

function editor_node_wnd_class:UpdateMode()
	local function GetPartUnderCursor( Obj )
		local CurLocalPos = Sub( self.CameraMouseOffset, Obj.Pos )
	
		local Ox, Oy, Ow, Oh = self:GetObjElemRect( Obj, 'head' )			
		if CheckPointIn( { CurLocalPos[ 1 ], CurLocalPos[ 2 ] }, { Ox, Oy }, { Ow, Oh } ) then				
			return { Obj = Obj, Type = 'head', IndexParam = nil, PartPos = Add( Obj.Pos, { Ox, Oy } ) } 
		end
		for I = 1, #Obj.Inputs do
			Ox, Oy, Ow, Oh = self:GetObjElemRect( Obj, 'in', I )			
			if CheckPointIn( { CurLocalPos[ 1 ], CurLocalPos[ 2 ] }, { Ox, Oy }, { Ow, Oh } ) then
				return { Obj = Obj, Type = 'in', IndexParam = I, PartPos = Add( Obj.Pos, { Ox, Oy } ) } 
			end			
		end	
		for I = 1, #Obj.Outputs do
			Ox, Oy, Ow, Oh = self:GetObjElemRect( Obj, 'out', I )			
			if CheckPointIn( { CurLocalPos[ 1 ], CurLocalPos[ 2 ] }, { Ox, Oy }, { Ow, Oh } ) then
				return { Obj = Obj, Type = 'out', IndexParam = I, PartPos = Add( Obj.Pos, { Ox, Oy } ) } 
			end			
		end	

		return nil
	end

	local function GetPartTextUnderCursor( Obj )
		local CurLocalPos = Sub( self.CameraMouseOffset, Obj.Pos )

		for I = 1, #Obj.Inputs do
			local Ox, Oy, Ow, Oh = self:GetObjElemRect( Obj, 'in', I )
			local Tx, Ty, Tw, Th = self:GetObjConnTextPosAndWidth( Obj.Size[ 1 ], 'in', { Ox, Oy } )		
			if CheckPointIn( { CurLocalPos[ 1 ], CurLocalPos[ 2 ] }, { Tx, Ty }, { Tw, Th } ) then
				return { Obj = Obj, Type = 'in', TextTab = Obj.Inputs, IndexParam = I } 
			end			
		end	
		for I = 1, #Obj.Outputs do
			local Ox, Oy, Ow, Oh = self:GetObjElemRect( Obj, 'out', I )
			local Tx, Ty, Tw, Th = self:GetObjConnTextPosAndWidth( Obj.Size[ 1 ], 'out', { Ox, Oy } )		
			if CheckPointIn( { CurLocalPos[ 1 ], CurLocalPos[ 2 ] }, { Tx, Ty }, { Tw, Th } ) then
				return { Obj = Obj, Type = 'out', TextTab = Obj.Outputs, IndexParam = I } 
			end			
		end	

		return nil
	end	

	if love.mouse.isDown( 1 ) then
		if self.ObjUnderCursor then
			local PartUnderCursor = GetPartUnderCursor( self.ObjUnderCursor )
			self.PartUnderCursor = PartUnderCursor
			self.PartTextUnderCursor = GetPartTextUnderCursor( self.ObjUnderCursor )
			if not self.MouseIsDown and PartUnderCursor and PartUnderCursor.Type == 'head' then
				self.MouseLastPos = { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] }
				self.DragObj = self.ObjUnderCursor
			end

			if not self.MouseIsDown and PartUnderCursor and ( PartUnderCursor.Type == 'in' or PartUnderCursor.Type == 'out' ) then
				self.MouseLastPos = { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] }
				self.DragLink = PartUnderCursor
			end
		end
				
		self.MouseIsDown = true
	else
		self.DragObj = nil		
		self.MouseIsDown = false

		if self.DragLink then
			if self.ObjUnderCursor then
				local PartUnderCursor = GetPartUnderCursor( self.ObjUnderCursor )
				if PartUnderCursor and ( PartUnderCursor.Type == 'in' or PartUnderCursor.Type == 'out' ) then
					if self.DragLink.Type == 'out' then
						self.DragLink.Obj.Outputs[ self.DragLink.IndexParam ].Link = { 
							NodeObj = self.ObjUnderCursor,
							InIndex = PartUnderCursor.IndexParam
						}
					end	
				end
			else
				self.DragLink.Obj.Outputs[ self.DragLink.IndexParam ].Link = nil				
			end	

			self.DragLink = nil		
		end
	end

	if self.DragObj then
		local MouseOffset = Sub( self.CameraMouseOffset, self.MouseLastPos )
		self.DragObj.Pos = Add( self.DragObj.Pos, MouseOffset )
		self.MouseLastPos = { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] }
	end
end


function editor_node_wnd_class:SelectObject( Obj )	
	self.SelectedObj = Obj
end


function editor_node_wnd_class:MainClick()	
	self:SelectObject( self.ObjUnderCursor )
end


function editor_node_wnd_class:DelSelected()
	local Obj = self.SelectedObj
	if Obj then	
		local SelectNodeInd = 0
		for NodeInd, Node in pairs( self.NodeList ) do
			if Node == Obj then
				SelectNodeInd = NodeInd
			end
			for _, Connection in pairs( Node.Outputs ) do 
				if Connection.Link and Connection.Link.NodeObj == Obj then
					Connection.Link = nil
				end
			end
		end

		self.NodeList[ SelectNodeInd ] = nil
		self.SelectedObj = nil	
	else
		g_Editor:ShowPopUpMsg( "No selected obj" )	
	end	
end


function editor_node_wnd_class:AddNode()
	local Node = {
		Name = "NewNode",
		Pos = { self.CameraMouseOffset[ 1 ], self.CameraMouseOffset[ 2 ] },
		Size = { 180, 150 },
		Inputs = {
			{
				Type = "",
				Name = "inn",
			},
		},
		Outputs = {
			{
				Type = "",
				Name = "out",
			},
		},
	}
	self:UpdateNodeH( Node )
	table.insert( self.NodeList, Node )
end


function editor_node_wnd_class:GetObjElemRect( Obj, Type, ConnInd )
	local BorderOffs, HeadH = 5, 20
	local ConnW, ConnH = 20, 20
	local W, H = Obj.Size[ 1 ], Obj.Size[ 2 ]
	local Rx, Ry, Rw, Rh

	if Type == "head" then
		Rx, Ry, Rw, Rh = BorderOffs, BorderOffs, W - BorderOffs * 2, HeadH
	end
	if Type == "in" then
		Rx, Ry, Rw, Rh = BorderOffs, ( BorderOffs * 2 + HeadH ) * ConnInd, ConnW, ConnH
	end
	if Type == "out" then
		if self.IsShiftOutputs then ConnInd = ConnInd + #Obj.Inputs end
		Rx, Ry, Rw, Rh = W - ConnW - BorderOffs, ( BorderOffs * 2 + HeadH ) * ConnInd, ConnW, ConnH	
	end
	return Rx * self.CameraScale, Ry * self.CameraScale, Rw * self.CameraScale, Rh * self.CameraScale
end


function editor_node_wnd_class:GetObjConnTextPosAndWidth( ObjW, Type, ConnPos )
	local BorderOffs, HeadH = 5, 20
	local ConnW, ConnH = 20, 20

	if Type == "in" then
		local X, Y = ConnPos[ 1 ] + ConnW + BorderOffs, ConnPos[ 2 ] + BorderOffs
		local Limit = ObjW / 2 - ConnW - BorderOffs * 3
		if self.IsShiftOutputs then
			Limit = ObjW - ConnW - BorderOffs * 3
		end	
		
		return X, Y, Limit, ConnH
	end

	if Type == "out" then
		local X, Y = ObjW / 2 + BorderOffs, ConnPos[ 2 ] + BorderOffs
		local Limit = ObjW / 2 - ConnW - BorderOffs * 3
		if self.IsShiftOutputs then
			X, Y = BorderOffs, ConnPos[ 2 ] + BorderOffs
			Limit = ObjW - ConnW - BorderOffs * 3
		end
		
		return X, Y, Limit, ConnH
	end
end


function editor_node_wnd_class:GetObjConnTextParam( Text, ObjW, Type, ConnPos, Offset )
	if Type == "in" then
		local X, Y, Limit = self:GetObjConnTextPosAndWidth( ObjW, Type, ConnPos )	
		local With, WrappedText = love.graphics.getFont():getWrap( Text, Limit )
		return WrappedText[ 1 ], math.ceil( X + Offset[ 1 ] ), math.ceil( Y + Offset[ 2 ] ), Limit, "left"
	end

	if Type == "out" then
		local X, Y, Limit = self:GetObjConnTextPosAndWidth( ObjW, Type, ConnPos )	
		local With, WrappedText = love.graphics.getFont():getWrap( Text, Limit )
		return WrappedText[ 1 ], math.ceil( X + Offset[ 1 ] ), math.ceil( Y + Offset[ 2 ] ), Limit, "right"
	end
end


function editor_node_wnd_class:UpdateNodeH( Obj )
	local BorderOffs, HeadH = 5, 20
	local ConnW, ConnH = 20, 20

	local Ch = ConnH + BorderOffs + BorderOffs
	local Hh = HeadH + BorderOffs

	if self.IsShiftOutputs then
		Obj.Size[ 2 ] = Hh + Ch * #Obj.Inputs + Ch * #Obj.Outputs + BorderOffs
	else	
		Obj.Size[ 2 ] = Hh + GetMax( Ch * #Obj.Inputs, Ch * #Obj.Outputs ) + BorderOffs 
	end

end


function editor_node_wnd_class:SaveNodes()
	local NodeList = self.NodeList

	local NodeToName = {}
	for Ind, Node in pairs( NodeList ) do
		NodeToName[ Node ] = "Node_" .. Ind
	end

	local Nodes = {}
	for Ind, Node in pairs( NodeList ) do
		local NodeName = NodeToName[ Node ]
		local NodeToSave = {}
		for ParamName, NodeParam in pairs( Node ) do
			if ParamName == 'Inputs' or ParamName == 'Outputs' then
				NodeToSave[ ParamName ] = {}
				for Ind, Conn in pairs( NodeParam ) do
					local SaveConn = {}
					for _, ConnParam in pairs( Conn ) do
						if ParamName == 'Inputs' or ParamName == 'Outputs' then

						end
					end
				end
			else
				NodeToSave[ ParamName ] = deepcopy( NodeParam )
			end
		end 
	end

end


function editor_node_wnd_class:PrepareToSave()
	local NodeList = self.NodeList

	local NodeToName = {}
	for Ind, Node in pairs( NodeList ) do
		NodeToName[ Node ] = "Node_" .. Ind
		Node.IndexName = "Node_" .. Ind
	end

	local function ReplaseObjToNameInConn( Tab )
		for K, V in pairs( Tab ) do
			if K == 'NodeObj' and type( V ) == "table" then
				Tab.ObjName = NodeToName[ K ]
				Tab[ K ] = nil
			else
				if type( V ) == "table" then
					ReplaseObjToNameInConn( V )
				end
			end
		end		
	end

	for Ind, Node in pairs( NodeList ) do
		ReplaseObjToNameInConn( Node )
	end
end


function editor_node_wnd_class:RestoreAfterSave()
	local NodeList = self.NodeList

	local NameToNode = {}
	for Ind, Node in pairs( NodeList ) do
		NameToNode[ Node.IndexName ] = Node
	end

	--local function ReplaseObjToNameInConn( Tab )
	--	for K, V in pairs( Tab ) do
	--		if K == 'Obj' and type( V ) == "table" then
	--			Tab.ObjName = NodeToName[ K ]
	--			Tab[ K ] = nil
	--		else
	--			if type( V ) == "table" then
	--				ReplaseObjToNameInConn( V )
	--			end
	--		end
	--	end		
	--end
end