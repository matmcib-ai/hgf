-- extracted opti: every optimization pass from message(25), with the
-- sync / plot-identity / priority support they depend on.
-- re-run guard: safe to execute multiple times
if _G.__SXE_OptimizerLoaded then return end
_G.__SXE_OptimizerLoaded = true

-- FPS uncap
pcall(function() setfpscap(999) end)

_G.__SXE_KillQ = _G.__SXE_KillQ or {}
if _G.__SXE_VelFlying == nil then _G.__SXE_VelFlying = false end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = workspace
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local LP = LocalPlayer

-- === animate strip (src 186-209)
do
    local Players = game:GetService("Players")
    local function pin(a)
        if a and a.Name == "Animate" then
            pcall(function() a.Disabled = true end)
        end
    end
    local function hook(char)
        if not char then return end
        pin(char:FindFirstChild("Animate"))
        char.ChildAdded:Connect(pin)
    end
    local function onLp(lp)
        if not lp then return end
        if lp.Character then hook(lp.Character) end
        lp.CharacterAdded:Connect(hook)
    end
    local lp = Players.LocalPlayer
    if lp then
        onLp(lp)
    else
        Players.PlayerAdded:Connect(onLp)
    end
end

-- === ReplicatedStorage keep list (src 210-293)
do
    local RS = game:GetService("ReplicatedStorage")
    local KEEP = {
        CustomProximityPromptController = true,
        InteractController = true,
        PlotController = true,
        AnimalController = true,
        PetController = true,
        WorldBrainrotController = true,
        EquipBrainrotsController = true,
        EquipBrainrotsRenderController = true,
        SelectBrainrotsController = true,
        BrainrotPreloadingController = true,
        AssetStreamController = true,
        AdminPanelController = true,
        NotificationController = true,
    }
    local function wrap(fn)
        if newcclosure then
            return newcclosure(fn)
        end
        return fn
    end
    local function isCtrlFolder(x)
        return typeof(x) == "Instance" and x.Name == "Controllers" and x.Parent == RS
    end
    local function callerName()
        if not getcallingscript then
            return "?"
        end
        local ok, s = pcall(getcallingscript)
        if not ok or s == nil then
            return "nil"
        end
        return tostring(s.Name)
    end
    local function fromLoader()
        return callerName() == "ClientLoader"
    end
    local function filt(kids)
        if type(kids) ~= "table" then
            return kids
        end
        local out = {}
        for i = 1, #kids do
            local k = kids[i]
            if k and KEEP[k.Name] then
                out[#out + 1] = k
            end
        end
        return out
    end
    local oldNc
    local undone = false
    local function unhook()
        if undone then return end
        undone = true
        pcall(function()
            if oldNc then
                hookmetamethod(game, "__namecall", oldNc)
            end
        end)
    end
    pcall(function()
        oldNc = hookmetamethod(game, "__namecall", wrap(function(self, ...)
            local method = getnamecallmethod()
            if type(method) ~= "string" then
                return oldNc(self, ...)
            end
            local ml = string.lower(method)
            if ml ~= "getchildren" then
                return oldNc(self, ...)
            end
            if not isCtrlFolder(self) then
                return oldNc(self, ...)
            end
            if not fromLoader() then
                return oldNc(self, ...)
            end
            return filt(oldNc(self, ...))
        end))
    end)
    task.delay(6, unhook)
end

-- === ReplicatedStorage vfx kill (src 380-402)
task.spawn(function()
    local RS = game:GetService("ReplicatedStorage")
    local KILL = {
        RNGMachineVFX = true,
        LuckIcons = true,
        GlossaryBackground = true,
        AnimationGraphEditor = true,
        ML = true,
        PlayWaveEvents = true,
    }
    local function yeet(ch)
        if not ch then return end
        pcall(function()
            ch:Destroy()
        end)
    end
    local function dropKill(ch)
        if ch and KILL[ch.Name] then yeet(ch) end
    end
    local kids = RS:GetChildren()
    for i = 1, #kids do dropKill(kids[i]) end
    RS.ChildAdded:Connect(dropKill)
end)

-- === kill queue helpers (src 404-423)
local function _sxeBusy()
    return _G.__SXE_VelFlying == true
end
function _G.SXE_IsMineInst(inst)
    if not inst then return false end
    local lp = game:GetService("Players").LocalPlayer
    if not lp then return true end
    local ok, hit = pcall(function()
        if inst.Name == lp.Name then return true end
        local ch = lp.Character
        if ch and (inst == ch or inst:IsDescendantOf(ch)) then return true end
        if inst:IsDescendantOf(lp) then return true end
        local n2 = inst.Name
        if string.sub(n2, 1, 2) == "D3" then return true end
        if string.match(n2, "^%d+_Clone$") then return true end
        return false
    end)
    return ok and hit or false
end
function _G.SXE_Kill(inst)
    if not inst then return end
    if _G.SXE_IsMineInst(inst) then
        _G.SXE_MineSaves = (tonumber(_G.SXE_MineSaves) or 0) + 1
        return
    end
    if _sxeBusy() then
        local q = _G.__SXE_KillQ
        q[#q + 1] = inst
        return
    end
    -- Rescue sounds: move them to SoundService before destroying the parent
    -- so game audio isn't silenced along with visual junk.
    pcall(function()
        if inst:IsA("Sound") then
            inst.Parent = game:GetService("SoundService")
            return
        end
        for _, d in ipairs(inst:GetDescendants()) do
            if d:IsA("Sound") then
                pcall(function() d.Parent = game:GetService("SoundService") end)
            end
        end
        inst:Destroy()
    end)
end
function _G.SXE_FlushKills()
    local q = _G.__SXE_KillQ
    _G.__SXE_KillQ = {}
    for i = 1, #q do
        local x = q[i]
        if x and x.Parent then pcall(function() x:Destroy() end) end
    end
end


-- === surface & material flattening (from 20m_base) ===
-- Reduces GPU cost by removing studs/inlets, heavy materials, and mesh textures.
local _SXE_SoundService = game:GetService("SoundService")
local function smoothVisiblePart(object)
    if not object:IsA("BasePart") then return end
    pcall(function()
        object.TopSurface    = Enum.SurfaceType.Smooth
        object.BottomSurface = Enum.SurfaceType.Smooth
        object.LeftSurface   = Enum.SurfaceType.Smooth
        object.RightSurface  = Enum.SurfaceType.Smooth
        object.FrontSurface  = Enum.SurfaceType.Smooth
        object.BackSurface   = Enum.SurfaceType.Smooth
        object.Material      = Enum.Material.SmoothPlastic
        object.MaterialVariant = ""
        object.CastShadow    = false
    end)
    if object:IsA("MeshPart") then
        pcall(function() object.TextureID = "" end)
    end
end
local function smoothOrStrip(object)
    if object:IsA("BasePart") then
        smoothVisiblePart(object)
    elseif object:IsA("Decal") or object:IsA("Texture") or object:IsA("SurfaceAppearance") then
        pcall(function() object:Destroy() end)
    elseif object:IsA("SpecialMesh") then
        pcall(function() object.TextureId = "" end)
    end
end
local function smoothTree(root)
    if not root then return end
    smoothOrStrip(root)
    local dd = root:GetDescendants()
    for i = 1, #dd do
        smoothOrStrip(dd[i])
        if i % 350 == 0 then RunService.Heartbeat:Wait() end
    end
end
local function smoothFloorQuick(root)
    smoothVisiblePart(root)
    for _, d in ipairs(root:GetDescendants()) do smoothVisiblePart(d) end
end

-- === main workspace strip (src 424-1066)
local function __sxeStrip()
    do
        local Players = game:GetService("Players")
        local t0 = os.clock()
        while os.clock() - t0 < (tonumber(_G.SXE_CharWait) or 10) do
            local lp = Players.LocalPlayer
            if lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then break end
            task.wait(0.1)
        end
    end
    -- Tout le nettoyage epargne ma base via __SXE_MyPlot, mais rien ne le posait
    -- avant le premier TP : au chargement, ma base etait donc traitee comme les
    -- autres et perdait son panneau des amis, son pad, son panneau de base...
    -- On l'identifie ici, avant de toucher a quoi que ce soit.
    if not _G.__SXE_MyPlot then
        local t0 = os.clock()
        repeat
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in ipairs(plots:GetChildren()) do
                    local ok, ch = pcall(function()
                        return _G.XenSyncGet and _G.XenSyncGet(plot.Name)
                    end)
                    if ok and ch and _G.SXE_IsMyPlot and _G.SXE_IsMyPlot(ch) then
                        _G.__SXE_MyPlot = plot.Name
                        break
                    end
                end
            end
            if _G.__SXE_MyPlot then break end
            task.wait(0.1)
        until os.clock() - t0 > (tonumber(_G.SXE_MyPlotWait) or 12)
        _G.SXE_MyPlotDiag = _G.__SXE_MyPlot
            and ("ma base : " .. tostring(_G.__SXE_MyPlot))
            or "ma base NON identifiee, elle sera nettoyee comme les autres"
    end
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local LP = Players.LocalPlayer
    local function kill(inst)
        _G.SXE_Kill(inst)
    end
    pcall(function() workspace.Terrain.Decoration = false end)

    local WS_KILL = {
        FriendPanel = true, Cash = true, Unlock = true, Purchases = true,
        PlotSign = true, CashPad = true, InvisibleWalls = true, Multiplier = true,
        Slope = true, IncubatorMachine = true, FuseMachine = true,
        XzFusionMECircuit6zX = true, HalloweenFuseMachine = true, JumpLTMMachine = true,
        EclipseSpinWheel = true, ["Eclipse Wheel"] = true, RobuxShop = true,
        AdminBoard = true, SoccerScoreBoard = true, CrystalSpinWheel = true,
        Beehive = true, CraftingMachine = true, Shop = true, Road = true,
        EventBoard = true, TradePlazaPortal = true, LosTraders = true,
        RNGMachine = true, Present = true, StPatricksPot = true,
        ShopNPCRobuxIdle = true, RoadPanel = true, Honey = true,
        Trap = true, Events = true, Sounds = true, rods = true,
        Dev = true, ToolsAdds = true, __PROJECTILES = true, CrystalMap = true,
        SpawnLocation = true, UFO = true, Interacts = true,
    }
    local PLOT_KEEP = {
        Skin = true, Laser = true, AnimalPodiums = true,
        DeliveryHitbox = true, StealHitbox = true, AnimalTarget = true,
        MainRoot = true, Floor = true, Spawn = true, Door = true, Hitbox = true,
        Base = true, Wall = true, Roof = true, SecondFloor = true, ThirdFloor = true,
        ["structure base home"] = true, Unlock = true,
    }
    local PLOT_NUKE = {
        FriendPanel = true, Cash = true, Purchases = true,
        PlotSign = true, CashPad = true, InvisibleWalls = true, Multiplier = true,
        -- LaserHitbox retire : c'est la boite de collision du laser. Le hub lit sa
        -- solidite pour savoir si une base est encore bloquee (isPlotUnlocked et le
        -- timer). La detruire faisait repondre "pas solide" en permanence.
        Events = true, Sounds = true,
        Slope = true,
    }
    local BODY_PART = {
        HumanoidRootPart = true, Head = true, Torso = true,
        UpperTorso = true, LowerTorso = true,
        LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
        RightUpperArm = true, RightLowerArm = true, RightHand = true,
        LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
        RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
        ["Left Arm"] = true, ["Right Arm"] = true,
        ["Left Leg"] = true, ["Right Leg"] = true,
    }
    local CHAR_KEEP_CLASS = {
        Humanoid = true, Animator = true, Attachment = true,
        Motor6D = true, AnimationConstraint = true,
        BallSocketConstraint = true, Weld = true, WeldConstraint = true,
    }
    local MAP_KEEP = { Ground = true, Ground_Left = true, Ground_Right = true }
    local PART_CLASS = {
        Part = true, MeshPart = true, UnionOperation = true,
        WedgePart = true, CornerWedgePart = true, TrussPart = true,
        SpawnLocation = true, Seat = true, VehicleSeat = true,
    }

    -- Rien de ce qui est dans MA base ne doit etre touche.
    local function underMyPlot(d)
        local mp = _G.__SXE_MyPlot
        if not mp then return false end
        local x = d
        for _ = 1, 14 do
            if not x or x == workspace then return false end
            if x.Name == mp then
                local p = x.Parent
                if p and p.Name == "Plots" then return true end
            end
            x = x.Parent
        end
        return false
    end
    local function underUnlock(d)
        local x = d
        for _ = 1, 12 do
            if not x then return false end
            if x.Name == "Unlock" then return true end
            if x == workspace then return false end
            x = x.Parent
        end
        return false
    end
    local function isMine(inst)
        if not (LP and inst) then return false end
        if inst == LP.Character or inst.Name == LP.Name then return true end
        return false
    end
    local function isVisualJunk(d)
        local cn = d.ClassName
        return cn == "Beam" or cn == "Trail" or cn == "ParticleEmitter"
            or cn == "PointLight" or cn == "SpotLight" or cn == "SurfaceLight"
            or cn == "Fire" or cn == "Smoke" or cn == "Sparkles"
            or cn == "BillboardGui" or cn == "SurfaceGui" or cn == "Highlight"
            or cn == "Decal" or cn == "Texture"
    end
    local function isSkinJunk(d)
        if not d then return false end
        if isVisualJunk(d) then return true end
        return PART_CLASS[d.ClassName] == true and not d.CanCollide
    end
    local function isPet(inst)
        if not inst or inst.ClassName ~= "Model" then return false end
        return inst:FindFirstChild("FakeRootPart") ~= nil
            or inst:FindFirstChild("RootPart") ~= nil
    end
    local function stripSkin(skin)
        if not (skin and skin.Parent) then return end
        local dd = skin:GetDescendants()
        local dump = {}
        for i = 1, #dd do
            if isSkinJunk(dd[i]) then dump[#dump + 1] = dd[i] end
        end
        for i = 1, #dump do kill(dump[i]) end
    end
    local function skipLaserStrip(plot)
        local keep = _G.__SXE_KeepPlot
        if not keep then
            return true
        end
        return plot and tostring(plot.Name) == tostring(keep)
    end
    local laserPend = {}
    local function stripLaser(laser)
        if not (laser and laser.Parent) then return end
        if skipLaserStrip(laser.Parent) then return end
        local bars = {}
        local beamPart = {}
        local dd = laser:GetDescendants()
        for i = 1, #dd do
            local d = dd[i]
            if d.ClassName == "Beam" then
                local a0, a1 = d.Attachment0, d.Attachment1
                local p0 = a0 and a0.Parent
                local p1 = a1 and a1.Parent
                if p0 and p0:IsA("BasePart") then beamPart[p0] = true end
                if p1 and p1:IsA("BasePart") then beamPart[p1] = true end
            elseif d:IsA("BasePart") then
                bars[#bars + 1] = d
            end
        end
        if #bars > 0 then
            local chosen = {}
            for i = 1, #bars do
                if beamPart[bars[i]] then chosen[#chosen + 1] = bars[i] end
            end
            if #chosen == 0 then
                for i = 1, #bars do
                    local d = bars[i]
                    local s = d.Size
                    local mx = math.max(s.X, s.Y, s.Z)
                    local mn = math.min(s.X, s.Y, s.Z)
                    local neon = false
                    pcall(function()
                        neon = d.Material == Enum.Material.Neon
                            or d.Material == Enum.Material.ForceField
                    end)
                    if neon or (mn <= 1.5 and mx >= 3) then
                        chosen[#chosen + 1] = d
                    end
                end
            end
            if #chosen == 0 then chosen = bars end
            local keep = chosen[1]
            if keep then
                for i = 1, #bars do
                    if bars[i] ~= keep then kill(bars[i]) end
                end
                -- La barre gardee reste solide : c'est elle qui dit au hub que la
                -- base est encore bloquee.
            end
        end
    end
    local function queueStripLaser(laser)
        if not laser or laserPend[laser] then return end
        laserPend[laser] = true
        task.defer(function()
            laserPend[laser] = nil
            stripLaser(laser)
        end)
    end
    local function stripPetVfx(pet)
        if not pet then return end
        local dd = pet:GetDescendants()
        local dump = {}
        for i = 1, #dd do
            local d = dd[i]
            local n = d.Name
            local cn = d.ClassName
            if n == "VfxInstance" or n == "_VfxInstance" or n == "AnimationController"
                or cn == "ParticleEmitter" or cn == "Beam" or cn == "Trail"
                or cn == "Fire" or cn == "Smoke" or cn == "Sparkles"
                or cn == "Animator" or cn == "AnimationController"
                or cn == "Bone"
                or cn == "BillboardGui" or cn == "SurfaceGui" then
                dump[#dump + 1] = d
            end
        end
        for i = 1, #dump do kill(dump[i]) end
    end
    _G.SXE_StripPetVfx = stripPetVfx

    local function isCharJunk(d)
        if not d then return false end
        local cn = d.ClassName
        if cn == "PathfindingModifier" then return false end
        if cn == "WrapTarget" or cn == "WrapLayer" then return true end
        if cn == "Shirt" or cn == "ShirtGraphic" then return true end
        if cn == "NoCollisionConstraint" then return true end
        local nm = d.Name
        if nm == "__HITBOX" or nm == "OriginalPosition" or nm == "OriginalSize" then return true end
        if CHAR_KEEP_CLASS[cn] then return false end
        if BODY_PART[nm] then return false end
        return true
    end
    local function isUuidName(n)
        return type(n) == "string" and #n == 36
            and string.match(n, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
    end
    local function isOtherAvatar(char)
        if not (char and char.ClassName == "Model") then return false end
        if isMine(char) then return false end
        if isPet(char) then return false end
        local n = char.Name
        if type(n) == "string" and string.sub(n, -6) == "_Clone" then return false end
        if Players:GetPlayerFromCharacter(char) then return true end
        if Players:FindFirstChild(n) then return true end
        return char:FindFirstChildOfClass("Humanoid") ~= nil
    end
    local hookedChars = {}
    local function stripOtherChar(char)
        if _G.__SXE_VelFlying then return end
        if not (char and char.Parent) or isMine(char) or not isOtherAvatar(char) then return end
        local function sweep()
            local dd = char:GetDescendants()
            local dump = {}
            for i = 1, #dd do
                if isCharJunk(dd[i]) then dump[#dump + 1] = dd[i] end
            end
            for i = 1, #dump do kill(dump[i]) end
        end
        sweep()
        if hookedChars[char] then return end
        hookedChars[char] = true
        char.DescendantAdded:Connect(function(d)
            if _G.__SXE_VelFlying then return end
            if d and d.Parent and not isMine(char) and isCharJunk(d) then kill(d) end
        end)
    end

    local strippedPlots = {}
    _G.__SXE_StrippedPlots = strippedPlots
    local function near(a, b)
        return math.abs(a - b) < 0.2
    end
    local function isPlotPadPart(d)
        if not d or PART_CLASS[d.ClassName] ~= true then return false end
        if d.Name == "structure base home" or d.Name == "Spawn" then return false end
        local s = d.Size
        if near(s.X, 4) and near(s.Y, 1) and near(s.Z, 4) then return true end
        if near(s.X, 2) and near(s.Y, 0.5) and near(s.Z, 2) then return true end
        return false
    end
    local function isPodiumPlate(d)
        if not d or PART_CLASS[d.ClassName] ~= true then return false end
        if d.Name == "Spawn" then return false end
        local s = d.Size
        if near(s.X, 6) and near(s.Y, 0.2) and near(s.Z, 6) then return true end
        if near(s.X, 4) and near(s.Y, 0.2) and near(s.Z, 4) then return true end
        return false
    end
    local function stripPlotDecor(dec)
        if not (dec and dec.Parent) then return end
        local dump = {}
        local function walk(x)
            local kids = x:GetChildren()
            for i = 1, #kids do
                local d = kids[i]
                local cn = d.ClassName
                local nm = d.Name
                if nm == "Spawn" or nm == "PromptAttachment" or cn == "ProximityPrompt" then
                elseif cn == "Model" and isPet(d) then
                elseif cn == "Beam" or cn == "PointLight" then
                    dump[#dump + 1] = d
                elseif isPlotPadPart(d) then
                    dump[#dump + 1] = d
                else
                    walk(d)
                end
            end
        end
        walk(dec)
        for i = 1, #dump do kill(dump[i]) end
    end
    local function stripPodiumPlates(pods)
        if not (pods and pods.Parent) then return end
        local dump = {}
        local function scan(folder)
            if not folder then return end
            local dd = folder:GetDescendants()
            for i = 1, #dd do
                local d = dd[i]
                if d.Name ~= "Spawn" and d.Name ~= "PromptAttachment"
                    and d.ClassName ~= "ProximityPrompt" and isPodiumPlate(d) then
                    dump[#dump + 1] = d
                end
            end
        end
        local slots = pods:GetChildren()
        for i = 1, #slots do
            local slot = slots[i]
            local base = slot:FindFirstChild("Base")
            if base then scan(base:FindFirstChild("Decorations")) end
            scan(slot:FindFirstChild("Decorations"))
        end
        for i = 1, #dump do kill(dump[i]) end
    end
    local function handlePlotChild(plot, ch)
        if not (ch and ch.Parent) then return end
        local n = ch.Name
        if n == "Skin" then stripSkin(ch); return end
        if n == "Laser" then
            if not skipLaserStrip(plot) then stripLaser(ch) end
            return
        end
        if n == "AnimalPodiums" then stripPodiumPlates(ch); return end
        if n == "Decorations" then stripPlotDecor(ch); return end
        if PLOT_KEEP[n] then return end
        if PLOT_NUKE[n] then kill(ch); return end
        if isPet(ch) then
            stripPetVfx(ch)
            return
        end
    end
    local function stripPlotInteriorFast(plot)
        if not (plot and plot.Parent) then return end
        if _G.__SXE_MyPlot and plot.Name == _G.__SXE_MyPlot then return end
        strippedPlots[plot.Name] = true
        local kids = plot:GetChildren()
        for i = 1, #kids do
            local ch = kids[i]
            if ch and ch.Parent then
                local n = ch.Name
                if n == "Skin" or n == "Laser" or n == "AnimalPodiums" or n == "Decorations" then
                elseif PLOT_KEEP[n] then
                elseif PLOT_NUKE[n] then
                    kill(ch)
                elseif isPet(ch) then
                    stripPetVfx(ch)
                end
            end
        end
    end
    local function stripPlotVisual(plot)
        if not (plot and plot.Parent) then return end
        if _G.__SXE_MyPlot and plot.Name == _G.__SXE_MyPlot then return end
        local skin = plot:FindFirstChild("Skin")
        if skin then stripSkin(skin) end
        local laser = plot:FindFirstChild("Laser")
        if laser and not skipLaserStrip(plot) then stripLaser(laser) end
        local pods = plot:FindFirstChild("AnimalPodiums")
        if pods then stripPodiumPlates(pods) end
        local dec = plot:FindFirstChild("Decorations")
        if dec then stripPlotDecor(dec) end
        local kids = plot:GetChildren()
        for i = 1, #kids do
            local ch = kids[i]
            if isPet(ch) then stripPetVfx(ch) end
        end
    end
    local function stripPlotInterior(plot)
        stripPlotInteriorFast(plot)
        stripPlotVisual(plot)
    end
    local function connectPlot(plot)
        if not (plot and plot.Parent) then return end
        -- Ma base : aucun gestionnaire destructeur. Sans ca, ses interfaces
        -- (panneau des amis, pad de verrouillage) etaient detruites a mesure
        -- qu'elles arrivaient.
        if _G.__SXE_MyPlot and plot.Name == _G.__SXE_MyPlot then return end
        plot.ChildAdded:Connect(function(ch)
            if _G.__SXE_VelFlying then return end
            handlePlotChild(plot, ch)
        end)
        plot.DescendantAdded:Connect(function(d)
            if _G.__SXE_VelFlying then return end
            if not d then return end
            if underUnlock(d) then return end
            local cn = d.ClassName
            if cn == "BillboardGui" or cn == "SurfaceGui" then kill(d); return end
            if d.Name == "Spawn" or d.Name == "PromptAttachment" or cn == "ProximityPrompt" then
                return
            end
            if d.Name == "Decorations" and d.Parent == plot then
                stripPlotDecor(d)
                return
            end
            local p = d.Parent
            if not p then return end
            if PART_CLASS[d.ClassName] then
                if isPlotPadPart(d) then
                    local x = p
                    local inPlotDec, skip = false, false
                    while x and x ~= plot do
                        if isPet(x) or x.Name == "Spawn" or x.Name == "AnimalPodiums" then
                            skip = true; break
                        end
                        if x.Name == "Decorations" and x.Parent == plot then inPlotDec = true end
                        x = x.Parent
                    end
                    if inPlotDec and not skip then kill(d); return end
                elseif isPodiumPlate(d) then
                    local x = p
                    local inDec, skip = false, false
                    while x and x ~= plot do
                        if x.Name == "Spawn" then skip = true; break end
                        if x.Name == "Decorations" then inDec = true end
                        if x.Name == "AnimalPodiums" then
                            if inDec and not skip then kill(d) end
                            return
                        end
                        x = x.Parent
                    end
                end
            end
            local sk = p
            while sk and sk ~= plot do
                if sk.Name == "Skin" then
                    if isSkinJunk(d) then kill(d) end
                    return
                end
                sk = sk.Parent
            end
            local las = p
            while las and las ~= plot do
                if las.Name == "Laser" then
                    if skipLaserStrip(plot) then return end
                    queueStripLaser(las)
                    return
                end
                las = las.Parent
            end
        end)
    end
    local hookedPlots
    local function hookPlot(plot)
        stripPlotInterior(plot)
        connectPlot(plot)
    end
    local function hookPlots(folder)
        if not folder or hookedPlots == folder then return end
        hookedPlots = folder
        local kids = folder:GetChildren()
        for i = 1, #kids do stripPlotInterior(kids[i]) end
        for i = 1, #kids do connectPlot(kids[i]) end
        folder.ChildAdded:Connect(function(plot)
            hookPlot(plot)
            local keep = _G.__SXE_KeepPlot
            if keep and plot.Name ~= keep and plot.Name ~= _G.__SXE_MyPlot then
                kill(plot)
            end
        end)
    end
    local function plotIsMine(plot)
        if not plot then return false end
        if _G.__SXE_MyPlot and plot.Name == _G.__SXE_MyPlot then return true end
        local ch
        pcall(function()
            if _G.XenSyncGet then ch = _G.XenSyncGet(plot.Name) end
        end)
        if ch and _G.SXE_IsMyPlot and _G.SXE_IsMyPlot(ch) then
            _G.__SXE_MyPlot = plot.Name
            return true
        end
        return false
    end
    _G.SXE_LockPrioPlot = function(plotName)
        if not plotName then return end
        _G.__SXE_KeepPlot = tostring(plotName)
        local plots = workspace:FindFirstChild("Plots")
        if not plots then return end
        local kids = plots:GetChildren()
        for i = 1, #kids do
            local plot = kids[i]
            if plot.Name ~= _G.__SXE_KeepPlot and not plotIsMine(plot) then
                kill(plot)
            end
        end
        local mine = _G.__SXE_MyPlot and plots:FindFirstChild(_G.__SXE_MyPlot)
        if mine and _G.SXE_NukePlotPodiums then
            pcall(_G.SXE_NukePlotPodiums, mine)
        end
        local keepPlot = _G.__SXE_KeepPlot and plots:FindFirstChild(_G.__SXE_KeepPlot)
        if keepPlot and _G.SXE_StripNonPrioPodiums then
            pcall(_G.SXE_StripNonPrioPodiums, keepPlot)
        end
    end

    local function stripMap(map)
        if _G.SXE_KeepMap == true then return end
        local function handle(x)
            if _G.__SXE_VelFlying then return end
            if x and not MAP_KEEP[x.Name] then kill(x) end
        end
        local kids = map:GetChildren()
        for i = 1, #kids do handle(kids[i]) end
        map.ChildAdded:Connect(handle)
    end
    local hookedRma
    local rmaBoxDone = false
    local function hookRma(rma)
        if not rma then return end
        if rmaBoxDone then
            kill(rma)
            return
        end
        if hookedRma == rma then return end
        hookedRma = rma
        local function nuke()
            if _G.__SXE_VelFlying then return end
            if rmaBoxDone then return end
            rmaBoxDone = true
            kill(rma)
        end
        if #rma:GetChildren() > 0 then
            nuke()
        else
            rma.ChildAdded:Connect(nuke)
        end
    end
    local function onWsChild(ch)
        if not ch then return end
        if _G.__SXE_VelFlying then return end
        local n = ch.Name
        if ch.ClassName == "Camera" or ch.ClassName == "Terrain" then return end
        if n == "Plots" then hookPlots(ch); return end
        if n == "RenderedMovingAnimals" then hookRma(ch); return end
        if n == "Map" then stripMap(ch); return end
        if isMine(ch) then return end
        if isUuidName(n) then kill(ch); return end
        if isOtherAvatar(ch) then stripOtherChar(ch); return end
        if ch.ClassName == "Model" then
            ch.ChildAdded:Connect(function()
                if isOtherAvatar(ch) then stripOtherChar(ch) end
            end)
        end
        if string.sub(n, 1, 7) == "BeeHive" or string.sub(n, 1, 7) == "Sentry_" then
            kill(ch)
            return
        end
        if WS_KILL[n] or ch.ClassName == "Highlight" then kill(ch); return end
        if ch.ClassName == "Model" and string.find(n, "'s Rainbow", 1, true) then
            kill(ch)
        end
    end
    local wsch = workspace:GetChildren()
    local plotsFolder, mapFolder, rmaFolder
    local rest = {}
    for i = 1, #wsch do
        local ch = wsch[i]
        local n = ch.Name
        if n == "Plots" then plotsFolder = ch
        elseif n == "Map" then mapFolder = ch
        elseif n == "RenderedMovingAnimals" then rmaFolder = ch
        else rest[#rest + 1] = ch end
    end
    if mapFolder then stripMap(mapFolder) end
    if rmaFolder then hookRma(rmaFolder) end
    for i = 1, #rest do onWsChild(rest[i]) end
    if plotsFolder then hookPlots(plotsFolder) end
    workspace.ChildAdded:Connect(onWsChild)

    local function hookPlrChar(plr)
        if not plr or plr == LP then return end
        if plr.Character then stripOtherChar(plr.Character) end
        plr.CharacterAdded:Connect(stripOtherChar)
    end
    local plrs = Players:GetPlayers()
    for i = 1, #plrs do hookPlrChar(plrs[i]) end
    Players.PlayerAdded:Connect(hookPlrChar)

    local function onLit(x)
        if _G.__SXE_VelFlying then return end
        if not x then return end
        local cn = x.ClassName
        if cn == "Sky" or cn == "Atmosphere" or cn == "Clouds"
            or cn == "SunRaysEffect" or cn == "ColorCorrectionEffect" then
            kill(x)
        end
    end
    local lit = Lighting:GetChildren()
    for i = 1, #lit do onLit(lit[i]) end
    Lighting.ChildAdded:Connect(onLit)
    local function stripCamFx(x)
        if not x then return end
        local cn = x.ClassName
        if cn == "ColorCorrectionEffect" or cn == "BlurEffect" then kill(x) end
    end
    local hookedCam
    local function hookCam(cam)
        if not cam or hookedCam == cam then return end
        hookedCam = cam
        local ck = cam:GetChildren()
        for i = 1, #ck do stripCamFx(ck[i]) end
        cam.ChildAdded:Connect(stripCamFx)
    end
    hookCam(workspace.CurrentCamera)
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        hookCam(workspace.CurrentCamera)
    end)
    workspace.DescendantAdded:Connect(function(d)
        if not d then return end
        if _G.__SXE_VelFlying then return end
        local cn = d.ClassName
        if cn == "BillboardGui" or cn == "SurfaceGui" or cn == "Decal" or cn == "Texture" then
            if underUnlock(d) then return end
            if underMyPlot(d) then return end
            kill(d)
        end
        -- Smooth new parts as they arrive (floors, kept plots)
        if d:IsA("BasePart") or d:IsA("SurfaceAppearance") or d:IsA("SpecialMesh") then
            pcall(smoothOrStrip, d)
        end
    end)
    if mapFolder and mapFolder.Parent then
        local md = mapFolder:GetDescendants()
        for i = 1, #md do
            local cn = md[i].ClassName
            if cn == "Decal" or cn == "Texture" then kill(md[i]) end
        end
    end
    do
        local ter = workspace.Terrain
        pcall(function() ter.Decoration = false end)
        pcall(function() ter:Clear() end)
        local kids = ter:GetChildren()
        for i = 1, #kids do kill(kids[i]) end
        ter.ChildAdded:Connect(function(ch)
            if _G.__SXE_VelFlying then return end
            kill(ch)
        end)
        ter.DescendantAdded:Connect(function(d)
            if _G.__SXE_VelFlying then return end
            if d then kill(d) end
        end)
    end
    -- === Lighting & render quality nukes (from 20m_base) ===
    -- Strip PostEffects (bloom, blur, DoF, sun rays) and force lowest quality.
    do
        local Lit = game:GetService("Lighting")
        local litKids = Lit:GetChildren()
        for i = 1, #litKids do
            local fx = litKids[i]
            if fx:IsA("PostEffect") or fx:IsA("Atmosphere") or fx:IsA("Sky") or fx:IsA("Clouds") then
                pcall(function() fx:Destroy() end)
            end
        end
        pcall(function()
            Lit.GlobalShadows            = false
            Lit.FogEnd                   = 1e9
            Lit.EnvironmentDiffuseScale  = 0
            Lit.EnvironmentSpecularScale = 0
        end)
        pcall(function()
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        end)
    end

    _G.__SXE_StripDone = true
    task.spawn(function()
        local t0 = os.clock()
        while os.clock() - t0 < (tonumber(_G.SXE_PlotRescanFor) or 45) do
            task.wait(tonumber(_G.SXE_PlotRescanEvery) or 3)
            if not _G.__SXE_VelFlying then
                local pf = workspace:FindFirstChild("Plots")
                if pf then
                    for _, plot in ipairs(pf:GetChildren()) do
                        pcall(stripPlotInteriorFast, plot)
                        pcall(stripPlotVisual, plot)
                    end
                end
            end
        end
        _G.SXE_PlotRescanDiag = "plot rescan finished"
    end)
end

-- === sync channel reader (from SRC) (src 1075-1141)
do
    local _xchan
    local _synInst, _syncMod
    local function _synNow()
        if _synInst and _synInst.Parent then return _synInst end
        local p = ReplicatedStorage:FindFirstChild("Packages")
        _synInst = p and p:FindFirstChild("Synchronizer")
        return _synInst
    end
    local function _trySenv()
        if _xchan then return true end
        local syn = _synNow()
        if not syn then return false end
        if type(_syncMod) ~= "table" then
            local req = (getrenv and getrenv().require) or require
            local ok, mod = pcall(req, syn)
            if ok and type(mod) == "table" then _syncMod = mod end
        end
        local getFn = type(_syncMod) == "table" and rawget(_syncMod, "Get")
        local gf = getfenv or (debug and debug.getfenv)
        if type(getFn) ~= "function" or type(gf) ~= "function" then return false end
        local ok, env = pcall(gf, getFn)
        if not ok or type(env) ~= "table" then return false end
        local ch = rawget(env, "Channels")
        if type(ch) ~= "table" then return false end
        _xchan = ch
        return true
    end
    local t0 = os.clock()
    while os.clock() - t0 < 8 do
        if _trySenv() then break end
        RunService.Heartbeat:Wait()
    end
    local function _chans()
        if _xchan then return _xchan end
        _trySenv()
        return _xchan
    end
    _G.XenSyncAll = function() return _chans() end
    _G.XenSyncGet = function(idx)
        local t = _chans()
        if not t or idx == nil then return nil end
        local ok, cd = pcall(rawget, t, idx)
        if ok and type(cd) == "table" then return cd end
        local ok2, cd2 = pcall(function() return t[idx] end)
        if ok2 and type(cd2) == "table" then return cd2 end
        return nil
    end
    _G.SXE_IsPlotChanKey = function(k)
        return type(k) == "string" and #k >= 32 and string.find(k, "-", 1, true) ~= nil
    end
    _G.sProp = function(ch, key)
        if type(ch) ~= "table" or key == nil then return nil end
        local ct = rawget(ch, "CacheTable")
        if type(ct) ~= "table" then
            local okC, c2 = pcall(function() return ch.CacheTable end)
            if okC and type(c2) == "table" then ct = c2 end
        end
        if type(ct) ~= "table" then return nil end
        local v = rawget(ct, key)
        if v ~= nil then return v end
        local okV, v2 = pcall(function() return ct[key] end)
        if okV then return v2 end
        return nil
    end
    if _xchan then _G.__SXE_SyncBoot = true end
end

-- === priority list + set (from SRC) (src 1224-1291)
priorityList = {
    "Headless Horseman",
    "Signore Carapace",
    "Strawberry Elephant",
    "Elefanto Frigo",
    "John Pork",
    "Meowl",
    "Los Dragons",
    "Skibidi Toilet",
    "Arcadragon",
    "Griffin",
    "Dragon Gingerini",
    "Dragon Aquanini",
    "Love Love Bear",
    "Orchidox",
    "Antonio",
    "Moby Bros",
    "Jelly Moby",
    "Fishino Clownino",
    "La Supreme Combinasion",
    "Kraken",
    "Ginger Gerat",
    "Hydra Bunny",
    "Bunny and Eggy",
    "Pancake and Syrup",
    "Hydra Dragon Cannelloni",
    "Dragon Cannelloni",
    "Tirilikalika Tirilikalako",
    "Grabatron",
    "Foxini Lanternini",
    "Rosey and Teddy",
    "La Casa Boo",
    "Bumbatron",
    "Spooky and Pumpky",
    "Venuspino",
    "Los Admins",
    "Dug dug dug",
    "La Fuse Machine",
    "Rico Dinero",
    "Globa Steppa",
    "Examen Bros",
    "Sammyni Truckini",
    "Sammyni Fattini",
    "Duggy Bros",
    "Foxini Lanternini",
    "Cerberus",
    "Cooki and Milki",
    "La Craft Machine",
    "Popcuru and Fizzuru",
    "Reinito Sleighito",
    "Fragrama and Chocrama",
    "La Food Combinasion",
    "Capitano Moby",
    "Guest 666",
    "Jolly Jolly Sahur",
    "Burguro And Fryuro",
    "pizza and ranch",
    "Garama And Madundung",
    "Fragola La La La",
    "La Breakfast Combinasion",

}
_G.SXE_PrioSet = {}
for _, n in ipairs(priorityList) do
    if type(n) == "string" and n ~= "" then
        _G.SXE_PrioSet[string.lower(n)] = true
    end
end

-- === plot owner check (from SRC) (src 1605-1627)
    local function channelGet(channel, key)
        return _G.sProp(channel, key)
    end
    local _myPlotYes = setmetatable({}, { __mode = "k" })
    local function isMyPlot(channel)
        if not channel then return false end
        if _myPlotYes[channel] then return true end
        local owner = channelGet(channel, "Owner")
        if not owner then return false end
        local result = false
        pcall(function()
            if typeof(owner) == "Instance" and owner:IsA("Player") then
                result = owner.UserId == LP.UserId
            elseif type(owner) == "table" and owner.UserId then
                result = owner.UserId == LP.UserId
            elseif typeof(owner) == "Instance" then
                result = owner == LP
            end
        end)
        if result then _myPlotYes[channel] = true end
        return result
    end
    _G.SXE_IsMyPlot = isMyPlot

-- === hide own character (src 4174-4217)
task.spawn(function()
    local LP = game.Players.LocalPlayer
    local saved = {}
    local function hideChar(char)
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BasePart") or d:IsA("MeshPart") then
                if saved[d] == nil then saved[d] = d.Transparency end
                pcall(function() d.Transparency = 1 end)
            elseif d:IsA("Decal") or d:IsA("Texture") then
                if saved[d] == nil then saved[d] = d.Transparency end
                pcall(function() d.Transparency = 1 end)
            elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") then
                if saved[d] == nil then saved[d] = d.Enabled end
                pcall(function() d.Enabled = false end)
            end
        end
    end
    local function restoreAll()
        for d, v in pairs(saved) do
            if d and d.Parent then
                pcall(function()
                    if type(v) == "boolean" then d.Enabled = v
                    else d.Transparency = v end
                end)
            end
        end
        saved = {}
    end
    local _runBusy = false
    local function run()
        if _G.SXE_HideOnLoad ~= true then return end
        if _runBusy then return end
        _runBusy = true
        local t0 = os.clock()
        while os.clock() - t0 < 5 do
            hideChar(LP.Character)
            task.wait(0.2)
        end
        restoreAll()
        _runBusy = false
    end
    task.spawn(run)
    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        task.spawn(run)
    end)
end)

-- === UI / inventory strip (src 4221-4266)
task.spawn(function()
    local LP = game.Players.LocalPlayer
    local pg = LP:WaitForChild("PlayerGui", 10)
    if not pg then return end
    local KILL_BTNS = {
        Index = true, Rebirth = true, Shop = true,
        DuelsMachinePlayerList = true, TradePlayerList = true, Codes = true,
    }
    local KILL_GUIS = { LeftBottom = true, HoneyBeeBase = true }
    local function strip()
        local lc = pg:FindFirstChild("LeftCenter")
        if lc then
            for _, d in ipairs(lc:GetDescendants()) do
                if (d:IsA("TextButton") or d:IsA("ImageButton")) and KILL_BTNS[d.Name] then
                    pcall(function() d:Destroy() end)
                end
            end
        end
        for name in pairs(KILL_GUIS) do
            local g = pg:FindFirstChild(name)
            if g then pcall(function() g:Destroy() end) end
        end
    end
    local function hookLC(lc)
        strip()
        lc.DescendantAdded:Connect(function(d)
            if (d:IsA("TextButton") or d:IsA("ImageButton")) and KILL_BTNS[d.Name] then
                pcall(function() d:Destroy() end)
            end
        end)
    end
    local lc = pg:FindFirstChild("LeftCenter")
    if lc then hookLC(lc) end
    pg.ChildAdded:Connect(function(g)
        if g.Name == "LeftCenter" then hookLC(g) end
        if KILL_GUIS[g.Name] then pcall(function() g:Destroy() end) end
    end)
    pg.DescendantAdded:Connect(function(d)
        if (d:IsA("TextButton") or d:IsA("ImageButton")) and KILL_BTNS[d.Name] then
            pcall(function() d:Destroy() end)
        end
    end)
    task.spawn(function()
        while true do task.wait(2); strip() end
    end)
end)

-- === base + wall hiding (src 4269-4331)
task.spawn(function()
    local LP = game.Players.LocalPlayer
    local KEEP = { AnimalPodiums = true, Laser = true, Spawn = true,
        AnimalTarget = true, StealHitbox = true, DeliveryHitbox = true, MainRoot = true }
    local saved = {}
    local function hidePart(d)
        if d:IsA("BasePart") or d:IsA("MeshPart") then
            if saved[d] == nil then
                saved[d] = { t = d.Transparency, cs = d.CastShadow, mat = d.Material }
            end
            pcall(function()
                d.Transparency = 1
                d.CastShadow = false
                if d.Material == Enum.Material.Neon or d.Material == Enum.Material.ForceField then
                    d.Material = Enum.Material.SmoothPlastic
                end
            end)
        elseif d:IsA("PointLight") or d:IsA("SpotLight") or d:IsA("SurfaceLight")
            or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam")
            or d:IsA("Smoke") or d:IsA("Sparkles") or d:IsA("Fire") then
            if saved[d] == nil then saved[d] = { en = d.Enabled } end
            pcall(function() d.Enabled = false end)
        end
    end
    local function restorePart(d)
        local s = saved[d]
        if not s then return end
        pcall(function()
            if s.t ~= nil then d.Transparency = s.t end
            if s.cs ~= nil then d.CastShadow = s.cs end
            if s.mat ~= nil then d.Material = s.mat end
            if s.en ~= nil then d.Enabled = s.en end
        end)
    end
    local function hideMyBase()
        local mp = _G.__SXE_MyPlot
        if not mp then return end
        local plots = workspace:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild(mp)
        if not plot then return end
        for _, ch in ipairs(plot:GetChildren()) do
            if not KEEP[ch.Name] then
                for _, d in ipairs(ch:GetDescendants()) do hidePart(d) end
                hidePart(ch)
            end
        end
    end
    local _runBusy = false
    local function run()
        if _G.SXE_HideOnLoad ~= true then return end
        if _runBusy then return end
        _runBusy = true
        local t0 = os.clock()
        while os.clock() - t0 < 5 do
            hideMyBase()
            task.wait(0.2)
        end
        for d in pairs(saved) do restorePart(d) end
        saved = {}
        _runBusy = false
    end
    task.spawn(run)
    LP.CharacterAdded:Connect(function()
        task.wait(0.5)
        task.spawn(run)
    end)
end)

-- === map ground hiding (src 4334-4367)
task.spawn(function()
    local GROUND = { Ground = true, Ground_Left = true, Ground_Right = true }
    local saved = {}
    local function hideGround()
        local map = workspace:FindFirstChild("Map")
        if not map then return end
        for _, d in ipairs(map:GetChildren()) do
            if GROUND[d.Name] and d:IsA("BasePart") then
                if saved[d] == nil then saved[d] = d.Transparency end
                pcall(function() d.Transparency = 1 end)
            end
        end
    end
    local function restoreGround()
        for d, v in pairs(saved) do
            if d and d.Parent then pcall(function() d.Transparency = v end) end
        end
        saved = {}
    end
    local _runBusy = false
    local function run()
        if _G.SXE_HideOnLoad ~= true then return end
        if _runBusy then return end
        _runBusy = true
        local t0 = os.clock()
        while os.clock() - t0 < 5 do
            hideGround()
            task.wait(0.2)
        end
        restoreGround()
        _runBusy = false
    end
    task.spawn(run)
    game.Players.LocalPlayer.CharacterAdded:Connect(function()
        task.wait(0.5)
        task.spawn(run)
    end)
end)

task.spawn(function()
	local ok, err = pcall(__sxeStrip)
	_G.SXE_StripDiag = ok and "strip done" or ("strip failed: " .. tostring(err))
	if not ok then warn("[extracted opti] " .. tostring(err)) end
end)
task.spawn(function()
	local t0 = os.clock()
	while os.clock() - t0 < (tonumber(_G.SXE_StripRetryFor) or 20) do
		task.wait(0.25)
		if not _G.__SXE_StripDone and not _G.__SXE_VelFlying then
			pcall(__sxeStrip)
		end
	end
end)
