@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo     Rime-Ice Configuration Script (Windows)
echo ==========================================
echo.

:: Configuration variables
set "RIME_ICE_REPO=https://gh-proxy.com/https://github.com/iDvel/rime-ice.git"
set "RIME_CONFIG_DIR=%APPDATA%\Rime"
set "TEMP_DIR=%TEMP%\rime-ice-temp"

echo [INFO] Checking system dependencies...

:: Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed, please install git first
    echo [INFO] Download from: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo [SUCCESS] Git is installed

:: Check if Weasel is installed
if not exist "%RIME_CONFIG_DIR%" (
    echo [WARNING] Weasel input method not detected
    echo [INFO] Download from: https://rime.im/download/
    set /p "continue=Continue anyway? (y/N): "
    if /i not "!continue!"=="y" (
        exit /b 1
    )
)
echo [SUCCESS] Weasel directory found

:: Create rime config directory
echo [INFO] Creating rime config directory...
if not exist "%RIME_CONFIG_DIR%" mkdir "%RIME_CONFIG_DIR%"
echo [SUCCESS] Rime config directory: %RIME_CONFIG_DIR%

:: Check rime-ice configuration status
echo [INFO] Checking rime-ice configuration status...
if exist "%RIME_CONFIG_DIR%\rime_ice.dict.yaml" (
    echo [INFO] rime-ice configuration detected
    set "RIME_ICE_CONFIGURED=1"
) else (
    echo [INFO] rime-ice not configured
    set "RIME_ICE_CONFIGURED=0"
)

:: Backup protected files
echo [INFO] Backing up protected files...
if exist "%RIME_CONFIG_DIR%\default.yaml" (
    copy "%RIME_CONFIG_DIR%\default.yaml" "%RIME_CONFIG_DIR%\default.yaml.backup" >nul
    echo [INFO] Backed up: default.yaml
)
if exist "%RIME_CONFIG_DIR%\squirrel.yaml" (
    copy "%RIME_CONFIG_DIR%\squirrel.yaml" "%RIME_CONFIG_DIR%\squirrel.yaml.backup" >nul
    echo [INFO] Backed up: squirrel.yaml
)
if exist "%RIME_CONFIG_DIR%\weasel.yaml" (
    copy "%RIME_CONFIG_DIR%\weasel.yaml" "%RIME_CONFIG_DIR%\weasel.yaml.backup" >nul
    echo [INFO] Backed up: weasel.yaml
)

:: Clone rime-ice repository
echo [INFO] Cloning rime-ice repository...

:: Clean temp directory
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
mkdir "%TEMP_DIR%"

:: Clone repository
git clone "%RIME_ICE_REPO%" "%TEMP_DIR%"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to clone rime-ice repository
    pause
    exit /b 1
)
echo [SUCCESS] rime-ice repository cloned successfully

:: Install rime-ice files
echo [INFO] Installing rime-ice files...

:: Copy all files to rime config directory
xcopy /e /y "%TEMP_DIR%\*" "%RIME_CONFIG_DIR%\" >nul
if %errorlevel% neq 0 (
    echo [ERROR] File copy failed
    pause
    exit /b 1
)
echo [SUCCESS] rime-ice files installation completed

:: Restore protected files
echo [INFO] Restoring protected files...
if exist "%RIME_CONFIG_DIR%\default.yaml.backup" (
    copy "%RIME_CONFIG_DIR%\default.yaml.backup" "%RIME_CONFIG_DIR%\default.yaml" >nul
    echo [INFO] Restored: default.yaml
)
if exist "%RIME_CONFIG_DIR%\squirrel.yaml.backup" (
    copy "%RIME_CONFIG_DIR%\squirrel.yaml.backup" "%RIME_CONFIG_DIR%\squirrel.yaml" >nul
    echo [INFO] Restored: squirrel.yaml
)
if exist "%RIME_CONFIG_DIR%\weasel.yaml.backup" (
    copy "%RIME_CONFIG_DIR%\weasel.yaml.backup" "%RIME_CONFIG_DIR%\weasel.yaml" >nul
    echo [INFO] Restored: weasel.yaml
)

:: Try to reload Weasel
echo [INFO] Trying to reload Weasel configuration...
for %%d in ("%PROGRAMFILES%\Rime" "%PROGRAMFILES(X86)%\Rime" "%LOCALAPPDATA%\Rime") do (
    if exist "%%d" (
        for /r "%%d" %%f in (weasel.exe) do (
            echo [INFO] Found Weasel at: %%f
            "%%f" /deploy >nul 2>&1
            if !errorlevel! equ 0 (
                echo [SUCCESS] Weasel configuration reloaded successfully
            ) else (
                echo [WARNING] Unable to automatically reload Weasel
                echo [INFO] Please right-click the Weasel icon in the taskbar and select 'Redeploy'
            )
            goto :weasel_done
        )
    )
)
:weasel_done

:: Clean up temporary files
echo [INFO] Cleaning up temporary files...
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"
echo [SUCCESS] Cleanup completed

:: Show configuration information
echo.
echo [INFO] rime-ice configuration information:
echo   Config directory: %RIME_CONFIG_DIR%
echo   Input method framework: Weasel
echo.
echo [INFO] After configuration, please redeploy Weasel to take effect
echo [INFO] Methods to redeploy Weasel:
echo [INFO] 1. Right-click the Weasel icon in the taskbar and select 'Redeploy'
echo [INFO] 2. Or run: weasel /deploy
echo [INFO] 3. Or restart the computer

echo.
echo [SUCCESS] rime-ice configuration completed!
pause
