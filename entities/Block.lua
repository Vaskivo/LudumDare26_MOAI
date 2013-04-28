module ("Block", package.seeall)

block_deck = MOAIGfxQuad2D.new ()
block_deck:setTexture (ResourceManager.getImage ("block.png"))
block_deck:setRect (-32, -32, 32, 32)
--block_deck:setRect (-16, -16, 16, 16)




function new(box2d_world, x, y)
	local prop = MOAIProp2D.new ()
	prop.gameType = 'block'
	prop:setDeck (block_deck)
	prop:setLoc (0, 0)

	-- physics
	local body = box2d_world:addBody (MOAIBox2DBody.DYNAMIC)
	
	local fixture = body:addRect (-32, -32, 32, 32)
	body:setTransform (x, y)
	-- set collision handler
	--fixture:setCollisionHandler (playerCollisionHandler, MOAIBox2DArbiter.BEGIN + 
	--													 MOAIBox2DArbiter.END)
	-- attribute link
	prop:setAttrLink (MOAIProp2D.INHERIT_TRANSFORM, body, MOAIProp2D.TRANSFORM_TRAIT)
	
	body.my_prop = prop
	prop.my_body = body
	prop.my_body.my_fixture = fixture

	prop.move = move

	return prop
end


function move(self, x, y)
	local currX, currY = self.my_body:getPosition ()
	self.my_body:setTransform (currX + x, currY + y)
	self.my_body:setAwake (true)
end
