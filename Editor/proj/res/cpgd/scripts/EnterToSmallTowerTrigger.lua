Script = function( Param )
	local CollNms = {}
	CollNms[ "player_actor" ] = true


	local IsCollision = Param.Scene:CheckTriggerCollision( Param.Obj, {
		CollisionNames = CollNms,
	} )

	if IsCollision then		
		if g_Game then		
			g_Game.GameData.BornPlaceName = "EntruBornPlaceTrigger"
			g_Game:SetScene( "/res/cpgd/build_entry.scn" )
		else
			LogE( "TRIGGER open scene tower entry", "warn" )
		end
	end
end