-- // Config
local Aural = {
	Shooting = {
		PerfectTiming = true,
		AutoCalibrate = true,
		PingCompensation = true,
		PingMultiplier = 100,
		ReleasePoint = 97,
		TimingOffset = -5,

		AutoAlign = true,
		DistanceScaling = true,
		ThreePointOnly = false,

		AutoShoot = false,
		ShootRange = 27,
		RangeCircle = false,
		RangeCircleColor = Color3.fromRGB(255, 92, 146),
	},

	Dribbling = {
		DribbleGlide = false,
		GlideSpeed = 25,

		AutoAnkleBreaker = false,
		AnkleBreakRange = 8,
		AnkleBreakerMove = "Crossover",
	},

	Defense = {
		AutoBlock = false,
		BlockRange = 12,
		BlockDelay = 150,
		BlockTeamCheck = true,

		AutoGuard = false,
		GuardSprint = false,
		TeamCheck = true,
		BallHandlerOnly = true,
		GuardDistance = 4,
		GuardStrength = 70,
		GuardRange = 45,
	},

	Ball = {
		Magnets = false,
		MagnetRange = 12,
		MagnetMode = "Pull",
		MagnetSpeed = 30,
		SkipShots = true,
		ShowRange = false,
	},

	Player = {
		SpeedBoost = false,
		Speed = 20,
		CframeSpeed = false,
		CframeSpeedValue = 8,
		AutoSprint = false,
		NoStun = false,
		InfiniteStamina = true,
		AutoTakeover = false,
		NoColdZone = true,
		NoDebounce = false,
	},

	Visuals = {
		RemovePostEffects = false,
		Fullbright = false,
		CustomFov = false,
		Fov = 80,
		Spectate = false,
		SpectateTarget = nil,
	},

	Cosmetics = {
		Hats = "None",
		Hair = "None",
		FacialHair = "None",
		Glasses = "None",
		Chain = "None",
		Backpack = "None",
		Shoes = "None",
		Mascot = "None",
	},

	Effects = {
		GoalEffect = false,
		GoalEffectName = "Fire",
		IncludeTrail = true,

		AutoCelebrate = false,
		Celebration2 = "Point To Sky",
		Celebration3 = "Grenade",
		Finisher = "Flex",
		CelebrateDelay = 0.15,
	},
}

-- // Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

-- // Variables
-- Autoexec can run before the local player exists.
local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
	LocalPlayer = Players.LocalPlayer
end

while game.PlaceId == 0 do
	task.wait()
end

local GuiRoot = (gethui and gethui()) or CoreGui
local Running = true
local Connections = {}

local function Connect(Signal, Callback)
	local Connection = Signal:Connect(Callback)
	table.insert(Connections, Connection)
	return Connection
end

-- // Library
-- // AuralV2 UI Library
local AuralV2 = (function()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LucideIcons = {}
pcall(function()
	local src = game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/src/Icons.lua")
	local fn = loadstring(src)
	if type(fn) == "function" then
		local ok2, result = pcall(fn)
		if ok2 and result and result.assets then LucideIcons = result.assets end
	end
end)

local AuralV2 = { Name = "Aural V2", Version = "2.6.0", Debug = false }

local function debugLog(...)
	if AuralV2.Debug then print("[Aural V2]", ...) end
end

AuralV2.LogoAsset = "rbxassetid://98317435813811"

local atan2 = math.atan2 or function(y, x)
	if x > 0 then return math.atan(y / x) end
	if x < 0 then return math.atan(y / x) + (y >= 0 and math.pi or -math.pi) end
	if y > 0 then return math.pi / 2 end
	if y < 0 then return -math.pi / 2 end
	return 0
end

local function clamp(n, lo, hi)
	if n < lo then return lo end
	if n > hi then return hi end
	return n
end

local function merge(base, override)
	local out = {}
	for k, v in pairs(base) do out[k] = v end
	if override then
		for k, v in pairs(override) do out[k] = v end
	end
	return out
end

local function create(className, props, children)
	local inst = Instance.new(className)
	local parent = nil
	if props then
		for key, value in pairs(props) do
			if key == "Parent" then
				parent = value
			else
				inst[key] = value
			end
		end
	end
	if children then
		for _, child in ipairs(children) do child.Parent = inst end
	end
	if parent then inst.Parent = parent end
	return inst
end

local function corner(parent, radius)
	local r
	if radius == "full" then
		r = UDim.new(0.5, 0)
	else
		r = UDim.new(0, radius or 0)
	end
	return create("UICorner", { CornerRadius = r, Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function padding(parent, left, right, top, bottom)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		Parent = parent,
	})
end

local function tween(obj, duration, goal, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out)
	local t = TweenService:Create(obj, info, goal)
	t:Play()
	return t
end

local function textWidth(text, size, font)
	local ok, bounds = pcall(function()
		return TextService:GetTextSize(text, size, font, Vector2.new(10000, 10000))
	end)
	if ok and bounds then return bounds.X end
	return #text * size * 0.56
end

local function formatNumber(n)
	local s = string.format("%.3f", n)
	s = string.gsub(s, "0+$", "")
	s = string.gsub(s, "%.$", "")
	if s == "-0" then s = "0" end
	return s
end

local function snap(value, minV, maxV, step)
	value = clamp(value, minV, maxV)
	if step and step > 0 then
		value = minV + math.floor((value - minV) / step + 0.5) * step
		value = clamp(value, minV, maxV)
	end
	return tonumber(string.format("%.6f", value))
end

local function colorHex(c)
	return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
end

local function hexColor(text)
	if type(text) ~= "string" then return nil end
	local h = string.match(text, "^%s*#?(%x+)%s*$")
	if not h then return nil end
	if #h == 3 then h = (string.gsub(h, ".", function(ch) return ch .. ch end)) end
	if #h ~= 6 then return nil end
	return Color3.fromRGB(tonumber(string.sub(h, 1, 2), 16) or 0, tonumber(string.sub(h, 3, 4), 16) or 0, tonumber(string.sub(h, 5, 6), 16) or 0)
end

local function mixColor(a, b, t)
	return Color3.new(a.R + (b.R - a.R) * t, a.G + (b.G - a.G) * t, a.B + (b.B - a.B) * t)
end

local function noTheme(inst)
	inst:SetAttribute("AuralNoTheme", true)
	return inst
end

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _fns = {} }, Signal)
end

function Signal:Connect(fn)
	local fns = self._fns
	fns[#fns + 1] = fn
	return {
		Disconnect = function()
			for i = 1, #fns do
				if fns[i] == fn then
					table.remove(fns, i)
					break
				end
			end
		end,
	}
end

function Signal:Fire(...)
	local snapshot = {}
	for i = 1, #self._fns do snapshot[i] = self._fns[i] end
	for i = 1, #snapshot do
		task.spawn(snapshot[i], ...)
	end
end

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end

local DefaultTheme = {
	Name = "Aural V2",

	Font = Enum.Font.GothamMedium,
	FontBold = Enum.Font.GothamBold,
	TextSize = 12,

	BackdropTransparency = 0,
	BackdropColors = ColorSequence.new({
		ColorSequenceKeypoint.new(0.000, rgb(24, 15, 102)),
		ColorSequenceKeypoint.new(0.120, rgb(24, 15, 102)),
		ColorSequenceKeypoint.new(0.163, rgb(14, 8, 84)),
		ColorSequenceKeypoint.new(0.204, rgb(9, 4, 71)),
		ColorSequenceKeypoint.new(0.272, rgb(4, 0, 53)),
		ColorSequenceKeypoint.new(0.340, rgb(1, 0, 41)),
		ColorSequenceKeypoint.new(0.408, rgb(0, 0, 34)),
		ColorSequenceKeypoint.new(0.543, rgb(0, 0, 25)),
		ColorSequenceKeypoint.new(0.679, rgb(0, 0, 21)),
		ColorSequenceKeypoint.new(0.815, rgb(0, 0, 17)),
		ColorSequenceKeypoint.new(1.000, rgb(0, 0, 17)),
	}),

	Window = rgb(22, 23, 30),
	Sidebar = rgb(28, 29, 36),
	Card = rgb(28, 29, 38),
	Divider = rgb(33, 34, 43),
	Field = rgb(30, 30, 39),
	Button = rgb(28, 29, 36),
	NavHover = rgb(33, 34, 41),
	NavActive = rgb(38, 39, 48),
	Control = rgb(34, 35, 45),
	ControlHover = rgb(42, 43, 55),
	Track = rgb(33, 34, 43),
	Knob = rgb(255, 255, 255),
	KnobOff = rgb(52, 53, 63),

	Accent = rgb(116, 102, 255),
	AccentBar = rgb(118, 100, 248),
	FillTop = rgb(146, 130, 254),
	FillBottom = rgb(105, 88, 237),

	Text = rgb(215, 216, 222),
	TextStrong = rgb(225, 226, 235),
	TextMuted = rgb(145, 146, 155),
	TextNav = rgb(140, 140, 154),
	TextNavHover = rgb(176, 177, 188),
	TextValue = rgb(196, 197, 207),
	TextPlaceholder = rgb(145, 146, 155),
	TextDropdown = rgb(190, 190, 200),
	CrumbTab = rgb(205, 206, 214),

	IconMuted = rgb(125, 126, 138),
	IconActive = rgb(173, 174, 183),
	IconSearch = rgb(123, 125, 137),
	IconButton = rgb(196, 197, 204),
	IconCrumb = rgb(142, 143, 153),
	CrumbArrow = rgb(108, 108, 120),
	Chevron = rgb(98, 99, 110),
	Dots = rgb(200, 200, 210),

	Success = rgb(86, 201, 128),
	Warning = rgb(240, 182, 74),
	Danger = rgb(236, 91, 91),

	Check = rgb(250, 251, 255),
	CheckBorder = rgb(52, 53, 63),
	Menu = rgb(32, 33, 41),
	MenuBorder = rgb(44, 45, 55),
	MenuHover = rgb(41, 42, 53),
	AvatarBg = rgb(253, 253, 253),
	AvatarFg = rgb(0, 0, 0),
	LogoMain = rgb(244, 242, 246),
	LogoAccent = rgb(131, 63, 233),

	WindowRadius = 15,
	SidebarRadius = 22,
	CardRadius = 13,
	FieldRadius = 15,
	NavRadius = 7,
	ControlRadius = 5,
	MenuRadius = 10,
}

AuralV2.DefaultTheme = DefaultTheme

local function themeColorKeys(theme)
	local keys = {}
	for k, v in pairs(theme) do
		if typeof(v) == "Color3" then keys[#keys + 1] = k end
	end
	table.sort(keys)
	return keys
end

local NUDGES = {
	{ 0, 0, 1 }, { 0, 1, 0 }, { 1, 0, 0 }, { 0, 0, -1 }, { 0, -1, 0 }, { -1, 0, 0 },
	{ 1, 1, 0 }, { 0, 1, 1 }, { 1, 0, 1 }, { -1, -1, 0 }, { 0, -1, -1 }, { -1, 0, -1 },
	{ 0, 0, 2 }, { 0, 2, 0 }, { 2, 0, 0 }, { 0, 0, -2 }, { 0, -2, 0 }, { -2, 0, 0 },
}

local function uniquifyTheme(theme)
	local keys = themeColorKeys(theme)
	for i, k in ipairs(keys) do
		if k == "Knob" then
			table.remove(keys, i)
			table.insert(keys, 1, "Knob")
			break
		end
	end
	local used = {}
	for _, k in ipairs(keys) do
		local c = theme[k]
		local r = math.floor(c.R * 255 + 0.5)
		local g = math.floor(c.G * 255 + 0.5)
		local b = math.floor(c.B * 255 + 0.5)
		if used[colorHex(Color3.fromRGB(r, g, b))] then
			for _, n in ipairs(NUDGES) do
				local r2, g2, b2 = clamp(r + n[1], 0, 255), clamp(g + n[2], 0, 255), clamp(b + n[3], 0, 255)
				if not used[colorHex(Color3.fromRGB(r2, g2, b2))] then
					r, g, b = r2, g2, b2
					theme[k] = Color3.fromRGB(r, g, b)
					break
				end
			end
		end
		used[colorHex(Color3.fromRGB(r, g, b))] = true
	end
	return theme
end

local Icons = {}

function Icons.target(b)
	b.ring(12, 12, 10.4)
	b.ring(12, 12, 4)
end

function Icons.wind(b)
	b.line(2, 8, 9, 8)
	b.arc(9, 6, 2, 90, -150)
	b.line(2, 12, 17, 12)
	b.arc(17, 9.5, 2.5, 90, -150)
	b.line(2, 16, 12, 16)
	b.arc(12, 18, 2, -90, 150)
end

function Icons.eye(b)
	b.arc(12, 15.6, 10.6, -160, -20)
	b.arc(12, 8.4, 10.6, 20, 160)
	b.ring(12, 12, 3.6)
end

function Icons.cloud(b)
	b.arc(9, 12, 7, 90, 343.4)
	b.line(15.7, 10, 17.5, 10)
	b.arc(17.5, 14.5, 4.5, -90, 90)
	b.line(17.5, 19, 9, 19)
end

function Icons.menu(b)
	b.line(3, 5.5, 21, 5.5)
	b.line(3, 12, 21, 12)
	b.line(3, 18.5, 21, 18.5)
end

function Icons.palette(b)
	b.arc(12, 12, 10, 90, 354)
	b.arc(16, 11, 6, 0, 90)
	b.poly({ { 16, 17 }, { 14.2, 17 }, { 13.7, 17.5 }, { 14.1, 18.5 }, { 14.5, 19.5 } })
	b.arc(12, 19.5, 2.5, 0, 90)
	b.dot(13.5, 6.5, 1.2)
	b.dot(17.5, 10.5, 1.2)
	b.dot(8.5, 7.5, 1.2)
	b.dot(6.5, 12.5, 1.2)
end

function Icons.cart(b)
	b.poly({ { 2, 2 }, { 4.1, 2 }, { 6.8, 14.4 }, { 7.3, 15.5 }, { 8.7, 16 }, { 18.4, 16 },
		{ 19.7, 15.5 }, { 20.3, 14.5 }, { 22, 7 }, { 5.1, 7 } })
	b.dot(8, 21, 1.5)
	b.dot(19, 21, 1.5)
end

function Icons.search(b)
	b.ring(11, 11, 8)
	b.line(21, 21, 16.8, 16.8)
end

function Icons.folder(b)
	b.poly({ { 4, 20 }, { 20, 20 }, { 22, 18 }, { 22, 8 }, { 20, 6 }, { 12.4, 6 }, { 10.6, 5 },
		{ 9.6, 3.9 }, { 8, 3 }, { 4, 3 }, { 2, 5 }, { 2, 18 }, { 4, 20 } })
end

function Icons.chevronDown(b) b.poly({ { 5, 9 }, { 12, 16 }, { 19, 9 } }) end
function Icons.chevronRight(b) b.poly({ { 9, 5 }, { 16, 12 }, { 9, 19 } }) end
function Icons.arrowRight(b)
	b.line(4, 12, 20, 12)
	b.poly({ { 14, 6 }, { 20, 12 }, { 14, 18 } })
end
function Icons.arrowsH(b)
	b.line(3, 12, 21, 12)
	b.poly({ { 7, 7 }, { 3, 12 }, { 7, 17 } })
	b.poly({ { 17, 7 }, { 21, 12 }, { 17, 17 } })
end
function Icons.dots(b)
	b.dot(4.2, 12, 2.2)
	b.dot(12, 12, 2.2)
	b.dot(19.8, 12, 2.2)
end
function Icons.check(b) b.poly({ { 4.5, 12.5 }, { 9.5, 17.5 }, { 19.5, 6.5 } }) end
function Icons.close(b)
	b.line(6, 6, 18, 18)
	b.line(18, 6, 6, 18)
end
function Icons.lock(b)
	b.poly({ { 5.5, 11 }, { 18.5, 11 }, { 18.5, 21 }, { 5.5, 21 }, { 5.5, 11 } })
	b.arc(12, 8, 4.2, 180, 360)
	b.line(7.8, 8, 7.8, 11)
	b.line(16.2, 8, 16.2, 11)
	b.dot(12, 16, 1.3)
end
function Icons.info(b)
	b.ring(12, 12, 10.4)
	b.dot(12, 7.6, 1.3)
	b.line(12, 11, 12, 16.8)
end
function Icons.warn(b)
	b.poly({ { 12, 3.2 }, { 21.6, 19.8 }, { 2.4, 19.8 }, { 12, 3.2 } })
	b.line(12, 9.4, 12, 13.6)
	b.dot(12, 16.6, 1.1)
end
function Icons.error(b)
	b.ring(12, 12, 10.4)
	b.line(8.6, 8.6, 15.4, 15.4)
	b.line(15.4, 8.6, 8.6, 15.4)
end
function Icons.success(b)
	b.ring(12, 12, 10.4)
	b.poly({ { 7.4, 12.4 }, { 10.6, 15.6 }, { 16.8, 8.8 } })
end
function Icons.keyboard(b)
	b.poly({ { 4, 6 }, { 20, 6 }, { 22, 8 }, { 22, 16 }, { 20, 18 }, { 4, 18 }, { 2, 16 }, { 2, 8 }, { 4, 6 } })
	b.line(6, 10, 6.2, 10)
	b.line(10, 10, 10.2, 10)
	b.line(14, 10, 14.2, 10)
	b.line(18, 10, 18.2, 10)
	b.line(7, 14, 17, 14)
end

function Icons.chat(b)
	b.poly({ { 5, 4.5 }, { 19, 4.5 }, { 21, 6.5 }, { 21, 14.5 }, { 19, 16.5 }, { 11, 16.5 }, { 6.5, 20.5 }, { 6.5, 16.5 }, { 5, 16.5 }, { 3, 14.5 }, { 3, 6.5 }, { 5, 4.5 } })
	b.line(8, 9, 16, 9)
	b.line(8, 12.4, 13, 12.4)
end
function Icons.send(b)
	b.poly({ { 3.2, 11.4 }, { 20.6, 3.4 }, { 14.2, 20.6 }, { 11.2, 13.4 }, { 3.2, 11.4 } })
	b.line(11.2, 13.4, 20.6, 3.4)
end
function Icons.users(b)
	b.ring(9, 8, 3.6)
	b.arc(9, 21, 7, 200, 340)
	b.ring(17.4, 9.4, 2.8, 1.8)
	b.arc(17.8, 21, 5, 210, 330, 1.8)
end

function Icons.aural(b)
	b.line(7.8, 16.2, 16.2, 16.2, 3.2, b.accent, 1)
	b.line(12, 3.2, 3.2, 21.4, 4.4, nil, 2)
	b.line(12, 3.2, 20.8, 21.4, 4.4, nil, 2)
end

function AuralV2.RegisterIcon(name, drawFunction)
	Icons[name] = drawFunction
end

AuralV2.Icons = Icons

local function buildIcon(parent, name, size, color, sw, accent)
	local draw = Icons[name]
	sw = sw or 2
	local k = size / 24
	local holder = create("Frame", {
		Name = "Icon", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(size, size), Parent = parent,
	})
	local fills, strokes = {}, {}
	local b = { accent = accent }

	function b.dot(cx, cy, r, c, z)
		local d = 2 * r / 24
		local f = create("Frame", {
			BackgroundColor3 = c or color, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(cx / 24, cy / 24),
			Size = UDim2.fromScale(d, d), ZIndex = z or 1, Parent = holder,
		})
		corner(f, "full")
		if not c then fills[#fills + 1] = f end
		return f
	end

	function b.ring(cx, cy, r, w)
		local width = w or sw
		local d = 2 * (r - width / 2) / 24
		local f = create("Frame", {
			BackgroundTransparency = 1, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(cx / 24, cy / 24),
			Size = UDim2.fromScale(d, d), Parent = holder,
		})
		corner(f, "full")
		strokes[#strokes + 1] = stroke(f, color, width * k)
		return f
	end

	function b.line(x1, y1, x2, y2, w, c, z)
		local width = w or sw
		local dx, dy = x2 - x1, y2 - y1
		local len = math.sqrt(dx * dx + dy * dy) + width
		local f = create("Frame", {
			BackgroundColor3 = c or color, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale((x1 + x2) / 48, (y1 + y2) / 48),
			Size = UDim2.fromScale(len / 24, width / 24),
			Rotation = math.deg(atan2(dy, dx)), ZIndex = z or 1, Parent = holder,
		})
		corner(f, "full")
		if not c then fills[#fills + 1] = f end
		return f
	end

	function b.poly(pts, w, c)
		for i = 1, #pts - 1 do
			b.line(pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2], w, c)
		end
	end

	function b.arc(cx, cy, r, a0, a1, w, c)
		local n = math.max(2, math.ceil(math.abs(a1 - a0) / 22))
		local pts = {}
		for i = 0, n do
			local a = math.rad(a0 + (a1 - a0) * i / n)
			pts[#pts + 1] = { cx + r * math.cos(a), cy + r * math.sin(a) }
		end
		b.poly(pts, w, c)
	end

	draw(b)

	local icon = { Frame = holder, Name = name }
	function icon:SetColor(c)
		color = c
		for _, f in ipairs(fills) do f.BackgroundColor3 = c end
		for _, s in ipairs(strokes) do s.Color = c end
	end
	return icon
end

local function makeIcon(parent, spec, size, color, sw, accent)
    if type(spec) == "string" then
        local name = string.lower(spec)
        name = name:gsub("^lucide:", "")
        name = name:gsub("^lucide%-", "")

        local lucideAsset = LucideIcons["lucide-" .. name]

        if lucideAsset then
            spec = lucideAsset
        elseif Icons[spec] then
            return buildIcon(parent, spec, size, color, sw, accent)
        end
    end

    if spec ~= nil and spec ~= "" then
        local image = create("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.fromOffset(size, size),
            Image = (type(spec) == "number") and ("rbxassetid://" .. spec) or spec,
            ImageColor3 = color,
            ScaleType = Enum.ScaleType.Fit,
            Parent = parent,
        })

        return {
            Frame = image,
            SetColor = function(_, c)
                image.ImageColor3 = c
            end,
        }
    end

    return nil
end

local function buildLogo(parent, spec, size, theme)
	if spec == nil or spec == true then spec = AuralV2.LogoAsset end
	local holder = create("Frame", {
		Name = "LogoHolder", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(size, size), Parent = parent,
	})
	local function vectorMark(name)
		makeIcon(holder, name or "aural", size, theme.LogoMain, 2, theme.LogoAccent)
	end
	if spec == false or spec == "aural" then
		vectorMark()
		return holder
	end
	if type(spec) == "string" and Icons[spec] then
		vectorMark(spec)
		return holder
	end

	local image = spec
	if type(spec) == "number" then image = "rbxassetid://" .. spec end
	local img = create("ImageLabel", {
		Name = "Logo", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1),
		Image = image, ImageColor3 = Color3.new(1, 1, 1),
		ScaleType = Enum.ScaleType.Fit, Parent = holder, -- visible from the start: a fully transparent image is never loaded by the engine
	})
	local settled = false
	local function settle(ok)
		if settled then return end
		settled = true
		if not img.Parent then return end
		if not ok then
			debugLog("logo: image did not load, using the built-in mark")
			img:Destroy()
			vectorMark()
		end
	end
	local function loadedNow()
		local ok, v = pcall(function() return img.IsLoaded end)
		return (not ok) or v == true -- property unavailable: cannot tell, assume it is fine
	end
	local function sizeOk()
		local ok, sizeValue = pcall(function() return img.ContentImageSize end)
		if not ok or typeof(sizeValue) ~= "Vector2" then return true end
		return sizeValue.X > 0 and sizeValue.Y > 0
	end
	task.spawn(function()
		local status
		local called = pcall(function()
			ContentProvider:PreloadAsync({ img }, function(_, s) status = s end)
		end)
		if called and status ~= nil and status ~= Enum.AssetFetchStatus.Success then
			settle(false)
			return
		end
		for _ = 1, 100 do
			if loadedNow() then break end
			task.wait(0.1)
		end
		settle(loadedNow() and sizeOk())
	end)
	task.delay(12, function() settle(loadedNow()) end)
	return holder
end

local function rgbc(r, g, b) return Color3.fromRGB(r, g, b) end

local function darkSurfaces(r, g, b)
	local function d(dr, dg, db)
		return Color3.fromRGB(clamp(r + dr, 0, 255), clamp(g + dg, 0, 255), clamp(b + db, 0, 255))
	end
	return {
		Window = d(0, 0, 0), Sidebar = d(6, 6, 6), Card = d(6, 6, 8), Divider = d(11, 11, 13), Field = d(8, 7, 9),
		Button = d(6, 6, 6), NavHover = d(11, 11, 11), NavActive = d(16, 16, 18), Control = d(12, 12, 15),
		ControlHover = d(20, 20, 25), Track = d(11, 11, 13), KnobOff = d(30, 30, 33), CheckBorder = d(30, 30, 33),
		Menu = d(10, 10, 11), MenuBorder = d(22, 22, 25), MenuHover = d(19, 19, 23),
	}
end

local function accentFamily(color)
	return {
		Accent = color,
		AccentBar = mixColor(color, Color3.new(0, 0, 0), 0.04),
		FillTop = mixColor(color, Color3.new(1, 1, 1), 0.2),
		FillBottom = mixColor(color, Color3.new(0, 0, 0), 0.1),
		LogoAccent = color,
	}
end

local function backdrop(top, mid, bottom)
	return ColorSequence.new({
		ColorSequenceKeypoint.new(0, top),
		ColorSequenceKeypoint.new(0.4, mid),
		ColorSequenceKeypoint.new(1, bottom),
	})
end

local function darkTheme(base, accent, backdropColors)
	local t = darkSurfaces(base[1], base[2], base[3])
	for k, v in pairs(accentFamily(rgbc(accent[1], accent[2], accent[3]))) do t[k] = v end
	if backdropColors then t.BackdropColors = backdropColors end
	return t
end

local Themes = {
	Default = {},
	Midnight = darkTheme({ 13, 17, 28 }, { 62, 126, 240 },
		backdrop(rgbc(10, 30, 92), rgbc(2, 8, 38), rgbc(0, 2, 14))),
	Moss = darkTheme({ 17, 25, 21 }, { 60, 170, 105 },
		backdrop(rgbc(10, 70, 46), rgbc(3, 30, 20), rgbc(0, 10, 6))),
	Ember = darkTheme({ 28, 20, 19 }, { 240, 110, 50 },
		backdrop(rgbc(92, 34, 12), rgbc(36, 12, 4), rgbc(14, 4, 2))),
	Rose = darkTheme({ 27, 19, 26 }, { 226, 78, 130 },
		backdrop(rgbc(90, 14, 56), rgbc(34, 6, 24), rgbc(12, 2, 8))),
	Mono = darkTheme({ 20, 20, 21 }, { 160, 162, 172 },
		backdrop(rgbc(52, 52, 56), rgbc(22, 22, 24), rgbc(6, 6, 7))),
}

do
	local t = {
		Window = rgbc(238, 239, 244), Sidebar = rgbc(250, 250, 253), Card = rgbc(250, 250, 253),
		Divider = rgbc(228, 229, 236), Field = rgbc(246, 246, 250), Button = rgbc(250, 250, 253),
		NavHover = rgbc(238, 239, 245), NavActive = rgbc(228, 229, 239), Control = rgbc(236, 237, 243),
		ControlHover = rgbc(225, 226, 236), Track = rgbc(212, 214, 226), KnobOff = rgbc(166, 169, 190),
		CheckBorder = rgbc(196, 198, 212), Menu = rgbc(252, 252, 254), MenuBorder = rgbc(222, 223, 232),
		MenuHover = rgbc(240, 241, 247),
		Text = rgbc(40, 42, 54), TextStrong = rgbc(22, 24, 34), TextMuted = rgbc(110, 113, 128),
		TextNav = rgbc(112, 115, 130), TextNavHover = rgbc(70, 73, 90), TextValue = rgbc(60, 63, 78),
		TextPlaceholder = rgbc(142, 145, 160), TextDropdown = rgbc(64, 67, 82), CrumbTab = rgbc(50, 53, 68),
		IconMuted = rgbc(130, 133, 148), IconActive = rgbc(60, 63, 80), IconSearch = rgbc(130, 133, 148),
		IconButton = rgbc(70, 73, 90), IconCrumb = rgbc(110, 113, 128), CrumbArrow = rgbc(150, 153, 168),
		Chevron = rgbc(140, 143, 158), Dots = rgbc(90, 93, 108), Check = rgbc(30, 32, 44),
		Success = rgbc(34, 160, 90), Warning = rgbc(214, 140, 20), Danger = rgbc(214, 60, 60),
		AvatarBg = rgbc(236, 237, 243), LogoMain = rgbc(30, 32, 44),
		BackdropColors = backdrop(rgbc(214, 218, 236), rgbc(232, 234, 244), rgbc(244, 245, 250)),
	}
	for k, v in pairs(accentFamily(rgbc(92, 80, 232))) do t[k] = v end
	Themes.Light = t
end

AuralV2.Themes = Themes

function AuralV2.AddTheme(name, overrides)
	if type(name) ~= "string" or name == "" or type(overrides) ~= "table" then return false end
	Themes[name] = overrides
	return true
end

local function resolveTheme(spec)
	local name = "Default"
	local overrides = nil
	if type(spec) == "string" then
		if Themes[spec] then
			name, overrides = spec, Themes[spec]
		else
			debugLog("unknown theme '" .. spec .. "', using the default")
		end
	elseif type(spec) == "table" then
		overrides = spec
		name = type(spec.Name) == "string" and spec.Name or "Custom"
	end
	local theme = merge(DefaultTheme, overrides)
	theme.Name = name
	uniquifyTheme(theme)
	return theme, name
end

local COLOR_PROPS = {
	Frame = { "BackgroundColor3" },
	CanvasGroup = { "BackgroundColor3" },
	TextLabel = { "BackgroundColor3", "TextColor3" },
	TextButton = { "BackgroundColor3", "TextColor3" },
	TextBox = { "BackgroundColor3", "TextColor3", "PlaceholderColor3" },
	ImageLabel = { "BackgroundColor3", "ImageColor3" },
	ScrollingFrame = { "BackgroundColor3", "ScrollBarImageColor3" },
	UIStroke = { "Color" },
}

local function recolorTree(root, map)
	local changed = 0
	local function walk(inst)
		if inst:GetAttribute("AuralNoTheme") == true then return end
		local class = inst.ClassName
		local props = COLOR_PROPS[class]
		if props then
			for _, prop in ipairs(props) do
				local ok, current = pcall(function() return inst[prop] end)
				if ok and typeof(current) == "Color3" then
					local new = map[colorHex(current)]
					if new then
						inst[prop] = new
						changed = changed + 1
					end
				end
			end
		elseif class == "UIGradient" then
			local ok, seq = pcall(function() return inst.Color end)
			if ok and seq then
				local out, any = {}, false
				for i, k in ipairs(seq.Keypoints) do
					local new = map[colorHex(k.Value)]
					if new then any = true end
					out[i] = ColorSequenceKeypoint.new(k.Time, new or k.Value)
				end
				if any then
					inst.Color = ColorSequence.new(out)
					changed = changed + 1
				end
			end
		end
		for _, child in ipairs(inst:GetChildren()) do walk(child) end
	end
	walk(root)
	return changed
end

local L = {
	RootW = 918, RootH = 558,
	PanelX = 54,
	SidebarW = 191, SidebarInset = 10,
	NavX = 10, NavY = 58, NavW = 175, NavH = 32, NavPitch = 32.5,
	BodyX = 206, BodyRight = 12,
	TopY = 10, TopH = 44, SearchW = 316,
	CrumbY = 73,
	PagesY = 111, PagesBottom = 13,
	RowH = 48, PadX = 12, Gap = 12,
	DescRowH = 62, -- rows that carry a description line
}

local function makeCheckbox(theme, parent, default, style)
	local state = default == true
	local btn = create("TextButton", {
		Name = "Checkbox", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.Control, Size = UDim2.fromOffset(16, 16), Parent = parent,
	})
	corner(btn, 4)
	local outline = stroke(btn, theme.CheckBorder, 1)
	local tick = nil
	if style == "Tick" then
		tick = makeIcon(btn, "check", 12, theme.Knob, 3.2)
		tick.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		tick.Frame.Position = UDim2.fromScale(0.5, 0.5)
	end
	local self = { Button = btn, Changed = Signal.new() }
	local function onColor()
		if style == "Tick" then return theme.Accent end
		return theme.Check
	end

	local function render(animate)
		local color = theme.Control
		if state then color = onColor() end
		if animate then
			tween(btn, 0.12, { BackgroundColor3 = color })
		else
			btn.BackgroundColor3 = color
		end
		outline.Transparency = state and 1 or 0
		if tick then tick.Frame.Visible = state end
	end

	function self:Set(v, silent)
		v = v == true
		if v == state then return end
		state = v
		render(true)
		if not silent then self.Changed:Fire(state) end
	end
	function self:Get() return state end

	btn.MouseButton1Click:Connect(function() self:Set(not state) end)
	render(false)
	return self
end

local function newStack(row)
	local stack = { cursor = -L.PadX, leftEdge = -L.PadX }
	function stack:Place(obj, width, gap)
		obj.AnchorPoint = Vector2.new(1, 0.5)
		obj.Position = UDim2.new(1, self.cursor, 0.5, 0)
		self.leftEdge = self.cursor - width
		self.cursor = self.leftEdge - (gap or L.Gap)
	end
	function stack:Finish()
		row.LabelW = self.leftEdge - 8 - L.PadX
		row.Section:_layoutRow(row)
	end
	return stack
end

local function bindDrag(hit, onMove, onEnd)
	hit.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			onMove(input.Position.X, true, input.Position.Y)
			local moveConn, endConn
			moveConn = UserInputService.InputChanged:Connect(function(i)
				local it = i.UserInputType
				if it == Enum.UserInputType.MouseMovement or it == Enum.UserInputType.Touch then
					onMove(i.Position.X, false, i.Position.Y)
				end
			end)
			endConn = UserInputService.InputEnded:Connect(function(i)
				local it = i.UserInputType
				if it == Enum.UserInputType.MouseButton1 or it == Enum.UserInputType.Touch then
					moveConn:Disconnect()
					endConn:Disconnect()
					if onEnd then onEnd() end
				end
			end)
		end
	end)
end

local function attachCommon(obj, row, o)
	obj.Row = row
	row.Obj = obj
	function obj:SetLabel(text)
		row.Label.Text = text
		row.SearchText = text
	end
	function obj:SetVisible(visible)
		row.Hidden = not visible
		row.Section:_refresh()
	end
	function obj:SetDesc(text)
		row.Section:_setRowDesc(row, text)
	end
	function obj:GetDesc() return row.DescText or "" end
	function obj:SetLocked(locked)
		row.Section:_setRowLocked(row, locked == true)
	end
	function obj:IsLocked() return row.Locked == true end
	function obj:Destroy()
		row.Section.Window:_unregisterControl(obj)
		row.Section:_removeRow(row)
	end
	if o then
		local desc = o.Desc
		if desc == nil then desc = o.Description end
		if desc ~= nil and desc ~= "" then obj:SetDesc(desc) end
		if o.Locked == true then obj:SetLocked(true) end
	end
end

local function parseNumber(text)
	text = string.gsub(tostring(text), ",", ".")
	local n = tonumber(string.match(text, "^%s*([%+%-]?%d*%.?%d+)"))
	if n ~= nil and n == n and n > -1e15 and n < 1e15 then return n end
	return nil
end

local function makeValueBox(theme, props, typed, hooks)
	if not typed then return create("TextLabel", props) end
	props.ClearTextOnFocus = false
	local box = create("TextBox", props)
	corner(box, 5)
	local outline = stroke(box, theme.AccentBar, 1, 1)
	local align = props.TextXAlignment
	box.Focused:Connect(function()
		box.BackgroundColor3 = theme.Control
		box.BackgroundTransparency = 0
		box.TextXAlignment = Enum.TextXAlignment.Center
		tween(outline, 0.12, { Transparency = 0 })
		hooks.onFocus()
	end)
	box.FocusLost:Connect(function()
		box.BackgroundTransparency = 1
		box.TextXAlignment = align
		tween(outline, 0.12, { Transparency = 1 })
		local n = parseNumber(box.Text)
		if n ~= nil then hooks.commit(n) end
		hooks.show()
	end)
	return box
end

local Section = {}
Section.__index = Section

function Section.new(window, page, column, options, order)
	local theme = window.Theme
	local self = setmetatable({ Window = window, Page = page, Theme = theme, Rows = {} }, Section)
	local title = options.Title
	if title == nil then title = options.Name end
	if title == nil then title = "Section" end
	self.Title = (title == false) and "" or tostring(title)

	self.Frame = create("Frame", {
		Name = "Section", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = order, Parent = column,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 13), Parent = self.Frame,
	})
	if title ~= false then
		self.TitleLabel = create("TextLabel", {
			Name = "Title", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 16),
			Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.Text,
			TextXAlignment = Enum.TextXAlignment.Left, Text = tostring(title),
			LayoutOrder = 1, Parent = self.Frame,
		})
	end
	self.Card = create("Frame", {
		Name = "Card", BackgroundColor3 = theme.Card, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = 2, Parent = self.Frame,
	})
	corner(self.Card, theme.CardRadius)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = self.Card })
	return self
end

function Section:SetTitle(text)
	if self.TitleLabel then self.TitleLabel.Text = text end
end

function Section:_addRow(name, searchText)
	local theme = self.Theme
	local row = { Section = self, Hidden = false, Filtered = false, SearchText = searchText or name or "" }
	row.Frame = create("Frame", {
		Name = "Row", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, L.RowH), LayoutOrder = #self.Rows + 1, Parent = self.Card,
	})
	row.Divider = create("Frame", {
		Name = "Divider", BackgroundColor3 = theme.Divider, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1), Parent = row.Frame,
	})
	row.Label = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1,
		Position = UDim2.fromOffset(L.PadX, 0), Size = UDim2.new(1, -L.PadX * 2, 1, 0),
		Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.TextMuted,
		TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		Text = name or "", Parent = row.Frame,
	})
	self.Rows[#self.Rows + 1] = row
	self:_refresh()
	return row
end

function Section:_removeRow(row)
	for i, r in ipairs(self.Rows) do
		if r == row then
			table.remove(self.Rows, i)
			break
		end
	end
	row.Frame:Destroy()
	self:_refresh()
end

function Section:_layoutRow(row)
	if row.ManualLabel then return end
	local lockShift = row.Locked and 20 or 0
	local wOff = (row.LabelW or (-L.PadX * 2)) - lockShift
	local x = L.PadX + lockShift
	local hasDesc = row.DescLabel ~= nil and row.DescLabel.Text ~= ""
	if hasDesc then
		row.Frame.Size = UDim2.new(1, 0, 0, L.DescRowH)
		row.Label.Position = UDim2.fromOffset(x, 9)
		row.Label.Size = UDim2.new(1, wOff, 0, 18)
		row.DescLabel.Position = UDim2.fromOffset(x, 29)
		row.DescLabel.Size = UDim2.new(1, wOff, 0, 16)
		row.DescLabel.Visible = true
	else
		row.Frame.Size = UDim2.new(1, 0, 0, row.BaseH or L.RowH)
		row.Label.Position = UDim2.fromOffset(x, 0)
		row.Label.Size = UDim2.new(1, wOff, 1, 0)
		if row.DescLabel then row.DescLabel.Visible = false end
	end
	if row.LockIcon then
		row.LockIcon.Frame.Position = UDim2.new(0, L.PadX, 0.5, -7)
	end
end

function Section:_setRowDesc(row, text)
	if row.ManualLabel then return end
	text = (text == nil or text == false) and "" or tostring(text)
	row.DescText = text
	if text ~= "" and not row.DescLabel then
		local theme = self.Theme
		row.DescLabel = create("TextLabel", {
			Name = "Desc", BackgroundTransparency = 1, Font = theme.Font, TextSize = 11,
			TextColor3 = theme.TextPlaceholder, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Text = "", Parent = row.Frame,
		})
	end
	if row.DescLabel then row.DescLabel.Text = text end
	row.SearchText = (row.Label.Text or "") .. (text ~= "" and (" " .. text) or "")
	self:_layoutRow(row)
end

function Section:_setRowLocked(row, locked)
	if (row.Locked == true) == locked then return end
	row.Locked = locked
	local theme = self.Theme
	if locked and not row.LockOverlay then
		row.LockOverlay = create("TextButton", {
			Name = "Lock", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
			BackgroundColor3 = theme.Card, BackgroundTransparency = 0.4,
			Position = UDim2.fromOffset(4, 3), Size = UDim2.new(1, -8, 1, -6), ZIndex = 10, Parent = row.Frame,
		})
		corner(row.LockOverlay, 8)
		row.LockIcon = makeIcon(row.Frame, "lock", 13, theme.TextPlaceholder, 2.2)
		row.LockIcon.Frame.ZIndex = 11
	end
	if row.LockOverlay then row.LockOverlay.Visible = locked end
	if row.LockIcon then row.LockIcon.Frame.Visible = locked end
	if row.Obj then row.Obj._locked = locked end
	self:_layoutRow(row)
end

function Section:SetLocked(locked)
	for _, row in ipairs(self.Rows) do self:_setRowLocked(row, locked == true) end
end

function Section:_refresh()
	local first = true
	local visible = 0
	for _, row in ipairs(self.Rows) do
		local show = (not row.Hidden) and (not row.Filtered)
		row.Frame.Visible = show
		if show then
			row.Divider.Visible = not first
			first = false
			visible = visible + 1
		end
	end
	self.Frame.Visible = visible > 0 or #self.Rows == 0
	return visible
end

function Section:_applyFilter(query)
	for _, row in ipairs(self.Rows) do
		row.Filtered = query ~= "" and not string.find(string.lower(row.SearchText), query, 1, true)
	end
	return self:_refresh()
end

function Section:AddToggle(o)
	o = o or {}
	local theme = self.Theme
	local row = self:_addRow(o.Name or "Toggle", o.SearchText)
	local stack = newStack(row)
	local state = o.Default == true
	local obj: any = { Kind = "Toggle", Changed = Signal.new(), OptionsClicked = Signal.new() }

	local switch = create("TextButton", {
		Name = "Switch", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.Control, Size = UDim2.fromOffset(33, 20), Parent = row.Frame,
	})
	corner(switch, "full")
	local knob = create("Frame", {
		Name = "Knob", BorderSizePixel = 0, BackgroundColor3 = theme.KnobOff,
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 1, 0.5, 0),
		Size = UDim2.fromOffset(18, 18), Parent = switch,
	})
	corner(knob, "full")
	stack:Place(switch, 33)

	if o.Checkbox then
		local cfg = o.Checkbox
		if type(cfg) ~= "table" then cfg = {} end
		obj.Checkbox = makeCheckbox(theme, row.Frame, cfg.Default, cfg.Style)
		stack:Place(obj.Checkbox.Button, 16)
		if cfg.Callback then obj.Checkbox.Changed:Connect(cfg.Callback) end
	end

	local keybindAction = nil -- set by Keybind.OnPress: the key runs this instead of flipping the switch
	if o.Keybind then
		local cfg = o.Keybind
		if type(cfg) ~= "table" then cfg = {} end
		obj.Keybind = self.Window:_newKeybind(row.Frame, cfg, { Locked = function() return row.Locked == true end })
		if type(cfg.OnPress) == "function" then
			keybindAction = cfg.OnPress
			if obj.Keybind.Mode ~= "None" then obj.Keybind.Mode = "Press" end
		end
		stack:Place(obj.Keybind.Button, obj.Keybind.Width)
	end

	if o.Options then
		local dots = create("TextButton", {
			Name = "Options", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
			Size = UDim2.fromOffset(22, 24), Parent = row.Frame,
		})
		local icon = makeIcon(dots, "dots", 14, theme.Dots, 2)
		icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Frame.Position = UDim2.fromScale(0.5, 0.5)
		dots.MouseEnter:Connect(function() icon:SetColor(theme.TextStrong) end)
		dots.MouseLeave:Connect(function() icon:SetColor(theme.Dots) end)
		dots.MouseButton1Click:Connect(function()
			obj.OptionsClicked:Fire()
			if type(o.Options) == "function" then task.spawn(o.Options) end
			if o.OnOptions then task.spawn(o.OnOptions) end
		end)
		stack:Place(dots, 22)
	end
	stack:Finish()

	local function render(animate)
		local knobX = state and 14 or 1
		local knobColor = state and theme.Accent or theme.KnobOff
		local labelColor = state and theme.Text or theme.TextMuted
		if animate then
			tween(knob, 0.16, { Position = UDim2.new(0, knobX, 0.5, 0), BackgroundColor3 = knobColor })
			tween(row.Label, 0.16, { TextColor3 = labelColor })
		else
			knob.Position = UDim2.new(0, knobX, 0.5, 0)
			knob.BackgroundColor3 = knobColor
			row.Label.TextColor3 = labelColor
		end
	end

	function obj:Set(value, silent)
		value = value == true
		if value == state then return end
		state = value
		render(true)
		if not silent then self.Changed:Fire(state) end
	end
	function obj:Get() return state end
	function obj:Toggle() self:Set(not state) end

	switch.MouseButton1Click:Connect(function() obj:Toggle() end)
	if obj.Keybind then
		local keybind = obj.Keybind
		keybind.Triggered:Connect(function(active)
			if keybindAction then
				task.spawn(keybindAction)
				return
			end
			if obj.Keybind.Mode == "Hold" then obj:Set(active) else obj:Toggle() end
		end)
	end
	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	if obj.Keybind then
		local baseDestroy = (obj :: any).Destroy
		function obj:Destroy()
			self.Keybind:Destroy()
			baseDestroy(self)
		end
	end
	render(false)
	function obj:_serialize()
		if self.Checkbox or self.Keybind then
			local t = { on = state }
			if self.Checkbox then t.checked = self.Checkbox:Get() end
			if self.Keybind then t.key = self.Keybind:GetName() end
			return t
		end
		return state
	end
	function obj:_deserialize(v, silent)
		if type(v) == "boolean" then
			self:Set(v, silent)
			return true
		end
		if type(v) == "table" and type(v.on) == "boolean" then
			self:Set(v.on, silent)
			if self.Checkbox and type(v.checked) == "boolean" then self.Checkbox:Set(v.checked, silent) end
			if self.Keybind and type(v.key) == "string" then self.Keybind:SetByName(v.key, silent) end
			return true
		end
		return false
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddSlider(o)
	o = o or {}
	local theme = self.Theme
	local minV, maxV = o.Min or 0, o.Max or 100
	local step = o.Increment or 1
	local suffix = o.Suffix or ""
	local value = snap(o.Default or minV, minV, maxV, step)
	local row = self:_addRow(o.Name or "Slider", o.SearchText)
	local stack = newStack(row)
	local obj: any = { Kind = "Slider", Changed = Signal.new() }
	local trackW = o.Width or 120

	local holder = create("Frame", {
		Name = "Slider", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(trackW, 28), Parent = row.Frame,
	})
	local track = create("Frame", {
		Name = "Track", BackgroundColor3 = theme.Track, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 12), Parent = holder,
	})
	corner(track, "full")
	local fill = create("Frame", {
		Name = "Fill", BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0), Parent = track,
	})
	corner(fill, "full")
	create("UIGradient", {
		Rotation = 90, Color = ColorSequence.new(theme.FillTop, theme.FillBottom), Parent = fill,
	})
	local knob = create("Frame", {
		Name = "Knob", BackgroundColor3 = theme.Knob, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(19, 14), ZIndex = 2, Parent = track,
	})
	corner(knob, "full")
	local hit = create("TextButton", {
		Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(1, 24, 1, 0), ZIndex = 3, Parent = holder,
	})
	local hooks = { onFocus = function() end, commit = function(_n) end, show = function() end }
	local valueLabel = makeValueBox(theme, {
		Name = "Value", BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.fromOffset(60, 20),
		Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.TextValue, BackgroundColor3 = theme.Control,
		TextXAlignment = Enum.TextXAlignment.Right, Text = "", Parent = row.Frame,
	}, o.Typed ~= false, hooks)
	stack:Place(holder, trackW)
	stack:Place(valueLabel, 60)
	stack:Finish()

	local function render(animate)
		local frac = 0
		if maxV > minV then frac = (value - minV) / (maxV - minV) end
		valueLabel.Text = formatNumber(value) .. suffix
		if animate then
			tween(fill, 0.12, { Size = UDim2.new(frac, 0, 1, 0) })
			tween(knob, 0.12, { Position = UDim2.new(frac, 0, 0.5, 0) })
		else
			fill.Size = UDim2.new(frac, 0, 1, 0)
			knob.Position = UDim2.new(frac, 0, 0.5, 0)
		end
	end

	function obj:Set(v, silent, animate)
		v = snap(tonumber(v) or value, minV, maxV, step)
		if v == value then return end
		value = v
		render(animate == true)
		if not silent then self.Changed:Fire(value) end
	end
	function obj:Get() return value end

	hooks.onFocus = function() valueLabel.Text = formatNumber(value) end -- plain number while typing
	hooks.commit = function(n) obj:Set(n, false, true) end
	hooks.show = function() render(false) end

	bindDrag(hit, function(x, began)
		local w = track.AbsoluteSize.X
		if w <= 0 then return end
		local frac = clamp((x - track.AbsolutePosition.X) / w, 0, 1)
		obj:Set(minV + frac * (maxV - minV))
		if began then tween(knob, 0.1, { Size = UDim2.fromOffset(21, 16) }) end
	end, function()
		tween(knob, 0.1, { Size = UDim2.fromOffset(19, 14) })
	end)

	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	render(false)
	function obj:_serialize() return value end
	function obj:_deserialize(v, silent)
		if type(v) ~= "number" or v ~= v then return false end
		self:Set(v, silent, true)
		return true
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddRangeSlider(o)
	o = o or {}
	local theme = self.Theme
	local minV, maxV = o.Min or 0, o.Max or 100
	local step = o.Increment or 1
	local suffix = o.Suffix or ""
	local lo = snap(o.DefaultMin or minV, minV, maxV, step)
	local hi = snap(o.DefaultMax or maxV, minV, maxV, step)
	if lo > hi then lo, hi = hi, lo end
	local row = self:_addRow(o.Name or "Range", o.SearchText)
	local stack = newStack(row)
	local obj: any = { Kind = "RangeSlider", Changed = Signal.new() }
	local trackW, inset = o.Width or 120, 6

	local holder = create("Frame", {
		Name = "Range", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(trackW + inset * 2 + 1, 28), Parent = row.Frame,
	})
	local track = create("Frame", {
		Name = "Track", BackgroundColor3 = theme.Track, BorderSizePixel = 0,
		Position = UDim2.new(0, inset, 0.5, -4), Size = UDim2.fromOffset(trackW, 8), Parent = holder,
	})
	corner(track, "full")
	local fill = create("Frame", {
		Name = "Fill", BackgroundColor3 = theme.AccentBar, BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0), Parent = track,
	})
	local function newKnob(name)
		local k = create("Frame", {
			Name = name, BackgroundColor3 = theme.Knob, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.fromOffset(12, 12), ZIndex = 2, Parent = track,
		})
		corner(k, "full")
		return k
	end
	local knobLo = newKnob("KnobMin")
	local knobHi = newKnob("KnobMax")
	local hit = create("TextButton", {
		Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), ZIndex = 3, Parent = holder,
	})

	local valueFrame = create("Frame", {
		Name = "Value", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromOffset(78, 20), Parent = row.Frame,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = valueFrame,
	})
	local typed = o.Typed ~= false
	local loHooks = { onFocus = function() end, commit = function(_n) end, show = function() end }
	local hiHooks = { onFocus = function() end, commit = function(_n) end, show = function() end }
	local function valueText(order, hooks)
		return makeValueBox(theme, {
			Name = order == 1 and "Min" or "Max",
			BackgroundTransparency = 1, BorderSizePixel = 0, BackgroundColor3 = theme.Control,
			Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
			Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.TextValue,
			TextXAlignment = Enum.TextXAlignment.Left, Text = "", LayoutOrder = order, Parent = valueFrame,
		}, typed, hooks)
	end
	local loLabel = valueText(1, loHooks)
	local arrow = makeIcon(valueFrame, "arrowsH", 10, theme.TextNav, 2.6)
	arrow.Frame.LayoutOrder = 2
	local hiLabel = valueText(3, hiHooks)

	stack:Place(holder, trackW + inset * 2 + 1)
	stack:Place(valueFrame, 78)
	stack:Finish()

	local function render()
		local span = maxV - minV
		local flo, fhi = 0, 0
		if span > 0 then
			flo = (lo - minV) / span
			fhi = (hi - minV) / span
		end
		loLabel.Text = formatNumber(lo) .. suffix
		hiLabel.Text = formatNumber(hi) .. suffix
		fill.Position = UDim2.new(flo, 0, 0, 0)
		fill.Size = UDim2.new(fhi - flo, 0, 1, 0)
		knobLo.Position = UDim2.new(flo, 0, 0.5, 0)
		knobHi.Position = UDim2.new(fhi, 0, 0.5, 0)
	end

	function obj:Set(newLo, newHi, silent)
		newLo = snap(tonumber(newLo) or lo, minV, maxV, step)
		newHi = snap(tonumber(newHi) or hi, minV, maxV, step)
		if newLo > newHi then newLo, newHi = newHi, newLo end
		if newLo == lo and newHi == hi then return end
		lo, hi = newLo, newHi
		render()
		if not silent then self.Changed:Fire(lo, hi) end
	end
	function obj:Get() return lo, hi end

	loHooks.onFocus = function() loLabel.Text = formatNumber(lo) end
	loHooks.commit = function(n) obj:Set(math.min(n, hi), hi) end
	loHooks.show = function() render() end
	hiHooks.onFocus = function() hiLabel.Text = formatNumber(hi) end
	hiHooks.commit = function(n) obj:Set(lo, math.max(n, lo)) end
	hiHooks.show = function() render() end

	local active = "lo"
	bindDrag(hit, function(x, began)
		local w = track.AbsoluteSize.X
		if w <= 0 then return end
		local v = minV + clamp((x - track.AbsolutePosition.X) / w, 0, 1) * (maxV - minV)
		if began then
			local dLo, dHi = math.abs(v - lo), math.abs(v - hi)
			if dLo == dHi then
				active = (v < lo) and "lo" or "hi"
			else
				active = (dLo < dHi) and "lo" or "hi"
			end
		end
		if active == "lo" then
			obj:Set(math.min(v, hi), hi)
		else
			obj:Set(lo, math.max(v, lo))
		end
	end)

	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	render()
	function obj:_serialize() return { min = lo, max = hi } end
	function obj:_deserialize(v, silent)
		if type(v) ~= "table" or type(v.min) ~= "number" or type(v.max) ~= "number" then return false end
		if v.min ~= v.min or v.max ~= v.max then return false end
		self:Set(v.min, v.max, silent)
		return true
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddDropdown(o)
	o = o or {}
	local theme = self.Theme
	local values = o.Values or {}
	local multi = o.Multi == true
	local current = o.Default
	if not multi and current == nil then current = values[1] end
	local row = self:_addRow(o.Name or "Dropdown", o.SearchText)
	local stack = newStack(row)
	local obj: any = { Kind = "Dropdown", Changed = Signal.new(), Values = values, Multi = multi }

	local function labelOf(v)
		if v == nil then return "-" end
		return tostring(v)
	end
	local function known(v)
		for _, x in ipairs(obj.Values) do
			if x == v then return true end
		end
		return false
	end

	local chosen = {}
	if multi then
		if type(o.Default) == "table" then
			for _, v in ipairs(o.Default) do
				if known(v) then chosen[v] = true end
			end
		elseif o.Default ~= nil and known(o.Default) then
			chosen[o.Default] = true
		end
	end
	local function chosenList()
		local out = {}
		for _, v in ipairs(obj.Values) do
			if chosen[v] then out[#out + 1] = v end
		end
		return out
	end
	local noneText = o.Placeholder or "None"
	local function summary()
		if not multi then return labelOf(current) end
		local list = chosenList()
		if #list == 0 then return noneText end
		if #list == 1 then return labelOf(list[1]) end
		if #list == #obj.Values then return "All" end
		return #list .. " selected"
	end

	local longest = summary()
	local candidates = {}
	for _, v in ipairs(values) do candidates[#candidates + 1] = labelOf(v) end
	if multi then
		candidates[#candidates + 1] = noneText
		candidates[#candidates + 1] = "All"
		candidates[#candidates + 1] = #values .. " selected"
	end
	for _, c in ipairs(candidates) do
		if textWidth(c, 11, theme.Font) > textWidth(longest, 11, theme.Font) then longest = c end
	end
	local width = math.max(math.floor(textWidth(longest, 11, theme.Font) + 44 + 0.5), o.MinWidth or 0)

	local button = create("TextButton", {
		Name = "Dropdown", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.Control, Size = UDim2.fromOffset(width, 22), Parent = row.Frame,
	})
	corner(button, theme.ControlRadius)
	local text = create("TextLabel", {
		Name = "Text", BackgroundTransparency = 1, Position = UDim2.fromOffset(13, 0),
		Size = UDim2.new(1, -38, 1, 0), Font = theme.Font, TextSize = 11,
		TextColor3 = theme.TextDropdown, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Text = summary(), Parent = button,
	})
	local chevron = makeIcon(button, "chevronDown", 8, theme.Chevron, 2.5)
	chevron.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	chevron.Frame.Position = UDim2.new(1, -15, 0.5, 0)

	stack:Place(button, width)
	if o.Checkbox then
		local cfg = o.Checkbox
		if type(cfg) ~= "table" then cfg = {} end
		obj.Checkbox = makeCheckbox(theme, row.Frame, cfg.Default, cfg.Style)
		stack:Place(obj.Checkbox.Button, 16)
		if cfg.Callback then obj.Checkbox.Changed:Connect(cfg.Callback) end
	end
	stack:Finish()

	local function sameSet(a, b)
		for _, v in ipairs(obj.Values) do
			if (a[v] == true) ~= (b[v] == true) then return false end
		end
		return true
	end

	function obj:Set(v, silent)
		if multi then
			local new = {}
			if type(v) == "table" then
				for _, x in ipairs(v) do
					if known(x) then new[x] = true end
				end
			elseif v ~= nil and known(v) then
				new[v] = true
			end
			if sameSet(new, chosen) then return end
			chosen = new
			text.Text = summary()
			if not silent then self.Changed:Fire(chosenList()) end
			return
		end
		if v == current then return end
		current = v
		text.Text = labelOf(v)
		if not silent then self.Changed:Fire(v) end
	end
	function obj:Get()
		if multi then return chosenList() end
		return current
	end
	function obj:SetValues(list)
		self.Values = list
		if multi then
			local keep = {}
			for _, v in ipairs(list) do
				if chosen[v] then keep[#keep + 1] = v end
			end
			chosen = {}
			for _, v in ipairs(keep) do chosen[v] = true end
			text.Text = summary()
			return
		end
		local found = false
		for _, v in ipairs(list) do
			if v == current then found = true end
		end
		if not found then self:Set(list[1]) end
	end
	function obj:IsSelected(v)
		if multi then return chosen[v] == true end
		return current == v
	end

	button.MouseEnter:Connect(function() tween(button, 0.1, { BackgroundColor3 = theme.ControlHover }) end)
	button.MouseLeave:Connect(function() tween(button, 0.1, { BackgroundColor3 = theme.Control }) end)
	button.MouseButton1Click:Connect(function()
		local items = {}
		for _, v in ipairs(obj.Values) do
			items[#items + 1] = { Text = labelOf(v), Value = v }
		end
		local searchable = o.Search
		if searchable == nil then searchable = #items >= 8 end
		if multi then
			self.Window:_openMenu(button, items, {
				Align = "Right", Multi = true, Selected = chosen, Search = searchable == true,
				OnToggle = function(v, on)
					local out = {}
					for _, x in ipairs(obj.Values) do
						local keep = chosen[x] == true
						if x == v then keep = on end
						if keep then out[#out + 1] = x end
					end
					obj:Set(out)
				end,
				OnBulk = function(on, visibleValues)
					local mark = {}
					for _, v in ipairs(visibleValues) do mark[v] = true end
					local out = {}
					for _, x in ipairs(obj.Values) do
						local keep = chosen[x] == true
						if mark[x] then keep = on end
						if keep then out[#out + 1] = x end
					end
					obj:Set(out)
				end,
			})
			return
		end
		self.Window:_openMenu(button, items, {
			Selected = current, Align = "Right", Search = searchable == true,
			OnSelect = function(v) obj:Set(v) end,
		})
	end)

	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	function obj:_serialize()
		local v
		if multi then
			v = {}
			for _, x in ipairs(chosenList()) do
				if type(x) ~= "string" and type(x) ~= "number" and type(x) ~= "boolean" then x = tostring(x) end
				v[#v + 1] = x
			end
		else
			v = current
			if v ~= nil and type(v) ~= "string" and type(v) ~= "number" and type(v) ~= "boolean" then v = tostring(v) end
		end
		if self.Checkbox then return { value = v, checked = self.Checkbox:Get() } end
		return v
	end
	function obj:_deserialize(v, silent)
		local value, checked = v, nil
		if type(v) == "table" and (v.value ~= nil or v.checked ~= nil) then value, checked = v.value, v.checked end
		local applied = false
		if multi then
			if type(value) == "table" then
				self:Set(value, silent)
				applied = true
			end
		elseif value ~= nil and known(value) then
			self:Set(value, silent)
			applied = true
		end
		if self.Checkbox and type(checked) == "boolean" then
			self.Checkbox:Set(checked, silent)
			applied = true
		end
		return applied
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddCheckbox(o)
	o = o or {}
	local theme = self.Theme
	local row = self:_addRow(o.Name or "Checkbox", o.SearchText)
	local stack = newStack(row)
	local cb = makeCheckbox(theme, row.Frame, o.Default, o.Style)
	stack:Place(cb.Button, 16)
	stack:Finish()
	local obj: any = { Kind = "Checkbox", Changed = cb.Changed }

	local function labelColor(on)
		if on then return theme.Text end
		return theme.TextMuted
	end
	row.Label.TextColor3 = labelColor(cb:Get())
	cb.Changed:Connect(function(on) tween(row.Label, 0.15, { TextColor3 = labelColor(on) }) end)

	function obj:Set(v, silent) cb:Set(v, silent) end
	function obj:Get() return cb:Get() end
	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	function obj:_serialize() return cb:Get() end
	function obj:_deserialize(v, silent)
		if type(v) ~= "boolean" then return false end
		cb:Set(v, silent)
		return true
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddButton(o)
	o = o or {}
	local theme = self.Theme
	local text = o.Text or o.Name or "Button"
	local accent = o.Style == "Accent"
	local labelText = o.Name or text
	if o.Full then labelText = "" end
	local row = self:_addRow(labelText, o.SearchText or o.Name or text)
	local obj: any = { Kind = "Button", Clicked = Signal.new() }

	local danger = o.Style == "Danger"
	local function colors()
		if accent then return theme.AccentBar, theme.FillTop, theme.FillBottom end
		if danger then
			return theme.Danger, mixColor(theme.Danger, Color3.new(1, 1, 1), 0.14), mixColor(theme.Danger, Color3.new(0, 0, 0), 0.14)
		end
		return theme.Control, theme.ControlHover, theme.NavActive
	end
	local baseColor0 = colors()
	local textColor = theme.TextDropdown
	if accent or danger then textColor = theme.Knob end
	local button = create("TextButton", {
		Name = "Button", AutoButtonColor = false, Text = text, Font = theme.Font, TextSize = 11,
		TextColor3 = textColor, BackgroundColor3 = baseColor0, BorderSizePixel = 0, Parent = row.Frame,
	})
	corner(button, theme.ControlRadius)
	if o.Full then
		row.ManualLabel = true
		row.Label.Visible = false
		button.Position = UDim2.fromOffset(L.PadX, 10)
		button.Size = UDim2.new(1, -L.PadX * 2, 0, 28)
		button.TextSize = 12
	else
		local width = math.max(56, math.floor(textWidth(text, 11, theme.Font) + 28 + 0.5))
		button.Size = UDim2.fromOffset(width, 22)
		local stack = newStack(row)
		stack:Place(button, width)
		stack:Finish()
	end

	button.MouseEnter:Connect(function()
		local _, hover = colors()
		tween(button, 0.1, { BackgroundColor3 = hover })
	end)
	button.MouseLeave:Connect(function()
		local base = colors()
		tween(button, 0.1, { BackgroundColor3 = base })
	end)
	button.MouseButton1Down:Connect(function()
		local _, _, press = colors()
		tween(button, 0.06, { BackgroundColor3 = press })
	end)
	button.MouseButton1Up:Connect(function()
		local _, hover = colors()
		tween(button, 0.1, { BackgroundColor3 = hover })
	end)
	button.MouseButton1Click:Connect(function() obj.Clicked:Fire() end)

	function obj:SetText(t) button.Text = t end
	if o.Callback then obj.Clicked:Connect(o.Callback) end
	attachCommon(obj, row, o)
	return obj
end

function Section:AddTextBox(o)
	o = o or {}
	local theme = self.Theme
	local row = self:_addRow(o.Name or "Text", o.SearchText)
	local stack = newStack(row)
	local obj: any = { Kind = "TextBox", Changed = Signal.new() }
	local width = o.Width or 120

	local box = create("TextBox", {
		Name = "Input", BackgroundColor3 = theme.Control, BorderSizePixel = 0,
		Size = UDim2.fromOffset(width, 24), Font = theme.Font, TextSize = 11,
		TextColor3 = theme.TextDropdown, PlaceholderText = o.Placeholder or "",
		PlaceholderColor3 = theme.TextPlaceholder, Text = o.Default or "",
		ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = row.Frame,
	})
	corner(box, theme.ControlRadius)
	padding(box, 10, 10, 0, 0)
	local outline = stroke(box, theme.AccentBar, 1, 1)
	box.Focused:Connect(function() tween(outline, 0.12, { Transparency = 0 }) end)
	box.FocusLost:Connect(function()
		tween(outline, 0.12, { Transparency = 1 })
		obj.Changed:Fire(box.Text)
	end)
	stack:Place(box, width)
	stack:Finish()

	function obj:Set(t, silent)
		box.Text = tostring(t)
		if not silent then self.Changed:Fire(box.Text) end
	end
	function obj:Get() return box.Text end
	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	function obj:_serialize() return box.Text end
	function obj:_deserialize(v, silent)
		if type(v) ~= "string" or #v > 400 then return false end
		self:Set(v, silent)
		return true
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddTextArea(o)
	o = o or {}
	local theme = self.Theme
	local lines = o.Lines or 5
	local boxH = lines * 14 + 12
	local row = self:_addRow(o.Name or "Text", o.SearchText)
	row.ManualLabel = true
	row.Frame.Size = UDim2.new(1, 0, 0, 34 + boxH + 12)
	row.Label.Size = UDim2.new(1, -L.PadX * 2, 0, 32)
	local obj: any = { Kind = "TextArea", Changed = Signal.new() }

	local box = create("TextBox", {
		Name = "Input", BackgroundColor3 = theme.Control, BorderSizePixel = 0,
		Position = UDim2.fromOffset(L.PadX, 34), Size = UDim2.new(1, -L.PadX * 2, 0, boxH),
		Font = Enum.Font.Code, TextSize = 11, TextColor3 = theme.TextDropdown,
		PlaceholderText = o.Placeholder or "", PlaceholderColor3 = theme.TextPlaceholder,
		Text = o.Default or "", ClearTextOnFocus = false, MultiLine = true, TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, Parent = row.Frame,
	})
	corner(box, theme.ControlRadius)
	padding(box, 8, 8, 6, 6)
	local outline = stroke(box, theme.AccentBar, 1, 1)
	box.Focused:Connect(function() tween(outline, 0.12, { Transparency = 0 }) end)
	box.FocusLost:Connect(function()
		tween(outline, 0.12, { Transparency = 1 })
		obj.Changed:Fire(box.Text)
	end)

	function obj:Set(t, silent)
		box.Text = tostring(t)
		if not silent then self.Changed:Fire(box.Text) end
	end
	function obj:Get() return box.Text end
	obj.Box = box
	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)

	function obj:_serialize() return box.Text end
	function obj:_deserialize(v, silent)
		if type(v) ~= "string" or #v > 400 then return false end
		self:Set(v, silent)
		return true
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddLabel(o)
	if type(o) == "string" then o = { Text = o } end
	o = o or {}
	local row = self:_addRow(o.Text or "", o.SearchText)
	row.ManualLabel = true
	row.Label.Size = UDim2.new(1, -L.PadX * 2, 1, 0)
	local obj: any = { Kind = "Label" }
	function obj:Set(t)
		row.Label.Text = t
		row.SearchText = t
	end
	function obj:Get() return row.Label.Text end
	attachCommon(obj, row, o)
	return obj
end

local Page = {}
Page.__index = Page

function Page.new(window, tab, options)
	local theme = window.Theme
	local self = setmetatable({
		Window = window, Tab = tab, Name = options.Name or tab.Name, Sections = {}, _count = 0,
	}, Page)

	self.Scroller = create("ScrollingFrame", {
		Name = "Page", BackgroundTransparency = 1, BorderSizePixel = 0, Visible = false,
		Size = UDim2.new(1, 0, 1, 0), CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.AccentBar, ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.None,
		ElasticBehavior = Enum.ElasticBehavior.Never, Parent = window._pages,
	})
	padding(self.Scroller, 0, 8, 0, 6)
	self.Columns = create("Frame", {
		Name = "Columns", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Parent = self.Scroller,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 16), Parent = self.Columns,
	})
	local function column(name, order)
		local c = create("Frame", {
			Name = name, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.new(0.5, -8, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
			LayoutOrder = order, Parent = self.Columns,
		})
		create("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 16), Parent = c,
		})
		return c
	end
	self.Left = column("Left", 1)
	self.Right = column("Right", 2)
	self.Empty = create("TextLabel", {
		Name = "Empty", BackgroundTransparency = 1, Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 0, 24), Font = theme.Font, TextSize = theme.TextSize,
		TextColor3 = theme.TextMuted, Text = "No matching elements", Visible = false,
		Parent = self.Scroller,
	})
	return self
end

function Page:AddSection(options)
	if type(options) == "string" then options = { Title = options } end
	options = options or {}
	self._count = self._count + 1
	local side = options.Side
	if side ~= "Left" and side ~= "Right" then
		if #self.Sections % 2 == 0 then side = "Left" else side = "Right" end
	end
	local column = self.Right
	if side == "Left" then column = self.Left end
	local section = Section.new(self.Window, self, column, options, self._count)
	self.Sections[#self.Sections + 1] = section
	return section
end

function Page:_filter(query)
	local any = false
	for _, section in ipairs(self.Sections) do
		if section:_applyFilter(query) > 0 then any = true end
	end
	self.Empty.Visible = (not any) and #self.Sections > 0
end

function Page:Select()
	self.Tab:SelectPage(self)
end

function Section:AddKeybind(o)
	o = o or {}
	local row = self:_addRow(o.Name or "Keybind", o.SearchText)
	local stack = newStack(row)
	local kb = self.Window:_newKeybind(row.Frame, o, { DefaultMode = "Press", Locked = function() return row.Locked == true end })
	stack:Place(kb.Button, kb.Width)
	stack:Finish()
	local obj: any = { Kind = "Keybind", Changed = kb.Changed, Triggered = kb.Triggered, Mode = kb.Mode }

	function obj:Get() return kb:Get() end -- Enum.KeyCode / Enum.UserInputType, or nil when unbound
	function obj:GetName() return kb:GetName() end
	function obj:Set(v, silent) return kb:Set(v, silent) end -- false when v is not a usable key
	function obj:GetState() return kb.State end
	if o.Callback then
		if kb.Mode == "None" then
			kb.Changed:Connect(o.Callback)
		else
			kb.Triggered:Connect(o.Callback)
		end
	end
	attachCommon(obj, row, o)
	local baseDestroy = (obj :: any).Destroy
	function obj:Destroy()
		kb:Destroy()
		baseDestroy(self)
	end
	function obj:_serialize() return kb:GetName() end
	function obj:_deserialize(v, silent)
		if type(v) ~= "string" then return false end
		return kb:SetByName(v, silent)
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddColorPicker(o)
	o = o or {}
	local theme = self.Theme
	local window = self.Window
	local row = self:_addRow(o.Name or "Color", o.SearchText)
	local stack = newStack(row)
	local obj: any = { Kind = "ColorPicker", Changed = Signal.new() }

	local color = o.Default
	if typeof(color) ~= "Color3" then color = hexColor(color) or Color3.fromRGB(116, 102, 255) end
	local hue, sat, val = Color3.toHSV(color)

	local chip = create("TextButton", {
		Name = "ColorPicker", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.Control, Size = UDim2.fromOffset(38, 22), Parent = row.Frame,
	})
	corner(chip, theme.ControlRadius)
	local swatch = noTheme(create("Frame", {
		Name = "Swatch", BorderSizePixel = 0, BackgroundColor3 = color,
		Position = UDim2.fromOffset(4, 4), Size = UDim2.new(1, -8, 1, -8), Parent = chip,
	}))
	corner(swatch, 3)
	stack:Place(chip, 38)
	stack:Finish()
	chip.MouseEnter:Connect(function() tween(chip, 0.1, { BackgroundColor3 = theme.ControlHover }) end)
	chip.MouseLeave:Connect(function() tween(chip, 0.1, { BackgroundColor3 = theme.Control }) end)

	local ui = nil

	local function refresh()
		swatch.BackgroundColor3 = color
		if ui and ui.alive then
			ui.sv.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
			ui.cursor.Position = UDim2.fromScale(sat, 1 - val)
			ui.hueKnob.Position = UDim2.fromScale(hue, 0.5)
			ui.preview.BackgroundColor3 = color
			if not ui.hexBox:IsFocused() then ui.hexBox.Text = colorHex(color) end
		end
	end

	local function apply(h, s, v, silent)
		hue, sat, val = clamp(h, 0, 1), clamp(s, 0, 1), clamp(v, 0, 1)
		local new = Color3.fromHSV(hue, sat, val)
		local changed = colorHex(new) ~= colorHex(color)
		color = new
		refresh()
		if changed and not silent then obj.Changed:Fire(color) end
	end

	function obj:Set(c, silent)
		if typeof(c) ~= "Color3" then c = hexColor(c) end
		if c == nil then return end
		local h, s, v = Color3.toHSV(c)
		if s == 0 or v == 0 then h = hue end -- greys / black keep the hue you were on
		apply(h, s, v, silent)
	end
	function obj:Get() return color end
	function obj:GetHex() return colorHex(color) end

	chip.MouseButton1Click:Connect(function()
		local w, h = 188, 186
		window:_openPopover(chip, w, h, function(pop)
			local api = { alive = true }
			ui = api
			local inner = w - 20

			local sv = noTheme(create("Frame", {
				Name = "SV", BorderSizePixel = 0, BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
				Position = UDim2.fromOffset(10, 10), Size = UDim2.fromOffset(inner, 110), Parent = pop,
			}))
			corner(sv, 6)
			local white = create("Frame", {
				Name = "White", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
				Size = UDim2.fromScale(1, 1), Parent = sv,
			})
			corner(white, 6)
			create("UIGradient", { Rotation = 0, Transparency = NumberSequence.new(0, 1), Parent = white })
			local black = create("Frame", {
				Name = "Black", BorderSizePixel = 0, BackgroundColor3 = Color3.new(0, 0, 0),
				Size = UDim2.fromScale(1, 1), Parent = sv,
			})
			corner(black, 6)
			create("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0), Parent = black })
			local cursor = create("Frame", {
				Name = "Cursor", BackgroundTransparency = 1, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(12, 12), ZIndex = 3, Parent = sv,
			})
			corner(cursor, "full")
			stroke(cursor, Color3.new(1, 1, 1), 2)
			local svHit = create("TextButton", {
				Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1), ZIndex = 4, Parent = sv,
			})
			bindDrag(svHit, function(x, _began, y)
				local sw, sh = sv.AbsoluteSize.X, sv.AbsoluteSize.Y
				if sw <= 0 or sh <= 0 then return end
				local fx = clamp((x - sv.AbsolutePosition.X) / sw, 0, 1)
				local fy = clamp((y - sv.AbsolutePosition.Y) / sh, 0, 1)
				apply(hue, fx, 1 - fy)
			end)

			local bar = noTheme(create("Frame", {
				Name = "Hue", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
				Position = UDim2.fromOffset(10, 130), Size = UDim2.fromOffset(inner, 12), Parent = pop,
			}))
			corner(bar, "full")
			local stops = {}
			for i = 0, 6 do
				stops[#stops + 1] = ColorSequenceKeypoint.new(i / 6, Color3.fromHSV(i / 6, 1, 1))
			end
			create("UIGradient", { Color = ColorSequence.new(stops), Parent = bar })
			local hueKnob = create("Frame", {
				Name = "Knob", BorderSizePixel = 0, BackgroundColor3 = Color3.new(1, 1, 1),
				AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(8, 16), ZIndex = 3, Parent = bar,
			})
			corner(hueKnob, "full")
			stroke(hueKnob, Color3.new(0, 0, 0), 1, 0.5)
			local hueHit = create("TextButton", {
				Name = "Hit", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
				Size = UDim2.new(1, 8, 1, 8), Position = UDim2.fromOffset(-4, -4), ZIndex = 4, Parent = bar,
			})
			bindDrag(hueHit, function(x)
				local bw = bar.AbsoluteSize.X
				if bw <= 0 then return end
				apply(clamp((x - bar.AbsolutePosition.X) / bw, 0, 1), sat, val)
			end)

			local preview = noTheme(create("Frame", {
				Name = "Preview", BorderSizePixel = 0, BackgroundColor3 = color,
				Position = UDim2.fromOffset(10, 152), Size = UDim2.fromOffset(24, 24), Parent = pop,
			}))
			corner(preview, 6)
			local hexBox = create("TextBox", {
				Name = "Hex", BackgroundColor3 = theme.Control, BorderSizePixel = 0,
				Position = UDim2.fromOffset(42, 152), Size = UDim2.fromOffset(inner - 32, 24),
				Font = theme.Font, TextSize = 11, TextColor3 = theme.TextDropdown, PlaceholderText = "#RRGGBB",
				PlaceholderColor3 = theme.TextPlaceholder, Text = colorHex(color), ClearTextOnFocus = false,
				TextXAlignment = Enum.TextXAlignment.Center, Parent = pop,
			})
			corner(hexBox, theme.ControlRadius)
			local outline = stroke(hexBox, theme.AccentBar, 1, 1)
			hexBox.Focused:Connect(function() tween(outline, 0.12, { Transparency = 0 }) end)
			hexBox.FocusLost:Connect(function()
				tween(outline, 0.12, { Transparency = 1 })
				local c = hexColor(hexBox.Text)
				if c then obj:Set(c) end
				hexBox.Text = colorHex(color)
			end)

			api.sv, api.cursor, api.hueKnob, api.preview, api.hexBox = sv, cursor, hueKnob, preview, hexBox
			api.OnClose = function()
				api.alive = false
				if ui == api then ui = nil end
			end
			refresh()
			return api
		end)
	end)

	if o.Callback then obj.Changed:Connect(o.Callback) end
	attachCommon(obj, row, o)
	function obj:_serialize() return colorHex(color) end
	function obj:_deserialize(v, silent)
		local c = hexColor(v)
		if c == nil then return false end
		self:Set(c, silent)
		return true
	end
	self.Window:_registerControl(obj, o, self)
	return obj
end

function Section:AddStat(o)
	if type(o) == "string" then o = { Name = o, Stat = o } end
	o = o or {}
	local theme = self.Theme
	local row = self:_addRow(o.Name or o.Stat or "Stat", o.SearchText)
	local stack = newStack(row)
	local obj: any = { Kind = "Stat" }
	local valueLabel = create("TextLabel", {
		Name = "Value", BackgroundTransparency = 1, Size = UDim2.fromOffset(120, 20),
		Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.TextValue,
		TextXAlignment = Enum.TextXAlignment.Right, Text = tostring(o.Value or "-"), Parent = row.Frame,
	})
	stack:Place(valueLabel, 120)
	stack:Finish()
	function obj:SetValue(text, color)
		valueLabel.Text = tostring(text)
		valueLabel.TextColor3 = color or theme.TextValue
	end
	function obj:Get() return valueLabel.Text end
	attachCommon(obj, row, o)
	if o.Stat then self.Window:_bindStat(obj, o.Stat) end
	return obj
end

local Tab = {}
Tab.__index = Tab

function Tab.new(window, options, index)
	local theme = window.Theme
	local self = setmetatable({
		Window = window, Name = options.Name or "Tab", Icon = options.Icon,
		Pages = {}, Index = index, Active = false,
	}, Tab)
	self.Y = math.floor((index - 1) * L.NavPitch + 0.5)

	self.Button = create("TextButton", {
		Name = "Tab", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.NavActive, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(0, self.Y), Size = UDim2.fromOffset(L.NavW, L.NavH),
		Parent = window._nav,
	})
	corner(self.Button, theme.NavRadius)
	self.IconObj = makeIcon(self.Button, self.Icon, 16, theme.IconMuted, 1.5)
	if self.IconObj then
		self.IconObj.Frame.Position = UDim2.new(0, 8, 0.5, -8)
	end
	self.Label = create("TextLabel", {
		Name = "Label", BackgroundTransparency = 1, Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -40, 1, 0), Font = theme.Font, TextSize = theme.TextSize,
		TextColor3 = theme.TextNav, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Text = self.Name, Parent = self.Button,
	})

	self.Button.MouseEnter:Connect(function()
		if not self.Active then
			tween(self.Button, 0.12, { BackgroundTransparency = 0, BackgroundColor3 = theme.NavHover })
			tween(self.Label, 0.12, { TextColor3 = theme.TextNavHover })
		end
	end)
	self.Button.MouseLeave:Connect(function()
		if not self.Active then
			tween(self.Button, 0.12, { BackgroundTransparency = 1 })
			tween(self.Label, 0.12, { TextColor3 = theme.TextNav })
		end
	end)
	self.Button.MouseButton1Click:Connect(function() window:SelectTab(self) end)
	return self
end

function Tab:_setActive(active)
	local theme = self.Window.Theme
	self.Active = active
	if active then
		tween(self.Button, 0.15, { BackgroundTransparency = 0, BackgroundColor3 = theme.NavActive })
		tween(self.Label, 0.15, { TextColor3 = theme.TextStrong })
		if self.IconObj then self.IconObj:SetColor(theme.IconActive) end
	else
		tween(self.Button, 0.15, { BackgroundTransparency = 1 })
		tween(self.Label, 0.15, { TextColor3 = theme.TextNav })
		if self.IconObj then self.IconObj:SetColor(theme.IconMuted) end
	end
end

function Tab:AddPage(options)
	if type(options) == "string" then options = { Name = options } end
	local page = Page.new(self.Window, self, options or {})
	self.Pages[#self.Pages + 1] = page
	if not self.ActivePage then
		self.ActivePage = page
		if self.Window.ActiveTab == self then self.Window:_showPage(page) end
	end
	return page
end

function Tab:AddSection(options)
	local page = self.Pages[1]
	if not page then page = self:AddPage({ Name = self.Name }) end
	return page:AddSection(options)
end

function Tab:SelectPage(page)
	self.ActivePage = page
	if self.Window.ActiveTab == self then
		self.Window:_showPage(page)
	else
		self.Window:SelectTab(self)
	end
end

function Tab:Select()
	self.Window:SelectTab(self)
end

local function optionalService(name)
	local ok, service = pcall(function() return game:GetService(name) end)
	if ok then return service end
	return nil
end

local function fetchGameName(callback)
	task.spawn(function()
		local name
		local market = optionalService("MarketplaceService")
		for attempt = 1, 2 do
			if name then break end
			if market then
				for _, method in ipairs({ "GetProductInfoAsync", "GetProductInfo" }) do
					if not name then
						local ok, info = pcall(function() return market[method](market, game.PlaceId) end)
						if ok and type(info) == "table" and type(info.Name) == "string" and info.Name ~= "" then
							name = info.Name
						else
							debugLog("game name:", method, "failed:", ok and "result has no Name" or tostring(info))
						end
					end
				end
			end
			if not name and attempt == 1 then task.wait(1) end
		end
		if not name then
			local ok, n = pcall(function() return game.Name end)
			if ok and type(n) == "string" and n ~= "" then
				name = n
				debugLog("game name: using game.Name =", n)
			end
		end
		if not name then debugLog("game name: nothing available") end
		callback(name)
	end)
end

local function fetchDisplayName(userId, callback)
	local player = Players.LocalPlayer
	if player and player.UserId == userId then
		local n = player.DisplayName
		if type(n) ~= "string" or n == "" then n = player.Name end
		callback(n)
		return
	end
	task.spawn(function()
		local name
		local service = optionalService("UserService")
		if service then
			local ok, infos = pcall(function() return service:GetUserInfosByUserIdsAsync({ userId }) end)
			if ok and type(infos) == "table" and infos[1] then
				local n = infos[1].DisplayName
				if type(n) ~= "string" or n == "" then n = infos[1].Username end
				if type(n) == "string" and n ~= "" then name = n end
			end
		end
		if not name then
			local ok, n = pcall(function() return Players:GetNameFromUserIdAsync(userId) end)
			if ok and type(n) == "string" and n ~= "" then name = n end
		end
		callback(name)
	end)
end

local function waitForImage(img, timeout)
	for _ = 1, math.floor(timeout * 10) do
		local ok, loaded = pcall(function() return img.IsLoaded end)
		if not ok then
			task.wait(1.5) -- property unavailable: cannot tell, give the image a moment and assume it loaded
			return true
		end
		if loaded then return true end
		task.wait(0.1)
	end
	return false
end

local function buildAvatar(parent, theme, spec)
	local circle = create("Frame", {
		Name = "Avatar", BackgroundColor3 = theme.AvatarBg, BorderSizePixel = 0,
		Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(34, 34), Parent = parent,
	})
	corner(circle, "full")

	local function buildMark()
		local cat = create("Frame", {
			Name = "Mark", BackgroundTransparency = 1, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(17, 17), Parent = circle,
		})
		local head = create("Frame", {
			Name = "Head", BackgroundColor3 = theme.AvatarFg, BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, 3), Size = UDim2.fromOffset(17, 14), Parent = cat,
		})
		corner(head, 5)
		local function ear(cx)
			create("Frame", {
				Name = "Ear", BackgroundColor3 = theme.AvatarFg, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx / 16, 4 / 16),
				Size = UDim2.fromScale(5.2 / 16, 5.2 / 16), Rotation = 45, Parent = cat,
			})
		end
		local function eye(cx)
			local e = create("Frame", {
				Name = "Eye", BackgroundColor3 = theme.AvatarBg, BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(cx / 16, 10 / 16),
				Size = UDim2.fromScale(2 / 16, 2 / 16), ZIndex = 2, Parent = cat,
			})
			corner(e, "full")
		end
		ear(3.6)
		ear(12.4)
		eye(5)
		eye(11)
		return cat
	end

	if type(spec) == "number" then
		local mark = buildMark()
		local img = create("ImageLabel", {
			Name = "Photo", BackgroundColor3 = theme.AvatarBg, BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), Image = "", ScaleType = Enum.ScaleType.Crop, ZIndex = 2, Parent = circle,
		})
		corner(img, "full")
		task.spawn(function()
			local url
			for _ = 1, 6 do
				local ok, content, ready = pcall(function()
					return Players:GetUserThumbnailAsync(spec, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				end)
				if ok and type(content) == "string" and content ~= "" then
					url = content
					if ready ~= false then break end -- not ready yet = placeholder image, try again shortly
				else
					debugLog("avatar: GetUserThumbnailAsync failed:", ok and "empty result" or tostring(content))
					if not ok then break end
				end
				task.wait(0.6)
			end
			local direct = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(spec) .. "&w=150&h=150"
			local candidates = {}
			if url then candidates[#candidates + 1] = url end
			if url ~= direct then candidates[#candidates + 1] = direct end
			for _, candidate in ipairs(candidates) do
				if not img.Parent then return end
				img.Image = candidate
				if waitForImage(img, 6) then
					debugLog("avatar: loaded", candidate)
					tween(img, 0.25, { BackgroundTransparency = 0 }) -- covers the built-in mark
					task.delay(0.3, function()
						if mark.Parent then mark:Destroy() end
					end)
					return
				end
				debugLog("avatar: no load confirmation for", candidate)
			end
		end)
	elseif type(spec) == "string" and spec ~= "" then
		local img = create("ImageLabel", {
			Name = "Photo", BackgroundTransparency = 1, BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), Image = spec, ScaleType = Enum.ScaleType.Crop, Parent = circle,
		})
		corner(img, "full")
	else
		buildMark()
	end
	return circle
end

local function newGroup(props, allowCanvas)
	local ok, inst = false, nil
	if allowCanvas then ok, inst = pcall(Instance.new, "CanvasGroup") end
	local canvas = ok and inst ~= nil
	if not canvas then inst = Instance.new("Frame") end
	for k, v in pairs(props) do
		if k ~= "Parent" then inst[k] = v end
	end
	inst.Parent = props.Parent
	return inst, canvas
end

local function newBlur(name)
	local old = Lighting:FindFirstChild(name)
	if old then old:Destroy() end
	return create("BlurEffect", { Name = name, Size = 0, Enabled = false, Parent = Lighting })
end

local Window = {}
Window.__index = Window

function Window:_tw(obj, duration, goal, style, direction)
	if self._animate then
		return tween(obj, duration, goal, style, direction)
	end
	for k, v in pairs(goal) do obj[k] = v end
	return nil
end

function Window:_connect(signal, fn)
	local c = signal:Connect(fn)
	self._conns[#self._conns + 1] = c
	return c
end

function Window:_fit()
	local vp = self.Gui.AbsoluteSize
	local rw, rh = self.Root.Size.X.Offset, self.Root.Size.Y.Offset
	local s = math.min(1, (vp.X - 24) / rw, (vp.Y - 24) / rh)
	if s < 0.35 then s = 0.35 end
	self._baseScale = s * self._userScale
	if self._open and not self._animating then
		self._scale.Scale = self._baseScale
	end
end

function Window:_attachDrag(handle)
	local dragging = false
	local startPoint, startPos = nil, nil
	handle.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging = true
			startPoint = input.Position
			startPos = self.Root.Position
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if not dragging then return end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
			local d = input.Position - startPoint
			self.Root.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y
			)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

function Window:_buildProfile(cfg)
	local theme = self.Theme
	local player = Players.LocalPlayer
	self._profileCfg = cfg
	local btn = create("TextButton", {
		Name = "Profile", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.NavHover, BackgroundTransparency = 1,
		Position = UDim2.new(0, 6, 1, -52), Size = UDim2.fromOffset(179, 46), Parent = self.Sidebar,
	})
	corner(btn, 12)
	self._profileButton = btn

	local userId = cfg.UserId
	if userId == nil and player then userId = player.UserId end
	if type(userId) ~= "number" or userId <= 0 then userId = nil end -- guests / Studio test players have no profile
	self._profileUserId = userId
	local avatarSpec = cfg.Avatar
	if avatarSpec == nil then avatarSpec = userId end
	self._avatar = buildAvatar(btn, theme, avatarSpec)
	local name = cfg.Name
	if name == nil then
		if userId and player and userId ~= player.UserId then
			name = "Player" -- another user: replaced as soon as their display name is fetched
		else
			name = (player and player.DisplayName) or "Guest"
		end
	end
	self._profileName = create("TextLabel", {
		Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(50, 6),
		Size = UDim2.fromOffset(125, 16), Font = theme.Font, TextSize = theme.TextSize,
		TextColor3 = theme.TextStrong, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Text = name, Parent = btn,
	})
	self._profileSub = create("TextLabel", {
		Name = "Subtitle", BackgroundTransparency = 1, Position = UDim2.fromOffset(50, 26),
		Size = UDim2.fromOffset(125, 14), Font = theme.Font, TextSize = 11,
		TextColor3 = theme.TextNav, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, Text = type(cfg.Subtitle) == "string" and cfg.Subtitle or "", Parent = btn,
	})
	if cfg.Name == nil and userId then self:_loadProfileName(userId) end
	if cfg.Subtitle == nil or cfg.Subtitle == true then self:_loadGameName() end
	btn.MouseEnter:Connect(function() tween(btn, 0.12, { BackgroundTransparency = 0.5 }) end)
	btn.MouseLeave:Connect(function() tween(btn, 0.12, { BackgroundTransparency = 1 }) end)
	btn.MouseButton1Click:Connect(function()
		local items = {}
		for _, item in ipairs(self._profileCfg.Menu or {}) do
			items[#items + 1] = { Text = item.Text or "", Callback = item.Callback, Color = item.Color }
		end
		self:_openMenu(btn, items, { Align = "Left", Direction = "Up", Width = 176 })
	end)
end

function Window:_loadProfileName(userId)
	self._nameToken = (self._nameToken or 0) + 1
	local token = self._nameToken
	fetchDisplayName(userId, function(name)
		if name and token == self._nameToken and self._profileName.Parent then
			self._profileName.Text = name
		end
	end)
end

function Window:_loadGameName()
	self._subToken = (self._subToken or 0) + 1
	local token = self._subToken
	fetchGameName(function(name)
		if name and token == self._subToken and self._profileSub.Parent then
			self._profileSub.Text = name
		end
	end)
end

function Window:SetProfile(p)
	if not self._profileButton then return end
	p = p or {}
	if p.UserId ~= nil then
		self._profileUserId = p.UserId
		if p.Avatar == nil then p.Avatar = p.UserId end
		if p.Name == nil then self:_loadProfileName(p.UserId) end
	end
	if p.Name ~= nil then
		self._nameToken = (self._nameToken or 0) + 1
		self._profileName.Text = p.Name
	end
	if p.Subtitle == true then
		self:_loadGameName()
	elseif p.Subtitle == false then
		self._subToken = (self._subToken or 0) + 1
		self._profileSub.Text = ""
	elseif p.Subtitle ~= nil then
		self._subToken = (self._subToken or 0) + 1
		self._profileSub.Text = p.Subtitle
	end
	if p.Menu ~= nil then self._profileCfg.Menu = p.Menu end
	if p.Avatar ~= nil then
		self._avatar:Destroy()
		self._avatar = buildAvatar(self._profileButton, self.Theme, p.Avatar)
	end
end

function Window:SetConfig(name, silent)
	self._configName = name
	if not self._configButton then return end
	local theme = self.Theme
	self._config.Name = name
	self._configLabel.Text = name
	local w = 13 + math.floor(textWidth(name, theme.TextSize, theme.Font) + 0.5) + 12 + 15 + 11
	self._configButton.Size = UDim2.fromOffset(w, L.TopH)
end

function Window:_layoutCrumb()
	local theme = self.Theme
	local c = self._crumb
	local tw1 = textWidth(c.tab.Text, theme.TextSize, theme.Font)
	c.tab.Size = UDim2.fromOffset(math.ceil(tw1) + 2, 20)
	local showPage = c.page.Text ~= ""
	c.arrow.Frame.Visible = showPage
	c.pageButton.Visible = showPage
	if showPage then
		local ax = 28 + math.floor(tw1 + 0.5) + 14
		c.arrow.Frame.Position = UDim2.fromOffset(ax, L.CrumbY + 5)
		local px = ax + 7 + 14
		local tw2 = textWidth(c.page.Text, theme.TextSize, theme.Font)
		c.pageButton.Position = UDim2.fromOffset(px - 4, L.CrumbY)
		c.pageButton.Size = UDim2.fromOffset(math.ceil(tw2) + 32, 20)
		c.page.Position = UDim2.fromOffset(4, 0)
		c.page.Size = UDim2.fromOffset(math.ceil(tw2) + 2, 20)
		c.chevron.Frame.Position = UDim2.fromOffset(4 + math.floor(tw2 + 0.5) + 9, 6)
	end
end

function Window:_updateCrumb()
	local theme = self.Theme
	local c = self._crumb
	local tab, page = self.ActiveTab, self.ActivePage
	if c.icon then
		c.icon.Frame:Destroy()
		c.icon = nil
	end
	if tab then
		c.icon = makeIcon(c.iconHolder, tab.Icon, 14, theme.IconCrumb, 1.7)
		c.tab.Text = tab.Name
	else
		c.tab.Text = ""
	end
	if tab and page and page.Name ~= tab.Name then
		c.page.Text = page.Name
	else
		c.page.Text = ""
	end
	self:_layoutCrumb()
	local key = tostring(tab) .. "/" .. tostring(page)
	local changed = key ~= self._crumbKey
	self._crumbKey = key
	if changed and self._animate and self._ready then
		for _, label in ipairs({ c.tab, c.page }) do
			label.TextTransparency = 1
			tween(label, 0.28, { TextTransparency = 0 })
		end
	end
end

function Window:_animatePage(page)
	local scroller = page.Scroller
	scroller.Position = UDim2.fromOffset(0, 12)
	tween(scroller, 0.32, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
	if self._pagesCanvas then
		self._pages.GroupTransparency = 1
		tween(self._pages, 0.26, { GroupTransparency = 0 })
	end
end

function Window:_showPage(page)
	local previous = self.ActivePage
	if previous and previous ~= page then
		previous.Scroller.Visible = false
	end
	self.ActivePage = page
	if page then
		page.Scroller.Visible = true
		page:_filter(self._searchText)
		if self._animate and self._ready and page ~= previous then
			self:_animatePage(page)
		else
			page.Scroller.Position = UDim2.fromOffset(0, 0)
			if self._pagesCanvas then self._pages.GroupTransparency = 0 end
		end
	end
	self:_updateCrumb()
	self.ViewChanged:Fire()
end

function Window:AddTab(options)
	if type(options) == "string" then options = { Name = options } end
	local tab = Tab.new(self, options or {}, #self.Tabs + 1)
	self.Tabs[#self.Tabs + 1] = tab
	if not self.ActiveTab then self:SelectTab(tab) end
	return tab
end

function Window:SelectTab(tab)
	self:_closeMenu()
	self.ActiveTab = tab
	for _, t in ipairs(self.Tabs) do t:_setActive(t == tab) end
	self._indicator.Visible = true
	local goal = UDim2.fromOffset(0, self._navY + tab.Y + 8)
	if self._indicatorPlaced then
		tween(self._indicator, 0.2, { Position = goal }, Enum.EasingStyle.Quint)
	else
		self._indicator.Position = goal
		self._indicatorPlaced = true
	end
	self:_showPage(tab.ActivePage)
end

function Window:_popupSpot(anchor, width, height, options)
	options = options or {}
	local layer = self._popups
	local scale = self._scale.Scale
	local rel = (anchor.AbsolutePosition - layer.AbsolutePosition) / scale
	local aw, ah = anchor.AbsoluteSize.X / scale, anchor.AbsoluteSize.Y / scale
	local x = rel.X + aw - width
	if options.Align == "Left" then x = rel.X end
	local y = rel.Y + ah + 6
	if options.Direction == "Up" then y = rel.Y - height - 6 end
	local lw, lh = layer.AbsoluteSize.X / scale, layer.AbsoluteSize.Y / scale
	x = math.floor(clamp(x, 0, math.max(0, lw - width)) + 0.5)
	y = math.floor(clamp(y, 0, math.max(0, lh - height)) + 0.5)
	return x, y
end

function Window:_openMenu(anchor, items, options)
	options = options or {}
	self:_closeMenu()
	if #items == 0 then return end
	local theme = self.Theme
	local layer = self._popups
	local scale = self._scale.Scale
	local itemH, pad = 28, 5
	local multi = options.Multi == true
	local searchable = options.Search == true
	local searchH = searchable and 36 or 0
	local footerH = (multi and options.OnBulk ~= nil) and 34 or 0
	local maxList = options.MaxHeight or 196
	local width = options.Width or math.max(math.floor(anchor.AbsoluteSize.X / scale + 0.5), 104)
	if searchable then
		width = math.max(width, 150)
	elseif multi then
		width = math.max(width, 130)
	end

	local ticked = {}
	if multi and type(options.Selected) == "table" then
		for k, v in pairs(options.Selected) do
			if v then ticked[k] = true end
		end
	end

	local contentH = #items * itemH + pad * 2
	local listH = math.min(contentH, maxList)
	local height = searchH + listH + footerH
	local x, y = self:_popupSpot(anchor, width, height, options)
	local slide = -4
	if options.Direction == "Up" then slide = 4 end

	local catcher = create("TextButton", {
		Name = "MenuCatcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = layer,
	})
	local menu = create("Frame", {
		Name = "Menu", BackgroundColor3 = theme.Menu, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y + slide), Size = UDim2.fromOffset(width, height),
		ZIndex = 2, Parent = layer,
	})
	corner(menu, theme.MenuRadius)
	stroke(menu, theme.MenuBorder, 1)
	local list = create("ScrollingFrame", {
		Name = "List", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, searchH), Size = UDim2.new(1, 0, 0, listH),
		CanvasSize = UDim2.fromOffset(0, contentH), ScrollBarThickness = 2,
		ScrollBarImageColor3 = theme.AccentBar, ScrollingDirection = Enum.ScrollingDirection.Y,
		ElasticBehavior = Enum.ElasticBehavior.Never, Parent = menu,
	})
	padding(list, 5, 5, pad, pad)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

	local entries = {}
	for i, item in ipairs(items) do
		local btn = create("TextButton", {
			Name = "Item", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
			BackgroundColor3 = theme.MenuHover, BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, itemH), LayoutOrder = i, Parent = list,
		})
		corner(btn, 7)
		local entry = { Item = item, Button = btn, Shown = true, Chosen = false }
		local textX = 10
		if multi then
			textX = 32
			entry.Box = create("Frame", {
				Name = "Box", BorderSizePixel = 0, BackgroundColor3 = theme.Control,
				Position = UDim2.new(0, 10, 0.5, -7), Size = UDim2.fromOffset(14, 14), Parent = btn,
			})
			corner(entry.Box, 4)
			entry.Tick = makeIcon(entry.Box, "check", 10, theme.Knob, 3.2)
			entry.Tick.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			entry.Tick.Frame.Position = UDim2.fromScale(0.5, 0.5)
		elseif options.Selected ~= nil and item.Value == options.Selected then
			textX = 22
			entry.Chosen = true
			local dot = create("Frame", {
				Name = "Dot", BackgroundColor3 = theme.AccentBar, BorderSizePixel = 0,
				Position = UDim2.new(0, 10, 0.5, -2), Size = UDim2.fromOffset(5, 5), Parent = btn,
			})
			corner(dot, "full")
		end
		local label = create("TextLabel", {
			Name = "Text", BackgroundTransparency = 1, Position = UDim2.fromOffset(textX, 0),
			Size = UDim2.new(1, -(textX + 8), 1, 0), Font = theme.Font, TextSize = theme.TextSize,
			TextColor3 = theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Text = item.Text or "", Parent = btn,
		})
		local function baseColor()
			local on = entry.Chosen
			if multi then on = ticked[item.Value] == true end
			if on then return theme.Text end
			return item.Color or theme.TextMuted
		end
		local function paint()
			label.TextColor3 = baseColor()
			if multi then
				local on = ticked[item.Value] == true
				entry.Box.BackgroundColor3 = on and theme.AccentBar or theme.Control
				entry.Tick.Frame.Visible = on
			end
		end
		entry.Paint = paint
		paint()
		btn.MouseEnter:Connect(function()
			tween(btn, 0.08, { BackgroundTransparency = 0 })
			tween(label, 0.08, { TextColor3 = theme.TextStrong })
		end)
		btn.MouseLeave:Connect(function()
			tween(btn, 0.08, { BackgroundTransparency = 1 })
			tween(label, 0.08, { TextColor3 = baseColor() })
		end)
		btn.MouseButton1Click:Connect(function()
			if multi then
				local on = not ticked[item.Value]
				ticked[item.Value] = on or nil
				paint()
				if options.OnToggle then task.spawn(options.OnToggle, item.Value, on, item) end
				return
			end
			self:_closeMenu()
			if item.Callback then task.spawn(item.Callback) end
			if options.OnSelect then task.spawn(options.OnSelect, item.Value, item) end
		end)
		entries[#entries + 1] = entry
	end

	local noResults = create("TextLabel", {
		Name = "NoResults", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, itemH),
		Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.TextPlaceholder,
		Text = "No results", Visible = false, LayoutOrder = #items + 1, Parent = list,
	})

	local footer = nil
	local function refit()
		local count = 0
		for _, e in ipairs(entries) do
			if e.Shown then count = count + 1 end
		end
		noResults.Visible = count == 0
		local ch = math.max(count, 1) * itemH + pad * 2
		list.CanvasSize = UDim2.fromOffset(0, ch)
		list.CanvasPosition = Vector2.new(0, 0)
		local lh = math.min(ch, maxList)
		list.Size = UDim2.new(1, 0, 0, lh)
		local h = searchH + lh + footerH
		local nx, ny = self:_popupSpot(anchor, width, h, options)
		menu.Size = UDim2.fromOffset(width, h)
		menu.Position = UDim2.fromOffset(nx, ny)
		if footer then footer.Position = UDim2.fromOffset(0, searchH + lh) end
	end

	local input = nil
	if searchable then
		local box = create("Frame", {
			Name = "Search", BackgroundColor3 = theme.Control, BorderSizePixel = 0,
			Position = UDim2.fromOffset(5, 5), Size = UDim2.new(1, -10, 0, 26), Parent = menu,
		})
		corner(box, 7)
		local icon = makeIcon(box, "search", 12, theme.IconSearch, 2)
		icon.Frame.Position = UDim2.fromOffset(9, 7)
		input = create("TextBox", {
			Name = "Input", BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(28, 0), Size = UDim2.new(1, -34, 1, 0),
			Font = theme.Font, TextSize = 11, TextColor3 = theme.Text, PlaceholderText = "Search",
			PlaceholderColor3 = theme.TextPlaceholder, Text = "", ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = box,
		})
		input:GetPropertyChangedSignal("Text"):Connect(function()
			local query = string.lower(input.Text)
			for _, e in ipairs(entries) do
				e.Shown = query == "" or string.find(string.lower(e.Item.Text or ""), query, 1, true) ~= nil
				e.Button.Visible = e.Shown
			end
			refit()
		end)
	end

	if footerH > 0 then
		footer = create("Frame", {
			Name = "Footer", BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, searchH + listH), Size = UDim2.new(1, 0, 0, footerH), Parent = menu,
		})
		create("Frame", {
			Name = "Divider", BackgroundColor3 = theme.MenuBorder, BorderSizePixel = 0,
			Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -16, 0, 1), Parent = footer,
		})
		local function link(text, order, on)
			local b = create("TextButton", {
				Name = on and "SelectAll" or "Clear", Text = text, AutoButtonColor = false, BackgroundTransparency = 1,
				BorderSizePixel = 0, Font = theme.Font, TextSize = 11, TextColor3 = theme.TextMuted,
				Position = UDim2.new((order - 1) * 0.5, 0, 0, 1), Size = UDim2.new(0.5, 0, 1, -1), Parent = footer,
			})
			b.MouseEnter:Connect(function() tween(b, 0.08, { TextColor3 = theme.TextStrong }) end)
			b.MouseLeave:Connect(function() tween(b, 0.08, { TextColor3 = theme.TextMuted }) end)
			b.MouseButton1Click:Connect(function()
				local values = {}
				for _, e in ipairs(entries) do
					if e.Shown then
						values[#values + 1] = e.Item.Value
						ticked[e.Item.Value] = on or nil
						e.Paint()
					end
				end
				task.spawn(options.OnBulk, on, values)
			end)
		end
		link("Select all", 1, true)
		link("Clear", 2, false)
	end

	catcher.MouseButton1Click:Connect(function() self:_closeMenu() end)
	self._menu = { Catcher = catcher, Menu = menu }
	tween(menu, 0.12, { Position = UDim2.fromOffset(x, y) })
	if input then
		local touchOnly = false
		pcall(function() touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled end)
		if not touchOnly then
			task.defer(function()
				if input.Parent then pcall(function() input:CaptureFocus() end) end
			end)
		end
	end
end

function Window:_openPopover(anchor, width, height, build, options)
	options = options or {}
	self:_closeMenu()
	local theme = self.Theme
	local x, y = self:_popupSpot(anchor, width, height, options)
	local slide = (options.Direction == "Up") and 4 or -4
	local catcher = create("TextButton", {
		Name = "MenuCatcher", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), ZIndex = 1, Parent = self._popups,
	})
	local pop = create("Frame", {
		Name = "Popover", BackgroundColor3 = theme.Menu, BorderSizePixel = 0,
		Position = UDim2.fromOffset(x, y + slide), Size = UDim2.fromOffset(width, height),
		ZIndex = 2, Parent = self._popups,
	})
	corner(pop, theme.MenuRadius)
	stroke(pop, theme.MenuBorder, 1)
	catcher.MouseButton1Click:Connect(function() self:_closeMenu() end)
	self._menu = { Catcher = catcher, Menu = pop }
	local api = build(pop)
	if type(api) == "table" and self._menu then self._menu.OnClose = api.OnClose end
	tween(pop, 0.12, { Position = UDim2.fromOffset(x, y) })
	return pop
end

function Window:_closeMenu()
	local m = self._menu
	if m then
		self._menu = nil
		if m.OnClose then pcall(m.OnClose) end
		m.Catcher:Destroy()
		m.Menu:Destroy()
	end
end

local NOTIFY_KINDS = {
	info = { Color = "Accent", Icon = "info" },
	success = { Color = "Success", Icon = "success" },
	warning = { Color = "Warning", Icon = "warn" },
	error = { Color = "Danger", Icon = "error" },
}

local TOAST_W = 288

function Window:Notify(o)
	if type(o) == "string" then o = { Text = o } end
	o = o or {}
	local theme = self.Theme
	local kindName = string.lower(tostring(o.Type or "info"))
	if kindName == "danger" or kindName == "err" then kindName = "error" end
	if kindName == "warn" then kindName = "warning" end
	local kind = NOTIFY_KINDS[kindName] or NOTIFY_KINDS.info
	local tint = theme[kind.Color]
	local duration = o.Duration
	if duration == nil then duration = 3.5 end
	if duration == false or (type(duration) == "number" and duration <= 0) then duration = nil end
	local hasTitle = o.Title ~= nil and o.Title ~= ""
	local hasText = o.Text ~= nil and o.Text ~= ""
	local iconSpec = o.Icon
	if iconSpec == nil then iconSpec = kind.Icon end
	local hasIcon = iconSpec ~= nil and iconSpec ~= false and iconSpec ~= ""
	local closable = o.Closable ~= false
	local radius = theme.CardRadius + 1

	local textX = hasIcon and 54 or 18
	local textW = TOAST_W - textX - (closable and 40 or 18)
	local function linesFor(text, size, most)
		local w = textWidth(text, size, theme.Font)
		return clamp(math.ceil(w / (textW * 0.92)), 1, most)
	end
	local titleText, bodyText = nil, nil
	local titleLines, bodyLines = 0, 0
	local titleSize = theme.TextSize
	if hasTitle and hasText then
		titleText, bodyText = tostring(o.Title), tostring(o.Text)
		titleLines, bodyLines = 1, linesFor(bodyText, 11, 3)
	elseif hasTitle then
		titleText = tostring(o.Title)
		titleLines = linesFor(titleText, titleSize, 2)
	else
		titleText = tostring(o.Text or "")
		titleLines = linesFor(titleText, titleSize, 2)
	end
	local titleH = titleLines * 16
	local bodyH = bodyLines * 15
	local contentH = titleH + (bodyH > 0 and (bodyH + 3) or 0)
	local stripH = duration and 7 or 0 -- room for the countdown line
	local h = math.max(50, 12 + contentH + 12 + stripH)
	self._toastCount = self._toastCount + 1

	local slot = create("Frame", {
		Name = "Toast", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, h), LayoutOrder = self._toastCount, Parent = self._toasts,
	})
	local lane = create("Frame", {
		Name = "Lane", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(-1.2, 0, 0, 0), Size = UDim2.fromScale(1, 1), Parent = slot,
	})
	local shadowFar = noTheme(create("Frame", {
		Name = "ShadowSoft", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.9, BorderSizePixel = 0,
		Position = UDim2.fromOffset(-3, 2), Size = UDim2.new(1, 6, 1, 6), Parent = lane,
	}))
	corner(shadowFar, radius + 3)
	local shadowNear = noTheme(create("Frame", {
		Name = "Shadow", BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.8, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 1, 1), Parent = lane,
	}))
	corner(shadowNear, radius)

	local card = create("Frame", {
		Name = "Card", BackgroundColor3 = theme.Card, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), Parent = lane,
	})
	corner(card, radius)
	local wash = create("Frame", {
		Name = "Wash", BackgroundColor3 = tint, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = card,
	})
	corner(wash, radius)
	create("UIGradient", {
		Rotation = 0,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.82), NumberSequenceKeypoint.new(0.55, 0.95), NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = wash,
	})

	local badgeScale = nil
	if hasIcon then
		local badge = create("Frame", {
			Name = "Accent", BackgroundColor3 = tint, BackgroundTransparency = 0.8, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 14, 0.5, 0), Size = UDim2.fromOffset(28, 28), Parent = card,
		})
		corner(badge, "full")
		local icon = makeIcon(badge, iconSpec, 14, tint, 2)
		if icon then
			icon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Frame.Position = UDim2.fromScale(0.5, 0.5)
		end
		badgeScale = create("UIScale", { Scale = 1, Parent = badge })
	end

	local top = math.floor((h - stripH - contentH) / 2 + 0.5)
	local function textLine(name, text, y, height, font, size, color)
		return create("TextLabel", {
			Name = name, BackgroundTransparency = 1, Position = UDim2.fromOffset(textX, y),
			Size = UDim2.fromOffset(textW, height), Font = font, TextSize = size, TextColor3 = color,
			TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true, TextTruncate = Enum.TextTruncate.AtEnd, Text = text, Parent = card,
		})
	end
	if bodyText then
		textLine("Title", titleText, top, titleH, theme.FontBold, theme.TextSize, theme.TextStrong)
		textLine("Text", bodyText, top + titleH + 3, bodyH, theme.Font, 11, theme.TextNav)
	elseif hasTitle then
		textLine("Title", titleText, top, titleH, theme.FontBold, titleSize, theme.TextStrong)
	else
		textLine("Text", titleText, top, titleH, theme.Font, titleSize, theme.TextStrong)
	end

	local track, fill = nil, nil
	if duration then
		track = create("Frame", {
			Name = "Countdown", BackgroundColor3 = tint, BackgroundTransparency = 0.85, BorderSizePixel = 0,
			Position = UDim2.new(0, 16, 1, -11), Size = UDim2.new(1, -32, 0, 3), Parent = card,
		})
		corner(track, "full")
		fill = create("Frame", {
			Name = "Fill", BackgroundColor3 = tint, BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Parent = track,
		})
		corner(fill, "full")
	end

	local dismissed = false
	local token, startedAt, remaining, barTween = 0, nil, duration, nil
	local function dismiss()
		if dismissed then return end
		dismissed = true
		token = token + 1
		if barTween then barTween:Cancel() end
		for i, handle in ipairs(self._toastList) do
			if handle.Slot == slot then
				table.remove(self._toastList, i)
				break
			end
		end
		if not slot.Parent then return end
		tween(lane, 0.2, { Position = UDim2.new(-1.2, 0, 0, 0) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		task.delay(0.1, function()
			if slot.Parent then tween(slot, 0.17, { Size = UDim2.new(1, 0, 0, 0) }, Enum.EasingStyle.Quad) end
		end)
		task.delay(0.28, function() slot:Destroy() end)
	end
	local function arm()
		if not duration or dismissed then return end
		token = token + 1
		local mine = token
		startedAt = os.clock()
		barTween = tween(fill, remaining, { Size = UDim2.new(0, 0, 1, 0) }, Enum.EasingStyle.Linear)
		task.delay(remaining, function()
			if mine == token then dismiss() end
		end)
	end
	local function pause()
		if not duration or dismissed or startedAt == nil then return end
		token = token + 1 -- the pending dismissal no longer counts
		remaining = math.max(0.8, remaining - (os.clock() - startedAt))
		startedAt = nil
		if barTween then barTween:Cancel() end
	end

	local hover = 0
	local function hoverChanged(delta)
		hover = math.max(0, hover + delta)
		if dismissed then return end
		if hover > 0 then
			tween(card, 0.12, { BackgroundColor3 = theme.NavHover })
			pause()
		else
			tween(card, 0.12, { BackgroundColor3 = theme.Card })
			if duration and startedAt == nil then arm() end
		end
	end
	local body = create("TextButton", {
		Name = "Body", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), ZIndex = 2, Parent = card,
	})
	body.MouseEnter:Connect(function() hoverChanged(1) end)
	body.MouseLeave:Connect(function() hoverChanged(-1) end)
	if o.Callback then
		body.MouseButton1Click:Connect(function()
			task.spawn(o.Callback)
			dismiss()
		end)
	end
	if closable then
		local x = create("TextButton", {
			Name = "Close", Text = "", AutoButtonColor = false, BackgroundColor3 = theme.Control, BackgroundTransparency = 1,
			BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -9, 0, 9),
			Size = UDim2.fromOffset(22, 22), ZIndex = 3, Parent = card,
		})
		corner(x, "full")
		local cross = makeIcon(x, "close", 9, theme.Chevron, 2.4)
		cross.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
		cross.Frame.Position = UDim2.fromScale(0.5, 0.5)
		x.MouseEnter:Connect(function()
			hoverChanged(1)
			cross:SetColor(theme.TextStrong)
			tween(x, 0.1, { BackgroundTransparency = 0 })
		end)
		x.MouseLeave:Connect(function()
			hoverChanged(-1)
			cross:SetColor(theme.Chevron)
			tween(x, 0.1, { BackgroundTransparency = 1 })
		end)
		x.MouseButton1Click:Connect(dismiss)
	end

	local handle = { Slot = slot, Close = dismiss }
	self._toastList[#self._toastList + 1] = handle
	local maxToasts = self._maxToasts
	while maxToasts and #self._toastList > maxToasts do
		self._toastList[1].Close()
	end

	tween(lane, 0.3, { Position = UDim2.new(0, 0, 0, 0) }, Enum.EasingStyle.Quint)
	if badgeScale then
		badgeScale.Scale = 0.5
		task.delay(0.1, function()
			if not dismissed then tween(badgeScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back) end
		end)
	end
	arm()
	return handle
end

function Window:_applyBlur(open, instant)
	local blur = self._blur
	if not blur then return end
	self._blurToken = self._blurToken + 1
	local bt = self._blurToken
	local target = 0
	if open then target = self._blurSize end
	if target > 0 then blur.Enabled = true end
	if self._animate and not instant then
		local duration = 0.25
		if open then duration = 0.4 end
		tween(blur, duration, { Size = target })
		if target == 0 then
			task.delay(duration + 0.03, function()
				if self._blurToken == bt then blur.Enabled = false end
			end)
		end
	else
		blur.Size = target
		if target == 0 then blur.Enabled = false end
	end
end

function Window:SetBlur(size)
	if size == true then size = 20 end
	if type(size) ~= "number" then size = 0 end
	self._blurSize = clamp(size, 0, 56)
	if not self._blur and self._blurSize > 0 then self._blur = newBlur(self._guiName .. "Blur") end
	if self._blur and self._open then self:_applyBlur(true, false) end
end

function Window:_applyBackdrop(open, instant)
	local b = self.Backdrop
	if not b then return end
	local target = 1
	if open then target = self._backdropT end
	if open then b.Visible = true end
	if self._animate and not instant then
		tween(b, open and 0.3 or 0.22, { BackgroundTransparency = target })
		if not open then
			local token = self._token
			task.delay(0.24, function()
				if self._token == token and not self._open then b.Visible = false end
			end)
		end
	else
		b.BackgroundTransparency = target
		if not open then b.Visible = false end
	end
end

function Window:_setOpen(open, instant)
	local root, scale = self.Root, self._scale
	self._open = open
	self._token = self._token + 1
	local token = self._token
	local base = self._baseScale or scale.Scale
	if not open then
		self:_closeMenu()
		self:_cancelCapture()
		self:_closeDialogs(false)
	end
	self:_applyBlur(open, instant)
	self:_applyBackdrop(open, instant)

	local animate = self._animate and not instant
	if open then
		if animate then
			self._animating = true
			if self._rootCanvas then root.GroupTransparency = 1 end
			scale.Scale = base * 0.94
			root.Visible = true
			if self._rootCanvas then tween(root, 0.22, { GroupTransparency = 0 }) end
			tween(scale, 0.34, { Scale = base }, Enum.EasingStyle.Back)
			task.delay(0.36, function()
				if token ~= self._token then return end
				self._animating = false
				scale.Scale = self._baseScale
			end)
		else
			self._animating = false
			if self._rootCanvas then root.GroupTransparency = 0 end
			scale.Scale = base
			root.Visible = true
		end
	else
		if animate then
			self._animating = true
			if self._rootCanvas then tween(root, 0.18, { GroupTransparency = 1 }) end
			tween(scale, 0.2, { Scale = base * 0.96 })
			task.delay(0.2, function()
				if token ~= self._token then return end
				root.Visible = false
				self._animating = false
				scale.Scale = self._baseScale
			end)
		else
			self._animating = false
			root.Visible = false
			scale.Scale = base
		end
	end
	self:_updatePill()
	self.ViewChanged:Fire()
end

function Window:Toggle(state)
	if state == nil then state = not self._open end
	if state == self._open then return end
	self:_setOpen(state, false)
end
function Window:Show() self:Toggle(true) end
function Window:Hide() self:Toggle(false) end
function Window:IsOpen() return self._open end

function Window:_updatePill()
	local pill = self._pill
	if not pill then return end
	local theme = self.Theme
	local open = self._open
	local dotColor = theme.KnobOff
	local textColor = theme.TextMuted
	if open then
		dotColor = theme.Accent
		textColor = theme.TextStrong
	end
	local changed = pill.LastOpen ~= nil and pill.LastOpen ~= open
	pill.LastOpen = open
	if pill.Dot then
		self:_tw(pill.Dot, 0.15, { BackgroundColor3 = dotColor })
		if changed and self._animate then
			tween(pill.Dot, 0.12, { Size = UDim2.fromOffset(11, 11) })
			task.delay(0.12, function()
				tween(pill.Dot, 0.32, { Size = UDim2.fromOffset(6, 6) }, Enum.EasingStyle.Back)
			end)
		end
	end
	if pill.Text then self:_tw(pill.Text, 0.15, { TextColor3 = textColor }) end
	if pill.Surface then
		pill.Surface.Retheme()
		if changed and self._animate then pill.Surface.Burst() end
	end
end

function Window:_placePill(x, y)
	local pill = self._pill
	if not pill then return end
	local vp = self.Gui.AbsoluteSize
	local w, h = pill.Button.AbsoluteSize.X, pill.Button.AbsoluteSize.Y
	x = clamp(x, 4, math.max(4, vp.X - w - 4))
	y = clamp(y, 4, math.max(4, vp.Y - h - 4))
	pill.Button.AnchorPoint = Vector2.new(0, 0)
	pill.Button.Position = UDim2.fromOffset(math.floor(x + 0.5), math.floor(y + 0.5))
	self._pillMoved = true
end

function Window:_clampPill()
	local pill = self._pill
	if pill and self._pillMoved then
		local p = pill.Button.AbsolutePosition
		self:_placePill(p.X, p.Y)
	end
end

function Window:SetPillVisible(visible)
	if self._pill then self._pill.Button.Visible = visible == true end
end

function Window:_buildPill(cfg)
	local theme = self.Theme
	if cfg == true then cfg = {} end
	local label = cfg.Text
	if label == nil then label = self.TitleLabel.Text end
	local hasText = label ~= false and label ~= ""
	local logoSize = math.floor(clamp(tonumber(cfg.LogoSize) or 34, 12, 48))
	local height = math.max(34, logoSize + 8)
	local textW = 0
	local width = height
	if hasText then
		textW = math.ceil(textWidth(label, theme.TextSize, theme.Font)) + 2
		width = 10 + logoSize + 8 + textW + 10 + 6 + 14
	end

	local button = create("TextButton", {
		Name = "Pill", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.Card, AnchorPoint = cfg.AnchorPoint or Vector2.new(0.5, 0),
		Position = cfg.Position or UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(width, height), ZIndex = 300, Parent = self.Gui,
	})
	corner(button, "full")
	local function surfaceLayer(name)
		local frame = noTheme(create("Frame", {
			Name = name, BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0,
			Size = UDim2.fromScale(1, 1), Parent = button,
		}))
		corner(frame, "full")
		return frame
	end
	local glowGradient = create("UIGradient", { Rotation = 35, Parent = surfaceLayer("Glow") })
	create("UIGradient", {
		Rotation = 90, Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.9), NumberSequenceKeypoint.new(0.5, 0.97), NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = surfaceLayer("Gloss"),
	})
	local shineLayer = surfaceLayer("Shine")
	local shineGradient = create("UIGradient", {
		Rotation = 20, Offset = Vector2.new(-1, 0), Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.36, 1), NumberSequenceKeypoint.new(0.5, 0.84),
			NumberSequenceKeypoint.new(0.64, 1), NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = shineLayer,
	})
	shineLayer.Visible = false
	local logoSpec = cfg.Logo
	if logoSpec == nil then logoSpec = self._logoSpec end -- the pill uses the window logo unless Pill.Logo is set
	local logo = buildLogo(button, logoSpec, logoSize, theme)
	logo.AnchorPoint = Vector2.new(0, 0.5)
	if hasText then
		logo.Position = UDim2.new(0, 10, 0.5, 0)
	else
		logo.AnchorPoint = Vector2.new(0.5, 0.5)
		logo.Position = UDim2.fromScale(0.5, 0.5)
	end
	local pill = { Button = button }
	if hasText then
		pill.Text = create("TextLabel", {
			Name = "Text", BackgroundTransparency = 1, Position = UDim2.fromOffset(10 + logoSize + 8, 0),
			Size = UDim2.fromOffset(textW, height), Font = theme.Font, TextSize = theme.TextSize,
			TextColor3 = theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left,
			Text = label, Parent = button,
		})
		pill.Dot = create("Frame", {
			Name = "Status", BackgroundColor3 = theme.KnobOff, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -17, 0.5, 0),
			Size = UDim2.fromOffset(6, 6), Parent = button,
		})
		corner(pill.Dot, "full")
	end
	self._pill = pill
	self.Pill = button
	if cfg.Visible == false or not UserInputService.TouchEnabled then button.Visible = false end

	local pillScale = create("UIScale", { Parent = button })
	local hovering, pressed = false, false
	local function settleScale(spring)
		local target = 1
		if pressed then target = 0.93 elseif hovering then target = 1.05 end
		if spring then
			self:_tw(pillScale, 0.3, { Scale = target }, Enum.EasingStyle.Back)
		else
			self:_tw(pillScale, 0.12, { Scale = target })
		end
	end
	local surface = {}
	do
		local level = 0.55      -- how strongly the glow shows (eased towards the target)
		local angle = 35        -- direction of the glow gradient, degrees
		local sweepClock = -0.6 -- seconds into the shine cycle (negative = waiting)
		local flash = 0
		local paintedLevel = -1
		local SWEEP = 1.1       -- seconds a sweep takes
		local function targetLevel()
			local target = self._open and 1 or 0.55
			if hovering then target = target + 0.25 end
			return target + flash * 0.5
		end
		local function paintAlpha()
			local strong = clamp(0.3 * level, 0, 0.6)
			local soft = clamp(0.13 * level, 0, 0.3)
			glowGradient.Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1 - strong), NumberSequenceKeypoint.new(0.5, 1 - soft),
				NumberSequenceKeypoint.new(1, 1 - strong),
			})
			paintedLevel = level
		end
		function surface.Retheme()
			local th = self.Theme
			glowGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, th.FillTop), ColorSequenceKeypoint.new(0.5, th.Accent),
				ColorSequenceKeypoint.new(1, th.FillBottom),
			})
			if not self._animate then level = targetLevel() end
			paintAlpha()
		end
		function surface.Burst()
			flash = 1
			sweepClock = 0
		end
		function surface.Sweep()
			if sweepClock > SWEEP + 0.15 or sweepClock < 0 then sweepClock = 0 end
		end
		function surface.Tick(dt)
			if not button.Visible then return end
			dt = math.min(dt, 0.1)
			flash = math.max(0, flash - dt / 0.7)
			level = level + (targetLevel() - level) * (1 - math.exp(-dt * 8))
			if math.abs(level - paintedLevel) > 0.004 then paintAlpha() end
			local speed = self._open and 38 or 16
			if hovering then speed = speed + 22 end
			angle = (angle + dt * speed) % 360
			glowGradient.Rotation = angle
			sweepClock = sweepClock + dt
			local cycle = self._open and 3.6 or 5.4
			if sweepClock >= cycle then sweepClock = 0 end
			if sweepClock >= 0 and sweepClock < SWEEP then
				local p = sweepClock / SWEEP
				shineLayer.Visible = true
				shineGradient.Offset = Vector2.new(-1 + 2 * (p * p * (3 - 2 * p)), 0)
			elseif shineLayer.Visible then
				shineLayer.Visible = false
			end
		end
	end
	pill.Surface = surface
	if self._animate then
		self:_connect(RunService.Heartbeat, surface.Tick)
	end

	button.MouseEnter:Connect(function()
		hovering = true
		self:_tw(button, 0.12, { BackgroundColor3 = theme.NavHover })
		settleScale(false)
		if self._animate then surface.Sweep() end
	end)
	button.MouseLeave:Connect(function()
		hovering = false
		self:_tw(button, 0.12, { BackgroundColor3 = theme.Card })
		settleScale(false)
	end)
	if self._animate then
		pillScale.Scale = 0.6
		tween(pillScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
	end

	local dragging, moved = false, false
	local threshold = 4
	local startPoint, startAbs = nil, nil
	button.InputBegan:Connect(function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			dragging = true
			moved = false
			pressed = true
			settleScale(false)
			threshold = (t == Enum.UserInputType.Touch) and 8 or 4
			startPoint = input.Position
			startAbs = button.AbsolutePosition
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if not dragging then return end
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch then
			local d = input.Position - startPoint
			if not moved and (math.abs(d.X) > threshold or math.abs(d.Y) > threshold) then
				moved = true
			end
			if moved then self:_placePill(startAbs.X + d.X, startAbs.Y + d.Y) end
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			if dragging then
				dragging = false
				pressed = false
				settleScale(true)
				if not moved then self:Toggle() end
			end
		end
	end)
	self:_updatePill()
end

function Window:SetScale(n)
	self._userScale = n
	self:_fit()
end

function Window:SetBackdropTransparency(t)
	self._backdropT = clamp(t, 0, 1)
	if self.Backdrop and self._open then self.Backdrop.BackgroundTransparency = self._backdropT end
end

function Window:SetToggleKey(key)
	self._toggleKey = key
end

function Window:Destroy()
	local hooks = self._destroyHooks
	self._destroyHooks = {}
	for _, hook in ipairs(hooks) do pcall(hook) end
	self:_closeDialogs(true)
	for _, c in ipairs(self._conns) do c:Disconnect() end
	self._conns = {}
	self._token = self._token + 1
	self._blurToken = self._blurToken + 1
	if self._blur then self._blur:Destroy() end
	self.Gui:Destroy()
end

function AuralV2.CreateWindow(a, b)
	local options = a
	if a == AuralV2 then options = b end
	options = options or {}

	local player = Players.LocalPlayer
	local parent = options.Parent
	if not parent then
		if not player then error("Aural V2 needs a client context (Players.LocalPlayer is nil)") end
		parent = player:WaitForChild("PlayerGui")
	end
	local theme, themeName = resolveTheme(options.Theme) -- a theme name ("Midnight"), a table of colour overrides, or nil
	local size = options.Size or Vector2.new(L.RootW, L.RootH)
	local guiName = options.GuiName or "AuralV2"
	AuralV2.Debug = options.Debug == true

	local old = parent:FindFirstChild(guiName)
	if old then old:Destroy() end
	local oldBlur = Lighting:FindFirstChild(guiName .. "Blur")
	if oldBlur then oldBlur:Destroy() end

	local self = setmetatable({
		Theme = theme, Tabs = {}, _conns = {}, _searchText = "", _toastCount = 0,
		_userScale = options.Scale or 1, _toggleKey = Enum.KeyCode.RightShift,
		_open = true, _animating = false, _ready = false, _token = 0, _blurToken = 0,
		_animate = options.Animate ~= false, _guiName = guiName, _baseScale = 1,
		Flags = {}, ConfigLoaded = Signal.new(), ConfigSaved = Signal.new(), _cfgEnabled = options.Configs ~= false,
		ThemeChanged = Signal.new(), _themeName = themeName, _themeSpec = options.Theme,
		_toastList = {}, _maxToasts = options.MaxNotifications == nil and 5 or options.MaxNotifications,
		_keybinds = {}, _stats = {}, _startTime = os.time(), _dialogQueue = {},
		ViewChanged = Signal.new(), _destroyHooks = {},
	}, Window)
	self._backdropT = options.BackdropTransparency
	if self._backdropT == nil then self._backdropT = theme.BackdropTransparency end
	if options.ToggleKey ~= nil then self._toggleKey = options.ToggleKey end

	self.Gui = create("ScreenGui", {
		Name = guiName, ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true, DisplayOrder = options.DisplayOrder or 1000,
	})
	self.Gui.Parent = parent

	if options.Backdrop == true then
		self.Backdrop = create("Frame", {
			Name = "Backdrop", BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 1,
			BorderSizePixel = 0, Size = UDim2.fromScale(1, 1), Active = true, ZIndex = 0, Parent = self.Gui,
		})
		self._backdropGradient = create("UIGradient", { Rotation = 90, Color = theme.BackdropColors, Parent = self.Backdrop })
	end

	local allowCanvas = self._animate and options.Fade ~= false
	self.Root, self._rootCanvas = newGroup({
		Name = "Root", BackgroundTransparency = 1, BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5), Position = options.Position or UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y), ZIndex = 1, Parent = self.Gui,
	}, allowCanvas)

	local blurSize = options.Blur
	if blurSize == nil or blurSize == true then blurSize = 20 end
	if type(blurSize) ~= "number" then blurSize = 0 end
	self._blurSize = clamp(blurSize, 0, 56)
	if self._blurSize > 0 then self._blur = newBlur(guiName .. "Blur") end
	self._scale = create("UIScale", { Parent = self.Root })
	self.Panel = create("Frame", {
		Name = "Panel", BackgroundColor3 = theme.Window, BorderSizePixel = 0, Active = true,
		Position = UDim2.fromOffset(L.PanelX, 0), Size = UDim2.new(1, -L.PanelX, 1, 0),
		ZIndex = 1, Parent = self.Root,
	})
	corner(self.Panel, theme.WindowRadius)
	self.Sidebar = create("Frame", {
		Name = "Sidebar", BackgroundColor3 = theme.Sidebar, BorderSizePixel = 0, Active = true,
		Position = UDim2.fromOffset(0, L.SidebarInset),
		Size = UDim2.new(0, L.SidebarW, 1, -L.SidebarInset * 2), ZIndex = 3, Parent = self.Root,
	})
	corner(self.Sidebar, theme.SidebarRadius)
	local sidebar = self.Sidebar

	local logoSize = math.floor(clamp(tonumber(options.LogoSize) or 70, 16, 96))
	local headerH = math.max(54, logoSize + 10)
	self._navY = L.NavY + (headerH - 54)
	local dragHeader = create("TextButton", {
		Name = "DragHeader", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, headerH), ZIndex = 1, Parent = sidebar,
	})
	local logo = buildLogo(sidebar, options.Logo, logoSize, theme)
	logo.Position = UDim2.fromOffset(12, math.floor((headerH - logoSize) / 2))
	logo.ZIndex = 2
	local titleX = 12 + logoSize + 8
	self.TitleLabel = create("TextLabel", {
		Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(titleX, math.floor(headerH / 2 - 10)),
		Size = UDim2.fromOffset(L.SidebarW - titleX - 8, 21), Font = theme.FontBold, TextSize = 17,
		TextColor3 = theme.TextStrong, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Text = options.Name or AuralV2.Name, ZIndex = 2, Parent = sidebar,
	})

	self._nav = create("Frame", {
		Name = "Nav", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(L.NavX, self._navY),
		Size = UDim2.new(0, L.NavW, 1, -(self._navY + 70)), Parent = sidebar,
	})
	self._indicator = create("Frame", {
		Name = "Indicator", BackgroundColor3 = theme.AccentBar, BorderSizePixel = 0, Visible = false,
		Position = UDim2.fromOffset(0, self._navY + 8), Size = UDim2.fromOffset(4, 16), ZIndex = 2, Parent = sidebar,
	})
	corner(self._indicator, 2)

	if options.Profile ~= false then
		self:_buildProfile(options.Profile or {})
	end

	local body = create("Frame", {
		Name = "Body", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(L.BodyX, 0),
		Size = UDim2.new(1, -(L.BodyX + L.BodyRight), 1, 0), ZIndex = 4, Parent = self.Root,
	})
	self.Body = body
	local dragBar = create("TextButton", {
		Name = "DragBar", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Position = UDim2.fromOffset(-(L.BodyX - L.SidebarW), 0),
		Size = UDim2.new(1, (L.BodyX - L.SidebarW) + L.BodyRight, 0, 62), ZIndex = 1, Parent = body,
	})
	self:_attachDrag(dragBar)
	self:_attachDrag(dragHeader)

	if options.Search ~= false then
		local cfg = options.Search or {}
		local bar = create("Frame", {
			Name = "Search", BackgroundColor3 = theme.Field, BorderSizePixel = 0,
			Position = UDim2.fromOffset(0, L.TopY), Size = UDim2.fromOffset(L.SearchW, L.TopH),
			ZIndex = 2, Parent = body,
		})
		corner(bar, theme.FieldRadius)
		local icon = makeIcon(bar, "search", 14, theme.IconSearch, 1.8)
		icon.Frame.Position = UDim2.fromOffset(12, 15)
		self.SearchBox = create("TextBox", {
			Name = "Input", BackgroundTransparency = 1, BorderSizePixel = 0,
			Position = UDim2.fromOffset(46, 0), Size = UDim2.new(1, -58, 1, 0),
			Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.Text,
			PlaceholderText = cfg.Placeholder or "Search elements",
			PlaceholderColor3 = theme.TextPlaceholder, Text = "", ClearTextOnFocus = false,
			TextXAlignment = Enum.TextXAlignment.Left, Parent = bar,
		})
		self:_connect(self.SearchBox:GetPropertyChangedSignal("Text"), function()
			self._searchText = string.lower(self.SearchBox.Text)
			if self.ActivePage then self.ActivePage:_filter(self._searchText) end
		end)
	end

	if options.Config ~= false then
		local cfg = options.Config or {}
		self._config = { Items = cfg.Items or {}, Callback = cfg.Callback, Name = cfg.Name or "Default" }
		local btn = create("TextButton", {
			Name = "Config", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
			BackgroundColor3 = theme.Button, AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -2, 0, L.TopY), Size = UDim2.fromOffset(104, L.TopH),
			ZIndex = 2, Parent = body,
		})
		corner(btn, theme.FieldRadius)
		self._configButton = btn
		self._configLabel = create("TextLabel", {
			Name = "Text", BackgroundTransparency = 1, Position = UDim2.fromOffset(13, 0),
			Size = UDim2.new(1, -51, 1, 0), Font = theme.Font, TextSize = theme.TextSize,
			TextColor3 = theme.CrumbTab, TextXAlignment = Enum.TextXAlignment.Left, Text = "", Parent = btn,
		})
		local folder = makeIcon(btn, "folder", 15, theme.IconButton, 1.7)
		folder.Frame.AnchorPoint = Vector2.new(1, 0.5)
		folder.Frame.Position = UDim2.new(1, -11, 0.5, 0)
		self:SetConfig(self._config.Name)
		btn.MouseEnter:Connect(function() tween(btn, 0.1, { BackgroundColor3 = theme.NavHover }) end)
		btn.MouseLeave:Connect(function() tween(btn, 0.1, { BackgroundColor3 = theme.Button }) end)
		btn.MouseButton1Click:Connect(function()
			if self._cfgEnabled then
				self:_openConfigMenu(btn) -- lists the saved configs; picking one loads it
				return
			end
			local items = {}
			for _, name in ipairs(self._config.Items) do
				items[#items + 1] = { Text = name, Value = name }
			end
			self:_openMenu(btn, items, {
				Align = "Right", Selected = self._config.Name,
				OnSelect = function(name)
					self:SetConfig(name)
					if self._config.Callback then task.spawn(self._config.Callback, name) end
				end,
			})
		end)
	end

	local crumb = {}
	crumb.iconHolder = create("Frame", {
		Name = "CrumbIcon", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, L.CrumbY + 3), Size = UDim2.fromOffset(14, 14), Parent = body,
	})
	crumb.tab = create("TextLabel", {
		Name = "CrumbTab", BackgroundTransparency = 1, Position = UDim2.fromOffset(28, L.CrumbY),
		Size = UDim2.fromOffset(60, 20), Font = theme.Font, TextSize = theme.TextSize,
		TextColor3 = theme.CrumbTab, TextXAlignment = Enum.TextXAlignment.Left, Text = "", Parent = body,
	})
	crumb.arrow = makeIcon(body, "chevronRight", 8, theme.CrumbArrow, 3)
	crumb.pageButton = create("TextButton", {
		Name = "CrumbPage", Text = "", AutoButtonColor = false, BackgroundTransparency = 1,
		Size = UDim2.fromOffset(80, 20), Parent = body,
	})
	crumb.page = create("TextLabel", {
		Name = "Text", BackgroundTransparency = 1, Size = UDim2.fromOffset(60, 20),
		Font = theme.Font, TextSize = theme.TextSize, TextColor3 = theme.TextNav,
		TextXAlignment = Enum.TextXAlignment.Left, Text = "", Parent = crumb.pageButton,
	})
	crumb.chevron = makeIcon(crumb.pageButton, "chevronDown", 8, theme.Chevron, 3)
	self._crumb = crumb
	crumb.pageButton.MouseButton1Click:Connect(function()
		local tab = self.ActiveTab
		if not tab or #tab.Pages < 2 then return end
		local items = {}
		for _, p in ipairs(tab.Pages) do
			items[#items + 1] = { Text = p.Name, Value = p }
		end
		self:_openMenu(crumb.pageButton, items, {
			Align = "Left", Selected = self.ActivePage,
			OnSelect = function(p) tab:SelectPage(p) end,
		})
	end)

	self._pages, self._pagesCanvas = newGroup({
		Name = "Pages", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, L.PagesY),
		Size = UDim2.new(1, 8, 1, -(L.PagesY + L.PagesBottom)), Parent = body,
	}, allowCanvas)

	self._popups = create("Frame", {
		Name = "Popups", BackgroundTransparency = 1, BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1), ZIndex = 100, Parent = self.Root,
	})
	self._toasts = create("Frame", {
		Name = "Toasts", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.new(0, 16, 0.25, 0), Size = UDim2.fromOffset(TOAST_W, 0),
		AutomaticSize = Enum.AutomaticSize.Y, ZIndex = 200, Parent = self.Gui,
	})
	create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = self._toasts,
	})

	-- Pin notifications below Roblox's chatbox at runtime
	do
		local toasts = self._toasts
		task.spawn(function()
			task.wait(2)
			local pgui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
			if not pgui or not toasts.Parent then return end

			local chatFrame = nil

			-- Classic Roblox chat (PlayerGui.Chat)
			local classicChat = pgui:FindFirstChild("Chat")
			if classicChat then
				for _, child in ipairs(classicChat:GetChildren()) do
					if child:IsA("Frame") and child.AbsoluteSize.Y > 60 then
						chatFrame = child
						break
					end
				end
			end

			-- TextChatService GUI fallback
			if not chatFrame then
				for _, name in ipairs({ "TextChatGui", "RbxChatGuiV2" }) do
					local tg = pgui:FindFirstChild(name)
					if tg then
						for _, child in ipairs(tg:GetChildren()) do
							if child:IsA("Frame") and child.AbsoluteSize.Y > 60 and child.AbsoluteSize.X > 150 then
								chatFrame = child
								break
							end
						end
						if chatFrame then break end
					end
				end
			end

			if not chatFrame then return end

			local function updateToastPos()
				if not toasts or not toasts.Parent then return end
				local ap = chatFrame.AbsolutePosition
				local as = chatFrame.AbsoluteSize
				toasts.Position = UDim2.fromOffset(
					math.floor(ap.X) + 12,
					math.floor(ap.Y + as.Y) + 8
				)
			end

			updateToastPos()
			pcall(function() chatFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(updateToastPos) end)
			pcall(function() chatFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateToastPos) end)
		end)
	end

	self._logoSpec = options.Logo
	if options.Pill ~= false then
		self:_buildPill(options.Pill or {})
	end

	self:_fit()
	self:_connect(self.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
		self:_fit()
		self:_clampPill()
	end)
	self:_connect(UserInputService.InputBegan, function(input, processed)
		self:_inputBegan(input, processed)
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		self:_inputEnded(input)
	end)
	self:_updateCrumb()
	self._ready = true
	self:_setOpen(true, not self._animate) -- intro: fade + scale in, blur up
	self:_setupConfigs(options.Configs) -- storage + auto load (p4_configs)
	return self
end

local JSON = {}
AuralV2.JSON = JSON

local jsonEscapes = {
	['"'] = '\\"', ["\\"] = "\\\\", ["\b"] = "\\b", ["\f"] = "\\f",
	["\n"] = "\\n", ["\r"] = "\\r", ["\t"] = "\\t",
}

local function jsonString(s)
	local escaped = (string.gsub(s, '[%c"\\]', function(c)
		return jsonEscapes[c] or string.format("\\u%04x", string.byte(c))
	end))
	return '"' .. escaped .. '"'
end

local function isArray(t)
	local n = 0
	for k in pairs(t) do
		if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then return false end
		n = n + 1
	end
	return n > 0 and n == #t
end

function JSON.encode(value, pretty)
	local out = {}
	local function put(s) out[#out + 1] = s end
	local function emit(v, level)
		local t = type(v)
		if t == "nil" then
			put("null")
		elseif t == "boolean" then
			put(v and "true" or "false")
		elseif t == "number" then
			local num = tonumber(v) or 0
			if num ~= num or num == math.huge or num == -math.huge then
				put("null")
			elseif num == math.floor(num) and math.abs(num) < 1e15 then
				put(string.format("%d", num))
			else
				put(string.format("%.14g", num))
			end
		elseif t == "string" then
			put(jsonString(v))
		elseif t == "table" then
			local nl, inner, outer = "", "", ""
			if pretty then
				nl = "\n"
				inner = string.rep("  ", level + 1)
				outer = string.rep("  ", level)
			end
			if isArray(v) then
				put("[")
				for i = 1, #v do
					if i > 1 then put(",") end
					put(nl .. inner)
					emit(v[i], level + 1)
				end
				put(nl .. outer .. "]")
			else
				local keys = {}
				for k in pairs(v) do keys[#keys + 1] = tostring(k) end
				table.sort(keys)
				if #keys == 0 then
					put("{}")
				else
					put("{")
					for i, k in ipairs(keys) do
						if i > 1 then put(",") end
						put(nl .. inner .. jsonString(k) .. (pretty and ": " or ":"))
						local item = v[k]
						if item == nil then item = v[tonumber(k)] end
						emit(item, level + 1)
					end
					put(nl .. outer .. "}")
				end
			end
		else
			put("null")
		end
	end
	emit(value, 0)
	return table.concat(out)
end

function JSON.decode(text)
	if type(text) ~= "string" then error("JSON: text expected", 0) end
	local pos, len, depth = 1, #text, 0
	local function fail(msg)
		error(string.format("JSON error at character %d: %s", pos, msg), 0)
	end
	local function skipSpace()
		local _, e = string.find(text, "^[ \t\r\n]*", pos)
		pos = e + 1
	end
	local simple = { ['"'] = '"', ["\\"] = "\\", ["/"] = "/", b = "\b", f = "\f", n = "\n", r = "\r", t = "\t" }

	local function parseString()
		pos = pos + 1 -- opening quote
		local buf = {}
		while true do
			local s, e = string.find(text, '^[^"\\\0-\31]+', pos)
			if s then
				buf[#buf + 1] = string.sub(text, s, e)
				pos = e + 1
			end
			local c = string.sub(text, pos, pos)
			if c == '"' then
				pos = pos + 1
				return table.concat(buf)
			elseif c == "\\" then
				local n = string.sub(text, pos + 1, pos + 1)
				if simple[n] then
					buf[#buf + 1] = simple[n]
					pos = pos + 2
				elseif n == "u" then
					local hex = string.match(text, "^%x%x%x%x", pos + 2)
					if not hex then fail("bad \\u escape") end
					local code = tonumber(hex, 16)
					pos = pos + 6
					if code >= 0xD800 and code <= 0xDBFF then
						local low = string.match(text, "^\\u(%x%x%x%x)", pos)
						local lowCode = low and tonumber(low, 16)
						if lowCode and lowCode >= 0xDC00 and lowCode <= 0xDFFF then
							code = 0x10000 + (code - 0xD800) * 0x400 + (lowCode - 0xDC00)
							pos = pos + 6
						else
							fail("unpaired surrogate")
						end
					elseif code >= 0xDC00 and code <= 0xDFFF then
						fail("unpaired surrogate")
					end
					buf[#buf + 1] = utf8.char(code)
				else
					fail("bad escape")
				end
			elseif c == "" then
				fail("string is not closed")
			else
				fail("control character inside a string")
			end
		end
	end

	local function parseNumber()
		local start, p = pos, pos
		if string.sub(text, p, p) == "-" then p = p + 1 end
		local digits = string.match(text, "^%d+", p) or ""
		if digits == "" then fail("bad number") end
		if #digits > 1 and string.sub(digits, 1, 1) == "0" then fail("bad number") end
		p = p + #digits
		if string.sub(text, p, p) == "." then
			local frac = string.match(text, "^%d+", p + 1) or ""
			if frac == "" then fail("bad number") end
			p = p + 1 + #frac
		end
		local ch = string.sub(text, p, p)
		if ch == "e" or ch == "E" then
			local sign = string.match(text, "^[+-]?", p + 1) or ""
			local exp = string.match(text, "^%d+", p + 1 + #sign) or ""
			if exp == "" then fail("bad number") end
			p = p + 1 + #sign + #exp
		end
		local n = tonumber(string.sub(text, start, p - 1))
		if not n then fail("bad number") end
		pos = p
		return n
	end

	local parseValue
	local function enter()
		depth = depth + 1
		if depth > 32 then fail("nested too deeply") end
	end

	function parseValue()
		skipSpace()
		local c = string.sub(text, pos, pos)
		if c == "{" then
			enter()
			pos = pos + 1
			local obj: any = {}
			skipSpace()
			if string.sub(text, pos, pos) == "}" then
				pos = pos + 1
				depth = depth - 1
				return obj
			end
			while true do
				skipSpace()
				if string.sub(text, pos, pos) ~= '"' then fail("a quoted key was expected") end
				local key = parseString()
				skipSpace()
				if string.sub(text, pos, pos) ~= ":" then fail("':' expected") end
				pos = pos + 1
				obj[key] = parseValue()
				skipSpace()
				local d = string.sub(text, pos, pos)
				if d == "," then
					pos = pos + 1
				elseif d == "}" then
					pos = pos + 1
					break
				else
					fail("',' or '}' expected")
				end
			end
			depth = depth - 1
			return obj
		elseif c == "[" then
			enter()
			pos = pos + 1
			local arr, n = {}, 0
			skipSpace()
			if string.sub(text, pos, pos) == "]" then
				pos = pos + 1
				depth = depth - 1
				return arr
			end
			while true do
				local item = parseValue()
				if item ~= nil then -- null entries are dropped (a Lua table cannot hold nil without holes)
					n = n + 1
					arr[n] = item
				end
				skipSpace()
				local d = string.sub(text, pos, pos)
				if d == "," then
					pos = pos + 1
				elseif d == "]" then
					pos = pos + 1
					break
				else
					fail("',' or ']' expected")
				end
			end
			depth = depth - 1
			return arr
		elseif c == '"' then
			return parseString()
		elseif c == "-" or string.find(c, "^%d") then
			return parseNumber()
		elseif string.sub(text, pos, pos + 3) == "true" then
			pos = pos + 4
			return true
		elseif string.sub(text, pos, pos + 4) == "false" then
			pos = pos + 5
			return false
		elseif string.sub(text, pos, pos + 3) == "null" then
			pos = pos + 4
			return nil
		elseif c == "" then
			fail("unexpected end of text")
		end
		fail("unexpected character '" .. c .. "'")
		return nil
	end

	if string.sub(text, 1, 3) == "\239\187\191" then pos = 4 end -- byte order mark
	local value = parseValue()
	skipSpace()
	if pos <= len then fail("extra text after the JSON") end
	return value
end

local Storage = {}
AuralV2.Storage = Storage

local AUTOLOAD_KEY = "__autoload"

local function isReserved(name)
	return string.sub(name, 1, 2) == "__"
end

local function sortNames(names)
	table.sort(names, function(a, b)
		local la, lb = string.lower(a), string.lower(b)
		if la == lb then return a < b end
		return la < lb
	end)
	return names
end

function Storage.Memory(initial)
	local data = {}
	if initial then
		for k, v in pairs(initial) do data[k] = v end
	end
	local self = { Kind = "Memory", Persistent = false, Location = "memory" }
	function self:List()
		local names = {}
		for name in pairs(data) do
			if not isReserved(name) then names[#names + 1] = name end
		end
		return sortNames(names)
	end
	function self:Read(name) return data[name] end
	function self:Write(name, text)
		data[name] = text
		return true
	end
	function self:Delete(name)
		data[name] = nil
		return true
	end
	return self
end

local function optionalGlobal(read)
	local ok, value = pcall(read)
	if ok and type(value) == "function" then return value end
	return nil
end

function Storage.Files(folder)
	folder = (string.gsub(tostring(folder or "AuralV2/configs"), "[/\\]+$", ""))
	local api = {
		writefile = optionalGlobal(function() return writefile end),
		readfile = optionalGlobal(function() return readfile end),
		isfile = optionalGlobal(function() return isfile end),
		isfolder = optionalGlobal(function() return isfolder end),
		makefolder = optionalGlobal(function() return makefolder end),
		listfiles = optionalGlobal(function() return listfiles end),
		delfile = optionalGlobal(function() return delfile end),
	}
	for _, need in ipairs({ "writefile", "readfile", "isfile", "listfiles" }) do
		if not api[need] then return nil, "no " .. need .. " here" end
	end

	local function ensureFolder()
		if not api.makefolder then return end
		local path = ""
		for part in string.gmatch(folder, "[^/\\]+") do
			if path == "" then path = part else path = path .. "/" .. part end
			local exists = false
			if api.isfolder then
				local ok, result = pcall(api.isfolder, path)
				exists = ok and result == true
			end
			if not exists then pcall(api.makefolder, path) end
		end
	end
	ensureFolder()

	local function pathFor(name) return folder .. "/" .. name .. ".json" end
	local self = { Kind = "Files", Persistent = true, Location = folder }
	function self:List()
		local names = {}
		local ok, files = pcall(api.listfiles, folder)
		if ok and type(files) == "table" then
			for _, path in ipairs(files) do
				local base = string.match(tostring(path), "([^/\\]+)%.json$")
				if base and not isReserved(base) then names[#names + 1] = base end
			end
		end
		return sortNames(names)
	end
	function self:Read(name)
		local path = pathFor(name)
		local okFile, exists = pcall(api.isfile, path)
		if not (okFile and exists) then return nil end
		local ok, data = pcall(api.readfile, path)
		if ok and type(data) == "string" then return data end
		return nil
	end
	function self:Write(name, text)
		ensureFolder()
		local ok, err = pcall(api.writefile, pathFor(name), text)
		if ok then return true end
		return false, tostring(err)
	end
	function self:Delete(name)
		if not api.delfile then return false, "this environment cannot delete files" end
		local ok, err = pcall(api.delfile, pathFor(name))
		if ok then return true end
		return false, tostring(err)
	end
	return self
end

local function cleanConfigName(name)
	if type(name) ~= "string" then return nil end
	name = (string.gsub(name, '[\\/:*?"<>|%c]', "_"))
	name = (string.gsub(name, "^[%s%.]+", ""))
	name = (string.gsub(name, "[%s%.]+$", ""))
	local count = utf8.len(name) or 0
	if count and count > 40 then
		local cut = utf8.offset(name, 41)
		name = string.sub(name, 1, cut and (cut - 1) or 40)
	elseif not count and #name > 40 then
		name = string.sub(name, 1, 40)
	end
	if name == "" or isReserved(name) then return nil end
	return name
end

local function stripFences(text)
	text = (string.gsub(tostring(text), "^%s+", ""))
	text = (string.gsub(text, "%s+$", ""))
	if string.sub(text, 1, 3) == "```" then
		text = (string.gsub(text, "^```[%w_%-]*[ \t]*\r?\n?", ""))
		text = (string.gsub(text, "\r?\n?```$", ""))
	end
	return text
end

local function copyToClipboard(text)
	local candidates = {
		optionalGlobal(function() return setclipboard end),
		optionalGlobal(function() return toclipboard end),
	}
	for _, fn in ipairs(candidates) do
		if fn and pcall(fn, text) then return true end
	end
	return false
end

function Window:_registerControl(obj, o, section)
	if o.Save == false then return end
	local flag = o.Flag
	if flag == nil then
		local parts = {}
		local function add(s)
			if s and s ~= "" then parts[#parts + 1] = s end
		end
		local page = section.Page
		local tab = page and page.Tab
		add(tab and tab.Name)
		if page and tab and page.Name ~= tab.Name then add(page.Name) end
		add(section.Title)
		add(obj.Row and obj.Row.Label.Text)
		flag = table.concat(parts, "/")
		if flag == "" then flag = obj.Kind end
	end
	flag = tostring(flag)
	local base, n = flag, 2
	while self.Flags[flag] do
		flag = base .. " #" .. n
		n = n + 1
	end
	obj.Flag = flag
	self.Flags[flag] = obj
	local pending = self._pending
	if pending and pending[flag] ~= nil then
		local value = pending[flag]
		pending[flag] = nil
		pcall(obj._deserialize, obj, value, false)
	end
end

function Window:_unregisterControl(obj)
	if obj.Flag and self.Flags[obj.Flag] == obj then self.Flags[obj.Flag] = nil end
end

function Window:GetConfig(name)
	local flags = {}
	for flag, obj in pairs(self.Flags) do
		local ok, value = pcall(obj._serialize, obj)
		if ok and value ~= nil then flags[flag] = value end
	end
	return {
		format = "AuralV2.Config",
		version = 1,
		name = name or self._configName or "Default",
		flags = flags,
	}
end

function Window:ExportConfig(name)
	local config = self:GetConfig(name)
	local text = JSON.encode(config, true)
	if #text > 15000 then text = JSON.encode(config, false) end
	return text
end

function Window:LoadConfig(input, options)
	options = options or {}
	local config = input
	if type(input) == "string" then
		local text = stripFences(input)
		if text == "" then return false, "Nothing to import - paste a config first." end
		if #text > 500000 then return false, "That text is too long to be a config." end
		local ok, decoded = pcall(JSON.decode, text)
		if not ok then return false, "That isn't valid JSON. " .. tostring(decoded) end
		config = decoded
	end
	if type(config) ~= "table" then return false, "That isn't a config (expected a JSON object)." end
	if config.format ~= nil and config.format ~= "AuralV2.Config" then
		return false, "That JSON isn't an Aural V2 config."
	end
	if type(config.flags) ~= "table" then return false, "No settings found in that config." end

	local ids = {}
	for flag in pairs(config.flags) do
		if type(flag) == "string" then ids[#ids + 1] = flag end
	end
	table.sort(ids)

	local applied, skipped, missing = 0, 0, 0
	local pending = nil
	if options.KeepUnmatched then pending = {} end
	for _, flag in ipairs(ids) do
		local obj = self.Flags[flag]
		local value = config.flags[flag]
		if obj then
			local ok, result = pcall(obj._deserialize, obj, value, options.Silent == true)
			if ok and result then applied = applied + 1 else skipped = skipped + 1 end
		else
			missing = missing + 1
			if pending then pending[flag] = value end
		end
	end
	self._pending = pending

	local name = options.Name
	if name == nil and type(config.name) == "string" then name = cleanConfigName(config.name) end
	if name then self:SetConfig(name, true) end
	self:_refreshConfigUI()
	self.ConfigLoaded:Fire(name, applied)
	return true, { Name = name, Applied = applied, Skipped = skipped, Missing = missing }
end

function Window:ImportConfig(text, options)
	return self:LoadConfig(text, options)
end

function Window:GetStorage() return self._storage end

function Window:SetStorage(adapter)
	self._storage = adapter
	self:_refreshConfigUI()
end

function Window:ListConfigs()
	local storage = self._storage
	if not storage then return {} end
	local ok, names = pcall(storage.List, storage)
	if ok and type(names) == "table" then return names end
	return {}
end

function Window:_readConfigText(name)
	local storage = self._storage
	if not storage then return nil end
	local ok, text = pcall(storage.Read, storage, name)
	if ok and type(text) == "string" then return text end
	return nil
end

function Window:SaveConfig(name)
	local storage = self._storage
	if not storage then return false, "Saving is turned off for this window." end
	name = cleanConfigName(name or self._configName)
	if not name then return false, "Type a config name first." end
	local existed = self:_readConfigText(name) ~= nil
	local text = JSON.encode(self:GetConfig(name), true)
	local ok, wrote, why = pcall(storage.Write, storage, name, text)
	if not ok then return false, "Couldn't save: " .. tostring(wrote) end
	if wrote ~= true then return false, "Couldn't save: " .. tostring(why or "unknown error") end
	self:SetConfig(name, true)
	self:_refreshConfigUI()
	self.ConfigSaved:Fire(name)
	return true, name, existed
end

function Window:LoadSavedConfig(name, options)
	if not self._storage then return false, "Saving is turned off for this window." end
	local clean = cleanConfigName(name)
	if not clean then return false, "Pick a saved config first." end
	local text = self:_readConfigText(clean)
	if not text then return false, "There is no saved config called '" .. clean .. "'." end
	options = options or {}
	options.Name = options.Name or clean
	return self:LoadConfig(text, options)
end

function Window:DeleteConfig(name)
	local storage = self._storage
	if not storage then return false, "Saving is turned off for this window." end
	local clean = cleanConfigName(name)
	if not clean or not self:_readConfigText(clean) then return false, "There is no saved config with that name." end
	local ok, deleted, why = pcall(storage.Delete, storage, clean)
	if not ok or deleted ~= true then
		return false, "Couldn't delete: " .. tostring((ok and why) or (not ok and deleted) or "unknown error")
	end
	if self:GetAutoLoad() == clean then self:SetAutoLoad(nil) end
	self:_refreshConfigUI()
	return true, clean
end

function Window:GetAutoLoad()
	local text = self:_readConfigText(AUTOLOAD_KEY)
	if not text then return nil end
	local ok, data = pcall(JSON.decode, text)
	if not ok or type(data) ~= "table" then return nil end
	local name = cleanConfigName(data.autoload)
	if name and self:_readConfigText(name) then return name end
	return nil
end

function Window:SetAutoLoad(name)
	local storage = self._storage
	if not storage then return false, "Saving is turned off for this window." end
	local data = {}
	if name then
		name = cleanConfigName(name)
		if not name or not self:_readConfigText(name) then return false, "Save that config first, then pick it." end
		data.autoload = name
	end
	local ok, wrote, why = pcall(storage.Write, storage, AUTOLOAD_KEY, JSON.encode(data))
	if not ok or wrote ~= true then
		return false, "Couldn't change auto load: " .. tostring((ok and why) or (not ok and wrote) or "unknown error")
	end
	self:_refreshConfigUI()
	return true, name
end

function Window:LoadAutoConfig()
	local name = self:GetAutoLoad()
	if not name then return false end
	local ok, info = self:LoadSavedConfig(name, { KeepUnmatched = true })
	if ok and self._cfgNotify then
		self:Notify({ Title = "Config loaded", Text = name .. "  (" .. info.Applied .. " settings)" })
	end
	return ok, info
end

function Window:_setupConfigs(options)
	if options == false then return end
	options = type(options) == "table" and options or {}
	self._cfgNotify = options.Notify ~= false
	local storage = options.Storage
	if storage == nil then
		local files = Storage.Files(options.Folder)
		storage = files or Storage.Memory()
	end
	self._storage = storage
	if self._config then self._configName = self._config.Name end
	if options.AutoLoad ~= false then
		local defer = task.defer or function(f) task.delay(0, f) end
		defer(function()
			if self.Gui and self.Gui.Parent then self:LoadAutoConfig() end
		end)
	end
end

function Window:_openConfigMenu(anchor)
	local theme = self.Theme
	local items = {}
	for _, name in ipairs(self:ListConfigs()) do
		items[#items + 1] = { Text = name, Value = name }
	end
	if #items == 0 then
		items[1] = { Text = "No saved configs yet", Color = theme.TextPlaceholder }
	end
	self:_openMenu(anchor, items, {
		Align = "Right", Selected = self._configName,
		OnSelect = function(name)
			if not name then return end
			local ok, info = self:LoadSavedConfig(name)
			if ok then
				self:Notify({ Title = "Config loaded", Text = name .. "  (" .. info.Applied .. " settings)" })
			else
				self:Notify({ Title = "Couldn't load config", Text = tostring(info) })
			end
			local cb = self._config and self._config.Callback
			if cb then task.spawn(cb, name) end
		end,
	})
end

function Window:_refreshConfigUI()
	local ui = self._configUI
	if not ui then return end
	if ui.List then
		local names = self:ListConfigs()
		ui.List:SetValues(names)
		local current = self._configName
		for _, n in ipairs(names) do
			if n == current then ui.List:Set(n, true) end
		end
	end
	if ui.NameBox and self._configName then ui.NameBox:Set(self._configName, true) end
	if ui.AutoLabel then
		local auto = self:GetAutoLoad()
		ui.AutoLabel:Set("Auto load on execute: " .. (auto or "off"))
	end
end

function Window:AddConfigSections(target, options)
	options = options or {}
	local ui = {}
	self._configUI = ui
	local storage = self._storage

	local function say(title, text)
		self:Notify({ Title = title, Text = text })
	end

	if storage then
		local configs = target:AddSection({ Title = options.Title or "Configs", Side = "Left" })
		ui.NameBox = configs:AddTextBox({
			Name = "Config name", Placeholder = "My config", Default = self._configName or "", Width = 150, Save = false,
		})
		ui.List = configs:AddDropdown({ Name = "Saved configs", Values = {}, MinWidth = 150, Save = false })

		configs:AddButton({ Name = "Save config", Text = "Save", Style = "Accent", Callback = function()
			local ok, name, existed = self:SaveConfig(ui.NameBox:Get())
			if ok then
				say(existed and "Config updated" or "Config saved", name)
			else
				say("Couldn't save", tostring(name))
			end
		end })
		configs:AddButton({ Name = "Load config", Text = "Load", Callback = function()
			local ok, info = self:LoadSavedConfig(ui.List:Get())
			if ok then
				say("Config loaded", info.Name .. "  (" .. info.Applied .. " settings)")
			else
				say("Couldn't load", tostring(info))
			end
		end })

		local deleteButton
		deleteButton = configs:AddButton({ Name = "Delete config", Text = "Delete", Callback = function()
			local name = ui.List:Get()
			if not name then
				say("Couldn't delete", "Pick a saved config first.")
				return
			end
			self:Confirm({
				Title = "Delete config?", Text = "\"" .. tostring(name) .. "\" will be removed. This can't be undone.",
				ConfirmText = "Delete", Danger = true,
				Callback = function(yes)
					if not yes then return end
					local ok, result = self:DeleteConfig(name)
					if ok then say("Config deleted", result) else say("Couldn't delete", tostring(result)) end
				end,
			})
		end })
		ui.DeleteButton = deleteButton
		configs:AddButton({ Name = "Refresh list", Text = "Refresh", Callback = function()
			self:_refreshConfigUI()
		end })

		local auto = target:AddSection({ Title = "Auto load", Side = "Left" })
		ui.AutoLabel = auto:AddLabel({ Text = "" })
		auto:AddButton({ Name = "Auto load the selected config", Text = "Set", Style = "Accent", Callback = function()
			local ok, result = self:SetAutoLoad(ui.List:Get())
			if ok then
				say("Auto load set", tostring(result) .. " will load when the script runs.")
			else
				say("Couldn't set auto load", tostring(result))
			end
		end })
		auto:AddButton({ Name = "Turn auto load off", Text = "Off", Callback = function()
			local ok, result = self:SetAutoLoad(nil)
			if ok then say("Auto load off", "Nothing loads automatically now.") else say("Couldn't change it", tostring(result)) end
		end })
		local where
		if storage.Persistent then
			where = "Saving to files: " .. tostring(storage.Location)
		else
			where = "No file access: configs are lost on rejoin"
		end
		ui.StorageLabel = auto:AddLabel({ Text = where })
	end

	local share = target:AddSection({ Title = "Share", Side = "Right" })
	share:AddKeybind({
    Name = "Menu Keybind",
    Default = self._toggleKey or Enum.KeyCode.RightShift,
    Mode = "None",
    Callback = function(key)
        self:SetToggleKey(key)
    end
})
	ui.Json = share:AddTextArea({
		Name = "Config JSON", Lines = 8, Save = false,
		Placeholder = "Press Export to get your config as text, or paste someone else's here and press Import",
	})
	share:AddButton({ Name = "Export current config", Text = "Export", Style = "Accent", Callback = function()
		local text = self:ExportConfig()
		ui.Json:Set(text, true)
		if copyToClipboard(text) then
			say("Config copied", "The JSON is on your clipboard and in the box.")
		else
			say("Config exported", "Select the text in the box and copy it (Ctrl+C).")
		end
	end })
	share:AddButton({ Name = "Import config from the box", Text = "Import", Callback = function()
		local ok, info = self:ImportConfig(ui.Json:Get())
		if ok then
			say("Config imported", (info.Name or "Config") .. "  (" .. info.Applied .. " settings)")
		else
			say("Import failed", tostring(info))
		end
	end })
	share:AddButton({ Name = "Copy the box to the clipboard", Text = "Copy", Callback = function()
		local text = ui.Json:Get()
		if text == "" then
			say("Nothing to copy", "Press Export first.")
		elseif copyToClipboard(text) then
			say("Copied", "The text is on your clipboard.")
		else
			say("No clipboard here", "Select the text in the box and copy it (Ctrl+C).")
		end
	end })
	share:AddButton({ Name = "Clear the box", Text = "Clear", Callback = function() ui.Json:Set("", true) end })

	self:_refreshConfigUI()
	return ui
end

local KEY_SHORT = {
	LeftShift = "LShift", RightShift = "RShift", LeftControl = "LCtrl", RightControl = "RCtrl",
	LeftAlt = "LAlt", RightAlt = "RAlt", Return = "Enter", Backspace = "Bksp", Escape = "Esc",
	Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
	KeypadZero = "Num0", KeypadOne = "Num1", KeypadTwo = "Num2", KeypadThree = "Num3", KeypadFour = "Num4",
	KeypadFive = "Num5", KeypadSix = "Num6", KeypadSeven = "Num7", KeypadEight = "Num8", KeypadNine = "Num9",
	BackSlash = "\\", Backquote = "`", Minus = "-", Equals = "=", LeftBracket = "[", RightBracket = "]",
	Semicolon = ";", Quote = "'", Comma = ",", Period = ".", Slash = "/", PageUp = "PgUp", PageDown = "PgDn",
	Insert = "Ins", Delete = "Del", CapsLock = "Caps",
}
local MOUSE_BINDINGS = { MouseButton2 = true, MouseButton3 = true }

local function newBinding(item, kind)
	local name = item.Name
	local short = KEY_SHORT[name] or name
	if kind == "Mouse" then short = "Mouse" .. string.sub(name, -1) end
	return { Kind = kind, Enum = item, Name = name, Short = short }
end

local function bindingFromName(name)
	if type(name) ~= "string" then return nil, false end
	if name == "None" or name == "" then return nil, true end
	if MOUSE_BINDINGS[name] then return newBinding(Enum.UserInputType[name], "Mouse"), true end
	local ok, item = pcall(function() return Enum.KeyCode[name] end)
	if ok and item ~= nil and item ~= Enum.KeyCode.Unknown then return newBinding(item, "Key"), true end
	return nil, false
end

local function isEnumItem(v)
	return typeof(v) == "EnumItem" or (type(v) == "table" and v.EnumCategory ~= nil)
end

local function bindingFromValue(v)
	if v == nil or v == false then return nil, true end
	if type(v) == "string" then return bindingFromName(v) end
	if isEnumItem(v) then return bindingFromName(v.Name) end
	return nil, false
end

local function bindingFromInput(input)
	local t = input.UserInputType
	if t == Enum.UserInputType.MouseButton2 or t == Enum.UserInputType.MouseButton3 then return newBinding(t, "Mouse") end
	local k = input.KeyCode
	if k ~= nil and k ~= Enum.KeyCode.Unknown then return newBinding(k, "Key") end
	return nil
end

local function inputMatches(binding, input)
	if binding.Kind == "Mouse" then return input.UserInputType == binding.Enum end
	return input.KeyCode == binding.Enum
end

function Window:_cancelCapture()
	local cap = self._capture
	if cap then
		self._capture = nil
		cap.Cancel()
	end
end

function Window:_beginCapture(apply, cancel)
	self:_cancelCapture()
	self._capture = { Apply = apply, Cancel = cancel }
end

function Window:_inputBegan(input, processed)
	local cap = self._capture
	if cap then
		local t = input.UserInputType
		if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
			self:_cancelCapture()
		elseif input.KeyCode == Enum.KeyCode.Escape then
			self:_cancelCapture()
		elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
			self._capture = nil
			cap.Apply(nil)
		else
			local binding = bindingFromInput(input)
			if binding then
				self._capture = nil
				cap.Apply(binding)
			end
		end
		return
	end
	if input.KeyCode == Enum.KeyCode.Escape and self._dialog then
		self._dialog.Dismiss() -- Esc is "processed" by Roblox's own menu, so this check comes first
		return
	end
	if processed then return end -- typing in a text box, a game menu, ...
	local key = self._toggleKey
	if key and input.KeyCode == key then
		self:Toggle()
		return
	end
	local snapshot = {}
	for i, kb in ipairs(self._keybinds) do snapshot[i] = kb end
	for _, kb in ipairs(snapshot) do kb:_press(input) end
end

function Window:_inputEnded(input)
	local snapshot = {}
	for i, kb in ipairs(self._keybinds) do snapshot[i] = kb end
	for _, kb in ipairs(snapshot) do kb:_release(input) end
end

function Window:_newKeybind(parent, cfg, ctx)
	local window = self
	local theme = self.Theme
	cfg = cfg or {}
	ctx = ctx or {}
	local mode = cfg.Mode or ctx.DefaultMode or "Press"
	if mode ~= "Press" and mode ~= "Toggle" and mode ~= "Hold" and mode ~= "None" then mode = "Press" end
	local kb = { Mode = mode, State = false, Width = 64, Changed = Signal.new(), Triggered = Signal.new() }
	local binding = bindingFromValue(cfg.Default)
	local listening = false

	local button = create("TextButton", {
		Name = "Keybind", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = theme.Control, Size = UDim2.fromOffset(kb.Width, 22), Parent = parent,
	})
	corner(button, theme.ControlRadius)
	local outline = stroke(button, theme.AccentBar, 1, 1)
	local label = create("TextLabel", {
		Name = "Key", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = theme.Font, TextSize = 11,
		TextColor3 = theme.TextDropdown, TextTruncate = Enum.TextTruncate.AtEnd, Text = "", Parent = button,
	})
	kb.Button = button
	kb.Label = label

	local function render()
		if listening then
			label.Text = "..."
			label.TextColor3 = theme.Accent
			outline.Transparency = 0
		else
			label.Text = binding and binding.Short or "None"
			label.TextColor3 = binding and theme.TextDropdown or theme.TextPlaceholder
			outline.Transparency = 1
		end
	end

	function kb:_apply(b, silent)
		local same = (b == nil and binding == nil) or (b ~= nil and binding ~= nil and b.Name == binding.Name)
		if same then
			render()
			return
		end
		binding = b
		self.State = false
		render()
		if not silent then self.Changed:Fire(self:Get()) end
	end
	function kb:Get()
		if binding then return binding.Enum end
		return nil
	end
	function kb:GetName()
		if binding then return binding.Name end
		return "None"
	end
	function kb:Set(v, silent)
		local b, ok = bindingFromValue(v)
		if not ok then return false end -- not a key: keep the current binding
		self:_apply(b, silent)
		return true
	end
	function kb:SetByName(name, silent)
		local b, ok = bindingFromName(name)
		if not ok then return false end
		self:_apply(b, silent)
		return true
	end
	function kb:_locked()
		return ctx.Locked ~= nil and ctx.Locked() == true
	end
	function kb:_press(input)
		if self.Mode == "None" or binding == nil or self:_locked() then return end
		if not inputMatches(binding, input) then return end
		if self.Mode == "Toggle" then
			self.State = not self.State
			self.Triggered:Fire(self.State)
		elseif self.Mode == "Hold" then
			if not self.State then
				self.State = true
				self.Triggered:Fire(true)
			end
		else
			self.Triggered:Fire(true)
		end
	end
	function kb:_release(input)
		if self.Mode == "Hold" and self.State and binding ~= nil and inputMatches(binding, input) then
			self.State = false
			self.Triggered:Fire(false)
		end
	end
	function kb:Destroy()
		if listening then window:_cancelCapture() end
		for i, k in ipairs(window._keybinds) do
			if k == kb then
				table.remove(window._keybinds, i)
				break
			end
		end
	end

	button.MouseEnter:Connect(function()
		if not listening then tween(button, 0.1, { BackgroundColor3 = theme.ControlHover }) end
	end)
	button.MouseLeave:Connect(function() tween(button, 0.1, { BackgroundColor3 = theme.Control }) end)
	button.MouseButton1Click:Connect(function()
		if kb:_locked() then return end
		listening = true
		render()
		window:_beginCapture(function(b)
			listening = false
			kb:_apply(b, false)
		end, function()
			listening = false
			render()
		end)
	end)

	self._keybinds[#self._keybinds + 1] = kb
	render()
	return kb
end

function Window:Dialog(o)
	o = o or {}
	if self._dialog then
		self._dialogQueue[#self._dialogQueue + 1] = o
		return
	end
	self:_showDialog(o)
end

function Window:Confirm(o)
	o = o or {}
	local function answer(yes)
		if yes then
			if o.OnConfirm then task.spawn(o.OnConfirm) end
		else
			if o.OnCancel then task.spawn(o.OnCancel) end
		end
		if o.Callback then task.spawn(o.Callback, yes) end
	end
	local confirmStyle = "Accent"
	if o.Danger == true then confirmStyle = "Danger" end
	self:Dialog({
		Title = o.Title or "Are you sure?", Text = o.Text, Dismissable = o.Dismissable,
		Buttons = {
			{ Text = o.CancelText or "Cancel", Style = "Default", Callback = function() answer(false) end },
			{ Text = o.ConfirmText or "Confirm", Style = confirmStyle, Callback = function() answer(true) end },
		},
		OnDismiss = function() answer(false) end,
	})
end

function Window:_showDialog(o)
	local theme = self.Theme
	local buttons = o.Buttons
	if type(buttons) ~= "table" or #buttons == 0 then buttons = { { Text = "OK", Style = "Accent" } } end
	local title = o.Title ~= nil and tostring(o.Title) or ""
	local text = o.Text ~= nil and tostring(o.Text) or ""
	local cardW, innerW = 304, 304 - 40
	local state = { Closed = false }

	local scrim = noTheme(create("TextButton", {
		Name = "DialogScrim", Text = "", AutoButtonColor = false, BorderSizePixel = 0,
		BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1), ZIndex = 150, Parent = self.Gui,
	}))

	local lines = 0
	if text ~= "" then
		for part in (text .. "\n"):gmatch("(.-)\n") do
			lines = lines + math.max(1, math.ceil(textWidth(part, 12, theme.Font) / (innerW - 4)))
		end
	end
	local textH = lines * 16
	local height = 20 + (title ~= "" and 22 or 0) + (textH > 0 and (textH + 6) or 0) + 18 + 30 + 18
	local card = newGroup({
		Name = "Dialog", BackgroundColor3 = theme.Card, BorderSizePixel = 0, AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(cardW, height), ZIndex = 151, Parent = self.Gui,
	}, self._rootCanvas == true)
	local center = self.Gui.AbsoluteSize / 2
	if self._open then
		center = self.Root.AbsolutePosition + self.Root.AbsoluteSize / 2
	end
	card.Position = UDim2.fromOffset(math.floor(center.X + 0.5), math.floor(center.Y + 0.5))
	corner(card, theme.CardRadius)
	stroke(card, theme.Divider, 1)
	local cardScale = create("UIScale", { Scale = self._baseScale or 1, Parent = card })

	local y = 20
	if title ~= "" then
		create("TextLabel", {
			Name = "Title", BackgroundTransparency = 1, Position = UDim2.fromOffset(20, y), Size = UDim2.fromOffset(innerW, 20),
			Font = theme.FontBold, TextSize = 14, TextColor3 = theme.TextStrong, TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd, Text = title, Parent = card,
		})
		y = y + 22
	end
	if textH > 0 then
		create("TextLabel", {
			Name = "Text", BackgroundTransparency = 1, Position = UDim2.fromOffset(20, y), Size = UDim2.fromOffset(innerW, textH),
			Font = theme.Font, TextSize = 12, TextColor3 = theme.TextMuted, TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, Text = text, Parent = card,
		})
		y = y + textH + 6
	end

	local row = create("Frame", {
		Name = "Buttons", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(20, y + 18), Size = UDim2.fromOffset(innerW, 30), Parent = card,
	})
	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8), Parent = row,
	})

	local function close(index)
		if state.Closed then return end
		state.Closed = true
		if self._dialog == state then self._dialog = nil end
		local spec = index and buttons[index] or nil
		if self._animate and scrim.Parent then
			tween(scrim, 0.15, { BackgroundTransparency = 1 })
			if self._rootCanvas then tween(card, 0.15, { GroupTransparency = 1 }) end
			tween(cardScale, 0.15, { Scale = (self._baseScale or 1) * 0.95 })
			task.delay(0.17, function()
				scrim:Destroy()
				card:Destroy()
			end)
		else
			scrim:Destroy()
			card:Destroy()
		end
		if spec then
			if spec.Callback then task.spawn(spec.Callback, index) end
		elseif o.OnDismiss then
			task.spawn(o.OnDismiss)
		end
		if o.OnClose then task.spawn(o.OnClose, index) end
		task.defer(function()
			if self._dialog == nil and self.Gui and self.Gui.Parent then
				local nextDialog = table.remove(self._dialogQueue, 1)
				if nextDialog then self:_showDialog(nextDialog) end
			end
		end)
	end
	function state.Dismiss()
		if o.Dismissable ~= false then close(nil) end
	end
	state.Close = close
	scrim.MouseButton1Click:Connect(state.Dismiss)

	for i, spec in ipairs(buttons) do
		local style = spec.Style or (i == #buttons and "Accent" or "Default")
		local function colors()
			if style == "Accent" then return theme.AccentBar, theme.FillTop, theme.Knob end
			if style == "Danger" then return theme.Danger, mixColor(theme.Danger, Color3.new(1, 1, 1), 0.14), theme.Knob end
			return theme.Control, theme.ControlHover, theme.TextDropdown
		end
		local base, _, textColor = colors()
		local label = tostring(spec.Text or "OK")
		local button = create("TextButton", {
			Name = "Button", AutoButtonColor = false, Text = label, Font = theme.Font, TextSize = 12,
			TextColor3 = textColor, BackgroundColor3 = base, BorderSizePixel = 0, LayoutOrder = i,
			Size = UDim2.fromOffset(math.max(76, math.floor(textWidth(label, 12, theme.Font) + 32 + 0.5)), 30), Parent = row,
		})
		corner(button, theme.ControlRadius + 1)
		button.MouseEnter:Connect(function()
			local _, hover = colors()
			tween(button, 0.1, { BackgroundColor3 = hover })
		end)
		button.MouseLeave:Connect(function()
			local b = colors()
			tween(button, 0.1, { BackgroundColor3 = b })
		end)
		button.MouseButton1Click:Connect(function() close(i) end)
	end

	self._dialog = state
	if self._animate then
		tween(scrim, 0.2, { BackgroundTransparency = 0.5 })
		if self._rootCanvas then
			card.GroupTransparency = 1
			tween(card, 0.18, { GroupTransparency = 0 })
		end
		cardScale.Scale = (self._baseScale or 1) * 0.92
		tween(cardScale, 0.28, { Scale = self._baseScale or 1 }, Enum.EasingStyle.Back)
	else
		scrim.BackgroundTransparency = 0.5
	end
end

function Window:_closeDialogs(silent)
	self._dialogQueue = {}
	local d = self._dialog
	if d then
		if silent then
			d.Closed = true
			self._dialog = nil
		else
			d.Close(nil)
		end
	end
end

function Window:GetTheme() return self._themeName end

function Window:GetThemes()
	local names = {}
	for name in pairs(AuralV2.Themes) do
		if name ~= "Default" then names[#names + 1] = name end
	end
	table.sort(names)
	table.insert(names, 1, "Default")
	return names
end

function Window:AddTheme(name, overrides)
	return AuralV2.AddTheme(name, overrides)
end

function Window:_applyTheme(spec, accent, source)
	local new, name = resolveTheme(spec)
	if accent then
		for k, v in pairs(accentFamily(accent)) do new[k] = v end
		uniquifyTheme(new)
	end
	local old = self.Theme
	local map, safe, newSet = {}, {}, {}
	local keys = themeColorKeys(new)
	for _, k in ipairs(keys) do newSet[colorHex(new[k])] = true end
	for _, k in ipairs(keys) do
		local was = old[k]
		if k ~= "Knob" and typeof(was) == "Color3" then
			local oldHex, newHex = colorHex(was), colorHex(new[k])
			if oldHex ~= newHex then
				map[oldHex] = new[k]
				if not newSet[oldHex] then safe[oldHex] = new[k] end
			end
		end
	end
	for k, v in pairs(new) do old[k] = v end
	recolorTree(self.Gui, map)
	if self._backdropGradient and new.BackdropColors then self._backdropGradient.Color = new.BackdropColors end
	task.delay(0.7, function()
		if self.Gui and self.Gui.Parent then recolorTree(self.Gui, safe) end
	end)
	self._themeName = name
	self._accentApplied = accent
	self:_updatePill()
	self.ThemeChanged:Fire(name, source)
end

function Window:SetTheme(spec)
	if type(spec) == "string" and not AuralV2.Themes[spec] then return false end
	self._themeSpec = spec
	self._accentTarget = nil
	self:_applyTheme(spec, nil, "theme")
	return true
end

function Window:SetAccent(color)
	if typeof(color) ~= "Color3" then return false end
	self._accentTarget = color
	if self._accentBusy then return true end
	self._accentBusy = true
	self:_applyTheme(self._themeSpec, color, "accent")
	task.delay(0.08, function()
		self._accentBusy = false
		if self._accentTarget ~= nil and self._accentTarget ~= self._accentApplied and self.Gui and self.Gui.Parent then
			self:SetAccent(self._accentTarget)
		end
	end)
	return true
end

function Window:AddThemePicker(target, options)
	options = options or {}
	local section = target
	if target.AddDropdown == nil then
		section = target:AddSection({ Title = options.Title or "Theme", Side = options.Side })
	end
	local save = options.Save == true
	local picker = section:AddDropdown({
		Name = options.Name or "Theme", Values = self:GetThemes(), Default = self._themeName, Save = save,
		Desc = options.Desc, Callback = function(name) self:SetTheme(name) end,
	})
	local accent = nil
	if options.Accent ~= false then
		accent = section:AddColorPicker({
			Name = options.AccentName or "Accent color", Default = self.Theme.Accent, Save = save,
			Callback = function(color) self:SetAccent(color) end,
		})
	end
	self.ThemeChanged:Connect(function(name, source)
		if source == "accent" then return end -- the colour picker made this change itself
		picker:Set(name, true)
		if accent then accent:Set(self.Theme.Accent, true) end
	end)
	return section, picker, accent
end

local function readPing()
	local player = Players.LocalPlayer
	if player then
		local ok, seconds = pcall(function() return player:GetNetworkPing() end)
		if ok and type(seconds) == "number" then return seconds * 1000 end
	end
	local ok, ms = pcall(function() return (game:GetService("Stats") :: any).Network.ServerStatsItem["Data Ping"]:GetValue() end)
	if ok and type(ms) == "number" then return ms end
	return nil
end

local function formatDuration(total)
	total = math.max(0, math.floor(total))
	local h = math.floor(total / 3600)
	local m = math.floor((total % 3600) / 60)
	local s = total % 60
	if h > 0 then return string.format("%dh %02dm", h, m) end
	if m > 0 then return string.format("%dm %02ds", m, s) end
	return string.format("%ds", s)
end

function Window:_statValue(kind)
	local theme = self.Theme
	if kind == "fps" then
		local fps = self._fps
		if fps == nil then return "...", nil end
		local color = theme.Danger
		if fps >= 55 then color = theme.Success elseif fps >= 30 then color = theme.Warning end
		return string.format("%d", math.floor(fps + 0.5)), color
	elseif kind == "ping" then
		local ping = readPing()
		if ping == nil then return "n/a", theme.TextPlaceholder end
		local color = theme.Danger
		if ping <= 90 then color = theme.Success elseif ping <= 180 then color = theme.Warning end
		return string.format("%d ms", math.floor(ping + 0.5)), color
	elseif kind == "players" then
		local ok, list = pcall(function() return Players:GetPlayers() end)
		local count = (ok and type(list) == "table") and #list or 0
		local max = Players.MaxPlayers
		if type(max) == "number" and max > 0 then return count .. " / " .. max, nil end
		return tostring(count), nil
	elseif kind == "uptime" then
		return formatDuration(os.time() - self._startTime), nil
	elseif kind == "time" then
		return tostring(os.date("%H:%M:%S")), nil
	end
	return "-", nil
end

function Window:_updateStats()
	local alive = {}
	for _, stat in ipairs(self._stats) do
		local row = stat.Obj.Row
		if row and row.Frame.Parent then
			alive[#alive + 1] = stat
			local text, color = self:_statValue(stat.Kind)
			stat.Obj:SetValue(text, color)
		end
	end
	self._stats = alive
end

function Window:_startStats()
	if self._statsConn then return end
	local seconds, frames = 0, 0
	self._statsConn = self:_connect(RunService.RenderStepped, function(dt)
		frames = frames + 1
		seconds = seconds + dt
		if seconds >= 0.5 then
			self._fps = frames / seconds
			frames, seconds = 0, 0
			if self._open then self:_updateStats() end
		end
	end)
end

function Window:_bindStat(obj, kind)
	self._stats[#self._stats + 1] = { Obj = obj, Kind = string.lower(tostring(kind)) }
	self:_startStats()
	local text, color = self:_statValue(string.lower(tostring(kind)))
	obj:SetValue(text, color)
end

function Window:AddStatsSection(target, options)
	options = options or {}
	local section = target
	if target.AddStat == nil then
		section = target:AddSection({ Title = options.Title or "Session", Side = options.Side })
	end
	local names = { FPS = "FPS", Ping = "Ping", Players = "Players", Uptime = "Session time", Time = "Local time" }
	for _, stat in ipairs(options.Stats or { "FPS", "Ping", "Players", "Uptime", "Time" }) do
		section:AddStat({ Name = names[stat] or stat, Stat = stat })
	end
	return section
end
do
local Chat = {}
AuralV2.Chat = Chat

local TEXT_MAX, NAME_MAX, UID_MAX, ROOM_MAX = 200, 24, 24, 64
local BATCH_MAX = 60
local KINDS = { chat = true, me = true, join = true, leave = true, rename = true }

local function isJunk(cp)
	return cp < 0x20 or (cp >= 0x7F and cp <= 0x9F) or (cp >= 0x200B and cp <= 0x200F)
		or (cp >= 0x2028 and cp <= 0x202E) or (cp >= 0x2066 and cp <= 0x2069) or cp == 0xFEFF
end

local function cleanText(value, max)
	if type(value) ~= "string" then return "" end
	local ok, out = pcall(function()
		local parts, n = {}, 0
		for _, cp in utf8.codes(value) do
			n = n + 1
			parts[n] = isJunk(cp) and " " or utf8.char(cp)
		end
		return table.concat(parts)
	end)
	if not ok then
		out = string.gsub(value, "[^\32-\126]", " ") -- not valid UTF-8: keep printable ASCII only
	end
	out = string.gsub(out, " +", " ")
	out = string.match(out, "^ *(.-) *$")
	local n = utf8.len(out) or 0
	if n > max then
		local cut = utf8.offset(out, max + 1)
		if cut then out = string.sub(out, 1, cut - 1) end
	end
	return out
end
Chat.CleanText = cleanText

local function cleanUid(value)
	if type(value) ~= "string" and type(value) ~= "number" then return "" end
	local s = tostring(value)
	if #s > UID_MAX or string.find(s, "[^%w_%-]") then return "" end
	return s
end

local function cleanRoom(value)
	if type(value) ~= "string" then return nil end
	local s = string.gsub(value, "[^%w:_%.%-]", "-")
	s = string.sub(s, 1, ROOM_MAX)
	if s == "" then return nil end
	return s
end

local function safeDate(format, t)
	local ok, text = pcall(os.date, format, t)
	if ok and type(text) == "string" then return text end
	return ""
end

local function findRequest()
	local reads = {
		function() return request end,
		function() return http_request end,
		function() return getgenv().syn.request end,
		function() return http.request end,
		function() return getgenv().fluxus.request end,
	}
	for _, read in ipairs(reads) do
		local fn = optionalGlobal(read)
		if fn then return fn end
	end
	return nil
end

local function urlEncode(s)
	return (string.gsub(tostring(s), "[^%w%-_%.~]", function(ch)
		return string.format("%%%02X", string.byte(ch))
	end))
end

function Chat.Relay(server, opts)
	opts = opts or {}
	if type(server) ~= "string" then error("Chat.Relay needs the relay address as a string", 2) end
	local base = string.gsub(server, "%s+", "")
	base = string.gsub(base, "/+$", "")
	local secure = string.match(base, "^https://[%w%.%-]") ~= nil
	if not secure and string.match(base, "^http://[%w%.%-]") == nil then
		error("Chat.Relay: the address must start with https:// or http://", 2)
	end
	local key = opts.Key
	local transport = {
		Kind = "relay", Server = base, Secure = secure,
		Interval = tonumber(opts.Interval) or 0.3, Wait = tonumber(opts.Wait) or 10,
	}

	local function call(method, path, body)
		local send = opts.Request or findRequest()
		if not send then return false, "no HTTP function", "nohttp" end
		local headers = { Accept = "application/json" }
		if body then headers["Content-Type"] = "application/json" end
		if key ~= nil and key ~= "" then headers["x-aural-key"] = tostring(key) end
		local called, res = pcall(send, { Url = base .. path, Method = method, Headers = headers, Body = body })
		if not called then return false, "request failed" end
		if type(res) ~= "table" then return false, "no answer" end
		local status = tonumber(res.StatusCode or res.status_code or res.Status) or 0
		local text = res.Body or res.body
		local data = nil
		if type(text) == "string" and text ~= "" then
			local okJ, decoded = pcall(AuralV2.JSON.decode, text)
			if okJ and type(decoded) == "table" then data = decoded end
		end
		if status >= 200 and status < 300 and data and data.ok == true then return true, data end
		local reason = (data and type(data.error) == "string") and cleanText(data.error, 60) or nil
		if reason == "" then reason = nil end
		if status == 401 then return false, reason or "wrong key", "auth" end
		if status == 429 then return false, reason or "slow down", "limit" end
		if status == 0 then return false, "relay not reachable" end
		return false, reason or ("HTTP " .. status)
	end

	function transport:Poll(room, since, who, wait)
		local path = string.format("/v1/poll?room=%s&since=%d&wait=%d&uid=%s&name=%s",
			urlEncode(room), tonumber(since) or -1, math.floor(tonumber(wait) or 0), urlEncode(who.uid), urlEncode(who.name))
		return call("GET", path, nil)
	end

	function transport:Send(room, who, text, isMe)
		local body = AuralV2.JSON.encode({ room = room, uid = who.uid, name = who.name, text = text, me = isMe == true })
		local ok, res, code = call("POST", "/v1/send", body)
		if ok then return true, tonumber(res.seq) end
		return false, res, code
	end

	function transport:ShareConfig(room, who, title, data)
		local body = AuralV2.JSON.encode({ room = room, uid = who.uid, name = who.name, title = title, data = data })
		return call("POST", "/v1/config", body)
	end

	function transport:GetConfig(code)
		return call("GET", "/v1/config?code=" .. urlEncode(code), nil)
	end
	return transport
end

function Chat.NewStore(opts)
	opts = opts or {}
	return {
		rooms = {}, history = opts.History or 100, presence = opts.Presence or 25,
		firstBatch = 30, clock = opts.Clock or os.time,
	}
end

local function storeRoom(store, name)
	local room = store.rooms[name]
	if not room then
		room = { seq = 0, messages = {}, users = {} }
		store.rooms[name] = room
	end
	return room
end

local function storePush(store, room, message)
	room.seq = room.seq + 1
	message.seq = room.seq
	message.ts = store.clock()
	room.messages[#room.messages + 1] = message
	if #room.messages > store.history then table.remove(room.messages, 1) end
	return message
end

local function storeTouch(store, room, who)
	local t = store.clock()
	for uid, u in pairs(room.users) do
		if t - u.seen > store.presence and not u.pinned then
			room.users[uid] = nil
			storePush(store, room, { kind = "leave", uid = uid, name = u.name, text = "" })
		end
	end
	local u = room.users[who.uid]
	if not u then
		room.users[who.uid] = { name = who.name, seen = t }
		storePush(store, room, { kind = "join", uid = who.uid, name = who.name, text = "" })
	else
		u.seen = t
		if who.name ~= u.name then
			local old = u.name
			u.name = who.name
			storePush(store, room, { kind = "rename", uid = who.uid, name = who.name, text = old })
		end
	end
end

local function storeAnswer(store, room, since)
	since = tonumber(since) or -1
	local reset = since > room.seq
	local out = {}
	if since < 0 or reset then
		local from = math.max(1, #room.messages - store.firstBatch + 1)
		for i = from, #room.messages do out[#out + 1] = room.messages[i] end
	else
		for _, m in ipairs(room.messages) do
			if m.seq > since then out[#out + 1] = m end
		end
	end
	local online = {}
	for uid, u in pairs(room.users) do online[#online + 1] = { uid = uid, name = u.name } end
	table.sort(online, function(a, b) return a.name < b.name end)
	return { seq = room.seq, reset = reset or nil, messages = out, online = online }
end

local sharedStore = nil

function Chat.Memory(store)
	if store == nil then
		sharedStore = sharedStore or Chat.NewStore()
		store = sharedStore
	end
	local transport = { Kind = "memory", Store = store, Interval = 0.4, Wait = 0 }
	function transport:Poll(room, since, who)
		local r = storeRoom(store, room)
		storeTouch(store, r, who)
		return true, storeAnswer(store, r, since)
	end
	function transport:Send(room, who, text, isMe)
		local r = storeRoom(store, room)
		storeTouch(store, r, who)
		local m = storePush(store, r, { kind = isMe and "me" or "chat", uid = who.uid, name = who.name, text = text })
		return true, m.seq
	end
	return transport
end

local function hasWord(text, word)
	local spaced = " " .. string.gsub(string.lower(text), "[^%a]", " ") .. " "
	return string.find(spaced, " " .. word .. " ", 1, true) ~= nil
end

function Chat.Demo()
	local store = Chat.NewStore()
	local transport = Chat.Memory(store)
	transport.Kind = "demo"
	local botUid, botName = "aural-bot", "Aural Bot"
	local greeted = {}
	local basePoll, baseSend = transport.Poll, transport.Send

	local function say(room, text)
		storePush(store, storeRoom(store, room), { kind = "chat", uid = botUid, name = botName, text = text })
	end

	function transport:Poll(room, since, who, wait)
		local r = storeRoom(store, room)
		r.users[botUid] = { name = botName, seen = store.clock(), pinned = true }
		if not greeted[room] then
			greeted[room] = true
			say(room, "Hi! This is demo mode: nobody else can see this chat. Give AddChat a Server to talk to other players.")
		end
		return basePoll(self, room, since, who, wait)
	end

	function transport:Send(room, who, text, isMe)
		local ok, seq = baseSend(self, room, who, text, isMe)
		if ok and not isMe then
			local reply = nil
			if hasWord(text, "hello") or hasWord(text, "hi") or hasWord(text, "hey") then
				reply = "Hello, " .. who.name .. "!"
			elseif hasWord(text, "help") then
				reply = "Type /help to see the chat commands."
			elseif hasWord(text, "ping") then
				reply = "pong"
			end
			if reply then task.delay(0.8, function() say(room, reply) end) end
		end
		return ok, seq
	end
	return transport
end

local PAD, GAP = 12, 3
local BODY_SIZE, NAME_SIZE, TIME_SIZE = 12, 11, 10
local ENTRY_H = 26

local STATUS = {
	connecting = { "Connecting...", "Warning" },
	connected = { "Connected", "Success" },
	demo = { "Demo mode", "Accent" },
	retrying = { "Retrying...", "Warning" },
	offline = { "Unavailable", "Danger" },
	stopped = { "Disconnected", "TextPlaceholder" },
}

local function measure(text, size, font, maxW)
	local ok, b = pcall(function()
		return TextService:GetTextSize(text, size, font, Vector2.new(maxW, 10000))
	end)
	local w, h
	if ok and b then
		w, h = b.X, b.Y
	else
		w, h = #text * size * 0.56, size
	end
	if w > maxW then -- the measurement did not wrap: wrap by width
		local lines = math.ceil(w / maxW)
		w = maxW
		h = math.max(h, lines * (size + 2))
	end
	return math.ceil(w), math.ceil(h)
end

function Window:AddChat(target, options)
	options = options or {}
	local window = self
	local theme = self.Theme

	local page, tab
	if type(target) == "table" and target.AddPage then
		tab = target
		page = tab.Pages[1] or tab:AddPage({ Name = tab.Name })
	elseif type(target) == "table" and target.AddSection and target.Tab then
		page = target
		tab = page.Tab
	else
		error("AddChat needs a tab or a page", 2)
	end

	local transport = options.Transport
	if transport == nil then
		if type(options.Server) == "string" and options.Server ~= "" then
			local okT, made = pcall(Chat.Relay, options.Server, { Key = options.Key, Wait = options.Wait, Request = options.Request })
			if okT then
				transport = made
			else
				debugLog("chat: " .. tostring(made))
				transport = {
					Kind = "invalid", Interval = 1, Wait = 0,
					Poll = function() return false, "bad server address", "fatal" end,
					Send = function() return false, "bad server address", "fatal" end,
				}
			end
		else
			transport = Chat.Demo()
		end
	end
	if type(transport) ~= "table" or type(transport.Poll) ~= "function" or type(transport.Send) ~= "function" then
		error("AddChat: Transport needs Poll and Send functions", 2)
	end

	local rooms = {}
	local function addRoom(name, key)
		name = cleanText(tostring(name or key or ""), 24)
		key = cleanRoom(tostring(key or ""))
		if name == "" or not key then return end
		for _, r in ipairs(rooms) do
			if r.Name == name then return end
		end
		rooms[#rooms + 1] = { Name = name, Key = key }
	end
	if type(options.Rooms) == "table" then
		for _, r in ipairs(options.Rooms) do
			if type(r) == "string" then
				addRoom(r, r)
			elseif type(r) == "table" then
				addRoom(r.Name or r.Key, r.Key or r.Name)
			end
		end
	end
	if #rooms == 0 then
		addRoom("Global", "aural:global")
		addRoom("Configs", "aural:configs")
		addRoom("This game", "aural:game:" .. tostring(game.PlaceId))
		local okJ, job = pcall(function() return game.JobId end)
		if okJ and type(job) == "string" and job ~= "" then addRoom("This server", "aural:server:" .. job) end
	end
	local allowCustom = options.Custom ~= false
	local CUSTOM = "Custom"
	local CONFIGS_ROOM = "aural:configs" -- configs only room: no text, only shared configs (the server enforces it too)

	local player = Players.LocalPlayer
	local function playerField(field)
		local okF, v = pcall(function() return player[field] end)
		if okF then return v end
		return nil
	end
	local uid = cleanUid(options.UserId)
	if uid == "" then uid = cleanUid(playerField("UserId")) end
	if uid == "" then uid = "g" .. tostring(math.random(100000, 999999)) end
	local robloxName = cleanText(tostring(playerField("DisplayName") or ""), NAME_MAX)
	if robloxName == "" then robloxName = cleanText(tostring(playerField("Name") or ""), NAME_MAX) end
	if robloxName == "" then robloxName = "Player" end
	local userName = cleanText(tostring(playerField("Name") or ""), NAME_MAX)
	local myName = cleanText(tostring(options.Nickname or ""), NAME_MAX)
	if myName == "" then myName = robloxName end
	local function who() return { uid = uid, name = myName } end
	local clock = options.Clock or os.clock

	local state: any = {
		alive = true, gen = 0, pollId = 0, since = -1, failures = 0, status = "connecting", detail = nil,
		joined = false, notice = false, notify = options.Notify ~= false, unread = 0,
		lastToast = -100, lastSlow = -100, roomName = rooms[1].Name, roomKey = rooms[1].Key,
		reported = nil, belowCount = 0, roomGen = 0, inflight = false, knownCount = 0,
		tokens = 4, tokenAt = clock(), lastText = nil, lastTextAt = -100,
	}
	if options.Room ~= nil then
		for _, r in ipairs(rooms) do
			if r.Name == options.Room or r.Key == options.Room then
				state.roomName, state.roomKey = r.Name, r.Key
			end
		end
	end
	local records, pending, skipSeq, known, muted = {}, {}, {}, {}, {}
	local online, onlineSig = {}, ""
	local canvasH, nextOrder = 0, 0
	local lastChat = nil
	local maxMessages = clamp(tonumber(options.MaxMessages) or 120, 20, 300)

	local chat: any = {
		Window = window, Transport = transport,
		MessageReceived = Signal.new(), StatusChanged = Signal.new(), RoomChanged = Signal.new(),
	}
	local conns = {}

	local function isDark()
		local c = theme.Card
		return (0.299 * c.R + 0.587 * c.G + 0.114 * c.B) < 0.6
	end
	local function nameColor(id)
		local h = 7
		id = tostring(id)
		for i = 1, #id do h = (h * 31 + string.byte(id, i)) % 2147483629 end
		local hue = (h * 0.6180339887498949) % 1
		if isDark() then return Color3.fromHSV(hue, 0.42, 1) end
		return Color3.fromHSV(hue, 0.62, 0.6)
	end
	local function bubbleColor(rec)
		if rec.own then return mixColor(theme.Card, theme.Accent, 0.34) end
		if rec.mention then return mixColor(theme.Control, theme.Warning, 0.2) end
		return theme.Control
	end

	local chatSection = page:AddSection({ Title = options.Title or "Chat", Side = "Left" })
	local listH = clamp(tonumber(options.Height) or 292, 160, 420)
	local listRow = chatSection:_addRow("Messages", "chat messages")
	listRow.ManualLabel = true
	listRow.Label.Visible = false
	listRow.Frame.Size = UDim2.new(1, 0, 0, listH)

	local list = noTheme(create("ScrollingFrame", {
		Name = "Messages", BackgroundTransparency = 1, BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 6), Size = UDim2.new(1, 0, 1, -12),
		CanvasSize = UDim2.fromOffset(0, 0), ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.AccentBar, ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y, VerticalScrollBarInset = Enum.ScrollBarInset.None,
		ElasticBehavior = Enum.ElasticBehavior.Never, Parent = listRow.Frame,
	}))
	padding(list, PAD, PAD, 0, 0)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, GAP), Parent = list })

	local emptyLabel = create("TextLabel", {
		Name = "Empty", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = theme.Font, TextSize = 11,
		TextColor3 = theme.TextPlaceholder, Text = "Connecting...", ZIndex = 2, Parent = listRow.Frame,
	})
	local newPill = create("TextButton", {
		Name = "NewMessages", AutoButtonColor = false, BorderSizePixel = 0, BackgroundColor3 = theme.AccentBar,
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.fromOffset(112, 22),
		Font = theme.FontBold, TextSize = 11, TextColor3 = theme.Knob, Text = "New messages", Visible = false,
		ZIndex = 5, Parent = listRow.Frame,
	})
	corner(newPill, "full")

	local function areaW()
		local w = list.AbsoluteSize.X
		if w < 120 then
			local rootW = window.Root.Size.X.Offset
			if rootW <= 0 then rootW = L.RootW end
			w = math.floor((rootW - L.BodyX - L.BodyRight - 22) / 2)
		end
		return w - PAD * 2 - 6
	end
	local function viewH()
		local h = list.AbsoluteSize.Y
		if h < 50 then h = listH - 12 end
		return h
	end
	local function maxScroll() return math.max(0, canvasH - viewH()) end
	local function atBottom() return list.CanvasPosition.Y >= maxScroll() - 24 end
	local function hidePill()
		state.belowCount = 0
		newPill.Visible = false
	end
	local function scrollToBottom()
		list.CanvasPosition = Vector2.new(0, maxScroll())
		task.defer(function()
			if list.Parent then list.CanvasPosition = Vector2.new(0, maxScroll()) end
		end)
		hidePill()
	end
	local function relayout()
		local total, n = 0, 0
		for _, r in ipairs(records) do
			if r.Shown then
				total = total + r.Height
				n = n + 1
			end
		end
		if n > 1 then total = total + GAP * (n - 1) end
		canvasH = total + 8
		list.CanvasSize = UDim2.fromOffset(0, canvasH)
		emptyLabel.Visible = n == 0
	end
	table.insert(conns, list:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		if state.belowCount > 0 and atBottom() then hidePill() end
	end))
	newPill.MouseButton1Click:Connect(scrollToBottom)

	local inputRow = chatSection:_addRow("Message", "message input")
	inputRow.ManualLabel = true
	inputRow.Label.Visible = false
	inputRow.Frame.Size = UDim2.new(1, 0, 0, 46)
	local box = create("TextBox", {
		Name = "Input", BackgroundColor3 = theme.Control, BorderSizePixel = 0,
		Position = UDim2.fromOffset(PAD, 9), Size = UDim2.new(1, -(PAD * 2 + 28 + 8), 0, 28),
		Font = theme.Font, TextSize = 12, TextColor3 = theme.TextDropdown,
		PlaceholderText = options.Placeholder or "Message...", PlaceholderColor3 = theme.TextPlaceholder,
		Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, Parent = inputRow.Frame,
	})
	pcall(function() box.MaxLength = TEXT_MAX end)
	corner(box, theme.ControlRadius + 1)
	local boxPad = padding(box, 10, 10, 0, 0)
	local outline = stroke(box, theme.AccentBar, 1, 1)
	local counter = create("TextLabel", {
		Name = "Counter", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -(PAD + 28 + 8 + 8), 0.5, 0), Size = UDim2.fromOffset(40, 14),
		Font = theme.Font, TextSize = 10, TextColor3 = theme.TextPlaceholder, TextXAlignment = Enum.TextXAlignment.Right,
		Text = "", Visible = false, ZIndex = 3, Parent = inputRow.Frame,
	})
	local sendButton = create("TextButton", {
		Name = "Send", AutoButtonColor = false, Text = "", BorderSizePixel = 0, BackgroundColor3 = theme.AccentBar,
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -PAD, 0.5, 0), Size = UDim2.fromOffset(28, 28),
		Parent = inputRow.Frame,
	})
	corner(sendButton, theme.ControlRadius + 1)
	local sendIcon = makeIcon(sendButton, "send", 14, theme.Knob, 2.2)
	sendIcon.Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	sendIcon.Frame.Position = UDim2.fromScale(0.5, 0.5)

	local function timeText(ts)
		if type(ts) ~= "number" or ts <= 0 or ts > 4e9 then ts = os.time() end
		return safeDate("%H:%M", ts)
	end

	local openUserMenu -- forward
	local loadSharedConfig -- forward

	local function buildItem(def)
		local rec = {
			kind = def.kind, uid = def.uid, name = def.name, text = def.text, own = def.own == true,
			mention = def.mention == true, pending = def.pending == true, Shown = true, ts = def.ts,
		}
		local W = areaW()
		nextOrder = nextOrder + 1
		local frame = create("Frame", {
			Name = "Msg", BackgroundTransparency = 1, BorderSizePixel = 0, LayoutOrder = nextOrder, Parent = list,
		})
		rec.Frame = frame

		if def.kind == "system" or def.kind == "me" then
			local line = def.text
			if def.kind == "me" then line = "* " .. def.name .. " " .. def.text end
			local _, th = measure(line, 11, theme.Font, W - 16)
			rec.Height = th + 10
			frame.Size = UDim2.new(1, 0, 0, rec.Height)
			local label = create("TextLabel", {
				Name = "Line", BackgroundTransparency = 1, Position = UDim2.fromOffset(8, 5), Size = UDim2.new(1, -16, 0, th),
				Font = theme.Font, TextSize = 11, TextWrapped = true, Text = line, Parent = frame,
			})
			function rec.restyle()
				if def.kind == "me" then
					label.TextColor3 = nameColor(rec.uid)
				else
					label.TextColor3 = theme.TextPlaceholder
				end
			end
			rec.restyle()
			return rec
		end

		local cfgCode, cfgTitle
		local invitePlace, inviteJob
		if def.kind == "chat" then
			cfgCode, cfgTitle = string.match(def.text or "", "^%[config:(%w+)%]%s*(.*)$")
			invitePlace, inviteJob = string.match(def.text or "", "^%[serverinvite:(%d+):([%w%-]+)%]$")
		end
		local shownText = def.text
		if cfgCode then shownText = "Shared config: " .. ((cfgTitle and cfgTitle ~= "") and cfgTitle or cfgCode) end
		if invitePlace then shownText = "Roblox Server Invite\nPlace ID: " .. invitePlace .. "\nJoin this exact server" end
		local maxBW = clamp(math.floor(W * 0.82), 120, 300)
		local tw, th = measure(shownText, BODY_SIZE, theme.Font, maxBW - 20)
		local bw, bh = tw + 22, th + 12
		if cfgCode then bw, bh = math.max(bw, 92), bh + 28 end
		if invitePlace then bw, bh = math.max(bw, 120), bh + 30 end
		local top = def.grouped and 0 or 6
		local headerH = def.grouped and 0 or 15
		rec.Height = top + headerH + bh
		frame.Size = UDim2.new(1, 0, 0, rec.Height)

		local nameButton, timeLabel
		if not def.grouped then
			if rec.own then
				timeLabel = create("TextLabel", {
					Name = "Time", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, -2, 0, top), Size = UDim2.fromOffset(80, 14), Font = theme.Font,
					TextSize = TIME_SIZE, TextXAlignment = Enum.TextXAlignment.Right, Text = timeText(def.ts), Parent = frame,
				})
			else
				local nameW = math.floor(math.max(20, math.min(textWidth(def.name, NAME_SIZE, theme.FontBold) + 4, W - 70)))
				nameButton = create("TextButton", {
					Name = "Name", AutoButtonColor = false, BackgroundTransparency = 1, Position = UDim2.fromOffset(2, top),
					Size = UDim2.fromOffset(nameW, 14), Font = theme.FontBold, TextSize = NAME_SIZE,
					TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, Text = def.name,
					Parent = frame,
				})
				timeLabel = create("TextLabel", {
					Name = "Time", BackgroundTransparency = 1, Position = UDim2.fromOffset(2 + nameW + 6, top),
					Size = UDim2.fromOffset(50, 14), Font = theme.Font, TextSize = TIME_SIZE,
					TextXAlignment = Enum.TextXAlignment.Left, Text = timeText(def.ts), Parent = frame,
				})
				nameButton.MouseButton1Click:Connect(function()
					if openUserMenu then openUserMenu(nameButton, rec.uid, rec.name) end
				end)
			end
		end
		local bubble = create("Frame", {
			Name = "Bubble", BorderSizePixel = 0, Size = UDim2.fromOffset(bw, bh), Parent = frame,
		})
		if rec.own then
			bubble.AnchorPoint = Vector2.new(1, 0)
			bubble.Position = UDim2.new(1, 0, 0, top + headerH)
		else
			bubble.Position = UDim2.fromOffset(0, top + headerH)
		end
		corner(bubble, 9)
		local body = create("TextLabel", {
			Name = "Text", BackgroundTransparency = 1, Position = UDim2.fromOffset(11, 6), Size = UDim2.fromOffset(tw + 2, th),
			Font = theme.Font, TextSize = BODY_SIZE, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top, Text = shownText, Parent = bubble,
		})
		local loadButton
		local inviteButton
		if cfgCode then
			loadButton = create("TextButton", {
				Name = "Load", AutoButtonColor = false, BorderSizePixel = 0, Position = UDim2.fromOffset(11, th + 10),
				Size = UDim2.fromOffset(70, 22), Font = theme.FontBold, TextSize = 11, Text = "Load", Parent = bubble,
			})
			corner(loadButton, theme.ControlRadius)
			loadButton.MouseButton1Click:Connect(function()
				if loadSharedConfig then loadSharedConfig(cfgCode, rec.name) end
			end)
		elseif invitePlace then
			inviteButton = create("TextButton", {
				Name = "JoinServer", AutoButtonColor = false, BorderSizePixel = 0, Position = UDim2.fromOffset(11, th + 10),
				Size = UDim2.fromOffset(98, 22), Font = theme.FontBold, TextSize = 11, Text = "Join Server", Parent = bubble,
			})
			corner(inviteButton, theme.ControlRadius)
			inviteButton.MouseButton1Click:Connect(function()
				local placeId = tonumber(invitePlace)
				local jobId = tostring(inviteJob or "")
				if not placeId or placeId <= 0 or jobId == "" or string.lower(jobId) == "nil" then
					chat.AddSystemMessage("This invite is missing a valid server ID. Ask them to type /server again in a live Roblox server.")
					return
				end
				local ok, err = pcall(function()
					game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, jobId, Players.LocalPlayer)
				end)
				if not ok then
					chat.AddSystemMessage("Could not join that server: " .. cleanText(tostring(err), 100))
				end
			end)
		end
		function rec.restyle()
			bubble.BackgroundColor3 = bubbleColor(rec)
			body.TextColor3 = rec.own and theme.TextStrong or theme.Text
			body.TextTransparency = rec.pending and 0.45 or 0
			if loadButton then
				loadButton.BackgroundColor3 = theme.AccentBar
				loadButton.TextColor3 = theme.Knob
			end
			if inviteButton then
				inviteButton.BackgroundColor3 = theme.AccentBar
				inviteButton.TextColor3 = theme.Knob
			end
			if timeLabel then timeLabel.TextColor3 = theme.TextPlaceholder end
			if nameButton then nameButton.TextColor3 = nameColor(rec.uid) end
		end
		rec.restyle()
		return rec
	end

	local function addItem(def)
		local wasBottom = atBottom()
		local rec = buildItem(def)
		if def.hidden then
			rec.Shown = false
			rec.Frame.Visible = false
		end
		records[#records + 1] = rec
		while #records > maxMessages do
			local old = table.remove(records, 1)
			old.Frame:Destroy()
		end
		relayout()
		if def.hidden then return rec end
		if wasBottom or def.own then
			scrollToBottom()
		elseif def.kind ~= "system" then
			state.belowCount = state.belowCount + 1
			newPill.Visible = true
		end
		return rec
	end

	local function systemLine(text)
		lastChat = nil
		return addItem({ kind = "system", text = cleanText(text, 240) })
	end
	chat.AddSystemMessage = function(_, text) return systemLine(tostring(text)) end

	local function addMessage(m, own, pendingFlag)
		local grouped = false
		if m.kind == "chat" and lastChat and lastChat.uid == m.uid and lastChat.own == own then
			local a, b = tonumber(lastChat.ts) or 0, tonumber(m.ts) or 0
			grouped = math.abs(b - a) < 90
		end
		local rec = addItem({
			kind = m.kind, uid = m.uid, name = m.name, text = m.text, ts = m.ts, own = own,
			mention = m.mention, pending = pendingFlag, grouped = grouped, hidden = muted[m.uid] ~= nil and not own,
		})
		if m.kind == "chat" then
			lastChat = rec
		else
			lastChat = nil
		end
		return rec
	end

	local badge = create("Frame", {
		Name = "ChatBadge", BackgroundColor3 = theme.AccentBar, BorderSizePixel = 0, AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(20, 16), Visible = false, ZIndex = 4, Parent = tab.Button,
	})
	corner(badge, "full")
	local badgeText = create("TextLabel", {
		Name = "Count", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = theme.FontBold, TextSize = 10,
		TextColor3 = theme.Knob, Text = "", ZIndex = 5, Parent = badge,
	})
	local function updateBadge()
		if state.unread > 0 then
			local text = state.unread > 99 and "99+" or tostring(state.unread)
			badgeText.Text = text
			badge.Size = UDim2.fromOffset(math.max(18, math.ceil(textWidth(text, 10, theme.FontBold) + 10)), 16)
			badge.Visible = true
		else
			badge.Visible = false
		end
	end
	local function viewing()
		return window._open and window.ActiveTab == tab and tab.ActivePage == page
	end

	local statusStat, roomDropdown, customBox, nickBox -- controls (below)
	local function refreshStatus()
		local entry = STATUS[state.status] or STATUS.connecting
		if statusStat then statusStat:SetValue(entry[1], theme[entry[2]]) end
		if #records == 0 then
			if state.status == "connected" or state.status == "demo" then
				emptyLabel.Text = "No messages yet. Say hi!"
			elseif state.status == "offline" then
				emptyLabel.Text = "Chat is unavailable"
			elseif state.status == "stopped" then
				emptyLabel.Text = "Disconnected"
			else
				emptyLabel.Text = "Connecting..."
			end
		end
	end
	local function setStatus(status, detail)
		if state.status == status and state.detail == detail then return end
		state.status, state.detail = status, detail
		refreshStatus()
		chat.StatusChanged:Fire(status, detail)
	end

	local roomSection = page:AddSection({ Title = "Room", Side = "Right" })
	local onlineSection = page:AddSection({ Title = "Online", Side = "Right" })
	local onlineH = clamp(tonumber(options.OnlineHeight) or 118, 70, 220)
	local onlineRow = onlineSection:_addRow("Online users", "online users people")
	onlineRow.ManualLabel = true
	onlineRow.Label.Visible = false
	onlineRow.Frame.Size = UDim2.new(1, 0, 0, onlineH)
	local onlineFrame = noTheme(create("ScrollingFrame", {
		Name = "Users", BackgroundTransparency = 1, BorderSizePixel = 0, Position = UDim2.fromOffset(0, 6),
		Size = UDim2.new(1, 0, 1, -12), CanvasSize = UDim2.fromOffset(0, 0), ScrollBarThickness = 3,
		ScrollBarImageColor3 = theme.AccentBar, ScrollBarImageTransparency = 0.35,
		ScrollingDirection = Enum.ScrollingDirection.Y, VerticalScrollBarInset = Enum.ScrollBarInset.None,
		ElasticBehavior = Enum.ElasticBehavior.Never, Parent = onlineRow.Frame,
	}))
	padding(onlineFrame, 6, 6, 0, 0)
	create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = onlineFrame })
	local onlineEmpty = create("TextLabel", {
		Name = "Empty", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Font = theme.Font, TextSize = 11,
		TextColor3 = theme.TextPlaceholder, Text = "Nobody here yet", ZIndex = 2, Parent = onlineRow.Frame,
	})
	local entryViews = {}

	local function restyleEntries()
		for _, e in ipairs(entryViews) do
			e.dot.BackgroundColor3 = nameColor(e.uid)
			e.label.TextColor3 = e.muted and theme.TextPlaceholder or theme.Text
			e.tag.TextColor3 = theme.TextPlaceholder
			e.button.BackgroundColor3 = theme.MenuHover
		end
		onlineFrame.ScrollBarImageColor3 = theme.AccentBar
	end

	local function rebuildOnline()
		for _, e in ipairs(entryViews) do e.button:Destroy() end
		entryViews = {}
		local count = #online
		onlineSection:SetTitle(count > 0 and ("Online (" .. count .. ")") or "Online")
		onlineEmpty.Visible = count == 0
		local shown = math.min(count, 60)
		for i = 1, shown do
			local u = online[i]
			local isMe = u.uid == uid
			local isMuted = muted[u.uid] ~= nil
			local button = create("TextButton", {
				Name = "User", AutoButtonColor = false, Text = "", BorderSizePixel = 0, BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, ENTRY_H), LayoutOrder = i, Parent = onlineFrame,
			})
			corner(button, 6)
			local dot = create("Frame", {
				Name = "Dot", BorderSizePixel = 0, Position = UDim2.new(0, 8, 0.5, -4), Size = UDim2.fromOffset(8, 8), Parent = button,
			})
			corner(dot, "full")
			local label = create("TextLabel", {
				Name = "Name", BackgroundTransparency = 1, Position = UDim2.fromOffset(24, 0), Size = UDim2.new(1, -78, 1, 0),
				Font = theme.Font, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd, Text = u.name, Parent = button,
			})
			local tagText = isMe and "you" or (isMuted and "muted" or "")
			local tag = create("TextLabel", {
				Name = "Tag", BackgroundTransparency = 1, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 0),
				Size = UDim2.fromOffset(46, ENTRY_H), Font = theme.Font, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Right,
				Text = tagText, Parent = button,
			})
			entryViews[#entryViews + 1] = { uid = u.uid, button = button, dot = dot, label = label, tag = tag, muted = isMuted }
			button.MouseEnter:Connect(function() tween(button, 0.08, { BackgroundTransparency = 0 }) end)
			button.MouseLeave:Connect(function() tween(button, 0.08, { BackgroundTransparency = 1 }) end)
			button.MouseButton1Click:Connect(function()
				if not isMe and openUserMenu then openUserMenu(button, u.uid, u.name) end
			end)
		end
		onlineFrame.CanvasSize = UDim2.fromOffset(0, shown * ENTRY_H + 4)
		restyleEntries()
	end

	local function setOnline(list)
		local clean, sigParts = {}, {}
		for i = 1, math.min(#list, 100) do
			local u = list[i]
			if type(u) == "table" then
				local id = cleanUid(u.uid)
				if id ~= "" then
					local name = cleanText(u.name, NAME_MAX)
					if name == "" then name = "user" .. string.sub(id, -4) end
					clean[#clean + 1] = { uid = id, name = name }
					sigParts[#sigParts + 1] = id .. "=" .. name
					known[id] = name
				end
			end
		end
		for i, u in ipairs(clean) do -- you first, so you always see yourself in the list
			if u.uid == uid then
				table.remove(clean, i)
				table.insert(clean, 1, u)
				break
			end
		end
		local sig = table.concat(sigParts, "|") .. "#" .. #clean
		for id in pairs(muted) do sig = sig .. "!" .. id end
		if sig == onlineSig then return end
		onlineSig = sig
		online = clean
		rebuildOnline()
	end

	local function resolveUser(who_)
		if type(who_) ~= "string" then return nil end
		local needle = string.lower(tostring(who_))
		if needle == "" then return nil end
		if known[who_] then return who_, known[who_] end
		local found, foundName = nil, nil
		for id, name in pairs(known) do
			local lowered = string.lower(tostring(name))
			if lowered == needle then return id, name end
			if string.sub(lowered, 1, #needle) == needle and not found then found, foundName = id, name end
		end
		return found, foundName
	end

	function chat:Mute(who_)
		local id, name = resolveUser(who_)
		if not id then return false, "unknown user" end
		if id == uid then return false, "that is you" end
		if muted[id] then return true, name end
		muted[id] = name
		for _, r in ipairs(records) do
			if r.uid == id and not r.own and r.kind ~= "system" then
				r.Shown = false
				r.Frame.Visible = false
			end
		end
		relayout()
		onlineSig = ""
		rebuildOnline()
		return true, name
	end

	function chat:Unmute(who_)
		local id, name = resolveUser(who_)
		if not id or not muted[id] then return false, "not muted" end
		muted[id] = nil
		for _, r in ipairs(records) do
			if r.uid == id then
				r.Shown = true
				r.Frame.Visible = true
			end
		end
		relayout()
		onlineSig = ""
		rebuildOnline()
		return true, name
	end

	function chat:IsMuted(who_)
		local id = resolveUser(who_)
		return id ~= nil and muted[id] ~= nil
	end

	function chat:GetMuted()
		local out = {}
		for id, name in pairs(muted) do out[#out + 1] = { Uid = id, Name = name } end
		table.sort(out, function(a, b) return a.Name < b.Name end)
		return out
	end

	function chat:GetOnline()
		local out = {}
		for i, u in ipairs(online) do out[i] = { Uid = u.uid, Name = u.name } end
		return out
	end

	openUserMenu = function(anchor, id, name)
		local items = {
			{ Text = "Mention", Callback = function()
				local text = box.Text
				if text ~= "" and string.sub(text, -1) ~= " " then text = text .. " " end
				box.Text = text .. "@" .. name .. " "
				pcall(function() box:CaptureFocus() end)
			end },
		}
		if id ~= uid then
			if muted[id] then
				items[#items + 1] = { Text = "Unmute", Callback = function()
					local ok = chat:Unmute(id)
					if ok then systemLine("Unmuted " .. name .. ".") end
				end }
			else
				items[#items + 1] = { Text = "Mute", Color = theme.Danger, Callback = function()
					local ok = chat:Mute(id)
					if ok then systemLine("Muted " .. name .. ". Click their name to undo.") end
				end }
			end
		end
		window:_openMenu(anchor, items, { Width = 140, Align = "Left" })
	end

	local function mentionsMe(text)
		local lowered = string.lower(text)
		for _, n in ipairs({ myName, robloxName, userName }) do
			if #n >= 2 and string.find(lowered, "@" .. string.lower(n), 1, true) then return true end
		end
		return false
	end

	local function arrival(m, mention)
		if viewing() then return end
		state.unread = state.unread + 1
		updateBadge()
		if state.notify or mention then
			local title = mention and (m.name .. " mentioned you") or m.name
			local text = m.text
			if m.kind == "me" then text = "* " .. m.text end
			local function esc(s) return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")) end
			local shown = pcall(function()
				local tcs = game:GetService("TextChatService")
				local ch = tcs:FindFirstChild("TextChannels") and tcs.TextChannels:FindFirstChild("RBXGeneral")
				assert(ch)
				ch:DisplaySystemMessage('<font color="#8B7CFF">[Aural] ' .. esc(title) .. ':</font> ' .. esc(text))
			end)
			if not shown then
				shown = pcall(function()
					game:GetService("StarterGui"):SetCore("ChatMakeSystemMessage", {
						Text = "[Aural] " .. title .. ": " .. text, Color = Color3.fromRGB(139, 124, 255),
					})
				end)
			end
			if not shown and clock() - state.lastToast >= 2.5 then
				state.lastToast = clock()
				window:Notify({ Type = "info", Title = title, Text = text, Icon = "chat", Duration = 4 })
			end
		end
	end

	local function normalise(m)
		if type(m) ~= "table" or not KINDS[m.kind] then return nil end
		local id = cleanUid(m.uid)
		if id == "" then return nil end
		local out = {
			kind = m.kind, uid = id, seq = tonumber(m.seq),
			name = cleanText(m.name, NAME_MAX), text = cleanText(m.text, m.kind == "rename" and NAME_MAX or TEXT_MAX),
		}
		local ts = tonumber(m.ts)
		if ts and ts > 0 and ts < 4e9 then out.ts = ts end
		if out.name == "" then out.name = "user" .. string.sub(id, -4) end
		if (out.kind == "chat" or out.kind == "me") and out.text == "" then return nil end
		if known[id] == nil then
			state.knownCount = state.knownCount + 1
			if state.knownCount > 500 then -- a hostile server could invent endless users
				known, state.knownCount = {}, 1
				for mid, mname in pairs(muted) do known[mid] = mname end
			end
		end
		known[id] = out.name
		return out
	end

	local function confirmPending(entry, seq)
		entry.rec.pending = false
		entry.rec.seq = seq
		entry.rec.restyle()
	end

	local function matchPending(m)
		for i, entry in ipairs(pending) do
			if entry.text == m.text and entry.isMe == (m.kind == "me") then
				table.remove(pending, i)
				confirmPending(entry, m.seq)
				return true
			end
		end
		return false
	end

	local function handleMessage(m, initial)
		if m.uid == uid then
			if m.kind ~= "chat" and m.kind ~= "me" then return end
			if matchPending(m) then return end
			if m.seq and skipSeq[m.seq] then
				skipSeq[m.seq] = nil
				return
			end
			addMessage(m, true, false) -- sent from another copy of the script on this account
			return
		end
		if m.kind == "join" or m.kind == "leave" then
			if options.ShowJoins == true and not initial and not muted[m.uid] then
				systemLine(m.name .. (m.kind == "join" and " joined." or " left."))
			end
			return
		end
		if m.kind == "rename" then
			if not initial and not muted[m.uid] then systemLine(m.text .. " is now " .. m.name .. ".") end
			return
		end
		if muted[m.uid] then
			addMessage(m, false, false) -- kept (hidden) so unmuting brings it back
			return
		end
		local mention = m.kind == "chat" and mentionsMe(m.text) -- history is tinted too, it just never notifies
		m.mention = mention
		addMessage(m, false, false)
		if not initial then arrival(m, mention) end
		chat.MessageReceived:Fire({
			Uid = m.uid, Name = m.name, Text = m.text, Kind = m.kind, Time = m.ts, Mention = mention, Room = state.roomName,
			Initial = initial,
		})
	end

	local function announceJoin()
		if state.joined then return end
		state.joined = true
		systemLine("Joined " .. state.roomName .. ".")
		if not state.notice then
			state.notice = true
			if transport.Kind == "demo" then
				systemLine("Demo mode: nobody else is connected.")
			else
				systemLine("Everyone in this room can read what you send, and so can whoever runs the relay.")
				if transport.Secure == false then
					systemLine("This relay uses plain http, so messages are not encrypted on the way.")
				end
			end
		end
	end

	local function handleResult(res)
		local seq = tonumber(res.seq)
		local first = state.since < 0
		local reset = res.reset == true or (seq ~= nil and state.since >= 0 and seq < state.since)
		if reset and not first then
			skipSeq = {}
			systemLine("The chat server was restarted, so earlier messages are gone.")
		end
		announceJoin()
		local initial = first or reset
		local list = type(res.messages) == "table" and res.messages or {}
		local from = math.max(1, #list - BATCH_MAX + 1)
		local top = state.since
		if reset then top = -1 end
		for i = from, #list do
			local m = normalise(list[i])
			if m then
				if m.seq == nil or initial or m.seq > top then
					local okH, err = pcall(function()
						if initial and m.kind ~= "chat" and m.kind ~= "me" then return end
						handleMessage(m, initial)
					end)
					if not okH then debugLog("chat: could not show a message:", err) end
				end
				if m.seq and m.seq > top then top = m.seq end
			end
		end
		if seq then
			state.since = math.max(seq, top)
			if reset then state.since = seq end
		elseif top > state.since then
			state.since = top
		end
		if type(res.online) == "table" then setOnline(res.online) end
	end

	local function alive()
		return state.alive and window.Gui ~= nil and window.Gui.Parent ~= nil
	end

	local pollOnce, startLoop
	local function schedule(delay, gen)
		task.delay(delay, function()
			if gen ~= state.gen or not alive() then return end
			pollOnce(gen)
		end)
	end

	local function backoff(failures)
		local delay = math.min(30, 1.5 * (2 ^ (failures - 1)))
		return delay * (0.85 + 0.3 * math.random())
	end

	pollOnce = function(gen)
		state.pollId = state.pollId + 1
		local id = state.pollId
		local waitSeconds = tonumber(transport.Wait) or 0
		state.inflight = true
		if waitSeconds > 0 then
			task.delay(waitSeconds + 20, function()
				if gen == state.gen and id == state.pollId and state.inflight and alive() then
					debugLog("chat: a request got stuck, starting again")
					state.failures = state.failures + 1
					setStatus("retrying", "no answer")
					startLoop(backoff(state.failures))
				end
			end)
		end
		local called, ok, res, code = pcall(transport.Poll, transport, state.roomKey, state.since, who(), waitSeconds)
		if id == state.pollId then state.inflight = false end
		if gen ~= state.gen or not alive() then return end
		if called and ok == true and type(res) == "table" then
			state.failures = 0
			state.reported = nil
			local handled, err = pcall(handleResult, res)
			if not handled then debugLog("chat: bad data from the server:", err) end
			setStatus(transport.Kind == "demo" and "demo" or "connected")
			schedule(clamp(tonumber(transport.Interval) or 0.3, 0.2, 5), gen)
			return
		end
		local reason = called and cleanText(tostring(res or "failed"), 60) or "error"
		if reason == "" then reason = "failed" end
		if code == "nohttp" or code == "fatal" then
			setStatus("offline", reason)
			if state.reported ~= reason then
				state.reported = reason
				if code == "nohttp" then
					systemLine("This executor has no HTTP request function, so chat cannot connect.")
				else
					systemLine("Chat cannot connect: " .. reason .. ".")
				end
			end
			return
		end
		state.failures = state.failures + 1
		setStatus("retrying", reason)
		if state.reported ~= reason then
			state.reported = reason
			systemLine("Cannot reach the chat server (" .. reason .. "). Trying again...")
		end
		schedule(backoff(state.failures), gen)
	end

	startLoop = function(delay)
		state.gen = state.gen + 1
		local gen = state.gen
		if delay and delay > 0 then
			schedule(delay, gen)
		else
			task.spawn(pollOnce, gen)
		end
	end

	local function failPending(entry, reason)
		for i, e in ipairs(pending) do
			if e == entry then
				table.remove(pending, i)
				break
			end
		end
		for i, r in ipairs(records) do
			if r == entry.rec then
				table.remove(records, i)
				break
			end
		end
		entry.rec.Frame:Destroy()
		if lastChat == entry.rec then lastChat = nil end
		relayout()
		if box.Text == "" then box.Text = entry.text end
		systemLine("Not sent: " .. reason .. ".")
	end

	function chat:Send(text, isMe)
		text = cleanText(text, TEXT_MAX)
		if text == "" then return false, "empty message" end
		if state.roomKey == CONFIGS_ROOM then return false, "configs only here, tap Share my config" end
		isMe = isMe == true
		if state.status ~= "connected" and state.status ~= "demo" then return false, "not connected" end
		local t = clock()
		if text == state.lastText and t - state.lastTextAt < 4 then return false, "duplicate message" end
		state.tokens = math.min(6, state.tokens + (t - state.tokenAt) / 0.5)
		state.tokenAt = t
		if state.tokens < 1 then return false, "slow down" end
		state.tokens = state.tokens - 1
		state.lastText, state.lastTextAt = text, t

		local rec = addMessage({ kind = isMe and "me" or "chat", uid = uid, name = myName, text = text, ts = os.time() }, true, true)
		local entry: any = { rec = rec, text = text, isMe = isMe, roomGen = state.roomGen }
		pending[#pending + 1] = entry
		local roomKey = state.roomKey
		task.spawn(function()
			local called, ok, res = pcall(transport.Send, transport, roomKey, who(), text, isMe)
			if entry.done or entry.roomGen ~= state.roomGen or not alive() then return end
			if called and ok == true then
				if not rec.pending then return end -- the poll already delivered it
				local seq = type(res) == "number" and res or (type(res) == "table" and tonumber(res.seq)) or nil
				for i, e in ipairs(pending) do
					if e == entry then
						table.remove(pending, i)
						break
					end
				end
				confirmPending(entry, seq)
				if seq then skipSeq[seq] = true end
			else
				local reason = called and cleanText(tostring(res or "failed"), 60) or "error"
				if reason == "" then reason = "failed" end
				failPending(entry, reason)
			end
		end)
		task.delay(25, function()
			if rec.pending and alive() then
				entry.done = true
				failPending(entry, "timed out")
			end
		end)
		return true
	end

	function chat:Clear()
		for _, r in ipairs(records) do r.Frame:Destroy() end
		records = {}
		lastChat = nil
		hidePill()
		relayout()
		refreshStatus()
	end

	function chat:ShareConfig(title)
		if type(transport.ShareConfig) ~= "function" then return false, "this chat server cannot share configs" end
		if state.status ~= "connected" then return false, "not connected" end
		if state.sharing then return false, "already sharing" end
		local okE, data = pcall(window.ExportConfig, window)
		if not okE or type(data) ~= "string" then return false, "could not read your config" end
		title = cleanText(tostring(title or ""), 40)
		if title == "" then return false, "name your config first" end
		state.sharing = true
		local roomKey = state.roomKey
		task.spawn(function()
			local called, ok, res = pcall(transport.ShareConfig, transport, roomKey, who(), title, data)
			state.sharing = false
			if not alive() then return end
			if not (called and ok == true) then
				local reason = called and cleanText(tostring(res or "failed"), 60) or "error"
				systemLine("Config not shared: " .. (reason ~= "" and reason or "failed") .. ".")
			else
				systemLine("Shared to Configs: " .. title .. (state.roomKey ~= CONFIGS_ROOM and " (open the Configs room to see it)." or "."))
			end
		end)
		return true
	end

	loadSharedConfig = function(code, fromName)
		if type(transport.GetConfig) ~= "function" then
			systemLine("This chat server cannot load configs.")
			return
		end
		if state.loadingConfig then return end
		state.loadingConfig = true
		task.spawn(function()
			local called, ok, res = pcall(transport.GetConfig, transport, code)
			state.loadingConfig = false
			if not alive() then return end
			if not (called and ok == true and type(res) == "table" and type(res.data) == "string") then
				local reason = (called and ok ~= true) and cleanText(tostring(res or "failed"), 60) or "failed"
				systemLine("Could not load that config: " .. reason .. ".")
				return
			end
			local okI, done, info = pcall(window.ImportConfig, window, res.data)
			local title = cleanText(tostring(res.title or code), 40)
			local by = cleanText(tostring(res.name or fromName or ""), NAME_MAX)
			if okI and done == true then
				local count = type(info) == "table" and tonumber(info.Applied) or nil
				systemLine("Loaded config " .. title .. (by ~= "" and (" by " .. by) or "") .. (count and (" (" .. count .. " settings)") or "") .. ".")
			else
				systemLine("Could not load that config: " .. cleanText(tostring(okI and info or done), 80) .. ".")
			end
		end)
	end
	chat.LoadConfig = function(_, code) loadSharedConfig(cleanText(tostring(code or ""), 12)) end

	local askConfigName
	do
		local panel = create("Frame", {
			Name = "ConfigName", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Visible = false,
			ZIndex = 4, Parent = inputRow.Frame,
		})
		local nameBox = create("TextBox", {
			Name = "ConfigNameInput", BackgroundColor3 = theme.Control, BorderSizePixel = 0,
			Position = UDim2.fromOffset(PAD, 9), Size = UDim2.new(1, -(PAD * 2 + 56 + 6 + 28 + 6), 0, 28),
			Font = theme.Font, TextSize = 12, TextColor3 = theme.TextDropdown,
			PlaceholderText = "Config name", PlaceholderColor3 = theme.TextPlaceholder,
			Text = "", ClearTextOnFocus = false, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4, Parent = panel,
		})
		pcall(function() nameBox.MaxLength = 40 end)
		corner(nameBox, theme.ControlRadius + 1)
		padding(nameBox, 10, 10, 0, 0)
		stroke(nameBox, theme.AccentBar, 1, 0)
		local shareGo = create("TextButton", {
			Name = "ShareConfig", AutoButtonColor = false, Text = "Share", Font = theme.Font, TextSize = 12,
			TextColor3 = theme.Knob, BackgroundColor3 = theme.AccentBar, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -(PAD + 28 + 6), 0.5, 0), Size = UDim2.fromOffset(56, 28),
			ZIndex = 4, Parent = panel,
		})
		corner(shareGo, theme.ControlRadius + 1)
		local cancel = create("TextButton", {
			Name = "Cancel", AutoButtonColor = false, Text = "X", Font = theme.Font, TextSize = 12,
			TextColor3 = theme.TextDropdown, BackgroundColor3 = theme.Control, BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -PAD, 0.5, 0), Size = UDim2.fromOffset(28, 28),
			ZIndex = 4, Parent = panel,
		})
		corner(cancel, theme.ControlRadius + 1)
		local function close()
			panel.Visible = false
			box.Visible, sendButton.Visible = true, true
		end
		local function go()
			local name = cleanText(nameBox.Text, 40)
			if name == "" then
				systemLine("Name your config first.")
				return
			end
			local ok, why = chat:ShareConfig(name)
			if ok then
				nameBox.Text = ""
				close()
			else
				systemLine("Config not shared: " .. tostring(why) .. ".")
			end
		end
		shareGo.MouseButton1Click:Connect(go)
		cancel.MouseButton1Click:Connect(close)
		nameBox.FocusLost:Connect(function(enter) if enter and panel.Visible then go() end end)
		askConfigName = function()
			box.Visible, sendButton.Visible, counter.Visible = false, false, false
			panel.Visible = true
			pcall(function() nameBox:CaptureFocus() end)
		end
	end

	local function slowDown(why)
		if clock() - state.lastSlow >= 2 then
			state.lastSlow = clock()
			systemLine(why == "slow down" and "Slow down a little." or ("Not sent: " .. why .. "."))
		end
	end

	local function runCommand(line)
		local name, arg = string.match(line, "^/(%S+)%s*(.-)$")
		name = string.lower(name or "")
		if name == "help" then
			systemLine("Commands: /me <action>, /share [config name], /server, /who, /mute <name>, /unmute <name>, /clear, /help")
		elseif name == "server" then
			local placeId = tonumber(game.PlaceId)
			local jobId = game.JobId
			if not placeId or placeId <= 0 or type(jobId) ~= "string" or jobId == "" or string.lower(jobId) == "nil" then
				systemLine("Could not read this server's ID. Run /server inside a live Roblox game server, not Studio or a test session.")
			else
				local invite = "[serverinvite:" .. tostring(placeId) .. ":" .. jobId .. "]"
				local ok, why = chat:Send(invite)
				if not ok then
					slowDown(why)
					return false
				end
			end
		elseif name == "share" then
			if cleanText(arg, 40) == "" then
				askConfigName()
			else
				local ok, why = chat:ShareConfig(arg)
				if not ok then systemLine("Config not shared: " .. tostring(why) .. ".") end
			end
		elseif name == "clear" then
			chat:Clear()
		elseif name == "who" then
			if #online == 0 then
				systemLine("Nobody else is here.")
			else
				local names = {}
				for i, u in ipairs(online) do
					if i > 12 then
						names[#names + 1] = "+" .. (#online - 12) .. " more"
						break
					end
					names[#names + 1] = u.name
				end
				systemLine("Online (" .. #online .. "): " .. table.concat(names, ", "))
			end
		elseif name == "me" then
			if arg == "" then
				systemLine("Usage: /me <action>")
			else
				local ok, why = chat:Send(arg, true)
				if not ok then
					slowDown(why)
					return false
				end
			end
		elseif name == "mute" or name == "unmute" then
			if arg == "" then
				systemLine("Usage: /" .. name .. " <name>")
			else
				local ok, result
				if name == "mute" then ok, result = chat:Mute(arg) else ok, result = chat:Unmute(arg) end
				if ok then
					systemLine((name == "mute" and "Muted " or "Unmuted ") .. result .. ".")
				else
					systemLine("Cannot " .. name .. " that: " .. tostring(result) .. ".")
				end
			end
		else
			systemLine("Unknown command. Type /help.")
		end
		return true
	end

	local function submit(raw)
		local text = cleanText(raw, TEXT_MAX)
		if text == "" then return false end
		if string.sub(text, 1, 2) == "//" then
			text = string.sub(text, 2)
		elseif string.sub(text, 1, 1) == "/" then
			return runCommand(text)
		end
		local ok, why = chat:Send(text)
		if not ok then
			slowDown(why)
			return false
		end
		return true
	end
	chat.Submit = function(_, text) return submit(text) end

	local function updateCounter()
		local text = box.Text
		local n = utf8.len(text) or 0
		if n > TEXT_MAX then
			local cut = utf8.offset(text, TEXT_MAX + 1)
			if cut then box.Text = string.sub(text, 1, cut - 1) end
			return
		end
		if n >= 140 then
			counter.Text = n .. "/" .. TEXT_MAX
			counter.TextColor3 = n >= 190 and theme.Warning or theme.TextPlaceholder
			counter.Visible = true
			boxPad.PaddingRight = UDim.new(0, 46)
		else
			counter.Visible = false
			boxPad.PaddingRight = UDim.new(0, 10)
		end
	end
	box:GetPropertyChangedSignal("Text"):Connect(updateCounter)
	box.Focused:Connect(function() tween(outline, 0.12, { Transparency = 0 }) end)
	local function trySubmit()
		local text = box.Text
		box.Text = ""
		if submit(text) then return true end
		if box.Text == "" then box.Text = text end
		return false
	end
	box.FocusLost:Connect(function(enter)
		tween(outline, 0.12, { Transparency = 1 })
		if enter then
			local had = box.Text ~= ""
			trySubmit()
		end
	end)
	sendButton.MouseEnter:Connect(function() tween(sendButton, 0.1, { BackgroundColor3 = theme.FillTop }) end)
	sendButton.MouseLeave:Connect(function() tween(sendButton, 0.1, { BackgroundColor3 = theme.AccentBar }) end)
	sendButton.MouseButton1Down:Connect(function() tween(sendButton, 0.06, { BackgroundColor3 = theme.FillBottom }) end)
	sendButton.MouseButton1Up:Connect(function() tween(sendButton, 0.1, { BackgroundColor3 = theme.FillTop }) end)
	sendButton.MouseButton1Click:Connect(function()
		trySubmit()
	end)

	statusStat = roomSection:AddStat({ Name = "Status", Value = "Connecting..." })
	local roomNames = {}
	for _, r in ipairs(rooms) do roomNames[#roomNames + 1] = r.Name end
	if allowCustom then roomNames[#roomNames + 1] = CUSTOM end

	local function customKey(text)
		local word = string.lower(cleanText(tostring(text or ""), 32))
		word = string.gsub(word, "[^%w_%-]+", "-")
		word = string.gsub(word, "^%-+", "")
		word = string.gsub(word, "%-+$", "")
		if word == "" then return nil end
		return "aural:c:" .. word, word
	end

	local function applyRoomMode()
		box.PlaceholderText = state.roomKey == CONFIGS_ROOM and "Configs only - tap Share my config" or (options.Placeholder or "Message...")
	end
	applyRoomMode()

	local function joinKey(key, name, custom)
		if key == state.roomKey then return true end
		local stopped = state.status == "stopped"
		state.roomKey, state.roomName = key, name
		applyRoomMode()
		state.roomGen = state.roomGen + 1
		state.since, state.failures, state.joined, state.reported = -1, 0, false, nil
		skipSeq, pending = {}, {}
		chat:Clear()
		online = {}
		onlineSig = ""
		rebuildOnline()
		if roomDropdown then roomDropdown:Set(custom and CUSTOM or name, true) end
		if customBox then
			customBox:SetVisible(custom)
			if custom then customBox:Set(string.sub(key, 9), true) end
		end
		if stopped then
			state.gen = state.gen + 1
		else
			setStatus("connecting")
			startLoop()
		end
		chat.RoomChanged:Fire(name, key)
		return true
	end

	local function joinCustom(text)
		if not allowCustom then return false, "custom rooms are off" end
		local key, word = customKey(text)
		if not key then return false, "type a room word first" end
		return joinKey(key, "Custom: " .. word, true)
	end

	function chat:Join(room)
		for _, r in ipairs(rooms) do
			if r.Name == room or r.Key == room then return joinKey(r.Key, r.Name, false) end
		end
		return joinCustom(room)
	end

	function chat:GetRoom() return state.roomName, state.roomKey end

	roomDropdown = roomSection:AddDropdown({
		Name = "Room", Values = roomNames, Default = state.roomName, Save = false,
		Callback = function(value)
			if value == CUSTOM then
				customBox:SetVisible(true)
				joinCustom(customBox:Get())
			else
				customBox:SetVisible(false)
				chat:Join(value)
			end
		end,
	})
	customBox = roomSection:AddTextBox({
		Name = "Custom room", Placeholder = "any word", Width = 120, Save = false,
		Callback = function(text) joinCustom(text) end,
	})
	customBox:SetVisible(false)

	function chat:SetNickname(name)
		name = cleanText(tostring(name or ""), NAME_MAX)
		if name == "" then name = robloxName end
		if name == myName then return end
		myName = name
		if nickBox and nickBox:Get() ~= name then nickBox:Set(name, true) end
		systemLine("You are now known as " .. name .. ".")
	end
	function chat:GetNickname() return myName end
	nickBox = roomSection:AddTextBox({
		Name = "Nickname", Default = myName, Placeholder = robloxName, Width = 120, Save = false,
		Callback = function(text) chat:SetNickname(text) end,
	})
	roomSection:AddToggle({
		Name = "Notifications", Default = state.notify, Save = false,
		Callback = function(on) state.notify = on == true end,
	})

	local buttonRow = onlineSection:_addRow("Actions", "clear reconnect")
	buttonRow.ManualLabel = true
	buttonRow.Label.Visible = false
	local function halfButton(text, x, offset, onClick)
		local button = create("TextButton", {
			Name = "Action", AutoButtonColor = false, Text = text, Font = theme.Font, TextSize = 11,
			TextColor3 = theme.TextDropdown, BackgroundColor3 = theme.Control, BorderSizePixel = 0,
			Position = UDim2.new(x, offset, 0.5, -13), Size = UDim2.new(0.5, -PAD - 6, 0, 26), Parent = buttonRow.Frame,
		})
		corner(button, theme.ControlRadius)
		button.MouseEnter:Connect(function() tween(button, 0.1, { BackgroundColor3 = theme.ControlHover }) end)
		button.MouseLeave:Connect(function() tween(button, 0.1, { BackgroundColor3 = theme.Control }) end)
		button.MouseButton1Down:Connect(function() tween(button, 0.06, { BackgroundColor3 = theme.NavActive }) end)
		button.MouseButton1Up:Connect(function() tween(button, 0.1, { BackgroundColor3 = theme.ControlHover }) end)
		button.MouseButton1Click:Connect(onClick)
		return button
	end
	halfButton("Clear chat", 0, PAD, function() chat:Clear() end)
	halfButton("Reconnect", 0.5, 6, function() chat:Reconnect() end)
	local shareRow = onlineSection:_addRow("Share config", "share config")
	shareRow.ManualLabel = true
	shareRow.Label.Visible = false
	local shareButton = halfButton("Share my config", 0, PAD, function()
		askConfigName()
	end)
	shareButton.Parent = shareRow.Frame
	shareButton.Size = UDim2.new(1, -PAD * 2, 0, 26)

	function chat:Disconnect()
		state.gen = state.gen + 1
		setStatus("stopped")
	end
	function chat:Connect()
		if state.status ~= "stopped" and state.status ~= "offline" then return end
		state.failures = 0
		setStatus("connecting")
		startLoop()
	end
	function chat:Reconnect()
		state.failures = 0
		state.reported = nil
		setStatus("connecting")
		startLoop()
	end
	function chat:GetStatus() return state.status, state.detail end
	function chat:ScrollToBottom() scrollToBottom() end
	function chat:GetUnread() return state.unread end

	function chat:Destroy()
		if not state.alive then return end
		state.alive = false
		state.gen = state.gen + 1
		for _, c in ipairs(conns) do c:Disconnect() end
		conns = {}
		badge:Destroy()
		for _, section in ipairs({ chatSection, roomSection, onlineSection }) do
			for i, s in ipairs(page.Sections) do
				if s == section then
					table.remove(page.Sections, i)
					break
				end
			end
			section.Frame:Destroy()
		end
	end

	local function restyleAll()
		for _, r in ipairs(records) do r.restyle() end
		list.ScrollBarImageColor3 = theme.AccentBar
		restyleEntries()
		refreshStatus()
		updateCounter()
	end
	table.insert(conns, window.ThemeChanged:Connect(restyleAll))
	table.insert(conns, window.ViewChanged:Connect(function()
		if state.unread > 0 and viewing() then
			state.unread = 0
			updateBadge()
			scrollToBottom()
		end
	end))
	table.insert(window._destroyHooks, function() chat:Destroy() end)

	refreshStatus()
	relayout()
	if options.Autoconnect ~= false then
		startLoop()
	else
		state.gen = state.gen + 1
		setStatus("stopped")
	end
	return chat
end
end

return AuralV2
end)()


-- // Library (AuralV2 UI, replacing ZeroUI)
-- AuralV2 compatibility bridge: exposes the same API surface ZeroUI provided
-- so the feature code below doesn't need rewriting.
local Library = (function()
    local AV2 = AuralV2

    -- Shared state the feature code reads directly
    local lib = {
        Name       = "AuralV2",
        Version    = "2.6.0",
        Folder     = "Aural",
        Flags      = {},
        Elements   = {},
        Icons      = {
            Chevron  = "rbxassetid://117180161825809",
            Check    = "rbxassetid://93912665739148",
            Gear     = "rbxassetid://133220441796193",
            Search   = "rbxassetid://91945241943601",
            Cursor   = "rbxassetid://131481965346967",
            Shadow   = "rbxassetid://112971167999062",
            Timer    = "rbxassetid://135691454830657",
            Target   = "rbxassetid://87144352307029",
            Dribble  = "rbxassetid://103201682357056",
            Combos   = "rbxassetid://79332487729164",
            List     = "rbxassetid://10723427199",
            Shield   = "rbxassetid://129838924496395",
            Guard    = "rbxassetid://83105221992002",
            Person   = "rbxassetid://10734920149",
            Sun      = "rbxassetid://140556911959904",
            Settings = "rbxassetid://133220441796193",
            Calibrate= "rbxassetid://123876321379439",
            Ping     = "rbxassetid://116858464331400",
            Meter    = "rbxassetid://10723395708",
            Lob      = "rbxassetid://106868089574304",
            Glide    = "rbxassetid://118479244779346",
            Contest  = "rbxassetid://10734951173",
            Jelly    = "rbxassetid://136365218255099",
            Ankle    = "rbxassetid://124496590373771",
            Move     = "rbxassetid://119681778821452",
        },
        Theme      = {},
        Settings   = {},
        Connections = {},
        Nudging    = nil,
        OnUnload   = nil,
    }

    -- Forward-declare the window so the shim can reference it after creation
    local _win

    -- ZeroUI-style CreateWindow → AuralV2 Window
    function lib:CreateWindow(opts)
        _win = AV2:CreateWindow({
            Title      = opts.Title or "Aural",
            Subtitle   = opts.Subtitle,
            ToggleKey  = Enum.KeyCode.F5,
            Configs    = true,
        })

        -- Sync theme accent so Library.Theme.Accent works
        lib.Theme = _win.Theme or {}
        _win.ThemeChanged:Connect(function(theme)
            lib.Theme = theme or {}
        end)

        -- Proxy Flags through the window's Flags table
        lib.Flags = _win.Flags

        -- ZeroUI-style Window wrapper
        local winProxy = {}

        -- CreateCategory: AuralV2 is flat (no categories), so we just label tabs
        function winProxy:CreateCategory(name)
            local cat = { _name = name }
            function cat:CreateTab(tabOpts)
                local title = (tabOpts and tabOpts.Title) or name
                local tab = _win:AddTab({ Name = title, Icon = tabOpts and tabOpts.Icon })
                local tabProxy = { _tab = tab }

                function tabProxy:CreateSection(secOpts)
                    local sec = tab:AddSection({ Title = (secOpts and secOpts.Title) or "Section" })
                    local secProxy = { _sec = sec }

                    -- Wrap all element methods, translating ZeroUI opts → AuralV2 opts
                    local function xlat(o)
                        if type(o) == "string" then return { Name = o } end
                        o = o or {}
                        local out = {}
                        out.Name       = o.Title or o.Name
                        out.Default    = o.Default
                        out.Callback   = o.Callback
                        out.Desc       = o.Description
                        out.SearchText = o.Description
                        out.Flag       = o.Flag
                        -- Slider
                        out.Min        = o.Min
                        out.Max        = o.Max
                        out.Step       = o.Step
                        out.Decimals   = o.Decimals
                        out.Suffix     = o.Suffix
                        -- Dropdown
                        out.Values     = o.Options
                        out.Multi      = o.Multi
                        -- Textbox
                        out.Placeholder = o.Placeholder
                        -- ColorPicker
                        -- (Default already set)
                        -- Keybind
                        -- (Default already set)
                        return out
                    end

                    function secProxy:AddToggle(o)
                        local x = xlat(o)
                        local el = sec:AddToggle(x)
                        -- AuralV2 Toggle: el.Changed signal; ZeroUI uses Callback directly
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        if o and o.Keybind then
                            -- also add a companion keybind row
                            local kb = sec:AddKeybind({ Name = (o.Title or "Toggle") .. " key" })
                            if o.Flag then lib.Elements[o.Flag .. "_Key"] = kb end
                        end
                        -- Expose :Update(v)
                        el.Update = function(self2, v) self2:Set(v) end
                        return el
                    end

                    function secProxy:AddSlider(o)
                        local x = xlat(o)
                        local el = sec:AddSlider(x)
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        el.Update = function(self2, v) self2:Set(v) end
                        return el
                    end

                    function secProxy:AddDropdown(o)
                        local x = xlat(o)
                        local el = sec:AddDropdown(x)
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        el.Update = function(self2, v) self2:Set(v) end
                        -- Add Refresh method for dynamic option lists
                        el.Refresh = function(self2, newOptions)
                            self2.Values = newOptions or {}
                        end
                        return el
                    end

                    function secProxy:AddButton(o)
                        local x = xlat(o)
                        if o and o.Risky then x.Style = "Danger" end
                        local el = sec:AddButton(x)
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        return el
                    end

                    -- Multi-button row: each entry is {Title, Callback}
                    function secProxy:AddButtons(buttons)
                        for _, btn in ipairs(buttons) do
                            sec:AddButton({ Name = btn.Title, Full = false, Callback = btn.Callback })
                        end
                    end

                    function secProxy:AddKeybind(o)
                        local x = xlat(o)
                        -- Wire ChangedCallback: fires when the user rebinds the key
                        if o and o.ChangedCallback then
                            local origCallback = x.Callback
                            x.ChangedCallback = o.ChangedCallback
                        end
                        local el = sec:AddKeybind(x)
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        el.Update = function(self2, v) self2:Set(v) end
                        -- If AuralV2 exposes a Changed signal, hook ChangedCallback onto it
                        if o and o.ChangedCallback and el.Changed then
                            pcall(function()
                                el.Changed:Connect(function(newKey)
                                    o.ChangedCallback(newKey)
                                end)
                            end)
                        end
                        return el
                    end

                    function secProxy:AddColorPicker(o)
                        local x = xlat(o)
                        local el = sec:AddColorPicker(x)
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        el.Update = function(self2, v) self2:Set(v) end
                        return el
                    end

                    function secProxy:AddLabel(o)
                        if type(o) == "string" then o = { Text = o } end
                        local el = sec:AddLabel(o)
                        -- ZeroUI labels use :Update(text); AuralV2 uses :Set(text)
                        el.Update = function(self2, t) self2:Set(t) end
                        return el
                    end

                    function secProxy:AddTextbox(o)
                        local x = xlat(o)
                        local el = sec:AddTextBox(x)
                        if o and o.Flag then lib.Elements[o.Flag] = el end
                        el.GetValue = function(self2) return self2:Get() end
                        el.Update = function(self2, v) self2:Set(v) end
                        return el
                    end

                    function secProxy:AddDivider(_label) end -- visual only, no-op

                    return secProxy
                end

                return tabProxy
            end
            return cat
        end

        function winProxy:Notify(opts)
            if type(opts) == "string" then opts = { Text = opts } end
            -- Remap ZeroUI's Content → AuralV2's Text
            if opts.Content and not opts.Text then opts.Text = opts.Content end
            _win:Notify(opts)
        end

        function winProxy:Unload()
            if lib.OnUnload then pcall(lib.OnUnload) end
            _win:Destroy()
        end

        function winProxy:GetConfigs()
            local ok, list = pcall(function() return _win:GetConfigs() end)
            if ok and list then return list end
            return {}
        end

        function winProxy:RefreshVisuals()
            lib.Theme = _win.Theme or {}
        end

        function winProxy:SetToggleKey(key)
            if key and _win then
                pcall(function() _win:SetToggleKey(key) end)
            end
        end

        function winProxy:Toggle(state)
            if _win then pcall(function() _win:Toggle(state) end) end
        end

        function winProxy:SaveConfig(name)
            if _win then return pcall(function() return _win:SaveConfig(name) end) end
        end

        function winProxy:LoadSavedConfig(name)
            if _win then return pcall(function() return _win:LoadSavedConfig(name) end) end
        end

        function winProxy:ExportConfig(name)
            if _win then
                local ok, result = pcall(function() return _win:ExportConfig(name) end)
                if ok then return result end
            end
            return ""
        end

        function winProxy:ImportConfig(text)
            if _win then return pcall(function() return _win:ImportConfig(text) end) end
        end

        function winProxy:SetAutoLoad(name)
            if _win then return pcall(function() return _win:SetAutoLoad(name) end) end
        end

        function winProxy:GetAutoLoad()
            if _win then
                local ok, result = pcall(function() return _win:GetAutoLoad() end)
                if ok then return result end
            end
            return nil
        end

        function winProxy:LoadAutoConfig()
            if _win then return pcall(function() return _win:LoadAutoConfig() end) end
        end

        function winProxy:AddConfigSections(tab)
            if _win and tab then
                pcall(function() _win:AddConfigSections(tab) end)
            end
        end

        return winProxy
    end

    return lib
end)()


-- // Game
-- Everything is read from instances; nothing in the game is required, so Xeno and Solara run the same code.
local RemoteServices = ReplicatedStorage:WaitForChild("Aero"):WaitForChild("AeroRemoteServices")
local Characters = workspace:WaitForChild("Characters", 30)

local function GetRemote(Service, Name)
	return RemoteServices:WaitForChild(Service):WaitForChild(Name)
end

local Remotes = {
	Shoot = GetRemote("InputService", "Shoot"),
	Jump = GetRemote("InputService", "Jump"),
	Dribble = GetRemote("InputService", "Dribble"),
	Sprint = GetRemote("InputService", "Sprint"),
	HoldG = GetRemote("InputService", "HoldG"),
	UpdateSetting = GetRemote("PlayerService", "UpdateSetting"),
	GetProfileData = GetRemote("PlayerService", "GetProfileData"),
	ShowFeedback = GetRemote("InterfaceService", "ShowFeedback"),
	MeterRegister = GetRemote("MeterService", "RegisterPacket"),
	MeterUnregister = GetRemote("MeterService", "UnregisterPacket"),
	GreenAnimation = GetRemote("InputService", "GreenAnimation"),
	GreenCelebration = GetRemote("InterfaceService", "GreenCelebration"),
	RunGreenEffect = GetRemote("InterfaceService", "RunGreenEffect"),
	GetWebData = GetRemote("WebService", "GetData"),
}

-- Called straight from the RemoteEvent class, so other scripts' namecall hooks never see or change these calls.
local FireServer = Instance.new("RemoteEvent").FireServer

local function Fire(Remote, ...)
	FireServer(Remote, ...)
end

local Grades = { "Very Early", "Early", "Slightly Early", "Good", "Perfect", "Slightly Late", "Late", "Very Late" }

-- Combo strings per hand ({ left, right }) from the game's Dribbling.Input table. The move a key makes depends on
-- the hand the ball is in, so the same move needs a different string from each hand.
local MoveCombos = {
	["Crossover"] = { "C", "Z" },
	["Hesitation"] = { "Z", "C" },
	["Double Crossover"] = { "ZZ", "CC" },
	["Tween"] = { "CC", "ZZ" },
	["Behind Back"] = { "ZX", "CX" },
	["Spin"] = { "ZXC", "CXZ" },
	["Breakdown"] = { "VZ", "VZ" },
	["Step Back"] = { "X", "X" },
	["Snatch Back"] = { "XX", "XX" },
	["Half Spin"] = { "V", "V" },
	["Double Behind Back"] = { "XZ", "XZ" },
	["Combo"] = { "VV", "VV" },
	["Switch Hand"] = { "H", "H" },
}
local MoveNames = { "Crossover", "Hesitation", "Double Crossover", "Tween", "Behind Back", "Spin", "Breakdown", "Step Back", "Snatch Back", "Half Spin", "Double Behind Back", "Combo", "Switch Hand" }

local MeterTypes = { "Vertical", "Rocket", "Bat", "Funnel", "Hoop", "Roblox", "None" }

-- Actions the game puts a player in on purpose. CanMove switching off during anything else is treated as a stun.
local OwnActions = {
	[""] = true, AwaitingPass = true, Blocking = true, BlowbyPush = true, CatchingLob = true, CatchingPass = true,
	ContactLayup = true, Diving = true, Dribbling = true, Dunking = true, Gathering = true, Inbounding = true,
	InVehicle = true, Moving = true, Passing = true, PassTransition = true, PickingUp = true, Pushing = true,
	Shooting = true, Sitting = true, Stealing = true, TipOff = true, TripleThreat = true,
}
local BlockActions = { Shooting = true, Dunking = true, ContactLayup = true }

-- // Helpers
local function Flat(Vector)
	return Vector3.new(Vector.X, 0, Vector.Z)
end

local function GetCharacter()
	return Characters and Characters:FindFirstChild(LocalPlayer.Name)
end

local function GetRoot(Model)
	return Model and Model:FindFirstChild("HumanoidRootPart")
end

-- The game moves this part on the client and streams it to the server; the visible character just follows it.
local function GetProxy()
	local Proxy = workspace:FindFirstChild("ProxyCharacter")
	if Proxy and Proxy:FindFirstChild("MovementVelocity") then
		return Proxy, Proxy.MovementVelocity, Proxy:FindFirstChild("MovementGyro")
	end
	return nil
end

-- Some modes (the tutorial) never set the Basketball attribute, but the ball weld always holds the ball while you do.
local function HasBall(Model)
	if not Model then
		return false
	end
	if Model:GetAttribute("Basketball") then
		return true
	end
	local Root = Model:FindFirstChild("HumanoidRootPart")
	local Weld = Root and Root:FindFirstChild("Basketball")
	return Weld ~= nil and Weld:IsA("Motor6D") and Weld.Part1 ~= nil
end

-- Team 0 is free play (park, tutorial), where there are no teammates.
local function IsOpponent(Model, Mine, TeamCheck)
	if not TeamCheck then
		return true
	end
	local MyTeam = Mine:GetAttribute("Team")
	return MyTeam == nil or MyTeam == 0 or Model:GetAttribute("Team") ~= MyTeam
end

local function GetOthers(Mine)
	local List = {}
	if not Characters then
		return List
	end
	for Index, Model in Characters:GetChildren() do
		local Root = Model ~= Mine and Model.Name ~= "InvisCharacter" and GetRoot(Model)
		if Root then
			table.insert(List, { Model = Model, Root = Root })
		end
	end
	return List
end

local Hoops = {}

local function TrackHoop(Object)
	if Object.Name == "Goal" and Object:IsA("BasePart") and Object.Parent and Object.Parent:FindFirstChild("PaintZone") then
		Hoops[Object] = true
	end
end

for Index, Object in workspace:GetDescendants() do
	TrackHoop(Object)
end
Connect(workspace.DescendantAdded, TrackHoop)

-- The hoop a player attacks: their own Goal attribute in a game, otherwise the closest hoop.
local function GetGoal(Model)
	local Goal = Model and Model:GetAttribute("Goal")
	if typeof(Goal) == "CFrame" then
		return Goal.Position
	elseif typeof(Goal) == "Vector3" then
		return Goal
	end
	local Root = GetRoot(Model)
	if not Root then
		return nil
	end
	local Closest, ClosestDistance = nil, math.huge
	for Hoop in Hoops do
		if Hoop.Parent then
			local Distance = (Hoop.Position - Root.Position).Magnitude
			if Distance < ClosestDistance then
				Closest, ClosestDistance = Hoop.Position, Distance
			end
		else
			Hoops[Hoop] = nil
		end
	end
	return Closest
end

-- Same camera-relative movement the game builds from WASD; falls back to the current velocity on touch and gamepad.
local function GetMoveDirection()
	local Camera = workspace.CurrentCamera
	local Look, Right = Flat(Camera.CFrame.LookVector), Flat(Camera.CFrame.RightVector)
	local Direction = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then Direction += Look end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then Direction -= Look end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then Direction += Right end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then Direction -= Right end
	if Direction.Magnitude > 0.01 then
		return Direction.Unit
	end
	local Proxy = GetProxy()
	local Velocity = Proxy and Flat(Proxy.AssemblyLinearVelocity)
	if Velocity and Velocity.Magnitude > 2 then
		return Velocity.Unit
	end
	return Vector3.zero
end

-- // Window
Library.Folder = "Aural"

local HttpService = game:GetService("HttpService")

local MenuKey = Enum.KeyCode.F5
local Window = Library:CreateWindow({ Title = "Aural", Subtitle = "practical basketball", ToggleKey = MenuKey })
local Icons = Library.Icons

-- Notify must be declared before the config helpers that call it
local function Notify(Title, Content)
	Window:Notify({ Title = Title, Text = Content, Duration = 4 })
end


-- Tabs (flat — no categories)
local ShootingTab = Window:CreateCategory(""):CreateTab({ Title = "Shooting",  Icon = Icons.Timer })
local OffenseTab  = Window:CreateCategory(""):CreateTab({ Title = "Offense",   Icon = Icons.Dribble })
local DefenseTab  = Window:CreateCategory(""):CreateTab({ Title = "Defense",   Icon = Icons.Shield })
local CharacterTab= Window:CreateCategory(""):CreateTab({ Title = "Character", Icon = Icons.Person })
local VisualsTab  = Window:CreateCategory(""):CreateTab({ Title = "Visuals",   Icon = Icons.Sun })
local SettingsTab = Window:CreateCategory(""):CreateTab({ Title = "Settings",  Icon = Icons.Settings })

-- Forward-declared labels and lists used in logic below
local PingLabel, CalibrationLabel, LastShotLabel
local SpectateList, GuardStatus

local function SetCurrentMeter(...) end
local function ResetCalibration() end
local function SetDebounce(...) end
local function ApplyEffects() end
local function RefreshCosmetics() end

-- Option lists for the cosmetic and effect changers
local Accessories = ReplicatedStorage:WaitForChild("Accessories", 10)
local EffectAssets = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models"):WaitForChild("GreenEffects")
local AccessoryTypes = { "Hats", "Hair", "FacialHair", "Glasses", "Chain", "Backpack" }
local CosmeticOptions = {}
local ShoeOptions, ShoeLookup = { "None" }, {}
local MascotOptions = { "None" }
local EffectOptions = {}

if Accessories then
	for Index, Type in AccessoryTypes do
		local Names, Seen = {}, {}
		for Index2, Item in Accessories[Type]:GetDescendants() do
			if Item:IsA("BasePart") and Item:FindFirstChildOfClass("Attachment") and not Seen[Item.Name] then
				Seen[Item.Name] = true
				table.insert(Names, Item.Name)
			end
		end
		table.sort(Names)
		table.insert(Names, 1, "None")
		CosmeticOptions[Type] = Names
	end
	for Index, Model in Accessories.Shoes:GetChildren() do
		for Index2, Variant in Model:GetChildren() do
			local Key = Variant.Name == "Base" and Model.Name or (Model.Name .. " (" .. Variant.Name .. ")")
			ShoeLookup[Key] = Variant
			table.insert(ShoeOptions, Key)
		end
	end
	table.sort(ShoeOptions, function(First, Second)
		return First == "None" or (Second ~= "None" and First < Second)
	end)
	for Index, Mascot in Accessories.Mascots:GetChildren() do
		table.insert(MascotOptions, Mascot.Name)
	end
end

for Index, Effect in (EffectAssets:FindFirstChild("Goal") or EffectAssets):GetChildren() do
	table.insert(EffectOptions, Effect.Name)
end
table.sort(EffectOptions)

local Celebrations = {
	["2PT"] = { "Too Small", "Stir", "Bombs Away", "Point To Sky", "Point To Crowd", "Arrow" },
	["3PT"] = { "Point To Sky", "Stir", "Grenade", "Arrow", "Point To Crowd", "Bombs Away", "Night Night" },
	["Finisher"] = { "Flex", "Truth", "Windmill" },
}
pcall(function()
	local Data = Remotes.GetWebData:InvokeServer("Animations")
	local Character = Data and Data.Character
	local function Packages(Kind)
		local List = {}
		for Index, Entry in Character[Kind] or {} do
			if type(Entry) == "table" and Entry.package and not table.find(List, Entry.package) then
				table.insert(List, Entry.package)
			end
		end
		return List
	end
	if Character then
		local Two, Three = Packages("2PT Celebrations"), Packages("3PT Celebrations")
		local Finishers = Packages("3PT Finisher")
		for Index, Package in Packages("2PT Finisher") do
			if not table.find(Finishers, Package) then
				table.insert(Finishers, Package)
			end
		end
		Celebrations["2PT"] = #Two > 0 and Two or Celebrations["2PT"]
		Celebrations["3PT"] = #Three > 0 and Three or Celebrations["3PT"]
		Celebrations.Finisher = #Finishers > 0 and Finishers or Celebrations.Finisher
	end
end)

-- ╔══════════════════════════════╗
-- ║  OFFENSE TAB                 ║
-- ╚══════════════════════════════╝

-- // Perfect Timing  [Shooting tab]
do
	local Timing = ShootingTab:CreateSection({ Title = "Perfect Timing", Icon = Icons.Timer })
	local PerfTimingToggle = Timing:AddToggle({ Title = "Perfect Timing", Description = "Releases every shot you hold at the top of the meter", Flag = "PerfectTiming", Default = Aural.Shooting.PerfectTiming, Callback = function(V) Aural.Shooting.PerfectTiming = V end })
	Timing:AddKeybind({ Title = "Perfect Timing Keybind", Flag = "PerfectTimingKey", Callback = function()
		local newVal = PerfTimingToggle and not PerfTimingToggle:Get() or not Aural.Shooting.PerfectTiming
		if PerfTimingToggle then pcall(function() PerfTimingToggle:Set(newVal) end) end
		Aural.Shooting.PerfectTiming = newVal
	end })
	Timing:AddSlider({ Title = "Release Point", Description = "How full the meter is when the release lands", Min = 90, Max = 100, Default = Aural.Shooting.ReleasePoint, Step = 0.5, Decimals = 1, Suffix = "%", Flag = "ReleasePoint", Callback = function(V) Aural.Shooting.ReleasePoint = V end })
	Timing:AddSlider({ Title = "Timing Offset", Description = "Manual nudge; positive releases later", Min = -100, Max = 100, Default = -5, Suffix = "ms", Flag = "TimingOffset", Callback = function(V) Aural.Shooting.TimingOffset = V end })
	Timing:AddToggle({ Title = "Auto Align", Description = "Squares up directly facing the hoop to eliminate drift and angle penalties", Flag = "AutoAlign", Default = Aural.Shooting.AutoAlign, Callback = function(V) Aural.Shooting.AutoAlign = V end })
	Timing:AddToggle({ Title = "Distance Scaling", Description = "Dynamically scales meter timing and optimal arc for 3s and deep shots", Flag = "DistanceScaling", Default = Aural.Shooting.DistanceScaling, Callback = function(V) Aural.Shooting.DistanceScaling = V end })

	local Calibrate = ShootingTab:CreateSection({ Title = "Auto Calibrate", Icon = Icons.Calibrate })
	Calibrate:AddToggle({ Title = "Auto Calibrate", Description = "Learns your timing from where the meter stops", Flag = "AutoCalibrate", Default = Aural.Shooting.AutoCalibrate, Callback = function(V) Aural.Shooting.AutoCalibrate = V end })
	CalibrationLabel = Calibrate:AddLabel("calibration: +0ms")
	LastShotLabel = Calibrate:AddLabel("last shot: none")
	Calibrate:AddButton({ Title = "Reset calibration", Callback = function() ResetCalibration() end })

	local Ping = ShootingTab:CreateSection({ Title = "Ping", Icon = Icons.Ping })
	PingLabel = Ping:AddLabel("ping: 0ms")
	Ping:AddToggle({ Title = "Ping Compensation", Description = "Sends the release one round trip early so it lands on time", Flag = "PingCompensation", Default = Aural.Shooting.PingCompensation, Callback = function(V) Aural.Shooting.PingCompensation = V end })
	Ping:AddSlider({ Title = "Compensation Amount", Description = "Share of your ping to send early", Min = 0, Max = 200, Default = Aural.Shooting.PingMultiplier, Suffix = "%", Flag = "PingMultiplier", Callback = function(V) Aural.Shooting.PingMultiplier = V end })

	local Meter = ShootingTab:CreateSection({ Title = "Meter", Icon = Icons.Meter })
	Meter:AddDropdown({ Title = "Change Meter", Description = "Switches your shot meter type", Options = MeterTypes, Flag = "MeterType", Callback = function(V)
		if V then
			SetCurrentMeter(V)
			Fire(Remotes.UpdateSetting, { "Meter" }, "Type", V)
			Notify("Meter", "Meter set to " .. V .. ".")
		end
	end })
end

-- // Auto Shoot  [Shooting tab]
do
	local Shoot = ShootingTab:CreateSection({ Title = "Auto Shoot", Icon = Icons.Target })
	local AutoShootToggle = Shoot:AddToggle({ Title = "Auto Shoot", Description = "Shoots once when in range, perfect timing releases", Flag = "AutoShoot", Default = Aural.Shooting.AutoShoot, Callback = function(V) Aural.Shooting.AutoShoot = V end })
	Shoot:AddKeybind({ Title = "Auto Shoot Keybind", Flag = "AutoShootKey", Callback = function()
		local newVal = AutoShootToggle and not AutoShootToggle:Get() or not Aural.Shooting.AutoShoot
		if AutoShootToggle then pcall(function() AutoShootToggle:Set(newVal) end) end
		Aural.Shooting.AutoShoot = newVal
	end })
	Shoot:AddSlider({ Title = "Shoot Range", Description = "Max distance from the hoop to shoot", Min = 5, Max = 45, Default = Aural.Shooting.ShootRange, Suffix = " studs", Flag = "ShootRange", Callback = function(V) Aural.Shooting.ShootRange = V end })
	Shoot:AddToggle({ Title = "3-Point Only", Description = "Auto shoot only fires when positioned behind the 3-point line (21.5+ studs)", Flag = "ThreePointOnly", Default = Aural.Shooting.ThreePointOnly, Callback = function(V) Aural.Shooting.ThreePointOnly = V end })

	local Circle = ShootingTab:CreateSection({ Title = "Range Circle", Icon = Icons.Target })
	Circle:AddToggle({ Title = "Show Range", Description = "Draws the shoot range around the hoop you attack", Flag = "RangeCircle", Default = Aural.Shooting.RangeCircle, Callback = function(V) Aural.Shooting.RangeCircle = V end })
	Circle:AddColorPicker({ Title = "Circle Color", Default = Aural.Shooting.RangeCircleColor, Flag = "RangeCircleColor", Callback = function(V) Aural.Shooting.RangeCircleColor = V end })
end

-- // Dribble
do
	local Glide = OffenseTab:CreateSection({ Title = "Dribble Glide", Icon = Icons.Glide })
	local GlideToggle = Glide:AddToggle({ Title = "Dribble Glide", Description = "Dribble moves travel further", Flag = "DribbleGlide", Default = Aural.Dribbling.DribbleGlide, Callback = function(V) Aural.Dribbling.DribbleGlide = V end })
	Glide:AddKeybind({ Title = "Dribble Glide Keybind", Flag = "DribbleGlideKey", Callback = function()
		local newVal = GlideToggle and not GlideToggle:Get() or not Aural.Dribbling.DribbleGlide
		if GlideToggle then pcall(function() GlideToggle:Set(newVal) end) end
		Aural.Dribbling.DribbleGlide = newVal
	end })
	Glide:AddSlider({ Title = "Glide Speed", Description = "Extra speed on every dribble move", Min = 0, Max = 100, Default = Aural.Dribbling.GlideSpeed, Suffix = "%", Flag = "GlideSpeed", Callback = function(V) Aural.Dribbling.GlideSpeed = V end })

	local Ankle = OffenseTab:CreateSection({ Title = "Auto Ankle Breaker", Icon = Icons.Ankle })
	local AnkleToggle = Ankle:AddToggle({ Title = "Auto Ankle Breaker", Description = "Fires an escape move when a defender closes in", Flag = "AutoAnkleBreaker", Default = Aural.Dribbling.AutoAnkleBreaker, Callback = function(V) Aural.Dribbling.AutoAnkleBreaker = V end })
	Ankle:AddKeybind({ Title = "Ankle Breaker Keybind", Flag = "AutoAnkleBreakerKey", Callback = function()
		local newVal = AnkleToggle and not AnkleToggle:Get() or not Aural.Dribbling.AutoAnkleBreaker
		if AnkleToggle then pcall(function() AnkleToggle:Set(newVal) end) end
		Aural.Dribbling.AutoAnkleBreaker = newVal
	end })
	Ankle:AddSlider({ Title = "Ankle Break Range", Description = "How close a defender has to be", Min = 3, Max = 20, Default = Aural.Dribbling.AnkleBreakRange, Step = 0.5, Decimals = 1, Suffix = " studs", Flag = "AnkleBreakRange", Callback = function(V) Aural.Dribbling.AnkleBreakRange = V end })
	Ankle:AddDropdown({ Title = "Move", Options = MoveNames, Default = Aural.Dribbling.AnkleBreakerMove, Flag = "AnkleBreakerMove", Callback = function(V) Aural.Dribbling.AnkleBreakerMove = V or "Crossover" end })

end

-- ╔══════════════════════════════╗
-- ║  DEFENSE TAB                 ║
-- ╚══════════════════════════════╝

-- // Auto Block
do
	local Block = DefenseTab:CreateSection({ Title = "Auto Block", Icon = Icons.Shield })
	local BlockToggle = Block:AddToggle({ Title = "Auto Block", Description = "Jumps at nearby shots, layups and dunks", Flag = "AutoBlock", Default = Aural.Defense.AutoBlock, Callback = function(V) Aural.Defense.AutoBlock = V end })
	Block:AddKeybind({ Title = "Auto Block Keybind", Flag = "AutoBlockKey", Callback = function()
		local newVal = BlockToggle and not BlockToggle:Get() or not Aural.Defense.AutoBlock
		if BlockToggle then pcall(function() BlockToggle:Set(newVal) end) end
		Aural.Defense.AutoBlock = newVal
	end })
	Block:AddSlider({ Title = "Block Range", Description = "How far away a shot triggers the block", Min = 3, Max = 30, Default = Aural.Defense.BlockRange, Suffix = " studs", Flag = "BlockRange", Callback = function(V) Aural.Defense.BlockRange = V end })
	Block:AddSlider({ Title = "Block Delay", Description = "Waits this long before jumping — filters pump fakes", Min = 0, Max = 500, Default = Aural.Defense.BlockDelay, Step = 10, Suffix = "ms", Flag = "BlockDelay", Callback = function(V) Aural.Defense.BlockDelay = V end })
	Block:AddToggle({ Title = "Team Check", Description = "Never blocks a teammate", Flag = "BlockTeamCheck", Default = Aural.Defense.BlockTeamCheck, Callback = function(V) Aural.Defense.BlockTeamCheck = V end })
end

-- // Auto Guard
do
	local Guard = DefenseTab:CreateSection({ Title = "Auto Guard", Icon = Icons.Guard })
	local GuardToggle = Guard:AddToggle({ Title = "Auto Guard", Description = "Holds guard and stays between your man and the hoop", Flag = "AutoGuard", Default = Aural.Defense.AutoGuard, Callback = function(V) Aural.Defense.AutoGuard = V end })
	Guard:AddKeybind({ Title = "Auto Guard Keybind", Flag = "AutoGuardKey", Callback = function()
		local newVal = GuardToggle and not GuardToggle:Get() or not Aural.Defense.AutoGuard
		if GuardToggle then pcall(function() GuardToggle:Set(newVal) end) end
		Aural.Defense.AutoGuard = newVal
	end })
	Guard:AddToggle({ Title = "Guard Sprint", Description = "Sprints to keep up when your man gets ahead", Flag = "GuardSprint", Default = Aural.Defense.GuardSprint, Callback = function(V) Aural.Defense.GuardSprint = V end })
	Guard:AddToggle({ Title = "Team Check", Description = "Never guards your own teammates", Flag = "TeamCheck", Default = Aural.Defense.TeamCheck, Callback = function(V) Aural.Defense.TeamCheck = V end })
	Guard:AddToggle({ Title = "Ball Handler Only", Description = "Only guards the player with the ball", Flag = "BallHandlerOnly", Default = Aural.Defense.BallHandlerOnly, Callback = function(V) Aural.Defense.BallHandlerOnly = V end })
	Guard:AddSlider({ Title = "Guard Distance", Description = "How tight to play your man — lower is closer", Min = 1, Max = 10, Default = Aural.Defense.GuardDistance, Step = 0.5, Decimals = 1, Suffix = " studs", Flag = "GuardDistance", Callback = function(V) Aural.Defense.GuardDistance = V end })
	Guard:AddSlider({ Title = "Guard Strength", Description = "How aggressively it corrects your position", Min = 10, Max = 100, Default = Aural.Defense.GuardStrength, Suffix = "%", Flag = "GuardStrength", Callback = function(V) Aural.Defense.GuardStrength = V end })
	Guard:AddSlider({ Title = "Guard Range", Description = "Max distance from your man before guard kicks in", Min = 10, Max = 80, Default = Aural.Defense.GuardRange, Suffix = " studs", Flag = "GuardRange", Callback = function(V) Aural.Defense.GuardRange = V end })
	GuardStatus = Guard:AddLabel("guarding: none")
end

-- // Ball Magnets
do
	local Magnets = DefenseTab:CreateSection({ Title = "Ball Magnets", Icon = Icons.Target })
	Magnets:AddToggle({ Title = "Ball Magnets", Description = "Goes after loose balls and rebounds near you", Flag = "BallMagnets", Default = Aural.Ball.Magnets, Callback = function(V) Aural.Ball.Magnets = V end })
	Magnets:AddSlider({ Title = "Magnet Range", Description = "Radius around you that triggers the magnet", Min = 3, Max = 40, Default = Aural.Ball.MagnetRange, Suffix = " studs", Flag = "MagnetRange", Callback = function(V) Aural.Ball.MagnetRange = V end })
	Magnets:AddDropdown({ Title = "Magnet Mode", Description = "Pull glides the ball in, Teleport snaps it instantly", Options = { "Pull", "Teleport" }, Default = Aural.Ball.MagnetMode, Flag = "MagnetMode", Callback = function(V) Aural.Ball.MagnetMode = V or "Pull" end })
	Magnets:AddSlider({ Title = "Pull Speed", Description = "How fast the ball slides toward you in Pull mode", Min = 10, Max = 60, Default = Aural.Ball.MagnetSpeed, Suffix = " studs/s", Flag = "MagnetSpeed", Callback = function(V) Aural.Ball.MagnetSpeed = V end })
	Magnets:AddToggle({ Title = "Ignore Shots", Description = "Leaves balls still in the air on a shot", Flag = "MagnetSkipShots", Default = Aural.Ball.SkipShots, Callback = function(V) Aural.Ball.SkipShots = V end })
	Magnets:AddToggle({ Title = "Show Range", Description = "Draws the magnet range around you", Flag = "MagnetShowRange", Default = Aural.Ball.ShowRange, Callback = function(V) Aural.Ball.ShowRange = V end })
end

-- ╔══════════════════════════════╗
-- ║  CHARACTER TAB               ║
-- ╚══════════════════════════════╝

-- // Movement
do
	local Movement = CharacterTab:CreateSection({ Title = "Movement", Icon = Icons.Move })
	local SpeedToggle = Movement:AddToggle({ Title = "Speed Boost", Description = "Raises your movement speed", Flag = "SpeedBoost", Default = Aural.Player.SpeedBoost, Callback = function(V) Aural.Player.SpeedBoost = V end })
	Movement:AddKeybind({ Title = "Speed Boost Keybind", Flag = "SpeedBoostKey", Callback = function()
		local newVal = SpeedToggle and not SpeedToggle:Get() or not Aural.Player.SpeedBoost
		if SpeedToggle then pcall(function() SpeedToggle:Set(newVal) end) end
		Aural.Player.SpeedBoost = newVal
	end })
	Movement:AddSlider({ Title = "Speed", Description = "Normal 14, sprint 17.35", Min = 14, Max = 30, Default = Aural.Player.Speed, Step = 0.5, Decimals = 1, Flag = "Speed", Callback = function(V) Aural.Player.Speed = V end })
	local CFrameToggle = Movement:AddToggle({ Title = "CFrame Speed", Description = "Moves you forward each frame on top of normal movement", Flag = "CframeSpeed", Default = Aural.Player.CframeSpeed, Callback = function(V) Aural.Player.CframeSpeed = V end })
	Movement:AddKeybind({ Title = "CFrame Speed Keybind", Flag = "CframeSpeedKey", Callback = function()
		local newVal = CFrameToggle and not CFrameToggle:Get() or not Aural.Player.CframeSpeed
		if CFrameToggle then pcall(function() CFrameToggle:Set(newVal) end) end
		Aural.Player.CframeSpeed = newVal
	end })
	Movement:AddSlider({ Title = "CFrame Amount", Description = "Extra studs added per frame while moving", Min = 1, Max = 30, Default = Aural.Player.CframeSpeedValue, Step = 0.5, Decimals = 1, Flag = "CframeSpeedValue", Callback = function(V) Aural.Player.CframeSpeedValue = V end })
	Movement:AddToggle({ Title = "Auto Sprint", Description = "Holds sprint automatically so you never slow down", Flag = "AutoSprint", Default = Aural.Player.AutoSprint, Callback = function(V) Aural.Player.AutoSprint = V end })
	Movement:AddToggle({ Title = "No Stun", Description = "Keeps you moving through stumbles and ankle breaks", Flag = "NoStun", Default = Aural.Player.NoStun, Callback = function(V) Aural.Player.NoStun = V end })
	Movement:AddToggle({ Title = "Infinite Stamina", Description = "Stops your stamina bar from ever running out", Flag = "InfiniteStamina", Default = Aural.Player.InfiniteStamina, Callback = function(V) Aural.Player.InfiniteStamina = V end })

	local State = CharacterTab:CreateSection({ Title = "State", Icon = Icons.Person })
	State:AddToggle({ Title = "Auto Takeover", Description = "Activates your takeover the moment it fills up", Flag = "AutoTakeover", Default = Aural.Player.AutoTakeover, Callback = function(V) Aural.Player.AutoTakeover = V end })
	State:AddToggle({ Title = "No Cold Zone", Description = "Removes the penalty for shooting from your cold spots", Flag = "NoColdZone", Default = Aural.Player.NoColdZone, Callback = function(V) Aural.Player.NoColdZone = V end })
	State:AddToggle({ Title = "No Debounce", Description = "Removes shoot and dribble input delay", Flag = "NoDebounce", Default = Aural.Player.NoDebounce, Callback = function(V)
		Aural.Player.NoDebounce = V
		SetDebounce(V)
	end })
end

-- ╔══════════════════════════════╗
-- ║  VISUALS TAB                 ║
-- ╚══════════════════════════════╝

-- // World / Camera / Spectate
do
	local World = VisualsTab:CreateSection({ Title = "World", Icon = Icons.Sun })
	World:AddToggle({ Title = "Remove Post Effects", Description = "Strips blur, bloom and color grading for a cleaner view", Flag = "RemovePostEffects", Default = Aural.Visuals.RemovePostEffects, Callback = function(V) Aural.Visuals.RemovePostEffects = V end })
	World:AddToggle({ Title = "Fullbright", Description = "Forces max brightness so dark courts are fully visible", Flag = "Fullbright", Default = Aural.Visuals.Fullbright, Callback = function(V) Aural.Visuals.Fullbright = V end })

	local Camera = VisualsTab:CreateSection({ Title = "Camera", Icon = Icons.Target })
	Camera:AddToggle({ Title = "Custom FOV", Description = "Enables the FOV slider below", Flag = "CustomFov", Default = Aural.Visuals.CustomFov, Callback = function(V) Aural.Visuals.CustomFov = V end })
	Camera:AddSlider({ Title = "FOV", Description = "Camera field of view — default Roblox is 70", Min = 30, Max = 120, Default = Aural.Visuals.Fov, Flag = "Fov", Callback = function(V) Aural.Visuals.Fov = V end })

	local Spectate = VisualsTab:CreateSection({ Title = "Spectate", Icon = Icons.Person })
	local SpectToggle = Spectate:AddToggle({ Title = "Spectate Player", Description = "Locks your camera onto the selected player", Flag = "Spectate", Save = false, Default = false, Callback = function(V) Aural.Visuals.Spectate = V end })
	Spectate:AddKeybind({ Title = "Spectate Keybind", Flag = "SpectateKey", Callback = function()
		local newVal = SpectToggle and not SpectToggle:Get() or not Aural.Visuals.Spectate
		if SpectToggle then pcall(function() SpectToggle:Set(newVal) end) end
		Aural.Visuals.Spectate = newVal
	end })
	SpectateList = Spectate:AddDropdown({ Title = "Player", Description = "Who to follow — list updates as players join/leave", Options = {}, Flag = "SpectateTarget", Save = false, MaxRows = 8, Callback = function(V) Aural.Visuals.SpectateTarget = V end })

	local function RefreshPlayers()
		local Names = {}
		for Index, Player in Players:GetPlayers() do
			if Player ~= LocalPlayer then
				table.insert(Names, Player.Name)
			end
		end
		table.sort(Names)
		SpectateList:Refresh(Names)
	end
	RefreshPlayers()
	Connect(Players.PlayerAdded, RefreshPlayers)
	Connect(Players.PlayerRemoving, function()
		task.defer(RefreshPlayers)
	end)
end

-- // Cosmetics
do
	local Names = { Hats = "Hat", Hair = "Hair", FacialHair = "Facial Hair", Glasses = "Glasses", Chain = "Chain", Backpack = "Backpack" }
	local Wear = VisualsTab:CreateSection({ Title = "Accessories", Icon = Icons.Person })
	Wear:AddLabel("Only you see these. Pick None to go back to your own.")
	for Index, Type in AccessoryTypes do
		Wear:AddDropdown({ Title = Names[Type], Options = CosmeticOptions[Type] or { "None" }, Default = Aural.Cosmetics[Type], MaxRows = 8, Flag = "Cosmetic" .. Type, Callback = function(V)
			Aural.Cosmetics[Type] = V or "None"
			RefreshCosmetics()
		end })
	end

	local Body = VisualsTab:CreateSection({ Title = "Shoes & Mascot", Icon = Icons.Move })
	Body:AddDropdown({ Title = "Shoes", Options = ShoeOptions, Default = Aural.Cosmetics.Shoes, MaxRows = 8, Flag = "CosmeticShoes", Callback = function(V)
		Aural.Cosmetics.Shoes = V or "None"
		RefreshCosmetics()
	end })
	Body:AddDropdown({ Title = "Mascot", Description = "Replaces your whole body", Options = MascotOptions, Default = Aural.Cosmetics.Mascot, Flag = "CosmeticMascot", Callback = function(V)
		Aural.Cosmetics.Mascot = V or "None"
		RefreshCosmetics()
	end })
	Body:AddButton({ Title = "Reset all cosmetics", Risky = true, Callback = function()
		for Type in Aural.Cosmetics do
			local Element = Library.Elements["Cosmetic" .. Type]
			if Element then
				Element:Update("None")
			end
		end
	end })
end

-- // Effects
do
	local Goal = VisualsTab:CreateSection({ Title = "Goal Effect", Icon = Icons.Jelly })
	Goal:AddToggle({ Title = "Goal Effect Changer", Description = "Every green plays this effect at the rim", Flag = "GoalEffect", Default = Aural.Effects.GoalEffect, Callback = function(V)
		Aural.Effects.GoalEffect = V
		ApplyEffects()
	end })
	Goal:AddDropdown({ Title = "Effect", Options = EffectOptions, Default = Aural.Effects.GoalEffectName, MaxRows = 8, Flag = "GoalEffectName", Callback = function(V)
		Aural.Effects.GoalEffectName = V or Aural.Effects.GoalEffectName
		ApplyEffects()
	end })
	Goal:AddToggle({ Title = "Ball Trail Too", Description = "Also applies the effect to the ball's trail", Flag = "GoalEffectTrail", Default = Aural.Effects.IncludeTrail, Callback = function(V)
		Aural.Effects.IncludeTrail = V
		ApplyEffects()
	end })

	local Celebrate = VisualsTab:CreateSection({ Title = "Green Celebration", Icon = Icons.Person })
	local CelebToggle = Celebrate:AddToggle({ Title = "Auto Green Celebration", Description = "Celebrates on every green", Flag = "AutoCelebrate", Default = Aural.Effects.AutoCelebrate, Callback = function(V) Aural.Effects.AutoCelebrate = V end })
	Celebrate:AddKeybind({ Title = "Celebrate Keybind", Flag = "AutoCelebrateKey", Callback = function()
		local newVal = CelebToggle and not CelebToggle:Get() or not Aural.Effects.AutoCelebrate
		if CelebToggle then pcall(function() CelebToggle:Set(newVal) end) end
		Aural.Effects.AutoCelebrate = newVal
	end })
	Celebrate:AddDropdown({ Title = "2PT Celebration", Description = "Animation played after a green 2-pointer", Options = Celebrations["2PT"], Default = Aural.Effects.Celebration2, Flag = "Celebration2", Callback = function(V) Aural.Effects.Celebration2 = V or Aural.Effects.Celebration2 end })
	Celebrate:AddDropdown({ Title = "3PT Celebration", Description = "Animation played after a green 3-pointer", Options = Celebrations["3PT"], Default = Aural.Effects.Celebration3, Flag = "Celebration3", Callback = function(V) Aural.Effects.Celebration3 = V or Aural.Effects.Celebration3 end })
	Celebrate:AddDropdown({ Title = "Finisher", Description = "Animation played after a dunk or layup green", Options = Celebrations.Finisher, Default = Aural.Effects.Finisher, Flag = "CelebrationFinisher", Callback = function(V) Aural.Effects.Finisher = V or Aural.Effects.Finisher end })
	Celebrate:AddSlider({ Title = "Celebration Delay", Description = "How long after the green before the animation fires", Min = 0, Max = 1, Default = Aural.Effects.CelebrateDelay, Step = 0.05, Decimals = 2, Suffix = "s", Flag = "CelebrateDelay", Callback = function(V) Aural.Effects.CelebrateDelay = V end })
end

-- ╔══════════════════════════════╗
-- ║  SETTINGS TAB                ║
-- ╚══════════════════════════════╝

do
	-- Master enable toggle — shows/hides the window
	local EnableSec = SettingsTab:CreateSection({ Title = "Script", Icon = Icons.Gear })
	EnableSec:AddToggle({ Title = "Enable Script", Description = "Pauses all features — turn off to lay low mid-game", Flag = "ScriptEnabled", Default = true, Callback = function(V)
		Running = V
		-- show/hide window by toggling visibility
		pcall(function()
			local ScreenGui = game.CoreGui:FindFirstChild("AuralV2") or game.CoreGui:FindFirstChild("Aural")
			if ScreenGui then
				ScreenGui.Enabled = V
			end
		end)
	end })

	-- Config + Menu Keybind (AuralV2 built-in: named configs, autoload, JSON share, menu keybind)
	Window:AddConfigSections(SettingsTab._tab)

	-- Unload
	local UnloadSec = SettingsTab:CreateSection({ Title = "Unload", Icon = Icons.Gear })
	UnloadSec:AddButton({ Title = "Unload script", Callback = function()
		Window:Unload()
	end })
end

-- Auto-load config on start (AuralV2 built-in: loads whichever config was set as autoload)
pcall(function() Window:LoadAutoConfig() end)


-- // Shot Tracking & Perfect Timing
do
	-- Progress (0 to 1) from the meter offset the server writes on your character.
	local MeterMaps = {
		Vertical = function(Offset) return (-Offset.Y - 0.25) / 1.25 end,
		Funnel   = function(Offset) return (-Offset.Y - 0.25) / 1.25 end,
		Rocket   = function(Offset) return -Offset.Y end,
		Bat      = function(Offset) return -Offset.Y end,
		None     = function(Offset) return -Offset.Y end,
		Hoop     = function(Offset) return Offset.Y end,
		Roblox   = function(Offset) return Offset.X end,
	}

	local Shot = {
		Active = false,
		Start = 0,
		Meter = "Vertical",
		Samples = {},
		Slope = nil,
		Intercept = nil,
		PredictedReleaseTime = nil,
		Released = false,
		ReleasedAt = 0,
		LastBeforeRelease = 0,
		Final = nil,
		Ours = false,
		Auto = false,
		Fadeaway = false,
		Distance = 22,
		Generation = 0,
	}
	local AutoPending = 0
	local Calibration = 0
	local LastAutoShot = 0
	local Bound, BoundConnections = nil, {}
	local SmoothedPing = nil

	SetCurrentMeter = function(MeterType)
		if MeterType then
			Shot.Meter = MeterType
		end
	end

	ResetCalibration = function()
		Calibration = 0
		CalibrationLabel:Update("calibration: +0ms")
	end

	-- Distance-based meter fill scaling: in Hoopz, 3-pointers and deep shots have slower meter fill speeds
	local function GetDistanceFillTime(Distance)
		if not Aural.Shooting.DistanceScaling or not Distance then
			return 0.380
		end
		if Distance <= 18 then
			return 0.380
		elseif Distance <= 22 then
			return 0.380 + (Distance - 18) * 0.004
		elseif Distance <= 26 then
			return 0.396 + (Distance - 22) * 0.007
		elseif Distance <= 34 then
			return 0.424 + (Distance - 26) * 0.005
		else
			return 0.464 + math.min((Distance - 34) * 0.003, 0.035)
		end
	end

	-- On 3-pointers, the release point must be clean and high to clear the front iron
	local function GetEffectiveTarget(Distance)
		local BaseTarget = Aural.Shooting.ReleasePoint / 100
		if not Aural.Shooting.DistanceScaling or not Distance then
			return BaseTarget
		end
		if Distance >= 21.5 then
			local ArcBoost = math.clamp((Distance - 21.5) * 0.0006, 0.001, 0.005)
			return math.min(BaseTarget + ArcBoost, 0.985)
		end
		return BaseTarget
	end

	-- Auto align: square up the proxy character facing directly toward the basket for clean, centered releases
	local function AlignToBasket(Character)
		if not Aural.Shooting.AutoAlign then
			return
		end
		local Goal = GetGoal(Character)
		local Proxy, Velocity, Gyro = GetProxy()
		if Gyro and Goal and Proxy then
			local Dir = Flat(Goal - Proxy.Position)
			if Dir.Magnitude > 0.5 then
				Gyro.CFrame = CFrame.lookAt(Proxy.Position, Vector3.new(Goal.X, Proxy.Position.Y, Goal.Z))
			end
		end
	end

	-- Exponential moving average ping filter to eliminate one-frame latency spikes
	local function GetSmoothedPing()
		local Raw = LocalPlayer:GetNetworkPing()
		if typeof(Raw) == "number" and Raw > 0 and Raw < 1 then
			if not SmoothedPing then
				SmoothedPing = Raw
			else
				SmoothedPing = SmoothedPing * 0.75 + Raw * 0.25
			end
		end
		return SmoothedPing or Raw or 0.05
	end

	local function GetLead()
		if not Aural.Shooting.PingCompensation then
			return 0
		end
		return GetSmoothedPing() * (Aural.Shooting.PingMultiplier / 100)
	end

	local function Release()
		if not Shot.Active or Shot.Released then
			return
		end
		Shot.Released = true
		Shot.Ours = true
		Shot.ReleasedAt = os.clock()
		local Last = Shot.Samples[#Shot.Samples]
		Shot.LastBeforeRelease = Last and Last[1] or Shot.Start
		Fire(Remotes.Shoot, { Shoot = false })
	end

	-- Robust linear regression through meter samples with progressive single-sample estimation
	local function Fit()
		local Count = #Shot.Samples
		if Count == 0 then
			return nil, nil
		end
		if Count == 1 then
			local Sample = Shot.Samples[1]
			local Dt = Sample[1] - Shot.Start
			if Dt > 0.03 and Sample[2] > 0.02 then
				local EstSlope = Sample[2] / Dt
				if EstSlope >= 0.5 and EstSlope <= 8.0 then
					return EstSlope, 0
				end
			end
			return nil, nil
		end

		local SumX, SumY, SumXX, SumXY = 0, 0, 0, 0
		for Index, Sample in Shot.Samples do
			local X = Sample[1] - Shot.Start
			SumX += X
			SumY += Sample[2]
			SumXX += X * X
			SumXY += X * Sample[2]
		end
		local Denominator = Count * SumXX - SumX * SumX
		if math.abs(Denominator) < 1e-7 then
			local First, Last = Shot.Samples[1], Shot.Samples[Count]
			local Dt = Last[1] - First[1]
			if Dt > 0.02 then
				local EstSlope = (Last[2] - First[2]) / Dt
				if EstSlope >= 0.5 and EstSlope <= 8.0 then
					return EstSlope, First[2] - EstSlope * (First[1] - Shot.Start)
				end
			end
			return nil, nil
		end
		local Slope = (Count * SumXY - SumX * SumY) / Denominator
		if Slope < 0.5 or Slope > 10.0 then
			return nil, nil
		end
		local Intercept = (SumY - Slope * SumX) / Count
		return Slope, Intercept
	end

	local function GetReleaseTime()
		local Target = GetEffectiveTarget(Shot.Distance)
		local Shift = (Aural.Shooting.TimingOffset / 1000) + Calibration - GetLead()

		-- Adaptive moving/fadeaway compensation
		if Shot.Fadeaway then
			Shift = Shift - 0.008
		end

		if MeterMaps[Shot.Meter] then
			local Slope, Intercept = Fit()
			if Slope and Slope >= 0.5 then
				Shot.Slope = Slope
				Shot.Intercept = Intercept
				return Shot.Start + ((Target - Intercept) / Slope) + Shift
			end
		end

		-- Distance-aware progressive fallback: If regression hasn't stabilized yet or meter isn't mapped,
		-- fall back to calibrated distance-fill timing so 3s release with dead-on accuracy.
		local FillTime = GetDistanceFillTime(Shot.Distance)
		return Shot.Start + (FillTime * Target) + Shift
	end

	-- Single dedicated high-precision worker loop per shot: eliminates race conditions and micro-spins for sub-millisecond accuracy
	local function StartReleaseWorker(Generation)
		task.spawn(function()
			-- Coarse wait until ~20ms out
			while Shot.Active and not Shot.Released and Shot.Generation == Generation do
				local Target = Shot.PredictedReleaseTime or (Shot.Start + 0.38)
				local Remaining = Target - os.clock()
				if Remaining <= 0.022 then
					break
				end
				task.wait(math.max(Remaining - 0.016, 0.005))
			end

			-- Fine synchronization with PreRender until ~2.5ms out
			while Shot.Active and not Shot.Released and Shot.Generation == Generation do
				local Target = Shot.PredictedReleaseTime or (Shot.Start + 0.38)
				local Now = os.clock()
				if Now >= Target then
					Release()
					return
				end
				if Target - Now > 0.0025 then
					RunService.PreRender:Wait()
				else
					break
				end
			end

			-- Microsecond spin lock for the final 0 to 2.5ms window
			while Shot.Active and not Shot.Released and Shot.Generation == Generation do
				local Target = Shot.PredictedReleaseTime or (Shot.Start + 0.38)
				if os.clock() >= Target then
					Release()
					break
				end
			end
		end)
	end

	local function UpdatePrediction()
		if not Shot.Active or Shot.Released then
			return
		end
		local TargetTime = GetReleaseTime()
		if not TargetTime then
			return
		end

		Shot.PredictedReleaseTime = TargetTime

		if os.clock() >= TargetTime then
			Release()
			return
		end
	end

	local function BeginShot(MeterType)
		Shot.Generation += 1
		Shot.Active = true
		Shot.Start = os.clock()
		Shot.Meter = MeterType or Shot.Meter
		Shot.Samples = {}
		Shot.Slope = nil
		Shot.Intercept = nil
		Shot.PredictedReleaseTime = nil
		Shot.Released = false
		Shot.Final = nil
		Shot.Ours = false
		Shot.Auto = (os.clock() - AutoPending < 0.6)
		AutoPending = 0

		-- Distance & fadeaway calculations for clean 3-point arcs
		local Character = GetCharacter()
		local Root, Goal = GetRoot(Character), GetGoal(Character)
		if Character and Root and Goal then
			Shot.Distance = Flat(Goal - Root.Position).Magnitude
			local Vel = Root.AssemblyLinearVelocity or Vector3.zero
			Shot.Fadeaway = (Flat(Vel).Magnitude > 2) or (Character:GetAttribute("Sprinting") == true)
			AlignToBasket(Character)
		else
			Shot.Distance = 22
			Shot.Fadeaway = false
		end

		UpdatePrediction()
		StartReleaseWorker(Shot.Generation)
	end

	local function Learn(Grade, Value)
		if not Aural.Shooting.AutoCalibrate or not Shot.Ours or not Grade then
			return
		end
		local Index = table.find(Grades, Grade) or 5
		if Index == 5 then
			-- Perfect green: perfectly timed, lock calibration in permanently
			return
		end

		local Measured = MeterMaps[Shot.Meter] ~= nil and #Shot.Samples > 0 and Shot.Slope and Shot.Slope > 0
		local Stalled = Measured and (Shot.ReleasedAt - Shot.LastBeforeRelease > 0.07)
		local Error = 0
		local Target = GetEffectiveTarget(Shot.Distance)

		-- Direct numerical server feedback support if the server reported an exact percentage or delta
		local NumVal = tonumber(Value)
		if NumVal and NumVal > 10 then
			NumVal = NumVal / 100
		end
		if NumVal and NumVal >= 0.5 and NumVal <= 1.5 and Shot.Slope and Shot.Slope > 0 then
			Error = (Target - NumVal) / Shot.Slope
		elseif Measured and Shot.Final then
			Error = (Target - Shot.Final) / Shot.Slope
		end

		local Change = 0
		if Index < 4 then
			Change = math.max(Error, 0.005 * (4 - Index))
		elseif Index > 5 then
			Change = math.min(Stalled and -0.010 or Error, -0.005 * (Index - 5))
		elseif Index == 4 then
			Change = Stalled and -0.008 or math.max(Error, 0.003)
		end
		Change = math.clamp(Change * 0.5, -0.015, 0.015)
		Calibration = math.clamp(Calibration + Change, -0.15, 0.15)
		CalibrationLabel:Update(string.format("calibration: %+dms", math.round(Calibration * 1000)))
	end

	local function Bind(Character)
		for Index, Connection in BoundConnections do
			Connection:Disconnect()
		end
		BoundConnections = {}
		Bound = Character
		if not Character then
			return
		end
		table.insert(BoundConnections, Character:GetAttributeChangedSignal("meterOffset"):Connect(function()
			local Offset = Character:GetAttribute("meterOffset")
			local Map = MeterMaps[Shot.Meter]
			if not Shot.Active or typeof(Offset) ~= "Vector2" or not Map then
				return
			end
			local Progress = Map(Offset)
			local Now = os.clock()
			local Elapsed = Now - Shot.Start

			-- Stale packet filter: If shot just started and progress is already > 0.40,
			-- it's lingering from the previous shot! Ignore it until server resets meter.
			if Elapsed < 0.08 and Progress > 0.40 then
				return
			end

			-- Range clamp & validation: ignore negative or erratic outlier offsets
			if Progress < -0.05 or Progress > 1.25 then
				return
			end
			Progress = math.clamp(Progress, 0, 1.15)
			Shot.Final = Progress

			if not Shot.Released then
				local Prev = Shot.Samples[#Shot.Samples]
				-- Monotonic check: meter should not jump backwards by more than 0.08
				if not Prev or Progress >= (Prev[2] - 0.08) then
					table.insert(Shot.Samples, { Now, Progress })
					UpdatePrediction()
				end
			end
		end))
		table.insert(BoundConnections, Character:GetAttributeChangedSignal("Action"):Connect(function()
			if Character:GetAttribute("Action") == "Shooting" and (not Shot.Active or os.clock() - Shot.Start > 0.3) then
				BeginShot(nil)
			end
		end))
	end

	-- User manual press pre-alignment: squares up instantly on keypress before server even responds
	Connect(UserInputService.InputBegan, function(Input, GameProcessed)
		if GameProcessed then return end
		local Character = GetCharacter()
		if not Character or not HasBall(Character) then return end
		if Input.KeyCode == Enum.KeyCode.E or Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if not Shot.Active or os.clock() - Shot.Start > 0.4 then
				AlignToBasket(Character)
			end
		end
	end)

	Connect(Remotes.MeterRegister.OnClientEvent, function(Model, MeterType)
		if Model == Bound and (not Shot.Active or os.clock() - Shot.Start > 0.3) then
			BeginShot(MeterType)
		elseif Model == Bound then
			Shot.Meter = MeterType or Shot.Meter
			UpdatePrediction()
		end
	end)

	Connect(Remotes.MeterUnregister.OnClientEvent, function(Model)
		if Model == Bound then
			Shot.Active = false
		end
	end)

	Connect(Remotes.ShowFeedback.OnClientEvent, function(Model, Value, GradeIndex)
		if Model ~= Bound then
			return
		end
		local Grade = Grades[tonumber(GradeIndex) or 0]
		task.delay(0.1, function()
			Learn(Grade, Value)
			LastShotLabel:Update(string.format("last shot: %s%s", Grade or "?", Shot.Final and string.format(" (%d%%)", math.round(Shot.Final * 100)) or ""))
		end)
	end)

	local function CheckShot()
		local Character = GetCharacter()
		if Character ~= Bound then
			Bind(Character)
		end
		if not Character then
			return
		end

		if Shot.Active and not Shot.Released and (Aural.Shooting.PerfectTiming or Shot.Auto) then
			-- Keep facing the basket during shot for crisp square-up
			AlignToBasket(Character)

			if Character:GetAttribute("ReleasedShot") == true and os.clock() - Shot.Start > 0.1 then
				Shot.Released = true
			else
				local ReleaseTime = Shot.PredictedReleaseTime or GetReleaseTime()
				if (ReleaseTime and os.clock() >= ReleaseTime) or os.clock() - Shot.Start > 1.2 then
					Release()
				end
			end
		end
		if Shot.Active and os.clock() - Shot.Start > 3 then
			Shot.Active = false
		end
	end

	-- Sub-frame precision: check before render so the release is dispatched ahead of graphics rendering
	Connect(RunService.PreRender, CheckShot)

	Connect(RunService.Heartbeat, function()
		CheckShot()

		local Character = GetCharacter()
		if Aural.Shooting.AutoShoot and not Shot.Active and Character and HasBall(Character) and Character:GetAttribute("Action") == "" and os.clock() - LastAutoShot > 1.5 then
			local Root, Goal = GetRoot(Character), GetGoal(Character)
			if Root and Goal then
				local Distance = Flat(Goal - Root.Position).Magnitude
				local InRange = Distance <= Aural.Shooting.ShootRange
				local ThreeValid = (not Aural.Shooting.ThreePointOnly) or (Distance >= 21.5)
				if InRange and ThreeValid then
					LastAutoShot = os.clock()
					AutoPending = os.clock()
					AlignToBasket(Character)
					Fire(Remotes.Shoot, { Shoot = true, Input = "E" })
				end
			end
		end
	end)

	task.spawn(function()
		while Running do
			PingLabel:Update(string.format("ping: %dms", math.round(GetSmoothedPing() * 1000)))
			task.wait(1)
		end
	end)
end

-- // Range Circle
do
	local Circle = Instance.new("CylinderHandleAdornment")
	Circle.Name = HttpService:GenerateGUID(false)
	Circle.Adornee = workspace.Terrain
	Circle.Height = 0.12
	Circle.Transparency = 0.2
	Circle.AlwaysOnTop = false
	Circle.Visible = false
	Circle.Parent = GuiRoot

	local MagnetCircle = Circle:Clone()
	MagnetCircle.Name = HttpService:GenerateGUID(false)
	MagnetCircle.Parent = GuiRoot

	Connect(RunService.RenderStepped, function()
		local Character = GetCharacter()
		local Root = GetRoot(Character)

		MagnetCircle.Visible = Aural.Ball.Magnets and Aural.Ball.ShowRange and Root ~= nil
		if MagnetCircle.Visible then
			local Range = Aural.Ball.MagnetRange
			MagnetCircle.Radius = Range
			MagnetCircle.InnerRadius = math.max(Range - 0.25, 0)
			MagnetCircle.Color3 = Library.Theme.Accent
			MagnetCircle.CFrame = CFrame.new(Root.Position.X, Root.Position.Y - 2.9, Root.Position.Z) * CFrame.Angles(math.rad(90), 0, 0)
		end

		local Goal = Aural.Shooting.RangeCircle and Root and GetGoal(Character)
		Circle.Visible = Goal ~= nil
		if not Goal then
			return
		end
		local Radius = Aural.Shooting.ShootRange
		Circle.Radius = Radius
		Circle.InnerRadius = math.max(Radius - 0.35, 0)
		Circle.Color3 = Aural.Shooting.RangeCircleColor
		Circle.CFrame = CFrame.new(Goal.X, Root.Position.Y - 2.9, Goal.Z) * CFrame.Angles(math.rad(90), 0, 0)
	end)

	table.insert(Connections, { Disconnect = function()
		Circle:Destroy()
		MagnetCircle:Destroy()
	end })
end

-- // Dribble Moves & Auto Ankle Breaker
do
	local LastAnkle = 0

	local function DoMove(Move, Direction)
		local Character = GetCharacter()
		local Combos = MoveCombos[Move]
		if not Combos or not HasBall(Character) then
			return false
		end
		local Combo = Combos[Character:GetAttribute("Hand") == "R" and 2 or 1]
		Fire(Remotes.Dribble, Combo, Character:GetAttribute("Sprinting") == true, Direction or GetMoveDirection())
		return true
	end

	Connect(RunService.Heartbeat, function()
		if not Aural.Dribbling.AutoAnkleBreaker or os.clock() - LastAnkle < 1.2 then
			return
		end
		local Character = GetCharacter()
		local Root = GetRoot(Character)
		local Action = Character and Character:GetAttribute("Action")
		if not Root or not HasBall(Character) or (Action ~= "" and Action ~= "TripleThreat") then
			return
		end
		local Closest, ClosestDistance = nil, Aural.Dribbling.AnkleBreakRange
		for Index, Other in GetOthers(Character) do
			if IsOpponent(Other.Model, Character, true) then
				local Distance = (Other.Root.Position - Root.Position).Magnitude
				if Distance <= ClosestDistance then
					Closest, ClosestDistance = Other, Distance
				end
			end
		end
		if not Closest then
			return
		end
		-- Cut sideways past the defender, toward the side the ball is not on.
		local Away = Flat(Root.Position - Closest.Root.Position)
		Away = Away.Magnitude > 0.01 and Away.Unit or Flat(Root.CFrame.LookVector).Unit
		local Side = Vector3.new(-Away.Z, 0, Away.X) * (Character:GetAttribute("Hand") == "R" and -1 or 1)
		LastAnkle = os.clock()
		DoMove(Aural.Dribbling.AnkleBreakerMove, (Side + Away * 0.35).Unit)
	end)
end

-- // Auto Block
do
	local Blocked = setmetatable({}, { __mode = "k" })
	local LastBlock = 0

	local function Jump(Toward)
		local Proxy, Velocity, Gyro = GetProxy()
		if Gyro and Toward then
			Gyro.CFrame = CFrame.lookAt(Proxy.Position, Vector3.new(Toward.X, Proxy.Position.Y, Toward.Z))
		end
		-- Same pair of calls the game sends for the jump key.
		Fire(Remotes.Shoot, { Shoot = true, Input = "E", UseSpace = true })
		Fire(Remotes.Jump)
		task.delay(0.3, function()
			Fire(Remotes.Shoot, { Shoot = false })
		end)
	end

	Connect(RunService.Heartbeat, function()
		if not Aural.Defense.AutoBlock or os.clock() - LastBlock < 0.8 then
			return
		end
		local Character = GetCharacter()
		local Root = GetRoot(Character)
		if not Root or HasBall(Character) or Character:GetAttribute("Action") ~= "" then
			return
		end
		for Index, Other in GetOthers(Character) do
			local Action = Other.Model:GetAttribute("Action")
			if BlockActions[Action] and IsOpponent(Other.Model, Character, Aural.Defense.BlockTeamCheck) and not (Blocked[Other.Model] and os.clock() - Blocked[Other.Model] < 1.5) then
				if (Other.Root.Position - Root.Position).Magnitude <= Aural.Defense.BlockRange then
					Blocked[Other.Model] = os.clock()
					LastBlock = os.clock()
					task.delay(Aural.Defense.BlockDelay / 1000, function()
						-- A pump fake ends the shooting action before the delay is up.
						if Running and BlockActions[Other.Model:GetAttribute("Action")] and (Other.Root.Position - Root.Position).Magnitude <= Aural.Defense.BlockRange + 4 then
							Jump(Other.Root.Position)
						end
					end)
					return
				end
			end
		end
	end)
end

-- // Movement: Auto Guard, Dribble Glide, Speed Boost & Character State
-- The game sets the proxy's velocity on Heartbeat; Stepped runs after that and right before physics, so these
-- overrides are the ones the physics step uses.
do
	local Guarding, Sprinting = false, false
	local LastGuard = 0
	local SavedDelays = nil
	local ShownTarget = false

	local function ShowTarget(Model)
		if Model ~= ShownTarget then
			ShownTarget = Model
			GuardStatus:Update("guarding: " .. (Model and Model.Name or "none"))
		end
	end

	local function StopGuard()
		ShowTarget(nil)
		if Guarding then
			Guarding = false
			Fire(Remotes.HoldG, { HoldingG = false })
		end
		if Sprinting then
			Sprinting = false
			Fire(Remotes.Sprint, false)
		end
	end

	local function FindGuardTarget(Character, Root)
		local Closest, ClosestDistance = nil, Aural.Defense.GuardRange
		for Index, Other in GetOthers(Character) do
			if IsOpponent(Other.Model, Character, Aural.Defense.TeamCheck) and (not Aural.Defense.BallHandlerOnly or HasBall(Other.Model)) then
				local Distance = (Other.Root.Position - Root.Position).Magnitude
				if Distance < ClosestDistance then
					Closest, ClosestDistance = Other, Distance
				end
			end
		end
		return Closest
	end

	-- A ball counts as loose when nobody's ball weld holds it. Balls still on a shot are left alone unless asked.
	local LastTeleport = 0

	local function FindLooseBall(Root)
		local Folder = workspace:FindFirstChild("Basketballs")
		if not Folder then
			return nil
		end
		local Held = {}
		if Characters then
			for Index, Model in Characters:GetChildren() do
				local ModelRoot = Model:FindFirstChild("HumanoidRootPart")
				local Weld = ModelRoot and ModelRoot:FindFirstChild("Basketball")
				if Weld and Weld:IsA("Motor6D") and Weld.Part1 then
					Held[Weld.Part1] = true
				end
			end
		end
		local Closest, ClosestDistance = nil, Aural.Ball.MagnetRange
		for Index, Ball in Folder:GetChildren() do
			if Ball:IsA("BasePart") and not Held[Ball] and Ball:GetAttribute("Active") ~= false and not (Aural.Ball.SkipShots and Ball:GetAttribute("MidShot")) then
				local Distance = Flat(Ball.Position - Root.Position).Magnitude
				if Distance < ClosestDistance then
					Closest, ClosestDistance = Ball, Distance
				end
			end
		end
		return Closest
	end

	-- No Debounce lowers the game's own input delay settings and puts the old ones back when it is turned off.
	SetDebounce = function(Enabled)
		task.spawn(function()
			if Enabled then
				if not SavedDelays then
					SavedDelays = { ShootDelay = 0.15, DribbleDelay = 0.15 }
					pcall(function()
						local Profile = Remotes.GetProfileData:InvokeServer()
						local Keyboard = Profile and Profile.SavedSettings and Profile.SavedSettings.Gameplay and Profile.SavedSettings.Gameplay.Keyboard
						if Keyboard then
							SavedDelays.ShootDelay = Keyboard.ShootDelay or SavedDelays.ShootDelay
							SavedDelays.DribbleDelay = Keyboard.DribbleDelay or SavedDelays.DribbleDelay
						end
					end)
				end
				Fire(Remotes.UpdateSetting, { "Gameplay", "Keyboard" }, "ShootDelay", 0)
				Fire(Remotes.UpdateSetting, { "Gameplay", "Keyboard" }, "DribbleDelay", 0)
			elseif SavedDelays then
				Fire(Remotes.UpdateSetting, { "Gameplay", "Keyboard" }, "ShootDelay", SavedDelays.ShootDelay)
				Fire(Remotes.UpdateSetting, { "Gameplay", "Keyboard" }, "DribbleDelay", SavedDelays.DribbleDelay)
				SavedDelays = nil
			end
		end)
	end

	Connect(RunService.Stepped, function(Time, DeltaTime)
		local Character = GetCharacter()
		local Root = GetRoot(Character)
		local Proxy, Velocity, Gyro = GetProxy()
		if not Root or not Proxy then
			StopGuard()
			return
		end
		local Action = Character:GetAttribute("Action")
		local Player = Aural.Player

		-- These are server attributes; the overrides only change what this client's movement code reads.
		if Player.InfiniteStamina then
			Character:SetAttribute("Stamina", Character:GetAttribute("MaxStamina") or 100)
		end
		if Player.NoColdZone and Character:GetAttribute("Cold") then
			Character:SetAttribute("Cold", false)
		end
		if Player.NoDebounce and Character:GetAttribute("Debounce") then
			Character:SetAttribute("Debounce", false)
		end
		if Player.AutoTakeover then
			local Type = Character:GetAttribute("TakeoverType")
			if type(Type) == "string" and Type ~= "" and Type ~= "That Guy" and not Character:GetAttribute("Takeover") then
				Character:SetAttribute("Takeover", true)
				Character:SetAttribute("TakeoverFill", 100)
			end
		end
		if Player.NoStun and Character:GetAttribute("CanMove") == false and Character:GetAttribute("ServerVelocity") == nil and not OwnActions[Action] then
			Character:SetAttribute("CanMove", true)
			Character:SetAttribute("CanTurn", true)
		end

		local Current = Velocity.Velocity
		local CanMove = Character:GetAttribute("CanMove")

		-- // Ball Magnets
		local Ball = Aural.Ball.Magnets and CanMove and not HasBall(Character) and FindLooseBall(Root)
		if Ball then
			local Offset = Flat(Ball.Position - Proxy.Position)
			if Aural.Ball.MagnetMode == "Teleport" then
				if os.clock() - LastTeleport > 0.3 and Offset.Magnitude > 1 then
					LastTeleport = os.clock()
					Proxy.CFrame = CFrame.new(Ball.Position.X, Proxy.Position.Y, Ball.Position.Z) * Proxy.CFrame.Rotation
				end
			elseif Offset.Magnitude > 0.5 then
				Velocity.Velocity = Offset.Unit * Aural.Ball.MagnetSpeed + Vector3.new(0, Current.Y, 0)
			end
			if Guarding then
				StopGuard()
			end
			return
		end

		-- // Auto Guard
		local Target = Aural.Defense.AutoGuard and CanMove and not HasBall(Character) and FindGuardTarget(Character, Root)
		if Target then
			local Goal = GetGoal(Target.Model) or Root.Position
			local ToGoal = Flat(Goal - Target.Root.Position)
			ToGoal = ToGoal.Magnitude > 0.01 and ToGoal.Unit or Vector3.zero
			local Offset = Flat(Target.Root.Position + ToGoal * Aural.Defense.GuardDistance - Proxy.Position)
			local Limit = Aural.Defense.GuardSprint and 17.35 or 14
			if Player.SpeedBoost then
				Limit = math.max(Limit, Player.Speed)
			end
			local Speed = math.min(Offset.Magnitude * Aural.Defense.GuardStrength / 10, Limit)
			Velocity.Velocity = (Offset.Magnitude > 0.25 and Offset.Unit * Speed or Vector3.zero) + Vector3.new(0, Current.Y, 0)
			if Gyro then
				Gyro.CFrame = CFrame.lookAt(Proxy.Position, Vector3.new(Target.Root.Position.X, Proxy.Position.Y, Target.Root.Position.Z))
			end
			if not Guarding then
				Guarding = true
				Fire(Remotes.HoldG, { HoldingG = true })
			end
			if Aural.Defense.GuardSprint ~= Sprinting then
				Sprinting = Aural.Defense.GuardSprint
				Fire(Remotes.Sprint, Sprinting)
			end
			ShowTarget(Target.Model)
			LastGuard = os.clock()
			return
		end
		-- A short grace period, so a steal attempt or a frame without a target does not drop and re-press guard.
		if os.clock() - LastGuard > 0.4 then
			StopGuard()
		end

		-- // Dribble Glide
		-- The game eases the proxy toward the move's velocity every frame, so changing that velocity would compound.
		-- Instead the proxy is carried a little further along the way it is already moving.
		if Aural.Dribbling.DribbleGlide and Action == "Dribbling" then
			local Moving = Flat(Proxy.AssemblyLinearVelocity)
			if Moving.Magnitude > 1 then
				Proxy.CFrame += Moving.Unit * (Aural.Dribbling.GlideSpeed / 100 * 16) * DeltaTime
			end
			return
		end

		-- // Speed Boost
		local Horizontal = Flat(Current)
		if Player.SpeedBoost and CanMove and Horizontal.Magnitude > 2 and Horizontal.Magnitude < Player.Speed then
			Velocity.Velocity = Horizontal.Unit * Player.Speed + Vector3.new(0, Current.Y, 0)
		end

		-- // CFrame Speed
		if Player.CframeSpeed and CanMove then
			local Direction = GetMoveDirection()
			if Direction.Magnitude > 0 then
				Proxy.CFrame += Direction * Player.CframeSpeedValue * DeltaTime
			end
		end
	end)

	table.insert(Connections, { Disconnect = function()
		StopGuard()
		if Aural.Player.NoDebounce then
			SetDebounce(false)
		end
		local Character = GetCharacter()
		if Character and Aural.Player.AutoTakeover then
			Character:SetAttribute("Takeover", false)
		end
	end })
end

-- // Visuals: Post Effects, Fullbright, FOV & Spectate
do
	local DisabledEffects = {}
	local SavedLighting = nil
	local LightingProperties = { "Brightness", "ClockTime", "FogEnd", "GlobalShadows", "Ambient", "OutdoorAmbient" }
	local SpectateType = nil

	local function UpdateEffects()
		local Camera = workspace.CurrentCamera
		if Aural.Visuals.RemovePostEffects then
			for Index, Root in { Lighting, Camera } do
				for Index2, Effect in Root:GetDescendants() do
					if Effect:IsA("PostEffect") and Effect.Enabled then
						DisabledEffects[Effect] = true
						Effect.Enabled = false
					end
				end
			end
		else
			for Effect in DisabledEffects do
				if Effect.Parent then
					Effect.Enabled = true
				end
			end
			table.clear(DisabledEffects)
		end
	end

	local function UpdateLighting()
		if Aural.Visuals.Fullbright then
			if not SavedLighting then
				SavedLighting = {}
				for Index, Property in LightingProperties do
					SavedLighting[Property] = Lighting[Property]
				end
			end
			Lighting.Brightness = 2
			Lighting.ClockTime = 14
			Lighting.FogEnd = 100000
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
			Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		elseif SavedLighting then
			for Property, Value in SavedLighting do
				Lighting[Property] = Value
			end
			SavedLighting = nil
		end
	end

	task.spawn(function()
		while Running do
			UpdateEffects()
			UpdateLighting()
			task.wait(0.5)
		end
	end)

	-- Bound last so the game's own camera has already moved this frame.
	RunService:BindToRenderStep("AuralCamera", Enum.RenderPriority.Last.Value, function()
		local Camera = workspace.CurrentCamera
		if Aural.Visuals.CustomFov then
			Camera.FieldOfView = Aural.Visuals.Fov
		end

		local Target = Aural.Visuals.Spectate and Aural.Visuals.SpectateTarget and Characters and Characters:FindFirstChild(Aural.Visuals.SpectateTarget)
		local Root = GetRoot(Target)
		if Root then
			if not SpectateType then
				SpectateType = Camera.CameraType
			end
			Camera.CameraType = Enum.CameraType.Scriptable
			local Focus = Root.Position + Vector3.new(0, 2.5, 0)
			local Look = Flat(Root.CFrame.LookVector)
			Look = Look.Magnitude > 0.01 and Look.Unit or Vector3.new(0, 0, -1)
			Camera.CFrame = CFrame.lookAt(Focus - Look * 13 + Vector3.new(0, 4, 0), Focus)
		elseif SpectateType then
			Camera.CameraType = SpectateType
			SpectateType = nil
		end
	end)

	table.insert(Connections, { Disconnect = function()
		RunService:UnbindFromRenderStep("AuralCamera")
		if SpectateType then
			workspace.CurrentCamera.CameraType = SpectateType
		end
		Aural.Visuals.RemovePostEffects = false
		Aural.Visuals.Fullbright = false
		UpdateEffects()
		UpdateLighting()
	end })
end

-- // Auto Sprint
do
	local AutoSprinting = false
	local LastSprint = 0

	Connect(RunService.Heartbeat, function()
		local Character = GetCharacter()
		if not Aural.Player.AutoSprint or not Character then
			if AutoSprinting then
				AutoSprinting = false
				Fire(Remotes.Sprint, false)
			end
			return
		end
		local Moving = GetMoveDirection().Magnitude > 0
		if Moving and not Character:GetAttribute("Sprinting") and os.clock() - LastSprint > 0.3 then
			LastSprint = os.clock()
			AutoSprinting = true
			Fire(Remotes.Sprint, true)
		elseif not Moving and AutoSprinting and not UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			AutoSprinting = false
			Fire(Remotes.Sprint, false)
		end
	end)
end

-- // Cosmetics
-- Built the same way the game's own Appearance code builds a character, but only on this client. The game's own
-- pieces of a replaced type are hidden rather than removed, so turning a slot back to None shows them again.
do
	local AttachParts = { Hats = "Head", Hair = "Head", FacialHair = "Head", Glasses = "Head", Chain = "UpperTorso", Backpack = "UpperTorso" }
	local Unscaled = { Hats = true, Hair = true, FacialHair = true, Glasses = true }
	local Applied = {}

	local function GetScales(Character)
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		local function Value(Name)
			local Object = Humanoid and Humanoid:FindFirstChild(Name)
			return Object and Object.Value or 1
		end
		return Value("BodyWidthScale"), Value("BodyHeightScale"), Value("BodyDepthScale"), Value("HeadScale")
	end

	local function Prepare(Object)
		for Index, Part in { Object, table.unpack(Object:GetDescendants()) } do
			if Part:IsA("BasePart") then
				Part.Anchored = false
				Part.CanCollide = false
				Part.CanQuery = false
				Part.CanTouch = false
				Part.Massless = true
			end
		end
	end

	-- The game's ScaleAccessory: size by the body scales, and the weld offset by the same scales.
	local function Scale(Character, Object, Weld, Original)
		local Width, Height, Depth = GetScales(Character)
		Object.Size = Object.Size * Vector3.new(Width, Height, Depth)
		local _, _, _, R00, R01, R02, R10, R11, R12, R20, R21, R22 = Original:GetComponents()
		Weld.C1 = CFrame.new(Original.X * Width, Original.Y / 1.135 * Height, Original.Z * Depth, R00, R01, R02, R10, R11, R12, R20, R21, R22)
	end

	-- Several slots can hide the same piece (a mascot hides hair a hair swap already hid), so every hidden piece
	-- keeps its real transparency once and only comes back when the last slot hiding it lets go.
	local HiddenBy = {}

	local function Hide(State, Object)
		if not Object:IsA("BasePart") or State.Hidden[Object] then
			return
		end
		local Entry = HiddenBy[Object]
		if not Entry then
			Entry = { Transparency = Object.Transparency, Owners = 0 }
			HiddenBy[Object] = Entry
		end
		Entry.Owners += 1
		State.Hidden[Object] = true
		Object.Transparency = 1
	end

	local function Clear(Type)
		local State = Applied[Type]
		if not State then
			return
		end
		for Index, Object in State.Objects do
			Object:Destroy()
		end
		for Object in State.Hidden do
			local Entry = HiddenBy[Object]
			if Entry then
				Entry.Owners -= 1
				if Entry.Owners <= 0 then
					HiddenBy[Object] = nil
					if Object.Parent then
						Object.Transparency = Entry.Transparency
					end
				end
			end
		end
		Applied[Type] = nil
	end

	local function Weld(Part0, Part1, C0, C1)
		local Joint = Instance.new("Weld")
		Joint.Name = "AttachmentWeld"
		Joint.Part0 = Part0
		Joint.Part1 = Part1
		Joint.C0 = C0
		Joint.C1 = C1
		Joint.Parent = Part1
		return Joint
	end

	local function HideOwn(Character, State, Type)
		local Folder = Character:FindFirstChild("Accessories")
		if Type == "Shoes" then
			for Index, Side in { "LeftShoe", "RightShoe" } do
				local Shoe = Character:FindFirstChild(Side)
				if Shoe then
					Hide(State, Shoe)
				end
			end
		elseif Folder then
			for Index, Object in Folder:GetChildren() do
				if Object:GetAttribute("Type") == Type and not Object:GetAttribute("Aural") then
					Hide(State, Object)
				end
			end
		end
	end

	local function ApplyAccessory(Character, Type, Name)
		local Source = Accessories[Type]:FindFirstChild(Name, true)
		local Part = Character:FindFirstChild(AttachParts[Type])
		local Folder = Character:FindFirstChild("Accessories")
		local Attachment = Source and Source:FindFirstChildOfClass("Attachment")
		if not (Part and Folder and Attachment) then
			return nil
		end
		local Rig = Part:FindFirstChild(Attachment.Name)
		if not Rig then
			for Index, Object in Character:GetDescendants() do
				if Object:IsA("Attachment") and Object.Name == Attachment.Name and Object.Parent:IsA("BasePart") and not Object.Parent:IsDescendantOf(Folder) then
					Rig = Object
					break
				end
			end
		end
		if not Rig then
			return nil
		end
		local Clone = Source:Clone()
		Clone:SetAttribute("Aural", true)
		Clone:SetAttribute("Type", Type)
		Prepare(Clone)
		local Joint = Weld(Rig.Parent, Clone, Rig.CFrame, Clone:FindFirstChildOfClass("Attachment").CFrame)
		if not Unscaled[Type] then
			Scale(Character, Clone, Joint, Joint.C1)
		end
		Clone.Parent = Folder
		return { Clone }
	end

	local function ApplyShoes(Character, Key)
		local Variant = ShoeLookup[Key]
		if not Variant then
			return nil
		end
		local Objects = {}
		for Index, Side in { "Left", "Right" } do
			local Source = Variant:FindFirstChild(Side .. "Shoe")
			local Foot = Character:FindFirstChild(Side .. "Foot")
			local Ankle = Foot and Foot:FindFirstChild(Side .. "AnkleRigAttachment")
			local Rig = Source and Source:FindFirstChild("RigAttachment")
			if Ankle and Rig then
				local Clone = Source:Clone()
				Clone.Name = "Aural" .. Side .. "Shoe"
				Prepare(Clone)
				local Joint = Weld(Foot, Clone, Ankle.CFrame, Clone.RigAttachment.CFrame)
				Scale(Character, Clone, Joint, Joint.C1)
				Clone.Parent = Character
				table.insert(Objects, Clone)
			end
		end
		return Objects
	end

	-- The game's ApplyMascot and UpdateMascotScale: each mascot piece is welded to the matching body part at its
	-- rest pose, worked out through the Motor6D chain back to the root, then scaled to the body.
	local function ApplyMascot(Character, Name, State)
		local Source = Accessories.Mascots:FindFirstChild(Name)
		local MascotRoot = Source and Source:FindFirstChild("HumanoidRootPart")
		local Root = Character:FindFirstChild("HumanoidRootPart")
		if not (MascotRoot and Root) then
			return nil
		end
		local Width, Height, Depth, HeadScale = GetScales(Character)
		local Vertical = Height / 1.135
		local Neck = nil
		local UpperTorso = Character:FindFirstChild("UpperTorso")
		local NeckAttachment = UpperTorso and (UpperTorso:FindFirstChild("NeckRigAttachment") or UpperTorso:FindFirstChild("NeckAttachment"))
		if NeckAttachment then
			Neck = Root.CFrame:PointToObjectSpace(NeckAttachment.WorldPosition)
		end

		local Objects = {}
		for Index, Piece in Source:GetChildren() do
			local Original = Piece:IsA("BasePart") and Piece ~= MascotRoot and Character:FindFirstChild(Piece.Name)
			if Original and Original:IsA("BasePart") then
				local BaseOffset = MascotRoot.CFrame:ToObjectSpace(Piece.CFrame)
				local Position = BaseOffset.Position
				local IsHead = Piece.Name == "Head"
				local Target, Size
				if IsHead and Neck then
					Target = Neck + (Position - Vector3.new(Neck.X / Width, Neck.Y / Vertical, Neck.Z / Depth)) * HeadScale
					Size = Vector3.new(HeadScale, HeadScale, HeadScale)
				else
					Target = Vector3.new(Position.X * Width, Position.Y * Vertical, Position.Z * Depth)
					Size = Vector3.new(Width, Vertical, Depth)
				end

				local Chain = CFrame.identity
				local Current = Original
				while Current ~= Root do
					local Motor = Current:FindFirstChildOfClass("Motor6D")
					if not (Motor and Motor.Part0 and Motor.Part1 == Current) then
						break
					end
					Chain = Motor.C0 * Motor.C1:Inverse() * Chain
					Current = Motor.Part0
				end

				local Clone = Piece:Clone()
				Clone.Name = Piece.Name .. "_AuralMascot"
				Prepare(Clone)
				Clone.Size = Piece.Size * Size
				local Mesh = Clone:FindFirstChildOfClass("SpecialMesh")
				if Mesh then
					Mesh.Scale = Mesh.Scale * Size
				end
				Weld(Original, Clone, Chain:Inverse() * CFrame.new(Target) * (BaseOffset - Position), CFrame.identity)
				Clone.Parent = Original.Parent
				Hide(State, Original)
				table.insert(Objects, Clone)
			end
		end

		-- Like the game, a mascot hides the face pieces, shoes and every accessory.
		for Index, PartName in { "Nose", "LeftEar", "RightEar", "LeftShoe", "RightShoe", "AuralLeftShoe", "AuralRightShoe" } do
			local Part = Character:FindFirstChild(PartName)
			if Part then
				Hide(State, Part)
			end
		end
		local Folder = Character:FindFirstChild("Accessories")
		if Folder then
			for Index, Object in Folder:GetChildren() do
				Hide(State, Object)
			end
		end
		return Objects
	end

	local function Ensure(Character, Type)
		local Choice = Aural.Cosmetics[Type]
		local State = Applied[Type]
		if not Choice or Choice == "None" then
			Clear(Type)
			return
		end
		if State and State.Character == Character and State.Choice == Choice then
			for Index, Object in State.Objects do
				if not Object.Parent then
					State = nil
					break
				end
			end
		else
			State = nil
		end
		if State then
			-- The game re-dresses the character now and then; keep its replaced pieces hidden.
			if Type == "Mascot" then
				local Folder = Character:FindFirstChild("Accessories")
				if Folder then
					for Index, Object in Folder:GetChildren() do
						Hide(State, Object)
					end
				end
			else
				HideOwn(Character, State, Type)
			end
			return
		end

		Clear(Type)
		State = { Character = Character, Choice = Choice, Objects = {}, Hidden = {} }
		local Objects
		if Type == "Shoes" then
			Objects = ApplyShoes(Character, Choice)
		elseif Type == "Mascot" then
			Objects = ApplyMascot(Character, Choice, State)
		else
			Objects = ApplyAccessory(Character, Type, Choice)
		end
		State.Objects = Objects or {}
		if Type ~= "Mascot" then
			HideOwn(Character, State, Type)
		end
		Applied[Type] = State
	end

	local Order = { "Hats", "Hair", "FacialHair", "Glasses", "Chain", "Backpack", "Shoes", "Mascot" }

	RefreshCosmetics = function()
		local Character = GetCharacter()
		if not Character or not Accessories then
			return
		end
		for Index, Type in Order do
			local Ok, Problem = pcall(Ensure, Character, Type)
			if not Ok then
				Applied[Type] = nil
			end
		end
	end

	task.spawn(function()
		while Running do
			RefreshCosmetics()
			task.wait(1)
		end
	end)

	table.insert(Connections, { Disconnect = function()
		for Index, Type in Order do
			Clear(Type)
		end
	end })
end

-- // Goal Effect & Green Celebration
-- The game finds a green's rim and trail effects by name in Assets.Models.GreenEffects each time one plays, so every
-- entry is swapped for a copy of the chosen effect. Only this client's copy of the assets changes.
do
	local Swapped = {}

	local function Restore()
		for Index = #Swapped, 1, -1 do
			local Entry = Swapped[Index]
			Entry.Copy:Destroy()
			if Entry.Original then
				Entry.Original.Parent = Entry.Folder
			end
		end
		table.clear(Swapped)
	end

	local function Swap(Kind, Choice)
		local Folder = EffectAssets:FindFirstChild(Kind)
		local Source = Folder and Folder:FindFirstChild(Choice)
		if not Source then
			return
		end
		for Index, Entry in Folder:GetChildren() do
			if Entry ~= Source then
				local Copy = Source:Clone()
				Copy.Name = Entry.Name
				Entry.Parent = nil
				Copy.Parent = Folder
				table.insert(Swapped, { Folder = Folder, Original = Entry, Copy = Copy })
			end
		end
	end

	ApplyEffects = function()
		Restore()
		if not Aural.Effects.GoalEffect then
			return
		end
		Swap("Goal", Aural.Effects.GoalEffectName)
		if Aural.Effects.IncludeTrail then
			Swap("Trail", Aural.Effects.GoalEffectName)
		end
	end

	-- An equipped effect with no assets of its own would show nothing, so it gets a copy for next time.
	Connect(Remotes.RunGreenEffect.OnClientEvent, function(Model, Ball, Goal, Time, Name)
		if not Aural.Effects.GoalEffect or type(Name) ~= "string" then
			return
		end
		for Index, Kind in { "Goal", "Trail" } do
			local Folder = EffectAssets:FindFirstChild(Kind)
			local Source = Folder and Folder:FindFirstChild(Aural.Effects.GoalEffectName)
			if Source and not Folder:FindFirstChild(Name) and (Kind == "Goal" or Aural.Effects.IncludeTrail) then
				local Copy = Source:Clone()
				Copy.Name = Name
				Copy.Parent = Folder
				table.insert(Swapped, { Folder = Folder, Copy = Copy })
			end
		end
	end)

	Connect(Remotes.GreenCelebration.OnClientEvent, function(Kind)
		if not Aural.Effects.AutoCelebrate then
			return
		end
		local Package = Aural.Effects.Celebration2
		if type(Kind) == "string" and string.find(Kind, "Finisher", 1, true) then
			Package = Aural.Effects.Finisher
		elseif type(Kind) == "string" and string.find(Kind, "3PT", 1, true) then
			Package = Aural.Effects.Celebration3
		end
		task.delay(Aural.Effects.CelebrateDelay, function()
			if Running and Package then
				Fire(Remotes.GreenAnimation, Package)
			end
		end)
	end)

	table.insert(Connections, { Disconnect = Restore })
end

-- // Unload
Library.OnUnload = function()
	Running = false
	for Index, Connection in Connections do
		pcall(function()
			Connection:Disconnect()
		end)
	end
	table.clear(Connections)
end

Notify("Aural", "Loaded. Press F5 to toggle the menu.")
