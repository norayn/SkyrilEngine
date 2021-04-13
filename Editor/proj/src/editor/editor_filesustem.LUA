local FileSustem = {}
g_Editor.FileSustem = FileSustem

FileSustem.SelectTime = 0


local function GetFileTree( Folder, DirFilesTable )
	local lfs = love.filesystem
	local FilesTable = lfs.getDirectoryItems( Folder )
	DirFilesTable.Files = {}

	for i,v in ipairs( FilesTable ) do
		local File = {}
		File.FullPatch = Folder.."/"..v
		File.Folder = Folder	
		File.Name = v	
		
		if lfs.isFile( File.FullPatch ) then
			File.IsFolder = false
			File.Ext = string.sub( v, string.find( v, "%." ) + 1 )
			File.ShortName = string.sub( v, 1, string.find( v, "%." ) - 1 )
		elseif lfs.isDirectory( File.FullPatch ) then
			File.IsFolder = true
			File.HasFolder = false
			DirFilesTable.HasFolder = true
			GetFileTree( File.FullPatch, File )
		end

		--DirFilesTable.Files[ File.Name ] = File
		table.insert( DirFilesTable.Files, File )
	end
end


function FileSustem:load()
	
	FileSustem.Root = { 
		IsFolder = true,
		Name = "root",
		FullPatch = "/",
	}
	GetFileTree( "", FileSustem.Root )
	LogE( "FileSustem ready", "atn" )
end


function FileSustem:Reload()
	GetFileTree( "", FileSustem.Root )
	LogE( "FileSustem updated", "oft" )
end


function FileSustem:DrawFileInTree( File, Param )
	local HasChildren = File.Files ~= nil
	local UseFlags = {}
	
	if HasChildren then
		UseFlags = { "OpenOnArrow", "OpenOnDoubleClick" }
		if Param.OnlyFolder and not File.HasFolder then
			UseFlags = { "Leaf" }
		end
	else
		if Param.Filters then
			local FilterOk = false
			for _, Filter in pairs( Param.Filters ) do
				if File.Ext:lower() == Filter:lower() then
					FilterOk = true
				end
			end

			if not FilterOk then return end
		end

		UseFlags = { "Leaf", "NoTreePushOnOpen" }
	end
	
	if File.Name == self.SelectedFileName then
		table.insert( UseFlags, "Selected" )
	end
	
	local NodeOpen = imgui.TreeNodeEx( File.Name, UseFlags, File.Name )
	local NodeClicked = imgui.IsItemClicked()

	if NodeClicked then
		self.SelectedFileName = File.Name
		if not HasChildren and love.timer.getTime() - self.SelectTime < 0.25 then
			if Param.OpenFile then
				Param.OpenFile( File )
			end
		else
			self.SelectTime = love.timer.getTime()
			if Param.SelectFile then
				Param.SelectFile( File )
			end
		end
	end

	if NodeOpen and HasChildren then
		for _, ChildObj in pairs( File.Files ) do
			self:DrawFileInTree( ChildObj, Param )
		end
		imgui.TreePop()
	end
end


function FileSustem:DrawFilesTree( Params )	
	if not Params then Params = {} end
	if not Params.WndName then Params.WndName = "FilesTree" end
	if Params.OnlyFolder then Params.Filters = { "only_folder" } end
	--Param.SelectFile()
	--Param.OpenFile()
	--Param.Filters{ ... }	

	if Params.NoHeader then
		imgui.PushStyleVar("IndentSpacing", imgui.GetFontSize()*0.5)

		if 1 then	--TODO set start folder
			local StartFolder = self:FindFolderByName( "res", self.Root )
			for _, ChildObj in pairs( StartFolder.Files ) do
				self:DrawFileInTree( ChildObj, Params )
			end
		else
			self:DrawFileInTree( self.Root, Params )
		end
		
		imgui.PopStyleVar()
	else
		if ( imgui.CollapsingHeader( Params.WndName ) ) then		

			imgui.BeginChild( Params.WndName, 0, -20, true );
			imgui.PushStyleVar("IndentSpacing", imgui.GetFontSize()*0.5)

			self:DrawFileInTree( self.Root, Params )

			imgui.PopStyleVar()
			imgui.EndChild()-----
		end
	end
end


function FileSustem:FindFolderByName( FolderName, FolderFile )
	if FolderFile.IsFolder and FolderName == FolderFile.Name then
		return FolderFile
	end

	if FolderFile.Files then
		for _, ChildObj in pairs( FolderFile.Files ) do
			local TmpFolder = self:FindFolderByName( FolderName, ChildObj )
			if TmpFolder then
				return TmpFolder
			end
		end
		imgui.TreePop()
	end

	return nil
end

