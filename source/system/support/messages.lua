-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		messages.lua 
--		Purpose:	Asynchronous messaging object code.
--		Author:		Paul Robson
--		Created:	25-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

--*****************************************************************************************************************
--- @class system.support.messages
--
---	The system.support.messages class is a singleton which handles the queuing and dispatch of messages 
---	between objects. This is done asynchronously (e.g. on onUpdate()). Objects receiving messages should 
--- define an onMessage() method to receive them otherwise an error will occur.
--*****************************************************************************************************************

local MessageManager = System:createClass("system.support.messages")

--*****************************************************************************************************************
---		@method 	systems.support.messages.constructor 		Create a new message manager
---		@param 		data<table>									Constructor data (ignored)
--*****************************************************************************************************************

function MessageManager:constructor(data)
	self.m_messageQueue = {}																	-- queue of message objects (newest on end)
	self:tag("update")																			-- the object updates on the frame tick
	self.m_uniqueID = 10000 																	-- next unique message ID
	self.m_messageFailed = false 																-- true when fails so no repeat errors
end

--*****************************************************************************************************************
---		@method 	systems.support.messages.destructor 		Disposes of a message manager.
--*****************************************************************************************************************

function MessageManager:destructor()
	self.m_messageQueue = nil 																	-- free up reference.
end

--*****************************************************************************************************************
---		@method 	systems.support.messages.onUpdate 			Handle elapsed time, check if messages should go.
---		@param 		deltaTime<number>							Elapsed time in seconds.
--*****************************************************************************************************************

function MessageManager:onUpdate(deltaTime)
	if #self.m_messageQueue == 0 or self.m_messageFailed then return end 						-- no messages / error occurred

	for _,ref in ipairs(self.m_messageQueue) do ref.delay = ref.delay - deltaTime end 			-- reduce all delays by deltatime.

	while #self.m_messageQueue > 0 and self.m_messageQueue[#self.m_messageQueue].delay <= 0 do 	-- while messages to dispatch ?

		local msg = self.m_messageQueue[#self.m_messageQueue]									-- retrieve message
		self.m_messageQueue[#self.m_messageQueue] = nil 										-- remove last array element.

		local recipientList,recipientCount 														-- find out where it is going.
		if type(msg.target) == "table" then 													-- is it being sent to a single object.
			recipientList = {} recipientList[msg.target] = msg.target recipientCount = 1 		-- send it to just one object.
		else 
			recipientList,recipientCount = self:query(msg.target)								-- otherwise send it to a query result.
		end 

		if recipientCount > 0 then 																-- something to send to 
			local msgInfo = { sender = msg.sender } 											-- this is the msg info structure
			for ref,_i in pairs(recipientList) do 												-- work through the mailing list
				if ref:isAlive() then 															-- if alive
					local isOk = ref:__execute("onMessage",msg.name,msg.body,msgInfo) 			-- execute onMessage() method
					if not isOk then 															-- if failed, then no more messages.
						self.m_messageFailed = true 											-- mark as failed
						self.m_messageQueue = {} 												-- empty the message queue, breaks outer loop
						break
					end 						
				end
			end
		end
	end
end 

--*****************************************************************************************************************
---		@method 	Root.sendMessage 						Dispatch messages
---		@oparam 	name<any>								Message identifier (creates a unique default)
--- 	@oparam 	target<instance/string>					Instance to message, or string which is a query (defaults to sender)
---		@oparam 	body<table>								Data you want to send in the message
---		@oparam 	delay<number>							Delay time in seconds.
---		@oparam 	sender<instance>						Object who sent the message.
--*****************************************************************************************************************

function MessageManager:sendMessage(name,target,body,delay,sender)
	if name == nil then 																		-- if no name, give it a unique one.
		name = "msginternal" .. self.m_uniqueID 												-- internally generated.
		self.m_uniqueID = self.m_uniqueID + 1
	end 
	target = target or sender body = body or {} delay = delay or 0 								-- default values.
	assert(type(target) == "string" or type(target) == "table")									-- check the types
	assert(type(body) == "table" and type(delay) == "number")

	local newMessage = { target = target, name = name, body = body, delay = delay, sender = sender }	-- convert it into a structure
	self.m_messageQueue[#self.m_messageQueue+1] = newMessage 									-- add it to the array of pending messages
	table.sort(self.m_messageQueue,function(a,b) return a.delay > b.delay end) 					-- sort it so the first message is the latest.
	return name
end

local managerObject = MessageManager:new("system.support.messages"):singleton("messageManager")	-- create the message manager singleton

System:__defineGlobalMethod("sendMessage",														-- create the support method.
							function(self,name,target,body,delay) 
								managerObject:sendMessage(name,target,body,delay,self)
							end)

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		25-Nov-14	Coding begun
-- 		25-Nov-14 	Coding complete
-- 		31-Dec-14 	Code Read #1
-- ****************************************************************************************************************
