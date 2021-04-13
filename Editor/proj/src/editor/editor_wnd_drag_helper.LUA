wnd_drag_helper = class( function( self )
	self.Visible = true	
	self.Pos = { 100, 100 }
	self.CurOffset = { 0, 0 }
	self.MouseIsDown = false
	self.MouseOverIndex = 0
	self.MouseDownIndex = 0
	self.MouseDownPos = { 0, 0 }

	
	self.Helpers = {}
	--self.Helpers[ 1 ] = {
	--	Offset = { 0, 0 },
	--	Size = { 20, 20 },
	--	Text = "M",
	--	MoveFunc = function( Offset )
	--		self.Pos[ 1 ] = self.Pos[ 1 ] + Offset[ 1 ]
	--		self.Pos[ 2 ] = self.Pos[ 2 ] + Offset[ 2 ]
	--	end,
	--}
	--self.Helpers[ 2 ] = {
	--	Offset = { 30, 0 },
	--	Size = { 20, 20 },
	--	Text = "S",
	--	MoveFunc = function( Offset )
	--		self.Helpers[ 1 ].Offset[ 1 ] = self.Helpers[ 1 ].Offset[ 1 ] + Offset[ 1 ]
	--		self.Helpers[ 1 ].Offset[ 2 ] = self.Helpers[ 1 ].Offset[ 2 ] + Offset[ 2 ]
	--	end,
	--}
end)


function wnd_drag_helper:Draw()
	if not self.Visible then
		return
	end
	
	self:HelperUdate()
	
	for I = 1, #self.Helpers do
		local Pos = { self.Helpers[ I ].Offset[ 1 ] + self.Pos[ 1 ], self.Helpers[ I ].Offset[ 2 ] + self.Pos[ 2 ] }
		local UnderMouse = false
		if self.MouseOverIndex == I or self.MouseDownIndex == I then
			UnderMouse = true
		end

		self:DrawHelperObj( { 
			Pos = Pos, 
			Size = self.Helpers[ I ].Size, 
			Text = self.Helpers[ I ].Text,
			UnderMouse = UnderMouse } )
	end	
end


function wnd_drag_helper:DrawHelperObj( Param )
	local Pos = Param.Pos
	local Size = Param.Size
	local MouseOwerControl = Param.UnderMouse

	love.graphics.setColor( 122, 122, 122, 255 )
	if MouseOwerControl then
		love.graphics.rectangle( "line", Pos[ 1 ], Pos[ 2 ], Size[ 1 ], Size[ 2 ] )
	else
		love.graphics.rectangle( "fill", Pos[ 1 ], Pos[ 2 ], Size[ 1 ], Size[ 2 ] )
	end
		
	love.graphics.setColor( 44, 44, 44, 255 )
	love.graphics.print( Param.Text, Pos[ 1 ] + 5, Pos[ 2 ] + 3 )	
end


function wnd_drag_helper:HelperUdate()
	self.MouseOverIndex = 0

	for I = 1, #self.Helpers do
		local Pos = { self.Helpers[ I ].Offset[ 1 ] + self.Pos[ 1 ], self.Helpers[ I ].Offset[ 2 ] + self.Pos[ 2 ] }
		local Size = self.Helpers[ I ].Size		
		local MouseOwerControl = false
		local CurPos = { love.mouse.getPosition() }
		CurPos[ 1 ] = CurPos[ 1 ] - self.CurOffset[ 1 ]
		CurPos[ 2 ] = CurPos[ 2 ] - self.CurOffset[ 2 ]

		if CurPos[ 1 ] > Pos[ 1 ] and CurPos[ 1 ] < Pos[ 1 ] + Size[ 1 ] 
		and CurPos[ 2 ] > Pos[ 2 ] and CurPos[ 2 ] < Pos[ 2 ] + Size[ 2 ] then
			MouseOwerControl = true
			self.MouseOverIndex = I
		end

		if love.mouse.isDown( 1 ) then
			if MouseOwerControl and self.MouseDownIndex == 0 and not self.MouseIsDown then
				self.MouseDownIndex = I
				self.MouseDownPos = CurPos
			end

			if self.MouseDownIndex == I then				
				local MouseOffset = { CurPos[ 1 ] - self.MouseDownPos[ 1 ], CurPos[ 2 ] - self.MouseDownPos[ 2 ] }				
				self.MouseDownPos = CurPos

				if self.Helpers[ I ].MoveFunc and ( MouseOffset[ 1 ] ~= 0 or MouseOffset[ 2 ] ~= 0 )  then
					self.Helpers[ I ].MoveFunc( MouseOffset )
				end
			end
		else
			if self.MouseDownIndex ~= 0 then
				self.MouseDownIndex = 0
			end
		end

	end		

	if love.mouse.isDown( 1 ) then
		self.MouseIsDown = true
	else
	
		self.MouseIsDown = false
	end	
end


function wnd_drag_helper:SetPosData( Param )
	local X = ( Param.Pos[ 1 ] * Param.CameraScale + Param.CameraOffset[ 1 ] )
	local Y = ( Param.Pos[ 2 ] * Param.CameraScale + Param.CameraOffset[ 2 ] )
	self.Pos = { X, Y }
	self.CurOffset = { Param.WndOffset[ 1 ], Param.WndOffset[ 2 ] }
end