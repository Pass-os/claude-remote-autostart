$outputFile = "C:\Users\softlive\claude-remote-output.txt"
$pidFile = "C:\Users\softlive\claude-remote-pid.txt"

# Remove arquivos anteriores
if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
if (Test-Path $pidFile) { Remove-Item $pidFile -Force }

# Inicia claude remote-control em background
$p = Start-Process `
    -FilePath "C:\Users\softlive\.local\bin\claude.exe" `
    -ArgumentList "remote-control", "--permission-mode", "bypassPermissions" `
    -WorkingDirectory "C:\Users\softlive" `
    -RedirectStandardOutput $outputFile `
    -WindowStyle Hidden `
    -PassThru

# Salva o PID
$p.Id | Out-File -FilePath $pidFile -Encoding ASCII -NoNewline
