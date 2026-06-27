-- ============================================================================
-- KK AUTOMATION SCRIPT - Full Game Automation
-- ============================================================================
-- Script que automatiza todas as ações do jogo, desde missões até compras
-- Local execution only | Roblox Lua
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================================================
-- CONFIGURAÇÕES GLOBAIS
-- ============================================================================

local CONFIG = {
    SEA_1_COMPLETE = false,
    SEA_2_REACHED = false,
    CURRENT_LEVEL = 0,
    TARGET_LEVEL = 0,
    FARMING_ENABLED = true,
    MAX_HEALTH = 100,
    AUTOMATION_ACTIVE = true,
}

local COMPLETED_TASKS = {
    secondary_missions = {},
    weapons_bought = {},
    combat_styles_bought = {},
    fruits_bought = {},
    general_items_bought = {},
}

local TARGET_ENEMY = nil
local LAST_MISSION_TIME = 0
local MISSION_COOLDOWN = 2

-- ============================================================================
-- INTERFACE - GUI OVERLAY
-- ============================================================================

local function createUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "kkUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = player:WaitForChild("PlayerGui")

    -- Fundo desfocado
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0.7
    background.BorderSizePixel = 0
    background.Parent = screenGui

    -- Efeito de blur (simulado com Frame)
    local blur = Instance.new("Frame")
    blur.Name = "BlurEffect"
    blur.Size = UDim2.new(1, 0, 1, 0)
    blur.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    blur.BackgroundTransparency = 0.85
    blur.BorderSizePixel = 0
    blur.Parent = background

    -- Nome "kk" no centro
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(0, 200, 0, 100)
    nameLabel.Position = UDim2.new(0.5, -100, 0.5, -50)
    nameLabel.BackgroundTransparency = 1
    nameLabel.TextSize = 72
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = true
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = "kk"
    nameLabel.Parent = background

    -- Status info (pequeno)
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Size = UDim2.new(0, 400, 0, 100)
    statusLabel.Position = UDim2.new(0.5, -200, 0.9, -50)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextSize = 14
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.TextScaled = true
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.Text = "AUTOMAÇÃO ATIVA"
    statusLabel.Parent = background

    return screenGui, statusLabel
end

local screenGui, statusLabel = createUI()

local function updateStatus(text)
    if statusLabel then
        statusLabel.Text = text
    end
end

-- ============================================================================
-- FUNÇÕES AUXILIARES
-- ============================================================================

local function getPlayerStats()
    local remoteFunction = ReplicatedStorage:FindFirstChild("Remotes") and 
                           ReplicatedStorage.Remotes:FindFirstChild("GetPlayerData")
    if remoteFunction then
        local success, data = pcall(function()
            return remoteFunction:InvokeServer()
        end)
        if success and data then
            return data
        end
    end
    return nil
end

local function getCurrentLevel()
    local stats = getPlayerStats()
    if stats and stats.Level then
        CONFIG.CURRENT_LEVEL = stats.Level
        return stats.Level
    end
    return CONFIG.CURRENT_LEVEL
end

local function getAllCompletedMissions()
    local stats = getPlayerStats()
    if stats and stats.CompletedQuests then
        return stats.CompletedQuests
    end
    return {}
end

local function teleportToNPC(npcName)
    local npc = workspace:FindFirstChild(npcName)
    if npc and npc:FindFirstChild("HumanoidRootPart") then
        rootPart.CFrame = npc.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
        wait(0.5)
        return true
    end
    return false
end

local function moveTowards(targetPos, distance)
    local connection
    local function move()
        if character:FindFirstChild("HumanoidRootPart") then
            local currentDistance = (rootPart.Position - targetPos).Magnitude
            if currentDistance > distance then
                humanoid:MoveTo(targetPos)
            else
                if connection then connection:Disconnect() end
                return true
            end
        end
    end
    connection = RunService.Heartbeat:Connect(move)
    wait(2)
    if connection then connection:Disconnect() end
end

local function findNearestEnemy()
    local nearestEnemy = nil
    local nearestDistance = math.huge

    for _, npc in pairs(workspace:GetChildren()) do
        if npc:FindFirstChild("Humanoid") and npc:FindFirstChild("HumanoidRootPart") then
            if npc ~= character then
                local distance = (npc.HumanoidRootPart.Position - rootPart.Position).Magnitude
                if distance < nearestDistance and distance < 100 then
                    nearestEnemy = npc
                    nearestDistance = distance
                end
            end
        end
    end

    return nearestEnemy
end

local function attackEnemy(enemy)
    if not enemy or not enemy:FindFirstChild("Humanoid") or enemy.Humanoid.Health <= 0 then
        return false
    end

    -- Movetar para perto do inimigo
    moveTowards(enemy.HumanoidRootPart.Position, 10)

    -- Simular ataques (M1)
    for i = 1, 3 do
        if enemy.Humanoid.Health > 0 then
            local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and
                               ReplicatedStorage.RemoteEvents:FindFirstChild("CombatRemote")
            if remoteEvent then
                pcall(function()
                    remoteEvent:FireServer("attack", {})
                end)
            end
            wait(0.5)
        end
    end

    return true
end

-- ============================================================================
-- SISTEMA DE MISSÕES
-- ============================================================================

local function acceptMission(questName)
    local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and
                       ReplicatedStorage.RemoteEvents:FindFirstChild("QuestAccept")
    if remoteEvent then
        pcall(function()
            remoteEvent:FireServer(questName)
        end)
        return true
    end
    return false
end

local function completeMission(questName)
    local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and
                       ReplicatedStorage.RemoteEvents:FindFirstChild("QuestComplete")
    if remoteEvent then
        pcall(function()
            remoteEvent:FireServer(questName)
        end)
        return true
    end
    return false
end

local function processSecondaryMissions()
    updateStatus("Processando missões secundárias...")

    local questConfig = ReplicatedStorage:FindFirstChild("Modules") and
                       ReplicatedStorage.Modules:FindFirstChild("QuestConfig")
    
    if questConfig then
        local quests = require(questConfig)
        local completedQuests = getAllCompletedMissions()

        for questName, questData in pairs(quests) do
            if not table.find(completedQuests, questName) and 
               questData.Type == "Secondary" then
                
                updateStatus("Fazendo: " .. questName)
                acceptMission(questName)
                wait(1)

                -- Farmar até completar
                while CONFIG.AUTOMATION_ACTIVE and 
                      not table.find(getAllCompletedMissions(), questName) do
                    
                    local enemy = findNearestEnemy()
                    if enemy then
                        attackEnemy(enemy)
                    else
                        wait(1)
                    end
                end

                COMPLETED_TASKS.secondary_missions[questName] = true
                wait(1)
            end
        end
    end
end

-- ============================================================================
-- SISTEMA DE COMPRAS
-- ============================================================================

local function buyWeapon(weaponName)
    local merchantRemote = ReplicatedStorage:FindFirstChild("Remotes") and
                          ReplicatedStorage.Remotes:FindFirstChild("MerchantRemotes") and
                          ReplicatedStorage.Remotes.MerchantRemotes:FindFirstChild("PurchaseMerchantItem")
    
    if merchantRemote then
        pcall(function()
            merchantRemote:FireServer(weaponName)
            COMPLETED_TASKS.weapons_bought[weaponName] = true
        end)
        return true
    end
    return false
end

local function buyCombatStyle(styleName)
    local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and
                       ReplicatedStorage.RemoteEvents:FindFirstChild("AbilityRemote")
    
    if remoteEvent then
        pcall(function()
            remoteEvent:FireServer("buy_ability", styleName)
            COMPLETED_TASKS.combat_styles_bought[styleName] = true
        end)
        return true
    end
    return false
end

local function buyFruit(fruitName)
    local remoteEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") and
                       ReplicatedStorage.RemoteEvents:FindFirstChild("FruitAction")
    
    if remoteEvent then
        pcall(function()
            remoteEvent:FireServer("buy", fruitName)
            COMPLETED_TASKS.fruits_bought[fruitName] = true
        end)
        return true
    end
    return false
end

local function processAllPurchases()
    updateStatus("Comprando itens...")

    -- Tentar comprar armas disponíveis
    local shopConfig = ReplicatedStorage:FindFirstChild("Modules") and
                      ReplicatedStorage.Modules:FindFirstChild("ShopConfig")
    
    if shopConfig then
        local shops = require(shopConfig)
        
        for itemName, itemData in pairs(shops) do
            if itemData.Type == "Weapon" and not COMPLETED_TASKS.weapons_bought[itemName] then
                updateStatus("Comprando arma: " .. itemName)
                buyWeapon(itemName)
                wait(0.5)
            end
        end
    end

    -- Tentar comprar estilos de combate
    local abilityConfig = ReplicatedStorage:FindFirstChild("AbilitySystem") and
                         ReplicatedStorage.AbilitySystem:FindFirstChild("AbilityConfig")
    
    if abilityConfig then
        local abilities = require(abilityConfig)
        
        for abilityName, abilityData in pairs(abilities) do
            if not COMPLETED_TASKS.combat_styles_bought[abilityName] then
                updateStatus("Comprando estilo: " .. abilityName)
                buyCombatStyle(abilityName)
                wait(0.5)
            end
        end
    end

    -- Tentar comprar frutas
    local fruitConfig = ReplicatedStorage:FindFirstChild("FruitConfig")
    if fruitConfig then
        local fruits = require(fruitConfig)
        
        for fruitName, fruitData in pairs(fruits) do
            if not COMPLETED_TASKS.fruits_bought[fruitName] then
                updateStatus("Comprando fruta: " .. fruitName)
                buyFruit(fruitName)
                wait(0.5)
            end
        end
    end
end

-- ============================================================================
-- SISTEMA DE FARMING
-- ============================================================================

local function farmEnemies()
    updateStatus("Farmando inimigos...")

    while CONFIG.FARMING_ENABLED and CONFIG.AUTOMATION_ACTIVE do
        local enemy = findNearestEnemy()
        
        if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            TARGET_ENEMY = enemy
            attackEnemy(enemy)
        else
            -- Procurar novo inimigo
            wait(1)
        end

        -- Atualizar nível periodicamente
        getCurrentLevel()
    end
end

-- ============================================================================
-- SISTEMA DE PROGRESSÃO SEA 1
-- ============================================================================

local function progressSea1()
    updateStatus("Iniciando Sea 1...")

    while not CONFIG.SEA_1_COMPLETE and CONFIG.AUTOMATION_ACTIVE do
        local currentLevel = getCurrentLevel()
        
        -- Verificar missões secundárias
        processSecondaryMissions()
        
        -- Verificar se tem nível para avançar
        if currentLevel >= 30 then
            updateStatus("Nível suficiente para Sea 2!")
            CONFIG.SEA_1_COMPLETE = true
            break
        end

        -- Comprar itens disponíveis
        processAllPurchases()

        -- Farmar
        local enemy = findNearestEnemy()
        if enemy then
            attackEnemy(enemy)
        else
            wait(2)
        end

        wait(0.1)
    end
end

-- ============================================================================
-- SISTEMA DE PROGRESSÃO SEA 2
-- ============================================================================

local function progressSea2()
    updateStatus("Progredindo em Sea 2...")

    while CONFIG.SEA_2_REACHED and CONFIG.AUTOMATION_ACTIVE do
        local currentLevel = getCurrentLevel()

        -- Missões em Sea 2
        processSecondaryMissions()

        -- Compras em Sea 2
        processAllPurchases()

        -- Farmar
        local enemy = findNearestEnemy()
        if enemy then
            attackEnemy(enemy)
        else
            wait(2)
        end

        -- Verificar progresso
        if currentLevel >= 100 then
            updateStatus("Sea 2 Completo! Nível máximo atingido!")
            CONFIG.AUTOMATION_ACTIVE = false
            break
        end

        wait(0.1)
    end
end

-- ============================================================================
-- SISTEMA PRINCIPAL
-- ============================================================================

local function mainLoop()
    -- Aguardar inicialização do jogo
    wait(2)
    
    updateStatus("Preparando automação...")
    wait(1)

    -- Fase 1: Sea 1
    progressSea1()

    if CONFIG.SEA_1_COMPLETE then
        wait(2)
        CONFIG.SEA_2_REACHED = true
        progressSea2()
    end

    updateStatus("AUTOMAÇÃO CONCLUÍDA")
    CONFIG.AUTOMATION_ACTIVE = false
end

-- ============================================================================
-- TRATAMENTO DE RECONEXÃO
-- ============================================================================

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    updateStatus("Personagem recriado - continuando automação...")
end)

-- ============================================================================
-- INICIAR SCRIPT
-- ============================================================================

spawn(function()
    mainLoop()
end)

-- ============================================================================
-- LOOP PRINCIPAL DE ATUALIZAÇÃO
-- ============================================================================

RunService.Heartbeat:Connect(function()
    if CONFIG.AUTOMATION_ACTIVE then
        -- Manter vivo
        if humanoid.Health < CONFIG.MAX_HEALTH * 0.3 then
            updateStatus("Regenerando saúde...")
            wait(1)
        end

        -- Atualizar informações
        getCurrentLevel()
    end
end)

print("✓ Script KK carregado com sucesso!")
print("✓ Automação iniciada")
print("✓ Sistema rodando em background")
