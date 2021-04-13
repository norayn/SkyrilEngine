MAP_EDITOR_MODE_SELECT = 1
MAP_EDITOR_MODE_MOVE = 2
MAP_EDITOR_MODE_SCALE = 3
MAP_EDITOR_MODE_ROTATE = 4
MAP_EDITOR_MODE_BRUSH = 5
MAP_EDITOR_MODE_BRUSH_GRID = 6
MAP_EDITOR_MODE_COUNT = 6


require( "src.editor.editor_wnd_class" )
require( "src.editor.editor_wnd_drag_helper" )


editor_map_wnd_class = class( editor_window, function( self )
	editor_window.init( self )
	
	self.WndName = "type Editor"
	self.Map = {}
	
	self.ObjUnderCursor = nil
	self.SelectedObj = nil
	self.CopyedObj = nil
	self.Mode = MAP_EDITOR_MODE_SELECT
	self.ShowRects = true
	self.ShowLayerRects = true
	
	self.OpenFile = ""
	self.SelectedFile = ""
	self.FileExtention = "map"
	self.IsSceneLinkMode = false
	
	self.ObjParentTable = {}

	self.ObjEditHelper = wnd_drag_helper()

	self.ObjEditHelper.Helpers[ 1 ] = {
		Offset = { 0, -22 },
		Size = { 20, 20 },
		Text = "M",
		MoveFunc = function( Offset )
			if self.SelectedObj then
				self.SelectedObj:SetGlobalPos( { 
					self.SelectedObj.GlobalPos[ 1 ] + ( Offset[ 1 ] / self.CameraScale ), 
					self.SelectedObj.GlobalPos[ 2 ] + ( Offset[ 2 ] / self.CameraScale ) } )
			end
		end,
	}
	self.ObjEditHelper.Helpers[ 2 ] = {
		Offset = { 30, -22 },
		Size = { 20, 20 },
		Text = "S",
		MoveFunc = function( Offset )
			if self.SelectedObj then
				self.SelectedObj.Size = { 
					self.SelectedObj.Size[ 1 ] + ( Offset[ 1 ] / self.CameraScale ), 
					self.SelectedObj.Size[ 2 ] + ( Offset[ 2 ] / self.CameraScale ) }
			end
		end,
	}
	self.ObjEditHelper.Helpers[ 3 ] = {
		Offset = { 60, -22 },
		Size = { 20, 20 },
		Text = "R",
		MoveFunc = function( Offset )
			if self.SelectedObj then
				local Rotate = self.SelectedObj.Rotate / math.pi * 180
				self.SelectedObj.Rotate = ( Rotate + Offset[ 2 ] ) / 180 * math.pi
			end
		end,
	}
end)


require( "src.editor.editor_map_wnd_class_logic" )


function editor_map_wnd_class:Init()
	LogE( "editor_map_wnd_class", "wrn" )
end


function editor_map_wnd_class:UpdateWnd()
	self:UpdateMode()
end


function editor_map_wnd_class:DrawAngleRect( Obj, Mode, X, Y, W, H )
	local PvtX, PvtY = Obj.Size[ 1 ] * Obj.Pivot[ 1 ] * self.CameraScale, Obj.Size[ 2 ] * Obj.Pivot[ 2 ] * self.CameraScale
	local P1 = RotatePoint( { 0 - PvtX, 0 - PvtY }, Obj.Rotate )
	local P2 = RotatePoint( { W - PvtX, 0 - PvtY }, Obj.Rotate )
	local P3 = RotatePoint( { W - PvtX, H - PvtY }, Obj.Rotate )
	local P4 = RotatePoint( { 0 - PvtX, H - PvtY }, Obj.Rotate )
	
	local Vertices = { 
		P1[ 1 ] + self.CameraOffset[ 1 ] + X, P1[ 2 ] + self.CameraOffset[ 2 ] + Y,
		P2[ 1 ] + self.CameraOffset[ 1 ] + X, P2[ 2 ] + self.CameraOffset[ 2 ] + Y,
		P3[ 1 ] + self.CameraOffset[ 1 ] + X, P3[ 2 ] + self.CameraOffset[ 2 ] + Y,
		P4[ 1 ] + self.CameraOffset[ 1 ] + X, P4[ 2 ] + self.CameraOffset[ 2 ] + Y,
	}

	love.graphics.polygon( Mode, Vertices )
end


function editor_map_wnd_class:DrawWorkArea( WndPos )
	self.ObjUnderCursor = nil
	self:DrawWorkAreaObj( self.Map.RootObj, { 0, 0 } )

	----------------------MAP_EDITOR_MODE_BRUSH-    -MAP_EDITOR_MODE_GRID_BRUSH
	if ( self.Mode == MAP_EDITOR_MODE_BRUSH or self.Mode == MAP_EDITOR_MODE_BRUSH_GRID ) 
	and SubTex[ g_Editor.AtlasEditor.SelectedSpriteName ] ~= nil then
		love.graphics.setColor( 255, 255, 255, 155 )
		
		local CoordX, CoordY = self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ]
		if self.Mode == MAP_EDITOR_MODE_BRUSH_GRID then
			CoordX, CoordY = self:GetGridCoordCur()
		end

		local TexName = g_Editor.AtlasEditor.SelectedFile
		local Tex = g_ResMgr:GetImage( TexName )
		local TexRect = SubTex[ g_Editor.AtlasEditor.SelectedSpriteName ].Coord					
		local Quad = g_ResMgr:GethQuad( Tex, TexRect )	
		local QuadViewport = { Quad:getViewport() }
		local OrigPvtX, OrigPvtY = QuadViewport[ 3 ] * 0.5, QuadViewport[ 4 ] * 0.5

		local X = CoordX * self.CameraScale - OrigPvtX
		local Y = CoordY * self.CameraScale - OrigPvtY
		love.graphics.draw( Tex, Quad, X + self.CameraOffset[ 1 ], Y + self.CameraOffset[ 2 ], 0, self.CameraScale, self.CameraScale )
		love.graphics.setColor( 255, 255, 255, 255 )
	end

	self.ObjEditHelper:Draw()
end


function editor_map_wnd_class:DrawWorkAreaObj( Obj, ParentPos )
	if not Obj.EditorVisible then
		return
	end	 

	Obj.GlobalPos = { Obj.LocalPos[ 1 ] + ParentPos[ 1 ], Obj.LocalPos[ 2 ] + ParentPos[ 2 ] }
	local X = Obj.GlobalPos[ 1 ] * self.CameraScale
	local Y = Obj.GlobalPos[ 2 ] * self.CameraScale
	local W = Obj.Size[ 1 ] * self.CameraScale
	local H = Obj.Size[ 2 ] * self.CameraScale

	if ( self.ShowRects and Obj.Type ~= MAP_TYPE_LAYER ) 
		or ( self.ShowLayerRects and Obj.Type == MAP_TYPE_LAYER ) 
		or Obj == self.SelectedObj then
		local RectType, AlphaColor = "line", 180 
		if Obj.Type == MAP_TYPE_LAYER then
			RectType, AlphaColor = "fill", 20 
		end

		if Obj == self.SelectedObj then
			love.graphics.setColor( 90, 255, 90, AlphaColor )		
		else
			love.graphics.setColor( 255, 255, 255, AlphaColor )
		end	

		if not Obj.Rotate or Obj.Rotate == 0 then
			local PvtOffsetX, PvtOffsetY = Obj.Size[ 1 ] * Obj.Pivot[ 1 ] * self.CameraScale, Obj.Size[ 2 ] * Obj.Pivot[ 2 ] * self.CameraScale
			love.graphics.rectangle( RectType, X + self.CameraOffset[ 1 ] - PvtOffsetX, Y + self.CameraOffset[ 2 ] - PvtOffsetY, W, H )		
		else
			self:DrawAngleRect( Obj, RectType, X, Y, W, H )
		end
	end
					
	if Obj:OnObjEx( self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] ) then
		self.ObjUnderCursor = Obj
	end

	if Obj.TexName ~= "" then --DRAW texture
		if Obj.EditorQuad == nil then
			local Tex = g_ResMgr:GetImage( Obj.TexName )	
			Obj.EditorQuad = g_ResMgr:GethQuad( Tex, Obj.TexRect )					
		end
		
		love.graphics.setColor( 255 * Obj.MulColor[ 1 ], 255 * Obj.MulColor[ 2 ], 255 * Obj.MulColor[ 3 ], 255 * Obj.MulColor[ 4 ] )
		local Tex = g_ResMgr:GetImage( Obj.TexName )			
		local StSlX, StSlY = Obj.Size[ 1 ] / Obj.TexRect[ 3 ] * self.CameraScale, Obj.Size[ 2 ] / Obj.TexRect[ 4 ] * self.CameraScale			
		local QuadViewport = { Obj.EditorQuad:getViewport() }
		local OrigPvtX, OrigPvtY = QuadViewport[ 3 ] * Obj.Pivot[ 1 ], QuadViewport[ 4 ] * Obj.Pivot[ 2 ]
		love.graphics.draw( Tex, Obj.EditorQuad
		, X + self.CameraOffset[ 1 ], Y + self.CameraOffset[ 2 ]
		, Obj.Rotate, StSlX, StSlY, OrigPvtX, OrigPvtY )
	end

	if Obj.Animation then --DRAW Animation
		if self.RunAnimation then
			Obj.Animation:Update( love.timer.getDelta( ) )
		end
		love.graphics.setColor( 255 * Obj.MulColor[ 1 ], 255 * Obj.MulColor[ 2 ], 255 * Obj.MulColor[ 3 ], 255 * Obj.MulColor[ 4 ] )
		local Frame = Obj.Animation:GetCurrentFrame() 
		local AnimPos = { X + self.CameraOffset[ 1 ], Y + self.CameraOffset[ 2 ] }
		Tex = g_ResMgr:GetImage( Frame.TexName )
		local StSlX, StSlY = self.CameraScale, self.CameraScale	
		local OrigPvtX, OrigPvtY = Frame.TexRect[ 3 ] * Obj.Pivot[ 1 ], Frame.TexRect[ 4 ] * Obj.Pivot[ 2 ]	
		love.graphics.draw( Tex, Frame.Quad, AnimPos[ 1 ], AnimPos[ 2 ], Obj.Rotate, StSlX, StSlY, OrigPvtX, OrigPvtY )
	end

	if #Obj.Childs > 0 then
		for _, child_object in pairs( Obj.Childs ) do
			self:DrawWorkAreaObj( child_object, Obj.GlobalPos )
		end
	end
end


function editor_map_wnd_class:DrawParamPanel()	
	self:DrawParamPanelInfo()
	self:DrawParamPanelMode()
	self:DrawParamPanelObjects()
	self:DrawParamPanelObjectParam()	
	self:DrawParamPanelTools()	
	self:DrawParamPanelSettings()	
end


function editor_map_wnd_class:DrawParamPanelFiles( Params )	
	if ( imgui.CollapsingHeader( Params.HeadName ) ) then
		if imgui.Button("save") then			
			self:MapSave()
		end
		imgui.SameLine()	
		if imgui.Button("load") then			
			self:MapLoad()
		end	
		imgui.SameLine()	
		if imgui.Button("save as") then	
			g_Editor:ShowDialogSaveAs( {
				CallbackSaveAs = function( Info )
					LogE( "Save " .. Params.Type .. " as: " .. Info.File )
					self:FileSave( Info.File .. "." .. Params.Type )
					g_Editor.FileSustem:Reload()
				end
			} )
		end

		imgui.BeginChild( Params.HeadName, 0, 200, true )			
		g_Editor.FileSustem:DrawFilesTree( { 
			NoHeader	= true,
			Filters		= { Params.Type }, 
			OpenFile	= function( Info )
				--
			end, 
			SelectFile	= function( Info )
				self.SelectedFile = Info.FullPatch
			end, 
		} )	

		imgui.EndChild()-----
	end
end


function editor_map_wnd_class:DrawParamPanelInfo()	
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );
		imgui.Text( "CameraScale: " .. self.CameraScale )
		if self.ObjUnderCursor then
			imgui.Text( "ObjUnderCursor: " .. self.ObjUnderCursor.Name )
			imgui.Text( "ObjUnderCursor: " .. tostring( self.ObjUnderCursor ) )
		else
			imgui.Text( "no ObjUnderCursor" )
		end
	end
end


function editor_map_wnd_class:DrawParamPanelSettings()	
	if ( imgui.CollapsingHeader( "Settings" ) ) then
		local Status = nil
		if imgui.Checkbox("ShowRects", self.ShowRects ) then
			self.ShowRects = not self.ShowRects
		end
		imgui.SameLine()
		if imgui.Checkbox("ShowLayerRects", self.ShowLayerRects ) then
			self.ShowLayerRects = not self.ShowLayerRects
		end

		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3] = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3]);

		if imgui.Button("save") then			
			self:MapSave()
		end		
		imgui.SameLine()	
		if imgui.Button("save as") then	
			g_Editor:ShowDialogSaveAs( {
				CallbackSaveAs = function( Info )
					LogE( "Save " .. self.FileExtention .. " as: " .. Info.File )
					self:FileSave( Info.File .. "." .. self.FileExtention )
					g_Editor.FileSustem:Reload()
				end
			} )
		end
	end
end


function editor_map_wnd_class:DrawParamPanelTools()	
	if ( imgui.CollapsingHeader( "Tools" ) ) then
		if imgui.Button("add layer") then
			if self.SelectedObj then
				self.SelectedObj:AddChild( map_obj( MAP_TYPE_LAYER ) )
			else
				self.Map.RootObj:AddChild( map_obj( MAP_TYPE_LAYER ) )
			end
		end
		imgui.SameLine()		
		if imgui.Button("add sprite") then
			if self.SelectedObj then
				self.SelectedObj:AddChild( map_obj( MAP_TYPE_SPRITE ) )
			else
				self.Map.RootObj:AddChild( map_obj( MAP_TYPE_SPRITE ) )
			end
		end
		imgui.SameLine()	
		if imgui.Button("del selected") then
			self:DelSelected()
		end
		if imgui.Button("MapSetTex") then			
			if self.SelectedObj and self.SelectedObj.Type == MAP_TYPE_SPRITE then
				self:MapSetTexFromAtlasWnd( self.SelectedObj )
			else
				g_Editor:ShowPopUpMsg( "No selected sprite" )
			end
		end	
		if imgui.Button("ReCalcLayer") then
			if self.SelectedObj and self.SelectedObj.Type == MAP_TYPE_LAYER then
				self.SelectedObj:ReCalcLayer()
			else
				g_Editor:ShowPopUpMsg( "No selected layer" )
			end
		end	
	end
end


function editor_map_wnd_class:DrawParamPanelMode()	
	if ( imgui.CollapsingHeader( "Mode" ) ) then
		local ModeNames = {}
		ModeNames[ MAP_EDITOR_MODE_SELECT	  ] = "SEL"
		ModeNames[ MAP_EDITOR_MODE_MOVE		  ] = "MOVE"
		ModeNames[ MAP_EDITOR_MODE_SCALE	  ] = "SCL"
		ModeNames[ MAP_EDITOR_MODE_ROTATE	  ] = "ROT"
		ModeNames[ MAP_EDITOR_MODE_BRUSH	  ] = "BRUSH"
		ModeNames[ MAP_EDITOR_MODE_BRUSH_GRID ] = "BRUSH_GRID"

		for I = 1, MAP_EDITOR_MODE_COUNT do
			if I ~= 1 then
				imgui.SameLine()
			end			
			
			local Color = { 0.9, 0.9, 0.9 }
			if self.Mode == I then
				Color = { 0.1, 0.9, 0.1 }
			end

			imgui.PushID( I )
			imgui.PushStyleColor( "ImGuiCol_Button", Color[1], Color[2], Color[3], 1 );
			imgui.PushStyleColor( "ImGuiCol_ButtonHovered", Color[1], Color[2], Color[3], 1 );
			imgui.PushStyleColor( "ImGuiCol_ButtonActive", Color[1], Color[2], Color[3], 1 );
			
			if imgui.Button( ModeNames[ I ] ) then
				self.Mode = I
				--LogE( "Mode " .. self.Mode )
			end

			imgui.PopStyleColor( 3 )
			imgui.PopID()
		end
	end	
end


function editor_map_wnd_class:DrawParamPanelObjects()
	if ( imgui.CollapsingHeader( "Objects" ) ) then		
		
		local WndW, WndH = imgui.GetWindowSize()
		local Height = math.ceil( WndH / 2 )
		imgui.BeginChild( "MapObjTree", 0, Height, true );-----

		-- Increase spacing to differentiate leaves from expanded contents.
		imgui.PushStyleVar("IndentSpacing", imgui.GetFontSize()*0.5)

		self:DrawParamPanelMapObject( self.Map.RootObj )	

		imgui.PopStyleVar()
		imgui.EndChild()-----

		if imgui.Button("shift up") then
			self:ObjStepInTree( "up" )
		end
		imgui.SameLine()	
		if imgui.Button("shift down") then
			self:ObjStepInTree( "down" )
		end
	end
end


function editor_map_wnd_class:DrawParamPanelMapObject( Obj )	
	local HasChildren = #Obj.Childs > 0
	local NodeClicked, NodeOpen, UseFlags
	
	if HasChildren then
		UseFlags = { "OpenOnArrow", "OpenOnDoubleClick" }
	else
		UseFlags = { "Leaf", "NoTreePushOnOpen" }
	end
	
	if Obj == self.SelectedObj then
		table.insert( UseFlags, "Selected" )
	end
	
	NodeOpen = imgui.TreeNodeEx( tostring( Obj ), UseFlags, Obj.Name )
	NodeClicked = imgui.IsItemClicked()

	if NodeClicked then
		self:SelectObject( Obj )
	end

	imgui.SameLine( imgui.GetWindowContentRegionWidth() - 10 )
	if imgui.Checkbox( "##" .. tostring( Obj ), Obj.EditorVisible ) then
		Obj.EditorVisible = not Obj.EditorVisible
	end

	if NodeOpen and HasChildren then
		for _, ChildObj in pairs( Obj.Childs ) do
			self:DrawParamPanelMapObject( ChildObj )
		end
		imgui.TreePop()
	end
end


function editor_map_wnd_class:DrawParamPanelObjectParam()	
	if ( imgui.CollapsingHeader( "Param" ) ) then		

		local status
		local Pos = { 0, 0 }
		local Size = { 0, 0 }		
		local Rotate = 0

		if self.SelectedObj then
			status, self.SelectedObj.Name = imgui.InputText( "Rect name", self.SelectedObj.Name, 40 );
			Pos = self.SelectedObj.GlobalPos
			Size = self.SelectedObj.Size
			Rotate = self.SelectedObj.Rotate / math.pi * 180
		else
			local Tmp = "no select obj"
			status, Tmp = imgui.InputText( "Rect name", Tmp, 40 );
		end

		imgui.PushItemWidth( imgui.GetWindowContentRegionWidth() / 2 - 10 );

		local EditedPos = {}
		status, EditedPos[ 1 ] = imgui.DragInt("##Pos X", Pos[ 1 ], 1 , -99999, 99999, "Pos X = %.0f" )
		imgui.SameLine()
		status, EditedPos[ 2 ] = imgui.DragInt("##Pos Y", Pos[ 2 ], 1 , -99999, 99999, "Pos Y = %.0f" )
		
		status, Size[ 1 ] = imgui.DragInt("##Size X", Size[ 1 ], 1 , -99999, 99999, "Size X = %.0f" )
		imgui.SameLine()
		status, Size[ 2 ] = imgui.DragInt("##Size Y", Size[ 2 ], 1 , -99999, 99999, "Size Y = %.0f" )
		
		if self.SelectedObj then			
			status, Rotate = imgui.DragInt("##Rotate", Rotate, 1 , -99999, 99999, "Rotate = %.0f" )
			self.SelectedObj.Rotate = Rotate / 180 * math.pi
		else
			local Tmp = 0
			status, Tmp = imgui.DragInt("##Rotate", Tmp, 1 , -99999, 99999, "Rotate = %.0f" )
		end	
			
		if self.SelectedObj then
			self.SelectedObj:SetGlobalPos( EditedPos )
		end

		local Color = { 1, 1, 1, 1 }
		if self.SelectedObj then
			Color = self.SelectedObj.MulColor
		end
		status, Color[1], Color[2], Color[3], Color[4] = imgui.ColorEdit4( "mul color", Color[1], Color[2], Color[3], Color[4] );
	end
end


function editor_map_wnd_class:DrawContextMenu()	
	if imgui.BeginPopupContextItem( "Area context menu" ) then  
		if self.SelectedObj and imgui.Selectable("Copy") then
			self.CopyedObj = self.SelectedObj
		end
		if self.CopyedObj and imgui.Selectable("Paste") then 
			local CpObj = deepcopy( self.CopyedObj )
			CpObj:SetGlobalPos( self.MousePresMenyBtn ) 
			if self.SelectedObj then
				self.SelectedObj:AddChild( CpObj )
			else
				self.Map.RootObj:AddChild( CpObj )
			end
		end
		if self.SelectedObj and imgui.Selectable("Delete") then
			self:DelSelected()
		end
		imgui.EndPopup()
	end
end