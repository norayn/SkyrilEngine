Script = function( Param )
	local Pos =  Param.Obj.Offset	
	local NewPos = { Pos[ 1 ], Pos[ 2 ] }	

	if love.keyboard.isDown("space") then
       LogE( "Bang!!" )

	   local Obj = object_props()
	   Obj:Load( "res/cpgd/objects/props_bullet_test.obj" )
	   Obj.Offset = NewPos
	   Obj.MoveVec = { 500, 0 }
	   Obj.LifeTime = 2
	   Obj.Z = 2
	   --table.insert( Obj.ScriptsLinkList, "/res/cpgd/scripts/shots/bullet_process.lua" )
	   Obj:AddScriptLink( "/res/cpgd/scripts/shots/bullet_process.lua" )
	   Param.Scene:AddObj( Obj )	
    end

end