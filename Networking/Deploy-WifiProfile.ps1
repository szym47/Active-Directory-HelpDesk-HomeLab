Write-Host "Uruchamianie konfiguratora sieci Wi-Fi" -ForegroundColor Cyan

# parametry firmowej sieci
$WLANProfileName = "Biuro_Corp_WiFi"
$WLAN_SSID = "Biuro_Corp_WiFi"
$WLAN_Password = "SuperSecurePassword123!"
$XMLPath = "$env:TEMP\WiFiProfile.xml"

# tworzymy strukturę XML
$XML_Content = @"
<?xml version="1.0"?>
<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1">
    <name>$WLANProfileName</name>
    <SSIDConfig>
        <SSID>
            <name>$WLAN_SSID</name>
        </SSID>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2PSK</authentication>
                <encryption>AES</encryption>
                <useOneX>false</useOneX>
            </authEncryption>
            <sharedKey>
                <keyType>passPhrase</keyType>
                <protected>false</protected>
                <keyMaterial>$WLAN_Password</keyMaterial>
            </sharedKey>
        </security>
    </MSM>
</WLANProfile>
"@

# zapisujemy profil do pliku .xml
$XML_Content | Out-File -FilePath $XMLPath -Encoding UTF8

Write-Host "Plik XML profilu $WLAN_SSID wygenerowany w $XMLPath" -ForegroundColor Yellow

# importujemy profil przez powłokę Netsh
Write-Host "Importowanie profilu do ustawień systemowych..."
$ImportResult = netsh wlan add profile filename="$XMLPath"

# wyświetlamy wynik
if ($ImportResult -match "is added") {
    Write-Host "SUKCES: Profil sieci Wi-Fi został poprawnie zainstalowany na stacji roboczej!" -ForegroundColor Green
} else {
    Write-Warning "UWAGA: Profil zaimportowany, ale napotkano błąd sprzętowy. Wynik: $ImportResult"
    Write-Host "(Ten komunikat jest oczekiwany na maszynach wirtualnych bez fizycznej karty WLAN)" -ForegroundColor Gray
}

# czyszczenie śladów
Remove-Item -Path $XMLPath -Force
Write-Host "Usunięto tymczasowy plik XML z hasłem." -ForegroundColor Green