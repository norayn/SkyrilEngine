Script = function( Param )
	local Pos =  Param.Obj.Offset
	if Param.Scene.OwnerObj then Pos = Param.Scene.OwnerObj.Offset	end
	local NewPos = { Pos[ 1 ], Pos[ 2 ] }	

	if love.keyboard.isDown("left") then
        NewPos[ 1 ]  = Pos[ 1 ] - ( Param.Delta * 150 )
    end
	if love.keyboard.isDown("right") then
        NewPos[ 1 ]  = Pos[ 1 ] + ( Param.Delta * 150 )
    end
	if love.keyboard.isDown("up") then
        NewPos[ 2 ]  = Pos[ 2 ] - ( Param.Delta * 150 )
    end
	if love.keyboard.isDown("down") then
        NewPos[ 2 ]  = Pos[ 2 ] + ( Param.Delta * 150 )
    end

	--Pos = NewPos
	--NewPos = Add( NewPos, { 0, 110 } )
	local IsCollision = Param.Scene:CheckCollision( {
		CollisionPoint = NewPos,
	} )
	
	if not IsCollision then
		Pos[ 1 ], Pos[ 2 ] = NewPos[ 1 ], NewPos[ 2 ]
	end
end