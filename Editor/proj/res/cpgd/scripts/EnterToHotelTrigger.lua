Script = function( Param )
	local CollNms = {}
	CollNms[ "player_actor" ] = true


	local IsCollision = Param.Scene:CheckTriggerCollision( Param.Obj, {
		CollisionNames = CollNms,
	} )

	if IsCollision then		
		if g_Game then		
			g_Game:SetScenePause( true )
			g_Game:SetGuiScene( "/res/cpgd/gui/dialog_default.scn" )
		else
			LogE( "TRIGGER open scene tower entry", "warn" )
		end
	end
end