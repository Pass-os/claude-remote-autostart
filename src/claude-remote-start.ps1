$installDir = "$env:APPDATA\claude-remote"
$outputFile  = "$installDir\claude-remote-output.txt"
$pidFile     = "$installDir\claude-remote-pid.txt"

# Remove arquivos anteriores
if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
if (Test-Path $pidFile) { Remove-Item $pidFile -Force }

# Inicia claude remote-control em background
$p = Start-Process `
    -FilePath "$env:USERPROFILE\.local\bin\claude.exe" `
    -ArgumentList "remote-control", "--permission-mode", "bypassPermissions" `
    -WorkingDirectory $installDir `
    -RedirectStandardOutput $outputFile `
    -WindowStyle Hidden `
    -PassThru

# Salva o PID
$p.Id | Out-File -FilePath $pidFile -Encoding ASCII -NoNewline
