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

function Write-UTF8($text)
{
  $bytes = [System.Text.Encoding]::GetEncoding(1254).GetBytes($text)
  return [System.Text.Encoding]::UTF8.GetString($bytes)
}

Check-RunAsAdministrator

$CHOCO = ${env:PROGRAMDATA} + "\chocolatey\bin\choco.exe"

$OHMYPOSH = ${env:LOCALAPPDATA} + "\Programs\oh-my-posh\bin\oh-my-posh.exe"
$ONELINETHEME = ${env:POSH_THEMES_PATH} + "\quick-term-oneline.omp.json"

$CLINK = ${env:PROGRAMFILES(x86)} + "\clink\clink_x64.exe"
$CLINKSETUP = $PSSCRIPTROOT + "\clink_setup.exe"
$CLINKDATA = ${env:LOCALAPPDATA} + "\clink"
$CLINKLUA = $CLINKDATA + "\oh-my-posh.lua"

$HACKFONT = $PSSCRIPTROOT + "\hack-nerdfont.zip"
$PROFILEBAK = $PROFILE + ".bak"

$UNCHOCO = ${env:PROGRAMDATA} + "\chocolatey"
$UNOHMYPOSH = ${env:LOCALAPPDATA} + "\Programs\oh-my-posh\unins000.exe"
$UNCLINK = ${env:PROGRAMFILES(x86)} + "\clink\clink_uninstall_1.4.19.57e404.exe"

Write-Host "*************************************************************************"
Write-UTF8 "* OhMyPosh Enviroment Uninstaller Script by Özay Turay a.k.a Simon/CGTr *"
Write-Host "*************************************************************************"
Write-Host ""

Write-Host "Setting up required permissions..."
Set-ExecutionPolicy RemoteSigned
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Host ""

if (Test-Path -Path "$PROFILE" -PathType Leaf)
{
  Write-Host "Profile found at $PROFILE, deleting and restoring backup..."
  Write-Host "Deleting profile..."
  Remove-Item "$PROFILE"
  Write-Host "Profile $PROFILE has been deleted!"
  
  if (Test-Path -Path "$PROFILEBAK" -PathType Leaf)
  {
    Write-Host "Backup found at $PROFILEBAK, restoring..."  
    Get-Item -Path "$PROFILEBAK" | Move-Item -Destination "$PROFILE"
    Write-Host "Profile $PROFILE has been restored!"
  }

  Write-Host ""
}

if (Get-Module -ListAvailable -Name Terminal-Icons)
{
  Write-Host "Terminal-Icons module is installed, uninstalling..."
  UnInstall-Module -Name Terminal-Icons
  Write-Host ""
}

if (Test-Path -Path "$HACKFONT" -PathType Leaf)
{
  Write-Host "Hack Nerd Font is present at $HACKFONT, deleting..."
  Remove-Item "$HACKFONT"
  Write-Host ""
}

if (Test-Path -Path "$CLINKLUA" -PathType Leaf)
{
  Write-Host "Clink Lua Script is present at $CLINKLUA, deleting..."
  Remove-Item "$CLINKLUA"
  Write-Host ""
}

if (Test-Path -Path "$CLINK" -PathType Leaf)
{
  Write-Host "Clink is installed at $CLINK, uninstalling..."
  Start-Process -NoNewWindow -FilePath "$UNCLINK" -ArgumentList "/S" -Wait
  Write-Host "Clink data is installed at $CLINKDATA, deleting..."
  Remove-Item "$CLINKDATA" -Recurse 
  Write-Host ""
}

if (Test-Path -Path "$CLINKSETUP" -PathType Leaf)
{
  Write-Host "Clink Setup is present at $CLINKSETUP, deleting..."
  Remove-Item "$CLINKSETUP"
  Write-Host ""
}

if (Test-Path -Path "$ONELINETHEME" -PathType Leaf)
{
  Write-Host "Quick-Term OneLine Theme is present at $ONELINETHEME, deleting..."
  Remove-Item "$ONELINETHEME"
  Write-Host ""
}

if (Test-Path -Path "$OHMYPOSH" -PathType Leaf)
{
  Write-Host "Oh-My-Posh is installed at $OHMYPOSH, uninstalling..."
  Start-Process -NoNewWindow -FilePath "$UNOHMYPOSH" -ArgumentList "/verysilent" -Wait
  Write-Host ""
}

if (Test-Path -Path "$CHOCO" -PathType Leaf)
{
  Write-Host "Chocolatey is installed at $CHOCO, uninstalling..."
  Remove-Item "$UNCHOCO" -Recurse 
  Write-Host ""
}

Write-Host "Uninstallation finished."
Write-Host "Press any key to continue..."
Cmd /C "Pause >NUL"
Write-Host ""