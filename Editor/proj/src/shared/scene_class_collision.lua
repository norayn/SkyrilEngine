local function PointCollisionInObj( MapObj, Point )	
	local X, Y = Point[ 1 ], Point[ 2 ]
	if MapObj.Rotate ~= 0 then
		local Res = RotatePoint( { X, Y }, -MapObj.Rotate, MapObj.GlobalPos )
		X, Y = Res[ 1 ], Res[ 2 ]
	end	

	local PvtX, PvtY = MapObj.Size[ 1 ] * MapObj.Pivot[ 1 ], MapObj.Size[ 2 ] * MapObj.Pivot[ 2 ]
	if	X >= MapObj.GlobalPos[ 1 ] - PvtX and X < MapObj.GlobalPos[ 1 ] + MapObj.Size[ 1 ] - PvtX 
	and Y >= MapObj.GlobalPos[ 2 ] - PvtY and Y < MapObj.GlobalPos[ 2 ] + MapObj.Size[ 2 ] - PvtY then
		return true
	else
		return false
	end
end


local function DataObjCollision( DataObj, Param, SceneObjOffset )
	if ( DataObj.Type ~= MAP_TYPE_LAYER ) then
		if Param.CollisionPoint then
			local CX, CY = Param.CollisionPoint[ 1 ] - SceneObjOffset[ 1 ], Param.CollisionPoint[ 2 ] - SceneObjOffset[ 2 ]

			if PointCollisionInObj( DataObj, { CX, CY } ) then
				return true
			end
		end	
	end

	if #DataObj.Childs > 0 then
		for _, ChildObject in pairs( DataObj.Childs ) do
			if DataObjCollision( ChildObject, Param, SceneObjOffset ) then
				return true
			end	
		end
	end
	
	return false	
end


local function SceneObjCollision( SceneObj, Param )
	if Param.CollisionPoint then
		local CX, CY = Param.CollisionPoint[ 1 ], Param.CollisionPoint[ 2 ]
		if SceneObj.Rotate ~= 0 then
			local Res = RotatePoint( { CX, CY }, -SceneObj.Rotate, SceneObj.Offset )
			CX, CY = Res[ 1 ], Res[ 2 ]
		end	
		
		if SceneObj:OnObj( CX, CY ) then
			if DataObjCollision( SceneObj.MapData.RootObj, Param, SceneObj.Offset ) then
				return true
			end	
		end
	end

	return false	
end


function scene:CheckCollision( Param )
	for _, Obj in pairs( self.Objects ) do
		if Obj.ObjType == OBJECT_TYPE_COLLISION then
			if SceneObjCollision( Obj, Param ) then
				return true
			end			
		end
	end

	return false	
end


function scene:CheckTriggerCollision( TriggerObj, Param )
	for _, Obj in pairs( self.Objects ) do
		ASSERT( Param.CollisionTypes or Param.CollisionNames, 'no CollisionTypes or CollisionNames'  )
		if Param.CollisionTypes and Param.CollisionTypes[ Obj.ObjType ] then
			if SceneObjCollision( TriggerObj, { CollisionPoint = Obj.Offset } ) then
				return true
			end			
		end
		if Param.CollisionNames and Param.CollisionNames[ Obj.Name ] then
			if SceneObjCollision( TriggerObj, { CollisionPoint = Obj.Offset } ) then
				return true
			end			
		end
	end

	return false	
end
