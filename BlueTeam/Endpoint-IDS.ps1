$WebhookUrl = "$env:DISCORD_WEBHOOK_IDS_URL"

$StartTime = (Get-Date).AddMinutes(-30) # logi do 30 min wstecz

Write-Host "Uruchamianie modułu Blue Team IDS..." -ForegroundColor Cyan

# lista wszystkich komputerów z AD
$Komputery = Get-ADComputer -Filter * | Select-Object -ExpandProperty Name

foreach ($Comp in $Komputery) {
    Write-Host "Skanowanie logów na stacji: $Comp..." -ForegroundColor Yellow
    
    # jeśli stacja jest wyłączona lub blokuje ją firewall, skrypt idzie dalej
    $Events = Get-WinEvent -ComputerName $Comp -FilterHashtable @{LogName='Security'; Id=4732; StartTime=$StartTime} -ErrorAction SilentlyContinue

   if ($Events) {
        foreach ($Event in $Events) {
            
            # Mapowanie indeksów
            $DodanySID = $Event.Properties[1].Value # SID dodanego użytkownika
            $Grupa = $Event.Properties[2].Value     # Nazwa grupy, do której go dodano
            $KtoDodal = $Event.Properties[6].Value  # nazwa użytkownika, który to zrobił

            # reaguj jeśli nazwa grupy zawiera słowo "Admin" 
            if ($Grupa -match "Admin") {
                $AlertText = "ALARM BLUE TEAM (SIEM)`nWykryto eskalację uprawnień!`nStacja: **$Comp**`nGrupa: **$Grupa**`nSID Atakującego: **$DodanySID**`nKto wykonal akcje: **$KtoDodal**"
                
                $Payload = @{ content = $AlertText }
                $JSON = $Payload | ConvertTo-Json -Compress
                
                Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $JSON -ContentType "application/json"
                Write-Host ">>> WYKRYTO ZAGROŻENIE NA $Comp! Alert wysłany. <<<" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Stacja $Comp czysta (lub brak połączenia)." -ForegroundColor Green
    }
}