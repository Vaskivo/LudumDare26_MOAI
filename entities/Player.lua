module ("Player", package.seeall)



player_deck = MOAIGfxQuad2D.new ()
player_deck:setTexture (ResourceManager.getImage ("player.png"))
player_deck:setRect (-32, -32, 32, 32)
--player_deck:setRect (-16, -16, 16, 16)

player_nDeck = MOAITileDeck2D.new ()
player_nDeck:setTexture (ResourceManager.getImage ("player-sprites.png"))
player_nDeck:setSize (6, 1)
player_nDeck:setRect (-40, -40, 40, 40)


function new(box2d_world)
	local prop = MOAIProp2D.new ()
	prop.gameType = "player"
	prop:setDeck (player_nDeck)
	prop:setIndex (1)
	prop.my_deck_size = 40

	-- physics
	local body = box2d_world:addBody (MOAIBox2DBody.STATIC)
	body:setTransform (0, 0)
	local fixture = body:addCircle (0, 0, 30)
	-- set collision handler
	fixture:setCollisionHandler (playerCollisionHandler, MOAIBox2DArbiter.BEGIN + 
														 MOAIBox2DArbiter.END)

	body.my_prop = prop
	prop.my_body = body
	prop.my_body.my_fixture = fixture


	-- attributes
	prop.lives = 3
	prop.touchedEnemy = false
	prop.touchedBlock = false
	prop.touchedGold = false
	prop.actual_level = 1

	prop.direction_x = 0
	prop.direction_y = 1

	-- methods
	prop.loseLife = loseLife
	prop.changeLevel = changeLevel
	prop.rotateTo = rotateTo
	prop.resizeDeck = resizeDeck
	prop.resetDeck = resetDeck

	return prop
end


function loseLife(self)
	self.lives = self.lives - 1
	--print ("lost Life")
end

function changeLevel (self, level)
	if level == self.actual_level then
		return
	end
	--print("gonna change player sprite")
	self.actual_level = level
	self:setIndex (level)
end

function rotateTo(self, x, y)
	--print(x, y)
	local angle = util.vectorAngle (self.direction_x, self.direction_y, x, y)
	if x > 0 then
		angle = -angle
	end
	angle = math.deg (angle)
	self:setRot (angle)
end


function resizeDeck(self)
	if self.my_deck_size > 400 then
		player_nDeck:setRect (-40, 40, 40, 40)
		self.gameOver ()
	end
	self.my_deck_size = self.my_deck_size * 1.5
	player_nDeck:setRect (- self.my_deck_size, -self.my_deck_size, self.my_deck_size, self.my_deck_size)
	self:setDeck (player_nDeck)
end

function resetDeck(self)
	player_nDeck:setRect (-40, -40, 40, 40)
	self:setDeck (player_nDeck)
end


-- collision handler
-- as always, my collision handler is turning out to be something that came from the pits of hell!
function playerCollisionHandler(phase, fix_a, fix_b, arbiter)
	local player = fix_a:getBody ().my_prop
	local other = fix_b:getBody ().my_prop

	if phase == MOAIBox2DArbiter.BEGIN then
		if other.gameType == 'block' then
			--print("block IN")
			--other.my_body:setActive (true)
			--player.my_body:setActive (true)
			--[[
			local myX, myY = player.my_body:getPosition ()
			local otherX, otherY = other.my_body:getPosition ()
	
			if otherY - myY > 30 then -- is on top
				player.nullifier.up = 0
			elseif otherY - myY < -30 then -- is down)
				player.nullifier.down = 0
			end
			if otherX - myX > 30 then -- is on right
				player.nullifier.right = 0
			elseif otherX - myX < -30 then -- is on left
				player.nullifier.left = 0
			end
			]]
			local block_timer = MOAITimer.new ()
			block_timer:setSpan (0.01)
			block_timer:setListener (MOAITimer.EVENT_STOP,
				function ()
					other:destroyBlock ()
				end
				)
			block_timer:start ()

			if player.touchedBlock == false then
				player.touchedBlock = true
				player.onTouchBlock ()
			end
		elseif other.gameType == "enemy" then
			player:loseLife ()
			if player.touchedEnemy == false then
				player.touchedEnemy = true
				player.onTouchEnemy ()
			end
		elseif other.gameType == "gold" then
			if player.touchedGold == false then
				player.touchedGold = true
				player.onTouchGold ()
			end
		end
	end
	--[[
	if phase == MOAIBox2DArbiter.END then
		if other.gameType == 'block' then
			print("block OUT")
			local myX, myY = player.my_body:getPosition ()
			local otherX, otherY = other.my_body:getPosition ()
			if otherY - myY > 30 then -- is on top
				player.nullifier.up = 1
			elseif otherY - myY < -30 then -- is down
				player.nullifier.down = 1
			end
			if otherX - myX > 30 then -- is on right
				player.nullifier.right = 1
			elseif otherX - myX < -30 then -- is on left
				player.nullifier.left = 1
			end
		end
	end ]]
end