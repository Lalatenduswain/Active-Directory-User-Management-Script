# Import Active Directory module
Import-Module ActiveDirectory

# Import the CSV file
$ADUsers = Import-Csv "C:\Path\To\Your\bulkuser.csv"

# Loop through each row in the CSV file and create users
foreach ($User in $ADUsers) {
    # Extract data from each row
    $Username   = $User.UserName
    $Password   = $User.Password
    $Firstname  = $User.FirstName
    $Lastname   = $User.LastName
    $OU         = $User.OU
    $Department = $User.Department

    # Check if the specified OU exists or default to "Users" container
    if ($OU -like "*CN=Users,*") {
        Write-Host "Placing $Username in the default Users container."
        $OU = "CN=Users,DC=example,DC=com" # Default container
    } elseif (-not (Get-ADOrganizationalUnit -Filter {DistinguishedName -eq $OU})) {
        Write-Warning "The specified OU $OU does not exist. Skipping user $Username."
        continue
    }

    # Check if the user already exists in AD
    if (Get-ADUser -Filter {SamAccountName -eq $Username}) {
        Write-Warning "A user account with username $Username already exists in Active Directory."
    } else {
        # Create a new user account
        Write-Host "Creating user: $Username in OU: $OU"
        New-ADUser `
            -SamAccountName $Username `
            -UserPrincipalName "$Username@example.com" `
            -Name "$Firstname $Lastname" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $true `
            -DisplayName "$Lastname, $Firstname" `
            -Path $OU `
            -Department $Department `
            -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -ChangePasswordAtLogon $true
    }
}
