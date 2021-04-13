local TOOL_AREA_WIDTH = 200


editor_file_browser_window = class( function( self )
	self.WndName = "File browser"
	self.Visible = true

	self.OpenFile = ""
	self.SelectedFile = ""

	self.SelectedFolder = nil
end)


function editor_file_browser_window:Init()

end


function editor_file_browser_window:Update()

end


function editor_file_browser_window:Draw()
	if not self.Visible then
		return
	end
	local IsVisible, IsOpen = imgui.Begin( self.WndName, true )
	if not IsOpen then 
		self.Visible = false
	end
	
	if IsVisible then
		imgui.BeginChild( self.WndName .. "Child1", imgui.GetWindowContentRegionWidth() - TOOL_AREA_WIDTH, 0, true );
			self:DrawCatalog()
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


function editor_file_browser_window:DrawParamPanel()
	--imgui.Text( "ScriptLen: " .. string.len( self.EditedText ) )

	if imgui.Button("update filesystem") then	
		g_Editor.FileSustem:Reload()	
	end

	self:DrawParamPanelScriptFiles()	
end


function editor_file_browser_window:DrawParamPanelScriptFiles()		
	imgui.BeginChild( "Script files", 0, -20, true )
		g_Editor.FileSustem:DrawFilesTree( { 
			NoHeader	= true,
			OnlyFolder  = true,
			--Filters		= { "only_folder" }, 
			OpenFile	= function( Info )
				--
			end, 
			SelectFile	= function( Info )
				if Info.IsFolder then
					self.SelectedFolder = Info
				end
			end, 
		} )	
	
	imgui.EndChild()-----
end


function editor_file_browser_window:DrawCatalog()	
	if not self.SelectedFolder then
		return
	end
	
	local NodeClicked, NodeOpen
	local UseFlags

	for k, v in pairsByKeys( self.SelectedFolder.Files ) do
		if not v.IsFolder then
			local HasChildren = false
			if HasChildren then
				UseFlags = { "OpenOnArrow", "OpenOnDoubleClick" }
			else
				UseFlags = { "Leaf", "NoTreePushOnOpen" }
			end
			
			--if v == self.SelectedObj then
			--	table.insert( UseFlags, "Selected" )
			--end
			
			local NodeOpen = imgui.TreeNodeEx( '[' .. v.Ext .. '] ' .. v.ShortName, UseFlags )
			local NodeClicked = imgui.IsItemClicked()

			if NodeClicked then
				--self:SelectObject( v )
				if imgui.IsMouseDoubleClicked( 0 ) then
					self:OpenFileByType( v.Ext, v.FullPatch )
				end
			end
			
			--imgui.SameLine( imgui.GetWindowContentRegionWidth() - 10 )
			--if .Checkbox( "##" .. tostring( v ), v.EditorVisible ) then
			--	v.EditorVisible = not v.EditorVisible
			--end

			imgui.PushID( '[' .. v.Ext .. '] ' .. v.ShortName )
			if ( imgui.BeginPopupContextItem("item context menu") ) then           
				self:DrawContextMenuByType( v.Ext, v.FullPatch )	             
                --imgui.PushItemWidth( -1 )
                --imgui.DragFloat("##Value", value, 0.1, 0.0, 0.0)
                --imgui.PopItemWidth()
                imgui.EndPopup()			
			end
			imgui.PopID()

		end
	end
end


function editor_file_browser_window:OpenFileByType( Type, File )	
	local OpenWnd = function( Wnd )
		Wnd.Visible = true
		imgui.SetWindowCollapsed( Wnd.WndName, false )
		--imgui.SetWindowPos( g_Editor.SceneEditor.WndName, 5, 20 )
	end
	
	if Type == 'scn' then
			g_Editor.SceneEditor.Scene:Load( File )
			g_Editor.SceneEditor.OpenFile = File
			OpenWnd ( g_Editor.SceneEditor )
	end	
	
	if Type == 'ssn' then
			g_Editor.SubSceneEditor.Scene:Load( File )
			g_Editor.SubSceneEditor.OpenFile = File
			OpenWnd ( g_Editor.SubSceneEditor )
	end	

	if Type == 'lua' then
	   
	end
	 
	if Type == 'map' then
		g_Editor.MapEditor.SelectedFile = File
		g_Editor.MapEditor:MapLoad()
		OpenWnd ( g_Editor.MapEditor )
	end

	if Type == 'obj' then
		g_Editor.ObjEditor.SelectedFile = File
		g_Editor.ObjEditor:MapLoad()
		OpenWnd ( g_Editor.ObjEditor )
	end

	if Type == 'tex' or Type == 'tga' or Type == 'png' then
		g_Editor.AtlasEditor:LoadAtlas( File )
		OpenWnd ( g_Editor.AtlasEditor )
	end

	if Type == 'asp' then
		g_Editor.AnimationEditor.OpenFile = File
		g_Editor.AnimationEditor:Load()
		OpenWnd ( g_Editor.AnimationEditor )
	end
end


function editor_file_browser_window:DrawContextMenuByType( Type, File )	
	if Type == 'scn' then
	    if imgui.Selectable("Open scene") then 
			self:OpenFileByType( Type, File )	
		end
	end	

	if Type == 'ssn' then
	    if imgui.Selectable("Open sub scene") then 
			self:OpenFileByType( Type, File )	
		end
		if g_Editor.SceneEditor.Visible and imgui.Selectable("Add sub scene to scene") then 
			g_Editor.SceneEditor:AddSubScene( File )
		end
	end	

	if Type == 'lua' then
	    if imgui.Selectable("Open script") then value = 0 end
	    if g_Editor.SceneEditor.Visible and imgui.Selectable("Add script to select obj on scene") then 
			g_Editor.SceneEditor:AddScriptFileToSelectedObj( File )
		end
	    if g_Editor.SubSceneEditor.Visible and imgui.Selectable("Add script to select obj on sub scene") then 
			g_Editor.SubSceneEditor:AddScriptFileToSelectedObj( File )
		end
	end
	 
	if Type == 'map' then
	    if imgui.Selectable("Open map") then 
			self:OpenFileByType( Type, File )	
		end
	    if g_Editor.SceneEditor.Visible and imgui.Selectable("Add map to scene") then 
			g_Editor.SceneEditor:AddMap( File )
		end
	end

	if Type == 'obj' then
	    if imgui.Selectable("Open obj") then 
			self:OpenFileByType( Type, File )	
		end
	    if g_Editor.SceneEditor.Visible and imgui.Selectable("Add obj to scene") then 
			g_Editor.SceneEditor:AddObj( File )
		end
	    if g_Editor.SubSceneEditor.Visible and imgui.Selectable("Add obj to sub scene") then 
			g_Editor.SubSceneEditor:AddObj( File )
		end
	end

	if Type == 'tex' or Type == 'tga' or Type == 'png' then
	    if imgui.Selectable("Open atlas") then 
			self:OpenFileByType( Type, File )	
		end
	end

	if Type == 'asp' then
	    if imgui.Selectable("Open sprite anim") then 
			self:OpenFileByType( Type, File )	
		end
	    if g_Editor.ObjEditor.Visible and imgui.Selectable("Add sprite anim to obg editor") then 
			local AnimObj = map_obj( MAP_TYPE_ANIMATION )
			AnimObj.Animation = animation_sprite()
			AnimObj.Animation:Load( File )
			g_Editor.ObjEditor.Map.RootObj:AddChild( AnimObj )
		end
	end
end


local FileBrowser = editor_file_browser_window()
g_Editor.FileBrowser = FileBrowser