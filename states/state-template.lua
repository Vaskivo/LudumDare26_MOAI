-- 
-- STATE TEMPLATE --
--

local state = {}
local state.layerTable = nil

-- partitions
state.main_partition = nil
state.gui_partition = nil

-- IO Stuff
state.mouseX
state.mouseY

--GUI stuff
state.gui = nil  


------ StateManager functions ------
function state.onFocus(self)

end


function state.onLoad(self)

end


function state.onInput(self)
	-- I think I'll manage the input myself
end


function state.onUpdate(self)

end


function state.onUnload(self)

end


function state.onLoseFocus(self)

end



-- Functionality implementation



-- Input Callbacks (maybe)



-- state specific utils




return state