Dim WshShell, fso
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

' --- Paths ---
Dim userHome, startupPath, installDir
userHome = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")
startupPath = WshShell.SpecialFolders("Startup")
installDir = userHome & "\claude-remote"

Dim scriptDir
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

' --- Verifica se ja esta instalado ---
Dim alreadyInstalled
alreadyInstalled = fso.FileExists(installDir & "\claude-remote.vbs")

If alreadyInstalled Then
    Dim reInstall
    reInstall = MsgBox("Claude Remote ja esta instalado em:" & vbCrLf & installDir & vbCrLf & vbCrLf & _
        "Deseja atualizar/reinstalar?", vbYesNo + vbQuestion, "Ja instalado")
    If reInstall = vbNo Then WScript.Quit
End If

If Not alreadyInstalled Then
    MsgBox "Claude Remote Auto-Start - Instalador" & vbCrLf & vbCrLf & _
        "Este instalador vai:" & vbCrLf & _
        "  1. Verificar se o Claude Code esta instalado e logado" & vbCrLf & _
        "  2. Copiar os arquivos para " & installDir & vbCrLf & _
        "  3. Configurar o Slack webhook" & vbCrLf & _
        "  4. Adicionar ao startup do Windows", _
        vbInformation, "Instalador"
End If

' --- Verifica Claude instalado ---
Dim claudePath
claudePath = userHome & "\.local\bin\claude.exe"

If Not fso.FileExists(claudePath) Then
    MsgBox "Claude Code nao encontrado em:" & vbCrLf & claudePath & vbCrLf & vbCrLf & _
        "Instale o Claude Code em https://claude.ai/code e execute o instalador novamente.", _
        vbCritical, "Claude nao encontrado"
    WScript.Quit
End If

' --- Verifica se esta logado ---
Dim oExec, output
Set oExec = WshShell.Exec("powershell -NoProfile -NonInteractive -Command """ & _
    "& '" & claudePath & "' --version 2>&1" & """")
output = oExec.StdOut.ReadAll() & oExec.StdErr.ReadAll()

If InStr(LCase(output), "not logged") > 0 Or InStr(LCase(output), "login") > 0 Or InStr(LCase(output), "auth") > 0 Then
    MsgBox "O Claude Code nao esta logado." & vbCrLf & vbCrLf & _
        "Abra um terminal e execute:" & vbCrLf & _
        "  claude login" & vbCrLf & vbCrLf & _
        "Depois execute o instalador novamente.", _
        vbExclamation, "Login necessario"
    WScript.Quit
End If

' --- Verifica workspace trust ---
Dim oTrust
Set oTrust = WshShell.Exec("powershell -NoProfile -NonInteractive -Command """ & _
    "cd '" & userHome & "'; & '" & claudePath & "' remote-control --help 2>&1 | Select-String 'Workspace not trusted'" & """")
Dim trustOut
trustOut = oTrust.StdOut.ReadAll()

If InStr(trustOut, "Workspace not trusted") > 0 Then
    MsgBox "O workspace nao esta configurado." & vbCrLf & vbCrLf & _
        "Abra um terminal, va para sua pasta home e execute:" & vbCrLf & _
        "  cd " & userHome & vbCrLf & _
        "  claude" & vbCrLf & vbCrLf & _
        "Aceite o dialogo de workspace trust e depois execute o instalador novamente.", _
        vbExclamation, "Workspace nao configurado"
    WScript.Quit
End If

' --- Pede o Slack Webhook ---
' Se ja instalado, le o webhook atual como valor padrao
Dim existingWebhook
existingWebhook = ""
If alreadyInstalled Then
    On Error Resume Next
    Dim tsExisting
    Set tsExisting = fso.OpenTextFile(installDir & "\claude-remote.vbs", 1)
    Dim existingContent
    existingContent = tsExisting.ReadAll()
    tsExisting.Close
    Dim existingLines, el
    existingLines = Split(existingContent, vbLf)
    For el = 0 To UBound(existingLines)
        If InStr(existingLines(el), "slackWebhook =") > 0 And InStr(existingLines(el), "YOUR_SLACK_WEBHOOK_URL") = 0 Then
            existingWebhook = Trim(existingLines(el))
            existingWebhook = Mid(existingWebhook, InStr(existingWebhook, """") + 1)
            existingWebhook = Left(existingWebhook, Len(existingWebhook) - 1)
        End If
    Next
    On Error GoTo 0
End If

Dim webhook
webhook = InputBox("INSTALACAO CONCLUIDA!" & vbCrLf & _
    "Claude Remote foi instalado e sera iniciado automaticamente com o Windows." & vbCrLf & vbCrLf & _
    "SLACK (OPCIONAL)" & vbCrLf & _
    "Cole abaixo o seu Incoming Webhook URL para receber a URL da sessao no Slack." & vbCrLf & _
    "Nao tem um? Acesse api.slack.com/apps para criar." & vbCrLf & vbCrLf & _
    "Deixe em branco para pular.", _
    "Configurar Slack (opcional)", existingWebhook)

' --- Cria pasta de instalacao ---
If Not fso.FolderExists(installDir) Then fso.CreateFolder installDir

' --- Copia os arquivos ---
Dim vbsDest, ps1Dest, trayDest
vbsDest  = installDir & "\claude-remote.vbs"
ps1Dest  = installDir & "\claude-remote-start.ps1"
trayDest = installDir & "\claude-remote-tray.ps1"

Dim vbsSrc, ps1Src, traySrc
vbsSrc  = scriptDir & "\claude-remote.vbs"
ps1Src  = scriptDir & "\claude-remote-start.ps1"
traySrc = scriptDir & "\claude-remote-tray.ps1"

If Not fso.FileExists(vbsSrc) Or Not fso.FileExists(ps1Src) Or Not fso.FileExists(traySrc) Then
    MsgBox "Arquivos do instalador nao encontrados." & vbCrLf & vbCrLf & _
        "Certifique-se de que todos os arquivos estao na mesma pasta que o instalador.", _
        vbCritical, "Arquivos nao encontrados"
    WScript.Quit
End If

fso.CopyFile vbsSrc,  vbsDest,  True
fso.CopyFile ps1Src,  ps1Dest,  True
fso.CopyFile traySrc, trayDest, True

' --- Substitui webhook e paths no vbs copiado ---
Dim tsVbs, vbsContent
Set tsVbs = fso.OpenTextFile(vbsDest, 1)
vbsContent = tsVbs.ReadAll()
tsVbs.Close

vbsContent = Replace(vbsContent, "C:\Users\softlive", userHome)

If webhook <> "" Then
    vbsContent = Replace(vbsContent, "YOUR_SLACK_WEBHOOK_URL", webhook)
End If

Set tsVbs = fso.CreateTextFile(vbsDest, True)
tsVbs.Write vbsContent
tsVbs.Close

' --- Substitui paths no ps1 copiado ---
Dim tsPs1, ps1Content
Set tsPs1 = fso.OpenTextFile(ps1Dest, 1)
ps1Content = tsPs1.ReadAll()
tsPs1.Close

ps1Content = Replace(ps1Content, "C:\Users\softlive", userHome)

Set tsPs1 = fso.CreateTextFile(ps1Dest, True)
tsPs1.Write ps1Content
tsPs1.Close

' --- Cria atalho no startup apontando para installDir ---
Dim oShortcut
Set oShortcut = WshShell.CreateShortcut(startupPath & "\claude-remote.lnk")
oShortcut.TargetPath = vbsDest
oShortcut.WorkingDirectory = installDir
oShortcut.Save

' --- Concluido ---
MsgBox "Tudo pronto!" & vbCrLf & vbCrLf & _
    "O Claude Remote sera iniciado automaticamente na proxima vez que o Windows ligar." & vbCrLf & vbCrLf & _
    "Arquivos em: " & installDir, _
    vbInformation, "Claude Remote Autostart"

Set fso = Nothing
Set WshShell = Nothing
