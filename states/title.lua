

local state = {}
state.layerTable = nil

-- partitions
state.main_partition = nil
state.gui_partition = nil

-- IO Stuff
state.mouseX = nil
state.mouseY = nil

--GUI stuff
state.gui = nil  


------ StateManager functions ------
function state.onFocus(self)
	MOAIInputMgr.device.mouseLeft:setCallback (
		function (down)
			if down then
				StateManager.swap ("states/game-state.lua")
			end
		end
		)


end


function state.onLoad(self)
	self.layerTable = {}

	local main_layer = MOAILayer2D.new ()
	main_layer:setViewport (viewport)

	self.layerTable[1] = {main_layer}

	self.layerTable[1][1]:setClearColor (0,0,0,1)

	local deck = MOAIGfxQuad2D.new ()
	deck:setTexture (ResourceManager.getImage ("title.png"))
	deck:setRect (-400, -300, 400, 300)

	local prop = MOAIProp2D.new ()
	prop:setDeck (deck)
	main_layer:insertProp (prop)
end


function state.onInput(self)
	-- I think I'll manage the input myself
end


function state.onUpdate(self)

end


function state.onUnload(self)

end


function state.onLoseFocus(self)
	MOAIInputMgr.device.mouseLeft:setCallback (nil)
end



-- Functionality implementation



-- Input Callbacks (maybe)



-- state specific utils




return state