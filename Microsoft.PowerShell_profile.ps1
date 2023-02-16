Import-Module -Name Terminal-Icons

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

function n { notepad $args }

function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

if (Test-Path "$env:USERPROFILE\Work Folders")
{
  New-PSDrive -Name Work -PSProvider FileSystem -Root "$env:USERPROFILE\Work Folders" -Description "Work Folders"
  function Work: { Set-Location Work: }
}

function prompt
{ 
  if ($isAdmin)
  {
    "[" + (Get-Location) + "] # " 
  }
  else
  {
    "[" + (Get-Location) + "] $ "
  }
}

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin)
{
  $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}

function dirs
{
  if ($args.Count -gt 0)
  {
    Get-ChildItem -Recurse -Include "$args" | Foreach-Object FullName
  }
  else
  {
    Get-ChildItem -Recurse | Foreach-Object FullName
  }
}

function admin
{
  if ($args.Count -gt 0)
  {   
    $argList = "& '" + $args + "'"
    Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $argList
  }
  else
  {
    Start-Process "$psHome\powershell.exe" -Verb runAs
  }
}

Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

function Edit-Profile
{
  if ($host.Name -match "ise")
  {
    $psISE.CurrentPowerShellTab.Files.Add($profile.CurrentUserAllHosts)
  }
  else
  {
    notepad $profile.CurrentUserAllHosts
  }
}

Remove-Variable identity
Remove-Variable principal

Function Test-CommandExists
{
  Param ($command)
  $oldPreference = $ErrorActionPreference
  $ErrorActionPreference = 'SilentlyContinue'
  try { if (Get-Command $command) { RETURN $true } }
  catch { Write-Host "$command does not exist"; RETURN $false }
  finally { $ErrorActionPreference = $oldPreference }
} 

if (Test-CommandExists code)
{
  $EDITOR='code'
}
elseif (Test-CommandExists notepad++)
{
  $EDITOR='notepad++'
}
elseif (Test-CommandExists notepad)
{
  $EDITOR='notepad'
}
elseif (Test-CommandExists nvim)
{
  $EDITOR='nvim'
}
elseif (Test-CommandExists pvim)
{
  $EDITOR='pvim'
}
elseif (Test-CommandExists vim)
{
  $EDITOR='vim'
}
elseif (Test-CommandExists vi)
{
  $EDITOR='vi'
}
elseif (Test-CommandExists sublime_text)
{
  $EDITOR='sublime_text'
}

Set-Alias -Name vim -Value $EDITOR


function ll { Get-ChildItem -Path $pwd -File }
function g { Set-Location $HOME\Documents\Github }
function gcom
{
  git add .
  git commit -m "$args"
}

function lazyg
{
  git add .
  git commit -m "$args"
  git push
}

function Get-PubIP
{
  (Invoke-WebRequest http://ifconfig.me/ip ).Content
}

function uptime
{
  Get-WmiObject win32_operatingsystem | Select-Object csname, @{
    LABEL = 'LastBootUpTime';
    EXPRESSION = { $_.ConverttoDateTime($_.lastbootuptime) }
  }
}

function reload-profile
{
  & $PROFILE
}

function find-file($name)
{
  Get-ChildItem -recurse -filter "*${name}*" -ErrorAction SilentlyContinue | ForEach-Object {
    $place_path = $_.directory
    Write-Output "${place_path}\${_}"
  }
}

function unzip ($file)
{
  Write-Output("Extracting", $file, "to", $pwd)
  $fullFile = Get-ChildItem -Path $pwd -Filter .\cove.zip | ForEach-Object { $_.FullName }
  Expand-Archive -Path $fullFile -DestinationPath $pwd
}

function grep($regex, $dir)
{
  if ($dir)
  {
    Get-ChildItem $dir | select-string $regex
    return
  }
  $input | select-string $regex
}

function touch($file)
{
  "" | Out-File $file -Encoding ASCII
}

function df
{
  get-volume
}

function sed($file, $find, $replace)
{
  (Get-Content $file).replace("$find", $replace) | Set-Content $file
}

function which($name)
{
  Get-Command $name | Select-Object -ExpandProperty Definition
}

function export($name, $value)
{
  set-item -force -path "env:$name" -value $value;
}

function pkill($name)
{
  Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
}

function pgrep($name)
{
  Get-Process $name
}

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/quick-term.omp.json" | Invoke-Expression

$ChocolateyProfile = "$env:CHOCOLATEYINSTALL\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile))
{
  Import-Module "$ChocolateyProfile"
}