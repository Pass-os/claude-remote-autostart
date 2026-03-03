Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$userHome   = $env:USERPROFILE
$installDir = "$userHome\claude-remote"
$claudePath = "$userHome\.local\bin\claude.exe"
$startupLnk = [System.IO.Path]::Combine(
    [Environment]::GetFolderPath('Startup'), 'claude-remote.lnk')
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path

$alreadyInstalled = Test-Path "$installDir\claude-remote.vbs"

# ── Colors & fonts ──────────────────────────────────────────────────────────
$bg      = [System.Drawing.Color]::FromArgb(13,  17,  23)
$bgPanel = [System.Drawing.Color]::FromArgb(22,  27,  34)
$border  = [System.Drawing.Color]::FromArgb(48,  54,  61)
$fg      = [System.Drawing.Color]::FromArgb(230, 237, 243)
$fgMuted = [System.Drawing.Color]::FromArgb(139, 148, 158)
$green   = [System.Drawing.Color]::FromArgb(63,  185, 80)
$blue    = [System.Drawing.Color]::FromArgb(88,  166, 255)
$red     = [System.Drawing.Color]::FromArgb(248, 81,  73)
$yellow  = [System.Drawing.Color]::FromArgb(210, 153, 34)

$fontMain  = New-Object System.Drawing.Font('Segoe UI', 10)
$fontBold  = New-Object System.Drawing.Font('Segoe UI', 10, [System.Drawing.FontStyle]::Bold)
$fontTitle = New-Object System.Drawing.Font('Segoe UI', 14, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font('Segoe UI', 8)
$fontMono  = New-Object System.Drawing.Font('Consolas', 9)

# ── Helper: styled label ─────────────────────────────────────────────────────
function New-Label($text, $x, $y, $w, $h, $font=$fontMain, $color=$fg) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text      = $text
    $l.Location  = New-Object System.Drawing.Point($x, $y)
    $l.Size      = New-Object System.Drawing.Size($w, $h)
    $l.Font      = $font
    $l.ForeColor = $color
    $l.BackColor = [System.Drawing.Color]::Transparent
    return $l
}

# ── Helper: check row ────────────────────────────────────────────────────────
function New-CheckRow($parent, $label, $y) {
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Location  = New-Object System.Drawing.Point(0, $y)
    $panel.Size      = New-Object System.Drawing.Size(440, 38)
    $panel.BackColor = $bgPanel

    $lbl = New-Label $label 14 10 280 20 $fontMain $fg
    $panel.Controls.Add($lbl)

    $status = New-Label '...' 310 10 116 20 $fontMain $fgMuted
    $status.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $panel.Controls.Add($status)

    $parent.Controls.Add($panel)
    return $status
}

# ════════════════════════════════════════════════════════════════════════════
# FORM
# ════════════════════════════════════════════════════════════════════════════
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'Claude Remote Autostart'
$form.Size            = New-Object System.Drawing.Size(460, 520)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $bg
$form.ForeColor       = $fg
$form.Font            = $fontMain
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox     = $false

# ── Header ───────────────────────────────────────────────────────────────────
$header = New-Object System.Windows.Forms.Panel
$header.Dock      = 'Top'
$header.Height    = 70
$header.BackColor = $bgPanel
$form.Controls.Add($header)

$lblTitle = New-Label 'Claude Remote Autostart' 20 14 320 28 $fontTitle $fg
$header.Controls.Add($lblTitle)

$lblSub = New-Label 'Installer  ·  v1.0.0' 20 44 200 18 $fontSmall $fgMuted
$header.Controls.Add($lblSub)

# ── Step dots ────────────────────────────────────────────────────────────────
$dotsPanel = New-Object System.Windows.Forms.Panel
$dotsPanel.Location  = New-Object System.Drawing.Point(0, 70)
$dotsPanel.Size      = New-Object System.Drawing.Size(440, 20)
$dotsPanel.BackColor = $bg
$form.Controls.Add($dotsPanel)

$dots = @()
for ($i = 0; $i -lt 4; $i++) {
    $d = New-Object System.Windows.Forms.Panel
    $d.Size      = New-Object System.Drawing.Size(8, 8)
    $d.Location  = New-Object System.Drawing.Point((20 + $i * 16), 6)
    $d.BackColor = $border
    $dotsPanel.Controls.Add($d)
    $dots += $d
}

function Set-Dots($active) {
    for ($i = 0; $i -lt 4; $i++) {
        if ($i -lt $active)   { $dots[$i].BackColor = $green }
        elseif ($i -eq $active) { $dots[$i].BackColor = $blue }
        else                  { $dots[$i].BackColor = $border }
    }
}
Set-Dots 0

# ── Content panels ───────────────────────────────────────────────────────────
$contentY = 90
$contentH = 340

function New-Screen {
    $p = New-Object System.Windows.Forms.Panel
    $p.Location  = New-Object System.Drawing.Point(0, $contentY)
    $p.Size      = New-Object System.Drawing.Size(444, $contentH)
    $p.BackColor = $bg
    $p.Visible   = $false
    $form.Controls.Add($p)
    return $p
}

# ── Footer ───────────────────────────────────────────────────────────────────
$footer = New-Object System.Windows.Forms.Panel
$footer.Location  = New-Object System.Drawing.Point(0, 430)
$footer.Size      = New-Object System.Drawing.Size(444, 50)
$footer.BackColor = $bgPanel
$form.Controls.Add($footer)

function New-Btn($text, $x, $primary=$true) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $text
    $b.Location  = New-Object System.Drawing.Point($x, 10)
    $b.Size      = New-Object System.Drawing.Size(110, 30)
    $b.FlatStyle = 'Flat'
    $b.Font      = $fontBold
    $b.ForeColor = $fg
    $b.BackColor = if ($primary) { [System.Drawing.Color]::FromArgb(35, 134, 54) } `
                   else          { [System.Drawing.Color]::FromArgb(33,  38,  45) }
    $b.FlatAppearance.BorderColor = if ($primary) { $green } else { $border }
    $b.FlatAppearance.BorderSize  = 1
    $b.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $footer.Controls.Add($b)
    return $b
}

$btnBack = New-Btn 'Back'    20  $false
$btnNext = New-Btn 'Next →' 314 $true
$btnBack.Visible = $false

# ════════════════════════════════════════════════════════════════════════════
# SCREEN 0 — Requirements
# ════════════════════════════════════════════════════════════════════════════
$s0 = New-Screen
$s0.Visible = $true

$s0Title = New-Label (if ($alreadyInstalled) {'Update Installation'} else {'Requirements'}) `
    20 10 400 26 $fontBold $fg
$s0.Controls.Add($s0Title)

$s0Desc = New-Label 'Checking your system before installation.' `
    20 38 400 18 $fontMain $fgMuted
$s0.Controls.Add($s0Desc)

$stClaude  = New-CheckRow $s0 'Claude Code installed'   70
$stLogin   = New-CheckRow $s0 'Logged in to Claude'    116
$stTrust   = New-CheckRow $s0 'Workspace trusted'      162

$alertBox = New-Object System.Windows.Forms.Panel
$alertBox.Location  = New-Object System.Drawing.Point(0, 215)
$alertBox.Size      = New-Object System.Drawing.Size(440, 60)
$alertBox.BackColor = $bg
$alertBox.Visible   = $false
$s0.Controls.Add($alertBox)

$alertLbl = New-Label '' 14 8 412 50 $fontSmall $red
$alertLbl.AutoSize = $false
$alertBox.Controls.Add($alertLbl)

function Show-Alert($msg, $color=$red) {
    $alertLbl.Text      = $msg
    $alertLbl.ForeColor = $color
    $alertBox.BackColor = [System.Drawing.Color]::FromArgb(45, 27, 27)
    $alertBox.Visible   = $true
}

function Set-CheckStatus($lbl, $text, $color) {
    $lbl.Text      = $text
    $lbl.ForeColor = $color
}

# ════════════════════════════════════════════════════════════════════════════
# SCREEN 1 — Slack
# ════════════════════════════════════════════════════════════════════════════
$s1 = New-Screen

$s1.Controls.Add((New-Label 'Slack Notifications' 20 10 250 26 $fontBold $fg))
$s1.Controls.Add((New-Label 'optional' 272 16 70 16 $fontSmall $fgMuted))
$s1.Controls.Add((New-Label "Receive the session URL on Slack when the service starts.`nAlready installed — Slack is optional, you can skip this step." `
    20 40 400 36 $fontMain $fgMuted))

$s1.Controls.Add((New-Label 'Incoming Webhook URL' 20 90 200 20 $fontBold $fg))

$hintLbl = New-Label "Don't have one? Create your app at api.slack.com/apps" `
    20 112 400 18 $fontSmall $fgMuted
$hintLbl.Cursor = [System.Windows.Forms.Cursors]::Hand
$hintLbl.add_Click({ Start-Process 'https://api.slack.com/apps' })
$s1.Controls.Add($hintLbl)

$webhookBox = New-Object System.Windows.Forms.TextBox
$webhookBox.Location  = New-Object System.Drawing.Point(20, 134)
$webhookBox.Size      = New-Object System.Drawing.Size(400, 26)
$webhookBox.BackColor = $bgPanel
$webhookBox.ForeColor = $fg
$webhookBox.BorderStyle = 'FixedSingle'
$webhookBox.Font      = $fontMono
$webhookBox.PlaceholderText = 'https://hooks.slack.com/services/...'
$s1.Controls.Add($webhookBox)

$skipLbl = New-Label 'Skip, configure later →' 20 170 200 18 $fontSmall $fgMuted
$skipLbl.Cursor = [System.Windows.Forms.Cursors]::Hand
$skipLbl.add_Click({
    $script:slackWebhook = ''
    Show-Screen 2
    $form.Refresh()
    Run-Install
})
$s1.Controls.Add($skipLbl)

# ════════════════════════════════════════════════════════════════════════════
# SCREEN 2 — Installing
# ════════════════════════════════════════════════════════════════════════════
$s2 = New-Screen

$s2.Controls.Add((New-Label 'Installing...' 20 10 300 26 $fontBold $fg))
$s2.Controls.Add((New-Label 'Copying files and configuring Windows Startup.' `
    20 38 400 18 $fontMain $fgMuted))

$stFiles   = New-CheckRow $s2 'Copying files'              70
$stStartup = New-CheckRow $s2 'Windows Startup shortcut'  116
$stSlack   = New-CheckRow $s2 'Slack webhook'             162

$alertInstall = New-Object System.Windows.Forms.Panel
$alertInstall.Location  = New-Object System.Drawing.Point(0, 215)
$alertInstall.Size      = New-Object System.Drawing.Size(440, 60)
$alertInstall.BackColor = $bg
$alertInstall.Visible   = $false
$s2.Controls.Add($alertInstall)

$alertInstallLbl = New-Label '' 14 8 412 50 $fontSmall $red
$alertInstallLbl.AutoSize = $false
$alertInstall.Controls.Add($alertInstallLbl)

# ════════════════════════════════════════════════════════════════════════════
# SCREEN 3 — Done
# ════════════════════════════════════════════════════════════════════════════
$s3 = New-Screen

$s3.Controls.Add((New-Label 'Installation complete!' 20 30 400 30 $fontTitle $green))
$s3.Controls.Add((New-Label "Claude Remote Autostart will launch automatically`nevery time Windows starts." `
    20 70 400 40 $fontMain $fgMuted))

$infoPath = New-Object System.Windows.Forms.Panel
$infoPath.Location  = New-Object System.Drawing.Point(0, 125)
$infoPath.Size      = New-Object System.Drawing.Size(440, 36)
$infoPath.BackColor = $bgPanel
$s3.Controls.Add($infoPath)

$infoPath.Controls.Add((New-Label 'Installed at' 14 8 100 20 $fontSmall $fgMuted))
$installPathLbl = New-Label $installDir 120 8 300 20 $fontMono $fg
$infoPath.Controls.Add($installPathLbl)

$infoSlack = New-Object System.Windows.Forms.Panel
$infoSlack.Location  = New-Object System.Drawing.Point(0, 169)
$infoSlack.Size      = New-Object System.Drawing.Size(440, 36)
$infoSlack.BackColor = $bgPanel
$infoSlack.Visible   = $false
$s3.Controls.Add($infoSlack)

$infoSlack.Controls.Add((New-Label 'Slack webhook' 14 8 120 20 $fontSmall $fgMuted))
$infoSlack.Controls.Add((New-Label 'Configured' 120 8 200 20 $fontMain $green))

# ════════════════════════════════════════════════════════════════════════════
# Navigation
# ════════════════════════════════════════════════════════════════════════════
$screens = @($s0, $s1, $s2, $s3)
$script:currentScreen = 0
$script:slackWebhook  = ''
$script:checksOk      = $false

function Show-Screen($n) {
    foreach ($s in $screens) { $s.Visible = $false }
    $screens[$n].Visible = $true
    $script:currentScreen = $n
    Set-Dots $n

    switch ($n) {
        0 {
            $btnBack.Visible = $false
            $btnNext.Text    = 'Check →'
            $btnNext.BackColor = [System.Drawing.Color]::FromArgb(35,134,54)
            $btnNext.Enabled = $script:checksOk
        }
        1 {
            $btnBack.Visible = $true
            $btnNext.Text    = 'Install →'
            $btnNext.Enabled = $true
        }
        2 {
            $btnBack.Visible = $false
            $btnNext.Text    = 'Installing...'
            $btnNext.Enabled = $false
        }
        3 {
            $btnBack.Visible = $false
            $btnNext.Text    = 'Close'
            $btnNext.BackColor = [System.Drawing.Color]::FromArgb(31,111,235)
            $btnNext.Enabled = $true
        }
    }
}

$btnBack.add_Click({ if ($script:currentScreen -eq 1) { Show-Screen 0 } })

$btnNext.add_Click({
    switch ($script:currentScreen) {
        0 { if ($script:checksOk) { Show-Screen 1 } }
        1 {
            $script:slackWebhook = $webhookBox.Text.Trim()
            Show-Screen 2
            $form.Refresh()
            Run-Install
        }
        3 { $form.Close() }
    }
})

# ════════════════════════════════════════════════════════════════════════════
# Checks
# ════════════════════════════════════════════════════════════════════════════
function Run-Checks {
    # 1. Claude installed
    if (-not (Test-Path $claudePath)) {
        Set-CheckStatus $stClaude 'Not found' $red
        Set-CheckStatus $stLogin  'Skipped'   $fgMuted
        Set-CheckStatus $stTrust  'Skipped'   $fgMuted
        Show-Alert "Claude Code not found.`nInstall it from claude.ai/code and re-run this installer."
        return
    }
    Set-CheckStatus $stClaude 'Found' $green

    # 2. Logged in (claude --version to temp file)
    $tmp = "$env:TEMP\claude-check-$PID.tmp"
    try {
        $p = Start-Process -FilePath $claudePath -ArgumentList '--version' `
            -RedirectStandardOutput $tmp -RedirectStandardError "$tmp.err" `
            -WindowStyle Hidden -PassThru -Wait
        $out = if (Test-Path $tmp) { (Get-Content $tmp -Raw).ToLower() } else { '' }
        Remove-Item $tmp, "$tmp.err" -ErrorAction SilentlyContinue
    } catch { $out = '' }

    if ($out -match 'not logged|please login') {
        Set-CheckStatus $stLogin 'Not logged in' $red
        Set-CheckStatus $stTrust 'Skipped'       $fgMuted
        Show-Alert "Claude Code is not logged in.`nOpen a terminal and run: claude login"
        return
    }
    Set-CheckStatus $stLogin 'OK' $green

    # 3. Workspace trust (read .claude.json)
    $trusted = $false
    $clauJson = "$userHome\.claude.json"
    if (Test-Path $clauJson) {
        try {
            $j = Get-Content $clauJson -Raw | ConvertFrom-Json
            $key = $userHome -replace '\\','/'
            if ($j.projects.$key.hasTrustDialogAccepted -eq $true) {
                $trusted = $true
            }
        } catch {}
    }

    if (-not $trusted) {
        Set-CheckStatus $stTrust 'Not trusted' $red
        Show-Alert "Workspace not trusted.`nOpen a terminal, go to your home folder, run 'claude' and accept the trust dialog." $yellow
        return
    }
    Set-CheckStatus $stTrust 'Trusted' $green

    $script:checksOk = $true
    $btnNext.Enabled = $true

    # Pre-fill webhook if reinstalling
    if ($alreadyInstalled) {
        try {
            $vbsContent = Get-Content "$installDir\claude-remote.vbs" -Raw
            if ($vbsContent -match 'slackWebhook = "([^"]*hooks\.slack\.com[^"]*)"') {
                $webhookBox.Text = $Matches[1]
            }
        } catch {}
    }
}

# ════════════════════════════════════════════════════════════════════════════
# Install
# ════════════════════════════════════════════════════════════════════════════
function Run-Install {
    $vbsSrc  = "$scriptDir\claude-remote.vbs"
    $ps1Src  = "$scriptDir\claude-remote-start.ps1"
    $traySrc = "$scriptDir\claude-remote-tray.ps1"

    # Check source files
    if (-not (Test-Path $vbsSrc) -or -not (Test-Path $ps1Src) -or -not (Test-Path $traySrc)) {
        $alertInstallLbl.Text = "Source files missing. Make sure all files are in the same folder as install.ps1"
        $alertInstall.Visible = $true
        $btnNext.Enabled = $true
        return
    }

    # Copy files
    try {
        if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }
        Copy-Item $vbsSrc  "$installDir\claude-remote.vbs"       -Force
        Copy-Item $ps1Src  "$installDir\claude-remote-start.ps1" -Force
        Copy-Item $traySrc "$installDir\claude-remote-tray.ps1"  -Force
        Set-CheckStatus $stFiles 'Done' $green
    } catch {
        Set-CheckStatus $stFiles 'Error' $red
        $alertInstallLbl.Text = "Failed to copy files: $_"
        $alertInstall.Visible = $true
        $btnNext.Enabled = $true
        return
    }

    # Patch paths in vbs
    try {
        $c = Get-Content "$installDir\claude-remote.vbs" -Raw
        $c = $c -replace [regex]::Escape('C:\Users\softlive'), $userHome
        if ($script:slackWebhook -match 'hooks\.slack\.com') {
            $c = $c -replace 'YOUR_SLACK_WEBHOOK_URL', $script:slackWebhook
        }
        Set-Content "$installDir\claude-remote.vbs" $c -Encoding UTF8
    } catch {}

    # Patch paths in ps1
    try {
        $c = Get-Content "$installDir\claude-remote-start.ps1" -Raw
        $c = $c -replace [regex]::Escape('C:\Users\softlive'), $userHome
        Set-Content "$installDir\claude-remote-start.ps1" $c -Encoding UTF8
    } catch {}

    # Startup shortcut
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $lnk = $wsh.CreateShortcut($startupLnk)
        $lnk.TargetPath       = "$installDir\claude-remote.vbs"
        $lnk.WorkingDirectory = $installDir
        $lnk.Save()
        Set-CheckStatus $stStartup 'Done' $green
    } catch {
        Set-CheckStatus $stStartup 'Error' $red
    }

    # Slack
    if ($script:slackWebhook -match 'hooks\.slack\.com') {
        Set-CheckStatus $stSlack 'Configured' $green
        $infoSlack.Visible = $true
    } else {
        Set-CheckStatus $stSlack 'Skipped' $fgMuted
    }

    $installPathLbl.Text = $installDir
    Show-Screen 3
}

# ════════════════════════════════════════════════════════════════════════════
# Start
# ════════════════════════════════════════════════════════════════════════════
$form.Add_Shown({
    $btnNext.Enabled = $false
    Run-Checks
})

[System.Windows.Forms.Application]::Run($form)
