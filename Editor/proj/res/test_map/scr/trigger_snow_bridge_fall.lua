Script = function( Param )
	local CollNms = {}
	CollNms[ "props_human" ] = true

	if Param.Obj.TriggerFlag == nil then
		Param.Obj.TriggerFlag = false
	end


	local IsCollision = Param.Scene:CheckTriggerCollision( Param.Obj, {
		CollisionNames = CollNms,
	} )

	if IsCollision ~= Param.Obj.TriggerFlag then
		Param.Obj.TriggerFlag = IsCollision

		if IsCollision then
			LogE( "TRIGGER " .. Param.Obj.Name .. " collision change on", "atn" )
			--Param.Scene:GetFirstObjectByName( "props_car_entry" ).EditorVisible = true
			local ActTrigger = Param.Scene:GetFirstObjectByName( "trigger_bridge_activate" )
			if ActTrigger.TriggerFlag then
				Param.Scene:GetFirstObjectByName( "props_snow_bridge" ).EditorVisible = false
				Param.Scene:GetFirstObjectByName( "collision_snow_bridge" ).Offset = { 2500, -497 }
			end
		else
			LogE( "TRIGGER " .. Param.Obj.Name .. " collisionn change off", "warn" )
		end
	end
end