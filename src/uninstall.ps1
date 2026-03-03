Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$userHome   = $env:USERPROFILE
$installDir = "$userHome\claude-remote"
$startupLnk = [System.IO.Path]::Combine([Environment]::GetFolderPath('Startup'), 'claude-remote.lnk')

$lang = @{}
$lang['pt'] = @{
    Subtitle     = 'Desinstalador  v1.0.0'
    LangTitle    = 'Escolha o idioma'
    LangDesc     = 'Selecione o idioma.'
    ConfTitle    = 'Confirmar desinstalacao'
    ConfDesc     = 'Os seguintes itens serao removidos permanentemente:'
    ConfFiles    = 'Pasta de arquivos'
    ConfStartup  = 'Atalho de inicializacao'
    ConfNotInst  = 'Claude Remote nao esta instalado neste computador.'
    StepTitle    = 'Desinstalando...'
    StepDesc     = 'Removendo arquivos e atalhos.'
    StepProc     = 'Encerrando processo ativo'
    StepStartup  = 'Removendo atalho de inicializacao'
    StepFiles    = 'Removendo arquivos'
    DoneTitle    = 'Desinstalacao concluida!'
    DoneDesc     = 'Claude Remote foi removido do seu computador.'
    BtnUninstall = 'Desinstalar'
    BtnCancel    = 'Cancelar'
    BtnBack      = 'Voltar'
    BtnClose     = 'Fechar'
    StDone       = 'Removido'
    StSkipped    = 'Nao encontrado'
    StError      = 'Erro'
    StWaiting    = '...'
}
$lang['en'] = @{
    Subtitle     = 'Uninstaller  v1.0.0'
    LangTitle    = 'Choose language'
    LangDesc     = 'Select the language.'
    ConfTitle    = 'Confirm uninstall'
    ConfDesc     = 'The following items will be permanently removed:'
    ConfFiles    = 'Files folder'
    ConfStartup  = 'Startup shortcut'
    ConfNotInst  = 'Claude Remote is not installed on this computer.'
    StepTitle    = 'Uninstalling...'
    StepDesc     = 'Removing files and shortcuts.'
    StepProc     = 'Stopping active process'
    StepStartup  = 'Removing startup shortcut'
    StepFiles    = 'Removing files'
    DoneTitle    = 'Uninstall complete!'
    DoneDesc     = 'Claude Remote has been removed from your computer.'
    BtnUninstall = 'Uninstall'
    BtnCancel    = 'Cancel'
    BtnBack      = 'Back'
    BtnClose     = 'Close'
    StDone       = 'Removed'
    StSkipped    = 'Not found'
    StError      = 'Error'
    StWaiting    = '...'
}

$script:T = $lang['pt']

# Paleta Claude Dark
$bg       = [System.Drawing.Color]::FromArgb(26,  25,  21)
$bgPanel  = [System.Drawing.Color]::FromArgb(33,  32,  28)
$bgDark   = [System.Drawing.Color]::FromArgb(48,  46,  40)
$fgDark   = [System.Drawing.Color]::FromArgb(232, 229, 220)
$fgMuted  = [System.Drawing.Color]::FromArgb(140, 136, 120)
$accent   = [System.Drawing.Color]::FromArgb(217, 119, 87)
$accentDk = [System.Drawing.Color]::FromArgb(193, 95,  60)
$green    = [System.Drawing.Color]::FromArgb(130, 175, 100)
$red      = [System.Drawing.Color]::FromArgb(220, 100, 80)
$redBg    = [System.Drawing.Color]::FromArgb(55,  35,  25)

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

# Form
$form = New-Object System.Windows.Forms.Form
$form.Text            = 'Claude Remote Autostart'
$form.Size            = New-Object System.Drawing.Size(460, 440)
$form.StartPosition   = 'CenterScreen'
$form.BackColor       = $bg
$form.ForeColor       = $fgDark
$form.Font            = $fontMain
$form.FormBorderStyle = 'FixedSingle'
$form.MaximizeBox     = $false

# Header
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

# Dots
$dotsPanel = New-Object System.Windows.Forms.Panel
$dotsPanel.Location  = New-Object System.Drawing.Point(0, 72)
$dotsPanel.Size      = New-Object System.Drawing.Size(440, 18)
$dotsPanel.BackColor = $bg
$form.Controls.Add($dotsPanel)
$dots = @()
for ($i = 0; $i -lt 4; $i++) {
    $d = New-Object System.Windows.Forms.Panel
    $d.Size      = New-Object System.Drawing.Size(7, 7)
    $d.Location  = New-Object System.Drawing.Point((20 + $i * 14), 5)
    $d.BackColor = $bgDark
    $dotsPanel.Controls.Add($d)
    $dots += $d
}
function Set-Dots($active) {
    for ($i = 0; $i -lt 4; $i++) {
        if ($i -lt $active)    { $dots[$i].BackColor = $green  }
        elseif ($i -eq $active){ $dots[$i].BackColor = $accent }
        else                   { $dots[$i].BackColor = $bgDark }
    }
}
Set-Dots 0

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
$footer.add_Paint({
    param($s, $e)
    $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, 0, $s.Width, 0)
})
$form.Controls.Add($footer)

function New-Btn($text, $x, $isPrimary=$true) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text      = $text
    $b.Location  = New-Object System.Drawing.Point($x, 10)
    $b.Size      = New-Object System.Drawing.Size(120, 30)
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

$btnBack   = New-Btn '' 20  $false
$btnAction = New-Btn '' 304 $true
$btnBack.Visible   = $false
$btnAction.Visible = $false

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
    ")
    $p.add_Click($click); $lt.add_Click($click); $ls.add_Click($click)
    $sLang.Controls.Add($p)
}

New-LangBtn 'Portugues (Brasil)' 'Desinstalar em portugues'  76 'pt'
New-LangBtn 'English'            'Uninstall in English'     138 'en'

# Screen 1 - Confirmacao
$sConf = New-Screen
$sConfTitle = New-Label '' 20 12 400 28 $fontBold $fgDark
$sConfDesc  = New-Label '' 20 44 400 18 $fontUI $fgMuted
$sConf.Controls.Add($sConfTitle)
$sConf.Controls.Add($sConfDesc)

$rowFiles = New-Object System.Windows.Forms.Panel
$rowFiles.Location  = New-Object System.Drawing.Point(0, 72)
$rowFiles.Size      = New-Object System.Drawing.Size(440, 40)
$rowFiles.BackColor = $bgPanel
$rowFiles.add_Paint({
    param($s, $e)
    $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, $s.Height-1, $s.Width, $s.Height-1)
})
$sConf.Controls.Add($rowFiles)
$rowFilesLabel = New-Label '' 16 11 120 18 $fontSmall $fgMuted
$rowFilesVal   = New-Label $installDir 140 11 285 18 $fontMono $fgDark
$rowFiles.Controls.Add($rowFilesLabel)
$rowFiles.Controls.Add($rowFilesVal)

$rowStartup = New-Object System.Windows.Forms.Panel
$rowStartup.Location  = New-Object System.Drawing.Point(0, 112)
$rowStartup.Size      = New-Object System.Drawing.Size(440, 40)
$rowStartup.BackColor = $bgPanel
$rowStartup.add_Paint({
    param($s, $e)
    $e.Graphics.DrawLine([System.Drawing.Pen]::new($bgDark, 1), 0, $s.Height-1, $s.Width, $s.Height-1)
})
$sConf.Controls.Add($rowStartup)
$rowStartupLabel = New-Label '' 16 11 120 18 $fontSmall $fgMuted
$rowStartupVal   = New-Label $startupLnk 140 11 285 18 $fontMono $fgDark
$rowStartup.Controls.Add($rowStartupLabel)
$rowStartup.Controls.Add($rowStartupVal)

$notInstalledLbl = New-Label '' 20 72 400 20 $fontUI $fgMuted
$sConf.Controls.Add($notInstalledLbl)

# Screen 2 - Progresso
$sStep = New-Screen
$sStepTitle = New-Label '' 20 12 300 28 $fontBold $fgDark
$sStepDesc  = New-Label '' 20 44 400 18 $fontUI $fgMuted
$sStep.Controls.Add($sStepTitle)
$sStep.Controls.Add($sStepDesc)
$stProc    = New-CheckRow $sStep '' 72
$stStartup = New-CheckRow $sStep '' 112
$stFiles   = New-CheckRow $sStep '' 152

$crProcLabel    = $sStep.Controls[2].Controls[0]
$crStartupLabel = $sStep.Controls[3].Controls[0]
$crFilesLabel   = $sStep.Controls[4].Controls[0]

# Screen 3 - Concluido
$sDone = New-Screen
$accentBar = New-Object System.Windows.Forms.Panel
$accentBar.Location  = New-Object System.Drawing.Point(20, 22)
$accentBar.Size      = New-Object System.Drawing.Size(36, 4)
$accentBar.BackColor = $accent
$sDone.Controls.Add($accentBar)
$sDoneTitle = New-Label '' 20 36 400 32 $fontTitle $fgDark
$sDoneDesc  = New-Label '' 20 74 400 40 $fontUI $fgMuted
$sDone.Controls.Add($sDoneTitle)
$sDone.Controls.Add($sDoneDesc)

function Set-StepStatus($lbl, $text, $color) {
    $lbl.Text = $text; $lbl.ForeColor = $color
}

function Apply-Lang {
    $T = $script:T
    $headerSub.Text        = $T.Subtitle
    $sLangTitle.Text       = $T.LangTitle
    $sLangDesc.Text        = $T.LangDesc
    $sConfTitle.Text       = $T.ConfTitle
    $sConfDesc.Text        = $T.ConfDesc
    $rowFilesLabel.Text    = $T.ConfFiles
    $rowStartupLabel.Text  = $T.ConfStartup
    $sStepTitle.Text       = $T.StepTitle
    $sStepDesc.Text        = $T.StepDesc
    $crProcLabel.Text      = $T.StepProc
    $crStartupLabel.Text   = $T.StepStartup
    $crFilesLabel.Text     = $T.StepFiles
    $sDoneTitle.Text       = $T.DoneTitle
    $sDoneDesc.Text        = $T.DoneDesc
    $btnBack.Text          = $T.BtnBack
}

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
        0 { $btnBack.Visible = $false; $btnAction.Visible = $false }
        1 {
            $btnBack.Visible = $true
            if ($isInstalled) {
                $btnAction.Visible   = $true
                $btnAction.Text      = $T.BtnUninstall
                $btnAction.BackColor = $red
                $btnAction.FlatAppearance.BorderColor = $red
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
        2 { $btnBack.Visible = $false; $btnAction.Visible = $false }
        3 {
            $btnBack.Visible           = $false
            $btnAction.Visible         = $true
            $btnAction.Text            = $T.BtnClose
            $btnAction.BackColor       = $accent
            $btnAction.FlatAppearance.BorderColor = $accentDk
        }
    }
}

$btnBack.add_Click({ if ($script:currentScreen -eq 1) { Show-Screen 0 } })
$btnAction.add_Click({
    switch ($script:currentScreen) {
        1 { Show-Screen 2; $form.Refresh(); Run-Uninstall }
        3 { $form.Close() }
    }
})

function Run-Uninstall {
    $T = $script:T
    # Encerrar processo
    try {
        $flagFile = "$installDir\claude-remote.running"
        if (Test-Path $flagFile) {
            $savedPid = (Get-Content $flagFile -Raw).Trim()
            if ($savedPid -match '^\d+$') {
                Stop-Process -Id ([int]$savedPid) -Force -ErrorAction SilentlyContinue
                Start-Sleep -Milliseconds 800
            }
        }
        Set-StepStatus $stProc $T.StDone $green
    } catch { Set-StepStatus $stProc $T.StSkipped $fgMuted }

    # Remover atalho
    try {
        if (Test-Path $startupLnk) { Remove-Item $startupLnk -Force; Set-StepStatus $stStartup $T.StDone $green }
        else { Set-StepStatus $stStartup $T.StSkipped $fgMuted }
    } catch { Set-StepStatus $stStartup $T.StError $red }

    # Remover pasta
    try {
        if (Test-Path $installDir) {
            Get-Process | Where-Object {
                try { $_.MainModule.FileName -like "$installDir*" } catch { $false }
            } | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Milliseconds 500
            Remove-Item $installDir -Recurse -Force -ErrorAction Stop
            Set-StepStatus $stFiles $T.StDone $green
        } else { Set-StepStatus $stFiles $T.StSkipped $fgMuted }
    } catch { Set-StepStatus $stFiles $T.StError $red }

    Show-Screen 3
}

$form.Add_Shown({ Apply-Lang; Show-Screen 0 })
[System.Windows.Forms.Application]::Run($form)
