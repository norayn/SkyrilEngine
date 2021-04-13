Script = function( Param )
	local CollNms = {}
	CollNms[ "props_human" ] = true

	if Param.Obj.TriggerFlag == nil then
		Param.Obj.TriggerFlag = false
	end


	local IsCollision = Param.Scene:CheckTriggerCollision( Param.Obj, {
		CollisionNames = CollNms,
	} )

	if IsCollision then
		--Param.Scene:GetFirstObjectByName( "props_snow_bridge" )

		if IsCollision then
			LogE( "TRIGGER " .. Param.Obj.Name .. " collision change on", "atn" )
			Param.Obj.TriggerFlag = true
		else
			LogE( "TRIGGER " .. Param.Obj.Name .. " collisionn change off", "warn" )
		end
	end
end