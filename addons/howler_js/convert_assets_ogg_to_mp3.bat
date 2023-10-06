@echo off

rem USAGE
rem ASSETS FOLDER MUST BE IN THE ROOT OF THE PROJECT FILESYSTEM
rem convert_assets_ogg_to_mp3.bat <path_to_assets_folder> <path_to_new_assets_folder_location>		<--- append
rem convert_assets_ogg_to_mp3.bat /r <path_to_assets_folder> <path_to_new_assets_folder_location>	<--- rewrite


setlocal ENABLEDELAYEDEXPANSION

set TRUE=1==1
set FALSE=1==0

set "IsRewrite=%FALSE%"
set "AssetsPath=%1"
set "ExportPath=%2"
set "ProjectFolderPath=%~dp1"
set "AbsExportPath=%~dpn2\%~n1"
set "AbsAssetsPath=%~dpn1"

if "%1" == "/r" (
	set "IsRewrite=%TRUE%"
	set "AssetsPath=%2"
	set "ExportPath=%3"
	set "ProjectFolderPath=%~dp2"
	set "AbsExportPath=%~dpn3\%~n2"
	set "AbsAssetsPath=%~dpn2"
) else (
	if "%1" == "/R" (
		set "IsRewrite=%TRUE%"
		set "AssetsPath=%2"
		set "ExportPath=%3"
		set "ProjectFolderPath=%~dp2"
		set "AbsExportPath=%~dpn3\%~n2"
		set "AbsAssetsPath=%~dpn2"
	)
)

if not "%AssetsPath%" == "" (
	pushd "%AssetsPath%"
)

if %IsRewrite% (
	if not "%ExportPath%" == "" (
		if exist !AbsExportPath! del /s /q !AbsExportPath!
		if exist !AbsExportPath! rmdir /s /q !AbsExportPath!
	)
)

for /r %%f in ("*.ogg") do (
	set "Filepath=%%~dpf"
	set "Filename=%%~nf.mp3"
	set "Filepath=!Filepath:%AbsAssetsPath%=%AbsExportPath%!"

	if not exist !Filepath! mkdir !Filepath!

	if %IsRewrite% (
		if exist !Filepath!!Filename! del /s /q !Filepath!!Filename!
	)

	if not exist "!Filepath!!Filename!" ffmpeg -i "%%f" -acodec libmp3lame "!Filepath!!Filename!"
)

if not "%AssetsPath%" == "" (
	popd
)