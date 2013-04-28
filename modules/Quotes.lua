module ("Quotes", package.seeall)


style = MOAITextStyle.new ()
style:setFont (ResourceManager.getFont ("DejaVuSerifCondensed-BoldItalic.ttf", 32))
style:setColor (0,0,0)
style:setSize (32)


-- TEXT
SWORD = "The secret of happiness, you see, is not found in seeking more, but in developing the capacity to enjoy less.\n - Socrates"
BLOCK = "Be Content with what you have; rejoice in the way things are. When you realize there is nothing lacking, the whole world belongs to you.\n - Lau Tzu"
ENEMY = "Live simply so that others may simply live.\n - Elizabeth Ann Seton"
GOLD = "You have succeeded in life when all you really want is only what you really need.\n - Vernon Howard"
BAD_END = "There is no greatness where there is not simplicity, goodness, and truth.\n - Leo Tolstoi"
GOOD_END = "It’s only after we’ve lost everything that we’re free to do anything.\n - Tyler Durden (Fight Club)"

ACTIVE = false

function drawText(layer, text)
	ACTIVE = true
	local textBox = MOAITextBox.new ()
	textBox:setString (text)
	textBox:setStyle (style)
	textBox:setRect ( -300, 0, 300, 250)
	textBox:setYFlip (true)
	--textBox:setWordBreak (MOAITextBox.WORD_BREAK_CHAR)
	layer:insertProp (textBox)

	-- remove it
	local timer = MOAITimer.new ()
	timer:setSpan (4)
	timer:setListener (MOAITimer.EVENT_STOP,
		function ()
			layer:removeProp (textBox)
			textBox = nil
			ACTIVE = false
		end
		)
	timer:start ()
end