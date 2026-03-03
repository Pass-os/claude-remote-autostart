Dim WshShell, fso
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim scriptDir, ps1Path
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
ps1Path   = scriptDir & "\src\uninstall.ps1"

If Not fso.FileExists(ps1Path) Then
    MsgBox "Arquivo nao encontrado: " & ps1Path, vbCritical, "Erro"
    WScript.Quit
End If

WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1Path & """", 0, False

Set fso = Nothing
Set WshShell = Nothing
