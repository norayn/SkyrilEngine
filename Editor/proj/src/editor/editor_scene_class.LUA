require( "src.editor.editor_wnd_class" )

require( "src.shared.scene_class" )
require( "src.shared.camera_class" )


editor_scene_class = class( editor_window, function( self )
	editor_window.init( self )
	
	self.WndName = "editor_scene_class"
	
	self.Scene = nil
	self.Visible = false

	self.ObjUnderCursor = nil
	self.SelectedObj = nil
	self.CopyedObj = nil

	self.ShowRects = true
	self.RunUpdate = true
	self.UseEditorCamera = true

	self.OpenFile = ""
	self.SelectedFile = ""
	self.ObjScriptSelectedFile = ""

	self.SelectedObjectFile = ""

	self.SelectedMap = nil

	self.SelectedScriptsLink = ""
	self.SelectedScriptsLinkInd = -1
	
	self.HideObjTypes = {}

	self.Scene = scene()
	self.Scene.Camera = camera()

	self.ObjEditHelper = wnd_drag_helper()

	self.ObjEditHelper.Helpers[ 1 ] = {
		Offset = { 0, -22 },
		Size = { 20, 20 },
		Text = "M",
		MoveFunc = function( Offset )
			if self.SelectedObj then
				self.SelectedObj.Offset = { 
					self.SelectedObj.Offset[ 1 ] + ( Offset[ 1 ] / self.CameraScale ), 
					self.SelectedObj.Offset[ 2 ] + ( Offset[ 2 ] / self.CameraScale ) }
			end
		end,
	}
	self.ObjEditHelper.Helpers[ 2 ] = {
		Offset = { 30, -22 },
		Size = { 20, 20 },
		Text = "S",
		MoveFunc = function( Offset )
			if self.SelectedObj then
				self:SelectedObjAddSize( Offset )
			end
		end,
	}
	self.ObjEditHelper.Helpers[ 3 ] = {
		Offset = { 60, -22 },
		Size = { 20, 20 },
		Text = "R",
		MoveFunc = function( Offset )
			self:SelectedObjAddRotate( Offset[ 2 ] / 180 * math.pi )
		end,
	}
end)


require( "src.editor.editor_scene_class_logic" )


function editor_scene_class:Init()
	LogE( "editor_scene_class ready", "wrn" )
end


function editor_scene_class:Close()
	self.Visible = false
end


function editor_scene_class:UpdateWnd()
	self:GetObjUnderCursor()
	if self.RunUpdate then
		self.Scene:Update( love.timer.getDelta() )
	end

	self:UpdateMode()
end


function editor_scene_class:DrawWorkArea( WndPos )
	if self.UseEditorCamera then
		self.Scene.Camera:SetWndPosAndOffset( WndPos, self.CameraOffset ) 
		self.Scene.Camera.Scale = self.CameraScale
		--LogE( "Editor camera pos " .. self.Scene.Camera.Offset[ 1 ] .. ":" .. self.Scene.Camera.Offset[ 2 ], "warn" )
	end

	self.Scene:Draw()
	self.ObjEditHelper:Draw()

	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end


function editor_scene_class:DrawParamPanel()	
	local Status = nil
	
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );
		imgui.Text( "CameraScale: " .. self.CameraScale )
		if self.ObjUnderCursor then
			imgui.Text( "ObjUnderCursor: " .. self.ObjUnderCursor.Name )
		else
			imgui.Text( "no ObjUnderCursor" )
		end
		imgui.Text( "Scene: " .. self.OpenFile )
	end
	
	self:DrawParamPanelMaps()	
	self:DrawParamPanelObjects()
	self:DrawParamPanelObjectParam()
			
	if ( imgui.CollapsingHeader( "Settings" ) ) then
		if imgui.Checkbox("ShowRects", self.ShowRects ) then
			self.ShowRects = not self.ShowRects
		end
		imgui.SameLine()
		if imgui.Checkbox("ShowLayerRects", self.ShowLayerRects ) then
			self.ShowLayerRects = not self.ShowLayerRects
		end
		if imgui.Checkbox("RunUpdate", self.RunUpdate ) then
			self.RunUpdate = not self.RunUpdate
		end
		imgui.SameLine()
		if imgui.Checkbox("UseEditorCamera", self.UseEditorCamera ) then
			self.UseEditorCamera = not self.UseEditorCamera
		end

		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3]  = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3] );
		
		if imgui.Button("Reload scripts") then
			g_ScrMgr:ResetScriptPool()
		end

		if imgui.Button("Save" ) then
			self:Save()
		end
		imgui.SameLine()
		if imgui.Button("SaveAs" ) then
			self:SaveAs()
		end
	end
end



function editor_scene_class:DrawParamPanelMaps()
	local Maps = self.Scene.Maps

	if not self.SelectedMap then
		if #Maps >= 1 then
			self.SelectedMap = Maps[ 1 ]
		else
			return
		end
	end

	if ( imgui.CollapsingHeader( "Maps" ) ) then
		local status = false
		---------
		imgui.BeginChild( "MapObjTree", 0, 200, true );-----

		for MapInd, Map in pairs( Maps ) do
			local NodeClicked, NodeOpen, UseFlags
			UseFlags = { "Leaf", "NoTreePushOnOpen" }
			
			if Map == self.SelectedMap then
				table.insert( UseFlags, "Selected" )
			end
			
			NodeOpen = imgui.TreeNodeEx( tostring( Map ), UseFlags, Map.MapDataName )
			NodeClicked = imgui.IsItemClicked()

			if NodeClicked then
				self.SelectedMap = Map
			end	

			imgui.SameLine( imgui.GetWindowContentRegionWidth() - 10 )
			if imgui.Checkbox( "##" .. tostring( Map ), Map.EditorVisible ) then
				Map.EditorVisible = not Map.EditorVisible
			end
		end

		imgui.EndChild()-----
		---------
		local Map = self.SelectedMap
		ASSERT( Map )
		
		if imgui.Button("shift up") then
			g_Editor:ObjStepInTree( {
				StepDirText = "up",
				ObjTable = Maps,
				Obj = Map,
			} )
		end
		imgui.SameLine()	
		if imgui.Button("shift down") then
			g_Editor:ObjStepInTree( {
				StepDirText = "down",
				ObjTable = Maps,
				Obj = Map,
			} )
		end
		imgui.SameLine()
		if imgui.Button("del map") then	
			self:DelSelectedMap( Map )
			self.SelectedMapIndex = nil
		end	

		local Scale = Map.Scale * 100
		status, Scale = imgui.DragInt("##Scale", Scale, 1 , -99999, 99999, "Scale persent = %.0f" )
		Map.Scale = Scale / 100		
				
		status, Map.Z = imgui.DragInt("##Z", Map.Z, 1 , -99, 99, "Z = %.0f" )

		imgui.PushItemWidth( imgui.GetWindowContentRegionWidth() / 2 - 10 );
		status, Map.Offset[ 1 ] = imgui.DragInt("##Pos X", Map.Offset[ 1 ], 1 , -99999, 99999, "Offset X = %.0f" )
		imgui.SameLine()
		status, Map.Offset[ 2 ] = imgui.DragInt("##Pos Y", Map.Offset[ 2 ], 1 , -99999, 99999, "Offset Y = %.0f" )

		local Parl = Map.ParallaxK[ 1 ] * 100
		status, Parl = imgui.DragInt("##ParallaxX", Parl, 1 , -99999, 99999, "Parallax X%% = %.0f" )
		Map.ParallaxK[ 1 ] = Parl / 100	
		imgui.SameLine()
		Parl = Map.ParallaxK[ 2 ] * 100
		status, Parl = imgui.DragInt("##ParallaxY", Parl, 1 , -99999, 99999, "Parallax Y%% = %.0f" )
		Map.ParallaxK[ 2 ] = Parl / 100	

		local Color = Map.MulColor
		status, Color[1], Color[2], Color[3], Color[4] = imgui.ColorEdit4("mul color", Color[1], Color[2], Color[3], Color[4] );
		
		if imgui.Button("online edit map") and self.SelectedMap then
			self:EditLinkedMap( self.SelectedMap )
		end
	end
end


function editor_scene_class:DrawParamPanelObjects()
	if ( imgui.CollapsingHeader( "Scene objects" ) ) then
		
		local DrawHideObjCheckbox = function( Name, Type )
			if imgui.Checkbox( Name, self.HideObjTypes[ Type ] ) then
				self.HideObjTypes[ Type ] = not self.HideObjTypes[ Type ]
			end
		end
		DrawHideObjCheckbox( "Hide props", OBJECT_TYPE_PROPS )
		imgui.SameLine()	
		DrawHideObjCheckbox( "collision", OBJECT_TYPE_COLLISION )
		imgui.SameLine()	
		DrawHideObjCheckbox( "trigger", OBJECT_TYPE_TRIGGER )

		imgui.BeginChild( "SceneObjects", 0, 250, true );-----
		
		local NodeClicked, NodeOpen
		local UseFlags

		for k, v in pairsByKeys( self.Scene.Objects ) do
			if not self.HideObjTypes[ v.ObjType ] then
				local HasChildren = false
				if HasChildren then
					UseFlags = { "OpenOnArrow", "OpenOnDoubleClick" }
				else
					UseFlags = { "Leaf", "NoTreePushOnOpen" }
				end
				
				if v == self.SelectedObj then
					table.insert( UseFlags, "Selected" )
				end
				
				local NodeOpen = imgui.TreeNodeEx( v.Name, UseFlags )
				local NodeClicked = imgui.IsItemClicked()

				if NodeClicked then
					self:SelectObject( v )
				end
				
				imgui.SameLine( imgui.GetWindowContentRegionWidth() - 10 )
				if imgui.Checkbox( "##" .. tostring( v ), v.EditorVisible ) then
					v.EditorVisible = not v.EditorVisible
				end
			end
		end
		imgui.EndChild()-----

		if imgui.Button("shift up") and self.SelectedObj then
			g_Editor:ObjStepInTree( {
				StepDirText = "up",
				ObjTable = self.Scene.Objects,
				Obj = self.SelectedObj,
			} )
		end
		imgui.SameLine()	
		if imgui.Button("shift down") and self.SelectedObj then
			g_Editor:ObjStepInTree( {
				StepDirText = "down",
				ObjTable = self.Scene.Objects,
				Obj = self.SelectedObj,
			} )
		end
		imgui.SameLine()	
		if imgui.Button("del") and self.SelectedObj then
			self:DelSelectedObj( self.SelectedObj )
		end
		if imgui.Button("online edit obj") and self.SelectedObj then
			self:EditLinkedObj( self.SelectedObj )
		end
	end
end


function editor_scene_class:DrawParamPanelObjectParam()	
	if ( imgui.CollapsingHeader( "Object Param" ) ) then		

		local status
		local Pos = { 0, 0 }
		local Size = { 0, 0 }		
		local Rotate = 0

		if self.SelectedObj then
			status, self.SelectedObj.Name = imgui.InputText( "Obj name", self.SelectedObj.Name, 40 );
			Pos = self.SelectedObj.Offset
			Size = self.SelectedObj.Size
			Rotate = self.SelectedObj.Rotate / math.pi * 180
			if not self.SelectedObj.MapDataName and self.SelectedObj.MapData then
				Rotate = self.SelectedObj.MapData.RootObj.Childs[ 1 ].Rotate / math.pi * 180
			end
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
		
		if self.SelectedObj and self.SelectedObj.MapData then	
			status, Rotate = imgui.DragInt("##Rotate", Rotate, 1 , -99999, 99999, "Rotate = %.0f" )
			self:SelectedObjSetRotate( Rotate / 180 * math.pi )
			imgui.SameLine()
			status, self.SelectedObj.Z = imgui.DragInt("##Z", self.SelectedObj.Z, 1 , -99, 99, "Z = %.0f" )
		else
			local Tmp = 0
			status, Tmp = imgui.DragInt("##Rotate", Tmp, 1 , -99999, 99999, "Rotate = %.0f" )
			imgui.SameLine()
			status, Tmp = imgui.DragInt("##Z", Tmp, 1 , -99, 99, "Z = %.0f" )
		end	
		
		local Color = { 1, 1, 1, 1 }
		if self.SelectedObj then
			self.SelectedObj.Offset[ 1 ] = EditedPos[ 1 ]
			self.SelectedObj.Offset[ 2 ] = EditedPos[ 2 ]
			
			if self.SelectedObj.MulColor then 
				Color = self.SelectedObj.MulColor
			end
		end
				
		status, Color[1], Color[2], Color[3], Color[4] = imgui.ColorEdit4( "mul color", Color[1], Color[2], Color[3], Color[4] );

		self:DrawParamPanelObjectParamScript()	
	end
end


function editor_scene_class:DrawParamPanelObjectParamScript()		
	local Obj = self.SelectedObj
	if not Obj then
		return
	end

	if ( imgui.TreeNodeEx( "obj scrip list", nil, "obj scrip list" ) ) then
		if imgui.Button("edit obj skript") and self.SelectedObj then
			local SkrEditor = g_Editor.ScriptEditor
			SkrEditor.LocalScriptOwner = self.SelectedObj
			if self.SelectedObj.ObjectScriptText then
				SkrEditor.EditedText = self.SelectedObj.ObjectScriptText
			end
			SkrEditor.WndName = "Local obj skript: " .. self.SelectedObj.Name
		end

		imgui.BeginChild( "Script list", 0, 100, true )

		for ScriptsLinkInd, ScriptsLink in pairs( Obj.ScriptsLinkList ) do
			local NodeClicked, NodeOpen, UseFlags
			UseFlags = { "Leaf", "NoTreePushOnOpen" }
			
			if ScriptsLinkInd == self.SelectedScriptsLinkInd then---!!!
				table.insert( UseFlags, "Selected" )
			end
			
			local ScrName = "..." .. string.sub( ScriptsLink, - 28 )

			NodeOpen = imgui.TreeNodeEx( ScriptsLink, UseFlags, ScrName )
			NodeClicked = imgui.IsItemClicked()			
			g_Editor:AddHint( ScriptsLink )

			if NodeClicked then
				self.SelectedScriptsLink = ScriptsLink
				self.SelectedScriptsLinkInd = ScriptsLinkInd
			end	
		end

		imgui.EndChild()-----

		if imgui.Button("del select link") then
			if Obj.ScriptsLinkList[ self.SelectedScriptsLinkInd ] then			
				table.remove( Obj.ScriptsLinkList, self.SelectedScriptsLinkInd )
			else
				g_Editor:ShowPopUpMsg( "No selected script" )
			end
		end
		imgui.TreePop()	
	end
end


function editor_scene_class:DrawContextMenu()	
	if imgui.BeginPopupContextItem( "Area context menu" ) then  
		if self.SelectedObj and imgui.MenuItem("Delete") then
			self:DelSelectedObj( self.SelectedObj )
		end
		if self.SelectedObj and imgui.MenuItem("Open in inspector") then
			g_Editor.Inspector.Obj = self.SelectedObj
			g_Editor.Inspector.Visible = true
		end

		if imgui.BeginMenu( "Add" ) then		
			local function AddSimplyObj( Type )
				local Obj = nil
				if Type == OBJECT_TYPE_TRIGGER then		Obj = object_trigger()		end
				if Type == OBJECT_TYPE_COLLISION then	Obj = object_collision()	end
				local MapObj = map_obj( MAP_TYPE_SPRITE )
				local MapData = {}
				MapData.ObjType = Type
				MapData.RootObj = map_obj( MAP_TYPE_LAYER )
				MapData.RootObj.Name = "root"
				MapData.RootObj.Childs = {
					MapObj
				}

				Obj.Size = { 100, 50 }
				Obj.Offset = { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] }
				Obj.MapData = MapData
				self.Scene:AddObj( Obj )
			end
			
			if imgui.MenuItem( "Text obj" ) then 				
				local Obj = object_text()
				Obj.Offset = { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] }
				self.Scene:AddObj( Obj )
			end
			if imgui.MenuItem( "Trigger obj" ) then 				
				AddSimplyObj( OBJECT_TYPE_TRIGGER )
			end
			if imgui.MenuItem( "Collision obj" ) then 				
				AddSimplyObj( OBJECT_TYPE_COLLISION )
			end
			imgui.EndMenu()
		end

		if imgui.MenuItem("test111") then value = 3.1415 end
		imgui.EndPopup()
	end
end

