$source = $PSScriptRoot
$stage = Join-Path $env:TEMP 'KPFloatingPanel-plgx'
$plgx = "$stage.plgx"
$output = Join-Path $source 'dist'
$keepass = 'C:\Program Files\KeePass Password Safe 2\KeePass.exe'

$runningKeePass = Get-Process KeePass -ErrorAction SilentlyContinue
if ($runningKeePass) {
  throw 'Close KeePass before creating the PLGX package, then run build.ps1 again.'
}

Remove-Item -Recurse -Force $stage -ErrorAction SilentlyContinue
Remove-Item -Force $plgx -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $stage -Force | Out-Null
New-Item -ItemType Directory -Path $output -Force | Out-Null

robocopy $source $stage /E `
  /XD .git bin obj dist .vs `
  /XF *.dll *.pdb *.plgx *.user *.suo | Out-Null

& $keepass `
  --plgx-create $stage `
  --plgx-prereq-net:4.8.1 `
  --plgx-prereq-os:Windows

for ($i = 0; $i -lt 20 -and !(Test-Path $plgx); $i++) {
  Start-Sleep -Milliseconds 500
}

if (!(Test-Path $plgx)) {
  throw "KeePass did not create the expected PLGX file: $plgx"
}

Copy-Item $plgx (Join-Path $output 'KPFloatingPanel.plgx') -Force
