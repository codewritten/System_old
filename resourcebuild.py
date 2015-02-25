#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		resourcebuild.py 
# 		Purpose:	Converts all external graphics/fonts/text/sounds and copies them into the source directory.
# 		Author:		Paul Robson
# 		Created:	29-12-14
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************
#
#	External library imports
#
from libraries.configurator import ConfigGenerator 
from libraries.information import InformationLoader
from libraries.defaultfiles import DefaultFiles 
from libraries.copier import FileCopier
from libraries.textcopier import TextCopier
import os 
#
#	Convert information.txt to lua equivalent.
#
print("Creating          : information.lua")
info = InformationLoader().loadInfo().generate("source")
print('Adverts supported : "'+info.getSupportedAdverts()+'"')
#
#	Display orientation
#
orientation = info.get("application","orientation").lower()
assert orientation == "portrait" or orientation == "landscape"
print('Orientation is    : "'+orientation+'"')
#
#	Generate build.settings and config.lua
#
print("Creating          : build.settings,config.lua")
cg = ConfigGenerator(orientation).generate("source",info.getSupportedAdverts())
#
#	Create Application Icons and Launch Images.
#
print("Creating          : Creating App Icons and Launch Images")
dic = DefaultFiles("media"+os.sep+"system",orientation)
launchBackground = [int(x) for x in info.get("configuration","launchBackground").split(",")]
dic.create(False,"source",tuple(launchBackground))
dic.create(True,"source",(255,255,255,0))
#
#	Copying text/info files to build area\media converting to lua structure.
#
print("Copying           : Text/Configuration files")
TextCopier("media"+os.sep+"text").copy(["xml"],"source"+os.sep+"media")
#
#	Copying sound effects etc. to build area\media
#
print("Copying           : Sound files.")
FileCopier("media"+os.sep+"sounds").copy(["wav","mp3"],"source"+os.sep+"media")

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		29 Dec 14 	First working version.
# 
#  ****************************************************************************************************************

# TODO: Graphic Import
# TODO: Font Import
