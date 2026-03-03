$userHome = $env:USERPROFILE
$outputFile = "$userHome\claude-remote\claude-remote-output.txt"
$pidFile = "$userHome\claude-remote\claude-remote-pid.txt"

# Remove arquivos anteriores
if (Test-Path $outputFile) { Remove-Item $outputFile -Force }
if (Test-Path $pidFile) { Remove-Item $pidFile -Force }

# Inicia claude remote-control em background
$p = Start-Process `
    -FilePath "$userHome\.local\bin\claude.exe" `
    -ArgumentList "remote-control", "--permission-mode", "bypassPermissions" `
    -WorkingDirectory "$userHome\claude-remote" `
    -RedirectStandardOutput $outputFile `
    -WindowStyle Hidden `
    -PassThru

# Salva o PID
$p.Id | Out-File -FilePath $pidFile -Encoding ASCII -NoNewline
