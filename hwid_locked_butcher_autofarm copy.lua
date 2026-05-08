-- ============================================================================
-- EXECUTOR KEY SYSTEM WITH HWID LOCKING - SINGLE LOCALSCRIPT
-- Works in: Potassium, Synapse X, KRNL, Fluxus, Script-Ware, and UNC executors
-- ============================================================================
-- INSTRUCTIONS: Search for "CHANGE_ME" in this file. Every line you MUST edit
-- before running is marked with "CHANGE_ME".
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================================
-- CHANGE_ME 1: DISCORD WEBHOOK URL
-- ============================================================================
-- Get this from Discord: Channel Settings -> Integrations -> Webhooks -> Copy URL
-- WARNING: Never share this URL publicly. Anyone with it can spam your channel.
local WEBHOOK_URL = "https://discord.com/api/webhooks/1498722935886839869/ZSh8Kyw5uyB18kFjn5WMcT_V2SM410fCC4bIpOJEKurWQyzxmjw3ZLJrM-g8yITaj7GO"

-- ============================================================================
-- CHANGE_ME 2: WEBHOOK BOT SETTINGS
-- ============================================================================
local WEBHOOK_NAME = "Key System Logger"
local COLOR_SUCCESS = 0x00FF00  -- Green
local COLOR_FAIL = 0xFF0000     -- Red

-- ============================================================================
-- CHANGE_ME 3: VALID HWID HASHES (HWID-ONLY AUTHENTICATION)
-- ============================================================================
-- Add HWID hashes directly here. No keys needed - just HWID-based access.
--
-- HOW TO GET HWID HASHES:
--   1. Run this script once on the target PC
--   2. Copy the HWID hash shown in the GUI or console output
--   3. Paste it below as shown
--
-- FORMAT: ["HWID_HASH"] = true
local VALID_HWID_HASHES = {
	["1FF55A0D"] = true,  -- me
    ["6EB0575C"] = true; -- joss
    
    -- Add more HWID hashes here:
    -- ["ANOTHER_HWID_HASH"] = true,
}

-- ============================================================================
-- CHANGE_ME 4: MAIN SCRIPT FUNCTION
-- ============================================================================
-- This function runs AFTER the player enters a valid key.
-- Paste your actual script code here, or call loadstring() to fetch a remote script.
local function runMainScript()
	print("[KeySystem] Access granted. Executing main script...")

	-- CHANGE_ME: ================================================
	-- PASTE YOUR MAIN SCRIPT CODE BELOW THIS LINE

	-- Example 1: Load a remote script
	-- loadstring(game:HttpGet("https://pastebin.com/raw/CHANGE_ME"))()

	-- Example 2: Run code directly
	-- print("Hello World - your script runs here!")

	-- CHANGE_ME: ================================================
	-- PASTE YOUR MAIN SCRIPT CODE ABOVE THIS LINE
end

-- ============================================================================
-- CORE FUNCTIONS (DO NOT EDIT BELOW THIS LINE UNLESS YOU KNOW WHAT YOU'RE DOING)
-- ============================================================================

-- Detect executor HTTP library (UNC standard: request, game:HttpGet)
local httpRequest = syn and syn.request
	or (http and http.request)
	or request
	or (fluxus and fluxus.request)
	or (getgenv and getgenv().request)
	or (potassium and potassium.request)

if not httpRequest then
	warn("[KeySystem] No executor HTTP library detected. Webhooks + IP logging disabled.")
end

-- Helper for simple GET (some executors prefer game:HttpGet over request)
local function httpGet(url)
	if httpRequest then
		local res = httpRequest({ Url = url, Method = "GET", Headers = {} })
		if type(res) == "table" and res.Body then
			return res.Body
		elseif type(res) == "string" then
			return res
		end
	end
	-- Fallback to game:HttpGet (UNC standard, works in Potassium)
	if game and game.HttpGet then
		return game:HttpGet(url)
	end
	return nil
end

-- Get executor name for logging (UNC standard: identifyexecutor / getexecutorname)
local executorName
pcall(function()
	if identifyexecutor then
		executorName = identifyexecutor()
	elseif getexecutorname then
		executorName = getexecutorname()
	elseif syn then
		executorName = "Synapse X"
	elseif KRNL_LOADED then
		executorName = "KRNL"
	elseif fluxus then
		executorName = "Fluxus"
	elseif potassium then
		executorName = "Potassium"
	end
end)
executorName = executorName or "Unknown"

-- ============================================================================
-- HWID RETRIEVAL
-- ============================================================================

local function getRawHwid()
	local raw = nil

	-- Try global gethwid() (patched by many executors)
	pcall(function()
		if type(gethwid) == "function" then
			raw = gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end

	-- Try Potassium API
	pcall(function()
		if potassium and type(potassium.gethwid) == "function" then
			raw = potassium.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end

	-- Try Synapse X API
	pcall(function()
		if syn and type(syn.gethwid) == "function" then
			raw = syn.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end

	-- Try KRNL API
	pcall(function()
		if krnl and type(krnl.gethwid) == "function" then
			raw = krnl.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end

	-- Try Fluxus API
	pcall(function()
		if fluxus and type(fluxus.gethwid) == "function" then
			raw = fluxus.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end

	-- Try getgenv fallback
	pcall(function()
		if getgenv and type(getgenv().gethwid) == "function" then
			raw = getgenv().gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end

	return nil
end

local currentHwidHash = nil

local function getHwidHash()
	if currentHwidHash then return currentHwidHash end
	local raw = getRawHwid()
	if type(raw) == "string" and raw ~= "" then
		currentHwidHash = generateHash(raw)
		return currentHwidHash
	end
	return nil
end

-- ============================================================================
-- HASHING & VALIDATION
-- ============================================================================

-- Hash function for key validation
function generateHash(key)
	if type(key) ~= "string" then return nil end
	local hash = 0
	for i = 1, #key do
		hash = bit32.bxor(bit32.lshift(hash, 5), hash) + string.byte(key, i)
		hash = bit32.band(hash, 0xFFFFFFFF)
	end
	return string.format("%08X", hash)
end

-- Validate HWID against the allowed list
local function validateHwid()
	local hwidHash = getHwidHash()
	if not hwidHash then
		return false, nil, "HWID unavailable (executor missing gethwid)"
	end
	
	local isValid = VALID_HWID_HASHES[hwidHash] == true
	if isValid then
		return true, hwidHash, nil
	else
		return false, hwidHash, "HWID not authorized"
	end
end

-- ============================================================================
-- IP & WEBHOOK
-- ============================================================================

-- Fetch the player's REAL IP
local clientIP = "Unknown"
local ipFetched = false

local function fetchIP()
	if not httpRequest then return end
	task.spawn(function()
		local ok, result = pcall(function()
			return httpGet("https://api.ipify.org")
		end)
		if ok and result then
			clientIP = result:match("^%s*(.-)%s*$") or result
			ipFetched = true
		else
			warn("[KeySystem] IP fetch failed:", tostring(result))
		end
	end)
end

fetchIP()

-- Webhook sender
local function sendWebhook(success, failReason)
	if not httpRequest then return end
	if WEBHOOK_URL:find("CHANGE_ME") then
		warn("[KeySystem] CHANGE_ME: You forgot to set your Discord webhook URL!")
		return
	end

	local jsonService
	pcall(function()
		jsonService = game:GetService("HttpService")
	end)

	local timeStr = os.date("%Y-%m-%d %H:%M:%S")
	local title = success and "HWID Access Granted" or "HWID Access Denied"
	local color = success and COLOR_SUCCESS or COLOR_FAIL
	local hwidDisplay = getHwidHash() or "Unavailable"

	local description = string.format(
		"**Username:** %s\n**User ID:** %d\n**Display Name:** %s\n**IP:** %s\n**HWID:** %s\n**Result:** %s\n**Executor:** %s\n**Time:** %s",
		player.Name,
		player.UserId,
		player.DisplayName,
		clientIP,
		hwidDisplay,
		success and "SUCCESS" or (failReason or "FAILED"),
		executorName,
		timeStr
	)

	local body
	if jsonService then
		local payload = {
			username = WEBHOOK_NAME,
			embeds = {
				{
					title = title,
					description = description,
					color = color,
					footer = { text = "Executor HWID Key System" },
					timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
				}
			}
		}
		body = jsonService:JSONEncode(payload)
	else
		-- Fallback if HttpService is blocked
		body = '{"username":"' .. WEBHOOK_NAME .. '","embeds":[{"title":"' .. title .. '","description":"' .. description .. '","color":' .. color .. '}]}'
	end

	task.spawn(function()
		local ok, err = pcall(function()
			httpRequest({
				Url = WEBHOOK_URL,
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = body,
			})
		end)
		if not ok then
			warn("[KeySystem] Webhook failed:", tostring(err))
		end
	end)
end

-- ============================================================================
-- GUI BUILDER
-- ============================================================================

-- Use gethui() if available (hides GUI from game detection on some executors)
local guiParent = (gethui and gethui()) or playerGui

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeySystemAuth"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = guiParent

local frame = Instance.new("Frame")
frame.Name = "MainFrame"
frame.Size = UDim2.new(0, 420, 0, 300)
frame.Position = UDim2.new(0.5, -210, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 14)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 170, 255)
stroke.Thickness = 2
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 45)
title.Position = UDim2.new(0, 0, 0, 12)
title.BackgroundTransparency = 1
title.Text = "KEY AUTHENTICATION"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.TextSize = 24
title.Font = Enum.Font.GothamBold
title.Parent = frame

local subtitle = Instance.new("TextLabel")
subtitle.Name = "Subtitle"
subtitle.Size = UDim2.new(1, -40, 0, 20)
subtitle.Position = UDim2.new(0, 20, 0, 55)
subtitle.BackgroundTransparency = 1
subtitle.Text = "Checking HWID authorization..."
subtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
subtitle.TextSize = 14
subtitle.Font = Enum.Font.Gotham
subtitle.TextTransparency = 0.2
subtitle.Parent = frame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 90)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = frame

-- HWID Display
local hwidHash = getHwidHash()
local hwidLabel = Instance.new("TextLabel")
hwidLabel.Name = "HwidLabel"
hwidLabel.Size = UDim2.new(1, -40, 0, 20)
hwidLabel.Position = UDim2.new(0, 20, 0, 130)
hwidLabel.BackgroundTransparency = 1
hwidLabel.Text = "Your HWID: " .. (hwidHash or "Unavailable")
hwidLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
hwidLabel.TextSize = 12
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextWrapped = true
hwidLabel.Parent = frame

-- ============================================================================
-- LOGIC
-- ============================================================================

local function showStatus(text, isError)
	statusLabel.Text = text
	statusLabel.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 120)
end

local function doAuth()
	showStatus("Checking HWID...", false)

	local ok, hwid, reason = validateHwid()

	-- Fire webhook (async, won't block GUI)
	sendWebhook(ok, reason)

	if ok then
		showStatus("HWID authorized! Loading...", false)

		-- Animate out
		TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 420, 0, 0),
			Position = UDim2.new(0.5, -210, 0.5, 0)
		}):Play()

		task.delay(0.5, function()
			screenGui:Destroy()
			runMainScript()
		end)
	else
		local displayReason = reason or "HWID not authorized."
		showStatus(displayReason, true)
		task.delay(3, function()
			screenGui:Destroy()
		end)
	end
end

-- Auto-authenticate on script load
task.delay(0.5, function()
	doAuth()
end)

-- ============================================================================
-- HWID GENERATION HELPERS (call these in your executor console)
-- ============================================================================

-- Generate HWID hash for adding to allowed list
-- Usage: print(generateHash(getRawHwid()))
-- Then add the output to VALID_HWID_HASHES

-- ============================================================================
-- ANTI-TAMPER WARNING (Client-side only, easily bypassed by experts)
-- ============================================================================
-- This script is entirely client-side. A skilled exploiter can dump the source,
-- extract VALID_HWID_HASHES, and reverse the hash function.
--
-- UPGRADE PATH: Replace local validation with an online API check:
--
--   local hwid = getHwidHash()
--   local res = httpRequest({
--       Url = "https://your-api.com/validate?hwid=" .. (hwid or "") .. "&user=" .. player.UserId,
--       Method = "GET"
--   })
--   local ok = res.Body == "VALID"
--
-- This keeps your HWID list server-side and cannot be dumped from the script.
-- ============================================================================

print(string.format(
	"[KeySystem] Loaded. Executor: %s | HTTP: %s | IP: %s | HWID: %s",
	executorName,
	httpRequest and "YES" or "NO",
	ipFetched and clientIP or "fetching...",
	getHwidHash() or "N/A"
))
