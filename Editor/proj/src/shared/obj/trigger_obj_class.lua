

object_trigger = class( object_base, function( self )
	object_base.init( self )

	self.Name = "trigger"
	self.ObjType = OBJECT_TYPE_TRIGGER
	--self.ParallaxK = { 1, 1 }

	self.MapData = nil
	self.MapDataName = nil	
end)


function object_trigger:DrawData( Camera )
	if g_Editor then
		self:DrawEditorObjRect( Camera, self.MapData.RootObj )
	end
end


function object_trigger:Update( Delta )

end


function object_trigger:PrepareToSave()
	if self.MapDataName then
		self.MapData = nil
	end
	self.DynamicData = nil
end


function object_trigger:Load( FullName )
	if FullName then	
		self.MapDataName = FullName
		
		local FileName = "proj/" .. FullName
		self.MapData = table.read( FileName ) 

		LogE( "Loaded trigger " .. FullName, "oft" )
	else
		MapObjRestoreAfterSave( self.MapData.RootObj ) 
		LogE( "Loaded trigger from scene", "oft" )
	end
end


function object_trigger:DrawEditorObjRect( Camera, Obj )	
	local AlphaColor = 80 
	love.graphics.setColor( 20, 50, 100, AlphaColor )
	self:DrawEditorMapObjRects( Camera, Obj )	
end