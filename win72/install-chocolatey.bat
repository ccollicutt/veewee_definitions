REM goto a temp directory
cd %SystemDrive%\windows\temp

cmd /c bitsadmin /transfer InstallChocolateyPS1 /download /priority normal https://raw.github.com/ferventcoder/chocolatey/master/chocolateyInstall/InstallChocolatey.ps1 %SystemDrive%\windows\temp\InstallChocolatey.ps1

cmd /c %windir%\System32\WindowsPowerShell\v1.0\powershell.exe -InputFormat none -NoProfile -ExecutionPolicy unrestricted -Command "& '%SystemDrive%\windows\temp\InstallChocolatey.ps1' %*"