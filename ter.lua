-- Persistent Teleport and Sit Logic
local plr = game.Players.LocalPlayer
local chr = plr.Character or plr.CharacterAdded:Wait()
local humanoid = chr:WaitForChild("Humanoid") -- Ensure Humanoid exists

local targetPosition = Vector3.new(-424, 30, -49041) -- Target seat position
local walkTargetPosition = Vector3.new(-341.88, 3, -49045) -- New walk target position

-- Auto Headshot Functionality
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ShootRemote = ReplicatedStorage.Remotes.Weapon.Shoot
local ReloadRemote = ReplicatedStorage.Remotes.Weapon.Reload

local Players = game:GetService("Players")
local workspace = game.Workspace

-- Configuration
local SEARCH_RADIUS = 350    -- Detect NPCs within 350 studs
local SHOOT_RADIUS = 300     -- Increased auto-shoot range
local TELEPORT_OFFSET = Vector3.new(0, 0, -2) -- Moves bullet behind NPC's head

local SupportedWeapons = {
    "Revolver",
    "Rifle",
    "Sawed-Off Shotgun",
    "Shotgun"
}

local function isPlayerModel(m)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character == m then
            return true
        end
    end
    return false
end

local function getEquippedSupportedWeapon()
    local char = Players.LocalPlayer and Players.LocalPlayer.Character
    if not char then return nil end
    for _, name in ipairs(SupportedWeapons) do
        local tool = char:FindFirstChild(name)
        if tool then
            return tool
        end
    end
    return nil
end

local function findClosestNPC()
    local closestNPC = nil
    local closestDistance = SEARCH_RADIUS
    local playerChar = Players.LocalPlayer.Character
    if not playerChar then return nil end

    local playerPosition = playerChar:GetPivot().Position

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and not isPlayerModel(obj) then
            local hum = obj:FindFirstChildOfClass("Humanoid")
            local head = obj:FindFirstChild("Head")
            if hum and head and hum.Health > 0 then
                local npcPosition = obj:GetPivot().Position
                local dist = (npcPosition - playerPosition).Magnitude
                
                if dist <= SEARCH_RADIUS and dist < closestDistance then
                    closestDistance = dist
                    closestNPC = {model = obj, hum = hum, head = head, distance = dist}
                end
            end
        end
    end
    return closestNPC
end

local function autoShoot()
    local tool = getEquippedSupportedWeapon()
    if tool then
        local closestNPC = findClosestNPC()
        if closestNPC and closestNPC.distance <= SHOOT_RADIUS then
            local pelletTable = {}
            if tool.Name == "Shotgun" or tool.Name == "Sawed-Off Shotgun" then
                for i = 1, 6 do
                    pelletTable[tostring(i)] = closestNPC.hum
                end
            else
                pelletTable["1"] = closestNPC.hum
            end

            -- Teleport bullet behind NPC's head
            local behindHeadPosition = closestNPC.head.Position + TELEPORT_OFFSET

            -- Fire from behind NPC's head
            ShootRemote:FireServer(
                workspace:GetServerTimeNow(),
                tool,
                CFrame.new(behindHeadPosition, closestNPC.head.Position), -- Always hits
                pelletTable
            )

            -- Auto reload after firing
            ReloadRemote:FireServer(workspace:GetServerTimeNow(), tool)
        end
    end
end

while true do
    task.wait(0.1) -- Add a slight delay for smoother repetition

    -- Teleport to the target position
    chr:PivotTo(CFrame.new(targetPosition)) -- Move character to the exact coordinates

    -- Trigger auto shoot immediately after teleporting
    autoShoot()

    -- Check if the character is seated
    if chr.Humanoid.SeatPart ~= nil then
        print("Successfully seated!")

        -- Wait for 1 second, then jump
        task.wait(1)
        game:GetService("VirtualInputManager"):SendKeyEvent(true, "Space", false, game)
        task.wait()
        game:GetService("VirtualInputManager"):SendKeyEvent(false, "Space", false, game)

        -- Walk to the new target position using MoveTo
        humanoid:MoveTo(walkTargetPosition) -- Start walking to the new target position
        local success, message = humanoid.MoveToFinished:Wait() -- Wait for the movement to finish

        if not success then
            warn("Failed to reach the target position!")
        else
            print("Successfully walked to the target position!")
        end

        break -- Exit the loop once seated, jumped, and walked to the new target position
    end

    -- Logic to search for the seat and try to sit remains unchanged
    local baseplates = workspace:FindFirstChild("Baseplates")
    if baseplates then
        local finalBasePlate = baseplates:FindFirstChild("FinalBasePlate")
        if finalBasePlate then
            local outlawBase = finalBasePlate:FindFirstChild("OutlawBase")
            if outlawBase then
                for _, v in pairs(outlawBase:GetDescendants()) do
                    if v:IsA("Seat") or v:IsA("VehicleSeat") then
                        if v.Position == targetPosition then
                            pcall(function()
                                v.Disabled = false -- Enable the seat
                                v:Sit(chr.Humanoid) -- Attempt to sit
                            end)
                        end
                    end
                end
            end
        end
    end
end
