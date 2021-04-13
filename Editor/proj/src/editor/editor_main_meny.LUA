
function DrawEditorMainMeny()
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
            if imgui.MenuItem("Test") then
				--action
			end
			imgui.EndMenu()
        end
        if imgui.BeginMenu("View") then
            if imgui.MenuItem("Scene editor") then
				g_Editor.SceneEditor.Visible = not g_Editor.SceneEditor.Visible
			end
            if imgui.MenuItem("SubScene editor") then
				g_Editor.SubSceneEditor.Visible = not g_Editor.SubSceneEditor.Visible
			end
            if imgui.MenuItem("Object editor") then
				g_Editor.ObjEditor.Visible = not g_Editor.ObjEditor.Visible
			end
            if imgui.MenuItem("Map editor") then
				g_Editor.MapEditor.Visible = not g_Editor.MapEditor.Visible
			end
            if imgui.MenuItem("Atlas editor") then
				g_Editor.AtlasEditor.Visible = not g_Editor.AtlasEditor.Visible
			end
            if imgui.MenuItem("Script editor") then
				g_Editor.ScriptEditor.Visible = not g_Editor.ScriptEditor.Visible
			end
            if imgui.MenuItem("Animation editor") then
				g_Editor.AnimationEditor.Visible = not g_Editor.AnimationEditor.Visible
			end
            if imgui.MenuItem("Game editor") then
				g_Editor.GameEditor.Visible = not g_Editor.GameEditor.Visible
			end
            if imgui.MenuItem("Node dialog editor") then
				g_Editor.NodeDialogEditor.Visible = not g_Editor.NodeDialogEditor.Visible
			end
            if imgui.MenuItem("File browser") then
				g_Editor.FileBrowser.Visible = not g_Editor.FileBrowser.Visible
			end
            if imgui.MenuItem("Inspector") then
				g_Editor.Inspector.Visible = not g_Editor.Inspector.Visible
			end
            if imgui.MenuItem("Debug console") then
				g_Editor.Console.ShowConsole = not g_Editor.Console.ShowConsole
			end
			imgui.EndMenu()
        end
        imgui.EndMainMenuBar()
    end
end

