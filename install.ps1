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

$OHMYPOSH = $env:LOCALAPPDATA + "\Programs\oh-my-posh\bin\oh-my-posh.exe"
$CHOCO = $env:PROGRAMDATA + "\chocolatey\bin\choco.exe"
$HACKFONT = $PSScriptRoot + "\hack-nerdfont.zip"
$ONELINETHEME = $env:POSH_THEMES_PATH + "\quick-term-oneline.omp.json"
$CLINKLUA = $env:LOCALAPPDATA + "\clink\oh-my-posh.lua"
$PROFILEBAK = $PROFILE + ".bak"

$COREPATH = $env:USERPROFILE + "\Documents\Powershell"
$DESKPATH = $env:USERPROFILE + "\Documents\WindowsPowerShell"

Check-RunAsAdministrator

Write-Host "Setting up required permissions..."
Set-ExecutionPolicy RemoteSigned
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Write-Host ""

if (!(Test-Path -Path $PROFILE -PathType Leaf))
{
  Write-Host "Profile not found, creating..."
  try
  {
    if ($PSVersionTable.PSEdition -eq "Core" )
    {
      if (!(Test-Path -Path $COREPATH))
      {
        New-Item -Path $COREPATH -ItemType "directory"
      }
    }
    elseif ($PSVersionTable.PSEdition -eq "Desktop")
    {
      if (!(Test-Path -Path $DESKPATH))
      {
        New-Item -Path $DESKPATH -ItemType "directory"
      }
    }
    New-Item -PATH $PROFILE -ItemType "file"
    Write-Host "New profile $PROFILE has been created!"
  }
  catch
  {
    throw $_.Exception.Message
  }
}

Write-Host ""

if (Test-Path -Path $OHMYPOSH -PathType Leaf)
{
  Write-Host "Oh-My-Posh is installed, skipping..."
}
else
{
  Write-Host "Oh-My-Posh installation started..."
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://ohmyposh.dev/install.ps1"))
  Write-Host "Oh-My-Posh installation finished!"
}

Write-Host ""

if (Test-Path -Path $CHOCO -PathType Leaf)
{
  Write-Host "Chocolatey is installed, skipping..."
}
else
{
  Write-Host "Chocolatey installation started..."
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))
  Write-Host "Chocolatey installation finished!"
}

Write-Host ""
Write-Host "!!! Please install a Nerd Font of your choice and configure your Terminal Program to use it."
Write-Host "!!! Hack Nerd Font will be downloaded now as a sample Nerd Font for your convenience..."
Write-Host ""

if (Test-Path -Path $HACKFONT -PathType Leaf)
{
  Write-Host "Hack Nerd Font is present, skip downloading..."
}
else
{
  Write-Host "Hack Nerd Font downloading started..."
  Invoke-RestMethod https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Hack.zip -o $HACKFONT
  Write-Host "Hack Nerd Font downloading finished!"
}

Write-Host ""

if (Test-Path -Path $ONELINETHEME -PathType Leaf)
{
  Write-Host "Quick-Term OneLine Theme is present, skip downloading..."
}
else
{
  Write-Host "Quick-Term OneLine Theme downloading started..."
  Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-Script/raw/main/quick-term-oneline.omp.json -o $ONELINETHEME
  Write-Host "Quick-Term OneLine Theme downloading finished!"
}

Write-Host ""

if (Test-Path -Path $CLINKLUA -PathType Leaf)
{
  Write-Host "Clink Lua Script is present, skip downloading..."
}
else
{
  Write-Host "Clink Lua Script downloading started..."
  Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-Script/raw/main/oh-my-posh.lua -o $CLINKLUA
  Write-Host "Clink Lua Script downloading finished!"
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

Write-Host "Profile found, backing up and replacing..."
if (Test-Path -Path $PROFILEBAK -PathType Leaf)
{
  Write-Host "Old backup found, skipping profile backup..."  
}
else
{
  Write-Host "Backing up profile..."
  Get-Item -Path $PROFILE | Move-Item -Destination $PROFILEBAK
} 

Write-Host "Replacing profile..."
Invoke-RestMethod https://github.com/ozayturay/OhMyPosh-Script/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
Write-Host "Profile $PROFILE has been replaced!"
Write-Host ""

Write-Host "Installation finished."
Write-Host "Press any key to continue..."
Cmd /C "Pause >NUL"
Write-Host ""