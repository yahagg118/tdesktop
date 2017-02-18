@echo off

SET BUILD_DIR=C:\TBuild
set LIB_DIR=%BUILD_DIR%\Libraries
set SRC_DIR=%BUILD_DIR%\tdesktop
SET QT_VERSION=5_6_2

cd %BUILD_DIR%

call "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\vcvarsall.bat" x86

::call:configureBuild
call:getDependencies
call:setupGYP

echo Finished!

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

	echo %BUILD_VERSION% | findstr /C:"disable_autoupdate">nul && (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_AUTOUPDATE
    )

	echo %BUILD_VERSION% | findstr /C:"disable_register_custom_scheme">nul && (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_REGISTER_CUSTOM_SCHEME
    )

	echo %BUILD_VERSION% | findstr /C:"disable_crash_reports">nul && (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_CRASH_REPORTS
    )

	echo %BUILD_VERSION% | findstr /C:"disable_network_proxy">nul && (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_NETWORK_PROXY
    )

	echo %BUILD_VERSION% | findstr /C:"disable_desktop_file_generation">nul && (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_DESKTOP_FILE_GENERATION
    )

	echo %BUILD_VERSION% | findstr /C:"disable_unity_integration">nul && (
        set GYP_DEFINES=%GYP_DEFINES%,TDESKTOP_DISABLE_UNITY_INTEGRATION
    )

	call:logInfo "GYP Defines: %GYP_DEFINES%"
	::setx GYP_DEFINES "%GYP_DEFINES%"
GOTO:EOF
