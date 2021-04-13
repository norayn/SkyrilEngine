Script = function( Param )
	local CollTps = {}
	CollTps[ OBJECT_TYPE_ACTOR ] = true

	if Param.Obj.TriggerFlag == nil then
		Param.Obj.TriggerFlag = false
	end


	local IsCollision = Param.Scene:CheckTriggerCollision( Param.Obj, {
		CollisionTypes = CollTps,
	} )

	if IsCollision ~= Param.Obj.TriggerFlag then
		Param.Obj.TriggerFlag = IsCollision

		if IsCollision then
			LogE( "TRIGGER actor collision change", "atn" )
		else
			LogE( "TRIGGER actor collision change", "warn" )
		end
	end
end