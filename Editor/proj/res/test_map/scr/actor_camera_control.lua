Script = function( Param )
	local Camera = Param.Scene.Camera
	local ObjPosition = Param.Obj.Offset
	
	Camera.Offset = Sub( ObjPosition, Div( Camera.Size, { 2, 2 } ) )
	Camera.Offset[ 2 ] = Camera.Offset[ 2 ] - 100

	Camera.Offset[ 1 ] = Camera.Offset[ 1 ] * -Camera.Scale
	Camera.Offset[ 2 ] = Camera.Offset[ 2 ] * -Camera.Scale
	--LogE( "camera pos " .. Camera.Offset[ 1 ] .. ":" .. Camera.Offset[ 2 ], "warn" )
end