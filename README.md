# Active Directory User Management Script

## Overview

This repository contains an **Active Directory User Management Script** designed to automate user account creation and Organizational Unit (OU) management in Microsoft Active Directory. The script simplifies administrative tasks by allowing you to:
- Create new Organizational Units (OUs) if they don’t already exist.
- Import user details from a CSV file and create corresponding user accounts in Active Directory.
- Automatically place users in the correct Organizational Unit based on their details in the CSV.
- Verify whether users already exist before creating them, avoiding duplicate accounts.

By automating these processes, this script can save you time and reduce the likelihood of errors that often arise from manual account creation.

**Repository:** [Lalatenduswain/Active-Directory-User-Management-Script](https://github.com/Lalatenduswain/Active-Directory-User-Management-Script/)  
**Author:** [Lalatendu Swain](https://github.com/Lalatenduswain)  
**Website:** [Blog](https://blog.lalatendu.info/)

---

## Prerequisites

Before you begin using the script, ensure the following prerequisites are met:

### Software Requirements

1. **PowerShell (for Windows)**  
   This script is written in PowerShell, which is natively available on Windows. If you're on Windows 10/11, PowerShell will already be installed. For Linux users, you may use **PowerShell Core**.

2. **Active Directory Module for PowerShell**  
   The script utilizes the **Active Directory PowerShell module** to interact with Active Directory. To install it on Windows:
   - For Windows 10/11, you can install the module by running:
     ```powershell
     Add-WindowsFeature RSAT-AD-PowerShell
     ```

3. **CSV File**  
   The script requires a CSV file with specific columns for user creation. Ensure your file is structured as shown in the example below:
   - **FirstName**: The user's first name.
   - **LastName**: The user's last name.
   - **UserName**: The user's login name (SamAccountName).
   - **Password**: The password for the account (in plain text).
   - **OU**: The Organizational Unit where the user will be placed (Distinguished Name format).
   - **Department**: The department the user belongs to.

### Permissions

To run the script successfully, ensure you have the following permissions:
- **Create Organizational Units (OUs)** in Active Directory.
- **Create and modify user accounts** in Active Directory.
- **Administrator-level access** on the machine running the script to execute PowerShell commands involving AD.

If you're running this from a Linux system, ensure you have **sudo** privileges and the correct PowerShell Core environment set up, as well as remote access to the AD server.

---

## How to Use the Script

### Step 1: Clone the Repository

First, clone the repository to your local machine:

```bash
git clone https://github.com/Lalatenduswain/Active-Directory-User-Management-Script/
cd Active-Directory-User-Management-Script/
```

### Step 2: Prepare the CSV File

Create a CSV file named `bulkuser.csv` with the following structure. Make sure each user entry contains the required details like first name, last name, username, password, OU, and department. Here’s an example:

```csv
FirstName,LastName,UserName,Password,OU,Department
John,Doe,john.doe,Pass@123,"OU=Sales,DC=example,DC=com",Sales
Jane,Smith,jane.smith,Pass@456,"OU=Marketing,DC=example,DC=com",Marketing
```

### Step 3: Review and Update the Script

Review the script `Active-Directory-User-Management.ps1` in the repository and make sure the file paths, domain names, and organizational units are correct for your environment.

### Step 4: Run the Script

Once your CSV file is ready, execute the script in PowerShell. The script will:
1. Check if the Organizational Units (OUs) specified in the CSV already exist. If not, it will create them.
2. Import user details from the CSV file and check if each user already exists in Active Directory.
3. Create the user accounts in their respective OUs based on the CSV data.

Run the script with the following PowerShell command:

```powershell
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
```

### Step 5: Verify Results

After the script runs, you can verify the OUs and user accounts with the following commands:

```powershell
# Verify OUs
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

# Verify Users
Get-ADUser -Filter * | Select-Object SamAccountName, Name, DistinguishedName
```

---

## Disclaimer | Running the Script

**Author:** Lalatendu Swain | [GitHub](https://github.com/Lalatenduswain) | [Website](https://blog.lalatendu.info/)

This script is provided "as-is" and may require modifications based on your environment. Ensure you test this script in a safe environment before deploying it in production. The author assumes no liability for any issues, data loss, or damage caused by using this script. Use it at your own risk.

## Donations

If you find this script helpful, you can show your appreciation by donating via [Buy Me a Coffee](https://www.buymeacoffee.com/lalatendu.swain).

## Support or Contact

If you encounter any issues or need help, feel free to open an issue on our [GitHub page](https://github.com/Lalatenduswain/+ScriptName/issues).

## Funding

You can support the development of this project through the following platforms:
- [GitHub Sponsors](https://github.com/Lalatenduswain)
- [Patreon](https://www.patreon.com/lalatenduswain)
- [Tidelift](https://tidelift.com/funding/latalendu/swain)
- [PayPal](https://www.paypal.com/paypalme/lalatenduswain)
- [Buy Me a Coffee](https://buymeacoffee.com/lalatendu.swain)
