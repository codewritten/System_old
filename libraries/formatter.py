#  ****************************************************************************************************************
#  ****************************************************************************************************************
# 
# 		File:		formatter.py 
# 		Purpose:	Python -> Lua format (sort of)
# 		Author:		Paul Robson
# 		Created:	31-Dec-14
# 
#  ****************************************************************************************************************
#  ****************************************************************************************************************

import json,re

#
#	Convert Python Data Structure to LUA format.
#
class LuaFormatter:
	def luaFormat(self,indent,name,contents):
		# Note here the changing of the separator from the default ': ' to '= '
		return name + " = \n"+self.fixJSON(json.dumps(contents,sort_keys = True,indent = 8,separators = (",","= ")))

	def fixJSON(self,text):
		lines = text.split("\n")													# Split around new line.
		lines = [self.process(l.rstrip()) for l in lines]							# Process them
		return "\n".join(lines)														# Rebuild

	def process(self,line):
		spaceSize = len(line)-len(line.lstrip()) 									# Line chars which are spaces/tabs
		return line[:spaceSize]+self.processText(line[spaceSize:])					# process the rest and add back on front.

	def processText(self,text):
		rx = r'^\"(\w+)\"(=.*)$'													# match "(word)"=(something)
		match = re.match(rx,text)													# this removes the quotes round												
		if match is not None:														# keys.
			text = match.group(1)+match.group(2)

		rx = r'^\"\[\\\"(.*)\\\"\]\"(=.*)$'											# these fix the square bracketed
		match = re.match(rx,text)													# keys which are in the launch 
		if match is not None:														# images in build.settings.
			text = '["'+match.group(1)+'"]'+match.group(2)							# remove escaping.

		if text[-1] == "[":															# Fix up square brackets.															
			text = text[:-1] + "{"													# it is prettyprinted so []
		if text[-1] == "]":															# are always on the end of lines
			text = text[:-1] + "}"													# ] may be followed by a comma.
		if len(text) >= 2 and text[-2:] == "],":															
			text = text[:-2] + "},"

		return text

# TODO: Processing as follows.
# "<word>" becomes word 
# "[\"<sometext>\"]" becomes ["<sometext>"] 


#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		31 Dec 14 	First working version.
# 
#  ****************************************************************************************************************

#		text = text.replace('\"[\\"','[\"')							# Replace "[/" with just ["
#		text = text.replace('\\"]\"','\"]')							# Replace \"]" with just "]

#		cmd = '\"([\\w\"\[\]\\\]+)\"\:'
#		p = re.compile(cmd)
#		text = p.sub("\\1 =",text)