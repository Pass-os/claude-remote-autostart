Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$userHome   = $env:USERPROFILE
$installDir = "$userHome\claude-remote"
$startupLnk = [System.IO.Path]::Combine([Environment]::GetFolderPath('Startup'), 'claude-remote.lnk')

$lang = @{}
$lang['pt'] = @{
    LangTitle    = 'Escolha o idioma'
    LangDesc     = 'Selecione o idioma.'
    Title        = 'Desinstalar Claude Remote'
    Subtitle     = 'Desinstalador  v1.0.0'
    ConfTitle    = 'Confirmar desinstalacao'
    ConfDesc     = 'Os seguintes itens serao removidos permanentemente:'
    ConfFiles    = "Pasta de arquivos:"
    ConfStartup  = "Atalho de inicializacao:"
    ConfNotInst  = 'Claude Remote nao esta instalado neste computador.'
    BtnUninstall = 'Desinstalar'
    BtnCancel    = 'Cancelar'
    BtnBack      = 'Voltar'
    BtnClose     = 'Fechar'
    StepTitle    = 'Desinstalando...'
    StepDesc     = 'Removendo arquivos e atalhos.'
    StepProc     = 'Encerrando processo ativo'
    StepStartup  = 'Removendo atalho de inicializacao'
    StepFiles    = 'Removendo arquivos'
    StDone       = 'Removido'
    StSkipped    = 'Nao encontrado'
    StError      = 'Erro'
    StWaiting    = '...'
    DoneTitle    = 'Desinstalacao concluida!'
    DoneDesc     = 'Claude Remote foi removido do seu computador.'
}
$lang['en'] = @{
    LangTitle    = 'Choose language'
    LangDesc     = 'Select the language.'
    Title        = 'Uninstall Claude Remote'
    Subtitle     = 'Uninstaller  v1.0.0'
    ConfTitle    = 'Confirm uninstall'
    ConfDesc     = 'The following items will be permanently removed:'
    ConfFiles    = "Files folder:"
    ConfStartup  = "Startup shortcut:"
    ConfNotInst  = 'Claude Remote is not installed on this computer.'
    BtnUninstall = 'Uninstall'
    BtnCancel    = 'Cancel'
    BtnBack      = 'Back'
    BtnClose     = 'Close'
    StepTitle    = 'Uninstalling...'
    StepDesc     = 'Removing files and shortcuts.'
    StepProc     = 'Stopping active process'
    StepStartup  = 'Removing startup shortcut'
    StepFiles    = 'Removing files'
    StDone       = 'Removed'
    StSkipped    = 'Not found'
    StError      = 'Error'
    StWaiting    = '...'
    DoneTitle    = 'Uninstall complete!'
    DoneDesc     = 'Claude Remote has been removed from your computer.'
}

$script:T = $lang['pt']

$bg      = [System.Drawing.Color]::FromArgb(13,  17,  23)
$bgPanel = [System.Drawing.Color]::FromArgb(22,  27,  34)
$border  = [System.Drawing.Color]::FromArgb(48,  54,  61)
$fg      = [System.Drawing.Color]::FromArgb(230, 237, 243)
$fgMuted = [System.Drawing.Color]::FromArgb(139, 148, 158)
$green   = [System.Drawing.Color]::FromArgb(63,  185, 80)
$blue    = [System.Drawing.Color]::FromArgb(88,  166, 255)
$red     = [System.Drawing.Color]::FromArgb(248, 81,  73)

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
$form.Size            = New-Object System.Drawing.Size(460, 440)
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
$headerTitle = New-Label '' 20 14 380 28 $fontTitle $fg
$header.Controls.Add($headerTitle)
$headerSub = New-Label '' 20 44 200 18 $fontSmall $fgMuted
$header.Controls.Add($headerSub)

# Dots
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
        if ($i -lt $active)    { $dots[$i].BackColor = $green }
        elseif ($i -eq $active){ $dots[$i].BackColor = $blue  }
        else                   { $dots[$i].BackColor = $border }
    }
}

# Content
$contentY = 90
function New-Screen {
    $p = New-Object System.Windows.Forms.Panel
    $p.Location  = New-Object System.Drawing.Point(0, $contentY)
    $p.Size      = New-Object System.Drawing.Size(444, 260)
    $p.BackColor = $bg
    $p.Visible   = $false
    $form.Controls.Add($p)
    return $p
}

# Footer
$footer = New-Object System.Windows.Forms.Panel
$footer.Location  = New-Object System.Drawing.Point(0, 350)
$footer.Size      = New-Object System.Drawing.Size(444, 50)
$footer.BackColor = $bgPanel
$form.Controls.Add($footer)

function New-Btn($text, $x, $r, $g, $b2) {
    $col = [System.Drawing.Color]::FromArgb($r, $g, $b2)
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $text
    $b.Location  = New-Object System.Drawing.Point($x, 10)
    $b.Size      = New-Object System.Drawing.Size(120, 30)
    $b.FlatStyle = 'Flat'
    $b.Font      = $fontBold
    $b.ForeColor = $fg
    $b.BackColor = $col
    $b.FlatAppearance.BorderColor = $col
    $b.FlatAppearance.BorderSize  = 1
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    $footer.Controls.Add($b)
    return $b
}

$btnBack   = New-Btn '' 20  33  38  45
$btnAction = New-Btn '' 304 248 81  73

# Screen 0 - Idioma
$sLang = New-Screen
$sLang.Visible = $true
$sLangTitle = New-Label '' 20 10 400 26 $fontBold $fg
$sLangDesc  = New-Label '' 20 40 400 18 $fontMain $fgMuted
$sLang.Controls.Add($sLangTitle)
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
    ")
    $p.add_Click($click)
    $lt.add_Click($click)
    $ls.add_Click($click)
    $sLang.Controls.Add($p)
}

New-LangBtn 'Portugues (Brasil)' 'Desinstalar em portugues'  80 'pt'
New-LangBtn 'English'            'Uninstall in English'     142 'en'

# Screen 1 - Confirmacao
$sConf = New-Screen
$sConfTitle = New-Label '' 20 10 400 26 $fontBold $fg
$sConfDesc  = New-Label '' 20 38 400 18 $fontMain $fgMuted
$sConf.Controls.Add($sConfTitle)
$sConf.Controls.Add($sConfDesc)

$rowFiles = New-Object System.Windows.Forms.Panel
$rowFiles.Location  = New-Object System.Drawing.Point(0, 70)
$rowFiles.Size      = New-Object System.Drawing.Size(440, 38)
$rowFiles.BackColor = $bgPanel
$sConf.Controls.Add($rowFiles)
$rowFilesLabel = New-Label '' 14 10 130 20 $fontSmall $fgMuted
$rowFilesVal   = New-Label $installDir 150 10 270 20 $fontMono $fg
$rowFiles.Controls.Add($rowFilesLabel)
$rowFiles.Controls.Add($rowFilesVal)

$rowStartup = New-Object System.Windows.Forms.Panel
$rowStartup.Location  = New-Object System.Drawing.Point(0, 116)
$rowStartup.Size      = New-Object System.Drawing.Size(440, 38)
$rowStartup.BackColor = $bgPanel
$sConf.Controls.Add($rowStartup)
$rowStartupLabel = New-Label '' 14 10 130 20 $fontSmall $fgMuted
$rowStartupVal   = New-Label $startupLnk 150 10 270 20 $fontMono $fg
$rowStartup.Controls.Add($rowStartupLabel)
$rowStartup.Controls.Add($rowStartupVal)

$notInstalledLbl = New-Label '' 20 70 400 20 $fontMain $fgMuted
$sConf.Controls.Add($notInstalledLbl)

# Screen 2 - Progresso
$sStep = New-Screen
$sStepTitle = New-Label '' 20 10 300 26 $fontBold $fg
$sStepDesc  = New-Label '' 20 38 400 18 $fontMain $fgMuted
$sStep.Controls.Add($sStepTitle)
$sStep.Controls.Add($sStepDesc)
$stProc    = New-CheckRow $sStep '' 70
$stStartup = New-CheckRow $sStep '' 116
$stFiles   = New-CheckRow $sStep '' 162

$crProcLabel    = $sStep.Controls[2].Controls[0]
$crStartupLabel = $sStep.Controls[3].Controls[0]
$crFilesLabel   = $sStep.Controls[4].Controls[0]

# Screen 3 - Concluido
$sDone = New-Screen
$sDoneTitle = New-Label '' 20 30 400 30 $fontTitle $green
$sDoneDesc  = New-Label '' 20 70 400 40 $fontMain $fgMuted
$sDone.Controls.Add($sDoneTitle)
$sDone.Controls.Add($sDoneDesc)

# Aplicar idioma
function Apply-Lang {
    $T = $script:T
    $headerTitle.Text  = $T.Title
    $headerSub.Text    = $T.Subtitle
    $sLangTitle.Text   = $T.LangTitle
    $sLangDesc.Text    = $T.LangDesc
    $sConfTitle.Text   = $T.ConfTitle
    $sConfDesc.Text    = $T.ConfDesc
    $rowFilesLabel.Text   = $T.ConfFiles
    $rowStartupLabel.Text = $T.ConfStartup
    $sStepTitle.Text   = $T.StepTitle
    $sStepDesc.Text    = $T.StepDesc
    $crProcLabel.Text    = $T.StepProc
    $crStartupLabel.Text = $T.StepStartup
    $crFilesLabel.Text   = $T.StepFiles
    $sDoneTitle.Text   = $T.DoneTitle
    $sDoneDesc.Text    = $T.DoneDesc
    $btnBack.Text      = $T.BtnBack
}

# Navegacao
$screens = @($sLang, $sConf, $sStep, $sDone)
$script:currentScreen = 0

function Show-Screen($n) {
    foreach ($s in $screens) { $s.Visible = $false }
    $screens[$n].Visible = $true
    $script:currentScreen = $n
    Set-Dots $n
    $T = $script:T

    $isInstalled = (Test-Path $installDir) -or (Test-Path $startupLnk)

    switch ($n) {
        0 {
            $btnBack.Visible   = $false
            $btnAction.Visible = $false
        }
        1 {
            $btnBack.Visible   = $true
            $btnBack.Text      = $T.BtnBack
            if ($isInstalled) {
                $btnAction.Visible   = $true
                $btnAction.Text      = $T.BtnUninstall
                $btnAction.BackColor = [System.Drawing.Color]::FromArgb(248,81,73)
                $btnAction.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(248,81,73)
                $notInstalledLbl.Visible = $false
                $rowFiles.Visible        = $true
                $rowStartup.Visible      = $true
            } else {
                $btnAction.Visible       = $false
                $notInstalledLbl.Text    = $T.ConfNotInst
                $notInstalledLbl.Visible = $true
                $rowFiles.Visible        = $false
                $rowStartup.Visible      = $false
            }
        }
        2 {
            $btnBack.Visible   = $false
            $btnAction.Visible = $false
        }
        3 {
            $btnBack.Visible           = $false
            $btnAction.Visible         = $true
            $btnAction.Text      = $T.BtnClose
            $btnAction.BackColor = [System.Drawing.Color]::FromArgb(31,111,235)
            $btnAction.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(31,111,235)
        }
    }
}

$btnBack.add_Click({
    if ($script:currentScreen -eq 1) { Show-Screen 0 }
})

$btnAction.add_Click({
    switch ($script:currentScreen) {
        1 { Show-Screen 2; $form.Refresh(); Run-Uninstall }
        3 { $form.Close() }
    }
})

function Set-StepStatus($lbl, $text, $color) {
    $lbl.Text      = $text
    $lbl.ForeColor = $color
}

function Run-Uninstall {
    $T = $script:T

    # Encerrar processo ativo se houver flag
    $flagFile = "$installDir\claude-remote.running"
    $pidFile  = "$installDir\claude-remote.pid"
    try {
        if (Test-Path $flagFile) {
            $savedPid = (Get-Content $flagFile -Raw).Trim()
            if ($savedPid -match '^\d+$') {
                $proc = Get-Process -Id ([int]$savedPid) -ErrorAction SilentlyContinue
                if ($proc) {
                    Stop-Process -Id ([int]$savedPid) -Force -ErrorAction SilentlyContinue
                    Start-Sleep -Milliseconds 800
                }
            }
        }
        Set-StepStatus $stProc $T.StDone $green
    } catch {
        Set-StepStatus $stProc $T.StSkipped $fgMuted
    }

    # Remover atalho startup
    try {
        if (Test-Path $startupLnk) {
            Remove-Item $startupLnk -Force
            Set-StepStatus $stStartup $T.StDone $green
        } else {
            Set-StepStatus $stStartup $T.StSkipped $fgMuted
        }
    } catch {
        Set-StepStatus $stStartup $T.StError $red
    }

    # Remover pasta (tenta matar qualquer processo filho ainda aberto)
    try {
        if (Test-Path $installDir) {
            # Mata processos que possam estar com arquivos abertos na pasta
            Get-Process | Where-Object {
                try { $_.MainModule.FileName -like "$installDir*" } catch { $false }
            } | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500
            Remove-Item $installDir -Recurse -Force -ErrorAction Stop
            Set-StepStatus $stFiles $T.StDone $green
        } else {
            Set-StepStatus $stFiles $T.StSkipped $fgMuted
        }
    } catch {
        Set-StepStatus $stFiles $T.StError $red
    }

    Show-Screen 3
}

$form.Add_Shown({
    Apply-Lang
    Show-Screen 0
})

[System.Windows.Forms.Application]::Run($form)
