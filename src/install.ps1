Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$userHome   = $env:USERPROFILE
$installDir = "$env:APPDATA\claude-remote"
$claudePath = "$userHome\.local\bin\claude.exe"
$startupLnk = [System.IO.Path]::Combine([Environment]::GetFolderPath('Startup'), 'claude-remote.lnk')
$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$alreadyInstalled = Test-Path "$installDir\claude-remote.vbs"

$lang = @{}
$lang['pt'] = @{
    Subtitle      = 'Instalador  v1.0.0'
    LangTitle     = 'Escolha o idioma'
    LangDesc      = 'Selecione o idioma do instalador.'
    ReqTitle      = 'Requisitos'
    ReqUpdate     = 'Atualizar instalacao'
    ReqDesc       = 'Verificando seu sistema antes da instalacao.'
    ReqClaude     = 'Claude Code instalado'
    ReqLogin      = 'Sessao iniciada'
    ReqTrust      = 'Workspace confiavel'
    ErrClaude     = "Claude Code nao encontrado.`nInstale em claude.ai/code e execute o instalador novamente."
    ErrLogin      = "Nao esta logado.`nAbra um terminal e execute: claude login"
    ErrTrust      = "Workspace ainda nao configurado - sera configurado automaticamente durante a instalacao."
    SlackTitle    = 'Notificacoes Slack'
    SlackOpt      = '(opcional)'
    SlackDesc     = "Receba a URL da sessao no Slack quando o servico iniciar.`nSlack e opcional - voce pode pular esta etapa."
    SlackLabel    = 'URL do Incoming Webhook'
    SlackHint     = 'Nao tem? Crie seu app em api.slack.com/apps'
    SlackSkip     = 'Pular, configurar depois'
    InstTitle     = 'Instalando...'
    InstDesc      = 'Copiando arquivos e configurando a inicializacao do Windows.'
    InstFiles     = 'Copiando arquivos'
    InstStartup   = 'Atalho de inicializacao'
    InstSlack     = 'Webhook do Slack'
    ErrSrcMissing = "Arquivos nao encontrados. Certifique-se de que todos os arquivos estao na pasta src/"
    DoneTitle     = 'Instalacao concluida!'
    DoneDesc      = "Claude Remote Autostart sera iniciado automaticamente`ncada vez que o Windows ligar."
    DoneAt        = 'Instalado em'
    DoneSlack     = 'Slack webhook'
    DoneSlackVal  = 'Configurado'
    BtnCheck      = 'Verificar >>'
    BtnInstall    = 'Instalar >>'
    BtnInstalling = 'Instalando...'
    BtnClose      = 'Fechar'
    BtnBack       = 'Voltar'
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
    Subtitle      = 'Installer  v1.0.0'
    LangTitle     = 'Choose language'
    LangDesc      = 'Select the installer language.'
    ReqTitle      = 'Requirements'
    ReqUpdate     = 'Update installation'
    ReqDesc       = 'Checking your system before installation.'
    ReqClaude     = 'Claude Code installed'
    ReqLogin      = 'Logged in to Claude'
    ReqTrust      = 'Workspace trusted'
    ErrClaude     = "Claude Code not found.`nInstall it from claude.ai/code and re-run the installer."
    ErrLogin      = "Not logged in.`nOpen a terminal and run: claude login"
    ErrTrust      = "Workspace not yet configured - will be configured automatically during installation."
    SlackTitle    = 'Slack Notifications'
    SlackOpt      = '(optional)'
    SlackDesc     = "Receive the session URL on Slack when the service starts.`nSlack is optional - you can skip this step."
    SlackLabel    = 'Incoming Webhook URL'
    SlackHint     = "Don't have one? Create your app at api.slack.com/apps"
    SlackSkip     = 'Skip, configure later'
    InstTitle     = 'Installing...'
    InstDesc      = 'Copying files and configuring Windows Startup.'
    InstFiles     = 'Copying files'
    InstStartup   = 'Windows Startup shortcut'
    InstSlack     = 'Slack webhook'
    ErrSrcMissing = "Source files missing. Make sure all files are in the src/ folder."
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

$script:T = $lang['pt']

# Paleta Claude Dark
$bg       = [System.Drawing.Color]::FromArgb(26,  25,  21)   # #1a1915
$bgPanel  = [System.Drawing.Color]::FromArgb(33,  32,  28)   # #21201c
$bgDark   = [System.Drawing.Color]::FromArgb(48,  46,  40)   # #302e28
$fgDark   = [System.Drawing.Color]::FromArgb(232, 229, 220)  # #e8e5dc off-white quente
$fgMuted  = [System.Drawing.Color]::FromArgb(140, 136, 120)  # muted quente
$accent   = [System.Drawing.Color]::FromArgb(217, 119, 87)   # #d97757 terra cotta
$accentDk = [System.Drawing.Color]::FromArgb(193, 95,  60)   # #c15f3c
$green    = [System.Drawing.Color]::FromArgb(130, 175, 100)  # verde suave
$red      = [System.Drawing.Color]::FromArgb(220, 100, 80)   # vermelho quente
$yellow   = [System.Drawing.Color]::FromArgb(200, 160, 70)   # amarelo quente

$fontMain  = New-Object System.Drawing.Font('Georgia', 10)
$fontBold  = New-Object System.Drawing.Font('Georgia', 10, [System.Drawing.FontStyle]::Bold)
$fontTitle = New-Object System.Drawing.Font('Georgia', 15, [System.Drawing.FontStyle]::Bold)
$fontSmall = New-Object System.Drawing.Font('Segoe UI', 8)
$fontMono  = New-Object System.Drawing.Font('Consolas', 9)
$fontUI    = New-Object System.Drawing.Font('Segoe UI', 9)
$fontUIB   = New-Object System.Drawing.Font('Segoe UI', 9, [System.Drawing.FontStyle]::Bold)

function New-Label($text, $x, $y, $w, $h, $font=$fontMain, $color=$fgDark) {
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
    $panel.Size      = New-Object System.Drawing.Size(440, 40)
    $panel.BackColor = $bgPanel
    $panel.add_Paint({
        param($s, $e)
        $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, $s.Height-1, $s.Width, $s.Height-1)
    })
    $lbl = New-Label $label 16 11 270 20 $fontUI $fgDark
    $panel.Controls.Add($lbl)
    $status = New-Label '...' 300 11 126 20 $fontUI $fgMuted
    $status.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
    $panel.Controls.Add($status)
    $parent.Controls.Add($panel)
    return $status
}

# Win32: cantos arredondados
Add-Type @'
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("gdi32.dll")] public static extern IntPtr CreateRoundRectRgn(int x1,int y1,int x2,int y2,int cx,int cy);
    [DllImport("user32.dll")] public static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);
}
'@

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'Claude Remote Autostart'
$form.Size            = New-Object System.Drawing.Size(460, 556)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $bg
$form.ForeColor       = $fgDark
$form.Font            = $fontMain
$form.FormBorderStyle = 'None'
$form.MaximizeBox     = $false

$form.add_Shown({
    Apply-Lang
    Show-Screen 0
    $rgn = [Win32]::CreateRoundRectRgn(0, 0, $form.Width + 1, $form.Height + 1, 20, 20)
    [Win32]::SetWindowRgn($form.Handle, $rgn, $true) | Out-Null
})


# Header (logo) - adicionado primeiro para ficar abaixo da titlebar (Dock=Top empilha de baixo pra cima)
$header = New-Object System.Windows.Forms.Panel
$header.Dock      = 'Top'
$header.Height    = 72
$header.BackColor = $bgPanel
$header.add_Paint({
    param($s, $e)
    $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, $s.Height-1, $s.Width, $s.Height-1)
})
$form.Controls.Add($header)
$headerTitle = New-Label 'Claude Remote Autostart' 20 14 380 30 $fontTitle $fgDark
$header.Controls.Add($headerTitle)
$headerSub = New-Label 'v1.0.0' 22 46 200 16 $fontSmall $fgMuted
$header.Controls.Add($headerSub)

# Titlebar customizada - adicionada por ultimo para ficar no topo
$titleBar = New-Object System.Windows.Forms.Panel
$titleBar.Dock      = 'Top'
$titleBar.Height    = 36
$titleBar.BackColor = $bgPanel
$form.Controls.Add($titleBar)

$titleLbl = New-Label 'Claude Remote Autostart' 14 9 320 18 $fontSmall $fgMuted
$titleBar.Controls.Add($titleLbl)

# Botao fechar
$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text      = 'x'
$btnClose.Size      = New-Object System.Drawing.Size(36, 36)
$btnClose.Location  = New-Object System.Drawing.Point(424, 0)
$btnClose.FlatStyle = 'Flat'
$btnClose.Font      = $fontUIB
$btnClose.ForeColor = $fgMuted
$btnClose.BackColor = $bgPanel
$btnClose.FlatAppearance.BorderSize = 0
$btnClose.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(180, 60, 40)
$btnClose.Cursor    = [System.Windows.Forms.Cursors]::Hand
$btnClose.add_Click({ $form.Close() })
$titleBar.Controls.Add($btnClose)

# Drag pela titlebar
$script:dragStart = $null
$titleBar.add_MouseDown({ param($s,$e) if ($e.Button -eq 'Left') { $script:dragStart = $e.Location } })
$titleBar.add_MouseMove({
    param($s,$e)
    if ($script:dragStart -and $e.Button -eq 'Left') {
        $form.Left += $e.X - $script:dragStart.X
        $form.Top  += $e.Y - $script:dragStart.Y
    }
})
$titleBar.add_MouseUp({ $script:dragStart = $null })
$titleLbl.add_MouseDown({ param($s,$e) if ($e.Button -eq 'Left') { $script:dragStart = $e.Location } })
$titleLbl.add_MouseMove({
    param($s,$e)
    if ($script:dragStart -and $e.Button -eq 'Left') {
        $form.Left += $e.X - $script:dragStart.X
        $form.Top  += $e.Y - $script:dragStart.Y
    }
})
$titleLbl.add_MouseUp({ $script:dragStart = $null })

# Dots
$dotsPanel = New-Object System.Windows.Forms.Panel
$dotsPanel.Location  = New-Object System.Drawing.Point(0, 108)
$dotsPanel.Size      = New-Object System.Drawing.Size(440, 18)
$dotsPanel.BackColor = $bg
$form.Controls.Add($dotsPanel)
$dots = @()
for ($i = 0; $i -lt 5; $i++) {
    $d = New-Object System.Windows.Forms.Panel
    $d.Size      = New-Object System.Drawing.Size(7, 7)
    $d.Location  = New-Object System.Drawing.Point((20 + $i * 14), 5)
    $d.BackColor = $bgDark
    $dotsPanel.Controls.Add($d)
    $dots += $d
}
function Set-Dots($active) {
    for ($i = 0; $i -lt 5; $i++) {
        if ($i -lt $active)    { $dots[$i].BackColor = $green  }
        elseif ($i -eq $active){ $dots[$i].BackColor = $accent }
        else                   { $dots[$i].BackColor = $bgDark }
    }
}
Set-Dots 0

$contentY = 126
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
$footer.Location  = New-Object System.Drawing.Point(0, 466)
$footer.Size      = New-Object System.Drawing.Size(444, 50)
$footer.BackColor = $bgPanel
$footer.add_Paint({
    param($s, $e)
    $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, 0, $s.Width, 0)
})
$form.Controls.Add($footer)

function New-Btn($text, $x, $isPrimary=$true) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $text
    $b.Location  = New-Object System.Drawing.Point($x, 10)
    $b.Size      = New-Object System.Drawing.Size(110, 30)
    $b.FlatStyle = 'Flat'
    $b.Font      = $fontUIB
    $b.Cursor    = [System.Windows.Forms.Cursors]::Hand
    if ($isPrimary) {
        $b.ForeColor = [System.Drawing.Color]::White
        $b.BackColor = $accent
        $b.FlatAppearance.BorderColor = $accentDk
        $b.FlatAppearance.MouseOverBackColor = $accentDk
    } else {
        $b.ForeColor = $fgDark
        $b.BackColor = $bgDark
        $b.FlatAppearance.BorderColor = $bgDark
        $b.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(220,218,208)
    }
    $b.FlatAppearance.BorderSize = 1
    $footer.Controls.Add($b)
    return $b
}

$btnBack = New-Btn 'Voltar' 20  $false
$btnNext = New-Btn 'OK >>'  314 $true
$btnBack.Visible = $false

# Screen 0 - Idioma
$sLang = New-Screen
$sLang.Visible = $true
$sLangTitle = New-Label '' 20 12 400 28 $fontBold $fgDark
$sLangDesc  = New-Label '' 20 44 400 18 $fontUI $fgMuted
$sLang.Controls.Add($sLangTitle)
$sLang.Controls.Add($sLangDesc)

function New-LangBtn($text, $sub, $y, $langKey) {
    $p = New-Object System.Windows.Forms.Panel
    $p.Location  = New-Object System.Drawing.Point(20, $y)
    $p.Size      = New-Object System.Drawing.Size(400, 54)
    $p.BackColor = $bgPanel
    $p.Cursor    = [System.Windows.Forms.Cursors]::Hand
    $p.add_Paint({
        param($s, $e)
        $e.Graphics.DrawRectangle([System.Drawing.Pen]::new($bgDark, 1), 0, 0, $s.Width-1, $s.Height-1)
    })
    $lt = New-Label $text 16 10 370 22 $fontUIB $fgDark
    $ls = New-Label $sub  16 32 370 16 $fontSmall $fgMuted
    $p.Controls.Add($lt)
    $p.Controls.Add($ls)
    $hoverColor = [System.Drawing.Color]::FromArgb(238, 236, 226)
    $p.add_MouseEnter({ param($sender, $e) $sender.BackColor = [System.Drawing.Color]::FromArgb(44, 43, 37) })
    $p.add_MouseLeave({ param($sender, $e) $sender.BackColor = [System.Drawing.Color]::FromArgb(33, 32, 28) })
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
}

New-LangBtn 'Portugues (Brasil)' 'Instalar em portugues'  76 'pt'
New-LangBtn 'English'            'Install in English'    138 'en'

# Screen 1 - Requisitos
$s0 = New-Screen
$s0Title = New-Label '' 20 12 400 28 $fontBold $fgDark
$s0Desc  = New-Label '' 20 44 400 18 $fontUI $fgMuted
$s0.Controls.Add($s0Title)
$s0.Controls.Add($s0Desc)
$stClaude = New-CheckRow $s0 '' 72
$stLogin  = New-CheckRow $s0 '' 112
$stTrust  = New-CheckRow $s0 '' 152

$crClaudeLabel = $s0.Controls[2].Controls[0]
$crLoginLabel  = $s0.Controls[3].Controls[0]
$crTrustLabel  = $s0.Controls[4].Controls[0]

$alertBox = New-Object System.Windows.Forms.Panel
$alertBox.Location  = New-Object System.Drawing.Point(0, 202)
$alertBox.Size      = New-Object System.Drawing.Size(440, 80)
$alertBox.BackColor = [System.Drawing.Color]::FromArgb(55, 35, 25)
$alertBox.Visible   = $false
$s0.Controls.Add($alertBox)
$alertLbl = New-Label '' 16 8 410 68 $fontSmall $red
$alertLbl.AutoSize = $false
$alertBox.Controls.Add($alertLbl)

function Show-Alert($msg, $color=$red) {
    $alertLbl.Text      = $msg
    $alertLbl.ForeColor = $color
    $alertBox.Visible   = $true
}
function Hide-Alert { $alertBox.Visible = $false }

function Set-CheckStatus($lbl, $text, $color) {
    $lbl.Text      = $text
    $lbl.ForeColor = $color
}

# Screen 2 - Slack
$s1 = New-Screen
$s1Title = New-Label '' 20 12 270 28 $fontBold $fgDark
$s1Opt   = New-Label '' 294 18 120 16 $fontSmall $fgMuted
$s1Desc  = New-Label '' 20 44 400 36 $fontUI $fgMuted
$s1Label = New-Label '' 20 90 200 20 $fontUIB $fgDark
$s1.Controls.Add($s1Title)
$s1.Controls.Add($s1Opt)
$s1.Controls.Add($s1Desc)
$s1.Controls.Add($s1Label)

$hintLbl = New-Label '' 20 112 400 18 $fontSmall $accent
$hintLbl.Cursor = [System.Windows.Forms.Cursors]::Hand
$hintLbl.add_Click({ Start-Process 'https://api.slack.com/apps' })
$s1.Controls.Add($hintLbl)

$webhookBox = New-Object System.Windows.Forms.TextBox
$webhookBox.Location    = New-Object System.Drawing.Point(20, 134)
$webhookBox.Size        = New-Object System.Drawing.Size(400, 24)
$webhookBox.BackColor   = $bgPanel
$webhookBox.ForeColor   = $fgDark
$webhookBox.BorderStyle = 'FixedSingle'
$webhookBox.Font        = $fontMono
$s1.Controls.Add($webhookBox)

$skipLbl = New-Label '' 20 168 250 18 $fontSmall $fgMuted
$skipLbl.Cursor = [System.Windows.Forms.Cursors]::Hand
$skipLbl.add_Click({
    $script:slackWebhook = ''
    Show-Screen 3
    $form.Refresh()
    Run-Install
})
$s1.Controls.Add($skipLbl)

# Screen 3 - Instalando
$s2 = New-Screen
$s2Title = New-Label '' 20 12 300 28 $fontBold $fgDark
$s2Desc  = New-Label '' 20 44 400 18 $fontUI $fgMuted
$s2.Controls.Add($s2Title)
$s2.Controls.Add($s2Desc)
$stFiles   = New-CheckRow $s2 '' 72
$stStartup = New-CheckRow $s2 '' 112
$stSlack   = New-CheckRow $s2 '' 152

$crFilesLabel   = $s2.Controls[2].Controls[0]
$crStartupLabel = $s2.Controls[3].Controls[0]
$crSlackLabel   = $s2.Controls[4].Controls[0]

$alertInstall = New-Object System.Windows.Forms.Panel
$alertInstall.Location  = New-Object System.Drawing.Point(0, 202)
$alertInstall.Size      = New-Object System.Drawing.Size(440, 56)
$alertInstall.BackColor = [System.Drawing.Color]::FromArgb(55, 35, 25)
$alertInstall.Visible   = $false
$s2.Controls.Add($alertInstall)
$alertInstallLbl = New-Label '' 16 8 410 44 $fontSmall $red
$alertInstallLbl.AutoSize = $false
$alertInstall.Controls.Add($alertInstallLbl)

# Screen 4 - Concluido
$s3 = New-Screen
$accentBar = New-Object System.Windows.Forms.Panel
$accentBar.Location  = New-Object System.Drawing.Point(20, 22)
$accentBar.Size      = New-Object System.Drawing.Size(36, 4)
$accentBar.BackColor = $accent
$s3.Controls.Add($accentBar)
$s3Title = New-Label '' 20 36 400 32 $fontTitle $fgDark
$s3Desc  = New-Label '' 20 74 400 40 $fontUI $fgMuted
$s3.Controls.Add($s3Title)
$s3.Controls.Add($s3Desc)

$infoPath = New-Object System.Windows.Forms.Panel
$infoPath.Location  = New-Object System.Drawing.Point(0, 124)
$infoPath.Size      = New-Object System.Drawing.Size(440, 38)
$infoPath.BackColor = $bgPanel
$infoPath.add_Paint({
    param($s, $e)
    $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, $s.Height-1, $s.Width, $s.Height-1)
})
$s3.Controls.Add($infoPath)
$infoAtLabel    = New-Label '' 16 10 110 18 $fontSmall $fgMuted
$installPathLbl = New-Label $installDir 130 10 295 18 $fontMono $fgDark
$infoPath.Controls.Add($infoAtLabel)
$infoPath.Controls.Add($installPathLbl)

$infoSlack = New-Object System.Windows.Forms.Panel
$infoSlack.Location  = New-Object System.Drawing.Point(0, 162)
$infoSlack.Size      = New-Object System.Drawing.Size(440, 38)
$infoSlack.BackColor = $bgPanel
$infoSlack.Visible   = $false
$s3.Controls.Add($infoSlack)
$infoSlackLabel = New-Label '' 16 10 110 18 $fontSmall $fgMuted
$infoSlackVal   = New-Label '' 130 10 200 18 $fontUI $green
$infoSlack.Controls.Add($infoSlackLabel)
$infoSlack.Controls.Add($infoSlackVal)

# Aplicar idioma
function Apply-Lang {
    $T = $script:T
    $headerSub.Text        = $T.Subtitle
    $sLangTitle.Text       = $T.LangTitle
    $sLangDesc.Text        = $T.LangDesc
    $s0Title.Text          = if ($alreadyInstalled) { $T.ReqUpdate } else { $T.ReqTitle }
    $s0Desc.Text           = $T.ReqDesc
    $crClaudeLabel.Text    = $T.ReqClaude
    $crLoginLabel.Text     = $T.ReqLogin
    $crTrustLabel.Text     = $T.ReqTrust
    $s1Title.Text          = $T.SlackTitle
    $s1Opt.Text            = $T.SlackOpt
    $s1Desc.Text           = $T.SlackDesc
    $s1Label.Text          = $T.SlackLabel
    $hintLbl.Text          = $T.SlackHint
    $skipLbl.Text          = $T.SlackSkip
    $s2Title.Text          = $T.InstTitle
    $s2Desc.Text           = $T.InstDesc
    $crFilesLabel.Text     = $T.InstFiles
    $crStartupLabel.Text   = $T.InstStartup
    $crSlackLabel.Text     = $T.InstSlack
    $s3Title.Text          = $T.DoneTitle
    $s3Desc.Text           = $T.DoneDesc
    $infoAtLabel.Text      = $T.DoneAt
    $infoSlackLabel.Text   = $T.DoneSlack
    $infoSlackVal.Text     = $T.DoneSlackVal
    $btnBack.Text          = $T.BtnBack
    $stClaude.Text = $T.StWaiting; $stLogin.Text = $T.StWaiting; $stTrust.Text = $T.StWaiting
    $stFiles.Text  = $T.StWaiting; $stStartup.Text = $T.StWaiting; $stSlack.Text = $T.StWaiting
}

# Navegacao
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
        0 { $btnBack.Visible = $false; $btnNext.Visible = $false }
        1 {
            $btnBack.Visible = $true;  $btnNext.Visible = $true
            $btnNext.Text    = $T.BtnCheck
            $btnNext.Enabled = $script:checksOk
        }
        2 {
            $btnBack.Visible = $true;  $btnNext.Visible = $true
            $btnNext.Text    = $T.BtnInstall
            $btnNext.Enabled = $true
        }
        3 { $btnBack.Visible = $false; $btnNext.Visible = $false }
        4 {
            $btnBack.Visible = $false; $btnNext.Visible = $true
            $btnNext.Text    = $T.BtnClose
            $btnNext.Enabled = $true
        }
    }
}

$btnBack.add_Click({
    switch ($script:currentScreen) {
        1 {
            $script:checksOk = $false
            $stClaude.Text = $script:T.StWaiting; $stClaude.ForeColor = $fgMuted
            $stLogin.Text  = $script:T.StWaiting; $stLogin.ForeColor  = $fgMuted
            $stTrust.Text  = $script:T.StWaiting; $stTrust.ForeColor  = $fgMuted
            Hide-Alert; Show-Screen 0
        }
        2 { Show-Screen 1 }
    }
})

$btnNext.add_Click({
    switch ($script:currentScreen) {
        1 { if ($script:checksOk) { Show-Screen 2 } }
        2 {
            $script:slackWebhook = $webhookBox.Text.Trim()
            Show-Screen 3; $form.Refresh(); Run-Install
        }
        4 { $form.Close() }
    }
})

function Run-Checks {
    $T = $script:T
    Hide-Alert
    if (-not (Test-Path $claudePath)) {
        Set-CheckStatus $stClaude $T.StNotFound $red
        Set-CheckStatus $stLogin  $T.StSkipped  $fgMuted
        Set-CheckStatus $stTrust  $T.StSkipped  $fgMuted
        Show-Alert $T.ErrClaude; return
    }
    Set-CheckStatus $stClaude $T.StFound $green

    $tmp = "$env:TEMP\claude-check-$PID.tmp"; $tmpErr = "$env:TEMP\claude-check-$PID.err"
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
        Show-Alert $T.ErrLogin; return
    }
    Set-CheckStatus $stLogin $T.StOk $green

    $trusted = $false
    if (Test-Path "$userHome\.claude.json") {
        try {
            $j = Get-Content "$userHome\.claude.json" -Raw | ConvertFrom-Json
            $key = $userHome -replace '\\','/'
            if ($j.projects.$key.hasTrustDialogAccepted -eq $true) { $trusted = $true }
        } catch {}
    }
    if (-not $trusted) {
        Set-CheckStatus $stTrust $T.StNotTrusted $yellow
        $msg = $T.ErrTrust -replace '%USERPROFILE%', $userHome
        Show-Alert $msg $yellow
    } else {
        Set-CheckStatus $stTrust $T.StTrusted $green
    }
    $script:checksOk = $true; $btnNext.Enabled = $true

    if ($alreadyInstalled) {
        try {
            $c = Get-Content "$installDir\claude-remote.vbs" -Raw
            if ($c -match 'slackWebhook = "([^"]*hooks\.slack\.com[^"]*)"') { $webhookBox.Text = $Matches[1] }
        } catch {}
    }
}

function Run-Install {
    $T = $script:T
    $vbsSrc     = "$scriptDir\claude-remote.vbs"
    $ps1Src     = "$scriptDir\claude-remote-start.ps1"
    $traySrc    = "$scriptDir\claude-remote-tray.ps1"
    $notifySrc  = "$scriptDir\claude-remote-notify.ps1"
    if (-not (Test-Path $vbsSrc) -or -not (Test-Path $ps1Src) -or -not (Test-Path $traySrc)) {
        $alertInstallLbl.Text = $T.ErrSrcMissing; $alertInstall.Visible = $true; return
    }
    try {
        if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }
        Copy-Item $vbsSrc  "$installDir\claude-remote.vbs"        -Force
        Copy-Item $ps1Src  "$installDir\claude-remote-start.ps1"  -Force
        Copy-Item $traySrc "$installDir\claude-remote-tray.ps1"   -Force
        if (Test-Path $notifySrc) { Copy-Item $notifySrc "$installDir\claude-remote-notify.ps1" -Force }
        Set-CheckStatus $stFiles $T.StDone $green
    } catch {
        Set-CheckStatus $stFiles $T.StError $red
        $alertInstallLbl.Text = "$($T.StError): $_"; $alertInstall.Visible = $true; return
    }
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    if ($script:slackWebhook -match 'hooks\.slack\.com') {
        try {
            $c = Get-Content "$installDir\claude-remote.vbs" -Raw
            $c = $c -replace 'YOUR_SLACK_WEBHOOK_URL', $script:slackWebhook
            [System.IO.File]::WriteAllText("$installDir\claude-remote.vbs", $c, $utf8NoBom)
        } catch {}
    }
    # Aceita o trust do workspace da pasta de instalacao
    try {
        $tmp = "$env:TEMP\claude-trust-$PID.txt"
        Start-Process -FilePath $claudePath -ArgumentList '-p', '""' `
            -WorkingDirectory $installDir `
            -RedirectStandardOutput $tmp -RedirectStandardError "$tmp.err" `
            -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
        Remove-Item $tmp, "$tmp.err" -ErrorAction SilentlyContinue
    } catch {}
    try {
        $wsh = New-Object -ComObject WScript.Shell
        $lnk = $wsh.CreateShortcut($startupLnk)
        $lnk.TargetPath = "$installDir\claude-remote.vbs"; $lnk.WorkingDirectory = $installDir; $lnk.Save()
        Set-CheckStatus $stStartup $T.StDone $green
    } catch { Set-CheckStatus $stStartup $T.StError $red }
    if ($script:slackWebhook -match 'hooks\.slack\.com') {
        Set-CheckStatus $stSlack $T.StConfigured $green; $infoSlack.Visible = $true
    } else { Set-CheckStatus $stSlack $T.StSkipped $fgMuted }
    $installPathLbl.Text = $installDir
    Show-Screen 4
}


[System.Windows.Forms.Application]::Run($form)
