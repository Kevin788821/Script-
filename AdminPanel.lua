-- Admin Panel LocalScript - MOBILE OPTIMIZED
-- Coloque isso em StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Detectar se é mobile
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Configuração
local ADMIN_KEY = Enum.KeyCode.F2 -- Pressione F2 para abrir/fechar (PC)
local TELEPORT_REMOTE = game.ReplicatedStorage.Remotes.TeleportStage -- Ajuste conforme necessário
local TELEPORT_RF = game.ReplicatedStorage.Remotes.TeleportStageRF -- RemoteFunction alternativa

-- Função para teleportar
local function teleportToStage(stageNumber)
	local teleported = false
	local errorMsg = ""

	-- Tentar RemoteFunction TeleportStageRF primeiro
	if TELEPORT_RF then
		local success, result = pcall(function()
			return TELEPORT_RF:InvokeServer(stageNumber)
		end)
		if success then
			print("✓ Teleportado para Stage " .. stageNumber .. " (TeleportStageRF)")
			teleported = true
			return true
		else
			errorMsg = errorMsg .. "\n❌ TeleportStageRF falhou: " .. tostring(result)
		end
	end

	-- Tentar RemoteEvent TeleportStage
	if not teleported and TELEPORT_REMOTE then
		local success, result = pcall(function()
			TELEPORT_REMOTE:FireServer(stageNumber)
			return true
		end)
		if success then
			print("✓ Teleportado para Stage " .. stageNumber .. " (TeleportStage FireServer)")
			teleported = true
			return true
		else
			errorMsg = errorMsg .. "\n❌ TeleportStage FireServer falhou: " .. tostring(result)
		end
	end

	if not teleported then
		print("⚠️ Erro ao teleportar para Stage " .. stageNumber .. errorMsg)
		return false
	end

	return teleported
end

-- Criar ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdminPanelGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Botão flutuante para mobile (FAB - Floating Action Button)
local fabButton = Instance.new("TextButton")
fabButton.Name = "FABButton"
fabButton.Size = UDim2.new(0, 60, 0, 60)
fabButton.Position = UDim2.new(1, -80, 1, -80)
fabButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
fabButton.BorderSizePixel = 0
fabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
fabButton.TextSize = 28
fabButton.Font = Enum.Font.GothamBold
fabButton.Text = "⚙️"
fabButton.Visible = isMobile
fabButton.Parent = screenGui
fabButton.ZIndex = 100

local fabCorner = Instance.new("UICorner")
fabCorner.CornerRadius = UDim.new(1)
fabCorner.Parent = fabButton

local fabShadow = Instance.new("UIStroke")
fabShadow.Thickness = 2
fabShadow.Color = Color3.fromRGB(0, 100, 200)
fabShadow.Parent = fabButton

-- Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = isMobile and UDim2.new(1, 0, 1, 0) or UDim2.new(0, 450, 0, 650)
mainFrame.Position = isMobile and UDim2.new(0, 0, 0, 0) or UDim2.new(0.5, -225, 0.5, -325)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui
mainFrame.ZIndex = 99

-- Adicionar sombra
local shadow = Instance.new("UICorner")
shadow.CornerRadius = UDim.new(0, 12)
shadow.Parent = mainFrame

local shadowGradient = Instance.new("UIGradient")
shadowGradient.Color = ColorSequence.new(Color3.fromRGB(10, 10, 20), Color3.fromRGB(30, 30, 40))
shadowGradient.Rotation = 45
shadowGradient.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 60)
header.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerGradient = Instance.new("UIGradient")
headerGradient.Color = ColorSequence.new(Color3.fromRGB(0, 100, 200), Color3.fromRGB(0, 150, 255))
headerGradient.Parent = header

-- Título
local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 28
title.Font = Enum.Font.GothamBold
title.Text = "⚙️ ADMIN PANEL"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 50, 0, 50)
closeBtn.Position = UDim2.new(1, -60, 0, 5)
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.BorderSizePixel = 0
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "✕"
closeBtn.Parent = header
closeBtn.ZIndex = 100

local closeBtnCorner = Instance.new("UICorner")
closeBtnCorner.CornerRadius = UDim.new(0, 8)
closeBtnCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
	if isMobile then
		fabButton.Visible = true
	end
end)

-- ScrollingFrame para os botões
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Name = "ScrollFrame"
scrollFrame.Size = UDim2.new(1, 0, 1, -70)
scrollFrame.Position = UDim2.new(0, 0, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = isMobile and 6 or 8
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.Parent = mainFrame

-- UIListLayout para organizar botões
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
listLayout.Parent = scrollFrame

-- Padding
local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = scrollFrame

-- Função para criar botão de teleporte
local function createStageButton(stageName, stageNumber)
	local btn = Instance.new("TextButton")
	btn.Name = "Stage_" .. stageNumber
	btn.Size = UDim2.new(1, -20, 0, isMobile and 45 or 50)
	btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = isMobile and 14 or 16
	btn.Font = Enum.Font.GothamBold
	btn.Text = "📍 " .. stageName
	btn.Parent = scrollFrame

	-- Estilo do botão
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(Color3.fromRGB(40, 40, 60), Color3.fromRGB(60, 60, 80))
	gradient.Parent = btn

	-- Efeito hover/touch
	local function activateButton()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = game:GetService("TweenService"):Create(btn, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(0, 150, 255)
		})
		tween:Play()
	end

	local function deactivateButton()
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local tween = game:GetService("TweenService"):Create(btn, tweenInfo, {
			BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		})
		tween:Play()
	end

	btn.MouseEnter:Connect(function()
		if not isMobile then
			activateButton()
		end
	end)

	btn.MouseLeave:Connect(function()
		if not isMobile then
			deactivateButton()
		end
	end)

	-- Click para teleportar
	btn.MouseButton1Down:Connect(function()
		activateButton()
	end)

	btn.MouseButton1Up:Connect(function()
		deactivateButton()
	end)

	btn.MouseButton1Click:Connect(function()
		teleportToStage(stageNumber)

		-- Fechar automaticamente após teleportar
		wait(0.3)
		mainFrame.Visible = false
		if isMobile then
			fabButton.Visible = true
		end
	end)

	return btn
end

-- Criar botões para as 22 fases
local stages = {
	{name = "Stage 1", number = 1},
	{name = "Stage 2", number = 2},
	{name = "Stage 3", number = 3},
	{name = "Stage 4", number = 4},
	{name = "Stage 5", number = 5},
	{name = "Stage 6", number = 6},
	{name = "Stage 7", number = 7},
	{name = "Stage 8", number = 8},
	{name = "Stage 9", number = 9},
	{name = "Stage 10", number = 10},
	{name = "Stage 11", number = 11},
	{name = "Stage 12", number = 12},
	{name = "Stage 13", number = 13},
	{name = "Stage 14", number = 14},
	{name = "Stage 15", number = 15},
	{name = "Stage 16", number = 16},
	{name = "Stage 17", number = 17},
	{name = "Stage 18", number = 18},
	{name = "Stage 19", number = 19},
	{name = "Stage 20", number = 20},
	{name = "Stage 21", number = 21},
	{name = "Stage 22", number = 22},
}

for _, stage in ipairs(stages) do
	createStageButton(stage.name, stage.number)
end

-- Atualizar canvas size
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
end)

-- Controle de abertura/fechamento
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == ADMIN_KEY and not isMobile then
		mainFrame.Visible = not mainFrame.Visible
	end
end)

-- FAB Button Click para mobile
fabButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = true
	fabButton.Visible = false
end)

-- Drag do FAB button para mobile
local dragging = false
local dragStart = nil
local startPosition = nil

fabButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPosition = fabButton.Position
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch and dragging and dragStart and startPosition then
		local currentPos = input.Position
		local deltaX = currentPos.X - dragStart.X
		local deltaY = currentPos.Y - dragStart.Y

		-- Calcular nova posição (adicionar delta ao invés de subtrair)
		local newX = startPosition.X.Offset + deltaX
		local newY = startPosition.Y.Offset + deltaY

		-- Limitar aos limites da tela
		local screenSize = fabButton.Parent.AbsoluteSize
		newX = math.max(0, math.min(newX, screenSize.X - 60))
		newY = math.max(0, math.min(newY, screenSize.Y - 60))

		fabButton.Position = UDim2.new(0, newX, 0, newY)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
		dragStart = nil
		startPosition = nil
	end
end)

print("✓ Admin Panel Mobile carregado!")
if isMobile then
	print("📱 Toque no botão azul ⚙️ para abrir")
else
	print("💻 Pressione F2 para abrir/fechar")
end
