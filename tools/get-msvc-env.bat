@echo off

setlocal ENABLEDELAYEDEXPANSION

@for /L %%i in (20, -1, 9) do (
@set COMMAND=set VS%%i0COMNTOOLS
@for /f "delims="  %%x in ('!COMMAND! 2^> nul') do (
@for /f "tokens=2 delims==" %%y in ('echo %%x') do (
call "%%yvsvars32.bat"
set VSINSTALLDIR
goto EXIT
)
)
)

:EXIT
endlocal