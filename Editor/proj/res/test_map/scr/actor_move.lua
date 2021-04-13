Script = function( Param )
	local Pos =  Param.Obj.Offset
	if love.keyboard.isDown("left") then
        Pos[ 1 ]  = Pos[ 1 ] - ( Param.Delta * 150 )
    end
	if love.keyboard.isDown("right") then
        Pos[ 1 ]  = Pos[ 1 ] + ( Param.Delta * 150 )
    end
end