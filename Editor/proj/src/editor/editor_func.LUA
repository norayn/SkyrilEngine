



function g_Editor:ObjStepInTree( Param )	
	local Obj = Param.Obj
	local ObjTable = Param.ObjTable

	if Obj == nil or ObjTable == nil then	
		g_Editor:ShowPopUpMsg( "no available selekted Obj" )
		return
	end
	
	local ObjNum = -1	
	for I = 1, #ObjTable do
		if ObjTable[ I ] == Obj then
			ObjNum = I
		end
	end
	
	if Param.StepDirText == "up" then
		if ObjNum == 1 then	
			g_Editor:ShowPopUpMsg( "already up" )		
			return
		end

		local UpObj = ObjTable[ ObjNum - 1 ]
		ObjTable[ ObjNum - 1 ] = Obj
		ObjTable[ ObjNum ] = UpObj
	end

	if Param.StepDirText == "down" then
		if ObjNum == #ObjTable then	
			g_Editor:ShowPopUpMsg( "already down" )		
			return
		end

		local DownObj = ObjTable[ ObjNum + 1 ]
		ObjTable[ ObjNum + 1 ] = Obj
		ObjTable[ ObjNum ] = DownObj
	end
end


function g_Editor:AddHint( Text )	
	if imgui.IsItemHovered() then
		imgui.BeginTooltip()
		imgui.PushTextWrapPos( imgui.GetFontSize() * 35 );
		imgui.TextUnformatted( Text )
		imgui.PopTextWrapPos()
		imgui.EndTooltip()
	end
end