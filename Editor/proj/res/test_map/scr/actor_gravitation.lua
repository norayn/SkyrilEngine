Script = function( Param )
	local Pos = Add( Param.Obj.Offset, { 0, 110 } )
	local IsCollision = Param.Scene:CheckCollision( {
		CollisionPoint = Pos,
	} )

	if not IsCollision then
		local IsDownCollision = Param.Scene:CheckCollision( {
			CollisionPoint = { Pos[ 1 ], Pos[ 2 ] + 1 },
		} )

		if not IsDownCollision then
			Param.Obj.Offset[ 2 ] = Param.Obj.Offset[ 2 ] + 1
		end
	else
		Param.Obj.Offset[ 2 ] = Param.Obj.Offset[ 2 ] - 1
	end
end