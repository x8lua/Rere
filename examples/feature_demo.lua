local compiler = loadstring or load
assert(type(compiler) == "function", "Rere requires loadstring or load")

local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/v0.1.21/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

local enabled = Rere.State(true)
local speed = Rere.State(50)
local smoothness = Rere.State(0.5)
local playerName = Rere.State("")
local status = Rere.State("Ready")
local counter = Rere.State(0)

Rere:Connect(function()
    Rere.Window({ "Rere Feature Demo" })
        Rere.TabBar()
            Rere.Tab({ "Dashboard" })
                Rere.Text({ "Runtime dashboard" })
                Rere.Separator()
                Rere.Text({ "Player: " .. game.Players.LocalPlayer.Name })
                Rere.Text({ "Place ID: " .. tostring(game.PlaceId) })
                Rere.Text({ "Status: " .. status:get() })
                Rere.SeparatorText({ "Counter" })
                Rere.Text({ "Current value: " .. counter:get() })
                Rere.SameLine()
                    if Rere.Button({ "Decrease" }).clicked() then
                        counter:set(counter:get() - 1)
                    end
                    if Rere.Button({ "Increase" }).clicked() then
                        counter:set(counter:get() + 1)
                    end
                Rere.End()
            Rere.End()

            Rere.Tab({ "Controls" })
                Rere.Checkbox({ "Enabled" }, { isChecked = enabled })
                Rere.SliderNum({ "Speed", 1, 0, 100, "%d%%" }, { number = speed })
                Rere.DragNum({ "Smoothness", 0.01, 0, 1, "%.2f" }, { number = smoothness })
                Rere.InputText({ "Target player", "Enter a username..." }, { text = playerName })
                Rere.Separator()
                if Rere.Button({ "Apply settings" }).clicked() then
                    status:set(string.format("Applied: speed %d / smoothness %.2f", speed:get(), smoothness:get()))
                end
                Rere.SameLine()
                    if Rere.Button({ "Reset" }).clicked() then
                        enabled:set(true)
                        speed:set(50)
                        smoothness:set(0.5)
                        playerName:set("")
                        status:set("Reset complete")
                    end
                Rere.End()
            Rere.End()

            Rere.Tab({ "About" })
                Rere.Text({ "Rere v" .. Rere:GetVersion() })
                Rere.Text({ "Executor-compatible Iris build." })
                Rere.CollapsingHeader({ "Live values" })
                    Rere.Text({ "Enabled: " .. tostring(enabled:get()) })
                    Rere.Text({ "Speed: " .. tostring(speed:get()) })
                    Rere.Text({ "Smoothness: " .. string.format("%.2f", smoothness:get()) })
                    Rere.Text({ "Target: " .. playerName:get() })
                Rere.End()
            Rere.End()
        Rere.End()
    Rere.End()
end)
