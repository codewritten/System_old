@echo off
rem ****************************************************************************************************************
rem
rem 	Builds the system.zip file which can be used to update any application with the latest versions
rem 	of scripts and similar. 
rem
rem 	It is advisable to check the final zip file produced by this batch file to check nothing 
rem 	is in it that would zap any application files.
rem 
rem ****************************************************************************************************************

rem Remove the old zip file and add the documentation, source and libraries to it.

del system.zip

zip -rq system.zip source documentation libraries version.txt removedefaults.py

rem Remove main.lua which changes.txt, information.lua build.settings and config.lua which are generated

zip -dq system.zip source/main.lua source/information.lua source/build.settings source/config.lua

rem Remove any stuff here for testing the System but which we don't want generally.

zip -dq system.zip source/__*.*

rem This adds the graphics/sounds/text/fonts/systems directories but not their contents

zip -q system.zip media/graphics media/sounds media/text media/fonts media/system

rem This adds the temp directory used for building resources

zip -q system.zip temp

rem This adds the universal directory *and* its contents.

zip -qr system.zip media/universal 

rem  Remove compiled python files.

zip -dq system.zip *.pyc

echo system.zip built successfully.