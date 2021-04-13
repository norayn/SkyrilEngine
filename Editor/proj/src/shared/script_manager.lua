--v1.0

script_manager = class(function( self, res_patch )
	self.ScriptCount = 0
	self.ScriptPool = {}
end)


function script_manager:GetScriptCount()
	return self.ScriptCount
end


function script_manager:GetScript( Name )
	if self.ScriptPool[ Name ] == nil then
		local Func = self:LoadScriptFromFile( Name )
		self.ScriptPool[ Name ] = Func
		self.ScriptCount = self.ScriptCount + 1
		return self.ScriptPool[ Name ]
	else
		return self.ScriptPool[ Name ]
	end
end


function script_manager:LoadScriptFromString( Str, DebugScriptName )
	local func = loadstring( Str, DebugScriptName )
	if func then 		
		func()
		local ResultFunc = Script
			
		if ResultFunc then 		
			Script = nil
			return ResultFunc
		else
			LogE( "Error in extract script func " .. DebugScriptName, "err" )
		end	
	else
		LogE( "Error in load script " .. DebugScriptName, "err" )
	end	

	return nil
end


function script_manager:LoadStringFromFile( FileName )
	local ScriptString = TextFileRead( "proj/" .. FileName )
	if not ScriptString then
		LogE( "Error in load file script string " .. FileName, "err" )
		return nil
	end

	return ScriptString
end


function script_manager:ExecuteScriptFile( FileName )
	local ScriptString = self:LoadStringFromFile( FileName )
	if not ScriptString then	return false	end

	local func = loadstring( ScriptString, FileName )
	if func then 		
		func()	
		return true	
	else
		LogE( "Error in load script " .. DebugScriptName, "err" )
		return false
	end		
end


function script_manager:LoadScriptFromFile( FileName )
	local ScriptString = self:LoadStringFromFile( FileName )
	if not ScriptString then	return nil	end
	return self:LoadScriptFromString( ScriptString, FileName )
end


function script_manager:ResetScriptPool()
	self.ScriptCount = 0
	self.ScriptPool = {}	
end


function script_manager:Call( Name, Param )
	local ScriptFunk = self:GetScript( Name )
	if ScriptFunk then
		ScriptFunk( Param )
	end
end

