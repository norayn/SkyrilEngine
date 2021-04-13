--V2.0


MAP_TYPE_NONE = 0
MAP_TYPE_LAYER = 1
MAP_TYPE_SPRITE = 2
MAP_TYPE_ANIMATION = 3


map_obj = class( function( self, Type )
	self.Name = "no_name"
	if Type == MAP_TYPE_SPRITE then self.Name = "map_sprite"  end
	if Type == MAP_TYPE_LAYER then self.Name = "map_layer"  end
	if Type == MAP_TYPE_ANIMATION then self.Name = "map_amimation"  end
		
	self.Type = Type
	self.LocalPos = { 0, 0 }	--primary
	self.GlobalPos = { 0, 0 }	--auto generated by LocalPos
	self.Size = { 100, 50 }
	self.Rotate = 0
	self.Pivot = { 0.5, 0.5 }	--xy 0...1
	self.Visible = true
	--self.Text = ""	
	self.TexName = ""
	self.SubTexName = ""	
	self.TexRect = { 0, 0, 0, 0 }	
	self.Childs = {}
	--self.ServRect = nil
	self.MulColor = { 1, 1, 1, 1 }
		
	self.EditorVisible = true
	self.EditorShowChildsInList = 1
	self.EditorQuad = nil	 
end)


function map_obj:AddChild( Child )
	table.insert( self.Childs, Child )
	Child:SetParent( self )
end


--function map_obj:OnObj( X, Y )
--	if X >= self.GlobalPos[ 1 ] and X < self.GlobalPos[ 1 ] + self.Size[ 1 ] 
--	   and Y >= self.GlobalPos[ 2 ] and Y < self.GlobalPos[ 2 ] + self.Size[ 2 ] then
--		return true
--	else
--		return false
--	end
--end


function map_obj:OnObjEx( X, Y )
	if self.Rotate ~= 0 then
		local Res = RotatePoint( { X, Y }, -self.Rotate, self.GlobalPos )
		X, Y = Res[ 1 ], Res[ 2 ]
	end
	
	local PvtX, PvtY = self.Size[ 1 ] * self.Pivot[ 1 ], self.Size[ 2 ] * self.Pivot[ 2 ]
	if self.EditorVisible
 	   and X >= self.GlobalPos[ 1 ] - PvtX and X < self.GlobalPos[ 1 ] + self.Size[ 1 ] - PvtX
	   and Y >= self.GlobalPos[ 2 ] - PvtY and Y < self.GlobalPos[ 2 ] + self.Size[ 2 ] - PvtY then
		return true
	else
		return false
	end
end


function map_obj:GetTypePrefix()
	if self.Type == MAP_TYPE_BG_SPRITE then return "BG:"  end
	if self.Type == MAP_TYPE_OBJ_SPRITE then return "OS:"  end
	if self.Type == MAP_TYPE_SERV_RECT then return "RS:"  end	
	if self.Type == MAP_TYPE_GROUP then return "GR:"  end	
	if self.Type == MAP_TYPE_SUB_LAYER then return "SL:"  end
	if self.Type == MAP_TYPE_TRIGGER_RECT then return "TR:"  end
	return "Uncnow:"		
end


function map_obj:SetGlobalPos( Pos )
	PosDiff = Sub( Pos, self.GlobalPos )	
	self.LocalPos = Add( PosDiff, self.LocalPos )
	self.GlobalPos[ 1 ], self.GlobalPos[ 2 ] = Pos[ 1 ], Pos[ 2 ]	
end


function map_obj:InitGlobalPos( Pos )
	if self:GetParent() then
		self.GlobalPos = Add( self:GetParent().GlobalPos, self.LocalPos )
	end
	self:SetGlobalPos( Pos )
end


function map_obj:GetMinMax()
	local PvtX, PvtY = self.Size[ 1 ] * self.Pivot[ 1 ], self.Size[ 2 ] * self.Pivot[ 2 ]
	local PvtInvX, PvtInvY = self.Size[ 1 ] - PvtX, self.Size[ 2 ] - PvtY

	local Min = Sub( self.GlobalPos, { PvtX, PvtY } )
	local Max = Add( self.GlobalPos, { PvtInvX, PvtInvY } )
	
	if self.Rotate ~= 0 then
		local W, H = self.Size[ 1 ], self.Size[ 2 ]
		local P1 = Add( self.GlobalPos, RotatePoint( { -PvtX,	-PvtY	}, self.Rotate ) )
		local P2 = Add( self.GlobalPos, RotatePoint( { PvtInvX,	-PvtY	}, self.Rotate ) )
		local P3 = Add( self.GlobalPos, RotatePoint( { -PvtX,	PvtInvY	}, self.Rotate ) )
		local P4 = Add( self.GlobalPos, RotatePoint( { PvtInvX,	PvtInvY	}, self.Rotate ) )

		Min = GetMin( P1, Min );	Max = GetMax( P1, Max )
		Min = GetMin( P2, Min );	Max = GetMax( P2, Max )
		Min = GetMin( P3, Min );	Max = GetMax( P3, Max )
		Min = GetMin( P4, Min );	Max = GetMax( P4, Max )
	end
		
	if #self.Childs == 0 or self.Type == MAP_TYPE_LAYER then
		return Min, Max
	end

	for _, Child in pairs( self.Childs ) do
		local ChildMin, ChildMax = Child:GetMinMax()
		Min = GetMin( ChildMin, Min )	
		Max = GetMax( ChildMax, Max )
	end

	return Min, Max
end


function map_obj:ReCalcLayer()
	if #self.Childs == 0 then
		return
	end
	
	local Min = self.Childs[ 1 ].GlobalPos
	local Max = self.Childs[ 1 ].GlobalPos

	for _, Child in pairs( self.Childs ) do
		local ChildMin, ChildMax = Child:GetMinMax()
		Min = GetMin( ChildMin, Min )	
		Max = GetMax( ChildMax, Max )
	end

	self.Size = Sub( Max, Min )	
	local CentrPos = { math.ceil( Min[ 1 ] + self.Size[ 1 ] / 2 ), math.ceil( Min[ 2 ] + self.Size[ 2 ] / 2 ) }
	local PosDiff = Sub( CentrPos, self.GlobalPos )
	self:SetGlobalPos( CentrPos )
	self.Rotate = 0

	if PosDiff[ 1 ] == 0 and PosDiff[ 2 ] == 0 then
		return
	end

	for _, Child in pairs( self.Childs ) do
		Child.LocalPos = Sub( Child.LocalPos, PosDiff )
	end
end


function map_obj:PrepareToSave()
	self.EditorQuad = nil
	self.MapQuad = nil

	if self.Type == MAP_TYPE_ANIMATION then
		self.Animation:PrepareToSaveObj()
	end

	if #self.Childs == 0 then
		return
	end
	
	for _, Child in pairs( self.Childs ) do
		Child:PrepareToSave()
	end
end


function MapObjRestoreAfterSave( Obj )
	if not Obj.MulColor then	Obj.MulColor = { 1, 1, 1, 1 }	end
	if not Obj.Pivot then	Obj.Pivot = { 0.5, 0.5 }	end

	local MapObjClass = map_obj( MAP_TYPE_LAYER )	
	setmetatable( Obj, getmetatable( MapObjClass ) )

	if Obj.Type == MAP_TYPE_ANIMATION then
		RestoreAnimationAfterSaveObj( Obj.Animation ) 
	end
	
	if #Obj.Childs > 0 then
		for I = 1, #Obj.Childs do
			MapObjRestoreAfterSave( Obj.Childs[ I ] )
			Obj.Childs[ I ]:SetParent( Obj )
		end
	end
end


function map_obj:SetParent( Obj )
	if not g_Editor then	return	end

	g_Editor.MapEditor.ObjParentTable[ self ] = Obj
end


function map_obj:GetParent()
	if not g_Editor then	return	end

	return  g_Editor.MapEditor.ObjParentTable[ self ]
end