Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias vim nvim

function pli { winget import -i C:\Users\duky8n\.local\share\chezmoi\.wingetfile.json }
function ple { nvim C:\Users\duky8n\.local\share\chezmoi\.wingetfile.json }

function y {
	$tmp = (New-TemporaryFile).FullName
	yazi.exe $args --cwd-file="$tmp"
	$cwd = Get-Content -Path $tmp -Encoding UTF8
	if ($cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
		Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
	}
	Remove-Item -Path $tmp
}
