@echo off
setlocal EnableDelayedExpansion

SET __DEBUGECHO=ECHO
IF NOT DEFINED __DEBUGECHO (SET __DEBUGECHO=REM)

REM bit is either 32 or 64
set "bit="
call set "bit=%%1"

set "ARCH="
set "CLARG="
if defined bit (
    goto :arg_exists
)
echo please include CLA for arch (32 or 64)
goto :exit

:arg_exists

if %bit%==32 (
    set ARCH=x86
) else if %bit%==64 (
    set ARCH=amd64
) else (
    echo please provide either 32 or 64 as command line argument.
    goto :EOF
)

REM setup Visual Studio
CALL :fn_ConfigVisualStudio

REM report the compiler architecture as a check
CALL :fn_GetCompilerArch

%__DEBUGECHO% *******************************
%__DEBUGECHO% *******************************
cl
%__DEBUGECHO% *******************************
%__DEBUGECHO% *******************************

%__DEBUGECHO% cleaning...
nmake -f Makefile.msc clean
if errorlevel 1 (echo clean error & goto :exit)

%__DEBUGECHO% building...
nmake -f Makefile.msc
if errorlevel 1 (echo build error & goto :exit)

move sqllogictest.exe sqllogictest_%bit%.exe 

%__DEBUGECHO% complete.

GOTO :exit

REM ***************************************************
:fn_ConfigVisualStudio
    REM
    REM Visual Studio 2017 / 2019 / 2022 / future versions (hopefully)...
    REM
    CALL :fn_TryUseVsWhereExe
    IF NOT DEFINED VSWHEREINSTALLDIR GOTO skip_detectVisualStudio2017
    SET VSVARS32=%VSWHEREINSTALLDIR%\Common7\Tools\VsDevCmd.bat
    IF EXIST "%VSVARS32%" (
            ECHO Using Visual Studio 2017 / 2019 / 2022...
            set CLARG=-arch=%ARCH%
            %__DEBUGECHO% VSVARS32="%VSVARS32%" %CLARG%
            GOTO skip_detectVisualStudio
    )
    :skip_detectVisualStudio2017

    REM
    REM Visual Studio 2015
    REM
    IF NOT DEFINED VS140COMNTOOLS GOTO skip_detectVisualStudio2015
    SET VSVARS32=%VS140COMNTOOLS%..\..\VC\vcvarsall.bat
    IF EXIST "%VSVARS32%" (
        ECHO Using Visual Studio 2015...
        if %bit%==64 (
            set CLARG=x86_%ARCH% 
        ) else (
            SET CLARG=%ARCH% 
        )
        %__DEBUGECHO% VSVARS32="%VSVARS32%" %ARCH%
        GOTO skip_detectVisualStudio
    )
    :skip_detectVisualStudio2015

    REM
    REM Visual Studio 2013
    REM
    IF NOT DEFINED VS120COMNTOOLS GOTO skip_detectVisualStudio2013
    SET VSVARS32=%VS120COMNTOOLS%..\..\VC\vcvarsall.bat
    IF EXIST "%VSVARS32%" (
        ECHO Using Visual Studio 2013...
        if %bit%==64 (
            set CLARG=x86_%ARCH% 
        ) else (
            SET CLARG=%ARCH% 
        )
        %__DEBUGECHO% VSVARS32="%VSVARS32%" %ARCH%
        GOTO skip_detectVisualStudio
    )
    :skip_detectVisualStudio2013

    REM
    REM Visual Studio 2012
    REM
    IF NOT DEFINED VS110COMNTOOLS GOTO skip_detectVisualStudio2012
    SET VSVARS32=%VS140COMNTOOLS%..\..\VC\vcvarsall.bat
    IF EXIST "%VSVARS32%" (
        ECHO Using Visual Studio 2012...
        if %bit%==64 (
            set CLARG=x86_%ARCH% 
        ) else (
            SET CLARG=%ARCH% 
        )
        %__DEBUGECHO% VSVARS32="%VSVARS32%" %ARCH%
        GOTO skip_detectVisualStudio
    )
    :skip_detectVisualStudio2012

    REM
    REM Visual Studio 2010
    REM
    IF NOT DEFINED VS100COMNTOOLS GOTO skip_detectVisualStudio2010
    SET VSVARS32=%VS100COMNTOOLS%..\..\VC\vcvarsall.bat
    IF EXIST "%VSVARS32%" (
        ECHO Using Visual Studio 2010...
        if %bit%==64 (
            set CLARG=x86_%ARCH% 
        ) else (
            SET CLARG=%ARCH% 
        )
        %__DEBUGECHO% VSVARS32="%VSVARS32%" %ARCH%
        GOTO skip_detectVisualStudio
    )
    :skip_detectVisualStudio2010

    REM
    REM NOTE: At this point, the appropriate Visual Studio version should be
    REM       selected.
    REM
    :skip_detectVisualStudio

    SET VSVARS32=%VSVARS32:\\=\%
    %__DEBUGECHO% "%VSVARS32%" %CLARG%
    CALL "%VSVARS32%" %CLARG% 1>nul
    GOTO :EOF

REM ***************************************************
:fn_GetCompilerArch
    set "cl_arch="
    SET _cmd=cl /? 
    FOR /F "delims=" %%G IN ('%_cmd% 2^>^&1 ^| findstr /C:"Version"') DO (
        for %%A in (%%G) do (
            set cl_arch=%%A
        )
    )
    echo cl.exe compiler architectue is %cl_arch%
    GOTO :EOF

REM ***************************************************
:fn_TryUseVsWhereExe
    IF DEFINED VSWHERE_EXE GOTO skip_setVsWhereExe
    SET VSWHERE_EXE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe
    IF NOT EXIST "%VSWHERE_EXE%" SET VSWHERE_EXE=%ProgramFiles%\Microsoft Visual Studio\Installer\vswhere.exe
    :skip_setVsWhereExe

    IF NOT EXIST "%VSWHERE_EXE%" (
        ECHO The "VsWhere" tool does not appear to be installed.
        GOTO :EOF
    ) ELSE (
        %__DEBUGECHO% VSWHERE_EXE="%VSWHERE_EXE%"
    )
    SET VS_WHEREIS_CMD="%VSWHERE_EXE%" -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath -latest
    %__DEBUGECHO% VS_WHEREIS_CMD=%VS_WHEREIS_CMD%

    FOR /F "delims=" %%D IN ('%VS_WHEREIS_CMD%') DO (SET VSWHEREINSTALLDIR=%%D)

    IF NOT DEFINED VSWHEREINSTALLDIR (
        ECHO Visual Studio 2017 / 2019 / 2022 is not installed.
    GOTO :EOF
    )
    %__DEBUGECHO% Visual Studio 2017 / 2019 / 2022 is installed.
    %__DEBUGECHO% VsWhereInstallDir = '%VSWHEREINSTALLDIR%'
    GOTO :EOF
    

:exit
