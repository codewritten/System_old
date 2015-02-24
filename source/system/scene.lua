-- ****************************************************************************************************************
-- ****************************************************************************************************************
--
--		File:		scene.lua 
--		Purpose:	Scene class (Group with associated display object support)
--		Author:		Paul Robson
--		Created:	27-Nov-14
--
-- ****************************************************************************************************************
-- ****************************************************************************************************************

local Scene,SuperClass = System:createClass("system.scene","system.group")							-- scene is an extended group.

--*****************************************************************************************************************
---		@class 		system.scene 
--
---		A scene object is almost identical to a group object, e.g. it is a collection of objects with a common tag
--- 	and a display container containing all the display objects. The container is passed as an additional parameter
--- 	to the constructor (container) and it is the responsibility of all objects to attach themselves, or remove
--- 	themselves from the container as required.
--*****************************************************************************************************************

--*****************************************************************************************************************
---		@method 	Scene.constructor 				Constructs a scene - a group with an associated container
---		@param 		data 							Constructor data
--*****************************************************************************************************************

function Scene:constructor(data)
	SuperClass.constructor(self,data)																-- call the superclass constructor.
	self.m_container = display.newContainer(display.contentWidth,display.contentHeight) 			-- create a new container
	self:resetContainer()																			-- reset the container to default
end

--*****************************************************************************************************************
---		@method 	Scene.destructor 				Destroys scene, checks container empty, then deletes container.
--*****************************************************************************************************************

function Scene:destructor()
	SuperClass.destructor(self) 																	-- call the destructor
	assert(self.m_container.numChildren == 0,"The container is not empty on deletion.")				-- there should now be nothing in it.
	self.m_container:removeSelf()																	-- delete container
	self.m_container = nil 																			-- erase pointer
end

--*****************************************************************************************************************
---		@method 	Scene.new 						Create a new instance of a given class, add it to the scene group
---		@param 		className<string>				Name of class to create
---		@oparam 	constructorData<table>			Constructor data (optional)
--*****************************************************************************************************************

function Scene:new(className,data)
	assert(data.container == nil,"container defined in scene constructor data")						-- shouldn't have a container
	data.container = self.m_container 																-- tell it about the container
	local newObject = SuperClass.new(self,className,data) 											-- create the new object
	data.container = nil 																			-- fix up the data back to what it was
	return newObject 
end

--*****************************************************************************************************************
---		@method 	Scene.setAlpha 					Set the alpha value for the whole scene.
---		@oparam 	Alpha value 					(defaults to 1)
--*****************************************************************************************************************

function Scene:setAlpha(alpha)
	self.m_container.alpha = alpha or 1
end 

--*****************************************************************************************************************
--		@method 	Scene.resetContainer 			Reset container to its default visibility/position, bring it to the front.
--*****************************************************************************************************************

function Scene:resetContainer()
	self.m_container.anchorX, self.m_container.anchorY = 0,0 										-- anchor top left
	self.m_container.anchorChildren = false 														-- don't anchor children.
	self:setAlpha(1)
	self.m_container:toFront() 																		-- bring to the front
end 

-- ****************************************************************************************************************
--		Date		Changes Made
--		----		------------
--		27-Nov-14	Coding begun
--		27-Nov-14	Initial Coding complete.
-- 		30-Dec-14 	Massively simplified transition interface.
--		31-Dec-14 	Code Read #1
-- ****************************************************************************************************************
