require ("entities/Player")
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
state.player_x = 0
state.player_y = 0
state.player_distance = 0
state.speed = 10
state.moving_x = 0
state.moving_y = 0



------ StateManager functions ------
function state.onFocus(self)
	self.layerTable[1][1]:setClearColor (0,0,0,1)
	MOAIInputMgr.device.pointer:setCallback (self:getPointerCallback ())
	MOAIInputMgr.device.mouseLeft:setCallback (self:getClickCallback ())



	------------------------------------
	--- FOR TESTING PURPOSES!!!!! ------
	------------------------------------
	MOAIInputMgr.device.keyboard:setCallback ( 
		function (key, down)
			if down == true then
				local to_moveX = 0
				local to_moveY = 0
				if key == 119 then
					local mapX, mapY = state.map:getLoc ()
					to_moveY = -10
					--state.map:moveMap (0, -10)
					--state.current_y = current_y - 10
				end
				if key == 115 then
					local mapX, mapY = state.map:getLoc ()
					to_moveY = 10
					--state.map:moveMap (0, 10)
					--state.current_y = current_y + 10
				end
				if key == 97 then
					local mapX, mapY = state.map:getLoc ()
					to_moveX = 10
					--state.map:moveMap (10, 0)
					--state.current_x = current_x + 10
				end
				if key == 100 then
					local mapX, mapY = state.map:getLoc ()
					to_moveX = 10
					--state.map:moveMap (-10, 0)
					--state.current_x = current_x - 10
				end

				state.player_x = state.player_x + to_moveX
				state.player_y = state.player_y + to_moveY
				local distance = util.vectorNorm (state.player_x, 
												  state.player_y)
				distance = distance / 64
				print (distance, (distance > state.player_distance), state:getFillTile (distance))
				state.map:changeFill (state:getFillTile (distance))
				state.map:moveMap (to_moveX, to_moveY, (distance > state.player_distance))
				state.player_distance = distance

			end
		end
		)
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

	self.layerTable[1] = {background_layer, main_layer}

	self.player = Player.new ()
	self.player:setLoc (0, 0)
	self.main_partition:insertProp (self.player)

	self.map = ScrollingMap.new (15, 12)
	background_layer:insertProp (self.map)
end


function state.onUpdate(self)
	--print (self.player:getLoc ())
end


function state.onUnload(self)

end


function state.onLoseFocus(self)

end



-- Functionality implementation



-- Input Callbacks (maybe)
function state.getPointerCallback(self)
	function callback(x, y)
		self.mouseX, self.mouseY = self.layerTable[1][2]:wndToWorld (x, y)
		if self.mouse_down then
			state.player_x = state.player_x + self.moving_x
			state.player_y = state.player_y + self.moving_y
			local distance = util.vectorNorm (state.player_x, 
											  state.player_y)
			distance = distance / 64
			print (distance, (distance > state.player_distance), state:getFillTile (distance))
			state.map:changeFill (state:getFillTile (distance))
			state.map:moveMap (self.moving_x, self.moving_y, (distance > state.player_distance))
			state.player_distance = distance
		end
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
			end
		else
			self.mouse_down = false
		end
	end
	return callback
end


-- state specific utils
function state.getFillTile(self, distance)
	-- gonna be ugly :/
	if distance < 6 then
		return 1
	elseif distance < 12 then
		return 2
	end
	return 3 
end



return state