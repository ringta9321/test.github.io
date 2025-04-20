local BindableFunction = Instance.new("BindableFunction")
BindableFunction.OnInvoke = function()
    setclipboard("https://youtube.com/@amreeeshi?si=EfTtiaBeM9kdl0nX")
end

game.StarterGui:SetCore("SendNotification", {
    Title = "Successfully Executed!",
    Text = "By: Amare Scripts Scripts on YouTube",
    Icon = "",
    Duration = 100,
    Button1 = "Subscribe!",
    Callback = BindableFunction
})

-- Delete invischair if it exist btw
local chair = workspace:FindFirstChild("invischair")
if chair then
    chair:Destroy()
end

-- Make humanoidrootpart transparent
local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if hrp then
    hrp.Transparency = 1
end

-- Detect and delete new maximgun parts
workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "MaximGun" then
        task.wait()
        descendant:Destroy()
    end
end)

-- Create invisible seat fo some reason
local seat = Instance.new("Seat", workspace)
seat.Anchored = false
seat.CanCollide = false
seat.Name = "invischair"
seat.Transparency = 1
seat.Position = Vector3.new(-25.95, 84, 3537.55)

-- Weld seat to character's torso or upper torso
local weld = Instance.new("Weld")
weld.Part0 = seat
weld.Part1 = game.Players.LocalPlayer.Character and (
    game.Players.LocalPlayer.Character:FindFirstChild("Torso")
    or game.Players.LocalPlayer.Character:FindFirstChild("UpperTorso")
)
weld.Parent = seat

-- Set humanoidrootpart transparency again just to be sure
local hrp2 = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
if hrp2 then
    hrp2.Transparency = 1
end

-- Disable all vehicleseats
for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("VehicleSeat") then
        part.Disabled = false
    end
end

-- Remove all baseparts and Decals named "MaximGun"
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("BasePart") or obj:IsA("Decal") then
        if obj.Name == "MaximGun" then
            obj:Destroy()
        end
    end
end
