Invoke-Expression (& { (zoxide init powershell | Out-String) })

Set-Alias vim nvim

function pli { winget import -i C:\Users\duky8n\.local\share\chezmoi\.wingetfile.json }
function ple { nvim C:\Users\duky8n\.local\share\chezmoi\.wingetfile.json }