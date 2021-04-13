Script = function( Param )
	local DS = Param.Obj.DialogState

	local function ShowStep( Step )
		DS.CurrentStep = Step
		Param.Scene:GetFirstObjectByName( "name_text" ).Text = Step.Char.Name
		Param.Scene:GetFirstObjectByName( "main_text" ).Text = Step.Text

		for I = 1, 4 do
			if Step.Ansvers[ I ] then
				Param.Scene:GetFirstObjectByName( "line" .. I .. "_text" ).Text = '{' .. I .. '}   ' .. Step.Ansvers[ I ].Text
			else
				Param.Scene:GetFirstObjectByName( "line" .. I .. "_text" ).Text = ""
			end
		end	
	end

	local function ActionEncoder( Action )
		--TODO add warnings
		if Action.Type == "BackToScene" then
			g_Game:SetGuiScene( "/res/cpgd/gui/test_gui_scene.scn" )
			g_Game:SetScenePause( false )
		end
		if Action.Type == "ToNextScene" then
			if Action.BornPlaceName then
				g_Game.GameData.BornPlaceName = Action.BornPlaceName			
			end
						
			g_Game:SetScene( Action.Scene )
		end
		if Action.Type == "MoveObj" then
			if Action.TargetObjName then		
				local BornPos = Add( { 0, 0 }, g_Game.CurrentScene:GetFirstObjectByName( Action.TargetObjName ).Offset )
				g_Game.CurrentScene:GetFirstObjectByName( Action.ObjName ).Offset = BornPos
			end
			if Action.TargetObjPos then						
				g_Game.CurrentScene:GetFirstObjectByName( Action.ObjName ).Offset = Action.TargetObjPos
			end
		end
		if Action.Type == "CallScript" then

		end
		if Action.Type == "Trading" then

		end
		if Action.Type == "GetQuest" then

		end
		if Action.Type == "MultiAction" then
			for _, v in pairs( Action.ActionList ) do
				ActionEncoder( v )
			end
		end
	end	

	if not Param.Obj.DialogState then
		Param.Obj.DialogState = {}
		DS = Param.Obj.DialogState
		local Name = "/res/cpgd/scripts/dialogs/dialog1.lua"

		if g_ScrMgr:ExecuteScriptFile( Name ) then
			DS.ScriptSteps = DialogScript.Steps
			ShowStep( DS.ScriptSteps.Step_StartDialog )
		else
			LogE( "Error load gui " .. Name, "err" )
		end

		Param.Obj.ActionKeyFlags = {}
	end

	local ActionKeyFlags = Param.Obj.ActionKeyFlags
	local ActionKeys = { "1", "2", "3", "4" } 
	for I = 1, 4 do
		if love.keyboard.isDown( ActionKeys[ I ] ) then
			if not ActionKeyFlags[ I ] then	
				ActionKeyFlags[ I ] = true			
				LogE( "select dialog action " .. I )				
				if DS.CurrentStep.Ansvers[ I ] then
					local Ansver = DS.CurrentStep.Ansvers[ I ]
					if Ansver.NextStepName ~= "" then
						ShowStep( DS.ScriptSteps[ Ansver.NextStepName ] )
					end
					if Ansver.Action then
						ActionEncoder( Ansver.Action )
					end
				end
			end
		else
			ActionKeyFlags[ I ] = false
		end			
	end	
end