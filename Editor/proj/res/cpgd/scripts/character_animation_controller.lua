Script = function( Param )
	local Pos =  Param.Obj.Offset
	if Param.Scene.OwnerObj then Pos = Param.Scene.OwnerObj.Offset	end
	
	if not Param.Obj.DynamicData then	
		Param.Obj.DynamicData = {}
	end
	
	if not Param.Obj.DynamicData.AnimationController then	
		Param.Obj.DynamicData.AnimationController = {}
		
		local AnimNames = {
			"idle_up",
			"idle_down",
			"idle_left",
			"idle_right",
			"walk_up",
			"walk_down",
			"walk_left",
			"walk_right",
		}

		local AnimObjByName = {}
		for _, Name in pairs( AnimNames ) do
			AnimObjByName[ Name ] = Param.Obj:GetFirstMapDataObjByName( Name )
			AnimObjByName[ Name ].Visible = false
		end

		AnimObjByName[ "idle_down" ].Visible = true

		Param.Obj.DynamicData.AnimationController.AnimObjByName = AnimObjByName
		Param.Obj.DynamicData.AnimationController.LastAnimState = "idle_down"
		Param.Obj.DynamicData.AnimationController.LastPos = { Pos[ 1 ], Pos[ 2 ] }
		Param.Obj.DynamicData.AnimationController.Direction = { 0, 1 }	
	end

	local AnimCntlr = Param.Obj.DynamicData.AnimationController
	local Dir = AnimCntlr.Direction	
	local IsMove = false

	if Pos[ 1 ] - AnimCntlr.LastPos[ 1 ] < 0 then
		Dir = { -1, 0 }
		IsMove = true
    end
	if Pos[ 1 ] - AnimCntlr.LastPos[ 1 ] > 0 then
		Dir = { 1, 0 }
		IsMove = true
    end
	if Pos[ 2 ] - AnimCntlr.LastPos[ 2 ] < 0 then
		Dir = { 0, -1 }
		IsMove = true
    end
	if Pos[ 2 ] - AnimCntlr.LastPos[ 2 ] > 0 then
		Dir = { 0, 1 }
		IsMove = true
    end

	AnimCntlr.Direction = { Dir[ 1 ], Dir[ 2 ] }
	AnimCntlr.LastPos = { Pos[ 1 ], Pos[ 2 ] }

	local NextAnimState = ""
	if IsMove then
		NextAnimState = "walk_"
	else
		NextAnimState = "idle_"
	end

	if Dir[ 1 ] == 1 then NextAnimState = NextAnimState .. "right" end
	if Dir[ 1 ] == -1 then NextAnimState = NextAnimState .. "left" end
	if Dir[ 2 ] == 1 then NextAnimState = NextAnimState .. "down" end
	if Dir[ 2 ] == -1 then NextAnimState = NextAnimState .. "up" end
	
	if NextAnimState ~= AnimCntlr.LastAnimState then		
		AnimCntlr.AnimObjByName[ AnimCntlr.LastAnimState ].Visible = false
		ASSERT( AnimCntlr.AnimObjByName[ NextAnimState ], NextAnimState )
		AnimCntlr.AnimObjByName[ NextAnimState ].Visible = true
		AnimCntlr.LastAnimState = NextAnimState
	end
end