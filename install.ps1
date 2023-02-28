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

$COREPATH = ${env:USERPROFILE} + "\Documents\Powershell"
$DESKPATH = ${env:USERPROFILE} + "\Documents\WindowsPowerShell"

Write-Host "***********************************************************************"
Write-UTF8 "* OhMyPosh Enviroment Installer Script by Özay Turay a.k.a Simon/CGTr *"
Write-Host "***********************************************************************"
Write-Host ""

Write-Host "Setting up required permissions..."
Set-ExecutionPolicy RemoteSigned
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Host ""

if (!(Test-Path -Path "$PROFILE" -PathType Leaf))
{
  Write-Host "Profile $PROFILE not found, creating..."
  try
  {
    if ("$PSVERSIONTABLE.PSEdition" -eq "Core" )
    {
      if (!(Test-Path -Path "$COREPATH"))
      {
        New-Item -Path "$COREPATH" -ItemType Directory
      }
    }
    elseif ("$PSVERSIONTABLE.PSEdition" -eq "Desktop")
    {
      if (!(Test-Path -Path "$DESKPATH"))
      {
        New-Item -Path "$DESKPATH" -ItemType Directory
      }
    }
    New-Item -PATH "$PROFILE" -ItemType File
    Write-Host "New profile $PROFILE has been created!"
  }
  catch
  {
    throw $_.Exception.Message
  }
}

Write-Host ""

if (Test-Path -Path "$CHOCO" -PathType Leaf)
{
  Write-Host "Chocolatey is installed at $CHOCO, skipping..."
}
else
{
  Write-Host "Chocolatey installation started..."
  Write-Host "Install Location: $CHOCO"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
  Write-Host "Chocolatey installation finished!"
}

Write-Host ""

if (Test-Path -Path "$OHMYPOSH" -PathType Leaf)
{
  Write-Host "Oh-My-Posh is installed at $OHMYPOSH, skipping..."
}
else
{
  Write-Host "Oh-My-Posh installation started..."
  Write-Host "Install Location: $OHMYPOSH"
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://ohmyposh.dev/install.ps1"))
  Write-Host "Oh-My-Posh installation finished!"
}

Write-Host ""

if (Test-Path -Path "$ONELINETHEME" -PathType Leaf)
{
  Write-Host "Quick-Term OneLine Theme is present at $ONELINETHEME, skip downloading..."
}
else
{
  Write-Host "Quick-Term OneLine Theme downloading started..."
  Write-Host "Theme File: $ONELINETHEME"
  Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-PowerShell/raw/main/quick-term-oneline.omp.json -o $ONELINETHEME
  Write-Host "Quick-Term OneLine Theme downloading finished!"
}

Write-Host ""

if (Test-Path -Path "$CLINKSETUP" -PathType Leaf)
{
  Write-Host "Clink Setup is present at $CLINKSETUP, skip downloading..."
}
else
{
  Write-Host "Clink Setup downloading started..."
  Write-Host "Setup File: $CLINKSETUP"
  Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-PowerShell/raw/main/clink_setup.exe -o $CLINKSETUP
  Write-Host "Clink Setup downloading finished!"
}

Write-Host ""

if (Test-Path -Path "$CLINK" -PathType Leaf)
{
  Write-Host "Clink is installed at $CLINK, skipping..."
}
else
{
  Write-Host "Clink installation started..."
  Write-Host "Install Location: $CLINK"
  Start-Process -NoNewWindow -FilePath "$CLINKSETUP" -ArgumentList "/S /ALLUSERS=1" -Wait
  Write-Host "Clink installation finished!"
}

Write-Host ""

if (Test-Path -Path "$CLINKLUA" -PathType Leaf)
{
  Write-Host "Clink Lua Script is present at $CLINKLUA, skip downloading..."
}
else
{
  Write-Host "Clink Lua Script downloading started..."
  Write-Host "Script File: $CLINKLUA"
  Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-PowerShell/raw/main/oh-my-posh.lua -o $CLINKLUA
  Write-Host "Clink Lua Script downloading finished!"
}

Write-Host ""
Write-Host "Please install a Nerd Font of your choice and configure your Terminal Program to use it."
Write-Host "Hack Nerd Font will be downloaded now as a sample Nerd Font for your convenience..."
Write-Host ""

if (Test-Path -Path "$HACKFONT" -PathType Leaf)
{
  Write-Host "Hack Nerd Font is present at $HACKFONT, skip downloading..."
}
else
{
  Write-Host "Hack Nerd Font downloading started..."
  Write-Host "Font File: $HACKFONT"
  Invoke-RestMethod https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip -o $HACKFONT
  Write-Host "Hack Nerd Font downloading finished!"
}

Write-Host ""

if (Get-Module -ListAvailable -Name Terminal-Icons)
{
  Write-Host "Terminal-Icons module is installed, skipping..."
}
else
{
  Write-Host "Terminal-Icons module installation started..."
  Install-Module -Name Terminal-Icons -Repository PSGallery
  Write-Host "Terminal-Icons module installation finished!"
}

Write-Host ""

Write-Host "Profile found at $PROFILE, backing up and replacing..."
if (Test-Path -Path "$PROFILEBAK" -PathType Leaf)
{
  Write-Host "Old backup found at $PROFILEBAK, skipping profile backup..."  
}
else
{
  Write-Host "Backing up profile..."
  Write-Host "Backup File: $PROFILEBAK"
  Get-Item -Path "$PROFILE" | Move-Item -Destination "$PROFILEBAK"
  Write-Host "Profile $PROFILE has been backed up!"
} 

Write-Host "Replacing profile..."
Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-PowerShell/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
Write-Host "Profile $PROFILE has been replaced!"
Write-Host ""

Write-Host "Installation finished."
Write-Host "Press any key to continue..."
Cmd /C "Pause >NUL"
Write-Host ""
