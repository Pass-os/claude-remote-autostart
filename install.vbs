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

MsgBox "Claude Remote Auto-Start - Instalador" & vbCrLf & vbCrLf & _
    "Este instalador vai:" & vbCrLf & _
    "  1. Verificar se o Claude Code esta instalado e logado" & vbCrLf & _
    "  2. Copiar os arquivos para " & installDir & vbCrLf & _
    "  3. Configurar o Slack webhook" & vbCrLf & _
    "  4. Adicionar ao startup do Windows", _
    vbInformation, "Instalador"

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
Dim webhook
webhook = InputBox("Cole aqui o seu Slack Incoming Webhook URL:" & vbCrLf & vbCrLf & _
    "Exemplo: https://hooks.slack.com/services/XXX/YYY/ZZZ" & vbCrLf & vbCrLf & _
    "(Deixe em branco para pular - voce pode configurar depois)", _
    "Slack Webhook", "")

If webhook = "" Then
    Dim skipSlack
    skipSlack = MsgBox("Nenhum webhook informado. Continuar sem Slack?", vbYesNo + vbQuestion, "Slack")
    If skipSlack = vbNo Then WScript.Quit
End If

' --- Cria pasta de instalacao ---
If Not fso.FolderExists(installDir) Then fso.CreateFolder installDir

' --- Copia os arquivos ---
Dim vbsDest, ps1Dest
vbsDest = installDir & "\claude-remote.vbs"
ps1Dest = installDir & "\claude-remote-start.ps1"

Dim vbsSrc, ps1Src
vbsSrc = scriptDir & "\claude-remote.vbs"
ps1Src = scriptDir & "\claude-remote-start.ps1"

If Not fso.FileExists(vbsSrc) Or Not fso.FileExists(ps1Src) Then
    MsgBox "Arquivos do instalador nao encontrados." & vbCrLf & vbCrLf & _
        "Certifique-se de que claude-remote.vbs e claude-remote-start.ps1 estao na mesma pasta que o instalador.", _
        vbCritical, "Arquivos nao encontrados"
    WScript.Quit
End If

fso.CopyFile vbsSrc, vbsDest, True
fso.CopyFile ps1Src, ps1Dest, True

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
MsgBox "Instalacao concluida com sucesso!" & vbCrLf & vbCrLf & _
    "Arquivos instalados em:" & vbCrLf & _
    "  " & installDir & vbCrLf & vbCrLf & _
    "Atalho adicionado ao startup do Windows." & vbCrLf & vbCrLf & _
    "O Claude Remote sera iniciado automaticamente na proxima vez que o Windows ligar.", _
    vbInformation, "Instalacao concluida"

Set fso = Nothing
Set WshShell = Nothing
