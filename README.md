# Config

Machine configuration and setup.

Configuration files for common applications are stored in the [apps](./apps) folder.

PowerShell scripts for automatically installing & configuring various applications are stored in the [scripts](./scripts) folder.

- Just about all scripts require PowerShell to be launched with Administrator privileges.
- Running the [NewMachine](./scripts/_NewMachine.ps1) script will run all the other scripts in turn, effectively configuring a blank machine with everything it needs.

## Boxstarter

To install these recipies, follow these steps:

1. Open the Microsoft Edge browser (required to launch ClickOnce applications)
2. Navigate to [edge://flags](edge://flags/#edge-click-once) and enable `ClickOnce Support`
3. Relaunch the Microsoft Edge browser as Administrator
4. Navigate back to this repository
5. Click on the link(s) below to install the desired recipies

| Recipe<br/>_(click to run)_                                                                                                      | Description                                                  |
| -------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| [New Machine](http://boxstarter.org/package/url?https://raw.githubusercontent.com/TaffarelJr/config/main/recipes/NewMachine.ps1) | Configure basic settings for a clean Windows 10 installation |
