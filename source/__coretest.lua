-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		__coretest.lua 
--		Purpose:	Testing of core and tagging functionality
--		Author:		Paul Robson
--		Created:	25-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

math.randomseed(42) 																			-- so does the same test each time if problems !

local classCount = 10																			-- number of classes
local instanceCount = 100																		-- references to max number objects
local tagCount = 50 																			-- number of possible tags.
local queryMaxSize = 5 																			-- max size of any query.
local execCount = 1000 																			-- number of times to run the testing loop.
local tagsPerLoop = 10 																			-- number of tags to add remove per loop.
local queriesPerLoop = 6 																		-- number of queries to check per loop.

local currentCount = 0 																			-- current number created.
local classNames = {}																			-- class names.
local tagNames = {} 																			-- tag names.
local instances = {} 																			-- instances, if object created
local tagged = {}  																				-- array for each instance of tag numbers.

local alreadyExisting,alreadyExistingCount = System:__getAllObjects()							-- objects that already exist (part of system)
for i = 1,classCount do  																		-- create class names and classes
	classNames[i] = "class"..i 
	System:createClass(classNames[i])
end

for i = 1,tagCount do tagNames[i] = "tag"..i end 												-- create tag names.

for outer = 1,execCount do 																		-- number of times to run the testing loop.
	if outer % 1000 == 0 then print("Loop "..outer) end 

	-- ******************** Create/Delete an instance ******************

	local inst = math.random(1,instanceCount) 													-- firstly either create or delete an instance.

	if instances[inst] == nil then 																-- creating a new instance.
		instances[inst] = System:new(classNames[math.random(1,classCount)]) 					-- so create it
		tagged[inst] = {} 																		-- create array of all untagged (as new object)
		for j = 1,tagCount do tagged[inst][j] = false end 										-- set all tag-flags to false.
		currentCount = currentCount + 1 														-- increment count
	else 																						-- deleting a current instance
		instances[inst]:dispose()																-- dispose of it
		instances[inst] = nil tagged[inst] = nil 												-- remove references and tags.
		currentCount = currentCount - 1 														-- decrement count
	end 

	-- ******************** Add/Remove tags instance ******************

	if currentCount > instanceCount / 10 then 													-- if at least 10% of the objects instantiated
		for inner = 1,tagsPerLoop do															-- add/remove that many tags.
			local inst
			repeat inst = math.random(1,instanceCount) until instances[inst] ~= nil 			-- find an existing instance.
			local tag = math.random(1,tagCount)													-- pick a tag to add or remove.
			local newState = math.random(1,2) == 1 												-- randomly choose a new state
			local oldState = instances[inst]:__setTagState(tagNames[tag],newState)				-- set the flag
			assert(oldState == tagged[inst][tag])												-- check that state was correct.
			tagged[inst][tag] = newState 														-- set flag in our list.
		end
	end

	-- ******************* Check object instances correct ****************

	local list,count = System:__getAllObjects() 												-- get list of all objects.
	assert(count == currentCount+alreadyExistingCount)											-- the numbers should be the same allowing for already existing ones.
	for i = 1,instanceCount do 																	-- check each object we think is done is in the main list.
		if instances[i] ~= nil then 
			assert(list[instances[i]] ~= nil or alreadyExisting[instances[i]] ~= nil) end 			
	end

	-- ******************* Check tags match up ***********************

	for i = 1,tagCount do 																		-- for each tag
		local list,count = System:__getAllTaggedObjects(tagNames[i])							-- get list of objects with that tag.
		local tagTotal = 0 																		-- total instances we find with that tag
		for j = 1,instanceCount do 																-- work through all instances.
			if instances[j] ~= nil and tagged[j][i] then 										-- is it tagged with that tag ?
				tagTotal = tagTotal + 1 														-- increment the total.
				assert(list[instances[j]] ~= nil)												-- check it is in the corresponding index 
			end 
		end
		assert(tagTotal == count)																-- check total found and total in index match up.
	end

		-- ******************* Check queries work ***********************

	for outer = 1,queriesPerLoop do 												
		local query = {} 																		-- contains one integer for each query item			
		local qSize = math.random(1,queryMaxSize) 												-- number of query entries
		local textQuery = ""
		for i = 1,qSize do 																		-- build the number query and its text equivalent
			query[i] = math.random(1,tagCount) 
			if textQuery ~= "" then textQuery = textQuery .. "," end 	
			textQuery = textQuery .. tagNames[query[i]]
		end 
		local sQuery,sCount = System:query(textQuery)											-- do the actual query test via the system.
		local tCount = 0 																		-- number of queries found by the testing code.
		for i = 1,instanceCount do 																-- work through all objects
			if instances[i] ~= nil then 														-- if there is an object.
				local matches = true 															-- check it has all the tags in the query.
				for j = 1,qSize do 
					if not tagged[i][query[j]] then matches = false break end 					-- if it doesn't have that tag, give up.
				end 
				if matches then 																-- have we found something that should match the query ?
					tCount = tCount + 1 														-- bump the success count
					assert(sQuery[instances[i]] ~= nil)											-- check that the instance is in the query result.
				end 
			end
		end
		assert(tCount == sCount)																-- check we have found all of them.
	end
end

print("Completed.")

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		25 Nov 14 	Started testing app.
--		31 Dec 14 	Adjusted to allow for objects that already exist.
-- ****************************************************************************************************************

-- This file should not be included in the system.zip archive. 
