$startupDir = Join-Path $env:USERPROFILE ".local\share\win-startup"
if (-not (Test-Path -Path $startupDir)) {
    exit 0
}

$items = Get-ChildItem -Path $startupDir -File | Sort-Object Name
foreach ($item in $items) {
    if ($item.Name -eq "win-startup-launcher.ps1") {
        continue
    }

    $ext = $item.Extension.ToLowerInvariant()
    switch ($ext) {
        ".ps1" {
            $args = "-NoProfile -ExecutionPolicy Bypass -File `"$($item.FullName)`""
            Start-Process -FilePath "powershell.exe" -ArgumentList $args
        }
        ".cmd" { Start-Process -FilePath $item.FullName }
        ".bat" { Start-Process -FilePath $item.FullName }
        ".exe" { Start-Process -FilePath $item.FullName }
        ".ahk" { Start-Process -FilePath $item.FullName }
        ".lnk" { Start-Process -FilePath $item.FullName }
        default { }
    }
}
