// VM hardware specs
vm_name                          = "GI-W11-001"
vm_cpus                          = "16"
vm_memory                        = "12000"
vm_disk_size                     = "32000"
switch_name                      = "Default Switch"
dynamic_memory                   = "true"
secure_boot                      = "true"
tpm                              = "true"
generation                       = "2"
headless                         = "false"
skip_export                      = "false"
enable_virtualization_extensions = "false"
guest_additions_mode             = "disable"

// Use the NAT Network
// vm_network      = "VMnet8"

// WinRM 
winrm_username = "admin"
winrm_password = "password"

// Removeable media
win_iso = "D:/artifacts/iso/Win11_23H2_English_x64v2.iso"
// In Powershell use the "get-filehash" command to find the checksum of the ISO
win_checksum = "36de5ecb7a0daa58dce68c03b9465a543ed0f5498aa8ae60ab45fb7c8c4ae402"

// Output and temp directories; map this to an external drive if doing many repeated builds.
// Here I am mapping this to an external SSD
output_directory = "D:/artifacts/packer"
temp_path        = "D:/builds/packer/temp"
