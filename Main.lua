local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- GUI Setup
local gui = Instance.new("ScreenGui")
gui.Name = "AntiFreezerCoquetteHub"
gui.Parent = game:GetService("CoreGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 150)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = gui
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "🎩 Anti Freezer Coquette Hub"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0.9, 0, 0, 50)
toggleBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
toggleBtn.Text = "ANTI FREEZER DESATIVADO"
toggleBtn.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 30)
statusLabel.Position = UDim2.new(0, 0, 0.85, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.SourceSansItalic
statusLabel.TextSize = 16
statusLabel.Text = ""
statusLabel.Parent = frame

local frozen = false
local freezeConnection
local antiKickConnection

local freezeBodyPosition
local freezeBodyVelocity
local freezeBodyGyro
local humanoid -- Para controlar o Humanoid
local originalWalkSpeed -- Para restaurar a velocidade
local originalJumpPower -- Para restaurar o pulo

local function createFreezeObjects(hrp)
    -- Criar BodyPosition com força máxima
    freezeBodyPosition = Instance.new("BodyPosition")
    freezeBodyPosition.Name = "StrongFreeze_BodyPosition"
    freezeBodyPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    freezeBodyPosition.P = 1e6 -- Aumentado para maior rigidez
    freezeBodyPosition.D = 1e5 -- Aumentado para maior amortecimento
    freezeBodyPosition.Position = hrp.Position
    freezeBodyPosition.Parent = hrp

    -- Criar BodyVelocity para zerar qualquer movimento
    freezeBodyVelocity = Instance.new("BodyVelocity")
    freezeBodyVelocity.Name = "StrongFreeze_BodyVelocity"
    freezeBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    freezeBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    freezeBodyVelocity.Parent = hrp

    -- Criar BodyGyro para travar rotação
    freezeBodyGyro = Instance.new("BodyGyro")
    freezeBodyGyro.Name = "StrongFreeze_BodyGyro"
    freezeBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    freezeBodyGyro.P = 1e6 -- Aumentado para maior rigidez
    freezeBodyGyro.D = 1e5 -- Aumentado para maior amortecimento
    freezeBodyGyro.CFrame = hrp.CFrame
    freezeBodyGyro.Parent = hrp
end

local function destroyFreezeObjects()
    if freezeBodyPosition and freezeBodyPosition.Parent then
        freezeBodyPosition:Destroy()
    end
    if freezeBodyVelocity and freezeBodyVelocity.Parent then
        freezeBodyVelocity:Destroy()
    end
    if freezeBodyGyro and freezeBodyGyro.Parent then
        freezeBodyGyro:Destroy()
    end

    freezeBodyPosition = nil
    freezeBodyVelocity = nil
    freezeBodyGyro = nil
end

local function updateStatus(text, color)
    statusLabel.Text = text or ""
    if color then
        statusLabel.TextColor3 = color
    else
        statusLabel.TextColor3 = Color3.new(1, 1, 1)
    end
end

local function simulateActivity()
    -- Simula pequenos inputs para evitar kick por inatividade
    UserInputService:SetKeyDown(Enum.KeyCode.LeftShift)
    wait(0.1)
    UserInputService:SetKeyUp(Enum.KeyCode.LeftShift)
end

local function activateAntiKick()
    if antiKickConnection then return end
    antiKickConnection = RunService.Heartbeat:Connect(function(step)
        if os.clock() % 15 < step then
            simulateActivity()
            updateStatus("Anti Kick: atividade simulada", Color3.fromRGB(255, 255, 0))
        end
    end)
end

local function deactivateAntiKick()
    if antiKickConnection then
        antiKickConnection:Disconnect()
        antiKickConnection = nil
    end
    updateStatus("")
end

local function activateFreeze()
    if frozen then return end
    frozen = true
    toggleBtn.Text = "ANTI FREEZER ATIVADO"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    updateStatus("Proteção ativa", Color3.fromRGB(0, 170, 0))

    local hrp = character:WaitForChild("HumanoidRootPart")
    humanoid = character:WaitForChild("Humanoid")
    
    -- Desativar movimento do Humanoid
    originalWalkSpeed = humanoid.WalkSpeed
    originalJumpPower = humanoid.JumpPower
    humanoid.WalkSpeed = 0
    humanoid.JumpPower = 0
    humanoid.AutoRotate = false -- Impede rotação automática

    -- Travar completamente o personagem
    hrp.Anchored = true -- Ancora o HumanoidRootPart para travar fisicamente
    createFreezeObjects(hrp)

    freezeConnection = RunService.Heartbeat:Connect(function()
        if not hrp or not hrp.Parent or not humanoid or not humanoid.Parent then
            deactivateFreeze()
            return
        end
        if not freezeBodyPosition or not freezeBodyPosition.Parent then
            createFreezeObjects(hrp)
        end
        freezeBodyPosition.Position = hrp.Position
        freezeBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        freezeBodyGyro.CFrame = hrp.CFrame
    end)

    activateAntiKick()
end

local function deactivateFreeze()
    if not frozen then return end
    frozen = false
    toggleBtn.Text = "ANTI FREEZER DESATIVADO"
    toggleBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    updateStatus("Proteção desativada", Color3.fromRGB(170, 0, 0))

    -- Restaurar movimento do Humanoid
    if humanoid and humanoid.Parent then
        humanoid.WalkSpeed = originalWalkSpeed or 16
        humanoid.JumpPower = originalJumpPower or 50
        humanoid.AutoRotate = true
    end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Anchored = false -- Desancora o HumanoidRootPart
    end

    destroyFreezeObjects()

    if freezeConnection then
        freezeConnection:Disconnect()
        freezeConnection = nil
    end

    deactivateAntiKick()
end

toggleBtn.MouseButton1Click:Connect(function()
    if frozen then
        deactivateFreeze()
    else
        activateFreeze()
    end
end)

player.CharacterAdded:Connect(function(charNew)
    character = charNew
    if frozen then
        wait(1)
        activateFreeze()
    end
end)

-- Animação simples de brilho no botão quando ativo
RunService.Heartbeat:Connect(function()
    if frozen then
        local colorValue = (math.sin(tick() * 3) + 1) / 2 -- 0 a 1
        toggleBtn.BackgroundColor3 = Color3.fromRGB(
            0,
            math.floor(170 + 85 * colorValue),
            0
        )
    end
end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "🎩 Anti Freezer Coquette Hub",
        Text = "Sistema super OP ativado!",
        Duration = 4,
    })
end)
