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
		return name + " = \n"+self.fixJSON(json.dumps(contents,sort_keys = True,indent = 8,separators = (",",": ")))

	def fixJSON(self,text):
		text = text.replace('\"[\\"','[\"')							# Replace "[/" with just ["
		text = text.replace('\\"]\"','\"]')							# Replace \"]" with just "]

		cmd = '\"([\\w\"\[\]\\\]+)\"\:'
		p = re.compile(cmd)
		text = p.sub("\\1 =",text)


		return text

# TODO: fix up  ["UILaunchImageSize"]: "{414, 736}" (colon present)
# TODO: fix up square bracket lists.

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		31 Dec 14 	First working version.
# 
#  ****************************************************************************************************************