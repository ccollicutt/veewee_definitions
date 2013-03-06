REM goto a temp directory
cd %SystemDrive%\windows\temp

cmd /c bitsadmin /transfer DotNetFx40_Full_setup /download /priority normal http://packages.serverascode.com/windows/dotNetFx40_Full_setup.exe %SystemDrive%\windows\temp\dotNetFx40_Full_setup.exe

REM run the installation
start /wait %SystemDrive%\windows\temp\dotNetFx40_Full_setup.exe /passive /norestart