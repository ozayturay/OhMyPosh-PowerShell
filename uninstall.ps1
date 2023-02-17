Function Check-RunAsAdministrator()
{
  $CurrentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
  
  if(!$CurrentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator))
  {
    $ElevatedProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
    $ElevatedProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
    $ElevatedProcess.Verb = "runas"
    [System.Diagnostics.Process]::Start($ElevatedProcess)
    Exit
  }
}

$CHOCO = "$env:ProgramData\chocolatey\bin\choco.exe"

$OHMYPOSH = "$env:LocalAppData\Programs\oh-my-posh\bin\oh-my-posh.exe"
$ONELINETHEME = "$env:POSH_THEMES_PATH\quick-term-oneline.omp.json"

$CLINK = "$env:ProgramFiles(x86)\clink\clink.exe"
$CLINKSETUP = $PSScriptRoot + "\clink.1.4.19.57e404_setup.exe"
$CLINKLUA = "$env:LocalAppData\clink\oh-my-posh.lua"

$HACKFONT = $PSScriptRoot + "\hack-nerdfont.zip"
$PROFILEBAK = $PROFILE + ".bak"

$UNCHOCO = "$env:ProgramData\chocolatey"
$UNOHMYPOSH = "$env:LocalAppData\Programs\oh-my-posh\unins000.exe /verysilent"
$UNCLINK = "$env:ProgramFiles(x86)\clink\clink_uninstall_1.4.19.57e404.exe /S"
 
Check-RunAsAdministrator

Write-Host "Setting up required permissions..."
Set-ExecutionPolicy RemoteSigned
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Host ""

if (Test-Path -Path $PROFILE -PathType Leaf)
{
  Write-Host "Profile found, deleting and restoring backup..."
  Write-Host "Deleting profile..."
  Remove-Item $PROFILE
  Write-Host "Profile $PROFILE has been deleted!"
  
  if (Test-Path -Path $PROFILEBAK -PathType Leaf)
  {
    Write-Host "Old backup found, restoring..."  
    Get-Item -Path $PROFILEBAK | Move-Item -Destination $PROFILE
    Write-Host "Profile backup $PROFILEBAK has been restored!"
  }

  Write-Host ""
}

if (Get-Module -ListAvailable -Name Terminal-Icons)
{
  Write-Host "Terminal-Icons module is installed, uninstalling..."
  UnInstall-Module -Name Terminal-Icons
  Write-Host ""
}

if (Test-Path -Path $HACKFONT -PathType Leaf)
{
  Write-Host "Hack Nerd Font is present, deleting..."
  Remove-Item $HACKFONT
  Write-Host ""
}

if (Test-Path -Path $CLINKSETUP -PathType Leaf)
{
  Write-Host "Clink Setup is present, deleting..."
  Remove-Item $CLINKSETUP
  Write-Host ""
}

if (Test-Path -Path $CLINKLUA -PathType Leaf)
{
  Write-Host "Clink Lua Script is present, deleting..."
  Remove-Item $CLINKLUA
  Write-Host ""
}

if (Test-Path -Path $CLINK -PathType Leaf)
{
  Write-Host "Clink is installed, uninstalling..."
  Cmd /C $UNCLINK
  Write-Host ""
}

if (Test-Path -Path $ONELINETHEME -PathType Leaf)
{
  Write-Host "Quick-Term OneLine Theme is present, deleting..."
  Remove-Item $ONELINETHEME
  Write-Host ""
}

if (Test-Path -Path $OHMYPOSH -PathType Leaf)
{
  Write-Host "Oh-My-Posh is installed, uninstalling..."
  Cmd /C $UNOHMYPOSH
  Write-Host ""
}

if (Test-Path -Path $CHOCO -PathType Leaf)
{
  Write-Host "Chocolatey is installed, uninstalling..."
  Remove-Item $UNCHOCO -Recurse 
  Write-Host ""
}

Write-Host "UnInstallation finished."
Write-Host "Press any key to continue..."
Cmd /C "Pause >NUL"
Write-Host ""
