-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		group.lua 
--		Purpose:	Object collection class
--		Author:		Paul Robson
--		Created:	27-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

local Group,SuperClass = System:createClass("system.group")

--*****************************************************************************************************************
---		@class 		system.group
--
---		A group object represents a collection of other objects. This group is never explicitly maintained, it is 
--- 	created by giving each group an "illegal" tag group$nnnn so as to identify it as a member of this object,
--- 	using the query system to get all tags. This has the consequence that groups within groups do not work - if
---		you add a group to another group the group itself is returned as part of the group, but the members of the
---		subgroup are not.
--*****************************************************************************************************************

Group.m_nextGroupID = 30000 																	-- next free group ID

--*****************************************************************************************************************
---		@method 	system.group.constructor 					Creates a new empty collection of objects
---		@param 		data<table>									Constructor data (ignored)
--*****************************************************************************************************************

function Group:constructor(data)
	self.m_groupTag = "group$"..Group.m_nextGroupID 											-- create a group tag.
	Group.m_nextGroupID = Group.m_nextGroupID + 1 												-- bump ID
end 

--*****************************************************************************************************************
---		@method 	system.group.new 							Create a new object and insert it in the group
---		@param		className 									Name of class to create
---		@oparam 	data<table>									Constructor data
---		@return 	<instance> 									Reference to new object
--*****************************************************************************************************************

function Group:new(className,data)
	local newObject = SuperClass.new(self,className,data)										-- use superclass method to create the object
	newObject:__setTagState(self.m_groupTag,true)												-- tag it with the group$nnn tag, cannot use "tag" here
	return newObject 																			-- return new object.
end 

--*****************************************************************************************************************
---		@method 	system.group.getMembers 					Get a map with every instance in the group 
---		@return 	<table> 									Dictionary where the instances are keys.
---		@return 	<number>									Number of items in the table.
--*****************************************************************************************************************

function Group:getMembers()
	return self:__getAllTaggedObjects(self.m_groupTag)											-- use core code to retrieve everything tagged
end 

--*****************************************************************************************************************
---		@method 	system.group.destructor 					Dispose of the group and its members
--*****************************************************************************************************************

function Group:destructor()
	local disposeList = self:getMembers() 														-- things we want to get rid of.
	for ref,_ in pairs(disposeList) do 															-- work through
		if ref:isAlive() then ref:dispose() end 												-- delete them if they are still alive
	end 
end

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		27-Nov-14	Coding begun
--		27-Nov-14	Initial Coding complete.
-- 		31-Dec-14 	Code Read#1
-- ****************************************************************************************************************
