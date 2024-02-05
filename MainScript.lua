---- General Variables & Functions ----
Players = game:GetService("Players")
Player = Players.LocalPlayer

---- Brew Variables & Functions ----
Brew = {
    -- Init Brew Variables --
    isReach = false,
    curReach = "Spoof",
    reachMagnitude = Vector3.new(1, 0.800000011920929, 4),
    selBox = false,
    selBoxColor = Color3.fromRGB(0,0,0),

    cWalkspeed = 16,
    cJumppower = 50,
    cWalking = false,
    CFSpeed = 1.35,

    Autoclick = false,
    Spin = false
}

function Brew:Interpolate(part, targetCFrame, duration)
    return coroutine.wrap(function()
        local startTime = tick()
        local startCFrame = part.CFrame
        while tick() - startTime < duration do
            local elapsedTime = tick() - startTime
            local t = elapsedTime / duration
            local lerpedCFrame = startCFrame:Lerp(targetCFrame, t)
            local slerpedCFrame = CFrame.new(
                lerpedCFrame.Position,
                targetCFrame.Position
            ):lerp(lerpedCFrame, math.sin(t * math.pi * 0.5))

            part.CFrame = slerpedCFrame
            game:GetService("RunService").Heartbeat:Wait()
        end
        part.CFrame = targetCFrame
    end)
end

function Brew:WaitForChildOfClass(parents, className, timeout)
    local startTime = tick()
    timeout = timeout or 9e9
    while tick() - startTime < timeout do
        for _, parent in pairs(parents) do
            for _, child in pairs(parent:GetChildren()) do
                if child:IsA(className) then
                    return child
                end
            end
        end
        wait(0.01)
    end
    return nil
end

function Brew:Spoof(Instance, Property, Value)
    local b
    b = hookmetamethod(game, "__index", function(A, B)
        if not checkcaller() then
            if A == Instance then
                local filter = string.gsub(tostring(B), "\0", "")
                if filter == Property then
                    return Value
                end
            end
        end
        return b(A, B)
    end)
end

function Brew:disableConnection(Connection)
    for i, v in pairs(getconnections(Connection)) do
        v:Disable()
    end
end

function Brew:getSword()
    return Brew:WaitForChildOfClass({Player.Character, Player.Backpack}, "Tool")
end

function Brew:getHitbox()
    for i,v in pairs(Brew:getSword():GetDescendants()) do
        if v:FindFirstChildOfClass("TouchTransmitter") then
            v.Massless = true
            return v
        end
    end
end

function Brew:doReach()
    Brew:getSword()
    Brew:disableConnection(Brew:getHitbox():GetPropertyChangedSignal("Size"))
    Brew:Spoof(Brew:getHitbox(), "Size", Vector3.new(1, 0.800000011920929, 4))
    Brew.isReach = true
    if not identifyexecutor() == "Fluxus" then
        damageAmplification = Brew:getHitbox().Touched:Connect(function(part)
            if Brew.isReach == true and part.Parent:FindFirstChildOfClass("Humanoid") then
                local victimCharacter = part.Parent
                for i,v in pairs(victimCharacter:GetChildren()) do
                    if v:IsA("Part") and victimCharacter.Humanoid.Health ~= 0 and victimCharacter.Humanoid.Health > 0 and victimCharacter.Name ~= Player.Name then
                        task.spawn(function()
                            firetouchinterest(v, Brew:getHitbox(), 0)
                            wait();
                            firetouchinterest(v, Brew:getHitbox(), 1)
                        end)
                    end
                end
            end
        end)
    end
    while Brew.isReach == true do
        Brew:getHitbox().Size = Brew.reachMagnitude
        wait()
    end
end

function Brew:undoReach()
    Brew:disableConnection(Brew:getHitbox():GetPropertyChangedSignal("Size"))
    Brew:Spoof(Brew:getHitbox(), "Size", Vector3.new(1, 0.800000011920929, 4))
    Brew.isReach = false
    if Brew:getHitbox() then
        Brew:getHitbox().Size = Vector3.new(1, 0.800000011920929, 4)
    end
    if damageAmplification then
        damageAmplification:Disconnect()
    end
end
function Brew:doSelBox()
    if not Brew:getHitbox():FindFirstChildOfClass("SelectionBox") then
        Brew.selBox = true
        local Box = Instance.new("SelectionBox", Brew:getHitbox())
        Box.Adornee = Brew:getHitbox()
        Box.LineThickness = 0.01
        while Brew.selBox == true do
            Box.Color3 = Brew.selBoxColor
            wait()
        end
    end
end

function Brew:undoSelBox()
    if Brew:getHitbox() and Brew:getHitbox():FindFirstChildOfClass("SelectionBox") then
        Brew.selBox = false
        wait(.15)
        Brew:getHitbox():FindFirstChildOfClass("SelectionBox"):Destroy()
    end
end

function Brew:Patch()
    local Seat = Instance.new("Seat")
    Brew:Spoof(Seat, "Parent", nil)
    local Weld = Instance.new("Weld")
    Brew:Spoof(Weld, "Parent", nil)
    Seat.Transparency = 1
    Seat.CanCollide = false
    wait(.2);
    Player.Character["HumanoidRootPart"].Anchored = true
    Seat.Parent = workspace
    Seat.CFrame = Player.Character["HumanoidRootPart"].CFrame
    Seat.Anchored = false
    Weld.Parent = Seat
    Weld.Part0 = Seat
    Weld.Part1 = Player.Character["HumanoidRootPart"]
    Player.Character["HumanoidRootPart"].Anchored = false
    Seat.CFrame = Player.Character["HumanoidRootPart"].CFrame
end

---- Init Brew ----
Brew:disableConnection(game:GetService("ScriptContext").Error)

-- Init UI Library --
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/ios-boop/matrix.gg/main/Module.lua"))()

local Win = Material.Load({
	Title = "Wsploits Hub ("..game.PlaceId..")",
	Style = 3,
	SizeX = 500,
	SizeY = 350,
	Theme = "Dark",
	ColorOverrides = {
		MainFrame = Color3.fromRGB(235,235,235)
	}
})

Sword = Brew:WaitForChildOfClass({Player.Character, Player.Backpack}, "Tool")

local HomeTab = Win.New({
	Title = "Home"
})

local CharacterTab = Win.New({
	Title = "Character"
})

-- Prevent Client-Sided Anticheat --
Brew:disableConnection(Brew:getHitbox():GetPropertyChangedSignal("Size"))

-- Setting Reconstruction -- 
Player.Character.Humanoid.Died:Connect(function()
    Brew:Spoof(Player.Character.Humanoid, "WalkSpeed", 16)
    Brew:Spoof(Player.Character.Humanoid, "JumpPower", 50)
    if Brew:getHitbox() then
        Brew:disableConnection(Brew:getHitbox():GetPropertyChangedSignal("Size"))
        Brew:Spoof(Brew:getHitbox(), "Size", Vector3.new(1, 0.800000011920929, 4))
        Brew:getHitbox().Size = Vector3.new(1, 0.800000011920929, 4)
        Brew:undoReach()
        Brew:undoSelBox()
    end
end)

Player.CharacterAdded:Connect(function()
    -- Re-do Settings --
    Brew:getSword() -- wait for sword
    wait(.25)
    for i,v in pairs(Brew:getSword():GetDescendants()) do
        if v:FindFirstChildOfClass("TouchTransmitter") then
            v.Massless = true
        end
    end
    task.spawn(function()
        if Brew.isReach == true then
            Brew:doReach()
        end
    end)
    task.spawn(function()
        if Brew.selBox == true then
            Brew:doSelBox()
        end
    end)
    task.spawn(function()
        if Brew.Spin then
            if not Player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity") then
                local Velocity = Instance.new("BodyAngularVelocity", Player.Character:FindFirstChild("HumanoidRootPart"))
                Velocity.AngularVelocity = Vector3.new(0,75,0)
                Velocity.MaxTorque = Vector3.new(0,9e9,0)
                Velocity.P = 1250
            end
        end
    end)
end)

-- Init UI Commands --

local Reach = HomeTab.Toggle({
	Text = "Reach",
	Callback = function(Value)
		if Value == true then
        Brew:doReach()
        Brew.isReach = true
    elseif Value == false then
        Brew:undoReach()
        Brew.isReach = false
	end,
	Enabled = false
})

local ReachMagnitude = HomeTab.TextField({
	Text = "Reach Magnitude",
	Callback = function(Value)
		Brew.reachMagnitude = Vector3.new(tonumber(Value), tonumber(Value), tonumber(Value))
	end
})

local ReachMethod = HomeTab.Dropdown({
	Text = "Reach Method",
	Callback = function(Value)
		Brew.curReach = Value
	end,
	Options = {
		"Sword Spoofing"
	}
})

local SelectionBox = HomeTab.Toggle({
	Text = "SelectionBox",
	Callback = function(Value)
		if Value == true then
        Brew:doSelBox()
        Brew.selBox = true
    elseif Value == false then
        Brew:undoSelBox()
        Brew.selBox = false
	end,
	Enabled = false
})

local G = Y.ColorPicker({
	Text = "ESP Colour",
	Default = Color3.fromRGB(0,0,0),
	Callback = function(Value)
		Brew.selBoxColor = Value
	end
})

local Autoclick = HomeTab.Toggle({
	Text = "Autoclick",
	Callback = function(Value)
		if Value == true then
        Brew.Autoclick = true
        while Brew.Autoclick do
            if Brew:getSword().Parent == Player.Character then
                Brew:getSword():Activate()
            end
            wait()
        end
    elseif Value == false then
        Brew.Autoclick = false
	end,
	Enabled = false
})

local Spin = CharacterTab.Toggle({
	Text = "Spin",
	Callback = function(Value)
		if Value == true then
		Brew.Spin = true
        if not Player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity") then
            local Velocity = Instance.new("BodyAngularVelocity", Player.Character:FindFirstChild("HumanoidRootPart"))
            Velocity.AngularVelocity = Vector3.new(0,75,0)
            Velocity.MaxTorque = Vector3.new(0,9e9,0)
            Velocity.P = 1250
        end
	elseif Value == false then
		Brew.Spin = false
        if Player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity") then
            Player.Character:FindFirstChild("HumanoidRootPart"):FindFirstChildOfClass("BodyAngularVelocity"):Destroy()
	end,
	Enabled = false
})

local Speed = CharacterTab.TextField({
	Text = "Speed",
	Callback = function(Value)
		Brew:Spoof(Player.Character:WaitForChild("Humanoid"), "WalkSpeed", 16)
	Player.Character:WaitForChild("Humanoid").WalkSpeed = tonumber(Value)
    Brew.cWalkspeed = tonumber(Value)
	end
})

local Jumppower = CharacterTab.TextField({
	Text = "Jumppower",
	Callback = function(Value)
		Brew:Spoof(Player.Character:WaitForChild("Humanoid"), "JumpPower", 50)
	Player.Character:WaitForChild("Humanoid").JumpPower = tonumber(Value)
	Brew.cJumppower = tonumber(Value)
	end
})
