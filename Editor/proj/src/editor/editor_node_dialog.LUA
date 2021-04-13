require( "src.editor.editor_node_wnd_class" )
require( "src.shared.text_input_class" )

local DialogActionTypes = {
	"BackToScene",
	"ToNextScene",
	"MoveObj",
	"CallScript",
	"Trading",
	"GetQuest",
	"MultiAction",
}

local NodeDialogEditor = editor_node_wnd_class()
g_Editor.NodeDialogEditor = NodeDialogEditor

NodeDialogEditor.WndName = "Node dialog Editor"
NodeDialogEditor.Visible = true

function NodeDialogEditor:ClickL()
	NodeDialogEditor:MainClick()	
end


function NodeDialogEditor:DoubleClickL()
	NodeDialogEditor:ShowEditTextWnd()
end


function NodeDialogEditor:Init()
	LogE( "NodeDialogEditor ready", "atn" )
	self.IsShiftOutputs = 1

	self.TextInputWndPos = { 100, 100 }
	self.TextInputWndSize = { 300, 200 }
	self.IsShowTextInputWnd = false

	self.Ti = text_input_class( { 
		X = self.TextInputWndPos[ 1 ] + 10, 
		Y = self.TextInputWndPos[ 2 ] + 10, 
		W = self.TextInputWndSize[ 1 ] - 20, 
		Size = 255, 
	} )
end


function editor_node_wnd_class:ShowEditTextWnd()
	if self.PartTextUnderCursor then
		self.IsShowTextInputWnd = true
		g_Editor.KeyPressedListnerTab[ 'ti' ] = function( Key, Scancode, IsRepeat )
			self.Ti:Keypressed( Key )
		end
		g_Editor.TextInputListnerTab[ 'ti' ] = function( T )
			self.Ti:TextInput( T )
		end

		self.Ti.Callback = function()
			self.PartTextUnderCursor.TextTab[ self.PartTextUnderCursor.IndexParam ].Name = self.Ti.Text
			self:HideEditTextWnd()
		end

		self.Ti:SetText( self.PartTextUnderCursor.TextTab[ self.PartTextUnderCursor.IndexParam ].Name )
	end
end


function editor_node_wnd_class:HideEditTextWnd()
	self.IsShowTextInputWnd = false
	g_Editor.KeyPressedListnerTab[ 'ti' ] = nil
	g_Editor.TextInputListnerTab[ 'ti' ] = nil
end


function editor_node_wnd_class:UpdateWnd()
	self:UpdateMode()
	self.Ti:Step( love.timer.getDelta() )
end


function NodeDialogEditor:DrawWorkArea( WndPos )
	self:DrawWorkAreaMain()
	if self.IsShowTextInputWnd then
		love.graphics.setColor( 50, 50, 50, 220 )	
		love.graphics.rectangle( "fill", self.TextInputWndPos[ 1 ], self.TextInputWndPos[ 2 ], self.TextInputWndSize[ 1 ], self.TextInputWndSize[ 2 ], 10, 10 )
		love.graphics.setColor( 250, 250, 250, 250 )	
		self.Ti:Draw()
	end
	--g_Editor.KeyPressedListnerTab[ 'ti' ] = function( Key, Scancode, IsRepeat )
	--	self.Ti:Keypressed( Key )
	--end
	--g_Editor.TextInputListnerTab[ 'ti' ] = function( T )
	--	self.Ti:TextInput( T )
	--end
end


function NodeDialogEditor:DrawParamPanel()	
	self:DrawParamPanelInfo()	
	self:DrawParamPanelNodeParam()
	self:DrawParamPanelSettings()	
end


function NodeDialogEditor:DrawParamPanelNodeParam()	
	if ( imgui.CollapsingHeader( "Param" ) ) then
		if self.SelectedObj then
			status, self.SelectedObj.Name = imgui.InputText( "Node name", self.SelectedObj.Name, 40 );
			local Inputs = self.SelectedObj.Inputs
			local Outputs = self.SelectedObj.Outputs

			local RbInd = Inputs[ 1 ].Type == "ACTION" and 2 or 1
			if imgui.RadioButton( "Dialog", RbInd, 1 ) then
				Inputs[ 1 ].Type = ""
			end			
			imgui.SameLine()
			if imgui.RadioButton( "Action", RbInd, 2 ) then
				Inputs[ 1 ].Type = "ACTION"
			end	
			
			if RbInd == 1 then	--dialog					
				status, Inputs[ 1 ].Name = imgui.InputText( "Dialog text", Inputs[ 1 ].Name, 40 );				
				
				if #Outputs < 4 and imgui.Button( "Add answer" ) then
					table.insert( Outputs, { Type = "", Name = "new answer" } )
					self:UpdateNodeH( self.SelectedObj )
				end
				if #Outputs < 4 and #Outputs > 1 then
					imgui.SameLine()
				end
				if #Outputs > 1 and imgui.Button( "Del last answer" ) then
					table.remove( Outputs )
					self:UpdateNodeH( self.SelectedObj )
				end

				for I = 1, #Outputs do
					status, Outputs[ I ].Name = imgui.InputText( "Answer " .. I, Outputs[ I ].Name, 40 );
				end
			end
			if RbInd == 2 then	--action
			
				local TypeNameToIndex = {}
				for I = 1, #DialogActionTypes do
					TypeNameToIndex[ DialogActionTypes[ I ] ] = I
				end				

				Inputs[ 1 ].Name = 'Trading'
				
				local status, TypeInd = imgui.Combo( "Type", TypeNameToIndex[ Inputs[ 1 ].Name ], DialogActionTypes, #DialogActionTypes )	
				Inputs[ 1 ].Name = DialogActionTypes[ TypeInd ]
			end
		else
			imgui.Text( "No select obj" )			
		end

		if imgui.Button( "test export" ) then
			self:ExportDialog()
		end
	end
end


function NodeDialogEditor:Close()
	NodeDialogEditor.Visible = false
end


function NodeDialogEditor:ExportDialog()
	local NodeList = self.NodeList

	local NodeToName = {}
	for Ind, Node in pairs( NodeList ) do
		NodeToName[ Node ] = "Node_" .. Ind
	end

	local DialogSteps = {}
	for Ind, Node in pairs( NodeList ) do
		local StepName = NodeToName[ Node ]
		local Step = {}
		Step.Text = Node.Inputs.Name
		Step.Ansvers = {}
		for Ind, Out in pairs( Node.Outputs ) do
			local Ansver = {}
			Ansver.Text = Out.Name
			if Out.Link then
				Ansver.NextStepName = NodeToName[ Out.Link.NodeObj ]
			else 
				Ansver.NextStepName = ""
			end
			--TODO actions
			Step.Ansvers[ Ind ] = Ansver
		end

		Step.Char = { Name = "char name", Icon = "" } --TODO
		DialogSteps[ StepName ] = Step
	end

	LogE( DialogSteps )
end