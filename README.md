# Config

Contains various files and scripts geared towards configuring a computer and installing standard tools applications.

## App Configuration Files

Configuration files for common applications are stored in the [apps](./apps) folder.

## [Boxstarter](https://boxstarter.org)

The [boxstarter](./boxstarter) folder contains scripts to automatically configure a computer and install various applications on it. These scripts were inspired by samples from:

- [Microsoft](https://github.com/Microsoft/windows-dev-box-setup-scripts)
- [elithrar](https://github.com/elithrar/dotfiles)
- [ElJefeDSecurIT](https://gist.github.com/ElJefeDSecurIT/014fcfb87a7372d64934995b5f09683e)
- [jessfraz](https://gist.github.com/jessfraz/7c319b046daa101a4aaef937a20ff41f)
- [NickCraver](https://gist.github.com/NickCraver/7ebf9efbfd0c3eab72e9)

To run them manually:

```powershell
# Install Boxstarter
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force

# Set execution policy
Set-ExecutionPolicy RemoteSigned

# Launch Boxstarter, pointing to a URL or local path to the script to be run
Install-BoxstarterPackage -PackageName <URL-TO-RAW-OR-GIST> [-DisableReboots]
```

Or, a quicker way to run these scripts is to use ClickOnce:

1. Open the Microsoft Edge browser (required to launch ClickOnce applications)
2. Navigate to [edge://flags/#edge-click-once](edge://flags/#edge-click-once) and enable `ClickOnce Support`
3. Relaunch the Microsoft Edge browser as Administrator
4. Navigate back to this repository
5. Click on the link(s) below to run the desired scripts (as necessary; perfer top to bottom)

| Recipe<br/>_(click to run)_                                                                                                                                  | Description                                                                                                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [Initialize New Machine](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Initialize.ps1)               | Configure basic settings for a clean Windows 10 installation<br/>_(May need to run this script multiple times, until it completes successfully.)_<br />_(Probably need to restart after running.)_ |
| ──────────────                                                                                                                                               | ─────────────────────────────────────────────                                                                                                                                                      |
| [Install: Basic Utilities](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Install-BasicUtilities.ps1) | Install standard utilities and applications                                                                                                                                                        |
| [Install: Virtualization](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Install-Virtualization.ps1)  | Install support for virtualized environments (Hyper-V, WSL, Docker)<br/>_(Windows 10 Pro only)_                                                                                                    |
| [Install: Developer](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Install-Developer.ps1)            | Install standard developer tools, frameworks, SDKs, and IDEs                                                                                                                                       |
| ──────────────                                                                                                                                               | ─────────────────────────────────────────────                                                                                                                                                      |
| [Profile: RJ](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Profile-RJ.ps1)                          | Configure RJ's user profile settings & install preferred applications                                                                                                                              |
| [Graphics](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Graphics.ps1)                               | Install advanced graphics editing tools                                                                                                                                                            |
| [Games](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Games.ps1)                                     | Install games & game platforms                                                                                                                                                                     |
