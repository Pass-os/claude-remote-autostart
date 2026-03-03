Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$userHome   = $env:USERPROFILE
$installDir = "$userHome\claude-remote"
$claudePath = "$userHome\.local\bin\claude.exe"
$startupLnk = [System.IO.Path]::Combine([Environment]::GetFolderPath('Startup'), 'claude-remote.lnk')
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$alreadyInstalled = Test-Path "$installDir\claude-remote.vbs"

# Strings por idioma
$lang = @{}
$lang['pt'] = @{
    Title         = 'Claude Remote Autostart'
    Subtitle      = 'Instalador  v1.0.0'
    # Tela de idioma
    LangTitle     = 'Escolha o idioma'
    LangDesc      = 'Selecione o idioma do instalador.'
    # Tela 1 - Requisitos
    ReqTitle      = 'Requisitos'
    ReqUpdate     = 'Atualizar Instalacao'
    ReqDesc       = 'Verificando seu sistema antes da instalacao.'
    ReqClaude     = 'Claude Code instalado'
    ReqLogin      = 'Sessao iniciada'
    ReqTrust      = 'Workspace confiavel'
    ErrClaude     = "Claude Code nao encontrado.`nInstale em claude.ai/code e execute o instalador novamente."
    ErrLogin      = "Nao esta logado.`nAbra um terminal e execute: claude login"
    ErrTrust      = "Workspace nao configurado.`nAbra um terminal, va para sua pasta home, execute 'claude' e aceite o dialogo de confianca."
    # Tela 2 - Slack
    SlackTitle    = 'Notificacoes Slack  (opcional)'
    SlackDesc     = "Receba a URL da sessao no Slack quando o servico iniciar.`nSlack e opcional - voce pode pular esta etapa."
    SlackLabel    = 'URL do Incoming Webhook'
    SlackHint     = 'Nao tem? Crie seu app em api.slack.com/apps'
    SlackSkip     = 'Pular, configurar depois'
    # Tela 3 - Instalando
    InstTitle     = 'Instalando...'
    InstDesc      = 'Copiando arquivos e configurando a inicializacao do Windows.'
    InstFiles     = 'Copiando arquivos'
    InstStartup   = 'Atalho de inicializacao'
    InstSlack     = 'Webhook do Slack'
    ErrSrcMissing = "Arquivos nao encontrados. Certifique-se de que todos os arquivos estao na mesma pasta que install.ps1"
    # Tela 4 - Concluido
    DoneTitle     = 'Instalacao concluida!'
    DoneDesc      = "Claude Remote Autostart sera iniciado automaticamente`ncada vez que o Windows ligar."
    DoneAt        = 'Instalado em'
    DoneSlack     = 'Slack webhook'
    DoneSlackVal  = 'Configurado'
    # Botoes
    BtnCheck      = 'Verificar >>'
    BtnInstall    = 'Instalar >>'
    BtnInstalling = 'Instalando...'
    BtnClose      = 'Fechar'
    BtnBack       = 'Voltar'
    # Status
    StFound       = 'Encontrado'
    StNotFound    = 'Nao encontrado'
    StOk          = 'OK'
    StNotLogged   = 'Nao logado'
    StTrusted     = 'Confiavel'
    StNotTrusted  = 'Nao confiavel'
    StSkipped     = 'Ignorado'
    StDone        = 'Concluido'
    StError       = 'Erro'
    StConfigured  = 'Configurado'
    StWaiting     = '...'
}
$lang['en'] = @{
    Title         = 'Claude Remote Autostart'
    Subtitle      = 'Installer  v1.0.0'
    LangTitle     = 'Choose language'
    LangDesc      = 'Select the installer language.'
    ReqTitle      = 'Requirements'
    ReqUpdate     = 'Update Installation'
    ReqDesc       = 'Checking your system before installation.'
    ReqClaude     = 'Claude Code installed'
    ReqLogin      = 'Logged in to Claude'
    ReqTrust      = 'Workspace trusted'
    ErrClaude     = "Claude Code not found.`nInstall it from claude.ai/code and re-run the installer."
    ErrLogin      = "Not logged in.`nOpen a terminal and run: claude login"
    ErrTrust      = "Workspace not trusted.`nOpen a terminal, go to your home folder, run 'claude' and accept the trust dialog."
    SlackTitle    = 'Slack Notifications  (optional)'
    SlackDesc     = "Receive the session URL on Slack when the service starts.`nSlack is optional - you can skip this step."
    SlackLabel    = 'Incoming Webhook URL'
    SlackHint     = "Don't have one? Create your app at api.slack.com/apps"
    SlackSkip     = 'Skip, configure later'
    InstTitle     = 'Installing...'
    InstDesc      = 'Copying files and configuring Windows Startup.'
    InstFiles     = 'Copying files'
    InstStartup   = 'Windows Startup shortcut'
    InstSlack     = 'Slack webhook'
    ErrSrcMissing = "Source files missing. Make sure all files are in the same folder as install.ps1"
    DoneTitle     = 'Installation complete!'
    DoneDesc      = "Claude Remote Autostart will launch automatically`nevery time Windows starts."
    DoneAt        = 'Installed at'
    DoneSlack     = 'Slack webhook'
    DoneSlackVal  = 'Configured'
    BtnCheck      = 'Check >>'
    BtnInstall    = 'Install >>'
    BtnInstalling = 'Installing...'
    BtnClose      = 'Close'
    BtnBack       = 'Back'
    StFound       = 'Found'
    StNotFound    = 'Not found'
    StOk          = 'OK'
    StNotLogged   = 'Not logged in'
    StTrusted     = 'Trusted'
    StNotTrusted  = 'Not trusted'
    StSkipped     = 'Skipped'
    StDone        = 'Done'
    StError       = 'Error'
    StConfigured  = 'Configured'
    StWaiting     = '...'
}

$script:T = $lang['pt']  # padrao portugues

# Cores
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

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'Claude Remote Autostart'
$form.Size            = New-Object System.Drawing.Size(460, 520)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $bg
$form.ForeColor       = $fg
$form.Font            = $fontMain
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox     = $false

# Header
$header = New-Object System.Windows.Forms.Panel
$header.Dock      = 'Top'
$header.Height    = 70
$header.BackColor = $bgPanel
$form.Controls.Add($header)
$headerTitle = New-Label 'Claude Remote Autostart' 20 14 320 28 $fontTitle $fg
$header.Controls.Add($headerTitle)
$headerSub = New-Label 'v1.0.0' 20 44 200 18 $fontSmall $fgMuted
$header.Controls.Add($headerSub)

# Dots (5 agora: idioma + 4 telas)
$dotsPanel = New-Object System.Windows.Forms.Panel
$dotsPanel.Location  = New-Object System.Drawing.Point(0, 70)
$dotsPanel.Size      = New-Object System.Drawing.Size(440, 20)
$dotsPanel.BackColor = $bg
$form.Controls.Add($dotsPanel)
$dots = @()
for ($i = 0; $i -lt 5; $i++) {
    $d = New-Object System.Windows.Forms.Panel
    $d.Size      = New-Object System.Drawing.Size(8, 8)
    $d.Location  = New-Object System.Drawing.Point((20 + $i * 16), 6)
    $d.BackColor = $border
    $dotsPanel.Controls.Add($d)
    $dots += $d
}
function Set-Dots($active) {
    for ($i = 0; $i -lt 5; $i++) {
        if ($i -lt $active)    { $dots[$i].BackColor = $green }
        elseif ($i -eq $active){ $dots[$i].BackColor = $blue  }
        else                   { $dots[$i].BackColor = $border }
    }
}
Set-Dots 0

# Content
$contentY = 90
function New-Screen {
    $p = New-Object System.Windows.Forms.Panel
    $p.Location  = New-Object System.Drawing.Point(0, $contentY)
    $p.Size      = New-Object System.Drawing.Size(444, 340)
    $p.BackColor = $bg
    $p.Visible   = $false
    $form.Controls.Add($p)
    return $p
}

# Footer
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
    if ($primary) {
        $b.BackColor = [System.Drawing.Color]::FromArgb(35,134,54)
        $b.FlatAppearance.BorderColor = $green
    } else {
        $b.BackColor = [System.Drawing.Color]::FromArgb(33,38,45)
        $b.FlatAppearance.BorderColor = $border
    }
    $b.FlatAppearance.BorderSize = 1
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    $footer.Controls.Add($b)
    return $b
}

$btnBack = New-Btn 'Voltar' 20  $false
$btnNext = New-Btn 'OK >>'  314 $true
$btnBack.Visible = $false

# ── Screen 0 - Idioma ────────────────────────────────────────────────────────
$sLang = New-Screen
$sLang.Visible = $true

$sLangTitle = New-Label 'Escolha o idioma / Choose language' 20 10 400 26 $fontBold $fg
$sLang.Controls.Add($sLangTitle)
$sLangDesc = New-Label 'Selecione o idioma do instalador.' 20 40 400 18 $fontMain $fgMuted
$sLang.Controls.Add($sLangDesc)

function New-LangBtn($text, $sub, $y, $langKey) {
    $p = New-Object System.Windows.Forms.Panel
    $p.Location  = New-Object System.Drawing.Point(0, $y)
    $p.Size      = New-Object System.Drawing.Size(440, 54)
    $p.BackColor = $bgPanel
    $p.Cursor    = [System.Windows.Forms.Cursors]::Hand

    $lt = New-Label $text 16 8  400 22 $fontBold $fg
    $ls = New-Label $sub  16 30 400 16 $fontSmall $fgMuted
    $p.Controls.Add($lt)
    $p.Controls.Add($ls)

    $click = [scriptblock]::Create("
        `$script:T = `$lang['$langKey']
        Apply-Lang
        Show-Screen 1
        Run-Checks
    ")
    $p.add_Click($click)
    $lt.add_Click($click)
    $ls.add_Click($click)

    $sLang.Controls.Add($p)
    return $p
}

$btnPT = New-LangBtn 'Portugues (Brasil)' 'Instalar em portugues'  80 'pt'
$btnEN = New-LangBtn 'English'            'Install in English'    142 'en'

# Borda no PT por padrao
$btnPT.BorderStyle = 'FixedSingle'

# ── Screen 1 - Requisitos ────────────────────────────────────────────────────
$s0 = New-Screen
$s0Title = New-Label '' 20 10 400 26 $fontBold $fg
$s0.Controls.Add($s0Title)
$s0Desc = New-Label '' 20 38 400 18 $fontMain $fgMuted
$s0.Controls.Add($s0Desc)
$stClaude = New-CheckRow $s0 '' 70
$stLogin  = New-CheckRow $s0 '' 116
$stTrust  = New-CheckRow $s0 '' 162

$alertBox = New-Object System.Windows.Forms.Panel
$alertBox.Location  = New-Object System.Drawing.Point(0, 215)
$alertBox.Size      = New-Object System.Drawing.Size(440, 60)
$alertBox.BackColor = $bg
$alertBox.Visible   = $false
$s0.Controls.Add($alertBox)
$alertLbl = New-Label '' 14 8 412 48 $fontSmall $red
$alertLbl.AutoSize = $false
$alertBox.Controls.Add($alertLbl)

function Show-Alert($msg, $color=$red) {
    $alertLbl.Text      = $msg
    $alertLbl.ForeColor = $color
    $alertBox.BackColor = [System.Drawing.Color]::FromArgb(45,27,27)
    $alertBox.Visible   = $true
}
function Hide-Alert { $alertBox.Visible = $false }

function Set-CheckStatus($lbl, $text, $color) {
    $lbl.Text      = $text
    $lbl.ForeColor = $color
}

# Labels das check rows (para atualizar texto ao mudar idioma)
$crClaudeLabel  = $s0.Controls[2].Controls[0]
$crLoginLabel   = $s0.Controls[3].Controls[0]
$crTrustLabel   = $s0.Controls[4].Controls[0]

# ── Screen 2 - Slack ─────────────────────────────────────────────────────────
$s1 = New-Screen
$s1Title  = New-Label '' 20 10 380 26 $fontBold $fg
$s1Desc   = New-Label '' 20 40 400 36 $fontMain $fgMuted
$s1Label  = New-Label '' 20 90 200 20 $fontBold $fg
$s1.Controls.Add($s1Title)
$s1.Controls.Add($s1Desc)
$s1.Controls.Add($s1Label)

$hintLbl = New-Label '' 20 112 400 18 $fontSmall $blue
$hintLbl.Cursor = [System.Windows.Forms.Cursors]::Hand
$hintLbl.add_Click({ Start-Process 'https://api.slack.com/apps' })
$s1.Controls.Add($hintLbl)

$webhookBox = New-Object System.Windows.Forms.TextBox
$webhookBox.Location    = New-Object System.Drawing.Point(20, 134)
$webhookBox.Size        = New-Object System.Drawing.Size(400, 26)
$webhookBox.BackColor   = $bgPanel
$webhookBox.ForeColor   = $fg
$webhookBox.BorderStyle = 'FixedSingle'
$webhookBox.Font        = $fontMono
$s1.Controls.Add($webhookBox)

$skipLbl = New-Label '' 20 170 200 18 $fontSmall $fgMuted
$skipLbl.Cursor = [System.Windows.Forms.Cursors]::Hand
$skipLbl.add_Click({
    $script:slackWebhook = ''
    Show-Screen 3
    $form.Refresh()
    Run-Install
})
$s1.Controls.Add($skipLbl)

# ── Screen 3 - Instalando ────────────────────────────────────────────────────
$s2 = New-Screen
$s2Title = New-Label '' 20 10 300 26 $fontBold $fg
$s2Desc  = New-Label '' 20 38 400 18 $fontMain $fgMuted
$s2.Controls.Add($s2Title)
$s2.Controls.Add($s2Desc)
$stFiles   = New-CheckRow $s2 '' 70
$stStartup = New-CheckRow $s2 '' 116
$stSlack   = New-CheckRow $s2 '' 162

$crFilesLabel   = $s2.Controls[2].Controls[0]
$crStartupLabel = $s2.Controls[3].Controls[0]
$crSlackLabel   = $s2.Controls[4].Controls[0]

$alertInstall = New-Object System.Windows.Forms.Panel
$alertInstall.Location  = New-Object System.Drawing.Point(0, 215)
$alertInstall.Size      = New-Object System.Drawing.Size(440, 60)
$alertInstall.BackColor = $bg
$alertInstall.Visible   = $false
$s2.Controls.Add($alertInstall)
$alertInstallLbl = New-Label '' 14 8 412 48 $fontSmall $red
$alertInstallLbl.AutoSize = $false
$alertInstall.Controls.Add($alertInstallLbl)

# ── Screen 4 - Concluido ─────────────────────────────────────────────────────
$s3 = New-Screen
$s3Title = New-Label '' 20 30 400 30 $fontTitle $green
$s3Desc  = New-Label '' 20 70 400 40 $fontMain $fgMuted
$s3.Controls.Add($s3Title)
$s3.Controls.Add($s3Desc)

$infoPath = New-Object System.Windows.Forms.Panel
$infoPath.Location  = New-Object System.Drawing.Point(0, 125)
$infoPath.Size      = New-Object System.Drawing.Size(440, 36)
$infoPath.BackColor = $bgPanel
$s3.Controls.Add($infoPath)
$infoAtLabel    = New-Label '' 14 8 100 20 $fontSmall $fgMuted
$installPathLbl = New-Label $installDir 120 8 300 20 $fontMono $fg
$infoPath.Controls.Add($infoAtLabel)
$infoPath.Controls.Add($installPathLbl)

$infoSlack = New-Object System.Windows.Forms.Panel
$infoSlack.Location  = New-Object System.Drawing.Point(0, 169)
$infoSlack.Size      = New-Object System.Drawing.Size(440, 36)
$infoSlack.BackColor = $bgPanel
$infoSlack.Visible   = $false
$s3.Controls.Add($infoSlack)
$infoSlackLabel = New-Label '' 14 8 120 20 $fontSmall $fgMuted
$infoSlackVal   = New-Label '' 140 8 200 20 $fontMain $green
$infoSlack.Controls.Add($infoSlackLabel)
$infoSlack.Controls.Add($infoSlackVal)

# ── Aplicar idioma ───────────────────────────────────────────────────────────
function Apply-Lang {
    $T = $script:T
    # Header
    $headerSub.Text = $T.Subtitle
    # Req screen
    $s0Title.Text = if ($alreadyInstalled) { $T.ReqUpdate } else { $T.ReqTitle }
    $s0Desc.Text  = $T.ReqDesc
    $crClaudeLabel.Text  = $T.ReqClaude
    $crLoginLabel.Text   = $T.ReqLogin
    $crTrustLabel.Text   = $T.ReqTrust
    # Slack screen
    $s1Title.Text  = $T.SlackTitle
    $s1Desc.Text   = $T.SlackDesc
    $s1Label.Text  = $T.SlackLabel
    $hintLbl.Text  = $T.SlackHint
    $skipLbl.Text  = $T.SlackSkip
    # Install screen
    $s2Title.Text          = $T.InstTitle
    $s2Desc.Text           = $T.InstDesc
    $crFilesLabel.Text     = $T.InstFiles
    $crStartupLabel.Text   = $T.InstStartup
    $crSlackLabel.Text     = $T.InstSlack
    # Done screen
    $s3Title.Text        = $T.DoneTitle
    $s3Desc.Text         = $T.DoneDesc
    $infoAtLabel.Text    = $T.DoneAt
    $infoSlackLabel.Text = $T.DoneSlack
    $infoSlackVal.Text   = $T.DoneSlackVal
    # Botoes
    $btnBack.Text = $T.BtnBack
    # Status placeholders
    $stClaude.Text  = $T.StWaiting
    $stLogin.Text   = $T.StWaiting
    $stTrust.Text   = $T.StWaiting
    $stFiles.Text   = $T.StWaiting
    $stStartup.Text = $T.StWaiting
    $stSlack.Text   = $T.StWaiting
}

# ── Navegacao ────────────────────────────────────────────────────────────────
$screens = @($sLang, $s0, $s1, $s2, $s3)
$script:currentScreen = 0
$script:slackWebhook  = ''
$script:checksOk      = $false

function Show-Screen($n) {
    foreach ($s in $screens) { $s.Visible = $false }
    $screens[$n].Visible = $true
    $script:currentScreen = $n
    Set-Dots $n
    $T = $script:T
    switch ($n) {
        0 {
            $btnBack.Visible   = $false
            $btnNext.Text      = 'PT / EN'
            $btnNext.Enabled   = $false
            $btnNext.BackColor = [System.Drawing.Color]::FromArgb(33,38,45)
        }
        1 {
            $btnBack.Visible   = $true
            $btnNext.Text      = $T.BtnCheck
            $btnNext.BackColor = [System.Drawing.Color]::FromArgb(35,134,54)
            $btnNext.Enabled   = $script:checksOk
        }
        2 {
            $btnBack.Visible   = $true
            $btnNext.Text      = $T.BtnInstall
            $btnNext.BackColor = [System.Drawing.Color]::FromArgb(35,134,54)
            $btnNext.Enabled   = $true
        }
        3 {
            $btnBack.Visible   = $false
            $btnNext.Text      = $T.BtnInstalling
            $btnNext.Enabled   = $false
        }
        4 {
            $btnBack.Visible   = $false
            $btnNext.Text      = $T.BtnClose
            $btnNext.BackColor = [System.Drawing.Color]::FromArgb(31,111,235)
            $btnNext.Enabled   = $true
        }
    }
}

$btnBack.add_Click({
    switch ($script:currentScreen) {
        1 {
            # Volta para selecao de idioma, reseta checks
            $script:checksOk = $false
            $stClaude.Text = $script:T.StWaiting; $stClaude.ForeColor = $fgMuted
            $stLogin.Text  = $script:T.StWaiting; $stLogin.ForeColor  = $fgMuted
            $stTrust.Text  = $script:T.StWaiting; $stTrust.ForeColor  = $fgMuted
            Hide-Alert
            Show-Screen 0
        }
        2 { Show-Screen 1 }
    }
})
$btnNext.add_Click({
    switch ($script:currentScreen) {
        1 { if ($script:checksOk) { Show-Screen 2 } }
        2 {
            $script:slackWebhook = $webhookBox.Text.Trim()
            Show-Screen 3
            $form.Refresh()
            Run-Install
        }
        4 { $form.Close() }
    }
})

# ── Checks ───────────────────────────────────────────────────────────────────
function Run-Checks {
    $T = $script:T
    Hide-Alert

    if (-not (Test-Path $claudePath)) {
        Set-CheckStatus $stClaude $T.StNotFound $red
        Set-CheckStatus $stLogin  $T.StSkipped  $fgMuted
        Set-CheckStatus $stTrust  $T.StSkipped  $fgMuted
        Show-Alert $T.ErrClaude
        return
    }
    Set-CheckStatus $stClaude $T.StFound $green

    $tmp    = "$env:TEMP\claude-check-$PID.tmp"
    $tmpErr = "$env:TEMP\claude-check-$PID.err"
    try {
        Start-Process -FilePath $claudePath -ArgumentList '--version' `
            -RedirectStandardOutput $tmp -RedirectStandardError $tmpErr `
            -WindowStyle Hidden -Wait -ErrorAction Stop
        $out = if (Test-Path $tmp) { (Get-Content $tmp -Raw).ToLower() } else { '' }
    } catch { $out = '' }
    Remove-Item $tmp, $tmpErr -ErrorAction SilentlyContinue

    if ($out -match 'not logged|please login') {
        Set-CheckStatus $stLogin $T.StNotLogged $red
        Set-CheckStatus $stTrust $T.StSkipped   $fgMuted
        Show-Alert $T.ErrLogin
        return
    }
    Set-CheckStatus $stLogin $T.StOk $green

    $trusted  = $false
    $clauJson = "$userHome\.claude.json"
    if (Test-Path $clauJson) {
        try {
            $j   = Get-Content $clauJson -Raw | ConvertFrom-Json
            $key = $userHome -replace '\\','/'
            if ($j.projects.$key.hasTrustDialogAccepted -eq $true) { $trusted = $true }
        } catch {}
    }
    if (-not $trusted) {
        Set-CheckStatus $stTrust $T.StNotTrusted $red
        Show-Alert $T.ErrTrust $yellow
        return
    }
    Set-CheckStatus $stTrust $T.StTrusted $green

    $script:checksOk = $true
    $btnNext.Enabled = $true

    if ($alreadyInstalled) {
        try {
            $c = Get-Content "$installDir\claude-remote.vbs" -Raw
            if ($c -match 'slackWebhook = "([^"]*hooks\.slack\.com[^"]*)"') {
                $webhookBox.Text = $Matches[1]
            }
        } catch {}
    }
}

# ── Install ──────────────────────────────────────────────────────────────────
function Run-Install {
    $T = $script:T
    $vbsSrc  = "$scriptDir\claude-remote.vbs"
    $ps1Src  = "$scriptDir\claude-remote-start.ps1"
    $traySrc = "$scriptDir\claude-remote-tray.ps1"

    if (-not (Test-Path $vbsSrc) -or -not (Test-Path $ps1Src) -or -not (Test-Path $traySrc)) {
        $alertInstallLbl.Text = $T.ErrSrcMissing
        $alertInstall.Visible = $true
        $btnNext.Enabled      = $true
        return
    }

    try {
        if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }
        Copy-Item $vbsSrc  "$installDir\claude-remote.vbs"       -Force
        Copy-Item $ps1Src  "$installDir\claude-remote-start.ps1" -Force
        Copy-Item $traySrc "$installDir\claude-remote-tray.ps1"  -Force
        Set-CheckStatus $stFiles $T.StDone $green
    } catch {
        Set-CheckStatus $stFiles $T.StError $red
        $alertInstallLbl.Text = "$($T.StError): $_"
        $alertInstall.Visible = $true
        $btnNext.Enabled      = $true
        return
    }

    try {
        $c = Get-Content "$installDir\claude-remote.vbs" -Raw
        $c = $c -replace [regex]::Escape('C:\Users\softlive'), $userHome
        if ($script:slackWebhook -match 'hooks\.slack\.com') {
            $c = $c -replace 'YOUR_SLACK_WEBHOOK_URL', $script:slackWebhook
        }
        Set-Content "$installDir\claude-remote.vbs" $c -Encoding UTF8
    } catch {}

    try {
        $c = Get-Content "$installDir\claude-remote-start.ps1" -Raw
        $c = $c -replace [regex]::Escape('C:\Users\softlive'), $userHome
        Set-Content "$installDir\claude-remote-start.ps1" $c -Encoding UTF8
    } catch {}

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $lnk = $wsh.CreateShortcut($startupLnk)
        $lnk.TargetPath       = "$installDir\claude-remote.vbs"
        $lnk.WorkingDirectory = $installDir
        $lnk.Save()
        Set-CheckStatus $stStartup $T.StDone $green
    } catch {
        Set-CheckStatus $stStartup $T.StError $red
    }

    if ($script:slackWebhook -match 'hooks\.slack\.com') {
        Set-CheckStatus $stSlack $T.StConfigured $green
        $infoSlack.Visible = $true
    } else {
        Set-CheckStatus $stSlack $T.StSkipped $fgMuted
    }

    $installPathLbl.Text = $installDir
    Show-Screen 4
}

# ── Start ────────────────────────────────────────────────────────────────────
$form.Add_Shown({
    Apply-Lang
    Show-Screen 0
})

[System.Windows.Forms.Application]::Run($form)
