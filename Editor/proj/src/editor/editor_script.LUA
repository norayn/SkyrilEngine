local TOOL_AREA_WIDTH = 200


editor_script_window = class( function( self )
	self.WndName = "New script window"
	self.Visible = false

	self.EditedText = "Script = function( Param )\n\nend"

	self.OpenFile = ""
	self.SelectedFile = ""

	self.LocalScriptOwner = nil
end)


function editor_script_window:Init()

end


function editor_script_window:Update()

end


function editor_script_window:Draw()
	if not self.Visible then
		return
	end
	
	local IsVisible, IsOpen = imgui.Begin( self.WndName, true )
	if not IsOpen then 
		self.Visible = false
	end
	
	if IsVisible then
		imgui.BeginChild( self.WndName .. "Child1", imgui.GetWindowContentRegionWidth() - TOOL_AREA_WIDTH, 0, true );
			self:DrawTextEditor()
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


function editor_script_window:DrawTextEditor()
	local status
	local UseFlags = { "AllowTabInput" }
	local TextBufferSize = 9999
	status, self.EditedText = imgui.InputTextMultiline("InputText", self.EditedText, TextBufferSize, -1, -1, UseFlags )
end


function editor_script_window:DrawParamPanel()
	imgui.Text( "ScriptLen: " .. string.len( self.EditedText ) )

	if self.LocalScriptOwner and imgui.Button("Save local") then	
		local Func = g_ScrMgr:LoadScriptFromString( self.EditedText, self.LocalScriptOwner.Name .. "_script" )
		if Func then 
			self.LocalScriptOwner.ObjectScriptText = self.EditedText
			self.LocalScriptOwner.ObjectScriptFunc = Func			
		else
			g_Editor:ShowPopUpMsg( "Script not valid" )
		end	
	end

	if imgui.Button("test script") then	
		local Func = g_ScrMgr:LoadScriptFromString( self.EditedText, "Edited script" )
		if Func then 
			local success, err = pcall( Func )
			if not success then
				g_Editor:ShowPopUpMsg( err )
			end
		end	
	end
	self:DrawParamPanelScriptFiles()	
end


function editor_script_window:DrawParamPanelScriptFiles()	
	if ( imgui.CollapsingHeader( "Script files" ) ) then
		imgui.BeginChild( "Script files", 0, TOOL_AREA_WIDTH, true )
			g_Editor.FileSustem:DrawFilesTree( { 
				NoHeader	= true,
				Filters		= { "lua" }, 
				OpenFile	= function( Info )
					--
				end, 
				SelectFile	= function( Info )
					if not Info.IsFolder then
						self.SelectedFile = Info.FullPatch
					end
				end, 
			} )	
		
		imgui.EndChild()-----
		if imgui.Button("Load") then
			if self.SelectedFile == "" then
				g_Editor:ShowPopUpMsg( "No Selected File" )
			else		
				self.EditedText = TextFileRead( "proj/" .. self.SelectedFile )
				self.OpenFile = self.SelectedFile
			end	
		end	
		imgui.SameLine()
		if imgui.Button("Save") then	
			if self.OpenFile == "" then
				g_Editor:ShowPopUpMsg( "No Open File" )
			else
				TextFileSave( self.EditedText, "proj/" .. self.OpenFile )
			end				
		end
		imgui.SameLine()
		if imgui.Button("Save as") then
			g_Editor:ShowDialogSaveAs( {
				CallbackSaveAs = function( Info )
					LogE( "Save " .. "script" .. " as: " .. Info.File )
					TextFileSave( self.EditedText, "proj/" .. Info.File .. ".lua" )
					self.OpenFile = Info.File .. ".lua"
					self.SelectedFile = self.OpenFile
					g_Editor.FileSustem:Reload()
				end
			} )
		end	
	end
end


local ScriptEditor = editor_script_window()
g_Editor.ScriptEditor = ScriptEditor