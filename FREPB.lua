local Ophyn = loadstring(game:HttpGet('https://ophyn.space/interface'))()

Ophyn.new({
    -- Window
    Title = "Aural Freemium Key System",
    Description = "Key System",
    Logo = "rbxassetid://98317435813811",
    Theme = "Indigo",
    Folder = "Ophyn-KSY",

    -- Buttons
    getkey = true,
    KeySystem = {
        SaveKey = true,
        API = {
            { -- PandaAuth (Panda Development)
                Type = "panda",
                ServiceId = "auralfree", -- from your Panda dashboard
            },
        },
    },
    -- Intro
    Intro = "true",
    startintro_size = 80,
    squareintro_time = 1.2,

    -- Appearance
    Changelogocolor = true,
    Changeiconscolor = true,
    ChangeTheme = true,
    NotifStyle = "1",
    TabsStyle = "1",

    -- Links
    discord_link = "discord.gg/auralhub",
    website_link = "https://auralhub.xyz",

    -- Cards
    Discord = "true",
    Website = "true",

    -- Games (PlaceId = true)
    SupportedGames = {
        [6229116934] = true,
        [80681221431821] = true,
        [119587547774646] = true,
        [118669925076970] = true,
        [115776365257536] = true,
    },

    Callback = function(key)
        
-- // Config
local Aural = {
	Shooting = {
		PerfectTiming = true,
		AutoCalibrate = false,
		PingCompensation = true,
		PingMultiplier = 100,
		ReleasePoint = 97,
		TimingOffset = -5,

		AutoShoot = false,
		ShootRange = 25,
		RangeCircle = false,
		RangeCircleColor = Color3.fromRGB(255, 92, 146),
	},

	Dribbling = {
		DribbleGlide = false,
		GlideSpeed = 25,

		AutoAnkleBreaker = false,
		AnkleBreakRange = 8,
		AnkleBreakerMove = "Crossover",

		Macros = true,
		ComboMoves = {},
		ComboDelay = 0.05,
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
		InfiniteStamina = false,
		AutoTakeover = false,
		NoColdZone = false,
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
-- // Airflow UI (https://github.com/PookiePepelsss/Airflow-UI)
local Airflow = loadstring(game:HttpGet("https://raw.githubusercontent.com/PookiePepelsss/Airflow-UI/refs/heads/main/Source.luau"))()
if Airflow.Assets then
    Airflow.Assets.Logo = "rbxassetid://98317435813811"
end

-- // Airflow-based Library shim
-- Exposes the same API the menu code uses (ZeroUI-style), bridged to Airflow.
local Library = (function()
    local lib = {
        Name    = "Airflow",
        Version = "1.3.0",
        Folder  = "Aural",
        Flags   = {},
        Elements = {},
        -- Lucide icon name strings; Airflow resolves them automatically
        Icons = {
            Timer    = "timer",
            Target   = "crosshair",
            Dribble  = "activity",
            Combos   = "layers",
            List     = "list",
            Shield   = "shield",
            Guard    = "shield-check",
            Person   = "user",
            Sun      = "sun",
            Settings = "settings",
            Calibrate= "sliders-horizontal",
            Ping     = "wifi",
            Meter    = "gauge",
            Lob      = "send",
            Glide    = "wind",
            Contest  = "swords",
            Jelly    = "sparkles",
            Ankle    = "footprints",
            Move     = "move",
            Gear     = "settings",
        },
        Theme   = {},
        OnUnload = nil,
    }

    local _win  -- set by CreateWindow

    -- Translate our ZeroUI-style opts table into Airflow's field names
    local function xlat(o)
        if type(o) == "string" then return { Name = o } end
        o = o or {}
        local out = {}
        out.Name           = o.Title or o.Name
        out.Desc           = o.Description or o.Desc
        out.Flag           = o.Flag
        out.Callback       = o.Callback
        -- Toggle
        out.CurrentValue   = o.Default
        -- Slider
        out.Range          = (o.Min and o.Max) and { o.Min, o.Max } or nil
        out.Increment      = o.Step
        out.Suffix         = o.Suffix
        -- Dropdown
        out.Options        = o.Options
        out.CurrentOption  = o.Default
        out.MultipleOptions= o.Multi
        out.Placeholder    = o.Placeholder
        -- ColorPicker
        out.Color          = o.Default
        -- Keybind
        local defKey = o.Default
        if typeof(defKey) == "EnumItem" then defKey = defKey.Name end
        out.CurrentKeybind = defKey
        out.OnChanged      = o.ChangedCallback
        -- Style passthrough for buttons
        out.Style          = o.Style
        if o.Risky then out.Style = "Danger" end
        return out
    end

    -- Build a section proxy exposing :AddToggle, :AddSlider, etc.
    local function makeSectionProxy(sec)
        local sp = { _sec = sec }

        function sp:AddToggle(o)
            local x = xlat(o)
            local el = sec:CreateToggle(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            el.Update = function(self2, v) self2:Set(v) end
            return el
        end

        function sp:AddSlider(o)
            local x = xlat(o)
            local el = sec:CreateSlider(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            el.Update = function(self2, v) self2:Set(v) end
            return el
        end

        function sp:AddDropdown(o)
            local x = xlat(o)
            local el = sec:CreateDropdown(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            el.Update = function(self2, v) self2:Set(v) end
            -- Refresh: rebuild option list
            el.Refresh = function(self2, newOpts)
                pcall(function() self2:Set(nil, true) end)
                -- Airflow dropdown doesn't have a direct Refresh; recreate options via internal
                -- For player lists we rely on :Set which re-selects; best effort
                rawset(self2, "_opts", newOpts or {})
            end
            return el
        end

        function sp:AddButton(o)
            local x = xlat(o)
            local el = sec:CreateButton(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            return el
        end

        function sp:AddButtons(buttons)
            for _, btn in ipairs(buttons or {}) do
                sec:CreateButton({ Name = btn.Title, Callback = btn.Callback })
            end
        end

        function sp:AddKeybind(o)
            local x = xlat(o)
            -- Airflow keybind Callback fires on key press with the KeyCode
            -- Our feature code uses Callback to toggle state — wire it straight through
            local el = sec:CreateKeybind(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            el.Update = function(self2, v)
                local name = typeof(v) == "EnumItem" and v.Name or tostring(v)
                self2:Set(name)
            end
            return el
        end

        function sp:AddColorPicker(o)
            local x = xlat(o)
            local el = sec:CreateColorPicker(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            el.Update = function(self2, v) self2:Set(v) end
            return el
        end

        function sp:AddLabel(o)
            local text = type(o) == "string" and o or (o and (o.Text or o.Title) or "")
            local el = sec:CreateLabel(text)
            -- AuralV2 labels use :Update(text)
            el.Update = function(self2, t) self2:Set(tostring(t)) end
            return el
        end

        function sp:AddTextbox(o)
            local x = xlat(o)
            local el = sec:CreateInput(x)
            if o and o.Flag then lib.Elements[o.Flag] = el end
            el.GetValue = function(self2) return self2:Get() end
            el.Update   = function(self2, v) self2:Set(v) end
            return el
        end

        function sp:AddDivider() sec:CreateDivider() end

        return sp
    end

    -- Build a tab proxy exposing :CreateSection
    local function makeTabProxy(tab)
        local tp = { _tab = tab }
        function tp:CreateSection(secOpts)
            local title = type(secOpts) == "string" and secOpts
                       or (secOpts and (secOpts.Title or secOpts.Name) or "")
            tab:CreateSection(title)
            -- Airflow sections are just labels; element calls go on the tab itself
            return makeSectionProxy(tab)
        end
        return tp
    end

    function lib:CreateWindow(opts)
        -- Register custom NavyBlue theme before creating the window
        Airflow.Themes.NavyBlue = {
            Background  = Color3.fromRGB(8,  14, 28),
            Surface     = Color3.fromRGB(12, 19, 36),
            Surface2    = Color3.fromRGB(16, 24, 44),
            Surface3    = Color3.fromRGB(28, 38, 62),
            Stroke      = Color3.fromRGB(24, 34, 56),
            StrokeHover = Color3.fromRGB(58, 80,128),
            Accent      = Color3.fromRGB(90,140,255),
            AccentDark  = Color3.fromRGB( 6, 12, 26),
            Text        = Color3.fromRGB(220,228,248),
            Muted       = Color3.fromRGB(110,125,165),
            Glow        = Color3.fromRGB(200,215,255),
            Warning     = Color3.fromRGB(240,176,108),
            Success     = Color3.fromRGB(150,220,170),
            Error       = Color3.fromRGB(240,120,120),
        }

        _win = Airflow:CreateWindow({
            Name              = opts.Title or "Aural Freemium",
            LoadingSubtitle   = opts.Subtitle or "Practice Basketball",
            Theme             = "NavyBlue",
            ToggleUIKeybind   = "F5",
            ConfigurationSaving = {
                Enabled    = true,
                FolderName = "Aural",
                FileName   = "default",
            },
        })

        -- Load font if supported
        pcall(function() Airflow:LoadFont({ Name = "ValleySans" }) end)

        -- Resize logo 50% larger than Airflow's default 30×28
        pcall(function()
            if _win._logo then
                _win._logo.Size     = UDim2.fromOffset(45, 42)
                _win._logo.Position = UDim2.fromOffset(16, 21)
            end
        end)

        lib.Flags = Airflow.Flags

        -- winProxy is what the rest of the file calls "Window"
        local winProxy = { _win = _win }

        -- CreateCategory is a ZeroUI concept; we flatten it to just tabs
        function winProxy:CreateCategory(_name)
            local cat = {}
            function cat:CreateTab(tabOpts)
                local icon = tabOpts and tabOpts.Icon
                local tab = _win:CreateTab({
                    Name = (tabOpts and (tabOpts.Title or tabOpts.Name)) or "Tab",
                    Icon = icon,
                })
                return makeTabProxy(tab)
            end
            return cat
        end

        function winProxy:Notify(opts)
            if type(opts) == "string" then opts = { Content = opts } end
            if opts.Text and not opts.Content then opts.Content = opts.Text end
            _win:Notify({
                Title    = opts.Title or "Aural",
                Content  = opts.Content or opts.Text or "",
                Duration = opts.Duration or 4,
                Type     = opts.Type or "Info",
            })
        end

        function winProxy:Unload()
            if lib.OnUnload then pcall(lib.OnUnload) end
            pcall(function() _win:Destroy() end)
        end

        function winProxy:SetToggleKey(_key) end  -- Airflow sets this at CreateWindow

        function winProxy:Toggle(_state) end  -- Airflow handles this internally

        function winProxy:AddConfigSections(tab)
            -- Airflow uses CreateConfigManager on a tab section proxy
            -- We call it on the settings tab directly
            pcall(function()
                tab:CreateSection("Configs")
                tab:CreateConfigManager({ Name = "Configs" })
            end)
        end

        function winProxy:SaveConfig(name)
            if _win then return pcall(function() return _win:SaveConfig(name) end) end
        end

        function winProxy:LoadSavedConfig(name)
            if _win then return pcall(function() return _win:LoadConfig(name) end) end
        end

        function winProxy:LoadAutoConfig()
            if _win then pcall(function() _win:LoadConfig() end) end
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

local Macros = {
	{ Name = "Cross Behind Back", Moves = { "Crossover", "Behind Back" } },
	{ Name = "Hesi Cross", Moves = { "Hesitation", "Crossover" } },
	{ Name = "Snatch Step Back", Moves = { "Snatch Back", "Step Back" } },
	{ Name = "Double Cross Spin", Moves = { "Double Crossover", "Spin" } },
	{ Name = "Breakdown Half Spin", Moves = { "Breakdown", "Half Spin" } },
	{ Name = "Tween Behind Back", Moves = { "Tween", "Behind Back" } },
}

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

local Window = Library:CreateWindow({ Title = "Aural Freemium", Subtitle = "practical basketball" })
local Icons = Library.Icons

-- Notify helper — wraps Airflow's notification API (uses Content not Text)
local function Notify(Title, Content)
	Airflow:Notify({ Title = Title, Content = Content, Duration = 4 })
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

local function RunCombo(...) end
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
	local Timing = ShootingTab:CreateSection({ Title = "Auto Time", Icon = Icons.Timer })
	local PerfTimingToggle = Timing:AddToggle({ Title = "Auto Time", Description = "Releases every shot you hold at the top of the meter", Flag = "PerfectTiming", Default = Aural.Shooting.PerfectTiming, Callback = function(V) Aural.Shooting.PerfectTiming = V end })
	Timing:AddKeybind({ Title = "Auto Time Keybind", Flag = "PerfectTimingKey", Callback = function()
		local newVal = PerfTimingToggle and not PerfTimingToggle:Get() or not Aural.Shooting.PerfectTiming
		if PerfTimingToggle then pcall(function() PerfTimingToggle:Set(newVal) end) end
		Aural.Shooting.PerfectTiming = newVal
	end })
	Timing:AddSlider({ Title = "Release Point", Description = "How full the meter is when the release lands", Min = 90, Max = 100, Default = Aural.Shooting.ReleasePoint, Step = 0.5, Decimals = 1, Suffix = "%", Flag = "ReleasePoint", Callback = function(V) Aural.Shooting.ReleasePoint = V end })
	Timing:AddSlider({ Title = "Timing Offset", Description = "Manual nudge; positive releases later", Min = -100, Max = 100, Default = -5, Suffix = "ms", Flag = "TimingOffset", Callback = function(V) Aural.Shooting.TimingOffset = V end })

	local Calibrate = ShootingTab:CreateSection({ Title = "Calibration", Icon = Icons.Calibrate })
	Calibrate:AddToggle({ Title = "Calibration", Description = "Learns your timing from where the meter stops", Flag = "AutoCalibrate", Default = Aural.Shooting.AutoCalibrate, Callback = function(V) Aural.Shooting.AutoCalibrate = V end })
	CalibrationLabel = Calibrate:AddLabel("calibration: +0ms")
	LastShotLabel = Calibrate:AddLabel("last shot: none")
	Calibrate:AddButton({ Title = "Reset calibration", Callback = function() ResetCalibration() end })

	local Ping = ShootingTab:CreateSection({ Title = "Network", Icon = Icons.Ping })
	PingLabel = Ping:AddLabel("ping: 0ms")
	Ping:AddToggle({ Title = "Ping Compensation", Description = "Sends the release one round trip early so it lands on time", Flag = "PingCompensation", Default = Aural.Shooting.PingCompensation, Callback = function(V) Aural.Shooting.PingCompensation = V end })
	Ping:AddSlider({ Title = "Compensation Amount", Description = "Share of your ping to send early", Min = 0, Max = 200, Default = Aural.Shooting.PingMultiplier, Suffix = "%", Flag = "PingMultiplier", Callback = function(V) Aural.Shooting.PingMultiplier = V end })

	local Meter = ShootingTab:CreateSection({ Title = "Shot Meter", Icon = Icons.Meter })
	Meter:AddDropdown({ Title = "Change Meter", Description = "Switches your shot meter type", Options = MeterTypes, Flag = "MeterType", Callback = function(V)
		if V then
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

	local Circle = ShootingTab:CreateSection({ Title = "Shoot Range", Icon = Icons.Target })
	Circle:AddToggle({ Title = "Show Range", Description = "Draws the shoot range around the hoop you attack", Flag = "RangeCircle", Default = Aural.Shooting.RangeCircle, Callback = function(V) Aural.Shooting.RangeCircle = V end })
	Circle:AddColorPicker({ Title = "Circle Color", Default = Aural.Shooting.RangeCircleColor, Flag = "RangeCircleColor", Callback = function(V) Aural.Shooting.RangeCircleColor = V end })
end

-- // Dribble
do
	local Glide = OffenseTab:CreateSection({ Title = "Glide", Icon = Icons.Glide })
	local GlideToggle = Glide:AddToggle({ Title = "Glide", Description = "Dribble moves travel further", Flag = "DribbleGlide", Default = Aural.Dribbling.DribbleGlide, Callback = function(V) Aural.Dribbling.DribbleGlide = V end })
	Glide:AddKeybind({ Title = "Glide Keybind", Flag = "DribbleGlideKey", Callback = function()
		local newVal = GlideToggle and not GlideToggle:Get() or not Aural.Dribbling.DribbleGlide
		if GlideToggle then pcall(function() GlideToggle:Set(newVal) end) end
		Aural.Dribbling.DribbleGlide = newVal
	end })
	Glide:AddSlider({ Title = "Glide Speed", Description = "Extra speed on every dribble move", Min = 0, Max = 100, Default = Aural.Dribbling.GlideSpeed, Suffix = "%", Flag = "GlideSpeed", Callback = function(V) Aural.Dribbling.GlideSpeed = V end })

	local Ankle = OffenseTab:CreateSection({ Title = "Ankle Breaker", Icon = Icons.Ankle })
	local AnkleToggle = Ankle:AddToggle({ Title = "Ankle Breaker", Description = "Fires an escape move when a defender closes in", Flag = "AutoAnkleBreaker", Default = Aural.Dribbling.AutoAnkleBreaker, Callback = function(V) Aural.Dribbling.AutoAnkleBreaker = V end })
	Ankle:AddKeybind({ Title = "Ankle Breaker Keybind", Flag = "AutoAnkleBreakerKey", Callback = function()
		local newVal = AnkleToggle and not AnkleToggle:Get() or not Aural.Dribbling.AutoAnkleBreaker
		if AnkleToggle then pcall(function() AnkleToggle:Set(newVal) end) end
		Aural.Dribbling.AutoAnkleBreaker = newVal
	end })
	Ankle:AddSlider({ Title = "Ankle Break Range", Description = "How close a defender has to be", Min = 3, Max = 20, Default = Aural.Dribbling.AnkleBreakRange, Step = 0.5, Decimals = 1, Suffix = " studs", Flag = "AnkleBreakRange", Callback = function(V) Aural.Dribbling.AnkleBreakRange = V end })
	Ankle:AddDropdown({ Title = "Move", Options = MoveNames, Default = Aural.Dribbling.AnkleBreakerMove, Flag = "AnkleBreakerMove", Callback = function(V) Aural.Dribbling.AnkleBreakerMove = V or "Crossover" end })

	local Macro = OffenseTab:CreateSection({ Title = "Macros", Icon = Icons.Move })
	Macro:AddToggle({ Title = "Macros", Description = "Enables the keybinds below to fire their combos", Flag = "DribbleMacros", Default = Aural.Dribbling.Macros, Callback = function(V) Aural.Dribbling.Macros = V end })
	local Selected = Macros[1].Name
	local Names = {}
	for Index, Entry in Macros do
		table.insert(Names, Entry.Name)
	end
	Macro:AddDropdown({ Title = "Macro", Options = Names, Default = Selected, Flag = "SelectedMacro", Callback = function(V) Selected = V or Selected end })
	Macro:AddButton({ Title = "Play macro", Callback = function()
		for Index, Entry in Macros do
			if Entry.Name == Selected then
				RunCombo(Entry.Moves, Aural.Dribbling.ComboDelay)
			end
		end
	end })
	for Index, Entry in Macros do
		Macro:AddKeybind({ Title = Entry.Name, Flag = "MacroKey" .. Index, Callback = function()
			if Aural.Dribbling.Macros then
				RunCombo(Entry.Moves, Aural.Dribbling.ComboDelay)
			end
		end })
	end

	local Creator = OffenseTab:CreateSection({ Title = "Combo Builder", Icon = Icons.Combos })
	local MovesDropdown = Creator:AddDropdown({ Title = "Select Moves", Description = "Pick moves in order — they play exactly as listed", Multi = true, Options = MoveNames, Flag = "ComboMoves", Callback = function(V) Aural.Dribbling.ComboMoves = V or {} end })
	Creator:AddButton({ Title = "Play combo", Callback = function()
		if #Aural.Dribbling.ComboMoves == 0 then
			Notify("Combo", "Pick some moves first.")
			return
		end
		RunCombo(Aural.Dribbling.ComboMoves, Aural.Dribbling.ComboDelay)
	end })
	Creator:AddButton({ Title = "Clear", Callback = function()
		MovesDropdown:Update({})
	end })
	Creator:AddSlider({ Title = "Combo Delay", Description = "Extra wait between moves", Min = 0, Max = 0.5, Default = Aural.Dribbling.ComboDelay, Step = 0.01, Decimals = 2, Suffix = "s", Flag = "ComboDelay", Callback = function(V) Aural.Dribbling.ComboDelay = V end })
	Creator:AddKeybind({ Title = "Combo Keybind", Flag = "ComboKey", Callback = function()
		if #Aural.Dribbling.ComboMoves > 0 then
			RunCombo(Aural.Dribbling.ComboMoves, Aural.Dribbling.ComboDelay)
		end
	end })
end

-- ╔══════════════════════════════╗
-- ║  DEFENSE TAB                 ║
-- ╚══════════════════════════════╝

-- // Auto Block
do
	local Block = DefenseTab:CreateSection({ Title = "Block", Icon = Icons.Shield })
	local BlockToggle = Block:AddToggle({ Title = "Block", Description = "Jumps at nearby shots, layups and dunks", Flag = "AutoBlock", Default = Aural.Defense.AutoBlock, Callback = function(V) Aural.Defense.AutoBlock = V end })
	Block:AddKeybind({ Title = "Block Keybind", Flag = "AutoBlockKey", Callback = function()
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
	local Guard = DefenseTab:CreateSection({ Title = "Guard", Icon = Icons.Guard })
	local GuardToggle = Guard:AddToggle({ Title = "Guard", Description = "Holds guard and stays between your man and the hoop", Flag = "AutoGuard", Default = Aural.Defense.AutoGuard, Callback = function(V) Aural.Defense.AutoGuard = V end })
	Guard:AddKeybind({ Title = "Guard Keybind", Flag = "AutoGuardKey", Callback = function()
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
	local Magnets = DefenseTab:CreateSection({ Title = "Magnets", Icon = Icons.Target })
	Magnets:AddToggle({ Title = "Magnets", Description = "Goes after loose balls and rebounds near you", Flag = "BallMagnets", Default = Aural.Ball.Magnets, Callback = function(V) Aural.Ball.Magnets = V end })
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

	local State = CharacterTab:CreateSection({ Title = "Player State", Icon = Icons.Person })
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
	local MenuSec = SettingsTab:CreateSection({ Title = "Menu", Icon = Icons.Gear })
	MenuSec:AddKeybind({
		Title = "Menu Keybind",
		Description = "Key that opens and closes the Aural menu",
		Flag = "MenuKeybind",
		Default = Enum.KeyCode.F5,
		Callback = function(Key)
			pcall(function() Window._win:SetKeybind(Key) end)
		end,
	})

	local EnableSec = SettingsTab:CreateSection({ Title = "Script", Icon = Icons.Gear })
	EnableSec:AddToggle({ Title = "Enable Script", Description = "Pauses all features — turn off to lay low mid-game", Flag = "ScriptEnabled", Default = true, Callback = function(V)
		Running = V
		-- show/hide window by toggling visibility
		pcall(function()
			local ScreenGui = game.CoreGui:FindFirstChild("Airflow")
                    or game.CoreGui:FindFirstChild("AuralV2")
                    or game.CoreGui:FindFirstChild("Aural")
			if ScreenGui then
				ScreenGui.Enabled = V
			end
		end)
	end })

	-- Config manager (Airflow built-in: named configs, save/load, share)
	local ConfigSec = SettingsTab:CreateSection({ Title = "Configs", Icon = Icons.Gear })
	ConfigSec._sec:CreateConfigManager({ Name = "Configs" })

	-- Unload
	local UnloadSec = SettingsTab:CreateSection({ Title = "Unload", Icon = Icons.Gear })
	UnloadSec:AddButton({ Title = "Unload script", Callback = function()
		Window:Unload()
	end })
end

-- Auto-load last-used config on start (Airflow ConfigurationSaving handles this automatically)
pcall(function() Window:LoadAutoConfig() end)


-- // Shot Tracking & Perfect Timing
do
	-- Progress (0 to 1) from the meter offset the server writes on your character. Each meter type maps it differently;
	-- these were measured in game. Types not listed fall back to timing from when the shot started.
	local MeterMaps = {
		Vertical = function(Offset) return (-Offset.Y - 0.25) / 1.25 end,
		Rocket = function(Offset) return -Offset.Y end,
		Bat = function(Offset) return -Offset.Y end,
		None = function(Offset) return -Offset.Y end,
		Hoop = function(Offset) return Offset.Y end,
		Roblox = function(Offset) return Offset.X end,
	}
	local DefaultFill = 0.38

	local Shot = {
		Active = false,
		Start = 0,
		Meter = "Vertical",
		Samples = {},
		Slope = nil,
		Released = false,
		ReleasedAt = 0,
		LastBeforeRelease = 0,
		Final = nil,
		Ours = false,
	}
	local AutoPending = 0
	local Calibration = 0
	local LastAutoShot = 0
	local Bound, BoundConnections = nil, {}

	ResetCalibration = function()
		Calibration = 0
		CalibrationLabel:Update("calibration: +0ms")
	end

	local function GetLead()
		if not Aural.Shooting.PingCompensation then
			return 0
		end
		return LocalPlayer:GetNetworkPing() * (Aural.Shooting.PingMultiplier / 100)
	end

	local function BeginShot(MeterType)
		Shot.Active = true
		Shot.Start = os.clock()
		Shot.Meter = MeterType or Shot.Meter
		Shot.Samples = {}
		Shot.Slope = nil
		Shot.Released = false
		Shot.Final = nil
		Shot.Ours = false
		Shot.Auto = os.clock() - AutoPending < 0.6
		AutoPending = 0
	end

	local function Release()
		Shot.Released = true
		Shot.Ours = true
		Shot.ReleasedAt = os.clock()
		local Last = Shot.Samples[#Shot.Samples]
		Shot.LastBeforeRelease = Last and Last[1] or Shot.Start
		Fire(Remotes.Shoot, { Shoot = false })
	end

	-- Least squares line through the meter samples, as progress over seconds since the shot started.
	local function Fit()
		local Count = #Shot.Samples
		local SumX, SumY, SumXX, SumXY = 0, 0, 0, 0
		for Index, Sample in Shot.Samples do
			local X = Sample[1] - Shot.Start
			SumX += X
			SumY += Sample[2]
			SumXX += X * X
			SumXY += X * Sample[2]
		end
		local Denominator = Count * SumXX - SumX * SumX
		if Denominator == 0 then
			return nil
		end
		local Slope = (Count * SumXY - SumX * SumY) / Denominator
		return Slope, (SumY - Slope * SumX) / Count
	end

	local function GetReleaseTime()
		local Target = Aural.Shooting.ReleasePoint / 100
		local Shift = Aural.Shooting.TimingOffset / 1000 + Calibration - GetLead()
		if MeterMaps[Shot.Meter] then
			if #Shot.Samples < 3 then
				return nil
			end
			local Slope, Intercept = Fit()
			if not Slope or Slope < 0.5 then
				return nil
			end
			Shot.Slope = Slope
			return Shot.Start + (Target - Intercept) / Slope + Shift
		end
		return Shot.Start + DefaultFill * Target + Shift
	end

	-- After each release the meter freezes where the server was when the release landed, which says how far off it
	-- was. If the meter had already stopped before the release went out, the server auto-released at the top and the
	-- release was late. The grade decides the direction; the frozen meter only sizes the step, and a step never goes
	-- past 20ms, because a contested or interrupted shot can freeze the meter somewhere meaningless.
	local function Learn(Grade)
		if not Aural.Shooting.AutoCalibrate or not Shot.Ours or not Grade then
			return
		end
		local Index = table.find(Grades, Grade) or 5
		local Measured = MeterMaps[Shot.Meter] ~= nil and #Shot.Samples > 0 and Shot.Slope and Shot.Slope > 0
		local Stalled = Measured and Shot.ReleasedAt - Shot.LastBeforeRelease > 0.07
		local Error = 0
		if Measured and Shot.Final then
			Error = (Aural.Shooting.ReleasePoint / 100 - Shot.Final) / Shot.Slope
		end

		local Change
		if Index < 4 then
			Change = math.max(Error, 0.008 * (4 - Index))
		elseif Index > 5 then
			Change = math.min(Stalled and -0.012 or Error, -0.008 * (Index - 5))
		elseif Index == 4 then
			Change = Stalled and -0.01 or math.max(Error, 0.006)
		else
			Change = Error * 0.25
		end
		Change = math.clamp(Change * 0.7, -0.02, 0.02)
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
			Shot.Final = Progress
			if not Shot.Released then
				table.insert(Shot.Samples, { os.clock(), Progress })
			end
		end))
		table.insert(BoundConnections, Character:GetAttributeChangedSignal("Action"):Connect(function()
			if Character:GetAttribute("Action") == "Shooting" and (not Shot.Active or os.clock() - Shot.Start > 0.3) then
				BeginShot(nil)
			end
		end))
	end

	Connect(Remotes.MeterRegister.OnClientEvent, function(Model, MeterType)
		if Model == Bound and (not Shot.Active or os.clock() - Shot.Start > 0.3) then
			BeginShot(MeterType)
		elseif Model == Bound then
			Shot.Meter = MeterType or Shot.Meter
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
		-- Give the frozen meter value a moment to arrive before learning from it.
		task.delay(0.1, function()
			Learn(Grade)
			LastShotLabel:Update(string.format("last shot: %s%s", Grade or "?", Shot.Final and string.format(" (%d%%)", math.round(Shot.Final * 100)) or ""))
		end)
	end)

	Connect(RunService.Heartbeat, function()
		local Character = GetCharacter()
		if Character ~= Bound then
			Bind(Character)
		end
		if not Character then
			return
		end

		if Shot.Active and not Shot.Released and (Aural.Shooting.PerfectTiming or Shot.Auto) then
			if Character:GetAttribute("ReleasedShot") == true and os.clock() - Shot.Start > 0.1 then
				-- The player let go first.
				Shot.Released = true
			else
				local ReleaseTime = GetReleaseTime()
				if (ReleaseTime and os.clock() >= ReleaseTime) or os.clock() - Shot.Start > 1.2 then
					Release()
				end
			end
		end
		if Shot.Active and os.clock() - Shot.Start > 3 then
			Shot.Active = false
		end

		if Aural.Shooting.AutoShoot and not Shot.Active and HasBall(Character) and Character:GetAttribute("Action") == "" and os.clock() - LastAutoShot > 1.5 then
			local Root, Goal = GetRoot(Character), GetGoal(Character)
			if Root and Goal and Flat(Goal - Root.Position).Magnitude <= Aural.Shooting.ShootRange then
				LastAutoShot = os.clock()
				AutoPending = os.clock()
				Fire(Remotes.Shoot, { Shoot = true, Input = "E" })
			end
		end
	end)

	task.spawn(function()
		while Running do
			PingLabel:Update(string.format("ping: %dms", math.round(LocalPlayer:GetNetworkPing() * 1000)))
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

-- // Dribble Moves, Macros & Auto Ankle Breaker
do
	local ComboRunning = false
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

	-- Each move waits for the last one to finish, plus the quarter second the server needs before it takes another.
	RunCombo = function(Moves, Delay)
		if ComboRunning or #Moves == 0 then
			return
		end
		ComboRunning = true
		task.spawn(function()
			for Index, Move in table.clone(Moves) do
				if not Running then
					break
				end
				if Index > 1 then
					local Character = GetCharacter()
					local Started = os.clock()
					task.wait(0.05)
					while Character and Character:GetAttribute("Action") == "Dribbling" and os.clock() - Started < 1.5 do
						task.wait()
					end
					task.wait(0.25 + (Delay or 0))
				end
				if not DoMove(Move) then
					break
				end
			end
			ComboRunning = false
		end)
	end

	Connect(RunService.Heartbeat, function()
		if not Aural.Dribbling.AutoAnkleBreaker or ComboRunning or os.clock() - LastAnkle < 1.2 then
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
    end,
})
