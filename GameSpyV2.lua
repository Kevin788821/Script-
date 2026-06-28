-- ═══════════════════════════════════════════════════════════
--   GAMESPY v2.0 - Universal Game Analyzer
--   Funciona em QUALQUER jogo do Roblox
--   Extrai dados técnicos + dados de gameplay
-- ═══════════════════════════════════════════════════════════

local Results = {}
local SectionCount = 0

-- ==================== UTILITÁRIOS ====================
local function AddLine(text)
    table.insert(Results, text)
end

local function AddSection(title)
    SectionCount = SectionCount + 1
    AddLine("")
    AddLine("╔══════════════════════════════════════════════════════════╗")
    AddLine("║  " .. string.format("%02d", SectionCount) .. ".  " .. title .. string.rep(" ", math.max(0, 52 - #title)) .. "║")
    AddLine("╚══════════════════════════════════════════════════════════╝")
end

local function AddSubSection(title)
    AddLine("")
    AddLine("  ┌─────────────────────────────────────────")
    AddLine("  │  " .. title)
    AddLine("  └─────────────────────────────────────────")
end

local function AddItem(label, value)
    if value then
        AddLine("  │  " .. label .. ": " .. tostring(value))
    else
        AddLine("  │  " .. label)
    end
end

local function AddBlank()
    AddLine("  │")
end

local function SafeGet(fn)
    local ok, result = pcall(fn)
    if ok then return result end
    return nil
end

-- ==================== HEADER ====================
local function BuildHeader()
    AddLine("╔══════════════════════════════════════════════════════════╗")
    AddLine("║                                                          ║")
    AddLine("║           🔍  GAMESPY v2.0 - UNIVERSAL ANALYZER         ║")
    AddLine("║                                                          ║")
    AddLine("╠══════════════════════════════════════════════════════════╣")
    AddLine("║  Data    : " .. os.date("%d/%m/%Y") .. "                                       ║")
    AddLine("║  Hora    : " .. os.date("%H:%M:%S") .. "                                          ║")
    AddLine("║  Jogo    : " .. tostring(game.Name):sub(1,40) .. string.rep(" ", math.max(0, 40 - #tostring(game.Name))) .. "   ║")
    AddLine("║  PlaceID : " .. tostring(game.PlaceId) .. string.rep(" ", math.max(0, 46 - #tostring(game.PlaceId))) .. "║")
    AddLine("╚══════════════════════════════════════════════════════════╝")
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 1 - REMOTE EVENTS
-- ══════════════════════════════════════════════════════
local function ScanRemoteEvents()
    AddSection("REMOTE EVENTS")
    
    local locations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"),
    }
    
    local count = 0
    for _, location in pairs(locations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    AddItem("📡 " .. obj:GetFullName())
                    count = count + 1
                end
            end
        end
    end
    
    AddBlank()
    AddItem("Total RemoteEvents", count)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 2 - REMOTE FUNCTIONS
-- ══════════════════════════════════════════════════════
local function ScanRemoteFunctions()
    AddSection("REMOTE FUNCTIONS")
    
    local count = 0
    for _, obj in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if obj:IsA("RemoteFunction") then
            AddItem("🔌 " .. obj:GetFullName())
            count = count + 1
        end
    end
    
    AddBlank()
    AddItem("Total RemoteFunctions", count)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 3 - SCRIPTS & MODULES
-- ══════════════════════════════════════════════════════
local function ScanScripts()
    AddSection("SCRIPTS & MODULES")
    
    local locations = {
        game:GetService("ReplicatedStorage"),
        game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui"),
        game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer:FindFirstChild("Backpack"),
    }
    
    local scripts = 0
    local localScripts = 0
    local modules = 0
    
    AddSubSection("Scripts")
    for _, location in pairs(locations) do
        if location then
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("Script") then
                    AddItem("📜 " .. obj:GetFullName())
                    scripts = scripts + 1
                elseif obj:IsA("LocalScript") then
                    AddItem("📄 " .. obj:GetFullName())
                    localScripts = localScripts + 1
                elseif obj:IsA("ModuleScript") then
                    AddItem("📦 " .. obj:GetFullName())
                    modules = modules + 1
                end
            end
        end
    end
    
    AddBlank()
    AddItem("Total Scripts", scripts)
    AddItem("Total LocalScripts", localScripts)
    AddItem("Total ModuleScripts", modules)
    AddItem("TOTAL GERAL", scripts + localScripts + modules)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 4 - SERVIÇOS DO JOGO
-- ══════════════════════════════════════════════════════
local function ScanServices()
    AddSection("SERVIÇOS DO JOGO")
    
    local serviceList = {
        "Workspace", "ReplicatedStorage", "ServerScriptService",
        "Players", "DataStoreService", "RunService",
        "UserInputService", "TweenService", "SoundService",
        "HttpService", "MarketplaceService", "BadgeService",
        "TeleportService", "GroupService", "TextService",
        "VirtualInputManager", "GuiService", "StarterGui",
        "StarterPack", "StarterPlayer", "Teams", "Chat",
        "LocalizationService", "TestService", "PhysicsService",
        "CollectionService", "Selection", "CoreGui",
    }
    
    for _, serviceName in pairs(serviceList) do
        local ok, service = pcall(function() return game:GetService(serviceName) end)
        if ok and service then
            AddItem("✅ " .. serviceName)
        else
            AddItem("❌ " .. serviceName .. " (não disponível)")
        end
    end
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 5 - NPCS & PERSONAGENS
-- ══════════════════════════════════════════════════════
local function ScanNPCs()
    AddSection("NPCs & PERSONAGENS")
    
    local count = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and not obj.Parent:FindFirstAncestor("Players") then
            local npc = obj.Parent
            local root = npc:FindFirstChild("HumanoidRootPart")
            local pos = root and root.Position or Vector3.new(0,0,0)
            
            AddSubSection("NPC: " .. npc.Name)
            AddItem("  Saúde", obj.Health .. "/" .. obj.MaxHealth)
            AddItem("  Posição", string.format("X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z))
            AddItem("  WalkSpeed", obj.WalkSpeed)
            AddItem("  RigType", tostring(obj.RigType))
            
            -- Animações
            local anims = npc:FindFirstChild("Animations") or npc:FindFirstChild("AnimSaves")
            if anims then
                AddItem("  Animações", #anims:GetChildren())
            end
            
            -- ProximityPrompts
            local prompts = {}
            for _, pp in pairs(npc:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then
                    table.insert(prompts, pp.ActionText ~= "" and pp.ActionText or pp.Name)
                end
            end
            if #prompts > 0 then
                AddItem("  Interações", table.concat(prompts, ", "))
            end
            
            count = count + 1
        end
    end
    
    AddBlank()
    AddItem("Total NPCs encontrados", count)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 6 - SPAWN POINTS & LOCAIS IMPORTANTES
-- ══════════════════════════════════════════════════════
local function ScanSpawnPoints()
    AddSection("SPAWN POINTS & LOCAIS IMPORTANTES")
    
    local spawnCount = 0
    local teleportCount = 0
    
    AddSubSection("Spawn Points")
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            local pos = obj.Position
            AddItem("🏁 " .. obj.Name, string.format("X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z))
            spawnCount = spawnCount + 1
        end
    end
    
    AddSubSection("Teleportes")
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("teleport") or obj.Name:lower():find("warp") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
                if pos then
                    AddItem("🔀 " .. obj:GetFullName(), string.format("X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z))
                    teleportCount = teleportCount + 1
                end
            end
        end
    end
    
    AddSubSection("Lojas / Shops")
    for _, obj in pairs(workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if name:find("shop") or name:find("store") or name:find("loja") or name:find("market") then
            if obj:IsA("BasePart") or obj:IsA("Model") then
                AddItem("🏪 " .. obj:GetFullName())
            end
        end
    end
    
    AddBlank()
    AddItem("Total SpawnPoints", spawnCount)
    AddItem("Total Teleportes", teleportCount)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 7 - VALORES & CONFIGURAÇÕES DO JOGO
-- ══════════════════════════════════════════════════════
local function ScanValues()
    AddSection("VALORES & CONFIGURAÇÕES DO JOGO")
    
    local repStorage = game:GetService("ReplicatedStorage")
    local numberCount = 0
    local stringCount = 0
    local boolCount = 0
    
    AddSubSection("NumberValues")
    for _, obj in pairs(repStorage:GetDescendants()) do
        if obj:IsA("NumberValue") then
            AddItem("🔢 " .. obj.Name, obj.Value)
            numberCount = numberCount + 1
        end
    end
    
    AddSubSection("StringValues")
    for _, obj in pairs(repStorage:GetDescendants()) do
        if obj:IsA("StringValue") then
            AddItem("📝 " .. obj.Name, '"' .. tostring(obj.Value):sub(1,40) .. '"')
            stringCount = stringCount + 1
        end
    end
    
    AddSubSection("BoolValues")
    for _, obj in pairs(repStorage:GetDescendants()) do
        if obj:IsA("BoolValue") then
            AddItem("✔️ " .. obj.Name, obj.Value and "TRUE" or "FALSE")
            boolCount = boolCount + 1
        end
    end
    
    AddBlank()
    AddItem("Total NumberValues", numberCount)
    AddItem("Total StringValues", stringCount)
    AddItem("Total BoolValues", boolCount)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 8 - MECÂNICAS DO JOGO
-- ══════════════════════════════════════════════════════
local function ScanMechanics()
    AddSection("MECÂNICAS DO JOGO")
    
    -- Ciclo dia/noite
    AddSubSection("Ciclo Dia/Noite")
    local lighting = game:GetService("Lighting")
    AddItem("TimeOfDay", lighting.TimeOfDay)
    AddItem("Brightness", lighting.Brightness)
    AddItem("Ambient", tostring(lighting.Ambient))
    AddItem("FogEnd", lighting.FogEnd)
    AddItem("ClockTime", lighting.ClockTime)
    
    -- Gravity
    AddSubSection("Física")
    AddItem("Gravidade", workspace.Gravity)
    AddItem("StreamingEnabled", tostring(workspace.StreamingEnabled))
    
    -- Atmosphere
    local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
    if atmosphere then
        AddSubSection("Atmosfera")
        AddItem("Density", atmosphere.Density)
        AddItem("Color", tostring(atmosphere.Color))
    end
    
    -- Sounds
    AddSubSection("Sons")
    local soundCount = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Sound") and obj.Playing then
            AddItem("🔊 " .. obj.Name, "SoundId: " .. obj.SoundId)
            soundCount = soundCount + 1
        end
    end
    AddItem("Sons ativos", soundCount)
    
    -- ProximityPrompts gerais
    AddSubSection("ProximityPrompts (Interações)")
    local ppCount = 0
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") then
            local action = obj.ActionText ~= "" and obj.ActionText or obj.Name
            AddItem("🖱️ " .. action, "Em: " .. obj.Parent.Name)
            ppCount = ppCount + 1
        end
    end
    AddItem("Total Interações", ppCount)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 9 - ATRIBUTOS CUSTOMIZADOS
-- ══════════════════════════════════════════════════════
local function ScanAttributes()
    AddSection("ATRIBUTOS CUSTOMIZADOS")
    
    AddSubSection("Attributes no Workspace")
    local wsAttrs = workspace:GetAttributes()
    if next(wsAttrs) then
        for key, value in pairs(wsAttrs) do
            AddItem("🏷️ " .. key, tostring(value))
        end
    else
        AddItem("Nenhum attribute encontrado no Workspace")
    end
    
    AddSubSection("Attributes no ReplicatedStorage")
    local rsAttrs = game:GetService("ReplicatedStorage"):GetAttributes()
    if next(rsAttrs) then
        for key, value in pairs(rsAttrs) do
            AddItem("🏷️ " .. key, tostring(value))
        end
    else
        AddItem("Nenhum attribute encontrado no ReplicatedStorage")
    end
    
    -- CollectionService Tags
    AddSubSection("CollectionService Tags")
    local ok, cs = pcall(function() return game:GetService("CollectionService") end)
    if ok then
        local tags = cs:GetAllTags()
        if #tags > 0 then
            for _, tag in pairs(tags) do
                local tagged = cs:GetTagged(tag)
                AddItem("🔖 " .. tag, #tagged .. " objeto(s)")
            end
        else
            AddItem("Nenhuma tag encontrada")
        end
    end
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 10 - ITEMS/LOOT DO JOGO
-- ══════════════════════════════════════════════════════
local function ScanItems()
    AddSection("ITEMS & LOOT")
    
    local toolCount = 0
    local partCount = 0
    
    -- Tools no workspace
    AddSubSection("Ferramentas/Tools no Mapa")
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            AddItem("🔧 " .. obj.Name, "Em: " .. (obj.Parent and obj.Parent.Name or "?"))
            toolCount = toolCount + 1
        end
    end
    
    -- Items coletáveis
    AddSubSection("Items Coletáveis (com ProximityPrompt)")
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local pp = obj:FindFirstChildOfClass("ProximityPrompt")
            if pp then
                local pos = obj.Position
                AddItem("📦 " .. obj.Name, string.format("Pos: X:%.1f Y:%.1f Z:%.1f", pos.X, pos.Y, pos.Z))
                partCount = partCount + 1
            end
        end
    end
    
    -- Items no ReplicatedStorage (assets)
    AddSubSection("Assets no ReplicatedStorage")
    local assetCount = 0
    local repStorage = game:GetService("ReplicatedStorage")
    for _, folder in pairs(repStorage:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Model") then
            AddItem("📁 " .. folder.Name, #folder:GetChildren() .. " itens")
            assetCount = assetCount + 1
        end
    end
    
    AddBlank()
    AddItem("Total Tools", toolCount)
    AddItem("Total Coletáveis", partCount)
    AddItem("Total Asset Folders", assetCount)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 11 - LEADERBOARD / STATS
-- ══════════════════════════════════════════════════════
local function ScanLeaderboard()
    AddSection("LEADERBOARD & STATS")
    
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer
    
    -- Leaderstats
    AddSubSection("Leaderstats do Player")
    local leaderstats = localPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, stat in pairs(leaderstats:GetChildren()) do
            AddItem("📊 " .. stat.Name, tostring(stat.Value))
        end
    else
        AddItem("Nenhum leaderstats encontrado")
    end
    
    -- PlayerData
    AddSubSection("PlayerData / PlayerValues")
    for _, child in pairs(localPlayer:GetChildren()) do
        if child:IsA("NumberValue") or child:IsA("StringValue") or child:IsA("BoolValue") then
            AddItem("📈 " .. child.Name, tostring(child.Value))
        end
        if child:IsA("Folder") then
            AddItem("📂 " .. child.Name, #child:GetChildren() .. " valores")
            for _, val in pairs(child:GetChildren()) do
                AddItem("    └─ " .. val.Name, tostring(SafeGet(function() return val.Value end) or "?"))
            end
        end
    end
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 12 - ZONAS & ÁREAS DO MAPA
-- ══════════════════════════════════════════════════════
local function ScanZones()
    AddSection("ZONAS & ÁREAS DO MAPA")
    
    local zoneKeywords = {"zone", "area", "region", "safe", "pvp", "base", "hub", "lobby"}
    local found = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        for _, keyword in pairs(zoneKeywords) do
            if nameLower:find(keyword) then
                if obj:IsA("BasePart") or obj:IsA("Model") or obj:IsA("Folder") then
                    if not found[obj.Name] then
                        found[obj.Name] = true
                        local pos = ""
                        if obj:IsA("BasePart") then
                            pos = string.format("X:%.1f Y:%.1f Z:%.1f", obj.Position.X, obj.Position.Y, obj.Position.Z)
                        end
                        AddItem("🗺️ " .. obj.Name, pos ~= "" and pos or obj.ClassName)
                    end
                end
                break
            end
        end
    end
    
    if not next(found) then
        AddItem("Nenhuma zona específica detectada")
    end
    
    -- Dimensões do mapa
    AddSubSection("Dimensões do Mapa")
    local minX, minZ, maxX, maxZ = math.huge, math.huge, -math.huge, -math.huge
    local partCount = 0
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            local pos = obj.Position
            minX = math.min(minX, pos.X)
            minZ = math.min(minZ, pos.Z)
            maxX = math.max(maxX, pos.X)
            maxZ = math.max(maxZ, pos.Z)
            partCount = partCount + 1
        end
    end
    
    if partCount > 0 then
        AddItem("Largura (X)", string.format("%.1f studs", maxX - minX))
        AddItem("Profundidade (Z)", string.format("%.1f studs", maxZ - minZ))
        AddItem("Limite X", string.format("%.1f até %.1f", minX, maxX))
        AddItem("Limite Z", string.format("%.1f até %.1f", minZ, maxZ))
        AddItem("Total Parts", partCount)
    end
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 13 - GUI / INTERFACE
-- ══════════════════════════════════════════════════════
local function ScanGUI()
    AddSection("GUI & INTERFACE")
    
    local playerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    local guiCount = 0
    
    for _, gui in pairs(playerGui:GetChildren()) do
        AddSubSection("ScreenGui: " .. gui.Name)
        AddItem("  Enabled", tostring(gui.Enabled))
        AddItem("  ResetOnSpawn", tostring(SafeGet(function() return gui.ResetOnSpawn end)))
        AddItem("  Total elementos", #gui:GetDescendants())
        
        -- Lista os frames principais
        for _, child in pairs(gui:GetChildren()) do
            AddItem("  └─ " .. child.ClassName, child.Name)
        end
        
        guiCount = guiCount + 1
    end
    
    AddBlank()
    AddItem("Total GUIs encontradas", guiCount)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 14 - ESTRUTURA COMPLETA
-- ══════════════════════════════════════════════════════
local function ScanStructure()
    AddSection("ESTRUTURA COMPLETA DO JOGO")
    
    local function Scan(parent, depth)
        if depth > 3 then return end
        local indent = string.rep("  ", depth)
        
        for _, child in pairs(parent:GetChildren()) do
            AddItem(indent .. "[".. child.ClassName .."] " .. child.Name)
            Scan(child, depth + 1)
        end
    end
    
    AddSubSection("Workspace")
    Scan(workspace, 0)
    
    AddSubSection("ReplicatedStorage")
    Scan(game:GetService("ReplicatedStorage"), 0)
end

-- ══════════════════════════════════════════════════════
--   SEÇÃO 15 - SUMÁRIO FINAL
-- ══════════════════════════════════════════════════════
local function BuildSummary()
    AddSection("SUMÁRIO FINAL")
    
    -- Conta tudo
    local remoteEvents = 0
    local remoteFunctions = 0
    local scripts = 0
    local npcs = 0
    local tools = 0
    local guis = 0
    local values = 0
    local prompts = 0
    
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") then remoteEvents = remoteEvents + 1
        elseif obj:IsA("RemoteFunction") then remoteFunctions = remoteFunctions + 1
        elseif obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then scripts = scripts + 1
        elseif obj:IsA("Humanoid") then npcs = npcs + 1
        elseif obj:IsA("Tool") then tools = tools + 1
        elseif obj:IsA("ScreenGui") then guis = guis + 1
        elseif obj:IsA("NumberValue") or obj:IsA("StringValue") or obj:IsA("BoolValue") then values = values + 1
        elseif obj:IsA("ProximityPrompt") then prompts = prompts + 1
        end
    end
    
    AddLine("")
    AddLine("  ╔═══════════════════════════════════╗")
    AddLine("  ║         CONTAGEM TOTAL            ║")
    AddLine("  ╠═══════════════════════════════════╣")
    AddLine("  ║  📡 RemoteEvents    : " .. string.format("%-14s", remoteEvents) .. "║")
    AddLine("  ║  🔌 RemoteFunctions : " .. string.format("%-14s", remoteFunctions) .. "║")
    AddLine("  ║  📜 Scripts         : " .. string.format("%-14s", scripts) .. "║")
    AddLine("  ║  👾 NPCs            : " .. string.format("%-14s", npcs) .. "║")
    AddLine("  ║  🔧 Tools           : " .. string.format("%-14s", tools) .. "║")
    AddLine("  ║  🖥️  GUIs            : " .. string.format("%-14s", guis) .. "║")
    AddLine("  ║  📊 Values          : " .. string.format("%-14s", values) .. "║")
    AddLine("  ║  🖱️  ProximityPrompts: " .. string.format("%-14s", prompts) .. "║")
    AddLine("  ╚═══════════════════════════════════╝")
    AddLine("")
    AddLine("  ✅ Análise concluída com sucesso!")
end

-- ══════════════════════════════════════════════════════
--   FOOTER
-- ══════════════════════════════════════════════════════
local function BuildFooter()
    AddLine("")
    AddLine("╔══════════════════════════════════════════════════════════╗")
    AddLine("║         GAMESPY v2.0 - Relatório Gerado com Sucesso      ║")
    AddLine("║              Copiado para área de transferência!         ║")
    AddLine("╚══════════════════════════════════════════════════════════╝")
end

-- ══════════════════════════════════════════════════════
--   EXECUTAR ANÁLISE
-- ══════════════════════════════════════════════════════
print("🔍 GameSpy v2.0 iniciando análise...")

BuildHeader()
ScanRemoteEvents()
ScanRemoteFunctions()
ScanScripts()
ScanServices()
ScanNPCs()
ScanSpawnPoints()
ScanValues()
ScanMechanics()
ScanAttributes()
ScanItems()
ScanLeaderboard()
ScanZones()
ScanGUI()
ScanStructure()
BuildSummary()
BuildFooter()

-- ══════════════════════════════════════════════════════
--   COPIAR PARA CLIPBOARD
-- ══════════════════════════════════════════════════════
local report = table.concat(Results, "\n")

local copied = false

-- Método 1: setclipboard (executores)
local ok1 = pcall(function()
    if setclipboard then
        setclipboard(report)
        copied = true
    end
end)

-- Método 2: Clipboard nativo
if not copied then
    local ok2 = pcall(function()
        if rbxassetid then return end
        local ss = game:GetService("GuiService")
        if ss and ss.SetClipboard then
            ss:SetClipboard(report)
            copied = true
        end
    end)
end

-- Sempre printa no console também
print(report)

if copied then
    print("\n✅ RELATÓRIO COPIADO PARA O CLIPBOARD! Cole com Ctrl+V")
else
    print("\n⚠️  Copie o texto acima manualmente (Ctrl+A, Ctrl+C no console)")
end

print("📊 Total de linhas no relatório: " .. #Results)
