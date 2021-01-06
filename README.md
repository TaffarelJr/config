# Config

Contains various files and scripts geared towards configuring a computer and installing standard tools applications.

## App Configuration Files

Configuration files for common applications are stored in the [apps](./apps) folder.

## [Boxstarter](https://boxstarter.org)

The [boxstarter](./boxstarter) folder contains scripts to automatically configure a computer and install various applications on it. To run them manually:

```powershell
# Install Boxstarter
. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force

# Set execution policy
Set-ExecutionPolicy RemoteSigned

# Launch Boxstarter, pointing to a URL or local path to the script to be run
Install-BoxstarterPackage -PackageName <URL-TO-RAW-OR-GIST> -DisableReboots
```

Or, a quicker way to run these scripts is to use ClickOnce:

1. Open the Microsoft Edge browser (required to launch ClickOnce applications)
2. Navigate to [edge://flags/#edge-click-once](edge://flags/#edge-click-once) and enable `ClickOnce Support`
3. Relaunch the Microsoft Edge browser as Administrator
4. Navigate back to this repository
5. Click on the link(s) below to run the desired scripts (as necessary; perfer top to bottom)

| Recipe<br/>_(click to run)_                                                                                                                    | Description                                                           |
| ---------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- |
| [Initialize New Machine](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Initialize.ps1) | Configure basic settings for a clean Windows 10 installation          |
| [Profile: RJ](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Profile-RJ.ps1)            | Configure RJ's user profile settings & install preferred applications |
| [Developer](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Developer.ps1)               | Install developer tools, frameworks, and SDKs                         |
| [Graphics](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Graphics.ps1)                 | Install advanced graphics editing tools                               |
| [Games](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/boxstarter/Games.ps1)                       | Install games & game platforms                                        |
