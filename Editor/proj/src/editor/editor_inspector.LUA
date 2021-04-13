

inspector_wnd_class = class( function( self, Name, Obj )
	self.Obj = Obj
	self.ObjName = Name
	self.Visible = false

	self.DrawValueFunkByType = {
		default = function(name, value)
			imgui.InputText(name, tostring(value), 40, {"ReadOnly"})
			return nil
		end,
		string = function(name, value)
			return imgui.InputText(name, tostring(value), 40)
		end,
		int = imgui.InputInt,
		float = imgui.InputFloat,
		color4 = function(name, value)
			return imgui.ColorEdit4(name, unpack(value))
		end,
		color3 = function(name, value)
			return imgui.ColorEdit3(name, unpack(value))
		end,
		boolean = function(name, value)
			return imgui.Checkbox( name, value )
		end,
	}
end)



function inspector_wnd_class:Draw()
	if not self.Visible then
		return
	end
	
	local IsVisible, IsOpen = imgui.Begin( self.ObjName, true )
	if not IsOpen then 
		self.Visible = false
	end

	if IsVisible then
		imgui.PushStyleVar( "ItemSpacing", 4, 1 )
		
		self:DrawObjParam( self.Obj )

		imgui.PopStyleVar()
		imgui.End()
	else
		imgui.End()
    end
end


function inspector_wnd_class:DrawObjParam( Obj )	
	for Key, Value in pairs( Obj ) do
		local Type = self:GetType( Value )
		
		if Type == "table" then
			UseFlags = { "OpenOnArrow", "OpenOnDoubleClick" }	
			if ( imgui.TreeNodeEx( Key, UseFlags, Key ) ) then
				self:DrawObjParam( Value )
				imgui.TreePop()
			end
		else			
			local Status
			ASSERT( self.DrawValueFunkByType[ Type ], Type )
			Status, Result = self.DrawValueFunkByType[ Type ]( Key, Value )			
			if Status and Result ~= nil then				
				Obj[ Key ] = Result
			end	
		end
	end	
end


function inspector_wnd_class:GetType( Value )
	if type( Value ) == "boolean" then			
		return "boolean"		
	end		
	
	if type( Value ) == "string" then
		return "string"
	end	

	if type( Value ) == "number" then
		local Num, Dec = math.modf( Value )
		if math.abs( Dec ) ~= 0 then		
			return "float"
		end
	end

	if type( Value ) == "number" then
		local Num, Dec = math.modf( Value )
		if math.abs( Dec ) == 0 then		
			return "int"
		end
	end

	if type( Value ) == "table" and #Value == 4  then
		if  type( Value[1] ) == "number" and
			type( Value[2] ) == "number" and 
			type( Value[3] ) == "number" and 
			type( Value[4] ) == "number" and 
			Value[1] >= 0 and Value[1] <= 1 and
			Value[2] >= 0 and Value[2] <= 1 and
			Value[3] >= 0 and Value[3] <= 1 and
			Value[4] >= 0 and Value[4] <= 1 		
		then		
			return "color4"
		end
	end

	if type( Value ) == "table" and #Value == 3  then
		if  type( Value[1] ) == "number" and
			type( Value[2] ) == "number" and 
			type( Value[3] ) == "number" and 
			Value[1] >= 0 and Value[1] <= 1 and
			Value[2] >= 0 and Value[2] <= 1 and
			Value[3] >= 0 and Value[3] <= 1 	
		then		
			return "color3"
		end
	end

	if type( Value ) == "table" then
		return "table"
	end

	if type( Value ) == "userdata" then
		return "default"
	end

	return type( Value )	 
end