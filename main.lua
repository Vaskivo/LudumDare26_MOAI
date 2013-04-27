require "modules/ResourceManager"
require "modules/StateManager"
require "modules/util"

MOAISim.openWindow ("Randomball", SCREEN_WIDTH, SCREEN_HEIGHT)

viewport = MOAIViewport.new ()
viewport:setSize (SCREEN_WIDTH, SCREEN_HEIGHT)
viewport:setScale (SCREEN_WIDTH, SCREEN_HEIGHT)


JUMP_TO = nil
----------------------------------------------------------------
if 	JUMP_TO	then
	StateManager.push ( JUMP_TO )
----------------------------------------------------------------
else
	StateManager.push ( "states/moai-splash.lua" )	
end
----------------------------------------------------------------

-- Start the game!
StateManager.begin ()