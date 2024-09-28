@echo off

if "%1" == "/?" (
echo Enter directory as an arg to convert txt files from ur directory from cp866 encoding to utf-8 encoding
echo If any mistakes happen, the program will output an error level
exit /b
)

if "%1" == "" (
echo Enter "/?" without quotation marks to get help
exit /b
)

if EXIST %1 (
for /r "%1" %%f in (*.txt) do (
copy /b "%%f" "%%f-timeFail.txt" > nul
echo.>"%%f"
iconv -f cp866 -t utf-8 "%%f-timeFail.txt" > "%%f"
del "%%f-timeFail.txt"
)
echo Convertation is done
) else (
echo This folder does not exist
)

if %errorlevel% NEQ 0 (
  echo Error level %errorlevel%
)