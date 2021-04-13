

object_text = class( object_base, function( self )
	object_base.init( self )

	self.Name = "text"
	self.ObjType = OBJECT_TYPE_TEXT
	--self.ParallaxK = { 1, 1 }

	self.Text = "text"
	self.TextAlign = 'left'
end)


function object_text:DrawData( Camera )
	if g_Editor then
		local X = self.ResultOffset[ 1 ] - math.floor( self.Size[ 1 ] / 2 )
		local Y = self.ResultOffset[ 2 ] - math.floor( self.Size[ 2 ] / 2 )
		local W = self.Size[ 1 ] * self.ResultScale
		local H = self.Size[ 2 ] * self.ResultScale

		love.graphics.printf( self.Text, X, Y, W, self.TextAlign )
	end
end


function object_text:Update( Delta )

end


function object_text:Load( FullName )
	self.MapDataName = FullName
	
	local FileName = "proj/" .. FullName
	self.MapData = table.read( FileName ) 

	LogE( "Loaded trigger " .. FullName, "oft" )
end


function object_text:DrawEditorObjRect( Camera, Obj )	
	local AlphaColor = 80 
	love.graphics.setColor( 20, 50, 100, AlphaColor )
	self:DrawEditorMapObjRects( Camera, Obj )	
end