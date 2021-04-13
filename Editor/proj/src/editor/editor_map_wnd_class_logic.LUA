

function editor_map_wnd_class:UpdateMode()
	if not self.SelectedObj then
		self.ObjEditHelper.Visible = false
		return
	end

	self.ObjEditHelper.Visible = true
	local Obj = self.SelectedObj

	if self.MouseSelectPresKeyDown then
		local StartCoord = self:GlobalCoorToSpriteCoord( self.MouseSelectPresCoord )
		local CX, CY = self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ]	

		if self.Mode == MAP_EDITOR_MODE_MOVE then
			local X = ( Obj.GlobalPos[ 1 ] + CX - StartCoord[ 1 ] )
			local Y = ( Obj.GlobalPos[ 2 ] + CY - StartCoord[ 2 ] )
			Obj:SetGlobalPos( { X, Y } )
			self.MouseSelectPresCoord[ 1 ], self.MouseSelectPresCoord[ 2 ] = love.mouse.getPosition()
		end
	 
		if self.Mode == MAP_EDITOR_MODE_SCALE then
			Obj.Size[ 1 ] = ( Obj.Size[ 1 ] + CX - StartCoord[ 1 ] )
			Obj.Size[ 2 ] = ( Obj.Size[ 2 ] + CY - StartCoord[ 2 ] )			
			self.MouseSelectPresCoord[ 1 ], self.MouseSelectPresCoord[ 2 ] = love.mouse.getPosition()
		end
	 
		if self.Mode == MAP_EDITOR_MODE_ROTATE then
			local R = 0 + ( ( CX - StartCoord[ 1 ] ) / 100 ) + ( ( CY - StartCoord[ 2 ] ) / 10000 )
			Obj.Rotate = Obj.Rotate + R			
			self.MouseSelectPresCoord[ 1 ], self.MouseSelectPresCoord[ 2 ] = love.mouse.getPosition()
		end
	end
		
	self.ObjEditHelper:SetPosData{
		Pos = Obj.GlobalPos,
		CameraScale = self.CameraScale,
		CameraOffset = self.CameraOffset,
		WndOffset = self.WorkAreaPos,
	}
end


function editor_map_wnd_class:SelectObject( Obj )	
	self.SelectedObj = Obj
end


function editor_map_wnd_class:MainClick()	
	if ( self.Mode == MAP_EDITOR_MODE_BRUSH or self.Mode == MAP_EDITOR_MODE_BRUSH_GRID ) then
		if SubTex[ g_Editor.AtlasEditor.SelectedSpriteName ] ~= nil then
			local Obj = map_obj( MAP_TYPE_SPRITE )
			self:MapSetTexFromAtlasWnd( Obj )
			Obj.Size[ 1 ] = SubTex[ g_Editor.AtlasEditor.SelectedSpriteName ].Coord[ 3 ]
			Obj.Size[ 2 ] = SubTex[ g_Editor.AtlasEditor.SelectedSpriteName ].Coord[ 4 ]

			if self.SelectedObj then
				self.SelectedObj:AddChild( Obj )
			else
				self.Map.RootObj:AddChild( Obj )
			end

			if self.Mode == MAP_EDITOR_MODE_BRUSH_GRID then
				local CoordX, CoordY = self:GetGridCoordCur()
				Obj:InitGlobalPos( { CoordX, CoordY } )
			else
				Obj:InitGlobalPos( self.CameraMouseOffset )
			end
		end
	else		
		self:SelectObject( self.ObjUnderCursor )	
	end	
end


function editor_map_wnd_class:MapSetTexFromAtlasWnd( Obj )
	local SubTexName = g_Editor.AtlasEditor.SelectedSpriteName
	local ImageName = g_Editor.AtlasEditor.SelectedFile
	
	if SubTex[ SubTexName ] == nil then
		g_Editor:ShowPopUpMsg( "no selekted tex" )
		return
	end

	if Obj ~= nil then
		if Obj.Type ~= MAP_TYPE_SPRITE then
			g_Editor:ShowPopUpMsg( "set tex available only for sprites" )
			return
		end
		
		Obj.TexName = ImageName
		Obj.SubTexName = SubTexName
		Obj.TexRect[ 1 ] = SubTex[ SubTexName ].Coord[ 1 ]
		Obj.TexRect[ 2 ] = SubTex[ SubTexName ].Coord[ 2 ]
		Obj.TexRect[ 3 ] = SubTex[ SubTexName ].Coord[ 3 ]
		Obj.TexRect[ 4 ] = SubTex[ SubTexName ].Coord[ 4 ]
		local Tex = g_ResMgr:GetImage( ImageName )
		Obj.EditorQuad = g_ResMgr:GethQuad( Tex, SubTex[ SubTexName ].Coord )
	end	
end


function editor_map_wnd_class:GetGridCoordCur()
		local Obj = self.SelectedObj
		local CoordX, CoordY = self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ]
		if not Obj then
			return CoordX, CoordY
		end

		local X, Y, W, H = Obj.GlobalPos[ 1 ], Obj.GlobalPos[ 2 ], Obj.Size[ 1 ], Obj.Size[ 2 ]		
		local OffsetX, OffsetY = X, Y
		
		CoordX = math.floor( ( CoordX - OffsetX ) / W )
		CoordY = math.floor( ( CoordY - OffsetY ) / H )
		return CoordX * W + OffsetX, CoordY * H + OffsetY
end


function editor_map_wnd_class:FileSave( FileToSave )
	self.Map.RootObj:PrepareToSave()
	table.save( self.Map, "proj/" .. FileToSave )
	MapObjRestoreAfterSave( self.Map.RootObj )
end


function editor_map_wnd_class:MapSave()
	if self.OpenFile == "" then
		g_Editor:ShowPopUpMsg( "no open file" )
		return
	end

	self:FileSave( string.sub( self.OpenFile, 1, -4 ) .. self.FileExtention )

	g_Editor:ShowPopUpMsg( "Save ok" )
	LogE( "Save " .. self.OpenFile )
end


function editor_map_wnd_class:MapLoad()
	if self.SelectedFile == "" then
		g_Editor:ShowPopUpMsg( "no selected file" )
		return
	end

	self.ObjParentTable = {}

	local FileName = "proj/" .. self.SelectedFile
	self.Map = table.read( FileName ) 

	MapObjRestoreAfterSave( self.Map.RootObj )
	self.OpenFile = self.SelectedFile
	
	LogE( "Load " .. self.OpenFile )
end


function editor_map_wnd_class:DelSelected()

	local Obj = self.SelectedObj
	if Obj and Obj:GetParent() then		
		if Obj == self.CopyedObj then	
			self.CopyedObj = nil
		end

		local ObjTable = Obj:GetParent().Childs

		for I = 1, #ObjTable do
			if ObjTable[ I ] == Obj then
				table.remove ( ObjTable, I )
				break
			end
		end

		self.SelectedObj = nil	
	else
		g_Editor:ShowPopUpMsg( "No selected obj" )	
	end	
end


function editor_map_wnd_class:ObjStepInTree( StepDirText )	
	local Obj = self.SelectedObj
	if Obj and Obj:GetParent() then		
		g_Editor:ObjStepInTree( {
			StepDirText = StepDirText,
			ObjTable = self.SelectedObj:GetParent().Childs,
			Obj = self.SelectedObj,
		} )
	else
		g_Editor:ShowPopUpMsg( "No selected obj" )	
	end	
end