Dim WshShell, fso
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim userHome
userHome = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")

Dim logFile, flagFile, lockFile, outputFile, pidFile, tmpFile
logFile   = userHome & "\claude-remote\claude-remote.log"
flagFile  = userHome & "\claude-remote\claude-remote.running"
lockFile  = userHome & "\claude-remote\claude-remote.lock"
outputFile = userHome & "\claude-remote\claude-remote-output.txt"
pidFile   = userHome & "\claude-remote\claude-remote-pid.txt"
tmpFile   = userHome & "\claude-remote\claude-slack-msg.txt"

Dim slackWebhook
slackWebhook = "YOUR_SLACK_WEBHOOK_URL"

' --- Funcao de log ---
Sub Log(msg)
    On Error Resume Next
    Dim tsLog
    Set tsLog = fso.OpenTextFile(logFile, 8, True)
    tsLog.WriteLine Now() & " | " & msg
    tsLog.Close
End Sub

' --- Funcao: envia pro Slack (totalmente opcional, nunca para o script) ---
Sub SendSlack(msg)
    On Error Resume Next
    If slackWebhook = "YOUR_SLACK_WEBHOOK_URL" Or slackWebhook = "" Then Exit Sub
    Dim tsTmp
    Set tsTmp = fso.CreateTextFile(tmpFile, True)
    tsTmp.Write msg
    tsTmp.Close
    If Err.Number <> 0 Then Exit Sub
    Dim cmd
    cmd = "powershell -NoProfile -NonInteractive -Command """ & _
        "$msg = [System.IO.File]::ReadAllText('" & tmpFile & "'); " & _
        "$body = ConvertTo-Json @{text=$msg}; " & _
        "Invoke-RestMethod -Uri '" & slackWebhook & "' -Method Post -ContentType 'application/json' -Body $body" & """"
    WshShell.Run cmd, 0, True
    Log "Slack enviado"
End Sub

Log "=== Script iniciado ==="

' --- Previne duas instancias simultaneas ---
If fso.FileExists(lockFile) Then
    Log "Outra instancia ja esta rodando, encerrando"
    WScript.Quit
End If
On Error Resume Next
Dim tsLock
Set tsLock = fso.CreateTextFile(lockFile, True)
tsLock.Write Now()
tsLock.Close
On Error GoTo 0

' --- Toggle: se flag existe, verifica se processo ainda esta rodando ---
If fso.FileExists(flagFile) Then
    Dim ts, savedPid
    savedPid = ""
    On Error Resume Next
    If fso.GetFile(flagFile).Size > 0 Then
        Set ts = fso.OpenTextFile(flagFile, 1)
        savedPid = Trim(ts.ReadAll())
        ts.Close
    End If
    On Error GoTo 0

    Dim processAlive
    processAlive = False
    If savedPid <> "" Then
        Dim oCheck
        Set oCheck = WshShell.Exec("powershell -NoProfile -NonInteractive -Command ""Get-Process -Id " & savedPid & " -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Id""")
        If Trim(oCheck.StdOut.ReadAll()) = savedPid Then processAlive = True
    End If

    If processAlive Then
        Log "Encerrando PID: " & savedPid
        WshShell.Run "taskkill /PID " & savedPid & " /T /F", 0, True
        WScript.Sleep 1000
        On Error Resume Next
        fso.DeleteFile flagFile
        fso.DeleteFile lockFile
        On Error GoTo 0
        Log "Processo encerrado"
        Log "=== Script finalizado (encerrou) ==="
        WScript.Quit
    Else
        Log "Processo nao existe (reboot?), limpando flag"
        On Error Resume Next
        fso.DeleteFile flagFile
        On Error GoTo 0
    End If
End If

' --- Limpa arquivos anteriores ---
On Error Resume Next
If fso.FileExists(outputFile) Then fso.DeleteFile outputFile
If fso.FileExists(pidFile) Then fso.DeleteFile pidFile
On Error GoTo 0

' --- Inicia claude remote-control ---
Log "Iniciando claude remote-control"
WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File """ & userHome & "\claude-remote\claude-remote-start.ps1""", 0, True
WScript.Sleep 500

' --- Le o PID ---
Dim claudePid
claudePid = ""
On Error Resume Next
If fso.FileExists(pidFile) Then
    Dim tsPid
    Set tsPid = fso.OpenTextFile(pidFile, 1)
    claudePid = Trim(tsPid.ReadAll())
    tsPid.Close
    fso.DeleteFile pidFile
End If
On Error GoTo 0
Log "PID: " & claudePid

' --- Salva flag ---
On Error Resume Next
Dim tsWrite
Set tsWrite = fso.CreateTextFile(flagFile, True)
tsWrite.Write claudePid
tsWrite.Close
On Error GoTo 0

' --- Tenta capturar URL (opcional, nao para o script) ---
Log "Aguardando URL..."
Dim sessionUrl, attempts
sessionUrl = ""
attempts = 0

Do While sessionUrl = "" And attempts < 15
    WScript.Sleep 1000
    attempts = attempts + 1
    On Error Resume Next
    If fso.FileExists(outputFile) Then
        Dim tsOut, outContent
        Set tsOut = fso.OpenTextFile(outputFile, 1)
        outContent = tsOut.ReadAll()
        tsOut.Close
        If Err.Number = 0 And Len(outContent) > 0 Then
            Dim outLines, ol
            outLines = Split(outContent, vbLf)
            For ol = 0 To UBound(outLines)
                If InStr(outLines(ol), "https://claude.ai/code/session") > 0 Then
                    Dim parts, p
                    parts = Split(outLines(ol), " ")
                    For p = 0 To UBound(parts)
                        If InStr(parts(p), "https://claude.ai/code/session") > 0 Then
                            sessionUrl = Trim(parts(p))
                            Do While Len(sessionUrl) > 0 And InStr("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-/:.#?=&", Right(sessionUrl, 1)) = 0
                                sessionUrl = Left(sessionUrl, Len(sessionUrl) - 1)
                            Loop
                            Exit For
                        End If
                    Next
                End If
                If sessionUrl <> "" Then Exit For
            Next
        End If
    End If
    On Error GoTo 0
Loop

Log "URL: " & sessionUrl

' --- Envia pro Slack (opcional) ---
If sessionUrl <> "" Then
    SendSlack ":computer: *SOFTLIVE VM* - Remote Control ativo!" & Chr(10) & ":link: " & sessionUrl
Else
    SendSlack ":computer: *SOFTLIVE VM* - Remote Control ativo!"
End If

' --- Inicia icone na bandeja ---
Dim trayScript
trayScript = userHome & "\claude-remote\claude-remote-tray.ps1"
If fso.FileExists(trayScript) Then
    WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & trayScript & """ -SessionUrl """ & sessionUrl & """", 0, False
End If

' --- Remove lock ---
On Error Resume Next
fso.DeleteFile lockFile
On Error GoTo 0

Log "Sucesso! PID: " & claudePid
Log "=== Script finalizado ==="

Set fso = Nothing
Set WshShell = Nothing
