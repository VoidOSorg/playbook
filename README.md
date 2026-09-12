<h1 align="center">
  <img src="https://i.ibb.co/xSVk7jRK/image.png" alt="VoidOS Logo" width="48">
  VoidOS Playbook
</h1>

<p align="center">
  <img alt="Target" src="https://img.shields.io/badge/Windows%2010-0078D7?style=for-the-badge" />
  <img alt="Wizard" src="https://img.shields.io/badge/AME%20Wizard-6A1FB9?style=for-the-badge" />
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" />
</p>

VoidOS Playbook is an **AME Wizard** package that applies a curated set of system optimizations to a clean Windows 10 installation. It automates debloating, service configuration, registry tuning, power management and visual customization, targeting improved gaming performance and reduced latency without manual user interaction.

---

## Overview

The playbook is organized as a sequence of task files, each scoped to a single concern. Execution order is defined in `Configuration/main.yml`:

| Phase | Task file | Scope |
|-------|-----------|-------|
| 1 | `start.yml` | Basic system preparation |
| 2 | `Components/app-win32.yml` | Removal of Edge, OneDrive, Teams and related services |
| 3 | `Components/appx.yml` | AppX package provisioning removal |
| 4 | `animations.yml` | Visual effects and animation settings |
| 5 | `customization.yml` | Theme, wallpaper, cursors and branding |
| 6 | `browsers.yml` | Optional browser installation |
| 7 | `services.yml` | Non-essential service disabling |
| 8 | `optimizations.yml` | Scheduler, power plan and system optimizations |
| 9 | `registry.yml` | Core registry tweak set |
| 10 | `regs/search.yml` | Windows Search behavior |
| 11 | `regs/start-menu.yml` | Start menu configuration |
| 12 | `regs/taskbar.yml` | Taskbar configuration |
| 13 | `final.yml` | Cleanup and finalization |

Each `Tasks\*.yml` file uses AME Wizard's YAML action schema (`!powerShell`, `!registryValue`, `!taskKill`, `!run`, `!service`). Task execution runs under the `TrustedInstaller` privilege where required.

## Technical details

### Application removal

- **Microsoft Edge**: uninstallation uses the official Chromium `setup.exe` with `--uninstall --system-level --force-uninstall --delete-profile`. A placeholder `MicrosoftEdge.exe` is created in the legacy `SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe` directory to unlock the uninstaller, and the `NoRemove` registry restriction is cleared.
- **OneDrive / Teams / Copilot**: removed via their AppX package identifiers and standard uninstallers.
- **AppX deprovisioning**: `APPX-REMOVER-DEFINITIVE.ps1` queries `Get-AppxProvisionedPackage -Online` once and removes packages in batch, preventing reinstallation for new user profiles.

### Power management

`Resources\PowerPlan` ships a custom power scheme plus a `settings.xml` containing per-GUID `powercfg` values (AC/DC index). `set-power-plan.ps1` imports the scheme, renames it, applies every setting and activates it.

### Registry and services

- `full.reg` and `fix.reg` carry the core registry tweak set.
- `disable-services.ps1` disables a predefined service list in a single batch with per-service logging.
- `apply-registry.ps1` walks `.reg` files with exit-code reporting.

### Customization

- Cursors are applied directly through `HKCU\Control Panel\Cursors` and refreshed via `SystemParametersInfo(SPI_SETCURSORS)`, avoiding the popup caused by the bundled INF/`rundll32` installer.
- Wallpaper is downloaded from the image host with a bundled fallback, applied through `SystemParametersInfo` and the `Wallpaper` policy key.
- Desktop and taskbar shortcuts for the `VoidOS-Tweaks` folder are created from `Images\shortcut.png` at the end of the branding phase.

### Taskbar

`CLEAN.ps1` and `pin-taskbar.ps1` unpin the taskbar and pin the selected browser using a three-step strategy: the local `pin to taskbar` shell verb, the `Windows.taskbarpin` CommandStore handler (via an `explorer`-named process), and a direct `.lnk` drop as fallback.

## Screenshots

| Installation | Applying playbook | Resulting system |
|:---:|:---:|:---:|
| ![Installation](Screenshots/installation.png) | ![Installing](Screenshots/installing.png) | ![Result](Screenshots/processi-avvio.png) |

## Usage

1. Download the latest `.apbx` package from the [Releases](https://github.com/VoidOSorg/playbook/releases) page.
2. Open **AME Wizard**, load the playbook and select the desired options.
3. Start the playbook. No manual steps are required during execution.

> The `.apbx` file is an encrypted 7-Zip archive; AME Wizard performs the decryption at load time.

## Repository layout

```
Configuration/       AME Wizard task files (YAML) and execution order
Executables/         PowerShell scripts, modules and bundled assets
Resources/           Themes, wallpapers, cursors, power plan and toolbox
Screenshots/         README preview images
playbook.conf        AME Wizard UI configuration
```

## Contributing

Contributions are welcome — new tweaks, script improvements and documentation updates. Submit a pull request or open an issue.

## License

MIT License. See `LICENSE`.