<#
.SYNOPSIS
	This script performs the installation or uninstallation of an application(s).
	# LICENSE #
	PowerShell App Deployment Toolkit - Provides a set of functions to perform common application deployment tasks on Windows.
	Copyright (C) 2017 - Sean Lillis, Dan Cunningham, Muhammad Mashwani, Aman Motazedian.
	This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
	You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.
.DESCRIPTION
	The script is provided as a template to perform an install or uninstall of an application(s).
	The script either performs an "Install" deployment type or an "Uninstall" deployment type.
	The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.
	The script dot-sources the AppDeployToolkitMain.ps1 script which contains the logic and functions required to install or uninstall an application.
.PARAMETER DeploymentType
	The type of deployment to perform. Default is: Install.
.PARAMETER DeployMode
	Specifies whether the installation should be run in Interactive, Silent, or NonInteractive mode. Default is: Interactive. Options: Interactive = Shows dialogs, Silent = No dialogs, NonInteractive = Very silent, i.e. no blocking apps. NonInteractive mode is automatically set if it is detected that the process is not user interactive.
.PARAMETER AllowRebootPassThru
	Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.
.PARAMETER TerminalServerMode
	Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Destkop Session Hosts/Citrix servers.
.PARAMETER DisableLogging
	Disables logging to file for the script. Default is: $false.
.EXAMPLE
	powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeployMode 'Silent'; Exit $LastExitCode }"
.EXAMPLE
	powershell.exe -Command "& { & '.\Deploy-Application.ps1' -AllowRebootPassThru; Exit $LastExitCode }"
.EXAMPLE
	powershell.exe -Command "& { & '.\Deploy-Application.ps1' -DeploymentType 'Uninstall'; Exit $LastExitCode }"
.EXAMPLE
	Deploy-Application.exe -DeploymentType "Install" -DeployMode "Silent"
.NOTES
	60000 - 68999: Reserved for built-in exit codes in Deploy-Application.ps1, Deploy-Application.exe, and AppDeployToolkitMain.ps1
	69000 - 69999: Recommended for user customized exit codes in Deploy-Application.ps1
	70000 - 79999: Recommended for user customized exit codes in AppDeployToolkitExtensions.ps1
.LINK
	http://psappdeploytoolkit.com
#>
[CmdletBinding()]
Param (
	[Parameter(Mandatory=$false)]
	[ValidateSet('Install','Uninstall','Repair')]
	[string]$DeploymentType = 'Install',
	[Parameter(Mandatory=$false)]
	[ValidateSet('Interactive','Silent','NonInteractive')]
	[string]$DeployMode = 'Interactive',
	[Parameter(Mandatory=$false)]
	[switch]$AllowRebootPassThru = $false,
	[Parameter(Mandatory=$false)]
	[switch]$TerminalServerMode = $false,
	[Parameter(Mandatory=$false)]
	[switch]$DisableLogging = $false
)

Try {
	## Set the script execution policy for this process
	Try { Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope 'Process' -Force -ErrorAction 'Stop' } Catch {}

	##*===============================================
	##* VARIABLE DECLARATION
	##*===============================================
	## Variables: Application
	[string]$appVendor = 'Company Meow'
	[string]$appName = 'YourApp_Installation'
	[string]$appVersion = 'v1.1.0'
	[string]$appArch = 'x64'
	[string]$appLang = 'EN'
	[string]$appRevision = '1'
	[string]$appScriptVersion = '1.1.0'
	[string]$appScriptDate = '08/12/2021'
	[string]$appScriptAuthor = 'weicong_tong'
	##*===============================================
	## Variables: Install Titles (Only set here to override defaults set by the toolkit)
	[string]$installName = ''
	[string]$installTitle = ''

	##* Do not modify section below
	#region DoNotModify

	## Variables: Exit Code
	[int32]$mainExitCode = 0

	## Variables: Script
	[string]$deployAppScriptFriendlyName = 'Deploy Application'
	[version]$deployAppScriptVersion = [version]'3.8.4'
	[string]$deployAppScriptDate = '26/01/2021'
	[hashtable]$deployAppScriptParameters = $psBoundParameters

	## Variables: Environment
	If (Test-Path -LiteralPath 'variable:HostInvocation') { $InvocationInfo = $HostInvocation } Else { $InvocationInfo = $MyInvocation }
	[string]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

	## Dot source the required App Deploy Toolkit Functions
	Try {
		[string]$moduleAppDeployToolkitMain = "$scriptDirectory\AppDeployToolkit\AppDeployToolkitMain.ps1"
		If (-not (Test-Path -LiteralPath $moduleAppDeployToolkitMain -PathType 'Leaf')) { Throw "Module does not exist at the specified location [$moduleAppDeployToolkitMain]." }
		If ($DisableLogging) { . $moduleAppDeployToolkitMain -DisableLogging } Else { . $moduleAppDeployToolkitMain }
	}
	Catch {
		If ($mainExitCode -eq 0){ [int32]$mainExitCode = 60008 }
		Write-Error -Message "Module [$moduleAppDeployToolkitMain] failed to load: `n$($_.Exception.Message)`n `n$($_.InvocationInfo.PositionMessage)" -ErrorAction 'Continue'
		## Exit the script, returning the exit code to SCCM
		If (Test-Path -LiteralPath 'variable:HostInvocation') { $script:ExitCode = $mainExitCode; Exit } Else { Exit $mainExitCode }
	}

	#endregion
	##* Do not modify section above
	##*===============================================
	##* END VARIABLE DECLARATION
	##*===============================================

	If ($deploymentType -ine 'Uninstall' -and $deploymentType -ine 'Repair') {
		##*===============================================
		##* PRE-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Installation'

		## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt
		## Show-InstallationWelcome -CloseApps 'iexplore' -AllowDefer -DeferTimes 0 -CheckDiskSpace -PersistPrompt

		## Show Progress Message (with the default message)

		##Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 1 of xx"



<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Perform un-installation of old software below~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #>

	## Pre-requisite registry checks - for .Net Framework 3.5 & Visual C++ Rd 2019 14.28 or higher version
    ## This installer will not run, if the pre-requisite checks fail
	If ((Test-Path "HKLM:\SOFTWARE\Microsoft\.NETFramework\AssemblyFolders\v3.5") -and (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\AssemblyFolders\v3.5") -and (Test-Path "HKLM:\SOFTWARE\Microsoft\MSBuild\ToolsVersions\3.5") -and (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\MSBuild\ToolsVersions\3.5") -and (Test-Path "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v3.5") -and (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\NET Framework Setup\NDP\v3.5") -and (((Test-Path "HKLM:\SOFTWARE\Classes\Installer\Dependencies\VC,redist.x64,amd64,14.28,bundle") -and (Test-Path "HKLM:\SOFTWARE\Classes\Installer\Dependencies\VC,redist.x86,x86,14.28,bundle")) -or ((Test-Path "HKLM:\SOFTWARE\Classes\Installer\Dependencies\VC,redist.x64,amd64,14.29,bundle") -and (Test-Path "HKLM:\SOFTWARE\Classes\Installer\Dependencies\VC,redist.x86,x86,14.29,bundle")) -or ((Test-Path "HKLM:\SOFTWARE\Classes\Installer\Dependencies\VC,redist.x64,amd64,14.30,bundle") -and (Test-Path "HKLM:\SOFTWARE\Classes\Installer\Dependencies\VC,redist.x86,x86,14.30,bundle")))){


		Show-InstallationProgress -StatusMessage "Un-installation of old software...`n Part 1 of 2" 
		if(Test-Path -Path "$envProgramFilesX86\YourFolderPath\uninstall.exe") {
			Execute-Process -Path "$envProgramFilesX86\YourFolderPath\uninstall.exe" -Parameters '/S /D' -IgnoreExitCodes '1223'
		}

        Show-InstallationProgress -StatusMessage "Un-installation of old software...`n Part 2 of 2"
		if(Test-Path -Path "$envProgramFilesX86\YourFolderPath\YourExistingApp_2") {
		    Execute-MSI -Action 'Uninstall' -Path "$envProgramFilesX86\YourFolderPath\YourExistingApp_2.msi" -Parameters '/quiet'	
		}		
    
		if(Test-Path -Path "$envProgramFilesX86\YourFolderPath\YourExistingApp_1") {
			Remove-File -Path "$envProgramFilesX86\YourFolderPath\YourExistingApp_1" -recurse
		}
		if(Test-Path -Path "$envProgramData\YourFolderPath\YourExistingApp_2") {
			Remove-File -Path "$envProgramData\YourFolderPath\YourExistingApp_2" -recurse
		}
		

		Show-InstallationProgress -StatusMessage "Un-installation Completed!!!"


		
<# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ YourApp Installation Starts below!!!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#> 



		## 1. Install software_1 - exe
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 1 of xx"
		Execute-Process -Path "$dirFiles\folderName_1\software_1.exe" -Parameters '/S /D PW=xxx' -IgnoreExitCodes '1223' -SecureParameters
 

		## 2. Install software_2 - msi
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 2 of xx" 
		Execute-MSI -Action 'Install' -Path "$dirFiles\folderName_2\software_2.msi" -Parameters '/quiet'


        ##3. Install software_3 - set compatibility mode		
        ##Some installer might not be compatible with Win10 or 11 thus using this setting might helps
        Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 3 of xx"
		Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers' -Name 'C:\YourFolderPath\Files\$fileName_3\$software_3.msi' -Value "~ MSIAUTO"
		Execute-MSI -Action 'Install' -Path "$dirFiles\folderName_3\software_3.msi" -Parameters '/quiet' -IgnoreExitCodes '1603' 
		

		## Create registry entries
		Show-InstallationProgress -StatusMessage "Creating registry entries..."		
		Execute-Process -Path "$envProgramFilesX86\YourFolderPath\Dependencies\LibRegistration.bat"
		Set-RegistryKey -Key 'HKEY_CLASSES_ROOT\software_3_dependency'
		
		##Declaring HKCR as a variable to be use
		New-PSDrive -Name 'HKCR' -PSProvider 'Registry' -Root 'HKEY_CLASSES_ROOT'

		##Set FullControl to software_3 dependency in registry entries
		$software_3_acl = get-acl -path "HKCR:\software_3"
		$software_3_rule = New-Object System.Security.AccessControl.RegistryAccessRule("BUILTIN\Users", "FullControl", "Allow")
		$software_3_acl.SetAccessRule($software_3_rule)
		$software_3_acl|set-acl -path "HKCR:\software_3"
		

		##4. Install software_4 - MySQL8.0
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 4 of xx" 
		Execute-MSI -Action 'Install' -Path "$dirFiles\folderName_4\mysql-installer-community.msi" -Parameters '/quiet' 

		Execute-Process -Path "$envProgramFilesX86\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe" -Parameters 'community install j;8.0.23 -silent' 
		Execute-Process -Path "$envProgramFilesX86\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe" -Parameters 'community install shell;8.0.23 -silent' 
		Execute-Process -Path "$envProgramFilesX86\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe" -Parameters 'community install server;8.0.23:*:type=config;openfirewall=false;port=3308;rootpasswd=password -silent'  -SecureParameters:$true

		Execute-Process -Path "$envProgramFiles\MySQL\MySQL Server 8.0\bin\mysql.exe" -Parameters '-uroot -ppassword --port=3308 --execute="source C:\YourFolderPath\SQL Scripts\createTables.sql"' -IgnoreExitCodes '1' -SecureParameters:$true		
		Execute-Process -Path "$envProgramFiles\MySQL\MySQL Server 8.0\bin\mysql.exe" -Parameters '--user="app_sa" --password="password" --port="3308" --execute="source C:\YourFolderPath\SQL Scripts\app_sa_structure20210401.sql"' -IgnoreExitCodes '1' -SecureParameters:$true
		
		Execute-Process -Path "$envProgramFilesX86\MySQL\MySQL Installer for Windows\MySQLInstallerConsole.exe" -Parameters 'community install workbench;8.0.23 -silent'


		##5. Give Full-Control permission to folder
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 5 of xx" 
		Set-ItemPermission -Path "$envHomeDrive\Program Files (x86)\YourFolderPath\folderName" -User $YourDomain\Users -Permission 'FullControl' -Inheritance "ObjectInherit","ContainerInherit"		

		##6. Set Environment Variable
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 6 of xx" 		
		[Environment]::SetEnvironmentVariable("Path", $env:Path + ";" + "C:\Program Files (x86)\YourFolderPath", "Machine")		
		[Environment]::SetEnvironmentVariable("JRE_HOME", "C:\Program Files (x86)\YourFolderPath", "Machine")		
		[Environment]::SetEnvironmentVariable("JAVA_MAJOR_VERSION", "15", "Process")		
		Start-ServiceAndDependencies -Name 'TomEE'
		
		
		##7. Installing Fonts through registry
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 7 of xx" 
		Set-RegistryKey -Key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts' -Name 'Free 3 of 9 Regular (TrueType)' -Value "C:\YourFolderPath\Files\fonts\FREE3OF9.TTF"


		##8. Import cert
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 8 of xx" 	
		Import-Certificate -FilePath "$dirFiles\Certs\YourApp.cer" -CertStoreLocation Cert:\LocalMachine\Root


		##9. Execute inf file for your peripherals driver
		Show-InstallationProgress -StatusMessage "Installation in Progress...`n Part 9 of xx"		

			##Installing the .inf files 
			Execute-Process -Path 'PnPutil.exe' -Parameters "/add-driver `"$dirFiles\folderName_5\InSight_One.inf`" /install"
			Execute-Process -Path 'PnPutil.exe' -Parameters "/add-driver `"$dirFiles\folderName_5\UMX.inf`" /install"	
			

		Show-InstallationProgress -StatusMessage "Installation Completed!!!" 


<#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~YourApp Installation Ends Here~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#>


		##*===============================================
		##* INSTALLATION
		##*===============================================
		[string]$installPhase = 'Installation'

		## Handle Zero-Config MSI Installations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Install'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat; If ($defaultMspFiles) { $defaultMspFiles | ForEach-Object { Execute-MSI -Action 'Patch' -Path $_ } }
		}

		## <Perform Installation tasks here>

			##Execute-Process -Path 'winrar-x64-601b1.exe' -Parameters '/S'
			
			
		##*===============================================
		##* POST-INSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Installation'

		## <Perform Post-Installation tasks here>

		## Display a message at the end of the install
		
		If (-not $useDefaultMsi) {

		Show-InstallationPrompt -Message 'Congratulations! Your Application have been installed successfully.' -ButtonRightText 'OK' -Icon Information -NoWait;
        Show-BalloonTip -BalloonTipIcon 'Info' -BalloonTipText "Installation Complete!    
        Please RESTART your PC. Thank You!" -NoWait
        Show-InstallationRestartPrompt
        }

    }

    else{
        Show-DialogBox -Title 'Your Application Installation’ -Text "Installation Halt! Prerequisite Check Failed. `n`n 1. .Net Framework 3.5 not installed `n 2. Visual C++ 2015-2019 Redistributable not installed" -Icon ‘Information’
        Show-BalloonTip -BalloonTipIcon 'Info' -BalloonTipText "Prerequisite Check Failed!"
    }
}

	ElseIf ($deploymentType -ieq 'Uninstall')
	{
		##*===============================================
		##* PRE-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Pre-Uninstallation'

		## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing
		Show-InstallationWelcome -CloseApps 'iexplore' -CloseAppsCountdown 60

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Uninstallation tasks here>


		##*===============================================
		##* UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Uninstallation'

		## Handle Zero-Config MSI Uninstallations
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Uninstall'; Path = $defaultMsiFile }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}

		# <Perform Uninstallation tasks here>


		##*===============================================
		##* POST-UNINSTALLATION
		##*===============================================
		[string]$installPhase = 'Post-Uninstallation'

		## <Perform Post-Uninstallation tasks here>


	}
	ElseIf ($deploymentType -ieq 'Repair')
	{
		##*===============================================
		##* PRE-REPAIR
		##*===============================================
		[string]$installPhase = 'Pre-Repair'

		## Show Progress Message (with the default message)
		Show-InstallationProgress

		## <Perform Pre-Repair tasks here>

		##*===============================================
		##* REPAIR
		##*===============================================
		[string]$installPhase = 'Repair'

		## Handle Zero-Config MSI Repairs
		If ($useDefaultMsi) {
			[hashtable]$ExecuteDefaultMSISplat =  @{ Action = 'Repair'; Path = $defaultMsiFile; }; If ($defaultMstFile) { $ExecuteDefaultMSISplat.Add('Transform', $defaultMstFile) }
			Execute-MSI @ExecuteDefaultMSISplat
		}
		# <Perform Repair tasks here>

		##*===============================================
		##* POST-REPAIR
		##*===============================================
		[string]$installPhase = 'Post-Repair'

		## <Perform Post-Repair tasks here>


    }
	##*===============================================
	##* END SCRIPT BODY
	##*===============================================

	## Call the Exit-Script function to perform final cleanup operations
	Exit-Script -ExitCode $mainExitCode
}
Catch {
	[int32]$mainExitCode = 60001
	[string]$mainErrorMessage = "$(Resolve-Error)"
	Write-Log -Message $mainErrorMessage -Severity 3 -Source $deployAppScriptFriendlyName
	Show-DialogBox -Text $mainErrorMessage -Icon 'Stop'
	Exit-Script -ExitCode $mainExitCode
}
