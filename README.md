# claude-remote-autostart

Automatically starts Claude Code in Remote Control mode on a Windows VM, captures the session URL and sends it to Slack — accessible from anywhere with a single click.

## How it works

- **1st click** on `claude-remote.vbs` → starts `claude remote-control` in background, captures the session URL, sends it to Slack
- **2nd click** → stops the process

## Files

- `claude-remote.vbs` — main toggle script (place on Desktop)
- `claude-remote-start.ps1` — helper script called by the `.vbs` (place in `C:\Users\<user>\`)

## Setup

1. Install [Claude Code](https://claude.ai/code) and log in
2. Run `claude` once in your working directory to accept the workspace trust dialog
3. Set your Slack webhook URL in `claude-remote.vbs`
4. Place `claude-remote.vbs` on the Desktop
5. Place `claude-remote-start.ps1` in `C:\Users\<user>\`
6. To auto-start with Windows, add a shortcut to `claude-remote.vbs` in `shell:startup`

## Requirements

- Windows 10/11
- Claude Code CLI installed
- PowerShell
- Slack Incoming Webhook URL
