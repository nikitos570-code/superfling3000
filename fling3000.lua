-- SWILL-совместимый скрипт для Xeno (Roblox)
-- Активация: касание игрока → выброс за пределы карты с гиперскоростью

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")

local TOUCH_FORCE = 99999999  -- гигантская скорость
local DIRECTION = Vector3.new(0, 500, 0) -- вертикальный выброс (можно заменить на горизонтальный)

-- Функция выброса
local function launchTarget(targetChar)
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if targetRoot then
        targetRoot.Velocity = DIRECTION * TOUCH_FORCE
        -- Дополнительный импульс для гарантии за карту
        targetRoot:ApplyImpulse(DIRECTION * TOUCH_FORCE * 10)
    end
end

-- Обработчик касания
local function onTouch(otherPart)
    local parent = otherPart.Parent
    if parent then
        local humanoid = parent:FindFirstChild("Humanoid")
        if humanoid and parent ~= character then
            launchTarget(parent)
        end
    end
end

-- Подключаем к корневой части
rootPart.Touched:Connect(onTouch)

-- Защита от отключения (если персонаж пересоздаётся)
characterAddedConnection = localPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    rootPart = character:WaitForChild("HumanoidRootPart")
    rootPart.Touched:Connect(onTouch)
end)

-- Опционально: постоянное сканирование для мгновенного выброса при появлении рядом (без касания)
RunService.Heartbeat:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            local targetChar = player.Character
            if targetChar and targetChar:FindFirstChild("HumanoidRootPart") then
                local dist = (targetChar.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if dist < 5 then -- дистанция касания
                    launchTarget(targetChar)
                end
            end
        end
    end
end)