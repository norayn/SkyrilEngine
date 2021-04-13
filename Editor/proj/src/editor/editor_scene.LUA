require( "src.editor.editor_scene_class" )

local SceneEditor = editor_scene_class()
g_Editor.SceneEditor = SceneEditor


function SceneEditor:Init()
	LogE( "SceneEditor ready", "atn" )
	self.WndName = "Scene Editor"
end

function SceneEditor:ClickL()
	SceneEditor:MainClick()	
end