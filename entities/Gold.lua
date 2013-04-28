module ("Gold", package.seeall)

gold_deck = MOAIGfxQuad2D.new ()
gold_deck:setTexture (ResourceManager.getImage ("gold.png"))
gold_deck:setRect (-16, -16, 16, 16)

gold_nDeck = MOAITileDeck2D.new ()
gold_nDeck:setTexture (ResourceManager.getImage ("gold-sprites.png"))
gold_nDeck:setSize (4, 1)
gold_nDeck:setRect (-16, -16, 16, 16)


function new(box2d_world, x, y, level)
	local prop = MOAIProp2D.new ()
	prop.gameType = "gold"
	prop:setDeck (gold_nDeck)
	prop:setIndex (level or 1)

	-- physics
	local body = box2d_world:addBody (MOAIBox2DBody.DYNAMIC)
	
	local fixture = body:addRect (-16, -16, 16, 16)
	body:setTransform (x, y)
	-- set collision handler
	fixture:setCollisionHandler (goldCollisionHandler, MOAIBox2DArbiter.BEGIN)
	-- attribute link
	prop:setAttrLink (MOAIProp2D.INHERIT_TRANSFORM, body, MOAIProp2D.TRANSFORM_TRAIT)

	body.my_prop = prop
	prop.my_body = body
	prop.my_body.my_fixture = fixture


	-- methods
	prop.move = move

	return prop
end

function move(self, x, y)
	if self.my_body == nil then
		return
	end
	local currX, currY = self.my_body:getPosition ()
	self.my_body:setTransform (currX + x, currY + y)
	--self.my_body:setAwake (true)
end


function goldCollisionHandler(phase, fix_a, fix_B, arbiter)
	local me = fix_a:getBody ().my_prop
	local gold_timer = MOAITimer.new ()
	gold_timer:setSpan (0.01)
	gold_timer:setListener (MOAITimer.EVENT_STOP,
		function ()
			me:clearAttrLink (MOAIProp2D.TRANSFORM_TRAIT)
			me.my_body:destroy ()
			me.my_body = nil
			me:setDeck (nil)
		end
		)
	gold_timer:start ()
end