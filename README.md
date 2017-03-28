# Windows Recovery Environment (WinRE)

<// ***Preliminary documentation*** //>

Rather than wiping a device and applying a new system image when you need to change configuration, you can reset the device to an original state. This project aim to return the device its original state, by maintaining vital settings (Computer name & Configuration Settings etc.)

### About Windows Recovery Environment (WinRE)
Windows Recovery Environment (WinRE) and Push-button reset features restore Windows 10 by constructing a new copy of the OS using runtime system files located in the Windows Component Store (C:\Windows\WinSxS). This allows recovery to be possible even without a separate recovery image containing a backup copy of all system files. 

### About this repository
This repository hosts customized files for Windows Recovery Environment (WinRE), compliance checks, and configuration tools for Windows 10. This repository can leverage to rebuild Windows 10 in various scenarios, however; the proposed solution does apply best in Cloud-only scenarios but can be easily modified to support Active Directory domain scenarios.

Questions or comments can be submitted to the [repository issue tracker](https://github.com/dotjesper/Windows-Recovery-Environment/issues).

### Repository content
<//>

**Folder structure**

<//>

**Scripts and tools**

Scripts for aiding with the solution can be found in the [Scripts](./Scripts) folder. Scripts available for use:
 - Deploy.cmd
 - Unattend.xml.ps1

### Getting started
<//>

**Downloading the repository**

Download the [current code]( https://github.com/dotjesper/Windows-Recovery-Environment/archive/master.zip) to your **Downloads** folder.

If the downloaded zip file is not unblocked before extracting it, then all the individual files that were in the zip file will have to be unblocked. You will need to run the following command:

``` PowerShell
Get-ChildItem -Path '.\Windows-Recovery-Environment' -Recurse -Include '*.*' | Unblock-File -Verbose
```

See the [Unblock-File command's documentation](https://technet.microsoft.com/en-us/library/hh849924.aspx) for more information on how to use it.

### Security considerations
Protecting the Recovery folder

``` Batchfile
attrib.exe +S +H +I "C:\Recovery\*.*" /s /d
icacls.exe "C:\Recovery\Customizations" /inheritance:r /T
icacls.exe "C:\Recovery\Customizations" /grant:r SYSTEM:(F) /T
icacls.exe "C:\Recovery\Customizations" /grant:r *S-1-5-32-544:(F) /T
icacls.exe "C:\Recovery\OEM" /inheritance:r /T
icacls.exe "C:\Recovery\OEM" /grant:r SYSTEM:(F) /T
icacls.exe "C:\Recovery\OEM" /grant:r *S-1-5-32-544:(F) /T
```

### Configure the system to start Windows RE next time the system starts up

``` Batchfile
:: Displays Windows RE and system reset configuration
   reagentc.exe /info

:: Configures the system to start Windows RE next time the system starts up.
   reagentc.exe /boottore
```

### License
See [LICENSE](./LICENSE.md).

### References

[Windows Recovery Environment (Windows RE)](https://msdn.microsoft.com/en-us/windows/hardware/commercialize/manufacture/desktop/windows-recovery-environment--windows-re--technical-reference)

[ResetConfig XML reference](https://msdn.microsoft.com/en-us/windows/hardware/commercialize/manufacture/desktop/resetconfig-xml-reference-s14)
