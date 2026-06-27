-- GAME SPY ANALYZER v1.0
-- Sistema completo de inspeção do jogo
-- Analisa: RemoteEvents, RemoteFunctions, Scripts, Modules, Eventos, Estrutura

local GameSpy = {}
local Results = {}
local INDENT = "  "

-- ==================== CORES E FORMATAÇÃO ====================
local Colors = {
	RemoteEvent = "\27[33m",      -- Amarelo
	RemoteFunction = "\27[36m",   -- Ciano
	LocalScript = "\27[32m",      -- Verde
	Script = "\27[31m",           -- Vermelho
	ModuleScript = "\27[35m",     -- Magenta
	Other = "\27[37m",            -- Branco
	Reset = "\27[0m"
}

-- ==================== FUNÇÕES UTILITÁRIAS ====================
local function Log(message, color)
	color = color or Colors.Other
	print(color .. message .. Colors.Reset)
end

local function GetType(obj)
	if obj:IsA("RemoteEvent") then return "RemoteEvent", Colors.RemoteEvent
	elseif obj:IsA("RemoteFunction") then return "RemoteFunction", Colors.RemoteFunction
	elseif obj:IsA("LocalScript") then return "LocalScript", Colors.LocalScript
	elseif obj:IsA("Script") then return "Script", Colors.Script
	elseif obj:IsA("ModuleScript") then return "ModuleScript", Colors.ModuleScript
	else return obj.ClassName, Colors.Other
	end
end

-- ==================== ANÁLISE DE ESTRUTURA ====================
local function AnalyzeDescendants(parent, depth, maxDepth)
	maxDepth = maxDepth or 10
	
	if depth > maxDepth then return end
	
	local indent = string.rep(INDENT, depth)
	local objType, color = GetType(parent)
	
	-- Log principal
	local logMsg = indent .. "[" .. objType .. "] " .. parent.Name
	if parent:FindFirstChild("Source") then
		logMsg = logMsg .. " (📄 Source)"
	end
	table.insert(Results, logMsg)
	Log(logMsg, color)
	
	-- Analisa filhos
	for _, child in pairs(parent:GetChildren()) do
		AnalyzeDescendants(child, depth + 1, maxDepth)
	end
end

-- ==================== ANÁLISE DE REMOTE EVENTS ====================
local function AnalyzeRemoteEvents()
	Log("\n" .. string.rep("=", 50), Colors.RemoteEvent)
	Log("📡 REMOTE EVENTS", Colors.RemoteEvent)
	Log(string.rep("=", 50), Colors.RemoteEvent)
	
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local serverScriptService = game:GetService("ServerScriptService")
	local players = game:GetService("Players")
	local playerGui = players.LocalPlayer and players.LocalPlayer:WaitForChild("PlayerGui") or nil
	
	local locations = {replicatedStorage, serverScriptService}
	if playerGui then table.insert(locations, playerGui) end
	
	local count = 0
	for _, location in pairs(locations) do
		for _, obj in pairs(location:GetDescendants()) do
			if obj:IsA("RemoteEvent") then
				local msg = "  └─ " .. location.Name .. "/" .. obj:GetFullName():gsub(location.Name .. "/", "")
				table.insert(Results, msg)
				Log(msg, Colors.RemoteEvent)
				count = count + 1
			end
		end
	end
	
	Log("\n📊 Total RemoteEvents: " .. count, Colors.RemoteEvent)
	table.insert(Results, "Total RemoteEvents: " .. count)
end

-- ==================== ANÁLISE DE REMOTE FUNCTIONS ====================
local function AnalyzeRemoteFunctions()
	Log("\n" .. string.rep("=", 50), Colors.RemoteFunction)
	Log("🔌 REMOTE FUNCTIONS", Colors.RemoteFunction)
	Log(string.rep("=", 50), Colors.RemoteFunction)
	
	local replicatedStorage = game:GetService("ReplicatedStorage")
	local serverScriptService = game:GetService("ServerScriptService")
	local players = game:GetService("Players")
	local playerGui = players.LocalPlayer and players.LocalPlayer:WaitForChild("PlayerGui") or nil
	
	local locations = {replicatedStorage, serverScriptService}
	if playerGui then table.insert(locations, playerGui) end
	
	local count = 0
	for _, location in pairs(locations) do
		for _, obj in pairs(location:GetDescendants()) do
			if obj:IsA("RemoteFunction") then
				local msg = "  └─ " .. location.Name .. "/" .. obj:GetFullName():gsub(location.Name .. "/", "")
				table.insert(Results, msg)
				Log(msg, Colors.RemoteFunction)
				count = count + 1
			end
		end
	end
	
	Log("\n📊 Total RemoteFunctions: " .. count, Colors.RemoteFunction)
	table.insert(Results, "Total RemoteFunctions: " .. count)
end

-- ==================== ANÁLISE DE SCRIPTS ====================
local function AnalyzeScripts()
	Log("\n" .. string.rep("=", 50), Colors.Script)
	Log("📝 SCRIPTS E MODULES", Colors.Script)
	Log(string.rep("=", 50), Colors.Script)
	
	local serverScriptService = game:GetService("ServerScriptService")
	local starterPlayer = game:GetService("StarterPlayer")
	local replicatedStorage = game:GetService("ReplicatedStorage")
	
	local locations = {serverScriptService, starterPlayer, replicatedStorage}
	local scriptCount = 0
	local moduleCount = 0
	
	for _, location in pairs(locations) do
		for _, obj in pairs(location:GetDescendants()) do
			if obj:IsA("Script") then
				local msg = "  [Script] " .. obj:GetFullName():gsub("^[^/]*/", "")
				table.insert(Results, msg)
				Log(msg, Colors.Script)
				scriptCount = scriptCount + 1
			elseif obj:IsA("LocalScript") then
				local msg = "  [LocalScript] " .. obj:GetFullName():gsub("^[^/]*/", "")
				table.insert(Results, msg)
				Log(msg, Colors.LocalScript)
				scriptCount = scriptCount + 1
			elseif obj:IsA("ModuleScript") then
				local msg = "  [Module] " .. obj:GetFullName():gsub("^[^/]*/", "")
				table.insert(Results, msg)
				Log(msg, Colors.ModuleScript)
				moduleCount = moduleCount + 1
			end
		end
	end
	
	Log("\n📊 Total Scripts: " .. scriptCount .. " | Modules: " .. moduleCount, Colors.Script)
	table.insert(Results, "Total Scripts: " .. scriptCount .. " | Modules: " .. moduleCount)
end

-- ==================== ANÁLISE DE SERVIÇOS ====================
local function AnalyzeServices()
	Log("\n" .. string.rep("=", 50), Colors.Other)
	Log("⚙️ GAME SERVICES", Colors.Other)
	Log(string.rep("=", 50), Colors.Other)
	
	local services = {
		"Workspace",
		"ReplicatedStorage",
		"ServerScriptService",
		"Players",
		"DataStoreService",
		"RunService",
		"UserInputService",
		"TweenService"
	}
	
	for _, serviceName in pairs(services) do
		local success, service = pcall(function() return game:GetService(serviceName) end)
		if success then
			local msg = "  ✓ " .. serviceName
			table.insert(Results, msg)
			Log(msg, Colors.Other)
		end
	end
end

-- ==================== ANÁLISE DE CONEXÕES ====================
local function AnalyzeConnections()
	Log("\n" .. string.rep("=", 50), Colors.Other)
	Log("🔗 GAME CONNECTIONS", Colors.Other)
	Log(string.rep("=", 50), Colors.Other)
	
	local workspace = game:GetService("Workspace")
	local models = {}
	
	for _, obj in pairs(workspace:GetDescendants()) do
		if obj:IsA("Model") or obj:IsA("Part") then
			table.insert(models, obj.Name)
		end
	end
	
	Log("  📦 Models/Parts no Workspace: " .. #models, Colors.Other)
	table.insert(Results, "Models/Parts no Workspace: " .. #models)
	
	-- Mostra primeiros 10
	for i, name in pairs(models) do
		if i <= 10 then
			Log("     - " .. name, Colors.Other)
		end
	end
	if #models > 10 then
		Log("     ... e mais " .. (#models - 10), Colors.Other)
	end
end

-- ==================== ANÁLISE COMPLETA DA ESTRUTURA ====================
local function AnalyzeFullStructure()
	Log("\n" .. string.rep("=", 50), Colors.Other)
	Log("🗂️ ESTRUTURA COMPLETA DO JOGO", Colors.Other)
	Log(string.rep("=", 50), Colors.Other)
	
	Log("\n[WORKSPACE]", Colors.Other)
	AnalyzeDescendants(game:GetService("Workspace"), 0, 3)
	
	Log("\n[REPLICATED STORAGE]", Colors.Other)
	AnalyzeDescendants(game:GetService("ReplicatedStorage"), 0, 3)
	
	Log("\n[SERVER SCRIPT SERVICE]", Colors.Other)
	AnalyzeDescendants(game:GetService("ServerScriptService"), 0, 3)
end

-- ==================== COPIAR PARA CLIPBOARD ====================
local function CopyToClipboard(text)
	-- Tenta usar o método nativo do Roblox (se disponível)
	local success = pcall(function()
		if setclipboard then
			setclipboard(text)
			return true
		end
	end)
	
	if success then
		return true
	end
	
	-- Fallback: tenta usar o serviço UserInputService
	local success2 = pcall(function()
		local UserInputService = game:GetService("UserInputService")
		if UserInputService and UserInputService.SetClipboard then
			UserInputService:SetClipboard(text)
			return true
		end
	end)
	
	return success or success2
end

-- ==================== EXPORTAR RELATÓRIO ====================
local function ExportReport()
	Log("\n" .. string.rep("=", 50), Colors.Other)
	Log("📋 COPIANDO PARA ÁREA DE TRANSFERÊNCIA", Colors.Other)
	Log(string.rep("=", 50), Colors.Other)
	
	local reportContent = table.concat(Results, "\n")
	
	-- Tenta copiar pra clipboard
	local clipboardSuccess = CopyToClipboard(reportContent)
	
	if clipboardSuccess then
		Log("✅ RELATÓRIO COPIADO COM SUCESSO!", Colors.RemoteEvent)
		Log("   Cole (Ctrl+V) em qualquer lugar!", Colors.RemoteEvent)
		print("\n" .. reportContent .. "\n")
	else
		Log("⚠️ Não conseguiu copiar automaticamente", Colors.Other)
		Log("   Copie o texto do console manualmente (Ctrl+C)", Colors.Other)
		print("\n" .. reportContent .. "\n")
	end
	
	return reportContent
end

-- ==================== EXECUTAR ANÁLISE COMPLETA ====================
function GameSpy:StartAnalysis()
	Log("\n" .. string.rep("╔", 50), Colors.RemoteEvent)
	Log("║" .. string.rep(" ", 48) .. "║", Colors.RemoteEvent)
	Log("║" .. string.rep(" ", 15) .. "🕵️ GAME SPY ANALYZER v1.0" .. string.rep(" ", 8) .. "║", Colors.RemoteEvent)
	Log("║" .. string.rep(" ", 48) .. "║", Colors.RemoteEvent)
	Log(string.rep("╚", 50), Colors.RemoteEvent)
	
	Log("\n⏳ Analisando jogo...\n")
	
	table.insert(Results, "════════════════════════════════════════════════════")
	table.insert(Results, "GAME SPY ANALYZER - Relatório Completo")
	table.insert(Results, "Data: " .. os.date("%d/%m/%Y %H:%M:%S"))
	table.insert(Results, "════════════════════════════════════════════════════")
	
	-- Executa análises
	AnalyzeRemoteEvents()
	AnalyzeRemoteFunctions()
	AnalyzeScripts()
	AnalyzeServices()
	AnalyzeConnections()
	AnalyzeFullStructure()
	
	Log("\n" .. string.rep("✓", 50), Colors.RemoteEvent)
	Log("✅ ANÁLISE COMPLETA!", Colors.RemoteEvent)
	Log(string.rep("✓", 50), Colors.RemoteEvent)
	
	ExportReport()
end

-- ==================== INICIAR ====================
GameSpy:StartAnalysis()

return GameSpy
