

object_animation = class( object_base, function( self )
	object_base.init( self )

	self.Name = "animation"
	self.ObjType = OBJECT_TYPE_ANIMATION
	--self.ParallaxK = { 1, 1 }

	self.MulColor = { 1, 1, 1, 1 }

	self.MapData = nil
	self.MapDataName = nil	
end)


function object_animation:DrawData( Camera )
	self:DrawDataObj( self.MapData.RootObj )
end


function object_animation:Update( Delta )
	self:UpdateAnimationObj( self.MapData.RootObj )
end


function object_animation:Load( FullName )
	self.MapDataName = FullName
	
	local FileName = "proj/" .. FullName
	self.MapData = table.read( FileName ) 

	LogE( "Loaded props " .. FullName, "oft" )
end


function object_animation:DrawDataObj( Obj )
	if not Obj.Visible then	return	end
	
	local X = Obj.GlobalPos[ 1 ] * self.ResultScale + self.ResultOffset[ 1 ] 
	local Y = Obj.GlobalPos[ 2 ] * self.ResultScale + self.ResultOffset[ 2 ] 
	local W = Obj.Size[ 1 ] * self.ResultScale
	local H = Obj.Size[ 2 ] * self.ResultScale

	if Obj.TexName ~= "" then --DRAW texture
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
		
		local QuadViewport = { Obj.MapQuad:getViewport() }
		local OrigPvtX, OrigPvtY = QuadViewport[ 3 ] * Obj.Pivot[ 1 ], QuadViewport[ 4 ] * Obj.Pivot[ 2 ]
		love.graphics.draw( Tex, Obj.MapQuad, X, Y, Obj.Rotate, StSlX, StSlY, OrigPvtX, OrigPvtY )
	end

	if Obj.Animation then --DRAW Animation
		love.graphics.setColor( 255 * self.MulColor[ 1 ] * Obj.MulColor[ 1 ], 
								255 * self.MulColor[ 2 ] * Obj.MulColor[ 2 ], 
								255 * self.MulColor[ 3 ] * Obj.MulColor[ 3 ], 
								255 * self.MulColor[ 4 ] * Obj.MulColor[ 4 ] )
		
		local Frame = Obj.Animation:GetCurrentFrame() 
		Tex = g_ResMgr:GetImage( Frame.TexName )
		local StSlX, StSlY = self.ResultScale, self.ResultScale			
	
		local OrigPvtX, OrigPvtY = Frame.TexRect[ 3 ] * Obj.Pivot[ 1 ], Frame.TexRect[ 4 ] * Obj.Pivot[ 2 ]	
		love.graphics.draw( Tex, Frame.Quad, X, Y, Obj.Rotate, StSlX, StSlY, OrigPvtX, OrigPvtY )
	end

	if #Obj.Childs > 0 then
		for _, child_object in pairs( Obj.Childs ) do
			self:DrawDataObj( child_object )
		end
	end
end


function object_animation:UpdateAnimationObj( Obj )
	if Obj.Animation then		
		Obj.Animation:Update( love.timer.getDelta() ) 
	end

	if #Obj.Childs > 0 then
		for _, child_object in pairs( Obj.Childs ) do
			self:UpdateAnimationObj( child_object )
		end
	end
end