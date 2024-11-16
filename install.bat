@echo off
rem ホームディレクトリを取得
set HOME=%USERPROFILE%

rem .config フォルダをホームディレクトリにコピー
xcopy ".config" "%HOME%\.config" /E /I /Y

echo install complete!