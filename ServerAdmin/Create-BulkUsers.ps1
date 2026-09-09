#biblioteka komend Active Directory
Import-Module ActiveDirectory

# wczytujemy dane z pliku csv
$dane = Import-Csv -Path "C:\Scripts\pracownicy.csv" -Delimiter ","

foreach ($pracownik in $dane) {
    
    # hasło startowe dla nowych pracowników
    $SecurePassword = ConvertTo-SecureString "Start123!" -AsPlainText -Force

    # towrzymy użytkownika i podstawiamy dane csv
    New-ADUser -Name "$($pracownik.Imie) $($pracownik.Nazwisko)" `
               -GivenName $pracownik.Imie `
               -Surname $pracownik.Nazwisko `
               -SamAccountName $pracownik.Login `
               -UserPrincipalName "$($pracownik.Login)@biuro.local" `
               -Path $pracownik.OU `
               -City $pracownik.Miasto `
               -Department $pracownik.Dzial `
               -AccountPassword $SecurePassword `
               -Enabled $true

    # dodajemy użytkownika od razu do jego grupy uprawnień
    Add-ADGroupMember -Identity $pracownik.Grupa -Members $pracownik.Login
    
    Write-Host "Pomyślnie utworzono konto dla: $($pracownik.Imie) $($pracownik.Nazwisko)" -ForegroundColor Green
}