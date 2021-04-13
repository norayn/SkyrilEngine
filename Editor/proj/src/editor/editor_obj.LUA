require( "src.editor.editor_map_wnd_class" )

local ObjEditor = editor_map_wnd_class()
g_Editor.ObjEditor = ObjEditor

ObjEditor.WndName = "Obj Editor"
ObjEditor.Visible = false


function ObjEditor:ClickL()
	ObjEditor:MainClick()	
end


function ObjEditor:Init()
	self.FileExtention = "obj"
	self.Map.RootObj = map_obj( MAP_TYPE_LAYER )
	self.Map.RootObj.Name = "root"
	self.Map.ObjType = OBJECT_TYPE_NONE
	self.RunAnimation = true
	LogE( "ObjEditor ready", "atn" )
end


function ObjEditor:DrawParamPanel()	
	self:DrawParamPanelInfo()
	self:DrawParamPanelMode()
	self:DrawParamPanelObjects()
	self:DrawParamPanelObjectParam()	
	self:DrawParamPanelTools()	
		
	if ( imgui.CollapsingHeader( "Obj Type Param" ) ) then		
		local status
		local Names = {}
		for I = 1, OBJECT_TYPE_COUNT do
			Names[ I ] = ObjectTypeToString[ I ]
		end

		status, self.Map.ObjType = imgui.Combo( "Type", self.Map.ObjType, Names, #Names )	
	end
		
	self:DrawParamPanelSettings()	
end


function ObjEditor:Close()
	ObjEditor.Visible = false
end