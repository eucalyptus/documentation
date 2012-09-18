@echo off
setlocal

set binDir=%~dp0
set libDir=%binDir%\..\lib

set cp=%libDir%\ditac.jar;%libDir%\whcmin.jar;%libDir%\resolver.jar;%libDir%\saxon9.jar

rem --------------------------------------------------------------------------
rem Do not increase the maximum amount of memory here when XEP, FOP or XFC 
rem report out of memory errors. Please do this in XEP, FOP or XFC
rem own .bat files.
rem --------------------------------------------------------------------------

java -Xss2m -Xmx256m -DDITAC_PLUGIN_DIR="%DITAC_PLUGIN_DIR%" -classpath "%cp%" com.xmlmind.ditac.convert.Converter %*
