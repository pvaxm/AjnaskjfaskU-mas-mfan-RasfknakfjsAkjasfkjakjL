if not game:IsLoaded() then game.Loaded:Wait() end

if not getgenv then getfenv().getgenv = function() return _G end end
if getgenv().aural then
    game:GetService("Players").LocalPlayer:Kick("please do not execute twice, this will break aural.")
		return
end
getgenv().aural = true

task.wait(1)

for _, actor in pairs(getactors()) do
    run_on_actor(actor, [[
        local reporter = filtergc("table", {
            Keys = { 3 },
            KeyValuePairs = { [2] = ":anticheat:" }
        }, true);

        if not reporter then
            return;
        end;

        local original;
        original = hookfunction(reporter[0], function(...)
            local event = ...;

            -- Log what the hooked function receives
            --warn("[bypass] arguments", ...);
            if type(event) == "string" then
                --warn("[bypass] string:", event);
            end;

            local is_report = (type(event) == "string") and (event:find("anticheat") ~= nil);

            if not is_report then
                return original(...);
            end;
            -- is_report is true: block directly, return nil
        end);
    ]]);
end;

for _, actor in pairs(getactors()) do
	run_on_actor(actor, [=[
		local players = game:GetService("Players")
		local player = players.LocalPlayer
		local char = player.Character or player.CharacterAdded:Wait()
		local hum = char:WaitForChild("Humanoid")

		local conns = getconnections(hum.MoveToFinished)
		local conns2 = getconnections(hum.Changed)
		--print("Connection count:", #conns)
		--print("Connection count:", #conns2)

		for i, conn in conns do
			--print(i, conn.State, conn.Function)
			if conn.Function then
				local src, line = debug.info(conn.Function, "sl")
				--print("Script:", src, "Line:", line)
				conn:Disable()
				--print("disabled")
			end
		end

		for i, conn in conns2 do
			if conn.Function then
            --print(conn.Function)
            local src, line = debug.info(conn.Function, "sl")
				--print("Script:", src, "Line:", line)
				conn:Disable()
				--print("more disabled")
			end
		end
	]=])
end


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
        if active then
            task.spawn(keybindAction)
        end
        return
    end

    if obj.Keybind.Mode == "Hold" then
        obj:Set(active)
    else
        obj:Toggle()
    end
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

local startTime = os.clock()
local syn = rawget(_G, "syn")
local fluxus = rawget(_G, "fluxus")

local Janitor = (function()
    local Janitor = {}
    Janitor.__index = Janitor
    Janitor.ClassName = "Janitor"

    local DEFAULT_METHODS = { "Destroy", "Disconnect", "destroy", "disconnect", "Cleanup" }

    local function runCleanup(entry)
        local obj, method = entry.obj, entry.method
        local kind = typeof(obj)

        if method then
            if method == true then
                if type(obj) == "function" then obj() end
                return
            end
            local fn = obj[method]
            if type(fn) == "function" then fn(obj) end
            return
        end

        if kind == "function" then obj()
        elseif kind == "RBXScriptConnection" then
            if obj.Connected then obj:Disconnect() end
        elseif kind == "Instance" then obj:Destroy()
        elseif kind == "thread" then
            if coroutine.status(obj) ~= "dead" and obj ~= coroutine.running() then task.cancel(obj) end
        elseif kind == "table" or kind == "userdata" then
            for _, name in ipairs(DEFAULT_METHODS) do
                local ok, fn = pcall(function() return obj[name] end)
                if ok and type(fn) == "function" then fn(obj); return end
            end
        end
    end

    function Janitor.new()
        return setmetatable({ _entries = {}, _named = {}, _cleaning = false, _destroyed = false }, Janitor)
    end

    function Janitor.is(x)
        return type(x) == "table" and getmetatable(x) == Janitor
    end

    function Janitor:Add(obj, method, name)
        if self._destroyed then
            pcall(runCleanup, { obj = obj, method = method })
            return obj
        end
        if name ~= nil then self:Remove(name) end
        local entry = { obj = obj, method = method, name = name }
        table.insert(self._entries, entry)
        if name ~= nil then self._named[name] = entry end
        return obj
    end

    function Janitor:Connect(signal, fn, name)
        return self:Add(signal:Connect(fn), nil, name)
    end

    function Janitor:Spawn(fn, ...)
        local thread = task.spawn(fn, ...)
        return self:Add(thread)
    end

    function Janitor:Delay(t, fn, ...)
        local thread = task.delay(t, fn, ...)
        return self:Add(thread)
    end

    function Janitor:Sub(name)
        local child = Janitor.new()
        self:Add(child, "Destroy", name)
        return child
    end

    function Janitor:Get(name)
        local entry = self._named[name]
        return entry and entry.obj or nil
    end

    function Janitor:Remove(name)
        local entry = self._named[name]
        if not entry then return false end
        self._named[name] = nil
        for i, e in ipairs(self._entries) do
            if e == entry then table.remove(self._entries, i); break end
        end
        local ok, err = pcall(runCleanup, entry)
        if not ok then warn("[Janitor] cleanup error (" .. tostring(name) .. "): " .. tostring(err)) end
        return true
    end

    function Janitor:Cleanup()
        if self._cleaning then return end
        self._cleaning = true
        local entries = self._entries
        self._entries = {}
        self._named = {}
        for i = #entries, 1, -1 do
            local ok, err = pcall(runCleanup, entries[i])
            if not ok then warn("[Janitor] cleanup error: " .. tostring(err)) end
        end
        self._cleaning = false
    end

    function Janitor:Destroy()
        self:Cleanup()
        self._destroyed = true
    end

    function Janitor:LinkToInstance(instance)
        local conn
        conn = instance.Destroying:Connect(function()
            if conn then conn:Disconnect() end
            self:Cleanup()
        end)
        return self:Add(conn)
    end

    function Janitor:IsCleaning() return self._cleaning end
    function Janitor:Count() return #self._entries end

    local env = (getgenv and getgenv()) or _G

    local function fromExecutor()
        if checkcaller then return checkcaller() end
        return true
    end

    local function autoAdd(obj, kind)
        local st = env.__JanitorAutoTrack
        if not st or not st.active then return end
        local j = st.janitor
        if not j or j._cleaning or j._destroyed then return end
        if not st.want[kind] then return end
        if not fromExecutor() then return end
        j:Add(obj)
    end

    local function installHooks(st)
        if not (hookfunction and newcclosure) then
            warn("[Janitor] AutoTrack needs hookfunction + newcclosure")
            return false
        end

        pcall(function()
            local sample = game.Changed
            local oldConnect
            oldConnect = hookfunction(sample.Connect, newcclosure(function(sig, fn, ...)
                local conn = oldConnect(sig, fn, ...)
                autoAdd(conn, "connections")
                return conn
            end))
            st.installed.Connect = true
        end)

        pcall(function()
            local sample = game.Changed
            local oldOnce
            oldOnce = hookfunction(sample.Once, newcclosure(function(sig, fn, ...)
                local conn = oldOnce(sig, fn, ...)
                autoAdd(conn, "connections")
                return conn
            end))
            st.installed.Once = true
        end)

        pcall(function()
            local oldNew
            oldNew = hookfunction(Instance.new, newcclosure(function(...)
                local inst = oldNew(...)
                autoAdd(inst, "instances")
                return inst
            end))
            st.installed.InstanceNew = true
        end)

        for _, nm in ipairs({ "spawn", "delay", "defer" }) do
            pcall(function()
                local old
                old = hookfunction(task[nm], newcclosure(function(...)
                    local th = old(...)
                    if typeof(th) == "thread" then autoAdd(th, "threads") end
                    return th
                end))
                st.installed["task." .. nm] = true
            end)
        end
        return true
    end

    function Janitor:AutoTrack(opts)
        opts = opts or {}
        local st = env.__JanitorAutoTrack
        if not st then
            st = { installed = {}, active = false }
            env.__JanitorAutoTrack = st
            installHooks(st)
        end
        st.want = {
            connections = opts.connections ~= false,
            instances   = opts.instances ~= false,
            threads     = opts.threads ~= false,
        }
        st.janitor = self
        st.active = true
        self:Add(function()
            if st.janitor == self then
                st.active = false
                st.janitor = nil
            end
        end, nil, "__autotrack")
        return st.installed
    end

    function Janitor:StopAutoTrack()
        local st = env.__JanitorAutoTrack
        if st and st.janitor == self then
            st.active = false
            st.janitor = nil
        end
    end

    return Janitor
end)()

if getgenv().__aural_janitor then
    pcall(function() getgenv().__aural_janitor:Destroy() end)
end

local J = Janitor.new()
getgenv().__aural_janitor = J

local HeadRide = (function()

    local players = game:GetService("Players")

    local userInputService = game:GetService("UserInputService")

    local localPlayer = players.LocalPlayer

    local HeadRide = {}

    HeadRide.Enabled = false

    HeadRide.Target = nil

    HeadRide.EngagedTarget = nil

    HeadRide.TargetDistance = math.huge

    HeadRide.Mounted = false

    HeadRide.Engaged = false

    HeadRide.LastJumpAt = 0

    HeadRide.Status = "OFF"

    HeadRide.Settings = {

        EngageRange = 5,

        FollowDistance = 7,

        AutoJump = true,

        JumpDistance = 2.8,

        JumpCooldown = 0.8,

        MountHorizontal = 1.5,

        MountVertical = 1.5,

        MountSmoothness = 18,

        ManualOverride = true,

        MovementKeys = {

            Enum.KeyCode.W,

            Enum.KeyCode.A,

            Enum.KeyCode.S,

            Enum.KeyCode.D

        }

    }

    local function find(parent, name)

        if not parent then return nil end

        return parent:FindFirstChild(name)

    end

    local function getRoot(character)

        return character and find(character, "HumanoidRootPart")

    end

    local function getHumanoid(character)

        return character and find(character, "Humanoid")

    end

    local function getHead(character)

        return character and find(character, "Head")

    end

    function HeadRide:SetSetting(name, value)

        if self.Settings[name] ~= nil then

            self.Settings[name] = value

            return true

        end

        return false

    end

    function HeadRide:GetSetting(name)

        return self.Settings[name]

    end

    function HeadRide:HasManualInput()

        if not self.Settings.ManualOverride then return false end

        for _, key in ipairs(self.Settings.MovementKeys) do

            if userInputService:IsKeyDown(key) then return true end

        end

        if not userInputService.GamepadEnabled then return false end

        local success, inputs = pcall(function()

            return userInputService:GetGamepadState(Enum.UserInputType.Gamepad1)

        end)

        if success then

            for _, input in ipairs(inputs) do

                if input.KeyCode == Enum.KeyCode.Thumbstick1 then

                    local position = Vector2.new(input.Position.X, input.Position.Y)

                    if position.Magnitude > 0.18 then return true end

                end

            end

        end

        return false

    end

    function HeadRide:GetTargetData(target, localRoot)

        if not target or target == localPlayer or not localRoot then

            return nil

        end

        local character = target.Character

        local root = getRoot(character)

        local humanoid = getHumanoid(character)

        local head = getHead(character)

        if not character or not root or not humanoid or not head then

            return nil

        end

        if humanoid.Health <= 0 then return nil end

        if find(character, "Basketball") then return nil end

        local delta = root.Position - localRoot.Position

        local distance = Vector3.new(delta.X, 0, delta.Z).Magnitude

        return character, root, humanoid, head, distance

    end

    function HeadRide:Reset(status)

        self.Target = nil

        self.TargetDistance = math.huge

        self.Mounted = false

        self.Engaged = false

        self.EngagedTarget = nil

        self.Status = status or (self.Enabled and "WAITING FOR TARGET" or "OFF")

    end

    function HeadRide:SetEnabled(enabled)

        self.Enabled = enabled == true

        self:Reset(self.Enabled and "WAITING FOR TARGET" or "OFF")

    end

    function HeadRide:IsEnabled()

        return self.Enabled

    end

    function HeadRide:SetTarget(target)

        if target ~= self.Target then

            self.Engaged = false

            self.Mounted = false

            self.EngagedTarget = nil

        end

        self.Target = target

    end

    function HeadRide:GetTarget()

        return self.Target

    end

    function HeadRide:IsMounted(localRoot, localHumanoid, targetHead)

        if not localRoot or not localHumanoid or not targetHead then

            return false

        end

        local feetOffset

        if localHumanoid.RigType == Enum.HumanoidRigType.R6 then

            feetOffset = 3.5

        else

            feetOffset = 3

        end

        local feet = localRoot.Position - Vector3.new(0, feetOffset, 0)

        local difference = feet - targetHead.Position

        local horizontal = Vector3.new(difference.X, 0, difference.Z).Magnitude

        local vertical = math.abs(difference.Y)

        local mounted = vertical < self.Settings.MountVertical

            and horizontal < self.Settings.MountHorizontal

        return mounted, feetOffset

    end

    function HeadRide:Step(dt)

        if not self.Enabled then return false end

        local character = localPlayer.Character

        if not character then

            self.Status = "WAITING FOR CHARACTER"

            return false

        end

        local localRoot = getRoot(character)

        local localHumanoid = getHumanoid(character)

        if not localRoot or not localHumanoid then

            self.Status = "WAITING FOR CHARACTER"

            return false

        end

        local target = self.Target

        if not target then

            self.Status = "WAITING FOR TARGET"

            return false

        end

        local targetCharacter, targetRoot, targetHumanoid, targetHead, distance =

            self:GetTargetData(target, localRoot)

        self.TargetDistance = distance or math.huge

        if not targetCharacter then

            self:Reset("WAITING FOR TARGET")

            return false

        end

        if self:HasManualInput() then

            self.Status = "MANUAL OVERRIDE"

            return false

        end

        local engageRange = math.max(tonumber(self.Settings.EngageRange) or 5, 1.5)

        if not self.Engaged then

            if distance > engageRange then

                self.Status = string.format("OFF-BALL GUARD | %.1f", distance)

                return false

            end

            self.Engaged = true

            self.EngagedTarget = target

        end

        if self.EngagedTarget and self.EngagedTarget ~= target then

            self:Reset("NEW TARGET")

            return false

        end

        local mounted, feetOffset = self:IsMounted(localRoot, localHumanoid, targetHead)

        self.Mounted = mounted

        if mounted then

            local desiredPosition = targetHead.Position + Vector3.new(0, feetOffset + 0.2, 0)

            local desiredCFrame = CFrame.new(desiredPosition) * localRoot.CFrame.Rotation

            local smoothness = math.max(tonumber(self.Settings.MountSmoothness) or 18, 1)

            local alpha = 1 - math.exp(-smoothness * math.clamp(dt or 1/60, 0, 0.1))

            localRoot.CFrame = localRoot.CFrame:Lerp(desiredCFrame, alpha)

            localHumanoid:Move(Vector3.zero, false)

            self.Status = "RIDING | " .. target.Name

            return true

        end

        local offset = targetRoot.Position - localRoot.Position

        local flatOffset = Vector3.new(offset.X, 0, offset.Z)

        if flatOffset.Magnitude < 0.01 then

            localHumanoid:Move(Vector3.zero, false)

            self.Status = "MOUNTING | " .. target.Name

            return true

        end

        local targetMove = Vector3.new(

            targetHumanoid.MoveDirection.X, 0, targetHumanoid.MoveDirection.Z)

        local followDistance = math.max(tonumber(self.Settings.FollowDistance) or 7, 0.5)

        local autoJump = self.Settings.AutoJump == true

        local approachDistance = autoJump and math.min(followDistance, 1.4) or followDistance

        local moveDirection

        if flatOffset.Magnitude > approachDistance then

            moveDirection = flatOffset.Unit

            if targetMove.Magnitude > 0.05 then

                local blend = targetMove.Unit + flatOffset.Unit

                if blend.Magnitude > 0.05 then

                    moveDirection = blend.Unit

                end

            end

        elseif targetMove.Magnitude > 0.05 then

            moveDirection = targetMove.Unit

        else

            moveDirection = Vector3.zero

        end

        localHumanoid:Move(moveDirection, false)

        local now = os.clock()

        local jumpDistance = math.max(tonumber(self.Settings.JumpDistance) or 2.8, 1)

        local jumpCooldown = tonumber(self.Settings.JumpCooldown) or 0.8

        if autoJump

            and flatOffset.Magnitude <= jumpDistance

            and localHumanoid.FloorMaterial ~= Enum.Material.Air

            and now - self.LastJumpAt >= jumpCooldown then

            self.LastJumpAt = now

            localHumanoid.Jump = true

            pcall(function()

                localHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)

            end)

            self.Status = "JUMPING TO | " .. target.Name

        else

            self.Status = "FOLLOWING | " .. target.Name

        end

        return true

    end

    function HeadRide:GetStatus()

        return self.Status

    end

    function HeadRide:IsMountedNow()

        return self.Mounted

    end

    function HeadRide:GetTargetDistance()

        return self.TargetDistance

    end

    return HeadRide

end)()

-- ============================================================
-- Court Skin Spoofer
-- ============================================================
local CourtSpoofer = (function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local CS = {
        Enabled = false,
        SkinName = "CourtSkin_Default",
        Status = "OFF",
        _skinner = nil,
        _resolved = false,
        _lastApply = 0,
    }

    local function getAllCourts()
        local out = {}
        local folder = workspace:FindFirstChild("Courts")
        if folder then
            for _, c in ipairs(folder:GetChildren()) do
                if c:IsA("Model") then table.insert(out, c) end
            end
        end
        local single = workspace:FindFirstChild("Court")
        if single and single:IsA("Model") then table.insert(out, single) end
        return out
    end

    local function resolveSkinner()
        if CS._resolved then return CS._skinner end
        CS._resolved = true
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        if not scripts then return nil end
        local found = scripts:FindFirstChild("CourtSkinner", true)
        if not found or not found:IsA("ModuleScript") then return nil end
        local ok, mod = pcall(require, found)
        if ok and type(mod) == "table" and type(mod.changeSkin) == "function" then
            CS._skinner = mod
            return mod
        end
        return nil
    end

    local function resolveSkin(name)
        local shop = ReplicatedStorage:FindFirstChild("ShopItems")
        local folder = shop and shop:FindFirstChild("CourtSkin")
        if not folder then return nil end
        if name and name ~= "None" then
            local m = folder:FindFirstChild(name)
            if m then return m end
        end
        return folder:FindFirstChild("CourtSkin_Default")
    end

    function CS:GetOptions()
        local list = { "None" }
        local shop = ReplicatedStorage:FindFirstChild("ShopItems")
        local folder = shop and shop:FindFirstChild("CourtSkin")
        if folder then
            for _, item in ipairs(folder:GetChildren()) do
                table.insert(list, item.Name)
            end
        end
        table.sort(list)
        return list
    end

    function CS:Apply(force)
        if not CS.Enabled then return false end
        local now = os.clock()
        if not force and now - CS._lastApply < 0.5 then return false end
        CS._lastApply = now
        local skinner = resolveSkinner()
        if not skinner then
            CS.Status = "UNSUPPORTED"
            return false
        end
        local skin = resolveSkin(CS.SkinName)
        if not skin then
            CS.Status = "NO ASSETS"
            return false
        end
        local applied = 0
        for _, court in ipairs(getAllCourts()) do
            local ok = pcall(function() skinner.changeSkin(court, skin, false) end)
            if ok then applied += 1 end
        end
        CS.Status = applied > 0 and (CS.SkinName .. " x" .. applied) or "NO COURTS"
        return applied > 0
    end

    function CS:SetEnabled(on)
        CS.Enabled = on == true
        if CS.Enabled then
            -- Game re-applies default when these flags are on, so clear them
            pcall(function()
                local PlayerData = require(ReplicatedStorage.Util.PlayerData)
                if PlayerData and PlayerData.storedData then
                    PlayerData.storedData.Config = PlayerData.storedData.Config or {}
                    PlayerData.storedData.Config.Toggle_CourtSkins = true
                end
            end)
            CS:Apply(true)
        else
            CS.SkinName = "CourtSkin_Default"
            CS:Apply(true)
            CS.Status = "OFF"
        end
    end

    function CS:SetSkin(name)
        CS.SkinName = name or "CourtSkin_Default"
        if CS.Enabled then CS:Apply(true) end
    end

    -- Re-apply periodically because the game resets skin on court load
    task.spawn(function()
        while CS._skinner ~= false do
            task.wait(2)
            if CS.Enabled then pcall(function() CS:Apply(false) end) end
        end
    end)

    return CS
end)()
getgenv().AuralCourtSpoofer = CourtSpoofer

-- ============================================================
-- Streak Spoofer (local-only)
-- ============================================================
local StreakSpoofer = (function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local SS = {
        Enabled = false,
        Value = 25,
        Status = "OFF",
        _rankings = nil,
        _running = true,
    }

    local function getRankings()
        if SS._rankings then return SS._rankings end
        local util = ReplicatedStorage:FindFirstChild("Util")
        local module = util and util:FindFirstChild("Rankings")
        if not module then return nil end
        local ok, result = pcall(require, module)
        if ok and type(result) == "table" then
            SS._rankings = result
            return result
        end
        return nil
    end

    local function isLocalName(value)
        value = tostring(value or "")
        return value == LocalPlayer.Name
            or value == LocalPlayer.DisplayName
            or value == ("@" .. LocalPlayer.Name)
    end

    local function isLocalBanner(streakFrame, playerGui)
        local node = streakFrame
        while node and node ~= playerGui do
            if node.Name == "MainFrame" or node.Name == "GameFrame" then
                for _, child in node:GetDescendants() do
                    if (child:IsA("TextLabel") or child:IsA("TextButton")) and isLocalName(child.Text) then
                        return true
                    end
                end
            end
            node = node.Parent
        end
        return false
    end

    local function patchStreak(streakFrame)
        if not (streakFrame and streakFrame.Parent and streakFrame:IsA("ImageLabel")) then return end

        local value = math.max(0, math.floor(tonumber(SS.Value) or 0))
        local rankings = getRankings()
        local image

        if value > 1 and rankings and type(rankings.getStreakImage) == "function" then
            local ok, result = pcall(rankings.getStreakImage, value)
            if ok and type(result) == "string" and result ~= "" then
                image = result
            end
        end

        if image then streakFrame.Image = image end
        streakFrame.Visible = value > 1
        streakFrame.ImageTransparency = 0
        streakFrame.ImageColor3 = Color3.new(1, 1, 1)

        local amount = streakFrame:FindFirstChild("AmountLabel", true)
            or streakFrame:FindFirstChildWhichIsA("TextLabel", true)

        if amount then
            amount.Text = value > 0 and tostring(value) or ""
            amount.Visible = value > 1
            amount.TextColor3 = Color3.new(1, 1, 1)

            local gradient = amount:FindFirstChildOfClass("UIGradient")
            if gradient then
                gradient.Color = ColorSequence.new(Color3.new(1, 1, 1))
            end
        end
    end

    function SS:Apply()
        if not SS.Enabled then return end

        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local nameTag = root and root:FindFirstChild("NameTag")

        if nameTag then
            for _, frameName in { "MainFrame", "GameFrame" } do
                local frame = nameTag:FindFirstChild(frameName)
                local streak = frame and (frame:FindFirstChild("StreakIcon") or frame:FindFirstChild("Streak"))
                if streak and streak:IsA("ImageLabel") then
                    patchStreak(streak)
                end
            end
        end

        local playerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not playerGui then return end

        for _, object in playerGui:GetDescendants() do
            if object:IsA("ImageLabel") and (object.Name == "StreakIcon" or object.Name == "Streak") then
                if isLocalBanner(object, playerGui) then
                    patchStreak(object)
                end
            end
        end
    end

    function SS:SetEnabled(enabled)
        SS.Enabled = enabled == true
        SS.Status = SS.Enabled and "ACTIVE" or "OFF"
        if SS.Enabled then SS:Apply() end
    end

    J:Spawn(function()
        while true do
            if SS.Enabled then
                pcall(function() SS:Apply() end)
                task.wait(0.35)
            else
                task.wait(0.6)
            end
        end
    end)

    function SS:SetValue(value)
        SS.Value = math.max(0, math.floor(tonumber(value) or 0))
        if SS.Enabled then SS:Apply() end
    end

    return SS
end)()
getgenv().AuralStreakSpoofer = StreakSpoofer

-- ============================================================
-- Auto Performance Mode
-- ============================================================
local AutoPerf = (function()
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local AP = {
        Enabled = false,
        LowFPS = 38,
        RestoreFPS = 52,
        Applied = false,
        Saved = nil,
        FPS = 60,
        Status = "MONITORING",
        _frames = 0,
        _windowAt = os.clock(),
    }

    AP.Keys = {
        Toggle_LowGraphics = true,
        Toggle_GlobalShadows = false,
        Toggle_GoalEffects = false,
        Toggle_BallAuras = false,
        Toggle_BallTrails = false,
        Toggle_BodyAuras = false,
        Toggle_AnimatedBanners = false,
        Toggle_AnimatedStreaks = false,
        Toggle_CourtMeshes = false,
        Toggle_CourtSkins = false,
        Toggle_Mountains = false,
    }

    local _playerData, _toggleEvent
    local function getPlayerData()
        if _playerData then return _playerData end
        local ok, m = pcall(require, ReplicatedStorage.Util.PlayerData)
        if ok and type(m) == "table" then _playerData = m end
        return _playerData
    end

    local function getToggleEvent()
        if _toggleEvent then return _toggleEvent end
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local ev = remotes and remotes:FindFirstChild("toggleEvent")
        _toggleEvent = ev
        return ev
    end

    local function setConfig(key, value)
        local pd = getPlayerData()
        if not pd then return false end
        local ev = getToggleEvent()
        if ev and ev.Parent then
            pcall(function()
                if type(value) == "boolean" then ev:FireServer(key)
                else ev:FireServer(key, value) end
            end)
        end
        if type(pd.updateData) == "function" then
            pcall(pd.updateData, "Config", key, value)
        end
        return true
    end

    local function getConfig(key, fallback)
        local pd = getPlayerData()
        if pd and type(pd.Get) == "function" then
            local ok, v = pcall(pd.Get, "Config", key)
            if ok and v ~= nil then return v end
        end
        return fallback
    end

    function AP:Apply()
        if AP.Applied then return end
        AP.Saved = {}
        for key, target in pairs(AP.Keys) do
            AP.Saved[key] = getConfig(key, not target)
            setConfig(key, target)
        end
        AP.Applied = true
        AP.Status = "REDUCED | " .. tostring(math.floor(AP.FPS)) .. " FPS"
    end

    function AP:Restore()
        if not AP.Applied then return end
        for key, val in pairs(AP.Saved or {}) do
            setConfig(key, val)
        end
        AP.Saved = nil
        AP.Applied = false
        AP.Status = "MONITORING"
    end

    function AP:SetEnabled(on)
        AP.Enabled = on == true
        if not AP.Enabled then
            AP:Restore()
            AP.Status = "OFF"
        else
            AP.Status = "MONITORING"
            AP._frames = 0
            AP._windowAt = os.clock()
        end
    end

    function AP:SetThresholds(low, restore)
        if low then AP.LowFPS = math.clamp(low, 10, 240) end
        if restore then AP.RestoreFPS = math.clamp(restore, AP.LowFPS + 5, 360) end
    end

    -- Heartbeat FPS sampling, same 5-second window as GoldenEagle
    local conn = RunService.Heartbeat:Connect(function()
        AP._frames += 1
        local now = os.clock()
        local elapsed = now - AP._windowAt
        if elapsed >= 5 then
            AP.FPS = AP._frames / elapsed
            AP._frames = 0
            AP._windowAt = now
            if AP.Enabled then
                if not AP.Applied and AP.FPS < AP.LowFPS then
                    pcall(function() AP:Apply() end)
                elseif AP.Applied and AP.FPS > AP.RestoreFPS then
                    pcall(function() AP:Restore() end)
                end
            end
        end
    end)

    function AP:Destroy() conn:Disconnect() end
    return AP
end)()
getgenv().AuralAutoPerf = AutoPerf
J:Add(AutoPerf.Destroy, nil, "AutoPerf")

local trash = { "Xeno", "Solara", "Nexomia" }
local execName = identifyexecutor and identifyexecutor() or ""

local zolar = nil -- replaced by AuralV2
local List = nil -- keybind list placeholder


if not cloneref then getfenv().cloneref = function(svc) return svc end end
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
local remote = cloneref(game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("lukeEvent"))
local TweenService = cloneref(game:GetService("TweenService"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local travelevent = cloneref(game:GetService("ReplicatedStorage").Remotes:FindFirstChild("sbEvent"))

local Camera = workspace.CurrentCamera
local Icon = nil
local IconCenter = nil

local setpower                  = nil
local settarget, doClick
local fatalClick                = nil
local getclosestplayerwithball  = nil
local nearestrim                = nil
local hoopDistanceGui           = nil
local hoopDistanceLabel         = nil
local hoopDistConnection        = nil

getgenv().Settings = {
    Shooting = {
        Mode = "Aural", AuralKeybind = Enum.KeyCode.X, AuralAimAssist = false, BankShots = false, HumanizeAim = false, HumanizeStrength = 0, MissChance = 0, AuralEnabled = false, ArmInMatch = false, FatalEnabled = false,
        ShotDelay = 0.32, ShotYAxis = 0, RandomizeShotDelay = false,
        ShotDelayMin = 0.25, ShotDelayMax = 0.38, GreenChance = 0,
        ThreesOnly = false, AimAssist = false, EBLHop = false,
        ArcTableAuto = false, ArcTablePref = "Closest to 85",
        AuralTrigger = "Jump", SilentAimButton = false
    },
    SelfPass = {
        Enabled = false, Keybind = "T", Power = 85, Distance = 50, Angle = 170, SelfPassButton = false
    },
    AutoDime = {
        Enabled = false,
        JumpBeforePass = true,
        JumpDelay = 0.25,
        PassPower = 85,
        Cooldown = 0.75,
        Key1 = "One", Key2 = "Two", Key3 = "Three", Key4 = "Four", Key5 = "Five",
        LeadMultiplier = 1.0,
        AutoLead = true,
        LeadPing = true,
    },
    Defending = {
        AutoGuard = false, OnlyGuardInMatch = false, AutoGuardButton = false, AutoGuardNearest = false, AutoGuardKeybind = "K",
        AutoGuardMode = "Prediction", AutoGuardRange = 33, GuardPrediction = 0.58, SpacingDistance = 3,
        GuardStyle = "Contain", CutoffLead = 3, ReactionTime = 0, JumpIfThrown = false
    },
    Automatics = {
        AutoQueue = false, QueueAlmostFinished = false,
        JoinType = "Teleport", AutoQueueAfterGames = false, AutoDunk = false
    },
    Visuals = {
        VisualizeBallProjectory = false, ProjectoryColor = "Red",
        ShotIndicator = false, IndicatorColor = "Blue",
        ShowHiddenRanks = false,
        IncludeYourself = false, HidePlayerTags = false,
        HideOwnNameplate = false,
        CustomName = false, CustomNameText = "",
        CustomRecord = false, CustomRecordText = "",
        CustomTitle = false, CustomTitleText = "",
        CustomRank = false,
        CustomRankChoice = "None",
        HeadlessSpoof = false,
        KorbloxSpoof = false,
        HoopDistance = false,
        HoopDistanceColor = "White",
        HoopDistanceTransparency = 0.6,
        ArrayList = false,
    },
    Ball = {
        BallMags = false, SmartReach = false, SmartReachDistance = 11, BallMagRange = 0.1, BallMagVisualizer = false, MagnetKeybind = "M",
        BallReach = false, BallReachRange = 0.1, BallReachVisualizer = false, ReachKeybind = "N", MagnetButton = false,
    },
    Player = { Walkspeed = false, WSvalue = 1.35 },
    Misc = {
        AntiTravel = false, AntiOOB = false, AntiModerator = false,
        Type = "Notify", DeviceSpoofer = false, Device = "PC", ServerPosition = false,
        AntiFall = false
    },
    Rep = {
        AutoCalculateRep = false,
        ShowGui = false,
    },
    Goal = { Enabled = false, SelectedEffect = "LightRay", CurrentEffect = "LightRay" },
    BallChanger = { Enabled = false, SelectedBall = "ForceField", CurrentBall = "ForceField" },
    Aura = { Enabled = false, SelectedAura = "None", CurrentAura = nil },
    Watch = { Court = "Auto Live Match", Mode = "2K CAM" },
    TrailChanger = { Enabled = false, SelectedTrail = "None", CurrentTrail = "None" },
    AvatarChanger = {
        SelectedPlayer = "None",
        CustomUser = "",
        LastCopiedUserId = nil,
        LastCopiedName = nil
    },

    AntiReach = {
        Enabled = false, Mode = "Adaptive",
        CounterRate = 90, CounterDuration = 3.5, CounterWindow = 2.5,
        CounterRadius = 15, NoStealKeeper = true, NoStealRange = 15,
        NoStealRequestInterval = 0.05, PingBoost = true,
        RejectMag = true, Persistent = true, TeamSafety = true,
    },
    AnklesReach = { Enabled = false, Radius = 8, ReachButton = false },
    AutoMix = {
        Enabled = false, BodyFirst = true,
        Mode = "Smart Mix",
        PreferredDistance = 7.5, ActionDistance = 5.5,
        ThreatSteerMax = 0.72, ManualInfluence = 0.72,
        RearSpinBlock = true, CrabStrength = 0.70, UseAntiReach = true,
        ManualHandles = false,
        SpinDegrees = 360,
        Movement = true,
        PostMoveCooldown = 0.35,
        DecisionHold = 0.14,
        EmergencyDistance = 4.8,
        BallSafetyMargin = 3.0,
        MoveVariety = false,
        Adaptive = true,
        Combo = false,
        PredictiveReach = true,
    },
        HeadRide = {

        Enabled        = false,

        OnlyArmInMatch   = false,

        AutoTarget     = true,

        ManualTarget   = "None",

        TeamSafety     = true,

        EngageRange    = 5,

        FollowDistance = 7,

        AutoJump       = true,

        JumpDistance   = 2.8,

        JumpCooldown   = 0.8,

        MountHorizontal = 1.5,

        MountVertical   = 1.5,

        MountSmoothness = 18,

        ManualOverride  = true,

    },
    FPSCap = { Enabled = false, Value = 60, Original = nil },
    AntiTravelHook = { Enabled = false, HookMode = "NOT INSTALLED", Original = nil, Blocked = 0 },
    ClanTag = { Enabled = false, Tag = "GEH", Color = "#FF3BD5" },
    ChatTag = { Enabled = false, Style = "Custom tag", Primary = "#FF3BD5", Secondary = "#35D9FF", GradientSpeed = 0.65 },
    LogoBadges = { VIP=false, Youtuber=false, Twitch=false, Booster=false, Tester=false, Staff=false, CustomIds={} },
    WalletSpoof = {
        Enabled = false, Money = 1000000, Spins = 99, Crates = 50, Boosts = 25,
        ClanCoins = 500000, EventCurrency = 10000, BattlepassLevel = 100, DailyRewardState = "READY TO SPIN!",
    },
    LocalAnonymizer = { Enabled = false, Alias = "Aural V2" },
}

-- ============================================================
-- Bank shot module: aims at the mirror point of the rim
-- reflected across the backboard, so the ball banks in.
-- ============================================================
local Backboard = {}

function Backboard.FindForRim(Rim)
    local Container = Rim and Rim.Parent
    for _ = 1, 4 do
        if not Container then break end
        local Board = Container:FindFirstChild("Backboard")
        if Board and Board:IsA("BasePart") then return Board end
        Container = Container.Parent
    end
    return nil
end

function Backboard.GetPlane(Board, ReleaseOrigin, BallRadius)
    if not (Board and ReleaseOrigin) then return nil end
    local Size = Board.Size
    local RawNormal, Thickness
    -- The thinnest axis is the face normal of the backboard.
    if Size.X <= Size.Y and Size.X <= Size.Z then
        RawNormal, Thickness = Board.CFrame.RightVector, Size.X
    elseif Size.Y <= Size.X and Size.Y <= Size.Z then
        RawNormal, Thickness = Board.CFrame.UpVector, Size.Y
    else
        RawNormal, Thickness = Board.CFrame.LookVector, Size.Z
    end
    local Normal = Vector3.new(RawNormal.X, 0, RawNormal.Z)
    if Normal.Magnitude <= 1e-4 then return nil end
    Normal = Normal.Unit
    -- Flip so the normal points toward the shooter.
    if (ReleaseOrigin - Board.Position):Dot(Normal) < 0 then Normal = -Normal end
    local Radius = math.max(tonumber(BallRadius) or 1.25, 0)
    local PlanePoint = Board.Position + Normal * ((Thickness * 0.5) + Radius + 0.08)
    return PlanePoint, Normal
end

function Backboard.GetMirrorTarget(Rim, ReleaseOrigin, BallRadius)
    local Board = Backboard.FindForRim(Rim)
    if not Board then return nil end
    local PlanePoint, Normal = Backboard.GetPlane(Board, ReleaseOrigin, BallRadius)
    if not PlanePoint then return nil end
    local Offset = Rim.Position - PlanePoint
    local FlatOffset = Vector3.new(Offset.X, 0, Offset.Z)
    -- Reflect the rim across the plane.
    local Target = Rim.Position - 2 * Normal * FlatOffset:Dot(Normal)
    return Target, Board
end

-- Returns the aim point to feed settarget()/fatalClick().
-- Falls back to the rim position when there is no backboard.
function Backboard.ResolveAimPoint(Rim)
    if not Rim then return nil end
    local char = LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return Rim.Position end
    local basketball = char:FindFirstChild("Basketball")
    local ball = basketball and basketball:FindFirstChild("Ball", true)
    local origin = (ball and ball:IsA("BasePart") and ball.Position) or head.Position
    local radius = (ball and ball:IsA("BasePart")
        and math.max(ball.Size.X, ball.Size.Y, ball.Size.Z) * 0.5) or 1.25
    local target = Backboard.GetMirrorTarget(Rim, origin, radius)
    return target or Rim.Position
end

getgenv().AuralBackboard = Backboard

local function isConsole()
    return UserInputService.GamepadEnabled
        and not UserInputService.KeyboardEnabled
        and not UserInputService.MouseEnabled
end

local function getConsoleSystem()
    if UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonX) == "ButtonSquare" then
        return "Playstation"
    end

    return "Xbox"
end

local MatchState = {

    Cached = false,

    CheckedAt = 0,

}

local function safeFind(parent, name)

    if typeof(parent) ~= "Instance" then return nil end

    return parent:FindFirstChild(name)

end

function IsInMatch()

    local now = os.clock()

    if now - MatchState.CheckedAt < 0.5 then

        return MatchState.Cached

    end

    MatchState.CheckedAt = now

    local inMatch = LocalPlayer:GetAttribute("Ingame") == true

        or LocalPlayer:GetAttribute("InGame") == true

        or LocalPlayer:GetAttribute("InMatch") == true

    if not inMatch and safeFind(workspace, "Court") then

        inMatch = true

    end

    if not inMatch then

        local char = LocalPlayer.Character

        local basketball = char and safeFind(char, "Basketball")

        local gameFolder = basketball and safeFind(basketball, "[GAME]")

        local currentGame = gameFolder and safeFind(gameFolder, "CurrentGame")

        if currentGame and currentGame:IsA("ObjectValue") and currentGame.Value then

            inMatch = true

        end

    end

    if not inMatch then

        local courts = safeFind(workspace, "Courts")

        if courts then

            for _, court in pairs(courts:GetChildren()) do

                local courtPlayers = safeFind(court, "_CourtPlayers")

                local settings = safeFind(court, "_CourtSettings")

                local started = settings and safeFind(settings, "Started")

                local isStarted = started and (

                    (started:IsA("BoolValue") and started.Value == true)

                    or started:GetAttribute("Value") == true

                )

                if courtPlayers and isStarted then

                    for _, slot in pairs(courtPlayers:GetChildren()) do

                        if slot:IsA("ObjectValue") and slot.Value == LocalPlayer then

                            inMatch = true

                            break

                        end

                    end

                end

                if inMatch then break end

            end

        end

    end

    MatchState.Cached = inMatch

    return inMatch

end

local rankelo = {
    ["Rookie 1"]=0,["Rookie 2"]=25,["Rookie 3"]=50,
    ["Veteran 1"]=100,["Veteran 2"]=150,["Veteran 3"]=200,
    ["Elite 1"]=300,["Elite 2"]=400,["Elite 3"]=500,
    ["Pro 1"]=650,["Pro 2"]=800,["Pro 3"]=950,
    ["All-star 1"]=1150,["All-star 2"]=1350,["All-star 3"]=1550,
    ["Superstar 1"]=1800,["Superstar 2"]=2050,["Superstar 3"]=2300,
    ["Phenom 1"]=2550,["Phenom 2"]=2800,["Phenom 3"]=3100,
    ["Legend 1"]=3350,["Legend 2"]=3600,["Legend 3"]=3850,
    ["Mamba 1"]=4100,["Mamba 2"]=5050,["Mamba 3"]=6050,
    ["HoF 1"]=10000,["HoF 2"]=12500,["HoF 3"]=15000,
    ["G.O.A.T 1"]=20000,["G.O.A.T 2"]=22500,["G.O.A.T 3"]=25000,
    ["Aura 1"]=30000,["Aura 2"]=32500,["Aura 3"]=35000
}

local s = getgenv().Settings

local headRideConnection = nil

local function pushHeadRideSettings()

    if not HeadRide then return end

    local hr = s.HeadRide

    HeadRide:SetSetting("EngageRange",     hr.EngageRange)

    HeadRide:SetSetting("FollowDistance",  hr.FollowDistance)

    HeadRide:SetSetting("AutoJump",        hr.AutoJump)

    HeadRide:SetSetting("JumpDistance",    hr.JumpDistance)

    HeadRide:SetSetting("JumpCooldown",    hr.JumpCooldown)

    HeadRide:SetSetting("MountHorizontal", hr.MountHorizontal)

    HeadRide:SetSetting("MountVertical",   hr.MountVertical)

    HeadRide:SetSetting("MountSmoothness", hr.MountSmoothness)

    HeadRide:SetSetting("ManualOverride",  hr.ManualOverride)

end

getgenv().__aural_pushHeadRide = pushHeadRideSettings

local uiToggles: { [string]: any } = {}

function hasball(char: Instance?): boolean
    return char ~= nil and char:FindFirstChild("Basketball") ~= nil
end
local rangeConnection = nil
local landedConnection = nil
local fallconnection = nil
local DeviceEvent = cloneref(game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("deviceEvent"))

UserInputService = cloneref(game:GetService("UserInputService"))
RunService = cloneref(game:GetService("RunService"))
ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
TeleportService = cloneref(game:GetService("TeleportService"))
HttpService = cloneref(game:GetService("HttpService"))
Input = cloneref(game:GetService("VirtualInputManager"))
local networkStats = cloneref(game:GetService("Stats"))
SharedTableRegistry = cloneref(game:GetService("SharedTableRegistry"))

local Hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
if not Hum then
    local Char = LocalPlayer.CharacterAdded:Wait()
    Hum = Char:WaitForChild("Humanoid")
end
local Rankings
do
    local ok, mod = pcall(function()
        return require(ReplicatedStorage.Util.Rankings)
    end)
    if ok and type(mod) == "table" then
        Rankings = mod
    else
        Rankings = {
            getRankFromELO = function(elo)
                local best, bestTier = "Rookie", 1
                local bestElo = -math.huge
                for rankName, minElo in pairs(rankelo) do
                    if elo >= minElo and minElo >= bestElo then
                        bestElo = minElo
                        local rk, tier = rankName:match("^(.-)%s+(%d+)$")
                        best, bestTier = rk or rankName, tonumber(tier) or 1
                    end
                end
                return best, bestTier
            end,
            getRankMinMaxFromELO = function(elo)
                local minV, maxV = nil, nil
                local names = {}
                for n in pairs(rankelo) do table.insert(names, n) end
                table.sort(names, function(a, b) return rankelo[a] < rankelo[b] end)
                for i, n in ipairs(names) do
                    if elo >= rankelo[n] then
                        minV = rankelo[n]
                        maxV = names[i + 1] and rankelo[names[i + 1]] or nil
                    end
                end
                return minV, maxV
            end,
            getNextRankFromELO = function(elo)
                local names = {}
                for n in pairs(rankelo) do table.insert(names, n) end
                table.sort(names, function(a, b) return rankelo[a] < rankelo[b] end)
                for _, n in ipairs(names) do
                    if rankelo[n] > elo then
                        local rk, tier = n:match("^(.-)%s+(%d+)$")
                        return rk or n, tonumber(tier) or 1
                    end
                end
                return "Aura", 3
            end,
            getRankImageFromELO = function() return "" end,
        }
    end
end

local networkstats = networkStats:FindFirstChild("Network", false) or networkStats:WaitForChild("Network", 60)
local serverstatsitem = networkstats:FindFirstChild("ServerStatsItem", false) or networkstats:WaitForChild("ServerStatsItem", 60)
local dataping = serverstatsitem:FindFirstChild("Data Ping", false) or serverstatsitem:WaitForChild("Data Ping", 60)
local Spectate = nil
pcall(function()
    local spectateUI = LocalPlayer.PlayerGui:WaitForChild("SpectateUI", 10)
    if spectateUI then
        Spectate = require(spectateUI:WaitForChild("Spectate", 5))
    end
end)

do
    local PowerUI = LocalPlayer.PlayerGui:WaitForChild("PowerUI")
    Icon = PowerUI:WaitForChild("CursorIcon")
    local CursorIcon2 = PowerUI:WaitForChild("CursorIcon2")
    task.delay(5, function()
        if Icon then
            IconCenter = Vector2.new(Icon.AbsolutePosition.X + Icon.AbsoluteSize.X / 2, Icon.AbsolutePosition.Y + Icon.AbsoluteSize.Y / 2)
            Icon:Destroy()
        end
        if CursorIcon2 then CursorIcon2.Visible = false end
    end)
end

local indicator = Instance.new("Highlight")
indicator.Name = "rangeindicator"
indicator.FillTransparency = 0.7
indicator.OutlineTransparency = 0
indicator.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
indicator.FillColor = Color3.fromRGB(60, 150, 255)
indicator.OutlineColor = Color3.fromRGB(60, 150, 255)
indicator.Parent = gethui()

IndicatorColors = {
    Blue     = Color3.fromRGB(60, 150, 255),
    Lavender = Color3.fromRGB(179, 165, 255),
    Purple   = Color3.fromRGB(138, 43, 226),
    Green    = Color3.fromRGB(0, 255, 128),
    Red      = Color3.fromRGB(255, 60, 60),
    Yellow   = Color3.fromRGB(255, 220, 0),
    Orange   = Color3.fromRGB(255, 140, 0),
    Pink     = Color3.fromRGB(255, 105, 180),
    White    = Color3.fromRGB(255, 255, 255),
}

getgenv().__aural_aiming = false

local function restoreMouseBehavior()
    pcall(function()
        if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
    end)
end

local repGui, repFrame, repRank, repElo, repBar, repNext, repNeeded
local repGuiVisible = false

local function createRepGui()
    if repGui then return end

    repGui = Instance.new("ScreenGui")
    repGui.Name = "RepCalculator"
    repGui.ResetOnSpawn = false
    repGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    repGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    repGui.Enabled = repGuiVisible

    repFrame = Instance.new("Frame")
    repFrame.Size = UDim2.fromOffset(300, 145)
    repFrame.Position = UDim2.new(0.5, -150, 0.5, -72)
    repFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    repFrame.BorderSizePixel = 0
    repFrame.Parent = repGui

    Instance.new("UICorner", repFrame).CornerRadius = UDim.new(0, 14)
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(45, 45, 52)
    stroke.Thickness = 1
    stroke.Transparency = 0.25
    stroke.Parent = repFrame

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 38)
    header.BackgroundTransparency = 1
    header.Active = true
    header.Parent = repFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -24, 1, 0)
    title.Position = UDim2.fromOffset(12, 0)
    title.BackgroundTransparency = 1
    title.Text = "REP"
    title.TextColor3 = Color3.fromRGB(245, 245, 248)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    repRank = Instance.new("TextLabel")
    repRank.Size = UDim2.new(1, -24, 0, 28)
    repRank.Position = UDim2.fromOffset(12, 39)
    repRank.BackgroundTransparency = 1
    repRank.TextColor3 = Color3.fromRGB(240, 240, 245)
    repRank.TextSize = 19
    repRank.Font = Enum.Font.GothamBold
    repRank.TextXAlignment = Enum.TextXAlignment.Left
    repRank.Parent = repFrame

    repElo = Instance.new("TextLabel")
    repElo.Size = UDim2.new(0, 100, 0, 22)
    repElo.Position = UDim2.new(1, -112, 0, 42)
    repElo.BackgroundTransparency = 1
    repElo.TextColor3 = Color3.fromRGB(145, 145, 155)
    repElo.TextSize = 13
    repElo.Font = Enum.Font.GothamMedium
    repElo.TextXAlignment = Enum.TextXAlignment.Right
    repElo.Parent = repFrame

    local barBack = Instance.new("Frame")
    barBack.Size = UDim2.new(1, -24, 0, 7)
    barBack.Position = UDim2.fromOffset(12, 77)
    barBack.BackgroundColor3 = Color3.fromRGB(35, 35, 41)
    barBack.BorderSizePixel = 0
    barBack.Parent = repFrame
    Instance.new("UICorner", barBack).CornerRadius = UDim.new(1, 0)

    repBar = Instance.new("Frame")
    repBar.Size = UDim2.fromScale(0, 1)
    repBar.BackgroundColor3 = Color3.fromRGB(225, 225, 230)
    repBar.BorderSizePixel = 0
    repBar.Parent = barBack
    Instance.new("UICorner", repBar).CornerRadius = UDim.new(1, 0)

    repNext = Instance.new("TextLabel")
    repNext.Size = UDim2.new(1, -24, 0, 24)
    repNext.Position = UDim2.fromOffset(12, 91)
    repNext.BackgroundTransparency = 1
    repNext.TextColor3 = Color3.fromRGB(145, 145, 155)
    repNext.TextSize = 12
    repNext.Font = Enum.Font.GothamMedium
    repNext.TextXAlignment = Enum.TextXAlignment.Left
    repNext.Parent = repFrame

    repNeeded = Instance.new("TextLabel")
    repNeeded.Size = UDim2.new(1, -24, 0, 24)
    repNeeded.Position = UDim2.fromOffset(12, 113)
    repNeeded.BackgroundTransparency = 1
    repNeeded.TextColor3 = Color3.fromRGB(235, 235, 240)
    repNeeded.TextSize = 12
    repNeeded.Font = Enum.Font.GothamBold
    repNeeded.TextXAlignment = Enum.TextXAlignment.Left
    repNeeded.Parent = repFrame

    local dragging, dragStart, startPos = false, nil, nil
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = repFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            repFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local function update()
        if not repRank then return end
        local currentElo = LocalPlayer:GetAttribute("ELO") or 0
        local currentRank, currentTier = Rankings.getRankFromELO(currentElo)
        local minElo, maxElo = Rankings.getRankMinMaxFromELO(currentElo)

        repElo.Text = tostring(currentElo) .. " ELO"
        repRank.Text = tostring(currentRank) .. " " .. tostring(currentTier)

        if not maxElo then
            repNext.Text = "MAX RANK"
            repNeeded.Text = "You've reached the highest rank"
            repBar.Size = UDim2.fromScale(1, 1)
            return
        end

        local nextRankName, nextTier = Rankings.getNextRankFromELO(currentElo)
        local required = maxElo - currentElo + 1
        local progress = math.clamp((currentElo - minElo) / (maxElo - minElo + 1), 0, 1)

        repNext.Text = "Next  •  " .. tostring(nextRankName) .. " " .. tostring(nextTier)
        repNeeded.Text = tostring(required) .. " ELO to next rank"
        repBar.Size = UDim2.fromScale(progress, 1)
    end

    LocalPlayer:GetAttributeChangedSignal("ELO"):Connect(update)
    update()
end

local function setRepGui(visible)
    repGuiVisible = visible
    if visible then
        createRepGui()
        repGui.Enabled = true
    elseif repGui then
        repGui.Enabled = false
    end
end

do
    local repCalcConn = nil
    function startAutoRepCalc()
        if repCalcConn then return end
        repCalcConn = task.spawn(function()
            while s.Rep.AutoCalculateRep do
                task.wait(5)
                local elo = LocalPlayer:GetAttribute("ELO") or 0
                local rank, tier = Rankings.getRankFromELO(elo)
                local minElo, maxElo = Rankings.getRankMinMaxFromELO(elo)
                local pct = maxElo and math.floor(
                    ((elo - minElo) / (maxElo - minElo + 1)) * 100
                ) or 100
                print(("[REP] %s %s | %d ELO | %d%% to next | need %s")
                    :format(tostring(rank), tostring(tier), elo, pct,
                        maxElo and tostring(maxElo - elo + 1) or "MAX"))
            end
        end)
        setRepGui(true)
    end

    function stopAutoRepCalc()
        if repCalcConn then
            task.cancel(repCalcConn)
            repCalcConn = nil
        end
        setRepGui(false)
    end
end

local function applyIndicatorColor()
    local col = IndicatorColors[s.Visuals.IndicatorColor] or Color3.fromRGB(60, 150, 255)
    indicator.FillColor = col
    indicator.OutlineColor = col
end

local velocify = function(target, dist)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return target end

    local velocity = hrp.AssemblyLinearVelocity
    local travelTime = dist / 50
    local prediction = travelTime * 0.06

    return target + Vector3.new(
        velocity.X * prediction,
        0,
        velocity.Z * prediction
    )
end

TrajColors = {
    Red    = Color3.fromRGB(255, 0, 0),
    Orange = Color3.fromRGB(255, 130, 0),
    Yellow = Color3.fromRGB(255, 255, 0),
    Green  = Color3.fromRGB(0, 255, 0),
    Blue   = Color3.fromRGB(0, 130, 255),
    Purple = Color3.fromRGB(170, 0, 255),
    White  = Color3.fromRGB(255, 255, 255),
    Rainbow = nil,
}

local fieldGoals = {}

for _, inst in ipairs(workspace:GetDescendants()) do
    local n = inst.Name
    if n == "FieldGoal" and inst:IsA("BasePart") then
        table.insert(fieldGoals, inst)
    end
end

function getclosestdunkfunc()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local pos = hrp.Position

    for i = #fieldGoals, 1, -1 do
        local v = fieldGoals[i]
        if not v.Parent then
            table.remove(fieldGoals, i)
        elseif (pos - v.Position).Magnitude <= 13 then
            return v:FindFirstChild("dunkFunction")
        end
    end
    return nil
end

Moderators = {
    "izzran","wistfulmikk","Bibliogical","aepione","kyraizo",
    "ar1sxm","westline60s","Iukejdjd","Ninja215215"
}

local rankings = Rankings

local function applycustomrank()
    if not s.Visuals.CustomRank then return end

    local elo = LocalPlayer:GetAttribute("ELO")
    if typeof(elo) ~= "number" then return end

    local character = LocalPlayer.Character
    if not character then return end

    local rootpart = character:FindFirstChild("HumanoidRootPart")
    if not rootpart then return end

    local nametag = rootpart:FindFirstChild("NameTag")
    if not nametag then return end

    local mainframe = nametag:FindFirstChild("MainFrame")
    if not mainframe then return end

    local rankicon = mainframe:FindFirstChild("RankIcon")
    if not rankicon or not rankicon:IsA("ImageLabel") then return end

    rankicon.Image = rankings.getRankImageFromELO(elo)
end

local Client = LocalPlayer
local Effects, EffectNames = {}, {}
local Balls, BallNames = {}, {}
local AuraList, AuraNames = {}, {"None"}
local goalEventHook = nil
local OriginalReplicateBall = nil
local Replicator = nil
local autoDimeConnection = nil
local quickPassConnections = {}
local passLabelGuis = {}
local Trails = {}
local TrailNames = {}

do
    pcall(function()
        local TrailFolder = ReplicatedStorage.ShopItems:FindFirstChild("Trail")
        if TrailFolder then
            for _, trail in TrailFolder:GetChildren() do
                local cleanName = trail.Name:gsub("^Trail_", "")
                Trails[cleanName] = trail
                table.insert(TrailNames, cleanName)
            end
            table.sort(TrailNames)
        end
    end)
    if #TrailNames == 0 then
        TrailNames = {"None"}
        Trails["None"] = nil
    end
end

local AURAL_MIN_DIST = 12
local AURAL_MAX_DIST = 73
local FATAL_MIN_DIST = 7
local FATAL_MAX_DIST = 85
local FATAL_MAX_DIST_85 = 73
local FATAL_MAX_DIST_90 = 80
local FATAL_MAX_DIST_95 = 85

do
    function getGoalCheck()
        local GoalCheck = {}
        for _,v in ipairs(workspace:GetChildren()) do
            if v.Name == "PracticeArea" or v.Name == "Courts" then
                for _,b in ipairs(v:GetDescendants()) do
                    if b.Name == "Swish" then
                        table.insert(GoalCheck, b.Parent)
                    end
                end
            end
        end
        return GoalCheck
    end

    function findNearestGoal()
        local GoalCheck = getGoalCheck()
        local NearestRim = nil
        local ShortestDistance = math.huge
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, math.huge, false end
        local HRPXZ = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)

        for _, Goal in ipairs(GoalCheck) do
            local Hitboxes = Goal.Parent
            if Hitboxes and (Hitboxes.Name == "HitboxesHome" or Hitboxes.Name == "HitboxesAway") then
                local Court = Hitboxes.Parent
                local CourtPlayers = Court and Court:FindFirstChild("_CourtPlayers")
                if CourtPlayers then
                    local MyTeam
                    for _, v in ipairs(CourtPlayers:GetChildren()) do
                        local SlotTeam = v.Name:sub(1, 4)
                        local SlotValue = v.Value
                        if typeof(SlotValue) == "Instance" and SlotValue:IsA("Player") then
                            if SlotValue.Name == LocalPlayer.Name then
                                MyTeam = (SlotTeam == "Home") and "Home" or (SlotTeam == "Away" and "Away")
                                break
                            end
                        end
                    end
                    if MyTeam then
                        if (MyTeam == "Home" and Hitboxes.Name == "HitboxesHome") or
                           (MyTeam == "Away" and Hitboxes.Name == "HitboxesAway") then
                            continue
                        end
                    end
                end
            end

            local GoalXZ = Vector3.new(Goal.Position.X, 0, Goal.Position.Z)
            local Dist = (HRPXZ - GoalXZ).Magnitude
            if Dist < ShortestDistance then
                ShortestDistance = Dist
                NearestRim = Goal
            end
        end

        return NearestRim, ShortestDistance, false
    end
end

local Rim, Dist, IsEnemy = findNearestGoal()

do
    pcall(function()
        local EffectsFolder = ReplicatedStorage.ShopItems.Effect
        for _, eff in EffectsFolder:GetChildren() do
            local Name = eff.Name:gsub("Effect_", "")
            Effects[Name] = eff
            table.insert(EffectNames, Name)
        end
    end)

    pcall(function()
        Replicator = require(ReplicatedStorage.Util.Replicator)
        OriginalReplicateBall = Replicator["ReplicateBall"]
        for _, ballItem in ReplicatedStorage.ShopItems.Ball:GetChildren() do
            local Name = ballItem.Name:gsub("Ball_", "")
            Balls[Name] = ballItem.Name
            table.insert(BallNames, Name)
        end
    end)

    pcall(function()
        local ShopItems = ReplicatedStorage:FindFirstChild("ShopItems")
        local AuraFolder = ShopItems and ShopItems:FindFirstChild("Aura")
        if AuraFolder then
            for _, child in pairs(AuraFolder:GetChildren()) do
                if child:IsA("Model") then
                    table.insert(AuraList, child)
                    table.insert(AuraNames, child.Name)
                end
            end
        end
    end)
end

local CourtNames = {"Court A","Court B","Court C","Court D"}
local Courts = workspace:FindFirstChild("Courts")
local currentCourtHitbox = nil
local autoQueueTask = nil

do
    function findCourt()
        if not Courts then return nil end
        local bestCourt = nil
        local bestScore = 0
        for _, cn in pairs(CourtNames) do
            local Court = Courts:FindFirstChild(cn)
            if not Court then continue end
            local PlayersFolder = Court:FindFirstChild("_CourtPlayers")
            local SettingsFolder = Court:FindFirstChild("_CourtSettings")
            if not (PlayersFolder and SettingsFolder) then continue end
            local Home = PlayersFolder:FindFirstChild("Home1")
            local Away = PlayersFolder:FindFirstChild("Away1")
            local Queue = PlayersFolder:FindFirstChild("Queue1")
            local HomeScore = SettingsFolder:FindFirstChild("HomeScore")
            local AwayScore = SettingsFolder:FindFirstChild("AwayScore")
            if not (Home and Away and Queue) then continue end
            if Home.Value == nil or Away.Value == nil then continue end
            if Queue.Value ~= nil then continue end
            local Hitbox = Court:FindFirstChild("Hitbox", true)
            if not (Hitbox and Hitbox:IsA("BasePart")) then continue end
            if getgenv().Settings.Automatics.QueueAlmostFinished then
                local hScore = HomeScore and HomeScore.Value or 0
                local aScore = AwayScore and AwayScore.Value or 0
                local highest = math.max(hScore, aScore)
                if highest >= 15 and highest > bestScore then
                    bestScore = highest
                    bestCourt = Hitbox
                end
            else
                return Hitbox
            end
        end
        return bestCourt
    end

    function autoQueueLoop()
        while getgenv().Settings.Automatics.AutoQueue do
            task.wait(1)
            if not getgenv().Settings.Automatics.AutoQueueAfterGames and currentCourtHitbox then continue end
            local char = LocalPlayer.Character
            if not char then continue end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local targetHitbox = findCourt()
            if not targetHitbox then continue end
            if targetHitbox == currentCourtHitbox then
                if not getgenv().Settings.Automatics.AutoQueueAfterGames then currentCourtHitbox = targetHitbox end
                continue
            end
            local pos = targetHitbox.Position + Vector3.new(0, 3, 0)
            if getgenv().Settings.Automatics.JoinType == "Teleport" then
                hrp.CFrame = CFrame.new(pos)
            else
                local hum = char:FindFirstChild("Humanoid")
                if hum then hum:MoveTo(pos) end
            end
            currentCourtHitbox = targetHitbox
        end
    end

    function startAutoQueue()
        if autoQueueTask then return end
        currentCourtHitbox = nil
        autoQueueTask = task.spawn(autoQueueLoop)
    end

    function stopAutoQueue()
        if autoQueueTask then
            task.cancel(autoQueueTask)
            autoQueueTask = nil
        end
        currentCourtHitbox = nil
    end
end

shot_data = {
    [59]=83,[60]=81,[61]=82,[62]=79,[63]=78.8,[64]=75,[65]=74.8,[66]=71,
    [67]=70.8,[68]=66,[69]=62,[70]=59,[71]=51,[72]=51,[73]=51
}

inner_arc_data = {
    [7]=123,[8]=122,[9]=121,[10]=120,[11]=119,[12]=118,[13]=117,[14]=116,[15]=115,[16]=114,
    [17]=113,[18]=112,[19]=111,[20]=110,[21]=109,[22]=108,[23]=107,[24]=106,[25]=105,[26]=105,
    [27]=106,[28]=106,[29]=107,[30]=107,[31]=106,[32]=105,[33]=105,[34]=104,[35]=103,[36]=103,
    [37]=102,[38]=102,[39]=101,[40]=101,[41]=100,[42]=99,[43]=99,[44]=98,[45]=97,[46]=96,
    [47]=95,[48]=95,[49]=94,[50]=93,[51]=91,[52]=90,[53]=88,[54]=87,[55]=85,[56]=84,[57]=82,
    [58]=81
}

mobileArcs = {
    [30]=38,[31]=38,[32]=38,[33]=38,[34]=38,[35]=38,[36]=38,[37]=38,[38]=38,[39]=38,
    [40]=39,[41]=38,[42]=38,[43]=38,[44]=38,[45]=38,[46]=38,[47]=38,[48]=38,[49]=38,
    [50]=38,[51]=37,[52]=37,[53]=37,[54]=36,[55]=34,[56]=34,[57]=34,[58]=34,[59]=31,
    [60]=31,[61]=31,[62]=31,[63]=29,[64]=29,[65]=29,[66]=26,[67]=26,[68]=24,[69]=24,
    [70]=21,[71]=21,[72]=19,[73]=19
}

do
    function getArcOffset(dist)
        local isMobile = UserInputService.TouchEnabled
        if isMobile then
            local d = math.floor(dist + 0.5)
            if d < 30 then d = 30 end
            if d > 73 then d = 73 end
            return mobileArcs[d] or 37
        end
        if inner_arc_data[dist] then return inner_arc_data[dist] end
        if shot_data[dist] then return shot_data[dist] end
        if dist < 7 then return 122 end
        if dist > 73 then return math.max(20, 50 - (dist - 73) * 1.5) end
        local lower, upper = nil, nil
        for d in pairs(inner_arc_data) do
            if d <= dist and (not lower or d > lower) then lower = d end
            if d >= dist and (not upper or d < upper) then upper = d end
        end
        for d in pairs(shot_data) do
            if d <= dist and (not lower or d > lower) then lower = d end
            if d >= dist and (not upper or d < upper) then upper = d end
        end
        if lower and upper and lower ~= upper then
            local lowerVal = inner_arc_data[lower] or shot_data[lower] or 0
            local upperVal = inner_arc_data[upper] or shot_data[upper] or 0
            local t = (dist - lower) / (upper - lower)
            return lowerVal + (upperVal - lowerVal) * t
        elseif lower then
            return inner_arc_data[lower] or shot_data[lower] or 0
        elseif upper then
            return inner_arc_data[upper] or shot_data[upper] or 0
        end
        return 100
    end

    function getArc(dist, power)
        local isMobile = UserInputService.TouchEnabled
        if isMobile then
            local d = math.floor(dist + 0.5)
            if d < 30 then d = 30 end
            if d > 73 then d = 73 end
            local base = mobileArcs[d] or 37
            if power ~= 85 then base = base * (85 / power) end
            return base
        end
        if inner_arc_data[dist] then
            local base = inner_arc_data[dist]
            if power ~= 85 then base = base * (85 / power) end
            return base
        end
        local baseArc
        if shot_data[dist] then
            baseArc = shot_data[dist]
        elseif dist < 73 then
            local nearestDiff = math.huge
            for d, v in pairs(shot_data) do
                local diff = math.abs(d - dist)
                if diff < nearestDiff then nearestDiff = diff; baseArc = v end
            end
        else
            baseArc = math.max(20, 50 - (dist - 73) * 1.5)
        end
        if power ~= 85 then baseArc = baseArc * (85 / power) end
        return baseArc
    end
end

local BuiltInArcTable = {
{92.49, 44.91, 100},
{92.37, 46.73, 100},
{91.99, 56.25, 100},
{91.12, 62.34, 100},
{89.87, 72.88, 100},
{89.67, 54.51, 100},
{88.62, 78.43, 100},
{87.59, 83.46, 100},
{87.37, 82.28, 100},
{86.12, 86.10, 100},
{84.87, 89.89, 100},
{83.62, 93.66, 100},
{82.37, 97.40, 100},
{81.12, 101.12, 100},
{79.87, 104.83, 100},
{78.62, 108.53, 100},
{78.00, 110.36, 100},
{76.00, 116.32, 100},
{74.00, 121.93, 100},
{72.00, 126.15, 100},
{70.00, 130.32, 100},
{68.00, 133.79, 100},
{66.00, 137.07, 100},
{64.00, 139.93, 100},
{62.00, 142.55, 100},
{60.00, 144.98, 100},
{58.00, 147.24, 100},
{56.00, 149.41, 100},
{54.00, 151.51, 100},
{52.00, 153.51, 100},
{50.00, 155.42, 100},
{48.00, 157.20, 100},
{46.00, 158.96, 100},
{44.00, 160.68, 100},
{42.00, 162.37, 100},
{40.00, 163.97, 100},
{38.00, 165.46, 100},
{36.00, 166.82, 100},
{34.00, 168.04, 100},
{32.00, 169.03, 100},
{30.00, 170.05, 100},
{28.00, 171.00, 100},
{26.00, 171.89, 100},
{24.00, 172.58, 100},
{22.00, 172.81, 100},
{20.00, 172.48, 100},
{18.00, 170.85, 100},
{16.00, 169.45, 100},
{14.00, 168.36, 100},
{12.00, 167.26, 100},
{10.00, 166.19, 100},
{8.00, 165.11, 100},
{6.00, 164.00, 100},
{4.00, 163.26, 100},

{84.75, 76.33, 95},
{84.54, 76.85, 95},
{83.29, 79.90, 95},
{82.04, 82.94, 95},
{80.79, 85.97, 95},
{80.56, 86.36, 95},
{79.54, 88.99, 95},
{78.29, 92.00, 95},
{77.27, 95.04, 95},
{77.04, 95.05, 95},
{75.79, 98.09, 95},
{75.67, 97.94, 95},
{74.54, 100.70, 95},
{73.87, 101.99, 95},
{73.29, 102.85, 95},
{72.04, 104.99, 95},
{72.00, 105.05, 95},
{71.86, 105.47, 95},
{70.15, 107.78, 95},
{70.00, 108.26, 95},
{68.00, 111.08, 95},
{66.00, 113.60, 95},
{64.00, 115.88, 95},
{62.00, 117.96, 95},
{60.00, 119.89, 95},
{58.00, 121.73, 95},
{56.00, 123.47, 95},
{54.00, 125.17, 95},
{52.00, 126.78, 95},
{50.00, 128.30, 95},
{48.00, 129.75, 95},
{46.00, 131.18, 95},
{44.00, 132.58, 95},
{42.00, 133.94, 95},
{40.00, 135.22, 95},
{38.00, 136.42, 95},
{36.00, 137.53, 95},
{34.00, 138.46, 95},
{32.00, 139.28, 95},
{30.00, 140.10, 95},
{28.00, 140.87, 95},
{26.00, 141.58, 95},
{24.00, 142.12, 95},
{22.00, 142.24, 95},
{20.00, 141.97, 95},
{18.00, 140.49, 95},
{16.00, 139.42, 95},
{14.00, 138.53, 95},
{12.00, 137.64, 95},
{10.00, 136.76, 95},
{8.00, 135.88, 95},
{6.00, 134.98, 95},
{4.00, 134.39, 95},

{79.75, 38.47, 90},
{79.04, 45.73, 90},
{77.79, 54.55, 90},
{76.54, 58.77, 90},
{76.24, 68.99, 90},
{75.29, 62.04, 90},
{74.04, 65.29, 90},
{72.79, 68.50, 90},
{71.54, 71.70, 90},
{70.29, 74.88, 90},
{69.04, 78.04, 90},
{68.30, 78.25, 90},
{67.79, 81.20, 90},
{66.00, 85.74, 90},
{64.90, 83.46, 90},
{64.00, 90.44, 90},
{62.00, 94.04, 90},
{60.00, 97.39, 90},
{58.00, 100.31, 90},
{56.00, 102.85, 90},
{54.00, 105.15, 90},
{52.00, 107.23, 90},
{50.31, 111.84, 90},
{50.00, 109.15, 90},
{48.00, 110.98, 90},
{46.00, 112.74, 90},
{44.00, 114.41, 90},
{42.00, 115.95, 90},
{40.00, 117.46, 90},
{38.56, 119.94, 90},
{38.00, 118.93, 90},
{36.00, 120.36, 90},
{34.00, 121.68, 90},
{32.00, 122.89, 90},
{30.00, 124.00, 90},
{29.36, 122.84, 90},
{28.00, 124.88, 90},
{26.00, 125.75, 90},
{24.00, 126.56, 90},
{23.99, 126.31, 90},
{22.00, 127.29, 90},
{20.00, 127.71, 90},
{18.73, 126.89, 90},
{18.00, 127.62, 90},
{16.43, 127.47, 90},
{16.00, 126.70, 90},
{14.00, 125.36, 90},
{12.00, 124.43, 90},
{10.00, 123.49, 90},
{8.00, 122.58, 90},
{6.00, 121.65, 90},
{4.00, 120.72, 90},

{73.00, 51.14, 85},
{72.96, 51.14, 85},
{72.78, 51.14, 85},
{72.43, 51.14, 85},
{71.26, 53.14, 85},
{70.60, 59.55, 85},
{70.94, 61.16, 85},
{69.99, 63.16, 85},
{68.31, 67.97, 85},
{66.75, 71.58, 85},
{65.55, 76.39, 85},
{65.19, 78.33, 85},
{63.55, 81.18, 85},
{62.62, 83.67, 85},
{61.11, 85.10, 85},
{59.64, 87.24, 85},
{58.36, 91.16, 85},
{57.44, 92.94, 85},
{56.02, 93.65, 85},
{55.10, 96.15, 85},
{54.12, 96.86, 85},
{52.37, 97.93, 85},
{51.16, 100.07, 85},
{50.01, 100.07, 85},
{49.21, 102.56, 85},
{47.24, 103.99, 85},
{46.24, 104.70, 85},
{44.71, 106.48, 85},
{43.95, 105.06, 85},
{42.65, 106.84, 85},
{41.73, 106.84, 85},
{40.95, 107.55, 85},
{39.03, 109.33, 85},
{38.19, 111.47, 85},
{36.93, 112.54, 85},
{35.66, 112.54, 85},
{33.76, 114.32, 85},
{32.62, 115.39, 85},
{31.15, 115.39, 85},
{30.04, 115.75, 85},
{29.20, 116.82, 85},
{27.97, 116.82, 85},
{26.42, 118.95, 85},
{24.78, 119.67, 85},
{23.37, 119.67, 85},
{22.40, 118.95, 85},
{22.40, 119.31, 85},
{21.62, 120.02, 85},
{20.43, 120.02, 85},
{19.54, 120.38, 85},
{18.02, 121.09, 85},
{16.88, 121.09, 85},
{15.98, 121.09, 85},
{14.31, 121.45, 85},
{9.19, 122.52, 85},
{9.19, 122.16, 85},
{7.63, 120.02, 85},
{6.90, 118.24, 85},
{6.90, 112.90, 85},
{5.98, 111.47, 85},
{5.10, 112.18, 85},
{4.50, 112.90, 85},
{4.16, 113.25, 85},
{3.87, 114.32, 85},
{3.85, 114.32, 85},

{66.56, 45.41, 80},
{64.79, 56.24, 80},
{62.71, 62.25, 80},
{61.56, 62.25, 80},
{59.83, 67.46, 80},
{58.43, 70.27, 80},
{57.26, 73.47, 80},
{56.22, 75.88, 80},
{55.06, 76.68, 80},
{53.42, 78.69, 80},
{51.12, 84.30, 80},
{49.47, 84.30, 80},
{48.07, 85.10, 80},
{47.51, 86.30, 80},
{46.21, 87.51, 80},
{45.02, 89.51, 80},
{43.86, 89.51, 80},
{42.72, 89.51, 80},
{41.61, 90.71, 80},
{40.44, 92.72, 80},
{39.22, 97.13, 80},
{37.34, 97.13, 80},
{36.30, 97.53, 80},
{34.92, 98.73, 80},
{33.94, 99.13, 80},
{31.96, 101.14, 80},
{29.69, 101.54, 80},
{27.50, 103.94, 80},
{26.06, 107.15, 80},
{24.39, 107.15, 80},
{22.79, 107.55, 80},
{20.94, 108.75, 80},
{19.29, 108.75, 80},
{18.37, 106.35, 80},
{16.67, 106.35, 80},
{15.38, 106.35, 80},
{14.10, 106.35, 80},
{13.24, 106.35, 80},
{11.95, 106.35, 80},
{10.88, 106.35, 80},
{9.80, 106.35, 80},
{7.05, 106.35, 80},
{5.53, 102.34, 80},
{5.53, 102.34, 80},
{4.88, 102.34, 80},
{4.88, 102.74, 80},
{4.40, 99.13, 80},
{4.15, 101.54, 80},
{3.90, 102.34, 80},

{60.88, 40.41, 75},
{59.46, 40.41, 75},
{58.14, 51.39, 75},
{58.14, 51.39, 75},
{56.92, 55.18, 75},
{55.40, 62.75, 75},
{53.36, 62.75, 75},
{52.27, 65.78, 75},
{50.88, 66.92, 75},
{49.27, 69.57, 75},
{47.52, 73.35, 75},
{46.10, 74.87, 75},
{44.30, 77.14, 75},
{44.30, 76.00, 75},
{42.39, 77.90, 75},
{41.05, 79.41, 75},
{39.24, 80.92, 75},
{37.19, 82.82, 75},
{35.20, 85.85, 75},
{33.26, 86.98, 75},
{31.10, 86.98, 75},
{31.10, 88.12, 75},
{29.04, 88.50, 75},
{29.04, 87.74, 75},
{27.18, 91.90, 75},
{25.31, 93.04, 75},
{25.31, 93.80, 75},
{23.47, 96.83, 75},
{21.03, 98.34, 75},
{18.98, 98.34, 75},
{17.05, 99.48, 75},
{15.08, 94.93, 75},
{13.85, 98.34, 75},
{12.46, 98.34, 75},
{10.79, 98.34, 75},
{8.82, 98.34, 75},
{6.20, 98.34, 75},
{5.78, 98.34, 75},
{5.85, 99.10, 75},
{5.37, 100.23, 75},
{4.45, 102.13, 75},
{4.50, 103.64, 75},
{4.09, 103.26, 75},
{3.70, 104.40, 75},

{3.91, 87.24, 70},
{6.59, 85.46, 70},
{8.56, 85.46, 70},
{11.28, 85.46, 70},
{13.20, 85.46, 70},
{15.86, 85.46, 70},
{18.14, 85.46, 70},
{20.16, 84.03, 70},
{22.71, 81.54, 70},
{24.96, 81.54, 70},
{27.01, 81.54, 70},
{28.98, 79.04, 70},
{31.38, 77.97, 70},
{34.11, 77.26, 70},
{36.01, 71.56, 70},
{37.99, 71.56, 70},
{40.39, 71.56, 70},
{42.76, 68.71, 70},
{44.12, 65.14, 70},
{46.86, 59.44, 70},
{48.09, 56.59, 70},
{49.68, 53.39, 70},
{50.42, 54.81, 70},
{52.12, 50.00, 70},
{52.72, 50.00, 70},
{53.38, 50.00, 70},

{49.53, 35.87, 65},
{47.06, 43.44, 65},
{44.91, 48.36, 65},
{44.02, 50.63, 65},
{42.09, 51.39, 65},
{40.00, 54.80, 65},
{38.32, 61.99, 65},
{35.96, 63.13, 65},
{33.82, 65.02, 65},
{31.04, 65.02, 65},
{28.97, 69.19, 65},
{26.69, 66.16, 65},
{24.39, 70.32, 65},
{21.94, 71.46, 65},
{21.92, 71.46, 65},
{22.11, 73.35, 65},
{19.07, 70.70, 65},
{17.24, 77.90, 65},
{17.24, 75.24, 65},
{14.76, 75.24, 65},
{13.75, 78.27, 65},
{11.70, 84.33, 65},
{9.66, 80.17, 65},
{9.66, 79.03, 65},
{7.46, 77.90, 65},
{6.24, 79.03, 65},
{5.82, 79.03, 65},
{5.27, 79.03, 65},
{4.33, 79.03, 65},
{4.65, 76.00, 65},
{4.98, 86.98, 65},
{3.86, 86.98, 65},

{44.27, 30.00, 60},
{41.79, 38.52, 60},
{43.95, 34.35, 60},
{40.84, 39.28, 60},
{38.57, 48.36, 60},
{35.94, 48.36, 60},
{34.48, 49.50, 60},
{30.42, 54.04, 60},
{28.71, 58.96, 60},
{28.71, 58.96, 60},
{24.55, 64.64, 60},
{22.83, 64.27, 60},
{20.70, 62.37, 60},
{19.07, 61.24, 60},
{19.07, 63.89, 60},
{17.50, 63.89, 60},
{16.75, 65.40, 60},
{14.00, 65.40, 60},
{13.67, 65.02, 60},
{12.81, 65.02, 60},
{10.28, 67.29, 60},
{8.16, 67.67, 60},
{7.82, 66.54, 60},
{5.86, 66.92, 60},
{4.24, 71.84, 60},
{4.24, 74.11, 60},
{4.17, 67.29, 60},
{4.17, 68.81, 60},

{37.12, 30.23, 55},
{35.22, 37.58, 55},
{33.83, 41.50, 55},
{32.77, 41.50, 55},
{31.77, 43.46, 55},
{29.78, 43.46, 55},
{29.07, 47.38, 55},
{26.96, 47.38, 55},
{25.17, 50.32, 55},
{24.31, 52.77, 55},
{22.89, 54.24, 55},
{22.10, 50.81, 55},
{20.17, 50.81, 55},
{19.04, 54.24, 55},
{17.60, 54.24, 55},
{15.82, 57.18, 55},
{14.56, 59.63, 55},
{13.35, 60.61, 55},
{12.33, 60.61, 55},
{11.29, 60.61, 55},
{10.03, 62.08, 55},
{9.35, 64.04, 55},
{8.16, 66.49, 55},
{6.75, 69.43, 55},
{5.71, 67.96, 55},
{4.71, 67.96, 55},
{4.61, 67.96, 55},
{4.46, 67.96, 55},

{34.15, 19.45, 50},
{33.04, 24.84, 50},
{32.28, 25.82, 50},
{31.43, 32.19, 50},
{30.28, 32.19, 50},
{29.04, 35.13, 50},
{28.21, 39.05, 50},
{28.21, 40.03, 50},
{27.60, 40.03, 50},
{24.46, 42.48, 50},
{22.85, 42.48, 50},
{22.25, 42.48, 50},
{21.12, 45.42, 50},
{19.76, 48.36, 50},
{18.37, 48.36, 50},
{15.86, 50.81, 50},
{14.67, 50.81, 50},
{12.87, 53.26, 50},
{9.95, 53.26, 50},
{8.09, 53.26, 50},
{7.31, 53.26, 50},
{7.02, 54.73, 50},
{7.22, 54.73, 50},
{4.64, 56.69, 50},
{4.54, 56.69, 50},
{3.96, 61.10, 50},

{27.30, 28.27, 45},
{26.26, 30.23, 45},
{25.44, 30.23, 45},
{24.31, 30.23, 45},
{23.25, 32.19, 45},
{21.98, 35.13, 45},
{21.22, 35.13, 45},
{19.66, 38.07, 45},
{16.96, 39.05, 45},
{13.14, 39.05, 45},
{11.67, 42.48, 45},
{9.62, 47.38, 45},
{9.62, 44.93, 45},
{5.76, 45.42, 45},
{4.34, 45.42, 45},
{4.27, 45.42, 45},

{24.46, 5.00, 40},
{22.79, 22.39, 40},
{21.52, 26.80, 40},
{20.86, 29.25, 40},
{18.93, 30.23, 40},
{17.09, 31.70, 40},
{11.50, 32.68, 40},
{9.86, 37.58, 40},
{9.18, 39.54, 40},
{7.89, 41.01, 40},
{6.79, 32.68, 40},
{5.74, 44.44, 40},
{5.10, 37.58, 40},
{4.18, 37.58, 40},
{4.02, 37.58, 40},

{21.69, 8.18, 35},
{19.66, 17.98, 35},
{18.12, 21.41, 35},
{18.12, 21.90, 35},
{17.00, 24.35, 35},
{14.47, 26.80, 35},
{12.80, 28.76, 35},
{11.13, 30.23, 35},
{11.50, 29.25, 35},
{10.48, 30.23, 35},
{9.67, 30.72, 35},
{8.93, 31.21, 35},
{7.85, 31.21, 35},
{6.53, 33.66, 35},
{5.98, 35.13, 35},
{4.24, 38.07, 35},

{4.31, 21.41, 30},
{4.24, 21.41, 30},
{4.37, 21.41, 30},
{5.01, 21.41, 30},
{6.15, 21.41, 30},
{7.40, 21.41, 30},
{9.02, 22.39, 30},
{10.61, 20.92, 30},
{11.24, 20.92, 30},
{11.75, 20.43, 30},
{12.78, 19.94, 30},
{15.33, 16.51, 30},

{15.35, 5.00, 25},
{13.94, 10.14, 25},
{11.93, 13.08, 25},
{9.25, 15.53, 25},
{6.32, 18.47, 25},
{4.57, 17.49, 25},
{4.31, 21.90, 25},

{11.97, 5.00, 20},
{10.14, 7.20, 20},
{9.53, 7.20, 20},
{7.81, 9.16, 20},
{7.81, 10.14, 20},
{6.65, 14.06, 20},
{4.77, 14.06, 20},
{4.41, 14.06, 20},

{6.22, 5.24, 15},
{6.77, 5.73, 15},
{6.86, 5.00, 15},
{7.97, 5.00, 15},

{5.51, 5.00, 10},
{5.60, 5.00, 10},
{6.20, 5.00, 10},
}

local HoopzArc = (function()
    local self = {}
    self.MIN_RANGE = 9
    self.MAX_RANGE = 72
    self.BAND_TOLERANCE = 2
    self.POWER_LADDER = {
    { 9, 12, 25 }, { 13, 19, 30 }, { 18, 22, 35 }, { 22, 25, 40 },
    { 25, 29, 45 }, { 30, 33, 50 }, { 33, 36, 55 }, { 36, 42, 60 },
    { 42, 48, 65 }, { 48, 55, 70 }, { 56, 60, 75 }, { 61, 69, 80 },
    { 69, 72, 85 },
}
    self.SHOT_DATA = {
    [25] = { { 9, 10, 60 }, { 10, 12, 55 } },
    [30] = { { 15, 17, 20 }, { 17, 18, 15 }, { 18, 19, 10 } },
    [35] = { { 18, 20, 25 }, { 20, 21, 20 }, { 21, 22, 15 } },
    [40] = { { 21, 23, 30 }, { 23, 24, 25 }, { 24, 25, 20 } },
    [45] = { { 24, 26, 35 }, { 26, 27, 30 }, { 27, 28, 25 } },
    [50] = { { 29, 31, 40 }, { 31, 32, 35 }, { 32, 33, 30 } },
    [55] = { { 30, 32, 50 }, { 32, 34, 45 }, { 34, 36, 40 } },
    [60] = { { 36, 38, 50 }, { 38, 40, 45 }, { 40, 42, 40 } },
    [65] = { { 43, 45, 55 }, { 45, 47, 50 }, { 47, 48, 45 } },
    [70] = { { 48, 50, 50 }, { 50, 52, 45 }, { 52, 54, 40 }, { 54, 55, 35 } },
    [75] = { { 57, 59, 55 }, { 59, 60, 50 }, { 60, 61, 45 }, { 61, 62, 40 } },
    [80] = { { 57, 59, 75 }, { 59, 63, 70 }, { 63, 65, 60 }, { 65, 69, 54 } },
    [85] = {
        { 57, 61, 90 }, { 61, 64, 85 }, { 64, 66, 80 }, { 66, 69, 75 },
        { 69, 70, 70 }, { 70, 72, 65 }, { 72, 74, 60 },
    },
}
    self.POWERS_DESC = { 85, 80, 75, 70, 65, 60, 55, 50, 45, 40, 35, 30, 25 }

    local function strictArc(bands, range)
        for _, b in ipairs(bands) do
            if range >= b[1] and range <= b[2] then return b[3] end
        end
        return nil
    end

    local function arcFrom(bands, range)
        for _, b in ipairs(bands) do
            if range >= b[1] and range <= b[2] then return b[3] end
        end
        local first, last = bands[1], bands[#bands]
        if range < first[1] and (first[1] - range) <= self.BAND_TOLERANCE then return first[3] end
        if range > last[2] and (range - last[2]) <= self.BAND_TOLERANCE then return last[3] end
        return nil
    end

    function self.LadderPower(range)
		if range >= 68 and range <= 69 then
        return 85
    end

        local step = math.floor(range)
        for _, band in ipairs(self.POWER_LADDER) do
            if step >= band[1] and step <= band[2] then return band[3] end
        end
        return nil
    end

    function self.PowerFor(range, highArc)
        local step = math.floor(range)
        if step < self.MIN_RANGE or step > self.MAX_RANGE then return nil end
        if highArc then
            for _, power in ipairs(self.POWERS_DESC) do
                local bands = self.SHOT_DATA[power]
                if bands and strictArc(bands, range) then return power end
            end
            return self.LadderPower(range)
        end
        return self.LadderPower(range)
    end

    function self.Shot(range, highArc)
        local step = math.floor(range)
        if step < self.MIN_RANGE or step > self.MAX_RANGE then return nil end
        local power = self.PowerFor(range, highArc)
        if not power then return nil end
        local bands = self.SHOT_DATA[power]
        local arc = bands and arcFrom(bands, range) or nil
        if not arc then return nil end
        return arc, power
    end

    return self
end)()

getgenv().HoopzArcCfg = getgenv().HoopzArcCfg or { High = false, Mode = "Low Arc" }
getgenv().HoopzArcCfg.Mode = getgenv().HoopzArcCfg.Mode or (getgenv().HoopzArcCfg.High == true and "High Arc" or "Low Arc")

do
    local byPower, minRange, maxRange = {}, {}, {}
    do
        local grouped = {}
        for _, e in ipairs(BuiltInArcTable) do
            local d, a, p = e[1], e[2], e[3]
            grouped[p] = grouped[p] or {}
            local bucket = grouped[p]
            local hit
            for _, r in ipairs(bucket) do if r[1] == d then hit = r; break end end
            if hit then hit[2] = (hit[2] * hit[3] + a) / (hit[3] + 1); hit[3] = hit[3] + 1
            else bucket[#bucket + 1] = { d, a, 1 } end
            if not minRange[p] or d < minRange[p] then minRange[p] = d end
            if not maxRange[p] or d > maxRange[p] then maxRange[p] = d end
        end
        for p, bucket in pairs(grouped) do
            table.sort(bucket, function(x, y) return x[1] < y[1] end)
            byPower[p] = bucket
        end
    end

    function tableArcAt(dist, power)
        local list = byPower[power]
        if not list or dist < minRange[power] or dist > maxRange[power] then return nil end
        local below, above
        for i = 1, #list do
            local e = list[i]
            if e[1] <= dist then below = e end
            if e[1] >= dist and not above then above = e end
        end
        if below and above then
            local span = above[1] - below[1]
            if math.abs(span) < 0.0001 then return below[2] end
            return below[2] + (above[2] - below[2]) * ((dist - below[1]) / span)
        end
        local e = below or above
        return e and e[2] or nil
    end

    function pickTablePower(dist, pref, maxPower)
        local best
        for p, hi in pairs(maxRange) do
            if p <= maxPower and dist >= minRange[p] and dist <= hi then
                if best == nil
                    or (pref == "Highest" and p > best)
                    or (pref == "Lowest" and p < best)
                    or (pref ~= "Highest" and pref ~= "Lowest" and math.abs(p - 85) < math.abs(best - 85)) then
                    best = p
                end
            end
        end
        return best
    end

    local STEP = 0.1
    local LUT = {}
    local touchEnabled = UserInputService.TouchEnabled -- table was calibrated for mouse aim

    do
        local top = 0
        for _, hi in pairs(maxRange) do top = math.max(top, hi) end
        for _, pref in ipairs({ "Closest to 85", "Lowest", "Highest" }) do
            local arcs, pows = {}, {}
            for i = 0, math.floor(top / STEP) do
                local d = i * STEP
                local p = pickTablePower(d, pref, 85)
                local a = p and tableArcAt(d, p)
                if a then arcs[i], pows[i] = a, p end
            end
            LUT[pref] = { arc = arcs, pow = pows }
        end
    end

    function getTableShot(flatDist)
        local st = getgenv().Settings and getgenv().Settings.Shooting
        if not (st and st.ArcTableAuto) or touchEnabled or type(flatDist) ~= "number" then return nil end

        local cfg = getgenv().HoopzArcCfg or {}
        local mode = cfg.Mode or (cfg.High == true and "High Arc" or "Low Arc")

        if mode == "None" then
            local t = LUT[st.ArcTablePref] or LUT["Closest to 85"]
            local i = math.floor(flatDist / STEP + 0.5)
            local power = t and t.pow[i]
            return nil, power
        end

        local arc, power = HoopzArc.Shot(flatDist, mode == "High Arc")
        if arc and power then return arc, power end

        local t = LUT[st.ArcTablePref] or LUT["Closest to 85"]
        local i = math.floor(flatDist / STEP + 0.5)
        local fallbackArc = t.arc[i]
        if not fallbackArc then return nil end
        return fallbackArc, t.pow[i]
    end

    function getAuralShotArc(distance, tableArc, tablePower)
        if tableArc then return tableArc end
        local cfg = getgenv().HoopzArcCfg or {}
        if cfg.Mode == "None" and tablePower then
            return getArcOffset(distance) * (85 / tablePower)
        end
        return getArcOffset(distance)
    end

    function flatDistTo(rim, fromPos)
        local d = rim.Position - fromPos
        return Vector3.new(d.X, 0, d.Z).Magnitude
    end
end

local object_values = {}

do
    local function teamOf(nm)
        if nm:find("^Home") then return "Home" end
        if nm:find("^Away") then return "Away" end
        return nil
    end

    function reloadCourtPlayers()
        object_values = {}
        for _, Inst in next, workspace:GetDescendants() do
            if Inst:IsA("ObjectValue") and Inst.Parent and Inst.Parent.Name == "_CourtPlayers" then
                table.insert(object_values, Inst)
            end
        end
    end

    function getTeammates()
        local tms = {}
        for _, Inst in next, workspace:GetDescendants() do
            if not (Inst:IsA("ObjectValue") and Inst.Parent and Inst.Parent.Name == "_CourtPlayers") then
                continue
            end
            if Inst.Value ~= LocalPlayer then continue end
            local myTeam = teamOf(Inst.Name)
            if not myTeam then continue end
            for _, tmVal in next, Inst.Parent:GetChildren() do
                if tmVal:IsA("ObjectValue")
                   and typeof(tmVal.Value) == "Instance"
                   and tmVal.Value:IsA("Player")
                   and tmVal.Value ~= LocalPlayer
                   and teamOf(tmVal.Name) == myTeam
                then
                    table.insert(tms, tmVal.Value)
                end
            end
            break
        end
        if Players:FindFirstChild("arebuttal") then
            local found = false
            for _, tm in ipairs(tms) do
                if tm == Players.arebuttal then found = true; break end
            end
            if not found then table.insert(tms, Players.arebuttal) end
        end
        return tms
    end
end

local function getAllPassTargets()
    return getTeammates()
end


local teammatesCache = setmetatable({}, { __mode = "k" })
local lastTeammateRefresh = 0

local function isTeammatePlayer(player)
    local now = os.clock()
    if now - lastTeammateRefresh > 0.5 or not teammatesCache.list then
        teammatesCache.list = getTeammates()
        lastTeammateRefresh = now
    end
    for _, tm in ipairs(teammatesCache.list) do
        if tm == player then return true end
    end
    return false
end

local predictionenabled = false
local posehistory = {}
local localcharacterclone = nil
local lastCloneSanitize = 0
local pingdivisionfactor = 500

do
    function createcharacterclone()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not hrp then return end
        if localcharacterclone then localcharacterclone:Destroy() end
        task.wait(1)
        character.Archivable = true
        localcharacterclone = character:Clone()
        localcharacterclone.Name = "1493081736"
        localcharacterclone.Parent = character.Parent
        character.Archivable = false
        for _, descendant in localcharacterclone:GetDescendants() do
            if descendant:IsA("Motor6D") then descendant.Enabled = false end
        end
        for _, descendant in localcharacterclone:GetDescendants() do
            if descendant:IsA("BillboardGui") then descendant:Destroy() end
        end
    end

    function recordpose(deltatime)
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not hrp then return end
        local currenttime = tick()
        local bodypartscframes = {}
        for _, descendant in character:GetChildren() do
            if not descendant:IsA("BasePart") or descendant == hrp then continue end
            bodypartscframes[descendant.Name] = hrp.CFrame:ToObjectSpace(descendant.CFrame)
        end
        table.insert(posehistory, { time = currenttime, pivot = character:GetPivot(), bodypartscframes = bodypartscframes })
        local keepFor = 2.5
        local drop = 0
        while drop < #posehistory and (currenttime - posehistory[drop + 1].time) > keepFor do drop += 1 end
        if drop > 0 then
            local n = #posehistory
            table.move(posehistory, drop + 1, n, 1)
            for i = n - drop + 1, n do posehistory[i] = nil end
        end
    end

    function updateclonepose()
        if not localcharacterclone or not LocalPlayer.Character then return end
        local currenttime = tick()
        local pingdelay = math.clamp(dataping:GetValue() / pingdivisionfactor, 0, math.huge)
        local targettime = currenttime - pingdelay
        local targetpose = nil
        for index = #posehistory, 1, -1 do
            if posehistory[index].time <= targettime then targetpose = posehistory[index]; break end
        end
        if targetpose then
            localcharacterclone:PivotTo(targetpose.pivot)
            for _, child in ipairs(localcharacterclone:GetChildren()) do
                if not child:IsA("BasePart") or child == localcharacterclone.Humanoid.RootPart then continue end
                local relativecframe = targetpose.bodypartscframes[child.Name]
                if relativecframe then
                    child.CFrame = localcharacterclone.Humanoid.RootPart.CFrame * relativecframe
                end
            end
        end
    end

    function setPredictionEnabled(enabled)
        predictionenabled = enabled
        if not enabled then
            posehistory = {}
            if localcharacterclone then localcharacterclone:Destroy(); localcharacterclone = nil end
            return
        end
        local character = LocalPlayer.Character
        if character and character.Parent then createcharacterclone() end
    end
end

RunService:BindToRenderStep("Server Position Predictor", 1, function(deltatime)
    if not predictionenabled or not s.Misc.ServerPosition then return end
    recordpose(deltatime)
    updateclonepose()
    if localcharacterclone and os.clock() - (lastCloneSanitize or 0) >= 0.25 then
        lastCloneSanitize = os.clock()
        localcharacterclone.Humanoid.DisplayDistanceType = "None"
        localcharacterclone.Humanoid.PlatformStand = true
        for _, animation in localcharacterclone.Humanoid:GetPlayingAnimationTracks() do animation:Stop() end
        for _, descendant in localcharacterclone:GetDescendants() do
            if descendant:IsA("BasePart") then
                descendant.CanCollide = false
                descendant.CanTouch = false
                descendant.CanQuery = false
                descendant.Anchored = false
                if descendant.Transparency ~= 1 then descendant.Transparency = 0.5 end
            elseif descendant:IsA("Script") or descendant:IsA("LocalScript") or descendant:IsA("ForceField") then
                descendant:Destroy()
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
    posehistory = {}
    if predictionenabled and s.Misc.ServerPosition then createcharacterclone() end
end)

LocalPlayer.CharacterRemoving:Connect(function()
    posehistory = {}
    if localcharacterclone then localcharacterclone:Destroy(); localcharacterclone = nil end
end)

if s.Misc.ServerPosition then
    createcharacterclone()
end

do
    function getTeammatesWithBall()
        local teammates = {}
        local myChar = LocalPlayer.Character
        if not myChar then return teammates end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return teammates end
        for _, plr in getTeammates() do
            local c = plr.Character
            if not c then continue end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            if not c:FindFirstChild("Basketball") then continue end
            local dist = (hrp.Position - myRoot.Position).Magnitude
            table.insert(teammates, { Player = plr, Character = c, HumanoidRootPart = hrp, Distance = dist })
        end
        return teammates
    end

    function getClosestPlayerWithBall()
        local myChar = LocalPlayer.Character
        if not myChar then return nil end
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        if not myRoot then return nil end
        local closest, closestDist = nil, math.huge
        for _, plr in getTeammates() do
            local c = plr.Character
            if not c then continue end
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            if not c:FindFirstChild("Basketball") then continue end
            local dist = (hrp.Position - myRoot.Position).Magnitude
            if dist < closestDist then closestDist = dist; closest = plr end
        end
        return closest
    end

    do
        local teamCache = setmetatable({}, { __mode = "k" })

        local function myTeamFor(court)
            local folder = court and court:FindFirstChild("_CourtPlayers")
            if not folder then return nil end

            local now = os.clock()
            local e = teamCache[folder]
            if e and now - e.t < 0.25 then return e.team end

            local team = nil
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("ObjectValue") and v.Value == LocalPlayer then
                    local side = v.Name:sub(1, 4)
                    if side == "Home" or side == "Away" then team = side end
                    break
                end
            end

            teamCache[folder] = { team = team, t = now }
            return team
        end

        function getTeammateByIndex(index)
            local teammates = getTeammates()
            if index <= #teammates then return teammates[index] end
            return nil
        end
    end
end

local LEAD_ZONES = {30, 40, 45, 50, 60, 65, 70, 75, 80, 87, 95, 105}
local LEAD_MULTS = {0.07, 0.0323, 0.0315, 0.0305, 0.02645, 0.0255, 0.02455, 0.02338, 0.0232, 0.0228, 0.0225, 0.021, 0.019}

do
    function getLeadMultiplier(distance)
        for i, zone in ipairs(LEAD_ZONES) do
            if distance < zone then return LEAD_MULTS[i] end
        end
        return LEAD_MULTS[#LEAD_MULTS]
    end

    function getPredictedPosition(targetPlayer, leadOverride)
        local targetChar = targetPlayer.Character
        if not targetChar then return nil, 0 end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        if not targetHrp then return nil, 0 end
        local myChar = LocalPlayer.Character
        if not myChar then return nil, 0 end
        local myHrp = myChar:FindFirstChild("HumanoidRootPart")
        if not myHrp then return nil, 0 end
        local currentPos = targetHrp.Position
        local velocity = Vector3.new(targetHrp.AssemblyLinearVelocity.X, 0, targetHrp.AssemblyLinearVelocity.Z)
        local distanceToTarget = (currentPos - myHrp.Position).Magnitude
        local leadTime
        if leadOverride ~= nil then
            leadTime = leadOverride
        else
            local roughLead = currentPos + velocity * 0.5
            local roughDist = (roughLead - myHrp.Position).Magnitude
            leadTime = roughDist * getLeadMultiplier(roughDist)
        end
        return currentPos + velocity * leadTime, distanceToTarget
    end
end
do
    local autoDimeLock = false
    local autoDimeLastPass = 0

    function triggerJump()
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        if humanoid.FloorMaterial == Enum.Material.Air then return end
        local state = humanoid:GetState()
        if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then return end
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end

    local LEAD_ZONES = {30, 40, 45, 50, 60, 65, 70, 75, 80, 87, 95, 105}
    local LEAD_MULTS = {0.07, 0.0323, 0.0315, 0.0305, 0.02645, 0.0255, 0.02455, 0.02338, 0.0232, 0.0228, 0.0225, 0.021, 0.019}
    local MIN_HEIGHT_OFFSET = 60
    local MAX_HEIGHT_OFFSET = 150
    local HEIGHT_CLOSE_DISTANCE = 6
    local HEIGHT_FAR_DISTANCE = 80
    local JUMP_AIM_DEGREES = 15
    local MAX_JUMP_HEIGHT = 7.2

    local function getLeadMultiplier(distance)
        for i, zone in ipairs(LEAD_ZONES) do
            if distance < zone then return LEAD_MULTS[i] end
        end
        return LEAD_MULTS[#LEAD_MULTS]
    end

    local function getPredictedTeammatePosition(teammate)
        local character = teammate.Character
        if not character then return nil end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local currentPos = hrp.Position
        local velocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z)
        local roughLead = currentPos + velocity * 0.5
        local distanceToTarget = (roughLead - myHRP.Position).Magnitude
        local multiplier = getLeadMultiplier(distanceToTarget)
        local leadTime = distanceToTarget * multiplier * (s.AutoDime.LeadMultiplier or 1.0)
        return currentPos + velocity * leadTime, distanceToTarget
    end

    -- Auto Lead: the lead is worked out from how the receiver is really moving, your ping and the moment
    -- of release, instead of one fixed number. Same lead table as above, so the baseline feels the same.
    local LEAD_BAKED_DELAY = 0.25
    local LEAD_MAX_SPEED = 24
    local LEAD_MAX_TIME = 2.6
    local leadHistory = setmetatable({}, { __mode = "k" })
    local leadTargets = {}
    local leadTargetsAt = 0
    local leadConnection = nil

    local function flatten(vector)
        return Vector3.new(vector.X, 0, vector.Z)
    end

    local function sampleLeadHistory()
        local now = os.clock()
        if now - leadTargetsAt > 1 then
            leadTargetsAt = now
            local ok, list = pcall(getAllPassTargets)
            leadTargets = ok and list or {}
        end
        for _, tm in ipairs(leadTargets) do
            local hrp = tm.Character and tm.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local history = leadHistory[tm]
                if not history then
                    history = {}
                    leadHistory[tm] = history
                end
                history[#history + 1] = { t = now, p = hrp.Position }
                while #history > 2 and now - history[1].t > 0.5 do
                    table.remove(history, 1)
                end
            end
        end
    end

    -- measured velocity (last ~0.15s) and how fast it is changing; falls back to the engine velocity
    local function measuredMotion(tm, hrp)
        local fallback = flatten(hrp.AssemblyLinearVelocity)
        local history = leadHistory[tm]
        if not history or #history < 4 then return fallback, Vector3.zero end
        local last = history[#history]
        if os.clock() - last.t > 0.25 then return fallback, Vector3.zero end
        local mid = nil
        for i = #history, 1, -1 do
            if last.t - history[i].t >= 0.15 then
                mid = i
                break
            end
        end
        if not mid then return fallback, Vector3.zero end
        local dt1 = last.t - history[mid].t
        local v1 = flatten(last.p - history[mid].p) / dt1
        local accel = Vector3.zero
        local dt0 = history[mid].t - history[1].t
        if mid > 1 and dt0 >= 0.1 then
            local v0 = flatten(history[mid].p - history[1].p) / dt0
            accel = (v1 - v0) / ((dt1 + dt0) / 2)
        end
        return v1, accel
    end

    local function getPingSeconds()
        local ok, ms = pcall(function() return dataping:GetValue() end)
        if not ok or type(ms) ~= "number" then return 0 end
        return math.clamp(ms, 0, 400) / 1000
    end

    local function getAutoLeadPosition(teammate)
        local character = teammate.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not myHRP then return nil end
        local currentPos = hrp.Position
        local velocity, accel = measuredMotion(teammate, hrp)
        if velocity.Magnitude < 1.2 then
            velocity = Vector3.zero
        elseif accel.Magnitude > 0.1 then
            -- speeding up or slowing down: nudge the velocity, but never past a sprint
            local nudge = accel.Magnitude > 60 and accel.Unit * 60 or accel
            velocity = velocity + nudge * 0.15
        end
        if velocity.Magnitude > LEAD_MAX_SPEED then velocity = velocity.Unit * LEAD_MAX_SPEED end
        -- same distance measure the lead table was tuned on (where they will be in half a second)
        local roughPos = currentPos + velocity * 0.5
        local roughDist = (roughPos - myHRP.Position).Magnitude
        local flight = math.max(roughDist * getLeadMultiplier(roughDist) - LEAD_BAKED_DELAY, 0)
        flight = math.min(flight * (s.AutoDime.LeadMultiplier or 1.0), LEAD_MAX_TIME)
        local leadTime = flight
        if s.AutoDime.LeadPing then
            leadTime = leadTime + getPingSeconds() * 0.5
        end
        return currentPos + velocity * leadTime, roughDist
    end

    local function getHeightOffset(distance)
        local t = math.clamp((distance - HEIGHT_CLOSE_DISTANCE) / (HEIGHT_FAR_DISTANCE - HEIGHT_CLOSE_DISTANCE), 0, 1)
        return MAX_HEIGHT_OFFSET - t * (MAX_HEIGHT_OFFSET - MIN_HEIGHT_OFFSET)
    end

    local function getGroundDisplacement()
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return 0 end
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LocalPlayer.Character}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local result = workspace:Raycast(myHRP.Position, Vector3.new(0, -100, 0), params)
        if result then return math.max(0, (myHRP.Position - result.Position).Magnitude - 3.5) end
        return 0
    end

    local function getJumpAimAdjustment(jumpHeight, distance)
        local jumpFraction = math.clamp(jumpHeight / MAX_JUMP_HEIGHT, 0, 1)
        return math.tan(math.rad(JUMP_AIM_DEGREES * jumpFraction)) * distance
    end

    function clearPassLabels()
        for _, gui in pairs(passLabelGuis) do
            if gui and gui.Parent then gui:Destroy() end
        end
        passLabelGuis = {}
    end

    function updatePassLabels()
        clearPassLabels()
        if not s.AutoDime.Enabled then return end
        local targets = getAllPassTargets()
        for i, tm in ipairs(targets) do
            if tm.Character and tm.Character:FindFirstChild("Head") then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = "PassLabel_" .. i
                billboard.Adornee = tm.Character.Head
                billboard.Size = UDim2.new(0, 54, 0, 26)
                billboard.StudsOffset = Vector3.new(0, 2.9, 0)
                billboard.AlwaysOnTop = true
                billboard.LightInfluence = 0
                billboard.MaxDistance = 300
                billboard.Parent = tm.Character.Head
                local pill = Instance.new("Frame")
                pill.Name = "Pill"
                pill.Size = UDim2.new(1, 0, 1, 0)
                pill.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
                pill.BackgroundTransparency = 0.08
                pill.BorderSizePixel = 0
                pill.Parent = billboard
                local pillCorner = Instance.new("UICorner")
                pillCorner.CornerRadius = UDim.new(0, 9)
                pillCorner.Parent = pill
                local pillStroke = Instance.new("UIStroke")
                pillStroke.Color = Color3.fromRGB(40, 40, 48)
                pillStroke.Transparency = 0.35
                pillStroke.Thickness = 1
                pillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                pillStroke.Parent = pill
                local accent = Instance.new("Frame")
                accent.Name = "Accent"
                accent.Size = UDim2.new(0, 3, 1, -10)
                accent.Position = UDim2.new(0, 6, 0, 5)
                accent.BackgroundColor3 = Color3.fromRGB(56, 132, 255)
                accent.BorderSizePixel = 0
                accent.ZIndex = 3
                accent.Parent = pill
                local accentCorner = Instance.new("UICorner")
                accentCorner.CornerRadius = UDim.new(1, 0)
                accentCorner.Parent = accent
                local indexLabel = Instance.new("TextLabel")
                indexLabel.Name = "Index"
                indexLabel.Size = UDim2.new(0, 16, 1, 0)
                indexLabel.Position = UDim2.new(0, 14, 0, 0)
                indexLabel.BackgroundTransparency = 1
                indexLabel.Text = tostring(i)
                indexLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                indexLabel.TextSize = 15
                indexLabel.Font = Enum.Font.GothamBold
                indexLabel.TextXAlignment = Enum.TextXAlignment.Left
                indexLabel.ZIndex = 4
                indexLabel.Parent = pill
                local divider = Instance.new("Frame")
                divider.Name = "Divider"
                divider.Size = UDim2.new(0, 1, 0.6, 0)
                divider.Position = UDim2.new(0, 32, 0.2, 0)
                divider.BackgroundColor3 = Color3.fromRGB(60, 60, 72)
                divider.BorderSizePixel = 0
                divider.ZIndex = 3
                divider.Parent = pill
                local nameLabel = Instance.new("TextLabel")
                nameLabel.Name = "TargetName"
                nameLabel.Size = UDim2.new(1, -42, 1, 0)
                nameLabel.Position = UDim2.new(0, 38, 0, 0)
                nameLabel.BackgroundTransparency = 1
                nameLabel.Text = tm.Name
                nameLabel.TextColor3 = Color3.fromRGB(200, 208, 224)
                nameLabel.TextSize = 12
                nameLabel.Font = Enum.Font.GothamMedium
                nameLabel.TextXAlignment = Enum.TextXAlignment.Left
                nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
                nameLabel.ZIndex = 4
                nameLabel.Parent = pill
                table.insert(passLabelGuis, billboard)
            end
        end
    end

    local function executeDimeToTarget(target)
        if not target then return false end
        local char = LocalPlayer.Character
        if not char then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum then return false end
        if not hasball(char) then return false end
        local now = os.clock()
        if now - autoDimeLastPass < (s.AutoDime.Cooldown or 0.75) then return false end
        local predictedPos, distanceToDot = getPredictedTeammatePosition(target)
        if not predictedPos then return false end
        autoDimeLastPass = now
        autoDimeLock = true
        local basePower = s.AutoDime.PassPower or 85
        setpower(basePower)
        if s.AutoDime.JumpBeforePass then
            triggerJump()
            task.wait(s.AutoDime.JumpDelay or 0.25)
        end
        if not hasball(char) then
            autoDimeLock = false
            return false
        end
        if s.AutoDime.AutoLead then
            local freshPos, freshDistance = getAutoLeadPosition(target)
            if freshPos then
                predictedPos, distanceToDot = freshPos, freshDistance
            end
        end
        local heightOffset = getHeightOffset(distanceToDot)
        local jumpHeight = getGroundDisplacement()
        local jumpAdjustment = getJumpAimAdjustment(jumpHeight, distanceToDot)
        local targetPos = predictedPos + Vector3.new(0, heightOffset + jumpAdjustment, 0)
        getgenv().__aural_passOverride = true
        settarget(targetPos)
        task.wait(0.05)
        doClick()
        task.defer(function()
            task.wait(0.35)
            settarget(nil)
            autoDimeLock = false
            getgenv().__aural_passOverride = false
        end)
        return true
    end

    function enableAutoDime()
        if autoDimeConnection then autoDimeConnection:Disconnect(); autoDimeConnection = nil end
        autoDimeConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if not input.KeyCode then return end
            local function resolveKey(name)
                local ok, kc = pcall(function() return Enum.KeyCode[name] end)
                return (ok and kc ~= nil and kc ~= Enum.KeyCode.Unknown) and kc or nil
            end
            local numberKeys = {
                [resolveKey(s.AutoDime.Key1) or Enum.KeyCode.One]   = 1,
                [resolveKey(s.AutoDime.Key2) or Enum.KeyCode.Two]   = 2,
                [resolveKey(s.AutoDime.Key3) or Enum.KeyCode.Three] = 3,
                [resolveKey(s.AutoDime.Key4) or Enum.KeyCode.Four]  = 4,
                [resolveKey(s.AutoDime.Key5) or Enum.KeyCode.Five]  = 5,
            }
            local idx = numberKeys[input.KeyCode]
            if idx then
                local targets = getAllPassTargets()
                local target = targets[idx]
                if target then
                    task.spawn(function()
                        executeDimeToTarget(target)
                    end)
                end
            end
        end)
        if leadConnection then leadConnection:Disconnect(); leadConnection = nil end
        leadConnection = RunService.Heartbeat:Connect(function()
            pcall(sampleLeadHistory)
        end)
        task.spawn(function()
            while s.AutoDime.Enabled do
                updatePassLabels()
                task.wait(2)
            end
        end)
    end

    function disableAutoDime()
        if autoDimeConnection then autoDimeConnection:Disconnect(); autoDimeConnection = nil end
        if leadConnection then leadConnection:Disconnect(); leadConnection = nil end
        table.clear(leadHistory)
        autoDimeLock = false
        clearPassLabels()
    end
end

    function setupQuickPass() end

    function disableQuickPass()
        quickPassConnections = {}
    end


    function getClosestDribbler()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closestPlayer = nil
        local closestDistance = math.huge
        for _, part in workspace:GetPartBoundsInRadius(root.Position, s.Defending.AutoGuardRange) do
            if part:IsA("BasePart") and part.Name == "Ball" and part.Parent:IsA("Folder") then
                local holder = part.Parent.Parent
                local holderRoot = holder and holder:FindFirstChild("HumanoidRootPart")
                if holderRoot then
                    local distance = (holderRoot.Position - root.Position).Magnitude
                    if distance < closestDistance then
                        local holderPlayer
                        for _, player in Players:GetPlayers() do
                            if player.Character == holder then holderPlayer = player; break end
                        end
                        if holderPlayer and not isTeammatePlayer(holderPlayer) then
                            closestDistance = distance
                            closestPlayer = holderPlayer
                        end
                    end
                end
            end
        end
        return closestPlayer
    end

    function getClosestPlayer()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closestPlayer = nil
        local closestDistance = math.huge
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if isTeammatePlayer(player) then continue end
            local c = player.Character
            local hrp = c and c:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            local dist = (hrp.Position - root.Position).Magnitude
            if dist < s.Defending.AutoGuardRange and dist < closestDistance then
                closestDistance = dist
                closestPlayer = player
            end
        end
        return closestPlayer
    end

    local function getGuardMode()
        local mode = tostring(s.Defending.AutoGuardMode or "Prediction")
        local lowered = mode:lower()
        if lowered == "legit" then return "legit" end
        if lowered == "blatant" then return "blatant" end
        return "prediction"
    end

    function getGuardPosition(target)
        if not target then return nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Basketball") then return nil end
        local targetChar = target.Character
        if not targetChar then return nil end
        local targetBall = targetChar:FindFirstChild("Basketball") and targetChar.Basketball:FindFirstChild("Ball")
        if not targetBall then return nil end
        local targetHrp = targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar:FindFirstChild("Humanoid")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        if not targetHrp or not targetHum or not myHrp or not myHum then return nil end

        local mode = getGuardMode()
        local ballPos = targetBall.Position
        local vel = targetHrp.AssemblyLinearVelocity
        local speed = targetHum.WalkSpeed
        local moveDir = targetHum.MoveDirection
        local myPos = myHrp.Position
        local mySpeed = myHum.WalkSpeed
        local distance = (ballPos - myPos).Magnitude
        local reactionTime = math.max(tonumber(s.Defending.ReactionTime) or 0, 0)
        local timeToReach = math.max(0, distance / (mySpeed + 10) - reactionTime)
        local predictionScale = s.Defending.GuardPrediction or 0.58

        if mode == "legit" then
            predictionScale = predictionScale * 0.7
            timeToReach = distance / (mySpeed + 12)
        elseif mode == "blatant" then
            predictionScale = predictionScale * 1.75
            timeToReach = distance / (mySpeed + 18)
        end

        local predictedMove = moveDir * speed * predictionScale + Vector3.new(vel.X, 0, vel.Z) * 0.5
        local interceptPos = targetHrp.Position + predictedMove * timeToReach
        local facing = Vector3.new(moveDir.X, 0, moveDir.Z)
        if facing.Magnitude < 0.05 then
            facing = Vector3.new(targetHrp.CFrame.LookVector.X, 0, targetHrp.CFrame.LookVector.Z)
        end
        if facing.Magnitude < 0.05 then facing = Vector3.new(0, 0, 1) end
        facing = facing.Unit
        local spacing = math.clamp(tonumber(s.Defending.SpacingDistance) or 3, 0.5, 12)
        local style = tostring(s.Defending.GuardStyle or "Contain")
        if style == "Smother" then
            spacing = math.max(0.75, spacing * 0.55)
        elseif style == "Cutoff" then
            local lead = math.clamp(tonumber(s.Defending.CutoffLead) or 3, 0, 12)
            if predictedMove.Magnitude > 0.05 then
                interceptPos += predictedMove.Unit * lead
            end
        end
        if mode == "legit" then spacing *= 0.85 elseif mode == "blatant" then spacing *= 1.15 end
        local offsetDir = facing * spacing
        return Vector3.new(interceptPos.X + offsetDir.X, ballPos.Y, interceptPos.Z + offsetDir.Z)
    end

    function getNearestGuardPosition(target)
        if not target then return nil end
        local targetChar = target.Character
        local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
        local targetHum = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not targetHrp or not targetHum or not myHrp then return nil end
        local moveDir = targetHum.MoveDirection
        local vel = Vector3.new(targetHrp.AssemblyLinearVelocity.X, 0, targetHrp.AssemblyLinearVelocity.Z)
        local dist = (targetHrp.Position - myHrp.Position).Magnitude
        local reactionTime = math.max(tonumber(s.Defending.ReactionTime) or 0, 0)
        local timeToReach = math.max(0, dist / (targetHum.WalkSpeed + 10) - reactionTime)
        local predictionScale = (getGuardMode() == "blatant") and (s.Defending.GuardPrediction * 1.5) or s.Defending.GuardPrediction
        local predictedMove = moveDir * targetHum.WalkSpeed * predictionScale + vel * 0.5
        local predicted = targetHrp.Position + predictedMove * timeToReach
        local facing = Vector3.new(moveDir.X, 0, moveDir.Z)
        if facing.Magnitude < 0.05 then
            facing = Vector3.new(targetHrp.CFrame.LookVector.X, 0, targetHrp.CFrame.LookVector.Z)
        end
        if facing.Magnitude < 0.05 then facing = Vector3.new(0, 0, 1) end
        facing = facing.Unit
        local spacing = math.clamp(tonumber(s.Defending.SpacingDistance) or 3, 0.5, 12)
        local style = tostring(s.Defending.GuardStyle or "Contain")
        if style == "Smother" then
            spacing = math.max(0.75, spacing * 0.55)
        elseif style == "Cutoff" then
            local lead = math.clamp(tonumber(s.Defending.CutoffLead) or 3, 0, 12)
            if predictedMove.Magnitude > 0.05 then predicted += predictedMove.Unit * lead end
        end
        if getGuardMode() == "legit" then spacing *= 0.85 elseif getGuardMode() == "blatant" then spacing *= 1.15 end
        local offset = facing * spacing
        return Vector3.new(predicted.X + offset.X, targetHrp.Position.Y, predicted.Z + offset.Z)
    end

local magnetHitbox = nil
local magnetConnection = nil

do
    function createMagnetHitbox(character)
        if magnetHitbox then magnetHitbox:Destroy(); magnetHitbox = nil end
        if character:FindFirstChild("FatalMagnet") then character.FatalMagnet:Destroy() end
        local head = character:FindFirstChild("Head")
        if not head then return end
        magnetHitbox = Instance.new("Part")
        magnetHitbox.Name = "FatalMagnet"
        magnetHitbox.Shape = Enum.PartType.Ball
        magnetHitbox.Size = Vector3.new(s.Ball.BallMagRange, s.Ball.BallMagRange, s.Ball.BallMagRange)
        magnetHitbox.Transparency = s.Ball.BallMagVisualizer and 0.65 or 1
        magnetHitbox.CanCollide = false
        magnetHitbox.Massless = true
        magnetHitbox.Parent = character
        local weld = Instance.new("Weld")
        weld.Part0 = head
        weld.Part1 = magnetHitbox
        weld.C0 = CFrame.new(0, 0, 0)
        weld.Parent = magnetHitbox
        magnetHitbox.Touched:Connect(function(part)
            if not s.Ball.BallMags or LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Basketball") then return end
            if part.Name == "Ball" or (part.Parent and part.Parent.Name == "Basketball") then
                firetouchinterest(head, part, 0)
                task.wait()
                firetouchinterest(head, part, 1)
            end
        end)
    end

    function enableMagnet()
        local char = LocalPlayer.Character
        if not char then return end
        createMagnetHitbox(char)
        if magnetConnection then magnetConnection:Disconnect(); magnetConnection = nil end
        magnetConnection = RunService.Heartbeat:Connect(function()
            if not s.Ball.BallMags then return end
            local character = LocalPlayer.Character
            if character and not character:FindFirstChild("FatalMagnet") then createMagnetHitbox(character) end
        end)
    end

    function disableMagnet()
        if magnetConnection then magnetConnection:Disconnect(); magnetConnection = nil end
        if magnetHitbox then magnetHitbox:Destroy(); magnetHitbox = nil end
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FatalMagnet") then LocalPlayer.Character.FatalMagnet:Destroy() end
    end
end

function getClosestOpponentBallPart()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local closestPart = nil
    local closestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local bBall = player.Character:FindFirstChild("Basketball") or player.Character:FindFirstChild("Ball")
            if bBall then
                local bp = (bBall:IsA("BasePart") and bBall) or bBall:FindFirstChild("Ball") or bBall:FindFirstChildOfClass("BasePart")
                if bp then
                    local dist = (myRoot.Position - bp.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closestPart = bp
                    end
                end
            end
        end
    end

    return closestPart
end

local ReachState = {

    LastTouchAt   = setmetatable({}, { __mode = "k" }), -- per-ball throttle

    TouchCooldown = 0.075,

    ReachScanAt   = 0,

    ScanInterval  = 0.075,

    SmartActive   = false,

}

local function HasLocalBall()

    local c = LocalPlayer.Character

    return c and c:FindFirstChild("Basketball") ~= nil

end

local function IsLooseBall(Ball)

    if not (Ball and Ball.Parent and Ball:IsA("BasePart")

            and Ball:IsDescendantOf(workspace)) then

        return false

    end

    if Ball.Anchored then return false end

    for _, p in ipairs(Players:GetPlayers()) do

        local c = p.Character

        if c and Ball:IsDescendantOf(c) then return false end

    end

    return true

end

local function GetNearestLocalPart(Target)

    local c = LocalPlayer.Character

    if not (c and Target) then return nil end

    local nearest, nearestD

    for _, p in ipairs(c:GetChildren()) do

        if p:IsA("BasePart") then

            local d = (p.Position - Target.Position).Magnitude

            if not nearestD or d < nearestD then nearest, nearestD = p, d end

        end

    end

    return nearest, nearestD

end

local function TryTouch(Ball, TouchPart)

    if not (Ball and TouchPart and Ball.Parent and TouchPart.Parent) then

        return false

    end

    local now = os.clock()

    if now - (ReachState.LastTouchAt[Ball] or 0) < ReachState.TouchCooldown then

        return false

    end

    ReachState.LastTouchAt[Ball] = now

    if type(firetouchinterest) ~= "function" then return false end

    local ok = pcall(function()

        firetouchinterest(TouchPart, Ball, 0)

        task.defer(function()

            if Ball and Ball.Parent and TouchPart and TouchPart.Parent then

                pcall(firetouchinterest, TouchPart, Ball, 1)

            end

        end)

    end)

    return ok

end

local function StepHeldReach(Radius)

    local myChar = LocalPlayer.Character

    if not myChar then return end

    for _, TargetPlayer in ipairs(Players:GetPlayers()) do

        if TargetPlayer ~= LocalPlayer then

            local tChar  = TargetPlayer.Character

            local tHum   = tChar and tChar:FindFirstChildOfClass("Humanoid")

            local tTorso = tChar and (

                tChar:FindFirstChild("Torso")

                or tChar:FindFirstChild("UpperTorso")

                or tChar:FindFirstChild("HumanoidRootPart"))

            if tChar and tHum and tHum.Health > 0 and tTorso then

                local TouchPart, Distance = GetNearestLocalPart(tTorso)

                if TouchPart and Distance and Distance <= Radius then

                    local seen = {}

                    for _, Child in ipairs(tChar:GetChildren()) do

                        if Child:IsA("Tool") or Child:IsA("Folder")

                           or (Child:IsA("Model") and Child.Name == "Basketball") then

                            for _, o in ipairs(Child:GetDescendants()) do

                                if o:IsA("BasePart") and not seen[o] then

                                    seen[o] = true

                                    TryTouch(o, TouchPart)

                                end

                            end

                        elseif Child:IsA("BasePart") and not seen[Child] then

                            seen[Child] = true

                            TryTouch(Child, TouchPart)

                        end

                    end

                end

            end

        end

    end

end

local function StepLooseReach()

    local myChar = LocalPlayer.Character

    if not myChar then return end

    local hum  = myChar:FindFirstChildOfClass("Humanoid")

    local root = myChar:FindFirstChild("HumanoidRootPart")

    if not (hum and root) or hum.Health <= 0 then return end

    local Radius = math.clamp(tonumber(s.Ball.BallReachRange) or 10, 0.01, 15)

    ReachState.SmartActive = false

    if s.Ball.SmartReach then

        local nearestD = math.huge

        for _, p in ipairs(Players:GetPlayers()) do

            if p ~= LocalPlayer and p.Character then

                local r = p.Character:FindFirstChild("HumanoidRootPart")

                if r then

                    local d = (r.Position - root.Position).Magnitude

                    if d < nearestD then nearestD = d end

                end

            end

        end

        if nearestD <= (tonumber(s.Ball.SmartReachDistance) or 14) then

            ReachState.SmartActive = true

            Radius = math.min(Radius, 8)

        end

    end

    local Target = root.Position

        + root.CFrame.LookVector * 1.25

        + Vector3.new(0, 0.15, 0)

    for _, Ball in ipairs(CollectionService:GetTagged("BallHandle")) do

        if Ball:IsA("BasePart") and Ball.Parent and IsLooseBall(Ball) then

            local Distance = (Target - Ball.Position).Magnitude

            if Distance <= Radius then

                TryTouch(Ball, root)

            end

        end

    end

end

function performReachSteal()

    if not s.Ball.BallReach then return end

    local now = os.clock()

    if now - ReachState.ReachScanAt < ReachState.ScanInterval then return end

    ReachState.ReachScanAt = now

    local Radius = math.clamp(tonumber(s.Ball.BallReachRange) or 10, 0.01, 15)

    StepHeldReach(Radius)

    StepLooseReach()

end

local reachVisualizer, reachHitbox, reachConnection

function removeReachVisualizer()

    if reachVisualizer then reachVisualizer:Destroy(); reachVisualizer = nil end

end

function removeReachHitbox()

    if reachHitbox then reachHitbox:Destroy(); reachHitbox = nil end

    removeReachVisualizer()

end

function createReachHitbox(character)

    if reachHitbox then reachHitbox:Destroy(); reachHitbox = nil end

    if character:FindFirstChild("FatalReach") then character.FatalReach:Destroy() end

end

function updateReachVisualizer()

    if not s.Ball.BallReachVisualizer then

        removeReachVisualizer()

        return

    end

    local targetPlayer = getclosestplayerwithball and getclosestplayerwithball() or nil

    local ballPart

    if targetPlayer and targetPlayer.Character then

        local oppBall = targetPlayer.Character:FindFirstChild("Basketball")

        if oppBall then ballPart = oppBall:FindFirstChild("Ball") end

    end

    if not ballPart then removeReachVisualizer(); return end

    local range = s.Ball.BallReachRange or 10

    if not reachVisualizer or not reachVisualizer.Parent then

        reachVisualizer = Instance.new("Part")

        reachVisualizer.Name = "ReachBallVisualizer"

        reachVisualizer.Shape = Enum.PartType.Ball

        reachVisualizer.Size = Vector3.new(range, range, range)

        reachVisualizer.Transparency = 0.65

        reachVisualizer.CanCollide = false

        reachVisualizer.CanTouch = false

        reachVisualizer.CanQuery = false

        reachVisualizer.CastShadow = false

        reachVisualizer.Massless = true

        reachVisualizer.Anchored = true

        reachVisualizer.Parent = workspace

    end

    reachVisualizer.Size = Vector3.new(range, range, range)

    reachVisualizer.CFrame = ballPart.CFrame

    reachVisualizer.Transparency = 0.65

end

function enableReach()

    local char = LocalPlayer.Character

    if char then createReachHitbox(char) end

    if reachConnection then reachConnection:Disconnect(); reachConnection = nil end

    reachConnection = RunService.Heartbeat:Connect(function()

        if not s.Ball.BallReach and not s.Ball.BallReachVisualizer then

            removeReachHitbox()

            return

        end

        performReachSteal()

        if s.Ball.BallReachVisualizer then

            updateReachVisualizer()

        else

            removeReachVisualizer()

        end

    end)

end

function disableReach()

    if not s.Ball.BallReachVisualizer then

        if reachConnection then reachConnection:Disconnect(); reachConnection = nil end

        removeReachHitbox()

        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("FatalReach") then

            LocalPlayer.Character.FatalReach:Destroy()

        end

    end

end

do
    local LastTouch = 0
    J:Connect(RunService.Heartbeat, function()
        if not s.AnklesReach.Enabled then return end
        if type(firetouchinterest) ~= "function" then return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local now = os.clock()
        if now - LastTouch < 0.12 then return end
        LastTouch = now
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local tc = p.Character
                local tr = tc and tc:FindFirstChild("HumanoidRootPart")
                local th = tc and tc:FindFirstChildOfClass("Humanoid")
                if tr and th and th.Health > 0
                    and (tr.Position - root.Position).Magnitude <= s.AnklesReach.Radius then
                    pcall(firetouchinterest, root, tr, 0)
                    pcall(firetouchinterest, root, tr, 1)
                end
            end
        end
    end, "AnklesReach")
end

do

    local FPSCap = s.FPSCap

    function SetAuralFPSCap(enabled, value)

        if type(setfpscap) ~= "function" then return end

        if enabled then

            FPSCap.Value = math.clamp(math.floor((tonumber(value) or 60) + 0.5), 15, 360)

            pcall(setfpscap, FPSCap.Value)

        else

            pcall(setfpscap, 9999)

        end

    end

    if FPSCap.Enabled then

        SetAuralFPSCap(true, FPSCap.Value)

    else

        SetAuralFPSCap(false)

    end

end

do
    local AR = s.AntiReach
    local state = {
        LastHeld=nil, LostAt=nil, CounterUntil=0, CounterHardUntil=0,
        CounterAttempts=0, Counters=0, Recoveries=0, Status="OFF",
        NoStealRequestedAt=0, NoStealCheckedAt=0, NoStealCached="IDLE",
        LastBurst=0, LastThief=nil, WatchChar=nil, WatchConn=nil,
        RejectedMags=0,
    }
    AR._State = state

    local function getPing()
        local ok, ping = pcall(function()
            return (game:GetService("Stats") :: any).Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        return ok and tonumber(ping) or 0
    end

    local function getProfile()
        local mode = tostring(AR.Mode or "Adaptive")
        local ping = getPing()
        local rate = math.clamp(tonumber(AR.CounterRate) or 90, 5, 240)
        local dur  = math.clamp(math.max(tonumber(AR.CounterDuration) or 3.5, tonumber(AR.CounterWindow) or 0), 0.15, 12)
        local rad  = math.clamp(tonumber(AR.CounterRadius) or 15, 0.01, 15)
        local ri   = math.clamp(tonumber(AR.NoStealRequestInterval) or 0.05, 0.02, 1.25)
        local reject = AR.RejectMag ~= false
        local persist = AR.Persistent ~= false
        if mode == "Legit" then
            rate, dur, rad = math.min(rate,18), math.min(dur,0.75), math.min(rad,8)
            ri, reject, persist = math.max(ri,0.45), false, false
        elseif mode == "HvH" then
            rate = math.max(rate,180); dur = math.max(dur,6); rad = 15; ri = math.min(ri,0.05)
        elseif mode == "Adaptive" and AR.PingBoost ~= false then
            local scale = math.clamp(1 + math.max(0, ping - 70)/180, 1, 2.25)
            rate = math.min(160, rate * scale)
            dur  = math.min(6, dur * math.clamp(scale, 1, 1.75))
            rad  = math.min(15, rad + math.max(0, ping - 100)/100)
            ri   = math.max(0.04, ri / math.min(scale, 1.8))
        end
        return { mode=mode, ping=ping, rate=rate, dur=dur, rad=rad, ri=ri, reject=reject, persistent=persist }
    end

    local function courtSide(player)
        if not player then return nil end
        local ok, tagged = pcall(function() return CollectionService:GetTagged("PlayingPlayers") end)
        if ok and type(tagged) == "table" then
            for _, slot in ipairs(tagged) do
                if slot.Value == player then
                    local prefix = string.sub(slot.Name, 1, 4)
                    if prefix == "Home" or prefix == "Away" then return prefix end
                end
            end
        end
        local courts = workspace:FindFirstChild("Courts")
        if not courts then return nil end
        for _, court in ipairs(courts:GetChildren()) do
            local cp = court:FindFirstChild("_CourtPlayers")
            if cp then
                for _, slot in ipairs(cp:GetChildren()) do
                    if slot:IsA("ObjectValue") and slot.Value == player then
                        local prefix = string.match(slot.Name, "^%a+")
                        if prefix == "Home" or prefix == "Away" then return prefix end
                        return nil
                    end
                end
            end
        end
        return nil
    end

    local function isOpponent(player)
        if not player or player == LocalPlayer then return false end
        local mine, theirs = courtSide(LocalPlayer), courtSide(player)
        if mine and theirs then return mine ~= theirs end
        if AR.TeamSafety and (mine or theirs) then return false end
        if LocalPlayer.Team and player.Team then return LocalPlayer.Team ~= player.Team end
        return true
    end

    local function getNoStealRemote()
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        return rem and rem:FindFirstChild("noStealEvent")
    end

    local function canonicalBall(container)
        if not container then return nil end
        local b = container:FindFirstChild("Ball", true)
        if b and b:IsA("BasePart") then return b end
        if container:IsA("Model") and container.PrimaryPart then return container.PrimaryPart end
        for _, o in ipairs(container:GetDescendants()) do
            if o:IsA("BasePart") then
                local n = string.lower(o.Name)
                if n == "handle" or n == "basketball" or string.find(n, "ball", 1, true) then
                    return o
                end
            end
        end
        return nil
    end

    local function isLoose(ball)
        if not (ball and ball.Parent and ball:IsA("BasePart") and ball:IsDescendantOf(workspace)) then return false end
        if ball.Anchored then return false end
        for _, p in ipairs(Players:GetPlayers()) do
            local c = p.Character
            if c and ball:IsDescendantOf(c) then return false end
        end
        return true
    end

    local function stepNoSteal(root, profile)
        if AR.NoStealKeeper ~= true then return "KEEPER OFF" end
        if LocalPlayer:GetAttribute("NoSteal") == true then
            state.NoStealCached = "PROTECTED"; return "PROTECTED"
        end
        local now = os.clock()
        if now - state.NoStealCheckedAt < 0.05 then return state.NoStealCached end
        state.NoStealCheckedAt = now
        local range = math.clamp(tonumber(AR.NoStealRange) or 15, 0.01, 15)
        local threat
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                if r and isOpponent(p) and (r.Position - root.Position).Magnitude <= range then
                    threat = p; break
                end
            end
        end
        if not threat then state.NoStealCached = "NO PRESSURE"; return "NO PRESSURE" end
        if now - state.NoStealRequestedAt < profile.ri then return state.NoStealCached end
        local remote = getNoStealRemote()
        if not remote then state.NoStealCached = "LOCAL COUNTER"; return "LOCAL COUNTER" end
        state.NoStealRequestedAt = now
        local ok = pcall(function() remote:FireServer() end)
        state.NoStealCached = ok and "REQUESTED" or "REMOTE ERROR"
        return state.NoStealCached
    end

    local function burst(Ball, Character, profile)
        if not (Ball and Ball.Parent and Character) then return 0 end
        local parts = {
            Character:FindFirstChild("HumanoidRootPart"),
            Character:FindFirstChild("Torso"),
            Character:FindFirstChild("UpperTorso"),
            Character:FindFirstChild("Left Arm"),  Character:FindFirstChild("Right Arm"),
            Character:FindFirstChild("Left Leg"),  Character:FindFirstChild("Right Leg"),
        }
        local n = 0
        for _, part in ipairs(parts) do
            if part and part:IsA("BasePart") and type(firetouchinterest) == "function" then
                local ok = pcall(function()
                    firetouchinterest(part, Ball, 0)
                    firetouchinterest(part, Ball, 1)
                end)
                if ok then n += 1 end
            end
        end
        if profile.reject then
            local root = Character:FindFirstChild("HumanoidRootPart")
            if root then
                local offset = root.Position - Ball.Position
                if offset.Magnitude > 0.05 then
                    pcall(function()
                        Ball.AssemblyLinearVelocity = offset.Unit * math.min(120, 35 + offset.Magnitude * 10)
                        Ball.AssemblyAngularVelocity *= 0.15
                    end)
                    state.RejectedMags += 1
                end
            end
        end
        return n
    end

    local function findTarget(root, radius)
        local bestBall, bestHolder, bestD = nil, nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and isOpponent(p) then
                local c = p.Character
                local cont = c and c:FindFirstChild("Basketball")
                local ball = cont and canonicalBall(cont)
                if ball and ball:IsA("BasePart") then
                    local d = (ball.Position - root.Position).Magnitude
                    if d <= radius and d < bestD then bestBall, bestHolder, bestD = ball, p, d end
                end
            end
        end
        if bestBall then return bestBall, bestHolder, bestD end
        local last = state.LastHeld
        if last and last.Parent and isLoose(last) then
            local d = (last.Position - root.Position).Magnitude
            if d <= radius then return last, nil, d end
        end
        return nil, nil, math.huge
    end

    local function watchLoss(char)
        if state.WatchChar == char then return end
        if state.WatchConn then pcall(function() state.WatchConn:Disconnect() end) end
        state.WatchChar = char
        if not char then return end
        state.WatchConn = char.ChildRemoved:Connect(function(child)
            if child and child.Name == "Basketball" and AR.Enabled then
                state.LastHeld = canonicalBall(child)
                state.LostAt = os.clock()
                local profile = getProfile()
                state.CounterUntil = os.clock() + profile.dur
                state.CounterHardUntil = os.clock() + math.min(12, profile.dur + 4)
                state.CounterAttempts = 0
                state.Counters += 1
                state.Status = "LOSS DETECTED"
            end
        end)
    end

    local function step()
        if not AR.Enabled then state.Status = "OFF"; return end
        local char = LocalPlayer.Character
        if not char then state.Status = "NO CHARACTER"; return end
        watchLoss(char)
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local profile = getProfile()
        local now = os.clock()
        local cont = char:FindFirstChild("Basketball")
        if cont then
            local held = canonicalBall(cont)
            if held then state.LastHeld = held end
            if (state.CounterAttempts or 0) > 0 then state.Recoveries += 1 end
            state.CounterAttempts = 0
            state.CounterUntil = 0
            state.Status = "HOLDING / " .. stepNoSteal(root, profile)
            return
        end
        if now > (state.CounterUntil or 0) then
            state.Status = "WAITING FOR BALL"
            return
        end
        local interval = math.max(0.004, 1 / math.max(5, profile.rate))
        if now - (state.LastBurst or 0) < interval then return end
        state.LastBurst = now
        local ball, holder, dist = findTarget(root, profile.rad)
        if not ball then state.Status = "SCANNING / NO TARGET"; return end
        if holder and not isOpponent(holder) then state.Status = "TEAMMATE SAFE"; return end
        state.LastThief = holder
        local touches = burst(ball, char, profile)
        state.CounterAttempts += (touches > 0 and touches or 1)
        if profile.persistent and holder and now < (state.CounterHardUntil or 0) then
            state.CounterUntil = math.min(state.CounterHardUntil, math.max(state.CounterUntil, now + 0.35))
        end
        state.Status = string.format("%s / %.0fHZ / %.1fSTUDS / %.0fMS",
            string.upper(profile.mode), profile.rate, dist or 0, profile.ping)
    end

    AR._Step = step
    J:Connect(RunService.Heartbeat, function() pcall(step) end, "AntiReach")
end

do
    local MX = s.AutoMix
    local st = { BodyStatus="IDLE", RearClearance=math.huge, ThreatSector="NONE", LastThreat=nil }
    MX._State = st

    local function findDefender(root)
        local best, bestD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local enemy = true
                    if LocalPlayer.Team and p.Team then enemy = LocalPlayer.Team ~= p.Team end
                    if enemy then
                        local d = (r.Position - root.Position).Magnitude
                        if d < bestD then best, bestD = p, d end
                    end
                end
            end
        end
        return best, bestD
    end

    local function rearClearance(root, defenderRoot)
        if not defenderRoot then return math.huge end
        local localPt = root.CFrame:PointToObjectSpace(defenderRoot.Position)
        if localPt.Z <= 0.25 then return math.huge end
        return Vector2.new(localPt.X, localPt.Z).Magnitude
    end

    local function classify(root, defenderRoot)
        if not defenderRoot then return "NONE" end
        local rel = root.CFrame:PointToObjectSpace(defenderRoot.Position)
        local flat = Vector3.new(rel.X, 0, rel.Z)
        if flat.Magnitude < 0.05 then return "OVERLAP" end
        local front = -flat.Z / flat.Magnitude
        local side  = flat.X / flat.Magnitude
        if front <= -0.55 then return "REAR" end
        if front >= 0.55 then
            if math.abs(side) < 0.25 then return "FRONT" end
            return side > 0 and "FRONT RIGHT" or "FRONT LEFT"
        end
        return side > 0 and "RIGHT" or "LEFT"
    end

    local function chooseOpenDirection(root, targetRoot)
        local away = Vector3.new(root.Position.X - targetRoot.Position.X, 0, root.Position.Z - targetRoot.Position.Z)
        if away.Magnitude > 0.05 then away = away.Unit else away = -root.CFrame.LookVector end
        local left  = Vector3.new(-away.Z, 0, away.X)
        local right = -left
        local candidates = { away, (away*0.65 + left*0.76).Unit, (away*0.65 + right*0.76).Unit, left, right }
        local best, bestScore = away, -math.huge
        for _, dir in ipairs(candidates) do
            local probe = root.Position + dir * 5.5
            local minimum = 40
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    local c = p.Character
                    local r = c and c:FindFirstChild("HumanoidRootPart")
                    if r then
                        local predicted = r.Position + r.AssemblyLinearVelocity * 0.18
                        minimum = math.min(minimum, (Vector3.new(probe.X,0,probe.Z) - Vector3.new(predicted.X,0,predicted.Z)).Magnitude)
                    end
                end
            end
            local score = minimum + dir:Dot(away) * 2.4
            if score > bestScore then best, bestScore = dir, score end
        end
        return best.Magnitude > 0.05 and best.Unit or away
    end

    local function crabDirection(root, threat)
        if not root or not threat then return nil, "NO DEFENDER" end
        local offset = root.Position - threat.Position
        local away = Vector3.new(offset.X, 0, offset.Z)
        if away.Magnitude <= 0.05 then return nil, "OVERLAP" end
        away = away.Unit
        local distance = offset.Magnitude
        local preferred = math.clamp(tonumber(MX.PreferredDistance) or 7.5, 5, 12)
        local openDir = chooseOpenDirection(root, threat)
        if distance < preferred - 1.0 then
            local escape = away * 0.78 + openDir * 0.22
            return escape.Magnitude > 0.05 and escape.Unit or away, "CREATING GAP"
        end
        if distance > preferred + 1.75 then return nil, "GAP SET" end
        local goal = select(1, findNearestGoal())
        local progress = Vector3.zero
        if goal then
            progress = Vector3.new(goal.Position.X - root.Position.X, 0, goal.Position.Z - root.Position.Z)
        end
        if progress.Magnitude <= 0.05 then progress = openDir end
        progress = progress.Unit
        local toward = -away
        if progress:Dot(toward) > 0.45 then progress = openDir end
        local strength = math.clamp(tonumber(MX.CrabStrength) or 0.70, 0, 1)
        local openWeight = 0.32 + strength * 0.23
        local crab = progress * (1 - openWeight) + openDir * openWeight
        if crab.Magnitude <= 0.05 then crab = away end
        return crab.Unit, "BODYING"
    end

    local function step(dt)
        if not MX.Enabled then st.BodyStatus = "OFF"; return end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then st.BodyStatus = "WAITING"; return end
        if not char:FindFirstChild("Basketball") then st.BodyStatus = "NO BALL"; return end
        if MX.ManualHandles then st.BodyStatus = "MANUAL MODE"; return end
        local defender, dist = findDefender(root)
        if not defender then st.BodyStatus = "SEARCHING"; return end
        local defRoot = defender.Character and defender.Character:FindFirstChild("HumanoidRootPart")
        if not defRoot then st.BodyStatus = "SEARCHING"; return end
        st.LastThreat = defRoot
        st.ThreatSector = classify(root, defRoot)
        st.RearClearance = rearClearance(root, defRoot)
        if MX.BodyFirst then
            local crab, label = crabDirection(root, defRoot)
            if crab then
                hum:Move(crab, false)
                st.BodyStatus = label or "BODYING"
            else
                st.BodyStatus = "HOLDING"
            end
        end
    end

    MX._Step = step
    J:Connect(RunService.RenderStepped, function(dt) pcall(step, dt) end, "AutoMixBody")
end
do
    local function sanitizeAlias(v)
        v = tostring(v or ""):gsub("[%c\r\n]", "")
        v = v:match("^%s*(.-)%s*$") or ""
        if #v > 20 then v = string.sub(v, 1, 20) end
        return v ~= "" and v or "Aural V2"
    end
    local OriginalDisguise = LocalPlayer:GetAttribute("DisguiseName")

    local function refreshNameTag()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local tag = root and root:FindFirstChild("NameTag")
        if not tag then return end
        local alias = sanitizeAlias(s.LocalAnonymizer.Alias)
        for _, obj in ipairs(tag:GetDescendants()) do
            if obj:IsA("TextLabel") then
                if obj.Name == "UsernameLabel" then
                    obj.Text = s.LocalAnonymizer.Enabled and ("@" .. alias) or ("@" .. LocalPlayer.Name)
                elseif obj.Name == "DisplayNameLabel" or obj.Name == "NameLabel" then
                    obj.Text = s.LocalAnonymizer.Enabled and alias or LocalPlayer.Name
                end
            end
        end
    end

    J:Connect(RunService.Heartbeat, function()
        if not s.LocalAnonymizer.Enabled then return end
        local alias = sanitizeAlias(s.LocalAnonymizer.Alias)
        if LocalPlayer:GetAttribute("DisguiseName") ~= alias then
            pcall(function() LocalPlayer:SetAttribute("DisguiseName", alias) end)
        end
        refreshNameTag()
    end, "LocalAnonymizer")

    s.LocalAnonymizer._Set = function(enabled, alias)
        s.LocalAnonymizer.Enabled = enabled == true
        s.LocalAnonymizer.Alias = sanitizeAlias(alias or s.LocalAnonymizer.Alias)
        pcall(function()
            LocalPlayer:SetAttribute("DisguiseName",
                s.LocalAnonymizer.Enabled and s.LocalAnonymizer.Alias or OriginalDisguise)
        end)
        refreshNameTag()
    end
end

do
    local CT = s.ClanTag
    local CHT = s.ChatTag
    local OriginalTag = LocalPlayer:GetAttribute("ClanTag")
    local OriginalColor = LocalPlayer:GetAttribute("ClanColor")
    local OriginalChat = LocalPlayer:GetAttribute("ChatTag")

    local function hexToColor(h, fallback)
        h = tostring(h or ""):gsub("#", "")
        if #h == 3 then h = h:sub(1,1):rep(2)..h:sub(2,2):rep(2)..h:sub(3,3):rep(2) end
        if not string.match(h, "^%x%x%x%x%x%x$") then return fallback or Color3.new(1,1,1) end
        return Color3.fromRGB(tonumber(h:sub(1,2),16), tonumber(h:sub(3,4),16), tonumber(h:sub(5,6),16))
    end

    local function apply()
        if CT.Enabled then
            pcall(function() LocalPlayer:SetAttribute("ClanTag", CT.Tag) end)
            pcall(function() LocalPlayer:SetAttribute("ClanColor", hexToColor(CT.Color)) end)
            if CHT.Enabled then
                pcall(function() LocalPlayer:SetAttribute("ChatTag", "Clan") end)
            end
        else
            pcall(function() LocalPlayer:SetAttribute("ClanTag", OriginalTag) end)
            pcall(function() LocalPlayer:SetAttribute("ClanColor", OriginalColor) end)
            if not CHT.Enabled then
                pcall(function() LocalPlayer:SetAttribute("ChatTag", OriginalChat) end)
            end
        end
    end

    CT._Apply = apply
    J:Connect(RunService.Heartbeat, function()
        if CT.Enabled and LocalPlayer:GetAttribute("ClanTag") ~= CT.Tag then apply() end
    end, "ClanTagWatch")
    if CT.Enabled then apply() end
end

do
    local Badges = s.LogoBadges
    local Originals = {}
    for _, bn in ipairs({"VIP","Youtuber","Twitch","Booster","Tester","Staff"}) do
        Originals[bn] = LocalPlayer:GetAttribute(bn)
    end

    local function apply()
        for _, bn in ipairs({"VIP","Youtuber","Twitch","Booster","Tester","Staff"}) do
            local want = Badges[bn] or Originals[bn] or false
            if LocalPlayer:GetAttribute(bn) ~= want then
                pcall(function() LocalPlayer:SetAttribute(bn, want) end)
            end
        end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local creatorTag = root and root:FindFirstChild("CreatorTag")
        if creatorTag then
            for _, bn in ipairs({"VIP","Youtuber","Twitch","Booster","Tester","Staff"}) do
                local el = creatorTag:FindFirstChild(bn)
                if el then el.Visible = Badges[bn] == true end
            end
            if #Badges.CustomIds > 0 then
                local prefix = "AURAL_Custom_"
                for _, child in ipairs(creatorTag:GetChildren()) do
                    if string.find(child.Name, prefix, 1, true) then child:Destroy() end
                end
                local template = creatorTag:FindFirstChild("VIP")
                if template then
                    for i, id in ipairs(Badges.CustomIds) do
                        local ok, clone = pcall(function() return template:Clone() end)
                        if ok and clone then
                            clone.Name = prefix .. tostring(id)
                            clone.LayoutOrder = 50 + i
                            clone.Visible = true
                            clone.Image = "rbxthumb://type=Asset&id=" .. tostring(id) .. "&w=420&h=420"
                            clone.ImageColor3 = Color3.new(1,1,1)
                            clone.ImageTransparency = 0
                            clone.Parent = creatorTag
                        end
                    end
                end
            end
        end
    end

    Badges._Apply = apply
    J:Connect(RunService.RenderStepped, function()
        local any = false
        for k, v in pairs(Badges) do
            if k ~= "CustomIds" and v == true then any = true; break end
        end
        if not any and #Badges.CustomIds == 0 then return end
        apply()
    end, "LogoBadges")
end

do
    local W = s.WalletSpoof
    local walletLabels = {}
    local walletConnections = {}
    local lastValues = {}

    local function compact(n)
        local t = tostring(math.max(0, math.floor(tonumber(n) or 0)))
        while true do
            local n2, c = t:gsub("^(%-?%d+)(%d%d%d)", "%1,%2")
            t = n2
            if c == 0 then break end
        end
        return t
    end

    local map = {
        money = "Money",
        cash = "Money",
        spin = "Spins",
        spins = "Spins",
        crate = "Crates",
        crates = "Crates",
        boost = "Boosts",
        boosts = "Boosts",
        clancoins = "ClanCoins",
        eventcurrency = "EventCurrency",
        battlepass = "BattlepassLevel",
        battlepasslevel = "BattlepassLevel",
    }

    local function disconnectWalletConnections()
        for _, connection in ipairs(walletConnections) do
            connection:Disconnect()
        end

        table.clear(walletConnections)
    end

    local function findWalletLabels()
        table.clear(walletLabels)
        disconnectWalletConnections()

        local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if not pg then return end

        for _, obj in ipairs(pg:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local n = string.lower(obj.Name):gsub("[^%w]", "")
                local parent = obj.Parent
                local pn = parent and string.lower(parent.Name):gsub("[^%w]", "") or ""

                local key = map[n] or map[pn]

                if key then
                    walletLabels[obj] = key
                end

                if (n == "timerlabel" or n == "time") and string.find(pn, "dailyspin", 1, true) then
                    walletLabels[obj] = "DailyRewardState"
                end
            end
        end

        table.insert(walletConnections, pg.DescendantAdded:Connect(function(obj)
            if not obj:IsA("TextLabel") then return end

            local n = string.lower(obj.Name):gsub("[^%w]", "")
            local parent = obj.Parent
            local pn = parent and string.lower(parent.Name):gsub("[^%w]", "") or ""

            local key = map[n] or map[pn]

            if key then
                walletLabels[obj] = key
            elseif (n == "timerlabel" or n == "time") and string.find(pn, "dailyspin", 1, true) then
                walletLabels[obj] = "DailyRewardState"
            end
        end))

        table.insert(walletConnections, pg.DescendantRemoving:Connect(function(obj)
            walletLabels[obj] = nil
        end))
    end

    local function apply()
        if not W.Enabled then return end

        if next(walletLabels) == nil then
            findWalletLabels()
        end

        for obj, key in pairs(walletLabels) do
            if obj and obj.Parent then
                local value = W[key]

                if value ~= nil then
                    local text

                    if key == "DailyRewardState" then
                        text = tostring(value)
                    else
                        text = compact(value)
                    end

                    if obj.Text ~= text then
                        obj.Text = text
                    end
                end
            else
                walletLabels[obj] = nil
            end
        end
    end

    function W._Apply()
        if W.Enabled then
            findWalletLabels()
            apply()
        else
            table.clear(walletLabels)
            disconnectWalletConnections()
        end
    end

    J:Connect(RunService.RenderStepped, function()
        if W.Enabled then
            apply()
        end
    end, "WalletSpoof")
end

do
    local trailRuntime = {
        Balls = setmetatable({}, { __mode = "k" }),
        LastUpdate = 0,
        FlightUntil = 0,
        Holding = false,
        LastBall = nil,
    }

    function getTemplateTrail()
        local trailName = s.TrailChanger.CurrentTrail
        if not trailName or trailName == "None" then return nil end
        local trailModel = Trails[trailName]
        if not trailModel then return nil end
        if trailModel:IsA("BasePart") then
            local trail = trailModel:FindFirstChildOfClass("Trail")
            if trail then return trail end
        end
        local trail = trailModel:FindFirstChildOfClass("Trail")
        if trail then return trail end
        for _, descendant in trailModel:GetDescendants() do
            if descendant:IsA("Trail") then return descendant end
        end
        return nil
    end

    local function getLocalBasketball()
        local character = LocalPlayer.Character
        local basketball = character and character:FindFirstChild("Basketball")
        if not basketball then return nil end
        local ballPart = basketball:FindFirstChild("Ball", true)
        if ballPart and ballPart:IsA("BasePart") then
            trailRuntime.LastBall = ballPart
            return ballPart
        end
        return nil
    end

    function cleanBallTrails(ballPart)
        if not ballPart then return end
        for _, child in ballPart:GetChildren() do
            if child.Name == "AuralAttach0" or child.Name == "AuralAttach1"
                or (child:IsA("Trail") and child.Name == "AuralTrail") then
                child:Destroy()
            end
        end
        trailRuntime.Balls[ballPart] = nil
    end

    function applyTrailToBall(ballPart)
        local localBall = getLocalBasketball()
        if not (ballPart and ballPart:IsA("BasePart")
            and (ballPart == localBall or ballPart == trailRuntime.LastBall
                or trailRuntime.Balls[ballPart] == true)
            and s.TrailChanger.Enabled) then return end

        local templateTrail = getTemplateTrail()
        if not templateTrail then
            cleanBallTrails(ballPart)
            return
        end

        cleanBallTrails(ballPart)

        local radius = math.max(ballPart.Size.X, ballPart.Size.Y, ballPart.Size.Z) * 0.5
        local attach0 = Instance.new("Attachment")
        attach0.Name = "AuralAttach0"
        attach0.Position = Vector3.new(0, radius * 0.8, 0)
        attach0.Parent = ballPart

        local attach1 = Instance.new("Attachment")
        attach1.Name = "AuralAttach1"
        attach1.Position = Vector3.new(0, -radius * 0.8, 0)
        attach1.Parent = ballPart

        local newTrail = templateTrail:Clone()
        newTrail.Name = "AuralTrail"
        newTrail.Attachment0 = attach0
        newTrail.Attachment1 = attach1
        newTrail.Enabled = false
        newTrail.FaceCamera = true
        newTrail.TextureMode = Enum.TextureMode.Stretch
        newTrail.Parent = ballPart

        trailRuntime.Balls[ballPart] = true
        trailRuntime.LastBall = ballPart
    end

    function applyTrailToAllBalls()
        if not s.TrailChanger.Enabled then return end
        if not getTemplateTrail() then
            resetTrailOnAllBalls()
            return
        end
        local ballPart = getLocalBasketball() or trailRuntime.LastBall
        if ballPart and ballPart.Parent then
            applyTrailToBall(ballPart)
        end
    end

    function resetTrailOnBall(ballPart)
        if not ballPart then return end
        cleanBallTrails(ballPart)
    end

    function resetTrailOnAllBalls()
        for ballPart in pairs(trailRuntime.Balls) do
            if ballPart and ballPart.Parent then
                cleanBallTrails(ballPart)
            end
        end
        local localBall = getLocalBasketball() or trailRuntime.LastBall
        if localBall and localBall.Parent then
            cleanBallTrails(localBall)
        end
        table.clear(trailRuntime.Balls)
        trailRuntime.FlightUntil = 0
        trailRuntime.Holding = false
        trailRuntime.LastBall = nil
    end

    local function bindLocalTrailCharacter(character)
        local function tryApply()
            if not s.TrailChanger.Enabled then return end
            local ballPart = getLocalBasketball()
            if ballPart then applyTrailToBall(ballPart) end
        end

        character.ChildAdded:Connect(function(child)
            if child.Name == "Basketball" then
                task.defer(function()
                    child:WaitForChild("Ball", 2)
                    tryApply()
                end)
            end
        end)

        local basketball = character:FindFirstChild("Basketball")
        if basketball then
            task.defer(function()
                basketball:WaitForChild("Ball", 2)
                tryApply()
            end)
        end
    end

    if LocalPlayer.Character then
        bindLocalTrailCharacter(LocalPlayer.Character)
    end
    J:Connect(LocalPlayer.CharacterAdded, bindLocalTrailCharacter, "AuralLocalTrailCharacter")

    local function updateLocalTrail()
        local character = LocalPlayer.Character
        local basketball = character and character:FindFirstChild("Basketball")
        local holding = basketball ~= nil
        local ballPart = getLocalBasketball()
        local now = os.clock()

        if ballPart and s.TrailChanger.Enabled then
            if not trailRuntime.Balls[ballPart] then
                applyTrailToBall(ballPart)
            end
        end

        if trailRuntime.Holding and not holding then
            trailRuntime.FlightUntil = now + 4
        elseif holding then
            trailRuntime.FlightUntil = 0
        end
        trailRuntime.Holding = holding

        local activeBall = ballPart or trailRuntime.LastBall
        if activeBall and activeBall.Parent then
            local trail = activeBall:FindFirstChild("AuralTrail")
            if trail and trail:IsA("Trail") then
                local speed = activeBall.AssemblyLinearVelocity.Magnitude
                local shouldShow = s.TrailChanger.Enabled
                    and not holding
                    and now < trailRuntime.FlightUntil
                    and speed >= 8
                if trail.Enabled ~= shouldShow then
                    trail.Enabled = shouldShow
                end
            end
        elseif trailRuntime.LastBall then
            trailRuntime.LastBall = nil
        end

        if now >= trailRuntime.FlightUntil and not holding then
            local oldBall = trailRuntime.LastBall
            if oldBall and oldBall.Parent then
                local trail = oldBall:FindFirstChild("AuralTrail")
                if trail and trail:IsA("Trail") then
                    trail.Enabled = false
                end
            end
        end
    end

    J:Connect(RunService.Heartbeat, function()
        if not s.TrailChanger.Enabled then return end
        local now = os.clock()
        if now - trailRuntime.LastUpdate < 1 / 30 then return end
        trailRuntime.LastUpdate = now
        updateLocalTrail()
    end, "AuralBallTrailFlight")
end

    autoDunkTask = nil

    function enableautodunk()
        if autoDunkTask then return end

        autoDunkTask = task.spawn(function()
            local wasInRange = false

            while s.Automatics.AutoDunk do
                local dunkFunction = getclosestdunkfunc()
                local inRange = dunkFunction ~= nil

                if inRange and not wasInRange then
                    pcall(function()
                        dunkFunction:InvokeServer()
                    end)
                end

                wasInRange = inRange
                task.wait()
            end

            autoDunkTask = nil
        end)
    end

    function disableautodunk()
        s.Automatics.AutoDunk = false
        if autoDunkTask then
            task.cancel(autoDunkTask)
            autoDunkTask = nil
        end
    end

    function applyGoalEffect()
        pcall(function()
            local PlayerData = require(ReplicatedStorage.Util.PlayerData)
            PlayerData.storedData["Equipping"]["Effect"] = Effects[s.Goal.CurrentEffect].Name
            PlayerData.storedData["Inventory"][Effects[s.Goal.CurrentEffect].Name] = 1
        end)
        if goalEventHook then return end
        pcall(function()
            local connections = getconnections(ReplicatedStorage.Remotes.goalEvent.OnClientEvent)
            if connections and connections[1] then
                local old
                old = hookfunction(connections[1].Function, function(Player, Court, Goal, XYZ, GoalEffect, Unknown)
                    if Player == Client and s.Goal.Enabled then GoalEffect = Effects[s.Goal.CurrentEffect].Value end
                    return old(Player, Court, Goal, XYZ, GoalEffect, Unknown)
                end)
                goalEventHook = old
            end
        end)
    end

    function resetGoalEffect()
        pcall(function()
            local PlayerData = require(ReplicatedStorage.Util.PlayerData)
            PlayerData.storedData["Equipping"]["Effect"] = Effects["LightRay"].Name
            PlayerData.storedData["Inventory"][Effects["LightRay"].Name] = 1
        end)
    end

local oobOriginals = {}

do
    function setoob(value)
        local found = {}
        for _, object in workspace:GetDescendants() do
            if object:IsA("Folder") and object.Name == "OOB" then
                for _, part in object:GetDescendants() do
                    if part:IsA("BasePart") then
                        found[part] = true
                        if not oobOriginals[part] then
                            oobOriginals[part] = {cancollide = part.CanCollide, cantouch = part.CanTouch}
                        end
                        if value then
                            if part.Parent and part.Parent.Name == "Walls" then part.CanCollide = false
                            elseif part.Parent and part.Parent.Name == "Floor" then part.CanTouch = false end
                        end
                    end
                end
            end
        end
        for part, original in next, oobOriginals do
            if not found[part] then
                if part and part.Parent then
                    part.CanCollide = original.cancollide
                    part.CanTouch = original.cantouch
                end
                oobOriginals[part] = nil
            elseif not value and part.Parent then
                part.CanCollide = original.cancollide
                part.CanTouch = original.cantouch
            end
        end
    end

    workspace.DescendantAdded:Connect(function(object)
        if not getgenv().Settings.Misc.AntiOOB then return end
        if object:IsA("BasePart") then
            local parent = object.Parent
            local oob = parent and parent.Parent
            if oob and oob:IsA("Folder") and oob.Name == "OOB" then
                oobOriginals[object] = {cancollide = object.CanCollide, cantouch = object.CanTouch}
                if parent.Name == "Walls" then object.CanCollide = false
                elseif parent.Name == "Floor" then object.CanTouch = false end
            end
        end
    end)

    -- helpers: copy visuals from the ShopItem Part -> local Ball Part
    local _origBallProps = nil

    local function getBallPart()
        local char = LocalPlayer.Character
        local folder = char and char:FindFirstChild("Basketball")
        return folder and folder:FindFirstChild("Ball")
    end

    local function getShopBallPart(ballItemName)
        local ok, item = pcall(function()
            return game:GetService("ReplicatedStorage").ShopItems.Ball:FindFirstChild(ballItemName)
        end)
        if not ok or not item then return nil end
        if item:IsA("BasePart") then return item end
        return item:FindFirstChildWhichIsA("BasePart")
    end

    local function saveBallProps(ball)
        if not ball then return end
        _origBallProps = {
            BrickColor   = ball.BrickColor,
            Color        = ball.Color,
            Material     = ball.Material,
            Transparency = ball.Transparency,
            Reflectance  = ball.Reflectance,
        }
        local m = ball:FindFirstChildOfClass("SpecialMesh")
        if m then
            _origBallProps.MeshId    = m.MeshId
            _origBallProps.TextureId = m.TextureId
            _origBallProps.Scale     = m.Scale
        end
    end

    local function applyBallChangerToPart(ball, ballItemName)
        if not ball or not ball:IsA("BasePart") then return end
        local src = getShopBallPart(ballItemName)
        if not src then return end
        if not _origBallProps then saveBallProps(ball) end
        ball.BrickColor   = src.BrickColor
        ball.Color        = src.Color
        ball.Material     = src.Material
        ball.Transparency = src.Transparency
        ball.Reflectance  = src.Reflectance
        local srcMesh = src:FindFirstChildOfClass("SpecialMesh")
        local dstMesh = ball:FindFirstChildOfClass("SpecialMesh")
        if srcMesh and dstMesh then
            dstMesh.MeshId    = srcMesh.MeshId
            dstMesh.TextureId = srcMesh.TextureId
            dstMesh.Scale     = srcMesh.Scale
        end
    end

    local lastHadBall = 0
RunService.Heartbeat:Connect(function()
    local c = LocalPlayer.Character
    if c and c:FindFirstChild("Basketball") then lastHadBall = os.clock() end
end)

local function isMine(parent)
    local char = LocalPlayer.Character
    if typeof(parent) ~= "Instance" or not char then return false end
    if parent == char or parent:IsDescendantOf(char) then return true end
    -- thrown ball: spawned in workspace right after you released it
    if parent == workspace and os.clock() - lastHadBall < 0.5 then return true end
    return false
end

function applyBallChanger()
    if Replicator and OriginalReplicateBall then
        Replicator["ReplicateBall"] = function(Parent, Name, ...)
            if s.BallChanger.Enabled and isMine(Parent) then
                Name = Balls[s.BallChanger.CurrentBall] or Name
            end
            return OriginalReplicateBall(Parent, Name, ...)
        end
    end
    local ball = getBallPart()
    if ball then
        pcall(applyBallChangerToPart, ball, Balls[s.BallChanger.CurrentBall])
    end
end

    function resetBallChanger()
        if Replicator and OriginalReplicateBall then
            Replicator["ReplicateBall"] = OriginalReplicateBall
        end
        -- restore original properties on the Part
        local ball = getBallPart()
        if ball and _origBallProps then
            pcall(function()
                ball.BrickColor   = _origBallProps.BrickColor
                ball.Color        = _origBallProps.Color
                ball.Material     = _origBallProps.Material
                ball.Transparency = _origBallProps.Transparency
                ball.Reflectance  = _origBallProps.Reflectance
                local m = ball:FindFirstChildOfClass("SpecialMesh")
                if m and _origBallProps.MeshId then
                    m.MeshId    = _origBallProps.MeshId
                    m.TextureId = _origBallProps.TextureId
                    m.Scale     = _origBallProps.Scale
                end
            end)
        end
        _origBallProps = nil
    end

    -- re-apply whenever the player picks up a new ball
    LocalPlayer.CharacterAdded:Connect(function(char)
        char:WaitForChild("Basketball", 10)
        if s.BallChanger.Enabled then
            task.wait(0.5)
            pcall(applyBallChanger)
        end
    end)
end
do
    local BODY_PARTS = { "Head", "HumanoidRootPart", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
    local auraRuntime = { Character = nil, Aura = nil, CheckAt = 0 }

    local function ClearManualBodyAura(character)
        if not character then return end
        for _, object in ipairs(character:GetDescendants()) do
            if object:GetAttribute("AuralLocalAura") then object:Destroy() end
        end
    end

    local function StripBodyAura(character)
        if not character then return end
        for _, object in ipairs(character:GetDescendants()) do
            if object:GetAttribute("Takeover") ~= nil or object:GetAttribute("AuralLocalAura") ~= nil then
                if object:IsA("ParticleEmitter") or object:IsA("Trail") or object:IsA("Beam")
                    or object:IsA("PointLight") or object:IsA("SpotLight") or object:IsA("SurfaceLight") then
                    pcall(function() object.Enabled = false end)
                end
            end
        end
    end

    local function HasLocalTakeover(character)
        if not character then return false end
        for _, object in ipairs(character:GetDescendants()) do
            if object:GetAttribute("Takeover") or object:GetAttribute("AuralLocalAura") then return true end
        end
        return false
    end

    local function ForceBodyAuraVisible(character)
        if not character then return end
        for _, object in ipairs(character:GetDescendants()) do
            if object:GetAttribute("Takeover") or object:GetAttribute("AuralLocalAura") then
                if object:IsA("ParticleEmitter") then
                    local savedSize = object:GetAttribute("Size")
                    if savedSize then pcall(function() object.Size = savedSize end) end
                    object.Enabled = true
                elseif object:IsA("Beam") or object:IsA("Trail") or object:IsA("PointLight") then
                    object.Enabled = true
                end
            end
        end
    end

    local function ApplyManualBodyAura(character, sourceRig)
        if not (character and sourceRig) then return end
        ClearManualBodyAura(character)
        for _, partName in ipairs(BODY_PARTS) do
            local targetPart = character:FindFirstChild(partName)
            local sourcePart = sourceRig:FindFirstChild(partName)
            if targetPart and sourcePart then
                for _, child in ipairs(sourcePart:GetChildren()) do
                    if child:GetAttribute("Takeover") then
                        local clone = child:Clone()
                        clone:SetAttribute("Takeover", nil)
                        clone:SetAttribute("AuralLocalAura", true)
                        for _, descendant in ipairs(clone:GetDescendants()) do
                            descendant:SetAttribute("Takeover", nil)
                            descendant:SetAttribute("AuralLocalAura", true)
                        end
                        clone.Parent = targetPart
                    end
                end
            end
        end
        for _, partName in ipairs(BODY_PARTS) do
            local targetPart = character:FindFirstChild(partName)
            if targetPart then
                for _, object in ipairs(targetPart:GetDescendants()) do
                    if object:GetAttribute("AuralLocalAura") then
                        if object:IsA("ParticleEmitter") then
                            local savedSize = object:GetAttribute("Size")
                            if savedSize then pcall(function() object.Size = savedSize end) end
                            object.Enabled = true
                        elseif object:IsA("Beam") or object:IsA("Trail") then
                            local a0 = object:GetAttribute("Attachment0")
                            local a1 = object:GetAttribute("Attachment1")
                            if a0 then object.Attachment0 = targetPart:FindFirstChild(a0, true) end
                            if a1 then object.Attachment1 = targetPart:FindFirstChild(a1, true) end
                            object.Enabled = true
                        elseif object:IsA("PointLight") then
                            object.Enabled = true
                        end
                    end
                end
            end
        end
    end

    function ApplyAura(auraModel)
        local char = LocalPlayer.Character
        if not (char and auraModel) then return false end
        local rig = auraModel:FindFirstChild("Rig") or auraModel
        if not rig:IsA("Model") then return false end
        ApplyManualBodyAura(char, rig)
        ForceBodyAuraVisible(char)
        auraRuntime.Character, auraRuntime.Aura, auraRuntime.CheckAt = char, auraModel.Name, os.clock()
        return true
    end

    function RemoveAura()
        local char = LocalPlayer.Character
        if char then
            ClearManualBodyAura(char)
            StripBodyAura(char)
        end
        auraRuntime.Character, auraRuntime.Aura = nil, nil
        return true
    end

    local acc = 0
    J:Connect(RunService.Heartbeat, function(dt)
        acc += dt
        if acc < 0.5 then return end
        acc = 0
        if not (s.Aura.Enabled and s.Aura.SelectedAura and s.Aura.SelectedAura ~= "None") then return end
        local char = LocalPlayer.Character
        if not char then return end
        local now = os.clock()
        local changed = auraRuntime.Character ~= char or auraRuntime.Aura ~= s.Aura.SelectedAura
        if not changed and now - auraRuntime.CheckAt < 2 then return end
        local shop = ReplicatedStorage:FindFirstChild("ShopItems")
        local folder = shop and shop:FindFirstChild("Aura")
        local model = folder and folder:FindFirstChild(s.Aura.SelectedAura)
        if not model then return end
        if changed or not HasLocalTakeover(char) then
            pcall(ApplyAura, model)
        else
            auraRuntime.CheckAt = now
            ForceBodyAuraVisible(char)
        end
    end)
end

local avatarSpoofRuntime = {
    Character = nil,
    Originals = setmetatable({}, { __mode = "k" }),
}

local function restoreAvatarSpoofs()
    for object, original in pairs(avatarSpoofRuntime.Originals) do
        if object and object.Parent then
            pcall(function()
                if original.Transparency ~= nil then object.Transparency = original.Transparency end
                if original.LocalTransparencyModifier ~= nil then
                    object.LocalTransparencyModifier = original.LocalTransparencyModifier
                end
            end)
        end
        avatarSpoofRuntime.Originals[object] = nil
    end
end

local function hideAvatarObject(object)
    if not object then return end
    if object:IsA("BasePart") then
        if not avatarSpoofRuntime.Originals[object] then
            avatarSpoofRuntime.Originals[object] = {
                Transparency = object.Transparency,
                LocalTransparencyModifier = object.LocalTransparencyModifier,
            }
        end
        object.Transparency = 1
        object.LocalTransparencyModifier = 1
    elseif object:IsA("Decal") or object:IsA("Texture") then
        if not avatarSpoofRuntime.Originals[object] then
            avatarSpoofRuntime.Originals[object] = { Transparency = object.Transparency }
        end
        object.Transparency = 1
    end
end

local function applyLocalAvatarSpoofs()
    local character = LocalPlayer.Character
    if avatarSpoofRuntime.Character ~= character then
        restoreAvatarSpoofs()
        avatarSpoofRuntime.Character = character
    end
    if not character then return end

    restoreAvatarSpoofs()

    if s.Visuals.HeadlessSpoof then
        local head = character:FindFirstChild("Head")
        if head then
            hideAvatarObject(head)
            for _, object in head:GetDescendants() do
                if object:IsA("Decal") or object:IsA("Texture") then
                    hideAvatarObject(object)
                end
            end
        end
    end

    if s.Visuals.KorbloxSpoof then
        for _, name in { "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot" } do
            local part = character:FindFirstChild(name)
            if part and part:IsA("BasePart") then
                hideAvatarObject(part)
            end
        end
    end
end

J:Connect(LocalPlayer.CharacterAdded, function()
    task.wait(0.25)
    applyLocalAvatarSpoofs()
end, "LocalAvatarSpoofCharacter")
applyLocalAvatarSpoofs()

local hiddenTags = {}
local hideTagsConnection = nil
local ownNameplateConnection = nil
local originalNameTexts = {}
local originalRecordTexts = {}
local originalTitleTexts = {}
local textListeners = {}

local function formatStrokeText(orig, custom)
    if not custom or custom == "" then return orig end
    if orig and orig:match("^<stroke>") and orig:match("</stroke>$") then
        return "<stroke>" .. custom .. "</stroke>"
    end
    return custom
end

do
    function applyOwnNameplate()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        for _, tagName in ipairs({"NameTag", "CreatorTag", "TeamSpot"}) do
            local tag = hrp:FindFirstChild(tagName)
            if tag and tag:IsA("BillboardGui") then
                tag.Enabled = not s.Visuals.HideOwnNameplate
            end
        end

        local nameTag = hrp:FindFirstChild("NameTag")
        if nameTag and nameTag:IsA("BillboardGui") then
            local mainFrame = nameTag:FindFirstChild("MainFrame")
            local gameFrame = nameTag:FindFirstChild("GameFrame")
            local subFrame = mainFrame and mainFrame:FindFirstChild("Frame")

            local nameLabels = {}
            if mainFrame and mainFrame:FindFirstChild("NameLabel") then table.insert(nameLabels, mainFrame.NameLabel) end
            if gameFrame and gameFrame:FindFirstChild("NameLabel") then table.insert(nameLabels, gameFrame.NameLabel) end
            for _, obj in ipairs(nameTag:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Name == "NameLabel" and not table.find(nameLabels, obj) then
                    table.insert(nameLabels, obj)
                end
            end

            for _, obj in ipairs(nameLabels) do
                if not originalNameTexts[obj] then originalNameTexts[obj] = obj.Text end
                local target = (s.Visuals.CustomNameText ~= "") and s.Visuals.CustomNameText or originalNameTexts[obj]
                if obj.Text ~= target then obj.Text = target end
                if not textListeners[obj] then
                    textListeners[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                        if s.Visuals.CustomNameText ~= "" and obj.Text ~= s.Visuals.CustomNameText then
                            obj.Text = s.Visuals.CustomNameText
                        end
                    end)
                end
            end

            local recordLabels = {}
            if subFrame and subFrame:FindFirstChild("RecordLabel") then table.insert(recordLabels, subFrame.RecordLabel) end
            for _, obj in ipairs(nameTag:GetDescendants()) do
                if obj:IsA("TextLabel") and obj.Name == "RecordLabel" and not table.find(recordLabels, obj) then
                    table.insert(recordLabels, obj)
                end
            end

            for _, obj in ipairs(recordLabels) do
                if not originalRecordTexts[obj] then originalRecordTexts[obj] = obj.Text end
                local target = formatStrokeText(originalRecordTexts[obj], s.Visuals.CustomRecordText)
                if obj.Text ~= target then obj.Text = target end
                if not textListeners[obj] then
                    textListeners[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                        if s.Visuals.CustomRecordText ~= "" then
                            local expected = formatStrokeText(originalRecordTexts[obj], s.Visuals.CustomRecordText)
                            if obj.Text ~= expected then obj.Text = expected end
                        end
                    end)
                end
            end

            local titleLabels = {}
            if subFrame and subFrame:FindFirstChild("AchievementName") then table.insert(titleLabels, subFrame.AchievementName) end
            for _, obj in ipairs(nameTag:GetDescendants()) do
                if obj:IsA("TextLabel") and (obj.Name == "AchievementName" or obj.Name == "TitleLabel") and not table.find(titleLabels, obj) then
                    table.insert(titleLabels, obj)
                end
            end

            for _, obj in ipairs(titleLabels) do
                if not originalTitleTexts[obj] then originalTitleTexts[obj] = obj.Text end
                local target = formatStrokeText(originalTitleTexts[obj], s.Visuals.CustomTitleText)
                if obj.Text ~= target then obj.Text = target end
                if not textListeners[obj] then
                    textListeners[obj] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                        if s.Visuals.CustomTitleText ~= "" then
                            local expected = formatStrokeText(originalTitleTexts[obj], s.Visuals.CustomTitleText)
                            if obj.Text ~= expected then obj.Text = expected end
                        end
                    end)
                end
            end
        end
    end
end

function setupOwnNameplateListener()
    if ownNameplateConnection then return end
    local function onChar(char)
        task.wait(0.2)
        applyOwnNameplate()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            hrp.ChildAdded:Connect(function(child)
                if child:IsA("BillboardGui") then
                    task.wait(0.05)
                    applyOwnNameplate()
                end
            end)
            local nameTag = hrp:WaitForChild("NameTag", 5)
            if nameTag then
                nameTag.DescendantAdded:Connect(function()
                    task.wait(0.05)
                    applyOwnNameplate()
                end)
            end
        end
    end
    if LocalPlayer.Character then task.spawn(onChar, LocalPlayer.Character) end
    ownNameplateConnection = LocalPlayer.CharacterAdded:Connect(onChar)
end

setupOwnNameplateListener()

do
    function startHideTags()
        if hideTagsConnection then return end
        local function hideNameTag(character)
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local tag = hrp:FindFirstChild("NameTag")
                if tag then
                    tag.Enabled = false
                    table.insert(hiddenTags, tag)
                end
                hrp.ChildAdded:Connect(function(child)
                    if child.Name == "NameTag" then
                        child.Enabled = false
                        table.insert(hiddenTags, child)
                    end
                end)
            end
        end
        for _, p in Players:GetPlayers() do
            if p.Character then hideNameTag(p.Character) end
            p.CharacterAdded:Connect(hideNameTag)
        end
        Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(hideNameTag) end)
        hideTagsConnection = true
    end

    function stopHideTags()
        for _, tag in hiddenTags do
            if tag and tag.Parent then tag.Enabled = true end
        end
        hiddenTags = {}
        hideTagsConnection = nil
    end

    function startHoopDistance()
        if hoopDistConnection then return end

        local function setupGui(char)
            if not char then return end
            local head = char:WaitForChild("Head", 5) or char:FindFirstChild("Head")
            if not head then return end

            if hoopDistanceGui then hoopDistanceGui:Destroy() end

            hoopDistanceGui = Instance.new("BillboardGui")
            hoopDistanceGui.Name = "HoopDistanceText"
            hoopDistanceGui.Size = UDim2.new(0, 150, 0, 30)
            hoopDistanceGui.StudsOffset = Vector3.new(0, 2.5, 0)
            hoopDistanceGui.AlwaysOnTop = true
            hoopDistanceGui.MaxDistance = 500
            hoopDistanceGui.Adornee = head

            hoopDistanceLabel = Instance.new("TextLabel", hoopDistanceGui)
            hoopDistanceLabel.Size = UDim2.new(1, 0, 1, 0)
            hoopDistanceLabel.BackgroundTransparency = 1
            hoopDistanceLabel.TextColor3 = IndicatorColors[s.Visuals.HoopDistanceColor] or Color3.fromRGB(255, 255, 255)
            hoopDistanceLabel.TextTransparency = 1 - (s.Visuals.HoopDistanceTransparency or 0.6)
            hoopDistanceLabel.TextStrokeTransparency = 0.2
            hoopDistanceLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            hoopDistanceLabel.TextSize = 14
            hoopDistanceLabel.Font = Enum.Font.GothamBold
            hoopDistanceLabel.Text = ""

            local parentObj = (gethui and gethui()) or (game:GetService("CoreGui"):FindFirstChild("RobloxGui") or char)
            hoopDistanceGui.Parent = parentObj
        end

        if LocalPlayer.Character then setupGui(LocalPlayer.Character) end

        local hoopAcc = 0
        hoopDistConnection = RunService.Heartbeat:Connect(function(dt)
            if not s.Visuals.HoopDistance then
                if hoopDistanceGui then hoopDistanceGui.Enabled = false end
                return
            end
            hoopAcc += dt
            if hoopAcc < 0.1 then return end
            hoopAcc = 0
            local char = LocalPlayer.Character
            local head = char and char:FindFirstChild("Head")
            if not char or not head then return end

            if not hoopDistanceGui or not hoopDistanceGui.Parent or hoopDistanceGui.Adornee ~= head then
                setupGui(char)
            end

            local rim, dist = nil, math.huge
            if type(nearestrim) == "function" then
                rim, dist = nearestrim(head.Position)
            end
            if (not rim or dist == math.huge) and type(findNearestGoal) == "function" then
                rim, dist = findNearestGoal()
            end

            if rim and dist and dist < 1000 and hoopDistanceLabel then
                hoopDistanceLabel.Text = string.format("%.1f studs", dist)
                hoopDistanceLabel.TextColor3 = IndicatorColors[s.Visuals.HoopDistanceColor] or Color3.fromRGB(255, 255, 255)
                hoopDistanceLabel.TextTransparency = 1 - (s.Visuals.HoopDistanceTransparency or 0.6)
                if hoopDistanceGui then hoopDistanceGui.Enabled = true end
            elseif hoopDistanceLabel then
                hoopDistanceLabel.Text = ""
                if hoopDistanceGui then hoopDistanceGui.Enabled = false end
            end
        end)
    end

    function stopHoopDistance()
        if hoopDistConnection then
            hoopDistConnection:Disconnect()
            hoopDistConnection = nil
        end
        if hoopDistanceGui then
            hoopDistanceGui:Destroy()
            hoopDistanceGui = nil
            hoopDistanceLabel = nil
        end
    end

    local originalHumanoidDescription = nil
    local originalAvatarBackup = {
        BodyColors = nil,
        Clothing = {},
        Accessories = {},
        CharacterMeshes = {},
        Decals = {},
        HeadMesh = nil,
        HasHeadMesh = false,
        SurfaceAppearance = nil,
        Scales = {},
    }

    local function captureOriginalAvatar()
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")

            if not originalHumanoidDescription and LocalPlayer.UserId then
                pcall(function()
                    originalHumanoidDescription = Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
                end)
            end

            local bc = char:FindFirstChildOfClass("BodyColors")
            if bc then
                originalAvatarBackup.BodyColors = {
                    HeadColor3 = bc.HeadColor3,
                    LeftArmColor3 = bc.LeftArmColor3,
                    RightArmColor3 = bc.RightArmColor3,
                    LeftLegColor3 = bc.LeftLegColor3,
                    RightLegColor3 = bc.RightLegColor3,
                    TorsoColor3 = bc.TorsoColor3,
                }
            end

            originalAvatarBackup.Clothing = {}
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                    table.insert(originalAvatarBackup.Clothing, item:Clone())
                end
            end

            originalAvatarBackup.Accessories = {}
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Hat") then
                    table.insert(originalAvatarBackup.Accessories, item:Clone())
                end
            end

            originalAvatarBackup.CharacterMeshes = {}
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("CharacterMesh") then
                    table.insert(originalAvatarBackup.CharacterMeshes, item:Clone())
                end
            end

            local head = char:FindFirstChild("Head")
            if head then
                originalAvatarBackup.Decals = {}
                for _, d in ipairs(head:GetChildren()) do
                    if d:IsA("Decal") then
                        table.insert(originalAvatarBackup.Decals, d:Clone())
                    end
                end
                local mesh = head:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    originalAvatarBackup.HasHeadMesh = true
                    originalAvatarBackup.HeadMesh = {
                        MeshId = mesh.MeshId,
                        TextureId = mesh.TextureId,
                        Scale = mesh.Scale,
                        Offset = mesh.Offset
                    }
                else
                    originalAvatarBackup.HasHeadMesh = false
                    originalAvatarBackup.HeadMesh = nil
                end
                local sa = head:FindFirstChildOfClass("SurfaceAppearance")
                if sa then originalAvatarBackup.SurfaceAppearance = sa:Clone() end
            end

            if hum then
                originalAvatarBackup.Scales = {}
                for _, scaleName in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale", "BodyProportionScale", "BodyTypeScale"}) do
                    local sc = hum:FindFirstChild(scaleName)
                    if sc then
                        originalAvatarBackup.Scales[scaleName] = sc.Value
                    end
                end
            end
        end)
    end
    task.defer(function()
        task.wait(1)
        captureOriginalAvatar()
    end)

    function getInGamePlayerNames()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        if #names == 0 then
            table.insert(names, "None")
        end
        table.sort(names)
        return names
    end

    function attachAccessoryToChar(localChar, accClone, originalAcc)
        local handle = accClone:FindFirstChild("Handle") or accClone:FindFirstChildOfClass("BasePart")
        if not handle then return end

        for _, joint in ipairs(handle:GetChildren()) do
            if joint:IsA("Weld") or joint:IsA("WeldConstraint") or joint:IsA("ManualWeld") or joint:IsA("Motor6D") then
                if joint.Name == "AccessoryWeld" or not joint.Part1 or not joint.Part1:IsDescendantOf(accClone) then
                    joint:Destroy()
                end
            end
        end

        handle.Anchored = false
        handle.CanCollide = false
        handle.CanTouch = false
        handle.CanQuery = false
        pcall(function() handle.Massless = true end)

        local attached = false
        local handleAtt = handle:FindFirstChildOfClass("Attachment")

        if handleAtt then
            for _, part in ipairs(localChar:GetChildren()) do
                if part:IsA("BasePart") then
                    local charAtt = part:FindFirstChild(handleAtt.Name)
                    if charAtt and charAtt:IsA("Attachment") then
                        local weld = Instance.new("Weld")
                        weld.Name = "AccessoryWeld"
                        weld.Part0 = handle
                        weld.Part1 = part
                        weld.C0 = handleAtt.CFrame
                        weld.C1 = charAtt.CFrame
                        weld.Parent = handle
                        attached = true
                        break
                    end
                end
            end
        end

        if not attached and originalAcc then
            local origHandle = originalAcc:FindFirstChild("Handle") or originalAcc:FindFirstChildOfClass("BasePart")
            if origHandle then
                local origWeld = origHandle:FindFirstChild("AccessoryWeld") or origHandle:FindFirstChildOfClass("Weld")
                if origWeld and origWeld.Part1 then
                    local targetPart = localChar:FindFirstChild(origWeld.Part1.Name)
                    if targetPart and targetPart:IsA("BasePart") then
                        local weld = Instance.new("Weld")
                        weld.Name = "AccessoryWeld"
                        weld.Part0 = handle
                        weld.Part1 = targetPart
                        weld.C0 = origWeld.C0
                        weld.C1 = origWeld.C1
                        weld.Parent = handle
                        attached = true
                    end
                end
            end
        end

        if not attached then
            local nameLower = accClone.Name:lower()
            local targetPartName = "Head"
            if nameLower:find("hair") or nameLower:find("hat") or nameLower:find("cap") or nameLower:find("hood")
                or nameLower:find("helm") or nameLower:find("horns") or nameLower:find("bandana")
                or nameLower:find("glasses") or nameLower:find("mask") or nameLower:find("face")
                or nameLower:find("beanie") or nameLower:find("fedora") or nameLower:find("crown") then
                targetPartName = "Head"
            elseif nameLower:find("cape") or nameLower:find("wings") or nameLower:find("backpack")
                or nameLower:find("sword") or nameLower:find("back") or nameLower:find("quiver") then
                targetPartName = localChar:FindFirstChild("UpperTorso") and "UpperTorso" or "Torso"
            elseif nameLower:find("waist") or nameLower:find("tail") or nameLower:find("belt") then
                targetPartName = localChar:FindFirstChild("LowerTorso") and "LowerTorso" or "Torso"
            elseif nameLower:find("shoulder") or nameLower:find("pauldrons") then
                targetPartName = localChar:FindFirstChild("RightUpperArm") and "RightUpperArm" or (localChar:FindFirstChild("Right Arm") and "Right Arm" or "Torso")
            elseif nameLower:find("necklace") or nameLower:find("scarf") or nameLower:find("collar") or nameLower:find("neck") then
                targetPartName = localChar:FindFirstChild("UpperTorso") and "UpperTorso" or (localChar:FindFirstChild("Head") and "Head" or "Torso")
            else
                targetPartName = "Head"
            end

            local targetPart = localChar:FindFirstChild(targetPartName) or localChar:FindFirstChild("Head") or localChar:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local weld = Instance.new("Weld")
                weld.Name = "AccessoryWeld"
                weld.Part0 = handle
                weld.Part1 = targetPart
                if handleAtt then
                    weld.C0 = handleAtt.CFrame
                else
                    weld.C0 = CFrame.new(0, 0, 0)
                end
                weld.C1 = CFrame.new(0, 0, 0)
                weld.Parent = handle
                attached = true
            end
        end

        accClone.Parent = localChar
    end

    function copyCharacterDirect(targetChar, targetUserId)
        local localChar = LocalPlayer.Character
        if not localChar or not targetChar then return false end
        local localHum = localChar:FindFirstChildOfClass("Humanoid")
        local targetHum = targetChar:FindFirstChildOfClass("Humanoid")
        if not localHum then return false end

        local targetColors = targetChar:FindFirstChildOfClass("BodyColors")
        if targetColors then
            local localColors = localChar:FindFirstChildOfClass("BodyColors")
            if not localColors then
                localColors = Instance.new("BodyColors", localChar)
            end
            localColors.HeadColor3 = targetColors.HeadColor3
            localColors.LeftArmColor3 = targetColors.LeftArmColor3
            localColors.RightArmColor3 = targetColors.RightArmColor3
            localColors.LeftLegColor3 = targetColors.LeftLegColor3
            localColors.RightLegColor3 = targetColors.RightLegColor3
            localColors.TorsoColor3 = targetColors.TorsoColor3
        end

        for _, item in ipairs(localChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                item:Destroy()
            end
        end
        for _, item in ipairs(targetChar:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") then
                local clone = item:Clone()
                clone.Parent = localChar
            end
        end

        for _, item in ipairs(localChar:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Hat") then
                item:Destroy()
            end
        end
        for _, item in ipairs(targetChar:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Hat") then
                local clone = item:Clone()
                attachAccessoryToChar(localChar, clone, item)
            end
        end

        local targetHead = targetChar:FindFirstChild("Head")
        local localHead = localChar:FindFirstChild("Head")
        if targetHead and localHead then
            local targetFace = targetHead:FindFirstChildOfClass("Decal") or targetHead:FindFirstChild("face")
            local localFace = localHead:FindFirstChildOfClass("Decal") or localHead:FindFirstChild("face")
            if targetFace then
                if not localFace then
                    localFace = Instance.new("Decal")
                    localFace.Name = "face"
                    localFace.Face = Enum.NormalId.Front
                    localFace.Parent = localHead
                end
                localFace.Texture = targetFace.Texture
            end
            local targetMesh = targetHead:FindFirstChildOfClass("SpecialMesh")
            local localMesh = localHead:FindFirstChildOfClass("SpecialMesh")
            if targetMesh and localMesh then
                localMesh.MeshId = targetMesh.MeshId
                localMesh.TextureId = targetMesh.TextureId
                localMesh.Scale = targetMesh.Scale
            end
        end

        for _, item in ipairs(localChar:GetChildren()) do
            if item:IsA("CharacterMesh") then item:Destroy() end
        end
        for _, item in ipairs(targetChar:GetChildren()) do
            if item:IsA("CharacterMesh") then
                item:Clone().Parent = localChar
            end
        end

        if targetHum then
            for _, scaleName in ipairs({"BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale", "BodyProportionScale", "BodyTypeScale"}) do
                local tScale = targetHum:FindFirstChild(scaleName)
                local lScale = localHum:FindFirstChild(scaleName)
                if tScale and lScale then
                    lScale.Value = tScale.Value
                end
            end
        end

        return true
    end

    function applyAvatar(targetUserId, targetPlayerInstance)
        local char = LocalPlayer.Character
        if not char then return false, "No character found" end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return false, "No humanoid found" end

        if targetPlayerInstance and targetPlayerInstance.Character and targetPlayerInstance.Character:FindFirstChild("Head") then
            if copyCharacterDirect(targetPlayerInstance.Character, targetUserId) then
                s.AvatarChanger.LastCopiedUserId = targetUserId
                return true
            end
        end

        if targetUserId then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.UserId == targetUserId and p.Character and p.Character:FindFirstChild("Head") then
                    if copyCharacterDirect(p.Character, targetUserId) then
                        s.AvatarChanger.LastCopiedUserId = targetUserId
                        return true
                    end
                end
            end
        end

        if targetUserId then
            local dummy = nil
            pcall(function()
                dummy = Players:CreateHumanoidModelFromUserId(targetUserId)
            end)

            if not dummy then
                local ok, desc = pcall(function()
                    return Players:GetHumanoidDescriptionFromUserId(targetUserId)
                end)
                if ok and desc then
                    pcall(function()
                        dummy = Players:CreateHumanoidModelFromDescription(desc, hum.RigType)
                    end)
                end
            end

            if dummy then
                local copied = copyCharacterDirect(dummy, targetUserId)
                dummy:Destroy()
                if copied then
                    s.AvatarChanger.LastCopiedUserId = targetUserId
                    return true
                end
            end

            local ok, desc = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(targetUserId)
            end)
            if ok and desc then
                local applied = pcall(function()
                    hum:ApplyDescription(desc)
                end)
                if applied then
                    s.AvatarChanger.LastCopiedUserId = targetUserId
                    return true
                end
            end
        end

        return false, "Could not apply avatar"
    end

    function copyAvatarFromSelected()
        local selectedName = s.AvatarChanger.SelectedPlayer
        if not selectedName or selectedName == "None" or selectedName == "" then
            return false, "Select a player from the list first"
        end

        local targetPlayer = nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and (p.Name == selectedName or p.DisplayName == selectedName or p.Name:lower() == selectedName:lower()) then
                targetPlayer = p
                break
            end
        end

        if not targetPlayer then
            return false, "Player not found in game"
        end

        if not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
            return false, "Target player character not spawned yet"
        end

        s.AvatarChanger.LastCopiedName = targetPlayer.Name
        local ok, err = applyAvatar(targetPlayer.UserId, targetPlayer)
        return ok, ok and targetPlayer.Name or err
    end

    function copyAvatarFromCustom()
        local input = s.AvatarChanger.CustomUser
        if not input or input:gsub("%s+", "") == "" then
            return false, "Enter a Username or UserId"
        end
        input = input:match("^%s*(.-)%s*$")

        local userId = tonumber(input)
        local targetName = input

        if not userId then
            local ok, resolvedId = pcall(function()
                return Players:GetUserIdFromNameAsync(input)
            end)
            if ok and resolvedId then
                userId = resolvedId
            else
                return false, "Username not found on Roblox"
            end
        end

        local targetPlayer = Players:GetPlayerByUserId(userId)
        s.AvatarChanger.LastCopiedName = targetName
        local ok, err = applyAvatar(userId, targetPlayer)
        return ok, ok and targetName or err
    end

    function resetAvatar()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum then return false end

        s.AvatarChanger.LastCopiedUserId = nil

        pcall(function()
            local desc = originalHumanoidDescription or Players:GetHumanoidDescriptionFromUserId(LocalPlayer.UserId)
            if desc then
                hum:ApplyDescription(desc)
            end
        end)

        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Shirt") or item:IsA("Pants") or item:IsA("ShirtGraphic") or item:IsA("Accessory") or item:IsA("Hat") or item:IsA("CharacterMesh") then
                item:Destroy()
            end
        end

        if originalAvatarBackup.BodyColors then
            local bc = char:FindFirstChildOfClass("BodyColors") or Instance.new("BodyColors", char)
            bc.HeadColor3 = originalAvatarBackup.BodyColors.HeadColor3
            bc.LeftArmColor3 = originalAvatarBackup.BodyColors.LeftArmColor3
            bc.RightArmColor3 = originalAvatarBackup.BodyColors.RightArmColor3
            bc.LeftLegColor3 = originalAvatarBackup.BodyColors.LeftLegColor3
            bc.RightLegColor3 = originalAvatarBackup.BodyColors.RightLegColor3
            bc.TorsoColor3 = originalAvatarBackup.BodyColors.TorsoColor3
        end

        for _, cloth in ipairs(originalAvatarBackup.Clothing) do
            cloth:Clone().Parent = char
        end

        for _, acc in ipairs(originalAvatarBackup.Accessories) do
            local clone = acc:Clone()
            attachAccessoryToChar(char, clone, acc)
        end

        for _, cm in ipairs(originalAvatarBackup.CharacterMeshes) do
            cm:Clone().Parent = char
        end

        local head = char:FindFirstChild("Head")
        if head then
            for _, d in ipairs(head:GetChildren()) do
                if d:IsA("Decal") or d:IsA("SurfaceAppearance") or d:IsA("FaceControls") then
                    d:Destroy()
                end
            end

            if #originalAvatarBackup.Decals > 0 then
                for _, d in ipairs(originalAvatarBackup.Decals) do
                    d:Clone().Parent = head
                end
            else
                local decal = Instance.new("Decal")
                decal.Name = "face"
                decal.Face = Enum.NormalId.Front
                decal.Texture = "rbxasset://textures/face.png"
                decal.Parent = head
            end

            if originalAvatarBackup.SurfaceAppearance then
                originalAvatarBackup.SurfaceAppearance:Clone().Parent = head
            end

            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if originalAvatarBackup.HasHeadMesh and originalAvatarBackup.HeadMesh then
                if not mesh then
                    mesh = Instance.new("SpecialMesh", head)
                end
                mesh.MeshId = originalAvatarBackup.HeadMesh.MeshId
                mesh.TextureId = originalAvatarBackup.HeadMesh.TextureId
                mesh.Scale = originalAvatarBackup.HeadMesh.Scale
                mesh.Offset = originalAvatarBackup.HeadMesh.Offset
            else
                if mesh then
                    mesh:Destroy()
                end
            end
        end

        for scaleName, val in pairs(originalAvatarBackup.Scales) do
            local sc = hum:FindFirstChild(scaleName)
            if sc then
                sc.Value = val
            end
        end

        return true
    end
end

local isMobile = UserInputService.TouchEnabled

do
    pcall(function()
        local area = workspace:WaitForChild("PracticeArea")
        local courts = workspace:FindFirstChild("Courts")
        area.Parent = courts
    end)
end

local env2 = getgenv()
if type(env2.__standalone_silent_aim_unload) == "function" then
    pcall(env2.__standalone_silent_aim_unload)
end
local fireMobileSelfPass  -- forward-declared; assigned below
do

    local Gui = Instance.new("ScreenGui")

    Gui.Name = "AuralMobileGui"

    Gui.ResetOnSpawn = false

    Gui.IgnoreGuiInset = true

    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    Gui.Parent = gethui()

    local Container = Instance.new("Frame")

    Container.Name = "GuardContainer"

    Container.Size = UDim2.fromOffset(74, 74)

    Container.Position = UDim2.new(0.82, 0, 0.55, 0)

    local saved = getgenv().__aural_guard_pos

    if saved then

        Container.Position = UDim2.new(saved[1], saved[2], saved[3], saved[4])

    end

    Container.BackgroundTransparency = 1

    Container.Active = false

    Container.Parent = Gui

    local Button = Instance.new("TextButton")

    Button.Name = "AutoGuard"

    Button.Size = UDim2.fromScale(1, 1)

    Button.BackgroundColor3 = Color3.fromRGB(28, 28, 32)

    Button.BackgroundTransparency = 0.15

    Button.Text = ""

    Button.AutoButtonColor = false

    Button.Visible = s.Defending.AutoGuardButton or false

    Button.Parent = Container

    Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

    local Stroke = Instance.new("UIStroke")

    Stroke.Color = Color3.fromRGB(70, 70, 78)

    Stroke.Thickness = 2

    Stroke.Transparency = 0.2

    Stroke.Parent = Button

    local IconLbl = Instance.new("ImageLabel")

    IconLbl.Name = "Icon"

    IconLbl.Size = UDim2.fromScale(0.55, 0.55)

    IconLbl.Position = UDim2.fromScale(0.5, 0.42)

    IconLbl.AnchorPoint = Vector2.new(0.5, 0.5)

    IconLbl.BackgroundTransparency = 1

    IconLbl.Image = "rbxassetid://6031090990"

    IconLbl.ImageColor3 = Color3.fromRGB(200, 200, 205)

    IconLbl.Parent = Button

    local StatusLabel = Instance.new("TextLabel")

    StatusLabel.Name = "Status"

    StatusLabel.Size = UDim2.new(1, 0, 0, 16)

    StatusLabel.Position = UDim2.new(0, 0, 1, -18)

    StatusLabel.BackgroundTransparency = 1

    StatusLabel.Font = Enum.Font.GothamBold

    StatusLabel.TextSize = 11

    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 158)

    StatusLabel.Text = "OFF"

    StatusLabel.Parent = Button

    local function setVisualState()

        local on = s.Defending.AutoGuard

        local mode = tostring(s.Defending.AutoGuardMode or "Prediction")

        local short = mode == "Blatant" and "BLAT"

                   or (mode == "Legit" and "LEGIT" or "PRED")

        if on then

            Button.BackgroundColor3 = Color3.fromRGB(0, 170, 85)

            Button.BackgroundTransparency = 0.05

            Stroke.Color = Color3.fromRGB(80, 255, 160)

            Stroke.Transparency = 0.35

            IconLbl.ImageColor3 = Color3.fromRGB(255, 255, 255)

            StatusLabel.Text = short

            StatusLabel.TextColor3 = Color3.fromRGB(220, 255, 235)

        else

            Button.BackgroundColor3 = Color3.fromRGB(28, 28, 32)

            Button.BackgroundTransparency = 0.15

            Stroke.Color = Color3.fromRGB(70, 70, 78)

            Stroke.Transparency = 0.2

            IconLbl.ImageColor3 = Color3.fromRGB(160, 160, 168)

            StatusLabel.Text = "OFF"

            StatusLabel.TextColor3 = Color3.fromRGB(140, 140, 148)

        end

    end

    setVisualState()

    local lastKey = nil

    task.spawn(function()

        while Gui.Parent do

            task.wait(0.2)

            local key = tostring(s.Defending.AutoGuard)

                     .. "|" .. tostring(s.Defending.AutoGuardMode)

                     .. "|" .. tostring(s.Defending.AutoGuardButton)

            if key ~= lastKey then

                lastKey = key

                Button.Visible = s.Defending.AutoGuardButton or false

                setVisualState()

            end

        end

    end)

    local activeInput = nil

    local dragging, dragStart, startPos, moved = false, nil, nil, false

    local DRAG_THRESHOLD = UserInputService.TouchEnabled and 14 or 6

    local lastToggleAt = 0

    local TOGGLE_COOLDOWN = 0.25

    Button.InputBegan:Connect(function(input)

        if input.UserInputType ~= Enum.UserInputType.MouseButton1

           and input.UserInputType ~= Enum.UserInputType.Touch then return end

        if activeInput then return end

        activeInput = input

        dragging, moved = true, false

        dragStart = input.Position

        startPos = Container.Position

    end)

    UserInputService.InputChanged:Connect(function(input)

        if not dragging or input ~= activeInput then return end

        if input.UserInputType ~= Enum.UserInputType.Touch

           and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end

        local delta = input.Position - dragStart

        if delta.Magnitude > DRAG_THRESHOLD then moved = true end

        Container.Position = UDim2.new(

            startPos.X.Scale, startPos.X.Offset + delta.X,

            startPos.Y.Scale, startPos.Y.Offset + delta.Y

        )

    end)

    UserInputService.InputEnded:Connect(function(input)

        if input ~= activeInput then return end

        dragging = false

        activeInput = nil

        if not moved then

            local now = os.clock()

            if now - lastToggleAt >= TOGGLE_COOLDOWN then

                lastToggleAt = now

                s.Defending.AutoGuard = not s.Defending.AutoGuard

                setVisualState()

                local popTween = TweenService:Create(

                    Button,

                    TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

                    { Size = UDim2.fromScale(1.12, 1.12) }

                )

                popTween:Play()

                popTween.Completed:Connect(function()

                    TweenService:Create(

                        Button,

                        TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),

                        { Size = UDim2.fromScale(1, 1) }

                    ):Play()

                end)

            end

        else

            getgenv().__aural_guard_pos = {

                Container.Position.X.Scale, Container.Position.X.Offset,

                Container.Position.Y.Scale, Container.Position.Y.Offset,

            }

        end

    end)

    -- ─── Mobile Quick-Toggle Buttons ─────────────────────────────────────────────
    local function makeMobileButton(opts)
        local cont = Instance.new("Frame")
        cont.Name = opts.name .. "Container"
        cont.Size = UDim2.fromOffset(74, 74)
        cont.Position = UDim2.new(opts.defaultX, 0, opts.defaultY, 0)
        local saved = getgenv()[opts.savedPosKey]
        if saved then
            cont.Position = UDim2.new(saved[1], saved[2], saved[3], saved[4])
        end
        cont.BackgroundTransparency = 1
        cont.Active = false
        cont.Parent = Gui

        local btn = Instance.new("TextButton")
        btn.Name = opts.name
        btn.Size = UDim2.fromScale(1, 1)
        btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
        btn.BackgroundTransparency = 0.15
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.Visible = opts.getVisible()
        btn.Parent = cont

        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

        local stroke2 = Instance.new("UIStroke")
        stroke2.Color = Color3.fromRGB(70, 70, 78)
        stroke2.Thickness = 2
        stroke2.Transparency = 0.2
        stroke2.Parent = btn

        local iconLbl = Instance.new("TextLabel")
        iconLbl.Name = "Icon"
        iconLbl.Size = UDim2.fromScale(1, 0.55)
        iconLbl.Position = UDim2.fromScale(0, 0.18)
        iconLbl.BackgroundTransparency = 1
        iconLbl.Font = Enum.Font.GothamBold
        iconLbl.TextSize = 13
        iconLbl.TextColor3 = Color3.fromRGB(160, 160, 168)
        iconLbl.Text = opts.label
        iconLbl.Parent = btn

        local statusLbl = Instance.new("TextLabel")
        statusLbl.Name = "Status"
        statusLbl.Size = UDim2.new(1, 0, 0, 16)
        statusLbl.Position = UDim2.new(0, 0, 1, -18)
        statusLbl.BackgroundTransparency = 1
        statusLbl.Font = Enum.Font.GothamBold
        statusLbl.TextSize = 11
        statusLbl.TextColor3 = Color3.fromRGB(150, 150, 158)
        statusLbl.Text = opts.isToggle and "OFF" or opts.label
        statusLbl.Parent = btn

        local function updateVisual()
            btn.Visible = opts.getVisible()
            if opts.isToggle then
                local on = opts.getState()
                if on then
                    btn.BackgroundColor3 = Color3.fromRGB(0, 170, 85)
                    btn.BackgroundTransparency = 0.05
                    stroke2.Color = Color3.fromRGB(80, 255, 160)
                    stroke2.Transparency = 0.35
                    iconLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                    statusLbl.Text = "ON"
                    statusLbl.TextColor3 = Color3.fromRGB(220, 255, 235)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
                    btn.BackgroundTransparency = 0.15
                    stroke2.Color = Color3.fromRGB(70, 70, 78)
                    stroke2.Transparency = 0.2
                    iconLbl.TextColor3 = Color3.fromRGB(160, 160, 168)
                    statusLbl.Text = "OFF"
                    statusLbl.TextColor3 = Color3.fromRGB(140, 140, 148)
                end
            else
                btn.BackgroundColor3 = Color3.fromRGB(90, 45, 140)
                btn.BackgroundTransparency = 0.05
                stroke2.Color = Color3.fromRGB(170, 90, 255)
                stroke2.Transparency = 0.35
                iconLbl.TextColor3 = Color3.fromRGB(220, 200, 255)
                statusLbl.Text = opts.label
                statusLbl.TextColor3 = Color3.fromRGB(200, 180, 255)
            end
        end

        updateVisual()

        local lastStateKey = nil
        task.spawn(function()
            while Gui.Parent do
                task.wait(0.2)
                local key = tostring(opts.isToggle and opts.getState() or false) .. "|" .. tostring(opts.getVisible())
                if key ~= lastStateKey then
                    lastStateKey = key
                    updateVisual()
                end
            end
        end)

        local activeInp = nil
        local draggingB, dragStartB, startPosB, movedB = false, nil, nil, false
        local DRAG_THRESH = UserInputService.TouchEnabled and 14 or 6
        local lastTapAt = 0
        local TAP_COOLDOWN = 0.25

        btn.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
               and input.UserInputType ~= Enum.UserInputType.Touch then return end
            if activeInp then return end
            activeInp = input
            draggingB, movedB = true, false
            dragStartB = input.Position
            startPosB = cont.Position
        end)

        UserInputService.InputChanged:Connect(function(input)
            if not draggingB or input ~= activeInp then return end
            if input.UserInputType ~= Enum.UserInputType.Touch
               and input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
            local delta = input.Position - dragStartB
            if delta.Magnitude > DRAG_THRESH then movedB = true end
            cont.Position = UDim2.new(
                startPosB.X.Scale, startPosB.X.Offset + delta.X,
                startPosB.Y.Scale, startPosB.Y.Offset + delta.Y
            )
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input ~= activeInp then return end
            draggingB = false
            activeInp = nil
            if not movedB then
                local now = os.clock()
                if now - lastTapAt >= TAP_COOLDOWN then
                    lastTapAt = now
                    if opts.isToggle then
                        opts.onToggle()
                        updateVisual()
                    else
                        opts.onPress()
                    end
                    local popTween = TweenService:Create(
                        btn,
                        TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                        { Size = UDim2.fromScale(1.12, 1.12) }
                    )
                    popTween:Play()
                    popTween.Completed:Connect(function()
                        TweenService:Create(
                            btn,
                            TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                            { Size = UDim2.fromScale(1, 1) }
                        ):Play()
                    end)
                end
            else
                getgenv()[opts.savedPosKey] = {
                    cont.Position.X.Scale, cont.Position.X.Offset,
                    cont.Position.Y.Scale, cont.Position.Y.Offset,
                }
            end
        end)
    end

    -- Silent Aim toggle button
    makeMobileButton({
        name = "SilentAim",
        savedPosKey = "__aural_silentaim_pos",
        defaultX = 0.72, defaultY = 0.36,
        label = "SA",
        isToggle = true,
        getVisible = function() return s.Shooting.SilentAimButton or false end,
        getState = function() return s.Shooting.AuralEnabled or s.Shooting.FatalEnabled end,
        onToggle = function()
            s.Shooting.AuralEnabled = not (s.Shooting.AuralEnabled or s.Shooting.FatalEnabled)
            s.Shooting.FatalEnabled = false
            if uiToggles and uiToggles.aural then
                pcall(function() uiToggles.aural:Set(s.Shooting.AuralEnabled) end)
            end
        end,
    })

    -- Reach (Ankles) toggle button
    makeMobileButton({
        name = "Reach",
        savedPosKey = "__aural_reach_pos",
        defaultX = 0.72, defaultY = 0.48,
        label = "REACH",
        isToggle = true,
        getVisible = function() return s.AnklesReach.ReachButton or false end,
        getState = function() return s.AnklesReach.Enabled end,
        onToggle = function()
            s.AnklesReach.Enabled = not s.AnklesReach.Enabled
            if uiToggles and uiToggles.reach then
                pcall(function() uiToggles.reach:Set(s.AnklesReach.Enabled) end)
            end
        end,
    })

    -- Ball Magnet toggle button
    makeMobileButton({
        name = "Magnet",
        savedPosKey = "__aural_magnet_pos",
        defaultX = 0.72, defaultY = 0.60,
        label = "MAG",
        isToggle = true,
        getVisible = function() return s.Ball.MagnetButton or false end,
        getState = function() return s.Ball.BallMags end,
        onToggle = function()
            s.Ball.BallMags = not s.Ball.BallMags
            if s.Ball.BallMags then enableMagnet() else disableMagnet() end
            if uiToggles and uiToggles.magnet then
                pcall(function() uiToggles.magnet:Set(s.Ball.BallMags) end)
            end
        end,
    })

    -- Self Pass action button (purple, fires immediately on tap)
    makeMobileButton({
        name = "SelfPass",
        savedPosKey = "__aural_selfpass_pos",
        defaultX = 0.82, defaultY = 0.36,
        label = "PASS",
        isToggle = false,
        getVisible = function() return s.SelfPass.SelfPassButton or false end,
        getState = function() return false end,
        onPress = function()
            task.spawn(fireMobileSelfPass)
        end,
    })

end

local goals = {}

do
    function validgoal(object)
        if not object:IsA("BasePart") then return false end
        local name2 = string.lower(object.Name)
        if name2 ~= "goal" and name2 ~= "goalhome" and name2 ~= "goalaway" then return false end
        local parent = object.Parent
        for _ = 1, 5 do
            if not parent then break end
            local parentname = string.lower(parent.Name)
            if string.find(parentname, "hitbox", 1, true) or string.find(parentname, "fieldgoal", 1, true) then return true end
            parent = parent.Parent
        end
        return false
    end

    function refreshgoals()
        table.clear(goals)
        for _, object in workspace:GetDescendants() do
            if validgoal(object) then table.insert(goals, object) end
        end
    end

    refreshgoals()

    workspace.DescendantAdded:Connect(function(object)
        if validgoal(object) then table.insert(goals, object) end
    end)

    workspace.DescendantRemoving:Connect(function(object)
        if not object:IsA("BasePart") then return end
        for i = #goals, 1, -1 do
            if goals[i] == object then
                table.remove(goals, i)
                break
            end
        end
    end)
end

local balls = {}
for _, v in workspace:GetDescendants() do
    if v:IsA("BasePart") and v.Name == "Ball" then table.insert(balls, v) end
end

workspace.DescendantAdded:Connect(function(child)
    if child:IsA("BasePart") and child.Name == "Ball" then table.insert(balls, child) end
end)

workspace.DescendantRemoving:Connect(function(child)
    if not child:IsA("BasePart") or child.Name ~= "Ball" then return end
    for i = #balls, 1, -1 do
        if balls[i] == child then
            table.remove(balls, i)
            break
        end
    end
end)

do
    local teamCache = setmetatable({}, { __mode = "k" })
    function getMyTeamOnCourt(Court)
        if not Court then return false end
        local now = os.clock()
        local cached = teamCache[Court]
        if cached and now - cached.at < 0.5 then return cached.team end
        local team = false
        local CourtPlayers = Court:FindFirstChild("_CourtPlayers")
        if CourtPlayers then
            for _, v in ipairs(CourtPlayers:GetChildren()) do
                local SlotValue = v.Value
                if typeof(SlotValue) == "Instance" and SlotValue:IsA("Player") and SlotValue.Name == LocalPlayer.Name then
                    local SlotTeam = v.Name:sub(1, 4)
                    team = (SlotTeam == "Home") and "Home" or (SlotTeam == "Away" and "Away")
                    break
                end
            end
        end
        teamCache[Court] = { team = team, at = now }
        return team
    end

    function nearestgoal(root)
        local best, bestDist = nil, math.huge
        local char = LocalPlayer.Character
        for i = #goals, 1, -1 do
            local goal = goals[i]
            if not goal or not goal.Parent then
                table.remove(goals, i)
                continue
            end

            local Hitboxes = goal.Parent
            if Hitboxes and (Hitboxes.Name == "HitboxesHome" or Hitboxes.Name == "HitboxesAway") then
                local MyTeam = getMyTeamOnCourt(Hitboxes.Parent)
                if MyTeam then
                    if (MyTeam == "Home" and Hitboxes.Name == "HitboxesHome") or
                       (MyTeam == "Away" and Hitboxes.Name == "HitboxesAway") then
                        continue
                    end
                end
            end

            local delta = goal.Position - root.Position
            local flat = Vector3.new(delta.X, 0, delta.Z).Magnitude
            if flat < bestDist then best = goal; bestDist = flat end
        end
        return best, bestDist
    end

    function getclosestball()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local closest, closestDist = nil, math.huge
        if not hrp then return nil, math.huge end
        for _, ball in balls do
            local d = (hrp.Position - ball.Position).Magnitude
            if d < closestDist then closestDist = d; closest = ball end
        end
        return closest, closestDist
    end

    getclosestplayerwithball = function()
        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local closest, closestDist = nil, math.huge
        if not hrp then return nil, math.huge end
        for _, player in Players:GetPlayers() do
            if player ~= LocalPlayer and player.Character then
                local basketball = player.Character:FindFirstChild("Basketball")
                if basketball and basketball:FindFirstChild("Ball") then
                    local hrp2 = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp2 then
                        local d = (hrp.Position - hrp2.Position).Magnitude
                        if d < closestDist then closestDist = d; closest = player end
                    end
                end
            end
        end
        return closest, closestDist
    end
end

local state: any = {
    target = nil, connections = {}, actorst = nil, actorname = nil,
    actors = {}, oldnewindex = nil, active = true, clicking = false
}

do
    function addconnection(c) table.insert(state.connections, c); return c end

    settarget = function(target)
        if target == nil and state.target == nil then return end
        state.target = target
        if state.actorst then pcall(function() state.actorst.t = target end) end
    end

    doClick = function()
    if state.clicking then return end
    state.clicking = true
    getgenv().__aural_aiming = true

    if isMobile then
        if Icon then
            local pos = Vector2.new(
                Icon.AbsolutePosition.X + Icon.AbsoluteSize.X / 2,
                Icon.AbsolutePosition.Y + Icon.AbsoluteSize.Y / 2
            )
            Input:SendTouchEvent(1, 0, pos.X, pos.Y)
            Input:SendTouchEvent(1, 2, pos.X, pos.Y)
        end
    elseif isConsole() then
        local consoleSystem = getConsoleSystem()
        if consoleSystem == "Xbox" then
			game:GetService("VirtualInputManager"):HandleGamepadConnect(123)
            Input:HandleGamepadButtonInput(123, Enum.KeyCode.ButtonRT, 1)
            Input:HandleGamepadButtonInput(123, Enum.KeyCode.ButtonRT, 0)
			game:GetService("VirtualInputManager"):HandleGamepadDisconnect(123)
        else
			game:GetService("VirtualInputManager"):HandleGamepadConnect(123)
            Input:HandleGamepadButtonInput(123, Enum.KeyCode.ButtonR2, 1)
            Input:HandleGamepadButtonInput(123, Enum.KeyCode.ButtonR2, 0)
			game:GetService("VirtualInputManager"):HandleGamepadDisconnect(123)
        end
    else
        local vp = Camera.ViewportSize
        Input:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
        Input:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
    end

    task.delay(0.35, function()
        state.clicking = false
        getgenv().__aural_aiming = false
    end)
end

    local cachedGoal, nextGoalScan = nil, 0
    local function fastNearestGoal(root)
        local now = os.clock()
        if now >= nextGoalScan or not (cachedGoal and cachedGoal.Parent) then
            nextGoalScan = now + 0.25
            cachedGoal = nearestgoal(root)
        end
        if not cachedGoal then return nil, math.huge end
        local d = cachedGoal.Position - root.Position
        return cachedGoal, Vector3.new(d.X, 0, d.Z).Magnitude
    end

    function auralLookOk(goal)
    local camCF = Camera.CFrame
    local wanted = (goal.Position - camCF.Position).Unit.Y
    return camCF.LookVector.Y >= math.min(0.3, wanted - 0.12)
end

    function updateAuralTarget()
if getgenv().__aural_passOverride then return end
        if not state.active or not s.Shooting.AuralEnabled then settarget(nil); return end
        local clickMode = s.Shooting.AuralTrigger == "Click"
        if clickMode and not (UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
            or os.clock() - (state.lastClick or 0) < 0.8) then
            settarget(nil); return
        end
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        if not char or not hum or not root or not head or not hasball(char) then settarget(nil); return end
        if hum.FloorMaterial ~= Enum.Material.Air and not hum.Jump then settarget(nil); return end
        local goal, distance = fastNearestGoal(root)
        if not goal then settarget(nil); return end
        if s.Shooting.AuralAimAssist and not auralLookOk(goal) then settarget(nil); return end
        local tableArc, tablePower = getTableShot(distance)
        if distance < AURAL_MIN_DIST or (distance > AURAL_MAX_DIST and not tablePower) then
            settarget(nil)
            return
        end
        if clickMode then
            local wanted = tablePower or 85
            if state.lastAuralPower ~= wanted then
                state.lastAuralPower = wanted
                if tablePower and setpower then setpower(tablePower) else LocalPlayer:SetAttribute("Power", 85) end
            end
        end
        local offset = getAuralShotArc(distance, tableArc, tablePower) + getgenv().Settings.Shooting.ShotYAxis

        if s.Shooting.HumanizeAim then
            local strength = s.Shooting.HumanizeStrength or 1.2
            local missChance = (s.Shooting.MissChance or 12) / 100

            if math.random() < missChance then
                if math.random() < 0.5 then
                    offset += strength * 3 + math.random() * strength * 2
                else
                    offset -= strength * 3 + math.random() * strength * 2
                end
            else
                offset += (math.random() * 2 - 1) * strength
            end
        end

        local aimPos = goal.Position
if s.Shooting.BankShots then
    aimPos = getgenv().AuralBackboard.ResolveAimPoint(goal) or goal.Position
end
settarget(velocify(aimPos + Vector3.new(0, offset, 0), distance))

        if tablePower then setpower(tablePower) end
    end
end

local actorcode = [==[
local registry = game:GetService("SharedTableRegistry")
local players = game:GetService("Players")
local st = registry:GetSharedTable(__silentaimtable)
local camera = workspace.CurrentCamera
local function target() local v = st.t return typeof(v) == "Vector3" and v or nil end
local function aimcframe()
    local v = target()
    local char = players.LocalPlayer.Character
    local head = char and char:FindFirstChild("Head")
    if v and head then return CFrame.new(head.Position, v) end
end
pcall(function()
    local oldrender
    oldrender = hookfunction(camera.GetRenderCFrame, function(self, ...) return aimcframe() or oldrender(self, ...) end)
    local oldscreen
    oldscreen = hookfunction(camera.ScreenPointToRay, function(self, ...)
        local v = aimcframe()
        if v then return Ray.new(v.Position, v.LookVector) end
        return oldscreen(self, ...)
    end)
    local oldviewport
    oldviewport = hookfunction(camera.ViewportPointToRay, function(self, ...)
        local v = aimcframe()
        if v then return Ray.new(v.Position, v.LookVector) end
        return oldviewport(self, ...)
    end)
    local cameradata = registry:GetSharedTable("CameraData")
    local history = cameradata.CameraHistory
    local meta = getrawmetatable(cameradata)
    local oldnewindex
    oldnewindex = hookfunction(meta.__newindex, newcclosure(function(tab, key, value)
        local current = tab == cameradata and key == "CameraCFrame"
        local previous = history ~= nil and tab == history and type(key) == "number"
        local aimed = aimcframe()
        if aimed and (current or previous) then return oldnewindex(tab, key, aimed) end
        return oldnewindex(tab, key, value)
    end))
end)
]==]

do
    function hookmain()
        pcall(function()
            state.actorname = "sa" .. tostring(math.floor(os.clock() * 100000)) .. tostring(math.random(10000, 99999))
            state.actorst = SharedTableRegistry:GetSharedTable(state.actorname)
            state.actorst.t = nil

            local cameradata = SharedTableRegistry:GetSharedTable("CameraData")
            local history = cameradata.CameraHistory
            local meta = getrawmetatable(cameradata)

            state.oldnewindex = hookfunction(meta.__newindex, newcclosure(function(tab, key, value)
                local current  = tab == cameradata and key == "CameraCFrame"
                local previous = history ~= nil and tab == history and type(key) == "number"
                local tgt = state.target
                if tgt and (current or previous) and typeof(value) == "CFrame" then
                    local char = LocalPlayer.Character
                    local head = char and char:FindFirstChild("Head")
                    if head then
                        return state.oldnewindex(tab, key, CFrame.new(head.Position, tgt))
                    end
                end
                return state.oldnewindex(tab, key, value)
            end))
        end)
    end
end

function hookactors()
    if type(getactors) ~= "function" or type(run_on_actor) ~= "function" or not state.actorname then return end
    local ok, actors = pcall(getactors)
    if not ok or type(actors) ~= "table" then return end
    local code = "local __silentaimtable = " .. string.format("%q", state.actorname) .. " " .. actorcode
    for _, actor in actors do
        if not state.actors[actor] then
            if pcall(run_on_actor, actor, code) then
                state.actors[actor] = true
            end
        end
    end
end

do
    s.Release = s.Release or {
        Perfect = false,
        AutoCalibrate = false,
        PrecisionSpin = true,
        PingCompensation = true,
        Base = 0.3195,        -- seconds from takeoff to the perfect release at ~0 ping
        MinDelay = 0.205,
        MaxDelay = 0.360,
        MaxPing = 300,
        PingAdaptive = false,
        PingBaseline = 60,    -- ms treated as normal
        PingStrength = 1,
        PingMaxLead = 250,    -- ms, cap on how much earlier ping may move the release
    }
    local R = s.Release
    local FILE = "Aural_Release.json"

    local OFFSETS = {
        0, 0.005, -0.005, 0.010, -0.010, 0.015, -0.015, 0.020, -0.020,
        0.026, -0.026, 0.032, -0.032, 0.040, -0.040,
    }

    local rt = {
        CalibratedBase = nil, Pending = nil, OffsetIndex = 1, Locked = false, Misses = 0,
        Samples = {}, Hits = 0, Attempts = 0, Streak = 0, BestStreak = 0, LastResult = "IDLE",
        PingSamples = {}, PingAverage = 0, PingSampledAt = 0,
    }

    local function getBase() return rt.CalibratedBase or R.Base end

    local function saveCalibration()
        if type(writefile) ~= "function" or not rt.CalibratedBase then return end
        pcall(function()
            writefile(FILE, HttpService:JSONEncode({ Base = rt.CalibratedBase, Hits = rt.Hits, Attempts = rt.Attempts }))
        end)
    end

    pcall(function()
        if type(readfile) ~= "function" or type(isfile) ~= "function" or not isfile(FILE) then return end
        local data = HttpService:JSONDecode(readfile(FILE))
        local base = tonumber(data and data.Base)
        if base and base >= 0.15 and base <= 0.45 then
            rt.CalibratedBase = base
            rt.Locked = true
        end
    end)

    local function readPing()
        local ok, v = pcall(function() return dataping:GetValue() end)
        return ok and tonumber(v) or 0
    end

    local function samplePing(force)
        local now = os.clock()
        if not force and now - rt.PingSampledAt < 0.25 then return end
        rt.PingSampledAt = now
        local v = math.clamp(readPing(), 0, 2000)
        if v <= 0 then return end
        local t = rt.PingSamples
        t[#t + 1] = v
        if #t > 15 then table.remove(t, 1) end
        rt.PingAverage = (rt.PingAverage == 0) and v or (rt.PingAverage * 0.75 + v * 0.25)
    end

    J:Connect(RunService.Heartbeat, function()
        if R.Perfect or R.PingAdaptive then samplePing(false) end
    end, "ReleasePingSampler")

    local function medianPing()
        local t = rt.PingSamples
        if #t == 0 then return readPing() end
        local sorted = table.clone(t)
        table.sort(sorted)
        local mid = #sorted // 2 + 1
        if #sorted % 2 == 1 then return sorted[mid] end
        return (sorted[mid - 1] + sorted[mid]) * 0.5
    end

    function getAdaptiveLead()
        if not R.PingAdaptive then return 0 end
        if rt.PingAverage == 0 then samplePing(true) end
        local excess = (rt.PingAverage - (tonumber(R.PingBaseline) or 60)) / 1000
        if excess <= 0 then return 0 end
        local maxLead = math.max(0, (tonumber(R.PingMaxLead) or 250) / 1000)
        return math.clamp(excess * (tonumber(R.PingStrength) or 1), 0, maxLead)
    end

    function getReleaseDelay()
        local ping = math.clamp(medianPing(), 0, R.MaxPing)
        local oneWay = R.PingCompensation and ping / 2000 or 0
        local offset = 0
        if R.AutoCalibrate and not rt.Locked then offset = OFFSETS[rt.OffsetIndex] or 0 end
        local delay = getBase() + offset - oneWay - getAdaptiveLead()
        return math.clamp(delay, R.MinDelay, R.MaxDelay), ping, offset
    end

    function waitUntilRelease(releaseAt)
        local step = 1 / 60
        while os.clock() + step < releaseAt do
            if not state.active then return end
            step = math.clamp(RunService.Heartbeat:Wait(), 1 / 240, 1 / 15)
        end
        if R.PrecisionSpin then
            local deadline = os.clock() + 0.05
            while os.clock() < releaseAt and os.clock() < deadline do end
        end
    end

    local function resolve(wasPerfect)
        local pending = rt.Pending
        if not pending then return end
        rt.Pending = nil
        rt.Attempts += 1

        if wasPerfect then
            rt.Hits += 1
            rt.Misses = 0
            rt.Streak += 1
            if rt.Streak > rt.BestStreak then rt.BestStreak = rt.Streak end
            rt.LastResult = "PERFECT"
            if R.AutoCalibrate then
                local adopted = math.clamp(getBase() + (pending.Offset or 0), 0.15, 0.45)
                table.insert(rt.Samples, adopted)
                if #rt.Samples >= 5 then
                    table.sort(rt.Samples)
                    rt.CalibratedBase = rt.Samples[math.ceil(#rt.Samples / 2)]
                    rt.OffsetIndex = 1
                    rt.Locked = true
                    saveCalibration()
                end
            end
            return
        end

        rt.Streak = 0
        rt.Misses += 1
        rt.LastResult = "NOT PERFECT"
        if not R.AutoCalibrate then return end
        if rt.Misses >= 2 then
            rt.Locked = false
            rt.OffsetIndex = (rt.OffsetIndex % #OFFSETS) + 1
        end
    end

    function recordReleaseAttempt(delay, offset)
        local token = {}
        rt.Pending = { Delay = delay, Offset = offset or 0, At = os.clock(), Token = token }
        rt.LastResult = "WAITING"
        task.delay(1.35, function()
            if rt.Pending and rt.Pending.Token == token then resolve(false) end
        end)
    end

    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local perfectEvent = remotes and remotes:FindFirstChild("perfectEvent")
        if not perfectEvent then return end
        J:Connect(perfectEvent.OnClientEvent, function(shooter)
            if shooter == LocalPlayer then resolve(true) end
        end, "PerfectReleaseHook")
    end)

    function getReleaseStats()
        local acc = rt.Attempts > 0 and (rt.Hits / rt.Attempts * 100) or 0
        return {
            Streak = rt.Streak, Best = rt.BestStreak, Hits = rt.Hits, Attempts = rt.Attempts,
            Accuracy = acc, Base = getBase(), Last = rt.LastResult, Locked = rt.Locked,
            Ping = rt.PingAverage, Lead = getAdaptiveLead(),
        }
    end

    function resetReleaseCalibration()
        rt.CalibratedBase = nil
        rt.Locked = false
        rt.OffsetIndex = 1
        rt.Misses = 0
        table.clear(rt.Samples)
        rt.Hits, rt.Attempts, rt.Streak, rt.BestStreak = 0, 0, 0, 0
        rt.LastResult = "IDLE"
        if type(delfile) == "function" then pcall(delfile, FILE) end
    end
end

function setupCharacterAural(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if not hum then return end

    local jumps = 0
    local airborne = false
    local lastJumpRequest = 0
    local jumpSequenceExpires = 0

    addconnection(UserInputService.JumpRequest:Connect(function()
        local now = os.clock()
        if now - lastJumpRequest < 0.07 then return end
        lastJumpRequest = now

        airborne = true

        if not s.Shooting.AuralEnabled then return end
        if s.Shooting.AuralTrigger == "Click" then return end -- Click mode: you shoot, the aim follows
if s.Shooting.ArmInMatch and not IsInMatch() then return end
        if not hasball(char) then return end

        if s.Shooting.EBLHop then
            if now > jumpSequenceExpires then jumps = 0 end
            jumps += 1
            jumpSequenceExpires = now + 1.5
            if jumps < 2 then return end
            jumps = 0
            jumpSequenceExpires = 0
        else
            jumps = 0
            jumpSequenceExpires = 0
        end

        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local goal, distance = nearestgoal(root)
local minDist = isMobile and 30 or AURAL_MIN_DIST

local tableArc, tablePower = getTableShot(distance)
if not goal or distance < minDist or (distance > AURAL_MAX_DIST and not tablePower) then return end

local arc = getAuralShotArc(distance, tableArc, tablePower) + s.Shooting.ShotYAxis

-- Bank shot: aim at the mirrored rim across the backboard plane,
-- and re-solve the arc using the mirrored distance.
local aimBase = goal.Position
if s.Shooting.BankShots then
    local mirror = getgenv().AuralBackboard.ResolveAimPoint(goal)
    if mirror then
        aimBase = mirror
        local d = mirror - root.Position
        local mirrorDist = Vector3.new(d.X, 0, d.Z).Magnitude
        local mirrorArc, mirrorPower = getTableShot(mirrorDist)
        if mirrorArc or mirrorPower then
            tableArc, tablePower = mirrorArc, mirrorPower
            arc = getAuralShotArc(mirrorDist, mirrorArc, mirrorPower) + s.Shooting.ShotYAxis
        end
    end
end

local targetPos = nil

        if s.Shooting.HumanizeAim then
            local strength = s.Shooting.HumanizeStrength or 1.2
            local missChance = (s.Shooting.MissChance or 12) / 100

            if math.random() < missChance then
                local mode = math.random(1, 3)
                if mode == 1 then
                    arc += strength * 3 + math.random() * strength * 2
                elseif mode == 2 then
                    arc -= strength * 3 + math.random() * strength * 2
                else
                    local side = (math.random() < 0.5) and -1 or 1
                    targetPos = aimBase
    				+ Vector3.new(0, (tableArc or getArcOffset(distance)) + s.Shooting.ShotYAxis, 0)
    				+ Camera.CFrame.RightVector * (side * (strength * 2 + math.random() * 2))
                end
            else
                arc += (math.random() * 2 - 1) * strength
            end
        end

        targetPos = targetPos or aimBase + Vector3.new(0, arc, 0)

        settarget(targetPos)

        local rel = s.Release
        local perfect = rel and rel.Perfect
        local takeoffAt = os.clock()
        if perfect then
            local giveUp = takeoffAt + 0.12
            while os.clock() < giveUp and root.AssemblyLinearVelocity.Y <= 3 do
                RunService.Heartbeat:Wait()
            end
            takeoffAt = os.clock()
        else
            task.wait(0.05)
        end

        if tablePower and setpower then
            setpower(tablePower)
        else
            LocalPlayer:SetAttribute("Power", 85)
        end

        local shotdelay = s.Shooting.ShotDelay or 0.25

        if s.Shooting.RandomizeShotDelay then
            local mn = s.Shooting.ShotDelayMin or 0.15
            local mx = s.Shooting.ShotDelayMax or 0.35
            if mx < mn then mx = mn end
            shotdelay = mn + math.random() * (mx - mn)
        end

        if perfect then
            local clientDelay, _, offset = getReleaseDelay()
            waitUntilRelease(takeoffAt + clientDelay)
            if not (state.active and s.Shooting.AuralEnabled and hasball(char)) then return end
            recordReleaseAttempt(clientDelay, offset)
        else
            task.wait(math.max(0, shotdelay - getAdaptiveLead()))
        end
        if s.Shooting.AuralAimAssist and not auralLookOk(goal) then
            settarget(nil)
            return
        end
        doClick()
        task.wait(0.1)
        updateAuralTarget()
    end))

    addconnection(hum.StateChanged:Connect(function(_, st2)
        if st2 == Enum.HumanoidStateType.Landed
            or st2 == Enum.HumanoidStateType.Running then
            airborne = false
        end
    end))
end

if LocalPlayer.Character then setupCharacterAural(LocalPlayer.Character) end
addconnection(LocalPlayer.CharacterAdded:Connect(setupCharacterAural))

hookmain()
hookactors()

addconnection(workspace.DescendantAdded:Connect(function(object)
    if validgoal(object) then table.insert(goals, object) end
end))

addconnection(UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        state.lastClick = os.clock()
    end
end))
addconnection(RunService.Heartbeat:Connect(updateAuralTarget))
addconnection(Players.PlayerAdded:Connect(function() task.defer(hookactors) end))

env2.__standalone_silent_aim_settings = {enabled = true, requireball = true}

env2.__standalone_silent_aim_unload = function()
    state.active = false
    settarget(nil)
    for _, c in state.connections do pcall(function() c:Disconnect() end) end
    table.clear(state.connections)
    s.SelfPass.Enabled = false
    disableAutoDime()
    disableQuickPass()
    env2.__standalone_silent_aim_settings = nil
    env2.__standalone_silent_aim_unload = nil
end

local fatalState = {
    shooting = false, cachedrim = nil, cacheddist = math.huge,
    lastjumpshot = 0, groundy = nil, lastvelY = 0, peakfiring = false, renderConnection = nil,
    inRange = false,
}

do
    local powerData
    local function writeSharedPower(p)
        if not powerData then powerData = SharedTableRegistry:GetSharedTable("PowerData") end
        if powerData.Power ~= p then powerData.Power = p end
    end
    local function writeAttrPower(p)
        if LocalPlayer:GetAttribute("Power") ~= p then LocalPlayer:SetAttribute("Power", p) end
    end
    setpower = function(p)
        pcall(writeAttrPower, p)
        pcall(writeSharedPower, p)
    end

    function screencenter()
        local sc = Camera.ViewportSize
        return sc.X / 2, sc.Y / 2
    end
end

do
    fatalClick = function(targetPos)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetPos then return false end

        local origcf = Camera.CFrame
        local origct = Camera.CameraType
        local origmb = UserInputService.MouseBehavior

        getgenv().__aural_aiming = true

        local ok, err = pcall(function()
            Camera.CameraType = Enum.CameraType.Scriptable
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
            Camera.CFrame = CFrame.lookAt(hrp.Position, targetPos)
            RunService.RenderStepped:Wait()

            if isMobile then
                local pos2
                if Icon then
                    pos2 = Vector2.new(Icon.AbsolutePosition.X + Icon.AbsoluteSize.X / 2, Icon.AbsolutePosition.Y + Icon.AbsoluteSize.Y / 2)
                else
                    pos2 = IconCenter or Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                end
                Input:SendTouchEvent(1, 0, pos2.X, pos2.Y)
                Input:SendTouchEvent(1, 2, pos2.X, pos2.Y)
            else
                local vp = Camera.ViewportSize
                Input:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, true, game, 1)
                RunService.RenderStepped:Wait()
                Input:SendMouseButtonEvent(vp.X / 2, vp.Y / 2, 0, false, game, 1)
            end
        end)

        Camera.CFrame = origcf
        Camera.CameraType = origct
        if origmb ~= Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = origmb
        end

        task.defer(function()
            task.wait()
            getgenv().__aural_aiming = false
            pcall(restoreMouseBehavior)
        end)

        if not ok then warn("[fatalClick] " .. tostring(err)) end
        return ok
    end
end

local rimsCache = {}

do
    function buildrims()
        rimsCache = {}
        for _, desc in workspace:GetDescendants() do
            if desc:IsA("BasePart") and (desc.Name == "Goal" or desc.Name == "Rim") then
                table.insert(rimsCache, desc)
            end
        end
    end
    buildrims()

    nearestrim = function(pos)
        local best, bestd = nil, math.huge
        for _, rim in rimsCache do
            if rim and rim.Parent then
                local Hitboxes = rim.Parent
                if Hitboxes and (Hitboxes.Name == "HitboxesHome" or Hitboxes.Name == "HitboxesAway") then
                    local MyTeam = getMyTeamOnCourt(Hitboxes.Parent)
                    if MyTeam then
                        if (MyTeam == "Home" and Hitboxes.Name == "HitboxesHome") or
                           (MyTeam == "Away" and Hitboxes.Name == "HitboxesAway") then
                            continue
                        end
                    end
                end

                local d = (rim.Position - pos).Magnitude
                if d < bestd then bestd = d; best = rim end
            end
        end
        return best, bestd
    end

    function flickshot_fatal()
        if fatalState.shooting then return end
        fatalState.shooting = true
        local char = LocalPlayer.Character
        if not char then fatalState.shooting = false; return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then fatalState.shooting = false; return end
        local rim, dist = fatalState.cachedrim, fatalState.cacheddist
        if not rim then fatalState.shooting = false; return end
        local selectedPower = 85
        local maxDist = FATAL_MAX_DIST_85
        local tableArc, tablePower = getTableShot(flatDistTo(rim, hrp.Position))
        if tablePower then selectedPower = tablePower; maxDist = math.huge end
        if dist < FATAL_MIN_DIST or dist > maxDist then fatalState.shooting = false; return end
        local arc = getAuralShotArc(dist, tableArc, tablePower)
        if dist < 59 then
            local toRim = (rim.Position - hrp.Position).Unit
            local velocityTowardRim = hrp.AssemblyLinearVelocity:Dot(toRim)
            if velocityTowardRim > 0 then arc = arc - (velocityTowardRim * 0.18) end
            if velocityTowardRim < -1 then arc = arc + 5 end
        end
        local GreenComp = Vector3.new(0, 0, 0)
        local sidewaysComp = Vector3.new(0, 0, 0)
        if math.random(1, 100) <= s.Shooting.GreenChance then
            GreenComp = Vector3.new(0, 4.05, 0)
        else
            GreenComp = Vector3.new(0, -1.14, 0)
            if math.random(0, 1) == 0 then sidewaysComp = Camera.CFrame.RightVector * -0.2
            else sidewaysComp = Camera.CFrame.RightVector * 0.2 end
        end
        local compensation = hrp.AssemblyLinearVelocity * (dist / 50) * 0.05
        local aimTarget = rim.Position + Vector3.new(0, arc, 0) + Vector3.new(0, 0.95, 0) + GreenComp + compensation + sidewaysComp
        local origcf = Camera.CFrame
        local origct = Camera.CameraType
        local origmb = UserInputService.MouseBehavior
        setpower(selectedPower)
        local cx, cy = screencenter()
        getgenv().__aural_aiming = true
        Camera.CameraType = Enum.CameraType.Scriptable
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        Camera.CFrame = CFrame.lookAt(hrp.Position, aimTarget)
        Input:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
        RunService.RenderStepped:Wait()
        Input:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        Camera.CFrame = origcf
        Camera.CameraType = origct
        if origmb ~= Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior = origmb
        end
        task.defer(function()
            task.wait()
            getgenv().__aural_aiming = false
            pcall(restoreMouseBehavior)
        end)
        fatalState.shooting = false
    end

    function fatalRenderLoop()
        if not s.Shooting.FatalEnabled then
            fatalState.inRange = false
            return
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            fatalState.cachedrim, fatalState.cacheddist = nil, math.huge
            fatalState.lastvelY = 0
            fatalState.inRange = false
            return
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local airborne = humanoid and (humanoid:GetState() == Enum.HumanoidStateType.Freefall or humanoid:GetState() == Enum.HumanoidStateType.Jumping)
        if not airborne then fatalState.groundy = hrp.Position.Y end
        local rim, dist = nearestrim(hrp.Position)
        fatalState.cachedrim, fatalState.cacheddist = rim, dist
        if not rim then
            fatalState.lastvelY = hrp.AssemblyLinearVelocity.Y
            fatalState.inRange = false
            return
        end
        if hasball(char) and not getgenv().__aural_passOverride then
        local _, tablePower = getTableShot(flatDistTo(rim, hrp.Position))
        if tablePower then setpower(tablePower) end
        end
        local selectedPower = 85
        local maxDist = FATAL_MAX_DIST_85
        local _, maxTablePower = getTableShot(flatDistTo(rim, hrp.Position))
        if maxTablePower then maxDist = math.huge end
        local inRange = (dist >= FATAL_MIN_DIST) and (dist <= maxDist)
        fatalState.inRange = inRange
        if not inRange then
            fatalState.lastvelY = hrp.AssemblyLinearVelocity.Y
            return
        end
        if s.Shooting.ThreesOnly and dist < 55 then fatalState.lastvelY = hrp.AssemblyLinearVelocity.Y; return end
        local velY = hrp.AssemblyLinearVelocity.Y
        if not fatalState.shooting then
            local atPeak = airborne and fatalState.lastvelY > 0 and velY <= 0
            if atPeak and s.Shooting.AimAssist then fatalState.assistUntil = os.clock() + 0.15 end
            local pending = airborne and fatalState.assistUntil ~= nil and os.clock() <= fatalState.assistUntil
            if (atPeak or pending) and not fatalState.peakfiring and hasball(char) and (os.clock() - fatalState.lastjumpshot) > 0.5 then
                local lookOk = true
                if s.Shooting.AimAssist then
                    local camCF = Camera.CFrame
                    local wanted = (rim.Position - camCF.Position).Unit.Y
                    lookOk = camCF.LookVector.Y >= math.min(0.3, wanted - 0.12)
                end
                if lookOk then
                    fatalState.assistUntil = nil
                    fatalState.peakfiring = true
                    fatalState.lastjumpshot = os.clock()
                    task.spawn(function() flickshot_fatal(); fatalState.peakfiring = false end)
                end
            end
            if not airborne then fatalState.peakfiring = false; fatalState.assistUntil = nil end
        end
        fatalState.lastvelY = velY
    end

    function enableFatal()
        if fatalState.renderConnection then return end
        fatalState.renderConnection = RunService.Heartbeat:Connect(fatalRenderLoop)
    end

    function disableFatal()
        if fatalState.renderConnection then fatalState.renderConnection:Disconnect(); fatalState.renderConnection = nil end
        fatalState.shooting = false
        fatalState.inRange = false
    end
end

local guardConnection = nil
local speedConnection = nil

do
    function enableAutoGuard()
        if guardConnection then guardConnection:Disconnect(); guardConnection = nil end
        local frameSkip = 0
        guardConnection = RunService.Stepped:Connect(function()
            if not s.Defending.AutoGuard then return end
if s.Defending.OnlyGuardInMatch and not IsInMatch() then return end
            frameSkip += 1
            if frameSkip < 3 then return end
            frameSkip = 0
            local char = LocalPlayer.Character
            local myHum = char and char:FindFirstChild("Humanoid")
            if not myHum or hasball(char) then return end

            local mode = tostring(s.Defending.AutoGuardMode or "Prediction"):lower()
            local closestDribbler = getClosestDribbler()
            if closestDribbler then
                local guardPos = nil
                if mode == "legit" then
                    guardPos = getNearestGuardPosition(closestDribbler)
                elseif mode == "blatant" then
                    guardPos = getGuardPosition(closestDribbler)
                    if guardPos and (closestDribbler.Character and closestDribbler.Character:FindFirstChild("HumanoidRootPart")) then
                        local targetRoot = closestDribbler.Character.HumanoidRootPart
                        local myRoot = char:FindFirstChild("HumanoidRootPart")
                        if myRoot and (targetRoot.Position - myRoot.Position).Magnitude < 18 then
                            guardPos = targetRoot.Position + (targetRoot.CFrame.LookVector * Vector3.new(1, 0, 1)).Unit * 3
                        end
                    end
                else
                    guardPos = getGuardPosition(closestDribbler)
                end
                if guardPos then myHum:MoveTo(guardPos) end
                return
            end
            if s.Defending.AutoGuardNearest then
                local nearest = getClosestPlayer()
                if nearest then
                    local guardPos = nil
                    if mode == "legit" then
                        guardPos = getNearestGuardPosition(nearest)
                    elseif mode == "blatant" then
                        guardPos = getNearestGuardPosition(nearest)
                        if guardPos then
                            local myRoot = char:FindFirstChild("HumanoidRootPart")
                            if myRoot then
                                local targetRoot = nearest.Character and nearest.Character:FindFirstChild("HumanoidRootPart")
                                if targetRoot and (targetRoot.Position - myRoot.Position).Magnitude < 20 then
                                    guardPos = targetRoot.Position + targetRoot.CFrame.LookVector * 4
                                end
                            end
                        end
                    else
                        guardPos = getNearestGuardPosition(nearest)
                    end
                    if guardPos then myHum:MoveTo(guardPos) end
                end
            end
        end)
    end

    function disableAutoGuard()
    if guardConnection then guardConnection:Disconnect(); guardConnection = nil end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if hum and root then
        hum:MoveTo(root.Position)
    end
end

    function enableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
        speedConnection = RunService.Heartbeat:Connect(function()
            if not s.Player.Walkspeed then return end
            local character = LocalPlayer.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end

            local moveDir = humanoid.MoveDirection
            if moveDir.Magnitude > 0.05 then
                local multiplier = math.clamp(s.Player.WSvalue or 1.35, 1, 2.5)
                local targetSpeed = 16 * multiplier
                local currentY = hrp.AssemblyLinearVelocity.Y
                local targetVel = moveDir.Unit * targetSpeed
                hrp.AssemblyLinearVelocity = Vector3.new(targetVel.X, currentY, targetVel.Z)
            end
        end)
    end

    function disableSpeedBoost()
        if speedConnection then speedConnection:Disconnect(); speedConnection = nil end
    end
end

function performSelfPass()
    local char = LocalPlayer.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    if not hrp or not hum then return end
    if not char:FindFirstChild("Basketball") then
        for _ = 1, 6 do task.wait(0.05); if char:FindFirstChild("Basketball") then break end end
        if not char:FindFirstChild("Basketball") then return end
    end

    local moveDir = hum.MoveDirection
    local aimDirection

    if moveDir.Magnitude < 0.1 then
        aimDirection = Vector3.new(0, 1, 0)
    else
        moveDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
        local upAngle = math.rad(s.SelfPass.Angle or 170)
        aimDirection = (moveDir * math.cos(upAngle - math.rad(90))) + Vector3.new(0, math.sin(upAngle - math.rad(90)), 0)
    end

    local aimPoint = hrp.Position + aimDirection.Unit * (s.SelfPass.Distance or 50)

    if setpower then setpower(s.SelfPass.Power or 85) end

    getgenv().__aural_passOverride = true
    settarget(aimPoint)
    task.wait(0.05)
    doClick()
    task.wait(0.25)
    settarget(nil)
    getgenv().__aural_passOverride = false
end

if s.Defending.AutoGuard then enableAutoGuard() end
if s.Player.Walkspeed then enableSpeedBoost() end
if s.Ball.BallMags then enableMagnet() end
if s.AutoDime.Enabled then
    enableAutoDime()
    setupQuickPass()
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local magKey = s.Ball.MagnetKeybind
    if magKey and input.KeyCode == Enum.KeyCode[magKey] then
        s.Ball.BallMags = not s.Ball.BallMags
        if s.Ball.BallMags then enableMagnet() else disableMagnet() end
        pcall(function()
            if uiToggles and uiToggles.magnet then uiToggles.magnet:Set(s.Ball.BallMags) end
        end)
        return
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end

    local bind = s.Shooting.AuralKeybind
    local targetKey = (type(bind) == "string") and Enum.KeyCode[bind] or bind
    if input.KeyCode ~= targetKey then return end

    if not s.Shooting.AuralEnabled then
        s.Shooting.AuralEnabled = false
        if s.Shooting.Mode == "Aural" then s.Shooting.Mode = "Fatal" end
    else
        s.Shooting.AuralEnabled = true
        s.Shooting.FatalEnabled = false
        s.Shooting.Mode = "Aural"
        disableFatal()
    end

    if uiToggles and uiToggles.aural then
        pcall(function() uiToggles.aural:Set(s.Shooting.AuralEnabled) end)
    end
end)

do
    function SpoofDevice()
        if not s.Misc.DeviceSpoofer then return end
        local device = s.Misc.Device
        if device == "PC" then DeviceEvent:FireServer("Desktop")
        elseif device == "Mobile" then DeviceEvent:FireServer("Mobile")
        elseif device == "Gamepad" then DeviceEvent:FireServer("Gamepad") end
    end

    local TRAJ_SEGMENTS   = 200
    local TRAJ_WIDTH      = 0.35
    local TRAJ_ONLY_MINE  = false
    local trajShots       = {}

    function clearTrajectories()
        for cleanup in pairs(trajShots) do
            pcall(cleanup)
        end
    end

    local function safeUnit(v, fallback)
        if v.Magnitude < 1e-4 then return fallback end
        return v.Unit
    end

    local function safeCross(a, b)
        local c = a:Cross(b)
        if c.Magnitude < 1e-3 then
            local alt = math.abs(a.Unit.Y) < 0.9 and Vector3.yAxis or Vector3.xAxis
            c = a:Cross(alt)
        end
        return c.Unit
    end

    function beamProjectile(g, v0, x0, t1)
        local c = 0.125
        local p3 = 0.5 * g * t1 * t1 + v0 * t1 + x0
        local p2 = p3 - (g * t1 * t1 + v0 * t1) / 3
        local p1 = (c * g * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2

        local curve0 = (p1 - x0).Magnitude
        local curve1 = (p2 - p3).Magnitude

        local b  = safeUnit(x0 - p3, Vector3.yAxis)
        local r1 = safeUnit(p1 - x0, Vector3.yAxis)
        local u1 = safeCross(r1, b)
        local r2 = safeUnit(p2 - p3, -Vector3.yAxis)
        local u2 = safeCross(r2, b)
        b = u1:Cross(r1).Unit

        local cf1 = CFrame.new(x0.X, x0.Y, x0.Z, r1.X, u1.X, b.X, r1.Y, u1.Y, b.Y, r1.Z, u1.Z, b.Z)
        local cf2 = CFrame.new(p3.X, p3.Y, p3.Z, r2.X, u2.X, b.X, r2.Y, u2.Y, b.Y, r2.Z, u2.Z, b.Z)
        return curve0, -curve1, cf1, cf2
    end

    local function drawTrajectory(model, ball)
        local t0 = os.clock()
        while ball.Parent == model
            and ball.AssemblyLinearVelocity.Magnitude < 5
            and os.clock() - t0 < 0.5 do
            task.wait()
        end
        if ball.Parent ~= model or ball.AssemblyLinearVelocity.Magnitude < 5 then return end
        if not getgenv().Settings.Visuals.VisualizeBallProjectory then return end

        local v1 = ball.AssemblyLinearVelocity
        local tA = os.clock()
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        if ball.Parent ~= model then return end

        local dt   = os.clock() - tA
        local vel  = ball.AssemblyLinearVelocity
        local pos  = ball.Position
        local grav = workspace.Gravity
        if dt > 0.005 then
            local measured = (v1.Y - vel.Y) / dt
            if measured > grav * 0.5 and measured < grav * 1.5 then
                grav = measured
            end
        end

        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.FilterDescendantsInstances = { model, LocalPlayer.Character }
        local hit = workspace:Raycast(pos, Vector3.new(0, -500, 0), rp)
        local floorY = hit and (hit.Position.Y + 1) or (pos.Y - 15)

        local h = pos.Y - floorY
        local t1 = (vel.Y + math.sqrt(math.max(0, vel.Y * vel.Y + 2 * grav * h))) / grav
        t1 = math.clamp(t1, 0.2, 6)

        local g = Vector3.new(0, -grav, 0)
        local c0, c1, cf1, cf2 = beamProjectile(g, vel, pos, t1)
        if c0 ~= c0 or c1 ~= c1 then return end

        local beam = Instance.new("Beam")
        local a0 = Instance.new("Attachment")
        local a1 = Instance.new("Attachment")

        beam.Name = "Trajectory"
        beam.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.02, 0.15),
            NumberSequenceKeypoint.new(0.95, 0.15),
            NumberSequenceKeypoint.new(1, 1),
        })
        beam.CurveSize0 = c0
        beam.CurveSize1 = c1
        beam.Segments = TRAJ_SEGMENTS
        beam.Width0 = TRAJ_WIDTH
        beam.Width1 = TRAJ_WIDTH
        beam.FaceCamera = true
        beam.LightEmission = 1
        beam.LightInfluence = 0

        a0.Parent = workspace.Terrain
        a1.Parent = workspace.Terrain
        a0.WorldCFrame = cf1
        a1.WorldCFrame = cf2
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Parent = workspace.Terrain

        local alive = true
        local anim, watcher
        local chosen = TrajColors[s.Visuals.ProjectoryColor]
        if chosen then
            beam.Color = ColorSequence.new(chosen)
        else
            local t = 0
            anim = RunService.Heartbeat:Connect(function(step)
                if not alive then return end
                t += step
                local hue = (t * 0.25) % 1
                beam.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.15) % 1, 1, 1)),
                })
            end)
        end

        local function cleanup()
            if not alive then return end
            alive = false
            trajShots[cleanup] = nil
            if anim then anim:Disconnect() end
            if watcher then watcher:Disconnect() end
            beam:Destroy(); a0:Destroy(); a1:Destroy()
        end
        trajShots[cleanup] = true

        watcher = RunService.Heartbeat:Connect(function()
            if ball.Parent ~= model then cleanup() end
        end)
        task.delay(t1 + 1, cleanup)
    end

    J:Connect(workspace.ChildAdded, function(b)
        if b.Name ~= "Basketball" then return end

        local ball = b:WaitForChild("Ball", 2)
        if not ball or not ball:IsA("BasePart") then return end

        if getgenv().Settings.Visuals.VisualizeBallProjectory then
            local allowed = true
            if TRAJ_ONLY_MINE then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                allowed = hrp ~= nil and (hrp.Position - ball.Position).Magnitude < 20
            end
            if allowed then
                task.spawn(function()
                    local ok, err = pcall(drawTrajectory, b, ball)
                    if not ok then warn("[Trajectory] " .. tostring(err)) end
                end)
            end
        end

    end, "BasketballWorldAdded")

    if s.TrailChanger.Enabled then
        J:Delay(0.5, applyTrailToAllBalls)
    end
end

local passLock = false

function fireViaSilentAim(aimPoint, power)
    if passLock then return false end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not aimPoint then return false end
    passLock = true
    if power and setpower then setpower(power) end
    local prevEnabled = s.Shooting.AuralEnabled
    s.Shooting.AuralEnabled = true
    settarget(aimPoint)
    task.wait(0.05)
    doClick()
    task.wait(0.15)
    if not prevEnabled then settarget(nil) end
    s.Shooting.AuralEnabled = prevEnabled
    passLock = false
    return true
end
fireMobileSelfPass = function()
    local char = LocalPlayer.Character
    if not char then return false end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")

    if not hrp or not hum then return false end
    if not hasball(char) then
        for _ = 1, 6 do task.wait(0.05); if hasball(char) then break end end
        if not hasball(char) then return false end
    end

    local moveDir = hum.MoveDirection
    local aimDirection

    if moveDir.Magnitude < 0.1 then
        aimDirection = Vector3.new(0, 1, 0)
    else
        moveDir = Vector3.new(moveDir.X, 0, moveDir.Z).Unit
        local upAngle = math.rad(s.SelfPass.Angle or 170)
        aimDirection = (moveDir * math.cos(upAngle - math.rad(90))) + Vector3.new(0, math.sin(upAngle - math.rad(90)), 0)
    end

    local aimPoint = hrp.Position + aimDirection.Unit * (s.SelfPass.Distance or 50)

    if setpower then setpower(s.SelfPass.Power or 85) end

    task.spawn(function()
        getgenv().__aural_passOverride = true
        settarget(aimPoint)
        task.wait(0.05)
        doClick()
        task.wait(0.25)
        settarget(nil)
        getgenv().__aural_passOverride = false
    end)

    return true
end

local arrayListGui, arrayListContainer, arrayListEntries, arrayListAccent
do
    local TweenServiceRef = game:GetService("TweenService")
    local RunServiceRef = game:GetService("RunService")
    arrayListAccent = Color3.fromRGB(179, 165, 255)
    arrayListEntries = {}
    local arrayWaveConnection = nil
    local TEXT_SIZE = 18
    local ENTRY_HEIGHT = 26
    local BAR_WIDTH = 3
    local textWidthCache = {}

    local arrayModules = {
        { "Silent Aim",       function() return s.Shooting.AuralEnabled or s.Shooting.FatalEnabled end },
        { "Perfect Release",  function() return s.Release and s.Release.Perfect end },
        { "Humanize Aim",     function() return s.Shooting.HumanizeAim end },
        { "Aim Assist",       function() return s.Shooting.AimAssist end },
        { "EBL Hop",          function() return s.Shooting.EBLHop end },
        { "High Arc",         function() return s.Shooting.ThreesOnly end },
        { "Self Pass",        function() return s.SelfPass.Enabled end },
        { "Auto Dime",        function() return s.AutoDime.Enabled end },
        { "Auto Guard",       function() return s.Defending.AutoGuard end },
        { "Head Ride",        function() return s.HeadRide.Enabled end },
        { "Auto Queue",       function() return s.Automatics.AutoQueue end },
        { "Auto Dunk",        function() return s.Automatics.AutoDunk end },
        { "Ball Magnet",      function() return s.Ball.BallMags end },
        { "Ball Reach",       function() return s.Ball.BallReach end },
        { "Walk Speed",       function() return s.Player.Walkspeed end },
        { "Ball Trajectory",  function() return s.Visuals.VisualizeBallProjectory end },
        { "Shot Indicator",   function() return s.Visuals.ShotIndicator end },
        { "Show Ranks",       function() return s.Visuals.ShowHiddenRanks end },
        { "Hide Tags",        function() return s.Visuals.HidePlayerTags end },
        { "Hoop Distance",    function() return s.Visuals.HoopDistance end },
        { "Custom Name",      function() return s.Visuals.CustomName end },
        { "Custom Record",    function() return s.Visuals.CustomRecord end },
        { "Custom Title",     function() return s.Visuals.CustomTitle end },
        { "Custom Rank",      function() return s.Visuals.CustomRank end},
        { "Goal Effect",      function() return s.Goal.Enabled end },
        { "Ball Changer",     function() return s.BallChanger.Enabled end },
        { "Trail Changer",    function() return s.TrailChanger.Enabled end },
        { "Aura",             function() return s.Aura.Enabled end },
        { "Anti Reach",       function() return s.AntiReach.Enabled end },
        { "Auto Mix",         function() return s.AutoMix.Enabled end },
        { "Ankles Reach",     function() return s.AnklesReach.Enabled end },
        { "FPS Cap",          function() return s.FPSCap.Enabled end },
        { "Anti Travel", function() return s.AntiTravelHook.Enabled end },
        { "Clan Tag",         function() return s.ClanTag.Enabled end },
        { "Chat Tag",         function() return s.ChatTag.Enabled end },
        { "Local Anonymizer", function() return s.LocalAnonymizer.Enabled end },
        { "Logo Badges",      function() return s.LogoBadges.VIP or s.LogoBadges.Youtuber or s.LogoBadges.Twitch or s.LogoBadges.Booster or s.LogoBadges.Tester or s.LogoBadges.Staff end },
        { "Wallet Spoof",     function() return s.WalletSpoof.Enabled end },
        { "Anti OOB",         function() return s.Misc.AntiOOB end },
        { "Anti Moderator",   function() return s.Misc.AntiModerator end },
        { "Anti Fall",        function() return s.Misc.AntiFall end },
        { "Server Position",  function() return s.Misc.ServerPosition end },
        { "Rep Calculator",   function() return s.Rep.ShowGui end },
    }

    local function getTextWidth(text, size)
    local key = text .. size
    if textWidthCache[key] then return textWidthCache[key] end
    local result
    local ok, err = pcall(function()
        local svc = game:GetService("TextService")
        local params = Instance.new("GetTextBoundsParams")
        params.Text = text
        params.Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold)
        params.Size = size
        params.Width = 9999
        result = svc:GetTextBoundsAsync(params).X
    end)
    if not ok or not result then
        result = #text * (size * 0.55)
    end
    textWidthCache[key] = result
    return result
end

    local function lerpColor(c1, c2, t)
        t = math.clamp(t, 0, 1)
        return Color3.new(
            c1.R + (c2.R - c1.R) * t,
            c1.G + (c2.G - c1.G) * t,
            c1.B + (c2.B - c1.B) * t
        )
    end

    local function getWaveT(index, totalActive, timeOffset)
        local phase = (index - 1) / math.max(totalActive, 1) * math.pi * 2
        local raw = math.sin(phase + timeOffset * 2.5)
        return (raw + 1) / 2
    end

    local function createArrayListGui()
        if arrayListGui then arrayListGui:Destroy() end

        arrayListGui = Instance.new("ScreenGui")
        arrayListGui.Name = "AuralArrayList"
        arrayListGui.ResetOnSpawn = false
        arrayListGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        arrayListGui.DisplayOrder = 998
        arrayListGui.IgnoreGuiInset = true
        arrayListGui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
        arrayListGui.Enabled = s.Visuals.ArrayList

        arrayListContainer = Instance.new("Frame")
        arrayListContainer.Name = "Container"
        arrayListContainer.Size = UDim2.new(0, 340, 1, 0)
        arrayListContainer.Position = UDim2.new(1, -340, 0, 0)
        arrayListContainer.BackgroundTransparency = 1
        arrayListContainer.Parent = arrayListGui

        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.Size = UDim2.new(1, 0, 0, 2)
        topBar.Position = UDim2.new(0, 0, 0, 0)
        topBar.BackgroundColor3 = arrayListAccent
        topBar.BorderSizePixel = 0
        topBar.ZIndex = 10
        topBar.Parent = arrayListContainer
    end

    local arrayEntryMap = {}
    local arrayEntryOrder = {}

    local function createEntry(name2, index)
        local textW = getTextWidth(name2, TEXT_SIZE)
        local entryWidth = textW + 28
        local yPos = 2 + (index - 1) * ENTRY_HEIGHT

        local entry = Instance.new("Frame")
        entry.Name = "Entry_" .. name2
        entry.Size = UDim2.new(0, entryWidth, 0, ENTRY_HEIGHT)
        entry.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
        entry.BackgroundTransparency = 0.3
        entry.BorderSizePixel = 0
        entry.ClipsDescendants = true
        entry.AnchorPoint = Vector2.new(1, 0)
        entry.Position = UDim2.new(1, 70, 0, yPos)
        entry.Parent = arrayListContainer

        local bar = Instance.new("Frame")
        bar.Name = "AccentBar"
        bar.Size = UDim2.new(0, BAR_WIDTH, 1, 0)
        bar.Position = UDim2.new(1, -BAR_WIDTH, 0, 0)
        bar.BorderSizePixel = 0
        bar.BackgroundColor3 = arrayListAccent
        bar.ZIndex = 5
        bar.Parent = entry

        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.Size = UDim2.new(1, -(BAR_WIDTH + 12), 1, 0)
        label.Position = UDim2.new(0, 8, 0, 0)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamBold
        label.TextSize = TEXT_SIZE
        label.TextColor3 = arrayListAccent
        label.TextXAlignment = Enum.TextXAlignment.Right
        label.TextTransparency = 0
        label.Text = name2
        label.ZIndex = 3
        label.Parent = entry

        local shadow = Instance.new("TextLabel")
        shadow.Name = "Shadow"
        shadow.Size = label.Size
        shadow.Position = UDim2.new(0, 9, 0, 1)
        shadow.BackgroundTransparency = 1
        shadow.Font = Enum.Font.GothamBold
        shadow.TextSize = TEXT_SIZE
        shadow.TextColor3 = Color3.fromRGB(0, 0, 0)
        shadow.TextTransparency = 0.55
        shadow.TextXAlignment = Enum.TextXAlignment.Right
        shadow.Text = name2
        shadow.ZIndex = 2
        shadow.Parent = entry

        local sep = Instance.new("Frame")
        sep.Name = "Sep"
        sep.Size = UDim2.new(1, 0, 0, 1)
        sep.Position = UDim2.new(0, 0, 1, -1)
        sep.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sep.BackgroundTransparency = 0.92
        sep.BorderSizePixel = 0
        sep.ZIndex = 4
        sep.Parent = entry

        arrayEntryMap[name2] = entry

        TweenServiceRef:Create(
            entry,
            TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
            {
                Position = UDim2.new(1, 0, 0, yPos)
            }
        ):Play()

        return entry
    end

    local removingEntries = {}

local function removeEntry(name2)
    if removingEntries[name2] then return end

    local entry = arrayEntryMap[name2]
    if not entry then return end

    removingEntries[name2] = true
    arrayEntryMap[name2] = nil

    TweenServiceRef:Create(
        entry,
        TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.In),
        {
            Position = UDim2.new(1, 70, 0, entry.Position.Y.Offset)
        }
    ):Play()

    task.delay(0.18, function()
        removingEntries[name2] = nil

        if entry and entry.Parent then
            entry:Destroy()
        end
    end)
end

    local function animateWave()
        if not arrayListContainer or not arrayListContainer.Parent then return end
        if not s.Visuals.ArrayList then return end

        local t = tick()
        local total = #arrayEntryOrder
        if total == 0 then return end

        for i, name2 in ipairs(arrayEntryOrder) do
            local entry = arrayEntryMap[name2]

            if entry and entry.Parent then
                local waveT = getWaveT(i, total, t)
                local color = lerpColor(
                    arrayListAccent,
                    Color3.fromRGB(255, 255, 255),
                    waveT
                )

                local bar = entry:FindFirstChild("AccentBar")
                if bar then
                    bar.BackgroundColor3 = color
                end

                local label = entry:FindFirstChild("Label")
                if label then
                    label.TextColor3 = color
                end
            end
        end

        local topBar = arrayListContainer:FindFirstChild("TopBar")

        if topBar then
            local topWave = (math.sin(t * 2.5) + 1) / 2

            topBar.BackgroundColor3 = lerpColor(
                arrayListAccent,
                Color3.fromRGB(255, 255, 255),
                topWave
            )
        end
    end

    function updateArrayList()
        if not arrayListGui or not arrayListContainer then return end

        if not s.Visuals.ArrayList then
            arrayListGui.Enabled = false
            return
        end

        arrayListGui.Enabled = true

        local active = {}
        local activeSet = {}

        for _, mod in ipairs(arrayModules) do
            local name2 = mod[1]
            local enabled = mod[2]()

            if enabled then
                active[#active + 1] = name2
                activeSet[name2] = true
            end
        end

        table.sort(active, function(a, b)
            return getTextWidth(a, TEXT_SIZE) > getTextWidth(b, TEXT_SIZE)
        end)

        for name2, entry in pairs(arrayEntryMap) do
            if not activeSet[name2] then
                removeEntry(name2)
            end
        end

        local changed = (#active ~= #arrayEntryOrder)
        if not changed then
            for i = 1, #active do
                if active[i] ~= arrayEntryOrder[i] then
                    changed = true
                    break
                end
            end
        end

        if not changed then return end

        arrayEntryOrder = active

        for i, name2 in ipairs(active) do
            local entry = arrayEntryMap[name2]
            local yPos = 2 + (i - 1) * ENTRY_HEIGHT

            if not entry or not entry.Parent then
    removingEntries[name2] = nil
    entry = createEntry(name2, i)
end

            local target = UDim2.new(1, 0, 0, yPos)

            if math.abs(entry.Position.Y.Offset - yPos) > 1 then
                TweenServiceRef:Create(
                    entry,
                    TweenInfo.new(
                        0.2,
                        Enum.EasingStyle.Quart,
                        Enum.EasingDirection.Out
                    ),
                    {
                        Position = target
                    }
                ):Play()
            else
                entry.Position = target
            end
        end
    end

    function setArrayListAccent(color)
        arrayListAccent = color

        for _, entry in pairs(arrayEntryMap) do
            local bar = entry:FindFirstChild("AccentBar")
            local label = entry:FindFirstChild("Label")

            if bar then
                bar.BackgroundColor3 = color
            end

            if label then
                label.TextColor3 = color
            end
        end
    end

    createArrayListGui()
    updateArrayList()

    local waveAcc = 0
    arrayWaveConnection = RunServiceRef.Heartbeat:Connect(function(dt)
        waveAcc = waveAcc + dt
        if waveAcc < 0.033 then return end
        waveAcc = 0
        if arrayListGui and arrayListGui.Parent and s.Visuals.ArrayList then
            animateWave()
        end
    end)

    local arrayListTask

arrayListTask = task.spawn(function()
    while arrayListGui and arrayListGui.Parent do
        pcall(updateArrayList)
        task.wait(0.2)
    end
end)
end

SpecWatch = {
    Active = false,
    CourtName = (s.Watch and s.Watch.Court == "Auto" and "Auto Live Match") or (s.Watch and s.Watch.Court) or "Auto Live Match",
    CourtSelection = "Auto Live Match",
    PlayerSummary = "--",
    Mode = (s.Watch and s.Watch.Mode) or "2K CAM",
    Status = "READY",
    Court = nil, Ball = nil,
    LastRefresh = 0, RosterAt = 0, BallAt = 0, BallCourt = nil,
    SavedCameraType = nil, SavedCameraSubject = nil, SavedFieldOfView = nil,
    CourtOptions = { "Auto Live Match" },
    CourtLookup = {}, LiveCourts = {}, LivePlayers = {},
    FrameCache = setmetatable({}, { __mode = "k" }),
    CachedCourt = nil, CachedParticipants = {},
    AppliedFilter = nil, FilterEffect = nil,
    IgnoredSlots = { Queue = true, Squad = true, Party = true },
    CameraModes = {
        "2K CAM", "2K REVERSED", "BROADCAST", "BROADCAST ZOOM", "BLIMP CAM",
        "DRONE CHASE", "SIDELINE LOW", "BASELINE HIGH", "ISOMETRIC", "TOP DOWN",
        "PLAYER FOCUS", "PLAYER SHOULDER", "PLAYER LEADING", "PLAYER LOW ANGLE", "PLAYER WIDE",
        "PLAYER DRONE", "DEFENDER VIEW", "FIRST PERSON EST", "KNEE CAM", "FOOTWORK CAM",
        "ORBIT CLOSE", "ORBIT WIDE", "ORBIT BIRDS EYE", "ORBIT FAST", "ORBIT SLOW",
        "PLAYER ORBIT", "PLAYER ORBIT WIDE", "ORBIT LOW", "ORBIT HIGH", "ORBIT ISOMETRIC",
        "CINEMATIC LOW", "CINEMATIC FAR", "DUTCH ACTION", "DUTCH REVERSE", "WORMS EYE",
        "CATWALK", "SNIPER CAM", "NOSEBLEEDS", "COURT CORNER", "VIP LOUNGE",
        "90s BROADCAST", "NOIR FILM", "SEPIA DRAMA", "CYBERPUNK", "VINTAGE POLAROID",
        "SECURITY CAM", "SUMMER VIBES", "COLD NIGHT", "GRIMY", "HIGH FANTASY",
    },
    Shots = {
        ["2K CAM"] = {Type="Ball", Offset=Vector3.new(0,12,25)},
        ["2K REVERSED"] = {Type="Ball", Offset=Vector3.new(0,12,-25)},
        ["BROADCAST"] = {Type="Ball", Offset=Vector3.new(40,15,0)},
        ["BROADCAST ZOOM"] = {Type="Ball", Offset=Vector3.new(25,8,0)},
        ["BLIMP CAM"] = {Type="Ball", Offset=Vector3.new(0,80,0)},
        ["DRONE CHASE"] = {Type="Ball", Offset=Vector3.new(0,18,18)},
        ["SIDELINE LOW"] = {Type="Ball", Offset=Vector3.new(25,3,0)},
        ["BASELINE HIGH"] = {Type="Ball", Offset=Vector3.new(0,25,45)},
        ["ISOMETRIC"] = {Type="Ball", Offset=Vector3.new(30,30,30)},
        ["TOP DOWN"] = {Type="Ball", Offset=Vector3.new(0,50,0.1)},
        ["PLAYER FOCUS"] = {Type="Player", Offset=Vector3.new(0,15,20)},
        ["PLAYER SHOULDER"] = {Type="Player", Offset=Vector3.new(3,2,5)},
        ["PLAYER LEADING"] = {Type="Player", Offset=Vector3.new(0,2,-15)},
        ["PLAYER LOW ANGLE"] = {Type="Player", Offset=Vector3.new(0,-2,8)},
        ["PLAYER WIDE"] = {Type="Player", Offset=Vector3.new(0,10,35)},
        ["PLAYER DRONE"] = {Type="Player", Offset=Vector3.new(0,25,0.1)},
        ["DEFENDER VIEW"] = {Type="Player", Offset=Vector3.new(0,5,-25)},
        ["FIRST PERSON EST"] = {Type="Player", Offset=Vector3.new(0,0.5,-1)},
        ["KNEE CAM"] = {Type="Player", Offset=Vector3.new(0,-1.5,6)},
        ["FOOTWORK CAM"] = {Type="Player", Offset=Vector3.new(0,-2.5,4)},
        ["ORBIT CLOSE"] = {Type="OrbitBall", Radius=15, Height=5, Speed=0.5},
        ["ORBIT WIDE"] = {Type="OrbitBall", Radius=40, Height=15, Speed=0.2},
        ["ORBIT BIRDS EYE"] = {Type="OrbitBall", Radius=30, Height=40, Speed=0.3},
        ["ORBIT FAST"] = {Type="OrbitBall", Radius=20, Height=8, Speed=1.2},
        ["ORBIT SLOW"] = {Type="OrbitBall", Radius=50, Height=25, Speed=0.1},
        ["PLAYER ORBIT"] = {Type="OrbitPlayer", Radius=12, Height=4, Speed=0.6},
        ["PLAYER ORBIT WIDE"] = {Type="OrbitPlayer", Radius=30, Height=10, Speed=0.3},
        ["ORBIT LOW"] = {Type="OrbitBall", Radius=25, Height=1, Speed=0.4},
        ["ORBIT HIGH"] = {Type="OrbitBall", Radius=20, Height=60, Speed=0.4},
        ["ORBIT ISOMETRIC"] = {Type="OrbitBall", Radius=35, Height=35, Speed=0.3},
        ["CINEMATIC LOW"] = {Type="Ball", Offset=Vector3.new(15,1,0)},
        ["CINEMATIC FAR"] = {Type="Ball", Offset=Vector3.new(0,8,45)},
        ["DUTCH ACTION"] = {Type="Ball", Offset=Vector3.new(15,10,15), Roll=15},
        ["DUTCH REVERSE"] = {Type="Ball", Offset=Vector3.new(-15,10,-15), Roll=-15},
        ["WORMS EYE"] = {Type="Ball", Offset=Vector3.new(0,0.5,15)},
        ["CATWALK"] = {Type="Ball", Offset=Vector3.new(0,70,30)},
        ["SNIPER CAM"] = {Type="Ball", Offset=Vector3.new(70,40,70)},
        ["NOSEBLEEDS"] = {Type="Ball", Offset=Vector3.new(45,35,0)},
        ["COURT CORNER"] = {Type="Ball", Offset=Vector3.new(30,10,30)},
        ["VIP LOUNGE"] = {Type="Ball", Offset=Vector3.new(40,25,40)},
        ["90s BROADCAST"] = {Type="Ball", Offset=Vector3.new(35,12,0), Filter={Sat=-0.4,Tint=Color3.fromRGB(255,240,200),Cont=0.1}},
        ["NOIR FILM"] = {Type="Ball", Offset=Vector3.new(20,5,20), Filter={Sat=-1,Cont=0.6,Bright=0.1}},
        ["SEPIA DRAMA"] = {Type="Player", Offset=Vector3.new(10,2,10), Filter={Sat=-0.5,Tint=Color3.fromRGB(200,160,110),Cont=0.3}},
        ["CYBERPUNK"] = {Type="OrbitBall", Radius=20,Height=10,Speed=0.4,Filter={Sat=0.8,Tint=Color3.fromRGB(255,150,255),Cont=0.4}},
        ["VINTAGE POLAROID"] = {Type="Ball", Offset=Vector3.new(0,15,30), Filter={Sat=-0.2,Tint=Color3.fromRGB(255,225,180),Cont=-0.1}},
        ["SECURITY CAM"] = {Type="Ball", Offset=Vector3.new(40,30,40), Filter={Sat=-0.8,Tint=Color3.fromRGB(150,255,150),Cont=0.8,Bright=0.2}},
        ["SUMMER VIBES"] = {Type="Player", Offset=Vector3.new(0,8,25), Filter={Sat=0.5,Tint=Color3.fromRGB(255,230,200),Bright=0.1}},
        ["COLD NIGHT"] = {Type="Ball", Offset=Vector3.new(0,10,35), Filter={Sat=-0.3,Tint=Color3.fromRGB(180,200,255)}},
        ["GRIMY"] = {Type="OrbitPlayer", Radius=10,Height=2,Speed=0.8,Filter={Sat=0.2,Tint=Color3.fromRGB(200,220,150),Cont=0.5}},
        ["HIGH FANTASY"] = {Type="Ball", Offset=Vector3.new(0,40,0.1), Filter={Sat=0.6,Tint=Color3.fromRGB(230,200,255),Bright=0.15}},
    },
}



do
    local Lighting = game:GetService("Lighting")
    local W = SpecWatch

    local function getAllCourts()
        local courts = {}
        local folder = workspace:FindFirstChild("Courts")
        if folder then
            for _, court in ipairs(folder:GetChildren()) do
                if court:IsA("Model") then table.insert(courts, court) end
            end
        end
        local single = workspace:FindFirstChild("Court")
        if single and single:IsA("Model") then
            local listed = false
            for _, court in ipairs(courts) do if court == single then listed = true; break end end
            if not listed then table.insert(courts, single) end
        end
        return courts
    end

    function W.GetCourtFrame(court)
        if not court then return nil, nil end
        local now = os.clock()
        local cached = W.FrameCache[court]
        if cached and now - cached.At < 1 then return cached.Frame, cached.Size end
        local positions = court:FindFirstChild("_CourtPositions")
        local center = positions and positions:FindFirstChild("Center")
        if center and center:IsA("BasePart") then
            local hitbox = court:FindFirstChild("HitboxesHome") or court:FindFirstChild("Hitboxes")
            local away = court:FindFirstChild("HitboxesAway")
            local homeGoal = hitbox and hitbox:FindFirstChild("FieldGoal")
            local awayGoal = away and away:FindFirstChild("FieldGoal")
            if homeGoal and awayGoal then
                local axis = awayGoal.Position - homeGoal.Position
                local length = axis.Magnitude
                if length > 1 then
                    local look = CFrame.lookAt(center.Position, center.Position + axis.Unit)
                    local size = Vector3.new(math.max(40, length * 0.6), 30, length)
                    W.FrameCache[court] = { Frame = look, Size = size, At = now }
                    return look, size
                end
            end
            local size = Vector3.new(60, 30, 90)
            W.FrameCache[court] = { Frame = center.CFrame, Size = size, At = now }
            return center.CFrame, size
        end
        local ok, frame, size = pcall(function() return court:GetBoundingBox() end)
        if ok and frame and size then
            W.FrameCache[court] = { Frame = frame, Size = size, At = now }
            return frame, size
        end
        local pivotOk, pivot = pcall(function() return court:GetPivot() end)
        if pivotOk then
            local size2 = Vector3.new(90, 30, 65)
            W.FrameCache[court] = { Frame = pivot, Size = size2, At = now }
            return pivot, size2
        end
        return nil, nil
    end

    function W.GetCourtSettings(court)
        if not court then return nil end
        return court:FindFirstChild("_CourtSettings") or court:FindFirstChild("CourtSettings")
    end

    function W.GetCourtPlayersFolder(court)
        if not court then return nil end
        return court:FindFirstChild("_CourtPlayers") or court:FindFirstChild("CourtPlayers")
    end

    function W.GetCourtValue(court, name)
        local settings = W.GetCourtSettings(court)
        local value = settings and settings:FindFirstChild(name)
        if value and value:IsA("ValueBase") then return value.Value end
        return nil
    end

    function W.IsCourtStarted(court) return W.GetCourtValue(court, "Started") == true end

    function W.GetCourtScore(court)
        local home = W.GetCourtValue(court, "HomeScore")
        local away = W.GetCourtValue(court, "AwayScore")
        if home == nil and away == nil then return nil end
        return tostring(home or 0) .. " - " .. tostring(away or 0)
    end

    function W.IsPracticeCourt(court)
        if not court then return true end
        if string.find(string.lower(court.Name), "practice", 1, true) then return true end
        if court:GetAttribute("Practice") == true then return true end
        local practiceArea = workspace:FindFirstChild("PracticeArea")
        if practiceArea and court:IsDescendantOf(practiceArea) then return true end
        if not W.GetCourtPlayersFolder(court) then return true end
        if not W.GetCourtSettings(court) then return true end
        return false
    end

    function W.SlotIsPlaying(slotName)
        slotName = tostring(slotName or "")
        for prefix in pairs(W.IgnoredSlots) do
            if string.sub(slotName, 1, #prefix) == prefix then return false end
        end
        return true
    end

    function W.SlotTeam(slotName)
        return string.sub(tostring(slotName or ""), 1, 4) == "Home" and "Home" or "Away"
    end

    function W.GetPlayersForCourt(court)
        local output = {}
        local folder = W.GetCourtPlayersFolder(court)
        if not folder then return output end
        for _, slot in ipairs(folder:GetChildren()) do
            if slot:IsA("ObjectValue") and W.SlotIsPlaying(slot.Name) then
                local player = slot.Value
                if player and player:IsA("Player") then
                    table.insert(output, { Player = player, Slot = slot.Name, Team = W.SlotTeam(slot.Name) })
                end
            end
        end
        table.sort(output, function(a, b)
            if a.Team ~= b.Team then return a.Team == "Home" end
            return a.Slot < b.Slot
        end)
        return output
    end

    function W.IsLiveMatch(court, playerList)
        if W.IsPracticeCourt(court) then return false end
        if type(playerList) ~= "table" or #playerList == 0 then return false end
        if W.IsCourtStarted(court) then return true end
        return #playerList >= 2
    end

    function W.FormatPlayers(playerList)
        if type(playerList) ~= "table" or #playerList == 0 then return "--" end
        local home, away = {}, {}
        for _, entry in ipairs(playerList) do
            local player = entry.Player
            if player then
                local name = player.DisplayName ~= "" and player.DisplayName or player.Name
                table.insert(entry.Team == "Home" and home or away, name)
            end
        end
        if #home > 0 and #away > 0 then
            return table.concat(home, ", ") .. " vs " .. table.concat(away, ", ")
        end
        local all = {}
        for _, n in ipairs(home) do table.insert(all, n) end
        for _, n in ipairs(away) do table.insert(all, n) end
        if #all == 0 then return "--" end
        return table.concat(all, ", ")
    end

    function W.RefreshOptions()
        table.clear(W.CourtOptions)
        table.clear(W.CourtLookup)
        table.clear(W.LiveCourts)
        table.clear(W.LivePlayers)
        table.insert(W.CourtOptions, "Auto Live Match")
        local selectedLabel
        for _, court in ipairs(getAllCourts()) do
            local participants = W.IsPracticeCourt(court) and {} or W.GetPlayersForCourt(court)
            if W.IsLiveMatch(court, participants) then
                local label = court.Name .. "  |  " .. W.FormatPlayers(participants)
                local score = W.GetCourtScore(court)
                if score and W.IsCourtStarted(court) then label = label .. "  [" .. score .. "]" end
                table.insert(W.CourtOptions, label)
                W.CourtLookup[label] = court.Name
                W.LiveCourts[court.Name] = court
                W.LivePlayers[court.Name] = participants
                if W.CourtName == court.Name then selectedLabel = label end
            end
        end
        table.sort(W.CourtOptions, function(a, b)
            if a == "Auto Live Match" then return true end
            if b == "Auto Live Match" then return false end
            return string.lower(a) < string.lower(b)
        end)
        if W.CourtName == "Auto" or W.CourtName == "Auto Match" or W.CourtName == "Auto Live Match" then
            W.CourtName, W.CourtSelection = "Auto Live Match", "Auto Live Match"
        elseif selectedLabel then
            W.CourtSelection = selectedLabel
        else
            W.CourtName, W.CourtSelection = "Auto Live Match", "Auto Live Match"
        end
        W.LastRefresh = os.clock()
    end

    function W.GetCourt()
        if os.clock() - W.LastRefresh >= 0.75 then W.RefreshOptions() end
        if W.CourtName ~= "Auto Live Match" then return W.LiveCourts[W.CourtName] end
        local best, bestScore = nil, -math.huge
        for name, court in pairs(W.LiveCourts) do
            local score = #(W.LivePlayers[name] or {}) * 100
            if W.IsCourtStarted(court) then score += 1000 end
            local currentBall = W.GetCourtValue(court, "CurrentBall")
            if currentBall and currentBall.Parent then score += 250 end
            if score > bestScore then best, bestScore = court, score end
        end
        return best
    end

    function W.FindBall(court)
        local now = os.clock()
        if W.BallCourt == court and W.Ball and W.Ball.Parent and now - W.BallAt < 0.1 then return W.Ball end
        local ballModel = W.GetCourtValue(court, "CurrentBall")
        local part
        if ballModel and ballModel.Parent then
            local holder = ballModel.Parent
            local root = holder and holder:FindFirstChild("HumanoidRootPart")
            if root then
                part = root
            else
                part = ballModel:FindFirstChild("Ball")
                    or (ballModel:IsA("BasePart") and ballModel or nil)
                    or ballModel:FindFirstChildWhichIsA("BasePart")
            end
        end
        if not part then
            local positions = court and court:FindFirstChild("_CourtPositions")
            local center = positions and positions:FindFirstChild("Center")
            if center and center:IsA("BasePart") then part = center end
        end
        W.Ball, W.BallCourt, W.BallAt = part, court, now
        return part
    end

    function W.SetCourt(selection)
        selection = tostring(selection or "Auto Live Match")
        if selection == "Auto" or selection == "Auto Match" then selection = "Auto Live Match" end
        local courtName = W.CourtLookup[selection]
        W.CourtSelection = selection
        W.CourtName = courtName or "Auto Live Match"
        if s.Watch then s.Watch.Court = W.CourtName end
        W.Court, W.CachedCourt, W.CachedParticipants, W.RosterAt = nil, nil, {}, 0
        W.Ball, W.BallCourt, W.PlayerSummary = nil, nil, "--"
    end

    function W.SetMode(mode)
        if not table.find(W.CameraModes, mode) then mode = "2K CAM" end
        W.Mode = mode
        if s.Watch then s.Watch.Mode = mode end
    end

    function W.ApplyFilter(filter)
        if not filter then
            if W.AppliedFilter == nil then return end
            W.AppliedFilter = nil
            if W.FilterEffect then W.FilterEffect.Enabled = false end
            return
        end
        if W.AppliedFilter == filter and W.FilterEffect and W.FilterEffect.Parent and W.FilterEffect.Enabled then return end
        if not W.FilterEffect or not W.FilterEffect.Parent then
            W.FilterEffect = Instance.new("ColorCorrectionEffect")
            W.FilterEffect.Name = "AuralSpectatorFilter"
            W.FilterEffect.Parent = Lighting
        end
        W.FilterEffect.Enabled = true
        W.FilterEffect.Saturation = filter.Sat or 0
        W.FilterEffect.Contrast = filter.Cont or 0
        W.FilterEffect.Brightness = filter.Bright or 0
        W.FilterEffect.TintColor = filter.Tint or Color3.new(1, 1, 1)
        W.AppliedFilter = filter
    end

    function W.RestoreCamera()
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam.CameraType = W.SavedCameraType or Enum.CameraType.Custom
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        cam.CameraSubject = W.SavedCameraSubject or humanoid
        cam.FieldOfView = W.SavedFieldOfView or 70
        W.ApplyFilter(nil)
    end

    function W.SetActive(value)
        value = value == true
        if value == W.Active then return end
        local cam = workspace.CurrentCamera
        if value then
            W.RefreshOptions()
            W.Court = W.GetCourt()
            if not W.Court then
                W.Active, W.Status, W.PlayerSummary = false, "NO LIVE MATCHES", "--"
                return
            end
            if cam then
                W.SavedCameraType, W.SavedCameraSubject, W.SavedFieldOfView = cam.CameraType, cam.CameraSubject, cam.FieldOfView
            end
            W.Active = true
            W.CachedCourt = W.Court
            W.CachedParticipants = W.LivePlayers[W.Court.Name] or W.GetPlayersForCourt(W.Court)
            W.RosterAt = os.clock()
            W.PlayerSummary = W.FormatPlayers(W.CachedParticipants)
            W.Status = "WATCHING LIVE MATCH"
        else
            W.Active, W.Status = false, "READY"
            W.Court, W.Ball, W.BallCourt, W.CachedCourt, W.CachedParticipants = nil, nil, nil, nil, {}
            W.RestoreCamera()
        end
    end

    function W.NearestPlayerRoot(position, court)
        local participants = (W.CachedCourt == court and W.CachedParticipants)
            or W.LivePlayers[court and court.Name or ""] or W.GetPlayersForCourt(court)
        local nearest, minimum = nil, math.huge
        for _, entry in ipairs(participants) do
            local character = entry.Player and entry.Player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - position).Magnitude
                if d < minimum then nearest, minimum = root, d end
            end
        end
        return nearest
    end

    function W.CameraForMode(mode, focusPosition, court, dt)
        local shot = W.Shots[mode] or W.Shots["2K CAM"]
        local lookTarget = focusPosition
        if shot.Type == "Player" or shot.Type == "OrbitPlayer" then
            local nearest = W.NearestPlayerRoot(focusPosition, court)
            if nearest then lookTarget = nearest.Position end
        end
        local courtFrame = W.GetCourtFrame(court)
        local camPos
        if shot.Type == "OrbitBall" or shot.Type == "OrbitPlayer" then
            local radius, height = shot.Radius or 20, shot.Height or 10
            local ang = os.clock() * (shot.Speed or 0.5)
            local orbit = Vector3.new(math.cos(ang) * radius, height, math.sin(ang) * radius)
            camPos = lookTarget + (courtFrame and courtFrame:VectorToWorldSpace(orbit) or orbit)
        else
            local offset = shot.Offset or Vector3.new(0, 10, 20)
            camPos = lookTarget + (courtFrame and courtFrame:VectorToWorldSpace(offset) or offset)
        end
        local cf = CFrame.new(camPos, lookTarget + Vector3.new(0, 1.5, 0))
        if shot.Roll and shot.Roll ~= 0 then cf = cf * CFrame.Angles(0, 0, math.rad(shot.Roll)) end
        return cf, 1 - math.exp(-8 * dt), shot.Filter
    end

    function W.Update(dt)
        if not (W.Active and state.active) then return end
        local cam = workspace.CurrentCamera
        if not cam then return end
        local now = os.clock()
        local court = W.Court
        if now - W.RosterAt >= 0.5 or not (court and court.Parent) then
            W.RosterAt = now
            court = W.GetCourt()
            W.Court = court
            if not court then
                W.SetActive(false)
                W.Status, W.PlayerSummary = "MATCH ENDED / EMPTY", "--"
                return
            end
            local participants = W.LivePlayers[court.Name] or W.GetPlayersForCourt(court)
            if not W.IsLiveMatch(court, participants) then
                W.SetActive(false)
                W.Status, W.PlayerSummary = "MATCH ENDED / EMPTY", "--"
                return
            end
            W.CachedCourt, W.CachedParticipants = court, participants
            W.PlayerSummary = W.FormatPlayers(participants)
        end
        local frame = W.GetCourtFrame(court)
        if not frame then
            W.Status = "COURT UNAVAILABLE"
            W.ApplyFilter(nil)
            return
        end
        local ball = W.FindBall(court)
        local focus = ball and ball.Position or (frame.Position + Vector3.new(0, 3, 0))
        local desired, smooth, filter = W.CameraForMode(W.Mode, focus, court, dt or 1 / 60)
        if cam.CameraType ~= Enum.CameraType.Scriptable then cam.CameraType = Enum.CameraType.Scriptable end
        if cam.CameraSubject ~= nil then cam.CameraSubject = nil end
        cam.CFrame = cam.CFrame:Lerp(desired, smooth)
        W.ApplyFilter(filter)
        local status = ball and "WATCHING LIVE MATCH" or "WATCHING COURT"
        if W.Status ~= status then W.Status = status end
    end

    J:Connect(RunService.RenderStepped, function(dt)
        if not W.Active then return end
        local ok, err = pcall(W.Update, dt)
        if not ok and W.Active then
            W.SetActive(false)
            warn("[Aural] Spectate camera stopped: " .. tostring(err))
        end
    end)
end

do
    local W = SpecWatch

    local FONT_SCORE = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic)
    local FONT_NAME  = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    local WHITE = Color3.fromRGB(255, 255, 255)

    local sb = {}   -- gui refs

    local function build()
        local gui = Instance.new("ScreenGui")
        gui.Name = "AuralSpectateScoreboard"
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        gui.DisplayOrder = 997
        gui.Enabled = false
        gui.Parent = (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")

        local root = Instance.new("Frame")
		root.AnchorPoint = Vector2.new(0.5, 0)
		root.Position = UDim2.new(0.5, 0, 0, 14)
		root.Size = UDim2.fromOffset(412, 120)
        root.BackgroundColor3 = Color3.fromRGB(38, 62, 190)
        root.BorderSizePixel = 0
        root.Parent = gui

		root.Parent = gui

-- Drag support
local dragging, dragStart, startPos = false, nil, nil
root.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = root.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        root.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

        Instance.new("UICorner", root).CornerRadius = UDim.new(0, 8)
        local rg = Instance.new("UIGradient", root)
        rg.Rotation = 90
        rg.Color = ColorSequence.new(Color3.fromRGB(38, 62, 190), Color3.fromRGB(24, 40, 140))
        local rs = Instance.new("UIStroke", root)
        rs.Color = Color3.fromRGB(10, 20, 80)
        rs.Thickness = 2

        local holder = Instance.new("Frame")
        holder.BackgroundTransparency = 1
        holder.Position = UDim2.fromOffset(8, 8)
        holder.Size = UDim2.new(1, -16, 1, -16)
        holder.Parent = root
        local list = Instance.new("UIListLayout", holder)
        list.FillDirection = Enum.FillDirection.Horizontal
        list.Padding = UDim.new(0, 9)
        list.SortOrder = Enum.SortOrder.LayoutOrder

        local function teamPanel(order, headerColor, bodyColor)
            local panel = Instance.new("Frame")
            panel.LayoutOrder = order
            panel.Size = UDim2.new(0, 150, 1, 0)
            panel.BackgroundColor3 = bodyColor
            panel.BorderSizePixel = 0
            panel.ClipsDescendants = true
            panel.Parent = holder
            Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 6)
            local g = Instance.new("UIGradient", panel)
            g.Rotation = 90
            g.Color = ColorSequence.new(bodyColor, bodyColor:Lerp(Color3.new(0, 0, 0), 0.25))

            local header = Instance.new("Frame")
            header.Size = UDim2.new(1, 0, 0, 26)
            header.BackgroundColor3 = headerColor
            header.BorderSizePixel = 0
            header.Parent = panel

            local nameLbl = Instance.new("TextLabel")
            nameLbl.BackgroundTransparency = 1
            nameLbl.Size = UDim2.new(1, -8, 1, 0)
            nameLbl.Position = UDim2.fromOffset(4, 0)
            nameLbl.FontFace = FONT_NAME
            nameLbl.TextScaled = true
            nameLbl.TextWrapped = false
            nameLbl.TextColor3 = WHITE
            nameLbl.Text = "-"
            nameLbl.Parent = header
            local pad = Instance.new("UIPadding", nameLbl)
            pad.PaddingTop, pad.PaddingBottom = UDim.new(0, 5), UDim.new(0, 5)
            local c = Instance.new("UITextSizeConstraint", nameLbl)
            c.MinTextSize, c.MaxTextSize = 8, 15

            local score = Instance.new("TextLabel")
            score.BackgroundTransparency = 1
            score.Position = UDim2.new(0, 0, 0, 26)
            score.Size = UDim2.new(1, 0, 1, -26)
            score.FontFace = FONT_SCORE
            score.TextScaled = true
            score.TextColor3 = WHITE
            score.Text = "00"
            score.Parent = panel
            local sp = Instance.new("UIPadding", score)
            sp.PaddingTop, sp.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4)
            local ss = Instance.new("UIStroke", score)
            ss.Color = Color3.new(0, 0, 0)
            ss.Transparency = 0.7
            ss.Thickness = 1.5
            return nameLbl, score
        end

        sb.homeName, sb.homeScore = teamPanel(1, Color3.fromRGB(18, 48, 130), Color3.fromRGB(30, 78, 205))
        sb.awayName, sb.awayScore = teamPanel(2, Color3.fromRGB(120, 8, 14), Color3.fromRGB(205, 18, 24))

        local clock = Instance.new("Frame")
        clock.LayoutOrder = 3
        clock.Size = UDim2.new(0, 70, 1, 0)
        clock.BackgroundColor3 = WHITE
        clock.BorderSizePixel = 0
        clock.Parent = holder
        Instance.new("UICorner", clock).CornerRadius = UDim.new(0, 6)

        sb.clock = Instance.new("TextLabel")
        sb.clock.BackgroundTransparency = 1
        sb.clock.Size = UDim2.fromScale(1, 1)
        sb.clock.FontFace = FONT_NAME
        sb.clock.TextSize = 26
        sb.clock.TextColor3 = Color3.fromRGB(215, 25, 40)
        sb.clock.Text = "--"
        sb.clock.Parent = clock

        sb.gui = gui
    end

    -- value of a slot -> display string (handles Player, string, or userId number)
    local function nameOf(v)
        if typeof(v) == "Instance" and v:IsA("Player") then
            return (v.DisplayName ~= "" and v.DisplayName) or v.Name
        elseif type(v) == "string" and v ~= "" then
            return v
        elseif type(v) == "number" and v > 0 then
            local p = Players:GetPlayerByUserId(v)
            if p then return (p.DisplayName ~= "" and p.DisplayName) or p.Name end
            return tostring(v)
        end
        return nil
    end

    -- Court A-D = 1s (one name per side). Any other letter = 2s/3s/4s/5s -> "a, b, c"
    local function teamText(court, prefix)
        local folder = W.GetCourtPlayersFolder(court)
        if not folder then return "-" end
        local slots = {}
        for _, slot in ipairs(folder:GetChildren()) do
            if slot:IsA("ValueBase") and string.sub(slot.Name, 1, #prefix) == prefix and W.SlotIsPlaying(slot.Name) then
                local n = nameOf(slot.Value)
                if n then slots[#slots + 1] = { slot.Name, n } end
            end
        end
        table.sort(slots, function(a, b) return a[1] < b[1] end)
        if #slots == 0 then return "-" end

        local is1s = string.match(court.Name, "^Court%s*[A-Da-d]$") ~= nil
        if is1s then return slots[1][2] end

        local names = {}
        for _, s2 in ipairs(slots) do names[#names + 1] = s2[2] end
        return table.concat(names, ", ")
    end

    local last = {}
    local function setText(label, key, text)
        if last[key] ~= text then
            last[key] = text
            label.Text = text
        end
    end

    local function update()
        if not sb.gui then build() end
        local court = W.Active and W.Court or nil
        if not (court and court.Parent) then
            sb.gui.Enabled = false
            return
        end
        sb.gui.Enabled = true

        local settings = W.GetCourtSettings(court)
        local function val(name)
            local v = settings and settings:FindFirstChild(name)
            return v and v.Value or nil
        end

        setText(sb.homeName,  "hn", teamText(court, "Home"))
        setText(sb.awayName,  "an", teamText(court, "Away"))
        setText(sb.homeScore, "hs", string.format("%02d", tonumber(val("HomeScore")) or 0))
        setText(sb.awayScore, "as", string.format("%02d", tonumber(val("AwayScore")) or 0))

        local sc = val("Shotclock")
        setText(sb.clock, "sc", sc ~= nil and tostring(math.max(0, math.floor(tonumber(sc) or 0))) or "--")
    end

    local acc = 0
    J:Connect(RunService.Heartbeat, function(dt)
        acc += dt
        if acc < 0.1 then return end
        acc = 0
        pcall(update)
    end, "SpectateScoreboard")

    J:Add(function()
        if sb.gui then pcall(function() sb.gui:Destroy() end) end
    end, nil, "SpectateScoreboardGui")
end

do
    local MX = s.AutoMix

    local Moves = {
        BehindLeft = { Action = "Behind_the_back_left", Track = "FTrack", EndHand = "R", Timeout = 0.42, SpinSign = 1, RearArc = true, Label = "SPIN LEFT (F)" },
        BehindRight = { Action = "Behind_the_back_right", Track = "GTrack", EndHand = "L", Timeout = 0.42, SpinSign = -1, RearArc = true, Label = "SPIN RIGHT (G)" },
        CrossUp = { Action = "Cross_up", Timeout = 0.56, Label = "CROSS SPIN" },
        FakeBehindLeft = { Action = "Fake_behind_left", Track = "VTrack", EndHand = "L", Timeout = 0.42, RearArc = true, Label = "LEFT ESCAPE" },
        FakeBehindRight = { Action = "Fake_behind_right", Track = "BTrack", EndHand = "R", Timeout = 0.42, RearArc = true, Label = "RIGHT ESCAPE" },
        FakeOut = { Action = "Fake_out", Timeout = 0.35, Label = "SPIN FAKE" },
        SwitchHandles = { Action = "Switch_handles", Timeout = 0.36, DynamicEndHand = true, Label = "SWITCH HANDLES" },
    }
    MX.Moves = Moves

    local TrackInfo = {
        FTrack = { EndHand = "R", Move = "BehindLeft" },
        GTrack = { EndHand = "L", Move = "BehindRight" },
        CRTrack = { EndHand = "R", Move = "CrossUp" },
        CLTrack = { EndHand = "L", Move = "CrossUp" },
        RFakeTrack = { EndHand = "R", Move = "FakeOut" },
        LFakeTrack = { EndHand = "L", Move = "FakeOut" },
        VTrack = { EndHand = "L", Move = "FakeBehindLeft" },
        BTrack = { EndHand = "R", Move = "FakeBehindRight" },
    }

    local NativeActionDefaults = {
        Increase_power = Enum.KeyCode.E,
        Decrease_power = Enum.KeyCode.Q,
        Switch_handles = Enum.KeyCode.H,
        Behind_the_back_left = Enum.KeyCode.F,
        Behind_the_back_right = Enum.KeyCode.G,
        Toggle_shiftlock = Enum.KeyCode.LeftShift,
        Dunk = Enum.KeyCode.T,
        Fake_behind_left = Enum.KeyCode.V,
        Fake_behind_right = Enum.KeyCode.B,
        Fake_out = Enum.KeyCode.R,
        Cross_up = Enum.KeyCode.C,
    }

    local rt = {
        CurrentHand = nil,
        Busy = false,
        SendingInput = false,
        LastMove = "--",
        LastMoveName = nil,
        NextAt = 0,
        Sequence = {},
        SequenceIndex = 1,
        SpinDirection = "L",
        LastDecisionAt = 0,
        ThreatSince = 0,
        ThreatKey = nil,
        ThreatLevel = "CLEAR",
        ThreatSector = "NONE",
        RearClearance = math.huge,
        CurrentBallClearance = 0,
        PredictedBallClearance = 0,
        PredictedBallEndClearance = 0,
        PredictedBallSide = "--",
        SafestMove = "--",
        RiskScore = 0,
        ClosingSpeed = 0,
        Plan = "HOLD",
        DefenderRead = "--",
        DefenseType = "NONE",
        MoveLastUsed = {},
        MoveCooldownUntil = {},
        MoveConfirmedAt = {},
        DefenderProfiles = {},
        Rotating = false,
        SpinRoot = nil,
        SpinHumanoid = nil,
        SpinOriginalAutoRotate = nil,
        SpinStartedAt = 0,
        SpinDuration = 0,
        SpinRadians = 0,
        SpinApplied = 0,
        SpinTarget = 0,
        ShiftLockActive = false,
        Animator = nil,
        AnimatorConnection = nil,
        TrackConnection = nil,
    }
    MX._Runtime = rt

    local function rawKey(action)
        local value
        local controls = LocalPlayer:FindFirstChild("Controls1")
        if controls then
            pcall(function() value = controls:GetAttribute(action) end)
        end
        if value == nil then
            pcall(function()
                local PlayerData = require(ReplicatedStorage.Util.PlayerData)
                if PlayerData and type(PlayerData.Get) == "function" then
                    value = PlayerData.Get("Controls_Keyboard", action)
                end
            end)
        end
        if typeof(value) == "EnumItem" then return value end
        local default = NativeActionDefaults[action]
        if type(value) ~= "string" or value == "" then return default end
        value = value:gsub("Enum%.KeyCode%.", "")
        local ok, key = pcall(function() return Enum.KeyCode[value] end)
        return ok and key or default
    end

    local function resolveKey(action)
        return rawKey(action)
    end

    local function getExpectedHand(name2, hand)
        local move = Moves[name2]
        if move and move.DynamicEndHand then
            return hand == "R" and "L" or "R"
        end
        return move and move.EndHand or hand
    end

    local function classify(root, defenderRoot)
        if not defenderRoot then return "NONE", 0, 0 end
        local rel = root.CFrame:PointToObjectSpace(defenderRoot.Position)
        local flat = Vector3.new(rel.X, 0, rel.Z)
        if flat.Magnitude < 0.05 then return "OVERLAP", 0, 0 end
        local front = -flat.Z / flat.Magnitude
        local side  = flat.X / flat.Magnitude
        if front <= -0.55 then return "REAR", front, side end
        if front >= 0.55 then
            if math.abs(side) < 0.25 then return "FRONT", front, side end
            return side > 0 and "FRONT RIGHT" or "FRONT LEFT", front, side
        end
        return side > 0 and "RIGHT" or "LEFT", front, side
    end

    local function getMovePath(name2, hand)
        local side = hand == "L" and -1 or 1
        if name2 == "BehindLeft" then
            return { {0,-1.5,-1.85},{0.2,-1.8,-0.75},{0.5,0,1.2},{0.75,1.8,-0.3},{1,1.5,-1.85} }
        elseif name2 == "BehindRight" then
            return { {0,1.5,-1.85},{0.2,1.8,-0.75},{0.5,0,1.2},{0.75,-1.8,-0.3},{1,-1.5,-1.85} }
        elseif name2 == "CrossUp" then
            return { {0,side*1.45,-1.85},{0.25,-side*1.55,-1.85},{0.55,side*1.45,-1.85},{0.78,-side*0.1,-1.85},{1,side*1.45,-1.85} }
        elseif name2 == "FakeBehindLeft" then
            return { {0,side*1.45,-1.85},{0.35,-0.15,0.9},{0.62,-1.65,-0.2},{1,-1.45,-1.85} }
        elseif name2 == "FakeBehindRight" then
            return { {0,side*1.45,-1.85},{0.35,0.15,0.9},{0.62,1.65,-0.2},{1,1.45,-1.85} }
        elseif name2 == "FakeOut" then
            return { {0,side*1.45,-1.85},{0.35,side*1.45,-0.65},{0.62,side*1.45,0.1},{1,side*1.45,-1.85} }
        elseif name2 == "SwitchHandles" then
            return { {0,side*1.45,-1.85},{0.32,side*0.55,-1.75},{0.62,-side*0.25,-1.7},{1,-side*1.45,-1.85} }
        end
        return { {0,side*1.45,-1.85},{1,side*1.45,-1.85} }
    end

    local function isMoveAllowed(name2, root, threat)
        local move = Moves[name2]
        if not move or not threat then return false, "INVALID MOVE" end
        if not move.RearArc or not MX.RearSpinBlock then return true end
        local rearClear = threat.RearClearance or math.huge
        if threat.Sector == "REAR" then return false, "DEFENDER BEHIND" end
        if rearClear < 7 then return false, "REAR PATH BLOCKED" end
        return true
    end

    local function evaluateBallSafety(name2, root, hand, threat)
        local move = Moves[name2]
        if not move or not threat or not threat.Root then return -math.huge, 0, hand, 0 end
        local key = resolveKey(move.Action)
        if not key then return -math.huge, 0, hand, 0 end
        if (rt.MoveCooldownUntil[name2] or 0) > os.clock() then
            return -math.huge, 0, hand, 0
        end
        local allowed = isMoveAllowed(name2, root, threat)
        if not allowed then return -math.huge, 0, hand, 0 end

        local duration = move.Timeout or 0.42
        local margin = math.max(1.5, tonumber(MX.BallSafetyMargin) or 3)
        local minimumClearance, endClearance = math.huge, 0
        local defenderRoots = threat.DefenderRoots and #threat.DefenderRoots > 0            and threat.DefenderRoots or { threat.Root }
        local path = getMovePath(name2, hand)
        for idx, point in ipairs(path) do
            local t, x, z = point[1], point[2], point[3]
            local ballWorld = root.CFrame:PointToWorldSpace(Vector3.new(x, 0, z))
            local pointClearance = math.huge
            for _, defenderRoot in ipairs(defenderRoots) do
                if defenderRoot and defenderRoot.Parent then
                    local relativeVelocity = defenderRoot.AssemblyLinearVelocity - root.AssemblyLinearVelocity
                    local predictedDefender = defenderRoot.Position + relativeVelocity * (t * duration)
                    local offset = Vector3.new(
                        ballWorld.X - predictedDefender.X, 0,
                        ballWorld.Z - predictedDefender.Z)
                    pointClearance = math.min(pointClearance, offset.Magnitude - margin)
                end
            end
            minimumClearance = math.min(minimumClearance, pointClearance)
            if idx == #path then endClearance = pointClearance end
        end

        local expectedHand = getExpectedHand(name2, hand)
        local score = minimumClearance * 2.5 + endClearance * 1.15 - duration * 0.75
        local rearClear = threat.RearClearance or math.huge
        local frontThreat = (threat.FrontDot or 0) > 0.05

        if threat.Sector ~= "REAR" then
            if expectedHand ~= threat.Side then score += 2.2 else score -= 2.3 end
        end
        if rt.LastMoveName == name2 then score -= 3.4 end

        if threat.Level == "EMERGENCY" then
            if name2 == "SwitchHandles" then score += 1.25 end
            if name2 == "FakeOut" then score += 0.9 end
            if move.RearArc and frontThreat and rearClear >= 7 then score += 0.55 end
        end

        local defense = threat.DefenseType
        if defense == "REACH" then
            if name2 == "SwitchHandles" then score += 1.8 end
            if name2 == "FakeOut" then score += 1.2 end
            if name2 == "CrossUp" and frontThreat then score += 0.35 end
            if move.RearArc and frontThreat and rearClear >= 7 then score += 0.5 end
        elseif defense == "HARD CLOSE" then
            if name2 == "FakeOut" then score += 1.3 end
            if name2 == "SwitchHandles" then score += 0.9 end
            if name2 == "CrossUp" then score += 0.7 end
        elseif defense == "CONTAIN MIDDLE" then
            if name2 == "FakeOut" then score += 1.1 end
            if name2 == "CrossUp" then score += 0.7 end
        elseif defense == "DOUBLE TEAM" then
            if name2 == "SwitchHandles" then score += 1.0 end
            if name2 == "FakeOut" then score += 0.8 end
        end

        local lastUsed = rt.MoveLastUsed[name2] or 0
        if MX.MoveVariety then
            score += math.clamp((os.clock() - lastUsed) / 9, 0, 1.4)
        end
        return score, minimumClearance, expectedHand, endClearance
    end

    local function chooseSafestMove(root, hand, threat)
        local candidates = { "BehindLeft","BehindRight","CrossUp","FakeBehindLeft","FakeBehindRight","FakeOut","SwitchHandles" }
        local ranked = {}
        for _, name2 in ipairs(candidates) do
            local score, clearance, endHand, endClearance = evaluateBallSafety(name2, root, hand, threat)
            if score > -math.huge then
                table.insert(ranked, { Name = name2, Score = score, Clearance = clearance, EndHand = endHand, EndClearance = endClearance })
            end
        end
        table.sort(ranked, function(a, b) return a.Score > b.Score end)
        if #ranked == 0 then return nil end
        local choice = ranked[1]
        if MX.MoveVariety then
            local safeTier = {}
            for _, item in ipairs(ranked) do
                if item.Score >= ranked[1].Score - 1.25 then table.insert(safeTier, item) end
            end
            table.sort(safeTier, function(a, b)
                return (rt.MoveLastUsed[a.Name] or 0) < (rt.MoveLastUsed[b.Name] or 0)
            end)
            choice = safeTier[1] or choice
        end
        rt.PredictedBallClearance = choice.Clearance
        rt.PredictedBallEndClearance = choice.EndClearance or choice.Clearance
        rt.PredictedBallSide = choice.EndHand
        rt.SafestMove = choice.Name
        return choice.Name
    end

    local function findDefender(root)
        local best, bestD = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local c = p.Character
                local r = c and c:FindFirstChild("HumanoidRootPart")
                local h = c and c:FindFirstChildOfClass("Humanoid")
                if r and h and h.Health > 0 then
                    local enemy = true
                    if LocalPlayer.Team and p.Team then enemy = LocalPlayer.Team ~= p.Team end
                    if enemy then
                        local d = (r.Position - root.Position).Magnitude
                        if d < bestD then best, bestD = p, d end
                    end
                end
            end
        end
        return best, bestD
    end

    local function readThreat(root, hand)
        local player, distance = findDefender(root)
        if not player then
            rt.RiskScore, rt.ClosingSpeed, rt.ThreatLevel = 0, 0, "CLEAR"
            rt.DefenseType, rt.ThreatSector = "NONE", "NONE"
            rt.RearClearance = math.huge
            return nil
        end
        local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return nil end
        local sector, frontDot, sideDot = classify(root, targetRoot)
        local horizontal = Vector3.new(targetRoot.Position.X - root.Position.X, 0, targetRoot.Position.Z - root.Position.Z)
        local relativeVelocity = targetRoot.AssemblyLinearVelocity - root.AssemblyLinearVelocity
        local closing = horizontal.Magnitude > 0.05
            and -relativeVelocity:Dot(horizontal.Unit) or 0
        local side = targetRoot.Position.X >= root.Position.X and "R" or "L"
        local sameSide = side == hand
        local protect = math.max(5, tonumber(MX.PreferredDistance) or 10)
        local sideRisk = sector ~= "REAR" and sameSide and 0.20 or 0
        local risk = math.clamp((protect - distance) / protect, 0, 1)
            + math.clamp(closing / 14, 0, 0.7) + sideRisk
        local emergency = math.max(3.5, tonumber(MX.EmergencyDistance) or 4.8)
        local level = (distance <= emergency or closing >= 8) and "EMERGENCY"
            or (risk >= 0.48 and "PRESSURE"
            or (risk >= 0.20 and "WATCH" or "CLEAR"))

        local rearClear = math.huge
        local local_ = root.CFrame:PointToObjectSpace(targetRoot.Position)
        if local_.Z > 0.25 then rearClear = Vector2.new(local_.X, local_.Z).Magnitude end

        local defense = "GAP"
        if sector == "REAR" then
            defense = "TRAIL"
            level = "WATCH"
            risk *= 0.25
        elseif closing >= 6 then
            defense = "HARD CLOSE"
        elseif math.abs(local_.X) < 1.5 then
            defense = "CONTAIN MIDDLE"
        end

        local threat = {
            Player = player, Root = targetRoot, Distance = distance,
            Sector = sector, FrontDot = frontDot, SideDot = sideDot,
            Side = side, SameSide = sameSide, Closing = closing,
            Risk = risk, Level = level, DefenseType = defense,
            RearClearance = rearClear,
            DefenderRoots = { targetRoot },
        }
        rt.RiskScore = risk
        rt.ClosingSpeed = closing
        rt.ThreatLevel = level
        rt.ThreatSector = sector
        rt.RearClearance = rearClear
        rt.DefenseType = defense
        return threat
    end

    local function readHand(character, humanoid, root)
        local hand
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if animator then
            local ok, tracks = pcall(function() return animator:GetPlayingAnimationTracks() end)
            if ok then
                local bestWeight = -1
                for _, track in ipairs(tracks) do
                    local animation = track.Animation
                    local name2 = animation and animation.Name
                    if name2 == "RTrack" and track.IsPlaying then
                        local w = tonumber(track.WeightCurrent) or 0
                        if w > bestWeight then hand, bestWeight = "R", w end
                    elseif name2 == "LTrack" and track.IsPlaying then
                        local w = tonumber(track.WeightCurrent) or 0
                        if w > bestWeight then hand, bestWeight = "L", w end
                    end
                end
            end
        end
        if not hand then
            local basketball = character:FindFirstChild("Basketball")
            local ball = basketball and basketball:FindFirstChild("Ball")
            if ball and ball:IsA("BasePart") then
                local local_ = root.CFrame:PointToObjectSpace(ball.Position)
                hand = math.abs(local_.X) >= 0.2 and (local_.X >= 0 and "R" or "L") or nil
            end
        end
        if hand then rt.CurrentHand = hand end
        return hand or rt.CurrentHand or "R"
    end

    local function stopSpin()
        local humanoid = rt.SpinHumanoid
        if humanoid and humanoid.Parent then
            pcall(function()
                humanoid.AutoRotate = rt.SpinOriginalAutoRotate ~= false
            end)
        end
        rt.Rotating = false
        rt.SpinRoot = nil
        rt.SpinHumanoid = nil
        rt.SpinOriginalAutoRotate = nil
        rt.SpinApplied = 0
        rt.SpinTarget = 0
    end
    MX.StopSpin = stopSpin

    local function getCameraBasis(root)
        local camera = workspace.CurrentCamera
        local look = camera and camera.CFrame.LookVector or (root and root.CFrame.LookVector) or Vector3.zAxis
        local right = camera and camera.CFrame.RightVector or (root and root.CFrame.RightVector) or Vector3.xAxis
        local forward = Vector3.new(look.X, 0, look.Z)
        local side = Vector3.new(right.X, 0, right.Z)
        if forward.Magnitude > 0.001 then forward = forward.Unit end
        if side.Magnitude > 0.001 then side = side.Unit end
        return forward, side
    end

    local function isShiftLockActive()
        local camera = workspace.CurrentCamera
        if not camera or UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then return false end
        local distance = 0
        pcall(function() distance = (camera.CFrame.Position - camera.Focus.Position).Magnitude end)
        return distance > 0.75
    end

    local function applyShiftLockSpin(root, target)
        if not root or not root.Parent or root.Anchored then return end
        local forward = getCameraBasis(root)
        if forward.Magnitude <= 0.001 then return end
        local position = root.Position
        root.CFrame = CFrame.lookAt(position, position + forward) * CFrame.Angles(0, target or 0, 0)
    end

    local function startSpin(move)
        if not MX.Enabled or not move or not move.SpinSign then return end
        if not MX.Movement then return end
        local character = LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid or root.Anchored then return end
        stopSpin()
        rt.Rotating = true
        rt.SpinRoot = root
        rt.SpinHumanoid = humanoid
        rt.SpinOriginalAutoRotate = humanoid.AutoRotate
        rt.SpinStartedAt = os.clock()
        rt.SpinDuration = math.max(0.25, move.Timeout or 0.42)
        rt.SpinRadians = math.rad(math.clamp(tonumber(MX.SpinDegrees) or 360, 90, 1080)) * move.SpinSign
        rt.SpinApplied = 0
        rt.SpinTarget = 0
        rt.ShiftLockActive = isShiftLockActive()
        humanoid.AutoRotate = false
    end

    local function perform(name2)
        local move = Moves[name2]
        if not move or rt.Busy then return false end
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not humanoid or not root or not character:FindFirstChild("Basketball") then
            return false
        end
        local threat = readThreat(root, rt.CurrentHand or "R")
        local allowed, blockReason = isMoveAllowed(name2, root, threat)
        if not allowed then
            rt.Plan = "BLOCKED " .. tostring(blockReason)
            return false
        end
        local key = resolveKey(move.Action)
        if not key then
            rt.Plan = "NO BIND " .. tostring(move.Action)
            rt.NextAt = os.clock() + 0.25
            return false
        end
        rt.Busy = true
        rt.LastMove = move.Label
        rt.LastMoveName = name2
        rt.MoveLastUsed[name2] = os.clock()
        rt.Plan = move.Label
        rt.SendingInput = true
        startSpin(move)
        local pressed = pcall(function() Input:SendKeyEvent(true, key, false, game) end)
        task.delay(0.03, function()
            pcall(function() Input:SendKeyEvent(false, key, false, game) end)
            rt.SendingInput = false
        end)
        if not pressed then stopSpin() end
        task.delay(move.Timeout or 0.42, function()
            if rt.Busy and rt.LastMoveName == name2 then
                rt.Busy = false
                local expectedEndHand = getExpectedHand(name2, rt.CurrentHand or "R")
                if expectedEndHand then rt.CurrentHand = expectedEndHand end
                if (rt.MoveConfirmedAt[name2] or 0) < (rt.MoveLastUsed[name2] or 0) then
                    rt.MoveCooldownUntil[name2] = os.clock() + 2.5
                    rt.Plan = "DEAD " .. move.Label
                end
                stopSpin()
                rt.NextAt = os.clock() + math.max(0.08, tonumber(MX.PostMoveCooldown) or 0.35)
            end
        end)
        return pressed
    end

    local function attachAnimator(character, humanoid)
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if not animator or rt.Animator == animator then return end
        if rt.AnimatorConnection then pcall(function() rt.AnimatorConnection:Disconnect() end) end
        rt.Animator = animator
        rt.AnimatorConnection = animator.AnimationPlayed:Connect(function(track)
            local name2 = track and track.Name or ""
            if name2 == "RTrack" then rt.CurrentHand = "R"; return end
            if name2 == "LTrack" then rt.CurrentHand = "L"; return end
            local info = TrackInfo[name2]
            if not info then return end
            rt.MoveConfirmedAt[info.Move] = os.clock()
            rt.MoveCooldownUntil[info.Move] = 0
            rt.Busy = true
            rt.LastMove = Moves[info.Move] and Moves[info.Move].Label or info.Move
            if rt.TrackConnection then pcall(function() rt.TrackConnection:Disconnect() end) end
            rt.TrackConnection = track.Stopped:Connect(function()
                rt.CurrentHand = info.EndHand or rt.CurrentHand
                rt.Busy = false
                stopSpin()
                rt.NextAt = os.clock() + math.max(0.08, tonumber(MX.PostMoveCooldown) or 0.35)
            end)
        end)
    end

    local function buildSpinSequence(mode, hand)
        if mode == "Spin Left" then return { "BehindLeft" } end
        if mode == "Spin Right" then return { "BehindRight" } end
        if mode == "Spin Chain" then
            rt.SpinDirection = rt.SpinDirection == "L" and "R" or "L"
            return rt.SpinDirection == "L"
                and { "BehindLeft", "BehindRight", "SwitchHandles", "CrossUp" }
                or { "BehindRight", "BehindLeft", "SwitchHandles", "CrossUp" }
        end
        if mode == "Spin Fake" then
            return hand == "R" and { "BehindRight", "FakeOut" }
                or { "BehindLeft", "FakeOut" }
        end
        if mode == "All Moves" then
            local order = { "SwitchHandles","FakeOut","CrossUp","FakeBehindLeft","FakeBehindRight","BehindLeft","BehindRight" }
            local i = ((rt.SequenceIndex - 1) % #order) + 1
            rt.SequenceIndex = i + 1
            return { order[i] }
        end
        return nil
    end

    local function selectMove(root, hand)
        local threat = readThreat(root, hand)
        if not threat then
            rt.Plan = "HOLD - NO THREAT"
            rt.NextAt = os.clock() + 0.22
            return nil
        end
        if threat.Level == "CLEAR" then
            rt.Plan = "HOLD - BALL SAFE"
            rt.NextAt = os.clock() + 0.18
            rt.ThreatSince = 0
            rt.ThreatKey = nil
            return nil
        end
        if threat.Level == "WATCH" then
            rt.Plan = "BODY " .. tostring(threat.DefenseType)
            rt.NextAt = os.clock() + 0.08
            return nil
        end
        local threatKey = threat.Level .. ":" .. tostring(threat.Sector) .. ":" .. threat.Side .. ":" .. tostring(threat.DefenseType)
        if rt.ThreatKey ~= threatKey then
            rt.ThreatKey = threatKey
            rt.ThreatSince = os.clock()
        end
        local stableFor = os.clock() - (rt.ThreatSince or 0)
        local hold = math.max(0.04, tonumber(MX.DecisionHold) or 0.14)
        if threat.Level ~= "EMERGENCY" and stableFor < hold then
            rt.Plan = "CONFIRMING " .. threat.Level
            rt.NextAt = os.clock() + 0.03
            return nil
        end
        local safest = chooseSafestMove(root, hand, threat)
        if not safest then
            rt.Plan = "NO SAFE MOVE"
            rt.NextAt = os.clock() + 0.18
            return nil
        end
        rt.Plan = string.format("COUNTER %s: %s", tostring(threat.DefenseType), safest)
        return safest
    end

    local function step(dt)
        if not MX.Enabled then return end
        if MX.ManualHandles then
            MX._State.BodyStatus = "MANUAL MODE"
            return
        end
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if not character or not humanoid or not root or humanoid.Health <= 0 then
            rt.Busy = false
            stopSpin()
            return
        end
        if not character:FindFirstChild("Basketball") then
            rt.Busy = false
            stopSpin()
            rt.NextAt = os.clock() + 0.15
            return
        end
        attachAnimator(character, humanoid)
        if rt.Rotating then
            local progress = math.clamp(
                (os.clock() - rt.SpinStartedAt) / rt.SpinDuration, 0, 1)
            local smoothed = progress * progress * (3 - 2 * progress)
            local target = rt.SpinRadians * smoothed
            local delta = target - rt.SpinApplied
            rt.SpinTarget = target
            rt.ShiftLockActive = isShiftLockActive()
            local spinRoot = rt.SpinRoot
            if spinRoot and spinRoot.Parent then
                if rt.ShiftLockActive then
                    applyShiftLockSpin(spinRoot, target)
                elseif math.abs(delta) > 0.0001 then
                    spinRoot.CFrame = spinRoot.CFrame * CFrame.Angles(0, delta, 0)
                end
                rt.SpinApplied = target
            end
            if progress >= 1 then stopSpin() end
            return
        end
        if rt.Busy then return end
        if os.clock() < (rt.NextAt or 0) then return end
        local hand = readHand(character, humanoid, root)
        local mode = tostring(MX.Mode or "Smart Mix")
        if mode ~= "Smart Mix" then
            if #rt.Sequence == 0 or rt.SequenceIndex > #rt.Sequence then
                rt.Sequence = buildSpinSequence(mode, hand) or {}
                rt.SequenceIndex = 1
            end
            local name2 = rt.Sequence[rt.SequenceIndex]
            if name2 then
                rt.SequenceIndex += 1
                perform(name2)
            else
                rt.NextAt = os.clock() + 0.15
            end
            return
        end
        local chosen = selectMove(root, hand)
        if chosen then
            perform(chosen)
        end
    end

    MX._Step = step
    J:Connect(RunService.RenderStepped, function(dt) pcall(step, dt) end, "AutoMixHandles")
end

do

    function enableHeadRide()

        if headRideConnection or not HeadRide then return end

        pushHeadRideSettings()

        HeadRide:SetEnabled(true)

        headRideConnection = RunService.Heartbeat:Connect(function(dt)

            if not s.HeadRide.Enabled then

                disableHeadRide()

                return

            end

            pushHeadRideSettings()
            if s.HeadRide.OnlyArmInMatch and not IsInMatch() then
    HeadRide:SetTarget(nil)
    HeadRide.Status = "WAITING FOR MATCH"
    return
end

                        local target = nil

            if s.HeadRide.AutoTarget then

                local candidate = getClosestDribbler()

                if not candidate then

                    candidate = getClosestPlayer()

                end

                if candidate and (not s.HeadRide.TeamSafety or not isTeammatePlayer(candidate)) then

                    target = candidate

                end

            else

                local manual = Players:FindFirstChild(s.HeadRide.ManualTarget)

                if manual and (not s.HeadRide.TeamSafety or not isTeammatePlayer(manual)) then

                    target = manual

                end

            end

            HeadRide:SetTarget(target)

            pcall(function() HeadRide:Step(dt) end)

        end)

    end

    function disableHeadRide()

        if not HeadRide then return end

        HeadRide:SetEnabled(false)

        if headRideConnection then

            headRideConnection:Disconnect()

            headRideConnection = nil

        end

    end

end

do
    local Blossom = loadstring(game:HttpGet("https://raw.githubusercontent.com/concurrentccu/mystudies/refs/heads/main/new.luau"))()
    local BlossomWindow = Blossom.new({
        Title = "Aural V2",
        Script = "AuralV2",
        Build = "Hoopz",
		Logo = "rbxassetid://123751656579481",
        Theme = "Obsidian",
        MenuKey = Enum.KeyCode.LeftControl,
        Size = Vector2.new(760, 590),
        MinSize = Vector2.new(560, 420),
        Resizable = true
    })

local isMobileDevice = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

if isMobileDevice then
    local ToggleScreenGui = Instance.new("ScreenGui")
    ToggleScreenGui.Name = "ToggleGui"
    ToggleScreenGui.ResetOnSpawn = false
    ToggleScreenGui.DisplayOrder = 101
    ToggleScreenGui.Parent = (typeof(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    J:Add(ToggleScreenGui)

    local ToggleButton = Instance.new("ImageButton")
    ToggleButton.Name = "ToggleButton"
    ToggleButton.Size = UDim2.fromOffset(55, 55)
    ToggleButton.Position = UDim2.new(0, 20, 0.5, -27)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    ToggleButton.Image = "rbxassetid://85594717889924"
    ToggleButton.ScaleType = Enum.ScaleType.Fit
    ToggleButton.Parent = ToggleScreenGui

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleButton

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1.5
    ToggleStroke.Transparency = 0.2
    ToggleStroke.Parent = ToggleButton

    local DRAG_THRESHOLD = 8
    local activeInput, dragStart, startPosition, moved = nil, nil, nil, false

    local function updateVisual()
        ToggleButton.BackgroundColor3 = BlossomWindow.Visible
            and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(35, 35, 35)
    end
    updateVisual()

    task.spawn(function()
        while ToggleScreenGui.Parent do
            updateVisual()
            task.wait(0.2)
        end
    end)

    ToggleButton.InputBegan:Connect(function(input)
        if activeInput then return end
        if input.UserInputType ~= Enum.UserInputType.Touch
            and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
        activeInput = input
        moved = false
        dragStart = input.Position
        startPosition = ToggleButton.Position
    end)

    J:Connect(UserInputService.InputChanged, function(input)
        if input ~= activeInput then return end
        local delta = input.Position - dragStart
        if not moved and delta.Magnitude >= DRAG_THRESHOLD then moved = true end
        if moved then
            ToggleButton.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    J:Connect(UserInputService.InputEnded, function(input)
        if input ~= activeInput then return end
        activeInput = nil
        if not moved then
            BlossomWindow:Toggle()
            updateVisual()
        end
    end)
end

    local Window = { _window = BlossomWindow, _categories = {} }

    local function wrapDropdown(control)
        function control:Refresh(values)
            self:SetOptions(values or {})
        end
        function control:SetValues(values)
            self:SetOptions(values or {})
        end
        function control:GetOptions()
            return self.Options
        end
        return control
    end

    local function wrapSection(section)
        local wrapper = { _section = section }
        function wrapper:AddToggle(options)
            local key = options.Keybind
            local mapped = {
                Name = options.Name,
                Default = options.Default,
                Flag = options.Flag,
                Callback = options.Callback,
                Color = options.Color,
                ColorCallback = options.ColorCallback
            }
            if type(key) == "table" then
                mapped.Keybind = key.Default
                mapped.KeybindMode = key.Mode or "Toggle"
            elseif typeof(key) == "EnumItem" then
                mapped.Keybind = key
            end
            return section:Toggle(mapped)
        end
        function wrapper:AddSlider(options)
            local increment = options.Increment
            local decimals = options.Decimals
            if decimals == nil and type(increment) == "number" and increment > 0 then
                local asText = string.format("%.8f", increment):gsub("0+$", "")
                decimals = math.max(0, #(asText:match("%.(%d+)") or ""))
            end
            local control
            local function changed(value)
                if type(increment) == "number" and increment > 0 then
                    local minimum = options.Min or 0
                    local snapped = minimum + math.floor((value - minimum) / increment + 0.5) * increment
                    local precision = decimals or 0
                    local factor = 10 ^ precision
                    snapped = math.floor(snapped * factor + 0.5) / factor
                    if control and math.abs(snapped - value) > 0.0000001 then
                        control:Set(snapped, true)
                    end
                    value = snapped
                end
                if options.Callback then options.Callback(value) end
            end
            control = section:Slider({
                Name = options.Name,
                Min = options.Min,
                Max = options.Max,
                Default = options.Default,
                Decimals = decimals or 0,
                Suffix = options.Suffix,
                Flag = options.Flag,
                Callback = changed
            })
            return control
        end
        function wrapper:AddDropdown(options)
            return wrapDropdown(section:Dropdown({
                Name = options.Name,
                Options = options.Values or options.Options or {},
                Default = options.Default,
                Multi = options.Multi == true,
                Flag = options.Flag,
                Callback = options.Callback,
                MaxRows = options.MaxRows,
                Empty = options.Empty
            }))
        end
        function wrapper:AddButton(options)
            return section:Button({
                Name = options.Text or options.Name,
                Callback = options.Callback
            })
        end
        function wrapper:AddTextBox(options)
            return section:Textbox({
                Name = options.Name,
                Default = options.Default,
                Placeholder = options.Placeholder,
                Flag = options.Flag,
                Callback = options.Callback
            })
        end
        function wrapper:AddColorPicker(options)
            return section:Colorpicker({
                Name = options.Name,
                Default = options.Default,
                Flag = options.Flag,
                Callback = options.Callback
            })
        end
        function wrapper:AddKeybind(options)
            return section:Keybind({
                Name = options.Name,
                Default = options.Default,
                Mode = options.Mode,
                Flag = options.Flag,
                Callback = options.Callback
            })
        end
        return wrapper
    end

    function Window:AddTab(options)
        local categoryName = options.Name or "Main"
        if not self._categories[categoryName] then
            self._window:Category(categoryName)
            self._categories[categoryName] = true
        end
        local tabWrapper = { _window = self, _name = categoryName, _icon = options.Icon }
        local sharedPageWrapper
        function tabWrapper:AddPage(pageOptions)
            if categoryName == "Offense" and sharedPageWrapper then
                return sharedPageWrapper
            end

            local rawTab = self._window._window:Tab({
                Name = categoryName == "Offense" and "Offense" or (pageOptions.Name or self._name),
                Icon = self._icon or "grid"
            })
            local pageWrapper = { _tab = rawTab }
            function pageWrapper:AddSection(sectionOptions)
                local side = sectionOptions.Side == "Right" and 2 or 1
                local rawSection = rawTab:Section({
                    Name = sectionOptions.Title or sectionOptions.Name or "Section",
                    Icon = sectionOptions.Icon or "cube",
                    Description = sectionOptions.Description,
                    Side = side
                })
                return wrapSection(rawSection)
            end

            if categoryName == "Offense" then
                sharedPageWrapper = pageWrapper
            end
            return pageWrapper
        end
        return tabWrapper
    end

    function Window:AddConfigSections(tab)
        if tab and tab.AddPage then
            local settingsPage = tab:AddPage({ Name = "Settings" })
            self._window:BuildSettings(settingsPage._tab)
        end
    end

    function Window:LoadAutoConfig()
        return true
    end

    function Window:Notify(options)
        return self._window:Notify(options)
    end

    local function notify(title, text, typ, dur)
        pcall(function()
            Window:Notify({ Title = title, Text = text, Type = typ or "info", Duration = dur or 3 })
        end)
    end

    local trash = { "Xeno", "Solara", "Nexomia" }
    local execName2 = identifyexecutor and identifyexecutor() or ""
    for _, exec in ipairs(trash) do
        if string.find(execName2, exec, 1, true) then
            notify("Features Limited", execName2 .. " may not support Aural V2. Features are limited.", "warning", 10)
            break
        end
    end

    do
    local OffenseTab = Window:AddTab({ Name = "Offense", Icon = "target" })

-- ════════════════════════════════════════════════════════════════
-- PAGE 1 · SILENT AIM
-- ════════════════════════════════════════════════════════════════
local SilentAimPage = OffenseTab:AddPage({ Name = "Silent Aim" })

local auralSection = SilentAimPage:AddSection({ Title = "Silent Aim (Aural)", Side = "Left" })
local auralsilent = auralSection:AddToggle({
    Name = "Enable Aural Silent Aim",
    Default = s.Shooting.AuralEnabled,
    Flag = "aural_toggle",
    Keybind = { Default = s.Shooting.AuralKeybind or Enum.KeyCode.Unknown, Mode = "Toggle" },
    Callback = function(value)
        s.Shooting.AuralEnabled = value
        if value then
            s.Shooting.FatalEnabled = false
            s.Shooting.Mode = "Aural"
            disableFatal()
        end
    end
})
uiToggles.aural = auralsilent

auralSection:AddToggle({ Name = "Only Arm In Match", Default = s.Shooting.ArmInMatch, Flag = "aural_arminmatch", Callback = function(value) s.Shooting.ArmInMatch = value end })
auralSection:AddToggle({ Name = "Aim Assist", Default = s.Shooting.AuralAimAssist, Flag = "aural_aimassist", Callback = function(v) s.Shooting.AuralAimAssist = v end })
auralSection:AddToggle({
    Name = "Bank shots",
    Default = s.Shooting.BankShots or false,
    Flag = "aural_bankshots",
    Callback = function(value) s.Shooting.BankShots = value end,
})
auralSection:AddToggle({ Name = "Silent Aim Button", Default = s.Shooting.SilentAimButton or false, Flag = "aural_mobilebutton", Callback = function(v) s.Shooting.SilentAimButton = v end })

local fatalSection = SilentAimPage:AddSection({ Title = "Silent Aim (Fatal)", Side = "Right" })
fatalSection:AddToggle({
    Name = "Enable Fatal Silent Aim",
    Default = s.Shooting.FatalEnabled,
    Flag = "fatal_toggle",
    Callback = function(value)
        s.Shooting.FatalEnabled = value
        if value then
            s.Shooting.AuralEnabled = false
            s.Shooting.Mode = "Fatal"
            enableFatal()
        else
            disableFatal()
        end
    end
})
fatalSection:AddSlider({ Name = "Green Chance", Min = 0, Max = 100, Default = s.Shooting.GreenChance, Increment = 5, Suffix = "%", Flag = "fatal_green", Callback = function(v) s.Shooting.GreenChance = v end })
fatalSection:AddToggle({ Name = "High Arc (85s only)", Default = s.Shooting.ThreesOnly, Flag = "fatal_threes", Callback = function(v) s.Shooting.ThreesOnly = v end })
fatalSection:AddToggle({ Name = "Aim Assist (only shoot when looking up)", Default = s.Shooting.AimAssist, Flag = "fatal_aimassist", Callback = function(v) s.Shooting.AimAssist = v end })


-- ════════════════════════════════════════════════════════════════
-- PAGE 2 · HUMANIZER
-- ════════════════════════════════════════════════════════════════
local HumanizerPage = OffenseTab:AddPage({ Name = "Humanizer" })

local humanizeSection = HumanizerPage:AddSection({ Title = "Humanize Aim", Side = "Left" })
humanizeSection:AddToggle({ Name = "Humanize Aim", Default = s.Shooting.HumanizeAim, Flag = "aural_humanizeaim", Callback = function(value) s.Shooting.HumanizeAim = value end })
humanizeSection:AddSlider({ Name = "Humanize strength", Min = 0.2, Max = 5, Default = 1.2, Increment = 0.1, Flag = "aural_hstrength", Callback = function(v) s.Shooting.HumanizeStrength = v end })
humanizeSection:AddSlider({ Name = "Humanize miss %", Min = 0, Max = 80, Default = 0, Increment = 1, Suffix = "%", Flag = "aural_hmiss", Callback = function(v) s.Shooting.MissChance = v end })

local variationSection = HumanizerPage:AddSection({ Title = "Shot Variation", Side = "Right" })
variationSection:AddToggle({ Name = "EBL Hop", Default = s.Shooting.EBLHop, Flag = "aural_eblhop", Callback = function(value) s.Shooting.EBLHop = value end })
variationSection:AddSlider({ Name = "Shot Y axis offset", Min = -15, Max = 10, Default = s.Shooting.ShotYAxis, Increment = 0.1, Flag = "aural_yaxis", Callback = function(v) s.Shooting.ShotYAxis = v end })
variationSection:AddSlider({ Name = "Shot delay", Min = 0.15, Max = 0.42, Default = s.Shooting.ShotDelay, Increment = 0.01, Suffix = "s", Flag = "aural_delay", Callback = function(v) s.Shooting.ShotDelay = v end })
variationSection:AddToggle({ Name = "Randomize shot delay", Default = s.Shooting.RandomizeShotDelay, Flag = "aural_rand", Callback = function(v) s.Shooting.RandomizeShotDelay = v end })
variationSection:AddSlider({ Name = "Min delay", Min = 0, Max = 1, Default = s.Shooting.ShotDelayMin, Increment = 0.05, Suffix = "s", Flag = "aural_mindelay", Callback = function(v) s.Shooting.ShotDelayMin = v end })
variationSection:AddSlider({ Name = "Max delay", Min = 0, Max = 1, Default = s.Shooting.ShotDelayMax, Increment = 0.05, Suffix = "s", Flag = "aural_maxdelay", Callback = function(v) s.Shooting.ShotDelayMax = v end })


-- ════════════════════════════════════════════════════════════════
-- PAGE 3 · AUTO POWER
-- ════════════════════════════════════════════════════════════════
local AutoPowerPage = OffenseTab:AddPage({ Name = "Auto Power" })

local arcTableSection = AutoPowerPage:AddSection({ Title = "Auto Power", Side = "Left" })
arcTableSection:AddToggle({ Name = "Auto Power", Default = s.Shooting.ArcTableAuto, Flag = "arctable_auto", Callback = function(v) s.Shooting.ArcTableAuto = v end })
arcTableSection:AddDropdown({ Name = "Power Choice", Values = { "Closest to 85", "Lowest", "Highest" }, Default = s.Shooting.ArcTablePref, Flag = "arctable_pref", Callback = function(v) s.Shooting.ArcTablePref = v end })

if getgenv().HoopzArcCfg.Mode ~= "High Arc" and getgenv().HoopzArcCfg.Mode ~= "Low Arc" then
    getgenv().HoopzArcCfg.Mode = getgenv().HoopzArcCfg.High and "High Arc" or "Low Arc"
end
getgenv().HoopzArcCfg.High = getgenv().HoopzArcCfg.Mode == "High Arc"

local arcModeSection = AutoPowerPage:AddSection({ Title = "Arc Mode", Side = "Right" })
arcModeSection:AddDropdown({
    Name = "Arc Mode",
    Values = { "Low Arc", "High Arc" },
    Default = (getgenv().HoopzArcCfg.Mode == "High Arc"
        or (getgenv().HoopzArcCfg.Mode == nil and getgenv().HoopzArcCfg.High)) and "High Arc" or "Low Arc",
    Flag = "hoopz_arcmode",
    Callback = function(v)
        getgenv().HoopzArcCfg.Mode = v
        getgenv().HoopzArcCfg.High = (v == "High Arc")
    end,
})


-- ════════════════════════════════════════════════════════════════
-- PAGE 4 · RELEASE TIMING
-- ════════════════════════════════════════════════════════════════
local ReleasePage = OffenseTab:AddPage({ Name = "Release Timing" })

local releaseSection = ReleasePage:AddSection({ Title = "Perfect Release", Side = "Left" })
releaseSection:AddToggle({ Name = "Perfect release", Default = s.Release.Perfect, Flag = "release_perfect", Callback = function(v) s.Release.Perfect = v end })
releaseSection:AddToggle({ Name = "Self-calibrate release", Default = s.Release.AutoCalibrate, Flag = "release_autocal", Callback = function(v) s.Release.AutoCalibrate = v end })
releaseSection:AddToggle({ Name = "Precision spin (exact release frame)", Default = s.Release.PrecisionSpin, Flag = "release_spin", Callback = function(v) s.Release.PrecisionSpin = v end })
releaseSection:AddToggle({ Name = "Ping compensation", Default = s.Release.PingCompensation, Flag = "release_pingcomp", Callback = function(v) s.Release.PingCompensation = v end })
releaseSection:AddSlider({ Name = "Release base delay", Min = 0.15, Max = 0.45, Default = s.Release.Base, Increment = 0.0005, Suffix = "s", Flag = "release_base", Callback = function(v) s.Release.Base = v end })

local pingAdaptiveSection = ReleasePage:AddSection({ Title = "Ping Adaptive", Side = "Right" })
pingAdaptiveSection:AddToggle({ Name = "Ping-adaptive release", Default = s.Release.PingAdaptive, Flag = "release_pingadaptive", Callback = function(v) s.Release.PingAdaptive = v end })
pingAdaptiveSection:AddSlider({ Name = "Baseline ping", Min = 0, Max = 300, Default = s.Release.PingBaseline, Increment = 1, Suffix = "ms", Flag = "release_pingbase", Callback = function(v) s.Release.PingBaseline = v end })
pingAdaptiveSection:AddSlider({ Name = "Ping strength", Min = 0, Max = 3, Default = s.Release.PingStrength, Increment = 0.05, Flag = "release_pingstrength", Callback = function(v) s.Release.PingStrength = v end })
pingAdaptiveSection:AddSlider({ Name = "Max ping lead", Min = 0, Max = 500, Default = s.Release.PingMaxLead, Increment = 5, Suffix = "ms", Flag = "release_pingmax", Callback = function(v) s.Release.PingMaxLead = v end })
pingAdaptiveSection:AddButton({ Name = "Release stats", Text = "Show", Callback = function()
    local st = getReleaseStats()
    notify("Release: " .. tostring(st.Last), string.format("%d/%d perfect (%.0f%%) | streak %d (best %d) | base %.4fs%s | ping %.0fms +%.0fms lead", st.Hits, st.Attempts, st.Accuracy, st.Streak, st.Best, st.Base, st.Locked and " locked" or "", st.Ping, st.Lead * 1000), "info", 5)
end })
pingAdaptiveSection:AddButton({ Name = "Reset release calibration", Text = "Reset", Callback = function()
    resetReleaseCalibration()
    notify("Release", "Calibration reset to the base delay slider.", "info", 3)
end })


-- ════════════════════════════════════════════════════════════════
-- PAGE 5 · SELF PASS
-- ════════════════════════════════════════════════════════════════
local SelfPassPage = OffenseTab:AddPage({ Name = "Self Pass" })

local selfPassSection = SelfPassPage:AddSection({ Title = "Self Pass", Side = "Left" })
local selfPassToggle = selfPassSection:AddToggle({
    Name = "Enable Self Pass",
    Default = s.SelfPass.Enabled,
    Flag = "selfpass_toggle",
    Callback = function(value)
        s.SelfPass.Enabled = value
    end,
})

local selfPassKey = selfPassSection:AddKeybind({
    Name = "Self Pass Key",
    Default = Enum.KeyCode[s.SelfPass.Keybind] or Enum.KeyCode.T,
    Mode = "Press",
    Callback = function()
        if s.SelfPass.Enabled then
            task.spawn(fireMobileSelfPass)
        end
    end,
})
selfPassSection:AddSlider({ Name = "Pass Power", Min = 10, Max = 85, Default = s.SelfPass.Power, Increment = 1, Flag = "selfpass_power", Callback = function(v) s.SelfPass.Power = v end })
selfPassSection:AddSlider({ Name = "Pass Distance", Min = 10, Max = 100, Default = s.SelfPass.Distance, Increment = 1, Flag = "selfpass_distance", Callback = function(v) s.SelfPass.Distance = v end })
selfPassSection:AddSlider({ Name = "Pass Angle", Min = 90, Max = 180, Default = s.SelfPass.Angle, Increment = 1, Flag = "selfpass_angle", Callback = function(v) s.SelfPass.Angle = v end })
selfPassSection:AddToggle({ Name = "Self Pass Button", Default = s.SelfPass.SelfPassButton or false, Flag = "selfpass_mobilebutton", Callback = function(v) s.SelfPass.SelfPassButton = v end })


-- ════════════════════════════════════════════════════════════════
-- PAGE 6 · AUTO DIME
-- ════════════════════════════════════════════════════════════════
local AutoDimePage = OffenseTab:AddPage({ Name = "Auto Dime" })

local autoDimeSection = AutoDimePage:AddSection({ Title = "Auto Dime", Side = "Left" })
autoDimeSection:AddToggle({
    Name = "Enable Auto Dime",
    Default = s.AutoDime.Enabled,
    Flag = "autodime_toggle",
    Keybind = { Default = Enum.KeyCode.G, Mode = "Toggle" },
    Callback = function(value)
        s.AutoDime.Enabled = value
        if value then enableAutoDime() else disableAutoDime() end
    end
})
autoDimeSection:AddSlider({ Name = "Pass Power", Min = 60, Max = 85, Default = s.AutoDime.PassPower, Increment = 5, Flag = "autodime_power", Callback = function(v) s.AutoDime.PassPower = v end })
autoDimeSection:AddToggle({ Name = "Jump Before Pass", Default = s.AutoDime.JumpBeforePass, Flag = "autodime_jump", Callback = function(v) s.AutoDime.JumpBeforePass = v end })
autoDimeSection:AddSlider({ Name = "Jump Delay", Min = 0.05, Max = 0.5, Default = s.AutoDime.JumpDelay, Increment = 0.01, Suffix = "s", Flag = "autodime_jumpdelay", Callback = function(v) s.AutoDime.JumpDelay = v end })
autoDimeSection:AddSlider({ Name = "Lead Multiplier", Min = 0, Max = 3, Default = s.AutoDime.LeadMultiplier, Increment = 0.05, Flag = "autodime_lead", Callback = function(v) s.AutoDime.LeadMultiplier = v end })
autoDimeSection:AddToggle({ Name = "Auto Lead", Default = s.AutoDime.AutoLead, Flag = "autodime_autolead", Callback = function(v) s.AutoDime.AutoLead = v end })
autoDimeSection:AddToggle({ Name = "Lead Ping Compensation", Default = s.AutoDime.LeadPing, Flag = "autodime_leadping", Callback = function(v) s.AutoDime.LeadPing = v end })

local autoDimeKeysSection = AutoDimePage:AddSection({ Title = "Teammate Pass Keys", Side = "Right" })
autoDimeKeysSection:AddKeybind({ Name = "Slot 1 Key", Default = Enum.KeyCode[s.AutoDime.Key1] or Enum.KeyCode.One, Mode = "None", Flag = "autodime_key1", Callback = function(kc) s.AutoDime.Key1 = kc and kc.Name or "One" end })
autoDimeKeysSection:AddKeybind({ Name = "Slot 2 Key", Default = Enum.KeyCode[s.AutoDime.Key2] or Enum.KeyCode.Two, Mode = "None", Flag = "autodime_key2", Callback = function(kc) s.AutoDime.Key2 = kc and kc.Name or "Two" end })
autoDimeKeysSection:AddKeybind({ Name = "Slot 3 Key", Default = Enum.KeyCode[s.AutoDime.Key3] or Enum.KeyCode.Three, Mode = "None", Flag = "autodime_key3", Callback = function(kc) s.AutoDime.Key3 = kc and kc.Name or "Three" end })
autoDimeKeysSection:AddKeybind({ Name = "Slot 4 Key", Default = Enum.KeyCode[s.AutoDime.Key4] or Enum.KeyCode.Four, Mode = "None", Flag = "autodime_key4", Callback = function(kc) s.AutoDime.Key4 = kc and kc.Name or "Four" end })
autoDimeKeysSection:AddKeybind({ Name = "Slot 5 Key", Default = Enum.KeyCode[s.AutoDime.Key5] or Enum.KeyCode.Five, Mode = "None", Flag = "autodime_key5", Callback = function(kc) s.AutoDime.Key5 = kc and kc.Name or "Five" end })


    end

    do
    local DefenseTab = Window:AddTab({ Name = "Defense", Icon = "bullet" })
    local DefensePage = DefenseTab:AddPage({ Name = "Defense" })

    local guardSec = DefensePage:AddSection({ Title = "Auto Guard", Side = "Left" })
    local guardToggle = guardSec:AddToggle({
        Name = "Auto guard",
        Default = s.Defending.AutoGuard,
        Flag = "defend_autoguard",
        Keybind = { Default = Enum.KeyCode.K, Mode = "Toggle" },
        Callback = function(value)
            s.Defending.AutoGuard = value
            if value then enableAutoGuard() else disableAutoGuard() end
        end
    })
    uiToggles.guard = guardToggle
    guardSec:AddToggle({ Name = "Only Guard In Match", Default = s.Defending.OnlyGuardInMatch, Flag = "defend_guardinmatch", Callback = function(value) s.Defending.OnlyGuardInMatch = value end })
    guardSec:AddDropdown({ Name = "Auto Guard Mode", Values = { "Prediction", "Legit", "Blatant" }, Default = s.Defending.AutoGuardMode, Flag = "defend_guardmode", Callback = function(v) s.Defending.AutoGuardMode = v end })
    guardSec:AddToggle({ Name = "Auto Guard Button", Default = s.Defending.AutoGuardButton, Flag = "defend_guardbutton", Callback = function(v)
        s.Defending.AutoGuardButton = v
        local hui: Instance = (gethui and gethui()) or game:GetService("CoreGui")
        local gui = hui:FindFirstChild("AuralMobileGui")
        local button = gui and (gui :: Instance):FindFirstChild("AutoGuard", true)
        if button then
            button.Visible = v
            button.BackgroundColor3 = s.Defending.AutoGuard and Color3.fromRGB(0, 170, 85) or Color3.fromRGB(35, 35, 35)
        end
    end })
    guardSec:AddToggle({ Name = "Guard nearest if no dribbler", Default = s.Defending.AutoGuardNearest, Flag = "defend_nearest", Callback = function(v)
        s.Defending.AutoGuardNearest = v
        if s.Defending.AutoGuard then enableAutoGuard() end
    end })
    guardSec:AddSlider({ Name = "Guard range", Min = 10, Max = 60, Default = s.Defending.AutoGuardRange, Increment = 1, Flag = "defend_range", Callback = function(v) s.Defending.AutoGuardRange = v end })
    guardSec:AddSlider({ Name = "Prediction strength", Min = 0.1, Max = 1.5, Default = s.Defending.GuardPrediction, Increment = 0.05, Flag = "defend_prediction", Callback = function(v) s.Defending.GuardPrediction = v end })
    guardSec:AddDropdown({ Name = "Guard style", Values = { "Contain", "Cutoff", "Smother" }, Default = s.Defending.GuardStyle or "Contain", Flag = "defend_style", Callback = function(v) s.Defending.GuardStyle = v end })
    guardSec:AddSlider({ Name = "Defensive spacing", Min = 0.5, Max = 12, Default = s.Defending.SpacingDistance or 3, Increment = 0.25, Flag = "defend_spacing", Callback = function(v) s.Defending.SpacingDistance = v end })
    guardSec:AddSlider({ Name = "Cutoff lead", Min = 0, Max = 12, Default = s.Defending.CutoffLead or 3, Increment = 0.25, Flag = "defend_cutofflead", Callback = function(v) s.Defending.CutoffLead = v end })
    guardSec:AddSlider({ Name = "Reaction delay", Min = 0, Max = 0.75, Default = s.Defending.ReactionTime or 0, Increment = 0.05, Flag = "defend_reaction", Callback = function(v) s.Defending.ReactionTime = v end })

    local antiReachSec = DefensePage:AddSection({ Title = "Anti Reach", Side = "Left" })
    antiReachSec:AddToggle({ Name = "Enable Anti Reach", Default = s.AntiReach.Enabled, Flag = "antireach_toggle", Callback = function(value)
        s.AntiReach.Enabled = value
        if s.AntiReach._State then s.AntiReach._State.Status = value and "READY" or "OFF" end
    end })
    antiReachSec:AddDropdown({ Name = "Mode", Values = { "Legit", "Adaptive", "HvH" }, Default = s.AntiReach.Mode, Flag = "antireach_mode", Callback = function(v) s.AntiReach.Mode = v end })
    antiReachSec:AddToggle({ Name = "NoSteal keeper", Default = s.AntiReach.NoStealKeeper, Flag = "antireach_nosteal", Callback = function(v) s.AntiReach.NoStealKeeper = v end })
    antiReachSec:AddToggle({ Name = "Reject hostile mag", Default = s.AntiReach.RejectMag, Flag = "antireach_reject", Callback = function(v) s.AntiReach.RejectMag = v end })
    antiReachSec:AddToggle({ Name = "Persistent recovery", Default = s.AntiReach.Persistent, Flag = "antireach_persistent", Callback = function(v) s.AntiReach.Persistent = v end })
    antiReachSec:AddToggle({ Name = "Adapt to ping", Default = s.AntiReach.PingBoost, Flag = "antireach_ping", Callback = function(v) s.AntiReach.PingBoost = v end })
    antiReachSec:AddToggle({ Name = "Teammate safety", Default = s.AntiReach.TeamSafety, Flag = "antireach_team", Callback = function(v) s.AntiReach.TeamSafety = v end })

    local mixSec = DefensePage:AddSection({ Title = "Auto Mix", Side = "Right" })
    mixSec:AddToggle({ Name = "Enable Auto Mix", Default = s.AutoMix.Enabled, Flag = "automix_toggle", Callback = function(v) s.AutoMix.Enabled = v end })
    mixSec:AddDropdown({ Name = "Mode", Values = { "Smart Mix", "All Moves", "Spin Left", "Spin Right", "Spin Chain", "Spin Fake" }, Default = s.AutoMix.Mode, Flag = "automix_mode", Callback = function(v)
        s.AutoMix.Mode = v
        local rt = s.AutoMix._Runtime
        if rt then rt.Sequence = {}; rt.SequenceIndex = 1; rt.NextAt = os.clock() + 0.10 end
    end })
    mixSec:AddToggle({ Name = "Body first", Default = s.AutoMix.BodyFirst, Flag = "automix_bodyfirst", Callback = function(v) s.AutoMix.BodyFirst = v end })
    mixSec:AddToggle({ Name = "Manual Handles only (F/G)", Default = s.AutoMix.ManualHandles, Flag = "automix_manual", Callback = function(v)
        s.AutoMix.ManualHandles = v
        if not v then local rt = s.AutoMix._Runtime; if rt then rt.Sequence = {}; rt.SequenceIndex = 1 end end
    end })
    mixSec:AddToggle({ Name = "Learn defender habits", Default = s.AutoMix.Adaptive, Flag = "automix_adaptive", Callback = function(v)
        s.AutoMix.Adaptive = v
        local rt = s.AutoMix._Runtime
        if rt and not v then table.clear(rt.DefenderProfiles); rt.DefenderRead = "--" end
    end })
    mixSec:AddToggle({ Name = "Chain counters", Default = s.AutoMix.Combo, Flag = "automix_combo", Callback = function(v) s.AutoMix.Combo = v end })
    mixSec:AddToggle({ Name = "Move variety", Default = s.AutoMix.MoveVariety, Flag = "automix_variety", Callback = function(v) s.AutoMix.MoveVariety = v end })
    mixSec:AddToggle({ Name = "Rear spin block", Default = s.AutoMix.RearSpinBlock, Flag = "automix_rearblock", Callback = function(v) s.AutoMix.RearSpinBlock = v end })
    mixSec:AddSlider({ Name = "Preferred defender gap", Min = 5, Max = 12, Default = s.AutoMix.PreferredDistance, Increment = 0.1, Flag = "automix_gap", Callback = function(v) s.AutoMix.PreferredDistance = v end })
    mixSec:AddSlider({ Name = "Emergency distance", Min = 3.5, Max = 9, Default = s.AutoMix.EmergencyDistance, Increment = 0.1, Flag = "automix_emergency", Callback = function(v) s.AutoMix.EmergencyDistance = v end })
    mixSec:AddSlider({ Name = "Ball safety margin", Min = 1.5, Max = 5, Default = s.AutoMix.BallSafetyMargin, Increment = 0.1, Flag = "automix_margin", Callback = function(v) s.AutoMix.BallSafetyMargin = v end })
    mixSec:AddSlider({ Name = "Post-move cooldown", Min = 0.08, Max = 0.8, Default = s.AutoMix.PostMoveCooldown, Increment = 0.02, Flag = "automix_cooldown", Callback = function(v) s.AutoMix.PostMoveCooldown = v end })
    mixSec:AddSlider({ Name = "Decision hold", Min = 0.04, Max = 0.35, Default = s.AutoMix.DecisionHold, Increment = 0.02, Flag = "automix_hold", Callback = function(v) s.AutoMix.DecisionHold = v end })
    mixSec:AddSlider({ Name = "Spin degrees", Min = 90, Max = 1080, Default = s.AutoMix.SpinDegrees, Increment = 90, Flag = "automix_degrees", Callback = function(v) s.AutoMix.SpinDegrees = v end })

    local headRideSec = DefensePage:AddSection({ Title = "Head Ride", Side = "Right" })
    headRideSec:AddToggle({ Name = "Head Ride", Default = s.HeadRide.Enabled, Flag = "headride_toggle", Callback = function(v)
        s.HeadRide.Enabled = v
        if v then enableHeadRide() else disableHeadRide() end
    end })
    headRideSec:AddToggle({ Name = "Only Arm In Match", Default = s.HeadRide.OnlyArmInMatch, Flag = "headride_onlyarmmatch", Callback = function(v) s.HeadRide.OnlyArmInMatch = v end })
    headRideSec:AddToggle({ Name = "Teammate safety", Default = s.HeadRide.TeamSafety, Flag = "headride_teamsafety", Callback = function(v) s.HeadRide.TeamSafety = v end })
    headRideSec:AddToggle({ Name = "Manual override (WASD cancels)", Default = s.HeadRide.ManualOverride, Flag = "headride_override", Callback = function(v) s.HeadRide.ManualOverride = v end })

    local ankleSec = DefensePage:AddSection({ Title = "Ankles Reach", Side = "Right" })
    ankleSec:AddToggle({ Name = "Enable Ankles Reach", Default = s.AnklesReach.Enabled, Flag = "ankles_toggle", Callback = function(v) s.AnklesReach.Enabled = v end })
    ankleSec:AddSlider({ Name = "Radius", Min = 1, Max = 20, Default = s.AnklesReach.Radius, Increment = 1, Flag = "ankles_radius", Callback = function(v) s.AnklesReach.Radius = v end })
    ankleSec:AddToggle({ Name = "Reach Button", Default = s.AnklesReach.ReachButton or false, Flag = "ankles_mobilebutton", Callback = function(v) s.AnklesReach.ReachButton = v end })


    local ballSec = DefensePage:AddSection({ Title = "Ball Magnet / Reach", Side = "Left" })
    local magnetToggle = ballSec:AddToggle({
        Name = "Ball magnet",
        Default = s.Ball.BallMags,
        Flag = "ball_mags",
        Keybind = { Default = Enum.KeyCode.M, Mode = "Toggle" },
        Callback = function(value)
            s.Ball.BallMags = value
            if value then enableMagnet() else disableMagnet() end
        end
    })
    uiToggles.magnet = magnetToggle
    ballSec:AddToggle({ Name = "Magnet Button", Default = s.Ball.MagnetButton or false, Flag = "ball_mobilebutton", Callback = function(v) s.Ball.MagnetButton = v end })
    ballSec:AddSlider({ Name = "Magnet size", Min = 1, Max = 50, Default = s.Ball.BallMagRange, Increment = 0.1, Flag = "ball_magrange", Callback = function(v)
        s.Ball.BallMagRange = v
        if magnetHitbox then magnetHitbox.Size = Vector3.new(v, v, v) end
    end })
    ballSec:AddToggle({ Name = "Show magnet visualizer", Default = s.Ball.BallMagVisualizer, Flag = "ball_visualizer", Callback = function(v)
        s.Ball.BallMagVisualizer = v
        if magnetHitbox then magnetHitbox.Transparency = v and 0.65 or 1 end
    end })
    local reachToggle = ballSec:AddToggle({
        Name = "Ball reach",
        Default = s.Ball.BallReach,
        Flag = "ball_reach",
        Keybind = { Default = Enum.KeyCode.N, Mode = "Toggle" },
        Callback = function(value)
            s.Ball.BallReach = value
            if value then enableReach() else disableReach() end
        end
    })
    uiToggles.reach = reachToggle
    ballSec:AddToggle({ Name = "Smart reach", Default = s.Ball.SmartReach, Flag = "ball_smart_reach", Callback = function(v) s.Ball.SmartReach = v end })
    ballSec:AddSlider({ Name = "Reach size", Min = 1, Max = 30, Default = s.Ball.BallReachRange or 10, Increment = 0.1, Flag = "ball_reachrange", Callback = function(v) s.Ball.BallReachRange = v end })
    ballSec:AddToggle({ Name = "Show reach visualizer", Default = s.Ball.BallReachVisualizer, Flag = "ball_reach_visualizer", Callback = function(v)
        s.Ball.BallReachVisualizer = v
        if v then enableReach() else removeReachHitbox(); if not s.Ball.BallReach then disableReach() end end
    end })

    local speedSec = DefensePage:AddSection({ Title = "Speed Boost", Side = "Right" })
    speedSec:AddToggle({ Name = "Speed boost", Default = s.Player.Walkspeed, Flag = "player_ws", Callback = function(value)
        s.Player.Walkspeed = value
        if value then enableSpeedBoost() else disableSpeedBoost() end
    end })
    speedSec:AddSlider({ Name = "Speed multiplier", Min = 1, Max = 2.5, Default = s.Player.WSvalue, Increment = 0.05, Flag = "player_wsvalue", Callback = function(v) s.Player.WSvalue = v end })

    end

    do
    local VisualizeTab = Window:AddTab({ Name = "Visualize", Icon = "globe" })
    local VisualizePage = VisualizeTab:AddPage({ Name = "Visuals" })

	local courtSec = VisualizePage:AddSection({ Title = "Court Skin Spoofer", Side = "Left" })
local courtOptions = CourtSpoofer:GetOptions()
local courtDropdown
courtDropdown = courtSec:AddDropdown({
    Name = "Court skin",
    Values = courtOptions,
    Default = "CourtSkin_Default",
    Flag = "courtskin_name",
    Callback = function(v) CourtSpoofer:SetSkin(v) end,
})
courtSec:AddToggle({
    Name = "Enable court skin preview",
    Default = false,
    Flag = "courtskin_enabled",
    Callback = function(v) CourtSpoofer:SetEnabled(v) end,
})
courtSec:AddButton({
    Name = "Refresh skin list",
    Text = "Refresh",
    Callback = function()
        local opts = CourtSpoofer:GetOptions()
        pcall(function() courtDropdown:SetValues(opts) end)
    end,
})

local streakSec = VisualizePage:AddSection({ Title = "Streak Spoofer", Side = "Right" })
streakSec:AddToggle({
    Name = "Enable streak spoof",
    Default = false,
    Flag = "streak_enabled",
    Callback = function(v) StreakSpoofer:SetEnabled(v) end,
})
streakSec:AddSlider({
    Name = "Streak value",
    Min = 0, Max = 999999, Default = 25, Increment = 1,
    Flag = "streak_value",
    Callback = function(v) StreakSpoofer:SetValue(v) end,
})
streakSec:AddButton({
    Name = "Apply now",
    Text = "Apply",
    Callback = function() StreakSpoofer:Apply() end,
})

local avatarSec = VisualizePage:AddSection({ Title = "Avatar Spoofer", Side = "Left" })
avatarSec:AddToggle({
    Name = "Headless",
    Default = s.Visuals.HeadlessSpoof,
    Flag = "visual_headless_spoof",
    Callback = function(value)
        s.Visuals.HeadlessSpoof = value == true
        applyLocalAvatarSpoofs()
    end,
})
avatarSec:AddToggle({
    Name = "Korblox leg",
    Default = s.Visuals.KorbloxSpoof,
    Flag = "visual_korblox_spoof",
    Callback = function(value)
        s.Visuals.KorbloxSpoof = value == true
        applyLocalAvatarSpoofs()
    end,
})

    local goalSec = VisualizePage:AddSection({ Title = "Goal Effect Changer", Side = "Left" })
    goalSec:AddDropdown({ Name = "Select effect", Values = #EffectNames > 0 and EffectNames or {"None"}, Default = s.Goal.SelectedEffect or "LightRay", Flag = "goal_effect_select", Callback = function(v)
        s.Goal.SelectedEffect = v; s.Goal.CurrentEffect = v
        if s.Goal.Enabled then pcall(applyGoalEffect) end
    end })
    goalSec:AddToggle({ Name = "Enable goal effect changer", Default = s.Goal.Enabled, Flag = "goal_effect_toggle", Callback = function(v)
        s.Goal.Enabled = v
        if v then pcall(applyGoalEffect) else pcall(resetGoalEffect) end
    end })
    goalSec:AddButton({ Name = "Reset to default effect", Text = "Reset", Callback = function()
        s.Goal.Enabled = false; s.Goal.SelectedEffect = "LightRay"; s.Goal.CurrentEffect = "LightRay"; pcall(resetGoalEffect)
    end })

    local ballChangerSec = VisualizePage:AddSection({ Title = "Ball Changer", Side = "Right" })
    ballChangerSec:AddDropdown({ Name = "Select ball", Values = #BallNames > 0 and BallNames or {"None"}, Default = s.BallChanger.SelectedBall or "ForceField", Flag = "ball_changer_select", Callback = function(v)
        s.BallChanger.SelectedBall = v; s.BallChanger.CurrentBall = v
        if s.BallChanger.Enabled then pcall(applyBallChanger) end
    end })
    ballChangerSec:AddToggle({ Name = "Enable ball changer", Default = s.BallChanger.Enabled, Flag = "ball_changer_toggle", Callback = function(v)
        s.BallChanger.Enabled = v
        if v then pcall(applyBallChanger) else pcall(resetBallChanger) end
    end })
    ballChangerSec:AddButton({ Name = "Reset to default ball", Text = "Reset", Callback = function()
        s.BallChanger.Enabled = false; s.BallChanger.SelectedBall = "ForceField"; s.BallChanger.CurrentBall = "ForceField"; pcall(resetBallChanger)
    end })

    local trailSec = VisualizePage:AddSection({ Title = "Ball Trail Changer", Side = "Right" })
    trailSec:AddDropdown({ Name = "Select trail", Values = #TrailNames > 0 and TrailNames or {"None"}, Default = s.TrailChanger.SelectedTrail or "None", Flag = "trail_select", Callback = function(v)
        s.TrailChanger.SelectedTrail = v; s.TrailChanger.CurrentTrail = v
        if s.TrailChanger.Enabled then applyTrailToAllBalls() end
    end })
    local trailToggle = trailSec:AddToggle({ Name = "Enable trail changer", Default = s.TrailChanger.Enabled, Flag = "trail_toggle", Callback = function(v)
        s.TrailChanger.Enabled = v
        if v then applyTrailToAllBalls() else resetTrailOnAllBalls() end
    end })
    uiToggles.trail = trailToggle
    trailSec:AddButton({ Name = "Reset to default trail", Text = "Reset", Callback = function()
        s.TrailChanger.Enabled = false; s.TrailChanger.SelectedTrail = "None"; s.TrailChanger.CurrentTrail = "None"
        resetTrailOnAllBalls()
        if uiToggles.trail then uiToggles.trail:Set(false) end
    end })

    local auraSec = VisualizePage:AddSection({ Title = "Aura Changer", Side = "Left" })
    auraSec:AddDropdown({ Name = "Select aura", Values = AuraNames, Default = s.Aura.SelectedAura or "None", Flag = "aura_select", Callback = function(v)
        s.Aura.SelectedAura = v
        if s.Aura.Enabled and v ~= "None" then
            for _, aura in AuraList do if aura.Name == v then pcall(function() ApplyAura(aura) end); break end end
        elseif v == "None" then pcall(RemoveAura) end
    end })
    auraSec:AddToggle({ Name = "Enable aura", Default = s.Aura.Enabled, Flag = "aura_toggle", Callback = function(v)
        s.Aura.Enabled = v
        if v and s.Aura.SelectedAura ~= "None" then
            for _, aura in AuraList do if aura.Name == s.Aura.SelectedAura then pcall(function() ApplyAura(aura) end); break end end
        else pcall(RemoveAura) end
    end })
    auraSec:AddButton({ Name = "Remove aura", Text = "Remove", Callback = function()
        s.Aura.Enabled = false; s.Aura.SelectedAura = "None"; pcall(RemoveAura)
    end })

    local avatarSec = VisualizePage:AddSection({ Title = "Avatar Changer", Side = "Left" })
    local playerDropdown = avatarSec:AddDropdown({ Name = "Select player", Values = getInGamePlayerNames(), Default = s.AvatarChanger.SelectedPlayer or "None", Flag = "avatar_player_select", Callback = function(v) s.AvatarChanger.SelectedPlayer = v end })
    avatarSec:AddButton({ Name = "Refresh Player List", Text = "Refresh", Callback = function()
        local names = getInGamePlayerNames()
        if playerDropdown and playerDropdown.Refresh then pcall(function() playerDropdown:Refresh(names) end)
        elseif playerDropdown and playerDropdown.SetValues then pcall(function() playerDropdown:SetValues(names) end) end
        notify("Player List Refreshed", "Found " .. tostring(#names) .. " player(s)", "info", 2)
    end })
    avatarSec:AddButton({ Name = "Copy Selected Avatar", Text = "Copy", Callback = function()
        local ok, info = copyAvatarFromSelected()
        if ok then notify("Avatar Copied", "Equipped avatar of " .. tostring(info), "success", 3)
        else notify("Avatar Error", tostring(info or "Failed to copy avatar"), "error", 3) end
    end })
    avatarSec:AddTextBox({ Name = "Custom Username / UserId", Default = s.AvatarChanger.CustomUser or "", Placeholder = "Username or UserId", Flag = "avatar_custom_user", Callback = function(text) s.AvatarChanger.CustomUser = text end })
    avatarSec:AddButton({ Name = "Copy Custom Avatar", Text = "Copy", Callback = function()
        local ok, info = copyAvatarFromCustom()
        if ok then notify("Avatar Copied", "Equipped avatar of " .. tostring(info), "success", 3)
        else notify("Avatar Error", tostring(info or "Failed to copy custom avatar"), "error", 3) end
    end })
    avatarSec:AddButton({ Name = "Reset to Original Avatar", Text = "Reset", Callback = function()
        local ok = resetAvatar()
        if ok then notify("Avatar Reset", "Restored your original avatar", "success", 3)
        else notify("Avatar Reset Error", "Could not restore original avatar", "error", 3) end
    end })

    local otherVisSec = VisualizePage:AddSection({ Title = "Other Visuals", Side = "Right" })
    otherVisSec:AddToggle({ Name = "ArrayList", Default = s.Visuals.ArrayList, Flag = "vis_arraylist", Callback = function(v)
        s.Visuals.ArrayList = v; task.defer(function() pcall(updateArrayList) end)
    end })
    otherVisSec:AddColorPicker({ Name = "ArrayList Color", Default = Color3.fromRGB(179, 165, 255), Flag = "vis_arraylist_color", Callback = function(color)
        if setArrayListAccent then setArrayListAccent(color) end
    end })
    otherVisSec:AddToggle({ Name = "Visualize ball trajectory", Default = s.Visuals.VisualizeBallProjectory, Flag = "vis_trajectory", Callback = function(v) s.Visuals.VisualizeBallProjectory = v end })
    otherVisSec:AddDropdown({ Name = "Trajectory color", Values = { "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "White", "Rainbow" }, Default = s.Visuals.ProjectoryColor, Flag = "vis_trajcolor", Callback = function(v) s.Visuals.ProjectoryColor = v end })
    otherVisSec:AddToggle({ Name = "Aimbot range indicator", Default = s.Visuals.ShotIndicator, Flag = "vis_shotindicator", Callback = function(value)
        s.Visuals.ShotIndicator = value
        if rangeConnection then rangeConnection:Disconnect(); rangeConnection = nil end
        indicator.Parent = nil
        if value then
            local rangeThrottle = 0
            rangeConnection = RunService.Heartbeat:Connect(function(dt)
                rangeThrottle += dt
                if rangeThrottle < 0.05 then return end
                rangeThrottle = 0
                local character = LocalPlayer.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if not root or not hasball(character) then indicator.Parent = nil; return end
                local inRange = false
                if s.Shooting.Mode == "Fatal" or s.Shooting.FatalEnabled then
                    local rim, dist = fatalState.cachedrim, fatalState.cacheddist
                    if not rim or dist == math.huge then rim, dist = nearestrim(root.Position) end
                    if rim and dist then
                        local minDist = s.Shooting.ThreesOnly and 55 or FATAL_MIN_DIST
                        local _, tablePower = getTableShot(dist)
                        if dist >= minDist and (dist <= AURAL_MAX_DIST or tablePower) then inRange = true end
                    end
                else
                    local goal, distance = nearestgoal(root)
                    local minDist = isMobile and 30 or AURAL_MIN_DIST
                    local _, tablePower = getTableShot(distance)
                    if goal and distance >= minDist and (distance <= AURAL_MAX_DIST or tablePower) then inRange = true end
                end
                if inRange then
                    applyIndicatorColor()
                    if indicator.Parent ~= character then indicator.Adornee = character; indicator.Parent = character end
                else indicator.Parent = nil end
            end)
        end
    end })
    otherVisSec:AddDropdown({ Name = "Indicator color", Values = { "Blue", "Lavender", "Purple", "Green", "Red", "Yellow", "Orange", "Pink", "White" }, Default = s.Visuals.IndicatorColor or "Blue", Flag = "vis_indicatorcolor", Callback = function(v)
        s.Visuals.IndicatorColor = v; applyIndicatorColor()
    end })
    otherVisSec:AddToggle({ Name = "Show hoop distance above head", Default = s.Visuals.HoopDistance, Flag = "vis_hoopdist", Callback = function(v)
        s.Visuals.HoopDistance = v
        if v then startHoopDistance() else stopHoopDistance() end
    end })
    otherVisSec:AddDropdown({ Name = "Hoop distance color", Values = { "White", "Blue", "Lavender", "Purple", "Green", "Red", "Yellow", "Orange", "Pink" }, Default = s.Visuals.HoopDistanceColor or "White", Flag = "vis_hoopdistcolor", Callback = function(v)
        s.Visuals.HoopDistanceColor = v
        if hoopDistanceLabel then hoopDistanceLabel.TextColor3 = IndicatorColors[v] or Color3.fromRGB(255, 255, 255) end
    end })
    otherVisSec:AddSlider({ Name = "Hoop distance transparency", Min = 0.1, Max = 1, Default = s.Visuals.HoopDistanceTransparency or 0.6, Increment = 0.05, Flag = "vis_hoopdisttransparency", Callback = function(v)
        s.Visuals.HoopDistanceTransparency = v
        if hoopDistanceLabel then hoopDistanceLabel.TextTransparency = 1 - v end
    end })
    otherVisSec:AddToggle({ Name = "Hide player tags", Default = s.Visuals.HidePlayerTags, Flag = "vis_hidetags", Callback = function(v)
        s.Visuals.HidePlayerTags = v
        if v then startHideTags() else stopHideTags() end
    end })

        local uiSection1 = VisualizePage:AddSection({ Title = "Nameplate & Title", Side = "Right" })
        uiSection1:AddToggle({ Name = "Hide my nameplate & tags", Default = s.Visuals.HideOwnNameplate, Flag = "vis_hideownnameplate", Callback = function(v)
            s.Visuals.HideOwnNameplate = v; applyOwnNameplate()
        end })
        uiSection1:AddTextBox({ Name = "Custom Username", Default = s.Visuals.CustomNameText or "", Placeholder = "e.g. Aural", Flag = "vis_customname_text", Callback = function(text)
            s.Visuals.CustomNameText = text; s.Visuals.CustomName = (text ~= ""); applyOwnNameplate()
        end })
        uiSection1:AddTextBox({ Name = "Custom Record / Stats", Default = s.Visuals.CustomRecordText or "", Placeholder = "e.g. 99-0", Flag = "vis_customrecord_text", Callback = function(text)
            s.Visuals.CustomRecordText = text; s.Visuals.CustomRecord = (text ~= ""); applyOwnNameplate()
        end })
        uiSection1:AddTextBox({ Name = "Custom Achievement", Default = s.Visuals.CustomTitleText or "", Placeholder = "e.g. Elite Shooter", Flag = "vis_customtitle_text", Callback = function(text)
            s.Visuals.CustomTitleText = text; s.Visuals.CustomTitle = (text ~= ""); applyOwnNameplate()
        end })
        uiSection1:AddToggle({ Name = "Custom rank", Default = s.Visuals.CustomRank, Flag = "vis_customrank", Callback = function(v)
            s.Visuals.CustomRank = v
            if v then LocalPlayer:SetAttribute("ELO", rankelo[s.Visuals.CustomRankChoice or "Rookie 1"]); applycustomrank() end
        end })
        uiSection1:AddDropdown({ Name = "Custom rank choice", Values = {
            "Rookie 1","Rookie 2","Rookie 3","Veteran 1","Veteran 2","Veteran 3",
            "Elite 1","Elite 2","Elite 3","Pro 1","Pro 2","Pro 3",
            "All-star 1","All-star 2","All-star 3","Superstar 1","Superstar 2","Superstar 3",
            "Phenom 1","Phenom 2","Phenom 3","Legend 1","Legend 2","Legend 3",
            "Mamba 1","Mamba 2","Mamba 3","HoF 1","HoF 2","HoF 3",
            "G.O.A.T 1","G.O.A.T 2","G.O.A.T 3","Aura 1","Aura 2","Aura 3"
        }, Default = s.Visuals.CustomRankChoice or "Rookie 1", Flag = "vis_customrankchoice", Callback = function(v)
            s.Visuals.CustomRankChoice = v
            if s.Visuals.CustomRank then LocalPlayer:SetAttribute("ELO", rankelo[v]); applycustomrank() end
        end })

    end

    do
        local PrivacyTab = Window:AddTab({ Name = "Privacy", Icon = "user" })
    local PrivacyPage = PrivacyTab:AddPage({ Name = "Local Spoof" })

    local uiSection2 = PrivacyPage:AddSection({ Title = "Local Anonymizer", Side = "Left" })
        uiSection2:AddToggle({ Name = "Enable anonymizer", Default = s.LocalAnonymizer.Enabled, Flag = "anon_toggle", Callback = function(v) s.LocalAnonymizer._Set(v, s.LocalAnonymizer.Alias) end })
        uiSection2:AddTextBox({ Name = "Alias", Default = s.LocalAnonymizer.Alias, Placeholder = "Aural V2", Flag = "anon_alias", Callback = function(text) s.LocalAnonymizer._Set(s.LocalAnonymizer.Enabled, text) end })

    local uiSection3 = PrivacyPage:AddSection({ Title = "Clan Tag / Chat Tag", Side = "Left" })
        uiSection3:AddToggle({ Name = "Enable clan tag spoof", Default = s.ClanTag.Enabled, Flag = "clan_toggle", Callback = function(v) s.ClanTag.Enabled = v; s.ClanTag._Apply() end })
        uiSection3:AddTextBox({ Name = "Clan tag", Default = s.ClanTag.Tag, Placeholder = "GEH", Flag = "clan_tag", Callback = function(text) s.ClanTag.Tag = text; s.ClanTag._Apply() end })
        uiSection3:AddTextBox({ Name = "Color (#RRGGBB)", Default = s.ClanTag.Color, Placeholder = "#FF3BD5", Flag = "clan_color", Callback = function(text) s.ClanTag.Color = text; s.ClanTag._Apply() end })
        uiSection3:AddToggle({ Name = "Enable chat tag spoof", Default = s.ChatTag.Enabled, Flag = "chattag_toggle", Callback = function(v) s.ChatTag.Enabled = v; s.ClanTag._Apply() end })

    local uiSection4 = PrivacyPage:AddSection({ Title = "Logo Badges", Side = "Right" })
        uiSection4:AddToggle({ Name = "VIP", Default = s.LogoBadges.VIP, Flag = "logo_vip", Callback = function(v) s.LogoBadges.VIP = v end })
        uiSection4:AddToggle({ Name = "YouTube", Default = s.LogoBadges.Youtuber, Flag = "logo_yt", Callback = function(v) s.LogoBadges.Youtuber = v end })
        uiSection4:AddToggle({ Name = "Twitch", Default = s.LogoBadges.Twitch, Flag = "logo_twitch", Callback = function(v) s.LogoBadges.Twitch = v end })
        uiSection4:AddToggle({ Name = "Booster", Default = s.LogoBadges.Booster, Flag = "logo_booster", Callback = function(v) s.LogoBadges.Booster = v end })
        uiSection4:AddToggle({ Name = "Tester", Default = s.LogoBadges.Tester, Flag = "logo_tester", Callback = function(v) s.LogoBadges.Tester = v end })
        uiSection4:AddToggle({ Name = "Staff", Default = s.LogoBadges.Staff, Flag = "logo_staff", Callback = function(v) s.LogoBadges.Staff = v end })
        uiSection4:AddTextBox({ Name = "Custom asset IDs (comma-separated)", Default = table.concat(s.LogoBadges.CustomIds, ","), Placeholder = "12345,67890", Flag = "logo_custom_ids", Callback = function(text)
            local ids = {}
            for n in string.gmatch(text, "%d+") do table.insert(ids, tonumber(n)) end
            s.LogoBadges.CustomIds = ids
        end })

    local uiSection5 = PrivacyPage:AddSection({ Title = "Wallet Spoof", Side = "Right" })
        uiSection5:AddToggle({ Name = "Enable wallet spoof", Default = s.WalletSpoof.Enabled, Flag = "wallet_toggle", Callback = function(v) s.WalletSpoof.Enabled = v; s.WalletSpoof._Apply() end })
        uiSection5:AddSlider({ Name = "Money", Min = 0, Max = 100000000, Default = s.WalletSpoof.Money, Increment = 1000, Flag = "wallet_money", Callback = function(v) s.WalletSpoof.Money = v end })
        uiSection5:AddSlider({ Name = "Spins", Min = 0, Max = 9999, Default = s.WalletSpoof.Spins, Increment = 1, Flag = "wallet_spins", Callback = function(v) s.WalletSpoof.Spins = v end })
        uiSection5:AddSlider({ Name = "Crates", Min = 0, Max = 9999, Default = s.WalletSpoof.Crates, Increment = 1, Flag = "wallet_crates", Callback = function(v) s.WalletSpoof.Crates = v end })
        uiSection5:AddSlider({ Name = "Boosts", Min = 0, Max = 9999, Default = s.WalletSpoof.Boosts, Increment = 1, Flag = "wallet_boosts", Callback = function(v) s.WalletSpoof.Boosts = v end })
        uiSection5:AddSlider({ Name = "Clan coins", Min = 0, Max = 100000000, Default = s.WalletSpoof.ClanCoins, Increment = 1000, Flag = "wallet_clancoins", Callback = function(v) s.WalletSpoof.ClanCoins = v end })
        uiSection5:AddSlider({ Name = "Event currency", Min = 0, Max = 1000000, Default = s.WalletSpoof.EventCurrency, Increment = 100, Flag = "wallet_event", Callback = function(v) s.WalletSpoof.EventCurrency = v end })
        uiSection5:AddSlider({ Name = "Battlepass level", Min = 0, Max = 200, Default = s.WalletSpoof.BattlepassLevel, Increment = 1, Flag = "wallet_bp", Callback = function(v) s.WalletSpoof.BattlepassLevel = v end })
    end

    do
    local UtilityTab = Window:AddTab({ Name = "Utility", Icon = "wrench" })
    local UtilityPage = UtilityTab:AddPage({ Name = "Utility" })

	local perfSec = UtilityPage:AddSection({ Title = "Auto Performance", Side = "Left" })
perfSec:AddToggle({
    Name = "Auto performance mode",
    Default = false,
    Flag = "autoperf_enabled",
    Callback = function(v) AutoPerf:SetEnabled(v) end,
})
perfSec:AddSlider({
    Name = "Reduce below FPS",
    Min = 10, Max = 120, Default = 38, Increment = 1,
    Flag = "autoperf_low",
    Callback = function(v) AutoPerf:SetThresholds(v, nil) end,
})
perfSec:AddSlider({
    Name = "Restore above FPS",
    Min = 30, Max = 240, Default = 52, Increment = 1,
    Flag = "autoperf_restore",
    Callback = function(v) AutoPerf:SetThresholds(nil, v) end,
})
perfSec:AddButton({
    Name = "Force performance now",
    Text = "Apply",
    Callback = function() AutoPerf:Apply() end,
})
perfSec:AddButton({
    Name = "Restore graphics",
    Text = "Restore",
    Callback = function() AutoPerf:Restore() end,
})

    local autoSec = UtilityPage:AddSection({ Title = "Auto Queue", Side = "Left" })
    autoSec:AddToggle({ Name = "Auto queue", Default = s.Automatics.AutoQueue, Flag = "auto_queue", Callback = function(v)
        s.Automatics.AutoQueue = v
        if v then startAutoQueue() else stopAutoQueue() end
    end })
    autoSec:AddToggle({ Name = "Queue almost finished", Default = s.Automatics.QueueAlmostFinished, Flag = "auto_finished", Callback = function(v) s.Automatics.QueueAlmostFinished = v end })
    autoSec:AddToggle({ Name = "Requeue after games", Default = s.Automatics.AutoQueueAfterGames, Flag = "auto_requeue", Callback = function(v) s.Automatics.AutoQueueAfterGames = v end })
    autoSec:AddDropdown({ Name = "Join type", Values = { "Teleport", "Walk" }, Default = s.Automatics.JoinType, Flag = "auto_jointype", Callback = function(v) s.Automatics.JoinType = v end })
    autoSec:AddToggle({ Name = "Auto dunk", Default = s.Automatics.AutoDunk, Flag = "auto_dunk", Callback = function(v)
        s.Automatics.AutoDunk = v
        if v then enableautodunk() else disableautodunk() end
    end })

    local travelingSec = UtilityPage:AddSection({ Title = "Traveling", Side = "Left" })
    travelingSec:AddButton({ Name = "Teleport to 2s", Text = "Teleport to 2s", Callback = function()
        local c = LocalPlayer.Character; if c then c:PivotTo(CFrame.new(391, 55, -459)) end
    end })
    travelingSec:AddButton({ Name = "Teleport to 3s", Text = "Teleport to 3s", Callback = function()
        local c = LocalPlayer.Character; if c then c:PivotTo(CFrame.new(6, 58, -736)) end
    end })
    travelingSec:AddButton({ Name = "Teleport to Practice", Text = "Teleport to Practice", Callback = function()
        local c = LocalPlayer.Character; if c then c:PivotTo(CFrame.new(392, 54, -981)) end
    end })
    travelingSec:AddButton({ Name = "Teleport to Spawn", Text = "Teleport to Spawn", Callback = function()
        local c = LocalPlayer.Character; if c then c:PivotTo(CFrame.new(387, 40, -736)) end
    end })

    local RepSec = UtilityPage:AddSection({ Title = "Calculation", Side = "Left" })
    RepSec:AddToggle({ Name = "Auto calculate rep", Default = s.Rep.AutoCalculateRep, Flag = "rep_autocalc", Callback = function(v)
        s.Rep.AutoCalculateRep = v
        if v then startAutoRepCalc() else stopAutoRepCalc() end
    end })

    local specSec = UtilityPage:AddSection({ Title = "Spectating", Side = "Left" })
    SpecWatch.RefreshOptions()
    local specCourtDropdown = specSec:AddDropdown({ Name = "Match", Values = SpecWatch.CourtOptions, Default = "Auto Live Match", Flag = "spectate_court", Callback = function(v) SpecWatch.SetCourt(v) end })
    specSec:AddButton({ Name = "Refresh matches", Text = "Refresh", Callback = function()
        SpecWatch.RefreshOptions()
        pcall(function() specCourtDropdown:Refresh(SpecWatch.CourtOptions) end)
    end })
    specSec:AddDropdown({ Name = "Camera mode", Values = SpecWatch.CameraModes, Default = SpecWatch.Mode, Flag = "spectate_mode", Callback = function(v) SpecWatch.SetMode(v) end })
    specSec:AddButton({ Name = "Spectate match", Text = "Watch", Callback = function()
        SpecWatch.SetActive(false); SpecWatch.SetActive(true)
        notify("Spectate", SpecWatch.Active and (SpecWatch.Status .. " | " .. SpecWatch.PlayerSummary) or SpecWatch.Status, SpecWatch.Active and "info" or "warning", 3)
    end })
    specSec:AddButton({ Name = "Stop spectating", Text = "Stop", Callback = function() SpecWatch.SetActive(false) end })

    local miscSec = UtilityPage:AddSection({ Title = "Miscellaneous", Side = "Right" })
    miscSec:AddToggle({ Name = "Anti moderator", Default = s.Misc.AntiModerator, Flag = "misc_mod", Callback = function(value)
        s.Misc.AntiModerator = value
        if value then
            task.spawn(function()
                local detected = {}
                while s.Misc.AntiModerator do
                    task.wait(1)
                    for _, moderator in next, Players:GetPlayers() do
                        if table.find(Moderators, moderator.Name) and not detected[moderator.UserId] then
                            detected[moderator.UserId] = true
                            if s.Misc.Type == "Kick" then
                                LocalPlayer:Kick("moderator detected: " .. moderator.Name)
                            elseif s.Misc.Type == "Notify" then
                                notify("moderator detected", "Moderator name: " .. moderator.Name .. " | remember to play carefully.", "warning", 5)
                            end
                        end
                    end
                end
            end)
        end
    end })
    miscSec:AddDropdown({ Name = "Mod detection type", Values = { "Notify", "Kick" }, Default = s.Misc.Type, Flag = "misc_modtype", Callback = function(v) s.Misc.Type = v end })
    miscSec:AddToggle({ Name = "Anti Fall", Default = s.Misc.AntiFall, Flag = "misc_antifall", Callback = function(v)
        s.Misc.AntiFall = v
        if fallconnection then fallconnection:Disconnect(); fallconnection = nil end
        if v then
            local Hum2 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if not Hum2 then return end
            fallconnection = Hum2:GetPropertyChangedSignal("PlatformStand"):Connect(function()
                if Hum2.PlatformStand then Hum2.PlatformStand = false end
            end)
            if Hum2.PlatformStand then Hum2.PlatformStand = false end
        end
    end })
    miscSec:AddToggle({ Name = "Device spoofer", Default = s.Misc.DeviceSpoofer, Flag = "misc_devspoof", Callback = function(v) s.Misc.DeviceSpoofer = v; SpoofDevice() end })
    miscSec:AddDropdown({ Name = "Device", Values = { "PC", "Mobile", "Gamepad" }, Default = s.Misc.Device, Flag = "misc_device", Callback = function(v) s.Misc.Device = v; SpoofDevice() end })
    miscSec:AddToggle({ Name = "Anti Travel", Default = s.AntiTravelHook.Enabled, Flag = "misc_antitravelhook", Callback = function(v) s.AntiTravelHook.Enabled = v end })
    miscSec:AddToggle({ Name = "FPS Cap", Default = s.FPSCap.Enabled, Flag = "misc_fpscap", Callback = function(v) s.FPSCap.Enabled = v; SetAuralFPSCap(v, s.FPSCap.Value) end })
    miscSec:AddSlider({ Name = "FPS limit", Min = 15, Max = 360, Default = s.FPSCap.Value, Increment = 1, Flag = "misc_fpscapvalue", Callback = function(v) s.FPSCap.Value = v; if s.FPSCap.Enabled then SetAuralFPSCap(true, v) end end })

    local serverSec = UtilityPage:AddSection({ Title = "Server", Side = "Right" })
    serverSec:AddButton({ Name = "Rejoin server", Text = "Rejoin", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end })
    serverSec:AddButton({ Name = "Server hop", Text = "Hop", Callback = function()
        local servers = {}
        local cursor = ""
        repeat
            local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end
            local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
            if success and result and result.data then
                for _, server in next, result.data do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then table.insert(servers, server.id) end
                end
                cursor = result.nextPageCursor or ""
            else break end
        until cursor == ""
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LocalPlayer)
        else
            notify("No available servers", "Could not find any available servers.", "warning", 3)
        end
    end })
    serverSec:AddToggle({ Name = "LocalPlayer Server Position", Default = s.Misc.ServerPosition, Flag = "misc_serverpos", Callback = function(v)
        s.Misc.ServerPosition = v; setPredictionEnabled(v)
    end })


    end

    do
    local ConfigsTab = Window:AddTab({ Name = "Configs", Icon = "gear" })
    Window:AddConfigSections(ConfigsTab)

    Window:Notify({ Title = "Aural V2 loaded", Text = "have fun!", Type = "success", Duration = 3 })
    Window:LoadAutoConfig()
    end
end

J:Add(function()
    state.active = false
    pcall(function() if SpecWatch then SpecWatch.SetActive(false) end end)
    pcall(settarget, nil)
    pcall(function() RunService:UnbindFromRenderStep("Server Position Predictor") end)
    pcall(resetBallChanger)
    pcall(resetGoalEffect)
    pcall(function() if HeadRide then HeadRide:SetEnabled(false) end end)
    if headRideConnection then
        pcall(function() headRideConnection:Disconnect() end)
        headRideConnection = nil
    end
    pcall(RemoveAura)
    pcall(function() setoob(false) end)
    pcall(stopHideTags)
    pcall(function() setPredictionEnabled(false) end)
    pcall(resetTrailOnAllBalls)
    pcall(function() if s.FPSCap.Enabled then SetAuralFPSCap(false) end end)
    pcall(function() if s.AutoMix._Runtime then s.AutoMix._Runtime.Busy = false end end)
end, nil, "manual_leftovers")

local deltaTime = os.clock() - startTime
warn("loaded in " .. math.round(deltaTime) .. " seconds.")
