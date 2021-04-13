
require( "src.editor.editor_wnd_class" )
require( "src.shared.game_class" )

local GameEditor = editor_window()
g_Editor.GameEditor = GameEditor

GameEditor.WndName = "Game Editor"
GameEditor.Visible = false

GameEditor.OpenFile = ""

GameEditor.Game = nil


function GameEditor:Init()	
	GameEditor.Game = game()
	GameEditor.Game:Init()

	self.ShowRects = false	
	self.ShowHiddenObj = true

	LogE( "GameEditor ready", "atn" )
end


function GameEditor:Close()
	GameEditor.Visible = false
end



function GameEditor:UpdateWnd()
	--if self.RunUpdate then
		self.Game:Update( love.timer.getDelta() )
	--end	
end


function GameEditor:DrawWorkArea( WndPos )
	local ShowRects = g_Editor.SceneEditor.ShowRects
	g_Editor.SceneEditor.ShowRects = self.ShowRects
	self.Game:Draw()
	g_Editor.SceneEditor.ShowRects = ShowRects
	
	
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
end


function GameEditor:DrawParamPanel()	
	local Status = nil
	
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		--imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );
		--imgui.Text( "CameraScale: " .. self.CameraScale )
	end
					
	if ( imgui.CollapsingHeader( "Settings" ) ) then
		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3]  = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3] );

		if imgui.Checkbox("ShowRects", self.ShowRects ) then
			self.ShowRects = not self.ShowRects
		end
		imgui.SameLine()
		if imgui.Checkbox("ShowHiddenObj", self.ShowHiddenObj ) then
			g_Editor.SceneEditor.HideObjTypes[ OBJECT_TYPE_COLLISION ] = self.ShowHiddenObj
			g_Editor.SceneEditor.HideObjTypes[ OBJECT_TYPE_TRIGGER ] = self.ShowHiddenObj
			self.ShowHiddenObj = not self.ShowHiddenObj
		end
		
		if imgui.Button("Reset" ) then
			GameEditor.Game = nil
			GameEditor.Game = game()
			GameEditor.Game:Init()
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


function GameEditor:DrawContextMenu()	
	if imgui.BeginPopupContextItem( "Area context menu" ) then  
		--if self.SelectedFrame and imgui.Selectable("Delete") then
		--	self:DelSlectedFrame()
		--end
		if imgui.Selectable("Set to PI") then value = 3.1415 end
		imgui.EndPopup()
	end
end


function GameEditor:Load()
	--if self.OpenFile == "" then
	--	g_Editor:ShowPopUpMsg( "No Open File" )
	--else
	--	self.Anim:Load( self.OpenFile )
	--end			
end


function GameEditor:Save()
	--if self.OpenFile == "" then
	--	g_Editor:ShowPopUpMsg( "No Open File" )
	--else
	--	self.Anim:Save( self.OpenFile )
	--end			
end


function GameEditor:SaveAs()
	--g_Editor:ShowDialogSaveAs( {
	--	CallbackSaveAs = function( Info )
	--		LogE( "Save " .. "sprite animation" .. " as: " .. Info.File )
	--		self.Anim:Save( Info.File .. ".asp" )
	--		self.OpenFile = Info.File .. ".asp"			
	--		g_Editor.FileSustem:Reload()
	--	end
	--} )	
end