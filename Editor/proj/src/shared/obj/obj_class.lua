OBJECT_TYPE_NONE		= 1
OBJECT_TYPE_PROPS		= 2					
OBJECT_TYPE_COLLISION	= 3
OBJECT_TYPE_LIGHT		= 4
OBJECT_TYPE_TRIGGER		= 5
OBJECT_TYPE_ACTOR		= 6
OBJECT_TYPE_ANIMATION	= 7
OBJECT_TYPE_SUBSCENE	= 8
OBJECT_TYPE_TEXT		= 9

OBJECT_TYPE_COUNT		= 8

ObjectTypeToString = {}
ObjectTypeToString[ OBJECT_TYPE_NONE ]		 = "NONE"
ObjectTypeToString[ OBJECT_TYPE_PROPS ]		 = "PROPS"
ObjectTypeToString[ OBJECT_TYPE_COLLISION ]	 = "COLLISION"
ObjectTypeToString[ OBJECT_TYPE_LIGHT ]		 = "LIGHT"
ObjectTypeToString[ OBJECT_TYPE_TRIGGER ]	 = "TRIGGER"
ObjectTypeToString[ OBJECT_TYPE_ACTOR ]		 = "ACTOR"
ObjectTypeToString[ OBJECT_TYPE_ANIMATION ]	 = "ANIMATION"
ObjectTypeToString[ OBJECT_TYPE_SUBSCENE ]	 = "SUBSCENE"
ObjectTypeToString[ OBJECT_TYPE_TEXT ]		 = "TEXT"



object_base = class( function( self )
	self.Name = "object_base"
	self.ObjType = OBJECT_TYPE_NONE

	self.Offset = { 0, 0 }
	self.Size = { 10, 10 }
	self.Rotate = 0
	self.Z = 1	

	self.ResultOffset = { 0, 0 }		
	self.ResultScale = 1
	
	self.ObjectScriptFunc = nil
	self.ObjectScriptText = nil

	self.ScriptsLinkList = {}

	self.EditorVisible = true

	self.BornTime = love.timer.getTime()
end)


function object_base:UpdateBase( Scene, Delta )
	if self.ObjectScriptFunc then
		self.ObjectScriptFunc( { Scene = Scene, Obj = self, Delta = Delta } )
	end

	for _, ScriptLink in pairs( self.ScriptsLinkList ) do
		local Param = { Scene = Scene, Obj = self, Delta = Delta }
		g_ScrMgr:Call( ScriptLink, Param )
	end

	if self.Update then
		self:Update( Delta )
	end
end


function object_base:Draw( Camera )
	if not self.EditorVisible then
		return
	end

	local CameraOffset = Add( Camera.WndOffset, Camera.Offset )
	local ObjOffset = Mul( self.Offset, { Camera.Scale, Camera.Scale } )
	self.ResultOffset = Add( CameraOffset, ObjOffset )
	self.ResultScale = Camera.Scale

	if g_Editor then
		local IsSelected = ( self == g_Editor.SceneEditor.SelectedObj )
		if g_Editor.SceneEditor.ShowRects or IsSelected then
			self:DrawRect( Camera, IsSelected )
		end
	end

	self:DrawData( Camera )
end


function object_base:DrawData( Camera )

end


function object_base:DrawRect( Camera, IsSelected )
	--draw
	local RectType, AlphaColor = "line", 180 
	if IsSelected then
		love.graphics.setColor( 90, 255, 90, AlphaColor )		
	else
		love.graphics.setColor( 255, 255, 255, AlphaColor )
	end	

	if not self.Rotate or self.Rotate == 0 then
		local Pivot = self.Pivot or { 0.5, 0.5 }
		local PvtX, PvtY = self.Size[ 1 ] * Pivot[ 1 ] * Camera.Scale, self.Size[ 2 ] * Pivot[ 2 ] * Camera.Scale
		love.graphics.rectangle( RectType, self.ResultOffset[ 1 ] - PvtX, self.ResultOffset[ 2 ] - PvtY, 
			self.Size[ 1 ] * self.ResultScale, self.Size[ 2 ] * self.ResultScale )	
	else
		self:DrawAngleRect( Camera, self, RectType, self.ResultOffset[ 1 ], self.ResultOffset[ 2 ], 
			self.Size[ 1 ] * self.ResultScale, self.Size[ 2 ] * self.ResultScale )
	end
end


function object_base:OnObjOld( X, Y )
	ASSERT( self.Rotate == 0 )

	if X >= self.Offset[ 1 ] and X < self.Offset[ 1 ] + self.Size[ 1 ] 
	   and Y >= self.Offset[ 2 ] and Y < self.Offset[ 2 ] + self.Size[ 2 ] then
		return true
	else
		return false
	end
end


function object_base:OnObj( X, Y )
	if self.Rotate ~= 0 then
		local Res = RotatePoint( { X, Y }, -self.Rotate, self.Offset )
		X, Y = Res[ 1 ], Res[ 2 ]
	end
	
	local Pivot = self.Pivot or { 0.5, 0.5 }
	local PvtX, PvtY = self.Size[ 1 ] * Pivot[ 1 ], self.Size[ 2 ] * Pivot[ 2 ]
	if X >= self.Offset[ 1 ] - PvtX and X < self.Offset[ 1 ] + self.Size[ 1 ] - PvtX
	   and Y >= self.Offset[ 2 ] - PvtY and Y < self.Offset[ 2 ] + self.Size[ 2 ] - PvtY then
		return true
	else
		return false
	end
end


function object_base:DrawAngleRectOld( Obj, Mode, X, Y, W, H )
	local P1 = { 0, 0 }
	local P2 = RotatePoint( { W, 0 }, Obj.Rotate )
	local P3 = RotatePoint( { W, H }, Obj.Rotate )
	local P4 = RotatePoint( { 0, H }, Obj.Rotate )
	
	local Vertices = { 
		P1[ 1 ] + X, P1[ 2 ] + Y,
		P2[ 1 ] + X, P2[ 2 ] + Y,
		P3[ 1 ] + X, P3[ 2 ] + Y,
		P4[ 1 ] + X, P4[ 2 ] + Y,
	}

	love.graphics.polygon( Mode, Vertices )
end


function object_base:DrawAngleRect( Camera, Obj, Mode, X, Y, W, H )
	local Pivot = Obj.Pivot or { 0.5, 0.5 }
	local PvtX, PvtY = W * Pivot[ 1 ], H * Pivot[ 2 ]
	local P1 = RotatePoint( { 0 - PvtX, 0 - PvtY }, Obj.Rotate )
	local P2 = RotatePoint( { W - PvtX, 0 - PvtY }, Obj.Rotate )
	local P3 = RotatePoint( { W - PvtX, H - PvtY }, Obj.Rotate )
	local P4 = RotatePoint( { 0 - PvtX, H - PvtY }, Obj.Rotate )
	
	local Vertices = { 
		P1[ 1 ] + X, P1[ 2 ] + Y,
		P2[ 1 ] + X, P2[ 2 ] + Y,
		P3[ 1 ] + X, P3[ 2 ] + Y,
		P4[ 1 ] + X, P4[ 2 ] + Y,
	}

	love.graphics.polygon( Mode, Vertices )
end


function object_base:DrawEditorMapObjRects( Camera, Obj )	
	local X = Obj.GlobalPos[ 1 ] * self.ResultScale + self.ResultOffset[ 1 ]
	local Y = Obj.GlobalPos[ 2 ] * self.ResultScale + self.ResultOffset[ 2 ]
	local W = Obj.Size[ 1 ] * self.ResultScale
	local H = Obj.Size[ 2 ] * self.ResultScale

	if ( Obj.Type ~= MAP_TYPE_LAYER ) then
		local RectType = "fill"
		local Pivot = Obj.Pivot or { 0.5, 0.5 }
		local PvtX, PvtY = Obj.Size[ 1 ] * Pivot[ 1 ] * Camera.Scale, Obj.Size[ 2 ] * Pivot[ 2 ] * Camera.Scale
	
		if not Obj.Rotate or Obj.Rotate == 0 then
			love.graphics.rectangle( RectType, X - PvtX, Y - PvtY, W, H )		
		else
			self:DrawAngleRect( Camera, Obj, RectType, X, Y, W, H )
		end
	end

	if #Obj.Childs > 0 then
		for _, child_object in pairs( Obj.Childs ) do
			self:DrawEditorObjRect( Camera, child_object )
		end
	end
end


function object_base:AddScriptLink( Patch )
	table.insert( self.ScriptsLinkList, Patch )
end


function object_base:PrepareToSave()
	self.MapData = nil
	self.DynamicData = nil
end


function object_base:GetFirstMapDataObjByName( Name, Obj )
	if not Obj then
		Obj = self.MapData.RootObj
	end
	
	if Obj.Name == Name then
		return Obj
	end

	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			local ChildRes = object_base:GetFirstMapDataObjByName( Name, Obj.Childs[ I ] )
			if ChildRes then
				return ChildRes
			end			
		end
	end

	return nil	
end


--===============================================================================================
require( "src.shared.obj.props_obj_class" )
require( "src.shared.obj.actor_obj_class" )
require( "src.shared.obj.collision_obj_class" )
require( "src.shared.obj.trigger_obj_class" )
require( "src.shared.obj.animation_obj_class" )
require( "src.shared.obj.subscene_obj_class" )
require( "src.shared.obj.text_obj_class" )

function ObjectCreateByFile( FullPatch )
	ASSERT( FullPatch and FullPatch ~= "" )

	local Obj = {}
	local ObjData = {}

	local FileName = "proj/" .. FullPatch
	ObjData = table.read( FileName ) 

	local ObjTypeValid = false
	if ObjData.ObjType == OBJECT_TYPE_PROPS then
		Obj = object_props()
		Obj.MapDataName = FullPatch
		Obj.MapData = ObjData
		Obj.Size = ObjData.RootObj.Size	
		ObjTypeValid = true	
	end
	if ObjData.ObjType == OBJECT_TYPE_ANIMATION then
		Obj = object_animation()
		Obj.MapDataName = FullPatch
		Obj.MapData = ObjData
		Obj.Size = ObjData.RootObj.Size	
		MapObjRestoreAfterSave( Obj.MapData.RootObj )
		ObjTypeValid = true	
	end
	if ObjData.ObjType == OBJECT_TYPE_COLLISION then
		Obj = object_collision()
		Obj.MapDataName = FullPatch
		Obj.MapData = ObjData
		Obj.Size = ObjData.RootObj.Size	
		ObjTypeValid = true	
	end
	if ObjData.ObjType == OBJECT_TYPE_TRIGGER then
		Obj = object_trigger()
		Obj.MapDataName = FullPatch
		Obj.MapData = ObjData
		Obj.Size = ObjData.RootObj.Size	
		ObjTypeValid = true	
	end
	--if ObjData.ObjType == OBJECT_TYPE_SUBSCENE then
	--	Obj = object_subscene()
	--	Obj.SubSceneName = FullPatch
	--	Obj:Load( File )
	--	ObjTypeValid = true	
	--end
	if ObjData.ObjType == OBJECT_TYPE_ACTOR then
		ASSERT( 0, "TODO LOAD OBJ ACTOR" )
		ObjTypeValid = true	
	end

	if not ObjTypeValid then
		ASSERT( 0, "no obj tupe ind " .. ObjData.ObjType )
	end

	return Obj
end

