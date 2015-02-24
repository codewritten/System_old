#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		removedefaults.py 
# 		Purpose:	Removes all icon files and default files from the source directory.
# 		Author:		Paul Robson
# 		Created:	13-Jan-15
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

#
#	This utility can be useful between builds as it reduces the clutter in the home directory. To get the icons/defaults
#	back just run resourcebuild.py to rebuild all the resources.
#

from libraries.reqfiles import RequiredFilesInformation
import os

def removeFiles(queryObject,isIcon,directory):
	qry = queryObject.query(isIcon,True,True)												# get all objects for Apple and Android.
	for q in qry:																			# scan through them.
		fileToDelete = directory + os.sep + q["name"]										# remove them.
		if os.path.isfile(fileToDelete):
			os.remove(fileToDelete)

print("Removing default screens and icon files.")
rf1 = RequiredFilesInformation("portrait")													# get both orientation requirements.
rf2 = RequiredFilesInformation("landscape")
removeFiles(rf1,True,"source")																# delete icons and default for both.
removeFiles(rf1,False,"source")
removeFiles(rf2,True,"source")
removeFiles(rf2,False,"source")

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		13 Jan 15 	First working version.
# 
#  ****************************************************************************************************************