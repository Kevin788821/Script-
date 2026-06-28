--[[ 
	GROW A GARDEN - ADMIN PANEL SUPREMO v3.0
	Desenvolvido por: Kevin
	Compatível com: Mobile + Desktop
	Exploits: Avançados com Fallback automático
	Data: 28/06/2026
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- ============================================================
-- CONFIGURAÇÃO INICIAL
-- ============================================================

local ADMIN_PANEL = {
	isActive = true,
	currentTab = "home",
	isRunning = false,
	activeExploit = nil,
}

local FRUIT_VALUES = {
	["Apple"] = 15,
	["Banana"] = 20,
	["Strawberry"] = 18,
	["Blueberry"] = 16,
	["Tomato"] = 12,
	["Coconut"] = 25,
	["Mango"] = 22,
	["Cherry"] = 19,
	["Grape"] = 17,
	["Pineapple"] = 28,
	["Dragon Fruit"] = 35,
	["Moon Bloom"] = 50,
}

-- ============================================================
-- FUNÇÕES AUXILIARES
-- ============================================================

local function findOwnPlot()
	local plots = {}
	local gardens = Workspace:FindFirstChild("Gardens")
	if not gardens then return nil end
	
	for _, plot in pairs(gardens:GetChildren()) do
		if plot:FindFirstChild("Plants") then
			table.insert(plots, plot)
		end
	end
	return plots[1] or nil
end

local function findAllPlots()
	local plots = {}
	local gardens = Workspace:FindFirstChild("Gardens")
	if not gardens then return plots end
	
	for _, plot in pairs(gardens:GetChildren()) do
		if plot:FindFirstChild("Plants") then
			table.insert(plots, plot)
		end
	end
	return plots
end

local function getPlayerInGarden(plot)
	for _, otherPlayer in pairs(Players:GetPlayers()) do
		if otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (otherPlayer.Character.HumanoidRootPart.Position - plot.PrimaryPart.Position).Magnitude
			if dist < 100 then
				return otherPlayer
			end
		end
	end
	return nil
end

local function getFruitsInPlot(plot)
	local fruits = {}
	local plantsFolder = plot:FindFirstChild("Plants")
	if not plantsFolder then return fruits end
	
	for _, plant in pairs(plantsFolder:GetChildren()) do
		if plant:IsA("Model") and plant:FindFirstChild("Handle") then
			table.insert(fruits, {
				model = plant,
				position = plant.PrimaryPart.Position,
				name = plant.Name
			})
		end
	end
	return fruits
end

local function getFruitValue(fruitName)
	return FRUIT_VALUES[fruitName] or 10
end

local function sortFruitsByValue(fruits)
	table.sort(fruits, function(a, b)
		return getFruitValue(a.name) > getFruitValue(b.name)
	end)
	return fruits
end

local function teleportPlayer(position)
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
	end
end

local function clickOnObject(object)
	if object:FindFirstChild("Handle") then
		mouse.Target = object.Handle
		mouse.Hit = object.Handle.CFrame
		game:GetService("VirtualInputManager"):SendMouseButtonEvent(mouse.X, mouse.Y, 0, true)
		wait(0.05)
		game:GetService("VirtualInputManager"):SendMouseButtonEvent(mouse.X, mouse.Y, 0, false)
	end
end

-- ============================================================
-- EXPLOITS - FUNÇÕES PRINCIPAIS
-- ============================================================

local Exploits = {}

function Exploits.HarvestGarden()
	print("[🌾 COLHEITA] Iniciando...")
	
	local myPlot = findOwnPlot()
	if not myPlot then
		print("[🌾 COLHEITA] ❌ Jardim não encontrado!")
		return
	end
	
	print("[🌾 COLHEITA] ✓ Jardim encontrado, coletando...")
	
	local fruits = getFruitsInPlot(myPlot)
	print("[🌾 COLHEITA] Encontradas " .. #fruits .. " frutas")
	
	for i, fruit in pairs(fruits) do
		if not ADMIN_PANEL.isRunning then break end
		
		print("[🌾 COLHEITA] Coletando " .. i .. ": " .. fruit.name)
		teleportPlayer(fruit.position)
		wait(0.3)
		clickOnObject(fruit.model)
		wait(0.5)
	end
	
	local spawnPoint = myPlot:FindFirstChild("SpawnPoint")
	if spawnPoint then
		teleportPlayer(spawnPoint.Position)
	end
	
	print("[🌾 COLHEITA] ✅ Concluída!")
	ADMIN_PANEL.isRunning = false
end

function Exploits.SellAllFruits()
	print("[💰 VENDA] Iniciando (SEM SAIR DO LUGAR)...")
	
	ADMIN_PANEL.isRunning = true
	
	while ADMIN_PANEL.isRunning and ADMIN_PANEL.activeExploit == "sell" do
		local npcFolder = Workspace:FindFirstChild("NPCS")
		if npcFolder then
			local seller = npcFolder:FindFirstChild("Steven") or npcFolder:FindFirstChild("Sell_Steven")
			
			if seller and seller:FindFirstChild("HumanoidRootPart") then
				print("[💰 VENDA] Enviando comando de venda...")
				
				-- Procura por RemoteEvent de venda
				local vendorRemote = ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
				if vendorRemote then
					vendorRemote:FireServer("SellFruit")
					print("[💰 VENDA] ✓ Frutas vendidas!")
				end
			end
		end
		
		wait(3)
	end
	
	print("[💰 VENDA] ✅ Auto-venda parada!")
	ADMIN_PANEL.isRunning = false
end

function Exploits.BuySeedsAuto(seedName)
	print("[🌱 COMPRA] Iniciando " .. seedName .. " (SEM SAIR DO LUGAR)...")
	
	ADMIN_PANEL.isRunning = true
	
	while ADMIN_PANEL.isRunning and ADMIN_PANEL.activeExploit == "buy" do
		local mapFolder = Workspace:FindFirstChild("Map")
		if mapFolder then
			local standsFolder = mapFolder:FindFirstChild("Stands")
			if standsFolder then
				local seedsShop = standsFolder:FindFirstChild("Seeds")
				
				if seedsShop then
					print("[🌱 COMPRA] Comprando " .. seedName .. "...")
					
					-- Procura por RemoteEvent de compra
					local buyRemote = ReplicatedStorage:FindFirstChildOfClass("RemoteEvent")
					if buyRemote then
						buyRemote:FireServer("BuySeed", seedName)
						print("[🌱 COMPRA] ✓ Semente comprada!")
					end
				end
			end
		end
		
		wait(2)
	end
	
	print("[🌱 COMPRA] ✅ Compra parada!")
	ADMIN_PANEL.isRunning = false
end

function Exploits.StealFruitAuto()
	print("[🔓 ROUBO] Iniciando (apenas à noite)...")
	
	ADMIN_PANEL.isRunning = true
	local nightValue = ReplicatedStorage:FindFirstChild("Night")
	
	while ADMIN_PANEL.isRunning and ADMIN_PANEL.activeExploit == "steal" do
		local isNight = (nightValue and nightValue.Value == true)
		
		if not isNight then
			print("[🔓 ROUBO] ⏳ Aguardando noite...")
			wait(5)
			goto continue
		end
		
		print("[🔓 ROUBO] 🌙 É noite! Procurando frutas...")
		
		local myPlot = findOwnPlot()
		if not myPlot then
			print("[🔓 ROUBO] ❌ Seu jardim não encontrado")
			goto continue
		end
		
		local allPlots = findAllPlots()
		
		for _, targetPlot in pairs(allPlots) do
			if targetPlot ~= myPlot then
				
				local playerInGarden = getPlayerInGarden(targetPlot)
				if playerInGarden then
					print("[🔓 ROUBO] ⚠️ Jogador neste jardim, pulando...")
					goto nextPlot
				end
				
				local fruits = getFruitsInPlot(targetPlot)
				
				if #fruits > 0 then
					fruits = sortFruitsByValue(fruits)
					
					-- Tentar até 10 frutas (FALLBACK AUTOMÁTICO)
					for priority = 1, math.min(#fruits, 10) do
						if not ADMIN_PANEL.isRunning then break end
						
						local fruit = fruits[priority]
						print("[🔓 ROUBO] Tentando #" .. priority .. ": " .. fruit.name .. " (valor: " .. getFruitValue(fruit.name) .. ")")
						
						if getPlayerInGarden(targetPlot) then
							print("[🔓 ROUBO] ⚠️ Jogador entrou! Próxima fruta...")
							goto nextFruit
						end
						
						teleportPlayer(fruit.position)
						wait(0.5)
						clickOnObject(fruit.model)
						wait(0.5)
						
						local mySpawn = myPlot:FindFirstChild("SpawnPoint")
						if mySpawn then
							teleportPlayer(mySpawn.Position)
						end
						
						print("[🔓 ROUBO] ✓ Roubada: " .. fruit.name)
						wait(1)
						break
						
						::nextFruit::
					end
				end
				
				::nextPlot::
				wait(2)
			end
		end
		
		wait(5)
		::continue::
	end
	
	print("[🔓 ROUBO] ✅ Roubo parado!")
	ADMIN_PANEL.isRunning = false
end

function Exploits.MonitorShopStock()
	print("[📊 SHOP] Monitorando em tempo real...")
	
	ADMIN_PANEL.isRunning = true
	
	while ADMIN_PANEL.isRunning and ADMIN_PANEL.activeExploit == "shop" do
		local stockValues = ReplicatedStorage:FindFirstChild("StockValues")
		
		if stockValues then
			local seedShop = stockValues:FindFirstChild("SeedShop")
			if seedShop then
				local nextRestock = seedShop:FindFirstChild("UnixNextRestock")
				local lastRestock = seedShop:FindFirstChild("UnixLastRestock")
				
				if nextRestock and lastRestock then
					local currentTime = os.time()
					local nextTime = nextRestock.Value
					local lastTime = lastRestock.Value
					local timeUntil = nextTime - currentTime
					
					print("\n" .. string.rep("=", 40))
					print("📊 SEED SHOP STATUS")
					print(string.rep("=", 40))
					print("Último restock: " .. os.date("%H:%M:%S", lastTime))
					print("Próximo restock: " .. os.date("%H:%M:%S", nextTime))
					
					if timeUntil > 0 then
						local mins = math.floor(timeUntil / 60)
						local secs = timeUntil % 60
						print("⏱️  Em: " .. mins .. "m " .. secs .. "s")
					else
						print("🔄 RESTOCKANDO AGORA!")
					end
					
					local items = seedShop:FindFirstChild("Items")
					if items then
						print("\n🌱 Itens: (" .. #items:GetChildren() .. ")")
						for _, item in pairs(items:GetChildren()) do
							print("   • " .. item.Name)
						end
					end
				end
			end
			
			local crateShop = stockValues:FindFirstChild("CrateShop")
			if crateShop then
				local nextRestock = crateShop:FindFirstChild("UnixNextRestock")
				
				if nextRestock then
					local currentTime = os.time()
					local nextTime = nextRestock.Value
					local timeUntil = nextTime - currentTime
					
					print("\n" .. string.rep("=", 40))
					print("🎁 CRATE SHOP STATUS")
					print(string.rep("=", 40))
					print("Próximo restock: " .. os.date("%H:%M:%S", nextTime))
					
					if timeUntil > 0 then
						local mins = math.floor(timeUntil / 60)
						local secs = timeUntil % 60
						print("⏱️  Em: " .. mins .. "m " .. secs .. "s")
					else
						print("🔄 RESTOCKANDO AGORA!")
					end
					
					local items = crateShop:FindFirstChild("Items")
					if items then
						print("\n🎁 Crates: (" .. #items:GetChildren() .. ")")
						for _, item in pairs(items:GetChildren()) do
							print("   • " .. item.Name)
						end
					end
				end
			end
			
			print(string.rep("=", 40) .. "\n")
		end
		
		wait(5)
	end
	
	print("[📊 SHOP] ✅ Monitoramento parado!")
	ADMIN_PANEL.isRunning = false
end

-- ============================================================
-- CRIAR GUI PRINCIPAL
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanelSupremo"
screenGui.ResetOnSpawn = false
screenGui.SafeAreaCompatible = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.02, 0, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local cornerRadius = Instance.new("UICorner")
cornerRadius.CornerRadius = UDim.new(0, 15)
cornerRadius.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2.5
stroke.Parent = mainFrame

-- ============================================================
-- HEADER
-- ============================================================

local headerFrame = Instance.new("Frame")
headerFrame.Name = "Header"
headerFrame.Size = UDim2.new(1, 0, 0, 55)
headerFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 15)
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
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "⚙️ ADMIN PANEL v3"
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = headerFrame

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
tabsFrame.Position = UDim2.new(0, 0, 0, 55)
tabsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
tabsFrame.BorderSizePixel = 0
tabsFrame.Parent = mainFrame

local tabsLayout = Instance.new("UIListLayout")
tabsLayout.FillDirection = Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
tabsLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabsLayout.Padding = UDim.new(0, 2)
tabsLayout.Parent = tabsFrame

local tabs = {
	{name = "🏠", id = "home"},
	{name = "🌾", id = "harvest"},
	{name = "💰", id = "sell"},
	{name = "🌱", id = "buy"},
	{name = "🔓", id = "steal"},
	{name = "📊", id = "shop"},
}

local tabButtons = {}

for i, tab in ipairs(tabs) do
	local tabButton = Instance.new("TextButton")
	tabButton.Name = tab.id
	tabButton.Size = UDim2.new(0, 58, 1, 0)
	tabButton.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
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
contentFrame.Size = UDim2.new(1, 0, 1, -95)
contentFrame.Position = UDim2.new(0, 0, 0, 95)
contentFrame.BackgroundTransparency = 1
contentFrame.BorderSizePixel = 0
contentFrame.Parent = mainFrame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, -8, 1, -8)
scrollFrame.Position = UDim2.new(0, 4, 0, 4)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 220)
scrollFrame.Parent = contentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Fill
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Padding = UDim.new(0, 8)
listLayout.Parent = scrollFrame

-- ============================================================
-- FUNÇÕES DE INTERFACE
-- ============================================================

local function CreateButton(parent, text, callback, color)
	color = color or Color3.fromRGB(60, 150, 255)
	
	local button = Instance.new("TextButton")
	button.Name = text
	button.Size = UDim2.new(1, 0, 0, 40)
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
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 150, 255)
	stroke.Thickness = 1
	stroke.Parent = button
	
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = color:lerp(Color3.fromRGB(255, 255, 255), 0.1)
	end)
	
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = color
	end)
	
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
			tab.button.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
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

function UpdateContentFrame()
	ClearContent()
	
	if ADMIN_PANEL.currentTab == "home" then
		CreateLabel(scrollFrame, "👋 Bem-vindo ao Admin Panel!", 1.2)
		scrollFrame:FindFirstChild("UIListLayout").Padding = UDim.new(0, 15)
		
		CreateLabel(scrollFrame, "Versão: 3.0 SUPREMA", 0.7)
		CreateLabel(scrollFrame, "Com exploits avançados", 0.7)
		CreateLabel(scrollFrame, "Compatível com mobile e desktop", 0.7)
		CreateLabel(scrollFrame, "", 0.5)
		CreateLabel(scrollFrame, "✨ FUNCIONALIDADES:", 0.9)
		CreateLabel(scrollFrame, "🌾 Colher frutas automaticamente", 0.7)
		CreateLabel(scrollFrame, "💰 Vender sem sair do lugar", 0.7)
		CreateLabel(scrollFrame, "🌱 Comprar sem se mover", 0.7)
		CreateLabel(scrollFrame, "🔓 Roubar com fallback (até 10)", 0.7)
		CreateLabel(scrollFrame, "📊 Monitor shop em tempo real", 0.7)
		
		CreateButton(scrollFrame, "🔄 Recarregar", function()
			print("✓ Panel recarregado!")
		end, Color3.fromRGB(100, 180, 100))
		
	elseif ADMIN_PANEL.currentTab == "harvest" then
		CreateLabel(scrollFrame, "🌾 COLHEITA AUTOMÁTICA", 1.1)
		CreateLabel(scrollFrame, "Colhe todas as frutas do seu jardim", 0.8)
		CreateLabel(scrollFrame, "", 0.5)
		
		CreateButton(scrollFrame, "🚀 Iniciar Colheita", function()
			ADMIN_PANEL.isRunning = true
			ADMIN_PANEL.activeExploit = "harvest"
			Exploits.HarvestGarden()
		end, Color3.fromRGB(80, 200, 80))
		
	elseif ADMIN_PANEL.currentTab == "sell" then
		CreateLabel(scrollFrame, "💰 VENDA AUTOMÁTICA", 1.1)
		CreateLabel(scrollFrame, "Vende frutas SEM SAIR DO LUGAR", 0.8)
		CreateLabel(scrollFrame, "", 0.5)
		
		CreateButton(scrollFrame, "💸 Vender Tudo", function()
			ADMIN_PANEL.isRunning = true
			ADMIN_PANEL.activeExploit = "sell"
			Exploits.SellAllFruits()
		end, Color3.fromRGB(200, 150, 60))
		
		CreateLabel(scrollFrame, "❌ Clique novamente para parar", 0.65)
		
	elseif ADMIN_PANEL.currentTab == "buy" then
		CreateLabel(scrollFrame, "🌱 COMPRA AUTOMÁTICA", 1.1)
		CreateLabel(scrollFrame, "Compra SEM SAIR DO LUGAR", 0.8)
		CreateLabel(scrollFrame, "", 0.5)
		
		local seeds = {"Apple", "Strawberry", "Tomato", "Corn", "Pumpkin"}
		for _, seed in ipairs(seeds) do
			CreateButton(scrollFrame, "🛒 " .. seed, function()
				ADMIN_PANEL.isRunning = true
				ADMIN_PANEL.activeExploit = "buy"
				Exploits.BuySeedsAuto(seed)
			end, Color3.fromRGB(100, 180, 100))
		end
		
	elseif ADMIN_PANEL.currentTab == "steal" then
		CreateLabel(scrollFrame, "🔓 ROUBO AUTOMÁTICO", 1.1)
		CreateLabel(scrollFrame, "Rouba melhores frutas (só noite)", 0.8)
		CreateLabel(scrollFrame, "Fallback automático até 10 frutas", 0.7)
		CreateLabel(scrollFrame, "", 0.5)
		
		CreateButton(scrollFrame, "⚡ Iniciar Roubo", function()
			ADMIN_PANEL.isRunning = true
			ADMIN_PANEL.activeExploit = "steal"
			Exploits.StealFruitAuto()
		end, Color3.fromRGB(255, 100, 100))
		
		CreateLabel(scrollFrame, "⚠️ Funciona apenas à noite!", 0.65)
		CreateLabel(scrollFrame, "✓ Detecta jogadores automaticamente", 0.65)
		
	elseif ADMIN_PANEL.currentTab == "shop" then
		CreateLabel(scrollFrame, "📊 MONITOR DE SHOP", 1.1)
		CreateLabel(scrollFrame, "Stock em tempo real", 0.8)
		CreateLabel(scrollFrame, "", 0.5)
		
		CreateButton(scrollFrame, "🔄 Iniciar Monitor", function()
			ADMIN_PANEL.isRunning = true
			ADMIN_PANEL.activeExploit = "shop"
			Exploits.MonitorShopStock()
		end, Color3.fromRGB(100, 150, 200))
		
		CreateLabel(scrollFrame, "Monitora Seed Shop + Crate Shop", 0.65)
		CreateLabel(scrollFrame, "Atualiza a cada 5 segundos", 0.65)
	end
	
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end

-- ============================================================
-- EVENTOS DO PANEL
-- ============================================================

closeButton.MouseButton1Click:Connect(function()
	ADMIN_PANEL.isRunning = false
	mainFrame:Destroy()
	screenGui:Destroy()
	ADMIN_PANEL.isActive = false
	print("✓ Admin Panel fechado!")
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

-- Parar exploit ao sair
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.Escape then
		ADMIN_PANEL.isRunning = false
	end
end)

-- ============================================================
-- INICIALIZAR
-- ============================================================

UpdateTabSelection()
UpdateContentFrame()

print("\n" .. string.rep("=", 50))
print("✅ ADMIN PANEL v3.0 SUPREMO CARREGADO!")
print("📌 Sistema de abas: 🏠 🌾 💰 🌱 🔓 📊")
print("⚡ Exploits avançados com fallback automático")
print("📱 Compatível com mobile e desktop")
print("🖱️  Arrastar pelo header para reposicionar")
print("⌨️  Pressione ESC para parar qualquer exploit")
print(string.rep("=", 50) .. "\n")

_G.AdminPanel = ADMIN_PANEL
_G.Exploits = Exploits
