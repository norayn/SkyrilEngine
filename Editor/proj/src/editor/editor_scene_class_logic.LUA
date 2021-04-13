
function editor_scene_class:Save()
	if self.OpenFile == "" then
		g_Editor:ShowPopUpMsg( "No Open File" )
	else
		self.Scene:Save( self.OpenFile )
	end			
end


function editor_scene_class:SaveAs()
	g_Editor:ShowDialogSaveAs( {
		CallbackSaveAs = function( Info )
			LogE( "Save " .. "scene" .. " as: " .. Info.File )
			self.Scene:Save( Info.File .. ".scn" )
			self.OpenFile = Info.File .. ".scn"
			self.SelectedFile = self.OpenFile
			g_Editor.FileSustem:Reload()
		end
	} )	
end


function editor_scene_class:UpdateMode()
	if not self.SelectedObj then
		self.ObjEditHelper.Visible = false
		return
	end

	self.ObjEditHelper.Visible = true
	local Obj = self.SelectedObj
		
	self.ObjEditHelper:SetPosData{
		Pos = Obj.Offset,
		CameraScale = self.CameraScale,
		CameraOffset = self.CameraOffset,
		WndOffset = self.WorkAreaPos,
	}
end


function editor_scene_class:GetObjUnderCursor()
	self.ObjUnderCursor = nil
	for _, Obj in pairs( self.Scene.Objects ) do
		if not self.HideObjTypes[ Obj.ObjType ] then
			local CX, CY = self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ]
			if Obj.Rotate ~= 0 then
				local Res = RotatePoint( { CX, CY }, -Obj.Rotate, Obj.Pos )
				CX, CY = Res[ 1 ], Res[ 2 ]
			end	
			
			if Obj:OnObj( CX, CY ) and Obj.EditorVisible then
				self.ObjUnderCursor = Obj
			end
		end
	end
end


function editor_scene_class:ClickL()
	self:MainClick()	
end


function editor_scene_class:SelectObject( Obj )	
	self.SelectedObj = Obj
end


function editor_scene_class:MainClick()
	self:SelectObject( self.ObjUnderCursor )
end


function editor_scene_class:AddObj( FullPatch )
	if not FullPatch or FullPatch == "" then
		g_Editor:ShowPopUpMsg( "no FullPatch" )
	end

	local Obj = ObjectCreateByFile( FullPatch ) 
	self.Scene:AddObj( Obj )
	LogE( "scene add " .. FullPatch )
end


function editor_scene_class:AddSubScene( FullPatch )
	if not FullPatch or FullPatch == "" then
		g_Editor:ShowPopUpMsg( "no FullPatch" )
	end

	local Obj = object_subscene()--ObjectCreateByFile( FullPatch ) 
	Obj:Load( FullPatch )
	self.Scene:AddObj( Obj )
	LogE( "scene add " .. FullPatch )
end


function editor_scene_class:AddMap( FullPatch )
	if not FullPatch or FullPatch == "" then
		g_Editor:ShowPopUpMsg( "no FullPatch" )
	end

	local Map = map()
	Map:Load( FullPatch )
	self.Scene:AddMap( Map )
	LogE( "scene add " .. FullPatch )
end


function editor_scene_class:EditLinkedMap( Map )
	g_Editor.MapEditor.SelectedFile = Map.MapDataName
	g_Editor.MapEditor:MapLoad()

	local Maps = self.Scene.Maps
	local LinkCnt = 0
	for I = 1, #Maps do
		if Maps[ I ].MapDataName == g_Editor.MapEditor.SelectedFile then
			Maps[ I ].MapData = g_Editor.MapEditor.Map	
			LinkCnt = LinkCnt + 1		
		end
	end

	g_Editor.MapEditor.IsSceneLinkMode = true
	LogE( "open linked map " .. Map.MapDataName .. "    Link Count " .. LinkCnt )
end


function editor_scene_class:EditLinkedObj( Obj )
	g_Editor.ObjEditor.SelectedFile = Obj.MapDataName
	g_Editor.ObjEditor:MapLoad()

	local Objects = self.Scene.Objects
	local LinkCnt = 0
	for I = 1, #Objects do
		if Objects[ I ].MapDataName == g_Editor.ObjEditor.SelectedFile then
			Objects[ I ].MapData = g_Editor.ObjEditor.Map	
			LinkCnt = LinkCnt + 1	
		end
	end

	g_Editor.ObjEditor.IsSceneLinkMode = true
	LogE( "open linked obj " .. Obj.MapDataName .. "    Link Count " .. LinkCnt )
end


function editor_scene_class:DelSelectedObj( Obj )
	if Obj then		
		if Obj == self.CopyedObj then	
			self.CopyedObj = nil
		end

		self.Scene:DelObj( Obj )
		self.SelectedObj = nil	
	else
		g_Editor:ShowPopUpMsg( "No selected obj" )	
	end	
end


function editor_scene_class:DelSelectedMap( Map )
	if Map then	
		self.Scene:DelMap( Map )
		self.SelectedMap = nil	
	else
		g_Editor:ShowPopUpMsg( "No selected map" )	
	end	
end


function editor_scene_class:AddScriptFileToSelectedObj( ScriptFile )
	local Obj = self.SelectedObj
	if not Obj then
		g_Editor:ShowPopUpMsg( "No Selected Obj" )
		return
	end

	table.insert( Obj.ScriptsLinkList, ScriptFile )
end


function editor_scene_class:SelectedObjAddSize( AddSize )
	AddSize = Mul( AddSize, { 2, 2 } )
	local Sx = self.SelectedObj.Size[ 1 ] + ( AddSize[ 1 ] / self.CameraScale )
	local Sy = self.SelectedObj.Size[ 2 ] + ( AddSize[ 2 ] / self.CameraScale )
	self.SelectedObj.Offset[ 1 ] = self.SelectedObj.Offset[ 1 ] + ( ( Sx - self.SelectedObj.Size[ 1 ] ) / 2 )
	self.SelectedObj.Offset[ 2 ] = self.SelectedObj.Offset[ 2 ] + ( ( Sy - self.SelectedObj.Size[ 2 ] ) / 2 )
	self.SelectedObj.Size = { Sx, Sy }

	if not self.SelectedObj.MapDataName then 
		self.SelectedObj.MapData.RootObj.Size = { Sx, Sy }
		self.SelectedObj.MapData.RootObj.Childs[ 1 ].Size = { Sx, Sy }
	end
end


function editor_scene_class:SelectedObjSetRotate( Rotate )
	if not self.SelectedObj.MapDataName then 
		self.SelectedObj.MapData.RootObj.Childs[ 1 ].Rotate = Rotate
		self.SelectedObj.MapData.RootObj:ReCalcLayer()
		self.SelectedObj.Size = Add( self.SelectedObj.MapData.RootObj.Size, { 0, 0 } )
	else
		self.SelectedObj.Rotate = Rotate
	end
end


function editor_scene_class:SelectedObjAddRotate( Rotate )
	if not self.SelectedObj.MapDataName then 
		self:SelectedObjSetRotate( self.SelectedObj.MapData.RootObj.Childs[ 1 ].Rotate + Rotate )
	else
		self:SelectedObjSetRotate( self.SelectedObj.Rotate + Rotate )
	end
end