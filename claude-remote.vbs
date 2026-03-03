Dim WshShell, fso
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim logFile, flagFile
logFile = "C:\Users\softlive\Desktop\claude-remote.log"
flagFile = "C:\Users\softlive\claude-remote.running"

Dim slackWebhook
slackWebhook = "YOUR_SLACK_WEBHOOK_URL"

' --- Funcao de log ---
Sub Log(msg)
    Dim tsLog
    Set tsLog = fso.OpenTextFile(logFile, 8, True)
    tsLog.WriteLine Now() & " | " & msg
    tsLog.Close
End Sub

' --- Funcao: envia mensagem pro Slack ---
Sub SendSlack(msg)
    ' Salva a mensagem em arquivo temporario e le pelo powershell (evita problemas com & e aspas na URL)
    Dim tmpFile
    tmpFile = "C:\Users\softlive\claude-slack-msg.txt"
    Dim tsTmp
    Set tsTmp = fso.CreateTextFile(tmpFile, True)
    tsTmp.Write msg
    tsTmp.Close

    Dim cmd
    cmd = "powershell -NoProfile -NonInteractive -Command """ & _
        "$msg = [System.IO.File]::ReadAllText('" & tmpFile & "'); " & _
        "$body = ConvertTo-Json @{text=$msg}; " & _
        "Invoke-RestMethod -Uri '" & slackWebhook & "' -Method Post -ContentType 'application/json' -Body $body" & """"
    WshShell.Run cmd, 0, True
    Log "Slack enviado: " & msg
End Sub

Log "=== Script iniciado ==="

' --- Toggle: se flag existe, encerra ---
If fso.FileExists(flagFile) Then
    Dim ts, savedPid
    savedPid = ""
    If fso.GetFile(flagFile).Size > 0 Then
        Set ts = fso.OpenTextFile(flagFile, 1)
        savedPid = Trim(ts.ReadAll())
        ts.Close
    End If
    Log "Flag encontrada, encerrando PID: " & savedPid

    If savedPid <> "" Then
        WshShell.Run "taskkill /PID " & savedPid & " /T /F", 0, True
        WScript.Sleep 1000
    End If
    fso.DeleteFile flagFile
    Log "Processo encerrado"
    MsgBox "Claude Remote Control encerrado com sucesso!", vbInformation, "Remote Control"
    Log "=== Script finalizado (encerrou) ==="
    WScript.Quit
End If

' --- Inicia claude remote-control e captura URL do stdout ---
Log "Iniciando claude remote-control"

Dim outputFile, pidFile
outputFile = "C:\Users\softlive\claude-remote-output.txt"
pidFile = "C:\Users\softlive\claude-remote-pid.txt"

' Deleta arquivos anteriores
If fso.FileExists(outputFile) Then fso.DeleteFile outputFile
If fso.FileExists(pidFile) Then fso.DeleteFile pidFile

' Inicia via script ps1 separado (evita problema de aspas no inline)
WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -File C:\Users\softlive\claude-remote-start.ps1", 0, True
WScript.Sleep 500

' Le o PID
Dim claudePid
claudePid = ""
If fso.FileExists(pidFile) Then
    Dim tsPid
    Set tsPid = fso.OpenTextFile(pidFile, 1)
    claudePid = Trim(tsPid.ReadAll())
    tsPid.Close
    fso.DeleteFile pidFile
End If
Log "PID capturado: " & claudePid

' Salva flag com PID
Dim tsWrite
Set tsWrite = fso.CreateTextFile(flagFile, True)
tsWrite.Write claudePid
tsWrite.Close

' Aguarda URL aparecer no output (max 15s)
Log "Aguardando URL no output..."
Dim sessionUrl, attempts
sessionUrl = ""
attempts = 0

Do While sessionUrl = "" And attempts < 15
    WScript.Sleep 1000
    attempts = attempts + 1

    If fso.FileExists(outputFile) Then
        Dim tsOut, outContent, outLines, ol
        Set tsOut = fso.OpenTextFile(outputFile, 1)
        outContent = tsOut.ReadAll()
        tsOut.Close

        outLines = Split(outContent, vbLf)
        For ol = 0 To UBound(outLines)
            If InStr(outLines(ol), "https://claude.ai/code/session") > 0 Then
                Dim parts, p
                parts = Split(outLines(ol), " ")
                For p = 0 To UBound(parts)
                    If InStr(parts(p), "https://claude.ai/code/session") > 0 Then
                        sessionUrl = Trim(parts(p))
                        ' Remove caracteres nao-URL do final
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
Loop

Log "URL capturada apos " & attempts & "s: " & sessionUrl

' Envia pro Slack
If sessionUrl <> "" Then
    SendSlack ":computer: *SOFTLIVE VM* - Remote Control ativo!" & Chr(10) & ":link: " & sessionUrl
Else
    SendSlack ":computer: *SOFTLIVE VM* - Remote Control ativo! Acesse: claude.ai/code"
    Log "AVISO: URL nao encontrada no output"
End If

Log "Sucesso! PID: " & claudePid
MsgBox "Claude Remote Control iniciado com sucesso!" & vbCrLf & "Sessao ativa - PID: " & claudePid, vbInformation, "Remote Control"

Log "=== Script finalizado ==="

Set fso = Nothing
Set WshShell = Nothing
