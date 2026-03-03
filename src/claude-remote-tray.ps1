param(
    [string]$SessionUrl = "",
    [string]$FlagFile = "$env:USERPROFILE\claude-remote\claude-remote.running",
    [string]$LogFile = "$env:USERPROFILE\claude-remote\claude-remote.log"
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Cria icone na bandeja ---
$tray = New-Object System.Windows.Forms.NotifyIcon
$tray.Visible = $true

# Icone: circulo verde (ativo)
$bitmap = New-Object System.Drawing.Bitmap 16, 16
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.FillEllipse([System.Drawing.Brushes]::LimeGreen, 1, 1, 13, 13)
$g.DrawEllipse([System.Drawing.Pens]::DarkGreen, 1, 1, 13, 13)
$g.Dispose()
$tray.Icon = [System.Drawing.Icon]::FromHandle($bitmap.GetHicon())

# Tooltip
if ($SessionUrl -ne "") {
    $tray.Text = "Claude Remote Control`n$SessionUrl"
} else {
    $tray.Text = "Claude Remote Control - Ativo"
}

# --- Menu de contexto ---
$menu = New-Object System.Windows.Forms.ContextMenuStrip

# Item: abrir URL no browser
$itemOpen = New-Object System.Windows.Forms.ToolStripMenuItem
$itemOpen.Text = "Abrir no Browser"
$itemOpen.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
if ($SessionUrl -ne "") {
    $itemOpen.Add_Click({
        Start-Process $SessionUrl
    })
} else {
    $itemOpen.Enabled = $false
}
$menu.Items.Add($itemOpen) | Out-Null

# Item: copiar URL
$itemCopy = New-Object System.Windows.Forms.ToolStripMenuItem
$itemCopy.Text = "Copiar URL"
if ($SessionUrl -ne "") {
    $itemCopy.Add_Click({
        [System.Windows.Forms.Clipboard]::SetText($SessionUrl)
        $tray.ShowBalloonTip(2000, "Claude Remote", "URL copiada!", [System.Windows.Forms.ToolTipIcon]::Info)
    })
} else {
    $itemCopy.Enabled = $false
}
$menu.Items.Add($itemCopy) | Out-Null

$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator)) | Out-Null

# Item: reiniciar
$itemRestart = New-Object System.Windows.Forms.ToolStripMenuItem
$itemRestart.Text = "Reiniciar Servico"
$itemRestart.Add_Click({
    $tray.Visible = $false
    $vbsPath = "$env:USERPROFILE\claude-remote\claude-remote.vbs"
    $flagFile = "$env:USERPROFILE\claude-remote\claude-remote.running"
    # Para o processo atual se estiver rodando
    if (Test-Path $flagFile) {
        $savedPid = (Get-Content $flagFile -Raw).Trim()
        if ($savedPid -match '^\d+$') {
            Start-Process -FilePath "taskkill" -ArgumentList "/PID $savedPid /T /F" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
        }
        Remove-Item $flagFile -ErrorAction SilentlyContinue
    }
    Start-Sleep -Milliseconds 1000
    # Reinicia
    Start-Process -FilePath "wscript.exe" -ArgumentList "`"$vbsPath`""
    [System.Windows.Forms.Application]::Exit()
})
$menu.Items.Add($itemRestart) | Out-Null

# Item: parar
$itemStop = New-Object System.Windows.Forms.ToolStripMenuItem
$itemStop.Text = "Parar Claude Remote"
$itemStop.ForeColor = [System.Drawing.Color]::Red
$itemStop.Add_Click({
    $tray.Visible = $false
    $vbsPath = "$env:USERPROFILE\claude-remote\claude-remote.vbs"
    Start-Process -FilePath "wscript.exe" -ArgumentList "`"$vbsPath`""
    [System.Windows.Forms.Application]::Exit()
})
$menu.Items.Add($itemStop) | Out-Null

$tray.ContextMenuStrip = $menu

# Clique duplo: abre no browser
$tray.Add_DoubleClick({
    if ($SessionUrl -ne "") {
        Start-Process $SessionUrl
    }
})

# Balloon tip ao iniciar
$tray.ShowBalloonTip(3000, "Claude Remote Control", "Sessao ativa!`nClique duplo para abrir no browser.", [System.Windows.Forms.ToolTipIcon]::Info)

# --- Monitora se o processo ainda esta rodando ---
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 5000
$timer.Add_Tick({
    if (-not (Test-Path $FlagFile)) {
        $tray.Visible = $false
        [System.Windows.Forms.Application]::Exit()
    }
})
$timer.Start()

# --- Loop de mensagens ---
[System.Windows.Forms.Application]::Run()

$tray.Visible = $false
$tray.Dispose()
