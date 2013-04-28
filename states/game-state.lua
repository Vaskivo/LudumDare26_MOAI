require ("entities/Player")
require ("entities/Block")
require ("entities/Enemy")
require ("entities/Gold")
require ("entities/ScrollingMap")
require ("modules/util")

local state = {}
state.layerTable = nil

-- partitions
state.main_partition = nil
state.gui_partition = nil

-- IO Stuff
state.mouseX = nil
state.mouseY = nil
state.mouse_down = false

--GUI stuff
state.gui = nil 


-- functionality stuff
state.player_level = 1
state.player_x = 0
state.player_y = 0
state.player_distance = 0
state.speed = 5
state.moving_x = 0
state.moving_y = 0
state.nullifier = { up = 1,
					down = 1,
					left = 1,
					right = 1}


state.stuff_table = nil
state.iteration_to_delete = 0


-- stuff for the random
state.random_total = 1000
state.random_limit = 980
state.spawn_block = true
state.spawn_enemy = true
state.spawn_gold = true




------ StateManager functions ------
function state.onFocus(self)
	self.layerTable[1][1]:setClearColor (0,0,0,1)
	MOAIInputMgr.device.pointer:setCallback (self:getPointerCallback ())
	MOAIInputMgr.device.mouseLeft:setCallback (self:getClickCallback ())



	------------------------------------
	--- FOR TESTING PURPOSES!!!!! ------
	------------------------------------
	
end


function state.onLoad(self)
	self.layerTable = {}

	local main_layer = MOAILayer2D.new ()
	main_layer:setViewport (viewport)

	local background_layer = MOAILayer2D.new ()
	background_layer:setViewport (viewport)

	-- partitions. I hate these...
	self.main_partition = MOAIPartition.new ()
	main_layer:setPartition (self.main_partition)


	-- set up Box2D
	box2d_world = MOAIBox2DWorld.new ()
	box2d_world:setUnitsToMeters (1/100)
	box2d_world:start ()
	main_layer:setBox2DWorld (box2d_world) --physics exist in the main layer


	self.layerTable[1] = {background_layer, main_layer}

	self.player = Player.new (box2d_world)
	self.player:setLoc (0, 0)
	self.main_partition:insertProp (self.player)

	self.player.nullifier = self.nullifier

	self.map = ScrollingMap.new (15, 13)
	background_layer:insertProp (self.map)

	self.stuff_table = {}
	self.box2d_world = box2d_world

end


function state.onUpdate(self)
	for i, j in pairs (self.stuff_table) do
		if j.update then
			j:update ()
		end
	end
	if self.mouse_down then
		--print (self.nullifier.up)
		if (self.moving_y < 0) and (self.nullifier.up == 0) then
			self.moving_y = 0
		end
		if (self.moving_y > 0) and (self.nullifier.down == 0) then
			self.moving_y = 0
		end
		if (self.moving_x < 0) and (self.nullifier.right == 0) then
			self.moving_x = 0
		end
		if (self.moving_x > 0) and (self.nullifier.left == 0) then
			self.moving_x = 0
		end

		self.player_x = self.player_x + self.moving_x
		self.player_y = self.player_y + self.moving_y
		local distance = util.vectorNorm (self.player_x, 
										  self.player_y)
		distance = distance / 64
		--print (distance, (distance > self.player_distance), self.map:getFillTile (distance))
		self.map:changeFill (self.map:getFillTile (distance,(distance > self.player_distance)))
		self.map:moveMap (self.moving_x, self.moving_y)
		self.player_distance = distance

		--move stuff
		for i, j in pairs (self.stuff_table) do
			j:move (self.moving_x, self.moving_y)
		end

		-- add stuff to the map
		if math.random (state.random_total) > state.random_limit then
			local f = nil
			local r = math.random (3)
			if r == 1 and state.spawn_block == true then
				f = self.createBlock
			elseif r == 2 and state.spawn_enemy == true then
				f = self.createEnemy
			elseif r == 3 and state.spawn_gold == true then
				f = self.createGold
			end

			if f == nil then
				f = void
			end

			-- see where am I walking
			if ( math.abs (self.moving_x) > math.abs (self.moving_y)) then
				-- going left or right
				local aux = -self.moving_x / math.abs (self.moving_x) -- 1 or -1
				local y_position = math.random (-300, 300)
				--self:createBlock (aux * 430, y_position)
				f (self, aux * 430, y_position)
			else
				-- going up or down
				local aux = -self.moving_y / math.abs (self.moving_y) -- 1 or -1
				local x_position = math.random (-400, 400)
				--self:createBlock (x_position, aux * 330)
				f (self, x_position, aux * 330)
			end
		end
		if state.iteration_to_delete > 300 then
			state:deleteOldStuff ()
			state.iteration_to_delete = 0
		end
		state.iteration_to_delete = state.iteration_to_delete + 1
	end
end


function state.onUnload(self)

end


function state.onLoseFocus(self)

end



-- Functionality implementation
function state.createBlock(self, x, y) 
	local block = Block.new (self.box2d_world, x, y)
	self.layerTable[1][2]:insertProp (block)
	table.insert (self.stuff_table, block)
	return block
end

function state.createEnemy (self, x, y)
	local enemy = Enemy.new (self.box2d_world, x, y)
	self.layerTable[1][2]:insertProp (enemy)
	table.insert (self.stuff_table, enemy)
	return enemy
end

function state.createGold (self, x, y)
	print(self)
	local gold = Gold.new (self.box2d_world, x, y)
	self.layerTable[1][2]:insertProp (gold)
	table.insert (self.stuff_table, gold)
	return gold
end


function state.deleteOldStuff(self)
	local new_table = {}
	for i, j in pairs (self.stuff_table) do
		local x, y = j:getLoc ()
		if not (x < -600 or x > 600 or y < -500 or y > 500) then
			table.insert (new_table, j)
		else
			self.layerTable[1][2]:removeProp (j)
			j.my_body:destroy ()
			j.my_body = nil
			j = nil
		end
	end
	self.stuff_table = new_table
end


-- a little hack
function void()

end



-- Input Callbacks (maybe)
function state.getPointerCallback(self)
	function callback(x, y)
		self.mouseX, self.mouseY = self.layerTable[1][2]:wndToWorld (x, y)
		self.moving_x, self.moving_y = util.normalizeVector (self.mouseX, 
															 self.mouseY, 
															 self.speed)
		self.moving_x = -self.moving_x
		self.moving_y = -self.moving_y
	end
	return callback
end

function state.getClickCallback(self)
	function callback(down)
		if down then
			local prop = self.main_partition:propForPoint (self.mouseX,
														   self.mouseY)
			if thisProp and thisProp.onClick then
				-- do something!
			else 
				-- clicked the map -> move
				self.mouse_down = true
				self.moving_x, self.moving_y = util.normalizeVector (self.mouseX, 
																	 self.mouseY, 
																	 self.speed)
				self.moving_x = -self.moving_x
				self.moving_y = -self.moving_y
			end
		else
			self.mouse_down = false
		end
	end
	return callback
end


-- state specific utils




return state