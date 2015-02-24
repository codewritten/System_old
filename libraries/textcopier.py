#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		textcopier.py
# 		Purpose:	Text copier - copies .txt .cfg .inf files converting to a lua structure.
# 		Author:		Paul Robson
# 		Created:	14-Jan-15
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

from libraries.copier import FileCopier 
from libraries.information import InformationLoader

class TextCopier(FileCopier):
	def copyFile(self,srcFile,tgtFile):
		tgtFile = tgtFile[:-4]+".lua"														# it's a lua file that is created.
		inf = InformationLoader()															# processing object
		data = inf.load(srcFile,{ "sourceFile":srcFile })									# load in the text
		inf.write(tgtFile,"return",data)													# write it out as a requireable file in media.

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		14 Jan 15 	First working version.
# 
#  ****************************************************************************************************************