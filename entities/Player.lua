module ("Player", package.seeall)



player_deck = MOAIGfxQuad2D.new ()
player_deck:setTexture (ResourceManager.getImage ("player.png"))
player_deck:setRect (-32, -32, 32, 32)


function new()
	local prop = MOAIProp2D.new ()
	prop.gameType = "player"
	prop:setDeck (player_deck)

	return prop
end
