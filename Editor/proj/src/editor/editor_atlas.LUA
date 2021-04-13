
local TOOL_AREA_WIDTH = 300

local AtlasEditor = {}
g_Editor.AtlasEditor = AtlasEditor

AtlasEditor.AtlasImg = nil

AtlasEditor.Visible = false
AtlasEditor.CameraOffset = { 0, 0 }
AtlasEditor.AtlasScale = 1

AtlasEditor.WndPos = { 0, 0 }
AtlasEditor.ReplaceAlphaColor = false
AtlasEditor.ClearColor = { 0.1, 0.1, 0.1 }
--AtlasEditor.NoRenderAtlasByModal = false

AtlasEditor.MouseSelectPresKeyDown = false
AtlasEditor.MouseSelectPresCoord = { 0, 0 }
AtlasEditor.MouseSelectRect = nil
AtlasEditor.MouseMovePresKeyDown = false
AtlasEditor.MouseMovePresCoord = { 0, 0 }
AtlasEditor.CameraOffsetPres = { 0, 0 }
AtlasEditor.CameraOwerAtlas = false
AtlasEditor.CameraMouseOffset = { 0, 0 }

AtlasEditor.NameOfSpriteUnderCursor = nil
AtlasEditor.SelectedSpriteName = nil
AtlasEditor.EditedSpriteName = ""

AtlasEditor.SelectedFile = "no atlas"
AtlasEditor.CreateGridParam = {
	StartPos = { 0, 0 },
	CellSize = { 10, 10 },
	Border = { 0, 0 },
	ColinmsRows = { 5, 1 },
	Count = 99,
	Name = "cell_",
	IsShowPreview = false,
}

function AtlasEditor:Init()
	self.AreaCanvas = love.graphics.newCanvas( 1920, 1080 )

	self:LoadAtlas( "res/test/interier_01.tex" )
	LogE( "AtlasEditor ready", "atn" )
end


function AtlasEditor:LoadAtlas( ImagePatch )
	self:SaveAtlas()
	
	self.NameOfSpriteUnderCursor = nil
	self.SelectedSpriteName = nil
	self.EditedSpriteName = ""

	local FileName = string.sub( ImagePatch, 1, -4 )
	local Extencion = "tga"
	if love.filesystem.exists( FileName .. "png" ) then Extencion = "png" end

	self.SelectedFile = FileName .. Extencion

	if love.filesystem.exists( FileName .. "tex" ) then
		dofile( "proj/" .. FileName .. "tex" )
	else
		SubTex = {}
	end
	self.AtlasImg = love.graphics.newImage( self.SelectedFile )	

end


function AtlasEditor:SaveAtlas()
	if not SubTex then
		return
	else
		local IsEmpty = true
		for k, v in pairsByKeys( SubTex ) do
			if v then 
				IsEmpty = false
				break
			end
		end
		
		if IsEmpty then
			return	
		end		
	end
	
	local FileName = "proj/" .. string.sub( self.SelectedFile, 1, -4 ) .. "tex"
	
	local TexFile, err = io.open( string.gsub( FileName, '/', '\\' ),"w"  )

	TexFile:write( "SubTex = {" .. "\n" )
	for k, v in pairsByKeys( SubTex ) do
		TexFile:write( "\t" .. k .. "\t\t\t\t\t\t\t\t" .. "= { Coord = { " .. v.Coord[ 1 ] .. ", " .. v.Coord[ 2 ] .. ", " .. v.Coord[ 3 ] .. ", " .. v.Coord[ 4 ] .. " } }," .. "\n" )
	end
	TexFile:write( "}" .. "\n" )

	TexFile:close()
	LogE( "Save atlas " .. FileName )
end


function AtlasEditor:Update()
	local X, Y = love.mouse.getPosition()
	local AtlOfs = self.CameraOffset

	if self.MouseMovePresKeyDown then
		AtlOfs[ 1 ] = self.CameraOffsetPres[ 1 ] + X - self.MouseMovePresCoord[ 1 ]
		AtlOfs[ 2 ] = self.CameraOffsetPres[ 2 ] + Y - self.MouseMovePresCoord[ 2 ]
	end

	self.NameOfSpriteUnderCursor = nil
	if self.CameraOwerAtlas then
		local LocalX, LocalY = X - self.WndPos[ 1 ], Y - self.WndPos[ 2 ]

		if g_MouseWheelY > 0 then
			AtlOfs[ 1 ] = AtlOfs[ 1 ] - ( LocalX - AtlOfs[ 1 ] )
			AtlOfs[ 2 ] = AtlOfs[ 2 ] - ( LocalY - AtlOfs[ 2 ] )
			self.AtlasScale = self.AtlasScale * 2
		end
		
		if g_MouseWheelY < 0 then
			AtlOfs[ 1 ] = ( AtlOfs[ 1 ] - LocalX ) / 2 + LocalX
			AtlOfs[ 2 ] = ( AtlOfs[ 2 ] - LocalY ) / 2 + LocalY
			self.AtlasScale = self.AtlasScale / 2
		end	
			
		local CoordX, CoordY = self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ]	
		for k, v in pairs( SubTex ) do
		    if CoordX >= v.Coord[ 1 ] and CoordX < v.Coord[ 1 ] + v.Coord[ 3 ] and CoordY >= v.Coord[ 2 ] and CoordY < v.Coord[ 2 ] + v.Coord[ 4 ] then
				self.NameOfSpriteUnderCursor = k
				break
			end
		end
	end
end


function AtlasEditor:GlobalCoorToSpriteCoord( Coord )
	return { 
		math.floor( ( Coord[ 1 ] - self.CameraOffset[ 1 ] ) / self.AtlasScale ),
		math.floor( ( Coord[ 2 ] - self.CameraOffset[ 2 ] ) / self.AtlasScale ) 
	}
end


function AtlasEditor:GetTexCoordCur()
 	local WndX, WndY = imgui.GetWindowPos()
	local CoordX, CoordY = love.mouse.getPosition()
	return AtlasEditor:GlobalCoorToSpriteCoord( { CoordX - WndX, CoordY - WndY } )
end


function AtlasEditor:Draw()
	if not self.Visible then
		return
	end
	local IsVisible, IsOpen = imgui.Begin( "Atlas Editor", true )
	if not IsOpen then 
		self.Visible = false
	end
	
	if IsVisible then
		self.WndPos[ 1 ], self.WndPos[ 2 ] = imgui.GetWindowPos()
		imgui.PushStyleVar( "WindowPadding", 0, 0 )
		imgui.BeginChild( "AtlasEditorChild1", imgui.GetWindowContentRegionWidth() - TOOL_AREA_WIDTH, 0, true,
		 { "NoScrollbar", "NoScrollWithMouse" } );
			imgui.PopStyleVar()
			self:DrawAtlas()
			imgui.Image( self.AreaCanvas , self.AreaCanvas:getWidth(), self.AreaCanvas:getHeight() )		
				
		imgui.EndChild()

		imgui.SameLine();

		imgui.BeginChild( "AtlasEditorChild2", 0, 0, true );
		AtlasEditor:DrawParamPanel()		
		imgui.EndChild()

		imgui.End()
	else
		imgui.End()
    end
end


function AtlasEditor:DrawWorkArea( WndPos )
	if self.ReplaceAlphaColor then 
		love.graphics.setBlendMode( "replace" ) 
	end

	local WndX, WndY = 0, 0
	love.graphics.setColor( 255, 255, 255, 255 )
	love.graphics.draw( self.AtlasImg, 
		WndX + self.CameraOffset[ 1 ], 
		WndY + self.CameraOffset[ 2 ], 
		0, self.AtlasScale, self.AtlasScale )
	love.graphics.setBlendMode( "alpha" )
	
	if self.SelectedSpriteName then
		love.graphics.setColor( 255, 255, 255, 155 )
		AtlasEditor:DrawRectOnTexByName( self.SelectedSpriteName, { WndX, WndY } )
	end
	
	if self.NameOfSpriteUnderCursor then
		love.graphics.setColor( 255, 255, 111, 155 )
		AtlasEditor:DrawRectOnTexByName( self.NameOfSpriteUnderCursor, { WndX, WndY } )
	end
	
	if self.MouseSelectRect then
		love.graphics.setColor( 25, 25, 111, 155 )
		love.graphics.rectangle( "fill", self.MouseSelectRect[ 1 ] + WndX, self.MouseSelectRect[ 2 ] + WndY, 
			self.MouseSelectRect[ 3 ], self.MouseSelectRect[ 4 ] )
	end

	if self.CreateGridParam.IsShowPreview then
		love.graphics.setColor( 111, 25, 111, 155 )		
		local CellInd = 0
		local Crg = self.CreateGridParam
		for Y = 0, Crg.ColinmsRows[ 2 ] - 1 do
			for X = 0, Crg.ColinmsRows[ 1 ] - 1 do
				CellInd = CellInd + 1
				local StartPosX = ( Crg.CellSize[ 1 ] * X ) + ( Crg.Border[ 1 ] * X ) + Crg.StartPos[ 1 ]
				local StartPosY = ( Crg.CellSize[ 2 ] * Y ) + ( Crg.Border[ 2 ] * Y ) + Crg.StartPos[ 2 ]
				if CellInd <= Crg.Count then
					self:DrawRectOnTex( { StartPosX, StartPosY, Crg.CellSize[ 1 ], Crg.CellSize[ 2 ] }, { WndX, WndY } )
				end
			end
		end
	end
end


function AtlasEditor:DrawAtlas()
	if self.NoRenderAtlasByModal then
		return
	end
	
	local WndX, WndY = imgui.GetWindowPos()
	local WndW, WndH = imgui.GetWindowSize()
	
	love.graphics.setCanvas( self.AreaCanvas )
		local Color = self.ClearColor
		love.graphics.setColor( Color[1] * 255, Color[2] * 255, Color[3] * 255, 255 )
		love.graphics.rectangle( "fill", 0, 0, WndW, WndH )
		self:DrawWorkArea( { 0, 0 } )
	love.graphics.setCanvas()
	love.graphics.setColor( 255, 255, 255, 255 )

	AtlasEditor:AtlasMouseEvents()
	self.CameraMouseOffset = AtlasEditor:GetTexCoordCur()
end


function AtlasEditor:AtlasMouseEvents()
	if imgui.IsWindowHovered() then
		self.CameraOwerAtlas = true

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
	else
		self.CameraOwerAtlas = false
	end

	if imgui.IsMouseReleased( 2 ) then
		self.MouseMovePresKeyDown = false
	end

	if imgui.IsMouseReleased( 0 ) then
		if self.MouseSelectPresKeyDown then
			--self.MouseSelectPresKeyDown = false
			local Mx, My = love.mouse.getPosition()
			if self.MouseSelectPresCoord[ 1 ] == Mx and self.MouseSelectPresCoord[ 2 ] == My then
				--clic
				AtlasEditor:SelectSpriteByName( self.NameOfSpriteUnderCursor )
				--reset selec rect
				self.MouseSelectRect = nil
			else
				--set selec rect
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


function AtlasEditor:DrawParamPanel()	
	local Status = nil
	self.comboSelection = 2
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );

		imgui.Text( "SelectedFile: " .. ( self.SelectedFile or "" ) );
		imgui.Text( "SpriteUnderCursor: " .. ( self.NameOfSpriteUnderCursor or "" ) );		
	end

	AtlasEditor:DrawParamPanelSprites()

	if ( imgui.CollapsingHeader( "Param" ) ) then
		local status
		--imgui.Text("With border")
		status, self.EditedSpriteName = imgui.InputText( "Rect name", self.EditedSpriteName, 40 );

		local Rect = { 0, 0, 0, 0 }
		if self.SelectedSpriteName then
			Rect = SubTex[ self.SelectedSpriteName ].Coord
		end

		imgui.PushItemWidth( imgui.GetWindowContentRegionWidth() / 2 - 10 );
		status, Rect[ 1 ] = imgui.DragInt("##Pos X", Rect[ 1 ], 1 , -99999, 99999, "Pos X = %.0f" )
		imgui.SameLine()
		status, Rect[ 2 ] = imgui.DragInt("##Pos Y", Rect[ 2 ], 1 , -99999, 99999, "Pos Y = %.0f" )
		
		status, Rect[ 3 ] = imgui.DragInt("##Size X", Rect[ 3 ], 1 , -99999, 99999, "Size X = %.0f" )
		imgui.SameLine()
		status, Rect[ 4 ] = imgui.DragInt("##Size Y", Rect[ 4 ], 1 , -99999, 99999, "Size Y = %.0f" )

		--self.NoRenderAtlasByModal = false

		if imgui.Button("Create new rect") then
			if not self.MouseSelectRect or self.EditedSpriteName == "" or self.SelectedSpriteName then
				g_Editor:ShowPopUpMsg( "No select region or select sprite or name empty or name already use" )
			else
				local SelRect = self.MouseSelectRect
				local StartPos = AtlasEditor:GlobalCoorToSpriteCoord( { SelRect[ 1 ], SelRect[ 2 ] } )
				local EndPos = AtlasEditor:GlobalCoorToSpriteCoord( { SelRect[ 1 ] + SelRect[ 3 ], SelRect[ 2 ] + SelRect[ 4 ] } )
				if StartPos[ 1 ] > EndPos[ 1 ] then StartPos[ 1 ], EndPos[ 1 ] = EndPos[ 1 ], StartPos[ 1 ]	end
				if StartPos[ 2 ] > EndPos[ 2 ] then StartPos[ 2 ], EndPos[ 2 ] = EndPos[ 2 ], StartPos[ 2 ]	end
				local W, H = EndPos[ 1 ] - StartPos[ 1 ] , EndPos[ 2 ] - StartPos[ 2 ] 
				SubTex[ self.EditedSpriteName ] = { Coord = { StartPos[ 1 ], StartPos[ 2 ], W, H } }
				AtlasEditor:SelectSpriteByName( self.EditedSpriteName )
			end
		end

		imgui.SameLine()
		if imgui.Button("Rename rect") then
			if self.EditedSpriteName == ""  or SubTex[ self.EditedSpriteName ] or not self.SelectedSpriteName then
				g_Editor:ShowPopUpMsg( "No obj or name empty or name already use" )
			else
				SubTex[ self.EditedSpriteName ] = SubTex[ self.SelectedSpriteName ]
				SubTex[ self.SelectedSpriteName ] = nil
				AtlasEditor:SelectSpriteByName( self.EditedSpriteName )
			end
		end

		imgui.SameLine()
		if imgui.Button("Del rect") then
			SubTex[ self.SelectedSpriteName ] = nil
			self.SelectedSpriteName = nil
		end
	end

	if ( imgui.CollapsingHeader( "Create sprites grid" ) ) then
		local status
		local Crg = self.CreateGridParam		
		status, Crg.Name = imgui.InputText( "Base name", Crg.Name, 40 );

		imgui.PushItemWidth( imgui.GetWindowContentRegionWidth() / 2 - 10 );
		status, Crg.StartPos[ 1 ] = imgui.DragInt("##StartPos X", Crg.StartPos[ 1 ], 1 , -99999, 99999, "StartPos X = %.0f" )
		imgui.SameLine()
		status, Crg.StartPos[ 2 ] = imgui.DragInt("##StartPos Y", Crg.StartPos[ 2 ], 1 , -99999, 99999, "StartPos Y = %.0f" )		

		status, Crg.CellSize[ 1 ] = imgui.DragInt("##CellSize X", Crg.CellSize[ 1 ], 1 , 1, 9999, "CellSize X = %.0f" )
		imgui.SameLine()
		status, Crg.CellSize[ 2 ] = imgui.DragInt("##CellSize Y", Crg.CellSize[ 2 ], 1 , 1, 9999, "CellSize Y = %.0f" )		

		status, Crg.Border[ 1 ] = imgui.DragInt("##Border X", Crg.Border[ 1 ], 1 , -999, 999, "Border X = %.0f" )
		imgui.SameLine()
		status, Crg.Border[ 2 ] = imgui.DragInt("##Border Y", Crg.Border[ 2 ], 1 , -999, 999, "Border Y = %.0f" )		

		status, Crg.ColinmsRows[ 1 ] = imgui.DragInt("##ColunmsRows X", Crg.ColinmsRows[ 1 ], 1 , 1, 999, "Columns = %.0f" )
		imgui.SameLine()
		status, Crg.ColinmsRows[ 2 ] = imgui.DragInt("##ColinmsRows Y", Crg.ColinmsRows[ 2 ], 1 , 1, 999, "Rows = %.0f" )		

		status, Crg.Count = imgui.DragInt("##Count", Crg.Count, 1 , -999, 999, "max cells = %.0f" )
		imgui.SameLine()
		if imgui.Checkbox( "ShowPreview", Crg.IsShowPreview ) then
			Crg.IsShowPreview = not Crg.IsShowPreview
		end

		if imgui.Button("Create sprite grid") then
			local CellInd = 0
			for Y = 0, Crg.ColinmsRows[ 2 ] - 1 do
				for X = 0, Crg.ColinmsRows[ 1 ] - 1 do
					CellInd = CellInd + 1
					local StartPosX = ( Crg.CellSize[ 1 ] * X ) + ( Crg.Border[ 1 ] * X ) + Crg.StartPos[ 1 ]
					local StartPosY = ( Crg.CellSize[ 2 ] * Y ) + ( Crg.Border[ 2 ] * Y ) + Crg.StartPos[ 2 ]
					if CellInd <= Crg.Count then
						SubTex[ Crg.Name .. CellInd ] = { Coord = { StartPosX, StartPosY, Crg.CellSize[ 1 ], Crg.CellSize[ 2 ] } }
					end
				end
			end

			Crg.IsShowPreview = false
		end
	end

	g_Editor.FileSustem:DrawFilesTree( { 
		WndName		= "Atlas files",
		Filters		= { "tex" }, 
		OpenFile	= function( Info )
			self:LoadAtlas( Info.FullPatch )
		end, 
	} )	

	if ( imgui.CollapsingHeader( "Settings" ) ) then
		if imgui.Checkbox("ReplaceAlphaColor", self.ReplaceAlphaColor ) then
			self.ReplaceAlphaColor = not self.ReplaceAlphaColor
		end

		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3] = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3]);
	end
end


function AtlasEditor:DrawParamPanelSprites()	
	if ( imgui.CollapsingHeader( "Sprites" ) ) then		
		--Status, self.comboSelection = imgui.ListBox("Combo", self.comboSelection, { "combo1", "combo2", "combo3", "combo4" }, 4);

		imgui.BeginChild( "AtlasSpritesTree", 0, -200, true );-----
		
		local node_clicked, node_open
		local use_flags

			-- Increase spacing to differentiate leaves from expanded contents.
		imgui.PushStyleVar("IndentSpacing", imgui.GetFontSize()*0.5)
		
		for k, v in pairsByKeys( SubTex ) do
			local has_children = false
			if has_children then
				use_flags = { "OpenOnArrow", "OpenOnDoubleClick" }
			else
				use_flags = { "Leaf", "NoTreePushOnOpen" }
			end
			
		    if k == self.SelectedSpriteName then
				table.insert( use_flags, "Selected" )
			end
			
			node_open = imgui.TreeNodeEx( k, use_flags )
			node_clicked = imgui.IsItemClicked()

			if node_clicked then
				AtlasEditor:SelectSpriteByName( k )
			end
		end
		
		imgui.PopStyleVar()
		imgui.EndChild()-----
	end
end

function AtlasEditor:DrawRectOnTex( Rect, Offset )	
	local X = ( Rect[ 1 ] ) * self.AtlasScale + Offset[ 1 ] 
	local Y = ( Rect[ 2 ] ) * self.AtlasScale + Offset[ 2 ] 
	local W = Rect[ 3 ] * self.AtlasScale
	local H = Rect[ 4 ] * self.AtlasScale
	love.graphics.rectangle( "line", X + self.CameraOffset[ 1 ], Y + self.CameraOffset[ 2 ], W, H )
end


function AtlasEditor:DrawRectOnTexByName( SubTexName, Offset )
	if SubTexName == nil then return end
	if not Offset then 	Offset = { 0, 0 } end

	self:DrawRectOnTex( SubTex[ SubTexName ].Coord, Offset )	
end


function AtlasEditor:SelectSpriteByName( Name )
	self.SelectedSpriteName = Name
	self.EditedSpriteName = Name or self.EditedSpriteName
end