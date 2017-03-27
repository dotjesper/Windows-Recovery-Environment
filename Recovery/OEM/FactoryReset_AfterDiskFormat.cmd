@echo off

:: ------------------------------------------------------------------------------------
::  FactoryReset_AfterDiskFormat.cmd
:: ------------------------------------------------------------------------------------
::  Created: 11-05-2016 10:38 GMT+1 by @dotJesper
::  Edited:  15-03-2017 22:49 GMT+1 by @dotJesper
:: ------------------------------------------------------------------------------------
::  Revision 1.0: First edition
::  Revision 1.1: Minor changes
::  Revision 1.2: Changed %LogFile% from %TargetOS%\Panther\*.log
::				                      to %TargetOSDrive%\Recovery\OEM\LOGS\*.log
:: ------------------------------------------------------------------------------------
::  Comments: None
::
:: ------------------------------------------------------------------------------------

:: Define %ScriptFolder% (This later becomes C:\Recovery\OEM)
   SET ScriptFolder=%~dp0

:: Define %TargetOS% as the Windows folder (This later becomes C:\Windows)
   FOR /F "tokens=1,2,3 delims= " %%A IN ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\RecoveryEnvironment" /v TargetOS') DO SET TargetOS=%%C

:: Define %TargetOSDrive% as the Windows partition (This later becomes C:)
   FOR /F "tokens=1 delims=\" %%A IN ('ECHO %TargetOS%') DO SET TargetOSDrive=%%A

:: Set log file
   SET LogFile="%TargetOSDrive%\Recovery\OEM\LOGS\%~n0.log"
   IF EXIST "%LogFile%" (del "%LogFile%" /q /f)

   ECHO    %LogFile%
   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Date: %DATE% >> %LogFile%
   ECHO    Time: %TIME% >> %LogFile%
   ECHO    ScriptFolder: %ScriptFolder% >> %LogFile%
   ECHO    TargetOS: %TargetOS% >> %LogFile%
   ECHO    TargetOSDrive: %TargetOSDrive% >> %LogFile%

:: EOF
   ECHO ------------------------------------------------------------------------------- >> %LogFile%
   ECHO    Script ended %DATE% %TIME% >> %LOGFILE%

   EXIT /B 0
