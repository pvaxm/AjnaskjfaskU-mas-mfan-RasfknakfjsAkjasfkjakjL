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
if environment.AuralV2Unload then pcall(environment.AuralV2Unload) end

if not rawget(_G, "LPH_OBFUSCATED") then
    local function Passthrough(fn) return fn end
    LPH_JIT, LPH_JIT_MAX, LPH_NO_VIRTUALIZE = Passthrough, Passthrough, Passthrough
end

local vector2New = Vector2.new
local cframeLookAt = CFrame.lookAt
local osClock = os.clock

-- AuralV2 UI library, fetched at runtime (see LoadAuralV2 above).
-- It lives in its own function so its locals don't count against the script
-- below it: Luau allows 200 locals per function. BuildInterface runs it.
-- AuralV2 UI library v2.6.0 — replace the URL below with wherever you host
-- the new library source (the attachment you provided). It requires v2.6.0+
-- for AddKeybind support used by the feature keybind toggles.
local function LoadAuralV2()
    local src = game:HttpGet("https://pastebin.ai/raw/YLZstkdtu") -- ← swap for your v2.6.0 URL
    local fn = loadstring(src)
    if type(fn) ~= "function" then error("AuralV2: loadstring returned " .. type(fn)) end
    local lib = fn()
    if type(lib) ~= "table" then error("AuralV2: module returned " .. type(lib)) end
    return lib
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
    local ran, loaded = pcall(LoadAuralV2)
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
    return window ~= nil and not window._destroyed and window.Open == true and not window.Minimized
end

local notifyIcons = { Info = "info", Coin = "coins" }
local notifyTypes = { Success = "Success", Warning = "Warning", Warn = "Warning", Error = "Error" }

function xDTaraZ.UI.Notify(title, content, duration, kind)
    local window = xDTaraZ.UI.Window
    if not window then return end
    local typeMap = { Success = "Success", Warning = "Warning", Warn = "Warning", Error = "Error", Info = "Info", Coin = "Info" }
    local ok, err = pcall(window.Notify, window, {
        Title = tostring(title),
        Text  = tostring(content),
        Duration = duration or 4,
        Type  = typeMap[kind] or "Info",
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
    local elem = group:AddToggle({
        Name     = info.Name,
        Desc     = info.Desc,
        Default  = info.Default == true,
        Flag     = idx,
        Keybind  = info.Keybind,   -- shows native picker button in the row (AuralV2 v2.6.0+)
        Callback = function(value) widget:Dispatch(value) end,
    })
    widget.Element = {
        Get = function() return elem:Get() end,
        -- elem:Set already fires elem.Changed -> our Callback -> widget:Dispatch
        -- when not silent, so no separate dispatch call here (that would fire twice).
        Set = function(_, v, silent) elem:Set(v, silent) end,
    }
    widget.Value = elem:Get()

    -- Register in FeatureBinds so our InputBegan handler can fire toggles even
    -- when the UI is open (the library skips keybinds when processed=true).
    if info.Keybind then
        table.insert(xDTaraZ.UI.FeatureBinds, {
            Elem   = elem,          -- has elem.Keybind:Get() -> current KeyCode
            Widget = widget,
            Mode   = info.Keybind.Mode or "Toggle",
        })
    end

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
    local elem = group:AddSlider({
        Name      = info.Name,
        Min       = info.Min,
        Max       = info.Max,
        Default   = info.Default,
        Increment = info.Increment or 1,
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
    local elem = group:AddDropdown({
        Name     = info.Name,
        Values   = info.Options,
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
    local main = tab:AddSection({ Title = T("Aim Lock", "เล็งอัตโนมัติ"), Side = "Left" })
    xDTaraZ.UI.Toggle(main, "Aimbot", {
        Name    = T("Aim Lock", "เล็งอัตโนมัติ"),
        Desc    = T("Snaps aim onto the nearest enemy", "ล็อคเป้าศัตรูที่ใกล้ที่สุด"),
        Keybind = { Default = Enum.KeyCode.E, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Slider(main, "AimbotSmooth", { Name = T("Smoothness", "ความนุ่ม"), Desc = T("Higher = smoother", "สูง = นุ่มกว่า"), Min = 1, Max = 20, Default = 1 })
    xDTaraZ.UI.Toggle(main, "AimbotSticky", { Name = T("Sticky target", "ล็อคเป้าเดิม"), Desc = T("Stays on one enemy until they're gone", "ไม่สลับเป้าจนกว่าเป้าจะหลุด"), Default = true })

    local target = tab:AddSection({ Title = T("Aim Config", "การตั้งค่าการเล็ง"), Side = "Right" })
    xDTaraZ.UI.Dropdown(target, "AimbotBone", { Name = T("Aim part", "จุดที่เล็ง"), Options = { "Head", "Torso" }, Default = "Head" })
    xDTaraZ.UI.Dropdown(target, "AimbotPriority", { Name = T("Priority", "เลือกเป้าตาม"), Options = priorities, Default = "Crosshair" })
    xDTaraZ.UI.Toggle(target, "AimbotVisible", { Name = T("Visible only", "เฉพาะที่มองเห็น"), Default = true })
    xDTaraZ.UI.Slider(target, "AimbotFov", { Name = T("FOV", "ขนาดวง"), Min = 20, Max = 800, Default = 150, Suffix = "px" })
    xDTaraZ.UI.Toggle(target, "AimbotShowFov", { Name = T("Show FOV circle", "แสดงวง FOV") })
    xDTaraZ.UI.Slider(target, "AimbotMaxDistance", { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 1500, Suffix = "m" })
end

function xDTaraZ.UI.BuildSilent(tab)
    local main = tab:AddSection({ Title = T("Bullet Redirect", "ไซเลนต์เอม"), Side = "Left" })
    xDTaraZ.UI.Toggle(main, "SilentAim", {
        Name    = T("Silent aim", "ไซเลนต์เอม"),
        Desc    = T("Bends bullets toward the nearest enemy", "ยิงพุ่งหาศัตรูที่ใกล้ที่สุด"),
        Keybind = { Default = Enum.KeyCode.Unknown, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Slider(main, "SilentHitChance", { Name = T("Hit chance", "โอกาสโดน"), Desc = T("Lower = less obvious", "ต่ำ = ดูเนียนกว่า"), Min = 1, Max = 100, Default = 100, Suffix = "%" })
    xDTaraZ.UI.Slider(main, "SilentHeadChance", { Name = T("Headshot chance", "โอกาสเข้าหัว"), Desc = T("Rest hit the body", "ที่เหลือเข้าตัว"), Min = 0, Max = 100, Default = 100, Suffix = "%" })
    xDTaraZ.UI.NeedCap("SilentAim", { "HookFunction", "Gc" })

    local target = tab:AddSection({ Title = T("Redirect Config", "การตั้งค่าไซเลนต์"), Side = "Right" })
    xDTaraZ.UI.Dropdown(target, "SilentPriority", { Name = T("Priority", "เลือกเป้าตาม"), Options = priorities, Default = "Crosshair" })
    xDTaraZ.UI.Toggle(target, "SilentVisible", { Name = T("Visible only", "เฉพาะที่มองเห็น"), Desc = T("Off = through walls too", "ปิด = ทะลุกำแพงด้วย"), Default = true })
    xDTaraZ.UI.Slider(target, "SilentFov", { Name = T("FOV", "ขนาดวง"), Min = 20, Max = 1000, Default = 220, Suffix = "px" })
    xDTaraZ.UI.Toggle(target, "SilentShowFov", { Name = T("Show FOV circle", "แสดงวง FOV") })
    xDTaraZ.UI.Slider(target, "SilentMaxDistance", { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 3000, Default = 2000, Suffix = "m" })
    xDTaraZ.UI.Toggle(target, "SilentPredict", { Name = T("Lead moving targets", "ยิงดักคนที่วิ่ง") })
end

function xDTaraZ.UI.BuildTrigger(tab)
    local trigger = tab:AddSection({ Title = T("Auto Fire", "ยิงอัตโนมัติ"), Side = "Left" })
    xDTaraZ.UI.Toggle(trigger, "Triggerbot", {
        Name    = T("Auto fire", "ยิงอัตโนมัติ"),
        Desc    = T("Auto fires when crosshair is on an enemy", "ยิงอัตโนมัติเมื่อเป้าอยู่บนศัตรู"),
        Keybind = { Default = Enum.KeyCode.T, Mode = "Toggle" },
        Notify  = true,
    })
    xDTaraZ.UI.Slider(trigger, "TriggerDelay", { Name = T("Reaction delay", "ดีเลย์ก่อนยิง"), Min = 0, Max = 400, Default = 0, Suffix = "ms" })
    xDTaraZ.UI.Slider(trigger, "TriggerHitChance", { Name = T("Fire chance", "โอกาสยิง"), Min = 1, Max = 100, Default = 100, Suffix = "%" })

    local rage = tab:AddSection({ Title = T("Rage Mode", "เรจบอท"), Side = "Right" })
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
    local mods = tab:AddSection({ Title = T("Weapon Control", "ม็อดปืน"), Side = "Left" })
    xDTaraZ.UI.Toggle(mods, "NoRecoil", { Name = T("No recoil", "ไม่มีแรงถีบ"), Desc = T("No camera kick when firing", "ไม่มีการสั่นของกล้องตอนยิง") })
    xDTaraZ.UI.Toggle(mods, "NoSpread", { Name = T("No spread", "ไม่มีการกระจาย"), Desc = T("All bullets hit dead center", "ทุกนัดลงกลางเป้า") })
    xDTaraZ.UI.NeedCap("NoRecoil", "HookFunction")
    xDTaraZ.UI.NeedCap("NoSpread", { "HookFunction", "Gc" })
end

function xDTaraZ.UI.BuildCombat(window)
    -- Flat tab: every combat feature lands as sections on one page, no page-switcher.
    local tab = window:AddTab({ Name = T("Combat", "การต่อสู้"), Icon = "target" })
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

    local main = tab:AddSection({ Title = "Player Tracking", Side = "Left" })
    feed(xDTaraZ.UI.Toggle(main, "Esp",          { Name = T("Enable ESP", "เปิด ESP") }), Setting("Enabled"))
    feed(xDTaraZ.UI.Toggle(main, "EspTeam",      { Name = T("Team check", "เช็คทีม"), Default = true }), Setting("TeamCheck"))
    feed(xDTaraZ.UI.Slider(main, "EspRange",     { Name = T("Max distance", "ระยะสูงสุด"), Min = 50, Max = 5000, Default = 2000, Increment = 50, Suffix = "m" }), Setting("MaxDistance"))
    feed(xDTaraZ.UI.Slider(main, "EspTextSize",  { Name = T("Text size", "ขนาดตัวอักษร"), Min = 9, Max = 20, Default = 13 }), Setting("TextSize"))

    local radar = tab:AddSection({ Title = T("Radar", "เรดาร์"), Side = "Left" })
    feed(xDTaraZ.UI.Toggle(radar, "Radar",       { Name = T("Radar", "เรดาร์"), Desc = T("Minimap of players, drag to move", "มินิแมพผู้เล่น ลากย้ายได้") }), Setting("Radar"))
    feed(xDTaraZ.UI.Slider(radar, "RadarRange",  { Name = T("Radar range", "ระยะเรดาร์"), Min = 50, Max = 1000, Default = 250, Increment = 10, Suffix = "m" }), Setting("RadarRange"))
    feed(xDTaraZ.UI.Slider(radar, "RadarSize",   { Name = T("Radar size", "ขนาดเรดาร์"), Min = 120, Max = 320, Default = 180, Suffix = "px" }), Setting("RadarSize"))

    local look = tab:AddSection({ Title = T("Display Elements", "องค์ประกอบ"), Side = "Right" })
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
    local world = tab:AddSection({ Title = T("Environment", "สภาพแวดล้อม"), Side = "Left" })
    xDTaraZ.UI.Toggle(world, "Fullbright", { Name = T("Fullbright", "สว่างทั้งแมพ") })
    xDTaraZ.UI.Toggle(world, "NoFlash",   { Name = T("No flash", "กันแฟลช"), Desc = T("Immune to flashbangs", "ไม่ถูกแฟลชบอด") })
    xDTaraZ.UI.Toggle(world, "NoSmoke",   { Name = T("No smoke", "ไม่มีควัน"), Desc = T("See through smoke", "มองทะลุควัน") })

    local heard = tab:AddSection({ Title = T("Sound Tracking", "ตามเสียงศัตรู"), Side = "Left" })
    xDTaraZ.UI.Toggle(heard, "SoundEsp",     { Name = T("Sound ESP", "ESP จากเสียง"), Desc = T("Tracks enemy footsteps and shots through walls", "ติดตามเสียงศัตรูและการยิงทะลุกำแพง") })
    xDTaraZ.UI.Slider(heard, "SoundEspLife", { Name = T("Show for", "แสดงนาน"), Min = 1, Max = 8, Default = 3, Suffix = "s" })
    xDTaraZ.UI.Slider(heard, "EspMemory",    { Name = T("Keep hidden enemies", "จำศัตรูที่หลบ"), Min = 0, Max = 15, Default = 5, Suffix = "s" })
    xDTaraZ.UI.NeedCap("SoundEsp", "Upvalues")

    local cam = tab:AddSection({ Title = T("View Control", "ตั้งค่ากล้อง"), Side = "Right" })
    xDTaraZ.UI.Toggle(cam, "CameraFov",      { Name = T("Custom FOV", "ปรับมุมมอง") })
    xDTaraZ.UI.Slider(cam, "CameraFovValue", { Name = T("FOV", "มุมมอง"), Min = 70, Max = 120, Default = 100 })
end

function xDTaraZ.UI.BuildVisuals(window)
    -- Flat tab: ESP and World sections both sit on one page, no page-switcher.
    local tab = window:AddTab({ Name = T("Visuals", "การมองเห็น"), Icon = "eye" })
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
    local group = tab:AddSection({ Title = T(title[1], title[2]), Side = side })
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
    local tab = window:AddTab({ Name = T("Skins", "สกิน"), Icon = "palette" })

    local main = tab:AddSection({ Title = T("Quick Actions", "จัดการสกิน"), Side = "Left" })
    xDTaraZ.UI.Toggle(main, "SkinChanger", { Name = T("Skin changer", "เปลี่ยนสกิน"), Desc = T("Applies instantly when selected", "ขึ้นทันทีเมื่อเลือก") })
    main:AddButton({ Name = T("Rarest On Everything", "หายากสุดทุกอัน"), Text = "Apply", Callback = xDTaraZ.UI.Detach(function()
        local count = xDTaraZ.Skins.SetAll(function(list) return list[1] end)
        xDTaraZ.UI.SyncSkins()
        xDTaraZ.UI.Notify("Skins", "Set " .. count .. " items", 3, "Success")
    end) })
    main:AddButton({ Name = T("Random", "สุ่ม"), Text = "Roll", Callback = xDTaraZ.UI.Detach(function()
        xDTaraZ.Skins.SetAll(function(list) return list[math.random(#list)] end)
        xDTaraZ.UI.SyncSkins()
    end) })
    main:AddButton({ Name = T("Reset All", "ล้างทั้งหมด"), Text = "Reset", Callback = xDTaraZ.UI.Detach(function()
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
    local tab = window:AddTab({ Name = T("Misc", "อื่นๆ"), Icon = "cart" })

    local buy = tab:AddSection({ Title = T("Round Setup", "เตรียมรอบ"), Side = "Left" })
    xDTaraZ.UI.Toggle(buy, "AutoRebuy", { Name = T("Auto rebuy", "ซื้อซ้ำอัตโนมัติ"), Desc = T("Rebuys your last loadout each round", "ซื้อชุดล่าสุดให้ทุกรอบ") })
    xDTaraZ.UI.NeedCap("AutoRebuy", "HookFunction")
    buy:AddButton({ Name = T("Rebuy Now", "ซื้อซ้ำตอนนี้"), Text = "Buy", Callback = xDTaraZ.UI.Detach(function()
        local sent = xDTaraZ.Economy.Rebuy()
        xDTaraZ.UI.Notify("Auto Buy", sent > 0 and ("Bought " .. sent .. " items") or "Buy something once first", 3, sent > 0 and "Success" or "Info")
    end) })
    buy:AddButton({ Name = T("Clear", "ล้าง"), Text = "Clear", Callback = xDTaraZ.UI.Detach(function()
        table.clear(xDTaraZ.State.Bought)
    end) })

    local codes = tab:AddSection({ Title = T("Promo Codes", "โค้ดส่วนลด"), Side = "Left" })
    codes:AddButton({ Name = T("Redeem All Codes", "แลกโค้ดทั้งหมด"), Text = "Redeem", Callback = xDTaraZ.UI.Detach(function()
        local sent = xDTaraZ.Economy.RedeemAll()
        xDTaraZ.UI.Notify("Codes", "Sent " .. sent .. " codes (level 5+ needed)", 4, "Coin")
    end) })

    local util = tab:AddSection({ Title = T("Movement & Server", "การเคลื่อนที่และเซิร์ฟ"), Side = "Right" })
    xDTaraZ.UI.Toggle(util, "InfiniteJump", { Name = T("Infinite jump", "กระโดดไม่จำกัด"), Desc = T("Lobby only — use Bunny hop in-game", "ล็อบบี้เท่านั้น — ใช้บันนี่ฮอปในเกม") })
    xDTaraZ.UI.Toggle(util, "BunnyHop",    { Name = T("Bunny hop", "บันนี่ฮอป"), Desc = T("Hold Space to chain jumps and keep speed", "กด Space ค้างเพื่อกระโดดต่อเนื่อง") })
    xDTaraZ.UI.Toggle(util, "BunnyCrouch", { Name = T("Crouch jump", "ย่อตอนลอย"), Desc = T("Crouches mid-air like a CS jump", "ย่อตัวกลางอากาศแบบ CS"), Default = true })
    xDTaraZ.UI.Toggle(util, "AntiAfk",     { Name = T("Anti AFK", "กันหลุด AFK") })
    util:AddButton({ Name = T("Rejoin", "เข้าใหม่"),     Text = "Go", Callback = xDTaraZ.UI.Detach(xDTaraZ.World.Rejoin) })
    util:AddButton({ Name = T("Server Hop", "ย้ายเซิร์ฟ"), Text = "Hop", Callback = xDTaraZ.UI.Detach(xDTaraZ.World.ServerHop) })
end

function xDTaraZ.UI.BuildSettings(window)
    local tab = window:AddTab({ Name = T("Settings", "ตั้งค่า"), Icon = "menu" })

    local interface = tab:AddSection({ Title = T("Menu Options", "ตั้งค่าเมนู"), Side = "Left" })

    -- The Menu Keybind is handled natively by AddConfigSections (AuralV2 v2.6.0+).
    -- It shows a native keybind picker row (default: RightShift) that calls
    -- window:SetToggleKey(key) automatically. Nothing custom needed here.

    -- Manual override for the floating pill button; boot already forces it
    -- hidden on PC (see BuildInterface), this just lets you flip it back on.
    interface:AddToggle({
        Name     = T("Show toggle button", "แสดงปุ่มเปิดเมนูลอย"),
        Default  = UserInputService.TouchEnabled,
        Flag     = "PillVisible",
        Callback = function(visible)
            pcall(window.SetPillVisible, window, visible)
        end,
    })
    -- Unload button (no Confirm dialog in AuralV2 — single press)
    interface:AddButton({
        Name = T("Unload Aural V2", "ปิด Aural V2"),
        Text = "Unload",
        Callback = function()
            xDTaraZ.UI.Unload()
        end,
    })

    -- Full config manager, built into AuralV2 itself: name box, Save/Load/
    -- Delete/Refresh on the left, Auto-load on/off under it, and an
    -- Export/Import/Copy JSON box on the right for sharing a config as text
    -- with someone else. Nothing custom to build — this one call does it all.
    window:AddConfigSections(tab)
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
    local window = xDTaraZ.UI.Window
    if window and not window._destroyed then pcall(window.Destroy, window) end
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
    environment.AuralV2Unload = nil
    environment.BloxStrikeUnload = nil
end

---@return boolean  false when the menu could not be opened
---@return boolean  false when the menu could not be opened
local function BuildInterface()
    Library = xDTaraZ.Util.LoadLibrary()
    if not Library then return false end
    pcall(AuralBanner.Step, "UI library")
    xDTaraZ.Library = Library

    -- AuralV2:CreateWindow({ Name, Icon, Accent, Configs })
    -- gethui() is the executor's protected GUI layer: it sits above CoreGui and
    -- every normal PlayerGui element regardless of DisplayOrder, so the menu
    -- can't end up stuck behind the game's own UI. DisplayOrder is still set to
    -- the max as a fallback for executors that don't expose gethui.
    local uiParent = (type(gethui) == "function" and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    -- "Icon" isn't a CreateWindow field AuralV2 reads at all (it's per-tab only);
    -- the window/pill logo key is "Logo".
    local opened, window = pcall(Library.CreateWindow, Library, {
        Name   = "Aural V2",
        Logo   = "rbxassetid://98317435813811",
        Accent = Color3.fromRGB(107, 68, 220),
        Parent = uiParent,
        DisplayOrder = 2147483647,
        Configs = {
            Folder = xDTaraZ.Config.SaveFolder .. "/Configs",
            -- AutoLoad and Notify both default to true: whatever config is set
            -- as the autoload target loads itself on boot, with a confirmation
            -- notify, no extra wiring needed on our side.
        },
    })
    if not opened or type(window) ~= "table" then
        xDTaraZ.Util.Alert("The menu failed to load on this executor: " .. (tostring(window):match("^[^\n]*") or ""), window)
        return false
    end
    xDTaraZ.UI.Window = window

    -- AuralV2 already hides the mobile pill on non-touch devices by default,
    -- but some executors misreport UserInputService.TouchEnabled, so force it
    -- deterministically here too: visible only on an actual touch device.
    pcall(window.SetPillVisible, window, UserInputService.TouchEnabled)

    -- Destroy hook: unload features when the window closes
    if typeof(window.Gui) == "Instance" then
        window.Gui.Destroying:Connect(function()
            if xDTaraZ.State.Alive then task.spawn(xDTaraZ.Unload, xDTaraZ) end
        end)
    end

    xDTaraZ.UI.Build(window)
    task.defer(xDTaraZ.Util.Try, "boot", xDTaraZ.Boot)
    -- No manual autoload call needed: CreateWindow's Configs already runs
    -- LoadAutoConfig() itself once the Gui is parented in (see AddConfigSections
    -- in the Settings tab for the Save/Load/Export/Import/Autoload UI).
    return true
end

environment.AuralV2Unload = function()
    xDTaraZ.UI.Unload()
end

pcall(AuralBanner.Step, "Systems")
if not BuildInterface() then return end
pcall(AuralBanner.Step, "Interface")
pcall(AuralBanner.Ready)
