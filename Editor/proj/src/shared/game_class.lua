
game = class( function( self, Type )
	self.Name = "no_game"

	self.GameData = {}
	self.StartSceneName = "/res/cpgd/first_street.scn"
	--self.StartSceneName = "/res/cpgd/start_level.scn"
	self.CurrentScene = nil
	self.NextScenePatch = nil
	self.CurrentGuiScene = nil
	self.NextGuiScenePatch = nil
	self.ScenesList = {
		{ Name = "first_street", Patch = "/res/cpgd/first_street.scn" },
		--{ Name = "", Patch = "" },
	}
end)


function game:Init()
	g_Game = self

	self.GameData.BornPlaceName = "BornPlaceTrigger"
	self:ChangeScene( self.StartSceneName )

	self:ChangeGuiScene( "/res/cpgd/gui/test_gui_scene.scn" )	
end


function game:Update( Delta )	
	self.CurrentScene:Update( Delta )
	self.CurrentGuiScene:Update( Delta )

	if self.NextScenePatch then
		self:ChangeScene( self.NextScenePatch )
		self.NextScenePatch = nil
	end
	if self.NextGuiScenePatch then
		self:ChangeGuiScene( self.NextGuiScenePatch )
		self.NextGuiScenePatch = nil
	end
end


function game:Draw()
	self.CurrentScene:Draw()
	self.CurrentGuiScene:Draw()
end


function game:SetScene( ScenePatch )
	self.NextScenePatch = ScenePatch
end


function game:SetGuiScene( ScenePatch )
	self.NextGuiScenePatch = ScenePatch
end


function game:ChangeScene( ScenePatch )
	self.CurrentScene = nil
	self.CurrentScene = scene()
	self.CurrentScene:Load( ScenePatch )
	self.CurrentScene.Camera.Scale = 1

	local Obj = object_subscene()
	Obj:Load( "res/cpgd/PlayerChar.ssn" )
	local StartPos = { 0, 0 }
	if self.GameData.BornPlaceName then
		Obj.Offset = Add( StartPos, self.CurrentScene:GetFirstObjectByName( self.GameData.BornPlaceName ).Offset )
	end
	Obj.Name = "player_actor"
	Obj.Z = 2
	table.insert( Obj.ScriptsLinkList, "/res/cpgd/scripts/character_camera_control.lua" )
	table.insert( Obj.ScriptsLinkList, "/res/cpgd/scripts/actor_move_controller.lua" )
	self.CurrentScene:AddObj( Obj )	
end


function game:ChangeGuiScene( ScenePatch )
	self.CurrentGuiScene = nil
	self.CurrentGuiScene = scene()
	self.CurrentGuiScene:Load( ScenePatch )
	self.CurrentGuiScene.Camera = camera()
end


function game:SetScenePause( IsPause )
	self.CurrentScene.IsRunUpdate = not IsPause
end