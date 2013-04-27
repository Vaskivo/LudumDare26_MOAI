module ("ScrollingMap", package.seeall)


green_tile_deck = MOAITileDeck2D.new ()
green_tile_deck:setTexture (ResourceManager.getImage ("tiles-sheet-test.png"))
green_tile_deck:setSize (3, 1)


function new(x_size, y_size) 
	local map = MOAIGrid.new ()
	map.x_size = x_size
	map.y_size = y_size
	map:initRectGrid (x_size, y_size, 64, 64)
	for i = 1, y_size do
		map:setRow (i, 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)   -- find way to do this using x_size
	end

	local prop = MOAIProp2D.new ()
	prop:setDeck (green_tile_deck)
	prop:setGrid (map)
	prop.x_limit = (-SCREEN_WIDTH / 2) - 64
	prop.y_limit = (-SCREEN_HEIGHT / 2) - 64
	prop:setLoc (prop.x_limit, prop.y_limit)


	-- set up attributes
	prop.current_fill = 1
	prop.old_fill = 1

	-- set up "methods"
	prop.moveMap = moveMap
	prop.shiftLeft = shiftLeft
	prop.shiftRight = shiftRight
	prop.shiftUp = shiftUp
	prop.shiftDown = shiftDown
	prop.fillRight = fillRight
	prop.fillLeft = fillLeft
	prop.fillUp = fillUp
	prop.fillDown = fillDown
	prop.changeFill = changeFill

	return prop
end

function moveMap(self, x, y, forward) 
	local mapX, mapY = self:getLoc ()
	mapX = mapX + x
	mapY = mapY + y
	if mapX > self.x_limit + 64 then -- going left
		mapX = mapX - 64
		self:shiftRight ()
		if forward then
			self:fillLeft (self.current_fill)
		else
			self:fillLeft (self.old_fill)
		end
	elseif mapX < self.x_limit - 64 then -- going right
		mapX = mapX + 64
		self:shiftLeft ()
		if forward then
			self:fillRight (self.current_fill)
		else
			self:fillRight (self.old_fill)
		end
	end
	if mapY > self.y_limit + 64 then  -- going down
		mapY = mapY - 64
		self:shiftUp ()
		if forward then
			self:fillDown (self.current_fill)
		else
			self:fillDown (self.old_fill)
		end
	elseif mapY < self.y_limit - 64 then -- going up
		mapY = mapY + 64
		self:shiftDown ()
		if forward then
			self:fillUp (self.current_fill)
		else
			self:fillUp (self.old_fill)
		end
	end

	self:setLoc (mapX, mapY)
end





function changeFill(self, fill) 
	if fill ~= self.current_fill then
		self.old_fill = self.current_fill
		self.current_fill = fill
	end
end




-- shifting
function shiftLeft(self)
	grid = self:getGrid ()
	for x = 1, grid.x_size - 1 do
		for y = 1, grid.y_size do
			local value = grid:getTile (x+1, y)
			grid:setTile (x, y, value)
		end
	end
end

function shiftRight(self)
	grid = self:getGrid ()
	for x = grid.x_size, 2, -1 do
		for y = 1, grid.y_size do
			local value = grid:getTile (x-1, y)
			grid:setTile (x, y, value)
		end
	end
end

function shiftDown(self)
	grid = self:getGrid ()
	for x = 1, grid.x_size do
		for y = 1, grid.y_size - 1 do
			local value = grid:getTile (x, y+1)
			grid:setTile (x, y, value)
		end
	end
end

function shiftUp(self)
	grid = self:getGrid ()
	for x = 1, grid.x_size do
		for y = grid.y_size, 2, -1 do
			local value = grid:getTile (x, y-1)
			grid:setTile (x, y, value)
		end
	end
end

-- filling
function fillRight(self, tile_number)
	grid = self:getGrid ()
	for y = 1, grid.y_size do
		grid:setTile (grid.x_size, y, tile_number)
	end
end

function fillLeft(self, tile_number)
	grid = self:getGrid ()
	for y = 1, grid.y_size do
		grid:setTile (1, y, tile_number)
	end
end

function fillUp(self, tile_number)
	grid = self:getGrid ()
	for x = 1, grid.x_size do
		grid:setTile (x, grid.y_size, tile_number)
	end
end

function fillDown(self, tile_number)
	grid = self:getGrid ()
	for x = 1, grid.x_size do
		grid:setTile (x, 1, tile_number)
	end
end