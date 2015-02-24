#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		copier.py
# 		Purpose:	File direct copier
# 		Author:		Paul Robson
# 		Created:	14-Jan-15
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

import os,shutil

class FileCopier:
	def __init__(self,source):
		self.source = source														# save where its coming from.

	def copy(self,types,target):
		self.typeList = "."+(".".join(types))+"."									# list of . seperated supported types.
		for root,dirs,files in os.walk(self.source):								# look through the directory.
			for f in files:															# scan through files
				fullName = root + os.sep + f 										# full name of file
				if self.typeList.find("."+fullName[-3:].lower()+".") >= 0:			# does it pass the target test.
					if fullName.lower() != fullName:								# check the case is correct. 
						print('        Warning : filename "'+fullName+'" is not all lower case.')
					self.copyFile(fullName,target+os.sep+f.lower())					# copy the file

	def copyFile(self,srcFile,tgtFile):
		shutil.copyfile(srcFile,tgtFile)											# this is just a simple copy.

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		14 Jan 15 	First working version.
# 
#  ****************************************************************************************************************