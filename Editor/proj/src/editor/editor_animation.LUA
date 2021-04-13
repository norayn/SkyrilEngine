
require( "src.editor.editor_wnd_class" )

local AnimationEditor = editor_window()
g_Editor.AnimationEditor = AnimationEditor

require( "src.shared.animation_class" )

AnimationEditor.WndName = "Animation Editor"
AnimationEditor.Visible = false

AnimationEditor.OpenFile = ""

AnimationEditor.ShowRects = true
AnimationEditor.RunAnimation = false

AnimationEditor.AreaPos = { 10, 300 }
AnimationEditor.AreaSize = { 600, 200 }
AnimationEditor.TimeSkale = 1

AnimationEditor.TimeCursorPos = { 0, 0 }
AnimationEditor.PreViewSize = { 60, 36 }

AnimationEditor.SelectedFrame = nil


function AnimationEditor:Init()
	self.Anim = animation_sprite()
	self.TimeCursorHelper = wnd_drag_helper()
	self.TimeCursorHelper.Helpers[ 1 ] = {
		Offset = { 0, -22 },
		Size = { 20, 20 },
		Text = "T",
		MoveFunc = function( Offset )
			local PosX = self.TimeCursorPos[ 1 ] + Offset[ 1 ] - self.CameraOffset[ 1 ]
			self.Anim:SetAnimationTime( PosX / self.AreaSize[ 1 ] / self.TimeSkale * self.Anim.DurationTime )
		end,
	}

	self.SelectedFrameHelper = wnd_drag_helper()
	self.SelectedFrameHelper.Helpers[ 1 ] = {
		Offset = { 0, -2 },
		Size = { 20, 20 },
		Text = "M",
		MoveFunc = function( Offset )
			local PosX = self:GetFramePos( self.SelectedFrame )[ 1 ] + Offset[ 1 ] - self.CameraOffset[ 1 ] - self.AreaPos[ 1 ]
			self.SelectedFrame.Time = PosX / self.AreaSize[ 1 ] / self.TimeSkale * self.Anim.DurationTime
			table.sort( self.Anim.Frames, function( A, B ) return A.Time < B.Time end )
		end,
	}

	LogE( "AnimationEditor ready", "atn" )
end


function AnimationEditor:Close()
	AnimationEditor.Visible = false
end


function AnimationEditor:GetFramePos( Frame )
	local X = Frame.Time / self.Anim.DurationTime * self.AreaSize[ 1 ] * self.TimeSkale + self.CameraOffset[ 1 ]
	return { X + self.AreaPos[ 1 ], self.AreaPos[ 2 ] + 30 }
end


function AnimationEditor:UpdateWnd()
	if self.RunAnimation then
		self.Anim:Update( love.timer.getDelta( ) )
	end
	
	local X = self.Anim.CurrentTime / self.Anim.DurationTime * self.AreaSize[ 1 ] * self.TimeSkale + self.CameraOffset[ 1 ]
	self.TimeCursorPos = { X + self.AreaPos[ 1 ] - 10, self.AreaPos[ 2 ] + 5 }
		
	self.TimeCursorHelper:SetPosData{
		Pos = self.TimeCursorPos,
		CameraScale = 1,
		CameraOffset = { 0, 0 },
		WndOffset = self.WorkAreaPos,
	}

	if self.SelectedFrame then
		self.SelectedFrameHelper.Visible = true
		
		self.SelectedFrameHelper:SetPosData{
			Pos = self:GetFramePos( self.SelectedFrame ),
			CameraScale = 1,
			CameraOffset = { 0, 0 },
			WndOffset = self.WorkAreaPos,
		}
	else
		self.SelectedFrameHelper.Visible = false
	end


	if self.MouseSelectPresKeyDown then
		for k, Frame in pairs( self.Anim.Frames ) do
			local CurCoord = { self.MouseSelectPresCoord[ 1 ] - self.WorkAreaPos[ 1 ], self.MouseSelectPresCoord[ 2 ] - self.WorkAreaPos[ 2 ] }
			if CheckPointIn( CurCoord, self:GetFramePos( Frame ), AnimationEditor.PreViewSize ) then
				self.SelectedFrame = Frame
			end
		end
	end
end


function AnimationEditor:DrawWorkArea( WndPos )
	local WndW, WndH = imgui.GetWindowSize()
	
	--timeline	
	self.AreaPos = { 10, WndH / 3 * 2 }
	self.AreaSize = { WndW - 20, WndH / 3 - 10 }
	local APos = self.AreaPos
	local ASize = self.AreaSize
	AnimationEditor.TimeSkale = self.CameraScale

	local OfsX = self.CameraOffset[ 1 ]

	love.graphics.setColor( 255, 255, 255, AlphaColor )		
	love.graphics.rectangle( "line", APos[ 1 ], APos[ 2 ], ASize[ 1 ], ASize[ 2 ] )
	love.graphics.rectangle( "line", APos[ 1 ], APos[ 2 ] + 25, ASize[ 1 ], 5 )

	love.graphics.setColor( 255, 255, 255, 111 )	
	love.graphics.rectangle( "fill", self.TimeCursorPos[ 1 ], self.TimeCursorPos[ 2 ], 20, 20 )
	love.graphics.setColor( 255, 255, 255, 255 )	

	for k, Frame in pairs( self.Anim.Frames ) do		
		local X = Frame.Time / self.Anim.DurationTime * ASize[ 1 ] * self.TimeSkale + OfsX
		local Pos = self:GetFramePos( Frame )
		
		love.graphics.rectangle( "fill", X + APos[ 1 ], APos[ 2 ] + 30, 5, 25 )
		love.graphics.print( string.format( "%.2f", Frame.Time ), X + APos[ 1 ], APos[ 2 ] + 10 )

		local Tex = g_ResMgr:GetImage( Frame.TexName )
		local StSlX, StSlY = AnimationEditor.PreViewSize[ 1 ] / Frame.TexRect[ 3 ], AnimationEditor.PreViewSize[ 2 ] / Frame.TexRect[ 4 ]		
		love.graphics.draw( Tex, Frame.Quad, Pos[ 1 ], Pos[ 2 ], 0, StSlX, StSlY )
	end

	--preview
	if #self.Anim.Frames > 0 then
		local Frame = self.Anim:GetCurrentFrame() 
		local AnimPos = { WndW / 2, WndH / 3 }
		Tex = g_ResMgr:GetImage( Frame.TexName )	
		love.graphics.draw( Tex, Frame.Quad, AnimPos[ 1 ], AnimPos[ 2 ], 0, 1, 1 )
	end

	self.TimeCursorHelper:Draw()
	self.SelectedFrameHelper:Draw()
end


function AnimationEditor:DrawParamPanel()	
	local Status = nil
	
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );
		imgui.Text( "CameraScale: " .. self.CameraScale )
	end
	
	if ( imgui.CollapsingHeader( "Animation" ) ) then
		if imgui.Button("Add frame" ) then
			self:AddFrameFromAtlas()
		end
		imgui.SameLine()
		if imgui.Button("del selected frame" ) then	
			self:DelSlectedFrame()
		end

		if imgui.Button("Play" ) then
			self.RunAnimation = true
		end
		imgui.SameLine()
		if imgui.Button("Pause" ) then			
			self.RunAnimation = false
		end
		imgui.SameLine()
		if imgui.Checkbox("RunAnimation", self.RunAnimation ) then
			self.RunAnimation = not self.RunAnimation
		end

		status, self.Anim.DurationTime = imgui.DragFloat("##Duration", self.Anim.DurationTime, 0.01 , 0, 99999, "Duration Time = %.2f" )
	
		if imgui.Button("Normalize sprite timeline" ) then	
			local TimeStep = self.Anim.DurationTime / #self.Anim.Frames
			for I = 1, #self.Anim.Frames do
				self.Anim.Frames[ I ].Time = TimeStep * ( I - 1 )
			end

			table.sort( self.Anim.Frames, function( A, B ) return A.Time < B.Time end )
		end	
	end
				
	if ( imgui.CollapsingHeader( "Settings" ) ) then
		if imgui.Checkbox("ShowRects", self.ShowRects ) then
			self.ShowRects = not self.ShowRects
		end

		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3]  = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3] );

		if imgui.Button("Save" ) then
			self:Save()
		end
		imgui.SameLine()
		if imgui.Button("SaveAs" ) then
			self:SaveAs()
		end
		if imgui.Button("Close animation" ) then
			self.OpenFile = ""
			self.ShowRects = true
			self.RunAnimation = false					
			self.TimeSkale = 1			
			self.TimeCursorPos = { 0, 0 }			
			self.SelectedFrame = nil
			self.Anim = nil
			self.Anim = animation_sprite()
		end
	end
end


function AnimationEditor:DrawContextMenu()	
	if imgui.BeginPopupContextItem( "Area context menu" ) then  
		if self.SelectedFrame and imgui.Selectable("Delete") then
			self:DelSlectedFrame()
		end
		if imgui.Selectable("Set to PI") then value = 3.1415 end
		imgui.EndPopup()
	end
end


function AnimationEditor:AddFrameFromAtlas()
	local SubTexName = g_Editor.AtlasEditor.SelectedSpriteName
	local ImageName = g_Editor.AtlasEditor.SelectedFile
	
	if SubTex[ SubTexName ] == nil then
		g_Editor:ShowPopUpMsg( "no selekted tex" )
		return
	end

	local Frame = {}
	Frame.TexName = ImageName
	Frame.SubTexName = SubTexName
	Frame.TexRect = {}
	Frame.TexRect[ 1 ] = SubTex[ SubTexName ].Coord[ 1 ]
	Frame.TexRect[ 2 ] = SubTex[ SubTexName ].Coord[ 2 ]
	Frame.TexRect[ 3 ] = SubTex[ SubTexName ].Coord[ 3 ]
	Frame.TexRect[ 4 ] = SubTex[ SubTexName ].Coord[ 4 ]
	local Tex = g_ResMgr:GetImage( ImageName )
	Frame.Quad = g_ResMgr:GethQuad( Tex, SubTex[ SubTexName ].Coord )
	
	if #self.Anim.Frames == 0 then
		Frame.Time = 0
	else
		Frame.Time = self.Anim.Frames[ #self.Anim.Frames ].Time + 0.2
	end

	table.insert( self.Anim.Frames, Frame )
end


function AnimationEditor:DelSlectedFrame()		
	for k, Frame in pairs( self.Anim.Frames ) do				
		if self.SelectedFrame == Frame then
			table.remove( self.Anim.Frames, k )
			break
		end
	end		
end


function AnimationEditor:Load()
	if self.OpenFile == "" then
		g_Editor:ShowPopUpMsg( "No Open File" )
	else
		self.Anim:Load( self.OpenFile )
	end			
end


function AnimationEditor:Save()
	if self.OpenFile == "" then
		g_Editor:ShowPopUpMsg( "No Open File" )
	else
		self.Anim:Save( self.OpenFile )
	end			
end


function AnimationEditor:SaveAs()
	g_Editor:ShowDialogSaveAs( {
		CallbackSaveAs = function( Info )
			LogE( "Save " .. "sprite animation" .. " as: " .. Info.File )
			self.Anim:Save( Info.File .. ".asp" )
			self.OpenFile = Info.File .. ".asp"			
			g_Editor.FileSustem:Reload()
		end
	} )	
end