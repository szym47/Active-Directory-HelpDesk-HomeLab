$WebhookUrl = $env:DISCORD_WEBHOOK_URL

# pobieramy wszystkich członków adminowej grupy w AD
$Admins = Get-ADGroupMember -Identity "Domain Admins"


foreach ($Admin in $Admins) {
    # domyślniee powinien być tylko wbudowany Administrator 
    if ($Admin.Name -ne "Administrator") {
        
        #  treść wiadomości
        $Message = "**ALARM BEZPIECZEŃSTWA (SOC)** `n Nieautoryzowane konto w grupie Domain Admins: **$($Admin.Name)**!"
        
        # pakujemy do formatu JSON
        $JSON = @{ content = $Message } | ConvertTo-Json
        
        # POST do API Discorda
        Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $JSON -ContentType "application/json"
        
        Write-Host "Wysłano alert o koncie: $($Admin.Name)" -ForegroundColor Red
    }
}