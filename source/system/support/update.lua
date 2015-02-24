-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		update.lua 
--		Purpose:	Frame based update code.
--		Author:		Paul Robson
--		Created:	25-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

--*****************************************************************************************************************
---	@class 	system.support.update 	This is a singleton class responsible for update/updateraw, which dispatch 
---									update messages to appropriately tagged objects. There are two modes, 
---									normal update and raw update which dispatch messages to objects tagged with
---									update and updateraw respectively. This allows the system to freeze object 
---									activity if necessary, say for example during pauses and transitions.
--*****************************************************************************************************************

local UpdateManager = System:createClass("system.support.update")

--*****************************************************************************************************************
---		@method 	system.support.update.constructor 		Constructor for update module
---		@param 		data<table>								Unused constructor data
--*****************************************************************************************************************

function UpdateManager:constructor(data)
	Runtime:addEventListener("enterFrame",self)													-- add event listener for frame
	self:__setRawTimerUpdateOnly(false)															-- set all updates.
	self.m_lastTime = 0 																		-- time last called (in milliseconds)
	self.m_errorOccurred = false 																-- set to true when an update call fails.
end

--*****************************************************************************************************************
---		@method 	system.support.update.destructor 		Destructor for update module
--*****************************************************************************************************************

function UpdateManager:destructor()
	Runtime:removeEventListener("enterFrame",self)
end 

--*****************************************************************************************************************
---		@method 	system.support.update.enterFrame		Called when Corona dispatches an enterFrame message
--*****************************************************************************************************************

function UpdateManager:enterFrame()
	if self.m_errorOccurred then return end 													-- stops repeating errors.
	local currentTime = system.getTimer() 														-- get current time, in milliseconds
	local deltaTime = math.min(currentTime - self.m_lastTime,100)/1000 							-- delta time in SECONDS.
	self.m_lastTime = currentTime 																-- set last time update fired.
	local instances,count 
	if self.m_rawOnly then 																		-- if raw only, get updateraw list
		instances,count = self:__getAllTaggedObjects("updateraw")
	else 																						-- otherwise, get update list.
		instances,count = self:__getAllTaggedObjects("update")
	end 
	if count == 0 then return end 																-- nothing to update 
	for ref,_ in pairs(instances) do 															-- work through all the instances
		if ref:isAlive() and not ref:__execute("onUpdate",deltaTime) then 						-- did it fail to work ?
			self.m_errorOccurred = true 														-- block more updates
			break 																				-- abort the loop
		end 
	end
end 


--*****************************************************************************************************************
---		@method 	Root.__setRawTimerUpdateOnly	Set the raw text update only flag
---		@param 		isOn<boolean>
--*****************************************************************************************************************

function UpdateManager:__setRawTimerUpdateOnly(isOn)
	assert(isOn ~= nil and type(isOn) == "boolean")												-- check type of parameter
	local oldValue = (self.m_rawOnly == true)													-- preserve old value
	self.m_rawOnly = isOn 																		-- update new value
	return oldValue 
end 

local managerObject = UpdateManager:new("system.support.update"):singleton("updateManager")		-- create update singleton.

System:__defineGlobalMethod("__setRawTimerUpdateOnly",											-- create the support method.
							function(self,isOn) 
								managerObject:__setRawTimerUpdateOnly(isOn)
							end)

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		25-Nov-14	Coding begun
--		25-Nov-14 	Coding ended
--		31-Dec-14 	Code Read #1. Added isAlive() test to update loop as assumption was wrong - onUpdate() could 
-- 								  delete objects consequentially.
-- ****************************************************************************************************************
