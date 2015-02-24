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

#
#	Convert Python Data Structure to LUA format.
#
class LuaFormatter:
	def luaFormat(self,indent,name,contents):
		return self.luaSubFormat(indent,name,contents,True)									# starts the recursive formatter

	def luaSubFormat(self,indent,name,contents,isFinal):
		indenting = ' ' * indent 															# indent spaces
		s = ""
		if isinstance(contents,dict):														# handle dictionary
			hashKeys = list(contents.keys())												# get keys
			hashKeys.sort()																	# sort alphabetically
			s = indenting + name
			if name != "return":															# if not return then add '='
				s = s + " = "
			s = s + "\n" + indenting + "{\n"												# indenting.
			for n in range(0,len(hashKeys)):												# work through keys
				name = hashKeys[n]															# call recursive formatter.
				s = s + self.luaSubFormat(indent + 4,name,contents[name],(n == len(hashKeys)-1))
			s = s + indenting + "}"

		elif isinstance(contents,list):														# list of strings (e.g. iphone icon list)
			if name[0] != '!':																# if ! don't print name.
				s = indenting + name + " = \n"
			s = s + indenting + "{\n"														# create it, formatted appropriately
			contents2 = [str(x) if x[0] == '[' else '"'+str(x)+'"' for x in contents]
			s = s + (",\n".join(indenting+'    '+x for x in contents2))
			s = s+"\n"+indenting + "}"
		else:																				# single items
			fmt = '"'+contents+'"' if isinstance(contents,str) else str(contents)
			if str(contents).strip()[:1] == "{":											# hack to make exclude work.
				fmt = contents.strip()
			s = indenting + name + " = " + fmt

		if not isFinal:																		# add terminating comma if not last element
			s = s + ","
		return s+"\n"

#  ****************************************************************************************************************
# 		Date		Changes Made
#		----		------------
#		31 Dec 14 	First working version.
# 
#  ****************************************************************************************************************