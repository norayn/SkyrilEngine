require( "src.editor.editor_map_wnd_class" )

local MapEditor = editor_map_wnd_class()
g_Editor.MapEditor = MapEditor

MapEditor.WndName = "Map Editor"
MapEditor.Visible = false


function MapEditor:ClickL()
	MapEditor:MainClick()	
end


function MapEditor:Init()
	self.Map.RootObj = map_obj( MAP_TYPE_LAYER )
	self.Map.RootObj.Name = "root"
	LogE( "MapEditor ready", "atn" )
end


function MapEditor:Close()
	MapEditor.Visible = false
end