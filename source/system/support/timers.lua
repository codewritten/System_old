-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		timers.lua 
--		Purpose:	Local timers code.
--		Author:		Paul Robson
--		Created:	25-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

-- ****************************************************************************************************************
---	@class system.support.timers
--
---	The class system.support.timers provides asynchronous timer events for an object. Objects can only create 
---	timer events for themselves, not for other object. Events can be one-shot, multi-shot or infinite and are
--- cancellable. Don't use this for fast events - for that use onUpdate() to pick up the frame event.
-- ****************************************************************************************************************

local TimerManager = System:createClass("system.support.timers")

--*****************************************************************************************************************
---		@method 	systems.support.timers.constructor 			Create a new timer manager
---		@param 		data<table>									Constructor data (ignored)
--*****************************************************************************************************************

function TimerManager:constructor(data)
	self.m_timerQueue = {}																		-- queue of timer objects, backwards - next to fire at end
	self:tag("update")																			-- the object updates on the frame tick
	self.m_timerFailed = false 																	-- true when fails, stops repeating errors
	self.m_uniqueID = 20000 																	-- next unique timer ID
end

--*****************************************************************************************************************
---		@method 	systems.support.timers.destructor 			Disposes of a timer manager.
--*****************************************************************************************************************

function TimerManager:destructor()
	self.m_timerQueue = nil 																	-- free up reference.
end

--*****************************************************************************************************************
---		@method 	systems.support.timers.onUpdate 			Handles update event
---		@param 		deltaTime<number>							Elapsed time
--*****************************************************************************************************************

function TimerManager:onUpdate(deltaTime)
	if #self.m_timerQueue == 0 or self.m_timerFailed then return end 							-- stop if empty queue or timer failed.

	for _,ref in ipairs(self.m_timerQueue) do ref.delay = ref.delay - deltaTime end 			-- reduce all timers by deltaTime.

	while #self.m_timerQueue > 0 and (not self.m_timerFailed) and 								-- while there are timers due and no fail.
												self.m_timerQueue[#self.m_timerQueue].delay < 0 do

		local current = self.m_timerQueue[#self.m_timerQueue]									-- timer event that is due to be fired.

		if not current.target:isAlive() then 													-- has its target object died ?
			self.m_timerQueue[#self.m_timerQueue] = nil 										-- remove it from the list.
			break 																				-- jump out of the loop.
		end

		current.delay = current.initialDelay 													-- reset the delay value.
		if current.repeatCount > 0 then 														-- is there a +ve repeat count ?
			current.repeatCount = current.repeatCount - 1  										-- decrement the repeat count.
			if current.repeatCount == 0 then self.m_timerQueue[#self.m_timerQueue] = nil end 	-- if zero, delete this timer event.
		end 																					-- as this is the last time it fires.
																								-- if -ve repeat count goes for ever.

		self:sortTimerQueue()																	-- resort timer queue so next event is last in queue.
		local isOk = current.target:__execute("onTimer",current.timerID)						-- fire the onTimer() event.
		if not isOk then self.m_timerFailed = true end 											-- handle failed timer execution.
	end
end

--*****************************************************************************************************************
---		@method 	systems.support.timers.createTimer 			Add a new timer event.
---		@param 		target<instance> 							Object to send timer event to.
---		@param 		delay<number>								Delay between timer events.
---		@param 		repeatCount<number>							Number of times to fire (0 = for ever)
---		@return 	<any>										timerID.
--*****************************************************************************************************************

function TimerManager:createTimer(target,delay,repeatCount)
	local timerID = self.m_uniqueID 															-- create a new timerID
	self.m_uniqueID = self.m_uniqueID + 1		
	assert(type(delay) == "number" and type(repeatCount) == "number" and 						-- check parameter types
															type(target) == "table")							
	local newTimer = { target = target, delay = delay, timerID = timerID,						-- create a new timer information object.
										initialDelay = delay, repeatCount = repeatCount }
	self.m_timerQueue[#self.m_timerQueue+1] = newTimer 											-- add the new timer object.										
	self:sortTimerQueue() 																		-- put queue in order.
	return timerID
end 

--*****************************************************************************************************************
---		@method 	systems.support.timers.sortTimerQueue 		Sort the timer queue so the next timer to be fired is at the end
--*****************************************************************************************************************

function TimerManager:sortTimerQueue()
	table.sort(self.m_timerQueue,function(a,b) return a.delay > b.delay end)					-- sort queue so earliest fired timer is *last*
end 

--*****************************************************************************************************************
---		@method 	systems.support.timers.cancelTimer			Cancel all timers with the given ID
---		@param 		timerID<any>								Timer ID to cancel.
--*****************************************************************************************************************

function TimerManager:cancelTimer(timerID)
	local oldQueue = self.m_timerQueue 															-- copy of old timer queue.
	self.m_timerQueue = {} 																		-- new timer queue
	for _,ref in ipairs(oldQueue) do 															-- work through the old queue
		if ref.timerID ~= timerID then 															-- if it does not contain the given timer ID
			self.m_timerQueue[#self.m_timerQueue+1] = ref 										-- add to the timer queue
		end
	end
	self:sortTimerQueue() 																		-- put queue in order.
end 

local managerObject = TimerManager:new("system.support.timers"):singleton("timerManager")		-- create the message manager singleton

System:__defineGlobalMethod("multipleTimer",
								function (self,delay, repeatCount)
									return managerObject:createTimer(self,delay,repeatCount)
								end)

System:__defineGlobalMethod("singleTimer",
								function (self,delay)
									return managerObject:createTimer(self,delay,1)
								end)

System:__defineGlobalMethod("repeatingTimer",
								function (self,delay)
									return managerObject:createTimer(self,delay,0)
								end)

System:__defineGlobalMethod("cancelTimer",
								function(self,timerID)
									managerObject:cancelTimer(timerID)
								end)

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		25-Nov-14	Coding begun
--		25-Nov-14	Initial Coding complete.
-- 		31-Dec-14 	Code Read#1
-- ****************************************************************************************************************
