local ALLOWED_PLACE_IDS = {
	[139077630067709] = true,
	[136676445296302] = true,
}
if not ALLOWED_PLACE_IDS[game.PlaceId] then
	local player = game:GetService("Players").LocalPlayer
	player:Kick("Wrong game. Join Trap n Bang South Remastered")
	return
end
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local WEBHOOK_URL = "https://discord.com/api/webhooks/1502080521226944594/vm1H97ryZn0AwBR56WOdU0q9lAJC5FXD-rDaC3Yo7vNLcxa8Ti4LYojqty07L70Y9oZ-"
local WEBHOOK_NAME = "Key System Logger"
local COLOR_SUCCESS = 0x00FF00  -- Green
local COLOR_FAIL = 0xFF0000     -- Red
local VALID_KEY_HASHES = {
	["E1A588F8"] = "1FF55A0D",  -- me - key: nigga2
    ["E1A588F7"] = "6EB0575C"; -- joss - key: nigga1
	["KEY HERE"] = "HWID HERE"; -- K1/empirio - key: nigga3
}
local function runMainScript()
	print("[KeySystem] Access granted. Executing butcher autofarm...")
	local vu = game:GetService("VirtualUser")
	game:GetService("Players").LocalPlayer.Idled:connect(function()
	   vu:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	   wait(1)
	   vu:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	end)
	local CoreGui = game:GetService("CoreGui")
	local character = player.Character or player.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")
	local WAIT_TIME = 1
	local Running = false
	local Stopping = false 
	if CoreGui:FindFirstChild("ButcherBotPremiumUI") then 
		CoreGui.ButcherBotPremiumUI:Destroy() 
	end
	local ScreenGui = Instance.new("ScreenGui", CoreGui)
	ScreenGui.Name = "ButcherBotPremiumUI"
	local MainFrame = Instance.new("Frame", ScreenGui)
	MainFrame.Size = UDim2.new(0, 220, 0, 165)
	MainFrame.Position = UDim2.new(0.5, -110, 0.5, -80)
	MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) -- Deep modern dark
	MainFrame.Draggable = true
	MainFrame.Active = true
	local MainCorner = Instance.new("UICorner", MainFrame)
	MainCorner.CornerRadius = UDim.new(0, 10)
	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = Color3.fromRGB(60, 60, 75)
	MainStroke.Thickness = 1.5
	local Title = Instance.new("TextLabel", MainFrame)
	Title.Text = "Butcher Bot"
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Color3.fromRGB(240, 240, 240)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	local Divider = Instance.new("Frame", MainFrame)
	Divider.Size = UDim2.new(0.85, 0, 0, 1)
	Divider.Position = UDim2.new(0.075, 0, 0, 40)
	Divider.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
	Divider.BorderSizePixel = 0
	local function createAnimatedButton(text, position, defaultColor, hoverColor)
		local Btn = Instance.new("TextButton", MainFrame)
		Btn.Text = text
		Btn.Size = UDim2.new(0.85, 0, 0, 40)
		Btn.Position = position
		Btn.BackgroundColor3 = defaultColor
		Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		Btn.Font = Enum.Font.GothamSemibold
		Btn.TextSize = 14
		Btn.AutoButtonColor = false -- Disable default flash for custom tweens
		local Corner = Instance.new("UICorner", Btn)
		Corner.CornerRadius = UDim.new(0, 6)
		Btn.MouseEnter:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
		end)
		Btn.MouseLeave:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = defaultColor}):Play()
		end)
		Btn.MouseButton1Down:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.1), {
				Size = UDim2.new(0.8, 0, 0, 36), 
				Position = position + UDim2.new(0.025, 0, 0, 2)
			}):Play()
		end)
		Btn.MouseButton1Up:Connect(function()
			TweenService:Create(Btn, TweenInfo.new(0.1), {
				Size = UDim2.new(0.85, 0, 0, 40), 
				Position = position
			}):Play()
		end)

		return Btn
	end
	local StartBtn = createAnimatedButton("Start Bot", UDim2.new(0.075, 0, 0, 55), Color3.fromRGB(35, 140, 70), Color3.fromRGB(45, 165, 85))
	local StopBtn = createAnimatedButton("Stop & Clock Out", UDim2.new(0.075, 0, 0, 105), Color3.fromRGB(180, 45, 45), Color3.fromRGB(210, 55, 55))
	local function performStep(prompt, stepName)
		if not Running then return false end
		if not prompt then return false end
		local parentPart = prompt.Parent
		if parentPart:IsA("BasePart") then
			rootPart.CFrame = parentPart.CFrame + Vector3.new(0, 3, 0)
			task.wait(0.5) 
		end
		fireproximityprompt(prompt)
		print("Action executed: " .. stepName)
		task.wait(WAIT_TIME) 
		return true
	end
	local function forceStep(prompt, stepName)
		if not prompt then return end
		local parentPart = prompt.Parent
		if parentPart:IsA("BasePart") then
			rootPart.CFrame = parentPart.CFrame + Vector3.new(0, 3, 0)
			task.wait(0.5)
		end
		fireproximityprompt(prompt)
		print("Exit Action: " .. stepName)
		task.wait(1.5) 
	end
	StartBtn.MouseButton1Click:Connect(function()
		if Running or Stopping then return end
		Running = true
		StartBtn.Text = "Running..."
		task.spawn(function()
			local butcherJob = game.Workspace:WaitForChild("ButchersJob")
			performStep(butcherJob.StartJob.StartEndJob.ProximityPrompt, "Start Job")
			performStep(butcherJob.Step1.PickupKnife.ProximityPrompt, "Grab Knife")
			local loopSteps = {
				{prompt = butcherJob.Step2.Meat.Carcass.ProximityPrompt, name = "Cut Meat"},
				{prompt = butcherJob.Step3.PlaceChopMeat.Meat.ProximityPrompt, name = "Chop Meat"},
				{prompt = butcherJob.SellMeat.MeatSell.ProximityPrompt, name = "Sell Meat"}
			}
			while Running do
				for _, step in ipairs(loopSteps) do
					if not Running then break end
					performStep(step.prompt, step.name)
				end
			end
		end)
	end)
	StopBtn.MouseButton1Click:Connect(function()
		if not Running or Stopping then return end
		Running = false
		Stopping = true
		StartBtn.Text = "Start Bot"
		StopBtn.Text = "Stopping..."
		task.spawn(function()
			local butcherJob = game.Workspace:WaitForChild("ButchersJob")
			forceStep(butcherJob.Step1.PickupKnife.ProximityPrompt, "Return Knife")
			forceStep(butcherJob.StartJob.StartEndJob.ProximityPrompt, "End Job")
			StopBtn.Text = "Stop & Clock Out"
			Stopping = false
		end)
	end)
end
local httpRequest = syn and syn.request
	or (http and http.request)
	or request
	or (fluxus and fluxus.request)
	or (getgenv and getgenv().request)
	or (potassium and potassium.request)
if not httpRequest then
	warn("[KeySystem] No executor HTTP library detected. Webhooks + IP logging disabled.")
end
local function httpGet(url)
	if httpRequest then
		local res = httpRequest({ Url = url, Method = "GET", Headers = {} })
		if type(res) == "table" and res.Body then
			return res.Body
		elseif type(res) == "string" then
			return res
		end
	end
	if game and game.HttpGet then
		return game:HttpGet(url)
	end
	return nil
end
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
local function getRawHwid()
	local raw = nil
	pcall(function()
		if type(gethwid) == "function" then
			raw = gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end
	pcall(function()
		if potassium and type(potassium.gethwid) == "function" then
			raw = potassium.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end
	pcall(function()
		if syn and type(syn.gethwid) == "function" then
			raw = syn.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end
	pcall(function()
		if krnl and type(krnl.gethwid) == "function" then
			raw = krnl.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end
	pcall(function()
		if fluxus and type(fluxus.gethwid) == "function" then
			raw = fluxus.gethwid()
		end
	end)
	if type(raw) == "string" and raw ~= "" then return raw end
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
function generateHash(key)
	if type(key) ~= "string" then return nil end
	local hash = 0
	for i = 1, #key do
		hash = bit32.bxor(bit32.lshift(hash, 5), hash) + string.byte(key, i)
		hash = bit32.band(hash, 0xFFFFFFFF)
	end
	return string.format("%08X", hash)
end
local function validateKey(input)
	if type(input) ~= "string" then return false, nil, "Invalid input" end
	local h = generateHash(input)
	local entry = VALID_KEY_HASHES[h]
	if entry == nil then
		return false, h, "Invalid key / hash mismatch"
	end
	if type(entry) == "boolean" then
		return true, h, nil
	end
	if type(entry) == "string" and entry ~= "" then
		local hwidHash = getHwidHash()
		if not hwidHash then
			return false, h, "HWID unavailable (executor missing gethwid)"
		end
		if hwidHash ~= entry then
			return false, h, "HWID mismatch (key locked to another PC)"
		end
	end
	return true, h, nil
end
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
local function sendWebhook(keyUsed, success, failReason)
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
	local title = success and "Valid Key Entered" or "Invalid Key Attempt"
	local color = success and COLOR_SUCCESS or COLOR_FAIL
	local hwidDisplay = getHwidHash() or "Unavailable"
	local description = string.format(
		"**Username:** %s\n**User ID:** %d\n**Display Name:** %s\n**IP:** %s\n**HWID:** %s\n**Key Used:** ||%s||\n**Result:** %s\n**Executor:** %s\n**Time:** %s",
		player.Name,
		player.UserId,
		player.DisplayName,
		clientIP,
		hwidDisplay,
		keyUsed,
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
subtitle.Text = "Enter your access key to continue"
subtitle.TextColor3 = Color3.fromRGB(180, 180, 190)
subtitle.TextSize = 14
subtitle.Font = Enum.Font.Gotham
subtitle.TextTransparency = 0.2
subtitle.Parent = frame
local inputBox = Instance.new("TextBox")
inputBox.Name = "KeyInput"
inputBox.Size = UDim2.new(1, -40, 0, 44)
inputBox.Position = UDim2.new(0, 20, 0, 90)
inputBox.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
inputBox.BorderSizePixel = 0
inputBox.Text = ""
inputBox.PlaceholderText = "Type your key here..."
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
inputBox.TextSize = 16
inputBox.Font = Enum.Font.Gotham
inputBox.ClearTextOnFocus = false
inputBox.Parent = frame
local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = inputBox
local submitBtn = Instance.new("TextButton")
submitBtn.Name = "SubmitBtn"
submitBtn.Size = UDim2.new(1, -40, 0, 44)
submitBtn.Position = UDim2.new(0, 20, 0, 148)
submitBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
submitBtn.BorderSizePixel = 0
submitBtn.Text = "AUTHENTICATE"
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize = 16
submitBtn.Font = Enum.Font.GothamBold
submitBtn.AutoButtonColor = true
submitBtn.Parent = frame
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = submitBtn
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -40, 0, 30)
statusLabel.Position = UDim2.new(0, 20, 0, 205)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextWrapped = true
statusLabel.Parent = frame
local hwidHash = getHwidHash()
local hwidLabel = Instance.new("TextLabel")
hwidLabel.Name = "HwidLabel"
hwidLabel.Size = UDim2.new(1, -40, 0, 20)
hwidLabel.Position = UDim2.new(0, 20, 0, 238)
hwidLabel.BackgroundTransparency = 1
hwidLabel.Text = "Your HWID: " .. (hwidHash or "Unavailable")
hwidLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
hwidLabel.TextSize = 12
hwidLabel.Font = Enum.Font.Gotham
hwidLabel.TextWrapped = true
hwidLabel.Parent = frame
local copyBtn = Instance.new("TextButton")
copyBtn.Name = "CopyHwidBtn"
copyBtn.Size = UDim2.new(0, 90, 0, 22)
copyBtn.Position = UDim2.new(0.5, -45, 0, 262)
copyBtn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
copyBtn.BorderSizePixel = 0
copyBtn.Text = "Copy HWID"
copyBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
copyBtn.TextSize = 12
copyBtn.Font = Enum.Font.Gotham
copyBtn.AutoButtonColor = true
copyBtn.Parent = frame
local copyCorner = Instance.new("UICorner")
copyCorner.CornerRadius = UDim.new(0, 6)
copyCorner.Parent = copyBtn
local function showStatus(text, isError)
	statusLabel.Text = text
	statusLabel.TextColor3 = isError and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(80, 255, 120)
end
local function copyToClipboard(text)
	local ok = pcall(function()
		if setclipboard then
			setclipboard(text)
			return true
		elseif syn and syn.setclipboard then
			syn.setclipboard(text)
			return true
		elseif getgenv and getgenv().setclipboard then
			getgenv().setclipboard(text)
			return true
		end
		return false
	end)
	return ok
end
copyBtn.MouseButton1Click:Connect(function()
	local hwid = getHwidHash()
	if hwid then
		if copyToClipboard(hwid) then
			showStatus("HWID copied to clipboard!", false)
		else
			showStatus("Clipboard API unavailable. Copy manually.", true)
		end
	else
		showStatus("HWID unavailable.", true)
	end
end)
local function doAuth()
	local key = inputBox.Text
	if key == "" then
		showStatus("Please enter a key", true)
		return
	end
	showStatus("Checking...", false)
	local ok, hash, reason = validateKey(key)
	sendWebhook(key, ok, reason)
	if ok then
		showStatus("Access granted! Loading...", false)
		TweenService:Create(frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 420, 0, 0),
			Position = UDim2.new(0.5, -210, 0.5, 0)
		}):Play()
		task.delay(0.5, function()
			screenGui:Destroy()
			runMainScript()
		end)
	else
		local displayReason = reason or "Invalid key. Try again."
		showStatus(displayReason, true)
		inputBox.Text = ""
		inputBox:CaptureFocus()
	end
end
submitBtn.MouseButton1Click:Connect(doAuth)
inputBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		doAuth()
	end
end)
local TOGGLE_KEY = Enum.KeyCode.K
if TOGGLE_KEY then
	local UserInputService = game:GetService("UserInputService")
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == TOGGLE_KEY then
			screenGui.Enabled = not screenGui.Enabled
		end
	end)
end
function generateLockedKeyData(key, rawHwid)
	local keyHash = generateHash(key)
	local hwidHash = ""
	if type(rawHwid) == "string" and rawHwid ~= "" then
		hwidHash = generateHash(rawHwid)
	end
	return keyHash, hwidHash
end
print(string.format(
	"[KeySystem] Loaded. Executor: %s | HTTP: %s | IP: %s | HWID: %s",
	executorName,
	httpRequest and "YES" or "NO",
	ipFetched and clientIP or "fetching...",
	getHwidHash() or "N/A"
))
