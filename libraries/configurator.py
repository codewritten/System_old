#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		configurator.py 
# 		Purpose:	Config files generation.
# 		Author:		Paul Robson
# 		Created:	31-Dec-14
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

import os
from libraries.reqfiles import RequiredFilesInformation 
from libraries.formatter import LuaFormatter

#
#	Class responsible for generating and interpreting configuration files.
#
#	Note Starter/Basic does not allow inmobi to be used.
#
class ConfigGenerator:
	def __init__(self,orientation):
		self.orientation = orientation.lower()												# save the orientation and check it
		assert self.orientation == "portrait" or self.orientation == "landscape"
		self.reqInfo = RequiredFilesInformation(self.orientation) 							# instance of required files information.
		self.formatter = LuaFormatter() 													# instance of formatting object.

	#
	#	Generate config.lua and build.settings
	#
	def generate(self,directory,advertList):
		self.generateConfigLua(directory)													# create config.lua
		self.generateBuildSettings(directory,advertList)									# create build.settings

	#
	#	Get required android permissions.
	#
	def getPermissionList(self):															# list of allowable android permission names
		return [ "android.permission.INTERNET","android.permission.ACCESS_NETWORK_STATE"] 

	#
	#	Get list of Apple's icons
	#
	def getIconList(self):																	# list of icons that Apple need
		items = self.reqInfo.query(True,True,False)											# query the 'database'
		return [ x["name"] for x in items]													# return a list of items.

	#
	#	Generate config.lua
	#
	def generateConfigLua(self,directory):													# create config.lua
		application = { "content" : { "width" : 640, "height" : 960, "scale" : "letterbox" }}

		configLua = self.formatter.luaFormat(0,"application",application)
		open(directory+os.sep+"config.lua","w").write(configLua)

	#
	#	Generate build.settings
	#
	def generateBuildSettings(self,directory,advertList):									# create build.settings
		settings = { "orientation":{}, "plugins":{}, "excludeFiles":{}, "android":{}, "iPhone":{} }

		if self.orientation == "landscape":													# orientation, default and allowable
			settings["orientation"] = { "default":"landscape", "supported":'{ "landscapeLeft","landscapeRight" }' }
		else:
			settings["orientation"] = { "default":"portrait", "supported":'{ "portrait","portraitUpsideDown" }' }


		settings["plugins"] = self.getAdvertisingPlugins(advertList) 						# get the required plugins.

		settings["excludeFiles"]["all"] = " { 'exclude/*' }"								# we exclude the exclude directory whatever

		settings["android"]["usesPermissions"] = self.getPermissionList()					# set up permissions

		settings["iPhone"] = { "plist": { "CFBundleIconFiles" : self.getIconList() }} 		# and Apple Icons
		settings["iPhone"]["plist"]["UILaunchImages"] = self.getUILaunchImageTable() 		# and the launch images table.

		settings = self.formatter.luaFormat(0,"settings",settings)							# format and write out.
		open(directory+os.sep+"build.settings","w").write(settings)

	#
	#	Return a table of plugins neede for advertisers of various types. Note that the Corona system automatically
	#	sets android permissions to match
	#
	def getAdvertisingPlugins(self,advertList):
		plugins = {}																		# plugins we require for various ad types
		advertList = advertList.lower() 													# don't worry about case.
		if advertList.find("admob") >= 0:													# Admob
			plugins['["plugin.google.play.services"]'] = { "publisherId":"com.coronalabs" }
		if advertList.find("inmobi") >= 0:													# Inmobi
			plugins['["CoronaProvider.ads.inmobi"]'] = { "publisherId":"com.coronalabs" }
		if advertList.find("inneractive") >= 0: 											# Inneractive
			plugins['["CoronaProvider.ads.inneractive"]'] = { "publisherId":"com.inner-active" }
		if advertList.find("vungle") >= 0:													# Vungle (also needs Google Play Services)
			plugins['["CoronaProvider.ads.vungle"]'] = { "publisherId":"com.vungle" }
			plugins['["plugin.google.play.services"]'] = { "publisherId":"com.coronalabs" }
		if advertList.find("crossinstall") >= 0: 											# Inneractive
			plugins['["CoronaProvider.ads.crossinstall"]'] = { "publisherId":"com.crossinstall" }
		return plugins

	#
	#	Really bad code but this makes no coherent sense as far as I can see.
	#
	def getUILaunchImageTable(self):														# from Corona's build.settings guide.
		defList = [("Default",320,480),("Default-568h",320,568),("Default-Portrait",768,1024),("Default-667h",375,667),("Default-736h",414,736)]
		liTable = {}																		# table of launch image descriptors
		n = 100																				# order for !n (100 because sort alphabetically)
		for df in defList:																	# work through defs
			version = "8.0" if df[2] == 667 or df[2] == 736 else "7.0"						# work out versions
			for orient in ["Portrait","LandscapeLeft","LandscapeRight"]:					# for each orientation
				liItem = []																	# create table
				name = df[0]																# work out name
				if orient != "Portrait":													# some change, some don't ...
					if name == "Default-Portrait":
						name = "Default-Landscape"
					if name == "Default-736h":
						name = "Default-Landscape-736h"
				#print(name,orient,df[1],df[2],version)
				liItem.append('["UILaunchImageMinimumOSVersion"] = "'+version+'"')			# add data formatted
				liItem.append('["UILaunchImageName"] = "'+name+'"')
				liItem.append('["UILaunchImageOrientation"] = "'+orient+'"')
				liItem.append('["UILaunchImageSize"] = "{'+str(df[1])+', '+str(df[2])+'}"')
				liTable["!"+str(n)] = liItem												# store in dictionary
				n = n + 1
		return liTable

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		31 Dec 14 	First working version.
# 
#  ****************************************************************************************************************