require "src.shared.utils"
require "src.shared.helper_func"

local Editor = {}
g_Editor = Editor

require "src.editor.editor_func"
require "src.editor.editor_dialog"
require "src.shared.map_base_class"
require "src.editor.editor_filesustem"
require "src.editor.editor_atlas"
require "src.editor.editor_map"
require "src.editor.editor_obj"
require "src.editor.editor_scene"
require "src.editor.editor_sub_scene"
require "src.editor.editor_script"
require "src.editor.editor_animation"
require "src.editor.editor_game"
require "src.editor.editor_file_browser"
require "src.editor.console"
require "src.editor.editor_main_meny"
require "src.editor.editor_inspector"
require "src.editor.editor_node_dialog"

Editor.NoRenderWorkAreaByModal = false
Editor.DialogWindow = nil
Editor.KeyPressedListnerTab = {}
Editor.TextInputListnerTab = {}
Editor.Console = console_class( "debug console" )
LogE = function( ... )	Editor.Console:Log( ... )	end
Editor.Inspector = inspector_wnd_class( "Inspector", { No_object = "Warning" } )

function Editor:Init()
	love.window.setTitle( "game editor" )
	self.FileSustem.load()

	self.AtlasEditor:Init()
	self.MapEditor:Init()
	self.ObjEditor:Init()
	self.SceneEditor:Init()
	self.SubSceneEditor:Init()
	self.ScriptEditor:Init()
	self.AnimationEditor:Init()
	self.GameEditor:Init()
	self.FileBrowser:Init()
	self.NodeDialogEditor:Init()

	local FontPatch = "res/font/arial.ttf"
	local Font = love.graphics.newFont( FontPatch, 15 )
	love.graphics.setFont( Font )	
end


function Editor:Update()
	self.AtlasEditor:Update()
	self.MapEditor:Update()
	self.ObjEditor:Update()
	self.SceneEditor:Update()
	self.SubSceneEditor:Update()
	self.ScriptEditor:Update()
	self.AnimationEditor:Update()
	self.GameEditor:Update()
	self.FileBrowser:Update()
	self.NodeDialogEditor:Update()
end


function Editor:Draw()
	DrawEditorMainMeny()
	
	self.Console:Draw()
	
	self.AtlasEditor:Draw()
	self.MapEditor:Draw()	
	self.ObjEditor:Draw()	
	self.SceneEditor:Draw()	
	self.SubSceneEditor:Draw()	
	self.ScriptEditor:Draw()
	self.AnimationEditor:Draw()
	self.GameEditor:Draw()
	self.FileBrowser:Draw()	
	self.NodeDialogEditor:Draw()	
	
	self.Inspector:Draw()	

	if self.DialogWindow then
		self:DrawDialogWnd()
	end

	local clearColor = { 0.2, 0.2, 0.2 }
    love.graphics.clear(clearColor[1] * 255, clearColor[2] * 255, clearColor[3] * 255, 255)
    imgui.Render();

	love.graphics.setColor( 255, 255, 255, 255 )
end


function Editor:KeyPressed( Key, Scancode, IsRepeat )
	for _, Func in pairs( self.KeyPressedListnerTab ) do
		Func( Key, Scancode, IsRepeat )
	end
end


function Editor:TextInput( T )
	for _, Func in pairs( self.TextInputListnerTab ) do
		Func( T )
	end
end