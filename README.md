# Software-Automate-Installer-via-PSADT

### What is PSADT?

aka PowerShell App Deployment Toolkit

It is an open-source software that provides a set of funtions to perform installation and/or deployment on common applications in a corporate environment. It can be customize for personal usage too.

---

### Why use PSADT?

This app helps to install multiple softwares automatically via using PowerShell. It ease having the need of manual installation or when cloning of PC is not an option.

---

## The Folders Structure

![folderStructure](https://github.com/eggOnion/Software-Automate-Installer-via-PSADT/blob/main/imageSource/folderStructure.png?raw=true)

- **AppDeployToolkit:** Contain the image of your "Company banner." It contains some logic for the program and also the config file to set the directory path to the `Logs` folder is inside `AppDeployToolkitConfig.xml`

- **Files:** Place all the softwares that you want to install into this folder.

- **Logs:** It contains the log information once the app finished running.

- **Deploy-Application.exe:** The exe file that will execute this application to install all your softwares.

- **Deploy-Application.exe.config:** Keep it as it is.

- **Deploy-Application.ps1** Probably the most IMPORTANT part of the whole application where all the logic reside. It defines how your softwares are going to be installed, give permission to folders, set registry key, set environment variable, import certificates & etc...

  ***

## How to run the app

**The functions used in this application are:**

| Function                              | Description                          |
| ------------------------------------- | ------------------------------------ |
| `Show-InstallationProgress`             | Display message on the dialog box    |
| `Test-Path`                             | To locate in a directory path        |
| `Execute-Process`                       | Execute a msi file to run            |
| `Remove-File`                           | Delete an existing folder            |
| `Set-RegistryKey`                       | Create a new registry entries        |
| `Test-Path`                             | To locate in a directory path        |
| `Execute-Process`                       | Execute a msi file to run            |
| `Remove-File`                           | Delete an existing folder            |
| `Set-ItemPermission`                    | Give permission rights to a folder   |
| `[Environment]::SetEnvironmentVariable` | Set Environment variables in Windows |
| `Start-ServiceAndDependencies`          | Start a certain service              |
| `Import-Certificate`                    | Import a certificate                 |

**Placeholder that was used - Pls replaced it accordingily**

| Placeholder       | Description               |
| ----------------- | ------------------------- |
| `YourFolderPath`    | The path to that folder   |
| `YourExistingApp_1` | The name of your app      |
| `folderName_1`      | The name of your folder   |
| `software_1`        | The name of your software |

![setPathToLogsFolder](https://github.com/eggOnion/Software-Automate-Installer-via-PSADT/blob/main/imageSource/setPathToLogsFolder.png?raw=true)

1. `AppDeployToolkitConfig.xml`

- Line 23:
- <Toolkit_LogPath>$envHOMEDRIVE\YourDirectoryPath\PSADT_Installer\Logs
- Changed the `YourDirectoryPath` based on where you put your folder.

2. `Deploy-Application.ps1`
   Input your installation logic into this file adding to what was given in the examples.

3. Run the `Deploy-Application.exe` to start the installation process and wait for it to complete!

![companyMeow](https://github.com/eggOnion/Software-Automate-Installer-via-PSADT/blob/main/imageSource/companyMeow.png?raw=true)

---

## IMPORTANT NOTES!!!

**The application will force restart your PC in 10 seconds after the installation is done. Please save all your work beforehand.**

Try not to change the folder structure, especially the `Files` folder. The variable `$dirFiles` is pointing to this folder where all the installing softwares reside.

---

### References

[Github](https://github.com/PSAppDeployToolkit/PSAppDeployToolkit)<br/>
[Documentation](https://psappdeploytoolkit.com/docs/)
