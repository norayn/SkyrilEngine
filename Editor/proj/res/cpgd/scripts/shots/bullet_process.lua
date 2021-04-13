Script = function( Param )	
	local Pos =  Param.Obj.Offset
	--if Param.Scene.OwnerObj then Pos = Param.Scene.OwnerObj.Offset	end
	local NewPos = { Pos[ 1 ], Pos[ 2 ] }	

	local Mv = { math.ceil( Param.Delta * Param.Obj.MoveVec[ 1 ] ), math.ceil( Param.Delta * Param.Obj.MoveVec[ 2 ] ) }
	--local Mv = { ( Param.Delta * Param.Obj.MoveVec[ 1 ] ), ( Param.Delta * Param.Obj.MoveVec[ 2 ] ) }
	NewPos = Add( NewPos, Mv )


	--local IsCollision = Param.Scene:CheckCollision( {
	--	CollisionPoint = NewPos,
	--} )
	--
	--if not IsCollision then
		Pos[ 1 ], Pos[ 2 ] = NewPos[ 1 ], NewPos[ 2 ]
	--end
end