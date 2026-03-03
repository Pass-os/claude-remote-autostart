param(
    [string]$Title = "Claude Remote Control ativo!",
    [string]$Body  = "Servico iniciado com sucesso."
)

try {
    [Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime] | Out-Null
    [Windows.Data.Xml.Dom.XmlDocument,Windows.Data.Xml.Dom,ContentType=WindowsRuntime] | Out-Null
    $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent(
        [Windows.UI.Notifications.ToastTemplateType]::ToastText02
    )
    $xml.SelectSingleNode('//text[@id=1]').InnerText = $Title
    $xml.SelectSingleNode('//text[@id=2]').InnerText = $Body
    $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
    [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('Claude Remote').Show($toast)
} catch {}
