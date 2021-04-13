require "imgui"
require "src.lua_lib.class"
require "src.editor.editor"
require "src.shared.res_manager"
require "src.shared.script_manager"


g_MouseWheelY = 0
g_ResMgr = resource_manager()
g_ScrMgr = script_manager()
--
-- LOVE callbacks
--
function love.load(arg)
	g_Editor:Init()
end

function love.update(dt)
	g_Editor:Update()
    imgui.NewFrame()	
end

function love.draw()  
	g_Editor:Draw()
	g_MouseWheelY = 0
end


function love.quit()
    imgui.ShutDown();
end

--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
		g_Editor:TextInput( t )
    end
end

function love.keypressed( key, scancode, isrepeat )
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
		g_Editor:KeyPressed( key, scancode, isrepeat )
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
        -- Pass event to the game
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
	g_MouseWheelY = y
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end