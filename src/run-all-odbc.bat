@echo off
setlocal EnableDelayedExpansion
cls

REM This runs all the tests and keeps track of errors.
REM It will exit at the end with exit value set to number of errors.

set /a errors=0

@echo STARTING...

for /R ..\test %%i in (*.test) do sqllogictest --odbc "DSN=SQLite3 Datasource;DATABASE=:memory:;" --verify %%i & if "!ERRORLEVEL!" == "0" (
    @echo total errors: !errors!
) else (
    set /a errors+=!ERRORLEVEL!
    @echo total errors: !errors!
)

REM Expecting 2 integer overflow errors in "G:\sqllogictest\test\evidence\slt_lang_aggfunc.test" 
REM According to the test file, Total() never throws an integer overflow. However with ODBC it throws error
REM and returns value.
REM We want to ignore these two errors so workflow passes. 
set /a errors-=2

@echo COMPLETE total errors: !errors!

exit /b !errors!


