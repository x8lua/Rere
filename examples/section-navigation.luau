-- rere-beta：內容頂端隱藏導覽列。向上滾動或下拉以顯示 45 度 section 捷徑。
local Rere = loadstring(game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/rere-beta/src/rere-beta.lua"))()
local environment = getgenv()
if environment.RereSectionDemo then environment.RereSectionDemo() end
Rere.Init(game:GetService("Players").LocalPlayer.PlayerGui)
local opened = Rere.State(true)
local size = Rere.State(Vector2.new(420, 340))
local enabled = Rere.State(false)
local headers = {}
for _, name in ipairs({"Auto Parry", "Attack Speed", "Dodge", "Tuff"}) do headers[name] = Rere.State(true) end
Rere:Connect(function()
    Rere.Window({"Larpgaku"}, {isOpened = opened, size = size})
    Rere.TabBar()
    local tab = Rere.Tab({"Combat"})
    if tab.state.isOpened.value then
        for _, name in ipairs({"Auto Parry", "Attack Speed", "Dodge", "Tuff"}) do
            Rere.PushId(name)
            local section = Rere.CollapsingHeader({name}, {isUncollapsed = headers[name]})
            if section.state.isUncollapsed.value then
                Rere.Checkbox({"Enabled"}, {isChecked = enabled})
                for index = 1, 4 do Rere.Text({name .. " setting " .. index}) end
            end
            Rere.End()
            Rere.PopId()
        end
    end
    Rere.End()
    Rere.Tab({"Main"}); Rere.End()
    Rere.End()
    Rere.End()
end)
local function cleanup()
    Rere.Shutdown()
    if environment.RereSectionDemo == cleanup then environment.RereSectionDemo = nil end
end
environment.RereSectionDemo = cleanup
if STATE and STATE.onCleanup then STATE.onCleanup(cleanup) end
