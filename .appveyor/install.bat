@echo off
@setlocal enableextensions enabledelayedexpansion

SET BUILD_DIR=C:\TBuild
set LIB_DIR=%BUILD_DIR%\Libraries
set SRC_DIR=%BUILD_DIR%\tdesktop
SET QT_VERSION=5_6_2

cd %BUILD_DIR%

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86

call:configureBuild
call:getDependencies
call:setupGYP

echo Finished!
endlocal

GOTO:EOF

:: FUNCTIONS
:logInfo
    echo [INFO] %~1
GOTO:EOF

:getDependencies
    call:logInfo "Clone dependencies repository"
    git clone -q --branch=master https://github.com/telegramdesktop/dependencies_windows.git %LIB_DIR%
    cd %LIB_DIR%

	call prepare.bat
GOTO:EOF

:setupGYP
    call:logInfo "Setup GYP/Ninja and generate VS solution"
    cd %LIB_DIR%
	git clone https://chromium.googlesource.com/external/gyp
    SET PATH=%PATH%;C:\TBuild\Libraries\gyp;C:\TBuild\Libraries\ninja;
    cd ..\tdesktop\Telegram
    call gyp\refresh.bat
GOTO:EOF

:configureBuild
    call:logInfo "Configuring build"
	call:logInfo "Build version: %BUILD_VERSION%"
	set GYP_DEFINES=

	if not x"%BUILD_VERSION:disable_autoupdate=%"==x"%BUILD_VERSION%" (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_AUTOUPDATE
    )

	if not x"%BUILD_VERSION:disable_register_custom_scheme=%"==x"%BUILD_VERSION%" (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME
    )

	if not x"%BUILD_VERSION:disable_crash_reports=%"==x"%BUILD_VERSION%" (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_CRASH_REPORTS
    )

	if not x"%BUILD_VERSION:disable_network_proxy=%"==x"%BUILD_VERSION%" (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_NETWORK_PROXY
    )

	if not x"%BUILD_VERSION:disable_desktop_file_generation=%"==x"%BUILD_VERSION%" (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_DESKTOP_FILE_GENERATION
    )

	if not x"%BUILD_VERSION:disable_unity_integration=%"==x"%BUILD_VERSION%" (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_UNITY_INTEGRATION
    )

	call:logInfo "GYP Defines: %GYP_DEFINES%"
	setx GYP_DEFINES "%GYP_DEFINES%"
GOTO:EOF
