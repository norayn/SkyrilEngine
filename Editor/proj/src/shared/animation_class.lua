animation_base = class( function( self )
	self.Name = "animation"
	self.Type = "animation_none"
	self.FileName = nil
	--self.Offset = { 0, 0 }
	
	self.Scale = 1	
	self.LastUpdateTime = love.timer.getTime( )	--second	
	self.CurrentTime = 0	--second	
	self.DurationTime = 1	--second
	self.IsRepeat = true	
	self.IsComplete = false
	self.IsFlipH = false
	self.IsFlipV = false		
end)


function animation_base:Update( Dt ) 
	local DeltaTime = Dt or love.timer.getTime() - self.LastUpdateTime
	self.LastUpdateTime = love.timer.getTime()
	local IsRestartAnimation = false

	self.CurrentTime = self.CurrentTime + DeltaTime

	if self.CurrentTime > self.DurationTime then
		if self.IsRepeat then
			self.CurrentTime = self.CurrentTime - self.DurationTime
			IsRestartAnimation = true
		else
			self.IsComplete = true
		end
	end

	if not self.IsComplete then
		self:UpdateFrame( IsRestartAnimation )
	end
end


function RestoreAnimationAfterSaveObj( Animation ) 
	if Animation.Type == "animation_sprite" then
		local ObjClass = animation_sprite()	
		setmetatable( Animation, getmetatable( ObjClass ) )
	else
		assert( false, "Animation.Type " .. Animation.Type )
	end

	Animation:Load( Animation.FileName )
end


animation_sprite = class( animation_base, function( self )
	animation_base.init( self )
	self.Type = "animation_sprite"
	
	self.CurrentFrameInd = 1
		
	self.Frames = {
		--{
		--	Time = 0,
		--	Image = nil,
		--	Quad = nil,
		--},
	}
			
end)


function animation_sprite:UpdateFrame( IsRestartAnimation ) 
	if IsRestartAnimation then 
		self.CurrentFrameInd = 1
		return
	end
	
	local NextFrameInd = self.CurrentFrameInd + 1
	if NextFrameInd > #self.Frames then 
		return
	end
	--LogE( "self.CurrentTime = " .. self.CurrentTime, "atn" )
	local NextFrame = self.Frames[ NextFrameInd ]
	--LogE( "NextFrame.Time[" .. NextFrameInd .. "] = " .. NextFrame.Time, "atn" )	
	if NextFrame.Time < self.CurrentTime then
		self.CurrentFrameInd = NextFrameInd
		self:UpdateFrame( false ) 
	end
	--LogE( "self.CurrentFrameInd = " .. self.CurrentFrameInd, "atn" )
	--	0	1	2	3	4	5	0	1	2	3	4	5	0
	--------------------------------------------------------
end


function animation_sprite:SetAnimationTime( Time ) 
	self.CurrentTime = Time	
	for Ind, Frame in pairs( self.Frames ) do
		if Frame.Time < self.CurrentTime then
			self.CurrentFrameInd = Ind
		end
	end
end


function animation_sprite:GetCurrentFrame() 
	return self.Frames[ self.CurrentFrameInd ]	
end


function animation_sprite:PrepareToSaveObj() 
	self.Frames = {}
end


function animation_sprite:Save( FileName ) 
	local SaveData = deepcopy( self )
	for _, Frame in pairs( SaveData.Frames ) do
		Frame.Quad = nil
	end	
	
	if FileName == "" then
		g_Editor:ShowPopUpMsg( "no FileName" )
		return
	end
	table.save( SaveData, "proj/" .. FileName )

	g_Editor:ShowPopUpMsg( "Save ok" )
	LogE( "Save sprite animation " .. FileName )
end


function animation_sprite:Load( FileName )
	if FileName == "" then
		g_Editor:ShowPopUpMsg( "no FileName" )
		return
	end

	self.FileName = FileName
	local Anim = table.read( "proj/" .. FileName ) 

	--RestoreAfterSave
	for _, Frame in pairs( Anim.Frames ) do
		local Tex = g_ResMgr:GetImage( Frame.TexName )
		Frame.Quad = g_ResMgr:GethQuad( Tex, Frame.TexRect )
	end	

	for k, v in pairs( Anim ) do
		self[ k ] = Anim[ k ]
	end

	self.CurrentTime = 0
	self.IsComplete = false				
	LogE( "Load sprite animation " .. FileName .. " done" )
end