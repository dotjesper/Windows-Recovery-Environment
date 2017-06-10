<#
.SYNOPSIS
    Create Unattend.xml for uniqe client for recocery scenarios

.DESCRIPTION
    This script will create Unattend.xml for uniqe client for recocery scenarios

.EXAMPLE
    Create a new Unattend.xml file with computer name DEVICENAME, SystemLocale and InputLocale to Danish
    & .\Unattend.xml.ps1 -ComputerName 'DEVICENAME' -InputLocale '0406:00000406' -SystemLocale 'da-DK' -UserLocale 'da-DK' -UILanguage 'en-US'

.EXAMPLE
    Create a new Unattend.xml file with computer name DEVICENAME, SystemLocale and InputLocale to Danish
    & .\Unattend.xml.ps1 -ComputerName 'DEVICENAME' -InputLocale '0406:00000406' -SystemLocale 'da-DK' -UserLocale 'da-DK' -UILanguage 'en-US' -UILanguageFallback 'en-US' -TimeZone 'Romance Standard Time' -RegisteredOrganization 'the PREFLIGHT project' -RegisteredOwner 'the PREFLIGHT project'

.EXAMPLE
    Create a new Unattend.xml file based on computer
    & .\Unattend.xml.ps1 -Online

.NOTES
    FileName:    Unattend.xml.ps1
    Author:      @dotJesper
    Created:     10:45 21-04-2016 GMT+1
    Updated:     23:00 19-03-2017 GMT+1
#>
#requires -version 3.0

[CmdletBinding(SupportsShouldProcess = $true)]

param(

    [parameter(
        Mandatory = $False,
        HelpMessage = "Read values online."
    )]
    [switch]$Online,

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define computer name."
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(1,16)]
    [string]$ComputerName = "*",

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define InputLocale, format '0409:00000409'."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$InputLocale = "en-US;da-DK",

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define SystemLocale, format 'en-US'."
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(5,5)]
    [string]$SystemLocale = "en-US",

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define UserLocale, format 'en-US'."
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(5,5)]
    [string]$UserLocale = 'en-US',

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define UI Language, format 'en-US'."
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(5,5)]
    [string]$UILanguage = "en-US",

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define UI Language fallback, format 'en-US'."
    )]
    [ValidateNotNullOrEmpty()]
    [ValidateLength(5,5)]
    [string]$UILanguageFallback = "en-US;da-DK",

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define TimeZone, format 'Pacific Standard Time'."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$TimeZone = "Pacific Standard Time",

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define Registered Organization."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$RegisteredOrganization = 'Windows User',

    [parameter(
        Mandatory = $False,
        HelpMessage = "Define Registered Owner."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$RegisteredOwner = 'Windows User',


    [parameter(
        Mandatory = $False,
        HelpMessage = "Define browser Start Page."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$Home_Page = "about:tabs",


    [parameter(
        Mandatory = $False,
        HelpMessage = "Specify Microsoft Deployment Partner ID."
    )]
    [ValidateNotNullOrEmpty()]
    [string]$MicrosoftDeploymentPartnerID
    

)

Begin {

    If ([switch]$Online) {

        [string]$ComputerName = $env:computername.ToUpper()

        [string]$InputLocale = (Get-Culture).Name
        [string]$SystemLocale = (Get-WinSystemLocale).Name
        [string]$HomeLocation = (Get-WinHomeLocation).GeoId # Microsoft-Windows-Shell-Setup: Region or CountryOrRegionID
        [string]$UserLocale = 'da-DK'
        [string]$UILanguage = 'en-US'
        [string]$UILanguageFallback = 'en-US;da-DK'

      # Get-ItemProperty 'HKCU:\Control Panel\International'
   
      # Get-WinUserLanguageList
      # Get-WinLanguageBarOption
      # Get-WinUILanguageOverride
      # https://technet.microsoft.com/en-us/library/hh852115.aspx

        [string]$TimeZone = ([TimeZoneInfo]::Local).StandardName
        [string]$RegisteredOrganization = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOrganization
        [string]$RegisteredOwner = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").RegisteredOwner

    }
       
    [bool]$DisableAutoDaylightTimeSet = $False
    [bool]$DisableWelcomePage = $True
    [bool]$DisableFirstRunWizard = $True
    [bool]$DisableWindowsConsumerFeatures = $True

    [bool]$EnableLSAprotection = $True

    [bool]$HideEULAPage = $true
    [bool]$HideOEMRegistrationScreen = $False
    [bool]$HideOnlineAccountScreens = $False
    [bool]$HideLocalAccountScreen = $False
    [bool]$HideWirelessSetupInOOBE = $False

  # [string]$NetworkLocation = 'Home' # This setting has been deprecated in Windows 10. The information about this deprecated setting is provided for reference only.
    
    [int]$ProtectYourPC = 1
    [int]$RunSynchronousOrder = 0

  # Unattend to Windows Provisioning settings map
  # https://msdn.microsoft.com/en-us/library/windows/hardware/dn958623(v=vs.85).aspx

  # TaskbarLinks
  # https://msdn.microsoft.com/en-us/library/windows/hardware/dn934546(v=vs.85).aspx

  # Themes
  # https://msdn.microsoft.com/en-us/library/windows/hardware/dn934553(v=vs.85).aspx

  # ThemeName
  # https://msdn.microsoft.com/en-us/library/windows/hardware/dn934560(v=vs.85).aspx

    [bool]$ShowThisPCiconOnDesktop = $True
    [bool]$HideMCTLink = $False

}

Process {

    If (Test-Path "Unattend.xml") {
      del .\Unattend.xml
    }

    $UnattendFile = New-Item "Unattend.xml" -type File

        Set-Content -Path $UnattendFile -Value '<?xml version="1.0" encoding="utf-8"?>'
        Add-Content -Path $UnattendFile -Value "<!-- Created $(get-date) -->"
        Add-Content -Path $UnattendFile -Value '<unattend xmlns="urn:schemas-microsoft-com:unattend">'
        Add-Content -Path $UnattendFile -Value '	<settings pass="windowsPE">'
        Add-Content -Path $UnattendFile -Value '		<component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        Add-Content -Path $UnattendFile -Value '			<SetupUILanguage>'
        Add-Content -Path $UnattendFile -Value "				<UILanguage>$UILanguage</UILanguage>"
        Add-Content -Path $UnattendFile -Value '			</SetupUILanguage>'
        Add-Content -Path $UnattendFile -Value "			<InputLocale>$InputLocale</InputLocale>"
        Add-Content -Path $UnattendFile -Value "			<SystemLocale>$SystemLocale</SystemLocale>"
        Add-Content -Path $UnattendFile -Value "			<UILanguage>$UILanguage</UILanguage>"
        Add-Content -Path $UnattendFile -Value "			<UILanguageFallback>$UILanguageFallback</UILanguageFallback>"
        Add-Content -Path $UnattendFile -Value "			<UserLocale>$UserLocale</UserLocale>"
        Add-Content -Path $UnattendFile -Value '		</component>'
        Add-Content -Path $UnattendFile -Value '	</settings>'
        Add-Content -Path $UnattendFile -Value '	<settings pass="specialize">'
        Add-Content -Path $UnattendFile -Value '		<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">'
        Add-Content -Path $UnattendFile -Value "			<ComputerName>$ComputerName</ComputerName>"

    If ([string]$RegisteredOrganization -ne "") {

        Add-Content -Path $UnattendFile -Value "			<RegisteredOrganization>$RegisteredOrganization</RegisteredOrganization>"

    }

    If ([string]$RegisteredOwner -ne "") {

        Add-Content -Path $UnattendFile -Value "			<RegisteredOwner>$RegisteredOwner</RegisteredOwner>"

    }

        Add-Content -Path $UnattendFile -Value "			<DisableAutoDaylightTimeSet>$($DisableAutoDaylightTimeSet.ToString().ToLower())</DisableAutoDaylightTimeSet>"
        Add-Content -Path $UnattendFile -Value "			<TimeZone>$TimeZone</TimeZone>"
        Add-Content -Path $UnattendFile -Value '		</component>'
        Add-Content -Path $UnattendFile -Value '		<component name="Microsoft-Windows-IE-InternetExplorer" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        Add-Content -Path $UnattendFile -Value "			<Home_Page>$Home_Page</Home_Page>"
      # Add-Content -Path $UnattendFile -Value "			<DisableWelcomePage>$($DisableWelcomePage.ToString().ToLower())</DisableWelcomePage>" # This setting has been deprecated in Windows 10. The information about this deprecated setting is provided for reference only.
        Add-Content -Path $UnattendFile -Value "			<DisableFirstRunWizard>$($DisableFirstRunWizard.ToString().ToLower())</DisableFirstRunWizard>"
        Add-Content -Path $UnattendFile -Value '		</component>'
        Add-Content -Path $UnattendFile -Value '		<component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        Add-Content -Path $UnattendFile -Value '			<RunSynchronous>'

    If ([bool]$DisableWindowsConsumerFeatures -eq $True) {

        $RunSynchronousDescription = 'Disable Windows Consumer Features'
        $RunSynchronousPath = 'reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" /t REG_DWORD /v DisableWindowsConsumerFeatures /d 1 /f'
        $RunSynchronousOrder = $RunSynchronousOrder + 1

        Add-Content -Path $UnattendFile -Value '				<RunSynchronousCommand wcm:action="add">'
        Add-Content -Path $UnattendFile -Value "					<Description>$RunSynchronousDescription</Description>"
        Add-Content -Path $UnattendFile -Value "					<Order>$RunSynchronousOrder</Order>"
        Add-Content -Path $UnattendFile -Value "					<Path>$RunSynchronousPath</Path>"
        Add-Content -Path $UnattendFile -Value '				</RunSynchronousCommand>'

      # Ref.: https://blogs.technet.microsoft.com/mniehaus/2015/11/23/seeing-extra-apps-turn-them-off/
    }

    If ([bool]$DisableFirstRunWizard -eq $True) {

        $RunSynchronousDescription = 'Disable First Logon Animation'
        $RunSynchronousPath = 'reg.exe add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /t REG_DWORD /v EnableFirstLogonAnimation /d 0 /f'
        $RunSynchronousOrder = $RunSynchronousOrder + 1

        Add-Content -Path $UnattendFile -Value '				<RunSynchronousCommand wcm:action="add">'
        Add-Content -Path $UnattendFile -Value "					<Description>$RunSynchronousDescription</Description>"
        Add-Content -Path $UnattendFile -Value "					<Order>$RunSynchronousOrder</Order>"
        Add-Content -Path $UnattendFile -Value "					<Path>$RunSynchronousPath</Path>"
        Add-Content -Path $UnattendFile -Value '				</RunSynchronousCommand>'

      # Ref.: https://blogs.technet.microsoft.com/mniehaus/2015/08/23/windows-10-mdt-2013-update-1-and-hideshell/

    }

    If ([bool]$EnableLSAprotection -eq $True) {

        $RunSynchronousDescription = 'Enable LSA protection of Credentials'
        $RunSynchronousPath = 'reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /t REG_DWORD /v RunAsPPL /d 1 /f'
        $RunSynchronousOrder = $RunSynchronousOrder + 1

        Add-Content -Path $UnattendFile -Value '				<RunSynchronousCommand wcm:action="add">'
        Add-Content -Path $UnattendFile -Value "					<Description>$RunSynchronousDescription</Description>"
        Add-Content -Path $UnattendFile -Value "					<Order>$RunSynchronousOrder</Order>"
        Add-Content -Path $UnattendFile -Value "					<Path>$RunSynchronousPath</Path>"
        Add-Content -Path $UnattendFile -Value '				</RunSynchronousCommand>'

      # Ref.: https://technet.microsoft.com/en-us/library/dn408187(v=ws.11).aspx
    }

    If ([string]$MicrosoftDeploymentPartnerID -ne "") {

        $RunSynchronousDescription = 'Assign Microsoft Deployment Partner ID'
        $RunSynchronousPath = 'reg.exe add "HKLM\SOFTWARE\Microsoft\Windows" /t REG_SZ /v DeployID /d ' + $MicrosoftDeploymentPartnerID + ' /f'
        $RunSynchronousOrder = $RunSynchronousOrder + 1

        Add-Content -Path $UnattendFile -Value '				<RunSynchronousCommand wcm:action="add">'
        Add-Content -Path $UnattendFile -Value "					<Description>$RunSynchronousDescription</Description>"
        Add-Content -Path $UnattendFile -Value "					<Order>$RunSynchronousOrder</Order>"
        Add-Content -Path $UnattendFile -Value "					<Path>$RunSynchronousPath</Path>"
        Add-Content -Path $UnattendFile -Value '				</RunSynchronousCommand>'

    }

    If ([bool]$ShowThisPCiconOnDesktop -eq $True) {

        $RunSynchronousDescription = 'Show "This PC" icon on Desktop'
        $RunSynchronousPath = 'reg.exe add "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /t REG_DWORD /v {20D04FE0-3AEA-1069-A2D8-08002B30309D} /d 0 /f'
        $RunSynchronousOrder = $RunSynchronousOrder + 1

        Add-Content -Path $UnattendFile -Value '				<RunSynchronousCommand wcm:action="add">'
        Add-Content -Path $UnattendFile -Value "					<Description>$RunSynchronousDescription</Description>"
        Add-Content -Path $UnattendFile -Value "					<Order>$RunSynchronousOrder</Order>"
        Add-Content -Path $UnattendFile -Value "					<Path>$RunSynchronousPath</Path>"
        Add-Content -Path $UnattendFile -Value '				</RunSynchronousCommand>'

    }

    If ([bool]$HideMCTLink -eq $True) {

        $RunSynchronousDescription = 'Hide MCT Link'
        $RunSynchronousPath = 'reg.exe add "HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /t REG_DWORD /v HideMCTLink /d 1 /f'
        $RunSynchronousOrder = $RunSynchronousOrder + 1
		
        Add-Content -Path $UnattendFile -Value '				<RunSynchronousCommand wcm:action="add">'
        Add-Content -Path $UnattendFile -Value "					<Description>$RunSynchronousDescription</Description>"
        Add-Content -Path $UnattendFile -Value "					<Order>$RunSynchronousOrder</Order>"
        Add-Content -Path $UnattendFile -Value "					<Path>$RunSynchronousPath</Path>"
        Add-Content -Path $UnattendFile -Value '				</RunSynchronousCommand>'

		# Ref.: support.microsoft.com/en-us/help/4019198/how-to-disable-windows-creators-update-notice-for-users
    }

        Add-Content -Path $UnattendFile -Value '			</RunSynchronous>'
        Add-Content -Path $UnattendFile -Value '		</component>'
        Add-Content -Path $UnattendFile -Value '	</settings>'
        Add-Content -Path $UnattendFile -Value '	<settings pass="oobeSystem">'
        Add-Content -Path $UnattendFile -Value '		<component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
        Add-Content -Path $UnattendFile -Value "			<InputLocale>$InputLocale</InputLocale>"
        Add-Content -Path $UnattendFile -Value "			<SystemLocale>$SystemLocale</SystemLocale>"
        Add-Content -Path $UnattendFile -Value "			<UILanguage>$UILanguage</UILanguage>"
        Add-Content -Path $UnattendFile -Value "			<UILanguageFallback>$UILanguageFallback</UILanguageFallback>"
        Add-Content -Path $UnattendFile -Value "			<UserLocale>$UserLocale</UserLocale>"
        Add-Content -Path $UnattendFile -Value '		</component>'
        Add-Content -Path $UnattendFile -Value '		<component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'

      # Add-Content -Path $UnattendFile -Value '			<FirstLogonCommands>'
      # Add-Content -Path $UnattendFile -Value '				<SynchronousCommand wcm:action="add">'
      # Add-Content -Path $UnattendFile -Value '					<Description>Orchestrator script</Description>'
      # Add-Content -Path $UnattendFile -Value '					<Order>1</Order>'
      # Add-Content -Path $UnattendFile -Value '					<CommandLine>cmd.exe /c %SystemDrive%\Recovery\OEM\Orchestrator.cmd</CommandLine>'
      # Add-Content -Path $UnattendFile -Value '				</SynchronousCommand>'
      # Add-Content -Path $UnattendFile -Value '			</FirstLogonCommands>'

        Add-Content -Path $UnattendFile -Value '			<OOBE>'
        Add-Content -Path $UnattendFile -Value "				<HideEULAPage>$($HideEULAPage.ToString().ToLower())</HideEULAPage>"
        Add-Content -Path $UnattendFile -Value "				<HideOEMRegistrationScreen>$($HideOEMRegistrationScreen.ToString().ToLower())</HideOEMRegistrationScreen>"
        Add-Content -Path $UnattendFile -Value "				<HideOnlineAccountScreens>$($HideOnlineAccountScreens.ToString().ToLower())</HideOnlineAccountScreens>"
      # Add-Content -Path $UnattendFile -Value "				<HideLocalAccountScreen>$($HideLocalAccountScreen.ToString().ToLower())</HideLocalAccountScreen>" # This setting applies only to the Windows Server editions, setting is provided for reference only.
        Add-Content -Path $UnattendFile -Value "				<HideWirelessSetupInOOBE>$($HideWirelessSetupInOOBE.ToString().ToLower())</HideWirelessSetupInOOBE>"
      # Add-Content -Path $UnattendFile -Value "				<NetworkLocation>$NetworkLocation</NetworkLocation>" # This setting has been deprecated in Windows 10. The information about this deprecated setting is provided for reference only.
        Add-Content -Path $UnattendFile -Value "				<ProtectYourPC>$ProtectYourPC</ProtectYourPC>"
        Add-Content -Path $UnattendFile -Value '			</OOBE>'

      # Ref.: https://msdn.microsoft.com/windows/hardware/commercialize/customize/desktop/unattend/microsoft-windows-shell-setup-oobe

    If ([string]$RegisteredOrganization -ne "") {

        Add-Content -Path $UnattendFile -Value "			<RegisteredOrganization>$RegisteredOrganization</RegisteredOrganization>"

    }

    If ([string]$RegisteredOwner -ne "") {

        Add-Content -Path $UnattendFile -Value "			<RegisteredOwner>$RegisteredOwner</RegisteredOwner>"

    }

        Add-Content -Path $UnattendFile -Value "			<DisableAutoDaylightTimeSet>$($DisableAutoDaylightTimeSet.ToString().ToLower())</DisableAutoDaylightTimeSet>"
        Add-Content -Path $UnattendFile -Value "			<TimeZone>$TimeZone</TimeZone>"
        Add-Content -Path $UnattendFile -Value '		</component>'
        Add-Content -Path $UnattendFile -Value '	</settings>'
        Add-Content -Path $UnattendFile -Value '</unattend>'

}

End {

}
