echo off

rem cmd> zip_to_itch_with_args.bat <dir_name> <game_url_name>

del /q %1.zip
7z a %1.zip %1
C:\Users\test\Downloads\butler-windows-amd64\butler.exe push %1.zip murchanskii/%2:html