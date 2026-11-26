local ProtectionConfig = {
    SecretKey = "2009",

    -- The name of your Hub (shown in the kick message if they try to bypass)
    HubName = "Aural V2"
}

-- Anti-Bypass Logic: Checks if the Key System successfully set the global variable
if false then -- [bypassed] anti-exec guard; was: if not _G[ProtectionConfig.SecretKey]
    local player = game:GetService("Players").LocalPlayer
    if player then
        player:Kick("\n🛡️ Unauthorized Execution 🛡️\n\nPlease use the official Key System to run " .. ProtectionConfig.HubName)
    end
    return -- Stops the rest of the script from loading!
end

-------------------------------------------------------------------------------
-- 👇 YOUR MAIN SCRIPT CODE STARTS HERE 👇
-------------------------------------------------------------------------------

-- Console output disabled: every print/warn call below is shadowed to a no-op
-- LOCAL (the real globals are left untouched), and the boot banner's own
-- Print field is forced silent further down too.
local function Noop(...) end
local print = Noop
local warn = Noop

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

if false then -- [bypassed] gameid lock; was: if game.GameId ~= 7633926880
    LocalPlayer:Kick("Aural V2: this script is for BloxStrike only")
    return
end

local AuralBanner = {
    Print = Noop, -- forced silent: console output is disabled for this build
    Started = os.clock(),
    Last = os.clock(),
    Done = 0,
    Total = 4,
}
local MarioBanner = AuralBanner

function AuralBanner.Show()
    local ok, executor = pcall(identifyexecutor)
    if not ok or type(executor) ~= "string" then executor = "Unknown" end
    local rule = string.rep("=", 54)
    AuralBanner.Print(table.concat({
        "",
        [[
  █████╗ ██╗   ██╗██████╗  █████╗ ██╗      ██╗   ██╗██████╗
 ██╔══██╗██║   ██║██╔══██╗██╔══██╗██║      ██║   ██║╚════██╗
 ███████║██║   ██║██████╔╝███████║██║      ██║   ██║ █████╔╝
 ██╔══██║██║   ██║██╔══██╗██╔══██║██║      ╚██╗ ██╔╝██╔═══╝
 ██║  ██║╚██████╔╝██║  ██║██║  ██║███████╗  ╚████╔╝ ███████╗
 ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═══╝  ╚══════╝
]],
        rule,
        "   BLOXSTRIKE  //  Aural V2  //  discord.gg/pzVJV34AH8",
        "   executor: " .. executor .. "   //   player: " .. game:GetService("Players").LocalPlayer.Name,
        rule,
    }, "\n"))
end

---@param label string  what just finished loading
function AuralBanner.Step(label)
    local now = os.clock()
    AuralBanner.Done = math.min(AuralBanner.Done + 1, AuralBanner.Total)
    local filled = math.floor(AuralBanner.Done / AuralBanner.Total * 20 + 0.5)
    AuralBanner.Print(string.format("[Aural V2] [%s] %3d%%  %-24s +%dms",
        string.rep("#", filled) .. string.rep(".", 20 - filled),
        math.floor(AuralBanner.Done / AuralBanner.Total * 100), label, math.floor((now - AuralBanner.Last) * 1000)))
    AuralBanner.Last = now
end

function AuralBanner.Ready()
    local rule = string.rep("=", 54)
    AuralBanner.Print(table.concat({
        rule,
        string.format("   >> AURAL V2 READY in %dms", math.floor((os.clock() - AuralBanner.Started) * 1000)),
        rule,
    }, "\n"))
end

pcall(AuralBanner.Show)
pcall(AuralBanner.Step, "Core")

local environment = getgenv and getgenv() or _G
if getgenv().Arcane and getgenv().Arcane.Unload then pcall(getgenv().Arcane.Unload, getgenv().Arcane) end

if not rawget(_G, "LPH_OBFUSCATED") then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local vector2New = Vector2.new
local cframeLookAt = CFrame.lookAt
local osClock = os.clock

local ARCANE_SOURCE = [=[
if getgenv().Arcane and getgenv().Arcane.Unload then
	getgenv().Arcane:Unload()
end

local arcane = {}
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local GuiService = game:GetService("GuiService")
local cloneref_ = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local mouse = LocalPlayer:GetMouse()
local Y = GuiService:GetGuiInset().Y
local v12 = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

gethui = gethui or function()
	return cloneref_
end

local lib

pcall(function()
	lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/icons.lua"))()
end)

local function v14(p1)
	if type(p1) == "number" then
		return "rbxassetid://" .. p1
	end

	if type(p1) == "string" then
		if string.match(p1, "^rbxassetid://") then
			return p1
		end

		if string.match(p1, "^%d+$") then
			return "rbxassetid://" .. p1
		end

		local v15 = string.lower(p1)

		if type(lib) == "function" then
			local ok, result = pcall(lib, v15)

			if ok and type(result) == "table" then
				local id = result.id or result.Id or result[1]
				local imageRectSize = result.imageRectSize or result.ImageRectSize or result[2]
				local imageRectOffset = result.imageRectOffset or result.imageRectPosition or result.ImageRectOffset or result[3]

				if id then
					return "rbxassetid://" .. tostring(id), imageRectOffset, imageRectSize
				end
			end
		elseif type(lib) == "table" then
			for _, v in {
				lib["48px"],
				lib["256px"],
				lib
			}, nil, nil do
				if type(v) == "table" then
					local v23 = v[v15]

					if type(v23) ~= "table" then
						continue
					end

					if v23[1] then
						return "rbxassetid://" .. tostring(v23[1]), v23[3], v23[2]
					end
				end
			end
		end
	end

	return "rbxassetid://0"
end
local function v24(p2)
	if typeof(p2) == "Vector2" then
		return p2
	end

	if type(p2) == "table" then
		return Vector2.new(p2[1] or p2.X or 0, p2[2] or p2.Y or 0)
	end

	return Vector2.new(0, 0)
end
local function v25(p3, p4)
	if not p4 then
		return
	end

	local v26, v27, v28 = v14(p4)

	p3.Image = v26
	p3.ImageRectOffset = v24(v27)
	p3.ImageRectSize = v24(v28)
end

local t1 = {
	Dark = {
		Background = Color3.fromRGB(16, 16, 18),
		Topbar = Color3.fromRGB(22, 22, 26),
		Section = Color3.fromRGB(21, 20, 25),
		Element = Color3.fromRGB(27, 26, 33),
		Accent = Color3.fromRGB(254, 0, 67),
		Text = Color3.fromRGB(255, 255, 255),
		DimText = Color3.fromRGB(120, 120, 130),
		Border = Color3.fromRGB(30, 29, 34),
		Selected = Color3.fromRGB(29, 28, 37),
		ToggleOff = Color3.fromRGB(35, 25, 38)
	},
	Light = {
		Background = Color3.fromRGB(228, 228, 233),
		Topbar = Color3.fromRGB(235, 235, 240),
		Section = Color3.fromRGB(245, 245, 249),
		Element = Color3.fromRGB(230, 230, 236),
		Accent = Color3.fromRGB(254, 0, 67),
		Text = Color3.fromRGB(24, 24, 30),
		DimText = Color3.fromRGB(140, 140, 150),
		Border = Color3.fromRGB(205, 205, 214),
		Selected = Color3.fromRGB(216, 216, 224),
		ToggleOff = Color3.fromRGB(210, 202, 206)
	},
	Ocean = {
		Background = Color3.fromRGB(14, 17, 22),
		Topbar = Color3.fromRGB(20, 24, 31),
		Section = Color3.fromRGB(18, 22, 28),
		Element = Color3.fromRGB(24, 29, 37),
		Accent = Color3.fromRGB(0, 170, 255),
		Text = Color3.fromRGB(235, 240, 245),
		DimText = Color3.fromRGB(90, 100, 115),
		Border = Color3.fromRGB(28, 33, 42),
		Selected = Color3.fromRGB(28, 35, 48),
		ToggleOff = Color3.fromRGB(26, 34, 46)
	},
	Crimson = {
		Background = Color3.fromRGB(18, 14, 15),
		Topbar = Color3.fromRGB(26, 20, 21),
		Section = Color3.fromRGB(23, 18, 19),
		Element = Color3.fromRGB(32, 24, 26),
		Accent = Color3.fromRGB(230, 40, 70),
		Text = Color3.fromRGB(245, 235, 237),
		DimText = Color3.fromRGB(120, 95, 100),
		Border = Color3.fromRGB(38, 28, 31),
		Selected = Color3.fromRGB(42, 28, 31),
		ToggleOff = Color3.fromRGB(40, 26, 30)
	},
	Emerald = {
		Background = Color3.fromRGB(14, 19, 16),
		Topbar = Color3.fromRGB(20, 27, 23),
		Section = Color3.fromRGB(18, 24, 20),
		Element = Color3.fromRGB(24, 33, 28),
		Accent = Color3.fromRGB(0, 200, 130),
		Text = Color3.fromRGB(235, 245, 240),
		DimText = Color3.fromRGB(95, 115, 105),
		Border = Color3.fromRGB(28, 38, 32),
		Selected = Color3.fromRGB(28, 44, 36),
		ToggleOff = Color3.fromRGB(26, 40, 32)
	},
	Amethyst = {
		Background = Color3.fromRGB(17, 14, 22),
		Topbar = Color3.fromRGB(24, 20, 31),
		Section = Color3.fromRGB(21, 18, 28),
		Element = Color3.fromRGB(30, 25, 39),
		Accent = Color3.fromRGB(170, 90, 255),
		Text = Color3.fromRGB(240, 236, 248),
		DimText = Color3.fromRGB(110, 100, 125),
		Border = Color3.fromRGB(35, 28, 46),
		Selected = Color3.fromRGB(40, 32, 54),
		ToggleOff = Color3.fromRGB(36, 28, 48)
	},
	-- ── Custom Themes ──────────────────────────────────────────────────────
	-- Midnight: near-black background with vivid electric-blue accent.
	-- Every colour is derived from the same midnight-blue hue family so the
	-- whole palette feels coherent, not just "dark + blue tacked on".
	Midnight = {
		Background = Color3.fromRGB(8,  10, 20),
		Topbar     = Color3.fromRGB(12, 15, 28),
		Section    = Color3.fromRGB(11, 14, 24),
		Element    = Color3.fromRGB(15, 20, 36),
		Accent     = Color3.fromRGB(80, 140, 255),
		Text       = Color3.fromRGB(220, 230, 255),
		DimText    = Color3.fromRGB(80,  95, 130),
		Border     = Color3.fromRGB(20,  28, 50),
		Selected   = Color3.fromRGB(18,  26, 52),
		ToggleOff  = Color3.fromRGB(16,  22, 42)
	},
	-- Abyss: deeper, more saturated variant — richer indigo-black tones,
	-- stronger blue accent, more contrast between Background and Element.
	Abyss = {
		Background = Color3.fromRGB(6,  8,  16),
		Topbar     = Color3.fromRGB(9,  12, 22),
		Section    = Color3.fromRGB(8,  11, 20),
		Element    = Color3.fromRGB(12, 17, 32),
		Accent     = Color3.fromRGB(40, 100, 220),
		Text       = Color3.fromRGB(210, 220, 255),
		DimText    = Color3.fromRGB(65,  80, 115),
		Border     = Color3.fromRGB(16,  22, 42),
		Selected   = Color3.fromRGB(14,  20, 44),
		ToggleOff  = Color3.fromRGB(12,  18, 36)
	}
}

local function v30()
	local Theme = arcane.Theme

	Theme.Inline = Theme.Topbar
	Theme.AccentDark = Theme.Accent
	Theme.Divider = Theme.Border
	Theme.DimIcon = Theme.DimText:Lerp(Theme.Background, 0.45)
	Theme.SliderBack = Theme.Element
	Theme.DropdownBack = Theme.Element
	Theme.DropdownSelected = Theme.Element:Lerp(Theme.Text, 0.045)
	Theme.ToggleOn = Theme.Accent:Lerp(Theme.Section, 0.72)
	Theme.ToggleOffCircle = Theme.ToggleOff:Lerp(Theme.DimText, 0.5)
	Theme.SliderKnob = Theme.Text:Lerp(Color3.fromRGB(255, 255, 255), 0.8)
end

arcane.__index = arcane
arcane.Theme = table.clone(t1.Dark)
v30()
arcane.CurrentTheme = "Dark"
arcane.PreviousTheme = "Dark"
arcane.Flags = {}
arcane.Threads = {}
arcane.Connections = {}
arcane.ThemingStuff = {}
arcane.ThemeMap = {}
arcane.OpenFrames = {}
arcane.Windows = {}
arcane.MenuKeybind = tostring(Enum.KeyCode.RightControl)
arcane.SetFlags = {}
arcane.Directory = "Arcane"
arcane.ConfigFolder = "Arcane/Configs"
arcane.ThemeKeys = {
	"Background",
	"Topbar",
	"Section",
	"Element",
	"Accent",
	"Text",
	"DimText",
	"Border"
}
arcane.ThemeList = {
	"Dark",
	"Light",
	"Ocean",
	"Crimson",
	"Emerald",
	"Amethyst",
	"Midnight",
	"Abyss"
}
arcane.Language = "ENG"
arcane.LanguageCodes = {
	RUS = "ru",
	SPA = "es",
	BRA = "pt",
	PHL = "tl",
	FRA = "fr",
	GER = "de",
	TUR = "tr"
}
arcane.Translations = {}
arcane.TranslationCache = {}
arcane.TextRegistry = {}
arcane.LanguageHooks = {}
arcane.SwapTokens = setmetatable({}, {
	__mode = "k"
})
arcane.SwapText = function(p5, p6, p7, p8)
	pcall(function()
		if p6.Text == p7 then
			return
		end

		if not p6:IsDescendantOf(arcane.Holder.Instance) then
			arcane.SwapTokens[p6] = (arcane.SwapTokens[p6] or 0) + 1
			p6.Text = p7

			return
		end

		local v32 = arcane.RestingValues[p6]

		if v32 and v32.TextTransparency ~= nil then
			arcane.SwapTokens[p6] = (arcane.SwapTokens[p6] or 0) + 1
			p6.Text = p7

			return
		end

		arcane.SwapTokens[p6] = (arcane.SwapTokens[p6] or 0) + 1

		local v33 = arcane.SwapTokens[p6]

		arcane:Tween({
			TextTransparency = 1
		}, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p6)
		task.delay(0.13, function()
			pcall(function()
				if arcane.SwapTokens[p6] ~= v33 then
					return
				end

				p6.Text = p7

				local v34 = arcane.RestingValues[p6]

				if v34 and v34.TextTransparency ~= nil then
					return
				end

				arcane:Tween({
					TextTransparency = p8 or 0
				}, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p6)
			end)
		end)
	end)
end
arcane.DisplayName = function(p9, p10)
	local v35 = arcane.LanguageCodes[arcane.Language]

	if v35 then
		return arcane.Translations[p10] or arcane.TranslationCache[v35 .. "\1" .. p10] or p10
	end

	return p10
end
arcane.TranslateEntry = function(p11, p12)
	local English = p12.English
	local v37 = arcane.LanguageCodes[arcane.Language]

	if not v37 then
		return
	end

	local v38 = arcane.Translations[English]

	if v38 then
		arcane:SwapText(p12.Label, v38, p12.Transparency)

		return
	end

	local v39 = v37 .. "\1" .. English
	local v40 = arcane.TranslationCache[v39]

	if not v40 then
		task.spawn(function()
			local ok, result = pcall(function()
				local v43 = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" .. v37 .. "&dt=t&q=" .. HttpService:UrlEncode(English)

				return HttpService:JSONDecode(game:HttpGet(v43))[1][1][1]
			end)

			if ok then
				if type(result) == "string" and result ~= "" then
					arcane.TranslationCache[v39] = result

					if arcane.LanguageCodes[arcane.Language] == v37 then
						arcane:SwapText(p12.Label, result, p12.Transparency)
					end
				end
			end
		end)

		return
	end

	arcane:SwapText(p12.Label, v40, p12.Transparency)
end
arcane.RegisterText = function(p13, p14, p15)
	local t2 = {
		Label = p14,
		English = p15,
		Transparency = p14.TextTransparency
	}

	table.insert(arcane.TextRegistry, t2)

	if arcane.LanguageCodes[arcane.Language] then
		arcane:TranslateEntry(t2)
	end

	return t2
end
arcane.SetLanguage = function(p16, p17)
	arcane.Language = p17
	arcane.LanguageToken = (arcane.LanguageToken or 0) + 1

	local LanguageToken = arcane.LanguageToken
	local v46 = arcane.LanguageCodes[p17]

	local function v47()
		for _, v in arcane.LanguageHooks, nil, nil do
			pcall(v)
		end
	end

	if v46 then
		task.spawn(function()
			local n1 = 0
			local n2 = 0
			local t3 = {}

			for _, v in arcane.TextRegistry, nil, nil do
				local v55 = v46 .. "\1" .. v.English

				if not arcane.Translations[v.English] and not arcane.TranslationCache[v55] and not t3[v55] then
					t3[v55] = true
					n1 += 1

					local English = v.English

					task.spawn(function()
						local ok, result = pcall(function()
							local v59 = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=" .. v46 .. "&dt=t&q=" .. HttpService:UrlEncode(English)

							return HttpService:JSONDecode(game:HttpGet(v59))[1][1][1]
						end)

						if ok and type(result) == "string" and result ~= "" then
							arcane.TranslationCache[v55] = result
						end

						n2 += 1
					end)
				end
			end

			local v60 = os.clock() + 8

			while n2 < n1 and os.clock() < v60 do
				task.wait(0.05)
			end

			if arcane.LanguageToken ~= LanguageToken then
				return
			end

			for _, v in arcane.TextRegistry, nil, nil do
				arcane:SwapText(v.Label, arcane.Translations[v.English] or arcane.TranslationCache[v46 .. "\1" .. v.English] or v.English, v.Transparency)
			end

			v47()
		end)

		return
	end

	for _, v in arcane.TextRegistry, nil, nil do
		arcane:SwapText(v.Label, v.English, v.Transparency)
	end

	v47()
end
arcane.Animation = {
	Time = 0.25,
	Style = Enum.EasingStyle.Quart,
	Direction = Enum.EasingDirection.Out
}
arcane.Create = function(p18, p19, p20)
	local t4 = {
		Class = p19,
		Properties = p20,
		Instance = Instance.new(p19)
	}

	for k, v in p20, nil, nil do
		if k == "FontFace" then
			t4.Instance.FontFace = arcane.Font
		elseif k == "Name" then
			t4.Instance.Name = "\0"
		else
			t4.Instance[k] = v
		end
	end

	return setmetatable(t4, arcane)
end
arcane.Thread = function(p21, p22)
	local thread = coroutine.create(p22)

	coroutine.resume(thread)
	table.insert(arcane.Threads, thread)

	return thread
end
arcane.Connect = function(p23, p24, p25)
	local connection

	if type(p24) ~= "string" then
		connection = p24:Connect(p25)
		table.insert(arcane.Connections, connection)

		return connection
	end

	if not p23.Instance then
		connection = p24:Connect(p25)
	elseif v12 and (p24 == "MouseButton1Down" or p24 == "MouseButton1Click") then
		if not p23.Instance:IsA("GuiButton") then
			connection = p23.Instance[p24]:Connect(p25)
			table.insert(arcane.Connections, connection)

			return connection
		end

		local n3 = 0

		local function v71(p26)
			local now = os.clock()

			if now - n3 < 0.25 then
				return
			end

			n3 = now
			p25(p26)
		end

		arcane.TouchButtons = arcane.TouchButtons or {}
		table.insert(arcane.TouchButtons, {
			Instance = p23.Instance,
			Fire = v71
		})
		connection = p23.Instance.Activated:Connect(function(inputObject)
			v71(inputObject)
		end)
	else
		connection = p23.Instance[p24]:Connect(p25)
	end

	table.insert(arcane.Connections, connection)

	return connection
end
arcane.SafeCall = function(p27, p28, ...)
	if type(p28) ~= "function" then
		return
	end

	local ok, result = pcall(p28, ...)

	if not ok then
		warn(result)
	end

	return ok, result
end
arcane.Round = function(p29, p30, p31)
	local v75 = 1 / (p31 or 1)

	return math.floor(p30 * v75) / v75
end
arcane.GetScreenScale = function()
	return arcane.UIScale and arcane.UIScale.Instance and arcane.UIScale.Instance.Scale or 1
end

if isfolder and not isfolder(arcane.Directory) then
	makefolder(arcane.Directory)
end

if isfolder and not isfolder(arcane.ConfigFolder) then
	makefolder(arcane.ConfigFolder)
end

arcane.GetConfig = function()
	local t5 = {}

	for k, v in arcane.Flags, nil, nil do
		if typeof(v) == "Color3" then
			t5[k] = {
				__color = v:ToHex()
			}
		else
			t5[k] = v
		end
	end

	local t6 = {}

	for k, v in arcane.Theme, nil, nil do
		if typeof(v) == "Color3" then
			t6[k] = v:ToHex()
		end
	end

	t5.__theme = t6

	return HttpService:JSONEncode(t5)
end
arcane.LoadConfig = function(p32, p33)
	local data = HttpService:JSONDecode(p33)

	for k, v in data, nil, nil do
		local v85 = arcane.SetFlags[k]

		if v85 then
			if type(v) == "table" and v.__color then
				v85(Color3.fromHex(v.__color), v.__alpha)
			else
				v85(v)
			end
		end
	end

	if type(data.__theme) == "table" then
		for k, v in data.__theme, nil, nil do
			local ok, result = pcall(Color3.fromHex, v)

			if ok then
				arcane.Theme[k] = result
			end
		end

		arcane:ApplyTheme()
	elseif type(data.__theme) == "string" then
		arcane:SetTheme(data.__theme)
	end
end
arcane.GetConfigsList = function(p34, p35)
	local t7 = {}

	for _, v in listfiles(arcane.ConfigFolder) do
		if v:sub(-5) == ".json" then
			local match = v:match("([^/\\]+)%.json$")

			if match then
				table.insert(t7, match)
			end
		end
	end

	if p35 then
		p35:Refresh(t7)
	end

	return t7
end
arcane.Tween = function(p36, p37, p38, p39)
	local tween = TweenService:Create(p39 or p36.Instance, p38 or TweenInfo.new(arcane.Animation.Time, arcane.Animation.Style, arcane.Animation.Direction), p37)

	tween:Play()

	return tween
end
arcane.GetTweenProperty = function(p40, p41)
	local Instance_ = p41 or p40.Instance

	if Instance_:IsA("Frame") then
		return { "BackgroundTransparency" }
	end

	if Instance_:IsA("TextLabel") or Instance_:IsA("TextButton") then
		return {
			"TextTransparency",
			"BackgroundTransparency"
		}
	end

	if Instance_:IsA("ImageLabel") or Instance_:IsA("ImageButton") then
		return {
			"BackgroundTransparency",
			"ImageTransparency"
		}
	end

	if Instance_:IsA("ScrollingFrame") then
		return {
			"BackgroundTransparency",
			"ScrollBarImageTransparency"
		}
	end

	if Instance_:IsA("TextBox") then
		return {
			"TextTransparency",
			"BackgroundTransparency"
		}
	end

	if Instance_:IsA("UIStroke") then
		return { "Transparency" }
	end
end
arcane.RestingValues = setmetatable({}, {
	__mode = "k"
})
arcane.FadeTokens = setmetatable({}, {
	__mode = "k"
})
arcane.CaptureResting = function(p42, p43, p44)
	local v96 = arcane.RestingValues[p43]

	if not v96 then
		v96 = {}
		arcane.RestingValues[p43] = v96
	end

	if v96[p44] == nil then
		v96[p44] = p43[p44]
	end

	return v96[p44]
end
arcane.ReleaseResting = function(p45, p46, p47)
	local v97 = arcane.RestingValues[p46]

	if not v97 then
		return nil
	end

	local v98 = v97[p47]

	v97[p47] = nil

	return v98
end
arcane.Fade = function(p48, p49, p50, p51)
	local Instance_ = p51 or p48.Instance
	local v100 = arcane:CaptureResting(Instance_, p49)

	if not p50 then
		return arcane:Tween({
			[p49] = 1
		}, nil, Instance_)
	end

	Instance_[p49] = 1

	return arcane:Tween({
		[p49] = v100
	}, nil, Instance_)
end
arcane.FadeDescendants = function(p52, p53, p54)
	local Instance_ = p52.Instance

	arcane.FadeTokens[Instance_] = (arcane.FadeTokens[Instance_] or 0) + 1

	local v102 = arcane.FadeTokens[Instance_]

	if p53 then
		Instance_.Visible = true
	end

	local descendants = Instance_:GetDescendants()

	table.insert(descendants, Instance_)

	for _, v in descendants, nil, nil do
		local tweenProperty = arcane:GetTweenProperty(v)

		if tweenProperty then
			for _, v2 in tweenProperty, nil, nil do
				arcane:Fade(v2, p53, v)
			end
		end
	end

	task.delay(arcane.Animation.Time + 0.03, function()
		if arcane.FadeTokens[Instance_] == v102 then
			Instance_.Visible = p53

			for _, v in descendants, nil, nil do
				local tweenProperty = arcane:GetTweenProperty(v)

				if tweenProperty then
					for _, v2 in tweenProperty, nil, nil do
						local v114 = arcane:ReleaseResting(v, v2)

						if v114 ~= nil then
							v[v2] = v114
						end
					end
				end
			end
		end

		if p54 then
			p54()
		end
	end)
end
arcane.ResetFade = function(p55)
	local Instance_ = p55.Instance

	arcane.FadeTokens[Instance_] = (arcane.FadeTokens[Instance_] or 0) + 1

	local descendants = Instance_:GetDescendants()

	table.insert(descendants, Instance_)

	for _, v in descendants, nil, nil do
		local tweenProperty = arcane:GetTweenProperty(v)

		if tweenProperty then
			for _, v2 in tweenProperty, nil, nil do
				local v122 = arcane:ReleaseResting(v, v2)

				if v122 ~= nil then
					v[v2] = v122
				end
			end
		end
	end
end
arcane.AddToTheme = function(p56, p57)
	local Instance_ = p56.Instance
	local t8 = {
		Item = Instance_,
		Properties = p57
	}

	for k, v in p57, nil, nil do
		if type(v) == "string" then
			Instance_[k] = arcane.Theme[v]
		else
			Instance_[k] = v()
		end
	end

	table.insert(arcane.ThemingStuff, t8)
	arcane.ThemeMap[Instance_] = t8

	return p56
end
arcane.ChangeItemTheme = function(p58, p59)
	local Instance_ = p58.Instance

	if not arcane.ThemeMap[Instance_] then
		return
	end

	arcane.ThemeMap[Instance_].Properties = p59
end
arcane.SetTheme = function(p60, p61)
	local v128 = t1[p61]

	if not v128 then
		return
	end

	arcane.CurrentTheme = p61

	if p61 ~= "Light" then
		arcane.PreviousTheme = p61
	end

	for k, v in v128, nil, nil do
		arcane.Theme[k] = v
	end

	v30()

	for _, v in arcane.ThemingStuff, nil, nil do
		for k, v2 in v.Properties, nil, nil do
			if type(v2) == "string" then
				arcane:Tween({
					[k] = arcane.Theme[v2]
				}, nil, v.Item)
			elseif type(v2) == "function" then
				arcane:Tween({
					[k] = v2()
				}, nil, v.Item)
			end
		end
	end
end
arcane.ApplyTheme = function()
	for _, v in arcane.ThemingStuff, nil, nil do
		for k, v2 in v.Properties, nil, nil do
			if type(v2) == "string" then
				arcane:Tween({
					[k] = arcane.Theme[v2]
				}, nil, v.Item)
			elseif type(v2) == "function" then
				arcane:Tween({
					[k] = v2()
				}, nil, v.Item)
			end
		end
	end
end
arcane.ThemeDirty = false
arcane.ApplyThemeInstant = function()
	for _, v in arcane.ThemingStuff, nil, nil do
		for k, v2 in v.Properties, nil, nil do
			if type(v2) == "string" then
				v.Item[k] = arcane.Theme[v2]
			elseif type(v2) == "function" then
				v.Item[k] = v2()
			end
		end
	end
end
arcane.ChangeTheme = function(p62, p63, p64)
	arcane.Theme[p63] = p64
	v30()
	arcane.ThemeDirty = true
end
arcane:Connect(RunService.Heartbeat, function()
	if arcane.ThemeDirty then
		arcane.ThemeDirty = false
		arcane:ApplyThemeInstant()
	end
end)
arcane.OnHover = function(p65, p66, p67)
	local Instance_ = p65.Instance

	arcane:Connect(Instance_.MouseEnter, p66)
	arcane:Connect(Instance_.MouseLeave, p67)
end
arcane.RaisePopup = function(p68, p69, p70, p71)
	arcane.TouchShields = arcane.TouchShields or {}

	if p70 then
		arcane.TouchShields[p69] = p71 or 60
	else
		arcane.TouchShields[p69] = nil
	end

	local descendants = p69:GetDescendants()

	table.insert(descendants, p69)

	for _, v in descendants, nil, nil do
		if v:IsA("GuiObject") then
			v.ZIndex = p70 and (p71 or 60) or 1
		end
	end
end
arcane.MakeDraggable = function(p72, p73)
	local Instance_ = p72.Instance
	local v148 = p73 or Instance_

	v148.Active = true

	local u149 = false
	local Position
	local vector2

	local function v152(p74)
		local screenScale = arcane:GetScreenScale()
		local v154 = (p74.Position - Position) / screenScale
		local v155 = vector2.Y + v154.Y
		local v156 = Instance_.Parent.AbsoluteSize / screenScale
		local v157 = Instance_.AbsoluteSize / screenScale
		local AnchorPoint = Instance_.AnchorPoint
		local v159 = math.clamp(vector2.X + v154.X, v157.X * AnchorPoint.X, v156.X - v157.X * (1 - AnchorPoint.X))
		local v160 = math.clamp(v155, v157.Y * AnchorPoint.Y, v156.Y - v157.Y * (1 - AnchorPoint.Y))

		p72:Tween({
			Position = UDim2.new(0, v159, 0, v160)
		}, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
	end

	local connection

	arcane:Connect(v148.InputBegan, function(p75)
		if p75.UserInputType == Enum.UserInputType.MouseButton1 or p75.UserInputType == Enum.UserInputType.Touch then
			u149 = true
			Position = p75.Position

			local v162 = Instance_.Parent.AbsoluteSize / arcane:GetScreenScale()

			vector2 = Vector2.new(Instance_.Position.X.Scale * v162.X + Instance_.Position.X.Offset, Instance_.Position.Y.Scale * v162.Y + Instance_.Position.Y.Offset)

			if connection then
				return
			end

			connection = p75.Changed:Connect(function()
				if p75.UserInputState == Enum.UserInputState.End then
					u149 = false
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p76)
		if (p76.UserInputType == Enum.UserInputType.MouseMovement or p76.UserInputType == Enum.UserInputType.Touch) and u149 then
			v152(p76)
		end
	end)
end
arcane.IsMouseOverFrame = function(p77)
	local Instance_ = p77.Instance
	local vector2 = Vector2.new(mouse.X, mouse.Y)

	return vector2.X >= Instance_.AbsolutePosition.X and vector2.X <= Instance_.AbsolutePosition.X + Instance_.AbsoluteSize.X and vector2.Y >= Instance_.AbsolutePosition.Y and vector2.Y <= Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y
end
arcane.Unload = function()
	for _, v in arcane.Connections, nil, nil do
		v:Disconnect()
	end

	for _, v in arcane.Threads, nil, nil do
		pcall(coroutine.close, v)
	end

	if arcane.Holder then
		arcane.Holder.Instance:Destroy()
	end

	if arcane.UnusedHolder then
		arcane.UnusedHolder.Instance:Destroy()
	end

	getgenv().Arcane = nil
end

local t9 = {
	New = function(p78, p79, p80, p81, p82)
		if not isfile(p79 .. ".ttf") then
			writefile(p79 .. ".ttf", game:HttpGet(p82.Url))
		end

		local t10 = {
			name = p79,
			faces = { {
				name = "Regular",
				weight = p80,
				style = p81,
				assetId = getcustomasset(p79 .. ".ttf")
			} }
		}

		if not isfile(p79 .. ".font") then
			writefile(p79 .. ".font", HttpService:JSONEncode(t10))
		end

		return Font.new(getcustomasset(p79 .. ".font"))
	end
}
local ok, result = pcall(function()
	return t9:New("ArcaneInter", 600, "Normal", {
		Url = "https://github.com/sametexe001/luas/raw/refs/heads/main/fonts/InterSemibold.ttf"
	})
end)

arcane.Font = ok and result or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold)
arcane.Holder = arcane:Create("ScreenGui", {
	Parent = gethui(),
	Name = "\0",
	ZIndexBehavior = Enum.ZIndexBehavior.Global,
	ResetOnSpawn = false,
	IgnoreGuiInset = true
})
arcane.UnusedHolder = arcane:Create("ScreenGui", {
	Parent = gethui(),
	Name = "\0",
	Enabled = false,
	ResetOnSpawn = false
})

local tween = arcane:Create("Frame", {
	Parent = arcane.Holder.Instance,
	Name = "\0",
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(0, 1, 0, 1),
	BorderSizePixel = 0
})

task.defer(function()
	Y = -tween.Instance.AbsolutePosition.Y
	tween.Instance:Destroy()
end)
arcane.NotifHolder = arcane:Create("Frame", {
	Parent = arcane.Holder.Instance,
	Name = "\0",
	AnchorPoint = Vector2.new(1, 0),
	BackgroundTransparency = 1,
	Position = UDim2.new(1, 0, 0, Y),
	Size = UDim2.new(0, 0, 1, 0),
	BorderSizePixel = 0,
	AutomaticSize = Enum.AutomaticSize.X
})
arcane:Create("UIPadding", {
	Parent = arcane.NotifHolder.Instance,
	PaddingTop = UDim.new(0, 15),
	PaddingRight = UDim.new(0, 15)
})
arcane:Create("UIListLayout", {
	Parent = arcane.NotifHolder.Instance,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 10)
})
arcane.UIScale = arcane:Create("UIScale", {
	Parent = arcane.Holder.Instance,
	Scale = 1
})

local Position

arcane:Connect(UserInputService.InputBegan, function(p83)
	if p83.UserInputType == Enum.UserInputType.Touch then
		Position = p83.Position
	end
end)
arcane:Connect(UserInputService.InputEnded, function(p84)
	if not v12 then
		return
	end

	if p84.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	if not Position then
		return
	end

	if not arcane.TouchButtons then
		return
	end

	local v175 = p84.Position - Position

	if math.abs(v175.X) > 12 or math.abs(v175.Y) > 12 then
		return
	end

	local Position2 = p84.Position

	local function v177(p85)
		local AbsolutePosition = p85.AbsolutePosition
		local AbsoluteSize = p85.AbsoluteSize

		return Position2.X >= AbsolutePosition.X and Position2.X <= AbsolutePosition.X + AbsoluteSize.X and Position2.Y >= AbsolutePosition.Y and Position2.Y <= AbsolutePosition.Y + AbsoluteSize.Y
	end
	local function v180(p86)
		if not p86:IsDescendantOf(arcane.Holder.Instance) then
			return false
		end

		local Parent = p86

		while true do
			if not Parent or Parent == arcane.Holder.Instance then
				return true
			end

			if not Parent:IsA("GuiObject") or Parent.Visible then
				Parent = Parent.Parent

				continue
			end

			break
		end

		return false
	end

	local n4 = 0

	if arcane.TouchShields then
		for k, v in arcane.TouchShields, nil, nil do
			if k:IsDescendantOf(arcane.Holder.Instance) and v177(k) then
				n4 = math.max(n4, v)
			end
		end
	end

	local v185

	for _, v in arcane.TouchButtons, nil, nil do
		local Instance_ = v.Instance

		if Instance_ and v180(Instance_) and v177(Instance_) and n4 <= Instance_.ZIndex then
			if v185 then
				if not (v185.Instance.ZIndex < Instance_.ZIndex) and (Instance_.ZIndex ~= v185.Instance.ZIndex or not (Instance_.AbsoluteSize.X * Instance_.AbsoluteSize.Y < v185.Instance.AbsoluteSize.X * v185.Instance.AbsoluteSize.Y)) then
					continue
				end
			end

			v185 = v
		end
	end

	if v185 then
		v185.Fire(p84)
	end
end)

local function v189()
	local scale = 1

	if v12 and workspace.CurrentCamera then
		local ViewportSize = workspace.CurrentCamera.ViewportSize

		scale = math.clamp(math.min(ViewportSize.X * 0.8 / 560, ViewportSize.Y * 0.8 / 555), 0.35, 1)
	end

	arcane.UIScale.Instance.Scale = scale

	for _, v in arcane.Windows, nil, nil do
		if v.Center then
			v:Center()
		end
	end
end

v189()
arcane:Connect(workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"), function()
	task.wait()
	v189()
end)
arcane.KeybindList = {
	Items = {}
}

local KeybindList = arcane.KeybindList

KeybindList.Items.Holder = arcane:Create("Frame", {
	Parent = arcane.Holder.Instance,
	Name = "\0",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 15, 0.5, 0),
	Size = UDim2.new(0, 220, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	Visible = false,
	BorderSizePixel = 0,
	BackgroundColor3 = arcane.Theme.Section
}):AddToTheme({
	BackgroundColor3 = "Section"
})
arcane:Create("UICorner", {
	Parent = KeybindList.Items.Holder.Instance,
	CornerRadius = UDim.new(0, 10)
})
arcane:Create("UIStroke", {
	Parent = KeybindList.Items.Holder.Instance,
	ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	Color = arcane.Theme.Border,
	Transparency = 0.4
}):AddToTheme({
	Color = "Border"
})
arcane:Create("UIPadding", {
	Parent = KeybindList.Items.Holder.Instance,
	PaddingBottom = UDim.new(0, 10)
})
KeybindList.Items.Title = arcane:Create("TextLabel", {
	Parent = KeybindList.Items.Holder.Instance,
	Name = "\0",
	FontFace = arcane.Font,
	TextColor3 = arcane.Theme.Text,
	Text = "Keybinds",
	TextSize = 14,
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 8),
	Size = UDim2.new(1, -24, 0, 18),
	TextXAlignment = Enum.TextXAlignment.Center,
	BorderSizePixel = 0
}):AddToTheme({
	TextColor3 = "Text"
})
KeybindList.Items.Liner = arcane:Create("Frame", {
	Parent = KeybindList.Items.Holder.Instance,
	Name = "\0",
	Position = UDim2.new(0, 12, 0, 30),
	Size = UDim2.new(1, -24, 0, 2),
	BorderSizePixel = 0,
	BackgroundColor3 = arcane.Theme.Accent
}):AddToTheme({
	BackgroundColor3 = "Accent"
})
KeybindList.Items.Content = arcane:Create("Frame", {
	Parent = KeybindList.Items.Holder.Instance,
	Name = "\0",
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0, 38),
	Size = UDim2.new(1, -24, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BorderSizePixel = 0
})
arcane:Create("UIListLayout", {
	Parent = KeybindList.Items.Content.Instance,
	Padding = UDim.new(0, 4),
	SortOrder = Enum.SortOrder.LayoutOrder
})
KeybindList.Items.Holder:MakeDraggable()
task.defer(function()
	local AbsolutePosition = KeybindList.Items.Holder.Instance.AbsolutePosition

	KeybindList.Items.Holder.Instance.AnchorPoint = Vector2.new(0, 0)
	KeybindList.Items.Holder.Instance.Position = UDim2.fromOffset(AbsolutePosition.X, AbsolutePosition.Y + Y)
end)
KeybindList.Add = function(p87, p88)
	local tween2 = arcane:Create("Frame", {
		Parent = KeybindList.Items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		BorderSizePixel = 0
	})
	local v197 = arcane:Create("TextLabel", {
		Parent = tween2.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = p88,
		TextSize = 13,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -110, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	local v198 = arcane:Create("TextLabel", {
		Parent = tween2.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = "[...]",
		TextSize = 13,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -52, 0, 0),
		Size = UDim2.new(0, 52, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	local v199 = arcane:Create("TextLabel", {
		Parent = tween2.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = "Off",
		TextSize = 13,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 48, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})

	arcane:RegisterText(v197.Instance, p88)

	local t11 = {
		Mode = "Toggle",
		Active = false
	}

	local function v201()
		if t11.Active then
			v199.Instance.Text = t11.Mode == "Hold" and "Holding" or "Toggled"
			v197:ChangeItemTheme({
				TextColor3 = "Text"
			})
			v198:ChangeItemTheme({
				TextColor3 = "Accent"
			})
			v199:ChangeItemTheme({
				TextColor3 = "Text"
			})
			v197:Tween({
				TextColor3 = arcane.Theme.Text
			})
			v198:Tween({
				TextColor3 = arcane.Theme.Accent
			})
			v199:Tween({
				TextColor3 = arcane.Theme.Text
			})
		else
			v199.Instance.Text = "Off"
			v197:ChangeItemTheme({
				TextColor3 = "DimText"
			})
			v198:ChangeItemTheme({
				TextColor3 = "DimText"
			})
			v199:ChangeItemTheme({
				TextColor3 = "DimText"
			})
			v197:Tween({
				TextColor3 = arcane.Theme.DimText
			})
			v198:Tween({
				TextColor3 = arcane.Theme.DimText
			})
			v199:Tween({
				TextColor3 = arcane.Theme.DimText
			})
		end
	end

	t11.SetKey = function(p89, p90)
		v198.Instance.Text = "[" .. tostring(p90) .. "]"
	end
	t11.SetMode = function(p91, p92)
		t11.Mode = p92
		v201()
	end
	t11.SetActive = function(p93, p94)
		t11.Active = p94
		v201()
	end
	t11.Remove = function()
		tween2.Instance:Destroy()
	end

	return t11
end
KeybindList.SetVisibility = function(p95, p96)
	KeybindList.Items.Holder:FadeDescendants(p96)
end
arcane.Notification = function(p97, p98)
	local v202 = p98 or {}
	local Name = v202.Name or v202.name or "Notification"
	local Description = v202.Description or v202.description or ""
	local Duration = v202.Duration or v202.duration or 5
	local Icon = v202.Icon or v202.icon
	local Color = v202.Color or v202.color or arcane.Theme.Accent
	local t12 = {
		Notification = arcane:Create("Frame", {
			Parent = arcane.NotifHolder.Instance,
			Name = "\0",
			Size = UDim2.new(0, 0, 0, 73),
			ClipsDescendants = true,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})
	}

	arcane:Create("UICorner", {
		Parent = t12.Notification.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	t12.Stroke = arcane:Create("UIStroke", {
		Parent = t12.Notification.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.4
	}):AddToTheme({
		Color = "Border"
	})

	local n5 = 12

	if Icon then
		t12.Icon = arcane:Create("ImageLabel", {
			Parent = t12.Notification.Instance,
			Name = "\0",
			ImageColor3 = Color,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 13),
			Size = UDim2.new(0, 18, 0, 18),
			BorderSizePixel = 0
		})
		v25(t12.Icon.Instance, Icon)
		n5 = 38
	end

	t12.Title = arcane:Create("TextLabel", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, n5, 0, 12),
		Size = UDim2.new(0, 260 - n5 - 12, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	t12.Description = arcane:Create("TextLabel", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		TextTransparency = 0.35,
		Text = Description,
		TextSize = 13,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 36),
		Size = UDim2.new(0, 150, 0, 15),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	t12.Duration = arcane:Create("TextLabel", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = Duration .. "s",
		TextSize = 13,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 36),
		Size = UDim2.new(0, 60, 0, 15),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	t12.Liner = arcane:Create("Frame", {
		Parent = t12.Notification.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 59),
		Size = UDim2.new(1, -24, 0, 4),
		BorderSizePixel = 0,
		BackgroundColor3 = Color
	})
	arcane:Create("UICorner", {
		Parent = t12.Liner.Instance,
		CornerRadius = UDim.new(1, 0)
	})

	local t13 = {}

	for _, v in t12, nil, nil do
		local Instance_ = v.Instance

		if Instance_:IsA("ImageLabel") then
			table.insert(t13, {
				Object = v,
				Property = "ImageTransparency",
				Original = Instance_.ImageTransparency
			})
		elseif Instance_:IsA("TextLabel") then
			table.insert(t13, {
				Object = v,
				Property = "TextTransparency",
				Original = Instance_.TextTransparency
			})
		elseif Instance_:IsA("Frame") then
			table.insert(t13, {
				Object = v,
				Property = "BackgroundTransparency",
				Original = Instance_.BackgroundTransparency
			})
		elseif Instance_:IsA("UIStroke") then
			table.insert(t13, {
				Object = v,
				Property = "Transparency",
				Original = Instance_.Transparency
			})
		end
	end

	for _, v in t13, nil, nil do
		v.Object.Instance[v.Property] = 1
	end

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)
	local u217 = true

	arcane:Thread(function()
		t12.Notification:Tween({
			Size = UDim2.new(0, 260, 0, 73)
		}, tweenInfo)

		for _, v in t13, nil, nil do
			v.Object:Tween({
				[v.Property] = v.Original
			}, tweenInfo)
		end

		t12.Liner:Tween({
			Size = UDim2.new(0, 0, 0, 4)
		}, TweenInfo.new(Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out))
		task.spawn(function()
			local v220 = Duration

			while u217 and v220 > 0 do
				task.wait(0.1)
				v220 = math.max(v220 - 0.1, 0)

				if t12.Duration.Instance.Parent then
					t12.Duration.Instance.Text = arcane:Round(v220, 0.1) .. "s"
				end
			end
		end)
		task.delay(Duration + 0.1, function()
			u217 = false

			for _, v in t13, nil, nil do
				v.Object:Tween({
					[v.Property] = 1
				}, tweenInfo)
			end

			t12.Notification:Tween({
				Size = UDim2.new(0, 0, 0, 0)
			}, tweenInfo)
			task.wait(0.5)
			t12.Notification.Instance:Destroy()
		end)
	end)
end
arcane.Tooltip = function(p99, p100)
	local Instance_ = p99.Instance

	if not Instance_ or p100 == nil or p100 == "" then
		return
	end

	local t14 = {
		Tooltip = arcane:Create("Frame", {
			Parent = arcane.Holder.Instance,
			Name = "\0",
			ClipsDescendants = true,
			Size = UDim2.new(0, 0, 0, 30),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 999,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})
	}

	arcane:Create("UICorner", {
		Parent = t14.Tooltip.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	arcane:Create("UIPadding", {
		Parent = t14.Tooltip.Instance,
		PaddingRight = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12)
	})
	t14.Text = arcane:Create("TextLabel", {
		Parent = t14.Tooltip.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = p100,
		TextSize = 13,
		AnchorPoint = Vector2.new(0, 0.5),
		Size = UDim2.new(0, 0, 0, 15),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 4, 0.5, 0),
		ZIndex = 999,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X
	}):AddToTheme({
		TextColor3 = "Text"
	})
	t14.Liner = arcane:Create("Frame", {
		Parent = t14.Tooltip.Instance,
		Name = "\0",
		Position = UDim2.new(0, -12, 0, 0),
		Size = UDim2.new(0, 4, 1, 0),
		ZIndex = 999,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Accent
	}):AddToTheme({
		BackgroundColor3 = "Accent"
	})

	local function v225(p101)
		for _, v in t14, nil, nil do
			if v.Instance:IsA("Frame") then
				v:Tween({
					BackgroundTransparency = p101 and 0 or 1
				})
			elseif v.Instance:IsA("TextLabel") then
				v:Tween({
					TextTransparency = p101 and 0 or 1
				})
			end
		end
	end

	v225(false)

	if not v12 then
		local connection

		p99:OnHover(function()
			local mouseLocation = UserInputService:GetMouseLocation()

			t14.Tooltip.Instance.Position = UDim2.new(0, mouseLocation.X + 18, 0, mouseLocation.Y + 12)
			v225(true)
			connection = RunService.RenderStepped:Connect(function()
				mouseLocation = UserInputService:GetMouseLocation()
				t14.Tooltip.Instance.Position = UDim2.new(0, mouseLocation.X + 18, 0, mouseLocation.Y + 12)
			end)
		end, function()
			v225(false)

			if connection then
				connection:Disconnect()
				connection = nil
			end
		end)

		return
	end

	if not Instance_:IsA("GuiButton") then
		return
	end

	local u230 = false

	p99:Connect("MouseButton1Click", function()
		u230 = not u230

		if u230 then
			local screenScale = arcane:GetScreenScale()

			t14.Tooltip.Instance.Position = UDim2.fromOffset(Instance_.AbsolutePosition.X / screenScale, (Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y + Y + 6) / screenScale)
			v225(true)
		else
			v225(false)
		end
	end)
end
arcane.Window = function(p102, p103)
	local v232 = p103 or {}
	local t15 = {
		Name = v232.Name or v232.name or "ARCANE",
		User = v232.User or v232.user or LocalPlayer.Name,
		Logo = v232.Logo or v232.logo or "72939878637463",
		IsOpen = true,
		Pages = {},
		Items = {}
	}
	local screenScale = arcane:GetScreenScale()
	local ViewportSize = workspace.CurrentCamera.ViewportSize
	local items = {
		MainFrame = arcane:Create("Frame", {
			Parent = arcane.Holder.Instance,
			Name = "\0",
			AnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(ViewportSize.X / (2 * screenScale) - 280, ViewportSize.Y / (2 * screenScale) - 278),
			Size = UDim2.new(0, 560, 0, 570),
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Background
		}):AddToTheme({
			BackgroundColor3 = "Background"
		})
	}

	arcane:Create("UICorner", {
		Parent = items.MainFrame.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	items.TopBar = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		Size = UDim2.new(1, 0, 0, 37),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.TopBar.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("Frame", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 10),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	items.MainFrame:MakeDraggable(v12 and items.TopBar.Instance or nil)
	items.Logo = arcane:Create("ImageLabel", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(0, 27, 0, 20),
		BorderSizePixel = 0
	})
	v25(items.Logo.Instance, t15.Logo)
	items.HubName = arcane:Create("TextLabel", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Accent,
		Text = t15.Name,
		TextSize = 16,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 46, 0, 0),
		Size = UDim2.new(0, 200, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Accent"
	})
	items.User = arcane:Create("TextLabel", {
		Parent = items.TopBar.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t15.User,
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.new(0, 157, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	items.Line = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		Position = UDim2.new(0, 0, 0, 36),
		Size = UDim2.new(1, 0, 0, 2),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Divider
	}):AddToTheme({
		BackgroundColor3 = "Divider"
	})
	items.ThemeHolder = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 0, 53),
		Size = UDim2.new(0, 108, 0, 46),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.ThemeHolder.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIListLayout", {
		Parent = items.ThemeHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local t16 = {}

	local function v238(p104, p105)
		local v239 = arcane:Create("TextButton", {
			Parent = items.ThemeHolder.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 46, 0, 38),
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Selected
		}):AddToTheme({
			BackgroundColor3 = "Selected"
		})

		arcane:Create("UICorner", {
			Parent = v239.Instance,
			CornerRadius = UDim.new(0, 8)
		})

		local v240 = arcane:Create("ImageLabel", {
			Parent = v239.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.DimIcon,
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "DimIcon"
		})

		v25(v240.Instance, p104)

		local t17 = {
			Button = v239,
			Icon = v240,
			Theme = p105,
			Set = function(p106, p107)
				if p107 then
					v239:ChangeItemTheme({
						BackgroundColor3 = "Selected"
					})
					v240:ChangeItemTheme({
						ImageColor3 = "Accent"
					})
					v239:Tween({
						BackgroundTransparency = 0,
						BackgroundColor3 = arcane.Theme.Selected
					})
					v240:Tween({
						ImageColor3 = arcane.Theme.Accent
					})
				else
					v240:ChangeItemTheme({
						ImageColor3 = "DimIcon"
					})
					v239:Tween({
						BackgroundTransparency = 1
					})
					v240:Tween({
						ImageColor3 = arcane.Theme.DimIcon
					})
				end
			end
		}

		v239:Connect("MouseButton1Down", function()
			if p105 == "Light" then
				arcane:SetTheme("Light")
			else
				arcane:SetTheme(arcane.PreviousTheme or "Dark")
			end

			local v242 = arcane.CurrentTheme == "Light"

			for _, v in t16, nil, nil do
				v:Set(v.Theme == "Light" == v242)
			end
		end)
		table.insert(t16, t17)

		return t17
	end

	v238("moon", "Dark"):Set(true)
	v238("sun", "Light"):Set(false)
	items.CornerHolder = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -15, 1, -62),
		Size = UDim2.new(0, 0, 0, 46),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		ZIndex = 3,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.CornerHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 8),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local function v245(p108)
		local v246 = arcane:Create("Frame", {
			Parent = items.CornerHolder.Instance,
			Name = "\0",
			Size = UDim2.new(0, 0, 0, 46),
			AutomaticSize = Enum.AutomaticSize.X,
			LayoutOrder = p108,
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Topbar
		}):AddToTheme({
			BackgroundColor3 = "Topbar"
		})

		arcane:Create("UICorner", {
			Parent = v246.Instance,
			CornerRadius = UDim.new(0, 10)
		})
		arcane:Create("UIPadding", {
			Parent = v246.Instance,
			PaddingLeft = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 4)
		})
		arcane:Create("UIListLayout", {
			Parent = v246.Instance,
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		return v246
	end

	items.SettingsHolder = v245(1)
	items.LanguageHolder = v245(2)
	items.UISettingsButton = arcane:Create("TextButton", {
		Parent = items.SettingsHolder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 46, 0, 38),
		ZIndex = 3,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Selected
	}):AddToTheme({
		BackgroundColor3 = "Selected"
	})
	arcane:Create("UICorner", {
		Parent = items.UISettingsButton.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	items.UISettingsIcon = arcane:Create("ImageLabel", {
		Parent = items.UISettingsButton.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimIcon,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimIcon"
	})
	v25(items.UISettingsIcon.Instance, "10734950309")

	local t18 = {}

	local function v248(p109)
		local v249 = arcane:Create("TextButton", {
			Parent = items.LanguageHolder.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 46, 0, 38),
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Selected
		}):AddToTheme({
			BackgroundColor3 = "Selected"
		})

		arcane:Create("UICorner", {
			Parent = v249.Instance,
			CornerRadius = UDim.new(0, 8)
		})

		local v250 = arcane:Create("TextLabel", {
			Parent = v249.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p109,
			TextSize = 13,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})
		local t19 = {
			Button = v249,
			Label = v250,
			Language = p109,
			Set = function(p110, p111)
				if p111 then
					v250:ChangeItemTheme({
						TextColor3 = "Accent"
					})
					v249:Tween({
						BackgroundTransparency = 0
					})
					v250:Tween({
						TextColor3 = arcane.Theme.Accent
					})
				else
					v250:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v249:Tween({
						BackgroundTransparency = 1
					})
					v250:Tween({
						TextColor3 = arcane.Theme.DimText
					})
				end
			end
		}

		v249:Connect("MouseButton1Down", function()
			for _, v in t18, nil, nil do
				v:Set(v.Language == p109)
			end

			local UIPanelState = t15.UIPanelState

			if UIPanelState and (UIPanelState.IsOpen or UIPanelState.Debounce) then
				task.delay(arcane.Animation.Time + 0.1, function()
					arcane:SetLanguage(p109)
				end)
			else
				arcane:SetLanguage(p109)
			end
		end)
		table.insert(t18, t19)

		return t19
	end

	v248("ENG"):Set(true)
	v248("RUS"):Set(false)
	items.UIPanel = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 1),
		Visible = false,
		Size = UDim2.new(0, 230, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 60,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Section
	}):AddToTheme({
		BackgroundColor3 = "Section"
	})
	arcane:Create("UICorner", {
		Parent = items.UIPanel.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIStroke", {
		Parent = items.UIPanel.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.4
	}):AddToTheme({
		Color = "Border"
	})
	arcane:Create("UIPadding", {
		Parent = items.UIPanel.Instance,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6)
	})
	items.UIPanelContent = arcane:Create("Frame", {
		Parent = items.UIPanel.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.UIPanelContent.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	local t20 = {
		Items = {
			Content = items.UIPanelContent
		},
		LastDivider = nil
	}
	local isPopup = {
		IsOpen = false,
		Debounce = false
	}

	isPopup.IsPopup = isPopup
	t20.IsPopup = isPopup
	t15.UIPanelState = isPopup
	task.defer(function()
		arcane.Dropdown(t20, {
			Name = "Language",
			Items = {
				"ENG",
				"RUS",
				"SPA",
				"BRA",
				"PHL",
				"FRA",
				"GER",
				"TUR"
			},
			Default = "ENG",
			Callback = function(p112)
				if type(p112) ~= "string" or p112 == arcane.Language then
					return
				end

				arcane:SetLanguage(p112)

				for _, v in t18, nil, nil do
					v:Set(v.Language == p112)
				end
			end
		})
		arcane.Toggle(t20, {
			Name = "Hide Username",
			Callback = function(p113)
				local Instance_ = items.User.Instance
				local v260 = p113

				Instance_.Text = v260 and "Username" or t15.User
			end
		})
		arcane.Toggle(t20, {
			Name = "Keybind List",
			Callback = function(p114)
				arcane.KeybindList:SetVisibility(p114)
			end
		})
		arcane.Toggle(t20, {
			Name = "Show Watermark",
			Default = true,
			Callback = function(p115)
				if t15.Items.Watermark then
					t15.Items.Watermark.Holder:FadeDescendants(p115)
				end
			end
		})
	end)
	isPopup.SetOpen = function(p116, p117)
		if isPopup.Debounce then
			return
		end

		isPopup.IsOpen = p117
		isPopup.Debounce = true

		local screenScale2 = arcane:GetScreenScale()
		local Instance_ = items.UISettingsButton.Instance
		local v263 = (Instance_.AbsolutePosition.X + Instance_.AbsoluteSize.X) / screenScale2
		local v264 = (Instance_.AbsolutePosition.Y - 8 + Y) / screenScale2

		if p117 then
			items.UISettingsButton:Tween({
				BackgroundTransparency = 0
			})
			items.UISettingsIcon:ChangeItemTheme({
				ImageColor3 = "Accent"
			})
			items.UISettingsIcon:Tween({
				ImageColor3 = arcane.Theme.Accent
			})
			items.UIPanel.Instance.Parent = arcane.Holder.Instance
			items.UIPanel.Instance.Position = UDim2.fromOffset(v263, v264 + 10)
			items.UIPanel.Instance.Visible = true
			arcane:RaisePopup(items.UIPanel.Instance, true)
			items.UIPanel:Tween({
				Position = UDim2.fromOffset(v263, v264)
			})

			for _, v in arcane.OpenFrames, nil, nil do
				if v ~= isPopup then
					v:SetOpen(false)
				end
			end

			arcane.OpenFrames[isPopup] = isPopup
			items.UIPanel:FadeDescendants(true, function()
				isPopup.Debounce = false
			end)
		else
			items.UISettingsButton:Tween({
				BackgroundTransparency = 1
			})
			items.UISettingsIcon:ChangeItemTheme({
				ImageColor3 = "DimIcon"
			})
			items.UISettingsIcon:Tween({
				ImageColor3 = arcane.Theme.DimIcon
			})
			arcane.OpenFrames[isPopup] = nil

			for _, v in arcane.OpenFrames, nil, nil do
				if v.Host == isPopup then
					v:SetOpen(false)
				end
			end

			items.UIPanel:Tween({
				Position = UDim2.fromOffset(v263, v264 + 10)
			})
			items.UIPanel:FadeDescendants(false, function()
				isPopup.Debounce = false
				items.UIPanel.Instance.Parent = arcane.UnusedHolder.Instance
				arcane:RaisePopup(items.UIPanel.Instance, false)
			end)
		end
	end
	items.UISettingsButton:Connect("MouseButton1Down", function()
		isPopup:SetOpen(not isPopup.IsOpen)
	end)
	arcane:Connect(UserInputService.InputBegan, function(p118)
		if (p118.UserInputType == Enum.UserInputType.MouseButton1 or p118.UserInputType == Enum.UserInputType.Touch) and isPopup.IsOpen then
			if not items.UIPanel:IsMouseOverFrame() then
				if not items.UISettingsButton:IsMouseOverFrame() then
					for _, v in arcane.OpenFrames, nil, nil do
						if v == isPopup then
							continue
						end

						return
					end

					isPopup:SetOpen(false)
				end
			end
		end
	end)
	items.PagesHolder = arcane:Create("Frame", {
		Parent = items.MainFrame.Instance,
		Name = "\0",
		Position = UDim2.new(0, 15, 1, -62),
		Size = UDim2.new(0, 0, 0, 46),
		ZIndex = 3,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.PagesHolder.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIPadding", {
		Parent = items.PagesHolder.Instance,
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4)
	})
	arcane:Create("UIListLayout", {
		Parent = items.PagesHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	t15.Items = items
	arcane:Connect(UserInputService.InputBegan, function(p119, p120)
		if p120 then
			return
		end

		if tostring(p119.KeyCode) == arcane.MenuKeybind then
			t15:SetOpen(not t15.IsOpen)
		end
	end)
	t15.SetOpen = function(p121, p122)
		t15.IsOpen = p122

		if not p122 then
			for _, v in arcane.OpenFrames, nil, nil do
				if v.SetOpen then
					v:SetOpen(false)
				end
			end
		end

		items.MainFrame:FadeDescendants(p122)

		if items.MobileText then
			items.MobileText.Instance.Text = p122 and "Close" or "Open"
		end
	end
	t15.Center = function()
		local screenScale2 = arcane:GetScreenScale()
		local ViewportSize2 = workspace.CurrentCamera.ViewportSize

		items.MainFrame.Instance.Position = UDim2.fromOffset(ViewportSize2.X / (2 * screenScale2) - 280, ViewportSize2.Y / (2 * screenScale2) - 278)
	end
	t15.Watermark = function(p123, p124)
		local v275 = p124 or {}
		local Title = v275.Title or v275.title or t15.Name
		local Icon = v275.Icon or v275.icon or t15.Logo
		local watermark = {
			Holder = arcane:Create("Frame", {
				Parent = arcane.Holder.Instance,
				Name = "\0",
				Active = true,
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.new(1, -16, 0, 16),
				Size = UDim2.new(0, 0, 0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BackgroundTransparency = 1,
				BorderSizePixel = 0
			})
		}

		arcane:Create("UIListLayout", {
			Parent = watermark.Holder.Instance,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5)
		})

		local function v279(p125)
			local v280 = arcane:Create("Frame", {
				Parent = watermark.Holder.Instance,
				Name = "\0",
				Size = UDim2.new(0, 0, 0, 34),
				AutomaticSize = Enum.AutomaticSize.X,
				LayoutOrder = p125,
				BorderSizePixel = 0,
				BackgroundColor3 = arcane.Theme.Section
			}):AddToTheme({
				BackgroundColor3 = "Section"
			})

			arcane:Create("UICorner", {
				Parent = v280.Instance,
				CornerRadius = UDim.new(0, 10)
			})
			arcane:Create("UIStroke", {
				Parent = v280.Instance,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Color = arcane.Theme.Border,
				Transparency = 0.4
			}):AddToTheme({
				Color = "Border"
			})
			arcane:Create("UIPadding", {
				Parent = v280.Instance,
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14)
			})
			arcane:Create("UIListLayout", {
				Parent = v280.Instance,
				FillDirection = Enum.FillDirection.Horizontal,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 8)
			})

			return v280
		end

		watermark.TitlePill = v279(1)
		watermark.Icon = arcane:Create("ImageLabel", {
			Parent = watermark.TitlePill.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.Accent,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 27, 0, 20),
			LayoutOrder = 1,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "Accent"
		})
		v25(watermark.Icon.Instance, Icon)
		watermark.Title = arcane:Create("TextLabel", {
			Parent = watermark.TitlePill.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = Title,
			TextSize = 15,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			LayoutOrder = 2,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		watermark.FpsPill = v279(2)
		watermark.Fps = arcane:Create("TextLabel", {
			Parent = watermark.FpsPill.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "0 FPS",
			TextSize = 15,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Center,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		watermark.PingPill = v279(3)
		watermark.Ping = arcane:Create("TextLabel", {
			Parent = watermark.PingPill.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "0 ping",
			TextSize = 15,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Center,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		watermark.Holder:MakeDraggable()

		local Stats = game:GetService("Stats")
		local n6 = 0
		local n7 = 0

		arcane:Connect(RunService.RenderStepped, function(p126)
			n6 += 1
			n7 += p126

			if n7 >= 0.5 then
				watermark.Fps.Instance.Text = math.floor(n6 / n7) .. " FPS"
				n6 = 0
				n7 = 0

				local ok2, result2 = pcall(function()
					return math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
				end)

				watermark.Ping.Instance.Text = (ok2 and result2 or 0) .. " ping"
			end
		end)

		local function v286()
			arcane.NotifHolder.Instance.Position = UDim2.new(1, 0, 0, watermark.Holder.Instance.Position.Y.Offset + watermark.Holder.Instance.AbsoluteSize.Y / arcane:GetScreenScale())
		end

		arcane:Connect(watermark.Holder.Instance:GetPropertyChangedSignal("AbsoluteSize"), v286)
		task.defer(v286)
		t15.Items.Watermark = watermark

		return watermark
	end
	table.insert(arcane.Windows, t15)

	if v12 then
		items.MobileToggle = arcane:Create("TextButton", {
			Parent = arcane.Holder.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 10),
			Size = UDim2.new(0, 0, 0, 40),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = 60,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Topbar
		}):AddToTheme({
			BackgroundColor3 = "Topbar"
		})
		arcane:Create("UICorner", {
			Parent = items.MobileToggle.Instance,
			CornerRadius = UDim.new(0, 10)
		})
		arcane:Create("UIStroke", {
			Parent = items.MobileToggle.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = arcane.Theme.Border,
			Transparency = 0.4
		}):AddToTheme({
			Color = "Border"
		})
		arcane:Create("UIPadding", {
			Parent = items.MobileToggle.Instance,
			PaddingLeft = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 14)
		})
		v25(arcane:Create("ImageLabel", {
			Parent = items.MobileToggle.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 22, 0, 22),
			ZIndex = 60,
			BorderSizePixel = 0
		}).Instance, t15.Logo)
		items.MobileText = arcane:Create("TextLabel", {
			Parent = items.MobileToggle.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "Close",
			TextSize = 15,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 30, 0.5, 0),
			Size = UDim2.new(0, 0, 1, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 60,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		})
		items.MobileToggle:Connect("MouseButton1Down", function()
			t15:SetOpen(not t15.IsOpen)
		end)
	end

	return setmetatable(t15, arcane)
end

local function v287(p127, p128, p129)
	local t21 = {
		Button = arcane:Create("TextButton", {
			Parent = p127,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 42, 0, 38),
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Selected
		}):AddToTheme({
			BackgroundColor3 = "Selected"
		})
	}

	arcane:Create("UICorner", {
		Parent = t21.Button.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	t21.Icon = arcane:Create("ImageLabel", {
		Parent = t21.Button.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimIcon,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimIcon"
	})
	v25(t21.Icon.Instance, p129)
	t21.Text = arcane:Create("TextLabel", {
		Parent = t21.Button.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = p128,
		TextSize = 14,
		Visible = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 38, 0, 0),
		Size = UDim2.new(0, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(t21.Text.Instance, p128)
	t21.Width = function()
		return t21.Text.Instance.TextBounds.X + (v12 and 64 or 50)
	end
	arcane:Connect(t21.Text.Instance:GetPropertyChangedSignal("TextBounds"), function()
		if t21.IsActive and t21.IsActive() then
			t21.Button:Tween({
				Size = UDim2.new(0, t21.Width(), 0, 38)
			})
		end
	end)

	return t21
end

arcane.Page = function(p130, p131)
	local v289 = p131 or {}
	local t22 = {
		Name = v289.Name or v289.name or "Page",
		Icon = v289.Icon or v289.icon or "swords",
		Window = p130,
		SubPages = {},
		Active = false,
		Debounce = false,
		Items = {}
	}
	local v292 = v287(t22.Window.Items.PagesHolder.Instance, t22.Name, t22.Icon)
	local items = {
		Tab = v292.Button,
		Icon = v292.Icon,
		Text = v292.Text
	}

	v292.IsActive = function()
		return t22.Active
	end
	items.Content = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		BorderSizePixel = 0
	})
	items.SubPagesHolder = arcane:Create("Frame", {
		Parent = items.Content.Instance,
		Name = "\0",
		Position = UDim2.new(0, 15, 0, 53),
		Size = UDim2.new(0, 0, 0, 46),
		ZIndex = 2,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = arcane.Theme.Topbar
	}):AddToTheme({
		BackgroundColor3 = "Topbar"
	})
	arcane:Create("UICorner", {
		Parent = items.SubPagesHolder.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	arcane:Create("UIPadding", {
		Parent = items.SubPagesHolder.Instance,
		PaddingRight = UDim.new(0, 4),
		PaddingLeft = UDim.new(0, 4)
	})
	arcane:Create("UIListLayout", {
		Parent = items.SubPagesHolder.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	items.Columns = arcane:Create("Frame", {
		Parent = items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 15, 0, 112),
		Size = UDim2.new(1, -30, 1, -186),
		BorderSizePixel = 0
	})
	t22.Items = items
	items.Tab:OnHover(function()
		if t22.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.Text
		})
	end, function()
		if t22.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.DimIcon
		})
	end)
	t22.Switch = function(p132, p133)
		t22.Active = p133
		items.Content.Instance.Parent = p133 and t22.Window.Items.MainFrame.Instance or arcane.UnusedHolder.Instance
		items.Content:ResetFade()
		items.Content.Instance.Visible = p133

		if p133 then
			items.Text.Instance.Visible = true
			items.Tab:ChangeItemTheme({
				BackgroundColor3 = "Selected"
			})
			items.Icon:ChangeItemTheme({
				ImageColor3 = "Accent"
			})
			items.Tab:Tween({
				BackgroundTransparency = 0,
				Size = UDim2.new(0, v292.Width(), 0, 38)
			})
			task.delay(0.1, function()
				if t22.Active then
					items.Tab:Tween({
						Size = UDim2.new(0, v292.Width(), 0, 38)
					})
				end
			end)
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.Accent
			})
			items.Content.Instance.Position = UDim2.new(0, 0, 0, 14)
			items.Content:Tween({
				Position = UDim2.new(0, 0, 0, 0)
			})
			items.SubPagesHolder:FadeDescendants(true)

			for _, v in t22.SubPages, nil, nil do
				if v.Active then
					for _, v2 in v.Sections, nil, nil do
						if v2.Appear then
							v2:Appear()
						end
					end
				end
			end
		else
			items.Text.Instance.Visible = false
			items.Icon:ChangeItemTheme({
				ImageColor3 = "DimIcon"
			})
			items.Tab:Tween({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 42, 0, 38)
			})
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.DimIcon
			})
		end
	end
	items.Tab:Connect("MouseButton1Down", function()
		for _, v in arcane.OpenFrames, nil, nil do
			v:SetOpen(false)
		end

		for _, v in t22.Window.Pages, nil, nil do
			v:Switch(v == t22)
		end
	end)

	if #t22.Window.Pages == 0 then
		t22:Switch(true)
	end

	table.insert(t22.Window.Pages, t22)

	return setmetatable(t22, arcane)
end
arcane.SubPage = function(p134, p135)
	local v301 = p135 or {}
	local t23 = {
		Name = v301.Name or v301.name or "SubPage"
	}
	local Icon = v301.Icon or v301.icon

	t23.Icon = Icon or "house"
	t23.Window = p134.Window
	t23.Page = p134
	t23.OneColumn = v301.OneColumn or v301.onecolumn or false
	t23.Active = false
	t23.Debounce = false
	t23.ColumnsData = {}
	t23.Sections = {}
	t23.Items = {}

	local v305 = v287(t23.Page.Items.SubPagesHolder.Instance, t23.Name, t23.Icon)
	local items = {
		Tab = v305.Button,
		Icon = v305.Icon,
		Text = v305.Text
	}

	v305.IsActive = function()
		return t23.Active
	end

	if #t23.Page.SubPages == 0 then
		items.Icon.Instance.Position = UDim2.new(0, 8, 0.5, 0)
		items.Text.Instance.Position = UDim2.new(0, 34, 0, 0)
	end

	items.Content = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		BorderSizePixel = 0
	})
	items.Left = arcane:Create("ScrollingFrame", {
		Parent = items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.5, -8, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.Left.Instance,
		Padding = UDim.new(0, 14),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	items.Right = arcane:Create("ScrollingFrame", {
		Parent = items.Content.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		ScrollBarImageTransparency = 1,
		ScrollBarThickness = 0,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0.5, -8, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.Right.Instance,
		Padding = UDim.new(0, 14),
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	if t23.OneColumn then
		items.Left.Instance.Size = UDim2.new(1, 0, 1, 0)
		items.Right.Instance.Visible = false
		t23.ColumnsData[1] = items.Left
		t23.ColumnsData[2] = items.Left
	else
		t23.ColumnsData[1] = items.Left
		t23.ColumnsData[2] = items.Right
	end

	t23.Items = items
	items.Tab:OnHover(function()
		if t23.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.Text
		})
	end, function()
		if t23.Active then
			return
		end

		items.Icon:Tween({
			ImageColor3 = arcane.Theme.DimIcon
		})
	end)
	t23.Switch = function(p136, p137)
		t23.Active = p137

		local Instance_ = items.Content.Instance
		local v307 = p137

		Instance_.Parent = v307 and t23.Page.Items.Columns.Instance or arcane.UnusedHolder.Instance
		items.Content:ResetFade()
		items.Content.Instance.Visible = p137

		if p137 then
			items.Text.Instance.Visible = true
			items.Tab:ChangeItemTheme({
				BackgroundColor3 = "Selected"
			})
			items.Icon:ChangeItemTheme({
				ImageColor3 = "Accent"
			})
			items.Tab:Tween({
				BackgroundTransparency = 0,
				Size = UDim2.new(0, v305.Width(), 0, 38)
			})
			task.delay(0.1, function()
				if t23.Active then
					items.Tab:Tween({
						Size = UDim2.new(0, v305.Width(), 0, 38)
					})
				end
			end)
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.Accent
			})
			items.Content.Instance.Position = UDim2.new(0, 0, 0, 14)
			items.Content:Tween({
				Position = UDim2.new(0, 0, 0, 0)
			})

			for _, v in t23.Sections, nil, nil do
				if v.Appear then
					v:Appear()
				end
			end
		else
			items.Text.Instance.Visible = false
			items.Icon:ChangeItemTheme({
				ImageColor3 = "DimIcon"
			})
			items.Tab:Tween({
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 42, 0, 38)
			})
			items.Icon:Tween({
				ImageColor3 = arcane.Theme.DimIcon
			})
		end
	end
	items.Tab:Connect("MouseButton1Down", function()
		for _, v in arcane.OpenFrames, nil, nil do
			v:SetOpen(false)
		end

		for _, v in t23.Page.SubPages, nil, nil do
			v:Switch(v == t23)
		end
	end)

	if #t23.Page.SubPages == 0 then
		t23:Switch(true)
	end

	table.insert(t23.Page.SubPages, t23)

	return setmetatable(t23, arcane)
end
arcane.Section = function(p138, p139)
	local v314 = p139 or {}
	local t24 = {
		Name = v314.Name or v314.name or "Section",
		Side = v314.Side or v314.side or 1,
		LastDivider = nil,
		Items = {}
	}
	local items = {
		Section = arcane:Create("Frame", {
			Parent = p138.ColumnsData[t24.Side].Instance,
			Name = "\0",
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})
	}

	arcane:Create("UICorner", {
		Parent = items.Section.Instance,
		CornerRadius = UDim.new(0, 10)
	})
	items.Stroke = arcane:Create("UIStroke", {
		Parent = items.Section.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.5
	}):AddToTheme({
		Color = "Border"
	})
	items.Content = arcane:Create("Frame", {
		Parent = items.Section.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y
	})
	arcane:Create("UIListLayout", {
		Parent = items.Content.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	t24.Items = items
	t24.AppearToken = 0
	t24.Appear = function()
		t24.AppearToken += 1

		local AppearToken = t24.AppearToken
		local Instance_ = items.Section.Instance
		local Instance_2 = items.Content.Instance
		local t25 = { {
			Obj = Instance_,
			Prop = "BackgroundTransparency",
			Orig = arcane:CaptureResting(Instance_, "BackgroundTransparency")
		} }

		if items.Stroke then
			table.insert(t25, {
				Obj = items.Stroke.Instance,
				Prop = "Transparency",
				Orig = arcane:CaptureResting(items.Stroke.Instance, "Transparency")
			})
		end

		local t26 = {}

		for _, v in Instance_2:GetDescendants() do
			local tweenProperty = arcane:GetTweenProperty(v)

			if tweenProperty then
				if type(tweenProperty) ~= "table" then
					tweenProperty = { tweenProperty }
				end

				for _, v2 in tweenProperty, nil, nil do
					table.insert(t26, {
						Obj = v,
						Prop = v2,
						Orig = arcane:CaptureResting(v, v2)
					})
				end
			end
		end

		local function v327()
			for _, v in t25, nil, nil do
				v.Obj[v.Prop] = v.Orig
				arcane:ReleaseResting(v.Obj, v.Prop)
			end

			for _, v in t26, nil, nil do
				v.Obj[v.Prop] = v.Orig
				arcane:ReleaseResting(v.Obj, v.Prop)
			end
		end

		for _, v in t25, nil, nil do
			v.Obj[v.Prop] = 1
		end

		for _, v in t26, nil, nil do
			v.Obj[v.Prop] = 1
		end

		task.defer(function()
			RunService.Heartbeat:Wait()

			if t24.AppearToken ~= AppearToken then
				return
			end

			local v336 = Instance_.AbsoluteSize.Y / arcane:GetScreenScale()

			if v336 < 1 then
				v327()

				return
			end

			Instance_.AutomaticSize = Enum.AutomaticSize.None
			Instance_.ClipsDescendants = true
			Instance_.Size = UDim2.new(1, 0, 0, 28)

			for _, v in t25, nil, nil do
				arcane:Tween({
					[v.Prop] = v.Orig
				}, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), v.Obj)
			end

			task.wait(0.16)

			if t24.AppearToken ~= AppearToken then
				return
			end

			arcane:Tween({
				Size = UDim2.new(1, 0, 0, v336)
			}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Instance_)

			for _, v in t26, nil, nil do
				arcane:Tween({
					[v.Prop] = v.Orig
				}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), v.Obj)
			end

			task.wait(0.32)

			if t24.AppearToken ~= AppearToken then
				return
			end

			Instance_.AutomaticSize = Enum.AutomaticSize.Y
			Instance_.ClipsDescendants = false
			v327()
		end)
	end

	if p138.Sections then
		table.insert(p138.Sections, t24)
	end

	return setmetatable(t24, arcane)
end

local function v341(p140, p141)
	if p140.LastDivider then
		p140.LastDivider.Instance.Visible = true
	end

	local v342 = arcane:Create("Frame", {
		Parent = p141,
		Name = "\0",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.new(0.5, 0, 1, 0),
		Size = UDim2.new(1, -24, 0, 1),
		Visible = false,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Divider
	}):AddToTheme({
		BackgroundColor3 = "Divider"
	})

	p140.LastDivider = v342

	return v342
end
local function v343(p142, p143, p144)
	if not p143 or p143 == "" then
		return
	end

	local v344 = arcane:Create("TextButton", {
		Parent = p142.Instance.Parent,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		TextTransparency = 0.25,
		Text = "[ ? ]",
		TextSize = 12,
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, p142.Instance.Size.Y.Scale, p142.Instance.Size.Y.Offset),
		ZIndex = 4,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	local v345 = v12 and 16 or 8

	local function v346()
		if p144 then
			v344.Instance.AnchorPoint = Vector2.new(0, 0.5)
			v344.Instance.Position = UDim2.new(0.5, p142.Instance.TextBounds.X / 2 + v345, 0.5, 0)
		else
			v344.Instance.Position = UDim2.new(0, p142.Instance.Position.X.Offset + p142.Instance.TextBounds.X + v345, p142.Instance.Position.Y.Scale, p142.Instance.Position.Y.Offset)
		end
	end

	v346()
	arcane:Connect(p142.Instance:GetPropertyChangedSignal("TextBounds"), v346)
	v344:Tooltip(p143)
end

arcane.Toggle = function(p145, p146)
	local v347 = p146 or {}
	local t27 = {
		Name = v347.Name or v347.name or "Toggle",
		Default = v347.Default or v347.default or false
	}
	local Callback = v347.Callback or v347.callback

	t27.Callback = Callback or function()
	end
	t27.Tooltip = v347.Tooltip or v347.tooltip
	t27.Flag = v347.Flag or v347.flag
	t27.Host = p145.IsPopup
	t27.Value = false
	t27.ListEntry = nil
	t27.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p145.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35),
			BorderSizePixel = 0
		})
	}

	items.Button = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	})
	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = t27.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(items.Name.Instance, t27.Name)
	v343(items.Name, t27.Tooltip)
	items.SubElements = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -48, 0.5, 0),
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.X,
		ZIndex = 3,
		BorderSizePixel = 0
	})
	arcane:Create("UIListLayout", {
		Parent = items.SubElements.Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 6),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	items.Background = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 28, 0, 14),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.ToggleOff
	}):AddToTheme({
		BackgroundColor3 = "ToggleOff"
	})
	arcane:Create("UICorner", {
		Parent = items.Background.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Circle = arcane:Create("Frame", {
		Parent = items.Background.Instance,
		Name = "\0",
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(0, 8, 0, 8),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.ToggleOffCircle
	}):AddToTheme({
		BackgroundColor3 = "ToggleOffCircle"
	})
	arcane:Create("UICorner", {
		Parent = items.Circle.Instance,
		CornerRadius = UDim.new(1, 0)
	})
	v341(p145, items.Holder.Instance)
	t27.Items = items

	local function set(p147, p148)
		t27.Value = p148

		if t27.Flag then
			arcane.Flags[t27.Flag] = p148
		end

		if p148 then
			items.Background:ChangeItemTheme({
				BackgroundColor3 = "ToggleOn"
			})
			items.Circle:ChangeItemTheme({
				BackgroundColor3 = "AccentDark"
			})
			items.Background:Tween({
				BackgroundColor3 = arcane.Theme.ToggleOn
			})
			items.Circle:Tween({
				BackgroundColor3 = arcane.Theme.AccentDark,
				Position = UDim2.new(0, 17, 0, 3)
			})
		else
			items.Background:ChangeItemTheme({
				BackgroundColor3 = "ToggleOff"
			})
			items.Circle:ChangeItemTheme({
				BackgroundColor3 = "ToggleOffCircle"
			})
			items.Background:Tween({
				BackgroundColor3 = arcane.Theme.ToggleOff
			})
			items.Circle:Tween({
				BackgroundColor3 = arcane.Theme.ToggleOffCircle,
				Position = UDim2.new(0, 3, 0, 3)
			})
		end

		if t27.ListEntry then
			t27.ListEntry:SetActive(p148)
		end

		arcane:SafeCall(t27.Callback, p148)
	end

	t27.Set = set
	t27.Get = function()
		return t27.Value
	end
	t27.Keybind = function(p149, p150)
		local v352 = p150 or {}
		local t28 = {
			Key = v352.Default or v352.default,
			Mode = v352.Mode or v352.mode or "Toggle",
			Flag = v352.Flag or v352.flag,
			Host = t27.Host,
			IsOpen = false,
			Debounce = false,
			Picking = false
		}
		local v354 = arcane:Create("ImageButton", {
			Parent = items.SubElements.Instance,
			Name = "\0",
			AutoButtonColor = false,
			ImageColor3 = arcane.Theme.DimText,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 16, 0, 16),
			LayoutOrder = 2,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "DimText"
		})

		v25(v354.Instance, "10734950309")

		local v355 = arcane:Create("Frame", {
			Parent = arcane.UnusedHolder.Instance,
			Name = "\0",
			Visible = false,
			Size = UDim2.new(0, 200, 0, 92),
			ZIndex = 60,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})

		arcane:Create("UICorner", {
			Parent = v355.Instance,
			CornerRadius = UDim.new(0, 8)
		})
		arcane:Create("UIStroke", {
			Parent = v355.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = arcane.Theme.Border,
			Transparency = 0.4
		}):AddToTheme({
			Color = "Border"
		})

		local v356 = arcane:Create("TextButton", {
			Parent = v355.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = "None",
			TextSize = 14,
			AutoButtonColor = false,
			Position = UDim2.new(0, 10, 0, 10),
			Size = UDim2.new(1, -20, 0, 28),
			ZIndex = 61,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Element
		}):AddToTheme({
			BackgroundColor3 = "Element",
			TextColor3 = "Text"
		})

		arcane:Create("UICorner", {
			Parent = v356.Instance,
			CornerRadius = UDim.new(0, 6)
		})

		local tween2 = arcane:Create("Frame", {
			Parent = v355.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 46),
			Size = UDim2.new(1, -20, 0, 28),
			ZIndex = 61,
			BorderSizePixel = 0
		})

		arcane:Create("UIListLayout", {
			Parent = tween2.Instance,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 10),
			SortOrder = Enum.SortOrder.LayoutOrder
		})

		local function v358(p151)
			local v359 = arcane:Create("TextButton", {
				Parent = tween2.Instance,
				Name = "\0",
				FontFace = arcane.Font,
				TextColor3 = arcane.Theme.DimText,
				Text = p151,
				TextSize = 13,
				AutoButtonColor = false,
				BackgroundTransparency = 1,
				Size = UDim2.new(0.5, -5, 1, 0),
				ZIndex = 61,
				BorderSizePixel = 0,
				BackgroundColor3 = arcane.Theme.Selected
			}):AddToTheme({
				BackgroundColor3 = "Selected",
				TextColor3 = "DimText"
			})

			arcane:Create("UICorner", {
				Parent = v359.Instance,
				CornerRadius = UDim.new(0, 6)
			})

			return v359
		end

		local Toggle = v358("Toggle")
		local Hold = v358("Hold")

		t27.ListEntry = arcane.KeybindList:Add(t27.Name)

		local function v362(p152)
			if p152 then
				return tostring(p152):gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
			end

			return "None"
		end
		local function v363()
			if t28.Flag then
				arcane.Flags[t28.Flag] = {
					Key = t28.Key and tostring(t28.Key) or "None",
					Mode = t28.Mode
				}
			end
		end

		t28.SetMode = function(p153, p154)
			t28.Mode = p154

			local v364 = p154 == "Toggle" and Toggle or Hold
			local v365 = p154 == "Toggle" and Hold

			v365 = v365 or Toggle
			v364:ChangeItemTheme({
				BackgroundColor3 = "Selected",
				TextColor3 = "Accent"
			})
			v364:Tween({
				BackgroundTransparency = 0,
				TextColor3 = arcane.Theme.Accent,
				Size = UDim2.new(0.6, -5, 1, 0)
			})
			v365:ChangeItemTheme({
				BackgroundColor3 = "Selected",
				TextColor3 = "DimText"
			})
			v365:Tween({
				BackgroundTransparency = 1,
				TextColor3 = arcane.Theme.DimText,
				Size = UDim2.new(0.4, -5, 1, 0)
			})

			if t27.ListEntry then
				t27.ListEntry:SetMode(p154)
			end

			v363()
		end
		t28.Set = function(p155, p156)
			t28.Key = p156
			v356.Instance.Text = v362(p156)
			t27.ListEntry:SetKey(v362(p156))
			t28.Picking = false
			v363()
		end
		t28.Get = function()
			return t28.Key, t28.Mode
		end

		local function v366(p157)
			local screenScale = arcane:GetScreenScale()
			local Instance_ = v354.Instance

			return UDim2.fromOffset(Instance_.AbsolutePosition.X / screenScale, (Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y + Y + (p157 or 0)) / screenScale)
		end
		local function setOpen(p158, p159)
			if t28.Debounce then
				return
			end

			t28.IsOpen = p159
			t28.Debounce = true

			if p159 then
				v355.Instance.Parent = arcane.Holder.Instance
				v355.Instance.Position = v366(-8)
				v355.Instance.Visible = true
				arcane:RaisePopup(v355.Instance, true, 70)
				v355:Tween({
					Position = v366(2)
				})

				for _, v in arcane.OpenFrames, nil, nil do
					if not (v == t28 or v == t28.Host or v.IsPopup) then
						v:SetOpen(false)
					end
				end

				arcane.OpenFrames[t28] = t28
				v355:FadeDescendants(true, function()
					t28.Debounce = false
				end)
			else
				arcane.OpenFrames[t28] = nil

				local Position2 = v355.Instance.Position

				v355:Tween({
					Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
				})
				v355:FadeDescendants(false, function()
					t28.Debounce = false
					v355.Instance.Parent = arcane.UnusedHolder.Instance
					arcane:RaisePopup(v355.Instance, false)
				end)
			end
		end

		t28.SetOpen = setOpen
		v356:Connect("MouseButton1Click", function()
			if t28.Picking then
				return
			end

			t28.Picking = true
			v356.Instance.Text = ". . ."
			task.wait()

			local connection

			connection = UserInputService.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					return
				end

				connection:Disconnect()

				if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Escape then
					t28:Set(nil)
				elseif input.UserInputType == Enum.UserInputType.Keyboard then
					t28:Set(input.KeyCode)
				else
					t28:Set(input.UserInputType)
				end
			end)
		end)
		Toggle:Connect("MouseButton1Down", function()
			t28:SetMode("Toggle")
		end)
		Hold:Connect("MouseButton1Down", function()
			t28:SetMode("Hold")
		end)
		v354:Connect("MouseButton1Down", function()
			t28:SetOpen(not t28.IsOpen)
		end)
		arcane:Connect(UserInputService.InputBegan, function(p160, p161)
			if (p160.UserInputType == Enum.UserInputType.MouseButton1 or p160.UserInputType == Enum.UserInputType.Touch) and t28.IsOpen and not v355:IsMouseOverFrame() and not v354:IsMouseOverFrame() then
				t28:SetOpen(false)
			end

			if not p161 and not t28.Picking then
				if t28.Key then
					if p160.KeyCode == t28.Key or p160.UserInputType == t28.Key then
						if t28.Mode == "Hold" then
							t27:Set(true)
						else
							t27:Set(not t27.Value)
						end
					end

					return
				end
			end
		end)
		arcane:Connect(UserInputService.InputEnded, function(p162)
			if t28.Mode == "Hold" then
				if t28.Key then
					if p162.KeyCode == t28.Key or p162.UserInputType == t28.Key then
						t27:Set(false)
					end

					return
				end
			end
		end)

		if t28.Flag then
			arcane.SetFlags[t28.Flag] = function(p163)
				if type(p163) ~= "table" then
					return
				end

				if p163.Mode then
					t28:SetMode(p163.Mode)
				end

				local Key = p163.Key

				if type(Key) == "string" then
					if Key == "None" then
						t28:Set(nil)
					else
						local v375 = Key:gsub("Enum.KeyCode.", ""):gsub("Enum.UserInputType.", "")
						local ok2, result2 = pcall(function()
							return Enum.KeyCode[v375]
						end)

						if ok2 and result2 then
							t28:Set(result2)
						else
							local ok3, result3 = pcall(function()
								return Enum.UserInputType[v375]
							end)

							if ok3 and result3 then
								t28:Set(result3)
							end
						end
					end
				end
			end
		end

		t28:SetMode(t28.Mode)
		t28:Set(t28.Key)
		t27.ListEntry:SetActive(t27.Value)

		return t28
	end
	t27.Settings = function(p164, p165)
		local v380 = p165 or {}
		local isPopup = {
			IsOpen = false,
			Debounce = false,
			LastDivider = nil,
			Items = {}
		}

		isPopup.IsPopup = isPopup

		local v382 = arcane:Create("TextButton", {
			Parent = items.SubElements.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = "···",
			TextSize = 17,
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 20, 1, 0),
			LayoutOrder = 1,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})
		local v383 = arcane:Create("Frame", {
			Parent = arcane.UnusedHolder.Instance,
			Name = "\0",
			Visible = false,
			Size = UDim2.new(0, 240, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 60,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Section
		}):AddToTheme({
			BackgroundColor3 = "Section"
		})

		arcane:Create("UICorner", {
			Parent = v383.Instance,
			CornerRadius = UDim.new(0, 10)
		})
		arcane:Create("UIStroke", {
			Parent = v383.Instance,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = arcane.Theme.Border,
			Transparency = 0.4
		}):AddToTheme({
			Color = "Border"
		})
		arcane:Create("UIPadding", {
			Parent = v383.Instance,
			PaddingBottom = UDim.new(0, 8)
		})
		arcane:RegisterText(arcane:Create("TextLabel", {
			Parent = v383.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			Text = t27.Name,
			TextSize = 14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 8),
			Size = UDim2.new(1, 0, 0, 18),
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 60,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text"
		}).Instance, t27.Name)
		arcane:Create("UICorner", {
			Parent = arcane:Create("Frame", {
				Parent = v383.Instance,
				Name = "\0",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = UDim2.new(0.5, 0, 0, 30),
				Size = UDim2.new(1, -24, 0, 2),
				ZIndex = 60,
				BorderSizePixel = 0,
				BackgroundColor3 = arcane.Theme.Accent
			}):AddToTheme({
				BackgroundColor3 = "Accent"
			}).Instance,
			CornerRadius = UDim.new(1, 0)
		})

		local tween2 = arcane:Create("Frame", {
			Parent = v383.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 38),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0
		})

		arcane:Create("UIListLayout", {
			Parent = tween2.Instance,
			SortOrder = Enum.SortOrder.LayoutOrder
		})
		isPopup.Items.Window = v383
		isPopup.Items.Content = tween2

		local function v385(p166)
			local screenScale = arcane:GetScreenScale()
			local Instance_ = v382.Instance

			return UDim2.fromOffset(Instance_.AbsolutePosition.X / screenScale, (Instance_.AbsolutePosition.Y + Instance_.AbsoluteSize.Y + Y + (p166 or 0)) / screenScale)
		end

		isPopup.SetOpen = function(p167, p168)
			if isPopup.Debounce then
				return
			end

			isPopup.IsOpen = p168
			isPopup.Debounce = true

			if p168 then
				v383.Instance.Parent = arcane.Holder.Instance
				v383.Instance.Position = v385(-8)
				v383.Instance.Visible = true
				arcane:RaisePopup(v383.Instance, true)
				v383:Tween({
					Position = v385(2)
				})

				for _, v in arcane.OpenFrames, nil, nil do
					if v ~= isPopup then
						v:SetOpen(false)
					end
				end

				arcane.OpenFrames[isPopup] = isPopup
				v383:FadeDescendants(true, function()
					isPopup.Debounce = false
				end)
			else
				arcane.OpenFrames[isPopup] = nil

				for _, v in arcane.OpenFrames, nil, nil do
					if v.Host == isPopup then
						v:SetOpen(false)
					end
				end

				local Position2 = v383.Instance.Position

				v383:Tween({
					Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
				})
				v383:FadeDescendants(false, function()
					isPopup.Debounce = false
					v383.Instance.Parent = arcane.UnusedHolder.Instance
					arcane:RaisePopup(v383.Instance, false)
				end)
			end
		end
		v382:Connect("MouseButton1Down", function()
			isPopup:SetOpen(not isPopup.IsOpen)
		end)
		arcane:Connect(UserInputService.InputBegan, function(p169)
			if p169.UserInputType == Enum.UserInputType.MouseButton1 or p169.UserInputType == Enum.UserInputType.Touch then
				if isPopup.IsOpen and not v383:IsMouseOverFrame() then
					for _, v in arcane.OpenFrames, nil, nil do
						if v == isPopup then
							continue
						end

						return
					end

					isPopup:SetOpen(false)
				end
			end
		end)

		return setmetatable(isPopup, arcane)
	end
	items.Button:Connect("MouseButton1Down", function()
		t27:Set(not t27.Value)
	end)
	t27:Set(t27.Default)

	if t27.Flag then
		arcane.SetFlags[t27.Flag] = function(p170)
			t27:Set(p170)
		end
	end

	return setmetatable(t27, arcane)
end
arcane.Slider = function(p171, p172)
	local v395 = p172 or {}
	local t29 = {
		Name = v395.Name or v395.name or "Slider",
		Min = v395.Min or v395.min or 0,
		Max = v395.Max or v395.max or 100,
		Default = v395.Default or v395.default or 0
	}
	local Decimals = v395.Decimals or v395.decimals

	t29.Decimals = Decimals or 1
	t29.Suffix = v395.Suffix or v395.suffix or ""
	t29.Callback = v395.Callback or v395.callback or function()
	end
	t29.Tooltip = v395.Tooltip or v395.tooltip
	t29.Flag = v395.Flag or v395.flag
	t29.Value = 0
	t29.Sliding = false
	t29.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p171.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t29.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 4),
		Size = UDim2.new(0.6, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t29.Name)
	v343(items.Name, t29.Tooltip)
	items.Value = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = "",
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4),
		Size = UDim2.new(0.4, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	items.Track = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 14, 0, 32),
		Size = UDim2.new(1, -28, 0, 5),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.SliderBack
	}):AddToTheme({
		BackgroundColor3 = "SliderBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Track.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	items.Fill = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.Accent,
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "Accent"
	})
	arcane:Create("UICorner", {
		Parent = items.Fill.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	arcane:Create("UIGradient", {
		Parent = items.Fill.Instance,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
		})
	})
	items.Drag = arcane:Create("Frame", {
		Parent = items.Fill.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.SliderKnob,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 7, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 8),
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "SliderKnob"
	})
	arcane:Create("UICorner", {
		Parent = items.Drag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	items.Input = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 26),
		Size = UDim2.new(1, -28, 0, 18),
		ZIndex = 3,
		BorderSizePixel = 0
	})
	v341(p171, items.Holder.Instance)
	t29.Items = items
	t29.Set = function(p173, p174)
		t29.Value = arcane:Round(math.clamp(p174, t29.Min, t29.Max), t29.Decimals)

		if t29.Flag then
			arcane.Flags[t29.Flag] = t29.Value
		end

		items.Fill:Tween({
			Size = UDim2.new((t29.Value - t29.Min) / (t29.Max - t29.Min), 0, 1, 0)
		}, TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		items.Value.Instance.Text = tostring(t29.Value) .. t29.Suffix
		arcane:SafeCall(t29.Callback, t29.Value)
	end
	t29.Get = function()
		return t29.Value
	end

	local function v399(p175)
		return t29.Min + (t29.Max - t29.Min) * math.clamp((p175.Position.X - items.Track.Instance.AbsolutePosition.X) / items.Track.Instance.AbsoluteSize.X, 0, 1)
	end

	local connection

	items.Input:Connect("InputBegan", function(p176)
		if p176.UserInputType == Enum.UserInputType.MouseButton1 or p176.UserInputType == Enum.UserInputType.Touch then
			t29.Sliding = true
			items.Drag:Tween({
				Size = UDim2.new(0, 18, 0, 12)
			}, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
			t29:Set(v399(p176))

			if connection then
				return
			end

			connection = p176.Changed:Connect(function()
				if p176.UserInputState == Enum.UserInputState.End then
					t29.Sliding = false
					items.Drag:Tween({
						Size = UDim2.new(0, 14, 0, 8)
					}, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p177)
		if (p177.UserInputType == Enum.UserInputType.MouseMovement or p177.UserInputType == Enum.UserInputType.Touch) and t29.Sliding then
			t29:Set(v399(p177))
		end
	end)
	t29:Set(t29.Default)

	if t29.Flag then
		arcane.SetFlags[t29.Flag] = function(p178)
			t29:Set(p178)
		end
	end

	return setmetatable(t29, arcane)
end
arcane.RangeSlider = function(p179, p180)
	local v401 = p180 or {}
	local t30 = {
		Name = v401.Name or v401.name or "Slider",
		Min = v401.Min or v401.min or 0,
		Max = v401.Max or v401.max or 100,
		Default = v401.Default or v401.default,
		Decimals = v401.Decimals or v401.decimals or 1,
		Suffix = v401.Suffix or v401.suffix or ""
	}
	local Callback = v401.Callback or v401.callback

	t30.Callback = Callback or function()
	end
	t30.Tooltip = v401.Tooltip or v401.tooltip
	t30.Flag = v401.Flag or v401.flag
	t30.Value = {
		0,
		0
	}
	t30.SlidingHandle = nil
	t30.Items = {}
	t30.Default = t30.Default or {
		t30.Min,
		t30.Max
	}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p179.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 48),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t30.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 4),
		Size = UDim2.new(0.6, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t30.Name)
	v343(items.Name, t30.Tooltip)
	items.Value = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = "",
		TextSize = 14,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 4),
		Size = UDim2.new(0.4, 0, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Right,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	items.Track = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 14, 0, 32),
		Size = UDim2.new(1, -28, 0, 5),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.SliderBack
	}):AddToTheme({
		BackgroundColor3 = "SliderBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Track.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	items.Fill = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.Accent,
		Size = UDim2.new(0, 0, 1, 0),
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "Accent"
	})
	arcane:Create("UICorner", {
		Parent = items.Fill.Instance,
		CornerRadius = UDim.new(0, 2)
	})
	arcane:Create("UIGradient", {
		Parent = items.Fill.Instance,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 150, 150))
		})
	})
	items.MinDrag = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.SliderKnob,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 8),
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "SliderKnob"
	})
	arcane:Create("UICorner", {
		Parent = items.MinDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	items.MaxDrag = arcane:Create("Frame", {
		Parent = items.Track.Instance,
		Name = "\0",
		BackgroundColor3 = arcane.Theme.SliderKnob,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 8),
		ZIndex = 3,
		BorderSizePixel = 0
	}):AddToTheme({
		BackgroundColor3 = "SliderKnob"
	})
	arcane:Create("UICorner", {
		Parent = items.MaxDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	items.Input = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 26),
		Size = UDim2.new(1, -28, 0, 18),
		ZIndex = 4,
		BorderSizePixel = 0
	})
	v341(p179, items.Holder.Instance)
	t30.Items = items
	t30.Set = function(p181, p182, p183)
		if type(p182) == "table" then
			p183 = p182[2]
			p182 = p182[1]
		end

		local v405 = arcane:Round(math.clamp(p182 or t30.Min, t30.Min, t30.Max), t30.Decimals)
		local v406 = arcane:Round(math.clamp(p183 or t30.Max, t30.Min, t30.Max), t30.Decimals)

		if v406 < v405 then
			local v407 = v405

			v405 = v406
			v406 = v407
		end

		t30.Value = {
			v405,
			v406
		}

		if t30.Flag then
			arcane.Flags[t30.Flag] = t30.Value
		end

		local v408 = (v405 - t30.Min) / (t30.Max - t30.Min)
		local v409 = (v406 - t30.Min) / (t30.Max - t30.Min)
		local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

		items.Fill:Tween({
			Position = UDim2.new(v408, 0, 0, 0),
			Size = UDim2.new(v409 - v408, 0, 1, 0)
		}, tweenInfo)
		items.MinDrag:Tween({
			Position = UDim2.new(v408, 0, 0.5, 0)
		}, tweenInfo)
		items.MaxDrag:Tween({
			Position = UDim2.new(v409, 0, 0.5, 0)
		}, tweenInfo)
		items.Value.Instance.Text = tostring(v405) .. t30.Suffix .. ", " .. tostring(v406) .. t30.Suffix
		arcane:SafeCall(t30.Callback, t30.Value)
	end
	t30.Get = function()
		return t30.Value
	end

	local function v411(p184)
		local v412 = t30.Min + (t30.Max - t30.Min) * math.clamp((p184.Position.X - items.Track.Instance.AbsolutePosition.X) / items.Track.Instance.AbsoluteSize.X, 0, 1)

		if t30.SlidingHandle == "Min" then
			t30:Set(math.min(v412, t30.Value[2]), t30.Value[2])
		else
			t30:Set(t30.Value[1], math.max(v412, t30.Value[1]))
		end
	end

	local connection

	items.Input:Connect("InputBegan", function(p185)
		if p185.UserInputType == Enum.UserInputType.MouseButton1 or p185.UserInputType == Enum.UserInputType.Touch then
			local v414 = math.clamp((p185.Position.X - items.Track.Instance.AbsolutePosition.X) / items.Track.Instance.AbsoluteSize.X, 0, 1)
			local v415 = (t30.Value[2] - t30.Min) / (t30.Max - t30.Min)

			t30.SlidingHandle = math.abs(v414 - (t30.Value[1] - t30.Min) / (t30.Max - t30.Min)) <= math.abs(v414 - v415) and "Min" or "Max"
			;(t30.SlidingHandle == "Min" and items.MinDrag or items.MaxDrag):Tween({
				Size = UDim2.new(0, 18, 0, 12)
			}, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out))
			v411(p185)

			if connection then
				return
			end

			connection = p185.Changed:Connect(function()
				if p185.UserInputState == Enum.UserInputState.End then
					items.MinDrag:Tween({
						Size = UDim2.new(0, 14, 0, 8)
					}, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
					items.MaxDrag:Tween({
						Size = UDim2.new(0, 14, 0, 8)
					}, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
					t30.SlidingHandle = nil
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p186)
		if (p186.UserInputType == Enum.UserInputType.MouseMovement or p186.UserInputType == Enum.UserInputType.Touch) and t30.SlidingHandle then
			v411(p186)
		end
	end)
	t30:Set(t30.Default[1], t30.Default[2])

	if t30.Flag then
		arcane.SetFlags[t30.Flag] = function(p187)
			t30:Set(p187)
		end
	end

	return setmetatable(t30, arcane)
end
arcane.Dropdown = function(p188, p189)
	local v416 = p189 or {}
	local t31 = {
		Name = v416.Name or v416.name or "Dropdown",
		Options = v416.Items or v416.items or {},
		Default = v416.Default or v416.default,
		Multi = v416.Multi or v416.multi or false,
		Callback = v416.Callback or v416.callback or function()
		end,
		Tooltip = v416.Tooltip or v416.tooltip,
		Flag = v416.Flag or v416.flag,
		SearchBarEnabled = v416.SearchBarEnabled or v416.searchBarEnabled or false,
		Value = nil,
		Host = p188.IsPopup,
		IsOpen = false,
		Debounce = false
	}

	t31.OptionData = {}
	t31.Order = {}
	t31.Items = {}

	if t31.Multi then
		t31.Value = {}
	end

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p188.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 60),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t31.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t31.Name)
	v343(items.Name, t31.Tooltip)
	items.Back = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 28),
		Size = UDim2.new(1, -24, 0, 25),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Back.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.Selected = arcane:Create("TextLabel", {
		Parent = items.Back.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = "-",
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -34, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	items.Arrow = arcane:Create("ImageLabel", {
		Parent = items.Back.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimText,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimText"
	})
	v25(items.Arrow.Instance, "127296511745226")
	items.Opened = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		Visible = false,
		ClipsDescendants = true,
		Size = UDim2.new(0, 218, 0, 0),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Opened.Instance,
		CornerRadius = UDim.new(0, 4)
	})

	local v419 = t31.SearchBarEnabled and 30 or 0

	if t31.SearchBarEnabled then
		items.SearchBack = arcane:Create("Frame", {
			Parent = items.Opened.Instance,
			Name = "\0",
			Position = UDim2.new(0, 6, 0, 6),
			Size = UDim2.new(1, -12, 0, 22),
			ZIndex = 51,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})
		arcane:Create("UICorner", {
			Parent = items.SearchBack.Instance,
			CornerRadius = UDim.new(0, 4)
		})
		items.SearchInput = arcane:Create("TextBox", {
			Parent = items.SearchBack.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.Text,
			PlaceholderColor3 = arcane.Theme.DimText,
			PlaceholderText = "Search...",
			Text = "",
			TextSize = 14,
			ClearTextOnFocus = false,
			CursorPosition = -1,
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 8, 0.5, 0),
			Size = UDim2.new(1, -16, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 51,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "Text",
			PlaceholderColor3 = "DimText"
		})
	end

	items.Scroll = arcane:Create("ScrollingFrame", {
		Parent = items.Opened.Instance,
		Name = "\0",
		ClipsDescendants = true,
		ScrollBarImageTransparency = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = arcane.Theme.Accent,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0, 0, 0, v419),
		Size = UDim2.new(1, 0, 1, -v419),
		ZIndex = 50,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	}):AddToTheme({
		ScrollBarImageColor3 = "Accent"
	})
	arcane:Create("UIPadding", {
		Parent = items.Scroll.Instance,
		PaddingRight = UDim.new(0, 6)
	})
	arcane:Create("UIListLayout", {
		Parent = items.Scroll.Instance,
		SortOrder = Enum.SortOrder.LayoutOrder
	})

	if t31.SearchBarEnabled then
		arcane:Connect(items.SearchInput.Instance:GetPropertyChangedSignal("Text"), function()
			local v420 = string.lower(items.SearchInput.Instance.Text)
			local n8 = 0

			for _, v in t31.Order, nil, nil do
				local visible = v420 == "" or string.find(string.lower(v.Name), v420, 1, true) ~= nil

				v.Row.Instance.Visible = visible

				if visible then
					n8 += 1
				end
			end

			t31:RefreshCorners()

			if t31.IsOpen then
				local Size = items.Opened.Instance.Size

				items.Opened:Tween({
					Size = UDim2.new(Size.X.Scale, Size.X.Offset, 0, 30 + math.min(n8 * 25, 125))
				}, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
			end
		end)
	end

	v341(p188, items.Holder.Instance)
	t31.Items = items
	items.Back:OnHover(function()
		items.Back:Tween({
			BackgroundColor3 = arcane.Theme.DropdownSelected
		})
	end, function()
		items.Back:Tween({
			BackgroundColor3 = arcane.Theme.DropdownBack
		})
	end)

	local function v426(p190)
		local Value

		if not t31.Multi then
			Value = t31.Value and arcane:DisplayName(t31.Value) or "-"
		elseif #t31.Value > 0 then
			local t32 = {}

			for _, v in t31.Value, nil, nil do
				table.insert(t32, arcane:DisplayName(v))
			end

			Value = table.concat(t32, ", ")
		else
			Value = "-"
		end

		if p190 then
			arcane:SwapText(items.Selected.Instance, Value, 0)
		else
			items.Selected.Instance.Text = Value
		end
	end

	table.insert(arcane.LanguageHooks, function()
		v426(true)
	end)
	t31.AddOption = function(p191, p192)
		local v431 = arcane:Create("Frame", {
			Parent = items.Scroll.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 25),
			ZIndex = 50,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})
		local tween2 = arcane:Create("TextButton", {
			Parent = v431.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 51,
			BorderSizePixel = 0
		})
		local v433 = arcane:Create("TextLabel", {
			Parent = v431.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p192,
			TextSize = 15,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 0),
			Size = UDim2.new(1, -10, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 51,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})
		local v434 = arcane:RegisterText(v433.Instance, p192)
		local v435 = arcane:Create("ImageLabel", {
			Parent = v431.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.Accent,
			ImageTransparency = 1,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0, 7),
			Size = UDim2.new(0, 12, 0, 12),
			ZIndex = 51,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "Accent"
		})

		v25(v435.Instance, "10709790644")

		local t33

		t33 = {
			Name = p192,
			Selected = false,
			Row = v431,
			Text = v433,
			Check = v435,
			TextEntry = v434,
			Toggle = function(p193, p194)
				t33.Selected = p194

				if p194 then
					v433:ChangeItemTheme({
						TextColor3 = "Text"
					})
					v431:Tween({
						BackgroundTransparency = 0
					})
					v433:Tween({
						TextColor3 = arcane.Theme.Text,
						Position = UDim2.new(0, 30, 0, 0)
					})
					v435:Tween({
						ImageTransparency = 0
					})
				else
					v433:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v431:Tween({
						BackgroundTransparency = 1
					})
					v433:Tween({
						TextColor3 = arcane.Theme.DimText,
						Position = UDim2.new(0, 10, 0, 0)
					})
					v435:Tween({
						ImageTransparency = 1
					})
				end
			end
		}
		tween2:Connect("MouseButton1Down", function()
			if t31.Multi then
				local v437 = table.find(t31.Value, p192)

				if v437 then
					table.remove(t31.Value, v437)
					t33:Toggle(false)
				else
					table.insert(t31.Value, p192)
					t33:Toggle(true)
				end
			else
				t31.Value = p192

				for _, v in t31.OptionData, nil, nil do
					v:Toggle(v == t33)
				end
			end

			if t31.Flag then
				arcane.Flags[t31.Flag] = t31.Value
			end

			v426()
			arcane:SafeCall(t31.Callback, t31.Value)
		end)
		t33:Toggle(false)
		t31.OptionData[p192] = t33
		table.insert(t31.Order, t33)
		t31:RefreshCorners()

		return t33
	end
	t31.RefreshCorners = function()
		local t34 = {}

		for _, v in t31.Order, nil, nil do
			if v.Row.Instance.Visible then
				table.insert(t34, v)
			end
		end

		for _, v in t31.Order, nil, nil do
			local v445 = t34[1] == v or t34[#t34] == v

			if not v445 or v.Corner then
				if not v445 and v.Corner then
					v.Corner.Instance:Destroy()
					v.Corner = nil
				end
			else
				v.Corner = arcane:Create("UICorner", {
					Parent = v.Row.Instance,
					CornerRadius = UDim.new(0, 4)
				})
			end
		end
	end
	t31.Set = function(p195, p196)
		if t31.Multi then
			if type(p196) ~= "table" then
				return
			end

			t31.Value = p196

			for _, v in t31.OptionData, nil, nil do
				v:Toggle(table.find(p196, v.Name) ~= nil)
			end
		else
			if not t31.OptionData[p196] then
				return
			end

			t31.Value = p196

			for _, v in t31.OptionData, nil, nil do
				v:Toggle(v.Name == p196)
			end
		end

		if t31.Flag then
			arcane.Flags[t31.Flag] = t31.Value
		end

		v426()
		arcane:SafeCall(t31.Callback, t31.Value)
	end
	t31.Get = function()
		return t31.Value
	end
	t31.SetValue = function(p197, p198, p199)
		if p198 ~= nil and p199 ~= nil then
			if p198 ~= p199 then
				local v450 = t31.OptionData[p198]

				if not v450 then
					return
				end

				if t31.OptionData[p199] then
					return
				end

				v450.Name = p199
				v450.Text.Instance.Text = p199

				if v450.TextEntry then
					v450.TextEntry.English = p199
					v450.TextEntry.Transparency = v450.Text.Instance.TextTransparency

					if arcane.LanguageCodes[arcane.Language] then
						arcane:TranslateEntry(v450.TextEntry)
					end
				end

				t31.OptionData[p198] = nil
				t31.OptionData[p199] = v450

				local v451 = table.find(t31.Options, p198)

				if v451 then
					t31.Options[v451] = p199
				end

				local v452 = false

				if t31.Multi then
					local v453 = table.find(t31.Value, p198)

					if v453 then
						t31.Value[v453] = p199
						v452 = true
					end
				elseif t31.Value == p198 then
					t31.Value = p199
					v452 = true
				end

				if v452 and t31.Flag then
					arcane.Flags[t31.Flag] = t31.Value
				end

				v426()

				if v452 then
					arcane:SafeCall(t31.Callback, t31.Value)
				end

				return
			end
		end
	end
	t31.RemoveOption = function(p200, p201)
		local v454 = t31.OptionData[p201]

		if v454 then
			local v455 = table.find(t31.Order, v454)

			if v455 then
				table.remove(t31.Order, v455)
			end

			v454.Row.Instance:Destroy()
			t31.OptionData[p201] = nil
			t31:RefreshCorners()
		end
	end
	t31.Refresh = function(p202, p203)
		for k in t31.OptionData, nil, nil do
			t31:RemoveOption(k)
		end

		t31.Options = p203

		for _, v in p203, nil, nil do
			t31:AddOption(v)
		end

		v426()
	end

	local function v459()
		local screenScale = arcane:GetScreenScale()

		return UDim2.new(0, items.Back.Instance.AbsoluteSize.X / screenScale, 0, (t31.SearchBarEnabled and 30 or 0) + math.min(#t31.Options * 25, 125))
	end
	local function v461(p204)
		local screenScale = arcane:GetScreenScale()
		local v463 = items.Back.Instance.AbsolutePosition.X / screenScale
		local v464 = items.Back.Instance.AbsolutePosition.Y + items.Back.Instance.AbsoluteSize.Y + Y

		return UDim2.fromOffset(v463, (v464 + (p204 or 0)) / screenScale)
	end

	t31.SetOpen = function(p205, p206)
		if t31.Debounce then
			return
		end

		t31.IsOpen = p206
		t31.Debounce = true
		items.Arrow:Tween({
			Rotation = p206 and 180 or 0
		})

		if p206 then
			items.Opened.Instance.Parent = arcane.Holder.Instance
			items.Opened.Instance.Size = v459()
			items.Opened.Instance.Position = v461(-8)
			items.Opened.Instance.Visible = true
			arcane:RaisePopup(items.Opened.Instance, true, 70)
			items.Opened:Tween({
				Position = v461(2)
			})

			for _, v in arcane.OpenFrames, nil, nil do
				if not (v == t31 or v == t31.Host or v.IsPopup) then
					v:SetOpen(false)
				end
			end

			arcane.OpenFrames[t31] = t31
			items.Opened:FadeDescendants(true, function()
				t31.Debounce = false
			end)
		else
			arcane.OpenFrames[t31] = nil

			local Position2 = items.Opened.Instance.Position

			items.Opened:Tween({
				Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
			})
			items.Opened:FadeDescendants(false, function()
				t31.Debounce = false
				items.Opened.Instance.Parent = arcane.UnusedHolder.Instance
				arcane:RaisePopup(items.Opened.Instance, false)
			end)
		end
	end
	items.Back:Connect("MouseButton1Down", function()
		t31:SetOpen(not t31.IsOpen)
	end)
	arcane:Connect(UserInputService.InputBegan, function(p207)
		if p207.UserInputType == Enum.UserInputType.MouseButton1 or p207.UserInputType == Enum.UserInputType.Touch then
			if t31.IsOpen then
				if not items.Opened:IsMouseOverFrame() then
					if not items.Back:IsMouseOverFrame() then
						t31:SetOpen(false)
					end
				end
			end
		end
	end)

	for _, v in t31.Options, nil, nil do
		t31:AddOption(v)
	end

	if t31.Default then
		t31:Set(t31.Default)
	end

	if t31.Flag then
		arcane.SetFlags[t31.Flag] = function(p208)
			t31:Set(p208)
		end
	end

	return setmetatable(t31, arcane)
end
arcane.Button = function(p209, p210)
	local v470 = p210 or {}
	local Name = v470.Name or v470.name
	local t35 = {
		Name = Name or "Button",
		Callback = v470.Callback or v470.callback or function()
		end,
		Tooltip = v470.Tooltip or v470.tooltip,
		Items = {}
	}
	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p209.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 46),
			BorderSizePixel = 0
		})
	}

	items.Button = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 9),
		Size = UDim2.new(1, -24, 0, 28),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Button.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.Text = arcane:Create("TextLabel", {
		Parent = items.Button.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = t35.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(items.Text.Instance, t35.Name)
	v343(items.Text, t35.Tooltip, true)
	v341(p209, items.Holder.Instance)
	t35.Items = items
	items.Button:OnHover(function()
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.DropdownSelected
		})
	end, function()
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.DropdownBack
		})
	end)
	t35.Press = function()
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.Accent
		})
		task.wait(0.12)
		items.Button:Tween({
			BackgroundColor3 = arcane.Theme.DropdownBack
		})
		arcane:SafeCall(t35.Callback)
	end
	t35.SetText = function(p211, p212)
		items.Text.Instance.Text = tostring(p212)
	end
	items.Button:Connect("MouseButton1Down", function()
		t35:Press()
	end)

	return setmetatable(t35, arcane)
end
arcane.Textbox = function(p213, p214)
	local v474 = p214 or {}
	local t36 = {
		Name = v474.Name or v474.name or "Textbox",
		Default = v474.Default or v474.default or ""
	}
	local Placeholder = v474.Placeholder or v474.placeholder

	t36.Placeholder = Placeholder or "..."
	t36.Callback = v474.Callback or v474.callback or function()
	end
	t36.Finished = v474.Finished or v474.finished or false
	t36.Tooltip = v474.Tooltip or v474.tooltip
	t36.Flag = v474.Flag or v474.flag
	t36.Value = ""
	t36.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p213.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 60),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t36.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t36.Name)
	v343(items.Name, t36.Tooltip)
	items.Back = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 28),
		Size = UDim2.new(1, -24, 0, 25),
		ClipsDescendants = true,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Back.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.Input = arcane:Create("TextBox", {
		Parent = items.Back.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		PlaceholderColor3 = arcane.Theme.DimText,
		PlaceholderText = t36.Placeholder,
		Text = "",
		TextSize = 14,
		ClearTextOnFocus = false,
		CursorPosition = -1,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 10, 0.5, 0),
		Size = UDim2.new(1, -20, 1, 0),
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text",
		PlaceholderColor3 = "DimText"
	})

	if v12 then
		arcane:Create("TextButton", {
			Parent = items.Back.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 5,
			BorderSizePixel = 0
		}):Connect("MouseButton1Down", function()
			items.Input.Instance:CaptureFocus()
		end)
	end

	v341(p213, items.Holder.Instance)
	t36.Items = items
	t36.Set = function(p215, p216)
		t36.Value = tostring(p216)
		items.Input.Instance.Text = t36.Value

		if t36.Flag then
			arcane.Flags[t36.Flag] = t36.Value
		end

		arcane:SafeCall(t36.Callback, t36.Value)
	end
	t36.Get = function()
		return t36.Value
	end

	if t36.Finished then
		items.Input:Connect("FocusLost", function(p217)
			if p217 then
				t36:Set(items.Input.Instance.Text)
			end
		end)
	else
		arcane:Connect(items.Input.Instance:GetPropertyChangedSignal("Text"), function()
			t36:Set(items.Input.Instance.Text)
		end)
	end

	if t36.Default ~= "" then
		t36:Set(t36.Default)
	end

	if t36.Flag then
		arcane.SetFlags[t36.Flag] = function(p218)
			t36:Set(p218)
		end
	end

	return setmetatable(t36, arcane)
end
arcane.List = function(p219, p220)
	local v478 = p220 or {}
	local t37 = {
		Name = v478.Name or v478.name or "List"
	}
	local Empty = v478.Empty or v478.empty

	t37.Empty = Empty or "It's still empty here"
	t37.Callback = v478.Callback or v478.callback or function()
	end
	t37.Tooltip = v478.Tooltip or v478.tooltip
	t37.Value = nil
	t37.OptionData = {}
	t37.Order = {}
	t37.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p219.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 178),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t37.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t37.Name)
	v343(items.Name, t37.Tooltip)
	items.Box = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 26),
		Size = UDim2.new(1, -24, 0, 138),
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Box.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Empty = arcane:Create("TextLabel", {
		Parent = items.Box.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t37.Empty,
		TextSize = 14,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	items.Scroll = arcane:Create("ScrollingFrame", {
		Parent = items.Box.Instance,
		Name = "\0",
		BackgroundTransparency = 1,
		ScrollBarThickness = 3,
		ScrollBarImageTransparency = 0,
		ScrollBarImageColor3 = arcane.Theme.Accent,
		Selectable = false,
		Active = true,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 2,
		BorderSizePixel = 0
	}):AddToTheme({
		ScrollBarImageColor3 = "Accent"
	})
	arcane:Create("UIPadding", {
		Parent = items.Scroll.Instance,
		PaddingTop = UDim.new(0, 4),
		PaddingBottom = UDim.new(0, 4)
	})
	arcane:Create("UIListLayout", {
		Parent = items.Scroll.Instance,
		Padding = UDim.new(0, 2),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	v341(p219, items.Holder.Instance)
	t37.Items = items

	local function v482()
		items.Empty.Instance.Visible = #t37.Order == 0
	end

	t37.AddOption = function(p221, p222)
		local v483 = arcane:Create("Frame", {
			Parent = items.Scroll.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 28),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})
		local tween2 = arcane:Create("TextButton", {
			Parent = v483.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			BorderSizePixel = 0
		})
		local v485 = arcane:Create("Frame", {
			Parent = v483.Instance,
			Name = "\0",
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 6, 0.5, 0),
			Size = UDim2.new(0, 3, 0, 14),
			BackgroundTransparency = 1,
			ZIndex = 3,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.Accent
		}):AddToTheme({
			BackgroundColor3 = "Accent"
		})

		arcane:Create("UICorner", {
			Parent = v485.Instance,
			CornerRadius = UDim.new(1, 0)
		})

		local v486 = arcane:Create("TextLabel", {
			Parent = v483.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p222,
			TextSize = 14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -20, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})

		arcane:RegisterText(v486.Instance, p222)

		local t38

		t38 = {
			Name = p222,
			Selected = false,
			Row = v483,
			Text = v486,
			Line = v485,
			Toggle = function(p223, p224)
				t38.Selected = p224

				if p224 then
					v486:ChangeItemTheme({
						TextColor3 = "Text"
					})
					v483:Tween({
						BackgroundTransparency = 0
					})
					v486:Tween({
						TextColor3 = arcane.Theme.Text,
						Position = UDim2.new(0, 24, 0, 0)
					})
					v485:Tween({
						BackgroundTransparency = 0,
						Position = UDim2.new(0, 12, 0.5, 0)
					})
				else
					v486:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v483:Tween({
						BackgroundTransparency = 1
					})
					v486:Tween({
						TextColor3 = arcane.Theme.DimText,
						Position = UDim2.new(0, 12, 0, 0)
					})
					v485:Tween({
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 6, 0.5, 0)
					})
				end
			end
		}
		tween2:Connect("MouseButton1Down", function()
			if t38.Selected then
				t37.Value = nil
				t38:Toggle(false)
			else
				t37.Value = p222

				for _, v in t37.Order, nil, nil do
					v:Toggle(v == t38)
				end
			end

			arcane:SafeCall(t37.Callback, t37.Value)
		end)
		t38:Toggle(false)
		t37.OptionData[p222] = t38
		table.insert(t37.Order, t38)
		v482()

		return t38
	end
	t37.RemoveOption = function(p225, p226)
		local v490 = t37.OptionData[p226]

		if v490 then
			local v491 = table.find(t37.Order, v490)

			if v491 then
				table.remove(t37.Order, v491)
			end

			v490.Row.Instance:Destroy()
			t37.OptionData[p226] = nil

			if t37.Value == p226 then
				t37.Value = nil
			end

			v482()
		end
	end
	t37.Refresh = function(p227, p228)
		for k in t37.OptionData, nil, nil do
			t37:RemoveOption(k)
		end

		for _, v in p228, nil, nil do
			t37:AddOption(v)
		end

		v482()
	end
	t37.Set = function(p229, p230)
		if not t37.OptionData[p230] then
			return
		end

		t37.Value = p230

		for _, v in t37.Order, nil, nil do
			v:Toggle(v.Name == p230)
		end

		arcane:SafeCall(t37.Callback, t37.Value)
	end
	t37.Get = function()
		return t37.Value
	end

	local Items = v478.Items or v478.items or {}

	for _, v in Items, nil, nil do
		t37:AddOption(v)
	end

	v482()

	return setmetatable(t37, arcane)
end
arcane.Selector = function(p231, p232)
	local v500 = p232 or {}
	local t39 = {
		Name = v500.Name or v500.name or "Selector"
	}
	local Items = v500.Items or v500.items

	t39.Options = Items or {}
	t39.Default = v500.Default or v500.default
	t39.Multi = v500.Multi or v500.multi or false
	t39.Callback = v500.Callback or v500.callback or function()
	end
	t39.Tooltip = v500.Tooltip or v500.tooltip
	t39.Flag = v500.Flag or v500.flag
	t39.Value = nil
	t39.OptionData = {}
	t39.Order = {}
	t39.Items = {}

	if t39.Multi then
		t39.Value = {}
	end

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p231.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0
		})
	}

	arcane:Create("UIPadding", {
		Parent = items.Holder.Instance,
		PaddingBottom = UDim.new(0, 8)
	})
	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.DimText,
		Text = t39.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 2),
		Size = UDim2.new(1, -24, 0, 18),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "DimText"
	})
	arcane:RegisterText(items.Name.Instance, t39.Name)
	v343(items.Name, t39.Tooltip)
	items.Box = arcane:Create("Frame", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Position = UDim2.new(0, 12, 0, 26),
		Size = UDim2.new(1, -24, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Box.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	arcane:Create("UIPadding", {
		Parent = items.Box.Instance,
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6)
	})
	arcane:Create("UIListLayout", {
		Parent = items.Box.Instance,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder
	})
	v341(p231, items.Holder.Instance).Instance.Position = UDim2.new(0.5, 0, 1, 10)
	t39.Items = items

	local function v504()
		if t39.Flag then
			arcane.Flags[t39.Flag] = t39.Value
		end

		arcane:SafeCall(t39.Callback, t39.Value)
	end

	t39.AddOption = function(p233, p234)
		local v505 = arcane:Create("Frame", {
			Parent = items.Box.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = arcane.Theme.DropdownSelected
		}):AddToTheme({
			BackgroundColor3 = "DropdownSelected"
		})

		arcane:Create("UICorner", {
			Parent = v505.Instance,
			CornerRadius = UDim.new(0, 6)
		})

		local tween2 = arcane:Create("TextButton", {
			Parent = v505.Instance,
			Name = "\0",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 3,
			BorderSizePixel = 0
		})
		local v507 = arcane:Create("ImageLabel", {
			Parent = v505.Instance,
			Name = "\0",
			ImageColor3 = arcane.Theme.Accent,
			ImageTransparency = 1,
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 10, 0.5, 0),
			Size = UDim2.new(0, 14, 0, 14),
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			ImageColor3 = "Accent"
		})

		v25(v507.Instance, "10709790644")

		local v508 = arcane:Create("TextLabel", {
			Parent = v505.Instance,
			Name = "\0",
			FontFace = arcane.Font,
			TextColor3 = arcane.Theme.DimText,
			Text = p234,
			TextSize = 14,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 12, 0, 0),
			Size = UDim2.new(1, -20, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 3,
			BorderSizePixel = 0
		}):AddToTheme({
			TextColor3 = "DimText"
		})

		arcane:RegisterText(v508.Instance, p234)

		local t40

		t40 = {
			Name = p234,
			Selected = false,
			Row = v505,
			Text = v508,
			Check = v507,
			Toggle = function(p235, p236)
				t40.Selected = p236

				if p236 then
					v508:ChangeItemTheme({
						TextColor3 = "Text"
					})
					v505:Tween({
						BackgroundTransparency = 0
					})
					v508:Tween({
						TextColor3 = arcane.Theme.Text,
						Position = UDim2.new(0, 34, 0, 0)
					})
					v507:Tween({
						ImageTransparency = 0
					})
				else
					v508:ChangeItemTheme({
						TextColor3 = "DimText"
					})
					v505:Tween({
						BackgroundTransparency = 1
					})
					v508:Tween({
						TextColor3 = arcane.Theme.DimText,
						Position = UDim2.new(0, 12, 0, 0)
					})
					v507:Tween({
						ImageTransparency = 1
					})
				end
			end
		}
		tween2:Connect("MouseButton1Down", function()
			if t39.Multi then
				local v510 = table.find(t39.Value, p234)

				if v510 then
					table.remove(t39.Value, v510)
					t40:Toggle(false)
				else
					table.insert(t39.Value, p234)
					t40:Toggle(true)
				end
			else
				t39.Value = p234

				for _, v in t39.OptionData, nil, nil do
					v:Toggle(v == t40)
				end
			end

			v504()
		end)
		t40:Toggle(false)
		t39.OptionData[p234] = t40
		table.insert(t39.Order, t40)

		return t40
	end
	t39.Set = function(p237, p238)
		if t39.Multi then
			if type(p238) ~= "table" then
				return
			end

			t39.Value = p238

			for _, v in t39.OptionData, nil, nil do
				v:Toggle(table.find(p238, v.Name) ~= nil)
			end
		else
			if not t39.OptionData[p238] then
				return
			end

			t39.Value = p238

			for _, v in t39.OptionData, nil, nil do
				v:Toggle(v.Name == p238)
			end
		end

		v504()
	end
	t39.Get = function()
		return t39.Value
	end
	t39.RemoveOption = function(p239, p240)
		local v517 = t39.OptionData[p240]

		if v517 then
			local v518 = table.find(t39.Order, v517)

			if v518 then
				table.remove(t39.Order, v518)
			end

			v517.Row.Instance:Destroy()
			t39.OptionData[p240] = nil
		end
	end
	t39.Refresh = function(p241, p242)
		for k in t39.OptionData, nil, nil do
			t39:RemoveOption(k)
		end

		t39.Options = p242

		for _, v in p242, nil, nil do
			t39:AddOption(v)
		end
	end

	for _, v in t39.Options, nil, nil do
		t39:AddOption(v)
	end

	if t39.Default then
		t39:Set(t39.Default)
	end

	if t39.Flag then
		arcane.SetFlags[t39.Flag] = function(p243)
			t39:Set(p243)
		end
	end

	return setmetatable(t39, arcane)
end
arcane.Colorpicker = function(p244, p245)
	local v524 = p245 or {}
	local t41 = {
		Name = v524.Name or v524.name or "Colorpicker"
	}

	t41.Default = v524.Default or v524.default or Color3.fromRGB(254, 0, 67)
	t41.Callback = v524.Callback or v524.callback or function()
	end
	t41.Tooltip = v524.Tooltip or v524.tooltip
	t41.Flag = v524.Flag or v524.flag
	t41.Hue = 0
	t41.Saturation = 0
	t41.Value = 0
	t41.Transparency = v524.Transparency or v524.transparency or 0
	t41.Color = Color3.fromRGB(255, 255, 255)
	t41.Host = p244.IsPopup
	t41.IsOpen = false
	t41.Debounce = false
	t41.Items = {}

	local items = {
		Holder = arcane:Create("Frame", {
			Parent = p244.Items.Content.Instance,
			Name = "\0",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 35),
			BorderSizePixel = 0
		})
	}

	items.Name = arcane:Create("TextLabel", {
		Parent = items.Holder.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		Text = t41.Name,
		TextSize = 14,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(1, -60, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		BorderSizePixel = 0
	}):AddToTheme({
		TextColor3 = "Text"
	})
	arcane:RegisterText(items.Name.Instance, t41.Name)
	v343(items.Name, t41.Tooltip)
	items.Swatch = arcane:Create("TextButton", {
		Parent = items.Holder.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 34, 0, 16),
		BorderSizePixel = 0,
		BackgroundColor3 = t41.Default
	})
	arcane:Create("UICorner", {
		Parent = items.Swatch.Instance,
		CornerRadius = UDim.new(0, 5)
	})
	arcane:Create("UIStroke", {
		Parent = items.Swatch.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.3
	}):AddToTheme({
		Color = "Border"
	})
	v341(p244, items.Holder.Instance)
	items.Window = arcane:Create("Frame", {
		Parent = arcane.UnusedHolder.Instance,
		Name = "\0",
		Visible = false,
		Size = UDim2.new(0, 210, 0, 210),
		ZIndex = 50,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.Section
	}):AddToTheme({
		BackgroundColor3 = "Section"
	})
	arcane:Create("UICorner", {
		Parent = items.Window.Instance,
		CornerRadius = UDim.new(0, 8)
	})
	arcane:Create("UIStroke", {
		Parent = items.Window.Instance,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = arcane.Theme.Border,
		Transparency = 0.4
	}):AddToTheme({
		Color = "Border"
	})
	items.Window:MakeDraggable()
	items.Palette = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(1, -24, 0, 108),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	})
	arcane:Create("UICorner", {
		Parent = items.Palette.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Sat = arcane:Create("Frame", {
		Parent = items.Palette.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 51,
		BorderSizePixel = 0
	})
	arcane:Create("UIGradient", {
		Parent = items.Sat.Instance,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
	arcane:Create("UICorner", {
		Parent = items.Sat.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.Val = arcane:Create("Frame", {
		Parent = items.Palette.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 51,
		BorderSizePixel = 0
	})
	arcane:Create("UIGradient", {
		Parent = items.Val.Instance,
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
	})
	arcane:Create("UICorner", {
		Parent = items.Val.Instance,
		CornerRadius = UDim.new(0, 6)
	})
	items.PaletteDrag = arcane:Create("Frame", {
		Parent = items.Palette.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 10, 0, 10),
		ZIndex = 52,
		BorderSizePixel = 0
	})
	arcane:Create("UICorner", {
		Parent = items.PaletteDrag.Instance,
		CornerRadius = UDim.new(1, 0)
	})
	arcane:Create("UIStroke", {
		Parent = items.PaletteDrag.Instance,
		Color = Color3.fromRGB(255, 255, 255),
		Thickness = 1.5
	})
	items.Hue = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 128),
		Size = UDim2.new(1, -54, 0, 14),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	})
	arcane:Create("UICorner", {
		Parent = items.Hue.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	arcane:Create("UIGradient", {
		Parent = items.Hue.Instance,
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
	})
	items.HueDrag = arcane:Create("Frame", {
		Parent = items.Hue.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 5, 1, 8),
		ZIndex = 52,
		BorderSizePixel = 0
	})
	arcane:Create("UICorner", {
		Parent = items.HueDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	arcane:Create("UIStroke", {
		Parent = items.HueDrag.Instance,
		Color = arcane.Theme.Section,
		Thickness = 1.5
	}):AddToTheme({
		Color = "Section"
	})
	items.Alpha = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		Position = UDim2.new(0, 12, 0, 148),
		Size = UDim2.new(1, -54, 0, 14),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = t41.Default
	})
	arcane:Create("UICorner", {
		Parent = items.Alpha.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	arcane:Create("UIGradient", {
		Parent = items.Alpha.Instance,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
	})
	items.AlphaDrag = arcane:Create("Frame", {
		Parent = items.Alpha.Instance,
		Name = "\0",
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(0, 5, 1, 8),
		ZIndex = 52,
		BorderSizePixel = 0
	})
	arcane:Create("UICorner", {
		Parent = items.AlphaDrag.Instance,
		CornerRadius = UDim.new(0, 3)
	})
	arcane:Create("UIStroke", {
		Parent = items.AlphaDrag.Instance,
		Color = arcane.Theme.Section,
		Thickness = 1.5
	}):AddToTheme({
		Color = "Section"
	})
	items.Copy = arcane:Create("TextButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0, 148),
		Size = UDim2.new(0, 28, 0, 40),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Copy.Instance,
		CornerRadius = UDim.new(0, 4)
	})
	items.CopyIcon = arcane:Create("ImageLabel", {
		Parent = items.Copy.Instance,
		Name = "\0",
		ImageColor3 = arcane.Theme.DimText,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		BackgroundTransparency = 1,
		ZIndex = 51,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "DimText"
	})
	v25(items.CopyIcon.Instance, "10709812159")
	items.Hex = arcane:Create("TextBox", {
		Parent = items.Window.Instance,
		Name = "\0",
		FontFace = arcane.Font,
		TextColor3 = arcane.Theme.Text,
		PlaceholderColor3 = arcane.Theme.DimText,
		PlaceholderText = "#ffffff",
		Text = "#ffffff",
		TextSize = 14,
		ClearTextOnFocus = false,
		CursorPosition = -1,
		Position = UDim2.new(0, 12, 0, 172),
		Size = UDim2.new(1, -44, 0, 26),
		ZIndex = 51,
		BorderSizePixel = 0,
		BackgroundColor3 = arcane.Theme.DropdownBack
	}):AddToTheme({
		TextColor3 = "Text",
		PlaceholderColor3 = "DimText",
		BackgroundColor3 = "DropdownBack"
	})
	arcane:Create("UICorner", {
		Parent = items.Hex.Instance,
		CornerRadius = UDim.new(0, 5)
	})
	arcane:Create("UIPadding", {
		Parent = items.Hex.Instance,
		PaddingLeft = UDim.new(0, 8)
	})
	items.Paste = arcane:Create("ImageButton", {
		Parent = items.Window.Instance,
		Name = "\0",
		AutoButtonColor = false,
		ImageColor3 = arcane.Theme.Accent,
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -12, 0, 185),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 51,
		BorderSizePixel = 0
	}):AddToTheme({
		ImageColor3 = "Accent"
	})
	v25(items.Paste.Instance, "10709798443")
	t41.Items = items
	t41.Update = function()
		t41.Color = Color3.fromHSV(t41.Hue, t41.Saturation, t41.Value)
		items.Swatch:Tween({
			BackgroundColor3 = t41.Color,
			BackgroundTransparency = t41.Transparency
		})
		items.Palette:Tween({
			BackgroundColor3 = Color3.fromHSV(t41.Hue, 1, 1)
		})
		items.Alpha:Tween({
			BackgroundColor3 = t41.Color
		})

		if not items.Hex.Instance:IsFocused() then
			items.Hex.Instance.Text = "#" .. t41.Color:ToHex()
		end

		if t41.Flag then
			arcane.Flags[t41.Flag] = {
				__color = t41.Color:ToHex(),
				__alpha = t41.Transparency
			}
		end

		arcane:SafeCall(t41.Callback, t41.Color, t41.Transparency)
	end
	t41.Set = function(p246, p247, p248)
		if type(p247) == "table" then
			p247 = Color3.fromRGB(p247[1], p247[2], p247[3])
		end

		if type(p247) == "string" then
			p247 = Color3.fromHex(p247)
		end

		local v527, v528, v529 = p247:ToHSV()

		t41.Hue = v527
		t41.Saturation = v528
		t41.Value = v529
		t41.Transparency = p248 or t41.Transparency or 0
		items.PaletteDrag.Instance.Position = UDim2.new(t41.Saturation, 0, 1 - t41.Value, 0)
		items.HueDrag.Instance.Position = UDim2.new(t41.Hue, 0, 0.5, 0)
		items.AlphaDrag.Instance.Position = UDim2.new(t41.Transparency, 0, 0.5, 0)
		t41:Update()
	end
	t41.Get = function()
		return t41.Color, t41.Transparency
	end

	local u530 = false
	local u531 = false
	local u532 = false
	local connection
	local connection2
	local connection3

	local function v536(p249)
		if not u530 or not p249 then
			return
		end

		local saturation = math.clamp((p249.Position.X - items.Palette.Instance.AbsolutePosition.X) / items.Palette.Instance.AbsoluteSize.X, 0, 1)
		local v538 = math.clamp((p249.Position.Y - items.Palette.Instance.AbsolutePosition.Y) / items.Palette.Instance.AbsoluteSize.Y, 0, 1)

		t41.Saturation = saturation
		t41.Value = 1 - v538
		items.PaletteDrag:Tween({
			Position = UDim2.new(saturation, 0, v538, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		t41:Update()
	end
	local function v539(p250)
		if not u531 or not p250 then
			return
		end

		local hue = math.clamp((p250.Position.X - items.Hue.Instance.AbsolutePosition.X) / items.Hue.Instance.AbsoluteSize.X, 0, 1)

		t41.Hue = hue
		items.HueDrag:Tween({
			Position = UDim2.new(hue, 0, 0.5, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		t41:Update()
	end
	local function v541(p251)
		if not u532 or not p251 then
			return
		end

		local transparency = math.clamp((p251.Position.X - items.Alpha.Instance.AbsolutePosition.X) / items.Alpha.Instance.AbsoluteSize.X, 0, 1)

		t41.Transparency = transparency
		items.AlphaDrag:Tween({
			Position = UDim2.new(transparency, 0, 0.5, 0)
		}, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
		t41:Update()
	end

	items.Palette:Connect("InputBegan", function(p252)
		if p252.UserInputType == Enum.UserInputType.MouseButton1 or p252.UserInputType == Enum.UserInputType.Touch then
			u530 = true
			v536(p252)

			if connection then
				return
			end

			connection = p252.Changed:Connect(function()
				if p252.UserInputState == Enum.UserInputState.End then
					u530 = false
					connection:Disconnect()
					connection = nil
				end
			end)
		end
	end)
	items.Hue:Connect("InputBegan", function(p253)
		if p253.UserInputType == Enum.UserInputType.MouseButton1 or p253.UserInputType == Enum.UserInputType.Touch then
			u531 = true
			v539(p253)

			if connection2 then
				return
			end

			connection2 = p253.Changed:Connect(function()
				if p253.UserInputState == Enum.UserInputState.End then
					u531 = false
					connection2:Disconnect()
					connection2 = nil
				end
			end)
		end
	end)
	items.Alpha:Connect("InputBegan", function(p254)
		if p254.UserInputType == Enum.UserInputType.MouseButton1 or p254.UserInputType == Enum.UserInputType.Touch then
			u532 = true
			v541(p254)

			if connection3 then
				return
			end

			connection3 = p254.Changed:Connect(function()
				if p254.UserInputState == Enum.UserInputState.End then
					u532 = false
					connection3:Disconnect()
					connection3 = nil
				end
			end)
		end
	end)
	arcane:Connect(UserInputService.InputChanged, function(p255)
		if p255.UserInputType == Enum.UserInputType.MouseMovement or p255.UserInputType == Enum.UserInputType.Touch then
			if u530 then
				v536(p255)
			end

			if u531 then
				v539(p255)
			end

			if u532 then
				v541(p255)
			end
		end
	end)
	items.Hex:Connect("FocusLost", function()
		local v543 = string.gsub(items.Hex.Instance.Text, "#", "")
		local ok2, result2 = pcall(function()
			return Color3.fromHex(v543)
		end)

		if ok2 and result2 then
			t41:Set(result2, t41.Transparency)
		else
			items.Hex.Instance.Text = "#" .. t41.Color:ToHex()
		end
	end)
	items.Copy:Connect("MouseButton1Down", function()
		local v546 = "#" .. t41.Color:ToHex()
		local setclipboard_ = setclipboard or toclipboard

		if setclipboard_ then
			setclipboard_(v546)
		end

		arcane:Notification({
			Name = "Copied to clipboard",
			Description = v546,
			Duration = 2,
			Icon = "10709812159",
			Color = t41.Color
		})
	end)
	items.Paste:Connect("MouseButton1Down", function()
		local getclipboard_ = getclipboard or readclipboard

		if getclipboard_ then
			local v549 = getclipboard_()

			if type(v549) == "string" and v549 ~= "" then
				local ok2, result2 = pcall(function()
					local v552 = string.gsub(v549, "#", "")

					return Color3.fromHex(v552)
				end)

				if ok2 and result2 then
					t41:Set(result2, t41.Transparency)
				end
			end
		end
	end)

	local function v553(p256)
		local screenScale = arcane:GetScreenScale()

		return UDim2.fromOffset(items.Swatch.Instance.AbsolutePosition.X / screenScale, (items.Swatch.Instance.AbsolutePosition.Y + items.Swatch.Instance.AbsoluteSize.Y + Y + (p256 or 0)) / screenScale)
	end

	t41.SetOpen = function(p257, p258)
		if t41.Debounce then
			return
		end

		t41.IsOpen = p258
		t41.Debounce = true

		if p258 then
			items.Window.Instance.Parent = arcane.Holder.Instance
			items.Window.Instance.Position = v553(-8)
			items.Window.Instance.Visible = true
			arcane:RaisePopup(items.Window.Instance, true, 70)
			items.Window:Tween({
				Position = v553(2)
			})

			for _, v in arcane.OpenFrames, nil, nil do
				if v ~= t41 and v ~= t41.Host and not v.IsPopup then
					v:SetOpen(false)
				end
			end

			arcane.OpenFrames[t41] = t41
			items.Window:FadeDescendants(true, function()
				t41.Debounce = false
			end)
		else
			arcane.OpenFrames[t41] = nil

			local Position2 = items.Window.Instance.Position

			items.Window:Tween({
				Position = UDim2.new(Position2.X.Scale, Position2.X.Offset, Position2.Y.Scale, Position2.Y.Offset - 10)
			})
			items.Window:FadeDescendants(false, function()
				t41.Debounce = false
				items.Window.Instance.Parent = arcane.UnusedHolder.Instance
				arcane:RaisePopup(items.Window.Instance, false)
			end)
		end
	end
	items.Swatch:Connect("MouseButton1Down", function()
		t41:SetOpen(not t41.IsOpen)
	end)
	arcane:Connect(UserInputService.InputBegan, function(p259)
		if (p259.UserInputType == Enum.UserInputType.MouseButton1 or p259.UserInputType == Enum.UserInputType.Touch) and t41.IsOpen then
			if not items.Window:IsMouseOverFrame() then
				if not items.Swatch:IsMouseOverFrame() then
					t41:SetOpen(false)
				end
			end
		end
	end)
	t41:Set(t41.Default, t41.Transparency)

	if t41.Flag then
		arcane.SetFlags[t41.Flag] = function(p260, p261)
			t41:Set(p260, p261)
		end
	end

	return setmetatable(t41, arcane)
end
arcane.Config = function(p262)
	local v558 = arcane.Directory .. "/autoload.txt"
	local s1 = ""
	local s2 = ""
	local v561 = p262:Section({
		Name = "Config List",
		Side = 1
	})
	local v562 = p262:Section({
		Name = "Configs",
		Side = 2
	})
	local v563 = p262:Section({
		Name = "Themes",
		Side = 1
	})
	local v564 = v561:List({
		Name = "Config List",
		Empty = "It's still empty here",
		Items = arcane:GetConfigsList(),
		Callback = function(p263)
			s1 = p263 or ""
		end
	})

	v562:Textbox({
		Name = "Config Name",
		Placeholder = "my config",
		Callback = function(p264)
			s2 = p264
		end
	})
	v562:Button({
		Name = "Create",
		Callback = function()
			if s2 ~= "" then
				writefile(arcane.ConfigFolder .. "/" .. s2 .. ".json", arcane:GetConfig())
				arcane:GetConfigsList(v564)
				arcane:Notification({
					Name = "Config",
					Description = "Created " .. s2,
					Duration = 3,
					Icon = "check",
					Color = Color3.fromRGB(52, 255, 164)
				})
			end
		end
	})
	v562:Button({
		Name = "Save",
		Callback = function()
			if s1 ~= "" then
				writefile(arcane.ConfigFolder .. "/" .. s1 .. ".json", arcane:GetConfig())
				arcane:Notification({
					Name = "Config",
					Description = "Saved " .. s1,
					Duration = 3,
					Icon = "check",
					Color = Color3.fromRGB(52, 255, 164)
				})
			end
		end
	})
	v562:Button({
		Name = "Load",
		Callback = function()
			if s1 ~= "" and isfile(arcane.ConfigFolder .. "/" .. s1 .. ".json") then
				arcane:LoadConfig(readfile(arcane.ConfigFolder .. "/" .. s1 .. ".json"))
				arcane:Notification({
					Name = "Config",
					Description = "Loaded " .. s1,
					Duration = 3,
					Icon = "check",
					Color = Color3.fromRGB(52, 255, 164)
				})
			end
		end
	})
	v562:Button({
		Name = "Delete",
		Callback = function()
			if s1 ~= "" and isfile(arcane.ConfigFolder .. "/" .. s1 .. ".json") then
				delfile(arcane.ConfigFolder .. "/" .. s1 .. ".json")
				arcane:GetConfigsList(v564)
			end
		end
	})
	v562:Button({
		Name = "Refresh",
		Callback = function()
			arcane:GetConfigsList(v564)
		end
	})
	v562:Toggle({
		Name = "Auto Load",
		Default = isfile and isfile(v558) or false,
		Callback = function(p265)
			if not p265 or s1 == "" then
				if not p265 and isfile(v558) then
					delfile(v558)
				end
			else
				writefile(v558, s1)
			end
		end
	})
	arcane.Theming(v563)

	if isfile and isfile(v558) then
		local v565 = readfile(v558)

		if isfile(arcane.ConfigFolder .. "/" .. v565 .. ".json") then
			task.defer(function()
				arcane:LoadConfig(readfile(arcane.ConfigFolder .. "/" .. v565 .. ".json"))
				v564:Set(v565)
			end)
		end
	end

	return v564
end
arcane.Theming = function(p266)
	local t42 = {}

	p266:Dropdown({
		Name = "Preset Theme",
		Items = arcane.ThemeList,
		Default = arcane.CurrentTheme,
		Callback = function(p267)
			arcane:SetTheme(p267)

			for k, v in t42, nil, nil do
				v:Set(arcane.Theme[k])
			end
		end
	})

	for _, v in arcane.ThemeKeys, nil, nil do
		t42[v] = p266:Colorpicker({
			Name = v,
			Default = arcane.Theme[v],
			Flag = "Theme" .. v,
			Callback = function(p268)
				arcane:ChangeTheme(v, p268)
			end
		})
	end
end
getgenv().Arcane = arcane

return arcane
]=]

-- Arcane UI library bootstrap.
-- The Arcane library source is embedded below. If getgenv().Arcane is already
-- set (e.g. a previous execution), it will be unloaded and reloaded cleanly.
local function LoadArcane()
    if getgenv().Arcane and getgenv().Arcane.Unload then
        pcall(getgenv().Arcane.Unload, getgenv().Arcane)
    end
    -- Execute the embedded Arcane library. This sets getgenv().Arcane.
    local arcaneChunk, chunkErr = loadstring(ARCANE_SOURCE, "arcane_patched")
    if not arcaneChunk then
        error("Arcane failed to compile: " .. tostring(chunkErr))
    end
    local ok, err = pcall(arcaneChunk)
    if not ok then
        error("Arcane failed to run: " .. tostring(err))
    end
    local arcane = getgenv().Arcane
    if type(arcane) ~= "table" then
        error("Arcane did not register itself after execution.")
    end
    return arcane
end


local Library, T

local xDTaraZ = setmetatable({}, {
    __newindex = function(self, key, value)
        rawset(self, key, type(value) == "function" and LPH_JIT(value) or value)
    end,
})

xDTaraZ.Config = {
    Discord = "https://discord.gg/pzVJV34AH8",
    UpdateLog = {
        { "2026-10-10", "Silent Aim and Ragebot hit again after the game update\nFixed the game crashing when you shoot\nFixed ESP Team Check and health\nAim and ESP now include bots\nSkin pictures, turning skins off restores the stock look\nAuto Rebuy works from round 1, No Flash/No Smoke/FOV restore when off" },
        { "2026-10-03", "Aural V2 UI is back\nBetter executor support\nImproved Combat & Movement" },
    },
    SaveFolder = "Aural V2",
    StatusInterval = 1,
    AimRenderPriority = Enum.RenderPriority.Camera.Value + 1,
    RefireGap = 0.12,
    TriggerRay = 2000,
    SilentFocusTime = 1,
    SeeThrough = { "Characters", "Debris", "ThirdPersonWeaponStash" },
    EspCacheMax = 256,
    SoundSelfRange = 6,
    GhostSnap = 45,
    LeadExtra = 0.02,
    LeadMaxSpeed = 60,
    SpreadMethods = { "getTrueSpread", "getSpreadForConfig", "getMovementSpreadForConfig", "getBaseSpreadForConfig", "getBaseSpread" },
    SoundMaxMarks = 24,
    SoundColor = Color3.fromRGB(255, 196, 64),
    RedeemGap = 1.1,
    RebuyGap = 0.25,
    AlertTries = 20,
    AlertGap = 0.5,
    RequireTimeout = 5,
    MaxFails = 5,
    FailWindow = 10,
    CombatToggles = { "Aimbot", "Triggerbot", "Ragebot", "AimbotShowFov", "SilentShowFov" },
    ModuleFeatures = {
        Net = { "AutoRebuy" },
        Character = { "BunnyHop" },
        Skins = { "SkinChanger" },
    },
    Codes = {
        "1MGROUPMEMBERS", "MYFAULTYALL", "RIANOMINATED2026", "LORE", "DUST_II", "MICHAELSRETURN",
        "FREEDOM", "HAPPYBDAYYUUTO", "GAMEBROKE318", "OHNEPIXEL", "NEBULA", "REACTORDELAY", "BUTTERFLYCASE", "TRADEUPS",
    },
    BoneParts = {
        Head = { "Head" },
        Torso = { "UpperTorso", "Torso", "HumanoidRootPart" },
    },
    BuyStates = { ["Buy Period"] = true, ["Warmup"] = true },
    StickySlack = 1.5,
    HopGap = 0.05,
    HookSettle = 1,
    SkinFile = "BloxStrike/skins.json",
    SkinWears = { "Factory New", "Minimal Wear", "Field-Tested", "Well-Worn", "Battle-Scarred" },
    SkinKinds = { Melee = "Knives", Glove = "Gloves", Grenade = "Grenades", C4 = "Gear", ["Zeus x27"] = "Gear" },
    SkinOrder = { "Pistol", "SMG", "Rifle", "Sniper", "Heavy", "Shotgun", "Machine Gun", "Knives", "Gloves", "Grenades", "Gear" },
    SkinRanks = { Forbidden = 9, Special = 8, Red = 7, Pink = 6, Purple = 5, Blue = 4, LightBlue = 3, Gray = 2, White = 1 },
    SkinMainRows = 5,
    SkinArms = { ["Left Arm"] = true, ["Right Arm"] = true },
    GloveKey = "@Glove",
    FovColors = {
        Aimbot = Color3.fromRGB(232, 160, 76),
        Silent = Color3.fromRGB(110, 170, 255),
    },
    EspFocusColor = Color3.fromRGB(255, 214, 64),
    FovLayer = 50,
}

xDTaraZ.State = {
    Alive = true,
    Connections = {},
    Halted = {},
    Notices = {},
    AimTarget = nil,
    AimPart = nil,
    RageTarget = nil,
    RagePart = nil,
    SilentTarget = nil,
    Firing = false,
    PressedAt = 0,
    LastShot = 0,
    Shots = 0,
    Redirected = 0,
    Bought = {},
    LightSaved = nil,
    FovSaved = nil,
    ViewSaved = nil,
    Hooks = {},
    TriggerWarned = false,
    HopAt = 0,
    HopCrouched = false,
    SpaceHeld = false,
    FovBound = false,
    FovBase = 0,
}

xDTaraZ.Options = {
    Aimbot = false,
    AimbotSmooth = 1,
    AimbotBone = "Head",
    AimbotPriority = "Crosshair",
    AimbotFov = 150,
    AimbotShowFov = false,
    AimbotVisible = true,
    AimbotSticky = true,
    AimbotMaxDistance = 1500,
    SilentAim = false,
    SilentHitChance = 100,
    SilentHeadChance = 100,
    SilentPriority = "Crosshair",
    SilentFov = 220,
    SilentShowFov = false,
    SilentVisible = true,
    SilentMaxDistance = 2000,
    SilentPredict = false,
    Triggerbot = false,
    TriggerDelay = 0,
    TriggerHitChance = 100,
    Ragebot = false,
    RageVisible = true,
    RageMaxDistance = 2000,
    NoRecoil = false,
    NoSpread = false,
    Fullbright = false,
    NoFlash = false,
    NoSmoke = false,
    SoundEsp = false,
    SoundEspLife = 3,
    EspMemory = 5,
    CameraFov = false,
    CameraFovValue = 100,
    InfiniteJump = false,
    BunnyHop = false,
    BunnyCrouch = true,
    SkinChanger = false,
    AutoRebuy = false,
    AntiAfk = false,
}

---Executor capability probes. AuralV2 does not ship these, so the script owns them.
---Every probe runs the API on a throwaway fixture, because some executors ship stubs that pass type() but do nothing.
xDTaraZ.Compat = { Probes = {} }

xDTaraZ.Compat.Api = {
    HookFunction = hookfunction or replaceclosure,
    RestoreFunction = restorefunction,
    IsFunctionHooked = isfunctionhooked,
    GetGc = getgc,
    GetUpvalue = getupvalue or (debug and debug.getupvalue),
}

---Probes run inline (this __index cannot yield), so a probe that yields counts as unsupported.
xDTaraZ.Compat.Caps = setmetatable({}, {
    __index = function(caps, name)
        local probe = xDTaraZ.Compat.Probes[name]
        if not probe then return false end
        local thread = coroutine.create(probe)
        local ok, works = coroutine.resume(thread)
        local has = ok and coroutine.status(thread) == "dead" and works == true
        if coroutine.status(thread) == "suspended" then pcall(coroutine.close, thread) end
        rawset(caps, name, has)
        return has
    end,
})

function xDTaraZ.Compat.Probes.HookFunction()
    local hook = xDTaraZ.Compat.Api.HookFunction
    if not hook then return false end
    local function Target() return "plain" end
    local original = hook(Target, function() return "hooked" end)
    local works = Target() == "hooked" and type(original) == "function" and original() == "plain"
    if type(original) == "function" then pcall(hook, Target, original) end
    return works
end

function xDTaraZ.Compat.Probes.Gc()
    local getGc = xDTaraZ.Compat.Api.GetGc
    if not getGc then return false end
    local function Marker() return "gc" end
    for _, value in ipairs(getGc(false)) do
        if value == Marker then return true end
    end
    return false
end

function xDTaraZ.Compat.Probes.Upvalues()
    local getUpvalue = xDTaraZ.Compat.Api.GetUpvalue
    if not getUpvalue then return false end
    local marker = {}
    local function Holder() return marker end
    return getUpvalue(Holder, 1) == marker
end

---The FOV circles set these every frame; a shim that only knows Line would throw.
function xDTaraZ.Compat.Probes.Drawing()
    if type(Drawing) ~= "table" and type(Drawing) ~= "userdata" then return false end
    local okNew, circle = pcall(function() return Drawing.new("Circle") end)
    if not okNew or circle == nil then return false end
    local ok = pcall(function()
        circle.Thickness, circle.NumSides, circle.Filled = 1.5, 64, false
        circle.Position, circle.Radius, circle.Visible = Vector2.new(-100, -100), 10, false
    end)
    pcall(circle.Remove or circle.Destroy, circle)
    return ok
end

---@param caps string|string[]
---@return boolean, string?  false + the first missing cap
function xDTaraZ.Compat.Has(caps)
    for _, name in ipairs(type(caps) == "table" and caps or { caps }) do
        if not xDTaraZ.Compat.Caps[name] then return false, name end
    end
    return true
end

---Undoes a hook: the executor's restorefunction first, else `rehook`.
function xDTaraZ.Compat.Unhook(target, rehook)
    local api = xDTaraZ.Compat.Api
    if target and api.RestoreFunction and pcall(api.RestoreFunction, target) then
        if not api.IsFunctionHooked then return end
        local ok, still = pcall(api.IsFunctionHooked, target)
        if ok and not still then return end
    end
    rehook()
end

xDTaraZ.Caps = setmetatable({}, {
    __index = function(_, name)
        return xDTaraZ.Compat.Caps[name] == true
    end,
})

xDTaraZ.Util = {}

---@param detail any  extra context for the warn; the player only sees `text`
function xDTaraZ.Util.Alert(text, detail)
    warn("[BloxStrike] menu:", detail or text)
    task.spawn(function()
        for _ = 1, xDTaraZ.Config.AlertTries do
            if pcall(StarterGui.SetCore, StarterGui, "SendNotification", { Title = "Aural V2", Text = text, Duration = 10 }) then return end
            task.wait(xDTaraZ.Config.AlertGap)
        end
    end)
end

---@return table?  nil after the player was told on screen
---@return table?  nil after the player was told on screen
function xDTaraZ.Util.LoadLibrary()
    local ran, loaded = pcall(LoadArcane)
    if ran and type(loaded) == "table" then return loaded end
    xDTaraZ.Util.Alert("The menu failed to load on this executor: " .. (tostring(loaded):match("^[^\n]*") or ""), loaded)
    return nil
end

function xDTaraZ.Util.Try(label, fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[BloxStrike] " .. label .. ":", err) end
    return ok
end

function xDTaraZ.Util.Copy(text)
    local fn = setclipboard or toclipboard
    if not fn then return false end
    return pcall(fn, text)
end

---@return function?  original, nil when already hooked or the executor can't hook it
function xDTaraZ.Util.Hook(key, fn, replacement)
    if type(fn) ~= "function" or xDTaraZ.State.Hooks[key] or not xDTaraZ.Caps.HookFunction then return nil end
    local ok, original = pcall(hookfunction, fn, replacement)
    if not ok or type(original) ~= "function" then
        warn("[BloxStrike] hook " .. key .. ":", ok and "executor returned no original" or original)
        return nil
    end
    xDTaraZ.State.Hooks[key] = { Fn = fn, Original = original }
    return original
end

function xDTaraZ.Util.UnhookAll()
    for key, hook in pairs(xDTaraZ.State.Hooks) do
        local ok, err = pcall(xDTaraZ.Compat.Unhook, hook.Fn, function() hookfunction(hook.Fn, hook.Original) end)
        if not ok then warn("[BloxStrike] unhook " .. key .. ":", err) end
    end
    table.clear(xDTaraZ.State.Hooks)
end

function xDTaraZ.Util.Decode(raw)
    if type(raw) ~= "string" then return nil end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, raw)
    return ok and decoded or nil
end

function xDTaraZ:Connect(signal, handler)
    local conn = signal:Connect(handler)
    table.insert(self.State.Connections, conn)
    return conn
end

xDTaraZ.GameLib = { Missing = {} }

---@param parent Instance?     where it lives today
---@param home string          parent name a moved copy must still have
---@return Instance?           nil after a warning that names it
function xDTaraZ.GameLib.Find(parent, name, class, home)
    local found = parent and parent:FindFirstChild(name)
    if found and found:IsA(class) then return found end
    for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
        if desc.Name == name and desc:IsA(class) and desc.Parent and desc.Parent.Name == home then return desc end
    end
    xDTaraZ.GameLib.Missing[name] = "Absent"
    warn("[BloxStrike] " .. home .. "." .. name .. " not found, features that need it are blocked")
    return nil
end

---@return any  module, or nil when this executor can't require it (never throws)
function xDTaraZ.GameLib.Require(inst)
    if not (inst and inst:IsA("ModuleScript")) then return nil end
    local ok, mod = pcall(require, inst)
    if ok then return mod end

    local done, okAgain, again = false, false, nil
    task.spawn(function()
        pcall(setthreadidentity, 2)
        local read, identity = pcall(getthreadidentity)
        if read and identity == 2 then okAgain, again = pcall(require, inst) end
        done = true
    end)
    local deadline = osClock() + xDTaraZ.Config.RequireTimeout
    while not done and osClock() < deadline do task.wait() end
    if okAgain then return again end
    warn("[BloxStrike] require " .. inst.Name .. ":", mod)
    return nil
end

do
    local database = ReplicatedStorage:FindFirstChild("Database")
    local security = database and database:FindFirstChild("Security")
    local custom = database and database:FindFirstChild("Custom")
    local controllers = ReplicatedStorage:FindFirstChild("Controllers")
    local find = xDTaraZ.GameLib.Find
    xDTaraZ.GameLib.Net = xDTaraZ.GameLib.Require(find(security, "Remotes", "ModuleScript", "Security"))
    xDTaraZ.GameLib.Character = xDTaraZ.GameLib.Require(find(controllers, "CharacterController", "ModuleScript", "Controllers"))
    xDTaraZ.GameLib.Camera = xDTaraZ.GameLib.Require(find(controllers, "CameraController", "ModuleScript", "Controllers"))
    xDTaraZ.GameLib.WeaponFolder = find(custom, "Weapons", "Folder", "Custom")
    xDTaraZ.GameLib.Rarities = xDTaraZ.GameLib.Require(find(custom, "Rarities", "ModuleScript", "GameStats"))
    local vfx = ReplicatedStorage:FindFirstChild("Components") and ReplicatedStorage.Components:FindFirstChild("VFXLibary", true)
    xDTaraZ.GameLib.Smoke = xDTaraZ.GameLib.Require(find(vfx, "CreateVoxelSmoke", "ModuleScript", "VFXLibary"))
    xDTaraZ.GameLib.Flash = xDTaraZ.GameLib.Require(find(vfx, "FlashEffect", "ModuleScript", "VFXLibary"))
end

xDTaraZ.Weapons = {}
do
    local folder = xDTaraZ.GameLib.WeaponFolder
    for _, module in ipairs(folder and folder:GetChildren() or {}) do
        local data = module:IsA("ModuleScript") and xDTaraZ.GameLib.Require(module)
        if type(data) == "table" and data.FireRate then xDTaraZ.Weapons[module.Name] = data end
    end
end

xDTaraZ.Player = {}

function xDTaraZ.Player.Character()
    local chars = Workspace:FindFirstChild("Characters")
    return (chars and chars:FindFirstChild(LocalPlayer.Name)) or LocalPlayer.Character
end

function xDTaraZ.Player.Alive()
    local char = xDTaraZ.Player.Character()
    return char ~= nil and char.Parent ~= nil and tostring(LocalPlayer:GetAttribute("Dead")) ~= "true"
end

function xDTaraZ.Player.Humanoid()
    local char = xDTaraZ.Player.Character()
    return char and char:FindFirstChildOfClass("Humanoid")
end

---@return table?  the game's own local character state; nil outside a round
function xDTaraZ.Player.Body()
    local controller = xDTaraZ.GameLib.Character
    if not controller then return nil end
    local ok, body = pcall(controller.getCurrentCharacter)
    return ok and body or nil
end

function xDTaraZ.Player.Equipped()
    return xDTaraZ.Util.Decode(LocalPlayer:GetAttribute("CurrentEquipped"))
end

xDTaraZ.Target = { Motion = setmetatable({}, { __mode = "k" }) }

local losParams = RaycastParams.new()
losParams.FilterType = Enum.RaycastFilterType.Exclude
local losFilter = table.create(3)
local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude

function xDTaraZ.Target.Candidates()
    local list = {}
    local chars = Workspace:FindFirstChild("Characters")
    if not chars then return list end
    for _, model in ipairs(chars:GetChildren()) do
        if model.Name ~= LocalPlayer.Name and model:IsA("Model") then list[#list + 1] = model end
    end
    return list
end

function xDTaraZ.Target.Owner(model)
    return Players:FindFirstChild(model.Name)
end

---@return string?  team of a character: owner's Team attribute, else the team that wears this character model
function xDTaraZ.Target.TeamOf(model)
    local owner = model and xDTaraZ.Target.Owner(model)
    local team = owner and owner:GetAttribute("Team")
    if team then return team end
    local look = model and model:GetAttribute("CharacterName")
    if not look then return nil end
    if look == Workspace:GetAttribute("CTCharacter") then return "Counter-Terrorists" end
    if look == Workspace:GetAttribute("TCharacter") then return "Terrorists" end
    return nil
end

function xDTaraZ.Target.MyTeam()
    return LocalPlayer:GetAttribute("Team") or xDTaraZ.Target.TeamOf(xDTaraZ.Player.Character())
end

function xDTaraZ.Target.IsEnemy(model)
    if tostring(model:GetAttribute("Dead")) == "true" then return false end
    if not xDTaraZ.Target.Owner(model) and model:GetAttribute("Health") == nil then return false end
    if xDTaraZ.Target.FreeForAll() then return true end
    local mine = xDTaraZ.Target.MyTeam()
    if mine == nil then return false end
    return xDTaraZ.Target.TeamOf(model) ~= mine
end

---Samples every enemy's head each frame so shots can lead a moving target.
function xDTaraZ.Target.Track()
    local motion, now = xDTaraZ.Target.Motion, osClock()
    for _, model in ipairs(xDTaraZ.Target.Candidates()) do
        local head = model:FindFirstChild("Head")
        if not head then continue end
        local last = motion[head]
        if last and now > last.Time then
            local step = (head.Position - last.Pos) / (now - last.Time)
            last.Vel = last.Vel and last.Vel:Lerp(step, 0.5) or step
            last.Pos, last.Time = head.Position, now
        else
            motion[head] = { Pos = head.Position, Time = now, Vel = Vector3.zero }
        end
    end
end

---@return Vector3  where the part will be once the shot reaches the server
function xDTaraZ.Target.Lead(part)
    if not xDTaraZ.Options.SilentPredict then return part.Position end
    local track = xDTaraZ.Target.Motion[part] or xDTaraZ.Target.Motion[part.Parent and part.Parent:FindFirstChild("Head")]
    local vel = track and track.Vel or Vector3.zero
    if vel.Magnitude > xDTaraZ.Config.LeadMaxSpeed then return part.Position end
    local ok, ping = pcall(LocalPlayer.GetNetworkPing, LocalPlayer)
    return part.Position + vel * ((ok and ping or 0.05) + xDTaraZ.Config.LeadExtra)
end

---@return boolean  true in Deathmatch, where the team picker is only cosmetic
function xDTaraZ.Target.FreeForAll()
    return tostring(Workspace:GetAttribute("Gamemode")):find("Deathmatch") ~= nil
end

function xDTaraZ.Target.Part(model, bone)
    for _, name in ipairs(xDTaraZ.Config.BoneParts[bone] or xDTaraZ.Config.BoneParts.Head) do
        local part = model:FindFirstChild(name)
        if part and part:IsA("BasePart") then return part end
    end
    return model:FindFirstChild("HumanoidRootPart")
end

function xDTaraZ.Target.Visible(from, model, point)
    local skip = { Workspace.CurrentCamera, model }
    for _, name in ipairs(xDTaraZ.Config.SeeThrough) do
        local folder = Workspace:FindFirstChild(name)
        if folder then skip[#skip + 1] = folder end
    end
    wallParams.FilterDescendantsInstances = skip
    return Workspace:Raycast(from, point - from, wallParams) == nil
end

---@param cfg table  { Bone, Fov?, Visible, MaxDistance, Priority }  Fov nil = whole map
---@return Model?, BasePart?
function xDTaraZ.Target.Pick(cfg)
    local cam = Workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local center = cam.ViewportSize / 2
    local best, bestPart, bestScore

    for _, model in ipairs(xDTaraZ.Target.Candidates()) do
        if not xDTaraZ.Target.IsEnemy(model) then continue end
        local part = xDTaraZ.Target.Part(model, cfg.Bone)
        if not part then continue end
        local dist = (part.Position - origin).Magnitude
        if dist > cfg.MaxDistance then continue end

        local screen, onScreen = cam:WorldToViewportPoint(part.Position)
        local screenDist = (vector2New(screen.X, screen.Y) - center).Magnitude
        if cfg.Fov and (not onScreen or screenDist > cfg.Fov) then continue end
        if cfg.Visible and not xDTaraZ.Target.Visible(origin, model, part.Position) then continue end

        local score = dist
        if cfg.Priority == "Crosshair" then
            score = onScreen and screenDist or 1e6 + dist
        elseif cfg.Priority == "Health" then
            score = (tonumber(model:GetAttribute("Health")) or 100) * 1e4 + dist
        end
        if not bestScore or score < bestScore then best, bestPart, bestScore = model, part, score end
    end
    return best, bestPart
end

---@return boolean  still a valid lock, with a looser fov
function xDTaraZ.Target.StillValid(model, part, cfg)
    if not (model and part and part.Parent and xDTaraZ.Target.IsEnemy(model)) then return false end
    local cam = Workspace.CurrentCamera
    local origin = cam.CFrame.Position
    if (part.Position - origin).Magnitude > cfg.MaxDistance then return false end
    if cfg.Visible and not xDTaraZ.Target.Visible(origin, model, part.Position) then return false end
    if not cfg.Fov then return true end
    local screen, onScreen = cam:WorldToViewportPoint(part.Position)
    local center = cam.ViewportSize / 2
    return onScreen and (vector2New(screen.X, screen.Y) - center).Magnitude <= cfg.Fov * xDTaraZ.Config.StickySlack
end

---@return Model?  enemy under the crosshair right now
function xDTaraZ.Target.UnderCrosshair()
    local cam = Workspace.CurrentCamera
    losFilter[1], losFilter[2], losFilter[3] = xDTaraZ.Player.Character(), cam, nil
    losParams.FilterDescendantsInstances = losFilter
    local hit = Workspace:Raycast(cam.CFrame.Position, cam.CFrame.LookVector * xDTaraZ.Config.TriggerRay, losParams)
    if not hit then return nil end
    local chars = Workspace:FindFirstChild("Characters")
    local model = hit.Instance
    while model and model.Parent ~= chars do model = model.Parent end
    if model and model:IsA("Model") and xDTaraZ.Target.IsEnemy(model) then return model end
    return nil
end

local function roll(percent)
    return percent >= 100 or math.random() * 100 < percent
end

xDTaraZ.Aimbot = {}

function xDTaraZ.Aimbot.Config()
    local o = xDTaraZ.Options
    return { Bone = o.AimbotBone, Fov = o.AimbotFov, Visible = o.AimbotVisible, MaxDistance = o.AimbotMaxDistance, Priority = o.AimbotPriority }
end

function xDTaraZ.Aimbot.Step()
    local state, o = xDTaraZ.State, xDTaraZ.Options
    if not o.Aimbot then state.AimTarget, state.AimPart = nil, nil; return end
    local cfg = xDTaraZ.Aimbot.Config()
    if o.AimbotSticky and xDTaraZ.Target.StillValid(state.AimTarget, state.AimPart, cfg) then return end
    state.AimTarget, state.AimPart = xDTaraZ.Target.Pick(cfg)
end

---@param dt number  frame time from RenderStep
function xDTaraZ.Aimbot.Lock(dt)
    local o, state = xDTaraZ.Options, xDTaraZ.State
    local part, smooth = nil, 1
    if o.Ragebot and state.RagePart and state.RagePart.Parent then
        part = state.RagePart
    elseif o.Aimbot and state.AimPart and state.AimPart.Parent then
        part, smooth = state.AimPart, math.max(o.AimbotSmooth, 1)
    end
    if not part then return end
    local cam = Workspace.CurrentCamera
    local origin = cam.CFrame.Position
    local want = (part.Position - origin).Unit
    local alpha = 1 - (1 - 1 / smooth) ^ ((dt or 1 / 60) * 60)
    local look = smooth <= 1 and want or cam.CFrame.LookVector:Lerp(want, alpha).Unit
    cam.CFrame = cframeLookAt(origin, origin + look)
end

xDTaraZ.Silent = {}

---@param forced boolean  ragebot shot: always hits, no fov
function xDTaraZ.Silent.Config(bone, forced)
    local o = xDTaraZ.Options
    if forced then return { Bone = bone, Visible = o.RageVisible, MaxDistance = o.RageMaxDistance, Priority = "Distance" } end
    return { Bone = bone, Fov = o.SilentFov, Visible = o.SilentVisible, MaxDistance = o.SilentMaxDistance, Priority = o.SilentPriority }
end

---@return BasePart?  part this shot should go to, nil = shoot where you look
function xDTaraZ.Silent.Aim()
    local o, state = xDTaraZ.Options, xDTaraZ.State
    state.SilentTarget = nil
    if not (o.SilentAim or o.Ragebot) then return nil end
    local forced = o.Ragebot
    if not forced and not roll(o.SilentHitChance) then return nil end
    local bone = (forced or roll(o.SilentHeadChance)) and "Head" or "Torso"
    local target, part = xDTaraZ.Target.Pick(xDTaraZ.Silent.Config(bone, forced))
    state.SilentTarget = target
    return part
end

---The server checks bullets against where you really look, so each new bullet turns the camera to the target and the view goes back as the shot is sent, before anything is drawn.
function xDTaraZ.Silent.InstallHook()
    local gun = xDTaraZ.Guns.FindClass()
    if gun then
        local original
        original = xDTaraZ.Util.Hook("Shoot", gun.shoot, function(...)
            local state = xDTaraZ.State
            state.LastShot = osClock()
            state.Shots += 1
            return original(...)
        end)
    end
    local bullet = xDTaraZ.Guns.FindBullet()
    if bullet and type(bullet.create) == "function" then
        local create
        create = xDTaraZ.Util.Hook("Bullet", bullet.create, function(...)
            xDTaraZ.Silent.Flick()
            return create(...)
        end)
    end
    xDTaraZ.Guns.HookSpread()

    local net = xDTaraZ.GameLib.Net
    local packet = net and net.Inventory and net.Inventory.ShootWeapon
    if not packet then return end
    local send
    send = xDTaraZ.Util.Hook("Send", packet.Send, function(...)
        xDTaraZ.Silent.RestoreView()
        return send(...)
    end)
end

---Turns the camera onto the silent aim target for this bullet.
function xDTaraZ.Silent.Flick()
    local ok, part = pcall(xDTaraZ.Silent.Aim)
    local cam, state = Workspace.CurrentCamera, xDTaraZ.State
    if not (ok and part and cam) then return end
    state.ViewSaved = state.ViewSaved or cam.CFrame
    cam.CFrame = cframeLookAt(cam.CFrame.Position, xDTaraZ.Target.Lead(part))
    state.Redirected += 1
end

---Puts your view back before the game's camera runs, so silent aim never moves what you see.
function xDTaraZ.Silent.RestoreView()
    local state, cam = xDTaraZ.State, Workspace.CurrentCamera
    if not state.ViewSaved then return end
    if cam then cam.CFrame = state.ViewSaved end
    state.ViewSaved = nil
end

xDTaraZ.Trigger = {}

function xDTaraZ.Trigger.Press(down)
    if down and xDTaraZ.UI.MenuOpen() then return end
    xDTaraZ.State.Firing = down
    if down then xDTaraZ.State.PressedAt = osClock() end
    local center = Workspace.CurrentCamera.ViewportSize / 2
    pcall(VirtualInputManager.SendMouseButtonEvent, VirtualInputManager, center.X, center.Y, 0, down, game, 0)
end

---@param want boolean  holds auto guns and re-clicks semi-auto ones
function xDTaraZ.Trigger.Fire(want)
    local state, now = xDTaraZ.State, osClock()
    if not want then
        if state.Firing then xDTaraZ.Trigger.Press(false) end
        return
    end
    if not state.Firing then
        xDTaraZ.Trigger.Press(true)
        return
    end
    local gap = xDTaraZ.Config.RefireGap
    if now - state.PressedAt > gap and now - state.LastShot > gap then xDTaraZ.Trigger.Press(false) end
end

function xDTaraZ.Trigger.Wanted()
    local o, state = xDTaraZ.Options, xDTaraZ.State
    if not o.Triggerbot then return false end
    local model = xDTaraZ.Target.UnderCrosshair()
    if model ~= state.TriggerModel then
        state.TriggerModel = model
        state.TriggerSeen = model and osClock() or nil
        state.TriggerRoll = model ~= nil and roll(o.TriggerHitChance)
    end
    if not model or not state.TriggerRoll then return false end
    return osClock() - state.TriggerSeen >= o.TriggerDelay / 1000
end

xDTaraZ.Rage = {}

function xDTaraZ.Rage.Step()
    local state = xDTaraZ.State
    if not xDTaraZ.Options.Ragebot then state.RageTarget, state.RagePart = nil, nil; return false end
    state.RageTarget, state.RagePart = xDTaraZ.Target.Pick(xDTaraZ.Silent.Config("Head", true))
    return state.RageTarget ~= nil
end

xDTaraZ.Combat = { Circles = {} }

---@return ScreenGui  made once; hidden gui first, then CoreGui, then PlayerGui
function xDTaraZ.Combat.Screen()
    local screen = xDTaraZ.Combat.Gui
    if screen and screen.Parent then return screen end

    screen = Instance.new("ScreenGui")
    screen.Name = "AuralFov"
    screen.IgnoreGuiInset = true
    screen.ResetOnSpawn = false
    screen.DisplayOrder = xDTaraZ.Config.FovLayer

    local function Mount(parent) screen.Parent = parent end
    local okHui, hui = pcall(gethui)
    local mounted = okHui and hui ~= nil and pcall(Mount, hui)
    if not mounted then mounted = pcall(Mount, game:GetService("CoreGui")) end
    if not mounted then Mount(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end

    xDTaraZ.Combat.Gui = screen
    return screen
end

---@return table  { Drawing = circle }, or { Frame = ring } drawn with Gui when Drawing is missing
function xDTaraZ.Combat.NewCircle(color)
    if xDTaraZ.Caps.Drawing then
        local circle = Drawing.new("Circle")
        circle.Thickness, circle.NumSides, circle.Filled, circle.Color = 1.5, 64, false, color
        return { Drawing = circle }
    end
    local frame = Instance.new("Frame")
    frame.AnchorPoint = vector2New(0.5, 0.5)
    frame.BackgroundTransparency = 1
    local round = Instance.new("UICorner")
    round.CornerRadius = UDim.new(1, 0)
    round.Parent = frame
    local edge = Instance.new("UIStroke")
    edge.Thickness, edge.Color = 1.5, color
    edge.Parent = frame
    frame.Parent = xDTaraZ.Combat.Screen()
    return { Frame = frame }
end

function xDTaraZ.Combat.Circle(key, show, radius)
    local circle = xDTaraZ.Combat.Circles[key]
    if not circle then
        if not show then return end
        circle = xDTaraZ.Combat.NewCircle(xDTaraZ.Config.FovColors[key])
        xDTaraZ.Combat.Circles[key] = circle
    end
    local center = Workspace.CurrentCamera.ViewportSize / 2
    local drawing, frame = circle.Drawing, circle.Frame
    if drawing then
        drawing.Visible, drawing.Position, drawing.Radius = show, center, radius
        return
    end
    frame.Visible = show
    frame.Position = UDim2.fromOffset(center.X, center.Y)
    frame.Size = UDim2.fromOffset(radius * 2, radius * 2)
end

function xDTaraZ.Combat.Step()
    local o, state = xDTaraZ.Options, xDTaraZ.State
    xDTaraZ.Combat.Circle("Aimbot", o.AimbotShowFov, o.AimbotFov)
    xDTaraZ.Combat.Circle("Silent", o.SilentShowFov, o.SilentFov)
    if not xDTaraZ.Player.Alive() then
        state.AimTarget, state.AimPart, state.RageTarget, state.RagePart, state.SilentTarget = nil, nil, nil, nil, nil
        xDTaraZ.Trigger.Fire(false)
        return
    end
    if o.SilentAim or o.Ragebot then xDTaraZ.Target.Track() end
    xDTaraZ.Aimbot.Step()
    local rage = xDTaraZ.Rage.Step()
    xDTaraZ.Trigger.Fire(rage or xDTaraZ.Trigger.Wanted())
end

function xDTaraZ.Combat.Rest()
    local state = xDTaraZ.State
    state.AimTarget, state.AimPart, state.RageTarget, state.RagePart, state.SilentTarget = nil, nil, nil, nil, nil
    xDTaraZ.Trigger.Fire(false)
    for key in pairs(xDTaraZ.Combat.Circles) do
        xDTaraZ.Combat.Circle(key, false, 0)
    end
end

function xDTaraZ.Combat.Start()
    RunService:BindToRenderStep("xDTaraZView", Enum.RenderPriority.First.Value, xDTaraZ.Silent.RestoreView)
    RunService:BindToRenderStep("xDTaraZAim", xDTaraZ.Config.AimRenderPriority, xDTaraZ.Aimbot.Lock)
    xDTaraZ:Connect(RunService.Heartbeat, function()
        local ok, err = pcall(xDTaraZ.Combat.Step)
        if ok then
            xDTaraZ.Faults.Clear("Combat")
        else
            xDTaraZ.Faults.Report("Combat", err, xDTaraZ.Config.CombatToggles, xDTaraZ.Combat.Rest)
        end
    end)
end

function xDTaraZ.Combat.Unload()
    xDTaraZ.Trigger.Fire(false)
    pcall(RunService.UnbindFromRenderStep, RunService, "xDTaraZAim")
    pcall(RunService.UnbindFromRenderStep, RunService, "xDTaraZView")
    for key, circle in pairs(xDTaraZ.Combat.Circles) do
        xDTaraZ.Combat.Circles[key] = nil
        if circle.Frame then
            circle.Frame:Destroy()
        else
            pcall(function() circle.Drawing:Remove() end)
        end
    end
    if xDTaraZ.Combat.Gui then
        xDTaraZ.Combat.Gui:Destroy()
        xDTaraZ.Combat.Gui = nil
    end
end

xDTaraZ.Guns = { Signature = nil, Warned = false }

function xDTaraZ.Guns.HookKick()
    local cam = xDTaraZ.GameLib.Camera
    if not cam then return end
    local kick, aim, rotation
    kick = xDTaraZ.Util.Hook("Kick", cam.weaponKick, function(...)
        if xDTaraZ.Options.NoRecoil then return end
        return kick(...)
    end)
    aim = xDTaraZ.Util.Hook("Recoil", cam.setWeaponRecoil, function(...)
        if xDTaraZ.Options.NoRecoil then return end
        return aim(...)
    end)
    rotation = xDTaraZ.Util.Hook("KickRotation", cam.getWeaponKickRotation, function(...)
        if xDTaraZ.Options.NoRecoil then return Vector3.zero end
        return rotation(...)
    end)
end

---@return boolean  true while any scope or zoom is up
function xDTaraZ.Guns.Scoped()
    if LocalPlayer:GetAttribute("IsSniperScoped") == true then return true end
    local cam = xDTaraZ.GameLib.Camera
    local getter = cam and cam.getTargetFOV
    if type(getter) ~= "function" then return false end
    local ok, target = pcall(getter)
    if not ok or type(target) ~= "number" then return false end

    local state = xDTaraZ.State
    if target > state.FovBase then state.FovBase = target end
    return target < state.FovBase
end

function xDTaraZ.Guns.StepFov()
    local camera, state = Workspace.CurrentCamera, xDTaraZ.State
    if not camera then return end
    if not xDTaraZ.Options.CameraFov then
        if state.FovSaved then camera.FieldOfView, state.FovSaved = state.FovSaved, nil end
        state.FovBase = 0
        return
    end
    if xDTaraZ.Guns.Scoped() then return end
    state.FovSaved = state.FovSaved or camera.FieldOfView
    camera.FieldOfView = xDTaraZ.Options.CameraFovValue
end

function xDTaraZ.Guns.BindFov()
    local state = xDTaraZ.State
    if state.FovBound then return end
    state.FovBound = true
    RunService:BindToRenderStep("xDTaraZFov", Enum.RenderPriority.Camera.Value + 3, xDTaraZ.Guns.StepFov)
end

function xDTaraZ.Guns.UnbindFov()
    local state, camera = xDTaraZ.State, Workspace.CurrentCamera
    if state.FovSaved and camera then camera.FieldOfView, state.FovSaved = state.FovSaved, nil end
    state.FovBound = false
    pcall(RunService.UnbindFromRenderStep, RunService, "xDTaraZFov")
end

function xDTaraZ.Guns.FindClass()
    if not xDTaraZ.Caps.Gc or not xDTaraZ.Caps.HookFunction then return nil end
    for _, entry in ipairs(getgc(true)) do
        if type(entry) == "table" and rawget(entry, "getSpread") and rawget(entry, "shoot") and rawget(entry, "setupRecoil") then return entry end
    end
    return nil
end

---@return table?  the bullet class that rolls spread for every shot
function xDTaraZ.Guns.FindBullet()
    if not xDTaraZ.Caps.Gc or not xDTaraZ.Caps.HookFunction then return nil end
    for _, entry in ipairs(getgc(true)) do
        if type(entry) == "table" and rawget(entry, "getTrueSpread") and rawget(entry, "getSpreadForConfig") then return entry end
    end
    return nil
end

---Every spread roll the bullet class makes returns 0 with No Spread, and while a silent aim shot is being built.
function xDTaraZ.Guns.HookSpread()
    local bullet = xDTaraZ.Guns.FindBullet()
    if not bullet then return end
    for _, method in ipairs(xDTaraZ.Config.SpreadMethods) do
        if type(bullet[method]) ~= "function" then continue end
        local original
        original = xDTaraZ.Util.Hook("Spread:" .. method, bullet[method], function(...)
            local value = original(...)
            if type(value) == "number" and (xDTaraZ.Options.NoSpread or xDTaraZ.State.ViewSaved) then return 0 end
            return value
        end)
    end
end

xDTaraZ.Esp = { Count = 0, Decoded = {}, CacheSize = 0, Ghosts = {}, Folder = nil }

---@return table?  JSON attribute decoded once per distinct raw string
function xDTaraZ.Esp.Attr(owner, key)
    local raw = owner:GetAttribute(key)
    if type(raw) ~= "string" then return nil end
    local esp = xDTaraZ.Esp
    if esp.Decoded[raw] == nil then
        esp.CacheSize += 1
        if esp.CacheSize > xDTaraZ.Config.EspCacheMax then table.clear(esp.Decoded); esp.CacheSize = 1 end
        esp.Decoded[raw] = xDTaraZ.Util.Decode(raw) or false
    end
    return esp.Decoded[raw] or nil
end

---@return string  " C4 Kit Helmet Scoped" style tags, "" when none
function xDTaraZ.Esp.Flags(owner)
    if not owner then return "" end
    local flags = {}
    local armor = xDTaraZ.Esp.Attr(owner, "Armor")
    local bomb = xDTaraZ.Esp.Attr(owner, "Slot5")
    if bomb and bomb.Weapon == "C4" then flags[#flags + 1] = "C4" end
    if owner:GetAttribute("HasDefuseKit") == true then table.insert(flags, "Kit") end
    if armor and type(armor.Type) == "string" and armor.Type:find("Helmet") then flags[#flags + 1] = "Helmet" end
    if owner:GetAttribute("IsSniperScoped") == true then flags[#flags + 1] = "Scoped" end
    return #flags > 0 and " " .. table.concat(flags, " ") or ""
end

---@return Model?  whatever aimbot, silent aim or ragebot is locked on
function xDTaraZ.Esp.Focus()
    local state = xDTaraZ.State
    local silent = osClock() - state.LastShot < xDTaraZ.Config.SilentFocusTime and state.SilentTarget or nil
    return state.AimTarget or silent or state.RageTarget
end

---@return table  one lasting stand-in per player, so a body that blinks in and out of view never rebuilds its box
function xDTaraZ.Esp.Ghost(name)
    local esp = xDTaraZ.Esp
    local ghost = esp.Ghosts[name]
    if ghost and ghost.Model.Parent then return ghost end
    if not (esp.Folder and esp.Folder.Parent) then
        esp.Folder = Instance.new("Folder")
        esp.Folder.Name = "xDTaraZGhosts"
        esp.Folder.Parent = Workspace.CurrentCamera
    end
    local model = Instance.new("Model")
    model.Name = name
    local root = Instance.new("Part")
    root.Name, root.Size, root.Transparency = "HumanoidRootPart", Vector3.new(2, 2, 1), 1
    root.Anchored, root.CanCollide, root.CanQuery, root.CanTouch = true, false, false, false
    root.Parent = model
    model.PrimaryPart = root
    model.Parent = esp.Folder
    ghost = { Model = model, Root = root, Seen = 0, Heard = 0 }
    esp.Ghosts[name] = ghost
    return ghost
end

---@return table  xDTaraZ.Visuals row for one player, live body or last known spot
function xDTaraZ.Esp.Row(ghost, model, owner, mine, focus)
    local equipped = owner and xDTaraZ.Esp.Attr(owner, "CurrentEquipped")
    local label = owner and owner.DisplayName or ghost.Model.Name
    if equipped and equipped.Name then label = label .. " [" .. equipped.Name .. "]" end
    local live = model and model:FindFirstChild("HumanoidRootPart")
    if not live then label = label .. " ?" end
    return {
        Model = ghost.Model,
        Root = live or ghost.Root,
        Adornee = model or false,
        Name = label .. xDTaraZ.Esp.Flags(owner),
        Health = tonumber(owner and owner:GetAttribute("Health")) or tonumber(model and model:GetAttribute("Health")) or 100,
        MaxHealth = tonumber(model and model:GetAttribute("MaxHealth")) or 100,
        Friendly = ghost.Friendly,
        Color = model ~= nil and model == focus and xDTaraZ.Config.EspFocusColor or nil,
    }
end

---@return table[]  targets in the shape xDTaraZ.Visuals expects; bots count as enemies
function xDTaraZ.Esp.Targets()
    local esp, now = xDTaraZ.Esp, osClock()
    local list = {}
    local mine = xDTaraZ.Target.MyTeam()
    local ffa = xDTaraZ.Target.FreeForAll()
    local focus = xDTaraZ.Esp.Focus()
    pcall(xDTaraZ.Sound.Install)
    local live = {}
    for _, model in ipairs(xDTaraZ.Target.Candidates()) do
        if xDTaraZ.Esp.IsDead(model, xDTaraZ.Target.Owner(model)) then
            xDTaraZ.Esp.Forget(model.Name)
            continue
        end
        local hrp = model:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end
        local ghost = esp.Ghost(model.Name)
        ghost.Root.CFrame, ghost.Seen = hrp.CFrame, now
        ghost.Friendly = not ffa and mine ~= nil and xDTaraZ.Target.TeamOf(model) == mine
        live[model.Name] = true
        list[#list + 1] = esp.Row(ghost, model, xDTaraZ.Target.Owner(model), mine, focus)
    end
    local memory = xDTaraZ.Options.EspMemory
    for name, ghost in pairs(esp.Ghosts) do
        if live[name] then continue end
        local owner = Players:FindFirstChild(name)
        if owner and xDTaraZ.Esp.IsDead(nil, owner) then
            xDTaraZ.Esp.Forget(name)
            continue
        end
        local gone = not ghost.Model.Parent or (not owner and now - ghost.Seen > memory)
        if gone or now - math.max(ghost.Seen, ghost.Heard) > memory then
            if gone and not owner then
                ghost.Model:Destroy()
                esp.Ghosts[name] = nil
            end
            continue
        end
        list[#list + 1] = esp.Row(ghost, nil, owner, mine, focus)
    end
    esp.Count = #list
    return list
end

---@return boolean  true once a player or bot is dead, by body flag or 0 health
function xDTaraZ.Esp.IsDead(model, owner)
    if model and (tostring(model:GetAttribute("Dead")) == "true" or (tonumber(model:GetAttribute("Health")) or 1) <= 0) then return true end
    if owner and (owner:GetAttribute("Dead") == true or (tonumber(owner:GetAttribute("Health")) or 1) <= 0) then return true end
    return false
end

---Drops the remembered spot of someone who died, so no box stays where they fell.
function xDTaraZ.Esp.Forget(name)
    local ghost = xDTaraZ.Esp.Ghosts[name]
    if ghost then ghost.Seen, ghost.Heard = 0, 0 end
end

---Moves the stand-in of the hidden enemy closest to a footstep or shot, so hidden players keep a box.
function xDTaraZ.Esp.Hear(pos, weapon)
    local esp, now = xDTaraZ.Esp, osClock()
    local best, bestDist = nil, xDTaraZ.Config.GhostSnap
    for name, ghost in pairs(esp.Ghosts) do
        if ghost.Friendly or now - ghost.Seen < 0.3 then continue end
        local owner = Players:FindFirstChild(name)
        local equipped = owner and xDTaraZ.Esp.Attr(owner, "CurrentEquipped")
        if weapon and equipped and equipped.Name and equipped.Name ~= weapon then continue end
        local dist = (ghost.Root.Position - pos).Magnitude
        if dist < bestDist then best, bestDist = ghost, dist end
    end
    if not best then return end
    best.Root.CFrame = CFrame.new(pos + Vector3.new(0, 2.5, 0))
    best.Heard = now
end

xDTaraZ.Sound = { Marks = {}, Entry = nil, Original = nil, Folder = nil }

---Hooks into the game's own sound listener: every footstep and shot of every player arrives with its position, even behind walls.
function xDTaraZ.Sound.Install()
    local sound = xDTaraZ.Sound
    if sound.Entry then return true end
    local net = xDTaraZ.GameLib.Net
    local packet = net and net.Sound and net.Sound.ReplicateSound
    if not (packet and xDTaraZ.Caps.Upvalues) then return false end
    local ok, listeners = pcall(function() return getupvalues(packet.Listen)[1] end)
    if not ok or type(listeners) ~= "table" then return false end
    for _, entry in ipairs(listeners) do
        if type(entry) == "table" and type(entry.callback) == "function" then
            sound.Entry, sound.Original = entry, entry.callback
            entry.callback = function(info, ...)
                xDTaraZ.Util.Try("sound esp", xDTaraZ.Sound.Heard, info)
                return sound.Original(info, ...)
            end
            return true
        end
    end
    return false
end

function xDTaraZ.Sound.Uninstall()
    local sound = xDTaraZ.Sound
    if sound.Entry then sound.Entry.callback = sound.Original end
    sound.Entry, sound.Original = nil, nil
    for _, mark in ipairs(sound.Marks) do mark.Gui:Destroy() end
    table.clear(sound.Marks)
end

---@return boolean  true when the sound came from you or a teammate you can see
function xDTaraZ.Sound.Friendly(pos)
    local range = xDTaraZ.Config.SoundSelfRange
    local me = xDTaraZ.Player.Character()
    if me and (me:GetPivot().Position - pos).Magnitude < range then return true end
    if xDTaraZ.Target.FreeForAll() then return false end
    for _, model in ipairs(xDTaraZ.Target.Candidates()) do
        if not xDTaraZ.Target.IsEnemy(model) and (model:GetPivot().Position - pos).Magnitude < range then return true end
    end
    return false
end

function xDTaraZ.Sound.Heard(info)
    if type(info) ~= "table" or typeof(info.Position) ~= "Vector3" then return end
    local floor = info.Class == "FloorSounds"
    if not floor and info.Name ~= "Shoot" then return end
    if xDTaraZ.Sound.Friendly(info.Position) then return end
    xDTaraZ.Esp.Hear(info.Position, not floor and tostring(info.Class) or nil)
    if xDTaraZ.Options.SoundEsp then xDTaraZ.Sound.Mark(info.Position, floor and "Steps" or tostring(info.Class)) end
end

function xDTaraZ.Sound.Mark(pos, label)
    local sound = xDTaraZ.Sound
    if not (sound.Folder and sound.Folder.Parent) then
        sound.Folder = Instance.new("Folder")
        sound.Folder.Name = "xDTaraZSounds"
        sound.Folder.Parent = Workspace.Terrain
    end
    if #sound.Marks >= xDTaraZ.Config.SoundMaxMarks then
        local removed = table.remove(sound.Marks, 1)
        if removed and removed.Gui then removed.Gui:Destroy() end
    end
    local holder = Instance.new("Attachment")
    holder.WorldPosition = pos
    local gui = Instance.new("BillboardGui")
    gui.AlwaysOnTop, gui.Size, gui.LightInfluence = true, UDim2.fromOffset(120, 34), 0
    local text = Instance.new("TextLabel")
    text.BackgroundTransparency, text.Size, text.Font, text.TextSize = 1, UDim2.fromScale(1, 1), Enum.Font.GothamBold, 13
    text.TextColor3, text.TextStrokeTransparency = xDTaraZ.Config.SoundColor, 0.3
    text.Parent = gui
    gui.Parent = holder
    holder.Parent = Workspace.Terrain
    gui.Adornee = holder
    sound.Marks[#sound.Marks + 1] = { Gui = holder, Text = text, Label = label, Born = osClock() }
end

---Fades markers and keeps their distance fresh.
function xDTaraZ.Sound.Step()
    local sound, life = xDTaraZ.Sound, xDTaraZ.Options.SoundEspLife
    local cam = Workspace.CurrentCamera
    for index = #sound.Marks, 1, -1 do
        local mark = sound.Marks[index]
        local age = osClock() - mark.Born
        if age > life or not xDTaraZ.Options.SoundEsp then
            mark.Gui:Destroy()
            table.remove(sound.Marks, index)
        else
            local dist = cam and math.floor((mark.Gui.WorldPosition - cam.CFrame.Position).Magnitude) or 0
            mark.Text.Text = ("%s\n%dm"):format(mark.Label, dist)
            mark.Text.TextTransparency = age / life * 0.8
        end
    end
end

xDTaraZ.World = {}

function xDTaraZ.World.Step()
    local opts, state = xDTaraZ.Options, xDTaraZ.State
    if opts.Fullbright then
        state.LightSaved = state.LightSaved or { Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.GlobalShadows, Lighting.Ambient }
        Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.GlobalShadows = 2, 14, 1e6, false
        Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    elseif state.LightSaved then
        Lighting.Brightness, Lighting.ClockTime, Lighting.FogEnd, Lighting.GlobalShadows, Lighting.Ambient = table.unpack(state.LightSaved)
        state.LightSaved = nil
    end
end

---No Flash and No Smoke stop the game from making the effect at all, and clear what is already on screen.
function xDTaraZ.World.HookEffects()
    local smoke, flash = xDTaraZ.GameLib.Smoke, xDTaraZ.GameLib.Flash
    if smoke and type(smoke.Create) == "function" then
        local create
        create = xDTaraZ.Util.Hook("Smoke", smoke.Create, function(...)
            if xDTaraZ.Options.NoSmoke then return nil end
            return create(...)
        end)
    end
    if flash and type(flash.Flash) == "function" then
        local blind
        blind = xDTaraZ.Util.Hook("Flash", flash.Flash, function(...)
            if xDTaraZ.Options.NoFlash then return nil end
            return blind(...)
        end)
    end
    if xDTaraZ.Options.NoSmoke and smoke then pcall(smoke.DestroyAll) end
    if xDTaraZ.Options.NoFlash and flash then pcall(flash.CancelFlash) end
end

function xDTaraZ.World.OnIdled()
    if not xDTaraZ.Options.AntiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(vector2New())
    end)
end

function xDTaraZ.World.OnJump()
    if not xDTaraZ.Options.InfiniteJump or xDTaraZ.Player.Body() then return end
    local hum = xDTaraZ.Player.Humanoid()
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end

function xDTaraZ.World.SetCrouch(down)
    local state = xDTaraZ.State
    if state.HopCrouched == down then return end
    state.HopCrouched = down
    local controller = xDTaraZ.GameLib.Character
    if not controller then return end
    if not down and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then return end
    controller.crouch(down)
end

function xDTaraZ.World.OnSpace(input, down, processed)
    if input.KeyCode ~= Enum.KeyCode.Space then return end
    if down and UserInputService:GetFocusedTextBox() then return end
    xDTaraZ.State.SpaceHeld = down
end

function xDTaraZ.World.Hop()
    local opts, state = xDTaraZ.Options, xDTaraZ.State
    local body = opts.BunnyHop and state.SpaceHeld and xDTaraZ.Player.Alive() and xDTaraZ.Player.Body()
    if not body or UserInputService:GetFocusedTextBox() then
        xDTaraZ.World.SetCrouch(false)
        return
    end
    local controller = xDTaraZ.GameLib.Character
    local grounded = body.OnGround == true
    xDTaraZ.World.SetCrouch(opts.BunnyCrouch and not grounded)
    controller.jump(false)
    if not grounded or osClock() - state.HopAt < xDTaraZ.Config.HopGap then return end
    state.HopAt = osClock()
    controller.jump()
end

function xDTaraZ.World.HopStep()
    local ok, err = pcall(xDTaraZ.World.Hop)
    if ok then
        xDTaraZ.Faults.Clear("Bunny Hop")
    else
        xDTaraZ.Faults.Report("Bunny Hop", err, { "BunnyHop" }, xDTaraZ.World.Hop)
    end
end

function xDTaraZ.World.Rejoin()
    pcall(TeleportService.TeleportToPlaceInstance, TeleportService, game.PlaceId, game.JobId, LocalPlayer)
end

function xDTaraZ.World.ServerHop()
    pcall(TeleportService.Teleport, TeleportService, game.PlaceId, LocalPlayer)
end

xDTaraZ.Skins = { Map = {}, Applied = setmetatable({}, { __mode = "k" }), Catalog = nil, Rarity = {}, Images = {}, Colors = {}, Originals = setmetatable({}, { __mode = "k" }) }

function xDTaraZ.Skins.Folder()
    local assets = ReplicatedStorage:FindFirstChild("Assets")
    return assets and assets:FindFirstChild("Skins")
end

---@return string?  category name, nil = not a weapon look
function xDTaraZ.Skins.CategoryOf(name, kind)
    local mapped = xDTaraZ.Config.SkinKinds[kind]
    if mapped then return mapped end
    if kind ~= "Weapon" then return nil end
    local gun = xDTaraZ.Weapons[name]
    return gun and gun.Type or "Other"
end

function xDTaraZ.Skins.Build()
    local skins = xDTaraZ.Skins
    local folder = skins.Folder()
    local listing = xDTaraZ.Util.Decode(ReplicatedStorage:GetAttribute("AvaiableSkins")) or {}
    local ranks = xDTaraZ.Config.SkinRanks
    local catalog = {}
    for name, entries in pairs(listing) do
        if type(entries) ~= "table" or not (folder and folder:FindFirstChild(name)) then continue end
        local _, first = next(entries)
        local category = skins.CategoryOf(name, type(first) == "table" and first.type)
        if not category then continue end
        catalog[category] = catalog[category] or {}
        table.insert(catalog[category], name)
        skins.Rarity[name], skins.Images[name], skins.Colors[name] = {}, {}, {}
        for skin, entry in pairs(entries) do
            if type(entry) ~= "table" then continue end
            skins.Rarity[name][skin] = ranks[entry.rarity] or 0
            local look = type(entry.wearImages) == "table" and entry.wearImages[1]
            skins.Images[name][skin] = look and look.assetId
            local rarity = xDTaraZ.GameLib.Rarities and xDTaraZ.GameLib.Rarities[entry.rarity]
            skins.Colors[name][skin] = type(rarity) == "table" and rarity.Color or nil
        end
    end
    for _, names in pairs(catalog) do table.sort(names) end
    skins.Catalog = catalog
end

---@return string[]  categories in display order
function xDTaraZ.Skins.Categories()
    if not xDTaraZ.Skins.Catalog then xDTaraZ.Skins.Build() end
    local list, seen = {}, {}
    for _, category in ipairs(xDTaraZ.Config.SkinOrder) do
        if xDTaraZ.Skins.Catalog[category] then list[#list + 1] = category; seen[category] = true end
    end
    for category in pairs(xDTaraZ.Skins.Catalog) do
        if not seen[category] then list[#list + 1] = category end
    end
    if #list == 0 then list[1] = "-" end
    return list
end

function xDTaraZ.Skins.Items(category)
    if not xDTaraZ.Skins.Catalog then xDTaraZ.Skins.Build() end
    local names = xDTaraZ.Skins.Catalog[category or ""]
    return (names and #names > 0) and names or { "-" }
end

---@return string[]  rarest first
function xDTaraZ.Skins.List(weapon)
    local folder = xDTaraZ.Skins.Folder()
    local holder = folder and folder:FindFirstChild(weapon or "")
    if not holder then return { "-" } end
    local ranks = xDTaraZ.Skins.Rarity[weapon] or {}
    local names = {}
    for _, child in ipairs(holder:GetChildren()) do names[#names + 1] = child.Name end
    table.sort(names, function(a, b)
        local ra, rb = ranks[a] or 0, ranks[b] or 0
        if ra ~= rb then return ra > rb end
        return a < b
    end)
    return #names > 0 and names or { "-" }
end

---@param view string  "Camera" or "Character"
---@return Folder?     best wear available
function xDTaraZ.Skins.Source(weapon, skin, view)
    local folder = xDTaraZ.Skins.Folder()
    local paint = folder and folder:FindFirstChild(weapon) and folder[weapon]:FindFirstChild(skin)
    local side = paint and paint:FindFirstChild(view)
    if not side then return nil end
    for _, wear in ipairs(xDTaraZ.Config.SkinWears) do
        if side:FindFirstChild(wear) then return side[wear] end
    end
    return side:FindFirstChildOfClass("Folder")
end

function xDTaraZ.Skins.Paint(model, weapon, skin, view)
    local source = xDTaraZ.Skins.Source(weapon, skin, view)
    if not source then return false end
    local whole = source:FindFirstChild("SurfaceAppearance")
    local arms = xDTaraZ.Config.SkinArms
    for _, part in ipairs(model:GetDescendants()) do
        if not part:IsA("BasePart") then continue end
        local old = part:FindFirstChildOfClass("SurfaceAppearance")
        local look = source:FindFirstChild(part.Name)
        if not look and whole and old and not arms[part.Name] then look = whole end
        if not look then continue end
        local originals = xDTaraZ.Skins.Originals
        if originals[part] == nil then originals[part] = old and old:Clone() or false end
        if old then old:Destroy() end
        look:Clone().Parent = part
    end
    return true
end

---Puts back the look each part had before we painted it.
function xDTaraZ.Skins.Reset(model)
    local originals = xDTaraZ.Skins.Originals
    for _, part in ipairs(model:GetDescendants()) do
        local saved = part:IsA("BasePart") and originals[part]
        if saved == nil then continue end
        local current = part:FindFirstChildOfClass("SurfaceAppearance")
        if current then current:Destroy() end
        if saved then saved:Clone().Parent = part end
        originals[part] = nil
    end
end

function xDTaraZ.Skins.WeaponOf(model)
    local folder = xDTaraZ.Skins.Folder()
    if folder and folder:FindFirstChild(model.Name) then return model.Name end
    local equipped = xDTaraZ.Player.Equipped()
    return equipped and (equipped.Weapon or equipped.Name)
end

function xDTaraZ.Skins.Models()
    local list = {}
    for _, child in ipairs(Workspace.CurrentCamera:GetChildren()) do
        if child:IsA("Model") then list[#list + 1] = { child, "Camera" } end
    end
    local char = xDTaraZ.Player.Character()
    local folder = xDTaraZ.Skins.Folder()
    if char and folder then
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Model") and folder:FindFirstChild(child.Name) then list[#list + 1] = { child, "Character" } end
        end
    end
    return list
end

function xDTaraZ.Skins.Step()
    local skins = xDTaraZ.Skins
    local on = xDTaraZ.Options.SkinChanger
    local glove = on and skins.Map[xDTaraZ.Config.GloveKey]
    local gloveSkin = glove and skins.Map[glove]
    for _, entry in ipairs(skins.Models()) do
        local model, view = entry[1], entry[2]
        local weapon = skins.WeaponOf(model)
        local skin = on and weapon and skins.Map[weapon] or nil
        local key = (skin or gloveSkin) and (tostring(weapon) .. "|" .. tostring(skin) .. "|" .. tostring(gloveSkin)) or nil
        if skins.Applied[model] == key then continue end
        if skins.Applied[model] then skins.Reset(model) end
        if skin then skins.Paint(model, weapon, skin, view) end
        if gloveSkin and view == "Camera" then skins.Paint(model, glove, gloveSkin, view) end
        skins.Applied[model] = key
    end
end

function xDTaraZ.Skins.Set(weapon, skin, quiet)
    if not weapon or weapon == "-" or not skin or skin == "-" then return false end
    local map, gloveKey = xDTaraZ.Skins.Map, xDTaraZ.Config.GloveKey
    local isGlove = xDTaraZ.Skins.Catalog and table.find(xDTaraZ.Skins.Catalog.Gloves or {}, weapon)
    if skin == "Default" then
        if map[weapon] == nil then return false end
        map[weapon] = nil
        if map[gloveKey] == weapon then map[gloveKey] = nil end
    else
        if map[weapon] == skin then return false end
        map[weapon] = skin
        if isGlove then map[gloveKey] = weapon end
    end
    if not quiet then xDTaraZ.Skins.Save() end
    return true
end

---@param pick fun(list: string[]): string  chooses one skin per item
---@return number  items changed
function xDTaraZ.Skins.SetAll(pick)
    local count = 0
    for _, category in ipairs(xDTaraZ.Skins.Categories()) do
        if category == "Gloves" then continue end
        for _, weapon in ipairs(xDTaraZ.Skins.Items(category)) do
            xDTaraZ.Skins.Set(weapon, pick(xDTaraZ.Skins.List(weapon)), true)
            count += 1
        end
    end
    xDTaraZ.Skins.Save()
    return count
end

function xDTaraZ.Skins.Save()
    if type(writefile) ~= "function" then return end
    local ok, err = pcall(function()
        if type(isfolder) == "function" and not isfolder(xDTaraZ.Config.SaveFolder) then makefolder(xDTaraZ.Config.SaveFolder) end
        writefile(xDTaraZ.Config.SkinFile, HttpService:JSONEncode(xDTaraZ.Skins.Map))
    end)
    if not ok then warn("[BloxStrike] skins save:", err) end
end

function xDTaraZ.Skins.Load()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then return end
    local ok, raw = pcall(function()
        if isfile(xDTaraZ.Config.SkinFile) then
            return readfile(xDTaraZ.Config.SkinFile)
        elseif isfile("BloxStrike/skins.json") then
            return readfile("BloxStrike/skins.json")
        end
        return nil
    end)
    local map = ok and xDTaraZ.Util.Decode(raw)
    if type(map) == "table" then xDTaraZ.Skins.Map = map end
end

xDTaraZ.Economy = {}

function xDTaraZ.Economy.RedeemAll()
    local net = xDTaraZ.GameLib.Net
    local packet = net and net.Dashboard and net.Dashboard.RedeemCode
    if not packet or xDTaraZ.State.Redeeming then return 0 end
    xDTaraZ.State.Redeeming = true
    local sent = 0
    for _, code in ipairs(xDTaraZ.Config.Codes) do
        if pcall(packet.Send, code) then sent += 1 end
        task.wait(xDTaraZ.Config.RedeemGap)
    end
    xDTaraZ.State.Redeeming = false
    return sent
end

function xDTaraZ.Economy.HookBuys()
    local net = xDTaraZ.GameLib.Net
    local packet = net and net.Inventory and net.Inventory.BuyMenuPurchase
    if not packet then return end
    local original
    original = xDTaraZ.Util.Hook("Buy", packet.Send, function(payload, ...)
        if type(payload) == "table" and payload.Name and not xDTaraZ.State.Replaying then
            local list = xDTaraZ.State.Bought
            for index, entry in ipairs(list) do
                if entry.Name == payload.Name then table.remove(list, index); break end
            end
            list[#list + 1] = { Equipment = payload.Equipment, Path = payload.Path, Name = payload.Name }
        end
        return original(payload, ...)
    end)
end

function xDTaraZ.Economy.Rebuy()
    local net = xDTaraZ.GameLib.Net
    local packet = net and net.Inventory and net.Inventory.BuyMenuPurchase
    if not packet or #xDTaraZ.State.Bought == 0 or xDTaraZ.State.Replaying then return 0 end
    xDTaraZ.State.Replaying = true
    local sent = 0
    for _, entry in ipairs(xDTaraZ.State.Bought) do
        if pcall(packet.Send, { Equipment = entry.Equipment, Path = entry.Path, Name = entry.Name }) then sent += 1 end
        task.wait(xDTaraZ.Config.RebuyGap)
    end
    xDTaraZ.State.Replaying = false
    return sent
end

---Buys once each time the game enters a buy phase, so warmup and round 1 each get their own rebuy.
function xDTaraZ.Economy.Step()
    local state = xDTaraZ.State
    local phase = Workspace:GetAttribute("GameState")
    local entered = xDTaraZ.Config.BuyStates[phase] and phase ~= state.LastPhase
    state.LastPhase = phase
    if not entered then state.RebuyPending = state.RebuyPending and xDTaraZ.Config.BuyStates[phase]; return end
    state.RebuyPending = true
end

function xDTaraZ.Economy.Tick()
    local state = xDTaraZ.State
    xDTaraZ.Economy.Step()
    if not (xDTaraZ.Options.AutoRebuy and state.RebuyPending and xDTaraZ.Player.Alive()) then return end
    state.RebuyPending = false
    task.spawn(xDTaraZ.Economy.Rebuy)
end

function xDTaraZ.Economy.BoughtText()
    local names = {}
    for _, entry in ipairs(xDTaraZ.State.Bought) do names[#names + 1] = entry.Name end
    return #names > 0 and table.concat(names, ", ") or "-"
end

xDTaraZ.Spectators = {}

function xDTaraZ.Spectators.Text()
    local count = tonumber(LocalPlayer:GetAttribute("Spectators")) or 0
    if count == 0 then return "None" end
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and tostring(player:GetAttribute("IsSpectating")) == "true" and tostring(player:GetAttribute("Dead")) == "true" then
            names[#names + 1] = player.DisplayName
        end
    end
    return count .. " watching" .. (#names > 0 and (" (dead: " .. table.concat(names, ", ") .. ")") or "")
end

xDTaraZ.Faults = { Streaks = {} }

function xDTaraZ.Faults.Clear(name)
    xDTaraZ.Faults.Streaks[name] = nil
end

function xDTaraZ.Faults.AnyOn(toggles)
    for _, key in ipairs(toggles) do
        if xDTaraZ.Options[key] then return true end
    end
    return false
end

---@param restore function?  the feature's own off path
function xDTaraZ.Faults.Halt(name, err, toggles, restore)
    warn("[BloxStrike] " .. name .. " stopped:", err)
    for _, key in ipairs(toggles) do
        xDTaraZ.Options[key] = false
    end
    if restore then xDTaraZ.Util.Try(name .. " restore", restore) end
    local halted = xDTaraZ.State.Halted
    halted[#halted + 1] = { name, tostring(err):match("^[^\n]*"), toggles }
end

---@param toggles string[]   turned off once the feature keeps failing; empty = keeps running, warns once per streak
---@param restore function?  run once when the feature is stopped
---@return boolean           true while the feature is stopped
function xDTaraZ.Faults.Report(name, err, toggles, restore)
    local now, streaks = osClock(), xDTaraZ.Faults.Streaks
    local streak = streaks[name]
    if not streak or (streak.Halted and xDTaraZ.Faults.AnyOn(toggles)) then
        streak = { Count = 0, First = now, Warned = false, Halted = false }
        streaks[name] = streak
    end
    streak.Count += 1
    if streak.Warned then return streak.Halted end
    if streak.Count < xDTaraZ.Config.MaxFails or now - streak.First < xDTaraZ.Config.FailWindow then return false end

    streak.Warned = true
    if #toggles == 0 then
        warn("[BloxStrike] " .. name .. " keeps failing:", err)
        return false
    end
    streak.Halted = true
    xDTaraZ.Faults.Halt(name, err, toggles, restore)
    return true
end

xDTaraZ.Scheduler = { Jobs = {} }

---@param toggles string[]   options the job serves; switched off if it keeps failing
---@param restore function?  the job's off path, run once if it gets stopped
function xDTaraZ.Scheduler.Every(name, interval, fn, toggles, restore)
    xDTaraZ.Scheduler.Jobs[name] = { Interval = interval, Fn = fn, Next = 0, Toggles = toggles, Restore = restore }
end

---@return boolean  a halted job runs again once one of its toggles is back on
function xDTaraZ.Scheduler.Resume(name, job)
    if not xDTaraZ.Faults.AnyOn(job.Toggles) then return false end
    job.Halted = false
    xDTaraZ.Faults.Clear(name)
    return true
end

function xDTaraZ.Scheduler.Boot()
    xDTaraZ:Connect(RunService.Heartbeat, function()
        local now = osClock()
        for name, job in pairs(xDTaraZ.Scheduler.Jobs) do
            if now < job.Next then continue end
            job.Next = now + job.Interval
            if job.Halted and not xDTaraZ.Scheduler.Resume(name, job) then continue end

            local ok, err = pcall(job.Fn)
            if ok then
                xDTaraZ.Faults.Clear(name)
            else
                job.Halted = xDTaraZ.Faults.Report(name, err, job.Toggles, job.Restore)
            end
        end
    end)
end

---Player ESP drawn with plain GuiObjects (no Drawing API needed). The old UI library had this built in;
---AuralV2 has no ESP, so it lives in the script now. Targets come from xDTaraZ.Esp.Targets.
xDTaraZ.Visuals = {
    Settings = {
        Enabled = false,
        Box = true,
        BoxStyle = "Full",
        BoxFill = false,
        Name = true,
        Health = true,
        HealthText = false,
        Distance = true,
        Tracer = false,
        TracerOrigin = "Bottom",
        HeadDot = false,
        Chams = false,
        Arrows = false,
        Radar = false,
        RadarRange = 250,
        RadarSize = 180,
        TeamCheck = true,
        MaxDistance = 2000,
        TextSize = 13,
        EnemyColor = Color3.fromRGB(232, 88, 76),
        FriendColor = Color3.fromRGB(96, 196, 120),
    },
    Entries = {},
    Targets = {},
    LastScan = 0,
    ScanInterval = 0.2,
    Radar = { Dots = {} },
}

function xDTaraZ.Visuals.New(class, props)
    local object = Instance.new(class)
    local parent = props.Parent
    props.Parent = nil
    for key, value in pairs(props) do object[key] = value end
    if parent then object.Parent = parent end
    return object
end

function xDTaraZ.Visuals.EnsureGui()
    local visuals = xDTaraZ.Visuals
    if visuals.Gui and visuals.Gui.Parent then return visuals.Gui end
    local screen = visuals.New("ScreenGui", { Name = "AuralVisuals", IgnoreGuiInset = true, ResetOnSpawn = false, DisplayOrder = 5, ZIndexBehavior = Enum.ZIndexBehavior.Sibling })
    local function Mount(parent) screen.Parent = parent end
    local okHui, hui = pcall(gethui)
    local mounted = okHui and hui ~= nil and pcall(Mount, hui)
    if not mounted then mounted = pcall(Mount, game:GetService("CoreGui")) end
    if not mounted then Mount(LocalPlayer:FindFirstChildOfClass("PlayerGui")) end
    visuals.Gui = screen
    return screen
end

function xDTaraZ.Visuals.Label(parent, alignY)
    return xDTaraZ.Visuals.New("TextLabel", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, alignY),
        Size = UDim2.fromOffset(200, 16),
        Font = Enum.Font.GothamBold,
        TextColor3 = Color3.new(1, 1, 1),
        TextStrokeTransparency = 0.35,
        Visible = false,
        Parent = parent,
    })
end

---@return table  reusable GUI pieces for one ESP target
function xDTaraZ.Visuals.BuildEntry(parent)
    local new = xDTaraZ.Visuals.New
    local entry = {}
    entry.Box = new("Frame", { BackgroundTransparency = 1, Visible = false, Parent = parent })
    entry.BoxStroke = new("UIStroke", { Thickness = 1.5, Parent = entry.Box })
    entry.BoxOutline = new("Frame", { BackgroundTransparency = 1, Position = UDim2.fromOffset(-1, -1), Size = UDim2.new(1, 2, 1, 2), Parent = entry.Box })
    new("UIStroke", { Thickness = 1, Color = Color3.new(0, 0, 0), Transparency = 0.3, Parent = entry.BoxOutline })
    entry.Corners = {}
    for index = 1, 8 do
        entry.Corners[index] = new("Frame", { BorderSizePixel = 0, Visible = false, Parent = parent })
    end
    entry.HealthBack = new("Frame", { BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.35, BorderSizePixel = 0, Visible = false, Parent = parent })
    entry.HealthFill = new("Frame", { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), BorderSizePixel = 0, Parent = entry.HealthBack })
    entry.HealthText = xDTaraZ.Visuals.Label(parent, 0.5)
    entry.Name = xDTaraZ.Visuals.Label(parent, 1)
    entry.Distance = xDTaraZ.Visuals.Label(parent, 0)
    entry.Tracer = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1), Visible = false, Parent = parent })
    entry.Dot = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(6, 6), BorderSizePixel = 0, Visible = false, Parent = parent })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = entry.Dot })
    entry.Arrow = xDTaraZ.Visuals.Label(parent, 0.5)
    entry.Arrow.Text = "▲"
    entry.Arrow.Size = UDim2.fromOffset(20, 20)
    return entry
end

function xDTaraZ.Visuals.HideEntry(entry)
    entry.Box.Visible = false
    for _, corner in ipairs(entry.Corners) do corner.Visible = false end
    entry.HealthBack.Visible, entry.HealthText.Visible = false, false
    entry.Name.Visible, entry.Distance.Visible = false, false
    entry.Tracer.Visible, entry.Dot.Visible, entry.Arrow.Visible = false, false, false
    if entry.Highlight then entry.Highlight.Enabled = false end
end

function xDTaraZ.Visuals.DestroyEntry(entry)
    for _, key in ipairs({ "Box", "HealthBack", "HealthText", "Name", "Distance", "Tracer", "Dot", "Arrow", "Highlight" }) do
        if entry[key] then pcall(entry[key].Destroy, entry[key]) end
    end
    for _, corner in ipairs(entry.Corners) do pcall(corner.Destroy, corner) end
end

function xDTaraZ.Visuals.SetLine(line, from, to, thickness)
    local delta = to - from
    line.Position = UDim2.fromOffset((from.X + to.X) / 2, (from.Y + to.Y) / 2)
    line.Size = UDim2.fromOffset(delta.Magnitude, thickness)
    line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
    line.Visible = true
end

---Places the 2D box, bars and labels from a screen rect.
function xDTaraZ.Visuals.Layout(entry, x, y, w, h, info, color, origin)
    local settings = xDTaraZ.Visuals.Settings
    local full = settings.Box and settings.BoxStyle ~= "Corner"
    entry.Box.Visible = full
    if full then
        entry.Box.Position, entry.Box.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
        entry.BoxStroke.Color = color
        entry.Box.BackgroundTransparency = settings.BoxFill and 0.82 or 1
        entry.Box.BackgroundColor3 = color
    end

    local corner = settings.Box and settings.BoxStyle == "Corner"
    local cw, ch = math.max(w / 4, 3), math.max(h / 5, 3)
    local spots = {
        { x, y, cw, 2 }, { x, y, 2, ch }, { x + w - cw, y, cw, 2 }, { x + w - 2, y, 2, ch },
        { x, y + h - 2, cw, 2 }, { x, y + h - ch, 2, ch }, { x + w - cw, y + h - 2, cw, 2 }, { x + w - 2, y + h - ch, 2, ch },
    }
    for index, piece in ipairs(entry.Corners) do
        piece.Visible = corner
        if corner then
            local spot = spots[index]
            piece.Position, piece.Size, piece.BackgroundColor3 = UDim2.fromOffset(spot[1], spot[2]), UDim2.fromOffset(spot[3], spot[4]), color
        end
    end

    local ratio = math.clamp((info.Health or 0) / math.max(info.MaxHealth or 100, 1), 0, 1)
    entry.HealthBack.Visible = settings.Health
    if settings.Health then
        entry.HealthBack.Position, entry.HealthBack.Size = UDim2.fromOffset(x - 6, y), UDim2.fromOffset(3, h)
        entry.HealthFill.Size = UDim2.fromScale(1, ratio)
        entry.HealthFill.BackgroundColor3 = Color3.fromRGB(232, 88, 76):Lerp(Color3.fromRGB(96, 214, 110), ratio)
    end
    entry.HealthText.Visible = settings.HealthText
    if settings.HealthText then
        local hp = math.floor(info.Health or 0)
        if entry.LastHp ~= hp then
            entry.LastHp = hp
            entry.HealthText.Text = tostring(hp)
        end
        entry.HealthText.TextSize = settings.TextSize - 2
        entry.HealthText.Position = UDim2.fromOffset(x - 20, y + h * (1 - ratio))
    end

    entry.Name.Visible = settings.Name
    if settings.Name then
        local name = info.Name or ""
        if entry.LastName ~= name then
            entry.LastName = name
            entry.Name.Text = name
        end
        entry.Name.TextSize, entry.Name.TextColor3 = settings.TextSize, color
        entry.Name.Position = UDim2.fromOffset(x + w / 2, y - 2)
    end
    entry.Distance.Visible = settings.Distance and info.Distance ~= nil
    if entry.Distance.Visible then
        local distance = math.floor(info.Distance)
        if entry.LastDist ~= distance then
            entry.LastDist = distance
            entry.Distance.Text = distance .. "m"
        end
        entry.Distance.TextSize = settings.TextSize - 1
        entry.Distance.Position = UDim2.fromOffset(x + w / 2, y + h + 2)
    end

    entry.Dot.Visible = settings.HeadDot
    if settings.HeadDot then
        entry.Dot.Position, entry.Dot.BackgroundColor3 = UDim2.fromOffset(x + w / 2, y + h * 0.1), color
    end

    if settings.Tracer and origin then
        entry.Tracer.BackgroundColor3 = color
        xDTaraZ.Visuals.SetLine(entry.Tracer, origin, Vector2.new(x + w / 2, y + h), 1.5)
    else
        entry.Tracer.Visible = false
    end
end

function xDTaraZ.Visuals.TracerOrigin(viewport)
    local mode = xDTaraZ.Visuals.Settings.TracerOrigin
    if mode == "Center" then return viewport / 2 end
    if mode == "Mouse" then return UserInputService:GetMouseLocation() end
    return Vector2.new(viewport.X / 2, viewport.Y)
end

function xDTaraZ.Visuals.Chams(entry, model, color, on)
    if not on then
        if entry.Highlight then entry.Highlight.Enabled = false end
        return
    end
    if not entry.Highlight then
        entry.Highlight = xDTaraZ.Visuals.New("Highlight", { DepthMode = Enum.HighlightDepthMode.AlwaysOnTop, FillTransparency = 0.55, OutlineTransparency = 0, Parent = xDTaraZ.Visuals.EnsureGui() })
    end
    entry.Highlight.Adornee = model
    entry.Highlight.FillColor, entry.Highlight.OutlineColor = color, color
    entry.Highlight.Enabled = true
end

function xDTaraZ.Visuals.Arrow(entry, screen, viewport, color)
    local center = viewport / 2
    local dir = Vector2.new(screen.X, screen.Y) - center
    if screen.Z < 0 then dir = -dir end
    if dir.Magnitude < 1 then return end
    local unit = dir.Unit
    local radius = math.min(viewport.X, viewport.Y) / 2 - 40
    local pos = center + unit * radius
    entry.Arrow.Position = UDim2.fromOffset(pos.X, pos.Y)
    entry.Arrow.Rotation = math.deg(math.atan2(unit.Y, unit.X)) + 90
    entry.Arrow.TextColor3 = color
    entry.Arrow.TextSize = 18
    entry.Arrow.Visible = true
end

function xDTaraZ.Visuals.Scan()
    local visuals = xDTaraZ.Visuals
    local now = osClock()
    if now - visuals.LastScan < visuals.ScanInterval then return end
    visuals.LastScan = now
    local ok, list = pcall(xDTaraZ.Esp.Targets)
    visuals.Targets = ok and type(list) == "table" and list or {}
end

function xDTaraZ.Visuals.Render()
    local visuals = xDTaraZ.Visuals
    local settings = visuals.Settings
    if not settings.Enabled then return end
    visuals.Scan()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local gui = visuals.EnsureGui()
    local viewport = cam.ViewportSize
    local origin = visuals.TracerOrigin(viewport)
    local camPos = cam.CFrame.Position
    local seen = {}

    for _, info in ipairs(visuals.Targets) do
        local model = info.Model
        if typeof(model) ~= "Instance" or not model.Parent then continue end
        if settings.TeamCheck and info.Friendly then continue end
        local root = info.Root or model:FindFirstChild("HumanoidRootPart") or (model :: Model).PrimaryPart
        if not root then continue end
        local distance = (root.Position - camPos).Magnitude
        if distance > settings.MaxDistance then continue end

        seen[model] = true
        local entry = visuals.Entries[model]
        if not entry then
            entry = visuals.BuildEntry(gui)
            visuals.Entries[model] = entry
        end
        local color = info.Color or (info.Friendly and settings.FriendColor or settings.EnemyColor)
        visuals.Chams(entry, info.Adornee or model, color, settings.Chams and (info.Adornee ~= false))

        local top, onTop = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local bottom, onBottom = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3.5, 0))
        if not (onTop and onBottom) then
            visuals.HideEntry(entry)
            if settings.Chams and entry.Highlight and info.Adornee ~= false then entry.Highlight.Enabled = true end
            if settings.Arrows then visuals.Arrow(entry, cam:WorldToViewportPoint(root.Position), viewport, color) end
            continue
        end
        entry.Arrow.Visible = false
        local h = math.max(bottom.Y - top.Y, 4)
        local w = h * 0.55
        info.Distance = distance
        visuals.Layout(entry, top.X - w / 2, top.Y, w, h, info, color, origin)
    end

    for model, entry in pairs(visuals.Entries) do
        if not seen[model] then
            if model.Parent then
                visuals.HideEntry(entry)
            else
                visuals.DestroyEntry(entry)
                visuals.Entries[model] = nil
            end
        end
    end
end

function xDTaraZ.Visuals.ClearAll()
    local visuals = xDTaraZ.Visuals
    for model, entry in pairs(visuals.Entries) do
        visuals.DestroyEntry(entry)
        visuals.Entries[model] = nil
    end
end

---Circular minimap centred on you, turned with the camera. Drag it to move it.
function xDTaraZ.Visuals.RadarBuild()
    local visuals = xDTaraZ.Visuals
    local radar = visuals.Radar
    if radar.Frame and radar.Frame.Parent then return radar end
    local new = visuals.New
    local frame = new("Frame", { Name = "Radar", Position = UDim2.fromOffset(24, 180), BackgroundColor3 = Color3.fromRGB(16, 16, 22), BackgroundTransparency = 0.25, Active = true, Visible = false, Parent = visuals.EnsureGui() })
    new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = frame })
    new("UIStroke", { Thickness = 2, Color = Color3.fromRGB(232, 160, 76), Transparency = 0.2, Parent = frame })
    for _, horizontal in ipairs({ true, false }) do
        new("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
            Size = horizontal and UDim2.new(1, -12, 0, 1) or UDim2.new(0, 1, 1, -12),
            BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.8, BorderSizePixel = 0, Parent = frame,
        })
    end
    local ring = new("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1, Parent = frame })
    new("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = ring })
    new("UIStroke", { Thickness = 1, Color = Color3.new(1, 1, 1), Transparency = 0.75, Parent = ring })
    new("TextLabel", { AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(16, 16), BackgroundTransparency = 1, Text = "▲", TextSize = 14, Font = Enum.Font.GothamBold, TextColor3 = Color3.new(1, 1, 1), ZIndex = 3, Parent = frame })

    local dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragStart, startPos = input.Position, frame.Position
            local release
            release = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragStart = nil
                    release:Disconnect()
                end
            end)
        end
    end)
    xDTaraZ:Connect(UserInputService.InputChanged, function(input)
        if not dragStart or not frame.Parent then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local delta = input.Position - dragStart
            frame.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)
    radar.Frame = frame
    return radar
end

function xDTaraZ.Visuals.RadarDot(index)
    local radar = xDTaraZ.Visuals.Radar
    local dot = radar.Dots[index]
    if not dot then
        dot = xDTaraZ.Visuals.New("Frame", { AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(7, 7), BorderSizePixel = 0, ZIndex = 2, Parent = radar.Frame })
        xDTaraZ.Visuals.New("UICorner", { CornerRadius = UDim.new(0.5, 0), Parent = dot })
        radar.Dots[index] = dot
    end
    return dot
end

function xDTaraZ.Visuals.RadarRender()
    local visuals = xDTaraZ.Visuals
    local settings, radar = visuals.Settings, visuals.Radar
    if not settings.Radar then
        if radar.Frame then radar.Frame.Visible = false end
        return
    end
    visuals.RadarBuild()
    visuals.Scan()
    local cam = Workspace.CurrentCamera
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local size = settings.RadarSize
    radar.Frame.Size = UDim2.fromOffset(size, size)
    radar.Frame.Visible = cam ~= nil and root ~= nil
    if not radar.Frame.Visible then return end

    local look = cam.CFrame.LookVector * Vector3.new(1, 0, 1)
    look = look.Magnitude > 0 and look.Unit or Vector3.new(0, 0, -1)
    local right = Vector3.new(-look.Z, 0, look.X)
    local radius = size / 2 - 6
    local used = 0
    for _, info in ipairs(visuals.Targets) do
        local model = info.Model
        local part = info.Root or (typeof(model) == "Instance" and (model:FindFirstChild("HumanoidRootPart") or (model :: Model).PrimaryPart))
        if not part or (settings.TeamCheck and info.Friendly) then continue end
        local rel = part.Position - root.Position
        local offset = Vector2.new(rel:Dot(right), -rel:Dot(look)) / settings.RadarRange * radius
        local outside = offset.Magnitude > radius
        if outside then offset = offset.Unit * radius end
        used += 1
        local dot = visuals.RadarDot(used)
        dot.Position = UDim2.new(0.5, offset.X, 0.5, offset.Y)
        dot.BackgroundColor3 = info.Color or (info.Friendly and settings.FriendColor or settings.EnemyColor)
        dot.BackgroundTransparency = outside and 0.55 or 0
        dot.Visible = true
    end
    for index = used + 1, #radar.Dots do radar.Dots[index].Visible = false end
end

function xDTaraZ.Visuals.Step()
    local visuals = xDTaraZ.Visuals
    local ok, err = pcall(visuals.Render)
    if not ok then warn("[BloxStrike] esp:", err) end
    ok, err = pcall(visuals.RadarRender)
    if not ok then warn("[BloxStrike] radar:", err) end
end

function xDTaraZ.Visuals:Set(key, value)
    self.Settings[key] = value
    if key == "Enabled" and not value then xDTaraZ.Visuals.ClearAll() end
end

function xDTaraZ.Visuals:Get(key)
    return self.Settings[key]
end

function xDTaraZ.Visuals.Destroy()
    local visuals = xDTaraZ.Visuals
    visuals.ClearAll()
    if visuals.Gui then pcall(visuals.Gui.Destroy, visuals.Gui) end
    visuals.Gui = nil
    visuals.Radar = { Dots = {} }
end

xDTaraZ.UI = { Labels = {}, Widgets = {}, Window = nil, FeatureBinds = {} }

---Thai when the Roblox locale is Thai, else English (the old library's Language = "Auto").
xDTaraZ.UI.Thai = tostring(LocalPlayer.LocaleId):lower():sub(1, 2) == "th"
T = function(en, th) return xDTaraZ.UI.Thai and th or en end

function xDTaraZ.UI.Detach(fn)
    return function(...)
        local packed = table.pack(...)
        task.defer(function()
            local ok, err = pcall(fn, table.unpack(packed, 1, packed.n))
            if not ok then warn("[BloxStrike] ui:", err) end
        end)
    end
end

---Runs `fn` every `interval` seconds until the script unloads.
function xDTaraZ.UI.Every(interval, fn)
    task.spawn(function()
        while xDTaraZ.State.Alive do
            local ok, err = pcall(fn)
            if not ok then warn("[BloxStrike] ui loop:", err) end
            task.wait(interval)
        end
    end)
end

---@return boolean  true while the menu covers the screen
function xDTaraZ.UI.MenuOpen()
    local window = xDTaraZ.UI.Window
    if not window or window._destroyed then return false end
    -- Arcane doesn't expose a simple .Open bool; use the holder visibility as proxy.
    local ok, vis = pcall(function()
        return window.Items.Holder.Instance.Enabled
    end)
    return ok and vis == true
end

local notifyIcons = { Info = "info", Coin = "coins" }
local notifyTypes = { Success = "Success", Warning = "Warning", Warn = "Warning", Error = "Error" }

function xDTaraZ.UI.Notify(title, content, duration, kind)
    if not Library then return end
    -- Arcane notification: { Name, Description, Duration, Icon, Color }
    local colorMap = {
        Success = Color3.fromRGB(52,  255, 164),
        Warning = Color3.fromRGB(255, 180, 0),
        Warn    = Color3.fromRGB(255, 180, 0),
        Error   = Color3.fromRGB(255, 70,  70),
        Info    = Color3.fromRGB(80,  140, 255),
        Coin    = Color3.fromRGB(255, 215, 0),
    }
    local iconMap = {
        Success = "check",
        Warning = "alert-triangle",
        Warn    = "alert-triangle",
        Error   = "x",
        Info    = "info",
        Coin    = "coins",
    }
    local ok, err = pcall(Library.Notification, Library, {
        Name        = tostring(title),
        Description = tostring(content),
        Duration    = duration or 4,
        Icon        = iconMap[kind] or "info",
        Color       = colorMap[kind] or Color3.fromRGB(80, 140, 255),
    })
    if not ok then warn("[BloxStrike] notify:", err) end
end

---One control the script reads and writes. AuralV2 elements only take a single Callback, so this adds
---OnChanged listeners and guards (a guard returning false vetoes the value before any listener sees it).
function xDTaraZ.UI.Widget(idx, name)
    local widget = { Idx = idx, Name = name or idx, Listeners = {}, Guards = {}, Value = nil, Element = nil }
    function widget:OnChanged(fn) table.insert(self.Listeners, fn) end
    function widget:AddGuard(fn) table.insert(self.Guards, fn) end
    function widget:SetValue(value)
        if self.Element then self.Element:Set(value) end
    end
    function widget:Dispatch(value)
        for _, guard in ipairs(self.Guards) do
            local ok, allowed = pcall(guard, value)
            if ok and allowed == false then return end
        end
        self.Value = value
        for _, fn in ipairs(self.Listeners) do
            local ok, err = pcall(fn, value)
            if not ok then warn("[BloxStrike] " .. idx .. ":", err) end
        end
    end
    xDTaraZ.UI.Widgets[idx] = widget
    return widget
end

---@param info table  { Name, Desc, Default, Keybind, Notify }
function xDTaraZ.UI.Toggle(group, idx, info)
    local widget = xDTaraZ.UI.Widget(idx, info.Name)
    local elem = group:Toggle({
        Name     = info.Name,
        Tooltip  = info.Desc,
        Default  = info.Default == true,
        Flag     = idx,
        Callback = function(value) widget:Dispatch(value) end,
    })
    widget.Element = {
        Get = function() return elem:Get() end,
        Set = function(_, v, silent) elem:Set(v, silent) end,
    }
    widget.Value = elem:Get()

    -- Optional toast notification on every state change.
    if info.Notify then
        widget:OnChanged(function(value)
            xDTaraZ.UI.Notify(
                info.Name,
                value and T("Enabled", "เปิดแล้ว") or T("Disabled", "ปิดแล้ว"),
                2,
                value and "Success" or "Warning"
            )
        end)
    end

    return widget
end

---@param info table  { Name, Desc, Min, Max, Default, Increment, Suffix }
function xDTaraZ.UI.Slider(group, idx, info)
    local widget = xDTaraZ.UI.Widget(idx, info.Name)
    local elem = group:Slider({
        Name      = info.Name,
        Tooltip   = info.Desc,
        Min       = info.Min,
        Max       = info.Max,
        Default   = info.Default,
        Suffix    = info.Suffix,
        Flag      = idx,
        Callback  = function(value) widget:Dispatch(value) end,
    })
    widget.Element = {
        Get = function() return elem:Get() end,
        Set = function(_, v, silent) elem:Set(v, silent) end,
    }
    widget.Value = elem:Get()
    return widget
end

---@param info table  { Name, Desc, Options, Default, Searchable, NoSave }
function xDTaraZ.UI.Dropdown(group, idx, info)
    local widget = xDTaraZ.UI.Widget(idx, info.Name)
    local elem = group:Dropdown({
        Name     = info.Name,
        Tooltip  = info.Desc,
        Items    = info.Options,
        Default  = info.Default,
        Flag     = not info.NoSave and idx or nil,
        Callback = function(value) widget:Dispatch(value) end,
    })
    widget.Element = {
        Get = function() return elem:Get() end,
        Set = function(_, v, silent) elem:Set(v, silent) end,
    }
    widget.Value = elem:Get()
    return widget
end

function xDTaraZ.UI.Color(group, idx, info)
    -- AuralV2 has no colour-picker component; stub so the rest of the script
    -- can still read/write the default colour value.
    local widget = xDTaraZ.UI.Widget(idx, info.Name)
    widget.Value = info.Default
    widget.Element = {
        Get = function() return widget.Value end,
        Set = function(_, v, _) widget.Value = v end,
    }
    return widget
end

---Feeds a widget's current value and every change into `fn`.
function xDTaraZ.UI.Feed(widget, fn)
    pcall(fn, widget.Value)
    widget:OnChanged(fn)
end

---Keybind + key mode for a feature toggle. AuralV2 keybinds only fire on press, so Toggle / Hold / Always
---(the old library's key picker modes) are handled here. Backspace or Delete clears the key.
---Keybind + key mode for a feature toggle.
---AuralV2 has no keybind picker; the key is stored in a dummy object and
---the mode dropdown is a plain AuralV2 dropdown.
-- Keybind handling is now fully native in AuralV2 v2.6.0+ via the Keybind
-- field on AddToggle. The library manages key listening, Toggle/Hold modes,
-- and the built-in Menu Keybind in AddConfigSections. No custom OnKey needed.

---Vetoes turning `idx` on and tells the player why.
local function Veto(idx, message)
    local widget = xDTaraZ.UI.Widgets[idx]
    if not widget then return end
    widget:AddGuard(function(value)
        if value ~= true then return true end
        local text = message()
        if not text then return true end
        xDTaraZ.UI.Notify("Aural V2", text, 4, "Warning")
        task.defer(widget.SetValue, widget, false)
        return false
    end)
end

---Blocks a hook-only feature on executors that cannot run it.
function xDTaraZ.UI.NeedCap(idx, caps)
    local widget = xDTaraZ.UI.Widgets[idx]
    Veto(idx, function()
        if xDTaraZ.Compat.Has(caps) then return nil end
        local feature = widget and widget.Name or idx
        return T(feature .. " is not supported on this executor", feature .. " ใช้กับ executor นี้ไม่ได้")
    end)
end

---Blocks a feature for good (missing game module, unsupported executor).
function xDTaraZ.UI.Block(idx, reason)
    local widget = xDTaraZ.UI.Widgets[idx]
    if widget then widget.Blocked = reason end
    Veto(idx, function()
        return (widget and widget.Name or idx) .. ": " .. tostring(reason)
    end)
end

function xDTaraZ.UI.Bind(widget, key)
    local function Apply(value) xDTaraZ.Options[key] = value end
    Apply(widget.Value)
    widget:OnChanged(Apply)
end

local priorities = { "Crosshair", "Distance", "Health" }

function xDTaraZ.UI.BuildAimbot(tab)
    local main = tab:Section({ Name = T("Aim Lock", "เล็งอัตโนมัติ"), Side = 1 })
    xDTaraZ.UI.Toggle(main, "Aimbot", {
        Name    = T("Aim Lock", "เล็งอัตโนมัติ"),
        Desc    = T("Snaps aim onto the nearest enemy", "ล็อคเป้าศัตรูที่ใกล้ที่สุด"),
        Keybind = { Default = Enum.KeyCode.E, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Slider(main, "AimbotSmooth", { Name = T("Smoothness", "ความนุ่ม"), Desc = T("Higher = smoother", "สูง = นุ่มกว่า"), Min = 1, Max = 20, Default = 1 })
    xDTaraZ.UI.Toggle(main, "AimbotSticky", { Name = T("Sticky target", "ล็อคเป้าเดิม"), Desc = T("Stays on one enemy until they're gone", "ไม่สลับเป้าจนกว่าเป้าจะหลุด"), Default = true })

    local target = tab:Section({ Name = T("Aim Config", "การตั้งค่าการเล็ง"), Side = 2 })
    xDTaraZ.UI.Dropdown(target, "AimbotBone", { Name = T("Aim part", "จุดที่เล็ง"), Options = { "Head", "Torso" }, Default = "Head" })
    xDTaraZ.UI.Dropdown(target, "AimbotPriority", { Name = T("Priority", "เลือกเป้าตาม"), Options = priorities, Default = "Crosshair" })
    xDTaraZ.UI.Toggle(target, "AimbotVisible", { Name = T("Visible only", "เฉพาะที่มองเห็น"), Default = true })
    xDTaraZ.UI.Slider(target, "AimbotFov", { Name = T("FOV", "ขนาดวง"), Min = 20, Max = 800, Default = 150, Suffix = "px" })
    xDTaraZ.UI.Toggle(target, "AimbotShowFov", { Name = T("Show FOV circle", "แสดงวง FOV") })
    xDTaraZ.UI.Slider(target, "AimbotMaxDistance", { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 1500, Suffix = "m" })
end

function xDTaraZ.UI.BuildSilent(tab)
    local main = tab:Section({ Name = T("Bullet Redirect", "ไซเลนต์เอม"), Side = 1 })
    xDTaraZ.UI.Toggle(main, "SilentAim", {
        Name    = T("Silent aim", "ไซเลนต์เอม"),
        Desc    = T("Bends bullets toward the nearest enemy", "ยิงพุ่งหาศัตรูที่ใกล้ที่สุด"),
        Keybind = { Default = Enum.KeyCode.Unknown, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Slider(main, "SilentHitChance", { Name = T("Hit chance", "โอกาสโดน"), Desc = T("Lower = less obvious", "ต่ำ = ดูเนียนกว่า"), Min = 1, Max = 100, Default = 100, Suffix = "%" })
    xDTaraZ.UI.Slider(main, "SilentHeadChance", { Name = T("Headshot chance", "โอกาสเข้าหัว"), Desc = T("Rest hit the body", "ที่เหลือเข้าตัว"), Min = 0, Max = 100, Default = 100, Suffix = "%" })
    xDTaraZ.UI.NeedCap("SilentAim", { "HookFunction", "Gc" })

    local target = tab:Section({ Name = T("Redirect Config", "การตั้งค่าไซเลนต์"), Side = 2 })
    xDTaraZ.UI.Dropdown(target, "SilentPriority", { Name = T("Priority", "เลือกเป้าตาม"), Options = priorities, Default = "Crosshair" })
    xDTaraZ.UI.Toggle(target, "SilentVisible", { Name = T("Visible only", "เฉพาะที่มองเห็น"), Desc = T("Off = through walls too", "ปิด = ทะลุกำแพงด้วย"), Default = true })
    xDTaraZ.UI.Slider(target, "SilentFov", { Name = T("FOV", "ขนาดวง"), Min = 20, Max = 1000, Default = 220, Suffix = "px" })
    xDTaraZ.UI.Toggle(target, "SilentShowFov", { Name = T("Show FOV circle", "แสดงวง FOV") })
    xDTaraZ.UI.Slider(target, "SilentMaxDistance", { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 2000, Suffix = "m" })
    xDTaraZ.UI.Toggle(target, "SilentPredict", { Name = T("Lead moving targets", "ยิงดักคนที่วิ่ง") })
end

function xDTaraZ.UI.BuildTrigger(tab)
    local trigger = tab:Section({ Name = T("Auto Fire", "ยิงอัตโนมัติ"), Side = 1 })
    xDTaraZ.UI.Toggle(trigger, "Triggerbot", {
        Name    = T("Auto fire", "ยิงอัตโนมัติ"),
        Desc    = T("Auto fires when crosshair is on an enemy", "ยิงอัตโนมัติเมื่อเป้าอยู่บนศัตรู"),
        Keybind = { Default = Enum.KeyCode.T, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Slider(trigger, "TriggerDelay", { Name = T("Reaction delay", "ดีเลย์ก่อนยิง"), Min = 0, Max = 400, Default = 0, Suffix = "ms" })
    xDTaraZ.UI.Slider(trigger, "TriggerHitChance", { Name = T("Fire chance", "โอกาสยิง"), Min = 1, Max = 100, Default = 100, Suffix = "%" })

    local rage = tab:Section({ Name = T("Rage Mode", "เรจบอท"), Side = 2 })
    xDTaraZ.UI.Toggle(rage, "Ragebot", {
        Name    = T("Rage mode", "เรจบอท"),
        Desc    = T("Auto-snaps and kills any reachable enemy", "สแนปและฆ่าศัตรูที่ยิงถึงเอง"),
        Keybind = { Default = Enum.KeyCode.Unknown, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Toggle(rage, "RageVisible", { Name = T("Visible only", "เฉพาะที่มองเห็น"), Desc = T("Off = through walls too", "ปิด = ทะลุกำแพงด้วย"), Default = true })
    xDTaraZ.UI.Slider(rage, "RageMaxDistance", { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 2000, Suffix = "m" })
end

function xDTaraZ.UI.BuildGuns(tab)
    local mods = tab:Section({ Name = T("Weapon Control", "ม็อดปืน"), Side = 1 })
    xDTaraZ.UI.Toggle(mods, "NoRecoil", { Name = T("No recoil", "ไม่มีแรงถีบ"), Desc = T("No camera kick when firing", "ไม่มีการสั่นของกล้องตอนยิง") })
    xDTaraZ.UI.Toggle(mods, "NoSpread", { Name = T("No spread", "ไม่มีการกระจาย"), Desc = T("All bullets hit dead center", "ทุกนัดลงกลางเป้า") })
    xDTaraZ.UI.NeedCap("NoRecoil", "HookFunction")
    xDTaraZ.UI.NeedCap("NoSpread", { "HookFunction", "Gc" })
end

function xDTaraZ.UI.BuildCombat(window)
    -- Flat tab: every combat feature lands as sections on one page, no page-switcher.
    local tab = window:Page({ Name = T("Combat", "การต่อสู้"), Icon = "target" })
    tab = tab:SubPage({})
    xDTaraZ.Util.Try("build aimbot",  xDTaraZ.UI.BuildAimbot,  tab)
    xDTaraZ.Util.Try("build silent",  xDTaraZ.UI.BuildSilent,  tab)
    xDTaraZ.Util.Try("build trigger", xDTaraZ.UI.BuildTrigger, tab)
    xDTaraZ.Util.Try("build guns",    xDTaraZ.UI.BuildGuns,    tab)
end

function xDTaraZ.UI.BuildEsp(tab)
    local function Setting(key)
        return function(value) xDTaraZ.Visuals:Set(key, value) end
    end
    local feed = xDTaraZ.UI.Feed

    local main = tab:Section({ Name = "Player Tracking", Side = 1 })
    feed(xDTaraZ.UI.Toggle(main, "Esp",          { Name = T("Enable ESP", "เปิด ESP") }), Setting("Enabled"))
    feed(xDTaraZ.UI.Toggle(main, "EspTeam",      { Name = T("Team check", "เช็คทีม"), Default = true }), Setting("TeamCheck"))
    feed(xDTaraZ.UI.Slider(main, "EspRange",     { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 5000, Default = 2000, Increment = 50, Suffix = "m" }), Setting("MaxDistance"))
    feed(xDTaraZ.UI.Slider(main, "EspTextSize",  { Name = T("Text size", "ขนาดตัวอักษร"), Min = 9, Max = 20, Default = 13 }), Setting("TextSize"))

    local radar = tab:Section({ Name = T("Radar", "เรดาร์"), Side = 1 })
    feed(xDTaraZ.UI.Toggle(radar, "Radar",       { Name = T("Radar", "เรดาร์"), Desc = T("Minimap of players, drag to move", "มินิแมพผู้เล่น ลากย้ายได้") }), Setting("Radar"))
    feed(xDTaraZ.UI.Slider(radar, "RadarRange",  { Name = T("Radar range", "ระยะเรดาร์"), Min = 50, Max = 1000, Default = 250, Increment = 10, Suffix = "m" }), Setting("RadarRange"))
    feed(xDTaraZ.UI.Slider(radar, "RadarSize",   { Name = T("Radar size", "ขนาดเรดาร์"), Min = 120, Max = 320, Default = 180, Suffix = "px" }), Setting("RadarSize"))

    local look = tab:Section({ Name = T("Display Elements", "องค์ประกอบ"), Side = 2 })
    feed(xDTaraZ.UI.Toggle(look, "EspBox",       { Name = T("Box", "กล่อง"), Default = true }), Setting("Box"))
    feed(xDTaraZ.UI.Dropdown(look, "EspBoxStyle",{ Name = T("Box style", "แบบกล่อง"), Options = { "Full", "Corner" }, Default = "Full" }), Setting("BoxStyle"))
    feed(xDTaraZ.UI.Toggle(look, "EspFill",      { Name = T("Box fill", "ถมสีกล่อง") }), Setting("BoxFill"))
    feed(xDTaraZ.UI.Toggle(look, "EspName",      { Name = T("Name", "ชื่อ"), Default = true }), Setting("Name"))
    feed(xDTaraZ.UI.Toggle(look, "EspHealth",    { Name = T("Health bar", "แถบเลือด"), Default = true }), Setting("Health"))
    feed(xDTaraZ.UI.Toggle(look, "EspHealthText",{ Name = T("Health number", "ตัวเลขเลือด") }), Setting("HealthText"))
    feed(xDTaraZ.UI.Toggle(look, "EspDistance",  { Name = T("Distance", "ระยะ"), Default = true }), Setting("Distance"))
    feed(xDTaraZ.UI.Toggle(look, "EspDot",       { Name = T("Head dot", "จุดหัว") }), Setting("HeadDot"))
    feed(xDTaraZ.UI.Toggle(look, "EspTracer",    { Name = T("Tracers", "เส้นนำสายตา") }), Setting("Tracer"))
    feed(xDTaraZ.UI.Dropdown(look, "EspTracerFrom", { Name = T("Tracer from", "เส้นเริ่มจาก"), Options = { "Bottom", "Center", "Mouse" }, Default = "Bottom" }), Setting("TracerOrigin"))
    feed(xDTaraZ.UI.Toggle(look, "EspChams",     { Name = T("Chams", "เรืองแสงทะลุกำแพง") }), Setting("Chams"))
    feed(xDTaraZ.UI.Toggle(look, "EspArrows",    { Name = T("Off-screen arrows", "ลูกศรนอกจอ") }), Setting("Arrows"))
end

function xDTaraZ.UI.BuildWorld(tab)
    local world = tab:Section({ Name = T("Environment", "สภาพแวดล้อม"), Side = 1 })
    xDTaraZ.UI.Toggle(world, "Fullbright", { Name = T("Fullbright", "สว่างทั้งแมพ") })
    xDTaraZ.UI.Toggle(world, "NoFlash",   { Name = T("No flash", "กันแฟลช"), Desc = T("Immune to flashbangs", "ไม่ถูกแฟลชบอด") })
    xDTaraZ.UI.Toggle(world, "NoSmoke",   { Name = T("No smoke", "ไม่มีควัน"), Desc = T("See through smoke", "มองทะลุควัน") })

    local heard = tab:Section({ Name = T("Sound Tracking", "ตามเสียงศัตรู"), Side = 1 })
    xDTaraZ.UI.Toggle(heard, "SoundEsp",     { Name = T("Sound ESP", "ESP จากเสียง"), Desc = T("Tracks enemy footsteps and shots through walls", "ติดตามเสียงศัตรูและการยิงทะลุกำแพง") })
    xDTaraZ.UI.Slider(heard, "SoundEspLife", { Name = T("Show for", "แสดงนาน"), Min = 1, Max = 8, Default = 3, Suffix = "s" })
    xDTaraZ.UI.Slider(heard, "EspMemory",    { Name = T("Keep hidden enemies", "จำศัตรูที่หลบ"), Min = 0, Max = 15, Default = 5, Suffix = "s" })
    xDTaraZ.UI.NeedCap("SoundEsp", "Upvalues")

    local cam = tab:Section({ Name = T("View Control", "ตั้งค่ากล้อง"), Side = 2 })
    xDTaraZ.UI.Toggle(cam, "CameraFov",      { Name = T("Custom FOV", "ปรับมุมมอง") })
    xDTaraZ.UI.Slider(cam, "CameraFovValue", { Name = T("FOV", "มุมมอง"), Min = 70, Max = 120, Default = 100 })
end

function xDTaraZ.UI.BuildVisuals(window)
    -- Flat tab: ESP and World sections both sit on one page, no page-switcher.
    local tab = window:Page({ Name = T("Visuals", "การมองเห็น"), Icon = "eye" })
    tab = tab:SubPage({})
    xDTaraZ.Util.Try("build esp",   xDTaraZ.UI.BuildEsp,   tab)
    xDTaraZ.Util.Try("build world", xDTaraZ.UI.BuildWorld, tab)
end

local skinTitles = {
    Pistol = { "Pistols", "ปืนพก", "coins" },
    SMG = { "SMGs", "ปืนกลมือ", "zap" },
    Rifle = { "Rifles", "ปืนไรเฟิล", "crosshair" },
    Sniper = { "Snipers", "สไนเปอร์", "target" },
    Heavy = { "Heavy", "ปืนหนัก", "bomb" },
    Shotgun = { "Shotguns", "ลูกซอง", "bomb" },
    ["Machine Gun"] = { "Machine Guns", "ปืนกล", "zap" },
    Knives = { "Knives", "มีด", "swords" },
    Gloves = { "Gloves", "ถุงมือ", "shield" },
    Grenades = { "Grenades", "ระเบิด", "bomb" },
    Gear = { "Gear", "อุปกรณ์", "settings" },
}

---Skin pickers save to their own skins.json, so they carry no config flag.
function xDTaraZ.UI.SkinGroup(tab, category, side)
    local title = skinTitles[category] or { category, category, "star" }
    local group = tab:Section({ Name = T(title[1], title[2]), Side = side })
    for _, weapon in ipairs(xDTaraZ.Skins.Items(category)) do
        if weapon == "-" then continue end
        local values = { "Default" }
        for _, skin in ipairs(xDTaraZ.Skins.List(weapon)) do values[#values + 1] = skin end
        local widget = xDTaraZ.UI.Dropdown(group, "Skin_" .. weapon, { Name = weapon, Options = values, Default = xDTaraZ.Skins.Map[weapon] or "Default", Searchable = #values > 8, NoSave = true })
        widget:OnChanged(function(skin)
            if skin then xDTaraZ.Skins.Set(weapon, skin) end
        end)
    end
end

function xDTaraZ.UI.PlaceSkinGroup(tab, category, heights)
    local side = heights.Left <= heights.Right and "Left" or "Right"
    local rows = 1
    for _, weapon in ipairs(xDTaraZ.Skins.Items(category)) do
        if weapon ~= "-" then rows += 1 end
    end
    if rows == 1 then return end
    heights[side] += rows
    xDTaraZ.Util.Try("skins " .. category, xDTaraZ.UI.SkinGroup, tab, category, side)
end

---Shows the saved skin in every picker without setting it again.
function xDTaraZ.UI.SyncSkins()
    for _, category in ipairs(xDTaraZ.Skins.Categories()) do
        for _, weapon in ipairs(xDTaraZ.Skins.Items(category)) do
            local widget = xDTaraZ.UI.Widgets["Skin_" .. weapon]
            if widget and widget.Element then
                local skin = xDTaraZ.Skins.Map[weapon] or "Default"
                pcall(widget.Element.Set, widget.Element, skin, true)
                widget.Value = skin
            end
        end
    end
end

function xDTaraZ.UI.BuildSkins(window)
    -- Flat tab: knives, gear and every gun category all sit on one page, no page-switcher.
    local tab = window:Page({ Name = T("Skins", "สกิน"), Icon = "palette" })
    tab = tab:SubPage({})

    local main = tab:Section({ Name = T("Quick Actions", "จัดการสกิน"), Side = 1 })
    xDTaraZ.UI.Toggle(main, "SkinChanger", { Name = T("Skin changer", "เปลี่ยนสกิน"), Desc = T("Applies instantly when selected", "ขึ้นทันทีเมื่อเลือก") })
    main:Button({ Name = T("Rarest On Everything", "หายากสุดทุกอัน"), Callback = xDTaraZ.UI.Detach(function()
        local count = xDTaraZ.Skins.SetAll(function(list) return list[1] end)
        xDTaraZ.UI.SyncSkins()
        xDTaraZ.UI.Notify("Skins", "Set " .. count .. " items", 3, "Success")
    end) })
    main:Button({ Name = T("Random", "สุ่ม"), Callback = xDTaraZ.UI.Detach(function()
        xDTaraZ.Skins.SetAll(function(list) return list[math.random(#list)] end)
        xDTaraZ.UI.SyncSkins()
    end) })
    main:Button({ Name = T("Reset All", "ล้างทั้งหมด"), Callback = xDTaraZ.UI.Detach(function()
        table.clear(xDTaraZ.Skins.Map)
        xDTaraZ.Skins.Save()
        xDTaraZ.UI.SyncSkins()
    end) })

    local gear = { Knives = true, Gloves = true, Grenades = true, Gear = true }
    -- One shared height tracker so gun categories keep balancing the same
    -- two columns the knives/gear categories started, instead of resetting.
    local heights = { Left = xDTaraZ.Config.SkinMainRows, Right = 0 }
    for _, category in ipairs({ "Knives", "Gloves", "Grenades", "Gear" }) do
        xDTaraZ.UI.PlaceSkinGroup(tab, category, heights)
    end

    local ok, categories = pcall(xDTaraZ.Skins.Categories)
    for _, category in ipairs(ok and categories or {}) do
        if gear[category] then continue end
        xDTaraZ.UI.PlaceSkinGroup(tab, category, heights)
    end
end

function xDTaraZ.UI.BuildMisc(window)
    local tab = window:Page({ Name = T("Misc", "อื่นๆ"), Icon = "cart" })
    tab = tab:SubPage({})

    local buy = tab:Section({ Name = T("Round Setup", "เตรียมรอบ"), Side = 1 })
    xDTaraZ.UI.Toggle(buy, "AutoRebuy", { Name = T("Auto rebuy", "ซื้อซ้ำอัตโนมัติ"), Desc = T("Rebuys your last loadout each round", "ซื้อชุดล่าสุดให้ทุกรอบ") })
    xDTaraZ.UI.NeedCap("AutoRebuy", "HookFunction")
    buy:Button({ Name = T("Rebuy Now", "ซื้อซ้ำตอนนี้"), Callback = xDTaraZ.UI.Detach(function()
        local sent = xDTaraZ.Economy.Rebuy()
        xDTaraZ.UI.Notify("Auto Buy", sent > 0 and ("Bought " .. sent .. " items") or "Buy something once first", 3, sent > 0 and "Success" or "Info")
    end) })
    buy:Button({ Name = T("Clear", "ล้าง"), Callback = xDTaraZ.UI.Detach(function()
        table.clear(xDTaraZ.State.Bought)
    end) })

    local codes = tab:Section({ Name = T("Promo Codes", "โค้ดส่วนลด"), Side = 1 })
    codes:Button({ Name = T("Redeem All Codes", "แลกโค้ดทั้งหมด"), Callback = xDTaraZ.UI.Detach(function()
        local sent = xDTaraZ.Economy.RedeemAll()
        xDTaraZ.UI.Notify("Codes", "Sent " .. sent .. " codes (level 5+ needed)", 4, "Coin")
    end) })

    local util = tab:Section({ Name = T("Movement & Server", "การเคลื่อนที่และเซิร์ฟ"), Side = 2 })
    xDTaraZ.UI.Toggle(util, "InfiniteJump", { Name = T("Infinite jump", "กระโดดไม่จำกัด"), Desc = T("Lobby only — use Bunny hop in-game", "ล็อบบี้เท่านั้น — ใช้บันนี่ฮอปในเกม") })
    xDTaraZ.UI.Toggle(util, "BunnyHop",    { Name = T("Bunny hop", "บันนี่ฮอป"), Desc = T("Hold Space to chain jumps and keep speed", "กด Space ค้างเพื่อกระโดดต่อเนื่อง") })
    xDTaraZ.UI.Toggle(util, "BunnyCrouch", { Name = T("Crouch jump", "ย่อตอนลอย"), Desc = T("Crouches mid-air like a CS jump", "ย่อตัวกลางอากาศแบบ CS"), Default = true })
    xDTaraZ.UI.Toggle(util, "AntiAfk",     { Name = T("Anti AFK", "กันหลุด AFK") })
    util:Button({ Name = T("Rejoin", "เข้าใหม่"), Callback = xDTaraZ.UI.Detach(xDTaraZ.World.Rejoin) })
    util:Button({ Name = T("Server Hop", "ย้ายเซิร์ฟ"), Callback = xDTaraZ.UI.Detach(xDTaraZ.World.ServerHop) })
end

function xDTaraZ.UI.BuildSettings(window)
    local tab = window:Page({ Name = T("Settings", "ตั้งค่า"), Icon = "menu" })
    tab = tab:SubPage({})

    local interface = tab:Section({ Name = T("Menu Options", "ตั้งค่าเมนู"), Side = 1 })

    -- Unload button — Arcane.Unload() disconnects everything and resets the env.
    interface:Button({
        Name     = T("Unload BloxStrike", "ปิด BloxStrike"),
        Callback = function()
            xDTaraZ.UI.Unload()
        end,
    })

    -- Arcane built-in config + theme manager (save / load / autoload / themes).
    -- arcane.Config(page) builds a full config and theming UI on the given page.
    Library:Config(tab)
end

function xDTaraZ.UI.RefreshStatus()
    local labels, state = xDTaraZ.UI.Labels, xDTaraZ.State
    if labels.Map then labels.Map:Set(tostring(Workspace:GetAttribute("Map") or "-")) end
    if labels.Round then labels.Round:Set(tostring(Workspace:GetAttribute("GameState") or "-")) end
    if labels.Money then labels.Money:Set("$" .. tostring(LocalPlayer:GetAttribute("Money") or 0)) end
    if labels.Target then
        local target = state.RageTarget or state.AimTarget or state.SilentTarget
        labels.Target:Set(target and target.Name or "none")
    end
    if labels.Kills then labels.Kills:Set(tostring(LocalPlayer:GetAttribute("Kills") or 0)) end
    if labels.Shots then labels.Shots:Set(("%d / %d"):format(state.Shots, state.Redirected)) end
    if labels.Spectators then labels.Spectators:Set(xDTaraZ.Spectators.Text()) end
    if labels.Esp then
        labels.Esp:Set(xDTaraZ.Visuals:Get("Enabled") and (xDTaraZ.Esp.Count .. " players") or "Off")
    end
    if labels.Bought then labels.Bought:Set(xDTaraZ.Economy.BoughtText()) end
end

---Turns off what the scheduler halted and shows queued notices; runs on the UI loop, never on a game thread.
function xDTaraZ.UI.Drain()
    local state = xDTaraZ.State
    if not (state.Halted[1] or state.Notices[1]) then return end
    local stopped, notices = table.clone(state.Halted), table.clone(state.Notices)
    table.clear(state.Halted)
    table.clear(state.Notices)

    for _, halt in ipairs(stopped) do
        for _, key in ipairs(halt[3]) do
            local widget = xDTaraZ.UI.Widgets[key]
            if widget and widget.Value == true then xDTaraZ.Util.Try("halt " .. key, widget.SetValue, widget, false) end
        end
        xDTaraZ.UI.Notify("Aural V2", halt[1] .. " stopped: " .. halt[2], 6, "Error")
    end
    for _, notice in ipairs(notices) do
        xDTaraZ.UI.Notify(notice[1], notice[2], 5, "Warning")
    end
end

---Hooks go in the first time a feature that needs them is switched on, never at load.
function xDTaraZ.UI.HookOnDemand()
    local installers = {
        SilentAim = xDTaraZ.Silent.InstallHook,
        Ragebot = xDTaraZ.Silent.InstallHook,
        Triggerbot = xDTaraZ.Silent.InstallHook,
        NoRecoil = xDTaraZ.Guns.HookKick,
        CameraFov = xDTaraZ.Guns.BindFov,
        NoSpread = xDTaraZ.Guns.HookSpread,
        NoSmoke = xDTaraZ.World.HookEffects,
        NoFlash = xDTaraZ.World.HookEffects,
        AutoRebuy = xDTaraZ.Economy.HookBuys,
        SoundEsp = xDTaraZ.Sound.Install,
    }
    for idx, install in pairs(installers) do
        local widget = xDTaraZ.UI.Widgets[idx]
        if not widget then continue end
        widget:OnChanged(function(on)
            if on then task.defer(xDTaraZ.Util.Try, "hook " .. idx, install) end
        end)
        if widget.Value == true then task.defer(xDTaraZ.Util.Try, "hook " .. idx, install) end
    end

    local trigger = xDTaraZ.UI.Widgets.Triggerbot
    if trigger then
        trigger:OnChanged(function(on)
            if on then task.delay(xDTaraZ.Config.HookSettle, xDTaraZ.UI.WarnReducedTrigger) end
        end)
    end
end

---Triggerbot fires without the shoot hook; only shot pacing is less exact, so say so once.
function xDTaraZ.UI.WarnReducedTrigger()
    local state = xDTaraZ.State
    if state.Hooks.Shoot or state.TriggerWarned then return end
    state.TriggerWarned = true
    table.insert(state.Notices, { T("Triggerbot", "ยิงอัตโนมัติ"), T("Running in reduced mode on this executor; shot pacing is less exact", "ทำงานแบบจำกัดบน executor นี้ จังหวะยิงอาจไม่แม่นเท่าที่ควร") })
end

function xDTaraZ.UI.BlockMissing()
    local absent = xDTaraZ.GameLib.Missing
    local missing = {
        Net = xDTaraZ.GameLib.Net == nil and (absent.Remotes or true),
        Character = xDTaraZ.GameLib.Character == nil and (absent.CharacterController or true),
        Skins = xDTaraZ.Skins.Folder() == nil and "Absent",
    }
    if missing.Skins then warn("[BloxStrike] Assets.Skins not found, the skin changer is blocked") end

    local unsupported = T("Not available on this executor", "ใช้กับ executor นี้ไม่ได้")
    local outdated = T("Changed by a game update, wait for a script update", "เกมอัปเดตแล้ว รอสคริปต์อัปเดต")
    for source, features in pairs(xDTaraZ.Config.ModuleFeatures) do
        local why = missing[source]
        if not why then continue end
        for _, idx in ipairs(features) do
            xDTaraZ.UI.Block(idx, why == "Absent" and outdated or unsupported)
        end
    end
end

function xDTaraZ.UI.Build(window)
    xDTaraZ.Util.Try("skins load", xDTaraZ.Skins.Load)
    for _, build in ipairs({ xDTaraZ.UI.BuildCombat, xDTaraZ.UI.BuildVisuals, xDTaraZ.UI.BuildSkins, xDTaraZ.UI.BuildMisc }) do
        xDTaraZ.Util.Try("build", build, window)
    end
    xDTaraZ.Util.Try("settings tab", xDTaraZ.UI.BuildSettings, window)

    for key in pairs(xDTaraZ.Options) do
        local widget = xDTaraZ.UI.Widgets[key]
        if widget then xDTaraZ.Util.Try("bind " .. key, xDTaraZ.UI.Bind, widget, key) end
    end
    xDTaraZ.Util.Try("hooks", xDTaraZ.UI.HookOnDemand)
    xDTaraZ.Util.Try("missing modules", xDTaraZ.UI.BlockMissing)

    -- AuralV2 v2.6.0 skips keybind firing when `processed = true` (i.e. the menu
    -- is open), so we drive feature-toggle keybinds ourselves. The native picker
    -- button still shows and saves the bound key — we just read it here.
    xDTaraZ:Connect(UserInputService.InputBegan, function(input, processed)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if UserInputService:GetFocusedTextBox() then return end
        local window = xDTaraZ.UI.Window
        local consumed = window ~= nil
            and window._consumedKey == input.KeyCode
            and osClock() - (window._consumedAt or 0) < 0.25
        if consumed then return end
        for _, bind in ipairs(xDTaraZ.UI.FeatureBinds) do
            local kb = bind.Elem and bind.Elem.Keybind
            if not kb or kb.Listening then continue end
            local boundKey = kb:Get()
            if boundKey == nil or boundKey == Enum.KeyCode.Unknown then continue end
            if input.KeyCode ~= boundKey then continue end
            if bind.Mode == "Hold" then
                bind.Widget:SetValue(true)
            elseif bind.Mode == "Toggle" then
                bind.Widget:SetValue(not bind.Widget.Value)
            end
        end
    end)
    xDTaraZ:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        for _, bind in ipairs(xDTaraZ.UI.FeatureBinds) do
            if bind.Mode ~= "Hold" then continue end
            local kb = bind.Elem and bind.Elem.Keybind
            if not kb then continue end
            local boundKey = kb:Get()
            if boundKey and input.KeyCode == boundKey then
                bind.Widget:SetValue(false)
            end
        end
    end)
    xDTaraZ.UI.Every(xDTaraZ.Config.StatusInterval, xDTaraZ.UI.RefreshStatus)
    xDTaraZ.UI.Every(xDTaraZ.Config.StatusInterval, xDTaraZ.UI.Drain)
end

function xDTaraZ.UI.Unload()
    xDTaraZ:Unload()
    -- Arcane.Unload() disconnects all connections, destroys the GUI, and
    -- clears getgenv().Arcane so the next execution starts clean.
    if Library and Library.Unload then
        pcall(Library.Unload, Library)
    end
end

function xDTaraZ.Boot()
    xDTaraZ.Util.Try("skins load", xDTaraZ.Skins.Load)
    xDTaraZ.Util.Try("combat", xDTaraZ.Combat.Start)
    xDTaraZ:Connect(RunService.RenderStepped, xDTaraZ.Visuals.Step)
    xDTaraZ:Connect(LocalPlayer.Idled, xDTaraZ.World.OnIdled)
    xDTaraZ:Connect(UserInputService.JumpRequest, xDTaraZ.World.OnJump)
    xDTaraZ:Connect(RunService.Heartbeat, xDTaraZ.World.HopStep)
    xDTaraZ:Connect(UserInputService.InputBegan, function(input, processed) xDTaraZ.World.OnSpace(input, true, processed) end)
    xDTaraZ:Connect(UserInputService.InputEnded, function(input) xDTaraZ.World.OnSpace(input, false) end)

    xDTaraZ.Scheduler.Every("World", 0.2, xDTaraZ.World.Step, { "Fullbright" }, xDTaraZ.World.Step)
    xDTaraZ.Scheduler.Every("Auto Rebuy", 0.5, xDTaraZ.Economy.Tick, { "AutoRebuy" })
    xDTaraZ.Scheduler.Every("Sound ESP", 0.1, xDTaraZ.Sound.Step, { "SoundEsp" }, xDTaraZ.Sound.Step)
    xDTaraZ.Scheduler.Every("Skin Changer", 0.15, xDTaraZ.Skins.Step, { "SkinChanger" }, xDTaraZ.Skins.Step)
    xDTaraZ.Util.Try("scheduler", xDTaraZ.Scheduler.Boot)
end

function xDTaraZ:Unload()
    if not self.State.Alive then return end
    self.State.Alive = false
    pcall(xDTaraZ.Sound.Uninstall)
    pcall(xDTaraZ.Visuals.Destroy)
    if xDTaraZ.Esp.Folder then pcall(function() xDTaraZ.Esp.Folder:Destroy() end) end
    xDTaraZ.Combat.Unload()
    for _, key in ipairs({ "NoRecoil", "NoSpread", "Fullbright", "CameraFov", "BunnyHop", "SkinChanger" }) do
        xDTaraZ.Options[key] = false
    end
    pcall(xDTaraZ.World.Step)
    pcall(xDTaraZ.World.SetCrouch, false)
    xDTaraZ.Guns.UnbindFov()
    pcall(xDTaraZ.Skins.Step)
    for _, conn in ipairs(self.State.Connections) do pcall(function() conn:Disconnect() end) end
    table.clear(self.State.Connections)
    xDTaraZ.Util.UnhookAll()
    getgenv().BloxStrikeUnload = nil
    environment.BloxStrikeUnload = nil
end

---@return boolean  false when the menu could not be opened
---@return boolean  false when the menu could not be opened
local function BuildInterface()
    Library = xDTaraZ.Util.LoadLibrary()
    if not Library then return false end
    pcall(AuralBanner.Step, "UI library")
    xDTaraZ.Library = Library

    -- Arcane manages its own GUI parent (gethui() internally). No Parent arg needed.
    -- Set the config folder so arcane.Config page saves to our folder.
    Library.Directory    = xDTaraZ.Config.SaveFolder
    Library.ConfigFolder = xDTaraZ.Config.SaveFolder .. "/Configs"
    -- Default to Midnight theme on first load.
    if Library.CurrentTheme == "Dark" then
        pcall(Library.SetTheme, Library, "Midnight")
    end

    local opened, window = pcall(Library.Window, Library, {
        Name = "BloxStrike",
        User = LocalPlayer.DisplayName,
        Logo = "rbxassetid://98317435813811",
    })
    if not opened or type(window) ~= "table" then
        xDTaraZ.Util.Alert("The menu failed to load on this executor: " .. (tostring(window):match("^[^\n]*") or ""), window)
        return false
    end
    xDTaraZ.UI.Window = window

    -- Destroy hook: unload features when the Arcane GUI is destroyed.
    local holderOk, holder = pcall(function()
        return window.Items.Holder.Instance
    end)
    if holderOk and typeof(holder) == "Instance" then
        holder.Destroying:Connect(function()
            if xDTaraZ.State.Alive then task.spawn(xDTaraZ.Unload, xDTaraZ) end
        end)
    end

    xDTaraZ.UI.Build(window)
    task.defer(xDTaraZ.Util.Try, "boot", xDTaraZ.Boot)
    return true
end
getgenv().BloxStrikeUnload = function()
    xDTaraZ.UI.Unload()
end

pcall(AuralBanner.Step, "Systems")
if not BuildInterface() then return end
pcall(AuralBanner.Step, "Interface")
pcall(AuralBanner.Ready)
