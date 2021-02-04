@echo off
REM
REM Name:         SharkJack Unofficial Payload Library UI (Windows 10 Patcher)
REM Version:      1.1
REM Author:       REDD
REM Target OS:    Windows 10
REM Description:  This is the patch script for the Unofficial
REM               SharkJack Payload Library. -Enjoy
REM

SET "SHARK_IP=172.16.24.1"
cls
echo Please put SharkJack into Arming Mode and
echo connect it to the Ethernet Port on your PC.
echo.
echo.
echo Waiting..
echo.
:loop
ping -n 1 %SHARK_IP% |find "TTL=" >NUL 2>NUL || goto :loop
echo Connected.
timeout /t 2 /NOBREAK >NUL

:MENU
cls
echo.
echo.
echo O=====================================O
echo ^|                                     ^|
echo ^|         SharkJack Patcher (WIN)     ^| 
echo ^|              by REDD                ^|
echo O=====================================O
echo.
echo   1. Install Payload Library Patch
echo   2. Remove Payload Library Patch
echo.
echo   0. Exit Patcher
echo.
SET /P MENU1=Select # from Menu and Press ENTER:

IF "%MENU1%"=="1" GOTO INSTALL_PATCH
IF "%MENU1%"=="2" GOTO REMOVE_PATCH

IF /I "%MENU1%"=="q" GOTO EOF
IF /I "%MENU1%"=="e" GOTO EOF
IF /I "%MENU1%"=="quit" GOTO EOF
IF /I "%MENU1%"=="exit" GOTO EOF
IF /I "%MENU1%"=="0" GOTO EOF
GOTO MENU

:INSTALL_PATCH
echo Connecting to the SharkJack..
echo.
echo YOU WILL HAVE TO ENTER YOUR SHARKJACK PASSWORD EACH STEP.
echo (Input password: hak5shark   OR  Password you have already set.)
echo.
echo  -^> SSH'ing into SharkJack to prepare patch directory.
ssh root@%SHARK_IP% "mkdir -p /tmp/patch;exit"
echo.
echo  -^> Copying patch installer.
scp "%CD%\patch.sh" "root@%SHARK_IP%:/tmp/patch.sh"
echo.
echo  -^> Copying patch content. (library command)
scp "%CD%\patch\library" root@%SHARK_IP%:/tmp/patch/library
echo.
echo  -^> Copying patch content. (library.sh)
scp "%CD%\patch\library.sh" root@%SHARK_IP%:/tmp/patch/library.sh
echo.
echo  -^> Executing patcher, and fixing permissions.
ssh root@%SHARK_IP% "/bin/bash /tmp/patch.sh;chmod 0755 /www/cgi-bin/library.sh;exit"
echo.
echo Press ENTER to return to Menu.
PAUSE >NUL
GOTO MENU

:REMOVE_PATCH
echo Connecting to the SharkJack..
echo.
echo (Input password: hak5shark   OR  Password you have already set.)
echo.
echo  -^> Removing Payload Library patch and files. Restoring to Stock Web UI.
ssh root@%SHARK_IP% "/bin/bash /tmp/patch.sh --remove;rm -rf /tmp/patch;rm /tmp/patch.sh;exit"
echo.
echo Press ENTER to return to Menu.
PAUSE >NUL
GOTO MENU
