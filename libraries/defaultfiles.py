#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		defaultfiles.py 
# 		Purpose:	Generate default files (icons + default display screens) .
# 		Author:		Paul Robson
# 		Created:	13-Jan-15
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

import os,re
from PIL import Image
from libraries.reqfiles import RequiredFilesInformation 

#
#	Class responsible for scaling/generation of launch images and application icons.
#
class DefaultFiles:
	def __init__(self,sourceDirectory,orientation):
		self.orientation = orientation.lower()												# save the orientation and check it
		assert self.orientation == "portrait" or self.orientation == "landscape"
		self.reqInfo = RequiredFilesInformation(self.orientation) 							# instance of required files information.
		self.sourceFiles = {} 																# file name => image.
		for root,dirs,files in os.walk(sourceDirectory):									# examine the source files for launch/icon
			for f in files:
				fl = f.lower()
				if fl[:4] == "icon" or fl[:7] == "default" or fl[:6] == "launch":			# is it icon/default/launch.
					if fl[-4:] == ".png":													# and it is a .png file 
						assert f not in self.sourceFiles									# check for no duplicates.
						self.sourceFiles[f] = Image.open(root+os.sep+f)						# read the image into memory.

	#
	#	Create all of type icon or default
	#
	def create(self,isIcon,targetDirectory,backgroundColour):
		fileList = self.reqInfo.query(isIcon,True,True)										# get all required files of that type.
		for f in fileList:																	# Generate the files for them.
			self.render(targetDirectory+os.sep+f["name"],f["size"],isIcon,backgroundColour)

	#
	#	Create a single one. Look for the nearest size to the required size, fill with background and scale to size.
	#
	def render(self,targetFile,requiredSize,isIcon,backgroundColour):						# Generate a single file.
		#print(targetFile,requiredSize,isIcon,backgroundColour)
		squareSz = min(requiredSize[0],requiredSize[1])										# this is the size we want the icon/launch to be square
		nearest = None 																		# best pick
		nearestScore = 9999999 																# nearest score.

		for k in self.sourceFiles.keys():													# work through the keys
			isKeyIcon = k.lower()[0] == "i"													# is this key an icon ?
			if isKeyIcon == isIcon:															# is this the correct type (e.g. icon or default)
				score = abs(self.sourceFiles[k].size[0]-squareSz)							# this is the "score" for this image.
				if score < nearestScore:												
					nearestScore = score 
					nearest = k
		assert nearest is not None															# check we had at least one we could scale.

		image = Image.new("RGBA",requiredSize,backgroundColour)								# create an image of the required size
																							# filled with background colour.

		resImg =self.sourceFiles[nearest].resize((squareSz,squareSz),resample=Image.BICUBIC)# resize the source image to the correct size.
		xOffset = int((requiredSize[0]-squareSz)/2) 										# work out offset in image
		yOffset = int((requiredSize[1]-squareSz)/2)
		image.paste(resImg,box = (xOffset,yOffset,xOffset+squareSz,yOffset+squareSz))		# Draw at appropriate position in image
		del resImg 																			# free up scaled image
		image.save(targetFile)																# save it out.
		del image 																			# free up memory space used by created image.

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		13 Jan 15 	First working version.
# 
#  ****************************************************************************************************************