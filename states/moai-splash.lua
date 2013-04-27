-- MOAI splash screen

local splash = {}

-- state-manager related variables
splash.layerTable = nil


-- constants
splash.duration = 2 -- seconds
splash.nextState = "states/randomball-state.lua"


function splash.onFocus(self)
	splash.layerTable[1][1]:setClearColor (0, 0, 0, 1)

	--[[
	self.timer = MOAITimer.new ()
	self.timer:setSpan (self.duration)
	self.timer:setListener (MOAITimer.EVENT_STOP, 
		function ()
			print (StateManager.getCurState ())
			StateManager.swap (self.nextState)
		end
		)
	self.timer:start ()
	]]--
end

 function splash.onLoad(self)
	self.layerTable = {}
	local layer = MOAILayer2D.new ()
	layer:setViewport (viewport)
	self.layerTable[1] = {layer}

	local moai_deck = MOAIGfxQuad2D.new ()
	moai_deck:setTexture (ResourceManager.getImage ("moai.png"))
	moai_deck:setRect (-512, -384, 512, 384)

	local moai_logo = MOAIProp2D.new ()
	moai_logo:setDeck (moai_deck)
	layer:insertProp (moai_logo)
end

function splash.onUnload(self)
	for i, layerSet in pairs (self.layerTable) do
		for j, layer in pairs (layerSet) do
			layer:clear ()
			layer = nil
		end
	end
end

function splash.onLoseFocus(self)	
end


return splash 