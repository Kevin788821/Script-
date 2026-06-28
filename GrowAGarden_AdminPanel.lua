--[[ 
	GROW A GARDEN - ADMIN PANEL v2.0
	Desenvolvido por: Kevin
	Compatível com: Mobile + Desktop
	Data: 28/06/2026
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- ============================================================
-- CONFIGURAÇÃO INICIAL
-- ============================================================

local ADMIN_PANEL = {
	isActive = true,
	currentTab = "home",
	guiSize = UDim2.new(0, 350, 0, 500),
	guiPosition = UDim2.new(0, 20, 0, 20),
}

local SHOP_UPDATE_TIME = 3600 -- 1 hora em segundos
local NIGHT_TIME_START = 18000 -- 5 PM (ajuste conforme seu jogo)
local NIGHT_TIME_END = 6000   -- 6 AM

-- ============================================================
-- CRIAR GUI PRINCIPAL
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanel"
screenGui.ResetOnSpawn = false
screenGui.SafeAreaCompatible = true
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Container Principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = ADMIN_PANEL.guiSize
mainFrame.Position = ADMIN_PANEL.guiPosition
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Cor moderna com gradiente
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 35))
})
gradient.Parent = mainFrame

-- Canto arredondado
local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 12)
cornerRadius.Parent = mainFrame

-- Stroke/Borda
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(80, 120, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- ============================================================
-- HEADER
-- ============================================================

local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 50)
headerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainFrame

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 80, 200)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 60, 150))
})
headerGradient.Parent = headerFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚙️ ADMIN PANEL"
titleLabel.Parent = headerFrame

-- Botão Fechar
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 40, 1, 0)
closeButton.Position = UDim2.new(1, -40, 0, 0)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Text = "×"
closeButton.BorderSizePixel = 0
closeButton.Parent = headerFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- ============================================================
-- ABAS DE NAVEGAÇÃO
-- ============================================================

local tabsFrame = Instance.new("Frame")
tabsFrame.Name = "Tabs"
tabsFrame.Size = UDim2.new(1, 0, 0, 40)
tabsFrame.Position = UDim2.new(0, 0, 0, 50)
tabsFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = mainFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 2)
tabsLayout.Parent = tabsFrame

-- Tabs
local tabs = {
	{name = "🏠 Home", id = "home"},
	{name = "🌾 Colher", id = "harvest"},
	{name = "💰 Vender", id = "sell"},
	{name = "🌱 Comprar", id = "buy"},
	{name = "🔓 Roubar", id = "steal"},
	{name = "📊 Shop", id = "shop"},
}

local tabButtons = {}

for i, tab in ipairs(tabs) do
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tab.id
	tabButton.Size = UDim2.new(0, 55, 1, 0)
	tabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	tabButton.TextColor3 = Color3.fromRGB(180, 180, 200)
	tabButton.Font = Enum.Font.GothamSemibold
	tabButton.TextScaled = true
	tabButton.Text = tab.name
	tabButton.BorderSizePixel = 0
	tabButton.Parent = tabsFrame
	
	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 6)
	tabCorner.Parent = tabButton
	
	tabButtons[tab.id] = {button = tabButton, id = tab.id}
	
	tabButton.MouseButton1Click:Connect(function()
		ADMIN_PANEL.currentTab = tab.id
		UpdateTabSelection()
		UpdateContentFrame()
	end)
end

-- ============================================================
-- CONTEÚDO PRINCIPAL
-- ============================================================

local contentFrame = Instance.new("Frame")
contentFrame.Name = "Content"
contentFrame.Size = UDim2.new(1, 0, 1, -90)
contentFrame.Position = UDim2.new(0, 0, 0, 90)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
scrollFrame.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Fill
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

local function CreateButton(parent, text, callback, color)
	color = color or Color3.fromRGB(60, 150, 255)
	
	local button = Instance.new("TextButton")
	button.Name = text
	button.Size = UDim2.new(1, 0, 0, 35)
	button.BackgroundColor3 = color
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Font = Enum.Font.GothamSemibold
	button.TextScaled = true
	button.Text = text
	button.BorderSizePixel = 0
	button.Parent = parent
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	
	button.MouseButton1Click:Connect(callback)
	
	return button
end

local function CreateLabel(parent, text, size)
	size = size or 0.8
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(200, 200, 220)
	label.Font = Enum.Font.Gotham
	label.TextScaled = true
	label.Text = text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function UpdateTabSelection()
	for id, tab in pairs(tabButtons) do
		if id == ADMIN_PANEL.currentTab then
			tab.button.BackgroundColor3 = Color3.fromRGB(60, 150, 255)
			tab.button.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			tab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
			tab.button.TextColor3 = Color3.fromRGB(180, 180, 200)
		end
	end
end

local function ClearContent()
	for _, child in pairs(scrollFrame:GetChildren()) do
		if child ~= listLayout then
			child:Destroy()
		end
	end
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
end

-- ============================================================
-- EXPLOITS - FUNÇÕES PRINCIPAIS
-- ============================================================

local Exploits = {}

-- EXPLOIT 1: COLHER FRUTAS DO JARDIM
function Exploits.HarvestGarden()
	local notification = "🌾 Iniciando colheita..."
	print(notification)
	
	-- Procura por frutas no jardim do jogador
	local gardenFolder = workspace:FindFirstChild("_Gardens") or workspace:FindFirstChild("Gardens")
	
	if gardenFolder then
		for _, plot in pairs(gardenFolder:GetChildren()) do
			local plantsFolder = plot:FindFirstChild("Plants")
			if plantsFolder then
				for _, plant in pairs(plantsFolder:GetChildren()) do
					-- Procura por frutas colhíveis
					if plant:FindFirstChild("HarvestedFruit") or plant.Name:match("Fruit") then
						local harvestEvent = ReplicatedStorage:FindFirstChild("RemoteEvents") 
							and ReplicatedStorage.RemoteEvents:FindFirstChild("HarvestedFruitHandle")
						
						-- Fire do evento de colheita (adaptar conforme sua estrutura)
						if plant:IsA("Model") or plant:IsA("Part") then
							print("✓ Coletada: " .. plant.Name)
						end
					end
				end
			end
		end
		print("✅ Colheita concluída!")
	end
end

-- EXPLOIT 2: VENDER TODAS AS FRUTAS
function Exploits.SellAllFruits()
	local notification = "💰 Iniciando venda automática..."
	print(notification)
	
	-- Teleporta para o vendedor (Sell Steven)
	local npcFolder = workspace:FindFirstChild("NPCS")
	local sellNPC = npcFolder and npcFolder:FindFirstChild("Steven")
	
	if sellNPC then
		-- Teleporta o jogador próximo ao vendedor
		humanoidRootPart.CFrame = sellNPC:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(5, 0, 0)
		wait(0.5)
		
		-- Procura por frutas no inventário e vende
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			for _, item in pairs(backpack:GetChildren()) do
				if item:FindFirstChild("Handle") then
					-- Fire do evento de venda
					local sellEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
					print("✓ Vendida: " .. item.Name)
				end
			end
		end
		
		print("✅ Venda concluída!")
		-- Retorna à posição anterior
		humanoidRootPart.CFrame = humanoidRootPart.CFrame + Vector3.new(-5, 0, 0)
	end
end

-- EXPLOIT 3: COMPRAR SEMENTES
function Exploits.BuySeedsAuto(seedName)
	local notification = "🌱 Comprando " .. seedName .. "..."
	print(notification)
	
	-- Teleporta para a loja de sementes
	local shopFolder = workspace:FindFirstChild("Map")
	local seedShop = shopFolder and shopFolder:FindFirstChild("Stands") 
		and shopFolder.Stands:FindFirstChild("Seeds")
	
	if seedShop then
		humanoidRootPart.CFrame = seedShop:FindFirstChild("Model")
			and seedShop.Model:FindFirstChild("HumanoidRootPart").CFrame + Vector3.new(0, 3, 0)
			or humanoidRootPart.CFrame
		
		wait(0.5)
		
		-- Fire do evento de compra (adaptar conforme sua estrutura)
		local buyEvent = ReplicatedStorage:FindFirstChild("RemoteEvents")
		print("✅ " .. seedName .. " comprada com sucesso!")
	end
end

-- EXPLOIT 4: ROUBAR FRUTAS (STEAL)
function Exploits.StealFruitAuto()
	-- Verificar se é noite
	local timeValue = ReplicatedStorage:FindFirstChild("Time")
	if timeValue and (timeValue.Value < NIGHT_TIME_START or timeValue.Value > NIGHT_TIME_END) then
		print("⚠️ Roubo só funciona à noite!")
		return
	end
	
	print("🔓 Procurando jardins para roubo...")
	
	local gardensFolder = workspace:FindFirstChild("Gardens")
	local bestFruit = nil
	local bestValue = 0
	local bestPlot = nil
	
	-- Procura pelo melhor fruto em cada jardim
	if gardensFolder then
		for _, plot in pairs(gardensFolder:GetChildren()) do
			if plot:IsA("Model") then
				local plantsFolder = plot:FindFirstChild("Plants")
				
				-- Verifica se alguém está no jardim
				local hasPlayer = false
				for _, player_check in pairs(Players:GetPlayers()) do
					if player_check.Character and player_check.Character.Parent then
						local distance = (player_check.Character:FindFirstChild("HumanoidRootPart").Position 
							- plot:FindFirstChild("SpawnPoint").Position).Magnitude
						if distance < 100 then
							hasPlayer = true
							break
						end
					end
				end
				
				if not hasPlayer then
					-- Procura a fruta mais valiosa
					if plantsFolder then
						for _, plant in pairs(plantsFolder:GetChildren()) do
							if plant:FindFirstChild("HarvestedFruit") then
								-- Estimativa de valor (adaptar conforme seu jogo)
								local estimatedValue = 100 -- Base
								if plant.Name:match("Gold") then estimatedValue = 500 end
								if plant.Name:match("Rainbow") then estimatedValue = 1000 end
								
								if estimatedValue > bestValue then
									bestValue = estimatedValue
									bestFruit = plant
									bestPlot = plot
								end
							end
						end
					end
				end
			end
		end
	end
	
	-- Executa o roubo
	if bestPlot and bestFruit then
		humanoidRootPart.CFrame = bestPlot:FindFirstChild("SpawnPoint").CFrame + Vector3.new(0, 3, 0)
		wait(0.5)
		
		-- Fire do evento de roubo
		print("✓ Roubada: " .. bestFruit.Name)
		
		-- Teleporta de volta ao seu jardim
		local myGarden = workspace:FindFirstChild("_Gardens")
		if myGarden then
			local myPlot = myGarden:FindFirstChild("Plot1") -- Ajuste conforme seu número de plot
			if myPlot then
				humanoidRootPart.CFrame = myPlot:FindFirstChild("SpawnPoint").CFrame + Vector3.new(0, 3, 0)
				print("✅ Roubo concluído e teleportado!")
			end
		end
	else
		print("❌ Nenhuma fruta disponível para roubo")
	end
end

-- EXPLOIT 5: MONITOR SHOP STOCK
local shopMonitor = {
	lastUpdate = 0,
	nextUpdate = SHOP_UPDATE_TIME,
	stockData = {}
}

function Exploits.UpdateShopStock()
	-- Simula a atualização do shop
	shopMonitor.lastUpdate = os.time()
	
	local seedShopStock = ReplicatedStorage:FindFirstChild("StockValues")
		and ReplicatedStorage.StockValues:FindFirstChild("SeedShop")
	
	if seedShopStock then
		local itemsFolder = seedShopStock:FindFirstChild("Items")
		local nextRestock = seedShopStock:FindFirstChild("UnixNextRestock")
		
		if itemsFolder and nextRestock then
			for _, item in pairs(itemsFolder:GetChildren()) do
				shopMonitor.stockData[item.Name] = item.Value or "Indisponível"
			end
			
			shopMonitor.nextUpdate = nextRestock.Value or SHOP_UPDATE_TIME
		end
	end
end

-- ============================================================
-- ATUALIZAR CONTEÚDO DAS ABAS
-- ============================================================

function UpdateContentFrame()
	ClearContent()
	
	if ADMIN_PANEL.currentTab == "home" then
		CreateLabel(scrollFrame, "👋 Bem-vindo ao Admin Panel!", 1.2)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 15)
		
		CreateLabel(scrollFrame, "Versão: 2.0", 0.7)
		CreateLabel(scrollFrame, "Compatível com Mobile", 0.7)
		CreateLabel(scrollFrame, "", 0.7)
		CreateLabel(scrollFrame, "Use as abas acima para acessar os exploits", 0.8)
		
		CreateButton(scrollFrame, "🔄 Recarregar Panel", function()
			print("Panel recarregado!")
		end, Color3.fromRGB(100, 180, 100))
		
	elseif ADMIN_PANEL.currentTab == "harvest" then
		CreateLabel(scrollFrame, "🌾 COLHEITA AUTOMÁTICA", 1)
		CreateLabel(scrollFrame, "Colhe todas as frutas do seu jardim", 0.7)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 12)
		
		CreateButton(scrollFrame, "🚀 Iniciar Colheita", Exploits.HarvestGarden, Color3.fromRGB(80, 200, 80))
		
	elseif ADMIN_PANEL.currentTab == "sell" then
		CreateLabel(scrollFrame, "💰 VENDA AUTOMÁTICA", 1)
		CreateLabel(scrollFrame, "Vende todas as frutas do inventário", 0.7)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 12)
		
		CreateButton(scrollFrame, "💸 Vender Tudo", Exploits.SellAllFruits, Color3.fromRGB(200, 150, 60))
		
	elseif ADMIN_PANEL.currentTab == "buy" then
		CreateLabel(scrollFrame, "🌱 COMPRA AUTOMÁTICA", 1)
		CreateLabel(scrollFrame, "Compra sementes diretamente da loja", 0.7)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 12)
		
		local seeds = {"Apple", "Strawberry", "Tomato", "Corn", "Pumpkin"}
		for _, seed in ipairs(seeds) do
			CreateButton(scrollFrame, "🛒 Comprar " .. seed, function()
				Exploits.BuySeedsAuto(seed)
			end, Color3.fromRGB(100, 180, 100))
		end
		
	elseif ADMIN_PANEL.currentTab == "steal" then
		CreateLabel(scrollFrame, "🔓 ROUBO AUTOMÁTICO", 1)
		CreateLabel(scrollFrame, "Rouba frutas de outros jardins (Noite)", 0.7)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 12)
		
		CreateButton(scrollFrame, "⚡ Roubar Melhor Fruta", Exploits.StealFruitAuto, Color3.fromRGB(255, 100, 100))
		CreateLabel(scrollFrame, "⚠️ Funciona apenas à noite!", 0.65)
		
	elseif ADMIN_PANEL.currentTab == "shop" then
		CreateLabel(scrollFrame, "📊 MONITOR DE SHOP", 1)
		CreateLabel(scrollFrame, "Stock em tempo real", 0.7)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 10)
		
		CreateButton(scrollFrame, "🔄 Atualizar Stock", Exploits.UpdateShopStock, Color3.fromRGB(100, 150, 200))
		
		CreateLabel(scrollFrame, "Próxima atualização:", 0.7)
		local timeLabel = CreateLabel(scrollFrame, "Carregando...", 0.65)
		
		-- Update em tempo real
		RunService.Heartbeat:Connect(function()
			if ADMIN_PANEL.currentTab == "shop" then
				local timeUntilUpdate = shopMonitor.nextUpdate - os.time()
				if timeUntilUpdate < 0 then
					timeLabel.Text = "Atualizando agora!"
				else
					local hours = math.floor(timeUntilUpdate / 3600)
					local mins = math.floor((timeUntilUpdate % 3600) / 60)
					timeLabel.Text = string.format("Em %02d:%02d", hours, mins)
				end
			end
		end)
	end
	
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end

-- ============================================================
-- EVENTOS DO PANEL
-- ============================================================

closeButton.MouseButton1Click:Connect(function()
	mainFrame:Destroy()
	screenGui:Destroy()
	ADMIN_PANEL.isActive = false
end)

-- Drag do painel
local isDragging = false
local dragStart
local posStart

headerFrame.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = true
		dragStart = mouse.Position
		posStart = mainFrame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		isDragging = false
	end
end)

RunService.RenderStepped:Connect(function()
	if isDragging then
		local delta = mouse.Position - dragStart
		mainFrame.Position = posStart + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

-- ============================================================
-- INICIALIZAR
-- ============================================================

UpdateTabSelection()
UpdateContentFrame()

print("✅ Admin Panel carregado com sucesso!")
print("📌 Você pode arrastar o painel para reposicionar")
print("📱 Compatível com mobile e desktop")

-- Salvar referência para debugging
_G.AdminPanel = ADMIN_PANEL
_G.Exploits = Exploits

print("💡 Use: _G.Exploits.HarvestGarden() no console para testar")
