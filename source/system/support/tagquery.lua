-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		tagquery.lua 
--		Purpose:	Tag and Query support methods for the System.
--		Author:		Paul Robson
--		Created:	25-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

-- ****************************************************************************************************************
--	This does not define a class, but adds functionality to the root object both to tag objects more simply
-- 	(e.g. using a +fred/-jim format rather than calling __setTagState) and to query the objects both for 
-- 	single or multiple tags (AND queries)
-- ****************************************************************************************************************

--*****************************************************************************************************************
---	This local function splits up strings - see "tags and queries" document for details, but it basically rips out
---	the first word before a comma.
--*****************************************************************************************************************

local function __extract(str)
	if str ~= nil then assert(type(str) == "string") end 										-- check parameter type if any
	if str == nil or str:match("^%s*$")  ~= nil then return nil,nil end 						-- handle spaces, empty string, nil.
	local s1,s2 = str:match("^%s*([%w%+%-]+)%s*$")												-- check for a single word.
	if s1 ~= nil then return nil,s1:lower() end 												-- if found, return that word and end of string
	s1,s2 = str:match("^%s*([%w%+%-]+)%s*,%s*(.*)$")											-- look for word, remainder.
	assert(s2 ~= nil and s2:match("^%s*$") == nil)												-- check matched, and there is something following.
	return s2,s1:lower()
end 

--*****************************************************************************************************************
---		@method 	Root.tag 						Tagging/Detagging with text instructions. Input is comma seperated
--													tags list prefixed by +/- (default is + if none provided)
---		@param 		tags<string>					Tags to add/remove in a comma seperated string.
---		@return 	<instance>						Self as is chainable.
--*****************************************************************************************************************

local tagFunc = function(self,tags)
	assert(type(tags) == "string")																-- parameter check
	local word
	while tags ~= nil do 																		-- while more to do
		tags,word = __extract(tags) 															-- get the next word
		if word ~= nil then 																	-- found something ?
			if word:match("^%w+$") ~= nil then 													-- is it just a single tag, no prefix ?
				self:__setTagState(word,true)													-- set the tag
			else 
				assert(word:match("^[%+%-]%w+") ~= nil,"Bad tag format "..word)					-- otherwise check it is +/- word.
				self:__setTagState(word:sub(2),word:sub(1,1) == "+")							-- set or clear tag depending on whether +/-
			end
		end
	end 
	return self
end

System:__defineGlobalMethod("tag",tagFunc)														-- add method to the root object

--*****************************************************************************************************************
---		@method 	Root.query						Comma seperated query, list of instances tagged with all provided.
--													If the list is empty, returns *all* instances.
---		@param 		tags<string>					Tags to use in query
---		@return 	<instance,?>					Table of objects which match that query (e.g. contain all listed keys)
---		@return 	<integer>						Number of objects in that table
--*****************************************************************************************************************

local qryFunc = function(self,tags)
	tags = tags or "" 																			-- default tags is empty string.
	assert(type(tags) == "string")																-- parameter check
	local tag 
	tags,tag = __extract(tags) 																	-- get the first query item.

	if tags == nil then 																		-- if there are no more tags (e.g. 0 or 1)
		if tag == nil then 
			return self:__getAllObjects() 														-- if no tag at all, return everything.
		else 
			return self:__getAllTaggedObjects(tag)												-- if one tag, return everything with that tag.
		end 
	end 

	local queryList = { tag } 																	-- more than one query. First build a list of the tag
	while tags ~= nil do 																		-- names in querylist.
		tags,tag = __extract(tags) 																-- get the next one, add it in
		if tag ~= nil then queryList[#queryList+1] = tag end
	end

	for i = 1,#queryList do 																	-- now convert each tag to a structure containing
		local inst,count = self:__getAllTaggedObjects(queryList[i])								-- count, tag and instance.
		queryList[i] = { tag = queryList[i], count = count, instances = inst }
		if count == 0 then return {},0 end 														-- short cut - if zero entries then cannot be a match at all.
	end

	table.sort(queryList,function(a,b) return a.count < b.count end) 							-- sort so the smallest instance count is first, optimising
																								-- the rather inefficient search being used here.

	local result = {} 																			-- stores the final result in here.
	local resultCount = 0

	for ref,data in pairs(queryList[1].instances) do 											-- for each instance in the tag with lowest # instances
		local isInAll = true 																	-- check it is in every other tag list.
		for search = 2,#queryList do 
			if queryList[search].instances[ref] == nil then 									-- if it is not found
				isInAll = false 																-- then no match
				break 																			-- don't check any more.
			end 
		end 
		if isInAll then 																		-- is it in all queries ?
			result[ref] = data 																	-- copy it into the result buffer
			resultCount = resultCount + 1 														-- and bump the count of successful matches
		end
	end

	return result,resultCount
end

System:__defineGlobalMethod("query",qryFunc)													-- add it to the root.

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		25-Nov-14	Coding begun on tagquery.lua
-- 		26-Nov-14 	Outline code completed.
-- 		31-Dec-14 	Code Read#1
-- ****************************************************************************************************************
