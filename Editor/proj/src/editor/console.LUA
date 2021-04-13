

console_class = class( function( self, Name )
	self.DefaultColor = { 1.0, 1.0, 1.0, 1.0 }
	self.StatusColor = {
		err = { 1.0, 0.4, 0.4, 1.0 },
		warn = { 1.0, 0.8, 0.6, 1.0 },
		atn = { 0.4, 1.0, 0.4, 1.0 },
		oft = { 1.0, 1.0, 1.0, 0.6 }
	}

	self.ConsoleHistory = {}
	self.ConsoleName = Name or "Console"
	self.ShowConsole = true
	self.NeedScrollEnd = false
end)


function console_class:LogString( Text, Status )
	Now = os.date('*t') --get the date/time
	local Time = "[" .. Now.hour .. ":" .. Now.min .. ":" .. Now.sec .. "] "
	local Line = {
		Status = Status or "no",
		Text = Time .. Text
	}

	table.insert( self.ConsoleHistory, Line )
	if #self.ConsoleHistory > 1000 then
		table.remove( self.ConsoleHistory, 1 )
	end
	self.NeedScrollEnd = true
end


function console_class:Log( Var, Status )
	local function PushToLog( Text )
		self:LogString( Text, Status )
	end
	LogVar( Var, PushToLog )
end


function console_class:Draw()
	if not self.ShowConsole then
		return
	end

	if imgui.Begin( self.ConsoleName ) then
		imgui.PushStyleVar( "ItemSpacing", 4, 1 )
		for _, Item in ipairs( self.ConsoleHistory ) do
			local Color = self.StatusColor[ Item.Status ] or self.DefaultColor
			imgui.PushStyleColor( "Text", unpack( Color ) )
			--imgui.TextUnformatted( "[" .. Item.Status .. "] " .. Item.Text )
			imgui.TextUnformatted( Item.Text )
			imgui.PopStyleColor()			
		end

		if self.NeedScrollEnd then
			imgui.SetScrollHere()
			self.NeedScrollEnd = false
		end
		imgui.PopStyleVar()

		imgui.End()
	else
		imgui.End()
    end
end