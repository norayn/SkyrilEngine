camera = class( function( self )
	self.Name = "camera"

	self.WndOffset = { 0, 0 }
	self.Offset = { 0, 0 }
	
	--self.size = { 1024, 768 }
	self.Size = { 800, 600 }
	self.Scale = 1		
end)


function camera:SetWndPosAndOffset( WndPos, CamOffset ) 
	self.Size = { 800, 600 }
	self.WndOffset[ 1 ], self.WndOffset[ 2 ] = WndPos[ 1 ], WndPos[ 2 ]
	self.Offset[ 1 ], self.Offset[ 2 ] = CamOffset[ 1 ], CamOffset[ 2 ]
end


function camera:DrawEditorRect()
	local Pos = self.WndOffset
	local Size = Mul( self.Size, { self.Scale, self.Scale } )
	
	love.graphics.setColor( 150, 100, 0, 255 )
	love.graphics.rectangle( "line", Pos[ 1 ], Pos[ 2 ], Size[ 1 ], Size[ 2 ] )		
	love.graphics.rectangle( "line", Pos[ 1 ] - 3, Pos[ 2 ] - 3, Size[ 1 ] + 6, Size[ 2 ] + 6 )		
end

