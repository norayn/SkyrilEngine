map = class( function( self )
	self.Name = "map"

	self.Offset = { 0, 0 }
	self.Scale = 1
	self.Z = 1
			
	self.ResultOffset = { 0, 0 }		
	self.ResultScale = 1

	self.ParallaxK = { 1, 1 }

	self.MulColor = { 1, 1, 1, 1 }

	self.MapData = nil
	self.MapDataName = nil	

	self.EditorVisible = true
end)


function map:Draw( Camera )
	if not self.EditorVisible then
		return
	end	 

	local CameraOffset = Mul( self.ParallaxK, Camera.Offset )
	local MapOffset = Mul( self.Offset, { Camera.Scale, Camera.Scale } )
	self.ResultOffset = { 
		CameraOffset[ 1 ] + MapOffset[ 1 ] + Camera.WndOffset[ 1 ],
		CameraOffset[ 2 ] + MapOffset[ 2 ] + Camera.WndOffset[ 2 ],	}	

	self.ResultScale = Camera.Scale * self.Scale

	if	self.MapData then
		self:DrawObj( self.MapData.RootObj )
	end
end


function map:Update( Delta )

end


function map:Load( FullName )
	self.MapDataName = FullName
	
	local FileName = "proj/" .. FullName
	self.MapData = table.read( FileName ) 

	LogE( "Loaded map " .. FullName, "oft" )
end


function map:DrawObj( Obj )	
	local X = Obj.GlobalPos[ 1 ] * self.ResultScale + self.ResultOffset[ 1 ] 
	local Y = Obj.GlobalPos[ 2 ] * self.ResultScale + self.ResultOffset[ 2 ] 
	local W = Obj.Size[ 1 ] * self.ResultScale
	local H = Obj.Size[ 2 ] * self.ResultScale

	if Obj.TexName ~= "" then
		if Obj.MapQuad == nil then
			local Tex = g_ResMgr:GetImage( Obj.TexName )	
			Obj.MapQuad = g_ResMgr:GethQuad( Tex, Obj.TexRect )					
		end
				
		love.graphics.setColor( 255 * self.MulColor[ 1 ] * Obj.MulColor[ 1 ], 
								255 * self.MulColor[ 2 ] * Obj.MulColor[ 2 ], 
								255 * self.MulColor[ 3 ] * Obj.MulColor[ 3 ], 
								255 * self.MulColor[ 4 ] * Obj.MulColor[ 4 ] )
		local Tex = g_ResMgr:GetImage( Obj.TexName )			
		local StSlX, StSlY = Obj.Size[ 1 ] / Obj.TexRect[ 3 ] * self.ResultScale, Obj.Size[ 2 ] / Obj.TexRect[ 4 ] * self.ResultScale			
		--love.graphics.draw( Tex, Obj.MapQuad, X, Y, Obj.Rotate, StSlX , StSlY )
		local QuadViewport = { Obj.MapQuad:getViewport() }
		local OrigPvtX, OrigPvtY = QuadViewport[ 3 ] * Obj.Pivot[ 1 ], QuadViewport[ 4 ] * Obj.Pivot[ 2 ]
		love.graphics.draw( Tex, Obj.MapQuad, X, Y, Obj.Rotate, StSlX, StSlY, OrigPvtX, OrigPvtY )
	end

	if #Obj.Childs > 0 then
		for _, child_object in pairs( Obj.Childs ) do
			self:DrawObj( child_object )
		end
	end
end