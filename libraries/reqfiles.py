#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		reqfiles.py 
# 		Purpose:	Database of required icon/image files for builds.
# 		Author:		Paul Robson
# 		Created:	31-Dec-14
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

#
#	Class responsible for returning information on launch images/icons for iOS and Android.
#
class RequiredFilesInformation:
	def __init__(self,orientation):
		self.reqList = {}
		self.orientation = orientation.lower()
		self.launchCount = 0
		self.addIcon("Icon-xxxhdpi.png",192,False,True)										# Android Icons.
		self.addIcon("Icon-xxhdpi.png",144,False,True)
		self.addIcon("Icon-xhdpi.png",96,False,True)
		self.addIcon("Icon-hdpi.png",72,False,True)
		self.addIcon("Icon-mdpi.png",48,False,True)
		self.addIcon("Icon-ldpi.png",36,False,True)
																							# List of suffix,sizes,base size
		defList = [("",2,57),("-60",3,60),("-72",2,72),("-76",2,76),("-Small-40",3,40),("-Small-50",2,50),("-Small",3,29)]
		for d in defList:																	# for each definition
			for size in range(1,d[1]+1):													# for each size
				iconFile = "Icon"+d[0]														# create file
				if size > 1:
					iconFile = iconFile + "@" + str(size)+"x"
				self.addIcon(iconFile+".png",d[2] * size,True,False)						# add definition.

		self.addLaunchImage("Default.png",320,480,True)										# Android and iOS launch images.								
		self.addLaunchImage("Default-Portrait.png",768,1024,True)										
		self.addLaunchImage("Default-Landscape.png",1024,768,True)										
		self.addLaunchImage("Default@2x.png",320*2,480*2,True)										
		self.addLaunchImage("Default-Portrait@2x.png",768*2,1024*2,True)										
		self.addLaunchImage("Default-Landscape@2x.png",1024*2,768*2,True)										

		self.addLaunchImage("Default-568h@2x.png",640,1136,False)							# iOS Specific Launch images.
		self.addLaunchImage("Default-667h@2x.png",750,1334,False)
		self.addLaunchImage("Default-736h@2x.png",1242,2208,False)
		self.addLaunchImage("Default-Landscape-568h@2x.png",1136,640,False)
		self.addLaunchImage("Default-Landscape-667h@2x.png",1334,750,False)
		self.addLaunchImage("Default-Landscape-736h@2x.png",2208,1242,False)

		assert(self.launchCount > 0)														# check there is at least one launch image

	def addGraphic(self,fileName,width,height,isIOS,isAndroid):
		newEntry = { "name":fileName,"size":(width,height),"apple":isIOS,"android":isAndroid,"icon":(width == height),"version":"7.0" }
		if fileName[:7] == "Default":														# is it default with 667h or 736h in it
			if fileName.find("667h") >= 0 or fileName.find("736h") >= 0:					# then if so it is version 8.0
				newEntry["version"] = "8.0"
		assert(fileName not in self.reqList)												# check not already present
		self.reqList[fileName] = newEntry 													# add it to the database.

	def addIcon(self,fileName,size,isIOS,isAndroid):
		self.addGraphic(fileName,size,size,isIOS,isAndroid)

	def addLaunchImage(self,fileName,width,height,isAndroid):
		appLandscape = self.orientation == "landscape"										# app is landscape
		liLandscape = width > height														# image is landscape
		isAdded = appLandscape == liLandscape												# do we want it ?
		if fileName == "Default-568h@2x.png":												# required by iOS activates iPhone 5 tall mode
			isAdded = True 																	# http://docs.coronalabs.com/guide/distribution/buildSettings/index.html
		if isAdded:																			# if we want it (e.g. fits app orientation)
			self.addGraphic(fileName,width,height,True,isAndroid)
			self.launchCount = self.launchCount + 1

	def query(self,isIcon,isApple,isAndroid):
		result = []
		for k,v in self.reqList.items():
			isOkay = isIcon == v["icon"] 
			if ((isApple and v["apple"]) or (isAndroid and v["android"])) and isOkay:
				result.append(v)
		result.sort(key=lambda k: k['name'])
		return result

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		31 Dec 14 	First working version.
# 
#  ****************************************************************************************************************