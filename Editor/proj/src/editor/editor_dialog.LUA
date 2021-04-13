local Editor = g_Editor


function Editor:DrawDialogWnd()
	local Dialog = self.DialogWindow

	if Dialog.Type == "warning" then
		imgui.OpenPopup("Warning!")
		imgui.BeginPopupModal( "Warning!" ) 	
		imgui.Text( Dialog.WarningMsgText )
		if imgui.Button( "Close" ) then
			imgui.CloseCurrentPopup()
			self.DialogWindow = nil
			self.NoRenderWorkAreaByModal = false
		end
		imgui.EndPopup();
	end	

	if Dialog.Type == "save_file" then
		local status
		imgui.OpenPopup("Save file")
		imgui.BeginPopupModal( "Save file" ) 	

		imgui.BeginChild( "Obj files", 300, 300, true )
		
		g_Editor.FileSustem:DrawFilesTree( { 
			NoHeader	= true,
			--Filters		= { "obj" }, 
			OpenFile	= function( Info )
				--
			end, 
			SelectFile	= function( Info )
				if Info.IsFolder then
					Dialog.SaveFilePatch = Info.FullPatch
				else
					Dialog.SaveFilePatch = Info.Folder
					Dialog.SaveFileName = Info.ShortName
				end
			end, 
		} )	

		imgui.EndChild()-----
		imgui.Text( "Folder: " .. Dialog.SaveFilePatch )
		status, Dialog.SaveFileName = imgui.InputText( "file name", Dialog.SaveFileName, 40 );

		if imgui.Button("save") then	
			if Dialog.CallbackSaveAs then
				Dialog.CallbackSaveAs( { File = Dialog.SaveFilePatch .. '/' .. Dialog.SaveFileName } )
			end
			self.DialogWindow = nil
			self.NoRenderWorkAreaByModal = false
		end
		imgui.SameLine()	
		if imgui.Button("cancel") then			
			self.DialogWindow = nil
			self.NoRenderWorkAreaByModal = false
		end	

		imgui.EndPopup();
	end
end


function Editor:ShowPopUpMsg( Text )
	self.DialogWindow = {}
	self.DialogWindow.Type = "warning"	
	self.DialogWindow.WarningMsgText = Text
	self.NoRenderWorkAreaByModal = true
end


function Editor:ShowDialogSaveAs( Info )
	self.DialogWindow = {}
	self.DialogWindow.Type = "save_file"
	self.DialogWindow.SaveFileName = ""
	self.DialogWindow.SaveFilePatch = ""
	self.DialogWindow.CallbackSaveAs = Info.CallbackSaveAs
	self.NoRenderWorkAreaByModal = true
end

