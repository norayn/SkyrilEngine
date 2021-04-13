require( "src.shared.map_class" )
require( "src.shared.obj.obj_class" )


scene = class( function( self )
	self.Name = "default"

	--self.CameraPos = { 0, 0 }	
	--self.Size = { 100, 50 }

	self.Camera = nil
	self.Maps = {}
	self.Objects = {}

	--self.Objects[ 1 ] = object_actor()
	self.IsSubScene = false

	self.IsRunUpdate = true
end)


require( "src.shared.scene_class_collision" )


function scene:Draw()
	ASSERT( self.Camera, "scene " .. self.Name .. " no has camera" )

	if self.IsSubScene then			--draw subscene--
		for _, Obj in pairs( self.Objects ) do
			Obj:Draw( self.Camera )
		end			
	else							--draw scene--
		--get obj to draw
		local DrawObjects = {}
		--TODO ADD IN CAMERA CHECK
		for _, Map in pairs( self.Maps ) do
			if not Map.Z then Map.Z = 0 end	--temp
			DrawObjects[ #DrawObjects + 1 ] = Map
		end	
		for _, Obj in pairs( self.Objects ) do
			if not Obj.Z then Obj.Z = 0 end	--temp
			
			if not g_Editor then
				DrawObjects[ #DrawObjects + 1 ] = Obj
			else
				if not g_Editor.SceneEditor.HideObjTypes[ Obj.ObjType ] then
					DrawObjects[ #DrawObjects + 1 ] = Obj
				end
			end
		end	
		
		--sort Z
		table.sort( DrawObjects, function( A, B ) return A.Z < B.Z end )
		
		--dracw
		for _, DrawObj in pairs( DrawObjects ) do
			DrawObj:Draw( self.Camera )
		end	


		if g_Editor then
			self.Camera:DrawEditorRect()
		end
	end
end


function scene:Update( Delta )
	if not self.IsRunUpdate then	return	end
	
	local ObjToDelInd = {}
	for Ind, Obj in pairs( self.Objects ) do
		Obj:UpdateBase( self, Delta )

		if Obj.LifeTime then
			Obj.LifeTime = Obj.LifeTime - Delta
			if Obj.LifeTime < 0 then
				table.insert( ObjToDelInd, Ind )
			end
		end
	end

	for I = #ObjToDelInd, 1, -1 do
		LogE( "Remove from scene " .. self.Objects[ ObjToDelInd[ I ] ].Name )
		table.remove( self.Objects, ObjToDelInd[ I ] )
	end
end


function scene:AddObj( Obj )
	ASSERT( Obj )
	table.insert( self.Objects, Obj )
end


function scene:DelObj( Obj )
	ASSERT( Obj )
	for I = 1, #self.Objects do
		if self.Objects[ I ] == Obj then
			table.remove ( self.Objects, I )
			return
		end
	end
	ASSERT( false, "no find obj by del of sceene" )
end


function scene:AddMap( Map )
	ASSERT( Map )
	table.insert( self.Maps, Map )
end


function scene:DelMap( Map )
	ASSERT( Map )
	for I = 1, #self.Maps do
		if self.Maps[ I ] == Map then
			table.remove ( self.Maps, I )
			return
		end
	end
	ASSERT( false, "no find map by del of sceene" )
end


function scene:PrepareToSave( Scene )
	for _, Map in pairs( Scene.Maps ) do
		Map.MapData = nil
	end	
	for _, Obj in pairs( Scene.Objects ) do
		Obj:PrepareToSave()
	end	
end


function scene:Save( FileName )
	if FileName == "" then
		g_Editor:ShowPopUpMsg( "no FileName" )
		return
	end	

	local SaveScene = deepcopy( self )
	self:PrepareToSave( SaveScene )
	
	table.save( SaveScene, "proj/" .. FileName )

	g_Editor:ShowPopUpMsg( "Save ok" )
	LogE( "Save scene " .. FileName )
end


function scene:Load( FileName )
	if FileName == "" then
		g_Editor:ShowPopUpMsg( "no FileName" )
		return
	end

	LogE( "Load scene " .. FileName .. " start" )

	local Scene = table.read( "proj/" .. FileName ) 

	--RestoreAfterSave
	local MapClass = map()	
	for _, Map in pairs( Scene.Maps ) do
		setmetatable( Map, getmetatable( MapClass ) )
		Map:Load( Map.MapDataName )
	end	

	
	for _, Obj in pairs( Scene.Objects ) do
		if Obj.ObjType == OBJECT_TYPE_PROPS then
			local ObjClass = object_props()	
			setmetatable( Obj, getmetatable( ObjClass ) )
			Obj:Load( Obj.MapDataName )
		elseif Obj.ObjType == OBJECT_TYPE_TRIGGER then
			local ObjClass = object_trigger()	
			setmetatable( Obj, getmetatable( ObjClass ) )
			Obj:Load( Obj.MapDataName )
		elseif Obj.ObjType == OBJECT_TYPE_COLLISION then
			local ObjClass = object_collision()	
			setmetatable( Obj, getmetatable( ObjClass ) )
			Obj:Load( Obj.MapDataName )
		elseif Obj.ObjType == OBJECT_TYPE_ANIMATION then
			local ObjClass = object_animation()	
			setmetatable( Obj, getmetatable( ObjClass ) )
			Obj:Load( Obj.MapDataName )
			MapObjRestoreAfterSave( Obj.MapData.RootObj )
		elseif Obj.ObjType == OBJECT_TYPE_ACTOR then
			local ObjClass = object_actor()	
			setmetatable( Obj, getmetatable( ObjClass ) )
			LogE( "WARNING no load actor funk", "atn" )	
		elseif Obj.ObjType == OBJECT_TYPE_SUBSCENE then
			local ObjClass = object_subscene()	
			setmetatable( Obj, getmetatable( ObjClass ) )
			Obj:Load( Obj.SubSceneName )
		elseif Obj.ObjType == OBJECT_TYPE_TEXT then
			local ObjClass = object_text()	
			setmetatable( Obj, getmetatable( ObjClass ) )
		else
			ASSERT( 0, "uncnow obj type " .. Obj.ObjType )
		end
	end	

	local CameraClass = camera()
	setmetatable( Scene.Camera, getmetatable( CameraClass ) )	

	for k, v in pairs( Scene ) do
		self[ k ] = Scene[ k ]
	end

	LogE( "Load map count: " .. #self.Maps, "oft" )	
	LogE( "Load obj count: " .. #self.Objects, "oft" )			
	LogE( "Load scene done" )
end


function scene:GetFirstObjectByName( Name )
	for _, Obj in pairs( self.Objects ) do
		if Obj.Name == Name then
			return Obj
		end
	end

	return nil	
end