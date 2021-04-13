require( "src.editor.editor_scene_class" )

local SubSceneEditor = editor_scene_class()
g_Editor.SubSceneEditor = SubSceneEditor


function SubSceneEditor:Init()
	LogE( "SubSceneEditor ready", "atn" )
	self.WndName = "SubScene Editor"
end


function SubSceneEditor:SaveAs()
	g_Editor:ShowDialogSaveAs( {
		CallbackSaveAs = function( Info )
			LogE( "Save " .. "sub scene" .. " as: " .. Info.File )
			self.Scene:Save( Info.File .. ".ssn" )
			self.OpenFile = Info.File .. ".ssn"
			self.SelectedFile = self.OpenFile
			g_Editor.FileSustem:Reload()
		end
	} )	
end


function SubSceneEditor:ClickL()
	SubSceneEditor:MainClick()	
end
