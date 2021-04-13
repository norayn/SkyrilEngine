

object_subscene = class( object_base, function( self )
	object_base.init( self )

	self.Name = "subscene"
	self.ObjType = OBJECT_TYPE_SUBSCENE
	--self.ParallaxK = { 1, 1 }

	self.MulColor = { 1, 1, 1, 1 }

	self.SubScene = nil
end)


function object_subscene:DrawData( Camera )
	self.SubScene.Camera.Offset[ 1 ] = Camera.Offset[ 1 ] + self.Offset[ 1 ]
	self.SubScene.Camera.Offset[ 2 ] = Camera.Offset[ 2 ] + self.Offset[ 2 ]
	self.SubScene.Camera.Scale = Camera.Scale
	self.SubScene:Draw()	
end


function object_subscene:Update( Delta )
	self.SubScene:Update( Delta )
end


function object_subscene:Load( FullName )
	self.SubSceneName = FullName
	
	local FileName = "proj/" .. FullName
	
	self.SubScene = scene()
	self.SubScene.Camera = camera()
	self.SubScene:Load( FullName )
	self.SubScene.IsSubScene = true
	self.SubScene.OwnerObj = self
	LogE( "Loaded subscene " .. FullName, "oft" )
end


function object_subscene:PrepareToSave()
	LogE( "SubScene PrepareToSave" )
	if self.SubScene then
		scene:PrepareToSave( self.SubScene )
		self.SubScene.OwnerObj = nil
	end
end
