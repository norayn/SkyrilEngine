

object_collision = class( object_base, function( self )
	object_base.init( self )

	self.Name = "collision"
	self.ObjType = OBJECT_TYPE_COLLISION
	--self.ParallaxK = { 1, 1 }

	self.MapData = nil
	self.MapDataName = nil	
end)


function object_collision:DrawData( Camera )
	if g_Editor then
		self:DrawEditorObjRect( Camera, self.MapData.RootObj )
	end
end


function object_collision:Update( Delta )

end


function object_collision:Load( FullName )
	if FullName then	
		self.MapDataName = FullName
		
		local FileName = "proj/" .. FullName
		self.MapData = table.read( FileName ) 

		LogE( "Loaded collision " .. FullName, "oft" )
	else
		MapObjRestoreAfterSave( self.MapData.RootObj ) 
		LogE( "Loaded collision from scene", "oft" )
	end
end


function object_collision:PrepareToSave()
	if self.MapDataName then
		self.MapData = nil
	end
	self.DynamicData = nil
end


function object_collision:DrawEditorObjRect( Camera, Obj )
	local AlphaColor = 80 
	love.graphics.setColor( 100, 50, 20, AlphaColor )
	self:DrawEditorMapObjRects( Camera, Obj )	
end