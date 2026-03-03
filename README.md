<div align="center">

# Claude Remote Autostart

**Automatically starts Claude Code in Remote Control mode when your Windows machine boots — captures the session URL and delivers it straight to Slack.**

[![Release](https://img.shields.io/github/v/release/Pass-os/claude-remote-autostart)](https://github.com/Pass-os/claude-remote-autostart/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-blue)](https://github.com/Pass-os/claude-remote-autostart)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## Overview

Claude Remote Autostart is a lightweight Windows automation tool that runs [Claude Code](https://claude.ai/code) in Remote Control mode silently at startup — no terminal windows, no manual steps. Once running, a system tray icon confirms the service is active and a Slack notification delivers the session URL so you can connect from any device, instantly.

## Features

- 🟢 **Auto-start** — launches automatically when Windows boots
- 🔗 **Session URL via Slack** — receive the remote session link on your phone, laptop, anywhere
- 🖥️ **System tray icon** — visual indicator with quick actions (open in browser, copy URL, stop)
- 🔄 **Toggle on/off** — run the script again to stop the service
- 🛡️ **Safe by default** — Slack is optional, errors never block the session

## Requirements

- Windows 10 or 11
- [Claude Code](https://claude.ai/code) installed and logged in
- PowerShell (built into Windows)
- Slack Incoming Webhook *(optional)*

## Installation

1. Download the latest ZIP from [Releases](https://github.com/Pass-os/claude-remote-autostart/releases/latest)
2. Extract all files to any folder
3. Double-click **`install.vbs`**
4. Follow the on-screen steps

The installer handles everything: copying files, configuring your Slack webhook, and registering the service in Windows startup.

## How It Works

```
Windows boots
     ↓
claude-remote.vbs runs via Startup
     ↓
claude.exe remote-control starts (hidden)
     ↓
Session URL captured from stdout
     ↓
Slack notification sent  +  Tray icon appears
```

## Files

| File | Description |
|------|-------------|
| `install.vbs` | One-click installer |
| `claude-remote.vbs` | Main toggle script |
| `claude-remote-start.ps1` | Launches Claude in background |
| `claude-remote-tray.ps1` | System tray icon manager |

---

<div align="center">
<sub>

**Português** · Inicia o Claude Code em modo Remote Control automaticamente quando o Windows liga. Captura a URL da sessão e envia para o Slack, com ícone na bandeja do sistema para acesso rápido. Instale com um clique via `install.vbs`. Veja o arquivo `INSTALL.txt` para instruções detalhadas em português.

</sub>
</div>
