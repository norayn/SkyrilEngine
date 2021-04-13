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
			Param.Scene:GetFirstObjectByName( "props_car_entry" ).EditorVisible = true
		else
			LogE( "TRIGGER " .. Param.Obj.Name .. " collisionn change off", "warn" )
		end
	end
end