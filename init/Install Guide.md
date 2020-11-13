# PC Installation Guide

## Initial Setup

* Connect to network
  * [<span style="color:red">Work</span>] One with no IronPort, for now
* _Windows Defender Security Center_
  * Check settings
* _Windows Store_
  * Update existing apps
  * Install new apps:
    *  _Dynamic Theme_
    * _Microsoft Terminal_
    * _Ubuntu 1804 LTS_
      * Username: rohol
      * Password: \<current\>
      * Follow instructions here: https://github.mktp.io/bc-swat/getting-started/blob/master/WSL/wsl.md
        * OFF IronPort (lots of data, do at home):
          * `sudo apt update`
          * `sudo apt upgrade`
          * `sudo nano /etc/wsl.conf`
          * Append snippet at the bottom of the file
          * Close Ubuntu
          * PowerShell admin: `Restart-Service -Name "LxssManager"`
          * Re-open Ubuntu
          * Install Homebrew: `sh -c "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh)"`
        * ON IronPort
          * Get the IronPort certificate
            * Go to Facebook.com
            * Click the lock icon in the address bar
            * Click "Certificate"
            * "Certification Path" tab
            * Click `ironport.extendhealth.com`
            * Click "View Certificate"
            * "Details" tab
            * Click "Copy to File..."
            * Choose "Base-64 encoded X.509 (.CER)"
            * Save it somewhere you'll remember
          * Import the IronPort certificate into Ubuntu:
            * `sudo mkdir /usr/local/share/ca-certificates/extra`
            * `sudo cp /c/<.cer path>/ironport.cer /usr/local/share/ca-certificates/extra/root.cert.crt`
            * `sudo update-ca-certificates`
          * Add Homebrew to the path:
            * `test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)`
            * `test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)`
            * `test -r ~/.bash_profile && echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.bash_profile`
            * `echo "eval \$($(brew --prefix)/bin/brew shellenv)" >>~/.profile`
            * `sudo apt-get install build-essential curl file git`
          * Install Homebrew apps:
            * `brew install gcc`
            * `brew install azure-cli`
            * `brew install terraform`
            * `brew install git`
            * `brew install coreutils`
            * `brew install mutt`
            * `brew install jq`
            * `brew install zip`
          * Additional app configuration:
            * `sudo apt-get install sendmail`
            * `sudo apt install python3-pip`
            * `pip3 install slack-cli --trusted-host="pypi.python.org"`
          * Set up Git credential manager
            * `git config --global credential.helper "/c/Program\ Files/Git/mingw64/libexec/git-core/git-credential-manager.exe"`
          * Install sqlcmd
            * `curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -`
            * `curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/msprod.list`
            * `sudo apt-get update`
            * `sudo apt-get install mssql-tools unixodbc-dev`
            * `sudo apt-get update`
            * `sudo apt-get install mssql-tools`
            * `echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile`
            * `echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc`
            * `source ~/.bashrc`
* Open _PowerShell_ as Administrator and run these commands
  * `..\OneDrive\Tech\Config\Machine Setup.ps1` (will restart the computer)

## Browsers

* [<span style="color:red">Work</span>] [Mozilla Firefox](https://www.mozilla.org/)
* [Google Chrome](https://www.google.com/chrome/)
  * Set as default browser
  * Sign into Google account
* [LastPass](https://lastpass.com/misc_download2.php)
  * Sign in on all browsers

## Core Windows Configuration

* [<span style="color:red">Work</span>] _Settings -> Accounts -> Email & app accounts_
  * Add Microsoft account
* _Control Panel -> Hardware and Sound -> Power Options_
  * _Selected plan_: Balanced
    * _Plugged in_:
    * _Turn off the display_: 30 minutes
    * _Put the computer to sleep_: Never
* _Mail_ app
  * Add accounts:
    * Microsoft
    * Google
    * Google (TaffarelJr)
    * Google (Theseus)
    * Yahoo account
  * _Settings -> Reading pane_
    * _Mark item as read_: When viewed in the reading pane
    * _Seconds to wait_: 0

## Drivers

* [Dell Drivers](http://www.dell.com/support/home)
  * Suspend BitLocker as necessary
* [Brother MFC-J835DW](http://support.brother.com/g/b/downloadtop.aspx?c=us&lang=en&prod=mfcj835dw_us)

## Microsoft Office

* [Microsoft Office Professional Plus 2016](https://stores.office.com/myaccount/home.aspx#otherproducts)
  * Sign into Microsoft account
  * [<span style="color:red">Work</span>] Outlook 2016
    * Sign into work account
    * _File -> Options -> Mail -> Outlook Panes -> Reading Pane_
      * _Mark items as read when viewed in the Reading Pane_
      * _Wait_ 0 _seconds before marking item as read_
* [Microsoft Visio Professional 2016](https://stores.office.com/myaccount/home.aspx#otherproducts)
  * Sign into Microsoft account

## Communications

* Skype
  * Sign into Microsoft account
* [<span style="color:red">Work</span>] Skype for Business 2016
  * Sign into work account
* [Slack](https://slack.com/downloads/windows)
  * Sign in
* [<span style="color:red">Work</span>] [Zoom](https://zoom.us/download)
  * Settings
    * _Video_
    * Turn off my video when joining meeting: true
  * _Audio_
    * Mute my microphone when joining a meeting: true

## Utilities

* [7-Zip](https://www.7-zip.org/)
* [Adobe Acrobat Reader DC](https://acrobat.adobe.com/us/en/acrobat/pdf-reader.html)
  * DO NOT install virus scanner
  * _View -> Display Theme_: Dark Gray
* [Advanced Renamer](https://www.advancedrenamer.com/download)
* [Attribute Changer](https://www.petges.lu/download/)
* [Divvy](https://mizage.com/windivvy)
  * _Settings_
    * Start Divvy at login: true
    * Use global shortcut to display panel
    * Set shortcuts
* [DivX](http://www.divx.com/)
* [Duplicate Cleaner](https://www.digitalvolcano.co.uk/dcdownloads.html)
* [Free Download Manager](https://www.freedownloadmanager.org/download.htm)
* [Link Shell Extension](http://schinagl.priv.at/nt/hardlinkshellext/linkshellextension.html)
* [Notepad++](https://notepad-plus-plus.org/downloads)
  * _Settings -> Style Configurator... -> Select theme_: Monokai
* [Piriform CCleaner](https://www.ccleaner.com/ccleaner/download/standard)
  * DO NOT add desktop shortcut
  * Open CCleaner -> _Custom Clean_
    * Check all boxes except:
      * _Windows_
        * _Advanced_
          * Custom Files and Folders
          * Wipe Free Space
      * _Applications_
      * _Applications_
      * Notepad++
        * _Windows_
          * Game Explorer
* [Piriform Defraggler](https://www.ccleaner.com/defraggler/download/standard)
  * DO NOT add desktop shortcut
* [SpaceSniffer](http://www.uderzo.it/main_products/space_sniffer/download.html)
* [Sysinternals Process Explorer](https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer)
* [Sysinternals Process Monitor](https://docs.microsoft.com/en-us/sysinternals/downloads/procmon)
* "...\OneDrive\Tech\Config\Open Command Window Here\\"
  * Run "Open Command Window Here.ps1"

## Cloud Storage

* OneDrive
  * [<span style="color:red">Work</span>] "...\OneDrive\Tech\Config\Unlock.reg"
  * [<span style="color:red">Work</span>] "%SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall"
  * [<span style="color:red">Work</span>] "%SystemRoot%\SysWOW64\OneDriveSetup.exe"
  * _Settings_
    * _Account_
      * Sign into Microsoft account
    * _Settings_
      * _General_
        * _Start OneDrive automatically when I sign into Windows_: True
      * _Files On-Demand_
        * _Save space and download files as you use them_: True
    * _Backup_
      * _Manage Backup_
        * Select all
      * _Screenshots_
        * _Automatically save screenshots I capture to OneDrive_: True
  * Backup Desktop, Documents, and Pictures
* [Google Backup and Sync](https://www.google.com/drive/download/)
  * Sign into Google account
* [DropBox](https://www.dropbox.com/install)
  * Sign into Dropbox account

## [<span style="color:red">Work</span>] Developer Tools (Part 1)

* [Microsoft Visual Studio Code](https://code.visualstudio.com/)
  * Set to always run as admin:
    * "%LocalAppData%\Programs\Microsoft VS Code\Code.exe
  * View -> Render Whitespace
  * File -> Preferences -> Settings
    * Features -> Terminal -> Integrated: Scrollback = 10000
  * Install extensions:
    * Settings Sync
      * Select Git Gist
      * Download synched settings and extensions
* [Fira Code font](https://github.com/tonsky/FiraCode)
  * Unzip file
  * Open _ttf_ folder
  * Select all
  * Click _Install_
* [Devart Code Compare](https://www.devart.com/codecompare/)
  * _Tools -> Options -> Environment -> General -> Skin_: Dark

## [<span style="color:red">Work</span>] Source Control

* [Git for Windows](https://git-scm.com/download/win)
  * _Use a TrueType font in all console windows_: True
  * _Check daily for Git for Windows updates_: True
  * Integrate with VS Code
  * Use the native Windows Secure Channel library
* [TortoiseGit](https://tortoisegit.org/download/)
  * Settings -> Git -> Global -> Name = RJ Hollberg 
  * [Integrate with Code Compare](https://www.devart.com/codecompare/integration_tortoisegit.html)
    * Diff Viewer: `"C:\Program Files\Devart\Code Compare\CodeCompare.exe" /SC=TortoiseGit /T1=%bname /T2=%yname %base %mine`
    * Merge Tool: `"C:\Program Files\Devart\Code Compare\CodeMerge.exe" /SC=TortoiseGit /BF=%base /BT=%bname /TF=%theirs /TT=%tname /MF=%mine /MT=%yname /RF=%merged /RT=%mname /REMOVEFILES`
* [Sourcetree](https://www.sourcetreeapp.com/)
* [GitHub Desktop](https://desktop.github.com/)

## [<span style="color:red">Work</span>] Developer Tools (Part 2)

* [Microsoft Visual Studio 2019 Professional](https://my.visualstudio.com/Downloads?q=Visual%20Studio%202019)
  * Sign into Microsoft account
  * Add work account (for license)
  * Set to always run as admin:
    * "%DevEnvDir%\Blend.exe
    * "%DevEnvDir%\devenv.exe
  * Import settings: "...\OneDrive\Tech\Config\Visual Studio 2019.vssettings"
  * Install Updates
  * Install extensions:
    * .ignore
    * Open in Visual Studio Code
    * Productivity Power Tools
    * Project System Tools
    * Security IntelliSense
    * Trailing Whitespace Visualizer
    * TypeScript Definition Generator
    * Visual Studio Spell Checker (VS2017 and Later)
    * Web Essentials 2019
  * Add NuGet Package Source:
    * Artifactory - https://artifacts.mktp.io/artifactory/api/nuget/nuget-all
    * MyGet - https://www.myget.org/F/rjh/api/v3/index.json
  * Trust Dev certs:
  * `dotnet dev-certs https --trust`
* [NuGet CLI](https://www.nuget.org/downloads)
  * Copy standalone EXE to _C:\Program Files (x86)\NuGet_
  * Add _C:\Program Files (x86)\NuGet_ to PATH environment variable
* Install any missing .NET [SDKs](https://dotnet.microsoft.com/download/visual-studio-sdks)
  * .NET Framework 4.8
  * .NET Core 1.1
  * .NET Core 2.2
* [SQL Server 2019 Developer](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
  * Basic install
  * Open `Sql Server Configuration Manager`
    * SQL Server Network Configuration -> Protocols for MSSQLSERVER
      * Named Pipes: Enabled
      * TCP/IP: Enabled
    * SQL Server Services -> SQL Server (MSSQLSERVER)
      * Restart service
* [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
* [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio)
* [PostgreSQL](https://www.enterprisedb.com/downloads/postgres-postgresql-downloads)
* [JetBrains Resharper Ultimate](https://www.jetbrains.com/resharper/download/)
  * Install all components
  * Integrate with Visual Studio 2019
* [Devart T4 Editor](https://www.devart.com/t4-editor/download.html)
* [Node.js](https://nodejs.org/en/)
* [Postman](https://www.getpostman.com/apps)
* [Wireshark](https://www.wireshark.org/download.html)
* [LINQPad](https://www.linqpad.net/Download.aspx)
  * _Edit -> Preferences -> General UI -> Theme_: Dark
* [Telerik Fiddler](https://www.telerik.com/download/fiddler)
* [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html)
* [WinSCP](https://winscp.net/eng/download.php)
* [WinGPG](https://scand.com/products/wingpg/)
* From an elevated command prompt, run:
  * `Install-PackageProvider -Name NuGet -MinimumVersion '2.8.5.201' -Force`
  * `choco install "eh.flyway.commandline" -s "https://artifacts.mktp.io/artifactory/api/nuget/Chocolatey"`

## Graphics

* [Paint.NET](https://www.getpaint.net/download.html)
* [Inkscape](https://inkscape.org/en/)
* [Gimp](https://www.gimp.org/downloads/)
* [<span style="color:green">Home</span>] Affinity Photo ("...\OneDrive\Archive\Software\Affinity Photo 1.5.0.exe")
* [<span style="color:green">Home</span>] Adobe Photoshop Elements (from disc)
* [Microangelo Toolset](http://microangelo.us/icon-editor.asp)
* [Microsoft Image Composite Editor (ICE)](https://www.microsoft.com/en-us/research/product/computational-photography-applications/image-composite-editor/)
* [Hugin](http://hugin.sourceforge.net/download/)
* [Shotcut](https://shotcut.org/download/)

## Games

* [Lego Digital Designer](https://www.lego.com/en-us/ldd/download)
* [Steam](http://store.steampowered.com/about/)
  * Sign into Steam account
* [Blizzard Battle.net App](https://us.battle.net/account/download/)
  * Sign into Blizzard acount
* [EA Origin](https://www.origin.com/usa/en-us/store/download)
  * Sign into EA Origin account
* [Ubisoft Uplay](https://uplay.ubi.com/)
  * Sign into Ubisoft account
* [Minecraft (Java)](https://minecraft.net/en-us/download/)
  * Sign into Mojang account
* [Minecraft (Bedrock)](https://www.microsoft.com/en-us/p/minecraft-for-windows-10/9nblggh2jhxj)
  * Sign into Mojang account

## [<span style="color:red">Work</span>] Linux (WSL)

* Open VS Code
* Open a folder in WSL, this will install the Remote Server in Ubuntu
