module ("GUI", package.seeall)


style = MOAITextStyle.new ()
style:setFont (ResourceManager.getFont ("DejaVuSerifCondensed-BoldItalic.ttf", 32))
style:setColor (0,0,0)
style:setSize (32)

frame_deck = MOAIGfxQuad2D.new ()
frame_deck:setTexture (ResourceManager.getImage ("frame.png"))
frame_deck:setRect (-100, -50, 100, 50)


function getXP() 
	local textBox = MOAITextBox.new ()
	textBox:setString (text)
	textBox:setStyle (style)
	textBox:setRect ( -80, -30, 80, 30)
	textBox:setYFlip (true)
	textBox:setLoc (800-80, 600-30)

	textFrame = MOAIProp2D.new ()
	textFrame:setDeck (frame_deck)

end