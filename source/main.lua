-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		main.lua 
--		Purpose:	Main application (for testing system objects)
--		Author:		Paul Robson
--		Created:	23-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

local ads = require "ads"
require("information")
print(ApplicationInformation.adverts.admob)
local function adListener( event )
  -- event table includes:
  --    event.provider
  --    event.isError (e.g. true/false )
  --    event.response (e.g. "Success"/<errorMessage>/"Fullscreen closed")

  if event.isError then
    -- handle failed ad loading
  else
    -- optionally handle interstitial closing, etc
  end
end

ads.init( "crossinstall", "cGCk", adListener )
ads.show( "banner", "my placement name", { x=0, y=430, w=320, h=50, timeout=15 } )

require("system.core")
--require("__coretest")


c1 = System:createClass("circle")

function c1:constructor(data)
	self.m_object = display.newCircle(data.container,data.x,data.y,data.radius or 45)
	self.m_object:setFillColor( math.random( ),math.random(),math.random())
	self.m_object.strokeWidth = 2
end 

function c1:destructor()
	self.m_object:removeSelf() self.m_object = nil 
end

function c1:getDisplayItems() return { self.m_object } end

c2 = System:createClass("thingy")
function c2:constructor(data)
	self.m_object = display.newGroup()
	self.m_object.x,self.m_object.y = data.x,data.y
	local c 
	c = display.newCircle(self.m_object,-10,0,14)
	c:setFillColor( math.random( ),math.random(),math.random())
	c = display.newCircle(self.m_object,10,0,14)
	c:setFillColor( math.random( ),math.random(),math.random())
	data.container:insert(self.m_object)
end 
function c2:destructor()
	self.m_object:removeSelf() self.m_object = nil 
end
function c2:getDisplayItems() return { self.m_object } end

g1 = System:new("system.scene")
g2 = System:new("system.scene")

for n = 1,10 do 
	i1 = g1:new("circle",{ x = 100,y = 100+n*20 })
	i2 = g2:new("thingy",{ x = display.contentWidth - 30,y = display.contentHeight - 10-n*33 })
end

rcp = System:createClass("recipient")
function rcp:onMessage(name,body,info)
	print(name,body.data,info.sender)
end 
rcp1 = System:new("recipient")

timer.performWithDelay(10,
	function()
		local w = math.floor(system.getTimer()/50) % 100
		g1:setAlpha(w/100)
		g2:setAlpha((1-w/100))
	end,0
)

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--
-- ****************************************************************************************************************

