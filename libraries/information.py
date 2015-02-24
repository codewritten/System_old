#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		information.py 
# 		Purpose:	Information File Manager
# 		Author:		Paul Robson
# 		Created:	07-Jan-15
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

import re,os
from libraries.formatter import LuaFormatter

#
#	Parses information.txt to create a lua equivalent. Decides which advertising systems are supported.
# 	and creates the 'adverts' structure which simplifies this. A copy is made of the information.text 
# 	structure with this new adverts structure and the old advert entries are then removed from it, this
#	is used to generate information.lua.
#
class InformationLoader:
	def __init__(self):
		self.formatter = LuaFormatter() 													# working formatter

	def loadInfo(self):
		initial = { "application":{}, "configuration":{}, "identity":{}}					# information structure
		self.information = self.load("information.txt",initial)								# load it in.
		self.usesAdverts = self.getBoolean("configuration","adverts")						# adverts used ?
		self.usesBanners = self.getBoolean("configuration","usesBanners") 					# do we use banners and interstitials ?
		self.usesInterstitials = self.getBoolean("configuration","usesInterstitials")

		supportedAdverts = self.getSupportedAdverts() 										# get advertisers list.
		self.information["adverts"] = { "available":supportedAdverts }						# add adverts structure.
		for adType in supportedAdverts.split(","):											# work through adverts supported
			keys = {} 																		# create simpler structure.
			if self.usesBanners:															# copy banners and interstitials.
				keys["iosbanner"] = self.get(adType,"iosBanner")							# if used
				keys["androidbanner"] = self.get(adType,"androidBanner")
			if self.usesInterstitials:
				keys["iosinterstitial"] = self.get(adType,"iosInterstitial")
				keys["androidinterstitial"] = self.get(adType,"androidInterstitial")
			self.information["adverts"][adType] = keys
		return self 

	def load(self,fileName,initial):
		loading = initial																	# information structure
		currentSection = None 																# not writing anywhere yet.
		l = open(fileName).readlines() 														# read in information.
		l = [x[:x.find("#")] if x.find("#") >= 0 else x for x in l] 						# remove comments
		l = [x.replace("\t"," ") for x in l]												# remove tabs
		l = [x.strip() for x in l if x.strip() != ""] 										# remove spaces and blank lines.
		for line in l:																		# work through it.
			if line[0] == '[':																# new section.
				section = line[1:-1].lower()												# get section name
				if section not in loading:													# does it exist ?
					loading[section] = {} 													# if not, create a blank section
				currentSection = loading[section]											# current section being written to
			else:
				s = re.search("^([A-Za-z0-9]+)\\s*\\=\\s*(.*)$",line)						# Match as a = b		
				if s is None: 																# fail if doesn't match.
					raise Exception("Bad line in information.txt : "+line)
				key = s.group(1).lower() 													# key always l/c
				assert key not in currentSection 											# not already defined.
				currentSection[key] = s.group(2).strip()									# store key/value
		return loading

	def generate(self,directory):
		self.infoCopy = {}																	# Copy the information dictionary.
		for k in self.information.keys():
			self.infoCopy[k] = self.information[k]
		for a in self.getAdvertList().split(","):											# delete raw advert data (e.g. admob/vungle bits)
			if a in self.infoCopy: 															# use the adverts structure which is built to 
				del self.infoCopy[a]	 													# suit.
		return self.write(directory+os.sep+"information.lua","ApplicationInformation",self.infoCopy)

	def write(self,tgtFile,globalName,data):
		infoLua = self.formatter.luaFormat(0,globalName,data)								# convert to LUA
		open(tgtFile,"w").write(infoLua)													# and write it out.
		return self

	def getAdvertList(self):																# possible monetisation via adverts.
		return "admob,vungle,crossinstall,inmobi,inneractive"

	def getSupportedAdverts(self):
		if not self.usesAdverts:															# adverts not used.
			return []			
		adPossibles = self.getAdvertList().split(",")										# List of possible advertisers
		adSupported = [] 																	# List that pass
		for ads in adPossibles: 															# scan through.
			if self.isSupported(ads):														# is it supported ?
				adSupported.append(ads) 													# add to list.
		return ",".join(adSupported)

	def isSupported(self,advertiser):
		advertiser = advertiser.lower() 													# add stub is lower case.
		if self.usesBanners:																# if uses Banners
			if self.get(advertiser,"iosBanner") == "" or self.get(advertiser,"androidBanner") == "":
				return False 																# require both banner and interstitial
		if self.usesInterstitials:
			if self.get(advertiser,"iosInterstitial") == "" or self.get(advertiser,"androidInterstitial") == "":
				return False 
		return True 

	def get(self,section,key):
		section = section.lower()															# case independent, all keys l/c
		key = key.lower()
		if section not in self.information:													# check if section and key present.
			return ""
		if key not in self.information[section]:
			return ""
		return self.information[section][key] 												# return result if is.

	def getBoolean(self,section,key):
		return self.get(section,key).lower()[:1] == "y"

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		11 Jan 14 	First working version.
# 
#  ****************************************************************************************************************