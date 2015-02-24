-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		core.lua 
--		Purpose:	Core code for the System.
--		Author:		Paul Robson
--		Created:	23-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

--*****************************************************************************************************************
---		@class 		Root
--
---		The Root class is the base class on which all others are built, and the default superclass for all new 
--- 	classes (hence all classes are descendents of Root). Its base functionality allows it to create new 
--- 	classes and instances, handle disposal of those instances, set and clear tags and execute a method on 
--- 	an instances. Other methods are attached by ecoration (e.g. timers, update, messages, query functionality)
--*****************************************************************************************************************

local RootClass = {} 																			-- this is the base class for all others.

local classes = {} 																				-- class information (l/c name => class instance)

local tagIndex = {} 																			-- tag index - (l/c name => { count, objects = instance => ?})
tagIndex["__object"] = { count = 0, instances = {} }											-- empty index for __object (all objects tagged with this)

local singletons = {}																			-- singletons (l/c name => reference)

--*****************************************************************************************************************
---		@method		Root.createClass				Create a new class, possibly derived from a superclass. 			
---		@param 		className<string>				Name of new class, alphanumerics with dot seperators.
---		@oparam 	superClassName<string>			Name class is derived from.
---		@return 	<classInstance>					Reference to newly created class.
---		@return 	<superClassInstance>			Reference to superclass, or the Root object if it doesn't have one.
--*****************************************************************************************************************

function RootClass:createClass(className,superClassName)
	assert(className ~= nil and type(className) == "string") 									-- parameter validation.
	if superClassName ~= nil then assert(type(superClassName) == "string") end 
	className = className:lower() 																-- make class Name lower case.
	assert(classes[className] == nil,"Class "..className.." defined twice.")					-- check class not defined twice.
	local newClass = {}																			-- create a new class.
	local superClass = RootClass 																-- this is the root class.
	if superClassName ~= nil then 																-- is a superclass provided.
		superClassName = superClassName:lower() 												-- make it lower case.
		assert(classes[superClassName] ~= nil,"Superclass "..superClassName.." is not defined")	-- check it exists
		superClass = classes[superClassName]													-- use it as a root class.
	end
	setmetatable(newClass,superClass)															-- make it derive from the parent class
	superClass.__index = superClass
	classes[className] = newClass 																-- store it in the class table.
	newClass.__index = newClass 																-- fix up so it can be used as a metatable in new()
	return newClass,superClass
end

--*****************************************************************************************************************
---		@method 	Root.constructor 				Default shallow copy constructor
---		@param  	constructorData 				Constructor data.
--*****************************************************************************************************************

function RootClass:constructor(constructorData)
	assert(constructorData ~= nil and type(constructorData) == "table")							-- check parameter is a table
	for key,data in pairs(constructorData) do 													-- start the shallow copy of data only.
		if type(data) ~= "function" then self[key] = data end 									-- copy everything except functions.
	end
end 

--*****************************************************************************************************************
---		@method 	Root.destructor 				Default destructor, does nothing at all.
--*****************************************************************************************************************

function RootClass:destructor()
end 

--*****************************************************************************************************************
---		@method 	Root.new 						Create a new instance of a given class
---		@param 		className<string>				Name of class to create
---		@oparam 	constructorData<table>			Constructor data (optional)
--*****************************************************************************************************************

function RootClass:new(className,constructorData)
	assert(className ~= nil and type(className) == "string")									-- check class name parameter
	className = className:lower() 																-- lower case class name
	constructorData = constructorData or {} 													-- default constructor data.
	assert(type(constructorData) == "table")													-- constructor data must be a table
	assert(classes[className] ~= nil,"Class "..className.." does not exist.")					-- check class actually exists.

	local newInstance = {} 																		-- create a new instance.
	setmetatable(newInstance,classes[className])												-- give it its inheritance from the class instance.
	newInstance.__isAlive = true 																-- mark it now as alive.

	local ti = tagIndex["__object"]																-- short cut to tag index for objects.
	ti.count = ti.count + 1 																	-- bump the count of the tag index.
	ti.instances[newInstance] = newInstance 													-- store the instance in the index.

	newInstance:constructor(constructorData)													-- call the constructor with the data.

	return newInstance 																			-- return the instance reference of the new object.
end 

--*****************************************************************************************************************
---		@method 	Root.dispose 					Delete a class instance and tidy up.
--*****************************************************************************************************************

function RootClass:dispose()
	assert(self.__isAlive) 																		-- check not already disposed.
	self:destructor() 																			-- call the destructor
	self.__isAlive = false 																		-- mark as no longer alive.
	for tagKey,tagIndex in pairs(tagIndex) do 													-- scan through all known tags, including __object
		if tagIndex.instances[self] ~= nil then 												-- present in that tag index ?
			tagIndex.count = tagIndex.count - 1 												-- adjust the tag index count.
			tagIndex.instances[self] = nil 														-- remove the tag entry.
		end 
	end 	
	for _,ref in pairs(singletons) do 															-- look through the singletons.
		if ref == self then singletons[_] = nil end 											-- found disposed object, then erase the singleton reference
	end
end 

--*****************************************************************************************************************
---		@method 	Root.isAlive 					Check to see if an instance is active, e.g. has not been disposed.
---		@return 	<boolean>						True if it is alive.
--*****************************************************************************************************************

function RootClass:isAlive()
	return self.__isAlive 																		-- return the member that indicates this.
end 

--*****************************************************************************************************************
---		@method 	Root.getClassName 				Get the class name for an instance.
---		@return 	<string> 						Name of class
--*****************************************************************************************************************

function RootClass:getClassName()
	local retVal 
	for name,instance in pairs(classes) do 														-- scan through all classes
		if getmetatable(self) == instance then retVal = name break end 							-- break with result if found
	end 
	assert(retVal ~= nil)																		-- check was found, fail if not.
	return retVal 																				-- return name of class.
end 

--*****************************************************************************************************************
---		@method 	Root.analyseClassUsage 			Dump each class with the number of instances ( > 0 ) to stdout
--*****************************************************************************************************************

function RootClass:analyseClassUsage()
	local classToCount = {}																		-- classes we are counting instances of
	local classList = {}																		-- list of counting classes
	for ref,_ in pairs(tagIndex["__object"].instances) do 										-- scan through objects known
		local name = ref:getClassName(ref) 														-- get the name of the class.
		if classToCount[name] == nil then 														-- previously unknown class ?
			classToCount[name] = 0 																-- clear count
			classList[#classList+1] = name 														-- add name to list
		end 
		classToCount[name] = classToCount[name] + 1 											-- bump count for this class.
	end 
	table.sort(classList) 																		-- instantiated classes in alpha order.
	print("Current usage at "..os.date("%I:%M").." -")											-- header and current time for logging.
	for _,class in ipairs(classList) do 														-- work through them all.
		print(("     %-24s (%d)"):format(class,classToCount[class]))							-- dump class and count to stdout.
	end
	print()																						-- gap to next line.
end

--*****************************************************************************************************************
---		@method 	Root.singleton 					Converts an instance to a singleton, optinally naming it.
---		@oparam 	name<string>					Name to use, if you want it named.
---		@return 	<instance>						Returns self so can be chained on new()
--*****************************************************************************************************************

function RootClass:singleton(name)
	assert(getmetatable(self).constructor ~= self.__singletonFunction)							-- check it hasn't already been made one.
	getmetatable(self).constructor = RootClass.__singletonFunction 								-- override the new() method to cause an error.
	if name ~= nil then 																		-- named singleton ?
		name = name:lower()																		-- make lower case
		assert(singletons[name] == nil,"Duplicate singleton name "..name)						-- check not already defined.
		singletons[name] = self 																-- store it.
	end
	return self 
end

function RootClass:__singletonFunction() 														-- this support method is used as a 'constructor'
	error(self:getClassName().." is a singleton") 												-- once an object has been marked as a singleton.
end

--*****************************************************************************************************************
---		@method 	Root.getNamed 					Access a named singleton
---		@param 		name<string>					Singleton to access
---		@return 	<instance>						Singleton reference, errors if does not exist.
--*****************************************************************************************************************

function RootClass:getNamed(name)
	assert(name ~= nil and type(name) == "string")												-- parameter check.
	name = name:lower()																			-- case insensitive
	assert(singletons[name] ~= nil,"Singleton unknown "..name)									-- check it actually exists
	return singletons[name]																		-- return the reference.
end

--*****************************************************************************************************************
---		@method 	Root.__getAllObjects 			Get a complete list of objects currently existing
---		@return 	<instance,?>					Table of objects where the key is the instance (not an array)
---		@return 	<integer>						Number of objects in that table
--*****************************************************************************************************************

function RootClass:__getAllObjects()
	return tagIndex["__object"].instances,tagIndex["__object"].count 							-- return data from the tag index
end 

--*****************************************************************************************************************
---		@method 	Root.__defineGlobalMethod 		Define a new 'global' method by adding it to the RootClass
---		@param 		name<string>					Name of method - this is uniquely here case sensitive
---		@func 		func<function>					Function to be added - should be a method, e.g. param 1 is 'self'
--*****************************************************************************************************************

function RootClass:__defineGlobalMethod(name,func)
	assert(func ~= nil and type(name) == "string" and type(func) == "function")					-- parameter check.
	assert(RootClass[name] == nil)																-- no duplicate functions.
	RootClass[name] = func 																		-- assign it.
end 

--*****************************************************************************************************************
---		@method 	Root.__setTagState 				Set the state of a tag for an object. This is a base function
---													which shouldn't be used by the user to set/clear tags.
---		@param 		tagName<string>					Name of tag to set
---		@param 		tagState<boolean>				State to set it to
---		@return 	<boolean>						Original state of tag
--*****************************************************************************************************************

function RootClass:__setTagState(tagName,tagState)
	assert(tagState ~= nil and type(tagName) == "string" and type(tagState) == "boolean")		-- basic tests on parameters
	tagName = tagName:lower()																	-- make tag name lower case
	--print(tagName,tagState)
	local xtag = tagIndex[tagName]																-- access the relevant index
	if xtag == nil then 																		-- if tag index does not exist, create it
		xtag = { count = 0,instances = {} }														-- create a new empty index
		tagIndex[tagName] = xtag 																-- save it in the index structure
	end

	local originalState = xtag.instances[self] ~= nil 											-- get current state - set if self is in that index

	if originalState ~= tagState then 															-- has it changed from the original state
		if tagState then 																		-- tag is set, was clear
			xtag.instances[self] = self 														-- put it in the index
			xtag.count = xtag.count + 1 														-- one more tag
		else 																					-- otherwise tag is clear, was set
			xtag.instances[self] = nil 															-- remove it from the index
			xtag.count = xtag.count - 1 														-- one less tag
		end
	end

	return originalState
end

--*****************************************************************************************************************
---		@method 	Root.__getAllTaggedObjects 		Gets all objects with a specific tag
---		@param 		tagName<string>					Tag to look for.
---		@return 	<instance,?>					Table of objects where the key is the instance (not an array)
---		@return 	<integer>						Number of objects in that table
--*****************************************************************************************************************

function RootClass:__getAllTaggedObjects(tagName)
	assert(tagName ~= nil and type(tagName) == "string")										-- basic parameter validation.
	local xtag = tagIndex[tagName:lower()]														-- get the tag index.
	if xtag == nil then 																		-- no such tag is in the index
		return {},0 																			-- so return an empty table and zero objects
	end 
	return xtag.instances,xtag.count 															-- otherwise return instances and count.
end

--*****************************************************************************************************************
---		@method 	Root.__execute 					Executes a method object by name, with optional parameters.
---		@param 		method<string>					Name of method to execute
---		@oparam 	p1<any>							Parameter
---		@oparam 	p2<any>							Parameter
---		@oparam 	p3<any>							Parameter
---		@oparam 	p4<any>							Parameter
---		@return 	<boolean>						True if successfully executed.
--*****************************************************************************************************************

function RootClass:__execute(method,p1,p2,p3,p4)
	assert(method ~= nil and type(method) == "string")											-- check parameter
	assert(self[method] ~= nil,"Object does not implement method "..method.."()")				-- check the method exists
	assert(self:isAlive(),"Object has been disposed")											-- check object disposed.
	local ok,errorMessage = pcall(function()
									self[method](self,p1,p2,p3,p4)								-- call the actual method.
								  end)
	if not ok then 																				-- method call threw an error.
		print("System.Error: method "..method.."() failed because "..errorMessage)				-- so create our own warning, but keep going.
	end 
	return ok
end 

-- ****************************************************************************************************************
-- 								One global "System" is the root class reference when needed
-- ****************************************************************************************************************

_G.System = RootClass

-- ****************************************************************************************************************
--	This code was suggested by Sergey as a defensive debugging aid, it handles the issues with variables being
--	undeclared and so on, originally strict.lua but now moved into the core.
-- ****************************************************************************************************************

if system.getInfo('environment') == 'simulator' then  
    -- Prevent global missuse
    local mt = getmetatable(_G)
    if mt == nil then
      mt = {}
      setmetatable(_G, mt)
    end

    mt.__declared = { Base = true }

    mt.__newindex = function (t, n, v)
      if not mt.__declared[n] then
        local w = debug.getinfo(2, 'S').what
        if w ~= 'main' and w ~= 'C' then
          error('assign to undeclared variable \'' .. n .. '\'', 2)
        end
        mt.__declared[n] = true
      end
      rawset(t, n, v)
    end

    mt.__index = function (t, n)
      if not mt.__declared[n] and debug.getinfo(2, 'S').what ~= 'C' then
        error('variable \'' .. n .. '\' is not declared', 2)
      end
      return rawget(t, n)
    end
end  

-- ****************************************************************************************************************
--									System mandatory components
-- ****************************************************************************************************************

require("system.support.tagquery")																-- tag and query helper methods.
require("system.support.update")																-- update/updateraw module
require("system.support.messages")																-- asynchronous messages
require("system.support.timers")																-- asynchronous timers
require("system.group")																			-- grouping objects
require("system.scene")																			-- group visual object - base class for game state.

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		25-Nov-14	Coding begun on core.lua
--		25-Nov-14 	First working version complete, testing of core begins.
--		31-Dec-14 	Code Read#1. Changed superclass case conversion in createClass(), added test for alive to __execute
-- ****************************************************************************************************************
