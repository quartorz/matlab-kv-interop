@echo off

setlocal ENABLEDELAYEDEXPANSION

@for /L %%i in (100, -1, 9) do (
@set COMMAND=set VS%%i0COMNTOOLS
@for /f "delims="  %%x in ('!COMMAND! 2^> nul') do (
@for /f "tokens=2 delims==" %%y in ('echo %%x') do (
call "%%yvsvars32.bat"
@for /f "tokens=2 delims==" %%z in ('set VSINSTALLDIR') do (
echo %%z
goto EXIT
)
)
)
)

:EXIT
endlocal