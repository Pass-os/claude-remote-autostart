<div align="center">

# Claude Remote Autostart

**Automatically starts Claude Code in Remote Control mode when your Windows machine boots — captures the session URL and delivers it straight to Slack.**

<sub>Inicia o Claude Code em modo Remote Control automaticamente quando o Windows liga — captura a URL da sessão e envia direto para o Slack.</sub>

[![Release](https://img.shields.io/github/v/release/Pass-os/claude-remote-autostart)](https://github.com/Pass-os/claude-remote-autostart/releases/latest)
[![Platform](https://img.shields.io/badge/platform-Windows%2010%2F11-blue)](https://github.com/Pass-os/claude-remote-autostart)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

</div>

---

## Overview

Claude Remote Autostart is a lightweight Windows automation tool that runs [Claude Code](https://claude.ai/code) in Remote Control mode silently at startup — no terminal windows, no manual steps. Once running, a system tray icon confirms the service is active and a Slack notification delivers the session URL so you can connect from any device, instantly.

<sub>Claude Remote Autostart é uma ferramenta leve de automação para Windows que roda o Claude Code em modo Remote Control silenciosamente ao iniciar — sem janelas de terminal, sem etapas manuais. Um ícone na bandeja confirma que o serviço está ativo e uma notificação no Slack entrega a URL da sessão para você conectar de qualquer dispositivo.</sub>

## Features

- 🟢 **Auto-start** — launches automatically when Windows boots
- 🔗 **Session URL via Slack** — receive the remote session link on your phone, laptop, anywhere
- 🖥️ **System tray icon** — visual indicator with quick actions (open in browser, copy URL, stop)
- 🔄 **Toggle on/off** — run the script again to stop the service
- 🛡️ **Safe by default** — Slack is optional, errors never block the session

<sub>🟢 **Auto-start** — inicia automaticamente com o Windows · 🔗 **URL via Slack** — receba o link da sessão no celular ou em qualquer dispositivo · 🖥️ **Ícone na bandeja** — indicador visual com ações rápidas · 🔄 **Toggle** — rode o script novamente para parar · 🛡️ **Seguro** — Slack é opcional, erros nunca bloqueiam a sessão</sub>

## Requirements

- Windows 10 or 11
- [Claude Code](https://claude.ai/code) installed and logged in
- PowerShell (built into Windows)
- Slack Incoming Webhook *(optional)*

<sub>Windows 10 ou 11 · Claude Code instalado e logado · PowerShell (já incluso no Windows) · Slack Incoming Webhook (opcional)</sub>

## Installation

1. Download the latest ZIP from [Releases](https://github.com/Pass-os/claude-remote-autostart/releases/latest)
2. Extract all files to any folder
3. Double-click **`install.vbs`**
4. Follow the on-screen steps

The installer handles everything: copying files, configuring your Slack webhook, and registering the service in Windows startup.

<sub>1. Baixe o ZIP em [Releases](https://github.com/Pass-os/claude-remote-autostart/releases/latest) · 2. Extraia em qualquer pasta · 3. Dê duplo clique em **`install.vbs`** · 4. Siga as instruções na tela. O instalador cuida de tudo: copia os arquivos, configura o webhook do Slack e registra o serviço no startup do Windows.</sub>

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

<sub>Windows liga → `claude-remote.vbs` roda via Startup → `claude.exe remote-control` inicia em background → URL da sessão capturada → Notificação enviada ao Slack + ícone aparece na bandeja</sub>

## Files

| File | Description |
|------|-------------|
| `install.vbs` | One-click installer |
| `claude-remote.vbs` | Main toggle script |
| `claude-remote-start.ps1` | Launches Claude in background |
| `claude-remote-tray.ps1` | System tray icon manager |

<sub>`install.vbs` — instalador · `claude-remote.vbs` — script principal toggle · `claude-remote-start.ps1` — inicia o Claude em background · `claude-remote-tray.ps1` — gerencia o ícone na bandeja</sub>
