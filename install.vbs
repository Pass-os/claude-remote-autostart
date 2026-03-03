Dim WshShell, fso
Set WshShell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")

Dim scriptDir
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

Dim ps1Path
ps1Path = scriptDir & "\install.ps1"

If Not fso.FileExists(ps1Path) Then
    MsgBox "install.ps1 not found in: " & scriptDir, vbCritical, "Error"
    WScript.Quit
End If

WshShell.Run "powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & ps1Path & """", 0, False

Set fso = Nothing
Set WshShell = Nothing
