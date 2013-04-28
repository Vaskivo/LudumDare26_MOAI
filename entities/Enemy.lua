module ("Enemy", package.seeall)

block_deck = MOAIGfxQuad2D.new ()
block_deck:setTexture (ResourceManager.getImage ("enemy.png"))
block_deck:setRect (-32, -32, 32, 32)
--block_deck:setRect (-16, -16, 16, 16)

enemy_speed = 2



function new(box2d_world, x, y)
	local prop = MOAIProp2D.new ()
	prop.gameType = 'enemy'
	prop:setDeck (block_deck)
	prop:setLoc (0, 0)

	-- physics
	local body = box2d_world:addBody (MOAIBox2DBody.DYNAMIC)
	
	local fixture = body:addRect (-32, -32, 32, 32)
	body:setTransform (x, y)
	-- set collision handler
	fixture:setCollisionHandler (enemyCollisionHandler, MOAIBox2DArbiter.BEGIN)
	-- attribute link
	prop:setAttrLink (MOAIProp2D.INHERIT_TRANSFORM, body, MOAIProp2D.TRANSFORM_TRAIT)
	
	body.my_prop = prop
	prop.my_body = body
	prop.my_body.my_fixture = fixture

	-- attributes
	prop.speed = enemy_speed
	prop.direction_x = math.random (-1, 1)
	prop.direction_y = math.random (-1, 1)

	-- methods
	prop.move = move
	prop.update = update

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

function update(self)
	--print ("update")
	local moveX, moveY = util.normalizeVector (self.direction_x, 
											   self.direction_y, 
											   self.speed)
	self:move (moveX, moveY)
end


--- collision callback
function enemyCollisionHandler(phase, fix_a, fix_b, arbiter)
	local me = fix_a:getBody ().my_prop
	local other = fix_b:getBody ().my_prop

	if other.gameType == "block" then
		local myX, myY = me.my_body:getPosition ()
		local otherX, otherY = other.my_body:getPosition ()
		if otherY - myY > 30 then -- is on top
			me.direction_y = - me.direction_y
		elseif otherY - myY < -30 then -- is down
			me.direction_y = - me.direction_y
		end
		if otherX - myX > 30 then -- is on right
			me.direction_x = - me.direction_x
		elseif otherX - myX < -30 then -- is on left
			me.direction_x = - me.direction_x
		end
	elseif other.gameType == "player" then
		local enemy_timer = MOAITimer.new ()
		enemy_timer:setSpan (0.01)
		enemy_timer:setListener (MOAITimer.EVENT_STOP,
			function ()
				me:clearAttrLink (MOAIProp2D.TRANSFORM_TRAIT)
				me.my_body:destroy ()
				me.my_body = nil
				me:setDeck (nil) --finish with explosion image 
			end
			)
		enemy_timer:start ()
	end
end