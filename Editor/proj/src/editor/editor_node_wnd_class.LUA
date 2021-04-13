require( "src.editor.editor_wnd_class" )
require( "src.editor.editor_wnd_drag_helper" )


editor_node_wnd_class = class( editor_window, function( self )
	editor_window.init( self )
	
	self.WndName = "Node Editor"
	self.NodeList = {
		{
			Name = "START",
			Pos = { 100, 100 },
			Size = { 180, 150 },
			Inputs = {
				{
					Type = "",
					Name = "in",
				},
			},
			Outputs = {
				{
					Type = "",
					Name = "out1",
				},
				{
					Type = "",
					Name = "out2",
				},
			},
		},
	}
	
	self.ObjUnderCursor = nil
	self.SelectedObj = nil
	self.CopyedObj = nil

	self.OpenFile = ""
	self.IsSceneLinkMode = false	
end)


require( "src.editor.editor_node_wnd_class_logic" )


function editor_node_wnd_class:Init()
	LogE( "editor_node_wnd_class", "wrn" )
end


function editor_node_wnd_class:UpdateWnd()
	self:UpdateMode()
end


function editor_node_wnd_class:DrawWorkArea( WndPos )
	self:DrawWorkAreaMain()
end


function editor_node_wnd_class:DrawWorkAreaMain()
	self.ObjUnderCursor = nil
	for I, Node in pairs( self.NodeList ) do
		self:DrawWorkAreaNode( Node )
	end

	if self.DragLink then
		local PosM = Sub( { love.mouse.getPosition() }, self.WorkAreaPos )
		local ResPos = Mul( self.DragLink.PartPos, { self.CameraScale, self.CameraScale } )
		ResPos = Add( ResPos, self.CameraOffset )
		love.graphics.line( ResPos[ 1 ] + 10, ResPos[ 2 ] + 10, PosM[ 1 ], PosM[ 2 ] )
	end
end


function editor_node_wnd_class:DrawWorkAreaNode( Obj )
	local X = Obj.Pos[ 1 ] * self.CameraScale
	local Y = Obj.Pos[ 2 ] * self.CameraScale
	local W = Obj.Size[ 1 ] * self.CameraScale
	local H = Obj.Size[ 2 ] * self.CameraScale
	local Rx, Ry = 5, 5

	love.graphics.setColor( 90, 255, 90, 50 )	
	local BgX, BgY = X + self.CameraOffset[ 1 ], Y + self.CameraOffset[ 2 ]
	love.graphics.rectangle( "fill", BgX, BgY, W, H, Rx, Ry )
	if self.SelectedObj == Obj then
		love.graphics.rectangle( "line", BgX, BgY, W, H )
		love.graphics.rectangle( "line", BgX, BgY, W, H )
	end
	local HeadX, HeadY, HeadW, HeadH = self:GetObjElemRect( Obj, 'head' )
	love.graphics.rectangle( "fill", HeadX + BgX, HeadY + BgY, HeadW, HeadH )		
	
	love.graphics.setColor( 255, 255, 255, 250 )	
	love.graphics.print( Obj.Name, math.ceil( HeadX + 5 + BgX ), math.ceil( HeadY + 5 + BgY ) )

	local function DrawConn( Conn, Ind, Type )
		love.graphics.setColor( 90, 255, 90, 50 )
		local LocalConX, localConY, ConnW, ConnH = self:GetObjElemRect( Obj, Type, Ind )
		local ConnX, ConnY = LocalConX + BgX, localConY + BgY
		love.graphics.rectangle( "fill", ConnX, ConnY, ConnW, ConnH, Rx, Ry )		
		
		if self.CameraScale >= 1 and Conn.Name ~= "" then
			love.graphics.setColor( 255, 255, 255, 250 )
			local TextPosX = Type == "in" and ConnX + 25 or ConnX - 40
			local ConnText = ( Conn.Type ~= "" and Conn.Type .. " | " or "" ) .. Conn.Name
			love.graphics.printf( self:GetObjConnTextParam( ConnText, W, Type, { LocalConX, localConY }, { BgX, BgY } ) )
		end
	end

	for Ind, Connection in pairs( Obj.Inputs ) do
		DrawConn( Connection, Ind, "in" )
	end

	for Ind, Connection in pairs( Obj.Outputs ) do
		DrawConn( Connection, Ind, "out" )
		if Connection.Link then
			local Ox, Oy, Ow, Oh = self:GetObjElemRect( Connection.Link.NodeObj, 'in', Connection.Link.InIndex )
			local InX = ( Ox + Connection.Link.NodeObj.Pos[ 1 ] ) * self.CameraScale + self.CameraOffset[ 1 ]
			local InY = ( Oy + Connection.Link.NodeObj.Pos[ 2 ] ) * self.CameraScale + self.CameraOffset[ 2 ]
			local ConnX, ConnY, ConnW, ConnH = self:GetObjElemRect( Obj, 'out', Ind )
			love.graphics.line( ConnX + BgX + ConnW / 2, ConnY + BgY + ConnH / 2, InX + ConnW / 2, InY + ConnH / 2 )
		end
	end

	if CheckPointIn( { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] }, Obj.Pos, Obj.Size ) then
		self.ObjUnderCursor = Obj
	end
end


function editor_node_wnd_class:DrawParamPanel()	
	self:DrawParamPanelInfo()
	self:DrawParamPanelSettings()	
end


function editor_node_wnd_class:DrawParamPanelInfo()	
	if ( imgui.CollapsingHeader( "Info" ) ) then
		local Mx, My = love.mouse.getPosition()
		imgui.Text( "CameraCursorPos: ( " .. self.CameraMouseOffset[ 1 ] .. ", " .. self.CameraMouseOffset[ 2 ] .. " )" );
		imgui.Text( "CameraScale: " .. self.CameraScale )
		if self.ObjUnderCursor then
			imgui.Text( "ObjUnderCursor: " .. self.ObjUnderCursor.Name )
			imgui.Text( "ObjUnderCursor: " .. tostring( self.ObjUnderCursor ) )
		else
			imgui.Text( "no ObjUnderCursor" )
		end
	end
end


function editor_node_wnd_class:DrawParamPanelSettings()	
	if ( imgui.CollapsingHeader( "Settings" ) ) then
		local Status = nil
		if imgui.Checkbox("ShowRects", self.ShowRects ) then
			self.ShowRects = not self.ShowRects
		end
		imgui.SameLine()
		if imgui.Checkbox("ShowLayerRects", self.ShowLayerRects ) then
			self.ShowLayerRects = not self.ShowLayerRects
		end

		local Color = self.ClearColor
		status, Color[1], Color[2], Color[3] = imgui.ColorEdit3("Clear color", Color[1], Color[2], Color[3]);

		if imgui.Button("save") then			
			self:MapSave()
		end		
		imgui.SameLine()	
		if imgui.Button("save as") then	
			g_Editor:ShowDialogSaveAs( {
				CallbackSaveAs = function( Info )
					LogE( "Save " .. self.FileExtention .. " as: " .. Info.File )
					self:FileSave( Info.File .. "." .. self.FileExtention )
					g_Editor.FileSustem:Reload()
				end
			} )
		end
	end
end



function editor_node_wnd_class:DrawContextMenu()	
	if imgui.BeginPopupContextItem( "Area context menu" ) then  
		if self.SelectedObj and imgui.Selectable("Delete") then
			self:DelSelected()
		end
		if imgui.Selectable("Add node") then
			self:AddNode()
		end
		imgui.EndPopup()
	end
end