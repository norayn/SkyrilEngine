Script = function( Param )
	local CollNms = {}
	CollNms[ "player_actor" ] = true


	local IsCollision = Param.Scene:CheckTriggerCollision( Param.Obj, {
		CollisionNames = CollNms,
	} )

	if IsCollision then		
		if g_Game then		
			g_Game.GameData.BornPlaceName = "BigToverBornPlaceTrigger"
			g_Game:SetScene( "/res/cpgd/first_street.scn" )
		else
			LogE( "TRIGGER open scene street", "warn" )
		end
	end
end