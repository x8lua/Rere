local compiler = loadstring or load
local source = game:HttpGet("https://raw.githubusercontent.com/x8lua/Rere/main/src/Rere.lua")
local Rere = assert(compiler(source))()
Rere.Init()

local model = Instance.new("Model")
local part = Instance.new("Part")
part.Size = Vector3.new(3, 3, 3)
part.Color = Color3.fromRGB(50, 160, 255)
part.Material = Enum.Material.Neon
part.Anchored = true
part.Parent = model

local camera = Instance.new("Camera")
camera.CFrame = CFrame.lookAt(Vector3.new(6, 4, 6), Vector3.zero)

Rere:Connect(function()
    Rere.Window({"ViewportFrame"})
    Rere.ViewportFrame({UDim2.fromOffset(320, 220), camera, model})
    Rere.End()
end)
