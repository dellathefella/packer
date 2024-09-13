# Enable TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# Speed up the invoke-webrequest command
$ProgressPreference = 'SilentlyContinue'

# Variables
$win11_downloadfolder = "C:\iso\"
$packer_config = "windows.json.pkr.hcl" #Packer config file
$packer_variable = "windows.auto.pkrvars.hcl" # Packer variable file

# Check if the temp folder exist
If(!(test-path -PathType container $win11_downloadfolder))
    {
      New-Item -ItemType Directory -Path $win11_downloadfolder
}

# Download the latest version of Packer
winget install Hashicorp.Packer

# Show Packer Version
packer -v

# Download Packer plugins
packer init "${$win11_downloadfolder}${packer_config}"

# Packer Format configuration files (.pkr.hcl) and variable files (.pkrvars.hcl) are updated.
packer fmt -var-file="${$win11_downloadfolder}{$packer_variable}" "${$win11_downloadfolder}${packer_config}"

# Packer validate
packer validate .

# Packer build
# packerbuild -force -var-file="${$win11_downloadfolder}${packer_variable}" -var "winrm_username=$env:winrm_admin" -var "winrm_password=$env:winrm_password" "${$win11_downloadfolder}${packer_config}"
packer build -force -var-file="${$win11_downloadfolder}${packer_variable}" "${$win11_downloadfolder}${packer_config}"