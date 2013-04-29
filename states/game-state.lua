require ("entities/Player")
require ("entities/Block")
require ("entities/Enemy")
require ("entities/Gold")
require ("entities/ScrollingMap")
require ("modules/Quotes")
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

state.record = { sword = false,
				 enemy = false,
				 block = false,
				 gold = false}



state.stuff_table = nil
state.iteration_to_delete = 0


-- stuff for the random
state.random_total = 1000
state.random_limit = 950
state.spawn_block = true
state.spawn_enemy = true
state.spawn_gold = true




------ StateManager functions ------
function state.onFocus(self)
	self:setUpShit ()
	self.player:resetDeck ()
	self.layerTable[1][1]:setClearColor (0,0,0,1)
	MOAIInputMgr.device.pointer:setCallback (self:getPointerCallback ())
	MOAIInputMgr.device.mouseLeft:setCallback (self:getClickCallback ())


	------------------------------------
	--- FOR TESTING PURPOSES!!!!! ------
	------------------------------------
	--[[
	MOAIInputMgr.device.keyboard:setCallback ( 
	    function (key, down)
	        if down == true then
	        	if key == 114 then
	        		for i, j in pairs (self.stuff_table) do
	        			j.my_body:destroy ()
	        			j.my_body = nil
	        			self.layerTable[1][2]:removeProp (j)
	        			j = nil
	        		end
	        		self.stuff_table = {}
	        	end
	        end
	    end
	    )]]
end


function state.onLoad(self)
	--self:setUpShit ()
	self.layerTable = {}

	local main_layer = MOAILayer2D.new ()
	main_layer:setViewport (viewport)

	local background_layer = MOAILayer2D.new ()
	background_layer:setViewport (viewport)

	local gui_layer = MOAILayer2D.new ()
	gui_layer:setViewport (viewport)

	-- partitions. I hate these...
	self.main_partition = MOAIPartition.new ()
	main_layer:setPartition (self.main_partition)


	-- set up Box2D
	box2d_world = MOAIBox2DWorld.new ()
	box2d_world:setDebugDrawEnabled	(false)
	box2d_world:setUnitsToMeters (1/100)
	box2d_world:start ()
	main_layer:setBox2DWorld (box2d_world) --physics exist in the main layer


	self.layerTable[1] = {background_layer, main_layer, gui_layer}

	self.player = Player.new (box2d_world)
	self.player:setLoc (0, 0)
	self.main_partition:insertProp (self.player)

	self.player.nullifier = self.nullifier
	self.player.onTouchEnemy = self:playerTouchedEnemy ()
	self.player.onTouchBlock = self:playerTouchedBlock ()
	self.player.onTouchGold = self:playerTouchedGold ()
	self.player.gameOver = self:finishGame ()

	self.map = ScrollingMap.new (15, 13)
	background_layer:insertProp (self.map)

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
		--[[
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
		]]
		

		self.player_x = self.player_x + self.moving_x
		self.player_y = self.player_y + self.moving_y
		local distance = util.vectorNorm (self.player_x, 
										  self.player_y)
		distance = distance / 64
		--print (distance)
		self.map:changeFill (self.map:getFillTile (distance,(distance > self.player_distance)))
		self.map:moveMap (self.moving_x, self.moving_y)
		self.player_distance = distance
		self:changeLevel (distance)
		self.player:changeLevel (self.player_level)
		--move stuff
		for i, j in pairs (self.stuff_table) do
			j:move (self.moving_x, self.moving_y)
		end
		self.player:rotateTo (-self.moving_x, -self.moving_y)

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
	

	for i, layerSet in ipairs ( self.layerTable ) do
		
		for j, layer in ipairs ( layerSet ) do
		
			layer = nil
		end
	end
	
	self.layerTable = nil
	self.main_partition = nil
	self.gui_partition = nil
end


function state.onLoseFocus(self)
	MOAIInputMgr.device.pointer:setCallback (nil)
	MOAIInputMgr.device.mouseLeft:setCallback (nil)

	for i, j in pairs (self.stuff_table) do
		self.main_partition:removeProp (j)
		if j.my_body then
			j.my_body:destroy ()
			j.my_body = nil
		end
		j = nil
	end
	self.main_partition:removeProp (self.player)
	self.main_partition = nil
	self.player.my_body:destroy ()
	self.player.my_body = nil
	self.player = nil
end



-- Functionality implementation
function state.setUpShit(self)
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

	state.record = { sword = false,
					 enemy = false,
					 block = false,
					 gold = false}



	state.stuff_table = {}
	state.iteration_to_delete = 0


	-- stuff for the random
	state.random_total = 1000
	state.random_limit = 950
	state.spawn_block = true
	state.spawn_enemy = true
	state.spawn_gold = true
end



function state.createBlock(self, x, y) 
	local block = Block.new (self.box2d_world, x, y, self.player_level)
	self.main_partition:insertProp (block)
	table.insert (self.stuff_table, block)
	return block
end

function state.createEnemy (self, x, y)
	local enemy = Enemy.new (self.box2d_world, x, y, self.player_level)
	self.main_partition:insertProp (enemy)
	table.insert (self.stuff_table, enemy)
	return enemy
end

function state.createGold (self, x, y)
	local gold = Gold.new (self.box2d_world, x, y, self.player_level)
	self.main_partition:insertProp (gold)
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
			self.main_partition:removeProp (j)
			j.my_body:destroy ()
			j.my_body = nil
			j = nil
		end
	end
	self.stuff_table = new_table
end


function state.playerTouchedEnemy(self)
	function f()
		if Quotes.ACTIVE == true then
			return
		end
		self.record.enemy = true
		Quotes.drawText (self.layerTable[1][3], Quotes.ENEMY)
	end
	return f
end

function state.playerTouchedBlock(self)
	function f()
		if Quotes.ACTIVE == true then
			return
		end
		self.record.block = true
		Quotes.drawText (self.layerTable[1][3], Quotes.BLOCK)
	end
	return f
end

function state.playerTouchedGold(self)
	function f()
		if Quotes.ACTIVE == true then
			return
		end
		self.record.gold = true
		Quotes.drawText (self.layerTable[1][3], Quotes.GOLD)
	end
	return f
end

function state.finishGame(self)
	local function gameOver()
		--print(self.record.gold, self.record.block, self.record.enemy)
		if self.record.gold or self.record.block or self.record.enemy then
			StateManager.swap ('states/bad-end.lua')
		else
			StateManager.swap ('states/good-end.lua')
		end
	end
	return gameOver
end


function state.changeLevel (self, distance)
	if distance < 26 then
		self:setLevel (1)
		self.player_level = 1
	elseif distance < 46 then 
		self:setLevel (2)
	elseif distance < 66 then
		self:setLevel (3)
	elseif distance < 86 then
		self:setLevel (4)
	elseif distance < 106 then
		self:setLevel (5)
	else
		self:setLevel (6)
	end
end

function state.setLevel (self, level)
	if self.player_level == level then
		return
	end
	self.player_level = level
	if level == 1 then
		self.spawn_enemy = true
		self.spawn_gold = true
		self.spawn_block = true
		-- show certain GUIs
	elseif level == 2 then
		self.spawn_enemy = true
		self.spawn_gold = true
		self.spawn_block = true
		-- show certain GUIs
	elseif level == 3 then
		self.spawn_enemy = false
		self.spawn_gold = true
		self.spawn_block = true
		-- show certain GUIs
	elseif level == 4 then
		self.spawn_enemy = false
		self.spawn_gold = false
		self.spawn_block = true
		-- show certain GUIs
	elseif level == 5 then

		self.spawn_enemy = false
		self.spawn_gold = false
		self.spawn_block = false
		-- show certain GUIs
	elseif level == 6 then
		self.spawn_enemy = false
		self.spawn_gold = false
		self.spawn_block = false
		-- show certain GUIs
	else
		-- jump to end
	end
end


-- a little hack
function void()

end



-- Input Callbacks (maybe)
function state.getPointerCallback(self)
	function callback(x, y)
		if self.player_level == 6 then
			return
		end
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
			if self.player_level >= 6 and self.player_distance > 112 then
				--print ("resizing")
				self.player:resizeDeck ()
				return
			end

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