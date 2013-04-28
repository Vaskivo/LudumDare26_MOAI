--[[
	ResourceManager.lua
	Version 1.0
]]--

-- mae namespace global
_G.ResourceManager = {}

-- constants
--              resource folder path
ResourceManager.RES_PATH = './resources/'
--                 images folder path
ResourceManager.IMAGES_PATH = ResourceManager.RES_PATH .. 'images/'
--                  fonts folder path
ResourceManager.FONT_PATH = ResourceManager.RES_PATH .. 'fonts/'

local charCode = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 _.,?!;:()[]{}+-/*^@#$%&\\\'"<>`|'

-- create a cache for fonts and images
local imgCache = {}
local fntCache = {}

-- retrieve an image resource
function ResourceManager.getImage(filename)
	-- look if image is already in cache
	if imgCache[filename] then
		-- instance exists 
		return imgCache[filename]
	end

	-- make a new image
	local img = MOAIImage.new ()
	--load file
	img:load (ResourceManager.IMAGES_PATH .. filename, MOAIImage.PREMULTIPLY_ALPHA)
	-- add to cache
	imgCache[filename] = img

	return img
end

-- release imgae from cache
function ResourceManager.releaseImage(filename) 
	-- look for filename
	if imgCache[filename] then
		-- release image from memory
		imgCache[filename]:release ()
		imgCache[filename] = nil
	end
end

function ResourceManager.getFont(filename, size)
	-- look if font is already cached
	if fntCache[filename .. size] then
		-- instance exists
		return fntCache[filename .. size]
	end
	-- make new font
	local fnt = MOAIFont.new ()
	-- load file
	fnt:load (ResourceManager.FONT_PATH .. filename)
	-- preload charcode and size
	fnt:preloadGlyphs (charCode, size, 72)
	-- add to cache
	fntCache[filename .. size] = fnt

	return fnt
end

-- release font from cache
function ResourceManager.releaseFont (filename, size)
	fntCache[filename .. size] = nil
end
