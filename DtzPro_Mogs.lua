if not game:IsLoaded() then game.Loaded:Wait() end
pcall(function() game:GetService("Players").RespawnTime = 0 end)
local privateBuild = false

local SharedState = {
    SelectedAdminCommand = nil,
    SelectedPetData = nil,
    AllAnimalsCache = nil,
    DisableStealSpeed = nil,
    ListNeedsRedraw = true,
    AdminButtonCache = {},
    StealSpeedToggleFunc = nil,
    _ssUpdateBtn = nil,
    AdminProxBtn = nil,
    BalloonedPlayers = {},
    MobileScaleObjects = {},
    RefreshMobileScale = nil,
}

local function WaitFor(path, timeout)
    timeout = timeout or 10
    local started = os.clock()
    local function left()
        if timeout <= 0 then return 0 end
        return math.max(0, timeout - (os.clock() - started))
    end
    local segments = {}
    if typeof(path) == "Instance" then
        return path
    elseif type(path) == "string" then
        local cleaned = path:gsub("^game[%.%/]", "")
        for seg in cleaned:gmatch("[^%./]+") do
            table.insert(segments, seg)
        end
    elseif type(path) == "table" then
        segments = path
    else
        return nil
    end
    if #segments == 0 then return nil end

    local current
    local first = segments[1]
    if first == "game" then
        current = game
    else
        local ok, svc = pcall(function() return game:GetService(first) end)
        if ok and svc then
            current = svc
        else
            current = game:WaitForChild(first, left())
        end
    end
    if not current then return nil end

    for i = 2, #segments do
        local seg = segments[i]
        if seg == "LocalPlayer" and current == game:GetService("Players") then
            while not current.LocalPlayer and (timeout <= 0 or (os.clock() - started) < timeout) do
                task.wait()
            end
            current = current.LocalPlayer
        elseif seg == "CurrentCamera" and current == game:GetService("Workspace") then
            while not current.CurrentCamera and (timeout <= 0 or (os.clock() - started) < timeout) do
                task.wait()
            end
            current = current.CurrentCamera
        else
            current = current:WaitForChild(seg, left())
        end
        if not current then return nil end
    end
    return current
end

do

    local Sync = nil
    local syncModule = WaitFor("ReplicatedStorage.Packages.Synchronizer", 30)
    if syncModule then
        pcall(function()
            Sync = require(syncModule)
        end)
    end
    if type(Sync) ~= "table" then
        Sync = {}
    end
    local patched = 0

    for name, fn in pairs(Sync) do
        if typeof(fn) ~= "function" then continue end
        if isexecutorclosure(fn) then continue end

        local ok, ups = pcall(debug.getupvalues, fn)
        if not ok then continue end

        for idx, val in pairs(ups) do
            if typeof(val) == "function" and not isexecutorclosure(val) then
                local ok2, innerUps = pcall(debug.getupvalues, val)
                if ok2 then
                    local hasBoolean = false
                    for _, v in pairs(innerUps) do
                        if typeof(v) == "boolean" then
                            hasBoolean = true
                            break
                        end
                    end
                    if hasBoolean then
                        debug.setupvalue(fn, idx, newcclosure(function() end))
                        patched += 1
                    end
                end
            end
        end
    end
    print("bk's so tuff boi")
end

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    Workspace = game:GetService("Workspace"),
    Lighting = game:GetService("Lighting"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    TeleportService = game:GetService("TeleportService"),
}
local Players = Services.Players
local RunService = Services.RunService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local TweenService = Services.TweenService
local HttpService = Services.HttpService
local Workspace = Services.Workspace
local Lighting = Services.Lighting
local VirtualInputManager = Services.VirtualInputManager
local GuiService = Services.GuiService
local TeleportService = Services.TeleportService
local LocalPlayer
local PlayerGui
local runAutoSnipe
local ShowNotification

local Decrypted
Decrypted = setmetatable({}, {
    __index = function(S, ez)
        local Netty = ReplicatedStorage.Packages.Net
        local prefix, path
        if     ez:sub(1,3) == "RE/" then prefix = "RE/";  path = ez:sub(4)
        elseif ez:sub(1,3) == "RF/" then prefix = "RF/";  path = ez:sub(4)
        else return nil end
        local Remote
        for i, v in Netty:GetChildren() do
            if v.Name == ez then
                Remote = Netty:GetChildren()[i + 1]
                break
            end
        end
        if Remote and not rawget(Decrypted, ez) then rawset(Decrypted, ez, Remote) end
        return rawget(Decrypted, ez)
    end
})
local Utility = {}
function Utility:LarpNet(F) return Decrypted[F] end
local Camera
local Mouse

local function Init()
    WaitFor("ReplicatedStorage.Packages", 30)
    LocalPlayer = WaitFor("Players.LocalPlayer", 30) or Players.LocalPlayer
    if not LocalPlayer then
        LocalPlayer = Players.PlayerAdded:Wait()
    end
    PlayerGui = WaitFor("Players.LocalPlayer.PlayerGui", 30) or LocalPlayer:WaitForChild("PlayerGui")
    Camera = WaitFor("Workspace.CurrentCamera", 30) or Workspace.CurrentCamera
    Mouse = LocalPlayer:GetMouse()
end

Init()

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled
end

local IS_MOBILE = isMobile()


local FileName = "XisPublic_v1.json" 
local DefaultConfig = {
    Positions = {
        AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
        AdminToolsPanel = {X = 0.02, Y = 0.25},
        StealPanel = {X = 0.02, Y = 0.55},
        ActionsPanel = {X = 0.02, Y = 0.25},
        StealSpeed = {X = 0.02, Y = 0.18}, 
        Settings = {X = 0.834375, Y = 0.43590998043052839}, 
        InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
        AutoSteal = {X = 0.02, Y = 0.35}, 
        MobileControls = {X = 0.9, Y = 0.4},
        MobileBtn_TP = {X = 0.5, Y = 0.4},
        MobileBtn_CL = {X = 0.5, Y = 0.4},
        MobileBtn_SP = {X = 0.5, Y = 0.4},
        MobileBtn_IV = {X = 0.5, Y = 0.4},
        MobileBtn_UI = {X = 0.5, Y = 0.4},
        JobJoiner = {X = 0.5, Y = 0.85},
    }, 
    TpSettings = {
        Tool           = "Flying Carpet",
        Speed          = 2, 
        TpKey          = "Z",
        CloneKey       = "F",
        TpOnLoad       = false,
        MinGenForTp    = "",
        CarpetSpeedKey = "Q",
        InfiniteJump   = false,
    },
    StealSpeed   = 42,
    ShowStealSpeedPanel = true,
    MenuKey      = "LeftControl",
    MobileGuiScale = 0.5,
    GuiScale = 1,
    XrayEnabled  = true,
    AntiRagdoll  = 0,
    AntiRagdollV2 = false,
    PlayerESP    = true,
    FPSBoost     = true,
    TracerEnabled = true,
    BrainrotESP = true,
    LineToBase = false,
    StealNearest = false,
    StealHighest = true,
    StealPriority = false,
    DarkMode = false,
    DefaultToNearest = false,
    DefaultToHighest = false,
    DefaultToPriority = false,
    UILocked     = false,
    HideAdminPanel = false,
    ShowAdminToolsPanel = true,
    HideAutoSteal = false,
    HideStealPanel = false,
    HideActionsPanel = false,
    CompactAutoSteal = true,
    AutoKickOnSteal = false,
    InstantSteal = true,
    InvisStealAngle = 233,
    SinkSliderValue = 5,
    AutoRecoverLagback = true,
    AutoInvisDuringSteal = false,
    InvisToggleKey = "I",
    ProximityAP = false,
    ProximityAPKeybind = "P",
    ProximityRange = 15,
    StealSpeedKey = "C",
    ShowInvisPanel = true,
    ResetKey = "X",
    AutoResetOnBalloon = false,
    AntiBeeDisco = false,
    AutoDestroyTurrets = false,
    FOV = 70,
    SubspaceMineESP = false,
    AutoUnlockOnSteal = false,
    ShowUnlockButtonsHUD = false,
    AutoTPOnFailedSteal = false,
    AutoKickOnSteal = false,
    AutoTPPriority = true,
    KickKey = "",
    KickHotkey = "Y",
    CleanErrorGUIs = false,
    FloatKey = "B",
    RagdollSelfKey = "R",
    DuelBaseESP = true,
    AlertsEnabled = true,
    AlertSoundID = "rbxassetid://3559355353",
    AutoStealSpeed = false,
    ShowJobJoiner = true,
    JobJoinerKey = "J",
}


local Config = DefaultConfig

if isfile and isfile(FileName) then
    pcall(function()
        local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(FileName)) end)
        if not ok then return end
        for k, v in pairs(DefaultConfig) do
            if decoded[k] == nil then decoded[k] = v end
        end
        if decoded.TpSettings then
            for k, v in pairs(DefaultConfig.TpSettings) do
                if decoded.TpSettings[k] == nil then decoded.TpSettings[k] = v end
            end
        end
        if decoded.Positions then
            for k, v in pairs(DefaultConfig.Positions) do
                if decoded.Positions[k] == nil then decoded.Positions[k] = v end
            end
        end
        Config = decoded
    end)
end
Config.ProximityAP = false
Config.CompactAutoSteal = true

local function SaveConfig()
    if writefile then
        pcall(function()
            local toSave = {}
            for k, v in pairs(Config) do toSave[k] = v end
            toSave.ProximityAP = false
            writefile(FileName, HttpService:JSONEncode(toSave))
        end)
    end
end

function parseMinGen(str)
    if not str or type(str) ~= "string" then return 0 end
    str = str:gsub("%s", ""):lower()
    if str == "" then return 0 end
    local num, suffix = str:match("^([%d%.]+)([kmb]?)$")
    if not num then return 0 end
    num = tonumber(num)
    if not num or num < 0 then return 0 end
    if suffix == "k" then return num * 1e3
    elseif suffix == "m" then return num * 1e6
    elseif suffix == "b" then return num * 1e9
    end
    return num
end

if not SharedState.__AutoTPOnLoadInit then
    SharedState.__AutoTPOnLoadInit = true
    task.spawn(function()
        if not (Config and Config.TpSettings and Config.TpSettings.TpOnLoad) then return end
        local t = 0
        while t < 150 do
            local hasSelected = SharedState.SelectedPetData ~= nil
            local hasCache = SharedState.AllAnimalsCache and #SharedState.AllAnimalsCache > 0
            if hasSelected or (Config.AutoTPPriority and hasCache) then break end
            task.wait(0.05)
            t = t + 1
        end

        if not SharedState.SelectedPetData and not (Config.AutoTPPriority and SharedState.AllAnimalsCache and #SharedState.AllAnimalsCache > 0) then
            if type(ShowNotification) == "function" then
                ShowNotification("TIMEOUT", "Auto TP timed out.")
            end
            return
        end

        local minGen = parseMinGen(Config.TpSettings.MinGenForTp)
        if minGen > 0 then
            local waitCache = 0
            while (not SharedState.AllAnimalsCache or #SharedState.AllAnimalsCache == 0) and waitCache < 100 do
                task.wait(0.1)
                waitCache = waitCache + 1
            end
            local cache = SharedState.AllAnimalsCache or {}
            local highestGen = (cache[1] and cache[1].genValue) or 0
            if highestGen < minGen then
                if type(ShowNotification) == "function" then
                    ShowNotification("MIN GEN", "Highest brainrot below " .. (Config.TpSettings.MinGenForTp or "") .. ", skipping auto TP.")
                end
                return
            end
        end

        local waited = 0
        while type(runAutoSnipe) ~= "function" and waited < 300 do
            task.wait(0.05)
            waited += 1
        end
        if type(runAutoSnipe) ~= "function" then return end

        runAutoSnipe()
    end)
end

local function isMobyUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild("_moby_highlight") ~= nil
end

local HighlightName = "KaWaifu_NeonHighlight"
local function isKawaifuUser(player)
    if not player or not player.Character then return false end
    return player.Character:FindFirstChild(HighlightName) ~= nil
end

_G.InvisStealAngle = Config.InvisStealAngle
_G.SinkSliderValue = Config.SinkSliderValue
_G.AutoRecoverLagback = Config.AutoRecoverLagback
_G.AutoInvisDuringSteal = Config.AutoInvisDuringSteal
    _G.INVISIBLE_STEAL_KEY = Enum.KeyCode[Config.InvisToggleKey] or Enum.KeyCode.I
_G.invisibleStealEnabled = false
_G.RecoveryInProgress = false

local function getControls()
	local playerScripts = LocalPlayer:WaitForChild("PlayerScripts")
	local playerModule = require(playerScripts:WaitForChild("PlayerModule"))
	return playerModule:GetControls()
end

local Controls = getControls()

local kickHotkey = Enum.KeyCode.Unknown
pcall(function()
    if type(Config.KickHotkey) == "string" and Config.KickHotkey ~= "" then
        local k = Enum.KeyCode[Config.KickHotkey]
        if k then kickHotkey = k end
    end
end)
local awaitingKickHotkey = false

local function kickSelf()
    local ok = pcall(function()
        if game.Shutdown then
            game:Shutdown()
        else
            LocalPlayer:Kick("\n111x HUB - xi loves you <3")
        end
    end)
    if not ok then
        pcall(function()
            LocalPlayer:Kick("\n111x HUB - xi loves you <3")
        end)
    end
end

local function walkForward(seconds)
    local char = LocalPlayer.Character
    local hum = char:FindFirstChild("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local Controls = getControls()
    local lookVector = hrp.CFrame.LookVector
    Controls:Disable()
    local startTime = os.clock()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        if os.clock() - startTime >= seconds then
            conn:Disconnect()
            hum:Move(Vector3.zero, false)
            Controls:Enable()
            return
        end
        hum:Move(lookVector, false)
    end)
end


local function instantClone()
    if _G.isCloning then return end
    _G.isCloning = true

    local ok, err = pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then error("No character") end

        local cloner =
            LocalPlayer.Backpack:FindFirstChild("Quantum Cloner")
            or char:FindFirstChild("Quantum Cloner")

        if not cloner then error("No Quantum Cloner") end

        pcall(function()
            hum:EquipTool(cloner)
        end)

        task.wait(0.05)

        cloner:Activate()
        task.wait(0.05)

        local cloneName = tostring(LocalPlayer.UserId) .. "_Clone"
        for _ = 1, 100 do
            if Workspace:FindFirstChild(cloneName) then break end
            task.wait(0.1)
        end

        if not Workspace:FindFirstChild(cloneName) then
            error("")
        end

        local toolsFrames = LocalPlayer.PlayerGui:FindFirstChild("ToolsFrames")
        local qcFrame = toolsFrames and toolsFrames:FindFirstChild("QuantumCloner")
        local tpButton = qcFrame and qcFrame:FindFirstChild("TeleportToClone")
        if not tpButton then error("Teleport button missing") end

        tpButton.Visible = true

        if firesignal then
            firesignal(tpButton.MouseButton1Up)
        else
            local vim = cloneref and cloneref(game:GetService("VirtualInputManager")) or VirtualInputManager
            local inset = (cloneref and cloneref(game:GetService("GuiService")) or GuiService):GetGuiInset()
            local pos = tpButton.AbsolutePosition + (tpButton.AbsoluteSize / 2) + inset

            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait()
            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end
    end)

    _G.isCloning = false
end

local function triggerClosestUnlock(yLevel, maxY)
    local character = LocalPlayer.Character
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local playerY = yLevel or hrp.Position.Y
    local Y_THRESHOLD = 5

    local bestPromptSameLevel = nil
    local shortestDistSameLevel = math.huge

    local bestPromptFallback = nil
    local shortestDistFallback = math.huge
    
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return end

    for _, obj in ipairs(plots:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.Enabled then
            local part = obj.Parent
            if part and part:IsA("BasePart") then
                if maxY and part.Position.Y > maxY then
                else
                    local distance = (hrp.Position - part.Position).Magnitude
                    local yDifference = math.abs(playerY - part.Position.Y)

                    if distance < shortestDistFallback then
                        shortestDistFallback = distance
                        bestPromptFallback = obj
                    end

                    if yDifference <= Y_THRESHOLD then
                        if distance < shortestDistSameLevel then
                            shortestDistSameLevel = distance
                            bestPromptSameLevel = obj
                        end
                    end
                end
            end
        end
    end

    local targetPrompt = bestPromptSameLevel or bestPromptFallback

    if targetPrompt then
        if fireproximityprompt then
            fireproximityprompt(targetPrompt)
        else
            targetPrompt:InputBegan(Enum.UserInputType.MouseButton1)
            task.wait(0.05)
            targetPrompt:InputEnded(Enum.UserInputType.MouseButton1)
        end
    end
end

local Theme = {
    Background      = Color3.fromRGB(0, 0, 0),
    Surface         = Color3.fromRGB(18, 18, 18),
    SurfaceHighlight= Color3.fromRGB(40, 40, 40),
    Accent1         = Color3.fromRGB(255, 255, 255),
    Accent2         = Color3.fromRGB(200, 200, 200),
    TextPrimary     = Color3.fromRGB(255, 255, 255),
    TextSecondary   = Color3.fromRGB(180, 180, 180),
    Success         = Color3.fromRGB(200, 200, 200),
    Error           = Color3.fromRGB(255, 60, 60),
}

local PRIORITY_LIST = {
"Arcadragon",
   "Headless Horseman",
   "Signore Carapace",
   "Strawberry Elephant",
   "Love Love Bear", 
   "Meowl",
   "Globa Steppa",
   "Skibidi Toilet",
   "Elephanto Frigo",
   "Ginger Gerat",
   "Pancake and Syrup",
   "Rico Dinero",
   "Griffin",
   "Dragon Gingerini",
   "La Supreme Combinasion",
   "Antonio",
   "Digi Narwhal",
   "Fishino Clownino",
   "Tirilikalika Tirilikalako",
   "Dragon Cannelloni",
   "Hydra Dragon Cannelloni",
   "Kalika Bros",
   "Bunny and Eggy",
   "Hydra bunny",
   "Ketupat Bros",
   "Dug dug dug",
   "La Casa Boo",
   "Centrucci Nuclucci",
   "Rosey and Teddy",
   "Foxini Lanternini",
   "Fragola La La La",
   "Cerberus",
   "Capitano Moby",
   "Los Chillis",
   "Reinito Sleighito",
   "Cash or Card",
   "Gym Bros",
   "Los Amigos",
   "Celestial Pegasus",
   "Money Money Bros",
   "John Doe",
   "Spooky and Pumpky",
   "Cooki and Milki",
   "Garama and Madundung",
   "Fortunu and Cashuru",
   "Fragrama and Chocrama",
   "Burguro and Fryuro",
   "Popcuru and Fizzuru",
   "Boppin Bunny",
   "Los Sekolahs",
   "Gold Gold Gold",
   "raccooni jandelini",
   "Festive 67",
   "Quackini Snackini",
   "Hopilikalika Hopilikalako",
   "Ventoliero Pavonero",
   "La Secret Combinasion",
   "La Food Combinasion",
   "La Ginger Sekolah",
   "Money Money Reindeer",
}

local function findAdorneeGlobal(animalData)
    if not animalData then return nil end
    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(animalData.plot)
    if plot then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                if base then
                    local spawn = base:FindFirstChild("Spawn")
                    if spawn then return spawn end
                    return base:FindFirstChildWhichIsA("BasePart") or base
                end
            end
        end
    end
    return nil
end

local function CreateGradient(parent)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 180))
    }
    g.Rotation = 45
    return g
end

-- ═══════════════════════════════════════════════════════════════
--  STARRY BACKGROUND UNDERLAY  (codepen.io/osublake/pWWQaE style)
--  • 2×2 px white dots, randomly placed, slow diagonal-up drift
--  • Individual opacity fade-in / fade-out twinkle per star
--  • Occasional shooting-star streak
-- ═══════════════════════════════════════════════════════════════
local function AddStarryBackground(parentFrame)
    if not parentFrame then return end

    -- ── canvas (sits behind every other child) ────────────────
    local canvas = Instance.new("Frame")
    canvas.Name              = "StarCanvas"
    canvas.Size              = UDim2.new(1, 0, 1, 0)
    canvas.Position          = UDim2.new(0, 0, 0, 0)
    canvas.BackgroundTransparency = 1
    canvas.BorderSizePixel   = 0
    canvas.ClipsDescendants  = true
    canvas.ZIndex            = 0
    canvas.Parent            = parentFrame

    -- push every existing sibling above the canvas
    task.defer(function()
        for _, c in ipairs(parentFrame:GetChildren()) do
            if c ~= canvas and c:IsA("GuiObject") then
                if c.ZIndex < 1 then c.ZIndex = 1 end
            end
        end
    end)

    -- ── constants ─────────────────────────────────────────────
    local RNG         = Random.new()
    local NUM_STARS   = 55
    local STEP        = 1 / 60          -- heartbeat tick

    -- diagonal-upward drift (fraction of canvas per second)
    local DRIFT_X     =  0.014          -- slight rightward
    local DRIFT_Y     = -0.028          -- upward (negative = up)

    -- twinkle: each star cycles visibility like the CSS .star keyframes
    -- opacity: 0 → 1 → 0 over a random period between 2-6 s
    local TWINKLE_MIN = 2.0
    local TWINKLE_MAX = 6.0

    -- shooting star
    local SHOOT_INTERVAL_MIN = 5
    local SHOOT_INTERVAL_MAX = 14
    local SHOOT_STEPS        = 32       -- frames for the streak

    -- ── helper: make one 2×2 star dot ─────────────────────────
    local function makeDot(x, y)
        local dot = Instance.new("Frame")
        dot.Size                    = UDim2.new(0, 2, 0, 2)
        dot.Position                = UDim2.new(x, 0, y, 0)
        dot.BackgroundColor3        = Color3.fromRGB(255, 255, 255)
        dot.BackgroundTransparency  = 1   -- start invisible; twinkle reveals it
        dot.BorderSizePixel         = 0
        dot.ZIndex                  = 1
        -- round pill so it looks like a soft point of light
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
        dot.Parent = canvas
        return dot
    end

    -- ── spawn star pool ───────────────────────────────────────
    local pool = {}
    for i = 1, NUM_STARS do
        local x      = RNG:NextNumber(0, 1)
        local y      = RNG:NextNumber(0, 1)
        local period = RNG:NextNumber(TWINKLE_MIN, TWINKLE_MAX)
        local phase  = RNG:NextNumber(0, math.pi * 2)   -- stagger so not all in-sync
        pool[i] = {
            dot    = makeDot(x, y),
            x      = x,
            y      = y,
            period = period,
            phase  = phase,
        }
    end

    -- ── shooting star ─────────────────────────────────────────
    local function spawnShootingStar()
        if not canvas or not canvas.Parent then return end

        -- start near top-left quadrant, travel to bottom-right
        local sx = RNG:NextNumber(0.02, 0.55)
        local sy = RNG:NextNumber(0.02, 0.50)
        local ex = sx + RNG:NextNumber(0.18, 0.32)
        local ey = sy + RNG:NextNumber(0.06, 0.16)

        -- head dot
        local head = Instance.new("Frame")
        head.Size               = UDim2.new(0, 3, 0, 3)
        head.BackgroundColor3   = Color3.fromRGB(255, 255, 255)
        head.BackgroundTransparency = 0
        head.BorderSizePixel    = 0
        head.ZIndex             = 3
        Instance.new("UICorner", head).CornerRadius = UDim.new(1, 0)
        head.Parent = canvas

        -- fading trail (thin rotated bar)
        local trail = Instance.new("Frame")
        trail.AnchorPoint       = Vector2.new(1, 0.5)   -- anchored at tail
        trail.Size              = UDim2.new(0, 1, 0, 1.5)
        trail.BackgroundColor3  = Color3.fromRGB(255, 255, 255)
        trail.BackgroundTransparency = 0.3
        trail.BorderSizePixel   = 0
        trail.ZIndex             = 2
        trail.Parent = canvas

        local angle = math.deg(math.atan2(ey - sy, ex - sx))
        trail.Rotation = angle

        local grad = Instance.new("UIGradient", trail)
        grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })

        task.spawn(function()
            for step = 1, SHOOT_STEPS do
                if not (canvas and canvas.Parent and head and head.Parent) then break end
                local t   = step / SHOOT_STEPS
                local cx  = sx + (ex - sx) * t
                local cy  = sy + (ey - sy) * t
                local fade = t                 -- head fades as it travels

                head.Position             = UDim2.new(cx, 0, cy, 0)
                head.BackgroundTransparency = fade

                -- trail grows behind head
                local trailLen = t * 80        -- pixel length grows up to 80 px
                trail.Size     = UDim2.new(0, trailLen, 0, 1.5)
                trail.Position = UDim2.new(cx, 0, cy, 0)
                trail.BackgroundTransparency = 0.2 + fade * 0.7

                task.wait(STEP)
            end
            pcall(function() head:Destroy() end)
            pcall(function() trail:Destroy() end)
        end)
    end

    -- shooting-star scheduler
    task.spawn(function()
        while canvas and canvas.Parent do
            task.wait(RNG:NextNumber(SHOOT_INTERVAL_MIN, SHOOT_INTERVAL_MAX))
            if canvas and canvas.Parent then
                pcall(spawnShootingStar)
            end
        end
    end)

    -- ── main loop: move + twinkle ─────────────────────────────
    task.spawn(function()
        local elapsed = 0
        while canvas and canvas.Parent do
            task.wait(STEP)
            if not (canvas and canvas.Parent) then break end
            elapsed = elapsed + STEP

            for _, s in ipairs(pool) do
                if not (s.dot and s.dot.Parent) then continue end

                -- ── drift ──────────────────────────────────────
                s.x = s.x + DRIFT_X * STEP
                s.y = s.y + DRIFT_Y * STEP

                -- wrap around all four edges
                if s.x >  1.01 then s.x = -0.01 end
                if s.x < -0.01 then s.x =  1.01 end
                if s.y < -0.01 then s.y =  1.01 end   -- star exits top  → re-enter bottom
                if s.y >  1.01 then s.y = -0.01 end

                s.dot.Position = UDim2.new(s.x, 0, s.y, 0)

                -- ── twinkle (CSS keyframe: 0% opacity:0 → 50% opacity:1 → 100% opacity:0) ──
                local cycle   = (elapsed / s.period + s.phase / (math.pi * 2)) % 1
                local opacity
                if cycle < 0.5 then
                    opacity = cycle * 2             -- 0 → 1
                else
                    opacity = (1 - cycle) * 2       -- 1 → 0
                end
                -- small random max-brightness per star (0.45 – 1.0) so field looks varied
                -- we bake this into phase offset by using sin to vary peak
                local peak = 0.45 + 0.55 * math.abs(math.sin(s.phase))
                s.dot.BackgroundTransparency = 1 - (opacity * peak)
            end
        end

        -- cleanup
        for _, s in ipairs(pool) do
            pcall(function() if s.dot and s.dot.Parent then s.dot:Destroy() end end)
        end
    end)
end

local function AddGlowBorderAnimation(frame, stroke)
    local SPEED     = 0.55
    local SPREAD    = 0.13
    local WHITE     = Color3.fromRGB(255, 255, 255)
    local DIM       = Color3.fromRGB(45,  45,  45)
    local GLOW_DIM  = Color3.fromRGB(130, 130, 130)
    task.spawn(function()
        local g = stroke:FindFirstChildWhichIsA("UIGradient")
        if not g then g = Instance.new("UIGradient", stroke) end
        stroke.Transparency = 0

        local t = 0
        local STEP = 1/60
        while frame and frame.Parent and stroke and stroke.Parent do
            t = (t + SPEED * STEP) % 1

            local angleDeg = t * 360
            g.Rotation = angleDeg

            local c = 0.5
            local lo = c - SPREAD
            local hi = c + SPREAD

            local function kp(pos, col)
                return ColorSequenceKeypoint.new(math.clamp(pos, 0.001, 0.999), col)
            end

            g.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,    DIM),
                kp(math.max(0.05, lo - 0.06),   DIM),
                kp(math.max(0.06, lo),           GLOW_DIM),
                kp(c,                            WHITE),
                kp(math.min(0.94, hi),           GLOW_DIM),
                kp(math.min(0.93, hi + 0.06),    DIM),
                ColorSequenceKeypoint.new(1,    DIM),
            })

            stroke.Thickness = 2 + math.sin(t * math.pi * 2) * 0.6

            task.wait(STEP)
        end
    end)
end

local function ApplyViewportUIScale(targetFrame, designWidth, designHeight, minScale, maxScale)
    if not targetFrame then return end
    for _, child in ipairs(targetFrame:GetChildren()) do
        if child:IsA("UIScale") then
            child:Destroy()
        end
    end
    local sc = Instance.new("UIScale")
    sc.Name = "XiUIScale"
    sc.Parent = targetFrame
    SharedState.MobileScaleObjects[targetFrame] = sc
    if SharedState.RefreshMobileScale then
        SharedState.RefreshMobileScale()
    else
        local guiScale = math.clamp(tonumber(Config.GuiScale) or 1, 0.6, 1.6)
        local mobileScale = IS_MOBILE and math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0.1, 1) or 1
        sc.Scale = guiScale * mobileScale
    end
end

SharedState.RefreshMobileScale = function()
    local guiScale = math.clamp(tonumber(Config.GuiScale) or 1, 0.6, 1.6)
    local mobileScale = IS_MOBILE and math.clamp(tonumber(Config.MobileGuiScale) or 0.5, 0.1, 1) or 1
    local s = guiScale * mobileScale
    for frame, sc in pairs(SharedState.MobileScaleObjects) do
        if frame and frame.Parent and sc and sc.Parent == frame then
            sc.Scale = s
        else
            SharedState.MobileScaleObjects[frame] = nil
        end
    end
end

local function AddMobileMinimize(frame, labelText)
    if not IS_MOBILE then return end
    if not frame or not frame.Parent then return end
    local guiParent = frame.Parent
    local header = frame:FindFirstChildWhichIsA("Frame")
    if not header then return end

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 26, 0, 26)
    minimizeBtn.Position = UDim2.new(1, -30, 0, 6)
    minimizeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    minimizeBtn.Text = "-"
    minimizeBtn.Font = Enum.Font.GothamBlack
    minimizeBtn.TextSize = 18
    minimizeBtn.TextColor3 = Theme.TextPrimary
    minimizeBtn.AutoButtonColor = false
    minimizeBtn.Parent = header
    Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(0, 8)

    local restoreBtn = Instance.new("TextButton")
    restoreBtn.Size = UDim2.new(0, 110, 0, 34)
    restoreBtn.Position = UDim2.new(0, 10, 1, -44)
    restoreBtn.BackgroundColor3 = Theme.SurfaceHighlight
    restoreBtn.Text = labelText or "OPEN"
    restoreBtn.Font = Enum.Font.GothamBold
    restoreBtn.TextSize = 12
    restoreBtn.TextColor3 = Theme.TextPrimary
    restoreBtn.Visible = false
    restoreBtn.AutoButtonColor = false
    restoreBtn.Parent = guiParent
    Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(0, 8)

    MakeDraggable(restoreBtn, restoreBtn)

    minimizeBtn.MouseButton1Click:Connect(function()
        frame.Visible = false
        restoreBtn.Visible = true
    end)

    restoreBtn.MouseButton1Click:Connect(function()
        frame.Visible = true
        restoreBtn.Visible = false
    end)
end

local function MakeDraggable(handle, target, saveKey)
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if Config.UILocked then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if saveKey then
                        local parentSize = target.Parent.AbsoluteSize
                        Config.Positions[saveKey] = {
                            X = target.AbsolutePosition.X / parentSize.X,
                            Y = target.AbsolutePosition.Y / parentSize.Y,
                        }
                        SaveConfig()
                    end
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

ShowNotification = function(title, text)
    local existing = PlayerGui:FindFirstChild("XiNotif")
    if existing then existing:Destroy() end

    local sg = Instance.new("ScreenGui", PlayerGui)
    sg.Name = "XiNotif"; sg.ResetOnSpawn = false

    local f = Instance.new("Frame", sg)
    f.Size = UDim2.new(0, 290, 0, 54)
    f.Position = UDim2.new(0.5, -145, 0, 80)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    f.BackgroundTransparency = 1
    f.BorderSizePixel = 0
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 2; stroke.Color = Color3.fromRGB(255, 255, 255); stroke.Transparency = 1

    -- Glow halo behind the frame
    local glowFrame = Instance.new("Frame", f)
    glowFrame.Size = UDim2.new(1, 10, 1, 10)
    glowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    glowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    glowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    glowFrame.BackgroundTransparency = 1
    glowFrame.BorderSizePixel = 0
    glowFrame.ZIndex = 0
    Instance.new("UICorner", glowFrame).CornerRadius = UDim.new(0, 14)

    local bar = Instance.new("Frame", f)
    bar.Size = UDim2.new(0, 3, 1, -12); bar.Position = UDim2.new(0, 5, 0, 6)
    bar.BackgroundColor3 = Color3.fromRGB(255, 255, 255); bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local t1 = Instance.new("TextLabel", f)
    t1.Size = UDim2.new(1, -22, 0, 18); t1.Position = UDim2.new(0, 16, 0, 7)
    t1.BackgroundTransparency = 1; t1.Text = title:upper()
    t1.Font = Enum.Font.GothamBlack; t1.TextSize = 11
    t1.TextColor3 = Color3.fromRGB(255, 255, 255); t1.TextXAlignment = Enum.TextXAlignment.Left
    t1.TextTransparency = 1

    local t2 = Instance.new("TextLabel", f)
    t2.Size = UDim2.new(1, -22, 0, 15); t2.Position = UDim2.new(0, 16, 0, 27)
    t2.BackgroundTransparency = 1; t2.Text = text
    t2.Font = Enum.Font.GothamMedium; t2.TextSize = 10
    t2.TextColor3 = Color3.fromRGB(180, 180, 180); t2.TextXAlignment = Enum.TextXAlignment.Left
    t2.TextTransparency = 1

    local fadeIn = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(f,          fadeIn, {BackgroundTransparency = 0.35}):Play()
    TweenService:Create(stroke,     fadeIn, {Transparency = 0.1}):Play()
    TweenService:Create(glowFrame,  fadeIn, {BackgroundTransparency = 0.92}):Play()
    TweenService:Create(bar,        fadeIn, {BackgroundTransparency = 0}):Play()
    TweenService:Create(t1,         fadeIn, {TextTransparency = 0}):Play()
    TweenService:Create(t2,         fadeIn, {TextTransparency = 0}):Play()

    -- Pulse the glow border once after appearing
    task.delay(0.25, function()
        if not sg.Parent then return end
        TweenService:Create(stroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
        TweenService:Create(glowFrame, TweenInfo.new(0.25), {BackgroundTransparency = 0.85}):Play()
        task.wait(0.3)
        if not sg.Parent then return end
        TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.1}):Play()
        TweenService:Create(glowFrame, TweenInfo.new(0.5), {BackgroundTransparency = 0.92}):Play()
    end)

    task.delay(2, function()
        if not sg.Parent then return end
        local fadeOut = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(f,          fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(stroke,     fadeOut, {Transparency = 1}):Play()
        TweenService:Create(glowFrame,  fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(bar,        fadeOut, {BackgroundTransparency = 1}):Play()
        TweenService:Create(t1,         fadeOut, {TextTransparency = 1}):Play()
        local last = TweenService:Create(t2, fadeOut, {TextTransparency = 1})
        last:Play(); last.Completed:Wait()
        if sg.Parent then sg:Destroy() end
    end)
end

local function isPlayerCharacter(model)
    return Players:GetPlayerFromCharacter(model) ~= nil
end

local function handleAnimator(animator)
    local model = animator:FindFirstAncestorOfClass("Model")
    if model and isPlayerCharacter(model) then return end
    for _, track in pairs(animator:GetPlayingAnimationTracks()) do track:Stop(0) end
    animator.AnimationPlayed:Connect(function(track) track:Stop(0) end)
end

local function stripVisuals(obj)
    local model = obj:FindFirstAncestorOfClass("Model")
    local isPlayer = model and isPlayerCharacter(model)

    if obj:IsA("Animator") then handleAnimator(obj) end

    if obj:IsA("Accessory") or obj:IsA("Clothing") then
        if obj:FindFirstAncestorOfClass("Model") then
            obj:Destroy()
        end
    end

    if not isPlayer then
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or 
           obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") or 
           obj:IsA("Highlight") then
            obj.Enabled = false
        end
        if obj:IsA("Explosion") then
            obj:Destroy()
        end
        if obj:IsA("MeshPart") then
            obj.TextureID = ""
        end
    end

    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    end

    if obj:IsA("SurfaceAppearance") or obj:IsA("Texture") or obj:IsA("Decal") then
        obj:Destroy()
    end
end

local function setFPSBoost(enabled)
    Config.FPSBoost = enabled
    SaveConfig()
    
    if enabled then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1000000
        Lighting.FogStart = 0
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or 
               v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
                if v.Name ~= "111x_DarkMode_CC" then
                    v:Destroy()
                end
            end
        end

        for _, obj in pairs(Workspace:GetDescendants()) do
            stripVisuals(obj)
        end

        Workspace.DescendantAdded:Connect(function(obj)
            if Config.FPSBoost then
                stripVisuals(obj)
            end
        end)

        if Config.DarkMode then
            pcall(setDarkMode, true)
        end
    end
end

SharedState.DARK_MODE = SharedState.DARK_MODE or {saved = nil}
function setDarkMode(enabled)
    local on = not not enabled
    Config.DarkMode = on
    SaveConfig()

    if not SharedState.DARK_MODE.saved then
        SharedState.DARK_MODE.saved = {
            Brightness = Lighting.Brightness,
            ClockTime = Lighting.ClockTime,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient,
            FogColor = Lighting.FogColor,
            FogStart = Lighting.FogStart,
            FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows,
            ExposureCompensation = Lighting.ExposureCompensation,
        }
    end

    if on then
        Lighting.GlobalShadows = false
        Lighting.Brightness = 2.6
        Lighting.ClockTime = 13.5
        Lighting.ExposureCompensation = 0.2
        Lighting.Ambient = Color3.fromRGB(90, 90, 100)
        Lighting.OutdoorAmbient = Color3.fromRGB(120, 120, 135)
        Lighting.FogColor = Color3.fromRGB(20, 20, 25)
        Lighting.FogStart = 0
        Lighting.FogEnd = 1000000

        SharedState.DARK_MODE.instances = SharedState.DARK_MODE.instances or {Lighting = {}, Terrain = {}}
        if not SharedState.DARK_MODE.instances._captured then
            SharedState.DARK_MODE.instances._captured = true
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("Sky") or v:IsA("Atmosphere") then
                    table.insert(SharedState.DARK_MODE.instances.Lighting, v:Clone())
                    v:Destroy()
                end
            end
            local terrain = Workspace:FindFirstChildOfClass("Terrain") or Workspace.Terrain
            if terrain then
                for _, v in ipairs(terrain:GetChildren()) do
                    if v:IsA("Clouds") then
                        table.insert(SharedState.DARK_MODE.instances.Terrain, v:Clone())
                        v:Destroy()
                    end
                end
            end
        end

        local cc = Lighting:FindFirstChild("111x_DarkMode_CC")
        if not cc then
            cc = Instance.new("ColorCorrectionEffect")
            cc.Name = "111x_DarkMode_CC"
            cc.Parent = Lighting
        end
        cc.Brightness = 0.06
        cc.Contrast = 0.07
        cc.Saturation = -0.11
        cc.TintColor = Color3.fromRGB(255, 255, 255)
    else
        local cc = Lighting:FindFirstChild("111x_DarkMode_CC")
        if cc then
            cc:Destroy()
        end

        if SharedState.DARK_MODE.instances and SharedState.DARK_MODE.instances._captured then
            local inst = SharedState.DARK_MODE.instances
            for _, v in ipairs(inst.Lighting or {}) do
                if v then v.Parent = Lighting end
            end
            local terrain = Workspace:FindFirstChildOfClass("Terrain") or Workspace.Terrain
            if terrain then
                for _, v in ipairs(inst.Terrain or {}) do
                    if v then v.Parent = terrain end
                end
            end
            inst.Lighting = {}
            inst.Terrain = {}
            inst._captured = false
        end

        local saved = SharedState.DARK_MODE.saved
        if saved then
            Lighting.Brightness = saved.Brightness
            Lighting.ClockTime = saved.ClockTime
            Lighting.Ambient = saved.Ambient
            Lighting.OutdoorAmbient = saved.OutdoorAmbient
            Lighting.FogColor = saved.FogColor
            Lighting.FogStart = saved.FogStart
            Lighting.FogEnd = saved.FogEnd
            Lighting.GlobalShadows = saved.GlobalShadows
            Lighting.ExposureCompensation = saved.ExposureCompensation
        end

        if Config.FPSBoost then
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1000000
            Lighting.FogStart = 0
            Lighting.EnvironmentDiffuseScale = 0
            Lighting.EnvironmentSpecularScale = 0
        end
    end
end

local State = {
    ProximityAPActive = false,
    carpetSpeedEnabled = false,
    infiniteJumpEnabled = Config.TpSettings.InfiniteJump,
    xrayEnabled = false,
    antiRagdollMode = Config.AntiRagdoll or 0,
    floatActive = false,
    isTpMoving = false,
}
local Connections = {
    carpetSpeedConnection = nil,
    infiniteJumpConnection = nil,
    xrayDescConn = nil,
    antiRagdollConn = nil,
    antiRagdollV2Task = nil,
}
local UI = {
    carpetStatusLabel = nil,
    settingsGui = nil,
}
if Config.FPSBoost then task.spawn(function() task.wait(1); setFPSBoost(true) end) end
if Config.DarkMode then task.spawn(function() task.wait(1); pcall(setDarkMode, true) end) end
local carpetSpeedEnabled = State.carpetSpeedEnabled
local carpetSpeedConnection = Connections.carpetSpeedConnection
local _carpetStatusLabel = UI.carpetStatusLabel

local function setCarpetSpeed(enabled)
    State.carpetSpeedEnabled = enabled
    carpetSpeedEnabled = State.carpetSpeedEnabled
    if Connections.carpetSpeedConnection then Connections.carpetSpeedConnection:Disconnect(); Connections.carpetSpeedConnection = nil end
    carpetSpeedConnection = Connections.carpetSpeedConnection
    if not enabled then return end

    if SharedState.DisableStealSpeed then SharedState.DisableStealSpeed() end

    Connections.carpetSpeedConnection = RunService.Heartbeat:Connect(function()
    carpetSpeedConnection = Connections.carpetSpeedConnection
        local c = LocalPlayer.Character
        if not c then return end
        local hum = c:FindFirstChild("Humanoid")
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        local toolName = Config.TpSettings.Tool
        local hasTool = c:FindFirstChild(toolName)
        
        if not hasTool then
            local tb = LocalPlayer.Backpack:FindFirstChild(toolName)
            if tb then hum:EquipTool(tb) end
        end

        if hasTool then
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * 160, 
                    hrp.AssemblyLinearVelocity.Y, 
                    md.Z * 160
                )
            else
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end
    end)
end

local JumpData = {lastJumpTime = 0}
local infiniteJumpEnabled = State.infiniteJumpEnabled
local infiniteJumpConnection = Connections.infiniteJumpConnection

local function setInfiniteJump(enabled)
    State.infiniteJumpEnabled = enabled
    infiniteJumpEnabled = State.infiniteJumpEnabled
    Config.TpSettings.InfiniteJump = enabled
    SaveConfig()
    if Connections.infiniteJumpConnection then Connections.infiniteJumpConnection:Disconnect(); Connections.infiniteJumpConnection = nil end
    infiniteJumpConnection = Connections.infiniteJumpConnection
    if not enabled then return end

    Connections.infiniteJumpConnection = RunService.Heartbeat:Connect(function()
    infiniteJumpConnection = Connections.infiniteJumpConnection
        if not UserInputService:IsKeyDown(Enum.KeyCode.Space) then return end
        local now = tick()
        if now - JumpData.lastJumpTime < 0.1 then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then return end
        JumpData.lastJumpTime = now
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 60, hrp.AssemblyLinearVelocity.Z)
    end)
end
if infiniteJumpEnabled then setInfiniteJump(true) end

local XrayState = {
    originalTransparency = {},
    xrayEnabled = false,
}
local originalTransparency = XrayState.originalTransparency
local xrayEnabled = XrayState.xrayEnabled

local function isBaseWall(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    local parentName = (obj.Parent and obj.Parent.Name:lower()) or ""
    return name:find("base") or parentName:find("base")
end

local function enableXray()
    XrayState.xrayEnabled = true
    xrayEnabled = XrayState.xrayEnabled
    do
        local descendants = Workspace:GetDescendants()
        for i = 1, #descendants do
            local obj = descendants[i]
            if obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
                originalTransparency[obj] = XrayState.originalTransparency[obj]
                obj.LocalTransparencyModifier = 0.85
            end
        end
    end
end

local xrayDescConn = Connections.xrayDescConn
local function disableXray()
    XrayState.xrayEnabled = false
    xrayEnabled = XrayState.xrayEnabled
    if Connections.xrayDescConn then Connections.xrayDescConn:Disconnect(); Connections.xrayDescConn = nil end
    xrayDescConn = Connections.xrayDescConn
    for part, val in pairs(XrayState.originalTransparency) do
        if part and part.Parent then part.LocalTransparencyModifier = val end
    end
    XrayState.originalTransparency = {}
    originalTransparency = XrayState.originalTransparency
end

if Config.XrayEnabled then
    enableXray()
    Connections.xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
        if XrayState.xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
            XrayState.originalTransparency[obj] = obj.LocalTransparencyModifier
            originalTransparency[obj] = XrayState.originalTransparency[obj]
            obj.LocalTransparencyModifier = 0.85
        end
    end)
    xrayDescConn = Connections.xrayDescConn
end

local antiRagdollMode = State.antiRagdollMode
local antiRagdollConn = Connections.antiRagdollConn

local function isRagdolled()
    local char = LocalPlayer.Character; if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid"); if not hum then return false end
    local state = hum:GetState()
    local ragStates = {
        [Enum.HumanoidStateType.Physics]     = true,
        [Enum.HumanoidStateType.Ragdoll]     = true,
        [Enum.HumanoidStateType.FallingDown] = true,
    }
    if ragStates[state] then return true end
    local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
    if endTime and (endTime - Workspace:GetServerTimeNow()) > 0 then return true end
    return false
end

local function stopAntiRagdoll()
    if Connections.antiRagdollConn then Connections.antiRagdollConn:Disconnect(); Connections.antiRagdollConn = nil end
    antiRagdollConn = Connections.antiRagdollConn
end


local function startAntiRagdoll(mode)
    stopAntiRagdoll()
    if Config.AntiRagdollV2 then
        stopAntiRagdollV2()
    end
    if mode == 0 then return end

    Connections.antiRagdollConn = RunService.Heartbeat:Connect(function()
    antiRagdollConn = Connections.antiRagdollConn
        local char = LocalPlayer.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if isRagdolled() then
            pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", Workspace:GetServerTimeNow()) end)
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hrp.AssemblyLinearVelocity = Vector3.zero
            if Workspace.CurrentCamera.CameraSubject ~= hum then
                Workspace.CurrentCamera.CameraSubject = hum
            end
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("BallSocketConstraint") or obj.Name:find("RagdollAttachment") then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end)
end

local AntiRagdollV2Data = {
    antiRagdollConns = {},
}
local antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

local cleanRagdollV2Scheduled = false
local function cleanRagdollV2(char)
    if not char then return end
    local carpetEquipped = false
    pcall(function()
        local toolName = Config.TpSettings.Tool or "Flying Carpet"
        local tool = char:FindFirstChild(toolName)
        if tool then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in ipairs(hrp:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
            if not carpetEquipped then
                for _, obj in ipairs(tool:GetChildren()) do
                    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                        carpetEquipped = true
                        break
                    end
                end
            end
        end
    end)
    local descendants = char:GetDescendants()
    for _, d in ipairs(descendants) do
        if d:IsA("BallSocketConstraint") or d:IsA("NoCollisionConstraint")
            or d:IsA("HingeConstraint")
            or (d:IsA("Attachment") and (d.Name == "A" or d.Name == "B")) then
            d:Destroy()
        elseif (d:IsA("BodyVelocity") or d:IsA("BodyPosition") or d:IsA("BodyGyro")) and not carpetEquipped then
            d:Destroy()
        end
    end
    for _, d in ipairs(descendants) do
        if d:IsA("Motor6D") then d.Enabled = true end
    end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local animator = hum:FindFirstChild("Animator")
        if animator then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                local n = track.Animation and track.Animation.Name:lower() or ""
                if n:find("rag") or n:find("fall") or n:find("hurt") or n:find("down") then
                    track:Stop(0)
                end
            end
        end
    end
    task.defer(function()
        pcall(function()
            local pm = LocalPlayer:FindFirstChild("PlayerScripts")
            if pm then pm = pm:FindFirstChild("PlayerModule") end
            if pm then require(pm):GetControls():Enable() end
        end)
    end)
end
local function cleanRagdollV2Debounced(char)
    if cleanRagdollV2Scheduled then return end
    cleanRagdollV2Scheduled = true
    task.defer(function()
        cleanRagdollV2Scheduled = false
        if char and char.Parent then cleanRagdollV2(char) end
    end)
end
local function isRagdollRelatedDescendant(obj)
    if obj:IsA("BallSocketConstraint") or obj:IsA("NoCollisionConstraint") or obj:IsA("HingeConstraint") then return true end
    if obj:IsA("Attachment") and (obj.Name == "A" or obj.Name == "B") then return true end
    if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then return true end
    return false
end

local function hookAntiRagV2(char)
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns

    local hum = char:WaitForChild("Humanoid", 10)
    local hrp = char:WaitForChild("HumanoidRootPart", 10)
    if not hum or not hrp then return end

    local lastVel = Vector3.new(0, 0, 0)

    local c1 = hum.StateChanged:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            local carpetActive = false
            pcall(function()
                local toolName = Config.TpSettings.Tool or "Flying Carpet"
                local tool = char:FindFirstChild(toolName)
                if tool and hrp then
                    for _, obj in ipairs(hrp:GetChildren()) do
                        if obj:IsA("BodyVelocity") or obj:IsA("BodyPosition") or obj:IsA("BodyGyro") then
                            carpetActive = true
                        end
                    end
                end
            end)
            if not carpetActive then
                hum:ChangeState(Enum.HumanoidStateType.Running)
            end
            cleanRagdollV2(char)
            pcall(function() Workspace.CurrentCamera.CameraSubject = hum end)
            pcall(function()
                local pm = LocalPlayer:FindFirstChild("PlayerScripts")
                if pm then pm = pm:FindFirstChild("PlayerModule") end
                if pm then require(pm):GetControls():Enable() end
            end)
        end
    end)
    table.insert(antiRagdollConns, c1)

    local c2 = char.DescendantAdded:Connect(function(desc)
        if isRagdollRelatedDescendant(desc) then
            cleanRagdollV2Debounced(char)
        end
    end)
    table.insert(antiRagdollConns, c2)

    pcall(function()
        local pkg = ReplicatedStorage:FindFirstChild("Packages")
        if pkg then
            local net = pkg:FindFirstChild("Net")
            if net then
                local applyImp = net:FindFirstChild("RE/CombatService/ApplyImpulse")
                if applyImp and applyImp:IsA("RemoteEvent") then
                    local c3 = applyImp.OnClientEvent:Connect(function()
                        local st = hum:GetState()
                        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
                            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
                            pcall(function() hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0) end)
                        end
                    end)
                    table.insert(antiRagdollConns, c3)
                end
            end
        end
    end)

    local c4 = RunService.Heartbeat:Connect(function()
        local st = hum:GetState()
        if st == Enum.HumanoidStateType.Physics or st == Enum.HumanoidStateType.Ragdoll
            or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.GettingUp then
            cleanRagdollV2(char)
            local vel = hrp.AssemblyLinearVelocity
            if (vel - lastVel).Magnitude > 40 and vel.Magnitude > 25 then
                hrp.AssemblyLinearVelocity = vel.Unit * math.min(vel.Magnitude, 15)
            end
        end
        lastVel = hrp.AssemblyLinearVelocity
    end)
    table.insert(antiRagdollConns, c4)

    cleanRagdollV2(char)
end

local function stopAntiRagdollV2()
    cleanRagdollV2Scheduled = false
    for _, c in ipairs(antiRagdollConns) do pcall(function() c:Disconnect() end) end
    AntiRagdollV2Data.antiRagdollConns = {}
    antiRagdollConns = AntiRagdollV2Data.antiRagdollConns
end

local function startAntiRagdollV2(enabled)
    stopAntiRagdoll()
    stopAntiRagdollV2()
    if not enabled then
        return
    end

    local char = LocalPlayer.Character
    if char then task.spawn(function() hookAntiRagV2(char) end) end
    LocalPlayer.CharacterAdded:Connect(function(c)
        task.spawn(function() hookAntiRagV2(c) end)
    end)
end

if antiRagdollMode > 0 then startAntiRagdoll(antiRagdollMode) end
if Config.AntiRagdollV2 then startAntiRagdollV2(true) end

do
    local plotBeam = nil
    local plotBeamAttachment0 = nil
    local plotBeamAttachment1 = nil

    local function findMyPlot()
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local surfaceGui = sign:FindFirstChildWhichIsA("SurfaceGui", true)
                if surfaceGui then
                    local label = surfaceGui:FindFirstChildWhichIsA("TextLabel", true)
                    if label then
                        local text = label.Text:lower()
                        if text:find(LocalPlayer.DisplayName:lower(), 1, true) or text:find(LocalPlayer.Name:lower(), 1, true) then
                            return plot
                        end
                    end
                end
            end
        end
        return nil
    end

    local function createPlotBeam()
        if not Config.LineToBase then return end
        local myPlot = findMyPlot()
        if not myPlot or not myPlot.Parent then return end
        local character = LocalPlayer.Character
        if not character or not character.Parent then return end
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return end
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        plotBeamAttachment0 = hrp:FindFirstChild("PlotBeamAttach_Player") or Instance.new("Attachment")
        plotBeamAttachment0.Name = "PlotBeamAttach_Player"
        plotBeamAttachment0.Position = Vector3.new(0, 0, 0)
        plotBeamAttachment0.Parent = hrp
        local plotPart = myPlot:FindFirstChild("MainRootPart") or myPlot:FindFirstChildWhichIsA("BasePart")
        if not plotPart or not plotPart.Parent then return end
        plotBeamAttachment1 = plotPart:FindFirstChild("PlotBeamAttach_Plot") or Instance.new("Attachment")
        plotBeamAttachment1.Name = "PlotBeamAttach_Plot"
        plotBeamAttachment1.Position = Vector3.new(0, 5, 0)
        plotBeamAttachment1.Parent = plotPart
        plotBeam = hrp:FindFirstChild("PlotBeam") or Instance.new("Beam")
        plotBeam.Name = "PlotBeam"
        plotBeam.Attachment0 = plotBeamAttachment0
        plotBeam.Attachment1 = plotBeamAttachment1
        plotBeam.FaceCamera = true
        plotBeam.LightEmission = 1
        plotBeam.LightInfluence = 0
        plotBeam.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 240, 255)),
            ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 255, 255)),
        })
        plotBeam.Transparency = NumberSequence.new(0.05)
        plotBeam.Width0 = 0.9
        plotBeam.Width1 = 0.9
        plotBeam.TextureMode = Enum.TextureMode.Wrap
        plotBeam.TextureSpeed = 0
        plotBeam.Parent = hrp

        -- Moderate pulsating glow animation
        task.spawn(function()
            local pulseUp = true
            local minAlpha, maxAlpha = 0.05, 0.45
            local minWidth, maxWidth = 0.6, 1.1
            local step = 0.016 -- ~60fps
            local speed = 1.2  -- pulse cycles per second
            local t = 0
            while plotBeam and plotBeam.Parent do
                t = t + step * speed
                local alpha = minAlpha + (maxAlpha - minAlpha) * (0.5 + 0.5 * math.sin(t * math.pi * 2))
                local w     = minWidth + (maxWidth - minWidth) * (0.5 + 0.5 * math.sin(t * math.pi * 2))
                pcall(function()
                    plotBeam.Transparency = NumberSequence.new(alpha)
                    plotBeam.Width0 = w
                    plotBeam.Width1 = w
                end)
                task.wait(step)
            end
        end)
    end

    local function resetPlotBeam()
        if plotBeam then pcall(function() plotBeam:Destroy() end) end
        if plotBeamAttachment0 then pcall(function() plotBeamAttachment0:Destroy() end) end
        if plotBeamAttachment1 then pcall(function() plotBeamAttachment1:Destroy() end) end
        plotBeam = nil
        plotBeamAttachment0 = nil
        plotBeamAttachment1 = nil
    end

    task.spawn(function()
        local checkCounter = 0
        RunService.Heartbeat:Connect(function()
            if not Config.LineToBase then return end
            checkCounter = checkCounter + 1
            if checkCounter >= 30 then
                checkCounter = 0
                if not plotBeam or not plotBeam.Parent or not plotBeamAttachment0 or not plotBeamAttachment0.Parent then
                    pcall(createPlotBeam)
                end
            end
        end)
    end)

    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        if Config.LineToBase and character then
            pcall(createPlotBeam)
        end
    end)

    if LocalPlayer.Character then
        task.spawn(function()
            task.wait(0.2)
            if Config.LineToBase then createPlotBeam() end
        end)
    end

    _G.createPlotBeam = createPlotBeam
    _G.resetPlotBeam = resetPlotBeam
end

task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas    = ReplicatedStorage:WaitForChild("Datas")
    local Shared   = ReplicatedStorage:WaitForChild("Shared")
    local Utils    = ReplicatedStorage:WaitForChild("Utils")

    local Synchronizer  = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData   = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils   = require(Utils:WaitForChild("NumberUtils"))

    local autoStealEnabled = false

    local stealNearestEnabled = (Config.StealNearest == true)
    local stealHighestEnabled = (Config.StealHighest == true)
    local stealPriorityEnabled = (Config.StealPriority == true)
    local manualTargetEnabled = false

    local function recomputeAutoStealEnabled()
        autoStealEnabled = (stealNearestEnabled or stealHighestEnabled or stealPriorityEnabled or manualTargetEnabled) and true or false
        if stealHighestEnabled then
            Config.AutoTPPriority = false
        elseif stealNearestEnabled or stealPriorityEnabled or manualTargetEnabled then
            Config.AutoTPPriority = true
        end
    end
    SharedState.RecomputeAutoStealEnabled = recomputeAutoStealEnabled
    recomputeAutoStealEnabled()
    Config.StealNearest = stealNearestEnabled
    Config.StealHighest = stealHighestEnabled
    Config.StealPriority = stealPriorityEnabled
    if Config.InstantSteal == nil then Config.InstantSteal = false end
    
    local instantStealEnabled = (Config.InstantSteal == true)
    local instantStealReady = false
    local instantStealDidInit = false
    local selectedTargetIndex = 1
    local selectedTargetUID   = nil 
    local allAnimalsCache    = {}
    local InternalStealCache = {}
    local PromptMemoryCache  = {}
    local activeProgressTween = nil
    local currentStealTargetUID = nil
    local petButtons         = {}
    
    local function isMyBaseAnimal(animalData)
        if not animalData or not animalData.plot then return false end
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(animalData.plot)
        if not plot then return false end
        local channel = Synchronizer:Get(plot.Name)
        if channel then
            local owner = channel:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "table" and owner.UserId then return owner.UserId == LocalPlayer.UserId
                elseif typeof(owner) == "Instance" then return owner == LocalPlayer end
            end
        end
        return false
    end
    
    local function formatMutationText(mutationName)
        if not mutationName or mutationName == "None" then return "" end
        local f = ""
        if mutationName == "Cursed" then f = "<font color='rgb(200,0,0)'>Cur</font><font color='rgb(0,0,0)'>sed</font>"
        elseif mutationName == "Gold" then f = "<font color='rgb(255,215,0)'>Gold</font>"
        elseif mutationName == "Diamond" then f = "<font color='rgb(0,255,255)'>Diamond</font>"
        elseif mutationName == "YinYang" then f = "<font color='rgb(255,255,255)'>Yin</font><font color='rgb(0,0,0)'>Yang</font>"
        elseif mutationName == "Candy" then f = "<font color='rgb(255,105,180)'>Candy</font>"
        elseif mutationName == "Divine" then f = "<font color='rgb(255,255,255)'>Divine</font>"
        elseif mutationName == "Rainbow" then
            local cols = {"rgb(255,0,0)","rgb(255,127,0)","rgb(255,255,0)","rgb(0,255,0)","rgb(0,0,255)","rgb(75,0,130)","rgb(148,0,211)"}
            for i = 1, #mutationName do f = f.."<font color='"..cols[(i-1)%#cols+1].."'>"..mutationName:sub(i,i).."</font>" end
        else f = mutationName end
        return "<font weight='800'>"..f.." </font>"
    end

    local function get_all_pets()
        local out = {}
        for _, a in ipairs(allAnimalsCache) do
            if a.genValue >= 1 and not isMyBaseAnimal(a) then
                table.insert(out, {petName=a.name, mpsText=a.genText, mpsValue=a.genValue,
                    owner=a.owner, plot=a.plot, slot=a.slot, uid=a.uid, mutation=a.mutation, animalData=a})
            end
        end
        return out
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoStealUI"; screenGui.ResetOnSpawn = false; screenGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.6 or 1
    frame.Size = UDim2.new(0, 300*mobileScale, 0, 630*mobileScale)
    frame.Position = UDim2.new(Config.Positions.AutoSteal.X, 0, Config.Positions.AutoSteal.Y, 0)
    frame.BackgroundColor3 = Theme.Background; frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0; frame.ClipsDescendants = true; frame.Parent = screenGui

    ApplyViewportUIScale(frame, 300, 630, 0.45, 0.8)
    AddMobileMinimize(frame, "AUTO STEAL")
    
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", frame)
    mainStroke.Color = Theme.Accent1; mainStroke.Thickness = 2; mainStroke.Transparency = 0
    AddGlowBorderAnimation(frame, mainStroke)
    AddStarryBackground(frame)
    
    local header = Instance.new("Frame", frame); header.Size = UDim2.new(1,0,0,40); header.BackgroundTransparency = 1
    MakeDraggable(header, frame, "AutoSteal") 
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = IS_MOBILE and UDim2.new(0.4,0,1,0) or UDim2.new(0.6,0,1,0)
    titleLabel.Position = UDim2.new(0,15,0,0)
    titleLabel.BackgroundTransparency = 1; titleLabel.Text = "AUTO STEAL"
    titleLabel.Font = Enum.Font.GothamBlack; titleLabel.TextSize = 16
    titleLabel.TextColor3 = Theme.TextPrimary; titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    if IS_MOBILE then
        local menuToggleBtn = Instance.new("TextButton", header)
        menuToggleBtn.Size = UDim2.new(0, 80, 0, 30)
        menuToggleBtn.Position = UDim2.new(1, -85, 0.5, -15)
        menuToggleBtn.BackgroundColor3 = Theme.Accent1
        menuToggleBtn.Text = "MENU"
        menuToggleBtn.Font = Enum.Font.GothamBold
        menuToggleBtn.TextSize = 12
        menuToggleBtn.TextColor3 = Color3.new(0, 0, 0)
        Instance.new("UICorner", menuToggleBtn).CornerRadius = UDim.new(0, 8)
        
        menuToggleBtn.MouseButton1Click:Connect(function()
            if settingsGui then
                settingsGui.Enabled = not settingsGui.Enabled
            end
        end)
    end

    local stealGui = Instance.new("ScreenGui")
    stealGui.Name = "XiStealPanel"
    stealGui.ResetOnSpawn = false
    stealGui.Enabled = not Config.HideStealPanel
    stealGui.Parent = PlayerGui

    local stealFrame = Instance.new("Frame", stealGui)
    stealFrame.Name = "Frame"
    local stealMobileScale = IS_MOBILE and 0.8 or 1
    stealFrame.Size = UDim2.new(0, 260*stealMobileScale, 0, 260*stealMobileScale)
    local stealPos = (Config.Positions and Config.Positions.StealPanel) or DefaultConfig.Positions.StealPanel
    stealFrame.Position = UDim2.new(stealPos.X, 0, stealPos.Y, 0)
    stealFrame.BackgroundColor3 = Theme.Background
    stealFrame.BackgroundTransparency = 0.35
    stealFrame.BorderSizePixel = 0
    stealFrame.ClipsDescendants = true

    ApplyViewportUIScale(stealFrame, 260, 260, 0.5, 0.85)
    Instance.new("UICorner", stealFrame).CornerRadius = UDim.new(0, 12)
    local stealStroke = Instance.new("UIStroke", stealFrame)
    stealStroke.Color = Theme.Accent1
    stealStroke.Thickness = 2
    stealStroke.Transparency = 0
    AddGlowBorderAnimation(stealFrame, stealStroke)
    AddStarryBackground(stealFrame)

    local stealHeader = Instance.new("Frame", stealFrame)
    stealHeader.Size = UDim2.new(1, 0, 0, 56)
    stealHeader.BackgroundTransparency = 1
    MakeDraggable(stealHeader, stealFrame, "StealPanel")

    local stealTitle = Instance.new("TextLabel", stealHeader)
    stealTitle.Size = UDim2.new(1, -20, 0, 22)
    stealTitle.Position = UDim2.new(0, 12, 0, 6)
    stealTitle.BackgroundTransparency = 1
    stealTitle.Text = "DTZ HUB MOGS"
    stealTitle.Font = Enum.Font.GothamBlack
    stealTitle.TextSize = 14
    stealTitle.TextColor3 = Theme.TextPrimary
    stealTitle.TextXAlignment = Enum.TextXAlignment.Left

    local stealCredit = Instance.new("TextLabel", stealHeader)
    stealCredit.Size = UDim2.new(1, -20, 0, 14)
    stealCredit.Position = UDim2.new(0, 12, 0, 22)
    stealCredit.BackgroundTransparency = 1
    stealCredit.Text = "YoDtz"
    stealCredit.Font = Enum.Font.GothamBold
    stealCredit.TextSize = 11
    stealCredit.TextColor3 = Theme.Accent1
    stealCredit.TextTransparency = 0.05
    stealCredit.TextXAlignment = Enum.TextXAlignment.Left

    local stealSub = Instance.new("TextLabel", stealHeader)
    stealSub.Size = UDim2.new(1, -20, 0, 18)
    stealSub.Position = UDim2.new(0, 12, 0, 36)
    stealSub.BackgroundTransparency = 1
    stealSub.Text = "/ Steal Panel"
    stealSub.Font = Enum.Font.GothamMedium
    stealSub.TextSize = 10
    stealSub.TextColor3 = Theme.TextSecondary
    stealSub.TextXAlignment = Enum.TextXAlignment.Left

    local stealContent = Instance.new("Frame", stealFrame)
    stealContent.Size = UDim2.new(1, -16, 1, -66)
    stealContent.Position = UDim2.new(0, 8, 0, 60)
    stealContent.BackgroundTransparency = 1

    local stealLayout = Instance.new("UIListLayout", stealContent)
    stealLayout.Padding = UDim.new(0, 0)
    stealLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function makeStealRow(text)
        local row = Instance.new("Frame", stealContent)
        row.Size = UDim2.new(1, 0, 0, 34)
        row.BackgroundColor3 = Theme.SurfaceHighlight
        row.BackgroundTransparency = 0.55
        row.BorderSizePixel = 0
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel", row)
        lbl.Size = UDim2.new(1, -90, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = text
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 12
        lbl.TextColor3 = Theme.TextPrimary
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(0, 74, 0, 26)
        btn.Position = UDim2.new(1, -82, 0.5, -13)
        btn.BackgroundColor3 = Theme.Surface
        btn.BorderSizePixel = 0
        btn.Text = "OFF"
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = Theme.TextPrimary
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        return btn
    end

    local btnStealHighest = makeStealRow("Steal Highest:")
    local btnStealPriority = makeStealRow("Steal Priority:")
    local btnStealNearest = makeStealRow("Steal Nearest:")
    local btnAutoTurret = makeStealRow("Auto Turret:")
    local btnAutoKick = makeStealRow("Auto Kick:")

    local targetPanel = Instance.new("Frame", frame)
    targetPanel.Size = UDim2.new(1,-30,0,62); targetPanel.Position = UDim2.new(0,15,0,45)
    targetPanel.BackgroundColor3 = Color3.fromRGB(10,10,10)
    targetPanel.BackgroundTransparency = 0.25
    targetPanel.BorderSizePixel = 0
    Instance.new("UICorner", targetPanel).CornerRadius = UDim.new(0, 10)

    -- Left accent bar
    local tpAccent = Instance.new("Frame", targetPanel)
    tpAccent.Size = UDim2.new(0, 2, 1, -14); tpAccent.Position = UDim2.new(0, 0, 0, 7)
    tpAccent.BackgroundColor3 = Theme.Accent1; tpAccent.BorderSizePixel = 0
    Instance.new("UICorner", tpAccent).CornerRadius = UDim.new(0, 8)

    -- Fixed-thickness stroke
    local tpStroke = Instance.new("UIStroke", targetPanel)
    tpStroke.Thickness    = 2
    tpStroke.Transparency = 0
    tpStroke.Color        = Color3.fromRGB(255, 255, 255)

    -- "CURRENT TARGET" eyebrow label
    local targetHeader = Instance.new("TextLabel", targetPanel)
    targetHeader.Size = UDim2.new(1,-24,0,13); targetHeader.Position = UDim2.new(0,12,0,7)
    targetHeader.BackgroundTransparency = 1; targetHeader.Text = "CURRENT TARGET"
    targetHeader.Font = Enum.Font.GothamBold; targetHeader.TextSize = 9
    targetHeader.TextColor3 = Theme.TextSecondary; targetHeader.TextXAlignment = Enum.TextXAlignment.Left
    targetHeader.ZIndex = 2

    -- Main target name label
    local targetLabel = Instance.new("TextLabel", targetPanel)
    targetLabel.Size = UDim2.new(1,-24,0,22); targetLabel.Position = UDim2.new(0,12,0,22)
    targetLabel.BackgroundTransparency = 1; targetLabel.Font = Enum.Font.GothamBlack; targetLabel.TextSize = 15
    targetLabel.TextColor3 = Theme.TextPrimary; targetLabel.TextXAlignment = Enum.TextXAlignment.Left
    targetLabel.TextTruncate = Enum.TextTruncate.AtEnd; targetLabel.Text = ""
    targetLabel.ZIndex = 2

    -- Scan track (dim base bar at bottom of panel)
    local scanTrack = Instance.new("Frame", targetPanel)
    scanTrack.Size = UDim2.new(1,-20,0,3); scanTrack.Position = UDim2.new(0,10,1,-9)
    scanTrack.BackgroundColor3 = Color3.fromRGB(40,40,40)
    scanTrack.BackgroundTransparency = 0.3; scanTrack.BorderSizePixel = 0
    scanTrack.ClipsDescendants = true
    Instance.new("UICorner", scanTrack).CornerRadius = UDim.new(1,0)

    -- Animated white sweep fill
    local scanFill = Instance.new("Frame", scanTrack)
    scanFill.Size = UDim2.new(0,0,1,0); scanFill.Position = UDim2.new(0,0,0,0)
    scanFill.BackgroundColor3 = Color3.fromRGB(255,255,255)
    scanFill.BackgroundTransparency = 0; scanFill.BorderSizePixel = 0
    Instance.new("UICorner", scanFill).CornerRadius = UDim.new(1,0)

    -- Soft glow halo above the fill (kept inside track via ClipsDescendants)
    local scanGlow = Instance.new("Frame", scanTrack)
    scanGlow.Size = UDim2.new(0,0,0,7); scanGlow.Position = UDim2.new(0,0,0.5,-3.5)
    scanGlow.BackgroundColor3 = Color3.fromRGB(255,255,255)
    scanGlow.BackgroundTransparency = 0.70; scanGlow.BorderSizePixel = 0
    Instance.new("UICorner", scanGlow).CornerRadius = UDim.new(1,0)

    -- Aliases expected by steal-timing code
    local progressBg      = scanTrack
    local progressBarFill = scanFill

    -- Border orbit + scan bar animation
    task.spawn(function()
        local STEP        = 1/60
        local SPEED       = 0.55
        local SCAN_SPEED  = 0.85
        local IDLE_SPEED  = 0.30
        local t           = 0
        local tScan       = 0

        local g = Instance.new("UIGradient", tpStroke)
        local SPREAD   = 0.13
        local WHITE    = Color3.fromRGB(255, 255, 255)
        local DIM      = Color3.fromRGB(45,  45,  45)
        local GLOW_DIM = Color3.fromRGB(130, 130, 130)
        local function kp(pos, col)
            return ColorSequenceKeypoint.new(math.clamp(pos, 0.001, 0.999), col)
        end

        while targetPanel and targetPanel.Parent do
            task.wait(STEP)
            local isSearching = targetLabel and targetLabel.Text == "Searching..."
            local scanSpeed   = isSearching and SCAN_SPEED or IDLE_SPEED

            tScan = (tScan + STEP * scanSpeed) % 1

            if isSearching then
                tpStroke.Transparency = 0
                t = (t + SPEED * STEP) % 1

                local c  = 0.5
                local lo = c - SPREAD
                local hi = c + SPREAD
                g.Rotation = t * 360
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,              DIM),
                    kp(math.max(0.05, lo - 0.06),             DIM),
                    kp(math.max(0.06, lo),                    GLOW_DIM),
                    kp(c,                                     WHITE),
                    kp(math.min(0.94, hi),                    GLOW_DIM),
                    kp(math.min(0.93, hi + 0.06),             DIM),
                    ColorSequenceKeypoint.new(1,              DIM),
                })
                local pulse = (math.sin(tScan * math.pi * 2) + 1) * 0.5
                local v = math.floor(180 + pulse * 75)
                targetHeader.TextColor3 = Color3.fromRGB(v, v, v)
                targetLabel.TextColor3  = Color3.fromRGB(v, v, v)
            else
                tpStroke.Transparency = 0.6
                g.Rotation = 0
                g.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
                targetHeader.TextColor3 = Theme.TextSecondary
                targetLabel.TextColor3  = Theme.TextPrimary
            end

            if isSearching then
                -- Perfect linear ping-pong: tScan 0→1 = left-to-right, 1→0 = right-to-left
                -- Triangle wave gives constant speed in both directions with no artifacts
                local tri = tScan < 0.5 and (tScan * 2) or (2 - tScan * 2)  -- 0→1→0 linear
                local FILL_W = 0.28  -- width of the travelling pill as a fraction of the track
                -- Centre of the pill travels from 0 to 1 across the track
                -- We offset by half the pill width so the pill starts fully off-screen left
                -- and ends fully off-screen right, giving a clean enter/exit each pass
                local centrePos = (1 + FILL_W) * tri - FILL_W * 0.5
                local leftEdge  = centrePos - FILL_W * 0.5
                local rightEdge = centrePos + FILL_W * 0.5
                -- Clip to [0,1] so nothing exceeds the track (ClipsDescendants also guards)
                local visL = math.max(0, leftEdge)
                local visR = math.min(1, rightEdge)
                local visW = math.max(0, visR - visL)
                scanFill.Size     = UDim2.new(visW, 0, 1, 0)
                scanFill.Position = UDim2.new(visL, 0, 0, 0)
                scanGlow.Size     = UDim2.new(visW, 0, 1, 0)
                scanGlow.Position = UDim2.new(visL, 0, 0, 0)
                -- Opacity is constant — no brightness falloff — so it looks uniform end-to-end
                scanFill.BackgroundTransparency = 0.05
                scanGlow.BackgroundTransparency = 0.55
                scanTrack.BackgroundTransparency = 0.65
            else
                scanFill.Size     = UDim2.new(1, 0, 1, 0)
                scanFill.Position = UDim2.new(0, 0, 0, 0)
                scanGlow.Size     = UDim2.new(1, 0, 1, 0)
                scanGlow.Position = UDim2.new(0, 0, 0, 0)
                local idle = (math.sin(tScan * math.pi * 2 * 0.5) + 1) * 0.5
                scanFill.BackgroundTransparency = 0.55 - idle * 0.15
                scanGlow.BackgroundTransparency = 0.82
                scanTrack.BackgroundTransparency = 0.45
            end
        end
    end)

    local selectLabel = Instance.new("TextLabel", frame)
    selectLabel.Size = UDim2.new(0.5,0,0,20); selectLabel.Position = UDim2.new(0,15,0,115)
    selectLabel.BackgroundTransparency = 1; selectLabel.Text = "AVAILABLE BRAINROTS"
    selectLabel.Font = Enum.Font.GothamBold; selectLabel.TextSize = 11
    selectLabel.TextColor3 = Color3.fromRGB(255, 255, 255); selectLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Pulsating white illuminated bar above the brainrot list
    local availableBar = Instance.new("Frame", frame)
    availableBar.Size = UDim2.new(1, -30, 0, 2)
    availableBar.Position = UDim2.new(0, 15, 0, 136)
    availableBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    availableBar.BackgroundTransparency = 0
    availableBar.BorderSizePixel = 0
    Instance.new("UICorner", availableBar).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        local barGrad = Instance.new("UIGradient", availableBar)
        local t = 0
        local STEP = 1/60
        local SPEED = 0.55  -- full sweeps per second
        while availableBar and availableBar.Parent do
            t = (t + STEP * SPEED) % 1
            -- Linear left-to-right sweep: hot spot travels 0→1 at constant speed
            local spotPos = t
            -- Pulse the bar's overall opacity so it breathes gently
            local pulse = 0.5 + 0.5 * math.sin(t * math.pi * 2)
            availableBar.BackgroundTransparency = 0.45 - pulse * 0.20
            local lo = math.max(0.001, spotPos - 0.14)
            local hi = math.min(0.999, spotPos + 0.14)
            barGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0,     Color3.fromRGB(160, 160, 160)),
                ColorSequenceKeypoint.new(math.clamp(lo, 0.001, 0.998), Color3.fromRGB(200, 200, 200)),
                ColorSequenceKeypoint.new(math.clamp(spotPos, 0.002, 0.998), Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(math.clamp(hi, 0.002, 0.999), Color3.fromRGB(200, 200, 200)),
                ColorSequenceKeypoint.new(1,     Color3.fromRGB(160, 160, 160)),
            })
            task.wait(STEP)
        end
    end)

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1,-30,1,-193); listFrame.Position = UDim2.new(0,15,0,140)
    listFrame.BackgroundTransparency = 1; listFrame.BorderSizePixel = 0
    listFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    listFrame.ScrollBarImageTransparency = 1; listFrame.ScrollBarThickness = 0
    local uiListLayout = Instance.new("UIListLayout", listFrame)
    uiListLayout.Padding = UDim.new(0,8); uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local toggleBtnContainer = Instance.new("Frame", frame)
    toggleBtnContainer.Size = UDim2.new(1,-30,0,34); toggleBtnContainer.Position = UDim2.new(0,15,1,-44)
    toggleBtnContainer.BackgroundTransparency = 1
    
    local function setStealMode(mode)
        if mode == "nearest" then
            stealNearestEnabled = not stealNearestEnabled
            if stealNearestEnabled then stealHighestEnabled = false; stealPriorityEnabled = false end
        elseif mode == "highest" then
            stealHighestEnabled = not stealHighestEnabled
            if stealHighestEnabled then stealNearestEnabled = false; stealPriorityEnabled = false end
        elseif mode == "priority" then
            stealPriorityEnabled = not stealPriorityEnabled
            if stealPriorityEnabled then stealNearestEnabled = false; stealHighestEnabled = false end
        end
        if stealNearestEnabled or stealHighestEnabled or stealPriorityEnabled then
            manualTargetEnabled = false
        end
        Config.StealNearest = stealNearestEnabled
        Config.StealHighest = stealHighestEnabled
        Config.StealPriority = stealPriorityEnabled
        SaveConfig()
        if SharedState.RecomputeAutoStealEnabled then
            SharedState.RecomputeAutoStealEnabled()
        end
    end
    SharedState.SetStealMode = setStealMode

    local function setToggleVisual(btn, on)
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Theme.Success or Theme.Surface
        btn.TextColor3 = on and Color3.new(0, 0, 0) or Theme.TextPrimary
    end

    local function updateStealPanelUI()
        setToggleVisual(btnStealNearest, stealNearestEnabled)
        setToggleVisual(btnStealHighest, stealHighestEnabled)
        setToggleVisual(btnStealPriority, stealPriorityEnabled)
        setToggleVisual(btnAutoTurret, Config.AutoDestroyTurrets == true)
        setToggleVisual(btnAutoKick, Config.AutoKickOnSteal == true)
    end
    SharedState.UpdateStealPanelUI = updateStealPanelUI
    updateStealPanelUI()

    local function updateUI(enabled, allPets)
        autoStealEnabled = enabled
        instantStealEnabled = true -- Force always ON

        updateStealPanelUI()

        --[[
        if instantStealBtn then
            instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"
            instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
            instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
        end
        ]]--

        if selectedTargetUID and allPets then
            local found = false
            for i, p in ipairs(allPets) do
                if p.uid == selectedTargetUID then
                    selectedTargetIndex = i
                    found = true
                    break
                end
            end
        end

        if SharedState.ListNeedsRedraw then
            for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
            petButtons = {}
            if allPets and #allPets > 0 then
                for i = 1, #allPets do
                    local petData = allPets[i]
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1,0,0,36); btn.BackgroundColor3 = Theme.Surface
                    btn.Text = ""; btn.Parent = listFrame
                    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)
                    local bStroke = Instance.new("UIStroke", btn)
                    bStroke.Color = Theme.Accent1; bStroke.Thickness = 1; bStroke.Transparency = 1

                    local MUT_COLORS_UI = {
                        Cursed=Color3.fromRGB(200,0,0), Gold=Color3.fromRGB(255,215,0),
                        Diamond=Color3.fromRGB(0,255,255), YinYang=Color3.fromRGB(220,220,220),
                        Rainbow=Color3.fromRGB(255,100,200), Lava=Color3.fromRGB(255,100,20),
                        Candy=Color3.fromRGB(255,105,180), Divine=Color3.fromRGB(255,255,255)
                    }
                    local hasMut = petData.mutation and petData.mutation ~= "None"
                    local barCol = hasMut and (MUT_COLORS_UI[petData.mutation] or Color3.fromRGB(210,130,255)) or Theme.Accent1
                    local itemBar = Instance.new("Frame", btn)
                    itemBar.Size = UDim2.new(0,3,1,-8); itemBar.Position = UDim2.new(0,3,0,4)
                    itemBar.BackgroundColor3 = barCol; itemBar.BorderSizePixel = 0
                    Instance.new("UICorner",itemBar).CornerRadius = UDim.new(1,0)

                    local rankLabel = Instance.new("TextLabel", btn)
                    rankLabel.Size = UDim2.new(0,28,1,0); rankLabel.Position = UDim2.new(0,10,0,0)
                    rankLabel.BackgroundTransparency = 1; rankLabel.Text = "#"..i
                    rankLabel.Font = Enum.Font.GothamBlack; rankLabel.TextSize = 13
                    local infoLabel = Instance.new("TextLabel", btn)
                    infoLabel.Size = UDim2.new(1,-42,1,0); infoLabel.Position = UDim2.new(0,38,0,0)
                    infoLabel.BackgroundTransparency = 1; infoLabel.RichText = true
                    infoLabel.Text = formatMutationText(petData.mutation).."<font weight='700'>"..petData.petName.."</font> - <font weight='700'>"..petData.mpsText.."</font>"
                    infoLabel.Font = Enum.Font.GothamMedium; infoLabel.TextSize = 12
                    infoLabel.TextXAlignment = Enum.TextXAlignment.Left; infoLabel.TextTruncate = Enum.TextTruncate.AtEnd
                    petButtons[i] = {button=btn, stroke=bStroke, rank=rankLabel, info=infoLabel, bar=itemBar}
                    
                    btn.MouseButton1Click:Connect(function()
                        selectedTargetIndex = i
                        selectedTargetUID = petData.uid 
                        manualTargetEnabled = true
                        stealNearestEnabled = false
                        stealHighestEnabled = false
                        stealPriorityEnabled = false
                        Config.StealNearest = false; Config.StealHighest = false; Config.StealPriority = false
                        SaveConfig()
                        if SharedState.RecomputeAutoStealEnabled then
                            SharedState.RecomputeAutoStealEnabled()
                        end
                        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
                    end)
                end
            end
            SharedState.ListNeedsRedraw = false
        end
        
        if selectedTargetIndex > #petButtons then selectedTargetIndex = 1 end

        for i, pb in ipairs(petButtons) do
            local sel = (i == selectedTargetIndex)
            pb.stroke.Transparency = sel and 0 or 1
            pb.button.BackgroundColor3 = sel and Theme.SurfaceHighlight or Theme.Surface
            pb.rank.TextColor3  = sel and Theme.Accent1 or Theme.TextSecondary
            pb.info.TextColor3  = sel and Theme.TextPrimary or Theme.TextSecondary
        end
        local ct = allPets and allPets[selectedTargetIndex]
        SharedState.SelectedPetData = ct
        if enabled then
            targetLabel.Text = ct and string.format("%s (%s)", ct.petName, ct.mpsText) or "Searching..."
        else targetLabel.Text = "Disabled" end
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0,0,0, math.max(0, uiListLayout.AbsoluteContentSize.Y))
    end)
    
    SharedState.UpdateAutoStealUI = function()
        updateUI(autoStealEnabled, get_all_pets())
    end
    
    btnStealNearest.MouseButton1Click:Connect(function()
        setStealMode("nearest")
        SharedState.ListNeedsRedraw = false
        updateUI(autoStealEnabled, get_all_pets())
    end)

    btnStealHighest.MouseButton1Click:Connect(function()
        setStealMode("highest")
        SharedState.ListNeedsRedraw = false
        updateUI(autoStealEnabled, get_all_pets())
    end)

    btnStealPriority.MouseButton1Click:Connect(function()
        setStealMode("priority")
        SharedState.ListNeedsRedraw = false
        updateUI(autoStealEnabled, get_all_pets())
    end)

    btnAutoTurret.MouseButton1Click:Connect(function()
        Config.AutoDestroyTurrets = not Config.AutoDestroyTurrets
        SaveConfig()
        updateStealPanelUI()
        if SharedState.SettingsAutoDestroyTurretsSet then
            pcall(SharedState.SettingsAutoDestroyTurretsSet, Config.AutoDestroyTurrets == true)
        end
    end)

    btnAutoKick.MouseButton1Click:Connect(function()
        Config.AutoKickOnSteal = not Config.AutoKickOnSteal
        SaveConfig()
        updateStealPanelUI()
        if SharedState.SettingsAutoKickSet then
            pcall(SharedState.SettingsAutoKickSet, Config.AutoKickOnSteal == true)
        end
    end)

    local customizePriorityBtn = Instance.new("TextButton", toggleBtnContainer)
    customizePriorityBtn.Size = UDim2.new(1,0,0,24); customizePriorityBtn.Position = UDim2.new(0,0,0,5)
    customizePriorityBtn.BackgroundColor3 = Theme.Accent1
    customizePriorityBtn.Text = "CUSTOMIZE PRIORITY"; customizePriorityBtn.Font = Enum.Font.GothamBold
    customizePriorityBtn.TextSize = 10; customizePriorityBtn.TextColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", customizePriorityBtn).CornerRadius = UDim.new(0, 8)
    customizePriorityBtn.Visible = not IS_MOBILE
    
    customizePriorityBtn.MouseButton1Click:Connect(function()
        local priorityGui = PlayerGui:FindFirstChild("PriorityListGUI")
        if priorityGui then
            priorityGui.Enabled = not priorityGui.Enabled
        end
    end)

    -- INSTANT STEAL BUTTON REMOVED (ALWAYS ON)
    --[[
    local instantStealBtn = Instance.new("TextButton", toggleBtnContainer)
    instantStealBtn.Size = UDim2.new(1,0,0,24*mobileButtonScale); instantStealBtn.Position = UDim2.new(0,0,0,116*mobileButtonScale)
    instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
    instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"; instantStealBtn.Font = Enum.Font.GothamBold
    instantStealBtn.TextSize = 10*mobileButtonScale; instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
    Instance.new("UICorner", instantStealBtn).CornerRadius = UDim.new(0, 8)

    instantStealBtn.MouseButton1Click:Connect(function()
        instantStealEnabled = not instantStealEnabled
        if not instantStealEnabled then
            instantStealReady = false
            instantStealDidInit = false
        end
        Config.InstantSteal = instantStealEnabled
        SaveConfig()
        instantStealBtn.Text = instantStealEnabled and "INSTANT STEAL: ON" or "INSTANT STEAL: OFF"
        instantStealBtn.BackgroundColor3 = instantStealEnabled and Theme.Accent1 or Theme.SurfaceHighlight
        instantStealBtn.TextColor3 = instantStealEnabled and Color3.new(0,0,0) or Theme.TextPrimary
        SharedState.ListNeedsRedraw = false; updateUI(autoStealEnabled, get_all_pets())
    end)
    ]]--

    local function findProximityPromptForAnimal(animalData)
        if not animalData then return nil end
        local cp = PromptMemoryCache[animalData.uid]
        if cp and cp.Parent then return cp end
        local plot = Workspace.Plots:FindFirstChild(animalData.plot); if not plot then return nil end
        local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then return nil end
        
        
        local ch = Synchronizer:Get(plot.Name)
        if not ch then
            
            local podium = podiums:FindFirstChild(animalData.slot)
            if podium then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if spawn then
                    local attach = spawn:FindFirstChild("PromptAttachment")
                    if attach then
                        for _, p in ipairs(attach:GetChildren()) do
                            if p:IsA("ProximityPrompt") then
                                PromptMemoryCache[animalData.uid] = p
                                return p
                            end
                        end
                    end
                end
            end
            return nil
        end
        
        local al = ch:Get("AnimalList")
        if not al then return nil end
        
        local brainrotName = animalData.name and animalData.name:lower() or ""
        local targetSlot = animalData.slot
        
        
        local foundPodium = nil
        for slot, ad in pairs(al) do
            if type(ad) == "table" and tostring(slot) == targetSlot then
                local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                if aInfo and (aInfo.DisplayName or aName):lower() == brainrotName then
                    foundPodium = podiums:FindFirstChild(tostring(slot))
                    break
                end
            end
        end
        
        
        if not foundPodium then
            foundPodium = podiums:FindFirstChild(animalData.slot)
        end
        
        if foundPodium then
            local base = foundPodium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            if spawn then
                
                local attach = spawn:FindFirstChild("PromptAttachment")
                if attach then
                    for _, p in ipairs(attach:GetChildren()) do
                        if p:IsA("ProximityPrompt") and p.Enabled and p.ActionText == "Steal" then
                            PromptMemoryCache[animalData.uid] = p
                            return p
                        end
                    end
                end
                
                
                local startPos = spawn.Position
                local slotX, slotZ = startPos.X, startPos.Z
                local nearestPrompt = nil
                local minDist = math.huge
                
                for _, desc in pairs(plot:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled and desc.ActionText == "Steal" then
                        local part = desc.Parent
                        local promptPos = nil
                        
                        if part and part:IsA("BasePart") then
                            promptPos = part.Position
                        elseif part and part:IsA("Attachment") and part.Parent and part.Parent:IsA("BasePart") then
                            promptPos = part.Parent.Position
                        end
                        
                        if promptPos then
                            local checkStartY = startPos.Y
                            if brainrotName:find("la secret combinasion") then
                                checkStartY = startPos.Y - 5
                            end
                            local horizontalDist = math.sqrt((promptPos.X - slotX)^2 + (promptPos.Z - slotZ)^2)
                            if horizontalDist < 5 and promptPos.Y > checkStartY then
                                local yDist = promptPos.Y - checkStartY
                                if yDist < minDist then
                                    minDist = yDist
                                    nearestPrompt = desc
                                end
                            end
                        end
                    end
                end
                
                if nearestPrompt then
                    PromptMemoryCache[animalData.uid] = nearestPrompt
                    return nearestPrompt
                end
            end
        end
        
        return nil
    end

    local STEAL_DURATION = 0.28  -- fast steal duration

    local function buildStealCallbacks(prompt)
        if InternalStealCache[prompt] then return end
        local data = {holdCallbacks = {}, triggerCallbacks = {}, holdEndCallbacks = {}, ready = true}
        local ok1, conns1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
        if ok1 and type(conns1) == "table" then
            for _, conn in ipairs(conns1) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdCallbacks, conn.Function)
                end
            end
        end
        local ok2, conns2 = pcall(getconnections, prompt.Triggered)
        if ok2 and type(conns2) == "table" then
            for _, conn in ipairs(conns2) do
                if type(conn.Function) == "function" then
                    table.insert(data.triggerCallbacks, conn.Function)
                end
            end
        end
        local ok3, conns3 = pcall(getconnections, prompt.PromptButtonHoldEnded)
        if ok3 and type(conns3) == "table" then
            for _, conn in ipairs(conns3) do
                if type(conn.Function) == "function" then
                    table.insert(data.holdEndCallbacks, conn.Function)
                end
            end
        end
        if (#data.holdCallbacks > 0) or (#data.triggerCallbacks > 0) or (#data.holdEndCallbacks > 0) then
            InternalStealCache[prompt] = data
        end
    end

    local function runCallbackList(list)
        for _, fn in ipairs(list) do
            task.spawn(fn)
        end
    end

    local INSTANT_STEAL_RADIUS = 60
    local INSTANT_STEAL_COOLDOWN = 0.015  -- fast cooldown
    local lastInstantStealTime = 0
    local function isMyPlot_Instant(plotName)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return false end
        local plot = plots:FindFirstChild(plotName)
        if not plot then return false end
        local sign = plot:FindFirstChild("PlotSign")
        if not sign then return false end
        local yb = sign:FindFirstChild("YourBase")
        return yb and yb:IsA("BillboardGui") and yb.Enabled
    end
    local function findNearestPrompt_Instant()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil, math.huge, nil end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil, math.huge, nil end
        local bestPrompt, bestDist, bestName = nil, math.huge, nil
        for _, plot in ipairs(plots:GetChildren()) do
            if isMyPlot_Instant(plot.Name) then continue end
            local plotDist = math.huge
            pcall(function() plotDist = (plot:GetPivot().Position - hrp.Position).Magnitude end)
            if plotDist > INSTANT_STEAL_RADIUS + 40 then continue end
            local podiums = plot:FindFirstChild("AnimalPodiums")
            if not podiums then continue end
            for _, pod in ipairs(podiums:GetChildren()) do
                local base = pod:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                if not spawn then continue end
                local dist = (spawn.Position - hrp.Position).Magnitude
                if dist > INSTANT_STEAL_RADIUS or dist >= bestDist then continue end
                local att = spawn:FindFirstChild("PromptAttachment")
                if not att then continue end
                local prompt = att:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.Parent and prompt.Enabled then
                    bestPrompt = prompt
                    bestDist = dist
                    bestName = pod.Name
                end
            end
        end
        return bestPrompt, bestDist, bestName
    end
    local function executeInstantSteal(prompt)
        if not prompt then return end
        local now = os.clock()
        if now - lastInstantStealTime < INSTANT_STEAL_COOLDOWN then return end
        lastInstantStealTime = now
        buildStealCallbacks(prompt)
        local data = InternalStealCache[prompt]
        if not data then return end
        local oDur = prompt.HoldDuration
        prompt.HoldDuration = 0
        for _, fn in ipairs(data.holdCallbacks) do pcall(fn) end
        for _rep = 1, 4 do  -- balanced: faster fires compensate for 1 less rep
            for _, fn in ipairs(data.triggerCallbacks) do pcall(fn) end
            if fireproximityprompt then fireproximityprompt(prompt) end
        end
        for _, fn in ipairs(data.holdEndCallbacks) do pcall(fn) end
        prompt.HoldDuration = oDur
    end

    local function executeInternalStealAsync(prompt, animalUID)
        local data = InternalStealCache[prompt]
        if not data or not data.ready then return false end
        data.ready = false

        task.spawn(function()
            if currentStealTargetUID ~= animalUID then
                if activeProgressTween then activeProgressTween:Cancel() end
                progressBarFill.Size = UDim2.new(0, 0, 1, 0)
                currentStealTargetUID = animalUID
            end

            if #data.holdCallbacks > 0 then
                runCallbackList(data.holdCallbacks)
            end

            progressBarFill.Size = UDim2.new(0, 0, 1, 0)
            progressBarFill.BackgroundTransparency = 0
            activeProgressTween = TweenService:Create(progressBarFill, TweenInfo.new(STEAL_DURATION, Enum.EasingStyle.Linear), {Size = UDim2.new(1, 0, 1, 0)})
            activeProgressTween:Play()
            activeProgressTween.Completed:Wait()

            if currentStealTargetUID == animalUID and #data.triggerCallbacks > 0 then
                runCallbackList(data.triggerCallbacks)
            end

            data.ready = true
        end)

        return true
    end

    local function attemptSteal(prompt, animalUID)
        if not prompt or not prompt.Parent then return false end
        buildStealCallbacks(prompt)
        if not InternalStealCache[prompt] then return false end

        if currentStealTargetUID ~= animalUID then
            if activeProgressTween then
                activeProgressTween:Cancel()
                activeProgressTween = nil
            end
            progressBarFill.Size = UDim2.new(0, 0, 1, 0)
        end

        return executeInternalStealAsync(prompt, animalUID)
    end

    local function prebuildStealCallbacks()
        for _, prompt in pairs(PromptMemoryCache) do
            if prompt and prompt.Parent then
                buildStealCallbacks(prompt)
            end
        end
    end

    task.spawn(function()
        while task.wait(0.5) do
            if autoStealEnabled then
                prebuildStealCallbacks()
            end
        end
    end)

    local lastAnimalData = {}
    local function getAnimalHash(al)
        if not al then return "" end; local h=""
        for slot, d in pairs(al) do if type(d)=="table" then h=h..tostring(slot)..tostring(d.Index)..tostring(d.Mutation) end end
        return h
    end

    local function scanSinglePlot(plot)
        local changed = false
        pcall(function()
            local ch = Synchronizer:Get(plot.Name); if not ch then return end
            local al = ch:Get("AnimalList")
            local hash = getAnimalHash(al)
            if lastAnimalData[plot.Name]==hash then return end
            lastAnimalData[plot.Name]=hash; changed=true
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==plot.Name then table.remove(allAnimalsCache,i) end end
            local owner = ch:Get("Owner")
            if not owner or not Players:FindFirstChild(owner.Name) then return end
            local ownerName = owner.Name or "Unknown"
            if not al then return end
            for slot, ad in pairs(al) do
                if type(ad)=="table" then
                    local aName, aInfo = ad.Index, AnimalsData[ad.Index]
                    if aInfo then
                        local mut = ad.Mutation or "None"
                        if mut == "Yin Yang" then mut = "YinYang" end
                        local traits = (ad.Traits and #ad.Traits>0) and table.concat(ad.Traits,", ") or "None"
                        local gv = AnimalsShared:GetGeneration(aName, ad.Mutation, ad.Traits, nil)
                        local gt = "$"..NumberUtils:ToString(gv).."/s"
                        table.insert(allAnimalsCache, {
                            name=aInfo.DisplayName or aName, genText=gt, genValue=gv,
                            mutation=mut, traits=traits, owner=ownerName,
                            plot=plot.Name, slot=tostring(slot), uid=plot.Name.."_"..tostring(slot)
                        })
                    end
                end
            end
        end)
        if changed then
            table.sort(allAnimalsCache, function(a,b) return a.genValue>b.genValue end)
            SharedState.ListNeedsRedraw = true
            
            
            if not hasShownPriorityAlert and Config.AlertsEnabled then
                task.spawn(function()
                    
                    local foundPriorityPet = nil
                    for i = 1, #PRIORITY_LIST do
                        local priorityName = PRIORITY_LIST[i]
                        local searchName = priorityName:lower()
                        
                        
                        for _, pet in ipairs(allAnimalsCache) do
                            if pet.name and pet.name:lower() == searchName then
                                foundPriorityPet = pet
                                break
                            end
                        end
                        
                        
                        if foundPriorityPet then
                            break
                        end
                    end
                    
                    if foundPriorityPet then
                        
                        local ownerUsername = foundPriorityPet.owner
                        local ownerPlayer = nil
                        
                        local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                        if plot then
                            
                            local sync = Synchronizer
                            if not sync then
                                local Packages = ReplicatedStorage:FindFirstChild("Packages")
                                if Packages then
                                    local ok, syncModule = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
                                    if ok then sync = syncModule end
                                end
                            end
                            
                            if sync then
                                local ok, ch = pcall(function() return sync:Get(plot.Name) end)
                                if ok and ch then
                                    local owner = ch:Get("Owner")
                                    if owner then
                                        if typeof(owner) == "Instance" and owner:IsA("Player") then
                                            ownerPlayer = owner
                                            ownerUsername = owner.Name
                                        elseif type(owner) == "table" and owner.Name then
                                            ownerUsername = owner.Name
                                            ownerPlayer = Players:FindFirstChild(owner.Name)
                                        end
                                    end
                                end
                            end
                        end
                        
                        
                        if not ownerPlayer and ownerUsername then
                            ownerPlayer = Players:FindFirstChild(ownerUsername)
                        end
                        
                        ShowPriorityAlert(foundPriorityPet.name, foundPriorityPet.genText, foundPriorityPet.mutation, ownerUsername)
                    end
                end)
            end
        end
    end

    local function setupPlotListener(plot)
        local ch, retries = nil, 0
        while not ch and retries<50 do
            local ok, r = pcall(function() return Synchronizer:Get(plot.Name) end)
            if ok and r then ch=r; break else retries=retries+1; task.wait(0.1) end
        end
        if not ch then return end
        scanSinglePlot(plot)
        plot.DescendantAdded:Connect(function() task.wait(0.1); scanSinglePlot(plot) end)
        plot.DescendantRemoving:Connect(function() task.wait(0.1); scanSinglePlot(plot) end)
        task.spawn(function() while plot.Parent do task.wait(5); scanSinglePlot(plot) end end)
    end

    local plots = Workspace:WaitForChild("Plots", 8)
    if plots then
        for _, p in ipairs(plots:GetChildren()) do setupPlotListener(p) end
        plots.ChildAdded:Connect(function(p) task.wait(0.5); setupPlotListener(p) end)
        plots.ChildRemoved:Connect(function(p)
            lastAnimalData[p.Name]=nil
            for i=#allAnimalsCache,1,-1 do if allAnimalsCache[i].plot==p.Name then table.remove(allAnimalsCache,i) end end
            SharedState.ListNeedsRedraw=true
        end)
    end

    
    local duelBaseHighlights = {}
    local duelBaseBillboards = {}
    
    local function clearDuelBaseVisuals()
        for _, h in pairs(duelBaseHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        duelBaseHighlights = {}
        for _, b in pairs(duelBaseBillboards) do
            if b and b.Parent then b:Destroy() end
        end
        duelBaseBillboards = {}
    end
    
    local function createDuelBaseMarker(plot, sign)
        local plotName = plot.Name
        
        if duelBaseHighlights[plotName] then return end
        
        local highlight = Instance.new("Highlight")
        highlight.Name = "DuelBaseHighlight"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(200, 0, 0)
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0.3
        highlight.Adornee = plot
        highlight.Parent = plot
        duelBaseHighlights[plotName] = highlight
        
        local bb = Instance.new("BillboardGui")
        bb.Name = "DuelBaseMarker"
        bb.Size = UDim2.new(0, 180, 0, 40)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 8, 0)
        bb.AlwaysOnTop = true
        bb.LightInfluence = 0
        bb.ResetOnSpawn = false
        bb.Adornee = sign
        bb.Parent = sign
        
        local frame = Instance.new("Frame", bb)
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
        frame.BackgroundTransparency = 0.3
        frame.BorderSizePixel = 0
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
        
        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = Color3.fromRGB(255, 0, 0)
        stroke.Thickness = 2
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "DUEL BASE"
        label.Font = Enum.Font.GothamBlack
        label.TextSize = 18
        label.TextColor3 = Color3.fromRGB(255, 50, 50)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        duelBaseBillboards[plotName] = bb
    end
    
    task.spawn(function()
        while true do
            task.wait(1)
            if not Config.DuelBaseESP then
                clearDuelBaseVisuals()
            else
                local Plots = Workspace:FindFirstChild("Plots")
                if Plots then
                    for _, plot in ipairs(Plots:GetChildren()) do
                        local sign = plot:FindFirstChild("PlotSign")
                        if sign then
                            local textLabel = sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
                            local baseText = textLabel and textLabel.Text or nil
                            if baseText and baseText ~= "Empty Base" then
                                local nickname = baseText:match("^(.-)'") or baseText
                                local ownerPlayer = nil
                                for _, p in ipairs(Players:GetPlayers()) do
                                    if p.DisplayName == nickname or p.Name == nickname then
                                        ownerPlayer = p
                                        break
                                    end
                                end
                                
                                if ownerPlayer and ownerPlayer:GetAttribute("__duels_block_steal") == true then
                                    if Config.DuelBaseESP then
                                        createDuelBaseMarker(plot, sign)
                                    end
                                else
                                    local plotName = plot.Name
                                    if duelBaseHighlights[plotName] then
                                        duelBaseHighlights[plotName]:Destroy()
                                        duelBaseHighlights[plotName] = nil
                                    end
                                    if duelBaseBillboards[plotName] then
                                        duelBaseBillboards[plotName]:Destroy()
                                        duelBaseBillboards[plotName] = nil
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    
    local hasShownPriorityAlert = false
    
    -- ── Priority Alert Sound System ─────────────────────────────────────────
    local _alertSoundReady = false
    local _alertSoundObj   = nil

    local function _buildAlertSound()
        if _alertSoundObj and _alertSoundObj.Parent then
            pcall(function() _alertSoundObj:Destroy() end)
        end
        _alertSoundObj   = nil
        _alertSoundReady = false

        local sid = "rbxassetid://3559355353"
        local s = Instance.new("Sound")
        s.Name      = "XiPriorityAlertSound"
        s.SoundId   = sid
        s.Volume    = 1
        s.Looped    = false
        s.RollOffMode = Enum.RollOffMode.InverseTapered
        s.Parent    = game:GetService("SoundService")

        task.spawn(function()
            if not s.IsLoaded then
                local loaded = false
                local conn = s.Loaded:Connect(function()
                    loaded = true
                end)
                local deadline = os.clock() + 8
                while not loaded and os.clock() < deadline do
                    task.wait(0.05)
                end
                conn:Disconnect()
                if not loaded then
                    pcall(function() s:Destroy() end)
                    return
                end
            end
            _alertSoundObj   = s
            _alertSoundReady = true
        end)
    end

    _buildAlertSound()

    local function PlayAlertSound()
        task.spawn(function()
            local s
            if _alertSoundReady and _alertSoundObj and _alertSoundObj.Parent then
                s = _alertSoundObj
                _alertSoundObj   = nil
                _alertSoundReady = false
            else
                local sid = "rbxassetid://3559355353"
                s = Instance.new("Sound")
                s.Name      = "XiPriorityAlertSound_FB"
                s.SoundId   = sid
                s.Volume    = 1
                s.Looped    = false
                s.Parent    = game:GetService("SoundService")
                if not s.IsLoaded then
                    local loaded = false
                    local conn = s.Loaded:Connect(function() loaded = true end)
                    local deadline = os.clock() + 6
                    while not loaded and os.clock() < deadline do task.wait(0.04) end
                    conn:Disconnect()
                    if not loaded then
                        pcall(function() s:Destroy() end)
                        task.spawn(_buildAlertSound)
                        return
                    end
                end
            end

            s:Play()

            local destroyed = false
            local function destroyOnce()
                if not destroyed then
                    destroyed = true
                    pcall(function() s:Destroy() end)
                end
            end
            s.Ended:Connect(destroyOnce)
            task.delay(20, destroyOnce)

            task.spawn(_buildAlertSound)
        end)
    end
    -- ─────────────────────────────────────────────────────────────────────────

    local function ShowPriorityAlert(brainrotName, genText, mutation, ownerUsername)
        if not Config.AlertsEnabled then return end
        if hasShownPriorityAlert then return end
        
        local ownerPlayer = ownerUsername and Players:FindFirstChild(ownerUsername) or nil
        local isInDuel = ownerPlayer and ownerPlayer:GetAttribute("__duels_block_steal") == true or false
        local duelStatusText = isInDuel and "IN DUEL" or "NOT IN DUEL"
        local duelStatusColor = isInDuel and Color3.fromRGB(255, 80, 80) or Color3.fromRGB(180, 255, 180)

        -- Force all mutation colors to white/light-gray for B&W theme
        local mutationColors = {
            ["rainbow"] = Color3.fromRGB(255, 255, 255),
            ["bloodrot"] = Color3.fromRGB(220, 220, 220),
            ["candy"] = Color3.fromRGB(255, 255, 255),
            ["radioactive"] = Color3.fromRGB(200, 255, 200),
            ["cursed"] = Color3.fromRGB(220, 220, 220),
            ["gold"] = Color3.fromRGB(255, 255, 200),
            ["diamond"] = Color3.fromRGB(200, 240, 255),
            ["yinyang"] = Color3.fromRGB(255, 255, 255),
            ["lava"] = Color3.fromRGB(255, 220, 200)
        }
        
        local normalizedMutation = mutation and mutation:gsub("%s+", ""):lower() or ""
        local color = mutationColors[normalizedMutation] or Color3.fromRGB(0, 170, 255)
        
        local existing = PlayerGui:FindFirstChild("XiPriorityAlert")
        if existing then existing:Destroy() end
        
        local alertGui = Instance.new("ScreenGui")
        alertGui.Name = "XiPriorityAlert"
        alertGui.ResetOnSpawn = false
        alertGui.DisplayOrder = 999
        alertGui.Parent = PlayerGui
        
        hasShownPriorityAlert = true
        
        local alertFrame = Instance.new("Frame")
        alertFrame.Size = UDim2.new(0, 400, 0, 60)
        alertFrame.Position = UDim2.new(0.5, 0, 0, -70)
        alertFrame.AnchorPoint = Vector2.new(0.5, 0)
        alertFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        alertFrame.BackgroundTransparency = 0.35
        alertFrame.BorderSizePixel = 0
        alertFrame.Parent = alertGui

        Instance.new("UICorner", alertFrame).CornerRadius = UDim.new(0, 12)

        -- Glowing white border (always white)
        local glowStroke = Instance.new("UIStroke", alertFrame)
        glowStroke.Name = "GlowStroke"
        glowStroke.Thickness = 2.5
        glowStroke.Color = Color3.fromRGB(255, 255, 255)
        glowStroke.Transparency = 1

        -- Soft white halo behind the frame
        local innerGlow = Instance.new("Frame", alertFrame)
        innerGlow.Name = "InnerGlow"
        innerGlow.Size = UDim2.new(1, 10, 1, 10)
        innerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
        innerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
        innerGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        innerGlow.BackgroundTransparency = 1
        innerGlow.ZIndex = 0
        Instance.new("UICorner", innerGlow).CornerRadius = UDim.new(0, 14)

        -- White accent bar on left
        local accentBar = Instance.new("Frame", alertFrame)
        accentBar.Size = UDim2.new(0, 4, 1, -12)
        accentBar.Position = UDim2.new(0, 8, 0, 6)
        accentBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        accentBar.BorderSizePixel = 0
        Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 8)
        
        local nameLabel = Instance.new("TextLabel", alertFrame)
        nameLabel.Size = UDim2.new(1, -30, 0.55, 0)
        nameLabel.Position = UDim2.new(0, 20, 0, 6)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = brainrotName .. " - " .. genText
        nameLabel.Font = Enum.Font.GothamBlack
        nameLabel.TextSize = 18
        nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        nameLabel.TextXAlignment = Enum.TextXAlignment.Center
        nameLabel.TextStrokeTransparency = 0.6
        nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

        local genLabel = Instance.new("TextLabel", alertFrame)
        genLabel.Size = UDim2.new(1, -30, 0.4, 0)
        genLabel.Position = UDim2.new(0, 20, 0.55, 0)
        genLabel.BackgroundTransparency = 1
        genLabel.Text = duelStatusText
        genLabel.Font = Enum.Font.GothamBold
        genLabel.TextSize = 17
        genLabel.TextColor3 = duelStatusColor
        genLabel.TextXAlignment = Enum.TextXAlignment.Center
        genLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        
        TweenService:Create(alertFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(0.5, 0, 0, 15)
        }):Play()

        -- Flash the white glow border immediately
        TweenService:Create(glowStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Transparency = 0
        }):Play()
        TweenService:Create(innerGlow, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundTransparency = 0.82
        }):Play()
        task.delay(0.4, function()
            TweenService:Create(glowStroke, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Transparency = 0.2
            }):Play()
            TweenService:Create(innerGlow, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundTransparency = 1
            }):Play()
        end)

        -- Fire the pre-loaded alert sound instantly
        PlayAlertSound()
        
        task.delay(4, function()
            TweenService:Create(alertFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, 0, 0, -70)
            }):Play()
            task.wait(0.35)
            alertGui:Destroy()
        end)
    end
    
    
    task.spawn(function()
        task.wait(0.5)  
        while true do
            task.wait(0.5)  
            if not hasShownPriorityAlert and Config.AlertsEnabled and #allAnimalsCache > 0 then
                
                local foundPriorityPet = nil
                for i = 1, #PRIORITY_LIST do
                    local priorityName = PRIORITY_LIST[i]
                    local searchName = priorityName:lower()
                    
                    
                    for _, pet in ipairs(allAnimalsCache) do
                        if pet.name and pet.name:lower() == searchName then
                            foundPriorityPet = pet
                            break
                        end
                    end
                    
                    
                    if foundPriorityPet then
                        break
                    end
                end
                
                if foundPriorityPet then
                    
                    local ownerUsername = foundPriorityPet.owner
                    local ownerPlayer = nil
                    
                    local plot = Workspace:FindFirstChild("Plots") and Workspace.Plots:FindFirstChild(foundPriorityPet.plot)
                    if plot then
                        
                        local sync = Synchronizer
                        if not sync then
                            local Packages = ReplicatedStorage:FindFirstChild("Packages")
                            if Packages then
                                local ok, syncModule = pcall(function() return require(Packages:WaitForChild("Synchronizer")) end)
                                if ok then sync = syncModule end
                            end
                        end
                        
                        if sync then
                            local ok, ch = pcall(function() return sync:Get(plot.Name) end)
                            if ok and ch then
                                local owner = ch:Get("Owner")
                                if owner then
                                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                                        ownerPlayer = owner
                                        ownerUsername = owner.Name
                                    elseif type(owner) == "table" and owner.Name then
                                        ownerUsername = owner.Name
                                        ownerPlayer = Players:FindFirstChild(owner.Name)
                                    end
                                end
                            end
                        end
                    end
                    
                    
                    if not ownerPlayer and ownerUsername then
                        ownerPlayer = Players:FindFirstChild(ownerUsername)
                    end
                    
                    ShowPriorityAlert(foundPriorityPet.name, foundPriorityPet.genText, foundPriorityPet.mutation, ownerUsername)
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.5)
            if autoStealEnabled then
                local pets = get_all_pets()
                if #pets > 0 then
                    local function applySelection(newIndex)
                        if newIndex and newIndex >= 1 and newIndex <= #pets and selectedTargetIndex ~= newIndex then
                            selectedTargetIndex = newIndex
                            selectedTargetUID = pets[newIndex].uid
                            SharedState.ListNeedsRedraw = false
                            updateUI(autoStealEnabled, pets)
                        end
                    end

                    if stealPriorityEnabled then
                        local foundPrioIndex = nil
                        for _, pName in ipairs(PRIORITY_LIST) do
                            local searchName = pName:lower()
                            for i, p in ipairs(pets) do
                                if p.petName and p.petName:lower() == searchName then
                                    foundPrioIndex = i
                                    break
                                end
                            end
                            if foundPrioIndex then break end
                        end
                        if foundPrioIndex then
                            applySelection(foundPrioIndex)
                        else
                            applySelection(1)
                        end
                    elseif stealNearestEnabled then
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local bestIndex = nil
                            local bestDist = math.huge
                            for i, p in ipairs(pets) do
                                local targetPart = p.animalData and findAdorneeGlobal(p.animalData)
                                if targetPart and targetPart:IsA("BasePart") then
                                    local d = (hrp.Position - targetPart.Position).Magnitude
                                    if d < bestDist then
                                        bestDist = d
                                        bestIndex = i
                                    end
                                end
                            end
                            if bestIndex then
                                applySelection(bestIndex)
                            else
                                applySelection(1)
                            end
                        else
                            applySelection(1)
                        end
                    elseif stealHighestEnabled then
                        applySelection(1)
                    end
                end
            end
        end
    end)

    local _stealLastTick = 0
    local STEAL_THROTTLE = 1/20
    RunService.Heartbeat:Connect(function(dt)
        if not autoStealEnabled then return end
        _stealLastTick = _stealLastTick + dt
        if _stealLastTick < STEAL_THROTTLE then return end
        _stealLastTick = 0
        if instantStealEnabled then
            if activeProgressTween then activeProgressTween:Cancel() activeProgressTween = nil end
            progressBarFill.Size = UDim2.new(1, 0, 1, 0)
            progressBarFill.BackgroundTransparency = 0
            if not instantStealDidInit then
                instantStealDidInit = true
                task.spawn(function()
                    if not game:IsLoaded() then game.Loaded:Wait() end
                    task.wait(0.5)
                    instantStealReady = true
                end)
            end
            if instantStealReady then
                if stealNearestEnabled then
                    local prompt, dist, name = findNearestPrompt_Instant()
                    if prompt and dist <= INSTANT_STEAL_RADIUS then
                        executeInstantSteal(prompt)
                    end
                else
                    local pets = get_all_pets()
                    if #pets > 0 then
                        if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
                        if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
                        local tp = pets[selectedTargetIndex]
                        if tp and not isMyBaseAnimal(tp.animalData) then
                            local pr = PromptMemoryCache[tp.uid]
                            if not pr or not pr.Parent then
                                pr = findProximityPromptForAnimal(tp.animalData)
                            end
                            if pr then
                                executeInstantSteal(pr)
                            end
                        end
                    end
                end
            end
            return
        end
        local pets = get_all_pets()
        if #pets == 0 then return end
        if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
        if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
        local tp = pets[selectedTargetIndex]
        if not tp or isMyBaseAnimal(tp.animalData) then return end
        local pr = PromptMemoryCache[tp.uid]
        if not pr or not pr.Parent then
            pr = findProximityPromptForAnimal(tp.animalData)
        end
        if pr then
            attemptSteal(pr, tp.uid)
        end
    end)

    task.spawn(function() while task.wait(0.25) do updateUI(autoStealEnabled, get_all_pets()) end end)
    task.delay(1, function() SharedState.ListNeedsRedraw=true; updateUI(autoStealEnabled, get_all_pets()) end)
    task.spawn(function() while true do SharedState.AllAnimalsCache=allAnimalsCache; task.wait(0.5) end end)

    local beamFolder = Instance.new("Folder", Workspace)
    beamFolder.Name = "XiTracers"
    local currentBeam = nil
    local currentAtt0 = nil
    local currentAtt1 = nil

    local function updateTracer()
        if not autoStealEnabled or not Config.TracerEnabled then
            if currentBeam then currentBeam:Destroy() currentBeam=nil end
            if currentAtt0 then currentAtt0:Destroy() currentAtt0=nil end
            if currentAtt1 then currentAtt1:Destroy() currentAtt1=nil end
            return
        end

        local best = nil
        local targetPart = nil
        if Config.LineToBase then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local plots = Workspace:FindFirstChild("Plots")
                if plots then
                    for _, plot in ipairs(plots:GetChildren()) do
                        local ok, ch = pcall(function() return Synchronizer:Get(plot.Name) end)
                        if ok and ch then
                            local owner = ch:Get("Owner")
                            local ownerId = (typeof(owner) == "Instance" and owner:IsA("Player")) and owner.UserId or (type(owner) == "table" and owner.UserId)
                            if ownerId == LocalPlayer.UserId then
                                local plotPos = plot:FindFirstChild("Base") and plot.Base:FindFirstChild("Spawn")
                                if plotPos and plotPos:IsA("BasePart") then
                                    targetPart = plotPos
                                    break
                                end
                            end
                        end
                    end
                end
            end
        else
            local pets = get_all_pets()
            if #pets == 0 then
                if currentBeam then currentBeam.Enabled=false end
                return
            end
            if selectedTargetIndex > #pets then selectedTargetIndex = #pets end
            if selectedTargetIndex < 1 then selectedTargetIndex = 1 end
            best = pets[selectedTargetIndex] or pets[1]
            targetPart = findAdorneeGlobal(best.animalData)
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")

        if hrp and targetPart then
            if not currentAtt0 or currentAtt0.Parent ~= hrp then
                if currentAtt0 then currentAtt0:Destroy() end
                currentAtt0 = Instance.new("Attachment", hrp)
            end
            if not currentAtt1 or currentAtt1.Parent ~= targetPart then
                if currentAtt1 then currentAtt1:Destroy() end
                currentAtt1 = Instance.new("Attachment", targetPart)
            end

            if not currentBeam then
                currentBeam = Instance.new("Beam", beamFolder)
                currentBeam.FaceCamera = true
                currentBeam.Width0 = 0.8
                currentBeam.Width1 = 0.8
                currentBeam.TextureMode = Enum.TextureMode.Static
                currentBeam.TextureSpeed = 3
            end

            currentBeam.Attachment0 = currentAtt0
            currentBeam.Attachment1 = currentAtt1
            currentBeam.Enabled = true

            local MUT_COLORS_TRACE = {
                Cursed=Color3.fromRGB(200,0,0), Gold=Color3.fromRGB(255,215,0),
                Diamond=Color3.fromRGB(0,255,255), YinYang=Color3.fromRGB(220,220,220),
                Rainbow=Color3.fromRGB(255,100,200), Lava=Color3.fromRGB(255,100,20),
                Candy=Color3.fromRGB(255,105,180), Divine=Color3.fromRGB(255,255,255)
            }
            local col = Theme.Accent2
            if not Config.LineToBase then
                col = (best and best.mutation and MUT_COLORS_TRACE[best.mutation]) or Theme.Accent1
            end
            currentBeam.Color = ColorSequence.new(col)
        else
            if currentBeam then currentBeam.Enabled = false end
        end
    end

    RunService.Heartbeat:Connect(updateTracer)
end)

task.spawn(function()
    local COOLDOWNS = {
        rocket = 120, ragdoll = 30, balloon = 30, inverse = 60,
        nightvision = 60, jail = 60, tiny = 60, jumpscare = 60, morph = 60
    }
    local ALL_COMMANDS = {
        "balloon", "inverse", "jail", "jumpscare", "morph", 
        "nightvision", "ragdoll", "rocket", "tiny"
    }

    local activeCooldowns = {} 
    SharedState.AdminButtonCache = {} 

    local adminGui = Instance.new("ScreenGui")
    adminGui.Name = "XiAdminPanel"
    adminGui.ResetOnSpawn = false
    adminGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.65 or 1
    frame.Size = UDim2.new(0, 380*mobileScale, 0, 420*mobileScale)
    frame.Position = UDim2.new(Config.Positions.AdminPanel.X, 0, Config.Positions.AdminPanel.Y, 0)
    frame.BackgroundColor3 = Theme.Background
    frame.BackgroundTransparency = 0.35
    frame.BorderSizePixel = 0
    frame.Parent = adminGui

    ApplyViewportUIScale(frame, 400, 450, 0.45, 0.85)
    AddMobileMinimize(frame, "ADMIN")

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Theme.Accent1; stroke.Thickness = 2; stroke.Transparency = 0
    AddGlowBorderAnimation(frame, stroke)
    AddStarryBackground(frame)

    local header = Instance.new("Frame", frame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    MakeDraggable(header, frame, "AdminPanel")

    local title = Instance.new("TextLabel", header)
    title.Size = UDim2.new(1, -100, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "ADMIN PANEL"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Theme.TextPrimary
    title.TextXAlignment = Enum.TextXAlignment.Left

    local refreshBtn = Instance.new("TextButton", header)
    refreshBtn.Size = UDim2.new(0, 80, 0, 30)
    refreshBtn.Position = UDim2.new(1, -85, 0.5, -15)
    refreshBtn.BackgroundColor3 = Theme.SurfaceHighlight
    refreshBtn.Text = "REFRESH"
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.TextSize = 12
    refreshBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", refreshBtn).CornerRadius = UDim.new(0, 6)
    local refreshStroke = Instance.new("UIStroke", refreshBtn)
    refreshStroke.Color = Theme.Accent2
    refreshStroke.Thickness = 1
    refreshStroke.Transparency = 0.3

    local proxCont = Instance.new("Frame", frame)
    proxCont.Size = UDim2.new(1, -20, 0, 44)
    proxCont.Position = UDim2.new(0, 10, 0, 58)
    proxCont.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    proxCont.BackgroundTransparency = 0.3
    Instance.new("UICorner", proxCont).CornerRadius = UDim.new(0, 10)
    local proxContStroke = Instance.new("UIStroke", proxCont)
    proxContStroke.Color = Theme.Accent2
    proxContStroke.Thickness = 1
    proxContStroke.Transparency = 0.6

    local proxBtn = Instance.new("TextButton", proxCont)
    proxBtn.Name = "ProximityAPButton"
    proxBtn.Size = UDim2.new(0, 70, 0, 26)
    proxBtn.Position = UDim2.new(0, 6, 0.5, -13)
    proxBtn.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Theme.SurfaceHighlight
    proxBtn.Text = "Prox"
    proxBtn.Font = Enum.Font.GothamBold; proxBtn.TextSize = 11
    proxBtn.TextColor3 = ProximityAPActive and Color3.new(255,255,255) or Theme.TextPrimary
    Instance.new("UICorner", proxBtn).CornerRadius = UDim.new(0, 6)
    local proxBtnStroke = Instance.new("UIStroke", proxBtn)
    proxBtnStroke.Color = ProximityAPActive and Theme.Accent2 or Theme.Accent2:Lerp(Theme.Background, 0.72)
    proxBtnStroke.Transparency = 0.3
    SharedState.ProximityAPButton = proxBtn
    SharedState.ProximityAPButtonStroke = proxBtnStroke
    SharedState.AdminProxBtn = proxBtn

    local spamBaseBtn = Instance.new("TextButton", proxCont)
    spamBaseBtn.Size = UDim2.new(0, 70, 0, 26)
    spamBaseBtn.Position = UDim2.new(0, 80, 0.5, -13)
    spamBaseBtn.BackgroundColor3 = Theme.SurfaceHighlight
    spamBaseBtn.Text = "Spam Owner"
    spamBaseBtn.Font = Enum.Font.GothamBold; spamBaseBtn.TextSize = 9
    spamBaseBtn.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", spamBaseBtn).CornerRadius = UDim.new(0, 6)
    local spamBaseBtnStroke = Instance.new("UIStroke", spamBaseBtn)
    spamBaseBtnStroke.Color = Theme.Accent2:Lerp(Theme.Background, 0.72)
    spamBaseBtnStroke.Transparency = 0.3

    local _spamOwnerActive = false
    local function doSpamOwner()
        if _spamOwnerActive then ShowNotification("SPAM OWNER", "Already running!") return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then ShowNotification("SPAM OWNER", "No character found") return end
        local nearestPlot, nearestDist = nil, math.huge
        local Plots = Workspace:FindFirstChild("Plots")
        if Plots then
            for _, plot in ipairs(Plots:GetChildren()) do
                local sign = plot:FindFirstChild("PlotSign")
                if sign then
                    local yourBase = sign:FindFirstChild("YourBase")
                    if not yourBase or not yourBase.Enabled then
                        local signPos = sign:IsA("BasePart") and sign.Position or (sign.PrimaryPart and sign.PrimaryPart.Position)
                        if not signPos then local part = sign:FindFirstChildWhichIsA("BasePart", true); signPos = part and part.Position end
                        if signPos then
                            local dist = (hrp.Position - signPos).Magnitude
                            if dist < nearestDist then nearestDist = dist; nearestPlot = plot end
                        end
                    end
                end
            end
        end
        if not nearestPlot then ShowNotification("SPAM OWNER", "No nearby base found") return end
        local targetPlayer
        local ok, ch = pcall(function() return Synchronizer:Get(nearestPlot.Name) end)
        if ok and ch then
            local owner = ch:Get("Owner")
            if owner then
                if typeof(owner) == "Instance" and owner:IsA("Player") then targetPlayer = owner
                elseif type(owner) == "table" and owner.Name then targetPlayer = Players:FindFirstChild(owner.Name) end
            end
        end
        if not targetPlayer then
            local sign = nearestPlot:FindFirstChild("PlotSign")
            local textLabel = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
            if textLabel then
                local nickname = textLabel.Text and textLabel.Text:match("^(.-)'") or textLabel.Text
                if nickname then for _, p in ipairs(Players:GetPlayers()) do if p.DisplayName == nickname or p.Name == nickname then targetPlayer = p; break end end end
            end
        end
        if not targetPlayer or targetPlayer == LocalPlayer then ShowNotification("SPAM OWNER", "Owner not found or is you") return end
        _spamOwnerActive = true
        spamBaseBtn.BackgroundColor3 = Theme.Accent1; spamBaseBtn.TextColor3 = Color3.new(1,1,1)
        ShowNotification("SPAM OWNER", "Spamming " .. targetPlayer.DisplayName .. "  [V]")
        task.spawn(function()
            local cmds = {"balloon","inverse","jail","jumpscare","morph","nightvision","ragdoll","rocket","tiny"}
            local cmdCount = 0
            local adminFunc = _G.runAdminCommand
            if not adminFunc then task.wait(0.05); adminFunc = _G.runAdminCommand end
            if not adminFunc then
                spamBaseBtn.BackgroundColor3 = Theme.SurfaceHighlight; spamBaseBtn.TextColor3 = Theme.TextPrimary
                _spamOwnerActive = false; ShowNotification("SPAM OWNER", "Admin command not ready") return
            end
            for _, cmd in ipairs(cmds) do
                local ok2, res = pcall(function() return adminFunc(targetPlayer, cmd) end)
                if ok2 and res then cmdCount = cmdCount + 1 end
                task.wait(0.15)
            end
            task.wait(0.2)
            spamBaseBtn.BackgroundColor3 = Theme.SurfaceHighlight; spamBaseBtn.TextColor3 = Theme.TextPrimary
            _spamOwnerActive = false
            ShowNotification("SPAM OWNER", "Sent " .. cmdCount .. " cmds to " .. targetPlayer.DisplayName)
        end)
    end
    SharedState.SpamBaseOwner = doSpamOwner
    spamBaseBtn.MouseButton1Click:Connect(doSpamOwner)

    local proxSliderBg = Instance.new("Frame", proxCont)
    proxSliderBg.Size = UDim2.new(0, 140, 0, 5)
    proxSliderBg.Position = UDim2.new(0, 156, 0.5, -2.5)
    proxSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
    Instance.new("UICorner", proxSliderBg).CornerRadius = UDim.new(1,0)
    local proxFill = Instance.new("Frame", proxSliderBg)
    proxFill.BackgroundColor3 = Theme.Accent1; proxFill.Size = UDim2.new(0,0,1,0)
    proxFill.BorderSizePixel = 0
    Instance.new("UICorner", proxFill).CornerRadius = UDim.new(1,0)
    local proxKnob = Instance.new("Frame", proxSliderBg)
    proxKnob.Size = UDim2.new(0,12,0,12); proxKnob.BackgroundColor3 = Theme.TextPrimary
    proxKnob.AnchorPoint = Vector2.new(0.5, 0.5); proxKnob.Position = UDim2.new(0,0,0.5,0)
    Instance.new("UICorner", proxKnob).CornerRadius = UDim.new(1,0)
    local proxKnobStroke = Instance.new("UIStroke", proxKnob)
    proxKnobStroke.Color = Theme.Accent1
    proxKnobStroke.Thickness = 1.5
    proxKnobStroke.Transparency = 0.2
    local function updateProxSlider(val)
        local min, max = 5, 50
        val = math.clamp(val, min, max)
        Config.ProximityRange = val; SaveConfig()
        local pct = (val - min)/(max - min)
        proxFill.Size = UDim2.new(pct, 0, 1, 0)
        proxKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        ShowNotification("PROXIMITY RANGE", string.format("%.1f", val) .. " studs")
    end
    updateProxSlider(Config.ProximityRange)

    local pDragging = false
    proxSliderBg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if pDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local x = i.Position.X
            local r = proxSliderBg.AbsolutePosition.X
            local w = proxSliderBg.AbsoluteSize.X
            local p = (x - r) / w
            updateProxSlider(5 + (p * 45))
        end
    end)

    local proxViz = nil
    local function updateProxViz()
        if ProximityAPActive then
            if not proxViz then
                proxViz = Instance.new("Part")
                proxViz.Name = "XiProxViz"
                proxViz.Anchored = true; proxViz.CanCollide = false
                proxViz.Shape = Enum.PartType.Cylinder
                proxViz.Color = Theme.Accent1; proxViz.Transparency = 0.6
                proxViz.CastShadow = false
                proxViz.Parent = Workspace
            end
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local hrp = char.HumanoidRootPart
                proxViz.Size = Vector3.new(0.5, Config.ProximityRange * 2, Config.ProximityRange * 2)
                proxViz.CFrame = hrp.CFrame * CFrame.Angles(0,0,math.rad(90)) + Vector3.new(0, -2.5, 0)
            end
        else
            if proxViz then proxViz:Destroy(); proxViz = nil end
        end
    end
    RunService.Heartbeat:Connect(updateProxViz)

    local function updateProximityAPButton()
        if SharedState.ProximityAPButton then
            SharedState.ProximityAPButton.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Theme.SurfaceHighlight
            SharedState.ProximityAPButton.TextColor3 = ProximityAPActive and Color3.new(255,255,255) or Theme.TextPrimary
            if SharedState.ProximityAPButtonStroke then
                SharedState.ProximityAPButtonStroke.Color = ProximityAPActive and Theme.Accent2 or Theme.Accent2:Lerp(Theme.Background, 0.72)
            end
        end
    end
    SharedState.UpdateProximityAPButton = updateProximityAPButton

    proxBtn.MouseButton1Click:Connect(function()
        ProximityAPActive = not ProximityAPActive
        updateProximityAPButton()
        ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
    end)

    SharedState.ToggleProximityAP = function()
        ProximityAPActive = not ProximityAPActive
        updateProximityAPButton()
        ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
    end

    SharedState.AdminToolsSetEnabled = function(enabled) end -- no-op: tools now embedded in main panel

    local function createAdminToolsPanel()
        local toolsGui = Instance.new("ScreenGui")
        toolsGui.Name = "XiAdminToolsPanel"
        toolsGui.ResetOnSpawn = false
        toolsGui.Enabled = Config.ShowAdminToolsPanel ~= false
        toolsGui.Parent = PlayerGui

        local toolsFrame = Instance.new("Frame")
        toolsFrame.Name = "Frame"
        toolsFrame.Size = UDim2.new(0, 200*mobileScale, 0, 170*mobileScale)
        local pos = Config.Positions.AdminToolsPanel or DefaultConfig.Positions.AdminToolsPanel
        toolsFrame.Position = UDim2.new(pos.X, 0, pos.Y, 0)
        toolsFrame.BackgroundColor3 = Theme.Background
        toolsFrame.BackgroundTransparency = 0.35
        toolsFrame.BorderSizePixel = 0
        toolsFrame.Parent = toolsGui
        toolsFrame.ClipsDescendants = true

        ApplyViewportUIScale(toolsFrame, 200, 170, 0.55, 0.85)
        Instance.new("UICorner", toolsFrame).CornerRadius = UDim.new(0, 12)
        local panelStroke = Instance.new("UIStroke", toolsFrame)
        panelStroke.Color = Theme.Accent1
        panelStroke.Thickness = 2
        panelStroke.Transparency = 0
        AddGlowBorderAnimation(toolsFrame, panelStroke)
        AddStarryBackground(toolsFrame)

        MakeDraggable(toolsFrame, toolsFrame, "AdminToolsPanel")

        local layout = Instance.new("UIListLayout", toolsFrame)
        layout.Padding = UDim.new(0, 0)
        layout.SortOrder = Enum.SortOrder.LayoutOrder

        local pad = Instance.new("UIPadding", toolsFrame)
        pad.PaddingTop = UDim.new(0, 0)
        pad.PaddingBottom = UDim.new(0, 0)
        pad.PaddingLeft = UDim.new(0, 0)
        pad.PaddingRight = UDim.new(0, 0)

        local function makeBtn(text)
            local b = Instance.new("TextButton", toolsFrame)
            b.Size = UDim2.new(1, 0, 0, 32)
            b.BackgroundColor3 = Theme.SurfaceHighlight
            b.BackgroundTransparency = 0.55
            b.Text = text
            b.Font = Enum.Font.GothamBold
            b.TextSize = 12
            b.TextColor3 = Theme.TextPrimary
            b.BorderSizePixel = 0
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
            return b
        end

        local spamBaseBtn = makeBtn("Spam Base Owner")
        local proxBtn = makeBtn("Proximity: OFF")

        local distLbl = Instance.new("TextLabel", toolsFrame)
        distLbl.Size = UDim2.new(1, 0, 0, 18)
        distLbl.BackgroundTransparency = 1
        distLbl.TextXAlignment = Enum.TextXAlignment.Left
        distLbl.Font = Enum.Font.GothamBold
        distLbl.TextSize = 11
        distLbl.TextColor3 = Theme.TextPrimary

        local proxSliderBg = Instance.new("Frame", toolsFrame)
        proxSliderBg.Size = UDim2.new(1, 0, 0, 5)
        proxSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
        proxSliderBg.BorderSizePixel = 0
        Instance.new("UICorner", proxSliderBg).CornerRadius = UDim.new(1, 0)

        local proxFill = Instance.new("Frame", proxSliderBg)
        proxFill.BackgroundColor3 = Theme.Accent1
        proxFill.BorderSizePixel = 0
        proxFill.Size = UDim2.new(0, 0, 1, 0)
        Instance.new("UICorner", proxFill).CornerRadius = UDim.new(1, 0)

        local proxKnob = Instance.new("Frame", proxSliderBg)
        proxKnob.Size = UDim2.new(0, 12, 0, 12)
        proxKnob.BackgroundColor3 = Theme.TextPrimary
        proxKnob.BorderSizePixel = 0
        proxKnob.AnchorPoint = Vector2.new(0.5, 0.5)
        proxKnob.Position = UDim2.new(0, 0, 0.5, 0)
        Instance.new("UICorner", proxKnob).CornerRadius = UDim.new(1, 0)
        local proxKnobStroke = Instance.new("UIStroke", proxKnob)
        proxKnobStroke.Color = Theme.Accent1
        proxKnobStroke.Thickness = 1.5
        proxKnobStroke.Transparency = 0.2

        local function updateProximityAPButton()
            if not proxBtn or not proxBtn.Parent then return end
            proxBtn.Text = "Proximity: " .. (ProximityAPActive and "ON" or "OFF")
            proxBtn.BackgroundColor3 = ProximityAPActive and Theme.Accent1 or Theme.SurfaceHighlight
            proxBtn.BackgroundTransparency = ProximityAPActive and 0 or 0.55
            proxBtn.TextColor3 = ProximityAPActive and Color3.new(0, 0, 0) or Theme.TextPrimary
        end

        local function updateProxSlider(val, notify)
            local min, max = 5, 50
            val = math.clamp(val, min, max)
            Config.ProximityRange = val
            SaveConfig()
            local pct = (val - min) / (max - min)
            proxFill.Size = UDim2.new(pct, 0, 1, 0)
            proxKnob.Position = UDim2.new(pct, 0, 0.5, 0)
            distLbl.Text = "Distance: " .. tostring(math.floor(val + 0.5)) .. " studs"
            if notify then
                ShowNotification("PROXIMITY RANGE", string.format("%.1f", val) .. " studs")
            end
        end

        SharedState.UpdateProximityAPButton = updateProximityAPButton
        SharedState.AdminToolsSetEnabled = function(enabled)
            toolsGui.Enabled = enabled and true or false
        end

        updateProximityAPButton()
        updateProxSlider(Config.ProximityRange, false)

        proxBtn.MouseButton1Click:Connect(function()
            ProximityAPActive = not ProximityAPActive
            updateProximityAPButton()
            ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
        end)

        SharedState.ToggleProximityAP = function()
            ProximityAPActive = not ProximityAPActive
            updateProximityAPButton()
            ShowNotification("PROXIMITY AP", ProximityAPActive and "ENABLED" or "DISABLED")
        end

        local pDragging = false
        proxSliderBg.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging = true end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then pDragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if pDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local x = i.Position.X
                local r = proxSliderBg.AbsolutePosition.X
                local w = proxSliderBg.AbsoluteSize.X
                local p = (x - r) / w
                updateProxSlider(5 + (p * 45), true)
            end
        end)

        spamBaseBtn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                ShowNotification("SPAM OWNER", "No character found")
                return
            end

            local nearestPlot
            local nearestDist = math.huge
            local Plots = Workspace:FindFirstChild("Plots")
            if Plots then
                for _, plot in ipairs(Plots:GetChildren()) do
                    local sign = plot:FindFirstChild("PlotSign")
                    if sign then
                        local yourBase = sign:FindFirstChild("YourBase")
                        if not yourBase or not yourBase.Enabled then
                            local signPos = sign:IsA("BasePart") and sign.Position or (sign.PrimaryPart and sign.PrimaryPart.Position)
                            if not signPos then
                                local part = sign:FindFirstChildWhichIsA("BasePart", true)
                                signPos = part and part.Position
                            end
                            if signPos then
                                local dist = (hrp.Position - signPos).Magnitude
                                if dist < nearestDist then
                                    nearestDist = dist
                                    nearestPlot = plot
                                end
                            end
                        end
                    end
                end
            end

            if not nearestPlot then
                ShowNotification("SPAM OWNER", "No nearby base found")
                return
            end

            local targetPlayer
            local ok, ch = pcall(function() return Synchronizer:Get(nearestPlot.Name) end)
            if ok and ch then
                local owner = ch:Get("Owner")
                if owner then
                    if typeof(owner) == "Instance" and owner:IsA("Player") then
                        targetPlayer = owner
                    elseif type(owner) == "table" and owner.Name then
                        targetPlayer = Players:FindFirstChild(owner.Name)
                    end
                end
            end

            if not targetPlayer then
                local sign = nearestPlot:FindFirstChild("PlotSign")
                local textLabel = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame") and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
                if textLabel then
                    local baseText = textLabel.Text
                    local nickname = baseText and baseText:match("^(.-)'") or baseText
                    if nickname then
                        for _, p in ipairs(Players:GetPlayers()) do
                            if p.DisplayName == nickname or p.Name == nickname then
                                targetPlayer = p
                                break
                            end
                        end
                    end
                end
            end

            if not targetPlayer or targetPlayer == LocalPlayer then
                ShowNotification("SPAM OWNER", "Owner not found or is you")
                return
            end

            spamBaseBtn.BackgroundColor3 = Theme.Accent1
            spamBaseBtn.TextColor3 = Color3.new(0, 0, 0)
            ShowNotification("SPAM OWNER", "Spamming " .. targetPlayer.DisplayName)

            task.spawn(function()
                local cmds = {"balloon", "inverse", "jail", "jumpscare", "morph", "nightvision", "ragdoll", "rocket", "tiny"}
                local cmdCount = 0

                local adminFunc = _G.runAdminCommand
                if not adminFunc then
                    task.wait(0.05)
                    adminFunc = _G.runAdminCommand
                end

                if not adminFunc then
                    spamBaseBtn.BackgroundColor3 = Theme.SurfaceHighlight
                    spamBaseBtn.TextColor3 = Theme.TextPrimary
                    ShowNotification("SPAM OWNER", "Admin command not ready")
                    return
                end

                for _, cmd in ipairs(cmds) do
                    local success, result = pcall(function()
                        return adminFunc(targetPlayer, cmd)
                    end)
                    if success and result then
                        cmdCount = cmdCount + 1
                    end
                    task.wait(0.15)
                end

                task.wait(0.2)
                spamBaseBtn.BackgroundColor3 = Theme.SurfaceHighlight
                spamBaseBtn.TextColor3 = Theme.TextPrimary
                ShowNotification("SPAM OWNER", "Sent " .. cmdCount .. " commands to " .. targetPlayer.DisplayName)
            end)
        end)
    end

    -- createAdminToolsPanel is now a no-op stub; tools are embedded in the main panel above
    createAdminToolsPanel()

    local ADMIN_PANEL_WIDTH = 380 * mobileScale
    local ADMIN_PANEL_MAX_HEIGHT = 420 * mobileScale
    local ADMIN_PANEL_MIN_HEIGHT = 120 * mobileScale
    local ADMIN_PANEL_BOTTOM_GAP = 12
    local ADMIN_LIST_BOTTOM_PAD = 14
    local ADMIN_LIST_TOP_OFFSET = 108  -- header(40) + proxCont(44) + gap(24)

    frame.Size = UDim2.new(0, ADMIN_PANEL_WIDTH, 0, ADMIN_PANEL_MAX_HEIGHT)

    local listFrame = Instance.new("ScrollingFrame", frame)
    listFrame.Size = UDim2.new(1, -20, 1, -(ADMIN_LIST_TOP_OFFSET + ADMIN_PANEL_BOTTOM_GAP))
    listFrame.Position = UDim2.new(0, 10, 0, ADMIN_LIST_TOP_OFFSET)
    listFrame.BackgroundTransparency = 1
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    listFrame.ScrollBarThickness = 5
    listFrame.ScrollBarImageColor3 = Theme.Accent1
    local listPad = Instance.new("UIPadding", listFrame)
    listPad.PaddingBottom = UDim.new(0, ADMIN_LIST_BOTTOM_PAD)
    local layout = Instance.new("UIListLayout", listFrame)
    layout.Padding = UDim.new(0, 10); layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function updateAdminPanelSize()
        task.defer(function()
            if not frame or not frame.Parent then return end
            local sc = frame:FindFirstChild("XiUIScale")
            local scale = (sc and sc:IsA("UIScale") and sc.Scale) or 1
            if scale <= 0 then scale = 1 end
            local contentY = layout.AbsoluteContentSize.Y
            local desiredScaledH = contentY + ADMIN_PANEL_BOTTOM_GAP
            local desiredUnscaledH = desiredScaledH / scale
            local desiredH = math.clamp(desiredUnscaledH, ADMIN_PANEL_MIN_HEIGHT, ADMIN_PANEL_MAX_HEIGHT)
            frame.Size = UDim2.new(0, ADMIN_PANEL_WIDTH, 0, desiredH)
        end)
    end

    do
        local sc = frame:FindFirstChild("XiUIScale")
        if sc and sc:IsA("UIScale") then
            sc:GetPropertyChangedSignal("Scale"):Connect(updateAdminPanelSize)
        end
    end

    local function getAdminPanelSortKey(plr)
        if not plr or not plr.Parent then return 3, 9999, "" end
        local stealing = plr:GetAttribute("Stealing")
        local brainrotName = plr:GetAttribute("StealingIndex")
        if not stealing then
            return 3, 9999, plr.Name or ""
        end
        if brainrotName then
            for i, pName in ipairs(PRIORITY_LIST) do
                if pName == brainrotName then
                    return 1, i, plr.Name or ""
                end
            end
            return 2, 9999, plr.Name or ""
        end
        return 2, 9999, plr.Name or ""
    end

    local function sortAdminPanelList()
        local rows = {}
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "" then
                local plr = Players:FindFirstChild(child.Name)
                if plr then
                    table.insert(rows, {row = child, plr = plr})
                end
            end
        end
        table.sort(rows, function(a, b)
            local t1, p1, n1 = getAdminPanelSortKey(a.plr)
            local t2, p2, n2 = getAdminPanelSortKey(b.plr)
            if t1 ~= t2 then return t1 < t2 end
            if p1 ~= p2 then return p1 < p2 end
            return (n1 or "") < (n2 or "")
        end)
        for i, entry in ipairs(rows) do
            entry.row.LayoutOrder = i
        end
    end

    local function fireClick(button)
        if button then
            if firesignal then
                firesignal(button.MouseButton1Click); firesignal(button.MouseButton1Down); firesignal(button.Activated)
            else
                local x = button.AbsolutePosition.X + (button.AbsoluteSize.X / 2)
                local y = button.AbsolutePosition.Y + (button.AbsoluteSize.Y / 2) + 58
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
            end
        end
    end
    _G.fireClick = fireClick

    local function runAdminCommand(targetPlayer, commandName)
        local realAdminGui = PlayerGui:WaitForChild("AdminPanel", 5)
        if not realAdminGui then return false end
        local contentScroll = realAdminGui.AdminPanel:WaitForChild("Content"):WaitForChild("ScrollingFrame")
        local cmdBtn = contentScroll:FindFirstChild(commandName)
        if not cmdBtn then return false end
        fireClick(cmdBtn)
        task.wait(0.05)
        local profilesScroll = realAdminGui:WaitForChild("AdminPanel"):WaitForChild("Profiles"):WaitForChild("ScrollingFrame")
        local playerBtn = profilesScroll:FindFirstChild(targetPlayer.Name)
        if not playerBtn then return false end
        fireClick(playerBtn)
        return true
    end
    
    _G.runAdminCommand = runAdminCommand

local ALL_COMMANDS = {
    "balloon", "inverse", "jail", "jumpscare", "morph", 
    "nightvision", "ragdoll", "rocket", "tiny"
}

local isOnCooldown

isOnCooldown = function(cmd)
    local adminGui = PlayerGui:FindFirstChild("AdminPanel")
    if adminGui then
        local content = adminGui:FindFirstChild("AdminPanel")
        if content then
            local scrollFrame = content:FindFirstChild("Content")
            if scrollFrame then
                local scrollingFrame = scrollFrame:FindFirstChild("ScrollingFrame")
                if scrollingFrame then
                    local cmdButton = scrollingFrame:FindFirstChild(cmd)
                    if cmdButton then
                        local timerLabel = cmdButton:FindFirstChild("Timer")
                        if timerLabel then
                            return timerLabel.Visible
                        end
                    end
                end
            end
        end
    end
    
    if not activeCooldowns[cmd] then return false end
    return (tick() - activeCooldowns[cmd]) < (COOLDOWNS[cmd] or 0)
end

    local function setGlobalVisualCooldown(cmd)
        if SharedState.AdminButtonCache[cmd] then
            for _, b in ipairs(SharedState.AdminButtonCache[cmd]) do
                if b and b.Parent then
                    b.BackgroundColor3 = Theme.Error
                    task.delay(COOLDOWNS[cmd] or 5, function()
                        if b and b.Parent then
                            local hasBallooned = (cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                            b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                        end
                    end)
                end
            end
        end
    end

    local function updateBalloonButtons()
        local hasBallooned = false
        for _, _ in pairs(SharedState.BalloonedPlayers) do
            hasBallooned = true
            break
        end
        if SharedState.AdminButtonCache and SharedState.AdminButtonCache["balloon"] then
            for _, b in ipairs(SharedState.AdminButtonCache["balloon"]) do
                if b and b.Parent then
                    b.BackgroundColor3 = hasBallooned and Theme.Error or Theme.SurfaceHighlight
                end
            end
        end
    end

    local function triggerAll(plr)
        local count = 0
        for _, cmd in ipairs(ALL_COMMANDS) do
            if not isOnCooldown(cmd) then
                task.delay(count * 0.1, function()
                    if runAdminCommand(plr, cmd) then
                        activeCooldowns[cmd] = tick()
                        setGlobalVisualCooldown(cmd)
                        if cmd == "balloon" then
                            SharedState.BalloonedPlayers[plr.UserId] = true
                            updateBalloonButtons()
                        end
                    end
                end)
                count = count + 1
            end
        end
    end

    local proxViz = nil
    RunService.Heartbeat:Connect(function()
        if ProximityAPActive then
            if not proxViz then
                proxViz = Instance.new("Part")
                proxViz.Name = "XiProxViz"
                proxViz.Anchored = true
                proxViz.CanCollide = false
                proxViz.Shape = Enum.PartType.Cylinder
                proxViz.Color = Theme.Accent1
                proxViz.Transparency = 0.6
                proxViz.CastShadow = false
                proxViz.Parent = Workspace
            end
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                proxViz.Size = Vector3.new(0.5, Config.ProximityRange * 2, Config.ProximityRange * 2)
                proxViz.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) + Vector3.new(0, -2.5, 0)
            end
        else
            if proxViz then
                proxViz:Destroy()
                proxViz = nil
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.2)
            if ProximityAPActive then
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (p.Character.HumanoidRootPart.Position - myChar.HumanoidRootPart.Position).Magnitude
                            if dist <= Config.ProximityRange then
                                local hasAnyAvailable = false
                                for _, cmd in ipairs(ALL_COMMANDS) do
                                    if not isOnCooldown(cmd) then
                                        hasAnyAvailable = true
                                        break
                                    end
                                end
                                if hasAnyAvailable then
                                    triggerAll(p)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local function createPlayerRow(plr)
        local row = Instance.new("TextButton") 
        row.Name = plr.Name
        row.LayoutOrder = 0
        row.Size = UDim2.new(1, 0, 0, 60)
        row.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        row.BackgroundTransparency = 0.5
        row.BorderSizePixel = 0
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = listFrame
        
        local separator = Instance.new("Frame", row)
        separator.Size = UDim2.new(1, -20, 0, 1)
        separator.Position = UDim2.new(0, 10, 1, -1)
        separator.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        separator.BackgroundTransparency = 0.5
        separator.BorderSizePixel = 0

        local headshot = Instance.new("ImageLabel", row)
        headshot.Size = UDim2.new(0, 40, 0, 40)
        headshot.Position = UDim2.new(0, 10, 0.5, -20)
        headshot.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        headshot.Image = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
        Instance.new("UICorner", headshot).CornerRadius = UDim.new(1, 0)
        
        local dName = Instance.new("TextLabel", row)
        dName.Size = UDim2.new(1, - (60 + 242 + 14), 0, 20)
        dName.Position = UDim2.new(0, 60, 0.5, -18)
        dName.BackgroundTransparency = 1
        dName.Text = plr.DisplayName
        dName.Font = Enum.Font.GothamBold
        dName.TextSize = 16
        dName.TextColor3 = Color3.new(1, 1, 1)
        dName.TextXAlignment = Enum.TextXAlignment.Left
        dName.TextTruncate = Enum.TextTruncate.AtEnd

        local uName = Instance.new("TextLabel", row)
        uName.Size = UDim2.new(1, - (60 + 242 + 14), 0, 16)
        uName.Position = UDim2.new(0, 60, 0.5, 4)
        uName.BackgroundTransparency = 1
        uName.Text = "@" .. plr.Name
        uName.Font = Enum.Font.GothamBold
        uName.TextSize = 12
        uName.TextColor3 = Color3.fromRGB(200, 200, 200)
        uName.TextXAlignment = Enum.TextXAlignment.Left
        uName.TextTruncate = Enum.TextTruncate.AtEnd

        local function updateStatus()
            if not plr or not plr.Parent or not Players:FindFirstChild(plr.Name) then
                return
            end
            local stealing = plr:GetAttribute("Stealing")
            local nearestBrainrotName = plr:GetAttribute("StealingIndex")
            
            if stealing then
                uName.Text = "STEALING:" .. tostring(nearestBrainrotName or "UNKNOWN")
                uName.TextColor3 = Color3.fromRGB(255, 0, 0)
                dName.TextColor3 = Color3.fromRGB(255, 0, 0)
            else
                uName.Text = "@" .. plr.Name
                uName.TextColor3 = Color3.fromRGB(200, 200, 200)
                dName.TextColor3 = Color3.new(1, 1, 1)
            end
        end

        task.spawn(function()
            while row and row.Parent do
                updateStatus()
                task.wait(1)
            end
        end)

        local btnCont = Instance.new("Frame", row)
        btnCont.Size = UDim2.new(0, 242, 1, 0)
        btnCont.AnchorPoint = Vector2.new(1, 0)
        btnCont.Position = UDim2.new(1, -6, 0, 0)
        btnCont.BackgroundTransparency = 1
        btnCont.ZIndex = 15

        local buttonsDef = {
            {icon = "🤸", cmd = "ragdoll"},
            {icon = "🔒", cmd = "jail"},
            {icon = "🚀", cmd = "rocket"},
            {icon = "🧬", cmd = "morph"},
            {icon = "🎈", cmd = "balloon"}
        }

        for i, def in ipairs(buttonsDef) do
            local b = Instance.new("TextButton", btnCont)
            b.Size = UDim2.new(0, 46, 0, 46)
            b.Position = UDim2.new(0, 2 + (i-1)*49, 0.5, -23)
            b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            b.BackgroundTransparency = 1
            b.Text = def.icon
            b.TextSize = 24
            b.Font = Enum.Font.GothamBlack
            b.TextColor3 = Color3.new(1, 1, 1)
            b.ZIndex = 20
            
            local bCorner = Instance.new("UICorner", b)
            bCorner.CornerRadius = UDim.new(0, 8)
            
            local bStroke = Instance.new("UIStroke", b)
            bStroke.Color = Color3.new(1, 1, 1)
            bStroke.Thickness = 1.5
            bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            bStroke.Enabled = false
            
            local function updateBtnVisual()
                local cd = isOnCooldown(def.cmd)
                local balloon = (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                
                if cd or balloon then
                    b.TextTransparency = 0
                    b.TextColor3 = Color3.fromRGB(255, 0, 0)
                    b.BackgroundTransparency = 0.6
                    b.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
                else
                    b.TextTransparency = 0
                    b.TextColor3 = Color3.new(1, 1, 1)
                    b.BackgroundTransparency = 1
                    b.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                end
            end

            b.MouseEnter:Connect(function()
                bStroke.Enabled = true
                bStroke.Transparency = 0.4
            end)
            
            b.MouseLeave:Connect(function()
                bStroke.Enabled = false
            end)

            b.MouseButton1Click:Connect(function()
                local adminFunc = _G.runAdminCommand
                if not adminFunc then return end
                local cd = isOnCooldown(def.cmd)
                local balloon = (def.cmd == "balloon" and SharedState.BalloonedPlayers and next(SharedState.BalloonedPlayers) ~= nil)
                if cd or balloon then return end
                if adminFunc(plr, def.cmd) then
                    activeCooldowns[def.cmd] = tick()
                    setGlobalVisualCooldown(def.cmd)
                    if def.cmd == "balloon" then
                        SharedState.BalloonedPlayers[plr.UserId] = true
                        updateBalloonButtons()
                    end
                end
            end)

            task.spawn(function()
                while b and b.Parent do
                    updateBtnVisual()
                    task.wait(0.1)
                end
            end)
            
            if not SharedState.AdminButtonCache[def.cmd] then SharedState.AdminButtonCache[def.cmd] = {} end
            table.insert(SharedState.AdminButtonCache[def.cmd], b)
        end

        row.MouseEnter:Connect(function()
            row.BackgroundTransparency = 0.2
        end)
        row.MouseLeave:Connect(function()
            row.BackgroundTransparency = 0.5
        end)
        row.MouseButton1Click:Connect(function()
            local adminFunc = _G.runAdminCommand
            if not adminFunc then return end
            triggerAll(plr)
        end)
        return row
    end

    local playerRows = {}
    local playerRowsByUserId = {}
    local isAdminPanelRefreshing = false

    local function dedupeRowsForPlayer(plr)
        local keep = nil
        for _, child in ipairs(listFrame:GetChildren()) do
            if child:IsA("TextButton") and child.Name == plr.Name then
                if not keep then
                    keep = child
                else
                    child:Destroy()
                end
            end
        end
        return keep
    end
    
    local function addPlayer(plr)
        if isAdminPanelRefreshing then return end
        if plr == LocalPlayer then return end
        local existing = playerRowsByUserId[plr.UserId]
        if existing then
            if existing.row and existing.row.Parent then return end
            playerRowsByUserId[plr.UserId] = nil
        end
        if not Players:FindFirstChild(plr.Name) then return end
        
        local existingRow = playerRows[plr]
        if existingRow and existingRow.Parent then return end
        playerRows[plr] = nil

        local adopted = dedupeRowsForPlayer(plr)
        if adopted then
            playerRows[plr] = adopted
            playerRowsByUserId[plr.UserId] = {player = plr, row = adopted}
            listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + ADMIN_LIST_BOTTOM_PAD)
            sortAdminPanelList()
            updateAdminPanelSize()
            return
        end
        
        local row = createPlayerRow(plr)
        playerRows[plr] = row
        playerRowsByUserId[plr.UserId] = {player = plr, row = row}
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + ADMIN_LIST_BOTTOM_PAD)
        sortAdminPanelList()
        updateAdminPanelSize()
    end
    
    local function removePlayer(plr)
        local userId = plr and plr.UserId or nil
        local entry = userId and playerRowsByUserId[userId] or nil
        local row = entry and entry.row or playerRows[plr]
        
        if row then
            if row.Parent then
                for cmd, buttons in pairs(SharedState.AdminButtonCache) do
                    for i = #buttons, 1, -1 do
                        if buttons[i] and buttons[i].Parent == row then
                            table.remove(buttons, i)
                        end
                    end
                end
                row:Destroy()
            end
            if plr then
                playerRows[plr] = nil
            end
            if userId then
                playerRowsByUserId[userId] = nil
            end
            if SharedState.BalloonedPlayers and userId then
                SharedState.BalloonedPlayers[userId] = nil
            end
            if plr and plr.Name then
                dedupeRowsForPlayer(plr)
            end
            listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + ADMIN_LIST_BOTTOM_PAD)
            updateAdminPanelSize()
        end
    end

    local function fullRefreshAdminPanel(showToast)
        if isAdminPanelRefreshing then return end
        isAdminPanelRefreshing = true
        local ok = pcall(function()
            for _, child in ipairs(listFrame:GetChildren()) do
                if child:IsA("GuiObject") then
                    child:Destroy()
                end
            end

            playerRows = {}
            playerRowsByUserId = {}
            SharedState.AdminButtonCache = {}
            SharedState.BalloonedPlayers = {}

            task.wait(0.1)

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer then
                    addPlayer(p)
                end
            end
            sortAdminPanelList()

            if showToast then
                ShowNotification("ADMIN PANEL", "Updated")
            end
        end)
        isAdminPanelRefreshing = false
        if not ok then
            isAdminPanelRefreshing = false
        end
    end

    refreshBtn.MouseButton1Click:Connect(function()
        pcall(fullRefreshAdminPanel, true)
    end)

    task.spawn(function()
        while listFrame and listFrame.Parent do
            task.wait(20)
            pcall(fullRefreshAdminPanel, false)
        end
    end)

    Players.PlayerAdded:Connect(function(plr)
        task.wait(0.1)
        if plr and plr.Parent then
            addPlayer(plr)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(plr)
        removePlayer(plr)
    end)
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then addPlayer(p) end
    end
    sortAdminPanelList()
    updateAdminPanelSize()

    task.spawn(function()
        while listFrame and listFrame.Parent do
            task.wait(0.5)
            pcall(sortAdminPanelList)
        end
    end)
    
    task.spawn(function()
        while true do
            task.wait(1)
            if isAdminPanelRefreshing then continue end
            local currentPlayerIds = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Parent then
                    currentPlayerIds[p.UserId] = true
                end
            end
            
            for userId, entry in pairs(playerRowsByUserId) do
                if not currentPlayerIds[userId] or not entry.player or not entry.player.Parent or not Players:FindFirstChild(entry.player.Name) then
                    removePlayer(entry.player)
                end
            end
            
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Parent and not playerRowsByUserId[p.UserId] then
                    addPlayer(p)
                end
            end
        end
    end)
    
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        listFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + ADMIN_LIST_BOTTOM_PAD)
        updateAdminPanelSize()
    end)
end)

local BASES_LOW = {
    [1] = Vector3.new(-460, -6, 219), [5] = Vector3.new(-355, -6, 217),
    [2] = Vector3.new(-460, -6, 111), [6] = Vector3.new(-355, -6, 113),
    [3] = Vector3.new(-460, -6, 5),   [7] = Vector3.new(-355, -6, 5),
    [4] = Vector3.new(-460, -6, -100),[8] = Vector3.new(-355, -6, -100) 
}

local BASES_HIGH = {
    [1] = Vector3.new(-476.474853515625, 20.732906341552734, 220.94090270996094), [5] = Vector3.new(-342.5367126464844, 20.69801902770996, 221.44737243652344),
    [2] = Vector3.new(-476.5684814453125, 20.70664405822754, 113.77315521240234), [6] = Vector3.new(-342.8604736328125, 20.669641494750977, 113.41409301757812),
    [3] = Vector3.new(-476.8675842285156, 20.74148178100586, 6.178487777709961),  [7] = Vector3.new(-342.42108154296875, 20.687667846679688, 6.249461650848389),
    [4] = Vector3.new(-476.6324768066406, 20.744949340820312, -101.07275390625), [8] = Vector3.new(-342.7937927246094, 20.748071670532227, -99.73458862304688)
}

local CLONE_POSITIONS_FLOOR = {
    Vector3.new(-476, -4, 221), Vector3.new(-476, -4, 114),
    Vector3.new(-476, -4, 7),   Vector3.new(-476, -4, -100),
    Vector3.new(-342, -4, -100),Vector3.new(-342, -4, 6),
    Vector3.new(-342, -4, 114), Vector3.new(-342, -4, 220)
}

local FACE_TARGETS = {
    Vector3.new(-519, -3, 221), Vector3.new(-519, -3, 114),
    Vector3.new(-518, -3, 7),   Vector3.new(-519, -3, -100),
    Vector3.new(-301, -3, -100),Vector3.new(-301, -3, 7),
    Vector3.new(-302, -3, 114), Vector3.new(-300, -3, 220)
}

local TeleportData = {
    bodyController = nil,
}
local bodyController = TeleportData.bodyController
local floatActive = State.floatActive
local FLOAT_RISE_SPEED = 60

RunService.Heartbeat:Connect(function(dt)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    if State.floatActive then
        -- Float up continuously, no locking
        hum.PlatformStand = true
        hrp.AssemblyLinearVelocity = Vector3.new(
            hrp.AssemblyLinearVelocity.X,
            FLOAT_RISE_SPEED,
            hrp.AssemblyLinearVelocity.Z
        )
    else
        -- Restore control
        if hum.PlatformStand then
            hum.PlatformStand = false
        end
    end
end)

local function getClosestBaseIdx(pos)
    local closest, dist = 1, math.huge
    for i, basePos in pairs(BASES_LOW) do
        local d = (Vector2.new(pos.X, pos.Z) - Vector2.new(basePos.X, basePos.Z)).Magnitude
        if d < dist then dist = d; closest = i end
    end
    return closest
end

local isTpMoving = State.isTpMoving

_G._isTargetPlotUnlocked = function(plotName)
    local ok, res = pcall(function()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return false end
        local targetPlot = plots:FindFirstChild(plotName)
        if not targetPlot then return false end
        local unlockFolder = targetPlot:FindFirstChild("Unlock")
        if not unlockFolder then return true end
        local unlockItems = {}
        for _, item in pairs(unlockFolder:GetChildren()) do
            local pos = nil
            if item:IsA("Model") then pcall(function() pos = item:GetPivot().Position end)
            elseif item:IsA("BasePart") then pos = item.Position end
            if pos then table.insert(unlockItems, {Object = item, Height = pos.Y}) end
        end
        table.sort(unlockItems, function(a, b) return a.Height < b.Height end)
        if #unlockItems == 0 then return true end
        local floor1Door = unlockItems[1].Object
        for _, desc in ipairs(floor1Door:GetDescendants()) do
            if desc:IsA("ProximityPrompt") and desc.Enabled then return false end
        end
        for _, child in ipairs(floor1Door:GetChildren()) do
            if child:IsA("ProximityPrompt") and child.Enabled then return false end
        end
        return true
    end)
    return ok and res or false
end

runAutoSnipe = function()
    if State.isTpMoving then return end
    
    if State.carpetSpeedEnabled then
        setCarpetSpeed(false)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = "OFF"
            _carpetStatusLabel.TextColor3 = Theme.Error
        end
    end

    local targetPetData = nil
    if Config.AutoTPPriority then
        local bestEntry = nil
        local cache = SharedState.AllAnimalsCache
        if cache and type(cache) == "table" then
            for _, pName in ipairs(PRIORITY_LIST) do
                local searchName = pName:lower()
                for _, a in ipairs(cache) do
                    if a and a.name and a.name:lower() == searchName and a.owner ~= LocalPlayer.Name then
                        bestEntry = a
                        break
                    end
                end
                if bestEntry then break end
            end
            if not bestEntry then
                for _, a in ipairs(cache) do
                    if a and a.owner ~= LocalPlayer.Name then
                        bestEntry = a
                        break
                    end
                end
            end
        end
        if bestEntry then
            targetPetData = bestEntry
        else
            if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
            targetPetData = SharedState.SelectedPetData.animalData
        end
    else
        if not SharedState.SelectedPetData then ShowNotification("ERROR","No target selected!"); return end
        targetPetData = SharedState.SelectedPetData.animalData
    end
    if not targetPetData then return end

    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not hrp or not hum or hum.Health <= 0 then return end
    
    State.isTpMoving = true
    isTpMoving = State.isTpMoving
    
    local targetPart = findAdorneeGlobal(targetPetData)
    if not targetPart then 
        State.isTpMoving = false
        isTpMoving = State.isTpMoving
        return 
    end
    
    local exactPos = targetPart.Position
    local carpetName = Config.TpSettings.Tool
    local carpet = LocalPlayer.Backpack:FindFirstChild(carpetName) or char:FindFirstChild(carpetName)
    local cloner = LocalPlayer.Backpack:FindFirstChild("Quantum Cloner") or char:FindFirstChild("Quantum Cloner")

    if carpet then hum:EquipTool(carpet) end
    task.wait(0.01)
    local isSecondFloor = exactPos.Y > 10
    local plotIndex = getClosestBaseIdx(exactPos)
    local targetBasePos = isSecondFloor and BASES_HIGH[plotIndex] or BASES_LOW[plotIndex]
    
    local minHeight = 50
    local targetHeight = math.max(targetBasePos.Y, minHeight)

    local jumpStart = tick()
    while hrp.Position.Y < targetHeight and (tick() - jumpStart) < 3 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 370, hrp.AssemblyLinearVelocity.Z)
        RunService.Heartbeat:Wait()
    end

    for i = 1, 10 do
        hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 10, hrp.AssemblyLinearVelocity.Z)
        if (hrp.Position - targetBasePos).Magnitude > 3 then
            hrp.CFrame = CFrame.new(targetBasePos)
            task.wait(0.05)
        end
    end

    if not isSecondFloor then
        local bestSpot = CLONE_POSITIONS_FLOOR[1]
        local minDst = math.huge
        for _, v in ipairs(CLONE_POSITIONS_FLOOR) do
            local d = (targetPart.Position - v).Magnitude
            if d < minDst then minDst = d; bestSpot = v end
        end
        for i = 1, 6 do
            if (hrp.Position - bestSpot).Magnitude > 3 then
                hrp.CFrame = CFrame.new(bestSpot)
                task.wait(0.05)
            end
        end
    end

    local bestFace = FACE_TARGETS[1]
    local minFaceDist = math.huge
    for _, v in ipairs(FACE_TARGETS) do
        local d = (hrp.Position - v).Magnitude
        if d < minFaceDist then
            minFaceDist = d
            bestFace = v
        end
    end

    task.wait(0.1)
    hrp.CFrame = CFrame.lookAt(hrp.Position, Vector3.new(bestFace.X, hrp.Position.Y, bestFace.Z))
    if isSecondFloor or not _G._isTargetPlotUnlocked(targetPetData.plot) then
        walkForward(0.3)
        task.wait(0.3)
        instantClone()
        while _G.isCloning do task.wait() end
    end
    task.wait(0.15)

    if carpet then hum:EquipTool(carpet) end

    local verticalDiff = targetPart.Position.Y - hrp.Position.Y

    if verticalDiff > 2 then
        local airPos = Vector3.new(targetPart.Position.X, targetPart.Position.Y - 5, targetPart.Position.Z)
        
        local plat = Instance.new("Part")
        plat.Name = "XiTempPlatform"
        plat.Size = Vector3.new(3, 1, 3)
        plat.Position = airPos - Vector3.new(0, 5, 0)
        plat.Color = Color3.new(1, 0, 0)
        plat.Material = Enum.Material.Neon
        plat.Anchored = true
        plat.CanCollide = true
        plat.Transparency = 0.3
        plat.Parent = Workspace
        
        RunService.Heartbeat:Wait()
        
        for i = 1, 10 do
            if not LocalPlayer:GetAttribute("Stealing") then
                hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 10, hrp.AssemblyLinearVelocity.Z)
                hrp.CFrame = CFrame.new(airPos)
                task.wait(0.05)
            end
        end
        
        task.spawn(function()
            local start = tick()
            while tick() - start < 20 do
                if LocalPlayer:GetAttribute("Stealing") then break end
                task.wait(0.1)
            end
            plat:Destroy()
        end)
    else
        for i = 1, 10 do
            if LocalPlayer:GetAttribute("Stealing") then break end
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 10, hrp.AssemblyLinearVelocity.Z)
            if (hrp.Position - targetPart.Position).Magnitude > 3 then
                hrp.CFrame = CFrame.new(targetPart.Position)
                task.wait(0.05)
            end
            task.wait(0.05)
        end
    end
    
    State.isTpMoving = false
    isTpMoving = State.isTpMoving
end

local function executeReset()
    local character = LocalPlayer.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if rootPart and humanoid then
        local toolName = Config.TpSettings.Tool
        local flying = LocalPlayer.Backpack:FindFirstChild(toolName) or character:FindFirstChild(toolName)
        if flying then humanoid:EquipTool(flying) end
                
        rootPart.CFrame = CFrame.new(0, 15000, 0)
    end
end

task.spawn(function()
    local balloonPhrase = 'ran "balloon" on you'
    while true do
        task.wait(1)
        if not Config.AutoResetOnBalloon then continue end
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text
            if txt and string.find(txt, balloonPhrase) then
                executeReset()
                break
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.1)
        if not Config.AutoKickOnSteal then continue end
        for _, gui in ipairs(PlayerGui:GetDescendants()) do
            local txt = (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text
            if txt and string.find(txt, "You stole") then
                kickSelf()
                return
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    local tpKey = Enum.KeyCode[Config.TpSettings.TpKey] or Enum.KeyCode.T
    local cloneKey = Enum.KeyCode[Config.TpSettings.CloneKey] or Enum.KeyCode.F

    if input.KeyCode == tpKey then
        runAutoSnipe()
    end

    if input.KeyCode == cloneKey then
        instantClone()
    end

    -- V keybind: Spam Base Owner
    if input.KeyCode == Enum.KeyCode.V then
        if SharedState.SpamBaseOwner then task.spawn(SharedState.SpamBaseOwner) end
    end
    
    if input.KeyCode == (Enum.KeyCode[Config.TpSettings.CarpetSpeedKey] or Enum.KeyCode.Q) then
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
        if _carpetStatusLabel then
            _carpetStatusLabel.Text = carpetSpeedEnabled and "ON" or "OFF"
            _carpetStatusLabel.TextColor3 = carpetSpeedEnabled and Theme.Success or Theme.Error
        end
        ShowNotification("CARPET SPEED", carpetSpeedEnabled and ("ON  |  "..Config.TpSettings.Tool.."  |  150") or "OFF")
    end

    if input.KeyCode == (Enum.KeyCode[Config.StealSpeedKey] or Enum.KeyCode.Z) then
        if SharedState.StealSpeedToggleFunc then
            SharedState.StealSpeedToggleFunc()
        end
    end

    if input.KeyCode == (Enum.KeyCode[Config.ResetKey] or Enum.KeyCode.X) then
        executeReset()
    end
    
    if input.KeyCode == (Enum.KeyCode[Config.RagdollSelfKey] or Enum.KeyCode.R) then
        task.spawn(function()
            if _G.runAdminCommand then
                if _G.runAdminCommand(LocalPlayer, "ragdoll") then
                    ShowNotification("RAGDOLL SELF", "Triggered")
                else
                    ShowNotification("RAGDOLL SELF", "Failed")
                end
            else
                ShowNotification("RAGDOLL SELF", "Function not available")
            end
        end)
    end

    if input.KeyCode == (Enum.KeyCode[Config.ProximityAPKeybind] or Enum.KeyCode.P) then
        if SharedState.ToggleProximityAP then
            SharedState.ToggleProximityAP()
        end
    end

end)

do
    local actionsGui = Instance.new("ScreenGui")
    actionsGui.Name = "XiActionsPanel"
    actionsGui.ResetOnSpawn = false
    actionsGui.Enabled = not Config.HideActionsPanel
    actionsGui.Parent = PlayerGui

    local actionsFrame = Instance.new("Frame", actionsGui)
    actionsFrame.Name = "Frame"
    local actionsMobileScale = IS_MOBILE and 0.8 or 1
    actionsFrame.Size = UDim2.new(0, 240*actionsMobileScale, 0, 340*actionsMobileScale)
    local actionsPos = (Config.Positions and Config.Positions.ActionsPanel) or DefaultConfig.Positions.ActionsPanel
    actionsFrame.Position = UDim2.new(actionsPos.X, 0, actionsPos.Y, 0)
    actionsFrame.BackgroundColor3 = Theme.Background
    actionsFrame.BackgroundTransparency = 0.35
    actionsFrame.BorderSizePixel = 0
    actionsFrame.ClipsDescendants = true

    ApplyViewportUIScale(actionsFrame, 240, 340, 0.55, 0.9)
    Instance.new("UICorner", actionsFrame).CornerRadius = UDim.new(0, 12)
    local actionsStroke = Instance.new("UIStroke", actionsFrame)
    actionsStroke.Color = Theme.Accent1
    actionsStroke.Thickness = 2
    actionsStroke.Transparency = 0
    AddGlowBorderAnimation(actionsFrame, actionsStroke)
    AddStarryBackground(actionsFrame)

    local actionsHeader = Instance.new("Frame", actionsFrame)
    actionsHeader.Size = UDim2.new(1, 0, 0, 56)
    actionsHeader.BackgroundTransparency = 1
    MakeDraggable(actionsHeader, actionsFrame, "ActionsPanel")

    local actionsTitle = Instance.new("TextLabel", actionsHeader)
    actionsTitle.Size = UDim2.new(1, -20, 0, 22)
    actionsTitle.Position = UDim2.new(0, 12, 0, 6)
    actionsTitle.BackgroundTransparency = 1
    actionsTitle.Text = "DTZ HUB MOGS"
    actionsTitle.Font = Enum.Font.GothamBlack
    actionsTitle.TextSize = 13
    actionsTitle.TextColor3 = Theme.TextPrimary
    actionsTitle.TextXAlignment = Enum.TextXAlignment.Left

    local actionsCredit = Instance.new("TextLabel", actionsHeader)
    actionsCredit.Size = UDim2.new(1, -20, 0, 14)
    actionsCredit.Position = UDim2.new(0, 12, 0, 22)
    actionsCredit.BackgroundTransparency = 1
    actionsCredit.Text = "YoDtz"
    actionsCredit.Font = Enum.Font.GothamBold
    actionsCredit.TextSize = 11
    actionsCredit.TextColor3 = Theme.Accent1
    actionsCredit.TextTransparency = 0.05
    actionsCredit.TextXAlignment = Enum.TextXAlignment.Left

    local actionsSub = Instance.new("TextLabel", actionsHeader)
    actionsSub.Size = UDim2.new(1, -20, 0, 18)
    actionsSub.Position = UDim2.new(0, 12, 0, 36)
    actionsSub.BackgroundTransparency = 1
    actionsSub.Text = "/ Actions"
    actionsSub.Font = Enum.Font.GothamMedium
    actionsSub.TextSize = 9
    actionsSub.TextColor3 = Theme.TextSecondary
    actionsSub.TextXAlignment = Enum.TextXAlignment.Left

    local content = Instance.new("Frame", actionsFrame)
    content.Size = UDim2.new(1, -16, 1, -66)
    content.Position = UDim2.new(0, 8, 0, 60)
    content.BackgroundTransparency = 1

    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0, 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    local function safeKeyCode(name, fallback)
        local out = nil
        if type(name) == "string" and name ~= "" then
            pcall(function()
                out = Enum.KeyCode[name]
            end)
        end
        return out or fallback or Enum.KeyCode.Unknown
    end

    local tpKey = safeKeyCode(Config.TpSettings and Config.TpSettings.TpKey, Enum.KeyCode.Z)
    local ragKey = safeKeyCode(Config.RagdollSelfKey, Enum.KeyCode.R)
    local resetKey = safeKeyCode(Config.ResetKey, Enum.KeyCode.X)
    local kickKey = safeKeyCode(Config.KickHotkey, Enum.KeyCode.Y)
    local ProximityAPKeybind = safeKeyCode(Config.ProximityKey, Enum.KeyCode.P)
    local function makeActionButton(text, backgroundColor3, textColor3)
        local btn = Instance.new("TextButton", content)
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = backgroundColor3 or Theme.SurfaceHighlight
        btn.BackgroundTransparency = 0.25
        btn.BorderSizePixel = 0
        btn.Text = text
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.TextColor3 = textColor3 or Theme.TextPrimary
        btn.AutoButtonColor = false
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        return btn
    end

    local tpBtn = makeActionButton("Teleport ("..tpKey.Name..")")
    local ragBtn = makeActionButton("Ragdoll Self ("..ragKey.Name..")")
    local rejoinBtn = makeActionButton("Rejoin")
    local kickBtn = makeActionButton("Kick ("..kickKey.Name..")")
    local resetBtn = makeActionButton("Reset ("..resetKey.Name..")", Theme.Error, Theme.TextPrimary)
    local settingsBtn = makeActionButton("⚙ Settings", Theme.Accent1, Color3.new(0, 0, 0))

    tpBtn.MouseButton1Click:Connect(function()
        pcall(runAutoSnipe)
    end)

    ragBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            if _G.runAdminCommand then
                local ok = _G.runAdminCommand(LocalPlayer, "ragdoll")
                ShowNotification("RAGDOLL SELF", ok and "Triggered" or "Failed")
            else
                ShowNotification("RAGDOLL SELF", "Function not available")
            end
        end)
    end)

    rejoinBtn.MouseButton1Click:Connect(function()
        rejoinBtn.Text = "Rejoining..."
        task.spawn(function()
            local ts = game:GetService("TeleportService")
            local pl = game:GetService("Players").LocalPlayer
            local ok = pcall(function()
                if #game:GetService("Players"):GetPlayers() <= 1 then
                    ts:Teleport(game.PlaceId, pl)
                else
                    ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, pl)
                end
            end)
            if not ok then
                rejoinBtn.Text = "Rejoin"
            end
        end)
    end)

    kickBtn.MouseButton1Click:Connect(function()
        kickSelf()
    end)

    resetBtn.MouseButton1Click:Connect(function()
        pcall(executeReset)
    end)

    settingsBtn.MouseButton1Click:Connect(function()
        task.spawn(function()
            local sg = PlayerGui:WaitForChild("SettingsUI", 5)
            if sg then
                sg.Enabled = not sg.Enabled
            end
        end)
    end)
end

local settingsGui = UI.settingsGui

if IS_MOBILE then
    local mobileGui = Instance.new("ScreenGui")
    mobileGui.Name = "XiMobileControls"
    mobileGui.ResetOnSpawn = false
    mobileGui.Parent = PlayerGui

    local controlsFrame = Instance.new("Frame")
    controlsFrame.Size = UDim2.new(0, 50, 0, 260)
    controlsFrame.Position = UDim2.new(1, -60, 0.5, -130)
    controlsFrame.BackgroundColor3 = Theme.Background
    controlsFrame.BackgroundTransparency = 0.2
    controlsFrame.BorderSizePixel = 0
    controlsFrame.Parent = mobileGui

    ApplyViewportUIScale(controlsFrame, 50, 260, 0.6, 1)

    Instance.new("UICorner", controlsFrame).CornerRadius = UDim.new(0, 8)
    local cStroke = Instance.new("UIStroke", controlsFrame)
    cStroke.Color = Theme.Accent1
    cStroke.Thickness = 2
    cStroke.Transparency = 0
    AddGlowBorderAnimation(controlsFrame, cStroke)
    AddStarryBackground(controlsFrame)

    MakeDraggable(controlsFrame, controlsFrame, "MobileControls")

    local layout = Instance.new("UIListLayout", controlsFrame)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 0)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center

    local function createMobBtn(text, color, layoutOrder, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 40, 0, 40)
        btn.BackgroundColor3 = Theme.SurfaceHighlight
        btn.Text = text
        btn.TextColor3 = Theme.TextPrimary
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 14
        btn.LayoutOrder = layoutOrder
        btn.Parent = mobileGui 
        
        local posKey = "MobileBtn_" .. text
        if Config.Positions[posKey] then
            btn.Position = UDim2.new(Config.Positions[posKey].X, 0, Config.Positions[posKey].Y, 0)
        else
            local angle = (layoutOrder - 1) * (math.pi * 2 / 5) - math.pi/2
            local radius = 60
            btn.Position = UDim2.new(0.5, math.cos(angle) * radius - 20, 0.5, math.sin(angle) * radius - 20)
        end

        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = color
        stroke.Thickness = 1
        stroke.Transparency = 1

        MakeDraggable(btn, btn, "MobileBtn_" .. text)

        btn.MouseButton1Click:Connect(function()
            local oldColor = btn.BackgroundColor3
            local oldTextColor = btn.TextColor3
            btn.BackgroundColor3 = color
            btn.TextColor3 = Color3.new(0,0,0)
            task.delay(0.1, function() 
                btn.BackgroundColor3 = oldColor 
                btn.TextColor3 = oldTextColor
            end)
            callback(btn)
        end)
        return btn
    end

    createMobBtn("TP", Theme.Accent1, 1, function()
        
        if SharedState.ForcePrioritySelection then
            SharedState.ForcePrioritySelection()
            task.wait(0.1) 
        end
        runAutoSnipe()
        ShowNotification("MOBILE", "Teleporting...")
    end)

    createMobBtn("CL", Theme.Accent1, 2, function()
        instantClone()
        ShowNotification("MOBILE", "Cloning...")
    end)

    createMobBtn("SP", Theme.Success, 3, function(self)
        carpetSpeedEnabled = not carpetSpeedEnabled
        setCarpetSpeed(carpetSpeedEnabled)
        self.TextColor3 = carpetSpeedEnabled and Theme.Success or Theme.TextPrimary
        ShowNotification("MOBILE", carpetSpeedEnabled and "Speed ON" or "Speed OFF")
    end)

    createMobBtn("IV", Color3.fromRGB(255, 50, 50), 4, function(self)
        if _G.toggleInvisibleSteal then
            _G.toggleInvisibleSteal()
            task.delay(0.1, function()
                local isOn = _G.invisibleStealEnabled
                self.TextColor3 = isOn and Color3.fromRGB(255, 0, 0) or Theme.TextPrimary
                ShowNotification("MOBILE", isOn and "Invis ON" or "Invis OFF")
            end)
        end
    end)

    createMobBtn("UI", Color3.fromRGB(255, 255, 255), 5, function()
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = not asUI.Enabled end

        local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
        if adUI then adUI.Enabled = not adUI.Enabled end
    end)

    local resetBtn = Instance.new("TextButton")
    resetBtn.Name = "MobileResetButton"
    resetBtn.Size = UDim2.new(0, 42, 0, 42)
    resetBtn.Position = UDim2.new(1, -58, 1, -105)
    resetBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    resetBtn.AutoButtonColor = false
    resetBtn.Text = "🔧"
    resetBtn.Font = Enum.Font.GothamBlack
    resetBtn.TextSize = 20
    resetBtn.TextColor3 = Color3.new(0, 0, 0)
    resetBtn.Parent = mobileGui
    Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(1, 0)
    local resetStroke = Instance.new("UIStroke", resetBtn)
    resetStroke.Color = Color3.fromRGB(255, 100, 0)
    resetStroke.Thickness = 1.5
    resetStroke.Transparency = 0.25

    MakeDraggable(resetBtn, resetBtn)

    resetBtn.MouseButton1Click:Connect(function()
        Config.Positions = {
            AdminPanel = {X = 0.1859375, Y = 0.5767123526556385}, 
            StealSpeed = {X = 0.02, Y = 0.18}, 
            Settings = {X = 0.834375, Y = 0.43590998043052839}, 
            InvisPanel = {X = 0.8578125, Y = 0.17260276361454258}, 
            AutoSteal = {X = 0.02, Y = 0.35}, 
            MobileControls = {X = 0.9, Y = 0.4},
            MobileBtn_TP = {X = 0.5, Y = 0.4},
            MobileBtn_CL = {X = 0.5, Y = 0.4},
            MobileBtn_SP = {X = 0.5, Y = 0.4},
            MobileBtn_IV = {X = 0.5, Y = 0.4},
            MobileBtn_UI = {X = 0.5, Y = 0.4},
        }
        Config.MobileGuiScale = 0.5
        SaveConfig()
        
        if SharedState.RefreshMobileScale then SharedState.RefreshMobileScale() end
        
        if mobileGui then
            mobileGui.Position = UDim2.new(Config.Positions.MobileControls.X, 0, Config.Positions.MobileControls.Y, 0)
        end
        
        ShowNotification("RESET", "All GUI positions and scale reset")
    end)

    local openBtn = Instance.new("TextButton")
    openBtn.Name = "MobileSettingsButton"
    openBtn.Size = UDim2.new(0, 42, 0, 42)
    openBtn.Position = UDim2.new(1, -58, 1, -58)
    openBtn.BackgroundColor3 = Theme.Accent1
    openBtn.AutoButtonColor = false
    openBtn.Text = "⚙"
    openBtn.Font = Enum.Font.GothamBlack
    openBtn.TextSize = 20
    openBtn.TextColor3 = Color3.new(0, 0, 0)
    openBtn.Parent = mobileGui
    Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1, 0)
    local openStroke = Instance.new("UIStroke", openBtn)
    openStroke.Color = Theme.Accent1
    openStroke.Thickness = 1.5
    openStroke.Transparency = 0.25

    MakeDraggable(openBtn, openBtn)

    openBtn.MouseButton1Click:Connect(function()
        if settingsGui then
            settingsGui.Enabled = not settingsGui.Enabled
        end
        if SharedState.RefreshMobileScale then
            SharedState.RefreshMobileScale()
        end
    end)
end

settingsGui = Instance.new("ScreenGui")
settingsGui.Name = "SettingsUI"; settingsGui.ResetOnSpawn = false
settingsGui.Parent = PlayerGui; settingsGui.Enabled = false
UI.settingsGui = settingsGui

local sFrame = Instance.new("Frame")
sFrame.Size = UDim2.new(0, 300, 0, 650)
sFrame.Position = UDim2.new(Config.Positions.Settings.X, 0, Config.Positions.Settings.Y, 0)
sFrame.BackgroundColor3 = Theme.Background; sFrame.BackgroundTransparency = 0.35
sFrame.BorderSizePixel = 0; sFrame.ClipsDescendants = true; sFrame.Parent = settingsGui

ApplyViewportUIScale(sFrame, 300, 650, 0.45, 0.85)
AddMobileMinimize(sFrame, "SETTINGS")

Instance.new("UICorner", sFrame).CornerRadius = UDim.new(0, 12)
local sStroke = Instance.new("UIStroke", sFrame)
sStroke.Color = Color3.fromRGB(255, 255, 255); sStroke.Thickness = 2; sStroke.Transparency = 0
AddGlowBorderAnimation(sFrame, sStroke)
AddStarryBackground(sFrame)

local sHeader = Instance.new("Frame", sFrame)
sHeader.Size = UDim2.new(1,0,0,40); sHeader.BackgroundTransparency = 1
MakeDraggable(sHeader, sFrame, "Settings") 
local sTitle = Instance.new("TextLabel", sHeader)
sTitle.Size = UDim2.new(1,-20,1,0); sTitle.Position = UDim2.new(0,15,0,0)
sTitle.BackgroundTransparency = 1; sTitle.Text = "SETTINGS"
sTitle.Font = Enum.Font.GothamBlack; sTitle.TextSize = 16
sTitle.TextColor3 = Theme.TextPrimary; sTitle.TextXAlignment = Enum.TextXAlignment.Left

local sList = Instance.new("ScrollingFrame", sFrame)
sList.Size = UDim2.new(1,-20,1,-50); sList.Position = UDim2.new(0,10,0,45)
sList.BackgroundTransparency = 1; sList.BorderSizePixel = 0
sList.ScrollBarThickness = 2; sList.ScrollBarImageColor3 = Theme.Accent1
sList.ScrollingDirection = Enum.ScrollingDirection.Y
sList.AutomaticCanvasSize = Enum.AutomaticSize.Y
sList.CanvasSize = UDim2.new(0, 0, 0, 0)

local sLayout = Instance.new("UIListLayout", sList)
sLayout.Padding = UDim.new(0,8); sLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function CreateToggleSwitch(parent, initialState, callback)
    local sw = Instance.new("Frame")
    sw.Size = UDim2.new(0,40,0,20); sw.Position = UDim2.new(1,-50,0.5,-10)
    sw.BackgroundColor3 = initialState and Theme.Success or Theme.SurfaceHighlight
    Instance.new("UICorner", sw).CornerRadius = UDim.new(1,0); sw.Parent = parent
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,16,0,16)
    dot.Position = initialState and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0); dot.Parent = sw
    local btn = Instance.new("TextButton"); btn.Size = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency = 1; btn.Text = ""; btn.Parent = sw
    local isOn = initialState
    local function SetState(s)
        isOn = s
        local tp = isOn and UDim2.new(1,-18,0.5,-8) or UDim2.new(0,2,0.5,-8)
        local tc = isOn and Theme.Success or Theme.SurfaceHighlight
        TweenService:Create(dot, TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {Position=tp}):Play()
        TweenService:Create(sw,  TweenInfo.new(0.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {BackgroundColor3=tc}):Play()
    end
    btn.MouseButton1Click:Connect(function() callback(not isOn, SetState) end)
    return {Set=SetState, Container=sw}
end

local function CreateRow(text, height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1,0,0,height or 34); row.BackgroundColor3 = Theme.Surface
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,6)
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6,0,1,0); lbl.Position = UDim2.new(0,10,0,0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.Font = Enum.Font.GothamMedium; lbl.TextColor3 = Theme.TextPrimary
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    row.Parent = sList; return row
end

local function CreateSectionHeader(text)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 28)
    row.BackgroundTransparency = 1
    row.Parent = sList
    
    local accent = Instance.new("Frame", row)
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 4, 0.5, -8)
    accent.BackgroundColor3 = Theme.Accent1
    accent.BorderSizePixel = 0
    Instance.new("UICorner", accent).CornerRadius = UDim.new(0, 8)
    
    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Theme.Accent1
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBlack
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local line = Instance.new("Frame", row)
    line.Size = UDim2.new(1, -80, 0, 1)
    line.Position = UDim2.new(0, 75, 0.5, 0)
    line.BackgroundColor3 = Theme.Accent1
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    
    return row
end

CreateRow("Auto TP on Script Load")
CreateToggleSwitch(sList:FindFirstChildOfClass("Frame"), Config.TpSettings.TpOnLoad, function(ns, set)
    set(ns); Config.TpSettings.TpOnLoad = ns; SaveConfig()
    ShowNotification("AUTO TP ON LOAD", ns and "ENABLED" or "DISABLED")
end)

local rMinGen = CreateRow("Min Gen for Auto TP")
local minGenBox = Instance.new("TextBox", rMinGen)
minGenBox.Size = UDim2.new(0, 100, 0, 24)
minGenBox.Position = UDim2.new(1, -110, 0.5, -12)
minGenBox.BackgroundColor3 = Theme.SurfaceHighlight
minGenBox.Text = tostring(Config.TpSettings.MinGenForTp or "")
minGenBox.Font = Enum.Font.Gotham
minGenBox.TextSize = 11
minGenBox.TextColor3 = Theme.TextPrimary
minGenBox.PlaceholderText = "e.g. 5k, 1m, 1b"
Instance.new("UICorner", minGenBox).CornerRadius = UDim.new(0, 8)
minGenBox.FocusLost:Connect(function()
    local raw = minGenBox.Text:gsub("%s", "")
    Config.TpSettings.MinGenForTp = (raw == "" and "" or raw)
    SaveConfig()
    ShowNotification("MIN GEN FOR TP", Config.TpSettings.MinGenForTp == "" and "No minimum" or "Min: " .. (Config.TpSettings.MinGenForTp or ""))
end)

CreateSectionHeader("PERFORMANCE")
CreateToggleSwitch(CreateRow("FPS Boost"), Config.FPSBoost, function(ns, set)
    set(ns); setFPSBoost(ns)
    ShowNotification("FPS BOOST", ns and "ENABLED" or "DISABLED")
end)
CreateToggleSwitch(CreateRow("Dark Mode"), Config.DarkMode, function(ns, set)
    set(ns); pcall(setDarkMode, ns)
    ShowNotification("DARK MODE", ns and "ENABLED" or "DISABLED")
end)

CreateSectionHeader("VISUALS")
CreateToggleSwitch(CreateRow("Tracer Best Brainrot"), Config.TracerEnabled, function(ns, set)
    set(ns); Config.TracerEnabled = ns; SaveConfig()
    ShowNotification("TRACER", ns and "ENABLED" or "DISABLED")
end)

CreateToggleSwitch(CreateRow("Line to base"), Config.LineToBase, function(ns, set)
    set(ns); Config.LineToBase = ns; SaveConfig()
    if not ns and _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
    ShowNotification("LINE TO BASE", ns and "ENABLED" or "DISABLED")
end)

CreateToggleSwitch(CreateRow("X-Ray"), Config.XrayEnabled, function(ns, set)
    set(ns); Config.XrayEnabled = ns; if ns then enableXray() else disableXray() end; SaveConfig()
    ShowNotification("X-RAY", ns and "ENABLED" or "DISABLED")
end)

CreateSectionHeader("Auto TP")
local toolOptions = {"Flying Carpet", "Cupid's Wings", "Santa's Sleigh", "Witch's Broom"}
local toolSwitches = {}
for _, toolName in ipairs(toolOptions) do
    local r = CreateRow(toolName)
    local ts = CreateToggleSwitch(r, Config.TpSettings.Tool==toolName, function(rs, set)
        if rs then
            Config.TpSettings.Tool=toolName; SaveConfig(); set(true)
            for n, sw in pairs(toolSwitches) do if n~=toolName then sw.Set(false) end end
            ShowNotification("TP TOOL", toolName)
        else
            set(Config.TpSettings.Tool==toolName)
        end
    end)
    toolSwitches[toolName] = ts
end

local rSpeed = CreateRow("Teleport Delay (1=Fast)")
local speedCont = Instance.new("Frame", rSpeed)
speedCont.Size = UDim2.new(0,100,0,24); speedCont.Position = UDim2.new(1,-110,0.5,-12); speedCont.BackgroundTransparency=1
local speedBtns = {}
for i = 1, 4 do
    local b = Instance.new("TextButton", speedCont)
    b.Size = UDim2.new(0.22,0,1,0); b.Position = UDim2.new((i-1)*0.26,0,0,0)
    local act = Config.TpSettings.Speed==i
    b.BackgroundColor3 = act and Theme.Accent1 or Theme.SurfaceHighlight
    b.Text = tostring(i); b.TextColor3 = act and Color3.new(0,0,0) or Theme.TextPrimary
    b.Font = Enum.Font.GothamBold; b.TextSize = 12
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,4)
    b.MouseButton1Click:Connect(function()
        Config.TpSettings.Speed=i; SaveConfig()
        for idx, btn in ipairs(speedBtns) do
            local a=(idx==i); btn.BackgroundColor3=a and Theme.Accent1 or Theme.SurfaceHighlight
            btn.TextColor3=a and Color3.new(0,0,0) or Theme.TextPrimary
        end
        ShowNotification("TP SPEED", "Set to " .. tostring(i))
    end)
    table.insert(speedBtns,b)
end

local rBind = CreateRow("TP Keybind")
local bBind = Instance.new("TextButton", rBind)
bBind.Size=UDim2.new(0,60,0,24); bBind.Position=UDim2.new(1,-70,0.5,-12)
bBind.BackgroundColor3=Theme.SurfaceHighlight; bBind.Text=Config.TpSettings.TpKey
bBind.Font=Enum.Font.GothamBold; bBind.TextColor3=Theme.TextPrimary; bBind.TextSize=12
Instance.new("UICorner",bBind).CornerRadius=UDim.new(0,8)
bBind.MouseButton1Click:Connect(function()
    bBind.Text="..."; bBind.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.TpKey=inp.KeyCode.Name; bBind.Text=inp.KeyCode.Name
            bBind.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("TP KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rBindClone = CreateRow("Auto Clone Keybind")
local bBindClone = Instance.new("TextButton", rBindClone)
bBindClone.Size=UDim2.new(0,60,0,24); bBindClone.Position=UDim2.new(1,-70,0.5,-12)
bBindClone.BackgroundColor3=Theme.SurfaceHighlight; bBindClone.Text=Config.TpSettings.CloneKey
bBindClone.Font=Enum.Font.GothamBold; bBindClone.TextColor3=Theme.TextPrimary; bBindClone.TextSize=12
Instance.new("UICorner",bBindClone).CornerRadius=UDim.new(0,8)
bBindClone.MouseButton1Click:Connect(function()
    bBindClone.Text="..."; bBindClone.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CloneKey=inp.KeyCode.Name; bBindClone.Text=inp.KeyCode.Name
            bBindClone.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CLONE KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

CreateSectionHeader("CARPET SPEED")
local rCarpetBind = CreateRow("Carpet Speed Keybind")
local bCarpet = Instance.new("TextButton", rCarpetBind)
bCarpet.Size=UDim2.new(0,60,0,24); bCarpet.Position=UDim2.new(1,-70,0.5,-12)
bCarpet.BackgroundColor3=Theme.SurfaceHighlight; bCarpet.Text=Config.TpSettings.CarpetSpeedKey
bCarpet.Font=Enum.Font.GothamBold; bCarpet.TextColor3=Theme.TextPrimary; bCarpet.TextSize=12
Instance.new("UICorner",bCarpet).CornerRadius=UDim.new(0,8)
bCarpet.MouseButton1Click:Connect(function()
    bCarpet.Text="..."; bCarpet.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.TpSettings.CarpetSpeedKey=inp.KeyCode.Name; bCarpet.Text=inp.KeyCode.Name
            bCarpet.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("CARPET SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rRagdollSelf = CreateRow("Ragdoll Self Keybind")
local bRagdollSelf = Instance.new("TextButton", rRagdollSelf)
bRagdollSelf.Size=UDim2.new(0,60,0,24); bRagdollSelf.Position=UDim2.new(1,-70,0.5,-12)
bRagdollSelf.BackgroundColor3=Theme.SurfaceHighlight; bRagdollSelf.Text=Config.RagdollSelfKey ~= "" and Config.RagdollSelfKey or "NONE"
bRagdollSelf.Font=Enum.Font.GothamBold; bRagdollSelf.TextColor3=Theme.TextPrimary; bRagdollSelf.TextSize=12
Instance.new("UICorner",bRagdollSelf).CornerRadius=UDim.new(0,8)
bRagdollSelf.MouseButton1Click:Connect(function()
    bRagdollSelf.Text="..."; bRagdollSelf.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.RagdollSelfKey=inp.KeyCode.Name; bRagdollSelf.Text=inp.KeyCode.Name
            bRagdollSelf.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("RAGDOLL SELF KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rCarpetStatus = CreateRow("Carpet Speed Status")
local carpetStatusLbl = Instance.new("TextLabel", rCarpetStatus)
carpetStatusLbl.Size=UDim2.new(0,50,0,20); carpetStatusLbl.Position=UDim2.new(1,-60,0.5,-10)
carpetStatusLbl.BackgroundTransparency=1
carpetStatusLbl.Text=carpetSpeedEnabled and "ON" or "OFF"
carpetStatusLbl.TextColor3=carpetSpeedEnabled and Theme.Success or Theme.Error
carpetStatusLbl.Font=Enum.Font.GothamBlack; carpetStatusLbl.TextSize=13
carpetStatusLbl.TextXAlignment=Enum.TextXAlignment.Right
_carpetStatusLabel = carpetStatusLbl

CreateSectionHeader("MOVEMENT")
local rInfJump = CreateRow("Infinite Jump")
CreateToggleSwitch(rInfJump, infiniteJumpEnabled, function(ns, set)
    set(ns); setInfiniteJump(ns)
    ShowNotification("INFINITE JUMP", ns and "ENABLED" or "DISABLED")
end)
local rShowSS = CreateRow("Show Steal Speed Panel")
CreateToggleSwitch(rShowSS, Config.ShowStealSpeedPanel, function(ns, set)
    set(ns); Config.ShowStealSpeedPanel = ns; SaveConfig()
    local ssGui = PlayerGui:FindFirstChild("StealSpeedUI")
    if ssGui then ssGui.Enabled = ns end
    ShowNotification("STEAL SPEED PANEL", ns and "SHOWN" or "HIDDEN")
end)
local rAutoStealSpeed = CreateRow("Auto Steal Speed")
CreateToggleSwitch(rAutoStealSpeed, Config.AutoStealSpeed, function(ns, set)
    set(ns); Config.AutoStealSpeed = ns; SaveConfig()
    ShowNotification("AUTO STEAL SPEED", ns and "ENABLED" or "DISABLED")
end)

local rStealSpeedKey = CreateRow("Steal Speed Keybind")
local bStealSpeedKey = Instance.new("TextButton", rStealSpeedKey)
bStealSpeedKey.Size=UDim2.new(0,60,0,24); bStealSpeedKey.Position=UDim2.new(1,-70,0.5,-12)
bStealSpeedKey.BackgroundColor3=Theme.SurfaceHighlight; bStealSpeedKey.Text=Config.StealSpeedKey
bStealSpeedKey.Font=Enum.Font.GothamBold; bStealSpeedKey.TextColor3=Theme.TextPrimary; bStealSpeedKey.TextSize=12
Instance.new("UICorner",bStealSpeedKey).CornerRadius=UDim.new(0,8)
bStealSpeedKey.MouseButton1Click:Connect(function()
    bStealSpeedKey.Text="..."; bStealSpeedKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.StealSpeedKey=inp.KeyCode.Name; bStealSpeedKey.Text=inp.KeyCode.Name
            bStealSpeedKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("STEAL SPEED KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

CreateSectionHeader("AUTO UNLOCK")
local rAutoUnlock = CreateRow("Auto Unlock on Steal")
CreateToggleSwitch(rAutoUnlock, Config.AutoUnlockOnSteal, function(ns, set)
    set(ns); Config.AutoUnlockOnSteal = ns; SaveConfig()
    ShowNotification("AUTO UNLOCK", ns and "ENABLED" or "DISABLED")
end)

local rShowUnlockHUD = CreateRow("Show Unlock Buttons HUD")
CreateToggleSwitch(rShowUnlockHUD, Config.ShowUnlockButtonsHUD, function(ns, set)
    set(ns); Config.ShowUnlockButtonsHUD = ns; SaveConfig()
    local hudGui = PlayerGui:FindFirstChild("XiStatusHUD")
    if hudGui then
        local main = hudGui:FindFirstChild("Main")
        local unlockContainer = main and main:FindFirstChild("UnlockButtonsContainer")
        if main and unlockContainer then
            unlockContainer.Visible = ns
            if ns then
                TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 500, 0, 100)
                }):Play()
            else
                TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Size = UDim2.new(0, 500, 0, 50)
                }):Play()
            end
        end
    end
end)
CreateSectionHeader("ANTI-RAGDOLL")
local arV1SetRef, arV2SetRef = {}, {}
local rAr = CreateRow("V1")
CreateToggleSwitch(rAr, Config.AntiRagdoll > 0, function(ns, set)
    arV1SetRef.fn = set
    if ns and Config.AntiRagdollV2 then
        set(false)
        ShowNotification("ANTI-RAGDOLL", "DISABLE V2 FIRST")
        return
    end
    set(ns)
    local mode = ns and 1 or 0
    Config.AntiRagdoll = mode
    if ns then
        Config.AntiRagdollV2 = false
        if arV2SetRef.fn then arV2SetRef.fn(false) end
    end
    SaveConfig()
    startAntiRagdoll(mode)
    if ns then startAntiRagdollV2(false) end
    ShowNotification("ANTI-RAGDOLL V1", ns and "ENABLED" or "DISABLED")
end)
local rArV2 = CreateRow("V2")
CreateToggleSwitch(rArV2, Config.AntiRagdollV2, function(ns, set)
    arV2SetRef.fn = set
    if ns and Config.AntiRagdoll > 0 then
        set(false)
        ShowNotification("ANTI-RAGDOLL", "DISABLE V1 FIRST")
        return
    end
    set(ns)
    Config.AntiRagdollV2 = ns
    if ns then
        Config.AntiRagdoll = 0
        if arV1SetRef.fn then arV1SetRef.fn(false) end
    end
    SaveConfig()
    startAntiRagdollV2(ns)
    if ns then startAntiRagdoll(0) end
    ShowNotification("ANTI-RAGDOLL V2", ns and "ENABLED" or "DISABLED")
end)

CreateSectionHeader("ESP")

local rXray = CreateRow("Base X-Ray")
local xrayToggle = CreateToggleSwitch(rXray, xrayEnabled, function(ns, set)
    set(ns)
    if ns then
        enableXray()
        xrayDescConn = Workspace.DescendantAdded:Connect(function(obj)
            if xrayEnabled and obj:IsA("BasePart") and obj.Anchored and isBaseWall(obj) then
                originalTransparency[obj] = obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier = 0.85
            end
        end)
    else
        disableXray()
    end
    Config.XrayEnabled = ns; SaveConfig()
    ShowNotification("BASE X-RAY", ns and "ENABLED" or "DISABLED")
end)
local playerESPToggleRef = {setFn=nil}
local rPlayerEsp = CreateRow("Player ESP (Hides Names)")
CreateToggleSwitch(rPlayerEsp, Config.PlayerESP, function(ns, set)
    set(ns); Config.PlayerESP = ns; SaveConfig()
    if playerESPToggleRef.setFn then playerESPToggleRef.setFn(ns) end
    ShowNotification("PLAYER ESP", ns and "ENABLED" or "DISABLED")
end)

local espToggleRef = {enabled=true, setFn=nil}
local rEsp = CreateRow("Brainrot ESP")
local espSettingsSwitch = CreateToggleSwitch(rEsp, Config.BrainrotESP, function(ns, set)
    set(ns); Config.BrainrotESP = ns; SaveConfig()
    if espToggleRef.setFn then espToggleRef.setFn(ns) end
    ShowNotification("BRAINROT ESP", ns and "ENABLED" or "DISABLED")
end)
local subspaceMineESPToggleRef = {setFn=nil}
local rSubspaceMineEsp = CreateRow("Subspace Mine Esp")
CreateToggleSwitch(rSubspaceMineEsp, Config.SubspaceMineESP, function(ns, set)
    set(ns); Config.SubspaceMineESP = ns; SaveConfig()
    if subspaceMineESPToggleRef.setFn then subspaceMineESPToggleRef.setFn(ns) end
    ShowNotification("SUBSPACE MINE ESP", ns and "ENABLED" or "DISABLED")
end)
local rDuelBaseESP = CreateRow("Duel Base ESP")
CreateToggleSwitch(rDuelBaseESP, Config.DuelBaseESP, function(ns, set)
    set(ns); Config.DuelBaseESP = ns; SaveConfig()
    ShowNotification("DUEL BASE ESP", ns and "ENABLED" or "DISABLED")
end)

CreateSectionHeader("AUTO STEAL DEFAULTS")
local nearestToggleRef = {}
local highestToggleRef = {}
local priorityToggleRef = {}
local autoTPPriorityToggleRef = {setFn = nil}

local rDefaultNearest = CreateRow("Default To Nearest")
local nearestToggleSwitch = CreateToggleSwitch(rDefaultNearest, Config.DefaultToNearest, function(ns, set)
    if ns then
        Config.DefaultToNearest = true
        Config.DefaultToHighest = false
        Config.DefaultToPriority = false
        set(true)
        if highestToggleRef.setFn then highestToggleRef.setFn(false) end
        if priorityToggleRef.setFn then priorityToggleRef.setFn(false) end
        
        Config.AutoTPPriority = true
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(true)
        end
    else
        local otherDefaults = Config.DefaultToHighest or Config.DefaultToPriority
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToNearest = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO NEAREST", ns and "ENABLED" or "DISABLED")
end)
nearestToggleRef.setFn = nearestToggleSwitch.Set

local rDefaultHighest = CreateRow("Default To Highest")
local highestToggleSwitch = CreateToggleSwitch(rDefaultHighest, Config.DefaultToHighest, function(ns, set)
    if ns then
        Config.DefaultToNearest = false
        Config.DefaultToHighest = true
        Config.DefaultToPriority = false
        set(true)
        if nearestToggleRef.setFn then nearestToggleRef.setFn(false) end
        if priorityToggleRef.setFn then priorityToggleRef.setFn(false) end
        
        Config.AutoTPPriority = false
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(false)
        end
    else
        local otherDefaults = Config.DefaultToNearest or Config.DefaultToPriority
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToHighest = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO HIGHEST", ns and "ENABLED" or "DISABLED")
end)
highestToggleRef.setFn = highestToggleSwitch.Set

local rDefaultPriority = CreateRow("Default To Priority")
local priorityToggleSwitch = CreateToggleSwitch(rDefaultPriority, Config.DefaultToPriority, function(ns, set)
    if ns then
        Config.DefaultToNearest = false
        Config.DefaultToHighest = false
        Config.DefaultToPriority = true
        set(true)
        if nearestToggleRef.setFn then nearestToggleRef.setFn(false) end
        if highestToggleRef.setFn then highestToggleRef.setFn(false) end
        
        Config.AutoTPPriority = true
        if autoTPPriorityToggleRef and autoTPPriorityToggleRef.setFn then
            autoTPPriorityToggleRef.setFn(true)
        end
    else
        local otherDefaults = Config.DefaultToNearest or Config.DefaultToHighest
        if not otherDefaults then
            set(true)
            ShowNotification("DEFAULT MODE", "At least one default must be enabled")
            return
        end
        Config.DefaultToPriority = false
        set(false)
    end
    SaveConfig()
    ShowNotification("DEFAULT TO PRIORITY", ns and "ENABLED" or "DISABLED")
end)
priorityToggleRef.setFn = priorityToggleSwitch.Set

CreateSectionHeader("AUTOMATION")
local rAutoInvis = CreateRow("Auto Invis During Steal")
CreateToggleSwitch(rAutoInvis, Config.AutoInvisDuringSteal, function(ns, set)
    set(ns); Config.AutoInvisDuringSteal = ns; _G.AutoInvisDuringSteal = ns; SaveConfig()
    ShowNotification("AUTO INVIS", ns and "ENABLED" or "DISABLED")
end)

local rShowInvisPanel = CreateRow("Show Invisible Steal Panel")
CreateToggleSwitch(rShowInvisPanel, Config.ShowInvisPanel, function(ns, set)
    set(ns); Config.ShowInvisPanel = ns; SaveConfig()
    local invisGui = PlayerGui:FindFirstChild("XiInvisPanel")
    if invisGui then invisGui.Enabled = ns end
    ShowNotification("INVIS PANEL", ns and "SHOWN" or "HIDDEN")
end)

local rAutoTpFail = CreateRow("Auto TP on Failed Steal")
CreateToggleSwitch(rAutoTpFail, Config.AutoTpOnFailedSteal, function(ns, set)
    set(ns); Config.AutoTpOnFailedSteal = ns; SaveConfig()
    ShowNotification("AUTO TP ON FAILED STEAL", ns and "ENABLED" or "DISABLED")
end)
local rAutoTpPriority = CreateRow("Auto TP Priority Mode")
local autoTPPriorityToggleSwitch = CreateToggleSwitch(rAutoTpPriority, Config.AutoTPPriority, function(ns, set)
    set(ns); Config.AutoTPPriority = ns; SaveConfig()
    ShowNotification("AUTO TP PRIORITY", ns and "PRIORITY" or "HIGHEST")
end)
autoTPPriorityToggleRef.setFn = autoTPPriorityToggleSwitch.Set
local rAutoKick = CreateRow("Auto-Kick on Steal")
local autoKickToggleSwitch = CreateToggleSwitch(rAutoKick, Config.AutoKickOnSteal, function(ns, set)
    set(ns); Config.AutoKickOnSteal = ns; SaveConfig()
    ShowNotification("AUTO-KICK ON STEAL", ns and "ENABLED" or "DISABLED")
end)
SharedState.SettingsAutoKickSet = autoKickToggleSwitch.Set

CreateSectionHeader("HIDE GUIS")
local rHideAdminPanel = CreateRow("Hide Admin Panel GUI")
CreateToggleSwitch(rHideAdminPanel, Config.HideAdminPanel, function(ns, set)
    set(ns); Config.HideAdminPanel = ns; SaveConfig()
    local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
    if adUI then adUI.Enabled = not ns end
    ShowNotification("HIDE ADMIN PANEL", ns and "ENABLED" or "DISABLED")
end)
local rHideAdminTools = CreateRow("Hide Admin Tools Panel GUI")
CreateToggleSwitch(rHideAdminTools, Config.ShowAdminToolsPanel == false, function(ns, set)
    set(ns); Config.ShowAdminToolsPanel = not ns; SaveConfig()
    local toolsGui = PlayerGui:FindFirstChild("XiAdminToolsPanel")
    if toolsGui then toolsGui.Enabled = not ns end
    if SharedState.AdminToolsSetEnabled then pcall(SharedState.AdminToolsSetEnabled, not ns) end
    if ns then
        ProximityAPActive = false
        SaveConfig()
        if SharedState.UpdateProximityAPButton then SharedState.UpdateProximityAPButton() end
    end
    ShowNotification("HIDE ADMIN TOOLS", ns and "ENABLED" or "DISABLED")
end)
local rHideAutoSteal = CreateRow("Hide Auto Steal GUI")
CreateToggleSwitch(rHideAutoSteal, Config.HideAutoSteal, function(ns, set)
    set(ns); Config.HideAutoSteal = ns; SaveConfig()
    local asUI = PlayerGui:FindFirstChild("AutoStealUI")
    if asUI then asUI.Enabled = not ns end
    ShowNotification("HIDE AUTO STEAL", ns and "ENABLED" or "DISABLED")
end)
local rHideStealPanel = CreateRow("Hide Steal Panel GUI")
CreateToggleSwitch(rHideStealPanel, Config.HideStealPanel, function(ns, set)
    set(ns); Config.HideStealPanel = ns; SaveConfig()
    local spUI = PlayerGui:FindFirstChild("XiStealPanel")
    if spUI then spUI.Enabled = not ns end
    ShowNotification("HIDE STEAL PANEL", ns and "ENABLED" or "DISABLED")
end)
local rHideActionsPanel = CreateRow("Hide Actions Panel GUI")
CreateToggleSwitch(rHideActionsPanel, Config.HideActionsPanel, function(ns, set)
    set(ns); Config.HideActionsPanel = ns; SaveConfig()
    local apUI = PlayerGui:FindFirstChild("XiActionsPanel")
    if apUI then apUI.Enabled = not ns end
    ShowNotification("HIDE ACTIONS PANEL", ns and "ENABLED" or "DISABLED")
end)

CreateSectionHeader("EXTRAS")   

local rResetKey = CreateRow("Reset")
local bResetKey = Instance.new("TextButton", rResetKey)
bResetKey.Size=UDim2.new(0,60,0,24); bResetKey.Position=UDim2.new(1,-70,0.5,-12)
bResetKey.BackgroundColor3=Theme.SurfaceHighlight; bResetKey.Text=Config.ResetKey
bResetKey.Font=Enum.Font.GothamBold; bResetKey.TextColor3=Theme.TextPrimary; bResetKey.TextSize=12
Instance.new("UICorner",bResetKey).CornerRadius=UDim.new(0,8)
bResetKey.MouseButton1Click:Connect(function()
    bResetKey.Text="..."; bResetKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.ResetKey=inp.KeyCode.Name; bResetKey.Text=inp.KeyCode.Name
            bResetKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("RESET KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

local rAutoResetBalloon = CreateRow("Auto reset on balloon")
CreateToggleSwitch(rAutoResetBalloon, Config.AutoResetOnBalloon, function(ns, set)
    set(ns); Config.AutoResetOnBalloon = ns; SaveConfig()
    ShowNotification("AUTO RESET ON BALLOON", ns and "ENABLED" or "DISABLED")
end)

local rKickHotkey = CreateRow("Kick Hotkey")
local bKickHotkey = Instance.new("TextButton", rKickHotkey)
bKickHotkey.Size=UDim2.new(0,60,0,24); bKickHotkey.Position=UDim2.new(1,-70,0.5,-12)
bKickHotkey.BackgroundColor3=Theme.SurfaceHighlight; bKickHotkey.Text=(kickHotkey ~= Enum.KeyCode.Unknown and kickHotkey.Name) or "NONE"
bKickHotkey.Font=Enum.Font.GothamBold; bKickHotkey.TextColor3=Theme.TextPrimary; bKickHotkey.TextSize=12
Instance.new("UICorner",bKickHotkey).CornerRadius=UDim.new(0,8)
bKickHotkey.MouseButton1Click:Connect(function()
    awaitingKickHotkey = true
    bKickHotkey.Text="..."; bKickHotkey.TextColor3=Theme.Accent1
end)

local rCleanErrors = CreateRow("Clean Error GUIs")
CreateToggleSwitch(rCleanErrors, Config.CleanErrorGUIs, function(ns, set)
    set(ns); Config.CleanErrorGUIs = ns; SaveConfig()
    ShowNotification("CLEAN ERROR GUIS", ns and "ENABLED" or "DISABLED")
end)

local rFloatKey = CreateRow("Float")
local bFloatKey = Instance.new("TextButton", rFloatKey)
bFloatKey.Size = UDim2.new(0, 65, 0, 27); bFloatKey.Position = UDim2.new(1, -60, 1, -10)
bFloatKey.BackgroundColor3 = Theme.SurfaceHighlight
bFloatKey.Text = Config.FloatKey or "B"
bFloatKey.Font = Enum.Font.GothamBold; bFloatKey.TextColor3 = Theme.TextPrimary; bFloatKey.TextSize = 12
bFloatKey.AutoButtonColor = false; bFloatKey.BorderSizePixel = 0
Instance.new("UICorner", bFloatKey).CornerRadius = UDim.new(0, 8)
local awaitingFloatKey = false
bFloatKey.MouseButton1Click:Connect(function()
    awaitingFloatKey = true
    bFloatKey.Text = "..."; bFloatKey.TextColor3 = Theme.Accent1
end)

CreateSectionHeader("ALERTS")
local rAlertsEnabled = CreateRow("Enable Alerts")
CreateToggleSwitch(rAlertsEnabled, Config.AlertsEnabled, function(ns, set)
    set(ns); Config.AlertsEnabled = ns; SaveConfig()
    ShowNotification("PRIORITY ALERTS", ns and "ENABLED" or "DISABLED")
end)
local rAlertSound = CreateRow("Alert Sound ID")
local soundBox = Instance.new("TextBox", rAlertSound)
soundBox.Size = UDim2.new(0, 180, 0, 24)
soundBox.Position = UDim2.new(1, -185, 0.5, -12)
soundBox.BackgroundColor3 = Theme.SurfaceHighlight
soundBox.Text = Config.AlertSoundID or "rbxassetid://6518811702"
soundBox.Font = Enum.Font.Gotham
soundBox.TextSize = 10
soundBox.TextColor3 = Theme.TextPrimary
soundBox.PlaceholderText = "Sound ID"
Instance.new("UICorner", soundBox).CornerRadius = UDim.new(0, 8)
soundBox.FocusLost:Connect(function()
    Config.AlertSoundID = soundBox.Text
    SaveConfig()
    ShowNotification("ALERT SOUND", "Updated")
end)

CreateSectionHeader("JOB JOINER")
local rJoinerRow = CreateRow("Job ID Joiner")
CreateToggleSwitch(rJoinerRow, Config.ShowJobJoiner, function(ns, set)
    set(ns); Config.ShowJobJoiner = ns; SaveConfig()
    local gui = PlayerGui:FindFirstChild("XiJobJoiner")
    if gui then gui.Enabled = Config.ShowJobJoiner end
    ShowNotification("JOB ID JOINER", ns and "ENABLED" or "DISABLED")
end)
local rJoinerKey = CreateRow("Job Joiner Keybind")
local bJoinerKey = Instance.new("TextButton", rJoinerKey)
bJoinerKey.Size=UDim2.new(0,60,0,24); bJoinerKey.Position=UDim2.new(1,-70,0.5,-12)
bJoinerKey.BackgroundColor3=Theme.SurfaceHighlight; bJoinerKey.Text=Config.JobJoinerKey or "J"
bJoinerKey.Font=Enum.Font.GothamBold; bJoinerKey.TextColor3=Theme.TextPrimary; bJoinerKey.TextSize=12
Instance.new("UICorner",bJoinerKey).CornerRadius=UDim.new(0,8)
bJoinerKey.MouseButton1Click:Connect(function()
    bJoinerKey.Text="..."; bJoinerKey.TextColor3=Theme.Accent1
    local con; con=UserInputService.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.Keyboard then
            Config.JobJoinerKey=inp.KeyCode.Name; bJoinerKey.Text=inp.KeyCode.Name
            bJoinerKey.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
            ShowNotification("JOB JOINER KEYBIND", inp.KeyCode.Name)
        end
    end)
end)

CreateSectionHeader("PROTECTION")
local rAntiBeeDisco = CreateRow("Anti-Bee & Anti-Disco")
CreateToggleSwitch(rAntiBeeDisco, Config.AntiBeeDisco, function(ns, set)
    set(ns); Config.AntiBeeDisco = ns; SaveConfig()
    if ns then
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Enable then
            _G.ANTI_BEE_DISCO.Enable()
        end
    else
        if _G.ANTI_BEE_DISCO and _G.ANTI_BEE_DISCO.Disable then
            _G.ANTI_BEE_DISCO.Disable()
        end
    end
    ShowNotification("ANTI-BEE & DISCO", ns and "ENABLED" or "DISABLED")
end)

local rAutoDestroyTurrets = CreateRow("Auto-Destroy Turrets")
local autoDestroyTurretsToggleSwitch = CreateToggleSwitch(rAutoDestroyTurrets, Config.AutoDestroyTurrets, function(ns, set)
    set(ns); Config.AutoDestroyTurrets = ns; SaveConfig()
    ShowNotification("AUTO-DESTROY TURRETS", ns and "ENABLED" or "DISABLED")
end)
SharedState.SettingsAutoDestroyTurretsSet = autoDestroyTurretsToggleSwitch.Set

CreateSectionHeader("CAMERA")
local rFOV = CreateRow("FOV")
local fovSliderBg = Instance.new("Frame", rFOV)
fovSliderBg.Size = UDim2.new(0, 140, 0, 5)
fovSliderBg.Position = UDim2.new(1, -200, 0.5, -2.5)
fovSliderBg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
Instance.new("UICorner", fovSliderBg).CornerRadius = UDim.new(1, 0)
local fovFill = Instance.new("Frame", fovSliderBg)
fovFill.BackgroundColor3 = Theme.Accent1
fovFill.Size = UDim2.new(0, 0, 1, 0)
Instance.new("UICorner", fovFill).CornerRadius = UDim.new(1, 0)
local fovKnob = Instance.new("Frame", fovSliderBg)
fovKnob.Size = UDim2.new(0, 12, 0, 12)
fovKnob.BackgroundColor3 = Theme.TextPrimary
fovKnob.AnchorPoint = Vector2.new(0.5, 0.5)
fovKnob.Position = UDim2.new(0, 0, 0.5, 0)
Instance.new("UICorner", fovKnob).CornerRadius = UDim.new(1, 0)
local fovKnobStroke = Instance.new("UIStroke", fovKnob)
fovKnobStroke.Color = Theme.Accent1
fovKnobStroke.Thickness = 1.5
fovKnobStroke.Transparency = 0.2
local fovValLbl = Instance.new("TextLabel", rFOV)
fovValLbl.Size = UDim2.new(0, 40, 0, 20)
fovValLbl.Position = UDim2.new(1, -50, 0.5, -10)
fovValLbl.BackgroundTransparency = 1
fovValLbl.Text = string.format("%.1f", Config.FOV)
fovValLbl.TextColor3 = Theme.TextPrimary
fovValLbl.Font = Enum.Font.GothamBold
fovValLbl.TextSize = 13

local function updateFOVSlider(val)
    val = math.clamp(val, 30, 180)
    Config.FOV = val
    SaveConfig()
    fovValLbl.Text = string.format("%.1f", val)
    local pct = (val - 30) / 150
    fovFill.Size = UDim2.new(pct, 0, 1, 0)
    fovKnob.Position = UDim2.new(pct, 0, 0.5, 0)
    if Workspace.CurrentCamera then
        Workspace.CurrentCamera.FieldOfView = val
    end
    ShowNotification("FIELD OF VIEW", string.format("%.1f", val))
end
updateFOVSlider(Config.FOV)

local fovDragging = false
fovSliderBg.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDragging = true end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then fovDragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if fovDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local x = i.Position.X
        local r = fovSliderBg.AbsolutePosition.X
        local w = fovSliderBg.AbsoluteSize.X
        local p = (x - r) / w
        updateFOVSlider(30 + (p * 150))
    end
end)

local rFOVReset = CreateRow("Reset FOV")
local bFOVReset = Instance.new("TextButton", rFOVReset)
bFOVReset.Size = UDim2.new(0, 60, 0, 24)
bFOVReset.Position = UDim2.new(1, -70, 0.5, -12)
bFOVReset.BackgroundColor3 = Theme.SurfaceHighlight
bFOVReset.Text = "Reset"
bFOVReset.Font = Enum.Font.GothamBold
bFOVReset.TextColor3 = Theme.TextPrimary
bFOVReset.TextSize = 12
Instance.new("UICorner", bFOVReset).CornerRadius = UDim.new(0, 8)
bFOVReset.MouseButton1Click:Connect(function()
    updateFOVSlider(70)
    ShowNotification("FIELD OF VIEW", "Reset to 70")
end)

CreateSectionHeader("MENU")
if not IS_MOBILE then
    local rMenu = CreateRow("Menu Toggle Key")
    local bMenu = Instance.new("TextButton", rMenu)
    bMenu.Size=UDim2.new(0,80,0,24); bMenu.Position=UDim2.new(1,-90,0.5,-12)
    bMenu.BackgroundColor3=Theme.SurfaceHighlight; bMenu.Text=Config.MenuKey
    bMenu.Font=Enum.Font.GothamBold; bMenu.TextColor3=Theme.TextPrimary; bMenu.TextSize=12
    Instance.new("UICorner",bMenu).CornerRadius=UDim.new(0,8)
    bMenu.MouseButton1Click:Connect(function()
        bMenu.Text="..."; bMenu.TextColor3=Theme.Accent1
        local con; con=UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.Keyboard then
                Config.MenuKey=inp.KeyCode.Name; bMenu.Text=inp.KeyCode.Name
                bMenu.TextColor3=Theme.TextPrimary; SaveConfig(); con:Disconnect()
                ShowNotification("MENU KEYBIND", inp.KeyCode.Name)
            end
        end)
    end)
else
    CreateRow("Menu Toggle: Touch Icon")
end

CreateSectionHeader("UI CONTROLS")
local rLock = CreateRow("Lock UI Dragging")
CreateToggleSwitch(rLock, Config.UILocked, function(ns, set)
    set(ns); Config.UILocked = ns; SaveConfig()
    ShowNotification("UI LOCK", ns and "ENABLED" or "DISABLED")
end)

local rGuiScale = CreateRow("GUI Size")
local bGuiMinus = Instance.new("TextButton", rGuiScale)
bGuiMinus.Size = UDim2.new(0, 26, 0, 24)
bGuiMinus.Position = UDim2.new(1, -145, 0.5, -12)
bGuiMinus.BackgroundColor3 = Theme.SurfaceHighlight
bGuiMinus.Text = "-"
bGuiMinus.Font = Enum.Font.GothamBlack
bGuiMinus.TextSize = 16
bGuiMinus.TextColor3 = Theme.TextPrimary
bGuiMinus.AutoButtonColor = false
Instance.new("UICorner", bGuiMinus).CornerRadius = UDim.new(0, 8)

local guiScaleReadout = Instance.new("TextLabel", rGuiScale)
guiScaleReadout.Size = UDim2.new(0, 60, 0, 20)
guiScaleReadout.Position = UDim2.new(1, -114, 0.5, -10)
guiScaleReadout.BackgroundTransparency = 1
guiScaleReadout.Text = string.format("%.2f", tonumber(Config.GuiScale) or 1)
guiScaleReadout.Font = Enum.Font.GothamBold
guiScaleReadout.TextSize = 11
guiScaleReadout.TextColor3 = Theme.Accent1
guiScaleReadout.TextXAlignment = Enum.TextXAlignment.Center

local bGuiPlus = Instance.new("TextButton", rGuiScale)
bGuiPlus.Size = UDim2.new(0, 26, 0, 24)
bGuiPlus.Position = UDim2.new(1, -45, 0.5, -12)
bGuiPlus.BackgroundColor3 = Theme.SurfaceHighlight
bGuiPlus.Text = "+"
bGuiPlus.Font = Enum.Font.GothamBlack
bGuiPlus.TextSize = 16
bGuiPlus.TextColor3 = Theme.TextPrimary
bGuiPlus.AutoButtonColor = false
Instance.new("UICorner", bGuiPlus).CornerRadius = UDim.new(0, 8)

local function setGuiScale(val)
    local v = math.clamp(tonumber(val) or 1, 0.6, 1.6)
    Config.GuiScale = v
    SaveConfig()
    guiScaleReadout.Text = string.format("%.2f", v)
    if SharedState.RefreshMobileScale then
        SharedState.RefreshMobileScale()
    end
end

bGuiMinus.MouseButton1Click:Connect(function()
    setGuiScale((tonumber(Config.GuiScale) or 1) - 0.1)
end)

bGuiPlus.MouseButton1Click:Connect(function()
    setGuiScale((tonumber(Config.GuiScale) or 1) + 0.1)
end)

if IS_MOBILE then
    local scaleUI = {}
    scaleUI.row = CreateRow("Mobile GUI Scale")
    scaleUI.bg = Instance.new("Frame", scaleUI.row)
    scaleUI.bg.Size = UDim2.new(0, 140, 0, 5)
    scaleUI.bg.Position = UDim2.new(1, -200, 0.5, -2.5)
    scaleUI.bg.BackgroundColor3 = Color3.fromRGB(30, 32, 38)
    Instance.new("UICorner", scaleUI.bg).CornerRadius = UDim.new(1, 0)
    scaleUI.fill = Instance.new("Frame", scaleUI.bg)
    scaleUI.fill.BackgroundColor3 = Theme.Accent1
    scaleUI.fill.BorderSizePixel = 0
    scaleUI.fill.Size = UDim2.new(0, 0, 1, 0)
    Instance.new("UICorner", scaleUI.fill).CornerRadius = UDim.new(1, 0)
    scaleUI.knob = Instance.new("Frame", scaleUI.bg)
    scaleUI.knob.Size = UDim2.new(0, 14, 0, 14)
    scaleUI.knob.AnchorPoint = Vector2.new(0.5, 0.5)
    scaleUI.knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scaleUI.knob.BorderSizePixel = 0
    Instance.new("UICorner", scaleUI.knob).CornerRadius = UDim.new(1, 0)
    scaleUI.stroke = Instance.new("UIStroke", scaleUI.knob)
    scaleUI.stroke.Color = Theme.Accent1
    scaleUI.stroke.Thickness = 2
    scaleUI.readout = Instance.new("TextLabel", scaleUI.row)
    scaleUI.readout.Size = UDim2.new(0, 50, 0, 20)
    scaleUI.readout.Position = UDim2.new(1, -145, 0.5, -10)
    scaleUI.readout.BackgroundTransparency = 1
    scaleUI.readout.Text = string.format("%.1f", Config.MobileGuiScale or 0.5)
    scaleUI.readout.Font = Enum.Font.GothamBold
    scaleUI.readout.TextSize = 11
    scaleUI.readout.TextColor3 = Theme.Accent1
    scaleUI.readout.TextXAlignment = Enum.TextXAlignment.Right
    scaleUI.dragging = false
    scaleUI.min = 0.1
    scaleUI.max = 1.0
    scaleUI.scaleToT = function(s)
        return math.clamp((s - scaleUI.min) / (scaleUI.max - scaleUI.min), 0, 1)
    end
    scaleUI.updateScaleSlider = function(val)
        local c = math.clamp(val, scaleUI.min, scaleUI.max)
        Config.MobileGuiScale = c
        SaveConfig()
        scaleUI.fill.Size = UDim2.new(scaleUI.scaleToT(c), 0, 1, 0)
        scaleUI.knob.Position = UDim2.new(0, scaleUI.scaleToT(c) * scaleUI.bg.AbsoluteSize.X, 0.5, 0)
        scaleUI.readout.Text = string.format("%.2f", c)
        if SharedState.RefreshMobileScale then SharedState.RefreshMobileScale() end
    end
    task.defer(function() scaleUI.updateScaleSlider(Config.MobileGuiScale or 0.5) end)
    scaleUI.onScaleInput = function(pos)
        scaleUI.updateScaleSlider(scaleUI.min + math.clamp((pos.X - scaleUI.bg.AbsolutePosition.X) / scaleUI.bg.AbsoluteSize.X, 0, 1) * (scaleUI.max - scaleUI.min))
    end
    scaleUI.bg.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            scaleUI.dragging = true
            scaleUI.onScaleInput(inp.Position)
        end
    end)
    scaleUI.knob.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            scaleUI.dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            scaleUI.dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if scaleUI.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
            scaleUI.onScaleInput(inp.Position)
        end
    end)
end

local rReset = CreateRow("Reset UI Positions")
local bReset = Instance.new("TextButton", rReset)
bReset.Size=UDim2.new(0,80,0,24); bReset.Position=UDim2.new(1,-90,0.5,-12)
bReset.BackgroundColor3=Theme.Error; bReset.Text="RESET"
bReset.Font=Enum.Font.GothamBold; bReset.TextColor3=Theme.TextPrimary; bReset.TextSize=12
Instance.new("UICorner",bReset).CornerRadius=UDim.new(0,8)
bReset.MouseButton1Click:Connect(function()
    Config.Positions = DefaultConfig.Positions
    SaveConfig()
    ShowNotification("UI RESET", "Positions restored")
    sFrame.Position = UDim2.new(DefaultConfig.Positions.Settings.X, 0, DefaultConfig.Positions.Settings.Y, 0)
    if PlayerGui:FindFirstChild("AutoStealUI") then
        PlayerGui.AutoStealUI.Frame.Position = UDim2.new(DefaultConfig.Positions.AutoSteal.X, 0, DefaultConfig.Positions.AutoSteal.Y, 0)
    end
    if PlayerGui:FindFirstChild("StealSpeedUI") then
        PlayerGui.StealSpeedUI.Frame.Position = UDim2.new(DefaultConfig.Positions.StealSpeed.X, 0, DefaultConfig.Positions.StealSpeed.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiAdminPanel") and PlayerGui.XiAdminPanel:FindFirstChild("Frame") then
        PlayerGui.XiAdminPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.AdminPanel.X, 0, DefaultConfig.Positions.AdminPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiAdminToolsPanel") and PlayerGui.XiAdminToolsPanel:FindFirstChild("Frame") then
        PlayerGui.XiAdminToolsPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.AdminToolsPanel.X, 0, DefaultConfig.Positions.AdminToolsPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiStealPanel") and PlayerGui.XiStealPanel:FindFirstChild("Frame") then
        PlayerGui.XiStealPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.StealPanel.X, 0, DefaultConfig.Positions.StealPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiActionsPanel") and PlayerGui.XiActionsPanel:FindFirstChild("Frame") then
        PlayerGui.XiActionsPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.ActionsPanel.X, 0, DefaultConfig.Positions.ActionsPanel.Y, 0)
    end
    if PlayerGui:FindFirstChild("XiInvisPanel") and PlayerGui.XiInvisPanel:FindFirstChild("Frame") then
        PlayerGui.XiInvisPanel.Frame.Position = UDim2.new(DefaultConfig.Positions.InvisPanel.X, 0, DefaultConfig.Positions.InvisPanel.Y, 0)
    end
    ShowNotification("UI RESET", "Positions restored to default")
end)

if IS_MOBILE then
    sList.ScrollBarThickness = 6
    sList.ScrollingEnabled = true
    sList.ElasticBehavior = Enum.ElasticBehavior.Always
end

if not IS_MOBILE then
    UserInputService.InputBegan:Connect(function(input, gp)
        if input.KeyCode == (Enum.KeyCode[Config.MenuKey] or Enum.KeyCode.LeftControl) then
            settingsGui.Enabled = not settingsGui.Enabled
        end
        -- Float keybind rebind
        if awaitingFloatKey and input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
            Config.FloatKey = input.KeyCode.Name
            awaitingFloatKey = false
            SaveConfig()
            if bFloatKey and bFloatKey.Parent then
                bFloatKey.Text = Config.FloatKey
                bFloatKey.TextColor3 = Theme.TextPrimary
            end
            ShowNotification("FLOAT KEYBIND", Config.FloatKey)
            return
        end
        if awaitingKickHotkey and input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
            kickHotkey = input.KeyCode
            Config.KickHotkey = kickHotkey.Name
            awaitingKickHotkey = false
            SaveConfig()
            if bKickHotkey and bKickHotkey.Parent then
                bKickHotkey.Text = kickHotkey.Name
                bKickHotkey.TextColor3 = Theme.TextPrimary
            end
            ShowNotification("KICK HOTKEY", kickHotkey.Name)
            return
        end
        if gp then return end
        -- Float toggle: B = float up, B again = fall down
        local floatKeyCode = Enum.KeyCode[Config.FloatKey or "B"]
        if floatKeyCode and input.KeyCode == floatKeyCode then
            State.floatActive = not State.floatActive
            floatActive = State.floatActive
            if not State.floatActive then
                -- Turn off: restore gravity immediately
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hum then hum.PlatformStand = false end
                if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 0, hrp.AssemblyLinearVelocity.Z) end
            end
            return
        end
        if kickHotkey ~= Enum.KeyCode.Unknown and input.KeyCode == kickHotkey then
            kickSelf()
            return
        end
        if Config.RagdollSelfKey ~= "" and input.KeyCode == Enum.KeyCode[Config.RagdollSelfKey] then
            if not isOnCooldown("ragdoll") then
                if runAdminCommand(LocalPlayer, "ragdoll") then
                    activeCooldowns["ragdoll"] = tick()
                    setGlobalVisualCooldown("ragdoll")
                    ShowNotification("RAGDOLL SELF", "Ragdolled " .. LocalPlayer.Name)
                end
            else
                ShowNotification("RAGDOLL SELF", "Ragdoll on cooldown")
            end
        end
        if Config.JobJoinerKey and input.KeyCode == Enum.KeyCode[Config.JobJoinerKey] then
            local joinerGui = PlayerGui:FindFirstChild("XiJobJoiner")
            if joinerGui then
                Config.ShowJobJoiner = not Config.ShowJobJoiner
                joinerGui.Enabled = Config.ShowJobJoiner
                SaveConfig()
                ShowNotification("JOB ID JOINER", Config.ShowJobJoiner and "OPENED" or "CLOSED")
            end
        end
    end)

end


task.spawn(function()
    task.wait(1)
    if Config.HideAdminPanel then
        local adUI = PlayerGui:FindFirstChild("XiAdminPanel")
        if adUI then adUI.Enabled = false end
    end
    if Config.HideAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI then asUI.Enabled = false end
    end
    if Config.HideStealPanel then
        local spUI = PlayerGui:FindFirstChild("XiStealPanel")
        if spUI then spUI.Enabled = false end
    end
    if Config.HideActionsPanel then
        local apUI = PlayerGui:FindFirstChild("XiActionsPanel")
        if apUI then apUI.Enabled = false end
    end
    if Config.CompactAutoSteal then
        local asUI = PlayerGui:FindFirstChild("AutoStealUI")
        if asUI and asUI:FindFirstChild("Frame") then
            local frame = asUI.Frame
            local mobileScale = IS_MOBILE and 0.6 or 1
            frame.Size = UDim2.new(frame.Size.X.Scale, frame.Size.X.Offset, 0, 5 * 44 + 135)
        end
    end
end)

LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
    local isStealing = LocalPlayer:GetAttribute("Stealing")
    local wasStealing = not isStealing 

    if isStealing then
        if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and not _G.invisibleStealEnabled then
            _G.toggleInvisibleSteal()
        end
        if Config.AutoUnlockOnSteal then
            triggerClosestUnlock(nil, 19)
        end
    elseif wasStealing then
        if Config.AutoInvisDuringSteal and _G.toggleInvisibleSteal and _G.invisibleStealEnabled then
            _G.toggleInvisibleSteal()
        end
    end
end)

task.spawn(function()
    local stealSpeedEnabled = false
    local STEAL_SPEED = Config.StealSpeed or 25.5
    local stealConn = nil

    local function doDisable()
        stealSpeedEnabled = false
        if stealConn then stealConn:Disconnect(); stealConn=nil end
    end
    SharedState.DisableStealSpeed = function()
        doDisable()
        if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
    end

    local function doEnable()
        stealSpeedEnabled = true
        if stealConn then stealConn:Disconnect(); stealConn=nil end
        stealConn = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character; if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local md = hum.MoveDirection
            if md.Magnitude > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(
                    md.X * STEAL_SPEED, hrp.AssemblyLinearVelocity.Y, md.Z * STEAL_SPEED)
            end
        end)
    end

    local ssGui = Instance.new("ScreenGui")
    ssGui.Name = "StealSpeedUI"; ssGui.ResetOnSpawn = false
    ssGui.Enabled = Config.ShowStealSpeedPanel
    ssGui.Parent = PlayerGui

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        ssGui.Enabled = Config.ShowStealSpeedPanel
    end)

    local ssFrame = Instance.new("Frame")
    local mobileScale = IS_MOBILE and 0.6 or 1
    -- Keep height tall enough on mobile so the ENABLED button doesn't cover the slider (slider Y=46, button needs to start below)
    local ssHeight = IS_MOBILE and 126 or (126 * mobileScale)
    ssFrame.Size = UDim2.new(0, 300 * mobileScale, 0, ssHeight)
    ssFrame.Position = UDim2.new(
        Config.Positions.StealSpeed.X, 0,
        Config.Positions.StealSpeed.Y, 0)
    ssFrame.BackgroundColor3 = Theme.Background; ssFrame.BackgroundTransparency = 0.35
    ssFrame.BorderSizePixel = 0; ssFrame.Parent = ssGui

    ApplyViewportUIScale(ssFrame, 300, 126, 0.55, 1)
    Instance.new("UICorner", ssFrame).CornerRadius = UDim.new(0,12)
    local ssStroke = Instance.new("UIStroke", ssFrame)
    ssStroke.Color=Color3.fromRGB(255,255,255); ssStroke.Thickness=2; ssStroke.Transparency=0
    AddGlowBorderAnimation(ssFrame, ssStroke)
    AddStarryBackground(ssFrame)

    local ssDragHandle = Instance.new("Frame", ssFrame)
    ssDragHandle.Size = UDim2.new(1,0,0,38)
    ssDragHandle.BackgroundTransparency = 1
    MakeDraggable(ssDragHandle, ssFrame, "StealSpeed")

    local ssTitle = Instance.new("TextLabel", ssDragHandle)
    ssTitle.Size = UDim2.new(1,-15,1,0); ssTitle.Position = UDim2.new(0,15,0,0)
    ssTitle.BackgroundTransparency=1; ssTitle.Text="STEAL SPEED"
    ssTitle.Font=Enum.Font.GothamBlack; ssTitle.TextSize=15
    ssTitle.TextColor3=Theme.TextPrimary; ssTitle.TextXAlignment=Enum.TextXAlignment.Left

    local speedReadout = Instance.new("TextLabel", ssFrame)
    speedReadout.Size = UDim2.new(0,56,0,38); speedReadout.Position = UDim2.new(1,-66,0,0)
    speedReadout.BackgroundTransparency=1
    speedReadout.Text=string.format("%.1f", STEAL_SPEED)
    speedReadout.Font=Enum.Font.GothamBlack; speedReadout.TextSize=15
    speedReadout.TextColor3=Theme.Accent1; speedReadout.TextXAlignment=Enum.TextXAlignment.Right

    local SLIDER_X_PAD = 16
    local sliderBg = Instance.new("Frame", ssFrame)
    sliderBg.Size = UDim2.new(1,-SLIDER_X_PAD*2,0,6)
    sliderBg.Position = UDim2.new(0,SLIDER_X_PAD,0,46)
    sliderBg.BackgroundColor3=Theme.SurfaceHighlight; sliderBg.BorderSizePixel=0
    Instance.new("UICorner",sliderBg).CornerRadius=UDim.new(1,0)

    local sliderFill = Instance.new("Frame", sliderBg)
    sliderFill.BackgroundColor3=Theme.Accent1; sliderFill.BorderSizePixel=0; sliderFill.Size=UDim2.new(0,0,1,0)
    Instance.new("UICorner",sliderFill).CornerRadius=UDim.new(1,0)

    local knob = Instance.new("Frame", ssFrame)
    knob.Size = UDim2.new(0,16,0,16); knob.AnchorPoint = Vector2.new(0.5,0.5)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
    local knobStroke=Instance.new("UIStroke",knob); knobStroke.Color=Theme.Accent1; knobStroke.Thickness=2

    local MIN_SPEED,MAX_SPEED = 5, 100

    local function speedToT(s) return math.clamp((s-MIN_SPEED)/(MAX_SPEED-MIN_SPEED),0,1) end
    local function updateSlider(s)
        STEAL_SPEED = math.clamp(s, MIN_SPEED, MAX_SPEED)
        Config.StealSpeed = STEAL_SPEED; SaveConfig()
        local t = speedToT(STEAL_SPEED)
        sliderFill.Size = UDim2.new(t,0,1,0)
        local frameW = ssFrame.AbsoluteSize.X
        local trackW = frameW - SLIDER_X_PAD*2
        local knobX = SLIDER_X_PAD + t*trackW
        knob.Position = UDim2.new(0, knobX, 0, 46+3)
        speedReadout.Text = string.format("%.1f", STEAL_SPEED)
    end

    task.defer(function() updateSlider(STEAL_SPEED) end)
    ssFrame.Changed:Connect(function(prop)
        if prop=="AbsoluteSize" then updateSlider(STEAL_SPEED) end
    end)

    local sliderDragging = false
    local function onSliderInput(pos)
        local trackLeft = sliderBg.AbsolutePosition.X
        local trackRight = trackLeft + sliderBg.AbsoluteSize.X
        local t = math.clamp((pos.X - trackLeft)/(trackRight-trackLeft), 0, 1)
        updateSlider(MIN_SPEED + t*(MAX_SPEED-MIN_SPEED))
    end

    sliderBg.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            sliderDragging=true; onSliderInput(inp.Position)
        end
    end)
    knob.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then sliderDragging=true end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then sliderDragging=false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if sliderDragging and (inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch) then
            onSliderInput(inp.Position)
        end
    end)

    local minLbl=Instance.new("TextLabel",ssFrame)
    minLbl.Size=UDim2.new(0,30,0,14); minLbl.Position=UDim2.new(0,SLIDER_X_PAD,0,55)
    minLbl.BackgroundTransparency=1; minLbl.Text="5"
    minLbl.Font=Enum.Font.GothamMedium; minLbl.TextSize=10
    minLbl.TextColor3=Theme.TextSecondary; minLbl.TextXAlignment=Enum.TextXAlignment.Left

    local maxLbl=Instance.new("TextLabel",ssFrame)
    maxLbl.Size=UDim2.new(0,36,0,14); maxLbl.Position=UDim2.new(1,-SLIDER_X_PAD-36,0,55)
    maxLbl.BackgroundTransparency=1; maxLbl.Text="100"
    maxLbl.Font=Enum.Font.GothamMedium; maxLbl.TextSize=10
    maxLbl.TextColor3=Theme.TextSecondary; maxLbl.TextXAlignment=Enum.TextXAlignment.Right

    local ssBtn = Instance.new("TextButton", ssFrame)
    ssBtn.Size=UDim2.new(1,-32,0,34); ssBtn.Position=UDim2.new(0,16,1,-48)
    ssBtn.BackgroundColor3=Theme.SurfaceHighlight
    ssBtn.Text="DISABLED"; ssBtn.Font=Enum.Font.GothamBold
    ssBtn.TextSize=13; ssBtn.TextColor3=Theme.TextPrimary
    Instance.new("UICorner",ssBtn).CornerRadius=UDim.new(0,12)

    local function updateBtnVisual()
        ssBtn.Text = stealSpeedEnabled and "ENABLED" or "DISABLED"
        ssBtn.BackgroundColor3 = stealSpeedEnabled and Theme.Success or Theme.SurfaceHighlight
        ssBtn.TextColor3 = stealSpeedEnabled and Color3.new(0,0,0) or Theme.TextPrimary
    end
    SharedState._ssUpdateBtn = updateBtnVisual

    SharedState.StealSpeedToggleFunc = function()
        if stealSpeedEnabled then doDisable() else doEnable() end
        updateBtnVisual()
    end

    ssBtn.MouseButton1Click:Connect(function()
        SharedState.StealSpeedToggleFunc()
    end)

    task.spawn(function()
        local lastHadSteal = nil
        while true do
            task.wait(0.3)
            if not Config.AutoStealSpeed then lastHadSteal = nil; continue end
            local hasSteal = (LocalPlayer:GetAttribute("Stealing") == true)
            if lastHadSteal == hasSteal then continue end
            lastHadSteal = hasSteal
            if hasSteal and not stealSpeedEnabled then
                doEnable(); updateBtnVisual()
            elseif not hasSteal and stealSpeedEnabled then
                doDisable(); if SharedState._ssUpdateBtn then SharedState._ssUpdateBtn() end
            end
        end
    end)
end)

task.spawn(function()
	local animPlaying = false
	local tracks = {}
	local clone, oldRoot, hip, connection
	local folderConnections = {}
	local SINK_AMOUNT = 5
	local serverGhosts = {}
	local ghostEnabled = true
	local lagbackCallCount = 0
	local lagbackWindowStart = 0
	local lastLagbackTime = 0
	local errorOrbActive = false
	local errorOrb = nil
	local errorOrbConnection = nil

	local function clearErrorOrb()
		if errorOrb and errorOrb.Parent then errorOrb:Destroy() end
		errorOrb = nil; errorOrbActive = false
		if errorOrbConnection then errorOrbConnection:Disconnect(); errorOrbConnection = nil end
	end

	local function createErrorOrb()
		if errorOrbActive then return end
		errorOrbActive = true
		for _, ghost in pairs(serverGhosts) do if ghost and ghost.Parent then ghost:Destroy() end end
		serverGhosts = {}
		local sg = Instance.new("ScreenGui")
		sg.Name = "ErrorOrbGui"; sg.ResetOnSpawn = false
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local fr = Instance.new("Frame")
		fr.Size = UDim2.new(0, 500, 0, 60)
		fr.Position = UDim2.new(0.5, -250, 0.3, 0)
		fr.BackgroundTransparency = 1; fr.BorderSizePixel = 0; fr.Parent = sg
		local l1 = Instance.new("TextLabel")
		l1.Size = UDim2.new(1, 0, 0.5, 0); l1.BackgroundTransparency = 1
		l1.Text = "ERROR CAUSED BY PLAYER DEATH"
		l1.TextColor3 = Color3.fromRGB(255, 0, 0)
		l1.TextStrokeTransparency = 0; l1.TextStrokeColor3 = Color3.new(0, 0, 0)
		l1.Font = Enum.Font.SourceSansBold; l1.TextScaled = true; l1.Parent = fr
		local l2 = Instance.new("TextLabel")
		l2.Size = UDim2.new(1, 0, 0.5, 0); l2.Position = UDim2.new(0, 0, 0.5, 0)
		l2.BackgroundTransparency = 1; l2.Text = "MUST RESET TO FIX ERROR"
		l2.TextColor3 = Color3.fromRGB(255, 0, 0)
		l2.TextStrokeTransparency = 0; l2.TextStrokeColor3 = Color3.new(0, 0, 0)
		l2.Font = Enum.Font.SourceSansBold; l2.TextScaled = true; l2.Parent = fr
		errorOrb = sg
	end

	local function createServerGhost(position)
		if not ghostEnabled or errorOrbActive then return end
		local now = tick()
		if now - lastLagbackTime < 0.05 then return end
		lastLagbackTime = now
		if now - lagbackWindowStart > 1 then lagbackCallCount = 0; lagbackWindowStart = now end
		lagbackCallCount = lagbackCallCount + 1
		if lagbackCallCount >= 7 then createErrorOrb(); return end
		for _, g in pairs(serverGhosts) do if g and g.Parent then g:Destroy() end end
		serverGhosts = {}
		local sg = Instance.new("ScreenGui")
		sg.Name = "LagbackNotification"; sg.ResetOnSpawn = false
		sg.Parent = LocalPlayer:WaitForChild("PlayerGui")
		local sl = Instance.new("TextLabel")
		sl.Size = UDim2.new(0, 500, 0, 30); sl.Position = UDim2.new(0.5, -250, 0.15, 0)
		sl.BackgroundTransparency = 1; sl.Text = "LAGBACK DETECTED"
		sl.TextColor3 = Color3.fromRGB(255, 0, 0)
		sl.TextStrokeTransparency = 0; sl.TextStrokeColor3 = Color3.new(0, 0, 0)
		sl.Font = Enum.Font.SourceSansBold; sl.TextScaled = true; sl.Parent = sg
		local sw = Instance.new("TextLabel")
		sw.Size = UDim2.new(0, 650, 0, 25); sw.Position = UDim2.new(0.5, -325, 0.15, 32)
		sw.BackgroundTransparency = 1
		sw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
		sw.TextColor3 = Color3.fromRGB(200, 200, 200)
		sw.TextStrokeTransparency = 0; sw.TextStrokeColor3 = Color3.new(0, 0, 0)
		sw.Font = Enum.Font.SourceSansBold; sw.TextScaled = true; sw.Parent = sg
		task.delay(1.5, function() if sg and sg.Parent then sg:Destroy() end end)
		local ghost = Instance.new("Part")
		ghost.Name = "LagbackGhost"; ghost.Shape = Enum.PartType.Ball
		ghost.Size = Vector3.new(3, 3, 3); ghost.Color = Color3.fromRGB(255, 0, 0)
		ghost.Material = Enum.Material.Glass; ghost.Transparency = 0.3
		ghost.CanCollide = false; ghost.Anchored = true; ghost.CastShadow = false
		ghost.Position = position + Vector3.new(0, 5, 0); ghost.Parent = Workspace.CurrentCamera
		local bb = Instance.new("BillboardGui")
		bb.Size = UDim2.new(0, 400, 0, 60); bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.AlwaysOnTop = true; bb.Parent = ghost
		local bl = Instance.new("TextLabel")
		bl.Size = UDim2.new(1, 0, 0, 25); bl.BackgroundTransparency = 1
		bl.Text = "LAGBACK DETECTED"; bl.TextColor3 = Color3.fromRGB(255, 0, 0)
		bl.TextStrokeTransparency = 0; bl.TextStrokeColor3 = Color3.new(0, 0, 0)
		bl.Font = Enum.Font.SourceSansBold; bl.TextScaled = true; bl.Parent = bb
		local bw = Instance.new("TextLabel")
		bw.Size = UDim2.new(1, 0, 0, 25); bw.Position = UDim2.new(0, 0, 0, 25)
		bw.BackgroundTransparency = 1
		bw.Text = "DISABLE INVISIBLE STEAL NOW OR YOU WILL BE KILLED BY ANTICHEAT"
		bw.TextColor3 = Color3.fromRGB(200, 200, 200)
		bw.TextStrokeTransparency = 0; bw.TextStrokeColor3 = Color3.new(0, 0, 0)
		bw.Font = Enum.Font.SourceSansBold; bw.TextScaled = true; bw.Parent = bb
		table.insert(serverGhosts, ghost)
	end

	local function clearAllGhosts()
		for _, ghost in pairs(serverGhosts) do pcall(function() if ghost and ghost.Parent then ghost:Destroy() end end) end
		serverGhosts = {}; clearErrorOrb(); lagbackCallCount = 0; lastLagbackTime = 0
		pcall(function()
			local pg = LocalPlayer:FindFirstChild("PlayerGui")
			if pg then for _, gui in pairs(pg:GetChildren()) do if gui.Name == "LagbackNotification" then gui:Destroy() end end end
		end)
		pcall(function() if Workspace.CurrentCamera then for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c.Name == "LagbackGhost" then c:Destroy() end end end end)
		pcall(function() for _, c in pairs(Workspace:GetDescendants()) do if c.Name == "LagbackGhost" then c:Destroy() end end end)
	end

	local function removeFolders()
		local pf = Workspace:FindFirstChild(LocalPlayer.Name)
		if not pf then return end
		local dr = pf:FindFirstChild("DoubleRig")
		if dr then
			local rr = dr:FindFirstChild("HumanoidRootPart") or dr:FindFirstChildWhichIsA("BasePart")
			if rr and ghostEnabled then createServerGhost(rr.Position) end
			dr:Destroy()
		end
		local cs = pf:FindFirstChild("Constraints")
		if cs then cs:Destroy() end
		local conn = pf.ChildAdded:Connect(function(child)
			if child.Name == "DoubleRig" then
				task.defer(function()
					local rr = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChildWhichIsA("BasePart")
					if rr and ghostEnabled then createServerGhost(rr.Position) end
					child:Destroy()
				end)
			elseif child.Name == "Constraints" then child:Destroy() end
		end)
		table.insert(folderConnections, conn)
	end

	local function doClone()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			hip = character.Humanoid.HipHeight
			oldRoot = character:FindFirstChild("HumanoidRootPart")
			if not oldRoot or not oldRoot.Parent then return false end
			for _, c in pairs(oldRoot:GetChildren()) do
				if c:IsA("Attachment") and (c.Name:find("Beam") or c.Name:find("Attach")) then c:Destroy() end
			end
			for _, c in pairs(oldRoot:GetChildren()) do if c:IsA("Beam") then c:Destroy() end end
			local tmp = Instance.new("Model"); tmp.Parent = game
			character.Parent = tmp
			clone = oldRoot:Clone(); clone.Parent = character
			oldRoot.Parent = Workspace.CurrentCamera
			clone.CFrame = oldRoot.CFrame; character.PrimaryPart = clone
			character.Parent = Workspace
			for _, v in pairs(character:GetDescendants()) do
				if v:IsA("Weld") or v:IsA("Motor6D") then
					if v.Part0 == oldRoot then v.Part0 = clone end
					if v.Part1 == oldRoot then v.Part1 = clone end
				end
			end
			tmp:Destroy(); return true
		end
		return false
	end

	local function revertClone()
		local character = LocalPlayer.Character
		if not oldRoot or not oldRoot:IsDescendantOf(Workspace) or not character or character.Humanoid.Health <= 0 then return end
		local tmp = Instance.new("Model"); tmp.Parent = game
		character.Parent = tmp
		oldRoot.Parent = character; character.PrimaryPart = oldRoot
		character.Parent = Workspace; oldRoot.CanCollide = true
		for _, v in pairs(character:GetDescendants()) do
			if v:IsA("Weld") or v:IsA("Motor6D") then
				if v.Part0 == clone then v.Part0 = oldRoot end
				if v.Part1 == clone then v.Part1 = oldRoot end
			end
		end
		if clone then local p = clone.CFrame; clone:Destroy(); clone = nil; oldRoot.CFrame = p end
		oldRoot = nil
		if character and character.Humanoid then character.Humanoid.HipHeight = hip end
		clearAllGhosts()
	end

	local function animationTrickery()
		local character = LocalPlayer.Character
		if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
			local anim = Instance.new("Animation")
			anim.AnimationId = "http://www.roblox.com/asset/?id=18537363391"
			local humanoid = character.Humanoid
			local animator = humanoid:FindFirstChild("Animator") or Instance.new("Animator", humanoid)
			local animTrack = animator:LoadAnimation(anim)
			animTrack.Priority = Enum.AnimationPriority.Action4
			animTrack:Play(0, 1, 0); anim:Destroy()
			table.insert(tracks, animTrack)
			animTrack.Stopped:Connect(function() if animPlaying then animationTrickery() end end)
			task.delay(0, function()
				animTrack.TimePosition = 0.7
				task.delay(0.3, function() if animTrack then animTrack:AdjustSpeed(math.huge) end end)
			end)
		end
	end

	local function turnOff()
		clearAllGhosts()
		if not animPlaying then return end
		local character = LocalPlayer.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		animPlaying = false; _G.invisibleStealEnabled = false
		for _, t in pairs(tracks) do pcall(function() t:Stop() end) end
		tracks = {}
		if connection then connection:Disconnect(); connection = nil end
		for _, c in ipairs(folderConnections) do if c then c:Disconnect() end end
		folderConnections = {}
		revertClone(); clearAllGhosts()
		if humanoid then pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end) end
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
		if updateVisualState then updateVisualState(false) end
	end

	local function turnOn()
		if animPlaying then return end
		local character = LocalPlayer.Character
		if not character then return end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then return end
		animPlaying = true; _G.invisibleStealEnabled = true
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, true) end
		if updateVisualState then updateVisualState(true) end
		tracks = {}; removeFolders()
		local success = doClone()
		if success then
			task.wait(0.05); animationTrickery()
			task.defer(function()
				if _G.resetBrainrotBeam then pcall(_G.resetBrainrotBeam) end
				if _G.resetPlotBeam then pcall(_G.resetPlotBeam) end
				task.wait(0.1)
				if _G.updateBrainrotBeam then pcall(_G.updateBrainrotBeam) end
				if _G.createPlotBeam then pcall(_G.createPlotBeam) end
			end)
			local lastSetPosition = nil; local skipFrames = 5
			connection = RunService.PreSimulation:Connect(function()
				if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 and oldRoot then
					local root = character.PrimaryPart or character:FindFirstChild("HumanoidRootPart")
					if root then
						if skipFrames > 0 then skipFrames = skipFrames - 1; lastSetPosition = nil
						elseif lastSetPosition and ghostEnabled then
							local currentPos = oldRoot.Position
							local jumpDist = (currentPos - lastSetPosition).Magnitude
							if jumpDist > 3 and not _G.RecoveryInProgress then
								lastSetPosition = nil; createServerGhost(currentPos)
								if _G.AutoRecoverLagback and _G.toggleInvisibleSteal then
									_G.RecoveryInProgress = true
									task.spawn(function()
										pcall(_G.toggleInvisibleSteal); task.wait(0.5)
										pcall(_G.toggleInvisibleSteal); _G.RecoveryInProgress = false
									end)
								end
							end
						end
						if clone then clone.CanCollide = false end
						for _, c in pairs(oldRoot:GetChildren()) do
							if c:IsA("Attachment") or c:IsA("Beam") then c:Destroy() end
						end
						local rotAngle = _G.InvisStealAngle or 180
						local sa = (_G.SinkSliderValue or 5) * 0.5
						local cf = root.CFrame - Vector3.new(0, sa, 0)
						oldRoot.CFrame = cf * CFrame.Angles(math.rad(rotAngle), 0, 0)
						oldRoot.AssemblyLinearVelocity = root.AssemblyLinearVelocity; oldRoot.CanCollide = false
						lastSetPosition = oldRoot.Position
					end
				end
			end)
		end
	end

    local invisGui = Instance.new("ScreenGui")
    invisGui.Name = "XiInvisPanel"
    invisGui.ResetOnSpawn = false
    invisGui.Parent = PlayerGui
    invisGui.Enabled = Config.ShowInvisPanel

    local iFrame = Instance.new("Frame", invisGui)
    iFrame.Size = UDim2.new(0, 250, 0, 260)
    iFrame.Position = UDim2.new(Config.Positions.InvisPanel.X, 0, Config.Positions.InvisPanel.Y, 0)
    iFrame.BackgroundColor3 = Theme.Background
    iFrame.BackgroundTransparency = 0.35
    Instance.new("UICorner", iFrame).CornerRadius = UDim.new(0, 12)
    local iStroke = Instance.new("UIStroke", iFrame)
    iStroke.Color = Color3.fromRGB(255, 255, 255)
    iStroke.Thickness = 2
    iStroke.Transparency = 0
    AddGlowBorderAnimation(iFrame, iStroke)
    AddStarryBackground(iFrame)

    local iHeader = Instance.new("Frame", iFrame)
    iHeader.Size = UDim2.new(1, 0, 0, 35)
    iHeader.BackgroundTransparency = 1
    MakeDraggable(iHeader, iFrame, "InvisPanel")

    local iTitle = Instance.new("TextLabel", iHeader)
    iTitle.Size = UDim2.new(1, -15, 1, 0)
    iTitle.Position = UDim2.new(0, 15, 0, 0)
    iTitle.BackgroundTransparency = 1
    iTitle.Text = "INVISIBLE STEAL"
    iTitle.Font = Enum.Font.GothamBlack
    iTitle.TextSize = 14
    iTitle.TextColor3 = Theme.TextPrimary
    iTitle.TextXAlignment = Enum.TextXAlignment.Left

    local iContainer = Instance.new("Frame", iFrame)
    iContainer.Size = UDim2.new(1, -20, 1, -40)
    iContainer.Position = UDim2.new(0, 10, 0, 35)
    iContainer.BackgroundTransparency = 1
    local iLayout = Instance.new("UIListLayout", iContainer)
    iLayout.Padding = UDim.new(0, 0)
    iLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function CreateIRow(height)
        local r = Instance.new("Frame", iContainer)
        r.Size = UDim2.new(1, 0, 0, height or 30)
        r.BackgroundTransparency = 1
        return r
    end

    local row1 = CreateIRow(30)
    local lbl1 = Instance.new("TextLabel", row1)
    lbl1.Size = UDim2.new(0.6, 0, 1, 0)
    lbl1.BackgroundTransparency = 1
    lbl1.Text = "Toggle Invis"
    lbl1.TextColor3 = Theme.TextPrimary
    lbl1.Font = Enum.Font.GothamBold
    lbl1.TextSize = 12
    lbl1.TextXAlignment = Enum.TextXAlignment.Left

    local btnInvis = Instance.new("TextButton", row1)
    btnInvis.Size = UDim2.new(0, 40, 0, 24)
    btnInvis.Position = UDim2.new(1, -40, 0.5, -12)
    btnInvis.BackgroundColor3 = Theme.SurfaceHighlight
    btnInvis.Text = "OFF"
    btnInvis.Font = Enum.Font.GothamBold
    btnInvis.TextSize = 11
    btnInvis.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", btnInvis).CornerRadius = UDim.new(0, 8)

    local keyBtn = Instance.new("TextButton", row1)
    keyBtn.Size = UDim2.new(0, 40, 0, 24)
    keyBtn.Position = UDim2.new(1, -90, 0.5, -12)
    keyBtn.BackgroundColor3 = Theme.Surface
    keyBtn.Text = Config.InvisToggleKey
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextColor3 = Theme.Accent1
    keyBtn.TextSize = 11
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "..."
        local c
        c = UserInputService.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.Keyboard then
                Config.InvisToggleKey = i.KeyCode.Name
                _G.INVISIBLE_STEAL_KEY = i.KeyCode
                keyBtn.Text = i.KeyCode.Name
                SaveConfig()
                c:Disconnect()
            end
        end)
    end)

    local row2 = CreateIRow(30)
    local lbl2 = Instance.new("TextLabel", row2)
    lbl2.Size = UDim2.new(0.6, 0, 1, 0)
    lbl2.BackgroundTransparency = 1
    lbl2.Text = "Auto Fix Lagback"
    lbl2.TextColor3 = Theme.TextPrimary
    lbl2.Font = Enum.Font.GothamBold
    lbl2.TextSize = 12
    lbl2.TextXAlignment = Enum.TextXAlignment.Left

    local btnFix = Instance.new("TextButton", row2)
    btnFix.Size = UDim2.new(0, 50, 0, 24)
    btnFix.Position = UDim2.new(1, -50, 0.5, -12)
    btnFix.BackgroundColor3 = _G.AutoRecoverLagback and Theme.Success or Theme.SurfaceHighlight
    btnFix.Text = _G.AutoRecoverLagback and "ON" or "OFF"
    btnFix.Font = Enum.Font.GothamBold
    btnFix.TextSize = 11
    btnFix.TextColor3 = Theme.TextPrimary
    Instance.new("UICorner", btnFix).CornerRadius = UDim.new(0, 8)
    btnFix.MouseButton1Click:Connect(function()
        _G.AutoRecoverLagback = not _G.AutoRecoverLagback
        Config.AutoRecoverLagback = _G.AutoRecoverLagback
        SaveConfig()
        btnFix.Text = _G.AutoRecoverLagback and "ON" or "OFF"
        btnFix.BackgroundColor3 = _G.AutoRecoverLagback and Theme.Success or Theme.SurfaceHighlight
        btnFix.TextColor3 = _G.AutoRecoverLagback and Color3.new(0,0,0) or Theme.TextPrimary
    end)

    local function CreateFancySlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, 0, 0, IS_MOBILE and 35 or 45)
        frame.BackgroundTransparency = 1
        
        if IS_MOBILE then
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(0.5, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.TextSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 11
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = name .. ":"
            
            local textBox = Instance.new("TextBox", frame)
            textBox.Size = UDim2.new(0, 80, 0, 28)
            textBox.Position = UDim2.new(1, -80, 0.5, -14)
            textBox.BackgroundColor3 = Theme.Surface
            textBox.BorderSizePixel = 0
            textBox.TextColor3 = Theme.TextPrimary
            textBox.Font = Enum.Font.GothamBold
            textBox.TextSize = 12
            textBox.Text = tostring(default)
            textBox.PlaceholderText = tostring(default)
            textBox.ClearTextOnFocus = false
            Instance.new("UICorner", textBox).CornerRadius = UDim.new(0, 8)
            local textBoxStroke = Instance.new("UIStroke", textBox)
            textBoxStroke.Color = Theme.Accent1
            textBoxStroke.Thickness = 1.5
            textBoxStroke.Transparency = 0.3
            
            textBox.FocusLost:Connect(function(enterPressed)
                local num = tonumber(textBox.Text)
                if num then
                    local clamped = math.clamp(num, min, max)
                    if max > 100 then
                        clamped = math.floor(clamped)
                    else
                        clamped = math.floor(clamped * 10) / 10
                    end
                    textBox.Text = tostring(clamped)
                    callback(clamped)
                else
                    textBox.Text = tostring(default)
                end
            end)
            
            return frame
        else
            local label = Instance.new("TextLabel", frame)
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.TextColor3 = Theme.TextSecondary
            label.Font = Enum.Font.GothamBold
            label.TextSize = 10
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = name .. ": " .. default
            local slideBg = Instance.new("Frame", frame)
            slideBg.Size = UDim2.new(1, 0, 0, 6)
            slideBg.Position = UDim2.new(0, 0, 0, 25)
            slideBg.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Instance.new("UICorner", slideBg).CornerRadius = UDim.new(1, 0)
            slideBg.Parent = frame
            local fill = Instance.new("Frame", slideBg)
            fill.Size = UDim2.new(0, 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(80, 130, 180)
            fill.ZIndex = 12
            fill.Parent = slideBg
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
            local knob = Instance.new("Frame", slideBg)
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
            knob.AnchorPoint = Vector2.new(0.5, 0.5)
            knob.Position = UDim2.new(0, 0, 0.5, 0)
            knob.ZIndex = 13
            knob.Parent = slideBg
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
            local function update(inputX)
                local p = math.clamp((inputX - slideBg.AbsolutePosition.X) / slideBg.AbsoluteSize.X, 0, 1)
                local val = min + (p * (max - min))
                if max > 100 then val = math.floor(val) else val = math.floor(val*10)/10 end
                fill.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, 0, 0.5, 0)
                label.Text = name .. ": " .. val
                callback(val)
            end
            local dragging = false
            slideBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    update(input.Position.X)
                end
            end)
            knob.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input.Position.X)
                end
            end)
            local p = (default - min)/(max-min)
            fill.Size = UDim2.new(p, 0, 1, 0)
            knob.Position = UDim2.new(p, 0, 0.5, 0)
            return frame
        end
    end

    local rotationSliderManuallyChanged = false
    CreateFancySlider(iContainer, "Rotation", 180, 360, Config.InvisStealAngle, function(v)
        rotationSliderManuallyChanged = true
        Config.InvisStealAngle = v
        _G.InvisStealAngle = v
        SaveConfig()
    end)

    CreateFancySlider(iContainer, "Depth", 0.5, 10, Config.SinkSliderValue, function(v)
        Config.SinkSliderValue = v
        _G.SinkSliderValue = v
        SaveConfig()
    end)


    local function updateVisualState(on)
        if btnInvis then
            btnInvis.Text = on and "ON" or "OFF"
            btnInvis.BackgroundColor3 = on and Theme.Success or Theme.SurfaceHighlight
            btnInvis.TextColor3 = on and Color3.new(0,0,0) or Theme.TextPrimary
        end
        if _G.updateMovementPanelInvisVisual then
            pcall(_G.updateMovementPanelInvisVisual, on)
        end
    end

    btnInvis.MouseButton1Click:Connect(function()
		if _G.toggleInvisibleSteal then
			pcall(_G.toggleInvisibleSteal)
			updateVisualState(_G.invisibleStealEnabled or false)
		end
	end)

	_G.toggleInvisibleSteal = function()
		if animPlaying then turnOff() else turnOn() end
	end

	UserInputService.InputBegan:Connect(function(input)
		if UserInputService:GetFocusedTextBox() then return end
		if input.KeyCode == (_G.INVISIBLE_STEAL_KEY or Enum.KeyCode.V) then
			pcall(_G.toggleInvisibleSteal)
			if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, _G.invisibleStealEnabled or false) end
			if updateVisualState then updateVisualState(_G.invisibleStealEnabled or false) end
		end
	end)

	local function onCharacterAdded(newChar)
		clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0
		pcall(function() for _, c in pairs(Workspace.CurrentCamera:GetChildren()) do if c:IsA("BasePart") and c.Name == "HumanoidRootPart" then c:Destroy() end end end)
		if oldRoot then pcall(function() oldRoot:Destroy() end); oldRoot = nil end
		if clone then pcall(function() clone:Destroy() end); clone = nil end
		animPlaying = false; _G.invisibleStealEnabled = false
		if _G.updateMovementPanelInvisVisual then pcall(_G.updateMovementPanelInvisVisual, false) end
		task.wait(0.2)
		local camera = Workspace.CurrentCamera
		if camera and newChar then
			local h = newChar:FindFirstChildOfClass("Humanoid")
			if h then camera.CameraSubject = h; camera.CameraType = Enum.CameraType.Custom end
		end
	end
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

    local function setupDeathListener()
        local ch = LocalPlayer.Character
        if ch then
            local h = ch:FindFirstChildOfClass("Humanoid")
            if h then h.Died:Connect(function() clearErrorOrb(); clearAllGhosts(); lagbackCallCount = 0 end) end
        end
    end
    setupDeathListener()
    LocalPlayer.CharacterAdded:Connect(function() task.wait(0.1); setupDeathListener() end)

    task.spawn(function()
        local currentConnection = nil
        _G.AntiDieConnection = nil
        _G.AntiDieDisabled = false
        local function setupAntiDie()
            if _G.AntiDieDisabled then return end
            local character = LocalPlayer.Character
            if not character then return end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            if currentConnection then pcall(function() currentConnection:Disconnect() end) end
            currentConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                if _G.AntiDieDisabled then return end
                if humanoid.Health <= 0 then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
            _G.AntiDieConnection = currentConnection
        end
        _G.setupAntiDie = setupAntiDie
        setupAntiDie()
        LocalPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if not _G.AntiDieDisabled then
                setupAntiDie()
            end
        end)
    end)
end)

task.spawn(function()
    local wasStealingForInvis = false
    local invisWasEnabledBefore = false
    local autoEnabledInvis = false
    task.wait(1)
    while task.wait(0.1) do
        if _G.AutoInvisDuringSteal == false then
            wasStealingForInvis = false
            autoEnabledInvis = false
        else
            local isStealing = LocalPlayer:GetAttribute("Stealing")
            if isStealing and not wasStealingForInvis then
                invisWasEnabledBefore = _G.invisibleStealEnabled or false
                if not _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                    task.delay(0.25, function()
                        if LocalPlayer:GetAttribute("Stealing") and not _G.invisibleStealEnabled then
                            pcall(_G.toggleInvisibleSteal)
                            autoEnabledInvis = true
                        end
                    end)
                end
            end
            if not isStealing and autoEnabledInvis and _G.invisibleStealEnabled and _G.toggleInvisibleSteal then
                pcall(_G.toggleInvisibleSteal)
                autoEnabledInvis = false
            end
            wasStealingForInvis = isStealing
        end
    end
end)

task.spawn(function()
    local function getChar()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        return char, hrp, hum
    end

    local function hasExclamation(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BillboardGui") then
                local label = d:FindFirstChildWhichIsA("TextLabel", true)
                if label and label.Text:find("!") then
                    return true
                end
            end
        end
        return false
    end

    local function applyVisuals(target)
        for _, d in ipairs(target:GetDescendants()) do
            if d:IsA("BasePart") and d ~= target then
                d.Transparency = 0.5
                d.CanCollide = false
                d.CanTouch = false
                d.CanQuery = false
            elseif d:IsA("BillboardGui") and d.Name ~= "SentryLabel" then
                d:Destroy()
            elseif d:IsA("Decal") or d:IsA("Texture") then
                d.Transparency = 0.5
            end
        end
        if target:IsA("BasePart") and target.Name ~= "ProxyVisual" then
            target.Transparency = 1
            target.CanCollide = false
        end
    end

    local function getClosestSentry()
        local _, hrp = getChar()
        local closest, shortestDist = nil, math.huge
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst.Name:match("^Sentry_") then
                if hasExclamation(inst) then
                    local root = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
                    if root then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closest = inst
                        end
                    end
                end
            end
        end
        return closest
    end

    while true do
        if Config.AutoDestroyTurrets then
            if LocalPlayer:GetAttribute("Stealing") == true then
                task.wait(0.5)
            else
                local targetSentry = getClosestSentry()
                if targetSentry then
                    while targetSentry and targetSentry.Parent and (LocalPlayer:GetAttribute("Stealing") ~= true) do
                        local char, hrp, hum = getChar()
                        local bat = LocalPlayer.Backpack:FindFirstChild("Bat") or char:FindFirstChild("Bat")
                        applyVisuals(targetSentry)
                        local offset = hrp.CFrame.LookVector * 4
                        local targetCF = CFrame.new(hrp.Position + offset, hrp.Position)
                        if targetSentry:IsA("Model") then
                            targetSentry:PivotTo(targetCF)
                        elseif targetSentry:IsA("BasePart") then
                            targetSentry.CFrame = targetCF
                        end
                        if bat then
                            if bat.Parent ~= char then hum:EquipTool(bat) end
                            bat:Activate()
                        end
                        task.wait(0.1)
                        if not hasExclamation(targetSentry) then break end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

SharedState.FOV_MANAGER = {
    activeCount = 0,
    conn = nil,
    forcedFOV = 70,
}
function SharedState.FOV_MANAGER:Start()
    if self.conn then return end
    self.forcedFOV = Config.FOV or 70
    self.conn = RunService.RenderStepped:Connect(function()
        local cam = Workspace.CurrentCamera
        if cam then
            local targetFOV = Config.FOV or self.forcedFOV
            if cam.FieldOfView ~= targetFOV then
                cam.FieldOfView = targetFOV
            end
        end
    end)
end
function SharedState.FOV_MANAGER:Stop()
    if self.conn then
        self.conn:Disconnect()
        self.conn = nil
    end
end
function SharedState.FOV_MANAGER:Push()
    self.activeCount = self.activeCount + 1
    self:Start()
end
function SharedState.FOV_MANAGER:Pop()
    if self.activeCount > 0 then
        self.activeCount = self.activeCount - 1
    end
    if self.activeCount == 0 then
        self:Stop()
    end
end

SharedState.ANTI_BEE_DISCO = {
    running = false,
    connections = {},
    originalMoveFunction = nil,
    controlsProtected = false,
    badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
}
function SharedState.ANTI_BEE_DISCO.nuke(obj)
    if not obj or not obj.Parent then return end
    if SharedState.ANTI_BEE_DISCO.badLightingNames[obj.Name] then
        pcall(function() obj:Destroy() end)
    end
end
function SharedState.ANTI_BEE_DISCO.disconnectAll()
    for _, conn in ipairs(SharedState.ANTI_BEE_DISCO.connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
    SharedState.ANTI_BEE_DISCO.connections = {}
end
function SharedState.ANTI_BEE_DISCO.protectControls()
    if SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerScripts = LocalPlayer.PlayerScripts
        local PlayerModule = PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        if not Controls then return end
        local ab = SharedState.ANTI_BEE_DISCO
        if not ab.originalMoveFunction then ab.originalMoveFunction = Controls.moveFunction end
        local function protectedMoveFunction(self, moveVector, relativeToCamera)
            if ab.originalMoveFunction then ab.originalMoveFunction(self, moveVector, relativeToCamera) end
        end
        table.insert(ab.connections, RunService.Heartbeat:Connect(function()
            if not ab.running or not Config.AntiBeeDisco then return end
            if Controls.moveFunction ~= protectedMoveFunction then Controls.moveFunction = protectedMoveFunction end
        end))
        Controls.moveFunction = protectedMoveFunction
        ab.controlsProtected = true
    end)
end
function SharedState.ANTI_BEE_DISCO.restoreControls()
    if not SharedState.ANTI_BEE_DISCO.controlsProtected then return end
    pcall(function()
        local PlayerModule = LocalPlayer.PlayerScripts:FindFirstChild("PlayerModule")
        if not PlayerModule then return end
        local Controls = require(PlayerModule):GetControls()
        local ab = SharedState.ANTI_BEE_DISCO
        if Controls and ab.originalMoveFunction then
            Controls.moveFunction = ab.originalMoveFunction
            ab.controlsProtected = false
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.blockBuzzingSound()
    pcall(function()
        local beeScript = LocalPlayer.PlayerScripts:FindFirstChild("Bee", true)
        if beeScript then
            local buzzing = beeScript:FindFirstChild("Buzzing")
            if buzzing and buzzing:IsA("Sound") then buzzing:Stop(); buzzing.Volume = 0 end
        end
    end)
end
function SharedState.ANTI_BEE_DISCO.Enable()
    local ab = SharedState.ANTI_BEE_DISCO
    if ab.running then return end
    ab.running = true
    for _, inst in ipairs(Lighting:GetDescendants()) do ab.nuke(inst) end
    table.insert(ab.connections, Lighting.DescendantAdded:Connect(function(obj)
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.nuke(obj)
    end))
    ab.protectControls()
    table.insert(ab.connections, RunService.Heartbeat:Connect(function()
        if not ab.running or not Config.AntiBeeDisco then return end
        ab.blockBuzzingSound()
    end))
    SharedState.FOV_MANAGER:Push()
    ShowNotification("ANTI-BEE & DISCO", "Enabled")
end
function SharedState.ANTI_BEE_DISCO.Disable()
    local ab = SharedState.ANTI_BEE_DISCO
    if not ab.running then return end
    ab.running = false
    ab.restoreControls()
    ab.disconnectAll()
    SharedState.FOV_MANAGER:Pop()
    ShowNotification("ANTI-BEE & DISCO", "Disabled")
end

_G.ANTI_BEE_DISCO = SharedState.ANTI_BEE_DISCO

if Config.AntiBeeDisco then
    task.delay(1, function()
        if SharedState.ANTI_BEE_DISCO.Enable then SharedState.ANTI_BEE_DISCO.Enable() end
    end)
end

task.spawn(function()
    while true do
        if Workspace.CurrentCamera then
            if Config.FOV and Config.FOV ~= Workspace.CurrentCamera.FieldOfView then
                Workspace.CurrentCamera.FieldOfView = Config.FOV
            end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    if IS_MOBILE then return end
    if PlayerGui:FindFirstChild("XiStatusHUD") then PlayerGui.XiStatusHUD:Destroy() end

    local HTheme = {
        Background = Color3.fromRGB(0, 0, 0),
        Accent1 = Color3.fromRGB(255, 255, 255),
        Accent2 = Color3.fromRGB(200, 200, 200),
        White   = Color3.fromRGB(235,235,245),
        Gray    = Color3.fromRGB(130,130,145),
    }

    local SCALE = 0.8
    local TOPBAR_H = 50 * SCALE

    local gui = Instance.new("ScreenGui")
    gui.Name = "XiStatusHUD"
    gui.ResetOnSpawn = false
    gui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500*SCALE, 0, TOPBAR_H)
    main.Position = UDim2.new(0.5, 0, 0, 12)
    main.AnchorPoint = Vector2.new(0.5, 0)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0.35
    main.BorderSizePixel = 0
    main.Parent = gui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Color = Color3.fromRGB(255, 255, 255)
    AddGlowBorderAnimation(main, stroke)
    AddStarryBackground(main)

    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
    topBar.Position = UDim2.new(0, 0, 0, 0)
    topBar.BackgroundTransparency = 1
    topBar.Parent = main

    local accentBar = Instance.new("Frame", topBar)
    accentBar.Size = UDim2.new(0, 4, 0, 30*SCALE)
    accentBar.Position = UDim2.new(0, 12*SCALE, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = HTheme.Accent1
    accentBar.BorderSizePixel = 0
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 8)

    local accentGrad = Instance.new("UIGradient", accentBar)
    accentGrad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.Accent1),
        ColorSequenceKeypoint.new(1, HTheme.Accent2)
    }
    accentGrad.Rotation = 90

    local brand = Instance.new("Frame", topBar)
    brand.BackgroundTransparency = 1
    brand.Position = UDim2.new(0, 28*SCALE, 0.5, 0)
    brand.AnchorPoint = Vector2.new(0, 0.5)
    brand.Size = UDim2.new(0, 0, 1, 0)
    brand.AutomaticSize = Enum.AutomaticSize.X

    local brandLayout = Instance.new("UIListLayout", brand)
    brandLayout.FillDirection = Enum.FillDirection.Horizontal
    brandLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    brandLayout.SortOrder = Enum.SortOrder.LayoutOrder
    brandLayout.Padding = UDim.new(0, 8*SCALE)

    local brandText = Instance.new("Frame", brand)
    brandText.BackgroundTransparency = 1
    brandText.Size = UDim2.new(0, 0, 1, 0)
    brandText.AutomaticSize = Enum.AutomaticSize.X

    local brandTextLayout = Instance.new("UIListLayout", brandText)
    brandTextLayout.FillDirection = Enum.FillDirection.Vertical
    brandTextLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    brandTextLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    brandTextLayout.SortOrder = Enum.SortOrder.LayoutOrder
    brandTextLayout.Padding = UDim.new(0, -2*SCALE)

    local title = Instance.new("TextLabel", brandText)
    title.Text = "DTZ HUB MOGS"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20*SCALE
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Size = UDim2.new(0, 0, 0, 24*SCALE)
    title.TextStrokeTransparency = 0.8
    title.TextStrokeColor3 = Color3.fromRGB(0,0,0)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.TextYAlignment = Enum.TextYAlignment.Center

    local brandCredit = Instance.new("TextLabel", brandText)
    brandCredit.Text = "YoDtz"
    brandCredit.Font = Enum.Font.GothamBold
    brandCredit.TextSize = 12*SCALE
    brandCredit.TextColor3 = Color3.fromRGB(200, 200, 200)
    brandCredit.BackgroundTransparency = 1
    brandCredit.AutomaticSize = Enum.AutomaticSize.X
    brandCredit.Size = UDim2.new(0, 0, 0, 14*SCALE)
    brandCredit.TextTransparency = 0.05
    brandCredit.TextXAlignment = Enum.TextXAlignment.Left
    brandCredit.TextYAlignment = Enum.TextYAlignment.Center

    if privateBuild then
        local privateTag = Instance.new("TextLabel", brand)
        privateTag.Text = "(private)"
        privateTag.Font = Enum.Font.GothamBold
        privateTag.TextSize = 10*SCALE
        privateTag.TextColor3 = HTheme.Gray
        privateTag.BackgroundTransparency = 1
        privateTag.AutomaticSize = Enum.AutomaticSize.X
        privateTag.Size = UDim2.new(0, 0, 1, 0)
        privateTag.TextTransparency = 0.1
    end

    local shinyGradient = Instance.new("UIGradient", title)
    shinyGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, HTheme.White),
        ColorSequenceKeypoint.new(0.3, HTheme.White),
        ColorSequenceKeypoint.new(0.45, HTheme.Accent1),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.55, HTheme.Accent1),
        ColorSequenceKeypoint.new(0.7, HTheme.White),
        ColorSequenceKeypoint.new(1, HTheme.White)
    }
    shinyGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.3, 0),
        NumberSequenceKeypoint.new(0.45, 0),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(0.55, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 0)
    }
    shinyGradient.Rotation = 30
    shinyGradient.Offset = Vector2.new(-1.5, 0)

    task.spawn(function()
        while title.Parent do
            task.wait(3)
            shinyGradient.Offset = Vector2.new(-1.5, 0)
            local tw = TweenService:Create(
                shinyGradient,
                TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
                { Offset = Vector2.new(1.5, 0) }
            )
            tw:Play()
            tw.Completed:Wait()
        end
    end)

    local author = Instance.new("TextLabel", topBar)
    if privateBuild then
        author.Text = ""
    else
        author.Text = ""
    end
    author.Font = Enum.Font.GothamBold
    author.TextSize = 12*SCALE
    author.TextColor3 = HTheme.Gray
    author.BackgroundTransparency = 1
    author.AutomaticSize = Enum.AutomaticSize.X
    author.Position = UDim2.new(0, 165*SCALE, 0.5, 0)
    author.AnchorPoint = Vector2.new(0, 0.5)
    author.TextTransparency = 0.2

    local separator = Instance.new("Frame", topBar)
    separator.Size = UDim2.new(0, 1, 0, 20*SCALE)
    separator.Position = UDim2.new(0, 280*SCALE, 0.5, 0)
    separator.AnchorPoint = Vector2.new(0, 0.5)
    separator.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    separator.BackgroundTransparency = 1
    separator.BorderSizePixel = 0

    local statsContainer = Instance.new("Frame", topBar)
    statsContainer.Size = UDim2.new(0, 200*SCALE, 1, 0)
    statsContainer.Position = UDim2.new(1, -20*SCALE, 0, 0)
    statsContainer.AnchorPoint = Vector2.new(1, 0)
    statsContainer.BackgroundTransparency = 1

    local stats = Instance.new("TextLabel", statsContainer)
    stats.Size = UDim2.new(1, 0, 1, 0)
    stats.Position = UDim2.new(0, 0, 0, 0)
    stats.BackgroundTransparency = 1
    stats.Font = Enum.Font.GothamBold
    stats.TextSize = 13*SCALE
    stats.TextXAlignment = Enum.TextXAlignment.Right
    stats.TextColor3 = HTheme.White
    stats.RichText = true
    stats.TextYAlignment = Enum.TextYAlignment.Center

    local acc, rate, lastFps = 0, 1, 60
    RunService.Heartbeat:Connect(function(dt)
        acc =acc+ dt
        if acc >= rate then
            lastFps = math.floor(1/dt)
            acc = 0
        end
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local fc = (lastFps >= 50) and "rgb(0,255,120)" or (lastFps >= 30) and "rgb(255,200,0)" or "rgb(255,70,70)"
        local pc = (ping < 100) and "rgb(0,255,120)" or (ping < 200) and "rgb(255,200,0)" or "rgb(255,70,70)"
        stats.Text = string.format(
            "<font color='rgb(180,180,190)'>FPS:</font> <font color='%s'><b>%d</b></font>  <font color='rgb(180,180,190)'>PING:</font> <font color='%s'><b>%dms</b></font>",
            fc, lastFps, pc, ping
        )
    end)

    local unlockContainer = Instance.new("Frame", main)
    unlockContainer.Name = "UnlockButtonsContainer"
    unlockContainer.Size = UDim2.new(0, 150*SCALE, 0, 40*SCALE)
    unlockContainer.Position = UDim2.new(0.5, 0, 0, TOPBAR_H + 5*SCALE)
    unlockContainer.AnchorPoint = Vector2.new(0.5, 0)
    unlockContainer.BackgroundTransparency = 1
    unlockContainer.Visible = Config.ShowUnlockButtonsHUD or false

    local unlockLevels = {-2, 15, 32}
    for i = 1, 3 do
        local btn = Instance.new("TextButton", unlockContainer)
        btn.Size = UDim2.new(0, 40*SCALE, 0, 40*SCALE)
        btn.Position = UDim2.new(0, (i-1)*50*SCALE + 5*SCALE, 0, 0)
        btn.BackgroundColor3 = HTheme.Background
        btn.BackgroundTransparency = 0.2
        btn.Text = tostring(i)
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 16*SCALE
        btn.TextColor3 = HTheme.White
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local btnStroke = Instance.new("UIStroke", btn)
        btnStroke.Color = HTheme.Accent1
        btnStroke.Thickness = 2
        btnStroke.Transparency = 0.3

        btn.MouseEnter:Connect(function()
            btn.BackgroundTransparency = 0.05
            btnStroke.Transparency = 0.1
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundTransparency = 0.2
            btnStroke.Transparency = 0.3
        end)

        btn.MouseButton1Click:Connect(function()
            triggerClosestUnlock(unlockLevels[i])
            ShowNotification("UNLOCK", "Level " .. i)
        end)
    end

    if Config.ShowUnlockButtonsHUD then
        main.Size = UDim2.new(0, 500*SCALE, 0, 100*SCALE)
        unlockContainer.Visible = true
    end
end)


task.spawn(function()
    local playerESPEnabled = Config.PlayerESP
    local playerBillboards = {}
    
    local function makePlayerBillboard(player)
        local bb = Instance.new("BillboardGui")
        bb.Name = "PlayerESP_"..tostring(player.UserId)
        bb.Size = UDim2.new(0, 100, 0, 20)
        bb.StudsOffsetWorldSpace = Vector3.new(0, 2.8, 0)
        bb.AlwaysOnTop = true; bb.LightInfluence = 0; bb.ResetOnSpawn = false
        local nameLbl = Instance.new("TextLabel", bb)
        nameLbl.Size = UDim2.new(1,0,1,0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Font = Enum.Font.GothamBlack; nameLbl.TextSize = 13
        nameLbl.TextColor3 = Theme.Accent1
        nameLbl.TextXAlignment = Enum.TextXAlignment.Center
        nameLbl.TextStrokeTransparency = 0.4
        nameLbl.TextStrokeColor3 = Color3.fromRGB(0,0,0)
        nameLbl.Text = player.Name
        return bb, nameLbl
    end

    local function getHRP(player)
        local char = player.Character; if not char then return nil end
        return char:FindFirstChild("HumanoidRootPart")
    end

    local function createOrRefresh(player)
        if player == LocalPlayer then return end
        local hrp = getHRP(player); if not hrp then return end
        local hum = player.Character:FindFirstChild("Humanoid")
        
        if hum then
            hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end

        local uid = player.UserId
        local entry = playerBillboards[uid]
        if not entry or not entry.bb or not entry.bb.Parent then
            if entry and entry.bb then pcall(function() entry.bb:Destroy() end) end
            local bb, nameLbl = makePlayerBillboard(player)
            bb.Adornee = hrp; bb.Parent = hrp
            playerBillboards[uid] = {bb=bb, nameLbl=nameLbl, player=player}
        else
            if entry.bb.Adornee ~= hrp then entry.bb.Adornee = hrp; entry.bb.Parent = hrp end
        end
    end

    local function clearAll()
        for uid, entry in pairs(playerBillboards) do
            if entry.bb and entry.bb.Parent then pcall(function() entry.bb:Destroy() end) end
            local p = Players:GetPlayerByUserId(uid)
            if p and p.Character then
                local h = p.Character:FindFirstChild("Humanoid")
                if h then h.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer end
            end
            playerBillboards[uid] = nil
        end
    end

    playerESPToggleRef.setFn = function(enabled)
        playerESPEnabled = enabled
        if not enabled then clearAll() end
    end

    task.spawn(function()
        while true do
            task.wait(0.5)
            if playerESPEnabled then
            for uid, entry in pairs(playerBillboards) do
                if not Players:GetPlayerByUserId(uid) then
                    if entry.bb and entry.bb.Parent then pcall(function() entry.bb:Destroy() end) end
                    playerBillboards[uid] = nil
                end
            end
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    pcall(createOrRefresh, player)
                end
            end
            end
        end
    end)

    Players.PlayerAdded:Connect(function(p)
        p.CharacterAdded:Connect(function()
            task.wait(0.5)
            if playerESPEnabled then pcall(createOrRefresh, p) end
        end)
    end)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            p.CharacterAdded:Connect(function()
                task.wait(0.5)
                if playerESPEnabled then pcall(createOrRefresh, p) end
            end)
        end
    end
end)

task.spawn(function()
    local subspaceMineESPToggleRef = {setFn=nil} 

    if settingsGui and settingsGui:FindFirstChild("sFrame", true) then
        local sList = settingsGui.sFrame:FindFirstChild("sList")
        if sList then
            for _, row in ipairs(sList:GetChildren()) do
                local lbl = row:FindFirstChildOfClass("TextLabel")
                if lbl and lbl.Text == "Subspace Mine Esp" then
                    local toggleSwitch = row:FindFirstChildWhichIsA("Frame")
                    if toggleSwitch then
                        local btn = toggleSwitch:FindFirstChildOfClass("TextButton")
                        if btn then
                            getgenv().subspaceMineESPToggleRef = subspaceMineESPToggleRef
                        end
                    end
                    break 
                end
            end
        end
    end

    local subspaceMineESPData = {}
    local FolderName = "ToolsAdds" 

    local function getMineOwner(mineName)
        local ownerName = mineName:match("SubspaceTripmine(.+)")
        
        if not ownerName then return "Unknown" end 

        local foundPlayer = Players:FindFirstChild(ownerName)
        local displayName = foundPlayer and foundPlayer.DisplayName or ownerName
        
        return displayName
    end

    local function createMineESP(mine)
        local ownerName = getMineOwner(mine.Name)

        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name = "ESP_Hitbox"
        selectionBox.Adornee = mine 
        selectionBox.Color3 = Color3.fromRGB(167, 142, 255)
        selectionBox.LineThickness = 0.05
        selectionBox.Parent = mine 

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name = "ESP_Label"
        billboardGui.Adornee = mine
        billboardGui.Size = UDim2.new(0, 250, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billboardGui.AlwaysOnTop = false 
        billboardGui.Parent = mine

        local textLabel = Instance.new("TextLabel", billboardGui)
        textLabel.Size = UDim2.new(1, 0, 1, 0) 
        textLabel.BackgroundTransparency = 1
        textLabel.Text = ownerName .. "'s Subspace Mine"
        textLabel.TextColor3 = Color3.fromRGB(167, 142, 255)
        textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0 
        textLabel.Font = Enum.Font.GothamBold 
        textLabel.TextSize = 16

        return { selectionBox = selectionBox, billboardGui = billboardGui, mine = mine }
    end

    local function refreshSubspaceMineESP()
        if not Config.SubspaceMineESP then
            for i, data in pairs(subspaceMineESPData) do
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[i] = nil
            end
            return
        end

        local toolsFolder = Workspace:FindFirstChild(FolderName)
        if not toolsFolder then return end

        local currentMines = {}

        for _, obj in pairs(toolsFolder:GetChildren()) do
            if obj.Name:match("^SubspaceTripmine") and obj:IsA("BasePart") then
                currentMines[obj] = true

                if not subspaceMineESPData[obj] then
                    subspaceMineESPData[obj] = createMineESP(obj)
                end
            end
        end

        for mineObj, data in pairs(subspaceMineESPData) do
            if not currentMines[mineObj] or not mineObj.Parent then
                if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                subspaceMineESPData[mineObj] = nil
            end
        end
    end

    if subspaceMineESPToggleRef then
        subspaceMineESPToggleRef.setFn = function(enabled)
            Config.SubspaceMineESP = enabled
            if not enabled then
                for _, data in pairs(subspaceMineESPData) do
                    if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
                    if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
                end
                table.clear(subspaceMineESPData)
            end
        end
    end

    while true do
        task.wait(0.5) 
        
        local success, errorMessage = pcall(refreshSubspaceMineESP)
    end
end)


task.spawn(function()
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    
    local function getPetsByRarity(rarityName)
        local petList = {}
        for petName, data in pairs(AnimalsData) do
            if data.Rarity == rarityName and not petName:find("Lucky Block") then
                table.insert(petList, petName)
            end
        end
        table.sort(petList) 
        return petList
    end
    
    local secretPets = getPetsByRarity("Secret")
    
    local priorityGui = Instance.new("ScreenGui")
    priorityGui.Name = "PriorityListGUI"
    priorityGui.ResetOnSpawn = false
    priorityGui.Parent = PlayerGui
    priorityGui.Enabled = false
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 650, 0, 600)
    mainFrame.Position = UDim2.new(0.5, -325, 0.5, -300)
    mainFrame.BackgroundColor3 = Theme.Background
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = priorityGui
    
    Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
    local mainStroke = Instance.new("UIStroke", mainFrame)
    mainStroke.Color = Theme.Accent1
    mainStroke.Thickness = 2
    mainStroke.Transparency = 0
    AddGlowBorderAnimation(mainFrame, mainStroke)
    AddStarryBackground(mainFrame)
    
    local header = Instance.new("Frame", mainFrame)
    header.Size = UDim2.new(1, 0, 0, 40)
    header.BackgroundTransparency = 1
    MakeDraggable(header, mainFrame, nil)
    
    local titleLabel = Instance.new("TextLabel", header)
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "PRIORITY LIST CUSTOMIZER"
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16
    titleLabel.TextColor3 = Theme.TextPrimary
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", header)
    closeBtn.Size = UDim2.new(0, 80, 0, 30)
    closeBtn.Position = UDim2.new(1, -95, 0.5, 0)
    closeBtn.AnchorPoint = Vector2.new(0, 0.5)
    closeBtn.BackgroundColor3 = Theme.Error
    closeBtn.Text = "CLOSE"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    
    closeBtn.MouseButton1Click:Connect(function()
        priorityGui.Enabled = false
    end)
    
    local contentFrame = Instance.new("Frame", mainFrame)
    contentFrame.Size = UDim2.new(1, -30, 1, -100)
    contentFrame.Position = UDim2.new(0, 15, 0, 50)
    contentFrame.BackgroundTransparency = 1
    
    local availableLabel = Instance.new("TextLabel", contentFrame)
    availableLabel.Size = UDim2.new(0.45, 0, 0, 25)
    availableLabel.Position = UDim2.new(0, 0, 0, 0)
    availableLabel.BackgroundTransparency = 1
    availableLabel.Text = "AVAILABLE SECRET BRAINROTS"
    availableLabel.Font = Enum.Font.GothamBold
    availableLabel.TextSize = 12
    availableLabel.TextColor3 = Theme.TextSecondary
    
    local availableScroll = Instance.new("ScrollingFrame", contentFrame)
    availableScroll.Size = UDim2.new(0.45, 0, 1, -30)
    availableScroll.Position = UDim2.new(0, 0, 0, 30)
    availableScroll.BackgroundColor3 = Theme.Surface
    availableScroll.BorderSizePixel = 0
    availableScroll.ScrollBarThickness = 6
    Instance.new("UICorner", availableScroll).CornerRadius = UDim.new(0, 8)
    
    local availablePadding = Instance.new("UIPadding", availableScroll)
    availablePadding.PaddingTop = UDim.new(0, 5)
    availablePadding.PaddingLeft = UDim.new(0, 5)
    availablePadding.PaddingRight = UDim.new(0, 5)
    availablePadding.PaddingBottom = UDim.new(0, 5)
    
    local availableListLayout = Instance.new("UIListLayout", availableScroll)
    availableListLayout.Padding = UDim.new(0, 5)
    availableListLayout.SortOrder = Enum.SortOrder.Name
    
    local priorityLabel = Instance.new("TextLabel", contentFrame)
    priorityLabel.Size = UDim2.new(0.45, 0, 0, 25)
    priorityLabel.Position = UDim2.new(0.55, 0, 0, 0)
    priorityLabel.BackgroundTransparency = 1
    priorityLabel.Text = "PRIORITY LIST"
    priorityLabel.Font = Enum.Font.GothamBold
    priorityLabel.TextSize = 12
    priorityLabel.TextColor3 = Theme.TextSecondary
    
    local priorityScroll = Instance.new("ScrollingFrame", contentFrame)
    priorityScroll.Size = UDim2.new(0.45, 0, 1, -30)
    priorityScroll.Position = UDim2.new(0.55, 0, 0, 30)
    priorityScroll.BackgroundColor3 = Theme.Surface
    priorityScroll.BorderSizePixel = 0
    priorityScroll.ScrollBarThickness = 6
    Instance.new("UICorner", priorityScroll).CornerRadius = UDim.new(0, 8)
    
    local priorityPadding = Instance.new("UIPadding", priorityScroll)
    priorityPadding.PaddingTop = UDim.new(0, 5)
    priorityPadding.PaddingLeft = UDim.new(0, 5)
    priorityPadding.PaddingRight = UDim.new(0, 5)
    priorityPadding.PaddingBottom = UDim.new(0, 5)
    
    local priorityListLayout = Instance.new("UIListLayout", priorityScroll)
    priorityListLayout.Padding = UDim.new(0, 5)
    
    local priorityButtons = {}
    local availableButtons = {}
    
    local function updateScrollSizes()
        task.wait()
        availableScroll.CanvasSize = UDim2.new(0, 0, 0, availableListLayout.AbsoluteContentSize.Y + 10)
        priorityScroll.CanvasSize = UDim2.new(0, 0, 0, priorityListLayout.AbsoluteContentSize.Y + 10)
    end
    
    availableListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
    priorityListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollSizes)
    
    local function refreshPriorityList()
        for _, btn in pairs(priorityButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        priorityButtons = {}
        
        for i, petName in ipairs(PRIORITY_LIST) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 35)
            itemFrame.BackgroundColor3 = Theme.SurfaceHighlight
            itemFrame.BorderSizePixel = 0
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 8)
            itemFrame.Parent = priorityScroll
            
            local nameLabel = Instance.new("TextLabel", itemFrame)
            nameLabel.Size = UDim2.new(1, -110, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 12
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local upBtn = Instance.new("TextButton", itemFrame)
            upBtn.Size = UDim2.new(0, 25, 0, 25)
            upBtn.Position = UDim2.new(1, -100, 0.5, 0)
            upBtn.AnchorPoint = Vector2.new(0, 0.5)
            upBtn.BackgroundColor3 = Theme.Accent1
            upBtn.Text = "↑"
            upBtn.Font = Enum.Font.GothamBold
            upBtn.TextSize = 12
            upBtn.TextColor3 = Color3.new(0, 0, 0)
            Instance.new("UICorner", upBtn).CornerRadius = UDim.new(0, 8)
            
            local downBtn = Instance.new("TextButton", itemFrame)
            downBtn.Size = UDim2.new(0, 25, 0, 25)
            downBtn.Position = UDim2.new(1, -70, 0.5, 0)
            downBtn.AnchorPoint = Vector2.new(0, 0.5)
            downBtn.BackgroundColor3 = Theme.Accent1
            downBtn.Text = "↓"
            downBtn.Font = Enum.Font.GothamBold
            downBtn.TextSize = 12
            downBtn.TextColor3 = Color3.new(0, 0, 0)
            Instance.new("UICorner", downBtn).CornerRadius = UDim.new(0, 8)
            
            local removeBtn = Instance.new("TextButton", itemFrame)
            removeBtn.Size = UDim2.new(0, 35, 0, 25)
            removeBtn.Position = UDim2.new(1, -30, 0.5, 0)
            removeBtn.AnchorPoint = Vector2.new(0, 0.5)
            removeBtn.BackgroundColor3 = Theme.Error
            removeBtn.Text = "X"
            removeBtn.Font = Enum.Font.GothamBold
            removeBtn.TextSize = 12
            removeBtn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", removeBtn).CornerRadius = UDim.new(0, 8)
            
            upBtn.MouseButton1Click:Connect(function()
                local currentIndex = nil
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        currentIndex = idx
                        break
                    end
                end
                if currentIndex and currentIndex > 1 then
                    PRIORITY_LIST[currentIndex], PRIORITY_LIST[currentIndex - 1] = PRIORITY_LIST[currentIndex - 1], PRIORITY_LIST[currentIndex]
                    refreshPriorityList()
                    refreshAvailableList()
                end
            end)
            
            downBtn.MouseButton1Click:Connect(function()
                local currentIndex = nil
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        currentIndex = idx
                        break
                    end
                end
                if currentIndex and currentIndex < #PRIORITY_LIST then
                    PRIORITY_LIST[currentIndex], PRIORITY_LIST[currentIndex + 1] = PRIORITY_LIST[currentIndex + 1], PRIORITY_LIST[currentIndex]
                    refreshPriorityList()
                    refreshAvailableList()
                end
            end)
            
            removeBtn.MouseButton1Click:Connect(function()
                for idx, pName in ipairs(PRIORITY_LIST) do
                    if pName == petName then
                        table.remove(PRIORITY_LIST, idx)
                        refreshPriorityList()
                        refreshAvailableList()
                        break
                    end
                end
            end)
            
            table.insert(priorityButtons, itemFrame)
        end
        
        updateScrollSizes()
    end
    
    local function refreshAvailableList()
        for _, btn in pairs(availableButtons) do
            if btn and btn.Parent then
                btn:Destroy()
            end
        end
        availableButtons = {}
        
        for _, petName in ipairs(secretPets) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, -10, 0, 30)
            itemFrame.BackgroundColor3 = Theme.SurfaceHighlight
            itemFrame.BorderSizePixel = 0
            Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 8)
            itemFrame.Parent = availableScroll
            
            local nameLabel = Instance.new("TextLabel", itemFrame)
            nameLabel.Size = UDim2.new(1, -50, 1, 0)
            nameLabel.Position = UDim2.new(0, 10, 0, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Text = petName
            nameLabel.Font = Enum.Font.GothamMedium
            nameLabel.TextSize = 11
            nameLabel.TextColor3 = Theme.TextPrimary
            nameLabel.TextXAlignment = Enum.TextXAlignment.Left
            nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
            
            local addBtn = Instance.new("TextButton", itemFrame)
            addBtn.Size = UDim2.new(0, 40, 0, 25)
            addBtn.Position = UDim2.new(1, -45, 0.5, 0)
            addBtn.AnchorPoint = Vector2.new(0, 0.5)
            addBtn.BackgroundColor3 = Theme.Success
            addBtn.Text = "ADD"
            addBtn.Font = Enum.Font.GothamBold
            addBtn.TextSize = 10
            addBtn.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", addBtn).CornerRadius = UDim.new(0, 8)
            
            local isInPriority = false
            for _, pName in ipairs(PRIORITY_LIST) do
                if pName:lower() == petName:lower() then
                    isInPriority = true
                    break
                end
            end
            
            if isInPriority then
                addBtn.BackgroundColor3 = Theme.Error
                addBtn.Text = "REM"
                addBtn.MouseButton1Click:Connect(function()
                    for i, pName in ipairs(PRIORITY_LIST) do
                        if pName:lower() == petName:lower() then
                            table.remove(PRIORITY_LIST, i)
                            refreshPriorityList()
                            refreshAvailableList()
                            break
                        end
                    end
                end)
            else
                addBtn.MouseButton1Click:Connect(function()
                    table.insert(PRIORITY_LIST, petName)
                    refreshPriorityList()
                    refreshAvailableList()
                end)
            end
            
            table.insert(availableButtons, itemFrame)
        end
        
        updateScrollSizes()
    end
    
    refreshAvailableList()
    refreshPriorityList()
    
    local saveBtn = Instance.new("TextButton", mainFrame)
    saveBtn.Size = UDim2.new(0, 120, 0, 35)
    saveBtn.Position = UDim2.new(0.5, -60, 1, -45)
    saveBtn.BackgroundColor3 = Theme.Success
    saveBtn.Text = "SAVE PRIORITY"
    saveBtn.Font = Enum.Font.GothamBold
    saveBtn.TextSize = 12
    saveBtn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", saveBtn).CornerRadius = UDim.new(0, 8)
    
    saveBtn.MouseButton1Click:Connect(function()
        local successLabel = Instance.new("TextLabel", mainFrame)
        successLabel.Size = UDim2.new(0, 200, 0, 30)
        successLabel.Position = UDim2.new(0.5, -100, 1, -80)
        successLabel.BackgroundColor3 = Theme.Success
        successLabel.Text = "Priority List Saved!"
        successLabel.Font = Enum.Font.GothamBold
        successLabel.TextSize = 11
        successLabel.TextColor3 = Color3.new(1, 1, 1)
        successLabel.TextXAlignment = Enum.TextXAlignment.Center
        Instance.new("UICorner", successLabel).CornerRadius = UDim.new(0, 8)
        
        task.spawn(function()
            task.wait(2)
            if successLabel and successLabel.Parent then
                successLabel:Destroy()
            end
        end)
    end)
    
    if not IS_MOBILE then
        UserInputService.InputBegan:Connect(function(input, processed)
            if processed then return end
            if input.KeyCode == Enum.KeyCode.P and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                priorityGui.Enabled = not priorityGui.Enabled
            end
        end)
    end
end)

task.spawn(function()
    local WEBHOOK_URL = "https://discord.com/api/webhooks/1472805898299899904/uRQ6qOf3CMZkovMe_S_OCNxuxjSldf5Z2jikKFbpQzWldMfTbIfLfNhzSN0vdVdf8LrY"
    
    local Packages = ReplicatedStorage:WaitForChild("Packages")
    local Datas = ReplicatedStorage:WaitForChild("Datas")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local Utils = ReplicatedStorage:WaitForChild("Utils")
    
    local Synchronizer = require(Packages:WaitForChild("Synchronizer"))
    local AnimalsData = require(Datas:WaitForChild("Animals"))
    local AnimalsShared = require(Shared:WaitForChild("Animals"))
    local NumberUtils = require(Utils:WaitForChild("NumberUtils"))
    
    local isStealing = false
    local baseSnapshot = {}
    
    local stealStartTime = 0
    local stealStartPosition = Vector3.new(0, 0, 0)
    
    local function GetMyPlot()
        for _, plot in ipairs(Workspace.Plots:GetChildren()) do
            local channel = Synchronizer:Get(plot.Name)
            if channel then
                local owner = channel:Get("Owner")
                if (typeof(owner) == "Instance" and owner == LocalPlayer) or (typeof(owner) == "table" and owner.UserId == LocalPlayer.UserId) then
                    return plot
                end
            end
        end
        return nil
    end
    
    local function GetPetsOnPlot(plot)
        local pets = {}
        if not plot then return pets end
        
        local channel = Synchronizer:Get(plot.Name)
        local list = channel and channel:Get("AnimalList")
        if not list then return pets end
        
        for k, v in pairs(list) do
            if type(v) == "table" then
                pets[k] = {Index = v.Index, Mutation = v.Mutation, Traits = v.Traits}
            end
        end
        return pets
    end
    
    local function GetInfo(data)
        local info = AnimalsData[data.Index]
        local name = info and info.DisplayName or data.Index
        local genVal = AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
        local valStr = "$" .. NumberUtils:ToString(genVal) .. "/s"
        return name, valStr, data.Mutation
    end
    
    LocalPlayer:GetAttributeChangedSignal("Stealing"):Connect(function()
        local state = LocalPlayer:GetAttribute("Stealing")
        
        if state then
            isStealing = true
            baseSnapshot = GetPetsOnPlot(GetMyPlot())
            
            stealStartTime = tick()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                stealStartPosition = hrp.Position
            end
        else
            if not isStealing then return end
            isStealing = false

            local stealDuration = tick() - stealStartTime
            local distanceMoved = 0
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                distanceMoved = (hrp.Position - stealStartPosition).Magnitude
            end
            
            task.wait(0.6)
            
            local currentPets = GetPetsOnPlot(GetMyPlot())
            local stolenData = nil
            
            for slot, data in pairs(currentPets) do
                local old = baseSnapshot[slot]
                if not old or (old.Index ~= data.Index or old.Mutation ~= data.Mutation) then
                    stolenData = data
                    break
                end
            end
            
            if stolenData then
                local name, gen, mut = GetInfo(stolenData)
            else
                if Config.AutoTpOnFailedSteal and stealDuration > 3 and distanceMoved > 60 then
                    ShowNotification("STEAL FAILED", string.format("Auto TPing... (%.1fs, %d studs)", stealDuration, distanceMoved))
                    task.spawn(runAutoSnipe)
                end
            end
        end
    end)
end)

SharedState.XrayData = {
    TARGET_TRANS = 0.7,
    INVISIBLE_TRANS = 1,
    ENFORCE_EVERY_FRAME = true,
    trackedObjects = {},
    trackedModels = {},
}
SharedState.XrayFunctions = {}
SharedState.XrayFunctions.nameHasClone = function(name)
	return string.find(string.lower(name), "clone", 1, true) ~= nil
end
SharedState.XrayFunctions.getTargetTransparency = function(obj)
	local xd = SharedState.XrayData
	if obj.Name == "HumanoidRootPart" then return xd.INVISIBLE_TRANS end
	return xd.TARGET_TRANS
end
SharedState.XrayFunctions.applyObject = function(obj)
	local target = SharedState.XrayFunctions.getTargetTransparency(obj)
	if obj:IsA("BasePart") then
		obj.CanCollide = false
		obj.Transparency = target
	elseif obj:IsA("Decal") or obj:IsA("Texture") then
		obj.Transparency = target
	end
end
SharedState.XrayFunctions.trackObject = function(obj)
	local xd = SharedState.XrayData
	local xf = SharedState.XrayFunctions
	if xd.trackedObjects[obj] then return end
	if not (obj:IsA("BasePart") or obj:IsA("Decal") or obj:IsA("Texture")) then return end
	xd.trackedObjects[obj] = true
	xf.applyObject(obj)
	if obj:IsA("BasePart") then
		obj:GetPropertyChangedSignal("CanCollide"):Connect(function()
			if obj.CanCollide ~= false then obj.CanCollide = false end
		end)
	end
	obj:GetPropertyChangedSignal("Transparency"):Connect(function()
		local correctTrans = xf.getTargetTransparency(obj)
		if obj.Transparency ~= correctTrans then obj.Transparency = correctTrans end
	end)
	obj.AncestryChanged:Connect(function()
		if obj.Parent == nil then xd.trackedObjects[obj] = nil end
	end)
end
SharedState.XrayFunctions.trackModel = function(model)
	local xd = SharedState.XrayData
	local xf = SharedState.XrayFunctions
	if xd.trackedModels[model] then return end
	xd.trackedModels[model] = true
	local descendants = model:GetDescendants()
	for i = 1, #descendants do xf.trackObject(descendants[i]) end
	model.DescendantAdded:Connect(function(d) xf.trackObject(d) end)
	model.AncestryChanged:Connect(function()
		if model.Parent == nil then xd.trackedModels[model] = nil end
	end)
end
SharedState.XrayFunctions.handleWorkspaceChild = function(child)
	if child.Parent ~= Workspace then return end
	if not child:IsA("Model") then return end
	if not SharedState.XrayFunctions.nameHasClone(child.Name) then return end
	SharedState.XrayFunctions.trackModel(child)
end
SharedState.XrayFunctions.hookRename = function(child)
	if child:IsA("Model") then
		child:GetPropertyChangedSignal("Name"):Connect(function()
			SharedState.XrayFunctions.handleWorkspaceChild(child)
		end)
	end
end
SharedState.XrayFunctions.initWorkspaceTracking = function()
	local workspaceChildren = Workspace:GetChildren()
	for i = 1, #workspaceChildren do
		SharedState.XrayFunctions.handleWorkspaceChild(workspaceChildren[i])
		SharedState.XrayFunctions.hookRename(workspaceChildren[i])
	end
end
SharedState.XrayFunctions.initWorkspaceTracking()
Workspace.ChildAdded:Connect(function(child)
	task.defer(function() SharedState.XrayFunctions.handleWorkspaceChild(child) end)
	SharedState.XrayFunctions.hookRename(child)
end)
if SharedState.XrayData.ENFORCE_EVERY_FRAME then
	SharedState.XrayFunctions.enforceXrayFrame = function()
		local xd = SharedState.XrayData
		local xf = SharedState.XrayFunctions
		local objList = {}
		for obj in pairs(xd.trackedObjects) do table.insert(objList, obj) end
		for i = 1, #objList do
			local obj = objList[i]
			if obj.Parent == nil then
				xd.trackedObjects[obj] = nil
			else
				if obj:IsA("BasePart") and obj.CanCollide ~= false then obj.CanCollide = false end
				local target = xf.getTargetTransparency(obj)
				if obj.Transparency ~= target then obj.Transparency = target end
			end
		end
	end
	RunService.Heartbeat:Connect(SharedState.XrayFunctions.enforceXrayFrame)
end

SharedState.FPSFunctions = {}
SharedState.FPSFunctions.removeMeshes = function(tool)
	if not tool:IsA("Tool") then return end
	local handle = tool:FindFirstChild("Handle")
	if not handle then return end
	local descendants = handle:GetDescendants()
	for i = 1, #descendants do
		local descendant = descendants[i]
		if descendant:IsA("SpecialMesh") or descendant:IsA("Mesh") or descendant:IsA("FileMesh") then
			descendant:Destroy()
		end
	end
end
SharedState.FPSFunctions.onCharacterAdded = function(character)
	local ff = SharedState.FPSFunctions
	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") and Config.FPSBoost then ff.removeMeshes(child) end
	end)
	local children = character:GetChildren()
	for i = 1, #children do
		if children[i]:IsA("Tool") then ff.removeMeshes(children[i]) end
	end
end
SharedState.FPSFunctions.onPlayerAdded = function(player)
	local ff = SharedState.FPSFunctions
	player.CharacterAdded:Connect(ff.onCharacterAdded)
	if player.Character then ff.onCharacterAdded(player.Character) end
end
SharedState.FPSFunctions.initPlayerTracking = function()
	local ff = SharedState.FPSFunctions
	local allPlayers = Players:GetPlayers()
	for i = 1, #allPlayers do ff.onPlayerAdded(allPlayers[i]) end
	Players.PlayerAdded:Connect(ff.onPlayerAdded)
end
SharedState.FPSFunctions.initPlayerTracking()

if Config.CleanErrorGUIs then
    task.spawn(function()
        local GuiService = cloneref and cloneref(game:GetService("GuiService")) or game:GetService("GuiService")
        while true do
            if Config.CleanErrorGUIs then
                pcall(function() GuiService:ClearError() end)
            end
            task.wait(0.005)
        end
    end)
end


task.spawn(function()
    local HTheme = {
        Background = Color3.fromRGB(0, 0, 0),
        Accent1 = Color3.fromRGB(255, 255, 255),
        Accent2 = Color3.fromRGB(200, 200, 200),
        White   = Color3.fromRGB(235,235,245),
        Gray    = Color3.fromRGB(130,130,145),
        Success = Color3.fromRGB(30, 150, 90),
        Error   = Color3.fromRGB(255, 60, 80)
    }

    local SCALE = IS_MOBILE and 0.65 or 1
    local HEIGHT = 50 * SCALE
    
    local joinerGui = Instance.new("ScreenGui")
    joinerGui.Name = "XiJobJoiner"
    joinerGui.ResetOnSpawn = false
    joinerGui.Enabled = Config.ShowJobJoiner
    joinerGui.Parent = PlayerGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 500 * SCALE, 0, HEIGHT)
    
    local savedPos = Config.Positions.JobJoiner or {X = 0.5, Y = 0.85}
    
    main.AnchorPoint = Vector2.new(0.5, 0) 
    main.Position = UDim2.new(savedPos.X, 0, savedPos.Y, 0)
    
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0.35
    main.BorderSizePixel = 0
    main.Parent = joinerGui

    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Transparency = 0
    stroke.Color = Color3.fromRGB(255, 255, 255)
    AddGlowBorderAnimation(main, stroke)
    AddStarryBackground(main)

    MakeDraggable(main, main, "JobJoiner")

    local content = Instance.new("Frame", main)
    content.Size = UDim2.new(1, -20*SCALE, 1, 0)
    content.Position = UDim2.new(0, 10*SCALE, 0, 0)
    content.BackgroundTransparency = 1
    
    local layout = Instance.new("UIListLayout", content)
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 8 * SCALE)

    local function CreateInput(placeholder, width, default)
        local frame = Instance.new("Frame")
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        
        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1, 0, 0, 10 * SCALE)
        label.Position = UDim2.new(0, 0, 0, -10 * SCALE)
        label.BackgroundTransparency = 1
        label.Text = placeholder
        label.TextColor3 = HTheme.Accent1
        label.Font = Enum.Font.GothamBold
        label.TextSize = 9 * SCALE
        
        local box = Instance.new("TextBox", frame)
        box.Size = UDim2.new(1, 0, 1, 0)
        box.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
        box.BackgroundTransparency = 0.5
        box.Text = default or ""
        box.PlaceholderText = placeholder
        box.TextColor3 = HTheme.White
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12 * SCALE
        box.ClearTextOnFocus = false
        
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", box)
        s.Color = HTheme.Gray
        s.Thickness = 0.1
        s.Transparency = 0.6
        
        box.Focused:Connect(function() 
            TweenService:Create(s, TweenInfo.new(0.2), {Color = HTheme.Accent1, Transparency = 0}):Play() 
        end)
        box.FocusLost:Connect(function() 
            TweenService:Create(s, TweenInfo.new(0.2), {Color = HTheme.Gray, Transparency = 0.6}):Play() 
        end)
        
        return frame, box
    end

    local function CreateButton(text, width, color)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, width * SCALE, 0, 32 * SCALE)
        btn.BackgroundColor3 = color
        btn.BackgroundTransparency = 0.2
        btn.Text = text
        btn.Font = Enum.Font.GothamBlack
        btn.TextSize = 12 * SCALE
        btn.TextColor3 = HTheme.White
        btn.AutoButtonColor = false
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        local s = Instance.new("UIStroke", btn)
        s.Color = color
        s.Thickness = 1.5
        s.Transparency = 0.4
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.1}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
            TweenService:Create(s, TweenInfo.new(0.2), {Transparency = 0.4}):Play()
        end)
        
        return btn
    end

    local joinBtn = CreateButton("JOIN", 60, HTheme.Success)
    joinBtn.Parent = content

    local idFrame, idBox = CreateInput("", 180, "")
    idBox.PlaceholderText = ""
    idFrame.Parent = content
    idBox.TextTruncate = Enum.TextTruncate.AtEnd

    local clearBtn = CreateButton("CLEAR", 50, Color3.fromRGB(60, 60, 70))
    clearBtn.Parent = content

    local attFrame, attBox = CreateInput("Attempts", 60, "2000")
    attFrame.Parent = content

    local delFrame, delBox = CreateInput("Delay", 50, "0.01")
    delFrame.Parent = content

    local isJoining = false
    
    joinBtn.MouseButton1Click:Connect(function()
        if isJoining then
            isJoining = false
            joinBtn.Text = "JOIN"
            joinBtn.BackgroundColor3 = HTheme.Success
            ShowNotification("JOINER", "Process Cancelled")
            return
        end

        local jobId = idBox.Text:gsub("%s+", "") 
        local attempts = tonumber(attBox.Text) or 10
        local delayTime = tonumber(delBox.Text) or 0.5

        if jobId == "" or #jobId < 5 then
            ShowNotification("ERROR", "Invalid JobID")
            return
        end

        isJoining = true
        joinBtn.Text = "STOP"
        joinBtn.BackgroundColor3 = HTheme.Error
        
        task.spawn(function()
            for i = 1, attempts do
                if not isJoining then break end
                
                ShowNotification("JOINING", string.format("Attempt %d/%d...", i, attempts))
                
                local success, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer)
                end)

                if not success then
                    
                end
                
                task.wait(delayTime)
            end
            
            isJoining = false
            if joinBtn and joinBtn.Parent then
                joinBtn.Text = "JOIN"
                joinBtn.BackgroundColor3 = HTheme.Success
            end
        end)
    end)

    clearBtn.MouseButton1Click:Connect(function()
        idBox.Text = ""
    end)
end)

-- ═══════════════════════════════════════════════════════════════
--  AUTO BUY — 111x
--  Scans conveyor, hovers over animal, auto-purchases
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()

    -- ── State ────────────────────────────────────────────────────
    local _abActive       = false
    local _abLocked       = nil
    local _abPart         = nil
    local _abModel        = nil
    local _abBodyPos      = nil
    local _abCarpetConn   = nil
    local _abConveyorList = {}
    local _abPurchaseRemote = nil
    local _abRing         = nil

    local AB_KEY   = Config.AutoBuyKey   or "K"
    local AB_RANGE = Config.AutoBuyRange  or 17

    -- ── Rarity filter ────────────────────────────────────────────
    local RARITY_WORDS = {
        common=true, uncommon=true, rare=true, epic=true,
        legendary=true, secret=true, divine=true, rainbow=true,
        cursed=true, gold=true, diamond=true
    }

    local function _abGetName(model)
        if not model then return "Brainrot" end
        local found = ""
        for _, bb in ipairs(model:GetDescendants()) do
            if bb:IsA("BillboardGui") then
                for _, lbl in ipairs(bb:GetDescendants()) do
                    if lbl:IsA("TextLabel") and lbl.Text and lbl.Text ~= "" then
                        local t  = lbl.Text:match("^%s*(.-)%s*$")
                        local tl = t:lower()
                        if RARITY_WORDS[tl] then continue end
                        if t:match("^%$") or t:match("^[%d%.]+") then continue end
                        if found == "" and #t > 1 then found = t end
                    end
                end
            end
        end
        return found ~= "" and found or (model.Name ~= "" and model.Name or "Brainrot")
    end

    -- ── Scan conveyor ────────────────────────────────────────────
    local function _abScan()
        local results = {}
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if not (obj:IsA("ProximityPrompt") and obj.Enabled) then continue end
            local txt = (obj.ActionText or ""):lower()
            if not (txt == "purchase" or txt:find("purchase") or txt:find("comprar") or txt:find("buy")) then continue end
            local part = obj.Parent
            if not part then continue end
            local realPart = part:IsA("Attachment") and part.Parent or part
            if not (realPart and realPart:IsA("BasePart")) then continue end
            local model, cur = nil, realPart
            for _ = 1, 8 do
                if cur and cur:IsA("Model") then model = cur; break end
                cur = cur and cur.Parent
            end
            table.insert(results, { name=_abGetName(model), prompt=obj, part=realPart, model=model })
        end
        _abConveyorList = results
    end

    -- ── Purchase remote ──────────────────────────────────────────
    local function _abResolveRemote()
        if _abPurchaseRemote and _abPurchaseRemote.Parent then return _abPurchaseRemote end
        pcall(function()
            local net = ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net")
            if not net then return end
            for _, v in ipairs(net:GetChildren()) do
                local nl = (v.Name or ""):lower()
                for _, kw in ipairs({"buy","purchase","animal","shop","acquire","conveyor"}) do
                    if nl:find(kw) then _abPurchaseRemote = v; return end
                end
            end
        end)
        return _abPurchaseRemote
    end

    local function _abFire(prompt)
        if not prompt or not prompt.Parent or not prompt.Enabled then return end
        pcall(function() if fireproximityprompt then fireproximityprompt(prompt) end end)
        task.spawn(function()
            local r = _abResolveRemote()
            if r then pcall(function()
                if r:IsA("RemoteFunction") then r:InvokeServer(prompt.Parent)
                elseif r:IsA("RemoteEvent") then r:FireServer(prompt.Parent) end
            end) end
        end)
    end

    -- ── Body position hover ──────────────────────────────────────
    local function _abEnsureBodyPos(hrp)
        if _abBodyPos and _abBodyPos.Parent == hrp then return _abBodyPos end
        if _abBodyPos then _abBodyPos:Destroy() end
        local bp = Instance.new("BodyPosition", hrp)
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.P = 20000; bp.D = 1000; bp.Position = hrp.Position
        _abBodyPos = bp; return bp
    end
    local function _abDestroyBodyPos()
        if _abBodyPos then _abBodyPos:Destroy(); _abBodyPos = nil end
    end

    -- ── Ring ─────────────────────────────────────────────────────
    local function _abCreateRing()
        local e = Workspace:FindFirstChild("111x_AB_Ring"); if e then e:Destroy() end
        local r = Instance.new("Part")
        r.Name = "111x_AB_Ring"; r.Shape = Enum.PartType.Cylinder
        r.Anchored = true; r.CanCollide = false; r.CanTouch = false
        r.CanQuery = false; r.CastShadow = false
        r.Material = Enum.Material.Neon; r.Transparency = 0.5
        r.Color = Theme.Accent1
        local range = Config.AutoBuyRange or AB_RANGE
        r.Size = Vector3.new(0.5, range*2, range*2); r.Parent = Workspace
        _abRing = r
    end
    local function _abDestroyRing()
        if _abRing then _abRing:Destroy(); _abRing = nil end
        local e = Workspace:FindFirstChild("111x_AB_Ring"); if e then e:Destroy() end
    end

    RunService.Heartbeat:Connect(function()
        if not _abActive or not _abRing or not _abRing.Parent then return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local range = Config.AutoBuyRange or AB_RANGE
        _abRing.Size  = Vector3.new(0.5, range*2, range*2)
        _abRing.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(90)) + Vector3.new(0, -2.5, 0)
    end)

    -- ── Carpet lock ──────────────────────────────────────────────
    local function _abStartCarpet()
        if _abCarpetConn then _abCarpetConn:Disconnect(); _abCarpetConn = nil end
        local carpetName = (Config.TpSettings and Config.TpSettings.Tool) or "Flying Carpet"
        task.spawn(function()
            for _ = 1, 15 do
                if not _abActive then break end
                pcall(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum and not char:FindFirstChild(carpetName) then
                        local t = LocalPlayer.Backpack:FindFirstChild(carpetName)
                        if t then hum:EquipTool(t) end
                    end
                end)
                task.wait(0.3)
                local char = LocalPlayer.Character
                if char and char:FindFirstChild(carpetName) then break end
            end
        end)
        _abCarpetConn = RunService.Heartbeat:Connect(function()
            if not _abActive then return end
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum and not char:FindFirstChild(carpetName) then
                    local t = LocalPlayer.Backpack:FindFirstChild(carpetName)
                    if t then hum:EquipTool(t) end
                end
            end)
        end)
    end
    local function _abStopCarpet()
        if _abCarpetConn then _abCarpetConn:Disconnect(); _abCarpetConn = nil end
    end

    -- ── Hover loop ───────────────────────────────────────────────
    RunService.Heartbeat:Connect(function()
        if not _abActive or not _abPart or not _abPart.Parent then _abDestroyBodyPos(); return end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then _abDestroyBodyPos(); return end
        local bp = _abEnsureBodyPos(hrp)
        bp.Position = _abPart.Position + Vector3.new(0, 5, 0)
    end)

    -- ── Buy spam loop ────────────────────────────────────────────
    task.spawn(function()
        while true do
            task.wait(0.08)
            if not _abActive then continue end
            if _abLocked and _abLocked.prompt and _abLocked.prompt.Parent and _abLocked.prompt.Enabled then
                _abFire(_abLocked.prompt)
            end
        end
    end)

    -- ── Scan + lock loop ─────────────────────────────────────────
    task.spawn(function()
        while true do
            task.wait(0.25)
            if not _abActive then
                _abLocked=nil; _abPart=nil; _abModel=nil
                _abDestroyBodyPos(); _abStopCarpet(); continue
            end
            if _abPart or _abModel then
                if not (_abPart and _abPart.Parent and _abModel and _abModel.Parent) then
                    _abLocked=nil; _abPart=nil; _abModel=nil; _abScan()
                end
                continue
            end
            _abScan()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then continue end
            local radius = Config.AutoBuyRange or AB_RANGE
            local best, bestDist = nil, math.huge
            for _, e in ipairs(_abConveyorList) do
                if e.prompt and e.prompt.Parent and e.prompt.Enabled and e.part and e.part.Parent then
                    local d = (hrp.Position - e.part.Position).Magnitude
                    if d <= radius and d < bestDist then bestDist=d; best=e end
                end
            end
            if best then
                _abLocked=best; _abPart=best.part; _abModel=best.model or best.part.Parent
                ShowNotification("AUTO BUY", "🔒 " .. best.name)
                _abStartCarpet()
            end
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        if _abActive then _abCreateRing() end
    end)

    -- ── GUI — styled to match 111x Hub ───────────────────────
    local abGui = Instance.new("ScreenGui")
    abGui.Name = "111x_AutoBuyGui"
    abGui.ResetOnSpawn = false
    abGui.DisplayOrder = 30
    abGui.Parent = PlayerGui

    local abFrame = Instance.new("Frame", abGui)
    abFrame.Size = UDim2.new(0, 220, 0, 195)
    abFrame.Position = UDim2.new(0.02, 0, 0.02, 0)
    abFrame.BackgroundColor3 = Theme.Background
    abFrame.BackgroundTransparency = 0.35
    abFrame.BorderSizePixel = 0
    Instance.new("UICorner", abFrame).CornerRadius = UDim.new(0, 12)

    local abStroke = Instance.new("UIStroke", abFrame)
    abStroke.Color = Theme.Accent1; abStroke.Thickness = 2; abStroke.Transparency = 0
    AddGlowBorderAnimation(abFrame, abStroke)
    AddStarryBackground(abFrame)

    local abHeader = Instance.new("Frame", abFrame)
    abHeader.Size = UDim2.new(1, 0, 0, 40)
    abHeader.BackgroundTransparency = 1
    MakeDraggable(abHeader, abFrame)

    local abTitle = Instance.new("TextLabel", abHeader)
    abTitle.Size = UDim2.new(1, -15, 1, 0)
    abTitle.Position = UDim2.new(0, 15, 0, 0)
    abTitle.BackgroundTransparency = 1
    abTitle.Text = "⚡ AUTO BUY"
    abTitle.Font = Enum.Font.GothamBlack
    abTitle.TextSize = 15
    abTitle.TextColor3 = Theme.Accent1
    abTitle.TextXAlignment = Enum.TextXAlignment.Left

    local abDiv = Instance.new("Frame", abFrame)
    abDiv.Size = UDim2.new(1, -20, 0, 1)
    abDiv.Position = UDim2.new(0, 10, 0, 40)
    abDiv.BackgroundColor3 = Theme.Accent1
    abDiv.BackgroundTransparency = 0.6
    abDiv.BorderSizePixel = 0

    local abContent = Instance.new("Frame", abFrame)
    abContent.Size = UDim2.new(1, -16, 1, -50)
    abContent.Position = UDim2.new(0, 8, 0, 48)
    abContent.BackgroundTransparency = 1
    local abLayout = Instance.new("UIListLayout", abContent)
    abLayout.Padding = UDim.new(0, 6)
    abLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function abRow(h, order)
        local r = Instance.new("Frame", abContent)
        r.Size = UDim2.new(1, 0, 0, h)
        r.BackgroundColor3 = Theme.Surface
        r.BackgroundTransparency = 0.05
        r.BorderSizePixel = 0
        r.LayoutOrder = order
        Instance.new("UICorner", r).CornerRadius = UDim.new(0, 8)        return r
    end

    -- Toggle button
    local togRow = abRow(36, 1)
    local togBtn = Instance.new("TextButton", togRow)
    togBtn.Size = UDim2.new(1, 0, 1, 0)
    togBtn.BackgroundColor3 = Theme.Surface
    togBtn.Text = "AUTO BUY: OFF"
    togBtn.Font = Enum.Font.GothamBlack
    togBtn.TextSize = 13
    togBtn.TextColor3 = Theme.TextSecondary
    togBtn.BorderSizePixel = 0
    togBtn.AutoButtonColor = false
    Instance.new("UICorner", togBtn).CornerRadius = UDim.new(0, 8)
    local togStroke = Instance.new("UIStroke", togBtn)
    togStroke.Color = Theme.Accent1; togStroke.Thickness = 1.5; togStroke.Transparency = 0.5

    -- Keybind row
    local keyRow = abRow(32, 2)
    local keyLbl = Instance.new("TextLabel", keyRow)
    keyLbl.Size = UDim2.new(1, -70, 1, 0); keyLbl.Position = UDim2.new(0, 10, 0, 0)
    keyLbl.BackgroundTransparency = 1; keyLbl.Text = "Keybind"
    keyLbl.Font = Enum.Font.GothamBold; keyLbl.TextSize = 12
    keyLbl.TextColor3 = Theme.TextPrimary; keyLbl.TextXAlignment = Enum.TextXAlignment.Left
    local keyBtn = Instance.new("TextButton", keyRow)
    keyBtn.Size = UDim2.new(0, 54, 0, 22); keyBtn.Position = UDim2.new(1, -60, 0.5, -11)
    keyBtn.BackgroundColor3 = Theme.SurfaceHighlight; keyBtn.Text = Config.AutoBuyKey or "K"
    keyBtn.Font = Enum.Font.GothamBold; keyBtn.TextSize = 11
    keyBtn.TextColor3 = Theme.Accent1; keyBtn.AutoButtonColor = false; keyBtn.BorderSizePixel = 0
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0, 8)
    keyBtn.MouseButton1Click:Connect(function()
        keyBtn.Text = "..."; keyBtn.TextColor3 = Theme.TextSecondary
        local c; c = UserInputService.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                Config.AutoBuyKey = inp.KeyCode.Name; AB_KEY = Config.AutoBuyKey
                keyBtn.Text = inp.KeyCode.Name; keyBtn.TextColor3 = Theme.Accent1
                SaveConfig(); c:Disconnect()
            end
        end)
    end)

    -- Range slider
    local slRow = abRow(42, 3)
    local slLbl = Instance.new("TextLabel", slRow)
    slLbl.Size = UDim2.new(1, -10, 0, 16); slLbl.Position = UDim2.new(0, 10, 0, 4)
    slLbl.BackgroundTransparency = 1; slLbl.Text = "Range: " .. (Config.AutoBuyRange or AB_RANGE) .. " studs"
    slLbl.Font = Enum.Font.GothamBold; slLbl.TextSize = 11
    slLbl.TextColor3 = Theme.TextPrimary; slLbl.TextXAlignment = Enum.TextXAlignment.Left

    local slBg = Instance.new("Frame", slRow)
    slBg.Size = UDim2.new(1, -20, 0, 6); slBg.Position = UDim2.new(0, 10, 0, 28)
    slBg.BackgroundColor3 = Theme.SurfaceHighlight; slBg.BorderSizePixel = 0
    Instance.new("UICorner", slBg).CornerRadius = UDim.new(1, 0)
    local slFill = Instance.new("Frame", slBg)
    slFill.BackgroundColor3 = Theme.Accent1; slFill.BorderSizePixel = 0
    Instance.new("UICorner", slFill).CornerRadius = UDim.new(1, 0)
    local slKnob = Instance.new("Frame", slBg)
    slKnob.Size = UDim2.new(0, 13, 0, 13); slKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    slKnob.BackgroundColor3 = Color3.new(1, 1, 1); slKnob.BorderSizePixel = 0
    Instance.new("UICorner", slKnob).CornerRadius = UDim.new(1, 0)
    local slKS = Instance.new("UIStroke", slKnob); slKS.Color = Theme.Accent1; slKS.Thickness = 1.5

    local SL_MIN, SL_MAX = 5, 40
    local function updateSlider(v)
        v = math.clamp(math.floor(v), SL_MIN, SL_MAX)
        Config.AutoBuyRange = v; AB_RANGE = v; SaveConfig()
        slLbl.Text = "Range: " .. v .. " studs"
        local pct = (v - SL_MIN) / (SL_MAX - SL_MIN)
        slFill.Size = UDim2.new(pct, 0, 1, 0); slKnob.Position = UDim2.new(pct, 0, 0.5, 0)
        if _abRing and _abRing.Parent then _abRing.Size = Vector3.new(0.5, v*2, v*2) end
    end
    updateSlider(Config.AutoBuyRange or AB_RANGE)

    local slDrag = false
    slBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            slDrag = true
            updateSlider(SL_MIN + ((i.Position.X - slBg.AbsolutePosition.X) / slBg.AbsoluteSize.X) * (SL_MAX - SL_MIN))
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then slDrag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if slDrag then
            updateSlider(SL_MIN + ((i.Position.X - slBg.AbsolutePosition.X) / slBg.AbsoluteSize.X) * (SL_MAX - SL_MIN))
        end
    end)

    -- Status row
    local stRow = abRow(26, 4)
    local stLbl = Instance.new("TextLabel", stRow)
    stLbl.Size = UDim2.new(1, -10, 1, 0); stLbl.Position = UDim2.new(0, 10, 0, 0)
    stLbl.BackgroundTransparency = 1; stLbl.Text = "Status: Idle"
    stLbl.Font = Enum.Font.GothamBold; stLbl.TextSize = 11
    stLbl.TextColor3 = Theme.TextSecondary; stLbl.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while abGui and abGui.Parent do
            task.wait(0.4)
            if not _abActive then
                stLbl.Text = "Status: Idle"; stLbl.TextColor3 = Theme.TextSecondary
            elseif _abLocked then
                stLbl.Text = "🔒 " .. (_abLocked.name or "?"); stLbl.TextColor3 = Theme.Accent1
            else
                stLbl.Text = "🔍 Scanning..."; stLbl.TextColor3 = Theme.TextPrimary
            end
        end
    end)

    -- Toggle logic
    local function applyVisual()
        if _abActive then
            togBtn.Text = "AUTO BUY: ON"
            togBtn.BackgroundColor3 = Theme.Accent1
            togBtn.TextColor3 = Color3.new(0, 0, 0)
            togStroke.Transparency = 1
        else
            togBtn.Text = "AUTO BUY: OFF"
            togBtn.BackgroundColor3 = Theme.Surface
            togBtn.TextColor3 = Theme.TextSecondary
            togStroke.Transparency = 0.5
        end
    end

    local function doToggle()
        _abActive = not _abActive
        if _abActive then
            _abCreateRing()
            ShowNotification("AUTO BUY", "✅ ACTIVATED")
        else
            _abDestroyRing(); _abDestroyBodyPos(); _abStopCarpet()
            _abLocked=nil; _abPart=nil; _abModel=nil
            ShowNotification("AUTO BUY", "❌ DEACTIVATED")
        end
        applyVisual()
    end

    togBtn.MouseButton1Click:Connect(doToggle)

    UserInputService.InputBegan:Connect(function(inp, gp)
        if gp then return end
        local ok, kc = pcall(function() return Enum.KeyCode[Config.AutoBuyKey or AB_KEY] end)
        if ok and kc and inp.KeyCode == kc then doToggle() end
    end)

end)

-- ═══════════════════════════════════════════════════════════════
--  PRIORITY BRAINROT ESP
--  Shows a billboard above any priority-list animal on any base
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    local prioritySet = {}
    for _,name in ipairs(PRIORITY_LIST) do prioritySet[name:lower()] = true end

    local MUT_COL = {Cursed=Color3.fromRGB(200,0,0),Gold=Color3.fromRGB(255,215,0),Diamond=Color3.fromRGB(0,255,255),
        YinYang=Color3.fromRGB(220,220,220),Rainbow=Color3.fromRGB(255,100,200),Lava=Color3.fromRGB(255,100,20),
        Candy=Color3.fromRGB(255,105,180),Divine=Color3.fromRGB(255,255,255)}

    local activeBBs = {} -- uid -> BillboardGui

    local function destroyBB(uid)
        if activeBBs[uid] and activeBBs[uid].Parent then activeBBs[uid]:Destroy() end
        activeBBs[uid]=nil
    end

    local function buildPriorityBB(part, animal)
        local uid = animal.uid or (animal.plot.."_"..animal.slot)
        if activeBBs[uid] and activeBBs[uid].Parent then return end -- already exists
        local accent = (animal.mutation and MUT_COL[animal.mutation]) or Theme.Accent1

        local bb = Instance.new("BillboardGui")
        bb.Name="111x_PrioESP_"..uid; bb.Size=UDim2.new(0,210,0,58)
        bb.StudsOffsetWorldSpace=Vector3.new(0,6,0); bb.AlwaysOnTop=true
        bb.ResetOnSpawn=false; bb.LightInfluence=0; bb.Adornee=part; bb.Parent=part

        local fr=Instance.new("Frame",bb)
        fr.Size=UDim2.new(1,0,1,0); fr.BackgroundColor3=Color3.fromRGB(0,0,0)
        fr.BackgroundTransparency=0.35; fr.BorderSizePixel=0
        Instance.new("UICorner",fr).CornerRadius=UDim.new(0,16)
        local sk=Instance.new("UIStroke",fr); sk.Color=accent; sk.Thickness=2.5; sk.Transparency=0.15

        local tag=Instance.new("TextLabel",fr)
        tag.Size=UDim2.new(1,-8,0,14); tag.Position=UDim2.new(0,4,0,3)
        tag.BackgroundTransparency=1; tag.Text="⭐ PRIORITY"
        tag.Font=Enum.Font.GothamBlack; tag.TextSize=9; tag.TextColor3=accent
        tag.TextXAlignment=Enum.TextXAlignment.Center

        local nl=Instance.new("TextLabel",fr)
        nl.Size=UDim2.new(1,-8,0,22); nl.Position=UDim2.new(0,4,0,16)
        nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBlack; nl.TextSize=13
        nl.TextColor3=Color3.fromRGB(255,255,255); nl.TextXAlignment=Enum.TextXAlignment.Center
        nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.Text=animal.name
        nl.TextStrokeTransparency=0.5; nl.TextStrokeColor3=Color3.new(0,0,0)

        local gl=Instance.new("TextLabel",fr)
        gl.Size=UDim2.new(1,-8,0,15); gl.Position=UDim2.new(0,4,0,40)
        gl.BackgroundTransparency=1; gl.Font=Enum.Font.GothamBold; gl.TextSize=11
        gl.TextColor3=Color3.fromRGB(200,200,200); gl.TextXAlignment=Enum.TextXAlignment.Center
        gl.Text=(animal.mutation and animal.mutation~="None" and "["..animal.mutation.."] " or "")..animal.genText.." • "..animal.owner
        gl.TextStrokeTransparency=0.6; gl.TextStrokeColor3=Color3.new(0,0,0)

        activeBBs[uid]=bb
        task.spawn(function()
            while sk and sk.Parent do
                TweenService:Create(sk,TweenInfo.new(0.55,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.7}):Play()
                task.wait(0.55); if not(sk and sk.Parent) then break end
                TweenService:Create(sk,TweenInfo.new(0.55,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{Transparency=0.1}):Play()
                task.wait(0.55)
            end
        end)
    end

    while true do
        task.wait(1)
        local cache = SharedState.AllAnimalsCache
        if not cache then continue end

        -- Collect current priority UIDs
        local currentUIDs = {}
        for _,a in ipairs(cache) do
            if prioritySet[a.name:lower()] then
                local uid = a.uid or (a.plot.."_"..a.slot)
                currentUIDs[uid] = a
                local part = findAdorneeGlobal(a)
                if part and part.Parent then
                    buildPriorityBB(part, a)
                end
            end
        end

        -- Remove stale billboards
        for uid,bb in pairs(activeBBs) do
            if not currentUIDs[uid] then destroyBB(uid) end
        end
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  STEAL-BACK ALERT
--  When someone is stealing FROM someone else's base,
--  shows a billboard on THAT base so you can steal it back
-- ═══════════════════════════════════════════════════════════════
task.spawn(function()
    local stealBackBBs = {} -- plr.UserId -> BillboardGui

    local function getPlotSign(plotName)
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local plot = plots:FindFirstChild(plotName)
        if not plot then return nil end
        -- Find any BasePart in the plot to adorn to
        local sign = plot:FindFirstChild("PlotSign")
        local part = sign and (sign:IsA("BasePart") and sign or sign:FindFirstChildWhichIsA("BasePart",true))
        if not part then part = plot:FindFirstChildWhichIsA("BasePart",true) end
        return part
    end

    local function getPlotNameForPlayer(plr)
        -- Find which plot the player owns by checking the Stealing attribute's plot
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        -- Try to find plot by owner
        local Synchronizer = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Synchronizer"))
        for _,plot in ipairs(plots:GetChildren()) do
            local ok,ch = pcall(function() return Synchronizer:Get(plot.Name) end)
            if ok and ch then
                local owner = ch:Get("Owner")
                if owner then
                    local ownerName = (typeof(owner)=="Instance" and owner:IsA("Player") and owner.Name)
                        or (type(owner)=="table" and owner.Name) or nil
                    if ownerName == plr.Name then return plot.Name end
                end
            end
        end
        return nil
    end

    local function removeStealBackBB(userId)
        if stealBackBBs[userId] and stealBackBBs[userId].Parent then
            stealBackBBs[userId]:Destroy()
        end
        stealBackBBs[userId]=nil
    end

    -- Screen alert GUI (created once, reused)
    local stealAlertGui = Instance.new("ScreenGui")
    stealAlertGui.Name = "111x_StealAlertGui"
    stealAlertGui.ResetOnSpawn = false
    stealAlertGui.DisplayOrder = 99
    stealAlertGui.Parent = PlayerGui

    local stealAlertFrame = Instance.new("Frame", stealAlertGui)
    stealAlertFrame.Size = UDim2.new(0, 320, 0, 70)
    stealAlertFrame.AnchorPoint = Vector2.new(0.5, 0)
    stealAlertFrame.Position = UDim2.new(0.5, 0, 0, -80)
    stealAlertFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    stealAlertFrame.BackgroundTransparency = 0.35
    stealAlertFrame.BorderSizePixel = 0
    Instance.new("UICorner", stealAlertFrame).CornerRadius = UDim.new(0, 12)
    local alertStroke = Instance.new("UIStroke", stealAlertFrame)
    alertStroke.Color = Color3.fromRGB(255, 255, 255)
    alertStroke.Thickness = 2
    alertStroke.Transparency = 0.1
    AddGlowBorderAnimation(stealAlertFrame, alertStroke)
    AddStarryBackground(stealAlertFrame)

    local alertTag = Instance.new("TextLabel", stealAlertFrame)
    alertTag.Size = UDim2.new(1, -12, 0, 18)
    alertTag.Position = UDim2.new(0, 6, 0, 6)
    alertTag.BackgroundTransparency = 1
    alertTag.Font = Enum.Font.GothamBlack
    alertTag.TextSize = 10
    alertTag.TextColor3 = Color3.fromRGB(255, 255, 255)
    alertTag.TextXAlignment = Enum.TextXAlignment.Center
    alertTag.Text = "⬜ SOMEONE IS STEALING — STEAL IT BACK"

    local alertName = Instance.new("TextLabel", stealAlertFrame)
    alertName.Name = "AlertName"
    alertName.Size = UDim2.new(1, -12, 0, 24)
    alertName.Position = UDim2.new(0, 6, 0, 22)
    alertName.BackgroundTransparency = 1
    alertName.Font = Enum.Font.GothamBlack
    alertName.TextSize = 15
    alertName.TextColor3 = Color3.fromRGB(255, 255, 255)
    alertName.TextXAlignment = Enum.TextXAlignment.Center
    alertName.TextTruncate = Enum.TextTruncate.AtEnd
    alertName.TextStrokeTransparency = 0.4
    alertName.TextStrokeColor3 = Color3.new(0, 0, 0)
    alertName.Text = ""

    local alertPet = Instance.new("TextLabel", stealAlertFrame)
    alertPet.Name = "AlertPet"
    alertPet.Size = UDim2.new(1, -12, 0, 18)
    alertPet.Position = UDim2.new(0, 6, 0, 46)
    alertPet.BackgroundTransparency = 1
    alertPet.Font = Enum.Font.GothamBold
    alertPet.TextSize = 11
    alertPet.TextColor3 = Color3.fromRGB(200, 200, 200)
    alertPet.TextXAlignment = Enum.TextXAlignment.Center
    alertPet.TextTruncate = Enum.TextTruncate.AtEnd
    alertPet.Text = ""

    local alertVisible = false
    local alertHideTime = 0
    local activeStealers = {}

    local function showScreenAlert(plrName, petName)
        alertName.Text = plrName .. " is stealing!"
        alertPet.Text = petName ~= "" and ("🐾 " .. petName) or ""
        if not alertVisible then
            alertVisible = true
            TweenService:Create(stealAlertFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                {Position = UDim2.new(0.5, 0, 0, 12)}):Play()
        end
        alertHideTime = os.clock() + 9
    end

    local function hideScreenAlert()
        alertVisible = false
        TweenService:Create(stealAlertFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            {Position = UDim2.new(0.5, 0, 0, -80)}):Play()
    end

    -- Auto-hide when no one is stealing
    task.spawn(function()
        while stealAlertGui and stealAlertGui.Parent do
            task.wait(0.5)
            if alertVisible and os.clock() > alertHideTime then
                hideScreenAlert()
            end
        end
    end)

    local function showStealBackBB(plr, petName, plotName)
        removeStealBackBB(plr.UserId)
        -- Show screen alert
        activeStealers[plr.UserId] = {name = plr.Name, pet = petName or ""}
        showScreenAlert(plr.Name, petName or "")
        local part = getPlotSign(plotName)
        if not part then return end

        local bb=Instance.new("BillboardGui")
        bb.Name="111x_StealBack_"..plr.UserId
        bb.Size=UDim2.new(0,230,0,58); bb.StudsOffsetWorldSpace=Vector3.new(0,16,0)
        bb.AlwaysOnTop=true; bb.ResetOnSpawn=false; bb.LightInfluence=0
        bb.Adornee=part; bb.Parent=part

        local fr=Instance.new("Frame",bb)
        fr.Size=UDim2.new(1,0,1,0); fr.BackgroundColor3=Color3.fromRGB(0,0,0)
        fr.BackgroundTransparency=0.35; fr.BorderSizePixel=0
        Instance.new("UICorner",fr).CornerRadius=UDim.new(0,16)
        local sk=Instance.new("UIStroke",fr); sk.Color=Color3.fromRGB(255,255,255); sk.Thickness=2.5; sk.Transparency=0.1

        local tag=Instance.new("TextLabel",fr)
        tag.Size=UDim2.new(1,-8,0,14); tag.Position=UDim2.new(0,4,0,3)
        tag.BackgroundTransparency=1; tag.Text="🔓 STEAL BACK OPPORTUNITY"
        tag.Font=Enum.Font.GothamBlack; tag.TextSize=9; tag.TextColor3=Color3.fromRGB(255,255,255)
        tag.TextXAlignment=Enum.TextXAlignment.Center

        local nl=Instance.new("TextLabel",fr)
        nl.Size=UDim2.new(1,-8,0,20); nl.Position=UDim2.new(0,4,0,16)
        nl.BackgroundTransparency=1; nl.Font=Enum.Font.GothamBlack; nl.TextSize=13
        nl.TextColor3=Color3.fromRGB(255,255,255); nl.TextXAlignment=Enum.TextXAlignment.Center
        nl.TextTruncate=Enum.TextTruncate.AtEnd; nl.Text=plr.Name.." stealing"
        nl.TextStrokeTransparency=0.4; nl.TextStrokeColor3=Color3.new(0,0,0)

        local gl=Instance.new("TextLabel",fr)
        gl.Size=UDim2.new(1,-8,0,16); gl.Position=UDim2.new(0,4,0,38)
        gl.BackgroundTransparency=1; gl.Font=Enum.Font.GothamBold; gl.TextSize=11
        gl.TextColor3=Color3.fromRGB(200,200,200); gl.TextXAlignment=Enum.TextXAlignment.Center
        gl.Text=petName; gl.TextStrokeTransparency=0.5; gl.TextStrokeColor3=Color3.new(0,0,0)

        stealBackBBs[plr.UserId]=bb

        -- Sequentially circling glowing white outline (mirrors AddGlowBorderAnimation)
        task.spawn(function()
            local g = sk:FindFirstChildWhichIsA("UIGradient")
            if not g then g = Instance.new("UIGradient", sk) end
            local SPEED    = 0.55
            local SPREAD   = 0.13
            local WHITE    = Color3.fromRGB(255, 255, 255)
            local DIM      = Color3.fromRGB(30,  30,  30)
            local GLOW_DIM = Color3.fromRGB(120, 120, 120)
            local STEP     = 1/60
            local t = 0
            local function kp(pos, col)
                return ColorSequenceKeypoint.new(math.clamp(pos, 0.001, 0.999), col)
            end
            while sk and sk.Parent and fr and fr.Parent do
                t = (t + SPEED * STEP) % 1
                g.Rotation = t * 360
                local c  = 0.5
                local lo = c - SPREAD
                local hi = c + SPREAD
                g.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0,   DIM),
                    kp(math.max(0.05, lo - 0.06),  DIM),
                    kp(math.max(0.06, lo),          GLOW_DIM),
                    kp(c,                           WHITE),
                    kp(math.min(0.94, hi),          GLOW_DIM),
                    kp(math.min(0.93, hi + 0.06),   DIM),
                    ColorSequenceKeypoint.new(1,   DIM),
                })
                sk.Transparency = 0.1 + math.sin(t * math.pi * 2) * 0.08
                sk.Thickness = 2.5 + math.sin(t * math.pi * 2) * 0.5
                task.wait(STEP)
            end
        end)
    end

    local function hookStealBack(plr)
        if plr == LocalPlayer then return end
        local stealingPlotName = nil
        local wasStealingFromOther = false

        local function checkSteal()
            local stealing = plr:GetAttribute("Stealing")
            local petName = plr:GetAttribute("StealingIndex") or "something"
            if stealing then
                -- Find which plot they are in
                if not stealingPlotName then
                    stealingPlotName = getPlotNameForPlayer(plr)
                end
                wasStealingFromOther = true
                if stealingPlotName then
                    if not stealBackBBs[plr.UserId] or not stealBackBBs[plr.UserId].Parent then
                        showStealBackBB(plr, petName, stealingPlotName)
                    end
                end
            else
                if wasStealingFromOther then
                    wasStealingFromOther = false
                    stealingPlotName = nil
                    removeStealBackBB(plr.UserId)
                end
            end
        end

        plr:GetAttributeChangedSignal("Stealing"):Connect(checkSteal)
        plr:GetAttributeChangedSignal("StealingIndex"):Connect(checkSteal)

        -- Poll to keep billboard alive
        task.spawn(function()
            while plr and plr.Parent do
                task.wait(0.25)
                if not plr or not plr.Parent then break end
                local stealing = plr:GetAttribute("Stealing")
                if stealing then
                    if not stealingPlotName then
                        stealingPlotName = getPlotNameForPlayer(plr)
                    end
                    if stealingPlotName then
                        local petName = plr:GetAttribute("StealingIndex") or "something"
                        if not stealBackBBs[plr.UserId] or not stealBackBBs[plr.UserId].Parent then
                            showStealBackBB(plr, petName, stealingPlotName)
                        end
                    end
                elseif wasStealingFromOther then
                    wasStealingFromOther = false
                    stealingPlotName = nil
                    removeStealBackBB(plr.UserId)
                end
            end
            removeStealBackBB(plr.UserId)
        end)

        plr.CharacterAdded:Connect(function()
            stealingPlotName = nil
            removeStealBackBB(plr.UserId)
        end)
    end

    Players.PlayerRemoving:Connect(function(plr) removeStealBackBB(plr.UserId) end)
    for _,plr in ipairs(Players:GetPlayers()) do task.spawn(hookStealBack, plr) end
    Players.PlayerAdded:Connect(hookStealBack)
end)

-- ============================================================
-- ZAWA'S REMOTE SELL — integrated into Dozer's Hub (purple theme)
-- ============================================================
task.spawn(function()
    -- Reuse hub locals: Players, LocalPlayer, PlayerGui, TweenService, UserInputService

    local RS_SAVE_FILE = "zawa_sell_pos2.txt"
    local RS_FRAME_W, RS_FRAME_H = 265, 445

    -- ---- find player plot ----
    local rs_lockedPlot = nil
    local function rs_findMyPlot()
        if rs_lockedPlot and rs_lockedPlot.Parent then return rs_lockedPlot end
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local myName = LocalPlayer.Name:lower()
        local myId   = tostring(LocalPlayer.UserId)
        local myDisp = LocalPlayer.DisplayName:lower()
        for _, plot in ipairs(plots:GetChildren()) do
            for _, v in ipairs(plot:GetDescendants()) do
                if v:IsA("StringValue") then
                    local val = tostring(v.Value):lower()
                    if val == myName or val == myId or val == myDisp then
                        rs_lockedPlot = plot; return plot
                    end
                elseif v:IsA("IntValue") then
                    if tostring(v.Value) == myId then rs_lockedPlot = plot; return plot end
                elseif v:IsA("ObjectValue") then
                    if v.Value == LocalPlayer then rs_lockedPlot = plot; return plot end
                end
            end
        end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local closest, closestDist = nil, math.huge
            for _, plot in ipairs(plots:GetChildren()) do
                local ok, pos = pcall(function() return plot:GetPivot().Position end)
                if ok then
                    local dist = (pos - root.Position).Magnitude
                    if dist < closestDist then closest = plot; closestDist = dist end
                end
            end
            if closest then rs_lockedPlot = closest; return closest end
        end
        return nil
    end

    -- ---- GUI ----
    local rs_screenGui = Instance.new("ScreenGui")
    rs_screenGui.Name = "RemoteSellGUI"
    rs_screenGui.ResetOnSpawn = false
    rs_screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    rs_screenGui.Parent = PlayerGui

    local screenSize = Workspace.CurrentCamera.ViewportSize
    local function rs_clampPos(x, y)
        x = math.clamp(x, 0, screenSize.X - RS_FRAME_W)
        y = math.clamp(y, 0, screenSize.Y - RS_FRAME_H)
        return x, y
    end

    local savedX, savedY = nil, nil
    if isfile and isfile(RS_SAVE_FILE) then
        local ok, data = pcall(readfile, RS_SAVE_FILE)
        if ok and data then
            local x, y = data:match("(-?[%d%.]+),(-?[%d%.]+)")
            if x and y then savedX, savedY = rs_clampPos(tonumber(x), tonumber(y)) end
        end
    end

    local rs_main = Instance.new("Frame")
    rs_main.Size = UDim2.new(0, RS_FRAME_W, 0, RS_FRAME_H)
    rs_main.Position = (savedX and savedY)
        and UDim2.new(0, savedX, 0, savedY)
        or  UDim2.new(0.5, -132, 0.5, -219)
    rs_main.BackgroundColor3 = Theme.Background
    rs_main.BackgroundTransparency = 0.35
    rs_main.BorderSizePixel = 0
    rs_main.Active = true
    rs_main.Draggable = false
    rs_main.ZIndex = 2
    rs_main.Parent = rs_screenGui
    Instance.new("UICorner", rs_main).CornerRadius = UDim.new(0, 12)

    local rs_stroke = Instance.new("UIStroke", rs_main)
    rs_stroke.Color = Theme.Accent1
    rs_stroke.Thickness = 2
    rs_stroke.Transparency = 0
    AddGlowBorderAnimation(rs_main, rs_stroke)
    AddStarryBackground(rs_main)

    -- drag with save
    do
        local dragging, dragStart, startPos
        rs_main.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true; dragStart = input.Position; startPos = rs_main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position - dragStart
                local cx, cy = rs_clampPos(startPos.X.Offset + delta.X, startPos.Y.Offset + delta.Y)
                rs_main.Position = UDim2.new(0, cx, 0, cy)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                dragging = false
                if writefile then
                    pcall(writefile, RS_SAVE_FILE, rs_main.Position.X.Offset .. "," .. rs_main.Position.Y.Offset)
                end
            end
        end)
    end

    -- accent line under title bar
    local rs_accentLine = Instance.new("Frame", rs_main)
    rs_accentLine.Size = UDim2.new(1, 0, 0, 2)
    rs_accentLine.Position = UDim2.new(0, 0, 0, 48)
    rs_accentLine.BackgroundColor3 = Theme.Accent1
    rs_accentLine.BorderSizePixel = 0
    rs_accentLine.ZIndex = 3

    -- title bar
    local rs_titleBar = Instance.new("Frame", rs_main)
    rs_titleBar.Size = UDim2.new(1, 0, 0, 48)
    rs_titleBar.BackgroundColor3 = Theme.Surface
    rs_titleBar.BorderSizePixel = 0
    rs_titleBar.ZIndex = 3
    Instance.new("UICorner", rs_titleBar).CornerRadius = UDim.new(0, 8)

    local rs_dot = Instance.new("Frame", rs_titleBar)
    rs_dot.Size = UDim2.new(0, 8, 0, 8)
    rs_dot.Position = UDim2.new(0, 14, 0.5, -4)
    rs_dot.BackgroundColor3 = Theme.Accent1
    rs_dot.BorderSizePixel = 0
    rs_dot.ZIndex = 4
    Instance.new("UICorner", rs_dot).CornerRadius = UDim.new(1, 0)

    local rs_titleLabel = Instance.new("TextLabel", rs_titleBar)
    rs_titleLabel.Size = UDim2.new(1, -80, 1, 0)
    rs_titleLabel.Position = UDim2.new(0, 30, 0, 0)
    rs_titleLabel.BackgroundTransparency = 1
    rs_titleLabel.Text = "REMOTE SELL"
    rs_titleLabel.TextColor3 = Theme.Accent1
    rs_titleLabel.Font = Enum.Font.GothamBlack
    rs_titleLabel.TextSize = 15
    rs_titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    rs_titleLabel.ZIndex = 4

    local rs_creditLabel2 = Instance.new("TextLabel", rs_titleBar)
    rs_creditLabel2.Size = UDim2.new(1, -80, 0, 12)
    rs_creditLabel2.Position = UDim2.new(0, 30, 1, -16)
    rs_creditLabel2.BackgroundTransparency = 1
    rs_creditLabel2.Text = "by YoDtz"
    rs_creditLabel2.TextColor3 = Theme.Accent1
    rs_creditLabel2.Font = Enum.Font.GothamBold
    rs_creditLabel2.TextSize = 10
    rs_creditLabel2.TextXAlignment = Enum.TextXAlignment.Left
    rs_creditLabel2.ZIndex = 4

    local rs_closeBtn = Instance.new("TextButton", rs_titleBar)
    rs_closeBtn.Size = UDim2.new(0, 26, 0, 26)
    rs_closeBtn.Position = UDim2.new(1, -34, 0.5, -13)
    rs_closeBtn.BackgroundColor3 = Theme.SurfaceHighlight
    rs_closeBtn.Text = "✕"
    rs_closeBtn.TextColor3 = Theme.TextPrimary
    rs_closeBtn.Font = Enum.Font.GothamBold
    rs_closeBtn.TextSize = 12
    rs_closeBtn.BorderSizePixel = 0
    rs_closeBtn.ZIndex = 4
    Instance.new("UICorner", rs_closeBtn).CornerRadius = UDim.new(0, 8)
    rs_closeBtn.MouseButton1Click:Connect(function() rs_screenGui:Destroy() end)

    -- status label
    local rs_statusLabel = Instance.new("TextLabel", rs_main)
    rs_statusLabel.Size = UDim2.new(1, -20, 0, 22)
    rs_statusLabel.Position = UDim2.new(0, 10, 0, 54)
    rs_statusLabel.BackgroundTransparency = 1
    rs_statusLabel.Text = "Scanning..."
    rs_statusLabel.TextColor3 = Theme.TextSecondary
    rs_statusLabel.Font = Enum.Font.Gotham
    rs_statusLabel.TextSize = 11
    rs_statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    rs_statusLabel.ZIndex = 3

    -- scroll frame
    local rs_scroll = Instance.new("ScrollingFrame", rs_main)
    rs_scroll.Size = UDim2.new(1, -18, 1, -112)
    rs_scroll.Position = UDim2.new(0, 9, 0, 80)
    rs_scroll.BackgroundColor3 = Theme.Surface
    rs_scroll.BackgroundTransparency = 0.3
    rs_scroll.BorderSizePixel = 0
    rs_scroll.ScrollBarThickness = 3
    rs_scroll.ScrollBarImageColor3 = Theme.Accent1
    rs_scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    rs_scroll.ZIndex = 3
    Instance.new("UICorner", rs_scroll).CornerRadius = UDim.new(0, 8)

    local rs_listLayout = Instance.new("UIListLayout", rs_scroll)
    rs_listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    rs_listLayout.Padding = UDim.new(0, 5)
    local rs_pad = Instance.new("UIPadding", rs_scroll)
    rs_pad.PaddingTop = UDim.new(0, 6); rs_pad.PaddingBottom = UDim.new(0, 6)
    rs_pad.PaddingLeft = UDim.new(0, 6); rs_pad.PaddingRight = UDim.new(0, 6)

    rs_listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        rs_scroll.CanvasSize = UDim2.new(0, 0, 0, rs_listLayout.AbsoluteContentSize.Y + 12)
    end)

    -- ---- row builder ----
    local rs_shownPodiums = {}
    local function rs_addRow(podiumNum, sellPrompt, sellText)
        local row = Instance.new("Frame", rs_scroll)
        row.Size = UDim2.new(1, -12, 0, 40)
        row.BackgroundColor3 = Theme.SurfaceHighlight
        row.BackgroundTransparency = 0.4
        row.BorderSizePixel = 0
        row.LayoutOrder = podiumNum
        row.ZIndex = 4
        row.Name = "PodiumRow_" .. podiumNum
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local leftAccent = Instance.new("Frame", row)
        leftAccent.Size = UDim2.new(0, 3, 1, -8)
        leftAccent.Position = UDim2.new(0, 0, 0, 4)
        leftAccent.BackgroundColor3 = Theme.Accent1
        leftAccent.BorderSizePixel = 0
        leftAccent.ZIndex = 5
        Instance.new("UICorner", leftAccent).CornerRadius = UDim.new(0, 8)

        local badge = Instance.new("TextLabel", row)
        badge.Size = UDim2.new(0, 28, 0, 28)
        badge.Position = UDim2.new(0, 10, 0.5, -14)
        badge.BackgroundColor3 = Theme.Surface
        badge.Text = tostring(podiumNum)
        badge.TextColor3 = Theme.Accent1
        badge.Font = Enum.Font.GothamBlack
        badge.TextSize = 12
        badge.BorderSizePixel = 0
        badge.ZIndex = 5
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 8)

        local nameLabel = Instance.new("TextLabel", row)
        nameLabel.Size = UDim2.new(1, -110, 1, 0)
        nameLabel.Position = UDim2.new(0, 46, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = sellText
        nameLabel.TextColor3 = Theme.TextPrimary
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.TextSize = 11
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.ZIndex = 5

        local sellBtn = Instance.new("TextButton", row)
        sellBtn.Size = UDim2.new(0, 56, 0, 28)
        sellBtn.Position = UDim2.new(1, -62, 0.5, -14)
        sellBtn.BackgroundColor3 = Theme.Accent1
        sellBtn.Text = "SELL"
        sellBtn.TextColor3 = Color3.new(0, 0, 0)
        sellBtn.Font = Enum.Font.GothamBold
        sellBtn.TextSize = 11
        sellBtn.BorderSizePixel = 0
        sellBtn.ZIndex = 5
        Instance.new("UICorner", sellBtn).CornerRadius = UDim.new(0, 8)

        sellBtn.MouseButton1Click:Connect(function()
            local sellOk = pcall(function() fireproximityprompt(sellPrompt) end)
            if sellOk then
                sellBtn.Text = "✓"
                sellBtn.BackgroundColor3 = Theme.Success
                task.wait(0.4)
                rs_shownPodiums[podiumNum] = nil
                row:Destroy()
                local remaining = 0
                for _ in pairs(rs_shownPodiums) do remaining += 1 end
                rs_statusLabel.Text = remaining == 0 and "No brainrots on podiums" or (remaining .. " brainrot(s) ready to sell")
            else
                sellBtn.Text = "ERR"
                sellBtn.BackgroundColor3 = Theme.Error
                task.wait(1)
                sellBtn.Text = "SELL"
                sellBtn.BackgroundColor3 = Theme.Accent1
            end
        end)
    end

    -- ---- scan ----
    local function rs_scan()
        local plot = rs_findMyPlot()
        if not plot then rs_statusLabel.Text = "❌ Base not found"; return end
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then rs_statusLabel.Text = "❌ AnimalPodiums not found"; return end
        local newFound = 0
        for _, podium in ipairs(podiums:GetChildren()) do
            local podiumNum = tonumber(podium.Name)
            if podiumNum and not rs_shownPodiums[podiumNum] then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local attachment = spawn and spawn:FindFirstChild("PromptAttachment")
                if attachment then
                    for _, pp in ipairs(attachment:GetChildren()) do
                        if pp:IsA("ProximityPrompt") and (pp.ActionText or ""):sub(1,4) == "Sell" then
                            rs_shownPodiums[podiumNum] = true
                            rs_addRow(podiumNum, pp, pp.ActionText)
                            newFound += 1
                        end
                    end
                end
            end
        end
        local total = 0
        for _ in pairs(rs_shownPodiums) do total += 1 end
        rs_statusLabel.Text = total == 0 and "No brainrots on podiums" or (total .. " brainrot(s) ready to sell")
    end

    local function rs_hasSellPrompt(plot)
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return false end
        for _, podium in ipairs(podiums:GetChildren()) do
            if tonumber(podium.Name) then
                local base = podium:FindFirstChild("Base")
                local spawn = base and base:FindFirstChild("Spawn")
                local attachment = spawn and spawn:FindFirstChild("PromptAttachment")
                if attachment then
                    for _, pp in ipairs(attachment:GetChildren()) do
                        if pp:IsA("ProximityPrompt") and (pp.ActionText or ""):sub(1,4) == "Sell" then return true end
                    end
                end
            end
        end
        return false
    end

    -- ---- watcher ----
    local function rs_startWatcher(plot)
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if not podiums then return end
        local function watchPodium(podium)
            local podiumNum = tonumber(podium.Name)
            if not podiumNum then return end
            local base = podium:FindFirstChild("Base")
            local spawn = base and base:FindFirstChild("Spawn")
            local attachment = spawn and spawn:FindFirstChild("PromptAttachment")
            if not attachment then return end
            attachment.ChildAdded:Connect(function(child)
                task.wait(0.1)
                if child:IsA("ProximityPrompt") and (child.ActionText or ""):sub(1,4) == "Sell" and not rs_shownPodiums[podiumNum] then
                    rs_shownPodiums[podiumNum] = true
                    rs_addRow(podiumNum, child, child.ActionText)
                    local total = 0
                    for _ in pairs(rs_shownPodiums) do total += 1 end
                    rs_statusLabel.Text = total .. " brainrot(s) ready to sell"
                end
            end)
            attachment.ChildRemoved:Connect(function(child)
                if child:IsA("ProximityPrompt") and (child.ActionText or ""):sub(1,4) == "Sell" then
                    rs_shownPodiums[podiumNum] = nil
                    local existingRow = rs_scroll:FindFirstChild("PodiumRow_" .. podiumNum)
                    if existingRow then existingRow:Destroy() end
                    local total = 0
                    for _ in pairs(rs_shownPodiums) do total += 1 end
                    rs_statusLabel.Text = total == 0 and "No brainrots on podiums" or (total .. " brainrot(s) ready to sell")
                end
            end)
        end
        for _, podium in ipairs(podiums:GetChildren()) do watchPodium(podium) end
        podiums.ChildAdded:Connect(function(podium) task.wait(0.2); watchPodium(podium); rs_scan() end)
    end

    -- ---- load ----
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 15)
    if not root then rs_statusLabel.Text = "❌ Character didn't load"; return end
    local plots = workspace:WaitForChild("Plots", 30)
    if not plots then rs_statusLabel.Text = "❌ Plots not found"; return end
    for i = 1, 40 do
        if #plots:GetChildren() > 0 then break end
        task.wait(0.5)
    end
    local myPlot = rs_findMyPlot()
    if not myPlot then rs_statusLabel.Text = "❌ Could not find your base"; return end
    rs_statusLabel.Text = "Loading brainrots..."
    for i = 1, 60 do
        if rs_hasSellPrompt(myPlot) then break end
        task.wait(0.5)
        if i == 60 then
            rs_statusLabel.Text = "No brainrots on podiums"
            rs_startWatcher(myPlot)
            return
        end
    end
    rs_scan()
    rs_startWatcher(myPlot)
end)
