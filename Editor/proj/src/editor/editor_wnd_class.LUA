
local TOOL_AREA_WIDTH = 300

editor_window = class( function( self )
	self.WndName = "New window"
	self.Visible = true
	self.CameraOffset = { 0, 0 }
	self.CameraScale = 1
	
	self.CameraEnableMove = true
	self.CameraEnableScale = true

	self.WorkAreaPos = { 0, 0 }
	self.ClearColor = { 0.1, 0.1, 0.1 }
	self.NoRenderAtlasByModal = false
	
	self.MouseSelectPresKeyDown = false
	self.MouseSelectPresCoord = { 0, 0 }
	self.MouseSelectRect = nil
	self.MouseMovePresKeyDown = false
	self.MouseMovePresCoord = { 0, 0 }
	self.MousePresMenyBtn = { 0, 0 }
	self.MouseLastCkickTime = 0
	self.CameraOffsetPres = { 0, 0 }
	self.CameraOwerWorkArea = false
	self.CameraMouseOffset = { 0, 0 }

	self.AreaCanvas = love.graphics.newCanvas( 1920, 1080 )
end)


function editor_window:Init()
	--to redefine
end
function editor_window:UpdateWnd()
	--to redefine	
end
function editor_window:ClickL()
	--to redefine
end
function editor_window:DoubleClickL()
	--to redefine
end
function editor_window:SelectRect()
	--to redefine
end
function editor_window:DrawWorkArea( WndPos )
	--to redefine
end
function editor_window:DrawContextMenu()
	--to redefine
end
function editor_window:Close()
	--to redefine
end


function editor_window:Update()
	local X, Y = love.mouse.getPosition()
	local AtlOfs = self.CameraOffset

	if self.CameraEnableMove and self.MouseMovePresKeyDown then
		AtlOfs[ 1 ] = self.CameraOffsetPres[ 1 ] + X - self.MouseMovePresCoord[ 1 ]
		AtlOfs[ 2 ] = self.CameraOffsetPres[ 2 ] + Y - self.MouseMovePresCoord[ 2 ]
	end

	if self.CameraEnableScale and self.CameraOwerWorkArea then
		local LocalX, LocalY = X - self.WorkAreaPos[ 1 ], Y - self.WorkAreaPos[ 2 ]

		if g_MouseWheelY > 0 then
			AtlOfs[ 1 ] = AtlOfs[ 1 ] - ( LocalX - AtlOfs[ 1 ] )
			AtlOfs[ 2 ] = AtlOfs[ 2 ] - ( LocalY - AtlOfs[ 2 ] )
			self.CameraScale = self.CameraScale * 2
		end
		
		if g_MouseWheelY < 0 then
			AtlOfs[ 1 ] = ( AtlOfs[ 1 ] - LocalX ) / 2 + LocalX
			AtlOfs[ 2 ] = ( AtlOfs[ 2 ] - LocalY ) / 2 + LocalY
			self.CameraScale = self.CameraScale / 2
		end
	end

	self.CameraMouseOffset = self:GetTexCoordCur()

	self:UpdateWnd()
end


function editor_window:Draw()
	if not self.Visible then
		return
	end
	local IsVisible, IsOpen = imgui.Begin( self.WndName, true )
	if not IsOpen then 
		self:Close()	
	end
	
	if IsVisible then
		imgui.PushStyleVar( "WindowPadding", 0, 0 )
		imgui.BeginChild( self.WndName .. "Child1", imgui.GetWindowContentRegionWidth() - TOOL_AREA_WIDTH, 0, true,
		 { "NoScrollbar", "NoScrollWithMouse" } );
			imgui.PopStyleVar()
			self:DrawAtlas()
			
			imgui.Image( self.AreaCanvas , self.AreaCanvas:getWidth(), self.AreaCanvas:getHeight() )
			self:DrawContextMenu()
		
		imgui.EndChild()
		
		imgui.SameLine();

		imgui.BeginChild( self.WndName .. "Child2", 0, 0, true );
			self:DrawParamPanel()		
		imgui.EndChild()

		imgui.End()
	else
		imgui.End()
    end
end


function editor_window:DrawAtlas()
	if self.NoRenderAtlasByModal then
		return
	end
	
	local WndX, WndY = imgui.GetWindowPos()
	local WndW, WndH = imgui.GetWindowSize()
	self.WorkAreaPos[ 1 ], self.WorkAreaPos[ 2 ] = WndX, WndY
		
	love.graphics.setCanvas( self.AreaCanvas )
		local Color = self.ClearColor
		love.graphics.setColor( Color[1] * 255, Color[2] * 255, Color[3] * 255, 255 )
		love.graphics.rectangle( "fill", 0, 0, WndW, WndH )
		--self:DrawWorkArea( self.WorkAreaPos )
		self:DrawWorkArea( { 0, 0 } )
	love.graphics.setCanvas()
	love.graphics.setColor( 255, 255, 255, 255 )
		
	self:WorkAreaMouseEvents()
end


function editor_window:DrawParamPanel()	
	local Status = nil
	
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );
		imgui.Text( "CameraScale: " .. self.CameraScale )
	end
	
	if ( imgui.CollapsingHeader( "Settings" ) ) then

		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3] = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3]);
	end
end


function editor_window:GlobalCoorToSpriteCoord( Coord )
	return { 
		math.floor( ( Coord[ 1 ] - self.WorkAreaPos[ 1 ] - self.CameraOffset[ 1 ] ) / self.CameraScale ),
		math.floor( ( Coord[ 2 ] - self.WorkAreaPos[ 2 ] - self.CameraOffset[ 2 ] ) / self.CameraScale ) 
	}
end


function editor_window:GetTexCoordCur()
	local CoordX, CoordY = love.mouse.getPosition()
	return self:GlobalCoorToSpriteCoord( { CoordX, CoordY } )
end


function editor_window:WorkAreaMouseEvents()
	if imgui.IsWindowHovered() then
		self.CameraOwerWorkArea = true

		if imgui.IsMouseClicked( 2 ) then
			self.MouseMovePresKeyDown = true
			self.MouseMovePresCoord[ 1 ], self.MouseMovePresCoord[ 2 ] = love.mouse.getPosition()
			self.CameraOffsetPres[ 1 ] = self.CameraOffset[ 1 ]
			self.CameraOffsetPres[ 2 ] = self.CameraOffset[ 2 ]
		end
		
		if imgui.IsMouseClicked( 0 ) then
			self.MouseSelectPresKeyDown = true
			self.MouseSelectPresCoord[ 1 ], self.MouseSelectPresCoord[ 2 ] = love.mouse.getPosition()
			
			local Mx, My = love.mouse.getPosition()
			local WndX, WndY = imgui.GetWindowPos()
			self.MouseSelectRect = { 
				Mx - WndX, 
				My - WndY, 
				0, 
				0 
			}
		end

		if imgui.IsMouseClicked( 1 ) then
			self.MousePresMenyBtn = self:GetTexCoordCur()
		end
	else
		self.CameraOwerWorkArea = false
	end

	if imgui.IsMouseReleased( 2 ) then
		self.MouseMovePresKeyDown = false
	end

	if imgui.IsMouseReleased( 0 ) then
		if self.MouseSelectPresKeyDown then
			local Mx, My = love.mouse.getPosition()
			if math.abs( self.MouseSelectPresCoord[ 1 ] - Mx ) < 3 and math.abs( self.MouseSelectPresCoord[ 2 ] - My ) < 3 then
				--clic				
				self.ClickL()
				self.MouseSelectRect = nil

				local Time = love.timer.getTime()
				if Time - self.MouseLastCkickTime < 0.22 then
					self.DoubleClickL()
				end
				self.MouseLastCkickTime = Time
			else
				--set selec rect
				self.SelectRect()
			end
		end				
		self.MouseSelectPresKeyDown = false
	end

	if self.MouseSelectPresKeyDown and self.MouseSelectRect then
		local Mx, My = love.mouse.getPosition()
		self.MouseSelectRect[ 3 ] = Mx - self.MouseSelectPresCoord[ 1 ] 
		self.MouseSelectRect[ 4 ] = My - self.MouseSelectPresCoord[ 2 ] 		
	end 
end
