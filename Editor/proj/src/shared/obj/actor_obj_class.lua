

object_actor = class( object_base, function( self )
	object_base.init( self )

	self.Name = "actor"
	self.ObjType = OBJECT_TYPE_ACTOR
	--self.ParallaxK = { 1, 1 }

	--self.MulColor = { 1, 1, 1, 1 }

	self.MapData = nil
	self.MapDataName = nil	
end)


function object_actor:DrawData( Camera )
	--self:DrawDataObj( self.MapData.RootObj )
end


function object_actor:Update( Delta )
	if love.keyboard.isDown("up") then
        self.Offset[ 2 ]  = self.Offset[ 2 ] - ( Delta * 50 )
    end
	if love.keyboard.isDown("down") then
        self.Offset[ 2 ]  = self.Offset[ 2 ] + ( Delta * 50 )
    end
	if love.keyboard.isDown("left") then
        self.Offset[ 1 ]  = self.Offset[ 1 ] - ( Delta * 50 )
    end
	if love.keyboard.isDown("right") then
        self.Offset[ 1 ]  = self.Offset[ 1 ] + ( Delta * 50 )
    end

	---old test!!!
	--if ( g_Editor.SceneEditor.Scene:CheckCollision( {
	--	CollisionPoint = self.Offset,
	--} ) ) then
	--	LogE( "actor collision test", "err" )
	--end

end


function object_actor:Load( FullName )
	self.MapDataName = FullName
	
	local FileName = "proj/" .. FullName
	self.MapData = table.read( FileName ) 

	LogE( "Loaded props " .. FullName, "oft" )
end

