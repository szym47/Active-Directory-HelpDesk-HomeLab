Write-Host "Uruchamianie konfiguracji drukarki sieciowej..." -ForegroundColor Cyan

# Parametry drukarki (zmienne)
$PrinterName = "Biuro_Drukarka_Glowna"
$PrinterIP = "10.0.0.50"
$DriverName = "Generic / Text Only"
$PortName = "IP_$PrinterIP"

# sprawdzamy czy drukarka już istnieje
$checkPrinter = Get-Printer -Name $PrinterName -ErrorAction SilentlyContinue

if ($checkPrinter) {
    Write-Host "Drukarka $PrinterName już istnieje. Przerwana instalacja, aby uniknac duplikatow." -ForegroundColor Yellow
} else {
    try {
        # tworzenie wirtualnego portu TCP/IP
        Write-Host "Krok 1: Tworzenie portu TCP/IP: $PortName..."
        Add-PrinterPort -Name $PortName -PrinterHostAddress $PrinterIP

        # instalacja sterownika
        Write-Host "Krok 2: Aktywacja sterownika: $DriverName..."
        Add-PrinterDriver -Name $DriverName

        # mapowanie drukarki
        Write-Host "Krok 3: Mapowanie drukarki: $PrinterName..."
        Add-Printer -Name $PrinterName -PortName $PortName -DriverName $DriverName

        Write-Host "SUKCES: Drukarka zostala pomyslnie zainstalowana i zmapowana!" -ForegroundColor Green
    } catch {
        Write-Error "Wystąpil krytyczny blad podczas instalacji drukarki: $_"
    }
}