local utf8 = require("utf8")


local function Split( Str, Pos )
	local Offs = utf8.offset( Str, Pos ) or 0
	return string.sub( Str, 1, Offs - 1 ), string.sub( Str, Offs )
end


text_input_class = class( function( self, Info )
	self.Text = ""
	self.Time = 0.0
	self.Cursor = "|"
	self.CursorPos = utf8.len( self.Text )
	self.X = Info.X
	self.Y = Info.Y
	self.Size = Info.Size
	self.W = Info.W
	self.Callback = Info.OnEnterCallback
	self.Shift = false
	self.Ctrl = false
end)


function text_input_class:Reset()
	self.Shift = false
	self.CursorPos = 0
	self.Text = ""
	self.Time = 0
end


function text_input_class:SetText( Text )
	self.CursorPos = utf8.len( Text )
	self.Text = Text
end


function text_input_class:Step( Dt )
	self.Time = self.Time + Dt
	if self.Time > 1 then
		if self.Cursor == "|" then
			self.Cursor = ""
		else
			self.Cursor = "|"
		end
		self.Time = 0
	end
	self.Shift = love.keyboard.isDown( "lshift", "rshift", "capslock" )
	self.Ctrl = love.keyboard.isDown( "lctrl", "rctrl" )
end


function text_input_class:Keypressed( Key )
	if Key == "backspace" and self.CursorPos > 0 then
		local L, R = Split( self.Text, self.CursorPos + 1 )
		local L2, _ = Split( L, utf8.len( L ) )
		self.Text = L2 .. R
		self.CursorPos = self.CursorPos - 1
	elseif Key == "delete" then
		local L, R = Split( self.Text, self.CursorPos + 1 )
		local _, R2 = Split( R, 2 )
		self.Text = L .. R2
	elseif Key == "backspace" and self.CursorPos > 0 then
		local L, R = Split( self.Text, self.CursorPos + 1 )
		local _, R2 = Split( R, 2 )
		self.Text = L .. R2
	elseif Key == "left" then
		self.CursorPos = math.max( 0, self.CursorPos - 1 )
	elseif Key == "right" then
		self.CursorPos = math.min( utf8.len( self.Text ), self.CursorPos + 1 )
	elseif Key == "home" then
		self.CursorPos = 0
	elseif Key == "end" then
		self.CursorPos = utf8.len( self.Text )
	elseif Key == "return" then
		if self.Callback then
			self.Callback()	
		end
	end
end


function text_input_class:TextInput( Key )
	if utf8.len( self.Text ) < self.Size then
		local TheKey = Key
		if self.Shift then
			TheKey = Key:upper()
		end
		local L, R = Split( self.Text, self.CursorPos + 1 )
		self.Text = L .. Key .. R
		self.CursorPos = self.CursorPos + 1
	end
end


function text_input_class:Draw()
	love.graphics.printf( self.Text, self.X, self.Y, self.W )

	local Font = love.graphics.getFont()
	local LeftText = string.sub( self.Text, 1, utf8.offset( self.Text, self.CursorPos + 1 ) - 1 )
	local With, WrappedTexts = love.graphics.getFont():getWrap( LeftText, self.W )	
	local LeftWrappedTexts = WrappedTexts[ #WrappedTexts ]
	love.graphics.printf(
		self.Cursor,
		self.X + ( LeftWrappedTexts and Font:getWidth( LeftWrappedTexts ) or 0 ),
		self.Y + ( LeftWrappedTexts and ( #WrappedTexts - 1 ) * Font:getHeight() or 0 ),
		self.W
	)		
end

--TODO
--if core:mouseReleasedOn(opt.id) then
--	local mx = core:getMousePosition() - x + input.text_draw_offset
--	input.cursor = utf8.len(input.text) + 1
--	for c = 1,input.cursor do
--		local s = input.text:sub(0, utf8.offset(input.text, c)-1)
--		if opt.font:getWidth(s) >= mx then
--			input.cursor = c-1
--			break
--		end
--	end
--end