if _G.EliteOptimizer~=false and not _G.__EliteEarlyOpt then
_G.__EliteEarlyOpt=true
do
local Players=game:GetService("Players")
local function pin(a)
if a and a.Name=="Animate"then
pcall(function()a.Disabled=true end)
end
end
local function hook(char)
if not char then return end
pin(char:FindFirstChild("Animate"))
char.ChildAdded:Connect(pin)
end
local function onLp(lp)
if not lp then return end
if lp.Character then hook(lp.Character)end
lp.CharacterAdded:Connect(hook)
end
if _G.EliteAnimatePin~=false then
local lp=Players.LocalPlayer
if lp then
onLp(lp)
else
Players.PlayerAdded:Connect(onLp)
end
end
end
if _G.EliteControllerFilter~=false then
local RS=game:GetService("ReplicatedStorage")
local KEEP={
CustomProximityPromptController=true,
InteractController=true,
PlotController=true,
AnimalController=true,
PetController=true,
WorldBrainrotController=true,
EquipBrainrotsController=true,
EquipBrainrotsRenderController=true,
SelectBrainrotsController=true,
BrainrotPreloadingController=true,
AssetStreamController=true,
AdminPanelController=true,
NotificationController=true,
CharacterController=true,
}
if type(_G.EliteControllerKeep)=="table"then
for k,v in pairs(_G.EliteControllerKeep)do
if type(k)=="string"then KEEP[k]=v and true or nil end
end
end
local function wrap(fn)
if newcclosure then
return newcclosure(fn)
end
return fn
end
local function isCtrlFolder(x)
return typeof(x)=="Instance"and x.Name=="Controllers"and x.Parent==RS
end
local function callerName()
if not getcallingscript then
return"?"
end
local ok,s=pcall(getcallingscript)
if not ok or s==nil then
return"nil"
end
return tostring(s.Name)
end
local function fromLoader()
return callerName()=="ClientLoader"
end
local function filt(kids)
if type(kids)~="table"then
return kids
end
local out={}
for i=1,#kids do
local k=kids[i]
if k and KEEP[k.Name]then
out[#out+1]=k
end
end
return out
end
local oldNc
local undone=false
local function unhook()
if undone then return end
undone=true
pcall(function()
if oldNc then
hookmetamethod(game,"__namecall",oldNc)
end
end)
end
pcall(function()
oldNc=hookmetamethod(game,"__namecall",wrap(function(self,...)
local method=getnamecallmethod()
if type(method)~="string"then
return oldNc(self,...)
end
local ml=string.lower(method)
if ml~="getchildren"then
return oldNc(self,...)
end
if not isCtrlFolder(self)then
return oldNc(self,...)
end
if not fromLoader()then
return oldNc(self,...)
end
return filt(oldNc(self,...))
end))
end)
task.delay(6,unhook)
end
end
local __eliteOk,__eliteErr=xpcall(function()
_G.__EliteNames=_G.__EliteNames or{}
function EN(logical)
local n=_G.__EliteNames[logical]
if n then return n end
local c={}
for i=1,math.random(10,16)do
c[i]=string.char(math.random(0,1)==0 and math.random(65,90)or math.random(97,122))
end
n=table.concat(c)
_G.__EliteNames[logical]=n
return n
end
function EliteGuiHost()
local h
pcall(function()h=gethui and gethui()end)
if not h then pcall(function()h=game:GetService("CoreGui")end)end
return h
end
function EliteParentGui(g)
pcall(function()
if syn and syn.protect_gui then syn.protect_gui(g)
elseif protectgui then protectgui(g)
elseif protect_gui then protect_gui(g)end
end)
local h=EliteGuiHost()
if h then pcall(function()g.Parent=h end)end
return g.Parent~=nil
end
do
local stats,on={},true
local P={}
function P.mark(name,t0)
if not on then return end
local ms=(os.clock()-t0)*1000
local st=stats[name]
if not st then st={n=0,total=0,worst=0};stats[name]=st end
st.n=st.n+1
st.total=st.total+ms
if ms>st.worst then st.worst=ms end
end
function P.wrap(name,fn)
if type(fn)~="function"then return fn end
return function(...)
if not on then return fn(...)end
local t0=os.clock()
local a,b,c=fn(...)
P.mark(name,t0)
return a,b,c
end
end
function P.report()
local rows={}
for name,st in pairs(stats)do
rows[#rows+1]={name=name,total=st.total,n=st.n,
avg=st.total/math.max(st.n,1),worst=st.worst}
end
table.sort(rows,function(x,y)return x.total>y.total end)
print("[PROF] ---- heaviest first ----")
for i=1,math.min(#rows,12)do
local r=rows[i]
print(string.format("[PROF] %-20s total %8.1fms  calls %6d  avg %6.3fms  worst %6.2fms",
r.name,r.total,r.n,r.avg,r.worst))
end
end
function P.reset()stats={}end
function P.off()on=false end
function P.auto(gap)
task.spawn(function()
while true do
task.wait(tonumber(gap)or 10)
P.report()
P.reset()
end
end)
end
_G.EliteProf=P
end
_G.EliteScanProfile=function(mode)
if mode=="fast"then
_G.EliteScanMode="fast"
_G.ElitePanelScanGap=tonumber(_G.EliteFastPanelGap)or 0.15
_G.EliteRepickGap=tonumber(_G.EliteFastRepickGap)or 0.1
_G.EliteInRangeGap=tonumber(_G.EliteFastInRangeGap)or 0.1
_G.EliteWatchdogTick=tonumber(_G.EliteFastWatchdogTick)or 0.15
_G.EliteSyncScanGap=tonumber(_G.EliteFastSyncGap)or 0.1
_G.EliteAutoTPPoll=tonumber(_G.EliteFastTPPoll)or 0.03
else
_G.EliteScanMode="normal"
_G.ElitePanelScanGap=tonumber(_G.EliteNormPanelGap)or 0.25
_G.EliteRepickGap=tonumber(_G.EliteNormRepickGap)or 0.25
_G.EliteInRangeGap=tonumber(_G.EliteNormInRangeGap)or 0.2
_G.EliteWatchdogTick=tonumber(_G.EliteNormWatchdogTick)or 0.2
_G.EliteSyncScanGap=tonumber(_G.EliteNormSyncGap)or 0.15
_G.EliteAutoTPPoll=tonumber(_G.EliteNormTPPoll)or 0.03
end
local k=1/math.clamp(tonumber(_G.EliteScanDelay)or 1,0.3,1)
if k>1 then
for _,key in ipairs({"ElitePanelScanGap","EliteRepickGap","EliteInRangeGap",
"EliteWatchdogTick","EliteSyncScanGap"})do
_G[key]=math.max(0.03,(tonumber(_G[key])or 0.2)/k)
end
end
end
if _G.EliteFOV==nil then _G.EliteFOV=120 end
task.spawn(function()
local fovConn=nil
local function hookCam(cam)
if fovConn then
pcall(function()
fovConn:Disconnect()
end)
fovConn=nil
end
if not cam then
return
end
local function fix()
local want=tonumber(_G.EliteFOV)or 120
if math.abs(cam.FieldOfView-want)>0.01 then
cam.FieldOfView=want
end
end
fovConn=cam:GetPropertyChangedSignal("FieldOfView"):Connect(fix)
pcall(fix)
end
hookCam(workspace.CurrentCamera)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
hookCam(workspace.CurrentCamera)
end)
end)
if _G.EliteTweenTP==nil then _G.EliteTweenTP=false end
if _G.EliteNewMethod==nil then _G.EliteNewMethod=false end
if _G.EliteFlashTP==nil then _G.EliteFlashTP=false end
if _G.EliteFlingTP==nil then _G.EliteFlingTP=false end
if _G.EliteTurretESP==nil then _G.EliteTurretESP=true end
if _G.EliteFlashGroundWait==nil then _G.EliteFlashGroundWait=0.12 end
if _G.EliteFlashPreEquip==nil then _G.EliteFlashPreEquip=50 end
_G.EliteFlashRetry,_G.EliteFlashArriveMin,_G.EliteFlashTurnSpeed=nil,nil,nil
_G.EliteScanProfile("fast")
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
task.wait(tonumber(_G.EliteFastWindow)or 60)
if _G.EliteScanMode=="fast"then _G.EliteScanProfile("normal")end
end)
local warn=function()end
_G.EliteInvisAuto=false
_G.EliteAutoKickOnSteal=false
_G.EliteAutoBuy=false
if _G.EliteStealMode==nil then _G.EliteStealMode="priority"end
if _G.EliteAutoTP==nil then _G.EliteAutoTP=true end
if not game:IsLoaded()then game.Loaded:Wait()end
local _gameLoadAt=os.clock()
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
task.wait(tonumber(_G.EliteFpsCapDelay)or 1.5)
pcall(function()if setfpscap then setfpscap(9999)end end)
end)
task.spawn(function()
local Workspace=game:GetService("Workspace")
local LocalPlayer=game:GetService("Players").LocalPlayer
local _RS=game:GetService("RunService")
if not Workspace.StreamingEnabled then return end
local plots
local t0=os.clock()
repeat plots=Workspace:FindFirstChild("Plots");if not plots then _RS.Heartbeat:Wait()end
until plots or(os.clock()-t0)>15
if not plots then return end
local function plotPos(plot)
local ok,pv=pcall(function()return plot:GetPivot().Position end)
if ok and pv and pv.Magnitude>1 then return pv end
if plot.PrimaryPart then return plot.PrimaryPart.Position end
local bp=plot:FindFirstChildWhichIsA("BasePart",true)
return bp and bp.Position or nil
end
local pending=0
for _,plot in ipairs(plots:GetChildren())do
local pos=plotPos(plot)
if pos then
pending=pending+1
task.spawn(function()
pcall(function()LocalPlayer:RequestStreamAroundAsync(pos)end)
pending=pending-1
end)
end
end
local sw=os.clock()
while pending>0 and os.clock()-sw<3 do task.wait(0.03)end
while _G.EliteKeepPlotsLoaded~=false do
task.wait(tonumber(_G.EliteStreamGap)or 4)
local pl=Workspace:FindFirstChild("Plots")or plots
for _,plot in ipairs(pl:GetChildren())do
local ap=plot:FindFirstChild("AnimalPodiums")
if not ap or#ap:GetChildren()<10 then
local pos=plotPos(plot)
if pos then
task.spawn(function()
pcall(function()LocalPlayer:RequestStreamAroundAsync(pos)end)
end)
end
end
end
end
end)
_G.EliteBootDelay=tonumber(_G.EliteBootDelay)or 0.3
if _G.EliteWaitForTools==nil then _G.EliteWaitForTools=true end
_G.EliteToolWait=tonumber(_G.EliteToolWait)or 6
do
local _bootT0=os.clock()
local _BOOT_TOOLS={
"Flying Carpet","Waverider","Santa's Sleigh","Witch's Broom","Cupid's Wings",
"Grapple Hook",
}
local _BOOT_SET={}
for _,n in ipairs(_BOOT_TOOLS)do _BOOT_SET[n]=true end
local function _boxHasTool(box,want)
if not box then return false end
for _,t in ipairs(box:GetChildren())do
if t:IsA("Tool")then
local n=t.Name
if n==want or _BOOT_SET[n]then return true end
end
end
return false
end
local function _toolsReady()
local plr=game:GetService("Players").LocalPlayer
if not plr then return false end
local want=(type(_G.EliteCarpetTool)=="string"and _G.EliteCarpetTool~="")
and _G.EliteCarpetTool or nil
return _boxHasTool(plr.Character,want)
or _boxHasTool(plr:FindFirstChild("Backpack"),want)
end
_G.EliteToolsReady=_toolsReady
_G.EliteBootWait=function()
local d=tonumber(_G.EliteBootDelay)or 0.3
local cap=tonumber(_G.EliteToolWait)or 6
local want=(_G.EliteWaitForTools~=false)
local t0=os.clock()
while true do
local ready=true
if want then
local ok,r=pcall(_toolsReady)
ready=(ok and r)and true or false
end
if ready and(os.clock()-_bootT0)>=d then
return
end
if os.clock()-t0>=cap then
return
end
task.wait(tonumber(_G.EliteBootPoll)or 0.03)
end
end
end
_G.ElitePriVersion=_G.ElitePriVersion or 0
if type(_G.ElitePriorityDefault)~="table"then _G.ElitePriorityDefault={}end
if type(_G.SHARED_PRIORITY_ITEMS)~="table"then _G.SHARED_PRIORITY_ITEMS={}end
if type(_G.SHARED_MUTATION_PRIORITY)~="table"then _G.SHARED_MUTATION_PRIORITY={}end
if type(_G.SHARED_TRAIT_PRIORITY)~="table"then _G.SHARED_TRAIT_PRIORITY={}end
if type(_G.SHARED_MUTATION_DISABLED)~="table"then _G.SHARED_MUTATION_DISABLED={}end
if LPH_OBFUSCATED==nil then
local env=getfenv()
env["LPH_NO_".."VIRTUALIZE"]=function(...)return...end
env["LPH_JIT_".."MAX"]=function(...)return...end
end
do
local _HS=game:GetService("HttpService")
local _TS=game:GetService("TeleportService")
_G.ELITE_DEFAULT_CONFIG_JSON=[==[{"mutationList":["Bloodrot","Candy","Crystal","Cursed","Cyber","Diamond","Divine","Galaxy","Gold","Lava","Phantom","Radioactive","Rainbow","YinYang"],"stealLead":0.07,"landingDelay":0.15000000000000002,"infJump":true,"invisAngle":216,"xray":true,"goSpeed":220,"antiBee":true,"cframeSpeed":450,"stealFireKey":"LeftAlt","autoKickOnSteal":false,"invisDepth":10,"cloneKey":"V","autoBuyRange":17,"antiFlash":true,"autoBuyHover":9,"resetKey":"X","closeSpeed":300,"walkSpeedOn":false,"stealMode":"priority","dropKey":"G","nearestKey":"F","autoSteal":true,"priorityList":["Headless Horseman","Strawberry Elephant","Signore Carapace","John Pork","Meowl","Elefanto Frigo","Arcadragon","Skibidi Toilet","Griffin","Antonio","Dragon Aquanini","Dragon Gingerini","Love Love Bear","Kalika Bros","Moby Bros","Grabatron","Jelly Moby","La Supreme Combinasion","Ginger Gerat","Digi Narwhal","Hydra Dragon Cannelloni","Hydra Bunny","Bunny and Eggy","Kraken","Fishino Clownino","Tirilikalika Tirilikalako","Pancake and Syrup","Dragon Cannelloni","Sammyni Cakini","Ketupat Bros","Bumbatron","Venuspino","Dug dug dug","La Casa Boo","Rico Dinero","Foxini Lanternini","Duggy Bros","Rosey and Teddy","Globa Steppa","Los Hackers","Cerberus","Fragrama and Chocrama","Cooki and Milki","La Secret Combinasion","Burguro and Fryuro","Capitano Moby","Spooky and Pumpky","Garama and Madundung","Popcuru and Fizzuru","Pizza and Ranch","Reinito Sleighito","Tenini Ballini","Fragola La La La","Ketchuru and Musturu","Tralaledon","Tictac Sahur","Ketupat Kepat","Tang Tang Keletang","Orcaledon","La Ginger Sekolah","Los Spaghettis","Lavadorito Spinito","Swaggy Bros","La Taco Combinasion","Los Primos","Los Chillis","Chillin Chili","Tuff Toucan","W or L","Chipso and Queso","Guest 666","Money Money Reindeer","Quackini Snackini","Los Sekolahs","Los Tacoritas","Los Amigos","Fortunu and Cashuru","Jolly Jolly Sahur","Boppin Bunny","Gym Bros","Los Cupids","Festive 67","Celularcini Viciosini","Cloverat Clapat","La Food Combinasion","Hopilikalika Hopilikalako","Celestial Pegasus","Sammyni Fattini","Money Money Bros","La Spooky Grande","Cash or Card","Swag Soda","Los Planitos","Lovin Rose","Tacorita Bicicleta","Los Jolly Combinasionas","La Romantic Grande","La Easter Grande","Los Hotspotsitos","Rosetti Tualetti","Los Bros","Gobblino Uniciciclino","Chicleteira Cupideira","La Extinct Grande","Las Sis","Nacho Spyder","Gold Gold Gold","Los Mariachis","Snailo Clovero","La Jolly Grande","Los Candies","Churrito Bunnito","Bananito","Eviledon","Los 67","Los Sweethearts","Noo my Heart","La Lucky Grande","Ventoliero Pavonero","Baskito","Chimnino","Los Puggies","Camera Ramena","Los 25","Spinny Hammy","Money Money Puggy","Cigno Fulgoro","Los Spooky Combinasionas","Chicleteira Noelteira","Mariachi Corazoni","Tacorillo Crocodillo","Noo my Gold","Los Mobilis","Mieteteira Bicicleteira","DJ Panda","Los Combinasionas","Nuclearo Dinossauro","Bacuru and Egguru","Spaghetti Tualetti","La Grande Combinasion","Esok Sekolah"],"walkSpeed":29,"grabBeforeKick":true,"carpetStrict":true,"autoBuy":false,"antiDie":false,"carpetSpeedValue":140,"tpVelocity":550,"invisAuto":true,"autoTp":true,"climbSpeed":100,"carpetTool":"Waverider","carpetSpeedKey":"Q","stealQuickKey":"C"}]==]
local DEFAULT_CONFIG
pcall(function()DEFAULT_CONFIG=_HS:JSONDecode(_G.ELITE_DEFAULT_CONFIG_JSON)end)
local fileData,tpData
if readfile then
pcall(function()
local raw=readfile(_G.EliteConfigFile or"elitevpriv.config")
if type(raw)=="string"and#raw>0 then fileData=_HS:JSONDecode(raw)end
end)
end
pcall(function()
local td=_TS:GetLocalPlayerTeleportData()
if td and td.EliteVersion then tpData=td.EliteVersion end
end)
local merged={}
if type(DEFAULT_CONFIG)=="table"then for k,v in pairs(DEFAULT_CONFIG)do merged[k]=v end end
if type(tpData)=="table"then for k,v in pairs(tpData)do merged[k]=v end end
if type(fileData)=="table"then for k,v in pairs(fileData)do merged[k]=v end end
if type(merged.tpDelay)=="number"then _G._stp_tpDelay=merged.tpDelay end
if type(merged.tpVelocity)=="number"then _G.TPVelocity=math.clamp(merged.tpVelocity,200,750)end
if type(merged.climbSpeed)=="number"then _G.EliteClimb=math.clamp(merged.climbSpeed,100,250)end
if type(merged.cframeSpeed)=="number"then _G.EliteCFrameSpeed=math.clamp(merged.cframeSpeed,100,900)end
if type(merged.walkSpeed)=="number"then _G.EliteWalkSpeed=math.clamp(merged.walkSpeed,16,32)end
if type(merged.carpetTool)=="string"then _G.EliteCarpetTool=merged.carpetTool end
if type(merged.landingDelay)=="number"then _G.LandingDelay=math.clamp(merged.landingDelay,0.01,1.0)end
if type(merged.closeSpeed)=="number"then _G.EliteCloseSpeed=math.clamp(merged.closeSpeed,20,400)end
if type(merged.problemBaseSpeed)=="number"then _G.EliteProblemBaseSpeed=math.clamp(merged.problemBaseSpeed,20,400)end
if type(merged.slowCrossRow)=="boolean"then _G.EliteSlowCrossRow=merged.slowCrossRow end
if type(merged.stealLead)=="number"then _G.EliteStealLead=math.clamp(merged.stealLead,0,2)end
_G.EliteStealQuick=false
if type(merged.stealQuickKey)=="string"then _G.EliteStealQuickKey=merged.stealQuickKey end
if type(merged.stealFireKey)=="string"then _G.EliteStealFireKey=merged.stealFireKey end
if type(merged.tpKey)=="string"then _G._stp_tpKeyName=merged.tpKey end
if type(merged.nearestKey)=="string"then _G.EliteNearestKey=merged.nearestKey end
if type(merged.stealHud)=="boolean"then _G.EliteStealHud=merged.stealHud end
if type(merged.hideCheap)=="boolean"then _G.EliteHideCheap=merged.hideCheap end
if type(merged.scanDelay)=="number"then _G.EliteScanDelay=math.clamp(merged.scanDelay,0.3,1)end
if _G.EliteScanProfile then pcall(_G.EliteScanProfile,_G.EliteScanMode or"fast")end
if type(merged.themeName)=="string"then _G.EliteThemeName=merged.themeName end
if type(merged.tgtW)=="number"and type(merged.tgtH)=="number"then
_G._elite_tgtW,_G._elite_tgtH=math.max(240,merged.tgtW),math.max(220,merged.tgtH)
end
if type(merged.mainW)=="number"and type(merged.mainH)=="number"then
_G._elite_mainW,_G._elite_mainH=math.max(300,merged.mainW),math.max(300,merged.mainH)
end
if type(merged.tweenTp)=="boolean"then _G.EliteTweenTP=merged.tweenTp end
if type(merged.newMethod)=="boolean"then _G.EliteNewMethod=merged.newMethod end
if type(merged.flashTp)=="boolean"then _G.EliteFlashTP=merged.flashTp end
if type(merged.flingTp)=="boolean"then _G.EliteFlingTP=merged.flingTp end
if type(merged.turretEsp)=="boolean"then _G.EliteTurretESP=merged.turretEsp end
if type(merged.flashFire)=="number"then _G.EliteFlashGroundWait=math.clamp(merged.flashFire,0,0.25)end
if type(merged.flashEquip)=="number"then _G.EliteFlashPreEquip=math.clamp(merged.flashEquip,0,60)end
if type(merged.newMethodStuds)=="number"then _G.EliteNewMethodStuds=math.clamp(merged.newMethodStuds,10,100)end
if type(merged.newMethodStep)=="number"then _G.EliteNewMethodStep=math.clamp(merged.newMethodStep,3,40)end
if type(merged.tweenStage)=="number"then _G.EliteTweenStage=math.clamp(merged.tweenStage,3,40)end
if type(merged.tweenNear)=="number"then _G.EliteTweenNear=math.clamp(merged.tweenNear,20,60)end
if type(merged.invisKey)=="string"then _G.EliteInvisKey=merged.invisKey end
if type(merged.wsKey)=="string"then _G.EliteWalkSpeedKey=merged.wsKey end
if type(merged.invisAuto)=="boolean"then _G.EliteInvisAuto=merged.invisAuto end
if type(merged.quickPanel)=="boolean"then _G.EliteQuickPanel=merged.quickPanel end
if type(merged.priorityOnly)=="boolean"then _G.ElitePriorityOnly=merged.priorityOnly end
if type(merged.prioMerged)=="boolean"then _G.ElitePrioMerged=merged.prioMerged end
if type(merged.quickX)=="number"and type(merged.quickY)=="number"then _G._elite_quickX,_G._elite_quickY=merged.quickX,merged.quickY end
if type(merged.invisDepth)=="number"then _G.EliteInvisDepth=math.clamp(merged.invisDepth,0,10)end
if type(merged.invisAngle)=="number"then _G.EliteInvisAngle=math.clamp(merged.invisAngle,0,360)end
if type(merged.accent)=="table"then _G.EliteAccent=merged.accent end
if type(merged.bgColor)=="table"then _G.EliteBgColor=merged.bgColor end
if type(merged.textColor)=="table"then _G.EliteTextColor=merged.textColor end
if merged.stealMode=="priority"or merged.stealMode=="nearest"then
_G.EliteStealMode=merged.stealMode
elseif merged.stealMode==false then
_G.EliteStealMode=nil
else
_G.EliteStealMode="priority"
end
_G.EliteStealTargetUID=nil
if type(merged.priorityList)=="table"then
local clean={}
for _,v in ipairs(merged.priorityList)do
if type(v)=="string"and v~=""then clean[#clean+1]=v end
end
if#clean>0 then
local L=_G.SHARED_PRIORITY_ITEMS
table.clear(L)
for i=1,#clean do L[i]=clean[i]end
_G.ElitePriVersion=_G.ElitePriVersion+1
end
end
if type(merged.priorityDefault)=="table"then
local d={}
for _,v in ipairs(merged.priorityDefault)do
if type(v)=="string"and v~=""then d[#d+1]=v end
end
if#d>0 then _G.ElitePriorityDefault=d end
end
if type(merged.mutationList)=="table"then
local clean={}
for _,v in ipairs(merged.mutationList)do
if type(v)=="string"and v~=""then clean[#clean+1]=v end
end
if#clean>0 then
local L=_G.SHARED_MUTATION_PRIORITY
table.clear(L)
for i=1,#clean do L[i]=clean[i]end
end
end
if type(merged.mutationDisabled)=="table"then
local D=_G.SHARED_MUTATION_DISABLED
table.clear(D)
for _,v in ipairs(merged.mutationDisabled)do
if type(v)=="string"and v~=""then D[v]=true end
end
end
if type(merged.invisAuto)=="boolean"then _G.EliteInvisAuto=merged.invisAuto end
if type(merged.quickPanel)=="boolean"then _G.EliteQuickPanel=merged.quickPanel end
if type(merged.priorityOnly)=="boolean"then _G.ElitePriorityOnly=merged.priorityOnly end
if type(merged.prioMerged)=="boolean"then _G.ElitePrioMerged=merged.prioMerged end
if type(merged.quickX)=="number"and type(merged.quickY)=="number"then _G._elite_quickX,_G._elite_quickY=merged.quickX,merged.quickY end
if type(merged.invisDepth)=="number"then _G.EliteInvisDepth=math.clamp(merged.invisDepth,0,10)end
if type(merged.invisAngle)=="number"then _G.EliteInvisAngle=math.clamp(merged.invisAngle,0,360)end
if type(merged.autoTp)=="boolean"then _G.EliteAutoTP=merged.autoTp end
if type(merged.autoBuy)=="boolean"then _G.EliteAutoBuy=merged.autoBuy end
if type(merged.autoBuyRange)=="number"then _G.EliteAutoBuyRange=math.clamp(merged.autoBuyRange,5,40)end
if type(merged.autoBuyHover)=="number"then _G.EliteAutoBuyHover=math.clamp(merged.autoBuyHover,0,20)end
if type(merged.panelX)=="number"then _G._stp_panelX=merged.panelX end
if type(merged.panelY)=="number"then _G._stp_panelY=merged.panelY end
if type(merged.panelPos)=="table"then _G._stp_pos=merged.panelPos end
if type(merged.autoKickOnSteal)=="boolean"then _G.EliteAutoKickOnSteal=merged.autoKickOnSteal end
if type(merged.resetKey)=="string"then _G.EliteResetKeyName=merged.resetKey end
if type(merged.cloneKey)=="string"then _G.EliteCloneKeyName=merged.cloneKey end
if type(merged.carpetSpeedKey)=="string"then _G.EliteCarpetSpeedKeyName=merged.carpetSpeedKey end
if type(merged.kickKey)=="string"then _G.EliteKickKeyName=merged.kickKey end
if type(merged.stopTpKey)=="string"then _G.EliteStopTPKeyName=merged.stopTpKey end
if type(merged.dropKey)=="string"then _G.EliteDropKeyName=merged.dropKey end
if type(merged.goSpeed)=="number"then _G.EliteGoSpeed=math.clamp(merged.goSpeed,80,600)end
if type(merged.walkSpeedOn)=="boolean"then _G.EliteWalkSpeedOn=merged.walkSpeedOn end
if type(merged.xray)=="boolean"then _G.EliteXray=merged.xray end
if type(merged.antiFlash)=="boolean"then _G.EliteAntiFlash=merged.antiFlash end
if type(merged.antiBee)=="boolean"then _G.EliteAntiBee=merged.antiBee end
if type(merged.antiAFK)=="boolean"then _G.EliteAntiAFK=merged.antiAFK end
if type(merged.playerESP)=="boolean"then _G.ElitePlayerESP=merged.playerESP end
if type(merged.holdESP)=="boolean"then _G.EliteHoldESP=merged.holdESP end
if type(merged.noPetAnim)=="boolean"then _G.EliteNoPetAnim=merged.noPetAnim end
if type(merged.infJump)=="boolean"then _G.EliteInfJump=merged.infJump end
if type(merged.antiDie)=="boolean"then _G.AntiDieDisabled=not merged.antiDie end
if type(merged.carpetSpeedValue)=="number"then _G.EliteCarpetSpeedValue=merged.carpetSpeedValue end
if type(merged.exX)=="number"then _G._elite_exX=merged.exX end
if type(merged.exY)=="number"then _G._elite_exY=merged.exY end
if type(merged.fX)=="number"then _G._elite_fX=merged.fX end
if type(merged.fY)=="number"then _G._elite_fY=merged.fY end
if type(merged.kX)=="number"then _G._elite_kX=merged.kX end
if type(merged.kY)=="number"then _G._elite_kY=merged.kY end
_G.EliteAutoTP=true
if writefile then
pcall(function()
local t=type(fileData)=="table"and fileData or{}
t.autoTp=true
writefile(_G.EliteConfigFile or"elitevpriv.config",_HS:JSONEncode(t))
end)
end
end
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("ReplicatedStorage")
local LP=Players.LocalPlayer
if _G.EliteNoZeroVel==nil then _G.EliteNoZeroVel=false end
function _vzOK()
if _G.EliteNoZeroVel==true then return false end
if _G.EliteZeroWhileStealing~=true and LP:GetAttribute("Stealing")==true then return false end
return true
end
function _vzL(p)
if p and _vzOK()then
p.AssemblyLinearVelocity=Vector3.new(0,0,0)
end
end
function _vzA(p)
if p and _vzOK()then
p.AssemblyAngularVelocity=Vector3.new(0,0,0)
end
end
_BLOCKING_MACHINE_TYPES={
Fuse=true,
Duel=true,
Trade=true,
Crafting=true,
}
function _EliteIsFusing(animalData)
if type(animalData)~="table"then return false end
local m=animalData.Machine
if type(m)~="table"then return false end
return _BLOCKING_MACHINE_TYPES[m.Type]==true
end
do
local RS=game:GetService("ReplicatedStorage")
local RUN=game:GetService("RunService")
local _netFolder
local function _netDir()
if _netFolder then return _netFolder end
local pk=RS:FindFirstChild("Packages")or RS:WaitForChild("Packages",10)
if not pk then return nil end
_netFolder=pk:FindFirstChild("Net")or pk:WaitForChild("Net",10)
return _netFolder
end
local _net
local function _getNet()
if _net then return _net end
local dir=_netDir()
if not dir then return nil end
local ok,m=pcall(require,dir)
if ok and type(m)=="table"then _net=m end
return _net
end
local _queue,_hooked,_original={},false,nil
local function _host()
for _,sig in ipairs({RUN.Heartbeat,RUN.RenderStepped,RUN.PostSimulation})do
local ok,conns=pcall(getconnections,sig)
if ok then
for _,c in ipairs(conns)do
local f=c.Function
if f and f~=_G.__mkSyncHost and islclosure(f)and not isexecutorclosure(f)then
local s=select(2,pcall(debug.info,f,"s"))
if type(s)=="string"and s:find("^ReplicatedStorage%.")and not s:find("ReplicatedFirst")then
return f
end
end
end
end
end
end
local function _install()
if _hooked then return true end
if not _getNet()then return false end
local h=_host()
if not h then return false end
_G.__mkNetHost=h
local w=function(...)
local job=table.remove(_queue,1)
if job then
local ok,r=pcall(_net[job.kind],_net,job.name)
job.result=(ok and typeof(r)=="Instance")and r or nil
job.done=true
end
return _original(...)
end
local ok,env=pcall(getfenv,h)
if ok and type(env)=="table"then pcall(setfenv,w,env)end
_original=hookfunction(h,w)
_hooked=true
return true
end
local _cache={}
local function _get(name,kind)
kind=(kind=="RemoteFunction"and"RemoteFunction")
or(kind=="UnreliableRemoteEvent"and"UnreliableRemoteEvent")
or"RemoteEvent"
if type(name)~="string"or name==""then return nil end
local logical=name:match("^R[EF]/(.+)$")or name:match("^URE/(.+)$")or name
local ck=kind.."|"..logical
local hit=_cache[ck]
if hit and hit.Parent then return hit end
_cache[ck]=nil
if not _getNet()then return nil end
if not _install()then return nil end
local job={kind=kind,name=logical}
table.insert(_queue,job)
local t=os.clock()+(tonumber(_G.EliteNetTimeout)or 5)
while not job.done and os.clock()<t do RUN.Heartbeat:Wait()end
if job.result and job.result.Parent then
_cache[ck]=job.result
return job.result
end
return nil
end
_G.EliteGetRemote=_get
_G.__secureGetRemote=function(method,name)return _get(name,method)end
do
local _dummy=Instance.new("RemoteEvent")
local _rawFire=(clonefunction and clonefunction(_dummy.FireServer))or _dummy.FireServer
end
end
do
local _lastTry,_attempts=0,0
local _deepScans,_lastDeep=0,0
local MAX_ATTEMPTS,RETRY_GAP=40,0.5
local BOOT_T0,BOOT_BURST,BOOT_GAP=os.clock(),3.0,0.10
local MAX_DEEP,DEEP_GAP=3,1.5
local RS_SYNC=game:GetService("ReplicatedStorage")
local _mask_sc
local function _getMask()
if _mask_sc and _mask_sc.Parent then return _mask_sc end
local c=RS_SYNC:FindFirstChild("Controllers")
_mask_sc=c and c:FindFirstChild("PlotController")
return _mask_sc
end
local secure_call=_G.secure_call
if type(secure_call)~="function"then
local RUN=game:GetService("RunService")
local state={ready=false,inside=false}
local conn,original
local function host()
for _,sig in ipairs({RUN.Heartbeat,RUN.RenderStepped,RUN.PostSimulation})do
local ok,conns=pcall(getconnections,sig)
if ok then
for _,c in ipairs(conns)do
local f=c.Function
if f and f~=_G.__mkNetHost and islclosure(f)and not isexecutorclosure(f)then
local s=select(2,pcall(debug.info,f,"s"))
if type(s)=="string"and s:find("^ReplicatedStorage%.")and not s:find("ReplicatedFirst")then
return f,c,s
end
end
end
end
end
end
local function install()
if state.ready then return true end
local h,c,src=host()
if not h then return false end
local chunk=loadstring([[
            local state, pack, unpack = ...
            return function(...)
                local job = state.job
                if job and not job.done then
                    job.done = true
                    state.inside = true
                    job.result = pack(pcall(job.fn, unpack(job.args, 1, job.args.n)))
                    state.inside = false
                end
                return state.original(...)
            end
        ]],"="..src)
if not chunk then return false end
local ok,env=pcall(getfenv,h)
if ok and type(env)=="table"then pcall(setfenv,chunk,env)end
local wrapper=chunk(state,table.pack,table.unpack)
_G.__mkSyncHost=h
original=hookfunction(h,wrapper)
state.original=original
conn=c
state.ready=true
return true
end
secure_call=function(fn,...)
if type(fn)~="function"then return nil end
if state.inside then return fn(...)end
if not install()then return nil end
state.job={fn=fn,args=table.pack(...),done=false}
pcall(function()conn:Fire(0)end)
local job=state.job
state.job=nil
if not job or not job.done or not job.result then return nil end
if not job.result[1]then error(job.result[2],2)end
return table.unpack(job.result,2,job.result.n)
end
_G.secure_call=secure_call
end
task.spawn(function()
pcall(function()
local sync=_getSyncMod()
if sync and type(sync.GetAllChannels)=="function"then
local mask=_getMask()
if mask then pcall(secure_call,sync.GetAllChannels,mask)end
end
end)
end)
local _syncMod_sc,_nextTry_sc=nil,0
local function _getSyncMod()
if _syncMod_sc then return _syncMod_sc end
local p=RS_SYNC:FindFirstChild("Packages")
local m=p and p:FindFirstChild("Synchronizer")
if not m then return nil end
local ok,mod=pcall(require,m)
if ok and type(mod)=="table"then _syncMod_sc=mod end
return _syncMod_sc
end
local function _channelCount(t)
if type(t)~="table"then return 0 end
local ok,hits=pcall(function()
local h,n=0,0
for _,v in next,t do
n=n+1
if type(v)=="table"and type(rawget(v,"CacheTable"))=="table"then
h=h+1
end
if n>=50 then break end
end
return h
end)
return(ok and hits)or 0
end
local function _probe(mod)
local gu=(debug and debug.getupvalue)or getupvalue
if type(gu)~="function"then return nil,0,nil end
local best,bestN,where=nil,0,nil
local function consider(t,tag)
local n=_channelCount(t)
if n>bestN then best,bestN,where=t,n,tag end
end
local cands={
{mod.Get,10,4,"Get/10/4"},
{mod.GetAllChannels,10,1,"GetAll/10/1"},
{mod.Wait,10,1,"Wait/10/1"},
}
for _,c in ipairs(cands)do
if type(c[1])=="function"then
local o,u=pcall(gu,c[1],c[2])
if o and type(u)=="table"then
consider(rawget(u,c[3]),c[4])
if bestN>0 then return best,bestN,where end
end
end
end
for _,fn in ipairs({mod.Get,mod.GetAllChannels,mod.Wait,mod.WaitAndCall,mod.GetTableFromChannel})do
if type(fn)=="function"then
for i=8,12 do
local o,u=pcall(gu,fn,i)
if o and type(u)=="table"then
consider(u,"up"..i)
for j=1,4 do consider(rawget(u,j),"up"..i.."/"..j)end
if bestN>0 then return best,bestN,where end
end
end
end
end
local ok,up=pcall(gu,mod.Get,9)
if ok and type(up)=="table"then
consider(rawget(up,3),"Get/9/3")
if bestN>0 then return best,bestN,where end
consider(up,"Get/9")
if bestN>0 then return best,bestN,where end
end
return best,bestN,where
end
local function _deepScan(mod)
local gu=(debug and debug.getupvalue)or getupvalue
if type(gu)~="function"then return nil,0,nil end
local best,bestN,where=nil,0,nil
local function consider(t,tag)
local n=_channelCount(t)
if n>bestN then best,bestN,where=t,n,tag end
end
local _fnCount=0
for fname,fn in next,mod do
if type(fn)=="function"then
_fnCount=_fnCount+1
if _fnCount>30 then break end
for i=1,16 do
local o,u=pcall(gu,fn,i)
if not o then break end
if type(u)=="table"then
consider(u,tostring(fname).."/"..i)
for j=1,4 do
consider(rawget(u,j),tostring(fname).."/"..i.."/"..j)
end
end
end
end
end
return best,bestN,where
end
local _gcFound,_gcFoundN,_gcState=nil,0,"idle"
local function _gcScanOnce()
local plots=workspace:FindFirstChild("Plots")
if not plots then return end
local live,names,nLive={},{},0
for _,p in ipairs(plots:GetChildren())do live[p.Name]=true;nLive=nLive+1;names[nLive]=p.Name end
if nLive==0 then return end
local function score(t)
local hits,seen=0,0
for k,v in next,t do
seen=seen+1
if type(k)=="string"and live[k]
and type(v)=="table"and type(rawget(v,"CacheTable"))=="table"then
hits=hits+1
end
if seen>=64 then break end
end
return hits
end
local best,bestN=nil,0
local hasFilter=type(filtergc)=="function"
if hasFilter then
local tries={}
if nLive>=2 then tries[1]={names[1],names[2],"CacheTable"}end
tries[#tries+1]={names[1],"CacheTable"}
if nLive>=3 then tries[#tries+1]={names[2],names[3],"CacheTable"}end
for _,keys in ipairs(tries)do
local ok,res=pcall(filtergc,"table",{Keys=keys},false)
if ok and type(res)=="table"then
for _,t in ipairs(res)do
if type(t)=="table"then
local n=score(t)
if n>bestN and n>=2 then best,bestN=t,n end
end
end
end
if bestN>=nLive then break end
end
end
if bestN==0 and type(getgc)=="function"
and(not hasFilter or _G.EliteAllowFullGc==true)
and not(_G.EliteIsTeleporting and _G.EliteIsTeleporting())
and(os.clock()-(_G.__gcFullAt or 0))>=(tonumber(_G.EliteFullGcGap)or 3.0)
and(workspace.StreamingEnabled==false or os.clock()-_gameLoadAt>=(tonumber(_G.EliteBootGcWait)or 1.0))then
_G.__gcFullAt=os.clock()
pcall(function()
local gc=getgc(true)
local _gcLimit=math.min(#gc,4000)
for i=1,_gcLimit do
local t=gc[i]
if type(t)=="table"then
local pk=0
for k in next,t do
if type(k)=="string"and live[k]then pk=pk+1;if pk>=2 then break end end
end
if pk>=2 then
local n=score(t)
if n>bestN and n>=2 then best,bestN=t,n end
end
if bestN>=nLive then break end
end
end
end)
end
if best and bestN>_gcFoundN then _gcFound,_gcFoundN=best,bestN end
end
local _gcLastScan=0
local _gcRescans=0
local _gcMiss,_gcLastPlots=0,-1
local function _gcChans()
if _gcFound then
local _pl=workspace:FindFirstChild("Plots")
local _nLive=_pl and#_pl:GetChildren()or 0
if _G.EliteSyncRescan==true and _gcFoundN<_nLive
and _gcRescans<(tonumber(_G.EliteSyncMaxRescan)or 20)
and(os.clock()-_gcLastScan)>=(tonumber(_G.EliteSyncRescanGap)or 3)then
_gcLastScan=os.clock()
_gcRescans=_gcRescans+1
_gcScanOnce()
end
return _gcFound,_gcFoundN,"gc/plot-key+CacheTable"
end
local _pl=workspace:FindFirstChild("Plots")
local _n=_pl and#_pl:GetChildren()or 0
if _n~=_gcLastPlots then
_gcLastPlots=_n
_gcMiss=(_gcMiss>2)and 2 or _gcMiss
_gcLastScan=_gcLastScan-0.05
end
local gap=tonumber(_G.EliteSyncScanGap)or 0.2
local back=math.min(_gcMiss*(tonumber(_G.EliteSyncMissStep)or 0.15),
tonumber(_G.EliteSyncMissMax)or 1)
if os.clock()-_gcLastScan<(gap+back)then return nil,0,nil end
_gcLastScan=os.clock()
_gcScanOnce()
if _gcFound then
_gcMiss=0
return _gcFound,_gcFoundN,"gc/plot-key+CacheTable"
end
if _n>0 then _gcMiss=_gcMiss+1 end
return nil,0,nil
end
local function _apiChans(mod)
if type(mod)~="table"then return nil,0,nil end
local fn=rawget(mod,"GetAllChannels")
if type(fn)~="function"then return nil,0,nil end
local function _accept(reg,tag)
if type(reg)~="table"then return nil,0,nil end
local n=_channelCount(reg)
if n>0 then return reg,n,tag end
return nil,0,nil
end
if _G.EliteAllowSecureSyncCall~=false and type(secure_call)=="function"then
for _,form in ipairs({"self","plain"})do
local ok,reg=pcall(function()
if form=="self"then return secure_call(fn,mod)end
return secure_call(fn)
end)
if ok then
local r,n,t=_accept(reg,"GetAllChannels/secure_call("..form..")")
if r then return r,n,t end
end
end
end
if _G.EliteAllowRawSyncCall then
for _,form in ipairs({"self","plain"})do
local ok,reg=pcall(function()
if form=="self"then return fn(mod)end
return fn()
end)
if ok then
local r,n,t=_accept(reg,"GetAllChannels/RAW("..form..")")
if r then return r,n,t end
end
end
end
return nil,0,nil
end
local _xchan2,_nextTry2,_attempts2=nil,0,0
local _xchan2Until=0
local _nextApi=0
local _chansLastScan=0
local function _chans()
if _xchan2 then
local now=os.clock()
if now<_xchan2Until then return _xchan2 end
local _boot=_gameLoadAt and(now-_gameLoadAt)<15
if _channelCount(_xchan2)>0 then _xchan2Until=now+(_boot and 0.25 or 2)return _xchan2 end
end
local now=os.clock()
if now-_chansLastScan<0.02 then return _xchan2 end
if now<_nextTry2 then return _xchan2 end
_chansLastScan=now
_attempts2=_attempts2+1
local best,n,where
if _G.EliteAllowSecureSyncCall~=false and os.clock()>=_nextApi then
local mod=_getSyncMod()
if mod then best,n,where=_apiChans(mod)end
local _boot=_gameLoadAt and(os.clock()-_gameLoadAt)<15
if not best or n==0 then _nextApi=os.clock()+(tonumber(_G.EliteSyncApiGap)or(_boot and 0.1 or 0.5))end
end
if not best or n==0 then best,n,where=_gcChans()end
if(not best or n==0)and _attempts2<=400 and _G.EliteAllowUpvalueProbe then
local mod=_getSyncMod()
if mod then
best,n,where=_probe(mod)
local inBoot=_gameLoadAt and(os.clock()-_gameLoadAt)<4
if(not best or n==0)and(not inBoot)and os.clock()-_lastDeep>2 then
_lastDeep=os.clock()
_deepScans=_deepScans+1
best,n,where=_deepScan(mod)
end
end
end
if best and n>0 then
_xchan2=best
_G.EliteSyncDiag=string.format("%s - %d channels",tostring(where),n)
return _xchan2
end
local inBoot2=_gameLoadAt and(os.clock()-_gameLoadAt)<4
_nextTry2=os.clock()+(inBoot2 and 0.1 or((_G.EliteScanMode=="fast")and 0.03 or 0.1))
return _xchan2
end
_G.EliteSyncAll=function()return _chans()end
_G.EliteSyncGet=function(idx)
local t=_chans()
if not t or idx==nil then return nil end
local ok,cd=pcall(rawget,t,idx)
if ok and type(cd)=="table"then return cd end
local ok2,cd2=pcall(function()return t[idx]end)
if ok2 and type(cd2)=="table"then return cd2 end
return nil
end
local _AD,_MD,_TD
local function _data()
if _AD then return true end
local ok=pcall(function()
local R=game:GetService("ReplicatedStorage")
local d=R:FindFirstChild("Datas")or R:WaitForChild("Datas",2)
if not d then return end
local a=d:FindFirstChild("Animals")or d:WaitForChild("Animals",2)
if a then _AD=require(a)end
local m=d:FindFirstChild("Mutations")or d:WaitForChild("Mutations",2)
if m then _MD=require(m)end
local t=d:FindFirstChild("Traits")or d:WaitForChild("Traits",2)
if t then _TD=require(t)end
end)
return ok and _AD~=nil
end
_G._eliteGen=function(index,mutation,traits)
if not _data()then return 0 end
local info=_AD[index]
if not info or not info.Generation then return 0 end
local mult=1
if mutation and mutation~="None"and mutation~=""then
local m=_MD[mutation]
if m and m.Modifier then mult=mult+m.Modifier end
end
if type(traits)=="table"then
for _,tr in ipairs(traits)do
local t=_TD[tr]
if t and t.MultiplierModifier then mult=mult+t.MultiplierModifier end
end
end
return info.Generation*mult
end
local _sharedAnimals
_G._eliteAnimShim=setmetatable({GetGeneration=function(_,index,mutation,traits)return _G._eliteGen(index,mutation,traits)end},{
__index=function(_,k)
if not _sharedAnimals then
local ok,real=pcall(function()
local R=game:GetService("ReplicatedStorage")
local sh=R:FindFirstChild("Shared")or R:WaitForChild("Shared",3)
local an=sh and(sh:FindFirstChild("Animals")or sh:WaitForChild("Animals",3))
return an and require(an)or nil
end)
if ok and type(real)=="table"then _sharedAnimals=real end
end
if not _sharedAnimals then return nil end
return rawget(_sharedAnimals,k)
end})
end
_G.EliteSyncAll=_G.EliteSyncAll
_G.EliteSyncGet=_G.EliteSyncGet
_G.EliteAnimShim=_G._eliteAnimShim
task.spawn(function()
for i=1,260 do
local t=_G.EliteSyncAll()
local pl=workspace:FindFirstChild("Plots")
local kids=pl and pl:GetChildren()
local want=kids and#kids or 0
if want>0 and type(t)=="table"then
local have=0
for k=1,want do
if rawget(t,kids[k].Name)~=nil then have=have+1 end
end
if have>=want then return end
end
task.wait(i<=100 and 0.04 or 0.1)
end
end)
_mkNextModTry=0
function _EliteBuildDefaultBrainrotPriority()
if not AnimalsData then return end
table.clear(_brainrotDefaultPri)
table.clear(_brainrotDefaultRarity)
local rarities={OG=1,Secret=2,["Brainrot God"]=3,["Brainrot Titan"]=4,["Brainrot Legendary"]=5,Legendary=6,Mythic=7,Epic=8,Rare=9,Uncommon=10,Common=11}
local list={}
for name,info in pairs(AnimalsData)do
if type(info)=="table"then
local r=tostring(info.Rarity or"Common")
local rIdx=rarities[r]or 12
table.insert(list,{name=info.DisplayName or name,index=name,r=r,rIdx=rIdx})
end
end
table.sort(list,function(a,b)
if a.rIdx~=b.rIdx then return a.rIdx<b.rIdx end
return(a.name or a.index)<(b.name or b.index)
end)
for i,v in ipairs(list)do
local nn=_normName(v.name)
local ni=_normName(v.index)
_brainrotDefaultPri[nn]=i
_brainrotDefaultRarity[nn]=v.r
if _brainrotDefaultPri[ni]==nil then
_brainrotDefaultPri[ni]=i
_brainrotDefaultRarity[ni]=v.r
end
end
if#_G.SHARED_PRIORITY_ITEMS==0 then
local cap=tonumber(_G.EliteDefaultPrioCap)or 60
for i,v in ipairs(list)do
if i>cap then break end
_G.SHARED_PRIORITY_ITEMS[i]=v.name
end
end
_G.ElitePriVersion=(_G.ElitePriVersion or 0)+1
end
function loadModules()
if AnimalsData then
if not AnimalsShared and _G.EliteAnimShim then AnimalsShared=_G.EliteAnimShim end
return true
end
if os.clock()<_mkNextModTry then return false end
_mkNextModTry=os.clock()+(tonumber(_G.EliteModRetry)or 0.5)
pcall(function()
local Datas=RS:FindFirstChild("Datas")or RS:WaitForChild("Datas",1.5)
if Datas then
local a=Datas:FindFirstChild("Animals")or Datas:WaitForChild("Animals",1.5)
if a then AnimalsData=require(a)end
end
end)
pcall(_EliteBuildDefaultBrainrotPriority)
AnimalsShared=_G.EliteAnimShim
if not NumberUtils then
pcall(function()
local Utils=RS:FindFirstChild("Utils")
local n=Utils and Utils:FindFirstChild("NumberUtils")
if n then NumberUtils=require(n)end
end)
end
return AnimalsData~=nil
end
function loadNet()return false end
function getRemote(method,name)
return _G.__secureGetRemote(method,name)
end
_G.EliteGetRemote=getRemote
GRAPPLE_ARG=0.8
task.spawn(function()_grappleUseItem=getRemote("RemoteEvent","UseItem")end)
task.spawn(function()_grappleItemUse=getRemote("RemoteEvent","75c9466d-e4c0-4b02-b26a-c3615fcc1e42")end)
function _fireGrapple()
local fired=false
if not(_grappleUseItem and _grappleUseItem.Parent)then
_grappleUseItem=getRemote("RemoteEvent","UseItem")
end
if not(_grappleItemUse and _grappleItemUse.Parent)then
_grappleItemUse=getRemote("RemoteEvent","75c9466d-e4c0-4b02-b26a-c3615fcc1e42")
end
if _grappleUseItem and _grappleUseItem.Parent then
pcall(function()_grappleUseItem:FireServer(GRAPPLE_ARG)end);fired=true
end
if _grappleItemUse and _grappleItemUse.Parent then
pcall(function()_grappleItemUse:FireServer(GRAPPLE_ARG)end);fired=true
end
if not fired then
local r=getRemote("RemoteEvent","UseItem")
if r then pcall(function()r:FireServer(GRAPPLE_ARG)end);fired=true end
end
return fired
end
function fireGrapple()
local char=LP.Character
if not char then return end
if not char:FindFirstChild("Grapple Hook")then
local bp=LP:FindFirstChild("Backpack")
local tool=bp and bp:FindFirstChild("Grapple Hook")
local hum=char:FindFirstChildOfClass("Humanoid")
if tool and hum then pcall(function()hum:EquipTool(tool)end)end
end
if not char:FindFirstChild("Grapple Hook")then return end
_fireGrapple()
end
CARPET_SPEED=280
CARPET_NAMES={"Flying Carpet","Waverider","Santa's Sleigh","Witch's Broom","Cupid's Wings"}
function findTool(name)
local char=LP.Character
local bp=LP:FindFirstChild("Backpack")
return(char and char:FindFirstChild(name))or(bp and bp:FindFirstChild(name))
end
_lastCarpetName=nil
function equipCarpet()
local char=LP.Character
if not char then return nil end
if _lastCarpetName then
local t=char:FindFirstChild(_lastCarpetName)
if t and t.Parent==char then return _lastCarpetName end
end
local hum=char:FindFirstChildOfClass("Humanoid")
if not hum then return nil end
for _,n in ipairs(CARPET_NAMES)do
local t=findTool(n)
if t and t:IsA("Tool")then
if t.Parent~=char then pcall(function()hum:EquipTool(t)end)end
_lastCarpetName=n
return n
end
end
return nil
end
function setCarpetTool(name)
if type(name)~="string"or name==""then return end
_G.EliteCarpetTool=name
_lastCarpetName=nil
for i=#CARPET_NAMES,1,-1 do
if CARPET_NAMES[i]==name then table.remove(CARPET_NAMES,i)end
end
table.insert(CARPET_NAMES,1,name)
end
if type(_G.EliteCarpetTool)=="string"and _G.EliteCarpetTool~=""then
setCarpetTool(_G.EliteCarpetTool)
end
_carpetEngaging=false
function carpetEngage(force)
if not force then
local c=LP.Character
if c then
for _,n in ipairs(CARPET_NAMES)do
local t=c:FindFirstChild(n)
if t and t:IsA("Tool")then
_G.TPEngage="carpet="..tostring(n)
return n
end
end
end
end
if _carpetEngaging then
local _tw=os.clock()
repeat
RunService.Heartbeat:Wait()
until(not _carpetEngaging)or os.clock()-_tw>6
local c=LP.Character
if c then
for _,n in ipairs(CARPET_NAMES)do
local t=c:FindFirstChild(n)
if t and t:IsA("Tool")then
return n
end
end
end
end
_carpetEngaging=true
local _t0=os.clock()
local _gw=_G.__EliteBootTP and(tonumber(_G.EliteBootGrappleWait)or 1)
or(tonumber(_G.EliteGrappleToolWait)or 5)
while not findTool("Grapple Hook")and os.clock()-_t0<_gw do
RunService.Heartbeat:Wait()
end
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not char or not hum then
_carpetEngaging=false
return nil
end
if not char:FindFirstChild("Grapple Hook")then
local g=findTool("Grapple Hook")
if g then
pcall(function()
hum:EquipTool(g)
end)
end
end
local _te=os.clock()
while not(LP.Character and LP.Character:FindFirstChild("Grapple Hook"))and os.clock()-_te<1.5 do
local c=LP.Character
local h2=c and c:FindFirstChildOfClass("Humanoid")
local g=findTool("Grapple Hook")
if g and h2 then
pcall(function()
h2:EquipTool(g)
end)
end
RunService.Heartbeat:Wait()
end
if LP.Character and LP.Character:FindFirstChild("Grapple Hook")then
_fireGrapple()
_G.__EliteGrappleAt=os.clock()
end
task.wait(tonumber(_G.EliteGrappleHold)or 0.03)
if _G.EliteGrappleUnequip==true then
local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if h then
pcall(function()
h:UnequipTools()
end)
end
task.wait(0.04)
end
local cn
local _tc=os.clock()
repeat
cn=equipCarpet()
local c=LP.Character
if cn and c and c:FindFirstChild(cn)then
break
end
RunService.Heartbeat:Wait()
until os.clock()-_tc>0.5
_G.TPEngage="carpet="..tostring(cn)
_carpetEngaging=false
return cn
end
_G.EliteEquipCarpet=equipCarpet
_G.EliteCarpetEngaging=function()return _carpetEngaging end
if _G.EliteJoinGrapple~=false then
local _shot=false
local _conns={}
local function _shoot()
if _shot then return end
if LP:GetAttribute("Stealing")==true then return end
local c=LP.Character
if not(c and c:FindFirstChildOfClass("Humanoid"))then return end
if not findTool("Grapple Hook")then return end
_shot=true
for _,k in ipairs(_conns)do pcall(function()k:Disconnect()end)end
task.spawn(function()
pcall(carpetEngage,true)
_G.__EliteBootGrappleDone=true
end)
end
local function _watchBag(bag)
if not bag then return end
_conns[#_conns+1]=bag.ChildAdded:Connect(function(t)
if t.Name=="Grapple Hook"then _shoot()end
end)
end
_watchBag(LP:FindFirstChildOfClass("Backpack"))
_conns[#_conns+1]=LP.ChildAdded:Connect(function(c)
if c:IsA("Backpack")then _watchBag(c)_shoot()end
end)
_conns[#_conns+1]=LP.CharacterAdded:Connect(function(c)
_watchBag(c)
task.defer(_shoot)
end)
if LP.Character then _watchBag(LP.Character)end
_shoot()
task.spawn(function()
local char=LP.Character or LP.CharacterAdded:Wait()
pcall(function()char:WaitForChild("Humanoid",15)end)
_shoot()
local t1=os.clock()
while os.clock()-t1<(tonumber(_G.EliteJoinGrappleWait)or 15)do
if _shot then return end
if LP:GetAttribute("Stealing")==true then break end
if findTool("Grapple Hook")then
_shoot()
if _shot then return end
end
if os.clock()-t1>1 then
local gotCarpet=false
for _,n in ipairs(CARPET_NAMES)do
if findTool(n)then gotCarpet=true break end
end
if gotCarpet then
pcall(carpetEngage,false)
break
end
end
task.wait(0.05)
end
_G.__EliteBootGrappleDone=true
end)
else
_G.__EliteBootGrappleDone=true
end
if _G.EliteKeepCarpet==nil then _G.EliteKeepCarpet=true end
LP.CharacterAdded:Connect(function(c)
if _G.EliteKeepCarpet==false then return end
task.spawn(function()
c:WaitForChild("Humanoid",10)
task.wait(tonumber(_G.EliteCarpetRespawnDelay)or 0.6)
if _G.EliteKeepCarpet==false then return end
if _carpetEngaging or LP.Character~=c then return end
if LP:GetAttribute("Stealing")==true then return end
for _,n in ipairs(CARPET_NAMES)do
if c:FindFirstChild(n)then return end
end
pcall(equipCarpet)
end)
end)
MUTATION_PRIORITY={
["Galaxy"]=1,["Candy"]=1,["Yin Yang"]=1,["YinYang"]=1,["Divine"]=1,
["Cursed"]=1,["Lava"]=1,["Radioactive"]=1,["Cyber"]=1,["Rainbow"]=1,["Bloodrot"]=2,
}
TRAIT_PRIORITY={}
MUTATION_ICONS,TRAIT_ICONS={},{}
function _EliteLoadGameData()
local ok1,mData=pcall(function()return require(game.ReplicatedStorage.Datas.Mutations)end)
if ok1 and type(mData)=="table"then
local mList={}
for name,data in pairs(mData)do
if type(data)=="table"then
MUTATION_ICONS[name]=data.Icon
mList[#mList+1]=name
end
end
table.sort(mList)
if#_G.SHARED_MUTATION_PRIORITY==0 then
for i=1,#mList do _G.SHARED_MUTATION_PRIORITY[i]=mList[i]end
end
end
local ok2,tData=pcall(function()return require(game.ReplicatedStorage.Datas.Traits)end)
if ok2 and type(tData)=="table"then
local tList={}
for name,data in pairs(tData)do
if type(data)=="table"then
TRAIT_ICONS[name]=data.Icon
tList[#tList+1]=name
end
end
table.sort(tList)
if#_G.SHARED_TRAIT_PRIORITY==0 then
for i=1,#tList do _G.SHARED_TRAIT_PRIORITY[i]=tList[i]end
end
end
end
task.spawn(function()
pcall(function()
local Datas=game:GetService("ReplicatedStorage"):FindFirstChild("Datas")
local a=Datas and Datas:FindFirstChild("Animals")
if a and not AnimalsData then AnimalsData=require(a)end
if AnimalsData then _EliteBuildDefaultBrainrotPriority()end
end)
pcall(_EliteLoadGameData)
end)
function getMutPrio(m)
if not m or m==""or m=="None"then return 0 end
local n=tostring(m)
local dis=_G.SHARED_MUTATION_DISABLED
if type(dis)=="table"and(dis[n]or dis[_normName(n)])then return 0 end
local idx=_priIndexOfMut(n)
if not idx then
n=n:lower():gsub("[%s%-_]","")
idx=_priIndexOfMut(n)
end
if idx then return 999-idx end
if MUTATION_PRIORITY[m]then return MUTATION_PRIORITY[m]end
if MUTATION_PRIORITY[n]then return MUTATION_PRIORITY[n]end
return 0
end
function getTraitPrio(t)
if not t or t==""then return 0 end
local name=type(t)=="table"and t.name or tostring(t)
local n=name
local idx=_priIndexOfTrait(n)
if not idx then
n=n:lower():gsub("[%s%-_]","")
idx=_priIndexOfTrait(n)
end
if idx then return 999-idx end
if TRAIT_PRIORITY[name]then return TRAIT_PRIORITY[name]end
if TRAIT_PRIORITY[n]then return TRAIT_PRIORITY[n]end
return 0
end
function _normName(s)
return tostring(s):lower():gsub("[%s%-_'%.]","")
end
_priCacheVer,_priCache=-1,{}
_brainrotDefaultPri={}
_brainrotDefaultRarity={}
_mutPriCacheVer,_mutPriCache=-1,{}
_traitPriCacheVer,_traitPriCache=-1,{}
function _priLookup(listName)
local ver=_G.ElitePriVersion or 0
if listName=="mutation"then
if _mutPriCacheVer~=ver then
table.clear(_mutPriCache)
local plist=_G.SHARED_MUTATION_PRIORITY
if type(plist)=="table"then
for i=#plist,1,-1 do _mutPriCache[_normName(plist[i])]=i end
end
_mutPriCacheVer=ver
end
return _mutPriCache
elseif listName=="trait"then
if _traitPriCacheVer~=ver then
table.clear(_traitPriCache)
local plist=_G.SHARED_TRAIT_PRIORITY
if type(plist)=="table"then
for i=#plist,1,-1 do _traitPriCache[_normName(plist[i])]=i end
end
_traitPriCacheVer=ver
end
return _traitPriCache
else
if _priCacheVer~=ver then
table.clear(_priCache)
local plist=_G.SHARED_PRIORITY_ITEMS
if type(plist)=="table"then
for i=#plist,1,-1 do _priCache[_normName(plist[i])]=i end
end
_priCacheVer=ver
end
return _priCache
end
end
_G.ElitePriLookup=function()return _priLookup()end
function _priIndexOf(name)
if not name then return nil end
local n=_normName(name)
local idx=_priLookup()[n]
if idx then return idx end
local def=_brainrotDefaultPri[n]
if def and _brainrotDefaultRarity[n]=="OG"then
return def*0.001
end
return nil
end
function _priIndexOfMut(name)
if not name then return nil end
return _priLookup("mutation")[_normName(name)]
end
function _priIndexOfTrait(name)
if not name then return nil end
return _priLookup("trait")[_normName(name)]
end
function getPlotChannel(plotName)
local channel
pcall(function()channel=_G.EliteSyncGet(plotName)end)
return channel
end
function channelGet(channel,key)
if not channel then return nil end
local ok,v=pcall(function()
local ct=rawget(channel,"CacheTable")
if type(ct)=="table"then
local r=rawget(ct,key)
if r~=nil then return r end
end
local d=rawget(channel,"Data")
if type(d)=="table"then
local r=rawget(d,key)
if r~=nil then return r end
end
return rawget(channel,key)
end)
if ok then return v end
return nil
end
function _ownerIsMe(owner)
if not owner then return false end
local result=false
pcall(function()
if typeof(owner)=="Instance"and owner:IsA("Player")then
result=owner.UserId==LP.UserId
elseif type(owner)=="table"and owner.UserId then
result=owner.UserId==LP.UserId
elseif typeof(owner)=="Instance"then
result=owner==LP
elseif type(owner)=="string"then
result=owner:lower()==LP.Name:lower()
or owner:lower()==(LP.DisplayName or LP.Name):lower()
end
end)
return result
end
function isMyPlot(channel)
if not channel then return false end
return _ownerIsMe(channelGet(channel,"Owner"))
end
_ownerInGameCache,_ownerInGameAt={},{}
function _ownerInGame(owner)
if not owner then return false end
local cacheKey
if typeof(owner)=="Instance"then cacheKey="i:"..tostring(owner)
elseif type(owner)=="number"then cacheKey="n:"..owner
elseif type(owner)=="string"then cacheKey="s:"..owner:lower()
else cacheKey="o:"..tostring(owner)end
local now=os.clock()
local cached=_ownerInGameAt[cacheKey]
if cached and(now-cached.t)<(cached.v and 2 or 0.2)then return cached.v end
local inGame=false
pcall(function()
if typeof(owner)=="Instance"and owner:IsA("Player")then
inGame=owner.Parent==Players
elseif type(owner)=="number"then
inGame=Players:GetPlayerByUserId(owner)~=nil
elseif type(owner)=="table"and owner.Name then
inGame=Players:FindFirstChild(tostring(owner.Name))~=nil
elseif typeof(owner)=="Instance"and owner.Name then
inGame=Players:FindFirstChild(owner.Name)~=nil
elseif type(owner)=="string"then
if Players:FindFirstChild(owner)then
inGame=true
else
local lo=owner:lower()
for _,pl in ipairs(Players:GetPlayers())do
if pl.Name:lower()==lo or(pl.DisplayName or""):lower()==lo then inGame=true break end
end
end
end
end)
_ownerInGameCache[cacheKey]={v=inGame,t=now}
_ownerInGameAt[cacheKey]={v=inGame,t=now}
return inGame
end
function ownerInGame(channel)
if not channel then return false end
return _ownerInGame(channelGet(channel,"Owner"))
end
_petModelCache=setmetatable({},{__mode="v"})
_genCache={}
local _MPS_SUFFIX={K=1e3,M=1e6,B=1e9,T=1e12,Q=1e15}
_wmpsCache,_wmpsAt={},{}
function _worldMPS(plot,slot)
local podiums=plot and plot:FindFirstChild("AnimalPodiums")
local podium=podiums and podiums:FindFirstChild(tostring(slot))
if not podium then return nil end
local _ck=plot.Name.."\0"..tostring(slot)
local _now=os.clock()
if _wmpsAt[_ck]and(_now-_wmpsAt[_ck])<(tonumber(_G.EliteWorldMPSTTL)or 1)then
return _wmpsCache[_ck]
end
local best=nil
local function _scanLabels(parent)
for _,child in ipairs(parent:GetChildren())do
if child:IsA("TextLabel")or child:IsA("TextButton")then
local txt=child.Text
if type(txt)=="string"and txt~=""then
local num,suf=txt:match("%$%s*([%d%.]+)%s*([KMBTQ]?)%s*/s")
if num then
local v=tonumber(num)
if v then
v=v*(_MPS_SUFFIX[suf]or 1)
if not best or v>best then best=v end
end
end
end
end
_scanLabels(child)
end
end
_scanLabels(podium)
_wmpsCache[_ck],_wmpsAt[_ck]=best,_now
return best
end
function getPetPosition(plot,slot,strict)
local podiums=plot:FindFirstChild("AnimalPodiums")
if not podiums then return nil end
local podium=podiums:FindFirstChild(tostring(slot))
if not podium then return nil end
local key=plot.Name.."\0"..tostring(slot)
local cached=_petModelCache[key]
if cached and cached.Parent and cached:IsDescendantOf(podium)then
local ok,cf=pcall(function()return cached:GetBoundingBox()end)
if ok then return cf.Position end
end
_petModelCache[key]=nil
local _skipNames={Claim=true,Base=true,Decorations=true}
local function _findModel(parent)
for _,child in ipairs(parent:GetChildren())do
if child:IsA("Model")and not _skipNames[child.Name]then
if child:FindFirstChildWhichIsA("MeshPart",true)then
return child
end
end
local found=_findModel(child)
if found then return found end
end
return nil
end
local model=_findModel(podium)
if model then
local ok,cf=pcall(function()return model:GetBoundingBox()end)
if ok then
_petModelCache[key]=model
return cf.Position
end
end
if strict then return nil end
local ok,cf=pcall(function()return podium:GetPivot()end)
if ok then return cf.Position end
return podium.Position
end
function scanAllPets()
local pets={}
if not loadModules()then
_G.EliteScanTotal,_G.EliteScanUsed,_G.EliteScanNoChan=0,0,8
return pets
end
local Plots=workspace:FindFirstChild("Plots")
if not Plots then
_G.EliteScanTotal,_G.EliteScanUsed,_G.EliteScanNoChan=0,0,8
return pets
end
local _mkSeen,_mkUse,_mkTotal=0,0,0
local _mkNoChan=0
local _mkTags={}
for _,plot in ipairs(Plots:GetChildren())do
_mkTotal=_mkTotal+1
local channel=getPlotChannel(plot.Name)
if not channel then _mkTags[#_mkTags+1]="nochan"_mkNoChan=_mkNoChan+1 continue end
_mkSeen=_mkSeen+1
local owner=channelGet(channel,"Owner")
if _ownerIsMe(owner)then _G.EliteMyPlot=plot.Name _mkTags[#_mkTags+1]="MINE"continue end
if _G.EliteMyPlot==plot.Name then _mkTags[#_mkTags+1]="MINE"continue end
if not _G.EliteMyPlot and owner==nil then _mkTags[#_mkTags+1]="noowner?"continue end
if _G.EliteRequireOwner~=false and not _ownerInGame(owner)then _mkTags[#_mkTags+1]="left"continue end
_mkUse=_mkUse+1
local animalList=channelGet(channel,"AnimalList")
if not animalList then _mkTags[#_mkTags+1]="nolist"continue end
local _mkPlotN=0
for slot,animalData in pairs(animalList)do
if type(animalData)~="table"then continue end
local animalName=animalData.Index
if not animalName then continue end
local animalInfo=AnimalsData and AnimalsData[animalName]
if not animalInfo and _G.EliteRequireKnown==true then continue end
if _EliteIsFusing(animalData)then continue end
local mutation=animalData.Mutation or"None"
local traits=animalData.Traits
if type(traits)~="table"then traits={}end
local genValue
local _gk=plot.Name.."\0"..tostring(slot)
local _gc=_genCache[_gk]
if _gc and _gc.n==animalName and _gc.m==animalData.Mutation and _gc.t==animalData.Traits then
genValue=_gc.g
else
genValue=0
pcall(function()
local shim=AnimalsShared or _G.EliteAnimShim
if shim then genValue=shim:GetGeneration(animalName,animalData.Mutation,animalData.Traits,nil)end
end)
if genValue and genValue>0 then
_genCache[_gk]={n=animalName,m=animalData.Mutation,t=animalData.Traits,g=genValue}
end
end
if(not genValue or genValue<=0)and _G.EliteWorldMPS~=false then
local wm=_worldMPS(plot,slot)
if wm and wm>0 then genValue=wm end
end
local displayName=(animalInfo and animalInfo.DisplayName)or animalName
local pos=getPetPosition(plot,slot,(_G.EliteRequireOwner==false)or(_G.EliteRequireModel==true))
if pos then
if genValue>=(tonumber(_G.EliteMinMPS)or 0)then
table.insert(pets,{
name=displayName,
index=animalName,
mps=genValue,
mutation=mutation,
traits=traits,
position=pos,
plot=plot.Name,
slot=tostring(slot),
})
_mkPlotN=_mkPlotN+1
end
end
end
_mkTags[#_mkTags+1]=tostring(_mkPlotN)
end
_G.EliteScanTotal,_G.EliteScanUsed,_G.EliteScanNoChan=_mkTotal,_mkUse,_mkNoChan
_G.EliteScanInfo=string.format("plots %d scanned of %d  pets %d  [%s]  %s",_mkUse,_mkTotal,#pets,table.concat(_mkTags," "),tostring(_G.EliteScanMode))
local function _bestTraitPrio(traits)
if type(traits)~="table"then return 0 end
local best=0
for _,t in ipairs(traits)do
local p=getTraitPrio(t)
if p>best then best=p end
end
return best
end
for _,p in ipairs(pets)do
p._pri=_priIndexOf(p.name)or(p.index and _priIndexOf(p.index))or nil
p._mp=tonumber(p.mps)or 0
p._mut=getMutPrio(p.mutation)
p._trait=_bestTraitPrio(p.traits)
end
local function _petOrder(a,b)
local ia,ib=a._pri,b._pri
if(ia~=nil)~=(ib~=nil)then return ia~=nil end
if ia and ib and ia~=ib then return ia<ib end
if ia==nil then
if a._mp~=b._mp then return a._mp>b._mp end
end
if a._mut~=b._mut then return a._mut>b._mut end
if a._trait~=b._trait then return a._trait>b._trait end
if a._mp~=b._mp then return a._mp>b._mp end
local pa,pb=tostring(a.plot),tostring(b.plot)
if pa~=pb then return pa<pb end
return(tonumber(a.slot)or 0)<(tonumber(b.slot)or 0)
end
local mode=_G.EliteStealMode
if mode=="highest"then
table.sort(pets,function(a,b)
local ma,mb=tonumber(a.mps)or 0,tonumber(b.mps)or 0
if ma~=mb then return ma>mb end
local pa,pb=tostring(a.plot),tostring(b.plot)
if pa~=pb then return pa<pb end
return(tonumber(a.slot)or 0)<(tonumber(b.slot)or 0)
end)
return pets
end
table.sort(pets,_petOrder)
return pets
end
_G.EliteScanAllPets=scanAllPets
_scanShared,_scanSharedAt=nil,0
function scanAllPetsCached(maxAge)
do
local k=1/math.clamp(tonumber(_G.EliteScanDelay)or 1,0.3,1)
if k>1 and type(maxAge)=="number"then
maxAge=math.max(0.03,maxAge/k)
end
end
local now=os.clock()
if _scanShared and(now-_scanSharedAt)<=(tonumber(maxAge)or 0.15)then
return _scanShared
end
local ok,p=pcall(scanAllPets)
if ok and type(p)=="table"then
_scanShared,_scanSharedAt=p,now
return p
end
return nil
end
_G.EliteScanCached=scanAllPetsCached
function scanForTP()
local inBoot=_gameLoadAt and(os.clock()-_gameLoadAt)<4
local full=scanAllPetsCached(tonumber(_G.EliteScanCacheAge)or(inBoot and 0.1 or 0.2))
if type(full)~="table"then
full={}
end
if _G.EliteScanTiered and _G.EliteUseTiered~=false then
local ok,tiered=pcall(_G.EliteScanTiered)
if ok and type(tiered)=="table"and#tiered>0 then
local seen={}
for _,p in ipairs(full)do
if p and p.plot and p.slot~=nil then
seen[tostring(p.plot).."_"..tostring(p.slot)]=true
end
end
for _,p in ipairs(tiered)do
if p and p.plot and p.slot~=nil then
local uid=tostring(p.plot).."_"..tostring(p.slot)
if not seen[uid]then
seen[uid]=true
full[#full+1]=p
end
end
end
end
end
return full
end
function _petUid(p)
if not p then
return nil
end
return tostring(p.plot).."_"..tostring(p.slot)
end
function _pickPetOnFoot(pets,myPos)
if not pets or#pets==0 then
return nil
end
local best
if _G.EliteStealMode=="nearest"and myPos then
local bestD=math.huge
for _,p in ipairs(pets)do
if not p.conveyor and p.position then
local d=(p.position-myPos).Magnitude
if d<bestD then
bestD=d
best=p
end
end
end
else
for _,p in ipairs(pets)do
if not p.conveyor then
best=p
break
end
end
end
return best or pets[1]
end
function _findTPSyncedPet(pets)
local uid=_G.EliteStealTargetUID
if type(uid)~="string"or uid==""then
return nil
end
for _,p in ipairs(pets)do
if _petUid(p)==uid then
return p
end
end
return nil
end
function _clearTPSync()
_G.EliteTPSyncActive=false
_G.EliteStealTargetUID=nil
_G.EliteStealTarget=nil
end
function _armTPSync(pet)
if not pet then
return
end
_G.EliteStealTargetUID=_petUid(pet)
_G.EliteStealTarget=pet
_G.EliteTPSyncActive=true
local gen=(_G._EliteTPSyncGen or 0)+1
_G._EliteTPSyncGen=gen
task.delay(12,function()
if _G._EliteTPSyncGen==gen then
_clearTPSync()
end
end)
end
_G.EliteClearTPSync=_clearTPSync
function _findStealTarget(pets)
if not _G.EliteTPSyncActive then
return nil
end
return _findTPSyncedPet(pets)
end
function _publishStealTarget(pet)
if not pet then
return
end
_G.EliteStealTargetUID=_petUid(pet)
_G.EliteStealTarget=pet
end
MK_UPPER={
B={
{coord=Vector3.new(-487.921448,16.850713,-75.768013),facing="NORTH"},
{coord=Vector3.new(-332.379730,16.850722,-75.762100),facing="NORTH"},
{coord=Vector3.new(-487.134918,16.850713,-18.094154),facing="SOUTH"},
{coord=Vector3.new(-316.300171,16.850713,-17.845898),facing="SOUTH"},
},
C={
{coord=Vector3.new(-330.765381,16.850713,31.424425),facing="NORTH"},
{coord=Vector3.new(-502.989349,16.850713,31.172430),facing="NORTH"},
{coord=Vector3.new(-489.077087,16.850713,89.010147),facing="SOUTH"},
{coord=Vector3.new(-330.908936,16.850713,88.930145),facing="SOUTH"},
},
D={
{coord=Vector3.new(-331.264893,16.850713,138.209167),facing="NORTH"},
{coord=Vector3.new(-487.935181,16.850713,138.026321),facing="NORTH"},
{coord=Vector3.new(-487.774933,16.850713,195.882538),facing="SOUTH"},
{coord=Vector3.new(-330.799133,16.850575,196.022354),facing="SOUTH"},
},
}
MK_LOWER={
B={
{coord=Vector3.new(-335.725586,-3.048217,-74.984589),facing="NORTH"},
{coord=Vector3.new(-503.214233,-3.048217,-75.043137),facing="NORTH"},
{coord=Vector3.new(-483.619385,-3.718430,-18.844337),facing="SOUTH"},
{coord=Vector3.new(-316.147095,-3.048218,-18.818844),facing="SOUTH"},
},
C={
{coord=Vector3.new(-335.985413,-3.048218,32.051426),facing="NORTH"},
{coord=Vector3.new(-503.277008,-3.048217,31.956175),facing="NORTH"},
{coord=Vector3.new(-483.749390,-3.048218,88.147003),facing="SOUTH"},
{coord=Vector3.new(-315.793823,-3.048217,88.163979),facing="SOUTH"},
},
D={
{coord=Vector3.new(-335.476654,-3.048218,139.001083),facing="NORTH"},
{coord=Vector3.new(-503.710083,-3.048218,138.989883),facing="NORTH"},
{coord=Vector3.new(-315.654938,-3.048218,195.302444),facing="SOUTH"},
{coord=Vector3.new(-483.859253,-3.048218,195.269043),facing="SOUTH"},
},
}
UPPER_Y_THRESHOLD=7
TALL_PETS={["La Secret Combinasion"]=true,["La Jolly Grande"]=true}
TALL_OFFSET=3
BASES_LOW={
[1]=Vector3.new(-476.52,-2,220.94090270996094),
[2]=Vector3.new(-476.52,-2,113.77315521240234),
[3]=Vector3.new(-476.52,-2,6.178487777709961),
[4]=Vector3.new(-476.52,-2,-101.07275390625),
[5]=Vector3.new(-342.66,-2,221.44737243652344),
[6]=Vector3.new(-342.66,-2,113.41409301757812),
[7]=Vector3.new(-342.66,-2,6.249461650848389),
[8]=Vector3.new(-342.66,-2,-99.73458862304688),
}
BASES_HIGH={
[1]=Vector3.new(-479.51,18,220.94090270996094),
[2]=Vector3.new(-479.51,18,113.77315521240234),
[3]=Vector3.new(-479.51,18,6.178487777709961),
[4]=Vector3.new(-479.51,18,-101.07275390625),
[5]=Vector3.new(-339.48,18,221.44737243652344),
[6]=Vector3.new(-339.48,18,113.41409301757812),
[7]=Vector3.new(-339.48,18,6.249461650848389),
[8]=Vector3.new(-339.48,18,-99.73458862304688),
}
FRONT_Y_LOW=-3.048217
FRONT_Y_HIGH=16.850713
COLUMN_SPLIT_X=-410
FRONT_Z_CLAMP=18
SIDE_NEAR_Z=45
function getClosestBaseIdx(pos)
local closest,dist=1,math.huge
for i=1,8 do
local b=BASES_LOW[i]
local d=(pos.X-b.X)^2+(pos.Z-b.Z)^2
if d<dist then
dist=d
closest=i
end
end
return closest
end
function buildFrontCandidate(idx,isUpper,playerZ)
local base=isUpper and BASES_HIGH[idx]or BASES_LOW[idx]
local frontY=isUpper and FRONT_Y_HIGH or FRONT_Y_LOW
local frontZ=math.clamp(playerZ-base.Z,-FRONT_Z_CLAMP,FRONT_Z_CLAMP)+base.Z
local coord=Vector3.new(base.X,frontY,frontZ)
local faceDir=(idx<=4)and Vector3.new(-1,0,0)or Vector3.new(1,0,0)
return coord,faceDir
end
function plotSides(coordTable,idx)
local base=BASES_LOW[idx]
local isWest=idx<=4
local out={}
for _,coords in pairs(coordTable)do
for _,data in ipairs(coords)do
if((data.coord.X<COLUMN_SPLIT_X)==isWest)and math.abs(data.coord.Z-base.Z)<SIDE_NEAR_Z then
out[#out+1]=data
end
end
end
return out
end
function _floor1LaserSolid(plotName)
local solid=false
pcall(function()
local Plots=workspace:FindFirstChild("Plots")
local plot=Plots and Plots:FindFirstChild(plotName)
if not plot then
return
end
for _,d in ipairs(plot:GetDescendants())do
if
d:IsA("BasePart")
and(d.Name=="LaserHitbox"or d.Name=="Laser")
and d.CanCollide
and d.Position.Y<=9
then
solid=true
break
end
end
end)
return solid
end
function isPlotUnlocked(plotName)
local ok,res=pcall(function()
local channel=getPlotChannel(plotName)
if not channel then
return false
end
if channelGet(channel,"BlockEndTimeFirstFloor")~=nil then
return false
end
return not _floor1LaserSolid(plotName)
end)
return ok and(res==true)
end
function findClosest(petPos,coordTable)
local best,bestKey,bestDist=nil,nil,math.huge
for skyKey,coords in pairs(coordTable)do
for _,data in ipairs(coords)do
local c=data.coord
local d=math.sqrt((petPos.X-c.X)^2+(petPos.Z-c.Z)^2)
if d<bestDist then
bestDist=d
best=data
bestKey=skyKey
end
end
end
return best,bestKey
end
do
_vizParts={}
_vizGen=0
function _vizEnsure()
if _vizFolder and _vizFolder.Parent then
return
end
_vizFolder=Instance.new("Folder")
_vizFolder.Name="Folder"
_vizFolder.Parent=workspace
_vizAnchor=Instance.new("Part")
_vizAnchor.Name="Anchor"
_vizAnchor.Anchored=true
_vizAnchor.CanCollide=false
_vizAnchor.CanQuery=false
_vizAnchor.CanTouch=false
_vizAnchor.Transparency=1
_vizAnchor.Size=Vector3.one
_vizAnchor.CFrame=CFrame.new()
_vizAnchor.Parent=_vizFolder
end
clearViz=function()
if _vizFolder then
pcall(function()
_vizFolder:Destroy()
end)
end
_vizFolder,_vizAnchor=nil,nil
table.clear(_vizParts)
end
local function _ghost(cf,size,color,op)
_vizEnsure()
local a=Instance.new("BoxHandleAdornment")
a.Adornee=_vizAnchor
a.AlwaysOnTop=true
a.ZIndex=0
pcall(function()
a.Shading=Enum.AdornShading.XRayShaded
end)
a.Color3=color
a.Transparency=1-op
a.Size=size
a.CFrame=cf
a.Parent=_vizAnchor
end
local function _neon(cf,size,color,ball,transp)
_vizEnsure()
local p=Instance.new("Part")
p.Anchored=true
p.CanCollide=false
p.CanQuery=false
p.CanTouch=false
p.CastShadow=false
p.Material=Enum.Material.Neon
p.Color=color
p.Transparency=transp or 0
if ball then
p.Shape=Enum.PartType.Ball
end
p.Size=size
p.CFrame=cf
p.Parent=_vizFolder
end
function vizLine(a,b,color)
local d=b-a
if d.Magnitude<0.05 then
return
end
_neon(CFrame.lookAt((a+b)*0.5,b),Vector3.new(0.25,0.25,d.Magnitude),color,false,0)
end
function vizDot(pos,color,sz)
_neon(CFrame.new(pos),Vector3.new(sz,sz,sz),color,true,0)
end
vizPath=function(fromPos,waypoints)
if _G.EliteShowPath~=true then
return
end
if#waypoints==0 then
return
end
local COL=Color3.fromRGB(208,208,214)
local prev=fromPos
for _,wp in ipairs(waypoints)do
vizLine(prev,wp,COL)
prev=wp
end
vizDot(waypoints[#waypoints],COL,1.6)
end
end
MK_SPEED=125
MK_ARRIVE=3
_STRIP_OK=(type(getconnections)=="function")
function _climbCap()
local v=math.clamp(tonumber(_G.EliteClimb)or 200,100,250)
if not _STRIP_OK then
v=55
end
return v
end
function vZero(hrp)
if hrp then
_vzL(hrp)
_vzA(hrp)
end
end
function _setFlightVel(hrp,vel)
local char=hrp and hrp.Parent
local part=(char and(char:FindFirstChild("UpperTorso")or char:FindFirstChild("Torso")))or hrp
if part then
part.AssemblyLinearVelocity=vel
end
if _G.EliteFlingTP==true and not _G.__EliteFlashHolding and not _G.__EliteFlingCalm and hrp and typeof(vel)=="Vector3"and vel.Magnitude>5 then
pcall(function()
local t=os.clock()
local amp=math.clamp(tonumber(_G.EliteFlingAmp)or 1,0,3)
hrp.CFrame=CFrame.new(hrp.Position)*CFrame.Angles(0,(t*18)%(math.pi*2),0)*CFrame.Angles(math.sin(t*20)*math.rad(45)*amp,0,(t*16)%(math.pi*2))
end)
end
end
function EliteTweenOn()
return _G.EliteTweenTP==true
end
function tweenPinAt(hrp,dest,faceDir)
if not hrp or not hrp.Parent then
return
end
local face=faceDir
if typeof(face)~="Vector3"or face.Magnitude<0.1 then
face=Vector3.new(dest.X-hrp.Position.X,0,dest.Z-hrp.Position.Z)
if face.Magnitude<0.1 then
face=Vector3.new(0,0,1)
end
end
face=Vector3.new(face.X,0,face.Z)
if face.Magnitude<0.1 then
face=Vector3.new(0,0,1)
end
face=face.Unit
local hum=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
local hadAuto=hum and hum.AutoRotate
if hum then
pcall(function()
hum.AutoRotate=false
end)
end
local function restore()
if hum and hadAuto~=nil then
pcall(function()
hum.AutoRotate=hadAuto
end)
end
end
local pingMs=80
pcall(function()
pingMs=math.clamp((LP:GetNetworkPing()or 0.08)*1000,20,400)
end)
local STAGE=math.clamp(tonumber(_G.EliteTweenStage)or(40-math.max(0,pingMs-120)*0.08),14,100)
local flySpd=math.max(tonumber(_G.__EliteTweenSpd)or 300,120)
if dest.Y>7 then
STAGE=math.min(STAGE,tonumber(_G.EliteTweenStageF2)or 12)
flySpd=0
end
local gap=(dest-hrp.Position).Magnitude
local n=math.max(1,math.ceil(gap/STAGE))
local from=hrp.Position
local dir=Vector3.new(dest.X-from.X,0,dest.Z-from.Z)
dir=dir.Magnitude>0.1 and dir.Unit or face
for k=1,n do
local p=(k==n)and dest or from:Lerp(dest,k/n)
hrp.CFrame=CFrame.lookAt(p,p+face)
hrp.AssemblyAngularVelocity=Vector3.zero
if k<n then
hrp.AssemblyLinearVelocity=(flySpd>0)and(dir*flySpd)or Vector3.zero
RunService.Heartbeat:Wait()
if not(hrp and hrp.Parent)or _G.EliteTPStop then
restore()
return
end
else
hrp.AssemblyLinearVelocity=Vector3.zero
end
end
task.spawn(function()
for _=1,6 do
RunService.Heartbeat:Wait()
if not(hrp and hrp.Parent)then
break
end
hrp.AssemblyAngularVelocity=Vector3.zero
end
restore()
end)
_G.EliteTPWhy=("snap %d studs in %d stage(s)"):format(math.floor(gap),n)
end
function tweenFlyThenTp(hrp,route,dest,spd,near,faceDir)
if not hrp or not hrp.Parent or not route or#route==0 then
return false
end
if not EliteTweenOn()then
velMoveThrough(hrp,route,spd,true,true)
return false
end
local NEAR=math.clamp(tonumber(near)or 40,20,60)
local path={hrp.Position}
for _,p in ipairs(route)do
path[#path+1]=p
end
if(path[#path]-dest).Magnitude>0.5 then
path[#path+1]=dest
end
local split,splitIdx=path[1],2
do
local left=NEAR
local i=#path
while i>1 do
local seg=(path[i]-path[i-1]).Magnitude
if seg>=left then
split=path[i]+(path[i-1]-path[i]).Unit*left
splitIdx=i
break
end
left=left-seg
i=i-1
end
end
local far={}
for j=2,splitIdx-1 do
far[#far+1]=path[j]
end
far[#far+1]=split
_G.__EliteTweenSpd=spd
if(split-hrp.Position).Magnitude>2 then
velMoveThrough(hrp,far,math.max(tonumber(spd)or 0,120),false,true,true)
end
if _G.EliteTPStop or not hrp.Parent then
return false
end
if(hrp.Position-split).Magnitude>12 then
pcall(eliteSay,string.format("[TWEEN] reached the tween start %.0f studs off - flew the rest instead",(hrp.Position-split).Magnitude))
local rest={}
for j=splitIdx,#path do
rest[#rest+1]=path[j]
end
velMoveThrough(hrp,rest,math.max(tonumber(spd)or 0,120),true,true)
return false
end
local near_={hrp.Position}
for j=splitIdx,#path do
near_[#near_+1]=path[j]
end
local pingMs=80
pcall(function()
pingMs=math.clamp((LP:GetNetworkPing()or 0.08)*1000,20,400)
end)
local flySpd=math.max(tonumber(spd)or 300,120)
local STAGE=math.clamp(tonumber(_G.EliteTweenStage)or 14,3,40)
local face=faceDir
if typeof(face)~="Vector3"or face.Magnitude<0.1 then
face=dest-near_[1]
end
face=Vector3.new(face.X,0,face.Z)
if face.Magnitude<0.1 then
face=Vector3.new(0,0,1)
end
face=face.Unit
local hum=hrp.Parent:FindFirstChildOfClass("Humanoid")
local hadAuto=hum and hum.AutoRotate
if hum then
pcall(function()
hum.AutoRotate=false
end)
end
for k=2,#near_ do
local a,b2=near_[k-1],near_[k]
local seg=b2-a
local n=math.max(1,math.ceil(seg.Magnitude/STAGE))
local dir=Vector3.new(seg.X,0,seg.Z)
dir=dir.Magnitude>0.1 and dir.Unit or face
for step=1,n do
if _G.EliteTPStop or not hrp.Parent then
break
end
local p=a:Lerp(b2,step/n)
hrp.CFrame=CFrame.lookAt(p,p+face)
hrp.AssemblyAngularVelocity=Vector3.zero
local isLast=(k==#near_ and step==n)
hrp.AssemblyLinearVelocity=(not isLast and flySpd>0)and(dir*flySpd)or Vector3.zero
if not isLast then
RunService.Heartbeat:Wait()
end
end
end
task.spawn(function()
for _=1,6 do
RunService.Heartbeat:Wait()
if not(hrp and hrp.Parent)then
break
end
hrp.AssemblyAngularVelocity=Vector3.zero
end
if hum and hadAuto~=nil then
pcall(function()
hum.AutoRotate=hadAuto
end)
end
end)
_G.EliteTPWhy="tween: hopped the last "..math.floor(NEAR).." studs of the route"
return true
end
_G.EliteTweenFlyThenTp,_G.EliteTweenPinAt=tweenFlyThenTp,tweenPinAt
function eliteStartHopThenFly(hrp,route,spd,allowJump,quickStart)
velMoveThrough(hrp,route,math.max(tonumber(spd)or 400,120),allowJump,quickStart)
return false
end
_G.EliteStartHopThenFly=eliteStartHopThenFly
function eliteEnsureArrive(hrp,dest,spd)
if not(hrp and typeof(dest)=="Vector3")then
return false
end
local flySpd=math.max(tonumber(spd)or 400,120)
for _=1,2 do
for _=1,3 do
RunService.Heartbeat:Wait()
end
if not hrp.Parent or _G.EliteTPStop then
return false
end
if(hrp.Position-dest).Magnitude<=(tonumber(_G.EliteArriveTolerance)or 6)then
return true
end
_tpStage("fixing position")
local gap=(hrp.Position-dest).Magnitude
local r={dest}
if gap>25 then
local ok,rr=pcall(computeRoute,hrp.Position,dest,nil)
if ok and type(rr)=="table"and#rr>0 then
r=rr
end
end
velMoveThrough(hrp,r,flySpd,true,true)
end
return hrp.Parent~=nil and(hrp.Position-dest).Magnitude<=6
end
_G.EliteEnsureArrive=eliteEnsureArrive
function velMoveThrough(hrp,waypoints,speedOverride,allowJump,quickStart,noEase)
if not hrp or not hrp.Parent or#waypoints==0 then
return
end
local _ease=(_G.EliteEaseIn~=false)and not noEase
local _runSpeed=speedOverride or(_G.TPVelocity and math.clamp(_G.TPVelocity,200,750))or CARPET_SPEED
vizPath(hrp.Position,waypoints)
local wpIdx=1
local done=false
local conn
local function finish()
if done then
return
end
done=true
if hrp and hrp.Parent then
_vzL(hrp)
_vzA(hrp)
local _,y=hrp.CFrame:ToEulerAnglesYXZ()
hrp.CFrame=CFrame.new(waypoints[#waypoints])*CFrame.Angles(0,y,0)
end
if conn then
conn:Disconnect()
end
end
local lastDist,stall=math.huge,0
local _stStart=os.clock()
local _lastJump=0
local _routeLen=0
do
local _p=hrp.Position
for _,wp in ipairs(waypoints)do
_routeLen=_routeLen+(_p-wp).Magnitude
_p=wp
end
end
local _mayJump=_routeLen>=(tonumber(_G.EliteJumpMinDist)or 100)
local _=quickStart
conn=RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
if not hrp or not hrp.Parent or done then
if conn then
conn:Disconnect()
end
return
end
if _G.EliteTPStop then
finish()
return
end
if _G.__EliteFlashNearFn and _G.__EliteFlashFlight and wpIdx==#waypoints
and(waypoints[wpIdx]-hrp.Position).Magnitude<=(tonumber(_G.EliteFlashPreEquip)or 40)then
local _nf=_G.__EliteFlashNearFn
_G.__EliteFlashNearFn=nil
pcall(_nf)
end
if not _G.__EliteFlashHolding then
equipCarpet()
end
if _mayJump and _G.EliteJumpEachStep~=false then
local _now=os.clock()
if _now-_lastJump>=(tonumber(_G.EliteJumpGap)or 0.2)then
_lastJump=_now
local _jh=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
if _jh then
pcall(function()
_jh:ChangeState(Enum.HumanoidStateType.Jumping)
end)
pcall(function()
_jh.Jump=true
end)
end
end
end
local target=waypoints[wpIdx]
local diff=target-hrp.Position
local mag=diff.Magnitude
local _spd=_runSpeed
if wpIdx<#waypoints and mag<26 then
local nxt=waypoints[wpIdx+1]
local b=nxt-target
if mag>0.1 and b.Magnitude>0.1 and diff.Unit:Dot(b.Unit)<0.9 then
_spd=math.min(_spd,_G.__EliteFlashFlight and(tonumber(_G.EliteFlashTurnSpeed)or 380)or 240)
end
end
local _last=(wpIdx==#waypoints)
if _last and _ease then
_spd=math.min(
_spd,
math.max(tonumber(_G.EliteArriveMin)or(_G.__EliteFlashFlight and 300 or 150),mag*(tonumber(_G.EliteArriveGain)or 30))
)
end
local _arr=_last and _ease and math.max(1.5,_spd/60*1.1)or math.max(MK_ARRIVE,_spd/60*1.25)
if mag<_arr then
wpIdx=wpIdx+1
if wpIdx>#waypoints then
finish()
return
end
lastDist,stall=math.huge,0
if _G.EliteZeroEachStep~=false and _vzOK()then
pcall(function()
local _v=hrp.AssemblyLinearVelocity
local _keepY=(_G.EliteZeroStepKeepY==false)and 0 or math.max(_v.Y,0)
hrp.AssemblyLinearVelocity=Vector3.new(0,_keepY,0)
hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
end)
end
if _mayJump and _G.EliteJumpEachStep~=false then
local _wh=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
if _wh then
_lastJump=os.clock()
pcall(function()
_wh:ChangeState(Enum.HumanoidStateType.Jumping)
end)
pcall(function()
_wh.Jump=true
end)
end
end
target=waypoints[wpIdx]
diff=target-hrp.Position
mag=diff.Magnitude
end
if mag>lastDist-0.05 then
stall=stall+1
else
stall=0
end
lastDist=mag
if stall>=(tonumber(_G.EliteStallFrames)or 18)then
finish()
return
end
if mag>=0.1 then
local dir=diff.Unit
if(allowJump or diff.Y>10)and diff.Y>5 and wpIdx<#waypoints then
local hum=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
if hum then
local st=hum:GetState()
if st~=Enum.HumanoidStateType.Jumping and st~=Enum.HumanoidStateType.Freefall then
pcall(function()
hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)
pcall(function()
hum.Jump=true
end)
end
end
end
local _sp=_spd
local _mc=_climbCap()
if dir.Y>0 and dir.Y*_sp>_mc then
_sp=_mc/dir.Y
end
local _vx,_vy,_vz=dir.X*_sp,dir.Y*_sp,dir.Z*_sp
local _calmD=tonumber(_G.EliteFlingCalm)or(EliteTweenOn()and 70 or 45)
_G.__EliteFlingCalm=(wpIdx==#waypoints and mag<_calmD)
if _G.EliteFlingTP==true and not _G.__EliteFlashHolding and not _G.__EliteFlingCalm then
_G.__EliteFlingSettled=false
local flat=Vector3.new(dir.X,0,dir.Z)
if flat.Magnitude>0.1 then
local u=flat.Unit
local perp=Vector3.new(-u.Z,0,u.X)
local t=os.clock()
local amp=math.clamp(tonumber(_G.EliteFlingAmp)or 1,0,3)
local slide=((math.sin(t*16)*0.8)+(math.cos(t*8)*0.55))*math.min(125,_sp*0.28)*amp
local waveY=((math.sin(t*20)*0.75)+(math.cos(t*10)*0.5))*math.min(75,_sp*0.18)*amp
local pulse=1+(math.sin(t*24)*0.18*amp)
_vx=dir.X*_sp*pulse+perp.X*slide
_vz=dir.Z*_sp*pulse+perp.Z*slide
_vy=math.clamp(_vy+waveY,math.min(_vy,-_mc),_mc)
local _m=math.sqrt(_vx*_vx+_vy*_vy+_vz*_vz)
if _m>_sp and _m>0 then
local k=_sp/_m
_vx,_vy,_vz=_vx*k,_vy*k,_vz*k
end
end
elseif _G.EliteFlingTP==true and not _G.__EliteFlingSettled then
_G.__EliteFlingSettled=true
local fd=Vector3.new(dir.X,0,dir.Z)
if fd.Magnitude>0.1 then
pcall(function()
hrp.CFrame=CFrame.lookAt(hrp.Position,hrp.Position+fd.Unit)
hrp.AssemblyAngularVelocity=Vector3.zero
end)
end
end
_setFlightVel(hrp,Vector3.new(_vx,_vy,_vz))
end
end))
local totalDist=0
do
local prev=hrp.Position
for _,wp in ipairs(waypoints)do
totalDist=totalDist+(prev-wp).Magnitude
prev=wp
end
end
local timeout=totalDist/math.min(MK_SPEED,_runSpeed)+(tonumber(_G.EliteFlightGrace)or 2)
local elapsed,_wt=0,os.clock()
while not done and elapsed<timeout do
if _G.__EliteFlashFlight then
RunService.Heartbeat:Wait()
if os.clock()-_wt>=0.05 then
_wt=os.clock()
elapsed=elapsed+0.05
end
else
task.wait(0.05)
elapsed=elapsed+0.05
end
if not(hrp and hrp.Parent)then
break
end
end
finish()
vZero(hrp)
end
_OTHER_CLONES={}
do
local _MY_CLONE=tostring(LP.UserId).."_Clone"
local _seen={}
local function _isOtherClone(inst)
if not inst then
return false
end
local n=inst.Name
if n==_MY_CLONE then
return false
end
if n:match("^%d+_Clone$")then
return true
end
if not n:find("lone",1,true)then
return false
end
if not inst:IsA("Model")then
return false
end
if inst==LP.Character then
return false
end
if not inst:FindFirstChild("HumanoidRootPart")then
return false
end
if not inst:FindFirstChildOfClass("Humanoid")then
return false
end
for _,pl in ipairs(Players:GetPlayers())do
if pl.Character==inst then
return false
end
end
return true
end
local function _neutralize(inst)
if not inst or _seen[inst]then
return
end
_seen[inst]=true
_OTHER_CLONES[#_OTHER_CLONES+1]=inst
local function declaw(d)
if d:IsA("BasePart")and d.CanCollide then
pcall(function()
d.CanCollide=false
end)
end
end
for _,d in ipairs(inst:GetDescendants())do
declaw(d)
end
inst.DescendantAdded:Connect(declaw)
inst.Destroying:Connect(function()
_seen[inst]=nil
for i=#_OTHER_CLONES,1,-1 do
if _OTHER_CLONES[i]==inst then
table.remove(_OTHER_CLONES,i)
break
end
end
end)
end
local function _scan(inst)
if _isOtherClone(inst)then
_neutralize(inst)
end
end
for _,c in ipairs(workspace:GetChildren())do
_scan(c)
end
workspace.ChildAdded:Connect(function(c)
_scan(c)
task.defer(function()
if c and c.Parent==workspace then
_scan(c)
end
end)
end)
end
do
local _pSeen=setmetatable({},{__mode="k"})
local _ncBag=setmetatable({},{__mode="k"})
local function _declaw(d)
if d:IsA("BasePart")and d.CanCollide then
pcall(function()
d.CanCollide=false
end)
end
end
local function _declawChar(char)
if not char then
return
end
for _,d in ipairs(char:GetDescendants())do
_declaw(d)
end
if not _pSeen[char]then
_pSeen[char]=true
char.DescendantAdded:Connect(_declaw)
end
end
local _THEIRS={"HumanoidRootPart","UpperTorso","LowerTorso","Torso","Head"}
local function _noCollide(char)
if _G.EliteNoCollideConstraints==false or not char then
return
end
local c=LP.Character
local mine=c and c:FindFirstChild("HumanoidRootPart")
if not mine then
return
end
local bag=_ncBag[char]
if not bag or bag.root~=mine then
bag={root=mine}
_ncBag[char]=bag
end
for _,n in ipairs(_THEIRS)do
local part=char:FindFirstChild(n)
if part and part:IsA("BasePart")then
local nc=bag[n]
if not(nc and nc.Parent)then
pcall(function()
local k=Instance.new("NoCollisionConstraint")
k.Part0,k.Part1=mine,part
k.Parent=mine
bag[n]=k
end)
end
end
end
end
local _watched=setmetatable({},{__mode="k"})
local _pinHooked=setmetatable({},{__mode="k"})
local function _pin(p)
if not p:IsA("BasePart")then
return
end
if p.CanCollide then
p.CanCollide=false
end
if _watched[p]then
return
end
_watched[p]=true
pcall(function()
p:GetPropertyChangedSignal("CanCollide"):Connect(function()
if p.CanCollide then
p.CanCollide=false
end
end)
end)
end
local function _pinChar(ch)
if not ch then
return
end
for _,d in ipairs(ch:GetDescendants())do
_pin(d)
end
if not _pinHooked[ch]then
_pinHooked[ch]=true
ch.DescendantAdded:Connect(function(d)
task.defer(_pin,d)
end)
end
end
local function _hookPlayer(pl)
if pl==LP then
return
end
if pl.Character then
_declawChar(pl.Character)
_noCollide(pl.Character)
_pinChar(pl.Character)
end
pl.CharacterAdded:Connect(function(c)
task.wait(0.05)
_declawChar(c)
_noCollide(c)
_pinChar(c)
end)
end
for _,pl in ipairs(Players:GetPlayers())do
_hookPlayer(pl)
end
Players.PlayerAdded:Connect(_hookPlayer)
LP.CharacterAdded:Connect(function()
task.wait(0.3)
for _,pl in ipairs(Players:GetPlayers())do
if pl~=LP and pl.Character then
_noCollide(pl.Character)
end
end
end)
local function _pinPlayer(pl)
if pl==LP then
return
end
if pl.Character then
_pinChar(pl.Character)
end
pl.CharacterAdded:Connect(function(c)
task.wait(0.15)
_pinChar(c)
end)
end
for _,pl in ipairs(Players:GetPlayers())do
_pinPlayer(pl)
end
Players.PlayerAdded:Connect(_pinPlayer)
local _MY_CLONE_N=tostring(LP.UserId).."_Clone"
local function _clones()
local t=_OTHER_CLONES
return(type(t)=="table")and t or{}
end
local _ncParts=setmetatable({},{__mode="k"})
local _ncAge=setmetatable({},{__mode="k"})
local function _ncList(m)
local t=_ncParts[m]
local now=os.clock()
if not t or now-(_ncAge[m]or 0)>3 then
t={}
for _,d in ipairs(m:GetDescendants())do
if d:IsA("BasePart")then
t[#t+1]=d
end
end
_ncParts[m],_ncAge[m]=t,now
end
return t
end
local _ncAcc=0
RunService.Stepped:Connect(function(_,dt)
if _G.EliteNoCollide==false or _G.isCloning==true then
return
end
_ncAcc=_ncAcc+(dt or 0.016)
if _ncAcc<0.1 then
return
end
_ncAcc=0
local c=LP.Character
local myHrp=c and c:FindFirstChild("HumanoidRootPart")
if not myHrp then
return
end
local mp=myHrp.Position
local rng=tonumber(_G.EliteNoCollideRange)or 28
for _,pl in ipairs(Players:GetPlayers())do
local ch=(pl~=LP)and pl.Character
local h=ch and ch:FindFirstChild("HumanoidRootPart")
if h and(h.Position-mp).Magnitude<=rng then
for _,d in ipairs(_ncList(ch))do
if d.CanCollide then
d.CanCollide=false
end
end
end
end
for _,cl in ipairs(_clones())do
if cl and cl.Parent and cl.Name~=_MY_CLONE_N then
local h=cl:FindFirstChild("HumanoidRootPart")
if h and(h.Position-mp).Magnitude<=rng then
for _,d in ipairs(_ncList(cl))do
if d.CanCollide then
d.CanCollide=false
end
end
end
end
end
end)
task.spawn(function()
while true do
task.wait(1)
if _G.EliteNoCollide~=false and _G.isCloning~=true then
for _,pl in ipairs(Players:GetPlayers())do
local ch=(pl~=LP)and pl.Character
if ch then
_pinChar(ch)
end
end
for _,cl in ipairs(_clones())do
if cl and cl.Parent and cl.Name~=_MY_CLONE_N then
_pinChar(cl)
end
end
end
end
end)
end
local _len
do
local _DIRS={Vector3.new(1,0,0),Vector3.new(-1,0,0),Vector3.new(0,0,1),Vector3.new(0,0,-1)}
local _STRUCT={["structure base home"]=true,["Wall"]=true,["Floor"]=true,["Roof"]=true}
local _SKIP_NAME={
["DeliveryHitbox"]=true,
["StealHitbox"]=true,
["LaserHitbox"]=true,
["AnimalTarget"]=true,
["Multiplier"]=true,
["Laser"]=true,
["Hitbox"]=true,
["Spawn"]=true,
["MainRoot"]=true,
["SecondFloor"]=true,
["ThirdFloor"]=true,
["Slope"]=true,
}
local function _blocks(inst)
if not inst then
return false
end
if _SKIP_NAME[inst.Name]then
return false
end
if inst.CanCollide then
return true
end
local _par=inst.Parent
if _par and(_par.Name=="ObstacleVolumes"or _par.Name=="ObstacleVolume")then
return false
end
if _STRUCT[inst.Name]then
return true
end
local s=inst.Size
if s and math.max(s.X*s.Y,s.X*s.Z,s.Y*s.Z)>150 then
return true
end
return false
end
local function _blocksWide(inst)
if not inst then
return false
end
if _SKIP_NAME[inst.Name]then
return false
end
if inst.CanCollide then
return true
end
local _par=inst.Parent
if _par and(_par.Name=="ObstacleVolumes"or _par.Name=="ObstacleVolume")then
return false
end
if _STRUCT[inst.Name]then
return true
end
local s=inst.Size
if s and math.max(s.X*s.Y,s.X*s.Z,s.Y*s.Z)>30 then
return true
end
return false
end
local function _block(origin,target,blockFn)
blockFn=blockFn or _blocks
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
rp.IgnoreWater=true
local skip={}
for _,pl in ipairs(Players:GetPlayers())do
if pl.Character then
skip[#skip+1]=pl.Character
end
end
for _,cl in ipairs(_OTHER_CLONES)do
skip[#skip+1]=cl
end
local o=origin
for _=1,16 do
rp.FilterDescendantsInstances=skip
local d=target-o
if d.Magnitude<0.05 then
return nil
end
local res=workspace:Raycast(o,d,rp)
if not res then
return nil
end
if blockFn(res.Instance)then
return res
end
skip[#skip+1]=res.Instance
o=res.Position+d.Unit*0.3
end
return nil
end
local function _clear(a,b)
return _block(a,b)==nil
end
local function _clearDist(origin,dir,maxD)
local res=_block(origin,origin+dir.Unit*maxD)
if not res then
return maxD
end
return(res.Position-origin).Magnitude
end
function _len(pts)
local s,prev=0,pts[1]
for k=2,#pts do
s=s+(pts[k]-prev).Magnitude
prev=pts[k]
end
return s
end
local function _pull(pts)
if#pts<=2 then
return pts
end
local out={pts[1]}
local i=1
while i<#pts do
local j=#pts
while j>i+1 and not _clear(out[#out],pts[j])do
j=j-1
end
out[#out+1]=pts[j]
i=j
end
return out
end
local function _stages(toPos)
local st={}
for _,dr in ipairs(_DIRS)do
local cd=_clearDist(toPos,dr,46)
if cd>=12 then
st[#st+1]=toPos+dr*math.min(cd-5,38)
end
end
return st
end
local function _routeClear(pts)
for i=1,#pts-1 do
if not _clear(pts[i],pts[i+1])then
return false
end
end
return true
end
local function _peakY(pts)
local m=-math.huge
for _,p in ipairs(pts)do
if p.Y>m then
m=p.Y
end
end
return m
end
local function _starts(fromPos)
local pts={fromPos}
if _block(fromPos,fromPos+Vector3.new(0,40,0))then
for _,dr in ipairs(_DIRS)do
local cd=_clearDist(fromPos,dr,40)
if cd>=12 then
pts[#pts+1]=fromPos+dr*math.min(cd-5,34)
end
end
end
return pts
end
local function _candidates(sp,stage,toPos)
local list={}
local function add(mid)
if mid then
list[#list+1]={sp,mid,stage,toPos}
else
list[#list+1]={sp,stage,toPos}
end
end
add(nil)
add(Vector3.new(stage.X,sp.Y,stage.Z))
add(Vector3.new(sp.X,stage.Y,sp.Z))
local dir=Vector3.new(stage.X-sp.X,0,stage.Z-sp.Z)
if dir.Magnitude>0.1 then
dir=dir.Unit
local perp=Vector3.new(-dir.Z,0,dir.X)
for _,off in ipairs({20,-20,40,-40})do
add(sp+perp*off)
end
end
return list
end
local PathfindingService=game:GetService("PathfindingService")
local _CLEARANCE=tonumber(_G.ElitePathClearance)or 16
local function _clearWideRay(a,b)
return _block(a,b,_blocksWide)==nil
end
local _SWEEP_R=4
local _ENDPOINT_SLACK=6
local _canSphere=nil
local function _sweepBlockFn(inst)
if _G.EliteStrictSweep==false then
return _blocks(inst)
end
return _blocksWide(inst)
end
local function _sweepDir(a,b)
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
rp.IgnoreWater=true
local skip={}
for _,pl in ipairs(Players:GetPlayers())do
if pl.Character then
skip[#skip+1]=pl.Character
end
end
for _,cl in ipairs(_OTHER_CLONES)do
skip[#skip+1]=cl
end
local o=a
for _=1,24 do
rp.FilterDescendantsInstances=skip
local d=b-o
if d.Magnitude<0.05 then
return false
end
local res
local ok=pcall(function()
res=workspace:Spherecast(o,_SWEEP_R,d,rp)
end)
if not ok then
_canSphere=false
return nil
end
if not res then
return false
end
if _sweepBlockFn(res.Instance)then
return true
end
skip[#skip+1]=res.Instance
local adv=(res.Distance or 0)-0.05
if adv>0 then
o=o+d.Unit*math.min(adv,d.Magnitude)
end
end
return true
end
local function _sweepBlocked(a,b,slackA,slackB)
if _canSphere==nil then
_canSphere=pcall(function()
workspace:Spherecast(Vector3.new(0,10000,0),1,Vector3.new(0,-1,0),RaycastParams.new())
end)
end
if not _canSphere then
return nil
end
local d=b-a
local len=d.Magnitude
if len<0.1 then
return false
end
local u=d/len
local a2=a+u*math.min(slackA or _ENDPOINT_SLACK,len*0.4)
local b2=b-u*math.min(slackB or _ENDPOINT_SLACK,len*0.4)
local fwd=_sweepDir(a2,b2)
if fwd==nil then
return nil
end
if fwd then
return true
end
local rev=_sweepDir(b2,a2)
if rev==nil then
return nil
end
return rev
end
local function _clearWide(a,b,slackA,slackB)
if not _clear(a,b)then
return false
end
local sw=_sweepBlocked(a,b,slackA,slackB)
if sw~=nil then
return not sw
end
local d=Vector3.new(b.X-a.X,0,b.Z-a.Z)
if d.Magnitude<0.1 then
local ox=Vector3.new(_CLEARANCE,0,0)
local oz=Vector3.new(0,0,_CLEARANCE)
return _clearWideRay(a+ox,b+ox)
and _clearWideRay(a-ox,b-ox)
and _clearWideRay(a+oz,b+oz)
and _clearWideRay(a-oz,b-oz)
end
local perp=Vector3.new(-d.Z,0,d.X).Unit*_CLEARANCE
local up=Vector3.new(0,_CLEARANCE,0)
return _clearWideRay(a+perp,b+perp)
and _clearWideRay(a-perp,b-perp)
and _clearWideRay(a+up,b+up)
and _clearWideRay(a-up,b-up)
end
local function _crestClear(a,b)
if not _clear(a,b)then
return false
end
local cl=tonumber(_G.EliteCrestClearance)or 6
local d=Vector3.new(b.X-a.X,0,b.Z-a.Z)
if d.Magnitude<0.1 then
return true
end
local perp=Vector3.new(-d.Z,0,d.X).Unit*cl
return _clearWideRay(a+perp,b+perp)
and _clearWideRay(a-perp,b-perp)
and _clearWideRay(a+Vector3.new(0,cl,0),b+Vector3.new(0,cl,0))
end
local function _pullWide(pts)
if#pts<=2 then
return pts
end
local out={pts[1]}
local i=1
local n=#pts
while i<n do
local j=n
while j>i+1 do
local a,b=out[#out],pts[j]
local sA=(i==1)and _ENDPOINT_SLACK or 0
local sB=(j==n)and _ENDPOINT_SLACK or 0
if _clearWide(a,b,sA,sB)then
break
end
j=j-1
end
out[#out+1]=pts[j]
i=j
end
return out
end
local function _pushOffWalls(pts)
if#pts<=2 then
return pts
end
local MARGIN=tonumber(_G.ElitePathWallMargin)or 8
local MAX_PUSH=12
local out={pts[1]}
for i=2,#pts-1 do
local p=pts[i]
local shift=Vector3.zero
for _,dr in ipairs(_DIRS)do
local res=_block(p,p+dr*MARGIN,_blocks)
if res then
local dist=(res.Position-p).Magnitude
if dist<MARGIN then
shift=shift-dr*(MARGIN-dist)
end
end
end
do
local resUp=_block(p,p+Vector3.new(0,MARGIN,0),_blocks)
if resUp then
local dist=(resUp.Position-p).Magnitude
if dist<4 then
shift=shift+Vector3.new(0,-(4-dist),0)
end
end
end
if shift.Magnitude>0.1 then
if shift.Magnitude>MAX_PUSH then
shift=shift.Unit*MAX_PUSH
end
local moved=p+shift
if _clear(out[#out],moved)then
out[#out+1]=moved
else
out[#out+1]=p
end
else
out[#out+1]=p
end
end
out[#out+1]=pts[#pts]
return out
end
do
local _vxFloor,_vxSqrt=math.floor,math.sqrt
local _vxMin,_vxMax=math.min,math.max
local function _vxAbs(n)
return n<0 and-n or n
end
local _vxOverlap=OverlapParams.new()
_vxOverlap.FilterType=Enum.RaycastFilterType.Exclude
_vxOverlap.RespectCanCollide=true
local _vxCast=RaycastParams.new()
_vxCast.FilterType=Enum.RaycastFilterType.Exclude
_vxCast.RespectCanCollide=true
_vxCast.IgnoreWater=true
local _vxOrigin
local _vxDimX,_vxDimY,_vxDimZ=0,0,0
local _vxSz,_vxInflate=4,2.5
local _vxSolid={}
local _vxSolidGen,_vxSolidAt="",0
local _vxOX,_vxOY,_vxOZ=0,0,0
local _vxHeight=5
local function _vxWorld(sz,x,y,z)
local h=sz*0.5
return Vector3.new(_vxOrigin.X+x*sz+h,_vxOrigin.Y+y*sz+h,_vxOrigin.Z+z*sz+h)
end
local function _vxKey(x,y,z)
return x+y*1024+z*1048576
end
local function _vxGKey(x,y,z)
return(x+_vxOX+8192)+(y+_vxOY+8192)*16384+(z+_vxOZ+8192)*268435456
end
local function _vxIsSolid(x,y,z)
if x<0 or y<0 or z<0 or x>=_vxDimX or y>=_vxDimY or z>=_vxDimZ then
return true
end
local k=_vxGKey(x,y,z)
local c=_vxSolid[k]
if c~=nil then
return c
end
local h=_vxSz*0.5
local cx=_vxOrigin.X+x*_vxSz+h
local cy=_vxOrigin.Y+y*_vxSz+h
local cz=_vxOrigin.Z+z*_vxSz+h
local sxz=_vxSz+_vxInflate
local vy=_vxHeight>_vxSz and _vxHeight or _vxSz
local vcy=cy-h+vy*0.5
local parts=
workspace:GetPartBoundsInBox(CFrame.new(cx,vcy,cz),Vector3.new(sxz,vy,sxz),_vxOverlap)
local solid=#parts>0
_vxSolid[k]=solid
return solid
end
local function _vxSegClear(from,to,radius,height,sample)
local dir=to-from
local mag=dir.Magnitude
if mag<0.05 then
return true
end
if workspace:Raycast(from,dir,_vxCast)then
return false
end
local r=radius>1 and radius or 1
if workspace:Blockcast(CFrame.new(from),Vector3.new(r*2,height,r*2),dir,_vxCast)~=nil then
return false
end
local n=_vxFloor(mag)
if sample~=false and n>=2 then
local step=dir/n
local torso=Vector3.new(r*2,3,r*2)
for i=1,n-1 do
local pt=from+step*i
if#workspace:GetPartBoundsInBox(CFrame.new(pt),torso,_vxOverlap)>0 then
return false
end
end
end
return true
end
local _vxNeigh={}
do
for dx=-1,1 do
for dy=-1,1 do
for dz=-1,1 do
if dx~=0 or dy~=0 or dz~=0 then
local nz=(dx~=0 and 1 or 0)+(dy~=0 and 1 or 0)+(dz~=0 and 1 or 0)
local kd=dx+dy*1024+dz*1048576
_vxNeigh[#_vxNeigh+1]={dx,dy,dz,_vxSqrt(dx*dx+dy*dy+dz*dz),nz,kd}
end
end
end
end
end
local function _vxNoCorner(cx,cy,cz,off)
if off[5]<2 then
return true
end
if off[1]~=0 and _vxIsSolid(cx+off[1],cy,cz)then
return false
end
if off[2]~=0 and _vxIsSolid(cx,cy+off[2],cz)then
return false
end
if off[3]~=0 and _vxIsSolid(cx,cy,cz+off[3])then
return false
end
return true
end
local function _vxSnapGoal(goalPos,x,y,z)
if not _vxIsSolid(x,y,z)then
return x,y,z
end
for r=1,16 do
for dx=-r,r do
for dy=-r,r do
for dz=-r,r do
if _vxMax(_vxAbs(dx),_vxAbs(dy),_vxAbs(dz))==r then
local nx,ny,nz=x+dx,y+dy,z+dz
if
not _vxIsSolid(nx,ny,nz)
and(_vxWorld(_vxSz,nx,ny,nz)-goalPos).Magnitude<=8
then
return nx,ny,nz
end
end
end
end
end
end
return x,y,z
end
local function _vxSnapStart(pos,x,y,z)
if not _vxIsSolid(x,y,z)then
return x,y,z
end
for r=1,16 do
for dx=-r,r do
for dy=-r,r do
for dz=-r,r do
if _vxMax(_vxAbs(dx),_vxAbs(dy),_vxAbs(dz))==r then
local nx,ny,nz=x+dx,y+dy,z+dz
if
not _vxIsSolid(nx,ny,nz)
and not workspace:Raycast(pos,_vxWorld(_vxSz,nx,ny,nz)-pos,_vxCast)
then
return nx,ny,nz
end
end
end
end
end
end
return x,y,z
end
local function _vxPush(h,f,key)
local i=#h+1
h[i]={f,key}
while i>1 do
local p=_vxFloor(i*0.5)
if h[p][1]<=h[i][1]then
break
end
h[p],h[i]=h[i],h[p]
i=p
end
end
local function _vxPop(h)
local n=#h
if n==0 then
return nil
end
local top=h[1]
h[1]=h[n]
h[n]=nil
n=n-1
local i=1
while true do
local l,r,s=i+i,i+i+1,i
if l<=n and h[l][1]<h[s][1]then
s=l
end
if r<=n and h[r][1]<h[s][1]then
s=r
end
if s==i then
break
end
h[i],h[s]=h[s],h[i]
i=s
end
return top[2]
end
local _vxHeurW=tonumber(_G.ElitePathWeight)or 2.5
local function _vxAStar(sz,startCell,goalCell,startPos,goalPos)
local sx,sy,sz2=_vxSnapStart(startPos,startCell.x,startCell.y,startCell.z)
local gx,gy,gz=_vxSnapGoal(goalPos,goalCell.x,goalCell.y,goalCell.z)
local goalKey=_vxKey(gx,gy,gz)
local startKey=_vxKey(sx,sy,sz2)
local nodes={[startKey]={x=sx,y=sy,z=sz2,g=0,parent=nil}}
local closed={}
local heap={}
_vxPush(heap,0,startKey)
local function Heur(x,y,z)
local ax,ay,az=x-gx,y-gy,z-gz
return _vxSqrt(ax*ax+ay*ay+az*az)
end
local pops=0
local _t0=os.clock()
local _slice=_t0
local _SLICE=(tonumber(_G.ElitePathSliceMs)or 8)/1000
local _CAP=tonumber(_G.ElitePathMaxTime)or math.huge
while#heap>0 do
local curKey=_vxPop(heap)
if closed[curKey]then
continue
end
closed[curKey]=true
pops=pops+1
if pops>300000 then
break
end
if os.clock()-_slice>_SLICE then
RunService.Heartbeat:Wait()
_slice=os.clock()
if _slice-_t0>_CAP or _G.EliteTPStop then
break
end
end
local cur=nodes[curKey]
if curKey==goalKey then
local path={}
local n=cur
while n do
path[#path+1]=_vxWorld(sz,n.x,n.y,n.z)
n=n.parent and nodes[n.parent]
end
local rev={}
for i=#path,1,-1 do
rev[#rev+1]=path[i]
end
return rev
end
local cx,cy,cz=cur.x,cur.y,cur.z
local cg=cur.g
for _,off in _vxNeigh do
local nk=curKey+off[6]
if closed[nk]then
continue
end
local nx,ny,nz=cx+off[1],cy+off[2],cz+off[3]
if _vxIsSolid(nx,ny,nz)then
continue
end
if not _vxNoCorner(cx,cy,cz,off)then
continue
end
local tg=cg+off[4]
local ex=nodes[nk]
if not ex or tg<ex.g then
if ex then
ex.g,ex.parent,ex.x,ex.y,ex.z=tg,curKey,nx,ny,nz
else
nodes[nk]={x=nx,y=ny,z=nz,g=tg,parent=curKey}
end
_vxPush(heap,tg+_vxHeurW*Heur(nx,ny,nz),nk)
end
end
end
return nil
end
local function _vxSimplify(path,radius,height)
if not path or#path<3 then
return path
end
local out={path[1]}
local anchor=1
local i=2
local _slice=os.clock()
while i<=#path do
if os.clock()-_slice>0.004 then
RunService.Heartbeat:Wait()
_slice=os.clock()
end
if not _vxSegClear(path[anchor],path[i+1]or path[i],radius,height,false)then
out[#out+1]=path[i]
anchor=i
end
i=i+1
end
out[#out+1]=path[#path]
return out
end
voxelRoute=function(fromPos,toPos)
local char=LP.Character
local _flt=char and{char}or{}
for _,cl in ipairs(_OTHER_CLONES)do
_flt[#_flt+1]=cl
end
_vxOverlap.FilterDescendantsInstances=_flt
_vxCast.FilterDescendantsInstances=_flt
local sz=tonumber(_G.ElitePathCell)or 4
local inflate=tonumber(_G.ElitePathRadius)or 2.5
local height=tonumber(_G.ElitePathHeight)or 5
local pad=tonumber(_G.ElitePathPad)or 40
_vxHeurW=tonumber(_G.ElitePathWeight)or 2.5
local _gen=sz.."|"..inflate.."|"..height
local _now=os.clock()
if _gen~=_vxSolidGen or(_now-_vxSolidAt)>(tonumber(_G.ElitePathCacheTTL)or 3)then
table.clear(_vxSolid)
_vxSolidGen=_gen
end
_vxSolidAt=_now
_vxSz,_vxInflate,_vxHeight=sz,inflate,height
local mn=Vector3.new(
_vxMin(fromPos.X,toPos.X),
_vxMin(fromPos.Y,toPos.Y),
_vxMin(fromPos.Z,toPos.Z)
)-Vector3.new(pad,pad,pad)
local mx=Vector3.new(
_vxMax(fromPos.X,toPos.X),
_vxMax(fromPos.Y,toPos.Y),
_vxMax(fromPos.Z,toPos.Z)
)+Vector3.new(pad,pad,pad)
mn=Vector3.new(_vxFloor(mn.X/sz)*sz,_vxFloor(mn.Y/sz)*sz,_vxFloor(mn.Z/sz)*sz)
_vxOrigin=mn
_vxOX,_vxOY,_vxOZ=_vxFloor(mn.X/sz),_vxFloor(mn.Y/sz),_vxFloor(mn.Z/sz)
local size=mx-mn
_vxDimX=_vxFloor(size.X/sz)+1
_vxDimY=_vxFloor(size.Y/sz)+1
_vxDimZ=_vxFloor(size.Z/sz)+1
if _vxDimX*_vxDimY*_vxDimZ>200000 then
return nil
end
local startCell={
x=_vxFloor((fromPos.X-_vxOrigin.X)/sz),
y=_vxFloor((fromPos.Y-_vxOrigin.Y)/sz),
z=_vxFloor((fromPos.Z-_vxOrigin.Z)/sz),
}
local goalCell={
x=_vxFloor((toPos.X-_vxOrigin.X)/sz),
y=_vxFloor((toPos.Y-_vxOrigin.Y)/sz),
z=_vxFloor((toPos.Z-_vxOrigin.Z)/sz),
}
local path=_vxAStar(sz,startCell,goalCell,fromPos,toPos)
if not path then
return nil
end
path=_vxSimplify(path,inflate,height)
if not path or#path==0 then
return nil
end
local route={}
for idx=2,#path do
route[#route+1]=path[idx]
end
if#route==0 or(route[#route]-toPos).Magnitude>0.5 then
route[#route+1]=toPos
end
return route
end
end
_G.EliteVoxelRoute=voxelRoute
local _MAP_CENTER={minX=-458,maxX=-362,minZ=-40,maxZ=185}
local _BYPASS_Z_NORTH,_BYPASS_Z_SOUTH=205,-95
local _BYPASS_X_WEST,_BYPASS_X_EAST=-525,-295
local function _inCenterZone(x,z)
return x>=_MAP_CENTER.minX and x<=_MAP_CENTER.maxX and z>=_MAP_CENTER.minZ and z<=_MAP_CENTER.maxZ
end
local function _segmentCrossesCenter(a,b)
if _inCenterZone(a.X,a.Z)or _inCenterZone(b.X,b.Z)then
return true
end
for i=1,10 do
local t=i/11
if _inCenterZone(a.X+(b.X-a.X)*t,a.Z+(b.Z-a.Z)*t)then
return true
end
end
return false
end
local function _findBestCenterDetour(fromPos,toPos,y)
local candidates={
{Vector3.new(fromPos.X,y,_BYPASS_Z_NORTH),Vector3.new(toPos.X,y,_BYPASS_Z_NORTH)},
{Vector3.new(fromPos.X,y,_BYPASS_Z_SOUTH),Vector3.new(toPos.X,y,_BYPASS_Z_SOUTH)},
{Vector3.new(_BYPASS_X_WEST,y,fromPos.Z),Vector3.new(_BYPASS_X_WEST,y,toPos.Z)},
{Vector3.new(_BYPASS_X_EAST,y,fromPos.Z),Vector3.new(_BYPASS_X_EAST,y,toPos.Z)},
}
local best,bestLen=nil,math.huge
for _,pair in ipairs(candidates)do
local w1,w2=pair[1],pair[2]
if _clearWide(fromPos,w1)and _clearWide(w1,w2)and _clearWide(w2,toPos)then
local len=(fromPos-w1).Magnitude+(w1-w2).Magnitude+(w2-toPos).Magnitude
if len<bestLen then
bestLen=len
best={w1,w2}
end
end
end
return best
end
_G.EliteSegmentCrossesCenter=_segmentCrossesCenter
_G.EliteFindCenterDetour=_findBestCenterDetour
local function _rowBoxX()
return tonumber(_G.EliteRowBoxX)or 26
end
local function _rowBoxZ()
return tonumber(_G.EliteRowBoxZ)or 30
end
local function _rowLane()
return tonumber(_G.EliteRowLane)or 30
end
local function _nearestBase(p)
local bi,bd=nil,math.huge
for i=1,8 do
local b=BASES_LOW[i]
local d=(p.X-b.X)^2+(p.Z-b.Z)^2
if d<bd then
bd=d
bi=i
end
end
if bd>70*70 then
return nil
end
return bi
end
local function _segmentHitsOtherBase(a,b,ignA,ignB)
local hx,hz=_rowBoxX(),_rowBoxZ()
for i=0,24 do
local t=i/24
local px=a.X+(b.X-a.X)*t
local pz=a.Z+(b.Z-a.Z)*t
for k=1,8 do
if k~=ignA and k~=ignB then
local bs=BASES_LOW[k]
if math.abs(px-bs.X)<=hx and math.abs(pz-bs.Z)<=hz then
return true
end
end
end
end
return false
end
local function _findRowDetour(fromPos,toPos,y)
local iFrom,iTo=_nearestBase(fromPos),_nearestBase(toPos)
if not _segmentHitsOtherBase(fromPos,toPos,iFrom,iTo)then
return nil
end
local colX=BASES_LOW[iTo or 1].X
local off=_rowLane()
local lanes={}
local outer=(colX<COLUMN_SPLIT_X)and(colX-off)or(colX+off)
lanes[#lanes+1]=outer
local inner=(colX<COLUMN_SPLIT_X)and(colX+off)or(colX-off)
if not _inCenterZone(inner,(fromPos.Z+toPos.Z)*0.5)then
lanes[#lanes+1]=inner
end
local best,bestLen=nil,math.huge
for _,laneX in ipairs(lanes)do
local w1=Vector3.new(laneX,y,fromPos.Z)
local w2=Vector3.new(laneX,y,toPos.Z)
if
_clearWide(fromPos,w1)
and _clearWide(w1,w2)
and _clearWide(w2,toPos)
and not _segmentHitsOtherBase(w1,w2,iFrom,iTo)
then
local len=(fromPos-w1).Magnitude+(w1-w2).Magnitude+(w2-toPos).Magnitude
if len<bestLen then
bestLen=len
best={w1,w2}
end
end
end
return best
end
_G.EliteFindRowDetour=_findRowDetour
local _hopRP=RaycastParams.new()
_hopRP.FilterType=Enum.RaycastFilterType.Exclude
local function _partTopY(inst)
local ok,t=pcall(function()
local cf,sz=inst.CFrame,inst.Size
local half=(
math.abs(cf.RightVector.Y)*sz.X
+math.abs(cf.UpVector.Y)*sz.Y
+math.abs(cf.LookVector.Y)*sz.Z
)/2
return cf.Position.Y+half
end)
if ok and t then
return t
end
return inst.Position.Y+(inst.Size.Y/2)
end
local function _hopBlockerTop(a,b)
local ignore={LP.Character}
for _,cl in ipairs(_OTHER_CLONES)do
ignore[#ignore+1]=cl
end
local top=nil
for _=1,10 do
_hopRP.FilterDescendantsInstances=ignore
local r=workspace:Raycast(a,b-a,_hopRP)
if not r then
break
end
if _blocks(r.Instance)then
local t=_partTopY(r.Instance)
if not top or t>top then
top=t
end
end
ignore[#ignore+1]=r.Instance
end
return top
end
local function _hopRoute(fromPos,toPos)
local flat=Vector3.new(toPos.X-fromPos.X,0,toPos.Z-fromPos.Z)
local dist=flat.Magnitude
if dist<8 then
return nil
end
local dir=flat.Unit
local step=tonumber(_G.EliteHopStep)or 8
local clear=tonumber(_G.EliteHopClear)or 4
local maxUp=tonumber(_G.EliteHopMaxUp)or 22
local groundY=fromPos.Y
local route={}
local inHop,hopY,hopStart=false,nil,nil
local i=step
while i<=dist do
local a=fromPos+dir*(i-step)
local b=fromPos+dir*math.min(i,dist)
local ga=Vector3.new(a.X,groundY,a.Z)
local gb=Vector3.new(b.X,groundY,b.Z)
if not _clear(ga,gb)then
local top=_hopBlockerTop(ga,gb)or(groundY+6)
local want=top+clear
if want-groundY>maxUp then
return nil
end
if not inHop then
inHop,hopY,hopStart=true,want,ga
route[#route+1]=Vector3.new(a.X,want,a.Z)
elseif want>hopY then
hopY=want
route[#route+1]=Vector3.new(a.X,want,a.Z)
end
elseif inHop then
inHop=false
route[#route+1]=Vector3.new(b.X,hopY,b.Z)
route[#route+1]=gb
end
i=i+step
end
if inHop then
route[#route+1]=Vector3.new(toPos.X,hopY,toPos.Z)
end
route[#route+1]=toPos
return route
end
_G.EliteHopRoute=_hopRoute
function _softenLine(fromPos,toPos)
if _G.EliteSoftenLine==false then
return nil
end
local span=toPos-fromPos
local d=span.Magnitude
if d<(tonumber(_G.EliteSoftenMin)or 220)then
return nil
end
local flat=Vector3.new(span.X,0,span.Z)
if flat.Magnitude<1 then
return nil
end
flat=flat.Unit
local perp=Vector3.new(-flat.Z,0,flat.X)
local segs=math.clamp(math.floor(d/(tonumber(_G.EliteSoftenSeg)or 160))+1,2,4)
local amp=tonumber(_G.EliteSoftenAmp)or 9
local ampY=tonumber(_G.EliteSoftenAmpY)or 5
local sgn=((math.floor(math.abs(fromPos.X)+math.abs(toPos.Z))%2)==0)and 1 or-1
local pts={}
for i=1,segs-1 do
local t=i/segs
local w=math.sin(t*math.pi)
pts[#pts+1]=fromPos+span*t+perp*(amp*w*sgn)+Vector3.new(0,ampY*w,0)
end
pts[#pts+1]=toPos
local prev=fromPos
for _,p in ipairs(pts)do
if not _clearWide(prev,p)then
return nil
end
prev=p
end
return pts
end
local function _centerSpanT(a,b)
local t0,t1=nil,nil
for i=0,40 do
local t=i/40
local x=a.X+(b.X-a.X)*t
local z=a.Z+(b.Z-a.Z)*t
if _inCenterZone(x,z)then
if not t0 then
t0=t
end
t1=t
end
end
return t0,t1
end
local function _hitSpanT(a,b)
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
rp.IgnoreWater=true
local skip={}
for _,pl in ipairs(Players:GetPlayers())do
if pl.Character then
skip[#skip+1]=pl.Character
end
end
for _,cl in ipairs(_OTHER_CLONES)do
skip[#skip+1]=cl
end
rp.FilterDescendantsInstances=skip
local t0,t1=nil,nil
local n,edge=28,0.1
for i=0,n-1 do
local tA,tB=i/n,(i+1)/n
if tB>edge and tA<(1-edge)then
local pA,pB=a:Lerp(b,tA),a:Lerp(b,tB)
local d=pB-pA
if d.Magnitude>0.05 then
local hit=workspace:Raycast(pA,d,rp)
if hit and _blocksWide(hit.Instance)then
if not t0 then
t0=math.max(tA,edge)
end
t1=math.min(tB,1-edge)
end
end
end
end
return t0,t1
end
local function _localHopOver(fromPos,toPos,tBlock0,tBlock1)
local lift=tonumber(_G.EliteCenterFly)or 10
local pad=tonumber(_G.EliteHopPad)or 0.12
local t0=math.clamp(tBlock0 or 0.35,0.08,0.85)
local t1=math.clamp(tBlock1 or 0.65,t0+0.04,0.92)
local tRise0=math.max(0.04,t0-pad)
local tRise1,tFall0,tFall1=t0,t1,math.min(0.94,t1+pad)
local function at(t,yAdd)
local p=fromPos:Lerp(toPos,t)
local gy=fromPos.Y+(toPos.Y-fromPos.Y)*t
return Vector3.new(p.X,gy+(yAdd or 0),p.Z)
end
local route={fromPos}
local function push(p)
if(route[#route]-p).Magnitude>0.6 then
route[#route+1]=p
end
end
push(at(tRise0,0))
push(at((tRise0+tRise1)*0.5,lift*0.5))
push(at(tRise1,lift))
push(at((tRise1+tFall0)*0.5,lift))
push(at(tFall0,lift))
push(at((tFall0+tFall1)*0.5,lift*0.5))
push(at(tFall1,0))
push(toPos)
return route
end
local function _centerRiseRoute(fromPos,toPos)
local top=_hopBlockerTop(fromPos,toPos)
local want=math.max(fromPos.Y+8,toPos.Y+6,(top or fromPos.Y)+6)
want=math.min(want,fromPos.Y+(tonumber(_G.EliteCenterRiseMax)or 60))
local room=_clearDist(fromPos,Vector3.new(0,1,0),want-fromPos.Y+3)
local riseY=math.min(want,fromPos.Y+room-3)
if riseY-fromPos.Y<5 then
return nil
end
local riseTo=Vector3.new(fromPos.X,riseY,fromPos.Z)
if _clearWide(riseTo,toPos)then
return{riseTo,toPos}
end
local over=Vector3.new(toPos.X,riseY,toPos.Z)
if _clearWide(riseTo,over)and _clear(over,toPos)then
return{riseTo,over,toPos}
end
return nil
end
function computeRoute(fromPos,toPos,facingDir,maxLift,preferCrest)
local _=maxLift
if _clearWide(fromPos,toPos)then
return{toPos}
end
if _G.EliteCenterRise~=false and _inCenterZone(fromPos.X,fromPos.Z)then
local rr=_centerRiseRoute(fromPos,toPos)
if rr then
return rr
end
end
if _segmentCrossesCenter(fromPos,toPos)then
local c0,c1=_centerSpanT(fromPos,toPos)
local h0,h1=_hitSpanT(fromPos,toPos)
if c0 and h0 and h1 and h1>=c0 and h0<=(c1 or 1)then
local t0=math.max(h0,c0)
local t1=math.min(h1,c1 or h1)
if(t1-t0)>0.02 then
return _localHopOver(fromPos,toPos,t0,t1)
end
end
end
local centerPatch=nil
local rowPatch=_findRowDetour(fromPos,toPos,fromPos.Y)
if rowPatch and#rowPatch>0 then
fromPos=rowPatch[#rowPatch]
end
local function _withPatch(route)
if(not centerPatch or#centerPatch==0)and(not rowPatch or#rowPatch==0)then
return route
end
local merged={}
if centerPatch then
for _,p in ipairs(centerPatch)do
merged[#merged+1]=p
end
end
if rowPatch then
for _,p in ipairs(rowPatch)do
merged[#merged+1]=p
end
end
for _,p in ipairs(route)do
merged[#merged+1]=p
end
return merged
end
if _clearWide(fromPos,toPos)then
return _withPatch({toPos})
end
if preferCrest then
local cruiseY=math.max(fromPos.Y,toPos.Y,26)+(tonumber(_G.ElitePathCrestLift)or 12)
local up=Vector3.new(fromPos.X,cruiseY,fromPos.Z)
local over=Vector3.new(toPos.X,cruiseY,toPos.Z)
local crest={fromPos,up,over,toPos}
local ok=true
for i=1,#crest-1 do
local a,b=crest[i],crest[i+1]
if(a-b).Magnitude>0.5 then
local sA=(i==1)and _ENDPOINT_SLACK or 0
local sB=(i==#crest-1)and _ENDPOINT_SLACK or 0
if not _clearWide(a,b,sA,sB)then
ok=false
break
end
end
end
if ok then
return _withPatch(crest)
end
end
do
local vr=voxelRoute(fromPos,toPos)
if vr and#vr>0 then
return _withPatch(vr)
end
end
local entry=facingDir and(toPos-facingDir*14)or toPos
local best,bestLen=nil,math.huge
local function consider(pts)
if not pts or#pts<2 then
return
end
local n=#pts
for i=1,n-1 do
local a,b=pts[i],pts[i+1]
if(a-b).Magnitude>0.5 then
local sA=(i==1)and _ENDPOINT_SLACK or 0
local sB=(i==n-1)and _ENDPOINT_SLACK or 0
if not _clearWide(a,b,sA,sB)then
return
end
end
end
local pulled=_pullWide(pts)
local L=_len(pulled)
if L<bestLen then
best,bestLen=pulled,L
end
end
do
local dirF=Vector3.new(entry.X-fromPos.X,0,entry.Z-fromPos.Z)
if dirF.Magnitude>0.1 then
dirF=dirF.Unit
local perp=Vector3.new(-dirF.Z,0,dirF.X)
local midBase=(fromPos+entry)*0.5
for _,off in ipairs({14,-14,24,-24,38,-38,56,-56,76,-76})do
consider({fromPos,midBase+perp*off,entry})
consider({fromPos,fromPos+perp*off,entry+perp*off,entry})
end
end
end
local navRaw
if not best then
local groundTo=Vector3.new(entry.X,fromPos.Y,entry.Z)
local path=PathfindingService:CreatePath({
AgentRadius=16,
AgentHeight=5,
AgentCanJump=true,
AgentJumpHeight=10,
AgentMaxSlope=89,
})
local FLOAT=tonumber(_G.ElitePathFloat)or 5
local nav={fromPos}
local ok=pcall(function()
path:ComputeAsync(Vector3.new(fromPos.X,fromPos.Y,fromPos.Z),groundTo)
end)
if ok and path.Status==Enum.PathStatus.Success then
local last=fromPos
for _,wp in ipairs(path:GetWaypoints())do
if(wp.Position-last).Magnitude>=8 then
nav[#nav+1]=wp.Position+Vector3.new(0,FLOAT,0)
last=wp.Position
end
end
end
nav[#nav+1]=entry+Vector3.new(0,FLOAT,0)
nav=_pushOffWalls(nav)
navRaw=nav
consider(nav)
end
local route=best
if not route and _clear(fromPos,toPos)then
route={toPos}
end
if not route and navRaw then
route=_pullWide(navRaw)
end
if not route then
route={toPos}
end
if(route[#route]-toPos).Magnitude>0.5 then
route[#route+1]=toPos
end
return _withPatch(route)
end
end
(function()
local TP2={}
_G.__EliteAB=TP2
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local LP=Players.LocalPlayer
function TP2.log(msg)
local L=_G.__EliteTPLog
if type(L)~="table"then
L={}
_G.__EliteTPLog=L
end
L[#L+1]=string.format("%.2f %s",os.clock(),tostring(msg))
if#L>300 then
table.remove(L,1)
end
end
local function v3s(v)
return string.format("(%.1f, %.1f, %.1f)",v.X,v.Y,v.Z)
end
TP2.v3s=v3s
local _PLOT_BOXES={
[1]={minX=-525.25,maxX=-479.75,minY=-10.10,maxY=43.90,minZ=196.61,maxZ=242.11},
[2]={minX=-525.25,maxX=-479.75,minY=-10.10,maxY=43.90,minZ=89.61,maxZ=135.11},
[3]={minX=-525.25,maxX=-479.75,minY=-10.10,maxY=43.90,minZ=-17.39,maxZ=28.11},
[4]={minX=-525.25,maxX=-479.75,minY=-10.10,maxY=43.90,minZ=-124.39,maxZ=-78.89},
[5]={minX=-339.44,maxX=-293.94,minY=-10.10,maxY=43.90,minZ=199.11,maxZ=244.61},
[6]={minX=-339.44,maxX=-293.94,minY=-10.10,maxY=43.90,minZ=92.11,maxZ=137.61},
[7]={minX=-339.44,maxX=-293.94,minY=-10.10,maxY=43.90,minZ=-14.89,maxZ=30.61},
[8]={minX=-339.44,maxX=-293.94,minY=-10.10,maxY=43.90,minZ=-121.89,maxZ=-76.39},
}
TP2.inBase=function(pos,pad)
pad=pad or 0
for k=1,8 do
local b=_PLOT_BOXES[k]
if
pos.X>=b.minX-pad
and pos.X<=b.maxX+pad
and pos.Z>=b.minZ-pad
and pos.Z<=b.maxZ+pad
then
return true,k
end
end
return false
end
function TP2.hold(hrp,pos,look)
local H={pos=pos,pressed=false,pushed=false,released=false}
local char=hrp.Parent
local hum=char and char:FindFirstChildOfClass("Humanoid")
local cc={}
local states={
Enum.HumanoidStateType.Freefall,
Enum.HumanoidStateType.FallingDown,
Enum.HumanoidStateType.Ragdoll,
Enum.HumanoidStateType.Jumping,
}
local auto=hum and hum.AutoRotate
if hum then
pcall(function()
for _,st in ipairs(states)do
hum:SetStateEnabled(st,false)
end
hum.AutoRotate=false
hum:ChangeState(Enum.HumanoidStateType.Running)
end)
end
local function noclip()
local c=LP.Character
if not c then
return
end
for _,d in ipairs(c:GetDescendants())do
if d:IsA("BasePart")and d.CanCollide then
cc[d]=true
d.CanCollide=false
end
end
end
local conn
function H.release(stepBack)
if H.released then
return
end
H.released=true
if conn then
conn:Disconnect()
end
if H.plat then
pcall(function()
H.plat:Destroy()
end)
H.plat=nil
end
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if stepBack and h then
pcall(function()
local back=H.pos-look*2
h.CFrame=CFrame.new(back,back+look)
h.AssemblyLinearVelocity=Vector3.zero
end)
end
for d in pairs(cc)do
if d and d.Parent then
pcall(function()
d.CanCollide=true
end)
end
end
if hum and hum.Parent then
pcall(function()
for _,st in ipairs(states)do
hum:SetStateEnabled(st,true)
end
if auto~=nil then
hum.AutoRotate=auto
end
end)
end
_G.__EliteTP2Hold=nil
end
local plat=Instance.new("Part")
plat.Name="ElitePlat"
plat.Size=Vector3.new(4,1,4)
plat.Anchored=true
plat.CanCollide=true
plat.CanQuery=false
plat.CanTouch=false
plat.Transparency=1
plat.Position=Vector3.new(pos.X,pos.Y-3.15,pos.Z)
plat.Parent=workspace
H.plat=plat
_G.__EliteTP2Hold=H
noclip()
pcall(function()
hrp.AssemblyLinearVelocity=Vector3.zero
hrp.AssemblyAngularVelocity=Vector3.zero
hrp.CFrame=CFrame.new(H.pos,H.pos+look)
end)
conn=RunService.Heartbeat:Connect(function()
if _G.EliteTPStop then
H.release(true)
return
end
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not h then
return
end
local d=h.Position-H.pos
if H.pressed and(d:Dot(look)>1 or d.Magnitude>3)then
H.release(false)
return
end
if d.Magnitude>0.5 then
H.pos=h.Position
if not H.pressed then
if not H.pushed then
TP2.log(
"hold: pushed "
..string.format("%.1f",d.Magnitude)
.." studs by the server to "
..v3s(h.Position)
)
end
H.pushed=true
end
end
noclip()
if _G.EliteStableTP==true then
local e=H.pos-h.Position
h.AssemblyLinearVelocity=e*20
h.AssemblyAngularVelocity=Vector3.zero
local okL,lv=pcall(function()
return h.CFrame.LookVector
end)
if okL and lv then
local a=Vector3.new(lv.X,0,lv.Z)
local b=Vector3.new(look.X,0,look.Z)
if a.Magnitude>0.01 and b.Magnitude>0.01 and a.Unit:Dot(b.Unit)<0.985 then
h.CFrame=CFrame.new(h.Position,h.Position+b)
end
end
else
h.AssemblyLinearVelocity=Vector3.zero
h.AssemblyAngularVelocity=Vector3.zero
h.CFrame=CFrame.new(H.pos,H.pos+look)
end
end)
return H
end
local function cloneButton()
local pg=LP:FindFirstChild("PlayerGui")
local tf=pg and pg:FindFirstChild("ToolsFrames")
local qc=tf and tf:FindFirstChild("QuantumCloner")
return qc and qc:FindFirstChild("TeleportToClone")
end
local function cloneRemotes()
if type(getRemote)~="function"then
return nil,nil
end
local okU,useItem=pcall(getRemote,"RemoteEvent","UseItem")
local okT,onTel=pcall(getRemote,"RemoteEvent","QuantumCloner/OnTeleport")
return okU and useItem or nil,okT and onTel or nil
end
local function press(tb)
if not tb then
return
end
tb.Visible=true
for _,sig in ipairs({"MouseButton1Click","MouseButton1Up","Activated"})do
pcall(function()
firesignal(tb[sig])
end)
end
end
function TP2.clone(H)
local c=LP.Character
local h=c and c:FindFirstChildOfClass("Humanoid")
if not h then
return"no character"
end
local cl=LP.Backpack:FindFirstChild("Quantum Cloner")or c:FindFirstChild("Quantum Cloner")
if not cl then
return"no Quantum Cloner in your backpack"
end
pcall(function()
h:UnequipTools()
end)
task.wait()
if cl.Parent~=c then
pcall(function()
h:EquipTool(cl)
end)
task.wait()
end
local tb=cloneButton()
local useItem,onTel=cloneRemotes()
if useItem and onTel then
task.wait((_G.EliteABInstant==true)and 0.03 or 0.045)
_G.isCloning=true
if H then
H.pressed=true
end
local okU=pcall(function()
useItem:FireServer()
end)
task.wait(0.03)
local okT=pcall(function()
onTel:FireServer()
end)
task.delay(0.55,function()
_G.isCloning=false
end)
TP2.log(
"clone: server method (use item ok="..tostring(okU)..", teleport ok="..tostring(okT)..")"
)
if okU and okT then
return"remote"
end
end
if not tb then
return"Teleport To Clone button not found"
end
_G.isCloning=true
local myName=tostring(LP.UserId).."_Clone"
local myHrp=c:FindFirstChild("HumanoidRootPart")
local function rootOf(m)
return m and(m:FindFirstChild("HumanoidRootPart")or m.PrimaryPart)
end
local old=workspace:FindFirstChild(myName)
local oldRoot=rootOf(old)
local oldPos=oldRoot and oldRoot.Position
local function ready()
local now=workspace:FindFirstChild(myName)
if not now then
return false
end
if now~=old then
return true
end
local r=rootOf(now)
if not r then
return false
end
if oldPos and(r.Position-oldPos).Magnitude<1 then
return false
end
return(not myHrp)or(r.Position-myHrp.Position).Magnitude<25
end
pcall(function()
cl:Activate()
end)
local t0=os.clock()
while os.clock()-t0<(tonumber(_G.EliteCloneWait)or 1.0)do
if ready()then
break
end
RunService.Heartbeat:Wait()
end
local seen=ready()
TP2.log(
"clone: button method, clone seen="
..tostring(seen)
.." after "
..string.format("%.2f",os.clock()-t0)
.."s"
)
if H then
H.pressed=true
end
press(tb)
task.delay(0.55,function()
_G.isCloning=false
end)
return seen and"clone"or"noclone"
end
function TP2.pressAgain()
local _,onTel=cloneRemotes()
if onTel then
pcall(function()
onTel:FireServer()
end)
end
press(cloneButton())
end
function TP2.cloneExists()
return workspace:FindFirstChild(tostring(LP.UserId).."_Clone")~=nil
end
function TP2.waitInside(H,look)
local t0,presses=os.clock(),0
while os.clock()-t0<(tonumber(_G.EliteInsideWait)or 1.6)do
if _G.EliteTPStop then
return false
end
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if h and TP2.inBase(h.Position,0.5)then
local mv=h.Position-H.pos
if H.released or mv:Dot(look)>1 or mv.Magnitude>3 then
TP2.log(
"inside: yes after "
..string.format("%.2f",os.clock()-t0)
.."s at "
..v3s(h.Position)
.." (re-sends "
..presses
..")"
)
return true
end
end
local el=os.clock()-t0
local r1,r2=0.3,0.7
if _G.EliteABInstant==true then
r1,r2=0.25,0.55
end
if(presses==0 and el>r1)or(presses==1 and el>r2)then
presses=presses+1
TP2.pressAgain()
end
RunService.Heartbeat:Wait()
end
local hh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
TP2.log(
"inside: NO after "
..string.format("%.2f",os.clock()-t0)
.."s, you are at "
..(hh and v3s(hh.Position)or"?")
..", clone exists="
..tostring(TP2.cloneExists())
)
return false
end
end)()
function eliteSay(...)
pcall(print,...)
end
do
local B={
{1,2,-469.9,-5.52,168.83,-0.49,-0.87,-0.49,-0.11,-0.87},
{1,3,-470.14,-5.52,63.03,-0.45,-0.89,-0.44,-0.19,-0.88},
{1,4,-470.29,-5.52,-43.98,-0.46,-0.89,-0.44,-0.28,-0.85},
{1,5,-378.08,-5.52,220.28,1,-0.01,0.95,-0.3,-0.01},
{1,6,-378.17,-5.52,131.07,1,0,0.9,-0.44,0},
{1,7,-350.33,-5.52,58.39,0.52,-0.86,0.5,-0.21,-0.84},
{1,8,-355.89,-5.52,-47.77,0.64,-0.77,0.62,-0.25,-0.74},
{2,1,-472.34,-5.52,164.48,-0.41,0.91,-0.4,-0.22,0.89},
{2,3,-473.9,-5.52,54.64,-0.51,-0.86,-0.48,-0.32,-0.81},
{2,4,-466.13,-5.52,-45.91,-0.55,-0.83,-0.52,-0.33,-0.79},
{2,5,-377.96,-5.52,198.26,1,0.09,0.96,-0.26,0.09},
{2,6,-378.34,-5.52,112.87,1,0.01,0.92,-0.39,0.01},
{2,7,-368.85,-5.52,47.78,0.77,-0.63,0.76,-0.21,-0.62},
{2,8,-376.72,-5.52,-75.27,0.99,-0.14,0.96,-0.25,-0.14},
{3,1,-471.28,-5.52,164.45,-0.44,0.9,-0.43,-0.2,0.88},
{3,2,-476.19,-5.52,56.52,-0.31,0.95,-0.31,-0.16,0.94},
{3,4,-471.04,-5.52,-43.1,-0.43,-0.9,-0.42,-0.16,-0.89},
{3,5,-377.58,-5.52,189.46,0.96,0.27,0.86,-0.45,0.24},
{3,6,-365.25,-5.52,72.56,0.77,0.64,0.73,-0.32,0.6},
{3,7,-378.83,-5.52,6.06,1,0.01,0.93,-0.36,0.01},
{3,8,-376.81,-5.52,-78.93,1,-0.05,0.96,-0.29,-0.04},
{4,1,-473.6,-5.52,162.3,-0.38,0.93,-0.38,-0.07,0.92},
{4,2,-474.21,-5.52,54.07,-0.34,0.94,-0.33,-0.15,0.93},
{4,3,-473.57,-5.52,-51.36,-0.36,0.93,-0.36,-0.16,0.92},
{4,5,-368.35,-5.52,178.33,0.77,0.63,0.74,-0.29,0.61},
{4,6,-349.17,-5.52,62.13,0.62,0.78,0.58,-0.34,0.73},
{4,7,-377.8,-5.52,-12.51,1,0,0.98,-0.22,0},
{4,8,-378.67,-5.52,-97.77,1,-0.01,0.95,-0.31,-0.01},
{5,1,-441.08,-5.52,222.35,-1,-0.01,-0.91,-0.42,-0.01},
{5,2,-444.08,-5.52,131.28,-1,0,-0.98,-0.21,0},
{5,3,-466.45,-5.52,59.48,-0.58,-0.81,-0.58,-0.12,-0.81},
{5,4,-464.82,-5.52,-47.06,-0.6,-0.8,-0.59,-0.18,-0.79},
{5,6,-343.75,-5.52,167.49,0.38,-0.93,0.37,-0.25,-0.9},
{5,7,-345.56,-5.52,61.85,0.41,-0.91,0.38,-0.39,-0.84},
{5,8,-347.92,-5.52,-43.7,0.43,-0.9,0.42,-0.15,-0.89},
{6,1,-448.42,-5.52,183.43,-0.86,0.52,-0.83,-0.24,0.5},
{6,2,-439.79,-5.52,115.57,-1,-0.03,-0.99,-0.11,-0.03},
{6,3,-448.18,-5.02,47.19,-0.83,-0.55,-0.82,-0.18,-0.54},
{6,4,-470.31,-5.52,-42.44,-0.43,-0.9,-0.42,-0.17,-0.89},
{6,5,-363.99,-5.52,174.97,0.68,0.74,0.65,-0.28,0.71},
{6,7,-343.43,-5.52,62.19,0.35,-0.94,0.32,-0.37,-0.87},
{6,8,-347.34,-5.52,-44.03,0.42,-0.91,0.42,-0.15,-0.9},
{7,1,-442.92,-5.52,188.67,-0.95,0.32,-0.86,-0.41,0.29},
{7,2,-443.67,-5.52,88.51,-0.99,0.15,-0.92,-0.37,0.14},
{7,3,-441.54,-5.52,1.16,-1,0.01,-0.91,-0.42,0.01},
{7,4,-442.67,-5.52,-80.81,-1,0,-0.94,-0.34,0},
{7,5,-346.63,-5.52,172.66,0.52,0.86,0.51,-0.14,0.85},
{7,6,-359.43,-5.52,73.99,0.67,0.74,0.58,-0.49,0.65},
{7,8,-349.76,-5.52,-44.69,0.47,-0.88,0.46,-0.26,-0.85},
{8,1,-451.67,-5.52,177.16,-0.75,0.66,-0.73,-0.25,0.64},
{8,2,-460.96,-5.52,60.5,-0.66,0.75,-0.64,-0.25,0.72},
{8,3,-441.51,-5.52,-12.72,-1,0.02,-0.96,-0.27,0.02},
{8,4,-442.07,-5.52,-101.37,-1,0.02,-0.97,-0.24,0.02},
{8,5,-347.19,-5.52,163.34,0.42,0.91,0.41,-0.22,0.89},
{8,6,-346.32,-5.52,56.84,0.43,0.9,0.42,-0.13,0.9},
{8,7,-345.81,-5.52,-41.66,0.53,0.85,0.5,-0.36,0.79},
}
local BH={
{1,2,-455.95,6.73,156.11,-0.69,-0.73,-0.66,-0.25,-0.71},
{1,3,-465.71,3.89,57.24,-0.62,-0.79,-0.62,-0.08,-0.78},
{1,4,-455.73,5.98,-65.32,-0.74,-0.67,-0.73,-0.2,-0.65},
{1,5,-375.44,7.56,230.29,0.99,0.11,0.98,-0.17,0.11},
{1,6,-371.19,8.66,146.3,0.9,-0.43,0.88,-0.19,-0.43},
{1,7,-349.26,8.41,60.79,0.49,-0.87,0.48,-0.16,-0.86},
{1,8,-363.23,4.95,-60.53,0.7,-0.72,0.69,-0.16,-0.71},
{2,1,-465.76,5.44,169.88,-0.63,0.78,-0.62,-0.2,0.76},
{2,3,-466.27,6.25,56.3,-0.66,-0.75,-0.65,-0.16,-0.74},
{2,4,-452.97,5.98,-67.07,-0.85,-0.52,-0.84,-0.17,-0.51},
{2,5,-373.5,10.71,193.99,0.93,0.37,0.9,-0.26,0.35},
{2,6,-376.1,8.64,100.38,1,0.02,0.96,-0.29,0.02},
{2,7,-371.72,8.05,36.14,0.91,-0.42,0.9,-0.16,-0.41},
{2,8,-364.17,2.95,-63.94,0.79,-0.62,0.79,-0.03,-0.62},
{3,1,-465.26,3.7,171.4,-0.67,0.75,-0.66,-0.13,0.74},
{3,2,-467.85,5.17,60.73,-0.56,0.83,-0.56,-0.13,0.82},
{3,4,-452.41,5.98,-67.35,-0.85,-0.52,-0.84,-0.17,-0.51},
{3,5,-350.67,1.95,170.57,0.57,0.82,0.57,-0.1,0.82},
{3,6,-356.61,6.79,66.2,0.72,0.69,0.71,-0.18,0.68},
{3,7,-375.04,6.08,4.59,1,-0.04,1,-0.06,-0.04},
{3,8,-370.18,4.19,-67.48,0.89,-0.45,0.88,-0.17,-0.45},
{4,1,-468.31,6.38,170.95,-0.67,0.74,-0.66,-0.2,0.72},
{4,2,-467.09,4.53,64.91,-0.67,0.74,-0.66,-0.16,0.73},
{4,3,-466.68,7.63,-44.7,-0.61,0.79,-0.58,-0.27,0.76},
{4,5,-367.15,8.38,183.82,0.79,0.61,0.78,-0.14,0.61},
{4,6,-355.1,6.61,63.74,0.66,0.75,0.65,-0.23,0.73},
{4,7,-375.4,9.57,-17.93,0.98,0.2,0.95,-0.25,0.19},
{4,8,-371.89,5.8,-93.09,1,0.09,0.98,-0.16,0.09},
{5,1,-443.5,7.63,212.69,-1,0,-0.97,-0.26,0},
{5,2,-445.51,6.13,137.64,-0.96,-0.28,-0.94,-0.21,-0.28},
{5,3,-447.7,6.92,36.55,-0.92,-0.4,-0.91,-0.14,-0.4},
{5,4,-451.73,3.98,-65.59,-0.82,-0.57,-0.82,-0.13,-0.56},
{5,6,-360.94,8.35,156.58,0.62,-0.78,0.6,-0.27,-0.75},
{5,7,-362,6.46,47.88,0.67,-0.74,0.66,-0.19,-0.73},
{5,8,-359.32,4.95,-61.47,0.65,-0.76,0.65,-0.06,-0.76},
{6,1,-445.05,8.81,213.67,-0.98,-0.21,-0.95,-0.26,-0.2},
{6,2,-444.35,5.94,137.83,-0.98,-0.21,-0.96,-0.2,-0.2},
{6,3,-447.64,6.93,32.31,-0.97,-0.26,-0.94,-0.24,-0.25},
{6,4,-454.97,5.98,-64.84,-0.78,-0.62,-0.77,-0.19,-0.61},
{6,5,-345.29,4.76,166.21,0.41,0.91,0.4,-0.17,0.9},
{6,7,-345.94,6.59,61.46,0.46,-0.89,0.45,-0.23,-0.86},
{6,8,-362.46,2.95,-59.46,0.69,-0.73,0.68,-0.11,-0.72},
{7,1,-454.21,6.38,191.37,-0.91,0.42,-0.9,-0.12,0.42},
{7,2,-451.23,7.48,86.9,-0.93,0.36,-0.9,-0.25,0.35},
{7,3,-448.36,11.06,9.09,-0.95,0.3,-0.92,-0.25,0.29},
{7,4,-450.92,6.25,-68.03,-0.89,-0.46,-0.88,-0.14,-0.46},
{7,5,-348.36,-0.52,173.83,0.62,0.79,0.62,0.06,0.78},
{7,6,-347.54,1.48,63.66,0.49,0.87,0.49,-0.05,0.87},
{7,8,-347.67,8.17,-49.23,0.43,-0.9,0.42,-0.22,-0.88},
{8,1,-461.63,5.15,176.89,-0.78,0.62,-0.78,-0.1,0.62},
{8,2,-464.03,11.88,58.95,-0.55,0.84,-0.52,-0.3,0.8},
{8,3,-445.7,10.08,-21.84,-0.95,0.32,-0.93,-0.19,0.31},
{8,4,-448.13,5.94,-106.2,-0.99,-0.15,-0.98,-0.17,-0.15},
{8,5,-354.9,6.71,171.8,0.68,0.73,0.67,-0.17,0.72},
{8,6,-353.44,3.4,63.65,0.62,0.78,0.62,-0.07,0.78},
{8,7,-350.33,4.01,-43.88,0.62,0.79,0.61,-0.14,0.78},
}
function eliteFlashSpot(petPos,upper)
local list=_G.__EliteFlashCache
if type(list)~="table"or os.clock()-(tonumber(_G.__EliteFlashCacheAt)or 0)>15 then
list=nil
pcall(function()
list=game:GetService("HttpService"):JSONDecode(readfile("elite_flash_pos.json"))
end)
_G.__EliteFlashCache,_G.__EliteFlashCacheAt=list,os.clock()
end
if type(list)~="table"then list=_G.EliteFlashPos end
if type(list)~="table"then list={}end
if upper==true then
local hl=_G.__EliteFlashHiCache
if type(hl)~="table"or os.clock()-(tonumber(_G.__EliteFlashHiCacheAt)or 0)>15 then
hl=nil
pcall(function()
hl=game:GetService("HttpService"):JSONDecode(readfile("elite_flash_pos_high.json"))
end)
_G.__EliteFlashHiCache,_G.__EliteFlashHiCacheAt=hl,os.clock()
end
if type(hl)=="table"and#hl>0 then
local all={}
for _,e in ipairs(hl)do all[#all+1]=e end
for _,e in ipairs(list)do all[#all+1]=e end
list=all
end
end
local myIdx
pcall(function()
local plots=workspace:FindFirstChild("Plots")
local mp=_G.EliteMyPlot or _G.__SXE_MyPlot
local mine=plots and mp and plots:FindFirstChild(mp)
if mine then myIdx=getClosestBaseIdx(mine:GetPivot().Position)end
end)
if not myIdx then return nil end
local tIdx=getClosestBaseIdx(petPos)
local function pick(want)
for _,e in ipairs(list)do
if e.my==myIdx and e.target==tIdx and(e.upper==true)==want
and type(e.pos)=="table"and type(e.look)=="table"then
local cam=type(e.cam)=="table"and Vector3.new(e.cam[1],e.cam[2],e.cam[3])or nil
return Vector3.new(e.pos[1],e.pos[2],e.pos[3]),Vector3.new(e.look[1],0,e.look[2]),cam
end
end
do
for _,r in ipairs(want and BH or B)do
if r[1]==myIdx and r[2]==tIdx then
return Vector3.new(r[3],r[4],r[5]),Vector3.new(r[6],0,r[7]),Vector3.new(r[8],r[9],r[10])
end
end
end
return nil
end
local pos,look,cam=pick(upper==true)
if not pos then
eliteSay("[FLASH] my base "..myIdx.." -> base "..tIdx..": "..(upper==true and"no HIGH spot"or"no saved spot")..", using normal TP spot")
return nil
end
if look.Magnitude>0.01 then
pos=pos+look.Unit*(tonumber(_G.EliteFlashForward)or 3)
end
local b=BASES_LOW[tIdx]
if look.Magnitude>0.01 and b and((pos.X-b.X)^2+(pos.Z-b.Z)^2)<=70*70 then
eliteSay("[FLASH] my base "..myIdx.." -> base "..tIdx..": using your "..(upper==true and"HIGH"or"LOW").." spot")
_G.__EliteFlashPair=myIdx.."->"..tIdx..(upper==true and" HIGH"or" LOW")
return pos,look.Unit,cam
end
eliteSay("[FLASH] my base "..myIdx.." -> base "..tIdx..": saved spot too far from that base, using normal TP spot")
return nil
end
end
function eliteFlashAimStop()
local saved=_G.__EliteFlashCamOld
_G.__EliteFlashCamOld=nil
local cam=workspace.CurrentCamera
if saved and cam then
pcall(function()
cam.CameraType=saved[1]
cam.CFrame=saved[2]
end)
end
end
function eliteFlashCamPos(dir)
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not h then return workspace.CurrentCamera.CFrame.Position end
local head=h.Position+Vector3.new(0,1.5,0)
local dist=_G.__EliteFlashCamD
if not dist then
local want=tonumber(_G.EliteFlashCamDist)or 10
dist=want
pcall(function()
local rp=RaycastParams.new()
rp.FilterType=Enum.RaycastFilterType.Exclude
local skip={}
for _,pl in ipairs(Players:GetPlayers())do
if pl.Character then
skip[#skip+1]=pl.Character
end
end
for _=1,8 do
rp.FilterDescendantsInstances=skip
local hit=workspace:Raycast(head,-dir*want,rp)
if not hit then
break
end
local p=hit.Instance
if p and p:IsA("BasePart")and not p.CanCollide and p.Transparency>=0.9 then
skip[#skip+1]=p
else
dist=math.max(1.5,(hit.Position-head).Magnitude-0.6)
break
end
end
end)
_G.__EliteFlashCamD=dist
end
return head-dir*dist
end
function eliteFlashAimStart(look,camLook)
if not _G.__EliteFlashCamOld then
_G.__EliteFlashCamD=nil
end
local d=(typeof(camLook)=="Vector3"and camLook)or(typeof(look)=="Vector3"and look)or nil
local dir=d and Vector3.new(d.X,0,d.Z)
local cam=workspace.CurrentCamera
if not(cam and dir and dir.Magnitude>0.01)then return end
local token={}
if not _G.__EliteFlashCamOld then
_G.__EliteFlashCamOld={cam.CameraType,cam.CFrame,token}
end
local from=eliteFlashCamPos(dir.Unit)
pcall(function()
cam.CameraType=Enum.CameraType.Scriptable
cam.CFrame=CFrame.lookAt(from,from+dir.Unit)
end)
task.delay(4,function()
local s=_G.__EliteFlashCamOld
if s and s[3]==token then eliteFlashAimStop()end
end)
end
function eliteFlashIn(look,camLook,spot,high)
_G.__EliteFlashCamD=nil
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if not(hum and hrp)then return false end
local tool=char:FindFirstChild("Flash Teleport")
or(LP:FindFirstChild("Backpack")and LP.Backpack:FindFirstChild("Flash Teleport"))
if not tool then
for _,holder in ipairs({char,LP:FindFirstChild("Backpack")})do
if holder and not tool then
for _,t in ipairs(holder:GetChildren())do
local n=string.lower(t.Name)
if t:IsA("Tool")and string.find(n,"flash",1,true)and string.find(n,"tele",1,true)then
tool=t
break
end
end
end
end
end
if not tool then return"notool"end
local RS=game:GetService("RunService")
local d=(typeof(camLook)=="Vector3"and camLook)or(typeof(look)=="Vector3"and look)or nil
local dir=d and Vector3.new(d.X,0,d.Z)
dir=(dir and dir.Magnitude>0.01)and dir.Unit or nil
local face=typeof(look)=="Vector3"and Vector3.new(look.X,0,look.Z)or nil
if face and face.Magnitude>0.01 then
pcall(function()
hum.AutoRotate=false
hrp.CFrame=CFrame.new(hrp.Position,hrp.Position+face.Unit)
end)
end
local function equip()
if tool.Parent~=LP.Character then
pcall(function()hum:EquipTool(tool)end)
_G.__EliteFlashEquipAt=os.clock()
local t0=os.clock()
while tool.Parent~=LP.Character and os.clock()-t0<1 do RS.Heartbeat:Wait()end
end
end
local cam=workspace.CurrentCamera
local saved=_G.__EliteFlashCamOld
local oldType=(saved and saved[1])or(cam and cam.CameraType)
local oldCF=(saved and saved[2])or(cam and cam.CFrame)
local _pressed=false
local function pin()
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if h and typeof(spot)=="Vector3"then
local off=h.Position-spot
local flat=Vector3.new(off.X,0,off.Z).Magnitude
if(flat>1.5 or math.abs(off.Y)>3)and off.Magnitude<=6 then
local fw=(face and face.Magnitude>0.01)and face.Unit or h.CFrame.LookVector
h.CFrame=CFrame.new(spot,spot+fw)
h.AssemblyLinearVelocity=Vector3.zero
h.AssemblyAngularVelocity=Vector3.zero
end
end
if cam and dir then
cam.CameraType=Enum.CameraType.Scriptable
local cf=eliteFlashCamPos(dir)
cam.CFrame=CFrame.lookAt(cf,cf+dir)
end
end
local function unpin()
_G.__EliteFlashCamOld=nil
pcall(function()
local h2=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if h2 then
h2.AutoRotate=true
end
end)
if cam and dir then
pcall(function()
cam.CameraType=oldType
cam.CFrame=oldCF
end)
end
end
local from=hrp.Position
local deadline=os.clock()+(tonumber(_G.EliteFlashMaxWait)or 5)
local ok=false
equip()
pcall(pin)
do
local since=os.clock()-(tonumber(_G.__EliteFlashEquipAt)or 0)
if since<0.05 then task.wait(0.05-since)end
end
local handle=tool:FindFirstChild("Handle")
local errS=handle and handle:FindFirstChild("ErrorSound")
local recS=handle and handle:FindFirstChild("RechargeSound")
local gotErr,ready=false,false
local c1=errS and errS.Played:Connect(function()gotErr=true end)
local c2=recS and recS.Played:Connect(function()ready=true end)
local _fp
local function makePad()
if _fp or typeof(spot)~="Vector3"or _G.EliteFlashPlatform==false then
return
end
pcall(function()
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local hm=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
local feet=spot.Y-(h and h.Size.Y/2 or 1)-(hm and hm.HipHeight or 2)
_fp=Instance.new("Part")
_fp.Name="EliteFlashPad"
_fp.Size=Vector3.new(6,1,6)
_fp.Anchored=true
_fp.CanCollide=true
_fp.Transparency=1
_fp.CFrame=CFrame.new(spot.X,feet-0.5,spot.Z)
_fp.Parent=workspace
end)
local fp=_fp
task.delay(10,function()if fp and fp.Parent then pcall(function()fp:Destroy()end)end end)
end
do
local hm0=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if high or(hm0 and hm0.FloorMaterial==Enum.Material.Air)then
makePad()
end
end
do
local hm=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
local tg=os.clock()
if hm and hm.FloorMaterial==Enum.Material.Air then
pcall(function()
hm:ChangeState(Enum.HumanoidStateType.Landed)
end)
end
while hm and hm.FloorMaterial==Enum.Material.Air and os.clock()-tg<(tonumber(_G.EliteFlashGroundWait)or 0.12)do
pcall(pin)
RS.Heartbeat:Wait()
end
end
local teleS=handle and handle:FindFirstChild("TeleportSound")
local going=false
local c3=teleS and teleS.Played:Connect(function()going=true end)
local function moved()
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
return h~=nil and(h.Position-from).Magnitude>4
end
local tStart,presses,waitedRecharge=os.clock(),0,false
local _nothing=0
while os.clock()<deadline and not ok do
if tool.Parent~=LP.Character then equip()end
pcall(pin)
gotErr,going=false,false
pcall(function()
local hm=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hm then
hm.Jump=false
if hm.Sit then
hm.Sit=false
end
if hm.PlatformStand then
hm.PlatformStand=false
end
end
end)
if tool.Enabled==false then
local te=os.clock()
while tool.Enabled==false and os.clock()<deadline and os.clock()-te<2 do
pcall(pin)
RS.Heartbeat:Wait()
end
end
presses=presses+1
_pressed=true
pcall(function()tool:Activate()end)
local t0=os.clock()
while os.clock()<deadline do
RS.Heartbeat:Wait()
if moved()then ok=true break end
pcall(pin)
if gotErr then break end
if not going and os.clock()-t0>=(tonumber(_G.EliteFlashRetry)or 0.3)then break end
if going and os.clock()-t0>=1.5 then break end
end
if not ok and not gotErr and not going then
local hm=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
eliteSay(string.format("[FLASH] press %d did nothing (tool %s, %s)",presses,
tool.Enabled==false and"disabled"or"ready",(hm and hm.FloorMaterial~=Enum.Material.Air)and"on ground"or"in air"))
_nothing=_nothing+1
if hm and hm.FloorMaterial==Enum.Material.Air then
makePad()
end
if _nothing==2 and _G.EliteFlashReequip~=false then
pcall(function()
local hm2=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if hm2 then
hm2:UnequipTools()
end
end)
RS.Heartbeat:Wait()
equip()
task.wait(0.08)
eliteSay("[FLASH] re-equipped Flash Teleport to reset it")
end
if _nothing>=(tonumber(_G.EliteFlashMaxTries)or 4)then
eliteSay("[FLASH] gave up after ".._nothing.." presses - letting you go")
break
end
end
if not ok and gotErr then
waitedRecharge=true
ready=false
while not ready and os.clock()<deadline do
if moved()then ok=true break end
pcall(pin)
RS.Heartbeat:Wait()
end
end
end
if c3 then c3:Disconnect()end
if c1 then c1:Disconnect()end
if c2 then c2:Disconnect()end
_G.__EliteFlashCamD=nil
eliteSay(string.format("[FLASH] %s after %.2fs, %d press%s%s",ok and"flashed"or"FAILED",os.clock()-tStart,
presses,presses==1 and""or"es",waitedRecharge and" (was recharging)"or""))
if not ok then
pcall(function()
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local hm=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
local st=hm and(tostring(hm:GetState()):gsub("Enum.HumanoidStateType.",""))or"?"
local line=string.format("%s | pair %s | presses %d | did-nothing %d | recharging %s | tool %s in %s | %s | state %s | from spot %.1f | ping %dms",
os.date("%H:%M:%S"),tostring(_G.__EliteFlashPair),presses,_nothing,tostring(waitedRecharge),
tool.Enabled==false and"disabled"or"enabled",tostring(tool.Parent and tool.Parent.Name),
(hm and hm.FloorMaterial~=Enum.Material.Air)and"on ground"or"in air",st,
(h and typeof(spot)=="Vector3")and(h.Position-spot).Magnitude or-1,
math.floor((LP:GetNetworkPing()or 0)*1000))
local old=""
pcall(function()
old=readfile("EliteFlash_fails.txt")
end)
writefile("EliteFlash_fails.txt",(old..line.."\n"):sub(-6000))
eliteSay("[FLASH] saved this fail to EliteFlash_fails.txt")
end)
end
if _fp then pcall(function()_fp:Destroy()end)end
unpin()
return ok
end
function eliteFlashCleanup()
pcall(function()
local cam=workspace.CurrentCamera
if cam and cam.CameraType==Enum.CameraType.Scriptable then
cam.CameraType=Enum.CameraType.Custom
end
local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if h then
h.AutoRotate=true
end
end)
_G.__EliteFlashCamOld=nil
end
function doClone()
local char=LP.Character or LP.CharacterAdded:Wait()
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not char or not hum then
return false
end
local cloner=(LP:FindFirstChild("Backpack")and LP.Backpack:FindFirstChild("Quantum Cloner"))
or char:FindFirstChild("Quantum Cloner")
if not cloner then
return false
end
if cloner.Parent~=char then
pcall(function()
hum:EquipTool(cloner)
end)
task.wait(0.06)
end
local useItem=getRemote("RemoteEvent","UseItem")
local onTel=getRemote("RemoteEvent","QuantumCloner/OnTeleport")
if not useItem or not onTel then
return false
end
_G.isCloning=true
local useOk=pcall(function()
useItem:FireServer()
end)
task.wait(0.03)
local telOk=pcall(function()
onTel:FireServer()
end)
task.wait(0.18)
pcall(function()
hum:UnequipTools()
end)
task.delay(0.4,function()
_G.isCloning=false
end)
return useOk and telOk
end
function _makeOneWay(plat)
if not plat then
return
end
local rsConn
local lastY=nil
rsConn=RunService.Stepped:Connect(function()
if not plat or not plat.Parent then
if rsConn then
rsConn:Disconnect()
end
return
end
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hrp then
local currentY=hrp.Position.Y
if not lastY then
lastY=currentY
end
local deltaY=currentY-lastY
local isMovingUp=(hrp.AssemblyLinearVelocity.Y>(tonumber(_G.ElitePlatUpVel)or 8))or(deltaY>0.25 and deltaY<5)
if isMovingUp then
plat.CanCollide=false
else
plat.CanCollide=(currentY>plat.Position.Y+0.1)
end
lastY=currentY
end
end)
end
function carpetEngageFast()
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not char or not hum then
return nil
end
if not char:FindFirstChild("Grapple Hook")then
local g=findTool("Grapple Hook")
if g then
pcall(function()
hum:EquipTool(g)
end)
end
end
local _t=os.clock()
while
not(LP.Character and LP.Character:FindFirstChild("Grapple Hook"))
and os.clock()-_t<(tonumber(_G.EliteGoGrappleWait)or 0.35)
do
local c=LP.Character
local h=c and c:FindFirstChildOfClass("Humanoid")
local g=findTool("Grapple Hook")
if g and h then
pcall(function()
h:EquipTool(g)
end)
end
RunService.Heartbeat:Wait()
end
if LP.Character and LP.Character:FindFirstChild("Grapple Hook")then
_fireGrapple()
end
if _G.EliteGrappleUnequip==true then
local h2=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if h2 then
pcall(function()
h2:UnequipTools()
end)
end
RunService.Heartbeat:Wait()
end
local cn
local _t2=os.clock()
repeat
cn=equipCarpet()
local c=LP.Character
if cn and c and c:FindFirstChild(cn)then
break
end
RunService.Heartbeat:Wait()
until os.clock()-_t2>(tonumber(_G.EliteGoCarpetWait)or 2)
return cn
end
_G.EliteCarpetEngageFast=carpetEngageFast
function goToBrainrot(petPos,slot)
if not petPos then
return
end
local char,hrp,hum
local _t0=os.clock()
repeat
char=LP.Character
hrp=char and char:FindFirstChild("HumanoidRootPart")
hum=char and char:FindFirstChildOfClass("Humanoid")
if hrp and hum then
break
end
RunService.Heartbeat:Wait()
until os.clock()-_t0>3
if not hrp or not hum then
return
end
pcall(function()
hrp.Anchored=false
end)
local _equipped=false
do
for _,_cn in ipairs(CARPET_NAMES)do
if char and char:FindFirstChild(_cn)then
_equipped=true
break
end
end
local _gd=(petPos and hrp and hrp.Parent)and(petPos-hrp.Position).Magnitude or math.huge
local _gmin=tonumber(_G.EliteGoGrappleMin)or 100
if not _equipped and _G.EliteGoGrapple~=false and _gd>_gmin then
pcall(carpetEngageFast)
char=LP.Character
for _,_cn in ipairs(CARPET_NAMES)do
if char and char:FindFirstChild(_cn)then
_equipped=true
break
end
end
end
local _e0=os.clock()
while not _equipped and os.clock()-_e0<=(tonumber(_G.EliteGoCarpetWait)or 3)do
char=LP.Character
for _,_cn in ipairs(CARPET_NAMES)do
if char and char:FindFirstChild(_cn)then
_equipped=true
break
end
end
if _equipped then
break
end
equipCarpet()
RunService.Heartbeat:Wait()
end
if _equipped then
task.wait(tonumber(_G.EliteGoCarpetSettle)or 0.02)
end
end
char=LP.Character
hrp=char and char:FindFirstChild("HumanoidRootPart")
hum=char and char:FindFirstChildOfClass("Humanoid")
if not hrp then
return
end
pcall(function()
hrp.Anchored=false
end)
local _plotRad=(petPos.Y<=8.9)and 26 or 25
do
local _t0b=os.clock()
repeat
local p=hrp.Position
local inRad=false
local plotsFolder=workspace:FindFirstChild("Plots")
if plotsFolder then
for _,plot in ipairs(plotsFolder:GetChildren())do
pcall(function()
local pp=plot:GetPivot().Position
if math.abs(p.X-pp.X)<_plotRad and math.abs(p.Z-pp.Z)<_plotRad then
inRad=true
end
end)
if inRad then
break
end
end
end
if inRad then
break
end
RunService.Heartbeat:Wait()
until os.clock()-_t0b>(tonumber(_G.EliteGoPlotWait)or 0.15)
end
local h=petPos.Y
pcall(function()
hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
end)
local _wentUnder=false
local _slot=tonumber(slot)
local _under=tonumber(_G.EliteUnderOffset)or 6
local targetY=hrp.Position.Y
if(_slot and _slot>=19)or(not _slot and h>23.15)then
targetY=h-(tonumber(_G.EliteUnderOffset3)or 4)
_wentUnder=true
elseif(_slot and _slot>=11)or(not _slot and h>=11 and h<=23.15)then
targetY=h-(tonumber(_G.EliteUnderOffset2)or 3.5)
_wentUnder=true
elseif(_slot and _slot>=1)or(not _slot and h>=-6.9 and h<=8.9)then
targetY=tonumber(_G.EliteFloor1Y)or-4
if _G.EliteFloor1Platform~=false then
_wentUnder=true
end
else
targetY=h-_under
_wentUnder=true
end
local _to=Vector3.new(petPos.X,targetY,petPos.Z)
if hrp and hrp.Parent then
do
local _goSpeed=tonumber(_G.EliteGoSpeed)or 400
local _s1=tonumber(_G.EliteGoGlideSpeed1)or(_goSpeed*0.375)
local _t1=tonumber(_G.EliteGoGlideTime1)or 0.03
local _s2=tonumber(_G.EliteGoGlideSpeed2)or _goSpeed
local _cap=tonumber(_G.EliteGoGlideMax)or 2.5
local _g0=os.clock()
local _lastJump=0
local _bestD,_bestAt=math.huge,os.clock()
local _flatFirst=_wentUnder
and _G.EliteGoFlatFirst~=false
and hrp
and hrp.Parent
and(_to.Y-hrp.Position.Y)>6
while os.clock()-_g0<_cap do
if not(hrp and hrp.Parent)then
break
end
if LP:GetAttribute("Stealing")or _G.EliteTPStop then
break
end
local d=_to-hrp.Position
if _flatFirst then
d=Vector3.new(d.X,0,d.Z)
if d.Magnitude<=2 then
break
end
elseif d.Magnitude<=3 then
break
end
if d.Magnitude<_bestD-0.5 then
_bestD,_bestAt=d.Magnitude,os.clock()
elseif os.clock()-_bestAt>(tonumber(_G.EliteGoStallTime)or 0.2)then
break
end
equipCarpet()
if _G.EliteGoJump==true and d.Magnitude>15 and(os.clock()-_lastJump)>0.5 then
local _gh=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
if _gh then
pcall(function()
_gh:ChangeState(Enum.HumanoidStateType.Jumping)
end)
pcall(function()
_gh.Jump=true
end)
_lastJump=os.clock()
end
end
if _G.EliteGoZeroEachFrame~=false then
pcall(function()
hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
end)
end
local _gs=((os.clock()-_g0)<_t1)and _s1 or _s2
if _G.EliteEaseIn~=false then
_gs=math.min(
_gs,
math.max(
tonumber(_G.EliteGoArriveMin)or 150,
d.Magnitude*(tonumber(_G.EliteGoArriveGain)or 30)
)
)
end
local _v=d.Unit*_gs
if _G.EliteGoNoRise~=false and hrp.Position.Y>=_to.Y-0.5 and _v.Y>0 then
_v=Vector3.new(_v.X,0,_v.Z)
end
_setFlightVel(hrp,_v)
RunService.Heartbeat:Wait()
end
end
local _snapCF=CFrame.new(_to)*(hrp.CFrame-hrp.CFrame.Position)
pcall(function()
hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
hrp.CFrame=_snapCF
end)
for _=1,(tonumber(_G.EliteSnapHoldFrames)or 8)do
RunService.Heartbeat:Wait()
if not(hrp and hrp.Parent)then
break
end
if(hrp.Position-_to).Magnitude>4 then
pcall(function()
hrp.CFrame=_snapCF
end)
end
end
end
if _wentUnder and _G.ElitePlatform~=false then
local _platPos=(hrp and hrp.Parent and hrp.Position)or _to
local _feetY=_platPos.Y-3
local _sz=tonumber(_G.ElitePlatSize)or 4
local _old=workspace:FindFirstChild(EN("ElitePlat"))
if _old then
pcall(function()
_old:Destroy()
end)
end
local _plat=Instance.new("Part")
_plat.Name=EN("ElitePlat")
_plat.Size=Vector3.new(_sz,1,_sz)
_plat.Position=Vector3.new(petPos.X,_feetY-(tonumber(_G.ElitePlatDrop)or 1.5),petPos.Z)
_plat.Anchored=true
_plat.CanCollide=false
pcall(_makeOneWay,_plat)
_plat.Transparency=1
_plat.Material=Enum.Material.SmoothPlastic
_plat.Parent=workspace
task.spawn(function()
local _s=tick()
while tick()-_s<(tonumber(_G.ElitePlatLife)or 20)do
if LP:GetAttribute("Stealing")then
break
end
task.wait(0.1)
end
if _plat and _plat.Parent then
_plat:Destroy()
end
end)
end
end
_Stats=game:GetService("Stats")
function _pingMs()
local ok,p=pcall(function()
return LP:GetNetworkPing()*1000
end)
if ok and type(p)=="number"and p>0 then
return p
end
local ok2,p2=pcall(function()
return _Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
end)
if ok2 and type(p2)=="number"and p2>0 then
return p2
end
return 0
end
_G.ElitePingMs=_pingMs
function _pingAdjustSpeed(spd)
local thresh=tonumber(_G.ElitePingThresh)or 170
local capped=tonumber(_G.EliteHighPingSpeed)or 400
if _pingMs()>=thresh and spd>capped then
return capped
end
return spd
end
function _inVoid(hrp)
if not hrp or not hrp.Parent then
return true
end
local voidY=tonumber(_G.EliteVoidY)or-50
return hrp.Position.Y<voidY
end
function _waitOutOfVoid(timeout)
local t0=os.clock()
local good=0
while os.clock()-t0<(timeout or 12)do
if _G.EliteTPStop then
return false
end
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hrp and hrp.Parent and not _inVoid(hrp)and math.abs(hrp.AssemblyLinearVelocity.Y)<12 then
good=good+1
if good>=4 then
return true
end
else
good=0
end
RunService.Heartbeat:Wait()
end
return false
end
do
local lastSafe=nil
local lastGround=nil
local recovering=false
local _voidTick=0
local _recAt,_recN=0,0
local _vrp=RaycastParams.new()
_vrp.FilterType=Enum.RaycastFilterType.Exclude
_vrp.IgnoreWater=true
local function _floorUnder(p)
if not p then
return false
end
local c=LP.Character
_vrp.FilterDescendantsInstances=c and{c}or{}
local r=workspace:Raycast(p+Vector3.new(0,3,0),Vector3.new(0,-16,0),_vrp)
return r~=nil and r.Instance~=nil and r.Instance.CanCollide==true
end
RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
_voidTick=_voidTick+1
if _voidTick<2 then
return
end
_voidTick=0
if _G.EliteVoidRecover==false then
return
end
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if not hrp or not hrp.Parent then
return
end
local voidY=tonumber(_G.EliteVoidY)or-50
if hrp.Position.Y>=voidY then
if math.abs(hrp.AssemblyLinearVelocity.Y)<40 then
lastSafe=hrp.Position
end
local _gh=char:FindFirstChildOfClass("Humanoid")
if _gh and _gh.FloorMaterial~=Enum.Material.Air then
lastGround=hrp.Position
end
return
end
if recovering or not lastSafe then
return
end
local _now=os.clock()
if _now-_recAt<6 then
_recN=_recN+1
else
_recN=1
end
_recAt=_now
if _recN>=2 or not _floorUnder(lastSafe)then
local _gOk=lastGround
and Vector3.new(lastGround.X-lastSafe.X,0,lastGround.Z-lastSafe.Z).Magnitude<=60
and _floorUnder(lastGround)
if _gOk then
lastSafe=lastGround
elseif _recN>=2 then
return
end
end
recovering=true
pcall(function()
_vzL(hrp)
_vzA(hrp)
hrp.CFrame=CFrame.new(lastSafe+Vector3.new(0,5,0))
end)
task.spawn(function()
local delay=tonumber(_G.EliteVoidRecoverDelay)or 0
if delay>0 then
task.wait(delay)
end
local vy=tonumber(_G.EliteVoidY)or-50
local tries=0
while tries<80 do
local c=LP.Character
local h=c and c:FindFirstChild("HumanoidRootPart")
if not h or not h.Parent then
break
end
if h.Position.Y>=vy and math.abs(h.AssemblyLinearVelocity.Y)<18 then
break
end
if lastSafe then
pcall(function()
_vzL(h)
_vzA(h)
h.CFrame=CFrame.new(lastSafe+Vector3.new(0,5,0))
end)
end
tries=tries+1
RunService.Heartbeat:Wait()
end
recovering=false
end)
end))
end
isTeleporting=false
task.spawn(function()
local _since=nil
while true do
task.wait(1)
if isTeleporting then
_since=_since or os.clock()
if os.clock()-_since>(tonumber(_G.EliteTPWatchdog)or 25)then
isTeleporting=false
_G.EliteStealHold=false
_since=nil
if _G.EliteTPDebug==true then
end
end
else
_since=nil
end
end
end)
_G.EliteDoClone=doClone
_G.EliteIsTeleporting=function()
return isTeleporting
end
function doVelocityTP(forceGrapple)
local ok,err=pcall(_doVelocityTPRaw,forceGrapple)
_G.__EliteFlashFlight=false
_G.__EliteFlashNearFn=nil
_G.__EliteFlashHolding=false
if eliteFlashAimStop then
pcall(eliteFlashAimStop)
end
if _G.__EliteFlashTPAt and eliteFlashCleanup then
pcall(eliteFlashCleanup)
end
if not ok then
isTeleporting=false
_G.EliteStealHold=false
_G.EliteLastTPError=tostring(err)
pcall(function()
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if hrp then
hrp.AssemblyLinearVelocity=Vector3.zero
hrp.AssemblyAngularVelocity=Vector3.zero
end
end)
pcall(_tpStage,"error: "..tostring(err):sub(1,60))
end
return ok
end
function _isStraightRoute(fromPos,route)
if not route or#route<=1 then
return true
end
local turns,lastDir,prev=0,nil,fromPos
for _,wp in ipairs(route)do
local seg=wp-prev
if seg.Magnitude>1 then
local dir=seg.Unit
if lastDir and dir:Dot(lastDir)<0.94 then
turns=turns+1
end
lastDir=dir
end
prev=wp
end
return turns<=(tonumber(_G.EliteStraightMaxTurns)or 1)
end
local _eliteAnimRestoreAt=0
local function restoreAnimations()
_eliteAnimRestoreAt=os.clock()+3
task.spawn(function()
local char=LP.Character
if not char then
return
end
local hum=char:FindFirstChildOfClass("Humanoid")
local animate=char:FindFirstChild("Animate")
if animate then
pcall(function()
animate.Disabled=false
end)
end
if hum then
pcall(function()
hum.AutoRotate=true
end)
local animator=hum:FindFirstChildOfClass("Animator")
if animator then
pcall(function()
local tracks=animator:GetPlayingAnimationTracks()
if tracks then
for _,t in ipairs(tracks)do
if
t.Priority==Enum.AnimationPriority.Core
or t.Priority==Enum.AnimationPriority.Idle
then
pcall(function()
t:Play(0.1)
end)
end
end
end
end)
end
end
end)
end
function _tpStage(name)
_G.EliteTPStage=name
_G.EliteTPStageAt=os.clock()
end
function _doVelocityTPRaw(forceGrapple)
if isTeleporting then
return
end
_G.__EliteLastTPTween=false
_G.__EliteLastTPFlash=false
_G.__EliteFlashTPAt=nil
if forceGrapple and _G.EliteCarpetEngaging and _G.EliteCarpetEngaging()then
local _t0g=os.clock()
repeat
RunService.Heartbeat:Wait()
until not _G.EliteCarpetEngaging()or os.clock()-_t0g>3
end
if
forceGrapple
and _G.__EliteGrappleAt
and(os.clock()-_G.__EliteGrappleAt)<(tonumber(_G.EliteGrappleFresh)or 6)
then
forceGrapple=false
end
if LP:GetAttribute("Stealing")==true then
return
end
isTeleporting=true
if _G.EliteDisarmSteal then
_G.EliteDisarmSteal()
end
_G.EliteTPStop=false
clearViz()
if not NetModule then
pcall(loadNet)
end
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then
isTeleporting=false
return
end
pcall(function()
hrp.AssemblyLinearVelocity=Vector3.new(0,0,0)
hrp.AssemblyAngularVelocity=Vector3.new(0,0,0)
end)
if forceGrapple or _G.EliteAlwaysGrapple~=false then
pcall(fireGrapple)
end
if _inVoid(hrp)then
if _G.EliteTPStop then
isTeleporting=false
return
end
char=LP.Character
hrp=char and char:FindFirstChild("HumanoidRootPart")
hum=char and char:FindFirstChildOfClass("Humanoid")
if not hrp or not hum then
isTeleporting=false
return
end
end
_tpStage("scanning")
local allPets=scanForTP()
if#allPets==0 then
local _t0=os.clock()
while#allPets==0 and os.clock()-_t0<(tonumber(_G.EliteTPScanWait)or 3)do
task.wait(0.03)
allPets=scanForTP()
end
end
if#allPets==0 then
isTeleporting=false
return
end
if _G.EliteFullScanFirst~=false then
local _fs0=os.clock()
local _fcap=tonumber(_G.EliteFullScanWait)or 0.8
local _stale=tonumber(_G.EliteScanStaleGap)or 0.2
local _prev=tonumber(_G.EliteScanNoChan)or 0
local _lastProg=os.clock()
while(tonumber(_G.EliteScanNoChan)or 0)>0 and os.clock()-_fs0<_fcap do
if _G.EliteTPStop then
break
end
task.wait(0.03)
allPets=scanForTP()
local _now=tonumber(_G.EliteScanNoChan)or 0
if _now<_prev then
_prev,_lastProg=_now,os.clock()
elseif os.clock()-_lastProg>=_stale then
break
end
end
if(tonumber(_G.EliteScanNoChan)or 0)>0 then
end
end
if not(type(_G.EliteStealTargetUID)=="string"and _G.EliteStealTargetUID~="")then
local pool,seen={},{}
local function _absorb(list)
if type(list)~="table"then
return
end
for _,p in ipairs(list)do
if not p.conveyor and p.plot and p.slot~=nil then
local uid=tostring(p.plot).."_"..tostring(p.slot)
local ex=seen[uid]
if not ex then
seen[uid]=p
pool[#pool+1]=p
elseif(p.mps or 0)>(ex.mps or 0)then
for i=1,#pool do
if pool[i]==ex then
pool[i]=p
break
end
end
seen[uid]=p
end
end
end
end
_absorb(allPets)
for _=1,(tonumber(_G.EliteTPScans)or 1)do
task.wait(tonumber(_G.EliteTPScanGap)or 0.03)
local _ok,_more=pcall(scanForTP)
if _ok then
_absorb(_more)
end
end
if#pool>0 then
allPets=pool
end
end
local pet
if type(_G.EliteStealTargetUID)=="string"and _G.EliteStealTargetUID~=""then
pet=_findStealTarget(allPets)or _findTPSyncedPet(allPets)
end
if not pet then
local _cand=(_G.ElitePrioFilter and _G.ElitePrioFilter(allPets))or allPets
if#_cand==0 then
_cand=allPets
end
local prio,best
for _,p in ipairs(_cand)do
if not p.conveyor then
if p._pri and(not prio or p._pri<prio._pri)then
prio=p
end
if not best or(p.mps or 0)>(best.mps or 0)then
best=p
end
end
end
pet=prio or best or _cand[1]
end
local petPos=pet.position
local petName=pet.name
if _G.EliteArmSteal then
pcall(_G.EliteArmSteal,pet)
end
_G.EliteStealHold=true
local _hasCarpet=false
do
local _c=LP.Character
if _c then
for _,_n in ipairs(CARPET_NAMES)do
if _c:FindFirstChild(_n)then
_hasCarpet=true
break
end
end
end
end
if not _hasCarpet then
pcall(fireGrapple)
end
local adjY=petPos.Y
if TALL_PETS[petName]then
adjY=petPos.Y-TALL_OFFSET
end
local coordTable=adjY>23.15 and MK_UPPER or MK_LOWER
if petPos.Y<=8.9 and isPlotUnlocked(pet.plot)then
if not _hasCarpet then
carpetEngage(forceGrapple)
end
vZero(hrp)
local _to=Vector3.new(petPos.X,-4,petPos.Z)
local route=computeRoute(hrp.Position,_to,nil)
if not route or#route==0 then
route={_to}
end
local _straight=_isStraightRoute(hrp.Position,route)
local _obSpeed=math.clamp(tonumber(_G.TPVelocity)or 400,200,750)
if _straight then
_obSpeed=math.clamp(tonumber(_G.EliteStraightSpeed)or 300,100,500)
end
do
local _len,_prev=0,hrp.Position
for _,wp in ipairs(route)do
_len=_len+(wp-_prev).Magnitude
_prev=wp
end
if _len<100 then
_obSpeed=math.clamp(tonumber(_G.EliteCloseSpeed)or 80,20,400)
end
end
_obSpeed=_pingAdjustSpeed(_obSpeed)
local _tw=false
local _left=route
if#_left>0 then
if EliteTweenOn()then
local _ok,_did=
pcall(tweenFlyThenTp,hrp,_left,_to,_obSpeed,tonumber(_G.EliteTweenNear)or 40,nil)
_tw=_ok and _did==true
if not _ok then
velMoveThrough(hrp,_left,_obSpeed,true,true)
end
else
velMoveThrough(hrp,_left,_obSpeed,true,true)
end
end
if _tw and not _G.EliteTPStop then
pcall(eliteEnsureArrive,hrp,_to,_obSpeed)
end
_G.__EliteLastTPTween=_tw
if hrp and hrp.Parent then
_vzL(hrp)
_vzA(hrp)
end
_G.EliteStealHold=false
isTeleporting=false
if _G.EliteTPStop then
return
end
return
end
local closestData,skyKey=findClosest(petPos,coordTable)
if not closestData or not skyKey then
_tpStage("no side spot for this base")
_G.EliteStealHold=false
isTeleporting=false
return
end
_tpStage("grapple + carpet")
local destPos=closestData.coord
local _carpet=_hasCarpet
and(function()
local _c=LP.Character
if _c then
for _,_n in ipairs(CARPET_NAMES)do
if _c:FindFirstChild(_n)then
return _n
end
end
end
return nil
end)()
or carpetEngage(forceGrapple)
vZero(hrp)
local facingDir=closestData.facing=="NORTH"and Vector3.new(0,0,-1)or Vector3.new(0,0,1)
local _frontApproach=false
do
local isUpper=(coordTable==MK_UPPER)
local idx=getClosestBaseIdx(petPos)
local frontCoord,frontFace=buildFrontCandidate(idx,isUpper,hrp.Position.Z)
local bestCoord,bestFace=frontCoord,frontFace
local bestDist=(hrp.Position-frontCoord).Magnitude
local pickedFront=true
local _tb=BASES_LOW[idx]
local _isWest=idx<=4
local _rowBlocked=false
local _dx,_dz=hrp.Position.X-_tb.X,hrp.Position.Z-_tb.Z
local _distToBase=math.sqrt(_dx*_dx+_dz*_dz)
local _sideRange=tonumber(_G.EliteSideTPRange)or 100
if _G.ElitePreferFrontOnRow~=false and _distToBase>_sideRange then
for i=1,8 do
if i~=idx and(i<=4)==_isWest then
local bz=BASES_LOW[i].Z
if(bz-hrp.Position.Z)*(bz-_tb.Z)<0 then
_rowBlocked=true
break
end
end
end
end
if not _rowBlocked then
for _,d in ipairs(plotSides(coordTable,idx))do
local dd=(hrp.Position-d.coord).Magnitude
if dd<bestDist then
bestDist=dd
bestCoord=d.coord
bestFace=d.facing=="NORTH"and Vector3.new(0,0,-1)or Vector3.new(0,0,1)
pickedFront=false
end
end
end
destPos=bestCoord
facingDir=bestFace
_frontApproach=pickedFront
if _G.EliteTPDebug==true then
end
end
if facingDir and facingDir.Magnitude>0.1 then
local axis=facingDir.Unit
local toPlayer=hrp.Position-destPos
local sign=(axis:Dot(toPlayer)>=0)and 1 or-1
destPos=destPos+axis*sign*(tonumber(_G.EliteCloneBackoff)or 0.5)
end
local _flashCam,_useFlash,_flashHigh=nil,false,false
if _G.EliteFlashTP==true then
local _fs=tonumber(pet and pet.slot)
local _fl=_fs and(_fs>=19 and 3 or _fs>=11 and 2 or 1)or(adjY>23.15 and 3 or adjY>8.9 and 2 or 1)
eliteSay("[FLASH] target floor ".._fl.." (slot "..tostring(pet and pet.slot)..")")
do
local okS,fPos,fLook,fCam=pcall(eliteFlashSpot,petPos,_fl==3)
if okS and fPos then
destPos,facingDir,_flashCam,_useFlash=fPos,fLook,fCam,true
_flashHigh=_fl==3
_G.__EliteFlashFlight=true
_G.__EliteFlashTPAt=os.clock()
_G.__EliteFlashHolding=false
_G.__EliteFlashNearFn=function()
local _c=LP.Character
local _h=_c and _c:FindFirstChildOfClass("Humanoid")
local _t=_c and(_c:FindFirstChild("Flash Teleport")or(LP:FindFirstChild("Backpack")and LP.Backpack:FindFirstChild("Flash Teleport")))
if _h and _t then
_G.__EliteFlashHolding=true
if _t.Parent~=_c then
_h:EquipTool(_t)
_G.__EliteFlashEquipAt=os.clock()
end
end
pcall(eliteFlashAimStart,facingDir,_flashCam)
end
end
end
end
_tpStage("routing")
local _route=computeRoute(hrp.Position,destPos,facingDir,nil,_G.EliteCrestRoute==true)
if _useFlash and _G.__EliteFlashNearFn and hrp and type(_route)=="table"then
local _pl,_pp=0,hrp.Position
for _,_w in ipairs(_route)do
_pl=_pl+(_w-_pp).Magnitude
_pp=_w
end
_pl=_pl+(destPos-_pp).Magnitude
if _pl<=(tonumber(_G.EliteFlashPreEquip)or 40)then
local _nf=_G.__EliteFlashNearFn
_G.__EliteFlashNearFn=nil
pcall(_nf)
end
end
local ASCEND_STEP=10
local _stepped={}
do
local prev=hrp.Position
for _,wp in ipairs(_route)do
local dy=wp.Y-prev.Y
if dy>ASCEND_STEP*1.5 then
local n=math.ceil(dy/ASCEND_STEP)
for s=1,n-1 do
local t=s/n
_stepped[#_stepped+1]=
Vector3.new(prev.X+(wp.X-prev.X)*t,prev.Y+dy*t,prev.Z+(wp.Z-prev.Z)*t)
end
end
_stepped[#_stepped+1]=wp
prev=wp
end
end
local _mainSpeed=math.clamp(tonumber(_G.TPVelocity)or 400,200,750)
local _targetIdx=getClosestBaseIdx(petPos)
local _targetIsWest=_targetIdx<=4
local _playerIsWest=hrp.Position.X<COLUMN_SPLIT_X
local _crossRow=_targetIsWest~=_playerIsWest
local _isLower=coordTable==MK_LOWER
local _toTarget=(petPos-hrp.Position).Unit
local _lookDir=hrp.CFrame.LookVector
local _dot=_toTarget:Dot(_lookDir)
local _isBehind=_dot<-0.3
local _isProblemTP=_crossRow and _frontApproach and _isLower and _isBehind
do
local _len,_prev=0,hrp.Position
for _,wp in ipairs(_route)do
_len=_len+(wp-_prev).Magnitude
_prev=wp
end
if _len<100 then
_mainSpeed=math.clamp(tonumber(_G.EliteCloseSpeed)or 80,20,400)
end
if _isProblemTP and _G.EliteSlowCrossRow==true then
_mainSpeed=math.clamp(tonumber(_G.EliteProblemBaseSpeed)or 60,20,400)
end
end
if _useFlash then
_mainSpeed=math.clamp(tonumber(_G.EliteFlashSpeed)or math.max(tonumber(_G.TPVelocity)or 400,550),200,750)
end
_mainSpeed=_pingAdjustSpeed(_mainSpeed)
_tpStage("flying")
local _tweened=false
local _left=_stepped
if#_left>0 then
if EliteTweenOn()and _frontApproach and not _useFlash then
local _ok,_did=
pcall(tweenFlyThenTp,hrp,_left,destPos,_mainSpeed,tonumber(_G.EliteTweenNear)or 40,facingDir)
_tweened=_ok and _did==true
if not _ok then
velMoveThrough(hrp,_left,_mainSpeed,true,true)
end
else
velMoveThrough(hrp,_left,_mainSpeed,true,true)
end
end
if EliteTweenOn()and _frontApproach and not _useFlash and not _G.EliteTPStop then
pcall(eliteEnsureArrive,hrp,destPos,_mainSpeed)
end
_G.__EliteLastTPTween=_tweened
_G.__EliteLastTPFlash=_useFlash==true
if _G.EliteTPStop then
if hrp and hrp.Parent then
vZero(hrp)
end
_G.EliteStealHold=false
isTeleporting=false
return
end
_G.__EliteFlashFlight=false
_G.__EliteFlashNearFn=nil
_G.__EliteFlashHolding=false
local _skipLand=_useFlash and hrp and hrp.Parent and true
if _skipLand and(hrp.Position-destPos).Magnitude>(tonumber(_G.EliteFlashSnap)or 10)then
pcall(velMoveThrough,hrp,{destPos},_mainSpeed,true,true)
end
if not _skipLand then
do
local above=destPos+Vector3.new(0,16,0)
local _t0=os.clock()
local _lastJump=0
_tpStage("climbing to floor")
while os.clock()-_t0<1.5 do
if not hrp or not hrp.Parent then
break
end
if LP:GetAttribute("Stealing")or _G.EliteTPStop then
break
end
equipCarpet()
local d=above-hrp.Position
local flat=Vector3.new(d.X,0,d.Z).Magnitude
if flat<=3 and hrp.Position.Y>=destPos.Y then
break
end
if d.Y>3 and(os.clock()-_lastJump)>0.5 then
local _hum=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
if _hum then
local st=_hum:GetState()
if st~=Enum.HumanoidStateType.Jumping and st~=Enum.HumanoidStateType.Freefall then
pcall(function()
_hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)
pcall(function()
_hum.Jump=true
end)
_lastJump=os.clock()
end
end
end
_setFlightVel(hrp,d.Unit*math.min(math.max(d.Magnitude*8,55),320))
_vzA(hrp)
RunService.Heartbeat:Wait()
end
end
do
local _runCap=_frontApproach and(tonumber(_G.EliteFrontRunIn)or 130)or 400
local _t0=os.clock()
local _bestMag,_bestT=math.huge,os.clock()
local _lastJump=0
while os.clock()-_t0<4 do
if not hrp or not hrp.Parent then
break
end
if LP:GetAttribute("Stealing")or _G.EliteTPStop then
break
end
equipCarpet()
local diff=destPos-hrp.Position
local mag=diff.Magnitude
if mag<=3 then
break
end
if mag<_bestMag-0.5 then
_bestMag=mag
_bestT=os.clock()
elseif os.clock()-_bestT>0.6 then
break
end
if diff.Y>3 and mag>15 and(os.clock()-_lastJump)>0.5 then
local _hum=hrp.Parent and hrp.Parent:FindFirstChildOfClass("Humanoid")
if _hum then
local st=_hum:GetState()
if st~=Enum.HumanoidStateType.Jumping and st~=Enum.HumanoidStateType.Freefall then
pcall(function()
_hum:ChangeState(Enum.HumanoidStateType.Jumping)
end)
pcall(function()
_hum.Jump=true
end)
_lastJump=os.clock()
end
end
end
_setFlightVel(hrp,diff.Unit*math.min(math.max(mag*8,55),_runCap))
_vzA(hrp)
RunService.Heartbeat:Wait()
end
end
end
if hrp and hrp.Parent and not _G.EliteTPStop then
local _flatOff=Vector3.new(destPos.X-hrp.Position.X,0,destPos.Z-hrp.Position.Z).Magnitude
if _flatOff>10 then
if _G.EliteTPDebug==true then
end
local _rr=(_stepped and#_stepped>0)and _stepped or{destPos}
velMoveThrough(hrp,_rr,_mainSpeed,true,true)
if hrp and hrp.Parent then
_vzL(hrp)
_vzA(hrp)
end
end
end
if _useFlash then
pcall(function()
local _c=LP.Character
local _h=_c and _c:FindFirstChildOfClass("Humanoid")
local _t=_c and(_c:FindFirstChild("Flash Teleport")or(LP:FindFirstChild("Backpack")and LP.Backpack:FindFirstChild("Flash Teleport")))
if _h and _t and _t.Parent~=_c then
_h:EquipTool(_t)
_G.__EliteFlashEquipAt=os.clock()
end
end)
pcall(eliteFlashAimStart,facingDir,_flashCam)
end
if hrp and hrp.Parent then
hrp.CFrame=CFrame.new(hrp.Position,hrp.Position+facingDir)
end
vZero(hrp)
local _useAB=_G.EliteOwnAutoBack~=true
and _G.__EliteAB~=nil
and _G.__EliteAB.hold~=nil
and hrp~=nil
and hrp.Parent~=nil
if _useFlash then
pcall(function()
hrp.CFrame=CFrame.new(destPos,destPos+facingDir)
_vzL(hrp)
_vzA(hrp)
end)
elseif not(_useAB and _G.EliteABInstant==true)then
local syncFrames=3
local syncConn
syncConn=RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
if not hrp or not hrp.Parent then
syncConn:Disconnect()
return
end
syncFrames=syncFrames-1
hrp.CFrame=CFrame.new(destPos,destPos+facingDir)
_vzL(hrp)
_vzA(hrp)
if syncFrames<=0 then
syncConn:Disconnect()
end
end))
local _landTries=tonumber(_G.EliteMaxLandTries)or 3
local _landGap=tonumber(_G.EliteLandCheckGap)or 0.03
for _=1,_landTries do
task.wait(_landGap)
if hum.FloorMaterial~=Enum.Material.Air then
break
end
end
do
local stable,_st0=0,os.clock()
local _cap=tonumber(_G.EliteStableWait)or 0.3
while os.clock()-_st0<_cap do
if _G.EliteTPStop then
break
end
local _hrp=char and char:FindFirstChild("HumanoidRootPart")
if not _hrp or not _hrp.Parent then
break
end
local flat=(Vector3.new(_hrp.Position.X,0,_hrp.Position.Z)-Vector3.new(
destPos.X,
0,
destPos.Z
)).Magnitude
if flat<=3.5 and math.abs(_hrp.Position.Y-destPos.Y)<=4 then
stable=stable+1
if stable>=2 then
break
end
else
stable=0
pcall(function()
_hrp.CFrame=CFrame.new(destPos,destPos+facingDir)
end)
_vzL(_hrp)
_vzA(_hrp)
end
RunService.Heartbeat:Wait()
end
end
end
local _ahrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local _clonePos=(_ahrp and _ahrp.Parent and _ahrp.Position)or destPos
local _flashed,_flashInside=false,false
if _useFlash then
_G.EliteStealHold=false
local okF,resF=pcall(eliteFlashIn,facingDir,_flashCam,destPos,_flashHigh)
pcall(eliteFlashCleanup)
_flashed=okF and resF~="notool"
if okF and resF==true then
local _hh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local _tb=BASES_LOW[getClosestBaseIdx(petPos)]
if _hh and _tb then
local _dx,_dz=_hh.Position.X-_tb.X,_hh.Position.Z-_tb.Z
local _r=tonumber(_G.EliteFlashInsideDist)or 30
_flashInside=(_dx*_dx+_dz*_dz)<=_r*_r
end
end
local _tries=tonumber(_G.EliteFlashRetries)or 1
while okF and resF==true and not _flashInside and _tries>0 and not _G.EliteTPStop do
_tries=_tries-1
eliteSay("[FLASH] missed the base - going back to the spot to flash again")
local _rh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not _rh then
break
end
local _rr=computeRoute(_rh.Position,destPos,facingDir,nil,false)
if not _rr or#_rr==0 then
_rr={destPos}
end
pcall(velMoveThrough,_rh,_rr,_mainSpeed,true,true)
pcall(function()
_rh.CFrame=CFrame.new(destPos,destPos+facingDir)
_vzL(_rh)
_vzA(_rh)
end)
pcall(eliteFlashAimStart,facingDir,_flashCam)
okF,resF=pcall(eliteFlashIn,facingDir,_flashCam,destPos,_flashHigh)
pcall(eliteFlashCleanup)
if okF and resF==true then
local _hh=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local _tb=BASES_LOW[getClosestBaseIdx(petPos)]
if _hh and _tb then
local _dx,_dz=_hh.Position.X-_tb.X,_hh.Position.Z-_tb.Z
local _r=tonumber(_G.EliteFlashInsideDist)or 30
_flashInside=(_dx*_dx+_dz*_dz)<=_r*_r
end
end
end
end
if _flashed then
elseif not _useAB or not(_ahrp and _ahrp.Parent)then
local _clonePlat=Instance.new("Part")
_clonePlat.Name="Part"
_clonePlat.Size=Vector3.new(4,1,4)
_clonePlat.Position=Vector3.new(_clonePos.X,_clonePos.Y-3,_clonePos.Z)
_clonePlat.Anchored=true
_clonePlat.CanCollide=true
_clonePlat.Transparency=1
_clonePlat.Material=Enum.Material.SmoothPlastic
_clonePlat.Parent=workspace
if _ahrp and _ahrp.Parent then
_vzL(_ahrp)
_vzA(_ahrp)
end
local _preClonePos,_preCloneChar
do
_preCloneChar=LP.Character
local _h=_preCloneChar and _preCloneChar:FindFirstChild("HumanoidRootPart")
_preClonePos=_h and _h.Position or destPos
end
local _charAdded=false
local _caConn=LP.CharacterAdded:Connect(function()
_charAdded=true
end)
_G.EliteStealHold=false
task.wait(tonumber(_G.LandingDelay)or tonumber(_G.TPCloneDelay)or 0.12)
if facingDir and facingDir.Magnitude>0.1 then
local _pinHum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if _pinHum then
pcall(function()
_pinHum.AutoRotate=false
end)
end
for _=1,2 do
local _h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if not _h or not _h.Parent then
break
end
pcall(function()
_h.CFrame=CFrame.new(_h.Position,_h.Position+facingDir)
_vzL(_h)
_vzA(_h)
end)
RunService.Heartbeat:Wait()
end
end
local _cloneOk=doClone()
if _clonePlat then
pcall(function()
_clonePlat:Destroy()
end)
_clonePlat=nil
end
do
local _t0=os.clock()
repeat
if _charAdded then
break
end
if LP.Character~=_preCloneChar then
break
end
local _h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if _h then
local _dx=_h.Position.X-_preClonePos.X
local _dz=_h.Position.Z-_preClonePos.Z
local _dy=_h.Position.Y-_preClonePos.Y
if(_dx*_dx+_dz*_dz)>4 then
break
end
if _dy*_dy>1 then
break
end
end
RunService.Heartbeat:Wait()
until os.clock()-_t0>(tonumber(_G.EliteCloneSettle)or 0.6)
end
if _caConn then
_caConn:Disconnect()
end
else
local AB=_G.__EliteAB
local look=(facingDir and facingDir.Magnitude>0.1)and facingDir.Unit or _ahrp.CFrame.LookVector
_G.EliteStealHold=false
local _inst=_G.EliteABInstant==true
local H=AB.hold(_ahrp,_inst and destPos or _clonePos,look)
if _inst then
local _abd=tonumber(_G.EliteABDelay)or 0
if _abd>0 then
task.wait(_abd)
else
RunService.Heartbeat:Wait()
end
else
task.wait(math.max(0.06,(tonumber(_G.LandingDelay)or tonumber(_G.TPCloneDelay)or 0.12)*0.7))
end
local okC,res=pcall(AB.clone,H)
local inside=false
if okC and(res=="remote"or res=="clone")then
local okW,w=pcall(AB.waitInside,H,look)
inside=okW and w==true
end
pcall(H.release,not inside)
_G.EliteLastAutoBack=tostring(okC and res or"error")..(inside and" / inside"or" / not inside")
task.delay(0.4,function()
_G.isCloning=false
end)
end
pcall(function()
local _rh=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
if _rh then
_rh.AutoRotate=true
end
end)
do
local _t0=os.clock()
repeat
RunService.Heartbeat:Wait()
local _h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if _h and _h.Parent then
break
end
until os.clock()-_t0>0.1
end
if _useFlash and _flashed and not _flashInside then
eliteSay("[FLASH] not inside base "..tostring(getClosestBaseIdx(petPos)).." - not going for the brainrot")
_G.EliteStealHold=false
isTeleporting=false
restoreAnimations()
return
end
goToBrainrot(petPos,pet and pet.slot)
isTeleporting=false
if _G.EliteTPStop then
return
end
if _G.EliteArmSteal then
pcall(_G.EliteArmSteal,pet)
end
restoreAnimations()
end
_manualTPBusy=false
function manualFullTP()
if _manualTPBusy or isTeleporting then
return
end
if LP:GetAttribute("Stealing")==true then
return
end
_manualTPBusy=true
if _G.EliteScanProfile and _G.EliteScanMode=="fast"then
_G.EliteScanProfile("normal")
end
local okAll=pcall(function()
local _t0=os.clock()
local _lastN,_lastTop=-1,nil
repeat
local ok,pets=pcall(scanForTP)
if ok and pets and#pets>0 then
local top=tostring(pets[1].plot).."_"..tostring(pets[1].slot)
if#pets==_lastN and top==_lastTop then
break
end
_lastN,_lastTop=#pets,top
task.wait(tonumber(_G.EliteScanSettle)or 0.04)
else
task.wait(0.05)
end
until os.clock()-_t0>(tonumber(_G.EliteTPMaxWait)or 4)
doVelocityTP(true)
end)
_manualTPBusy=false
return okAll
end
_G.EliteStartSideTP=manualFullTP
if type(_G.SHARED_PRIORITY_ITEMS)~="table"or#_G.SHARED_PRIORITY_ITEMS==0 then
_G.SHARED_PRIORITY_ITEMS={}
pcall(function()
for i,v in ipairs(game:GetService("HttpService"):JSONDecode(_G.ELITE_DEFAULT_CONFIG_JSON).priorityList)do
_G.SHARED_PRIORITY_ITEMS[i]=v=="Gobblino Uniciciclino"and"Gobblino Uniciclino"or v
end
end)
end
if _G.ElitePrioMerged~=true then
local extra={
"Headless Horseman",
"Strawberry Elephant",
"Signore Carapace",
"Elefanto Frigo",
"Arcadragon",
"Meowl",
"John Pork",
"Love Love Bear",
"Antonio",
"Skibidi Toilet",
"Griffin",
"Kalika Bros",
"Fishino Clownino",
"Pancake and Syrup",
"Dragon Gingerini",
"Dragon Aquanini",
"Tirilikalika Tirilikalako",
"La Supreme Combinasion",
"Digi Narwhal",
"Rico Dinero",
"Ginger Gerat",
"Hydra Bunny",
"Duggy Bros",
"Globa Steppa",
"Bunny and Eggy",
"Dragon Cannelloni",
"Hydra Dragon Cannelloni",
"Dug Dug Dug",
"Guest 666",
"Rubrikiko",
"Los Hackers",
"Ketupat Bros",
"La Casa Boo",
"Foxini Lanternini",
"Quackini Snackini",
"Cerberus",
"Celestial Pegasus",
"Rosey and Teddy",
"Los Chillis",
"Fragrama and Chocrama",
"Spooky and Pumpky",
"Reinito Sleighito",
"Fortunu and Cashuru",
"Los Amigos",
"Los Sekolahs",
"Cooki and Milki",
"La Food Combinasion",
"Jelly Moby",
"Gym Bros",
"Examen Bros",
"Cloverat Clapat",
"Money Money Reindeer",
"Popcuru and Fizzuru",
"Sammyni Truckini",
"Capitano Moby",
"Burguro And Fryuro",
"Money Money Bros",
"Sammyni Fattini",
"pizza and ranch",
"Garama and Madundung",
"La Lucky Grande",
"La Easter Grande",
"Fragola La La La",
"La Secret Combinasion",
"Cangurato Gelato",
"Cash or Card",
"Boppin Bunny",
"Los Tictacs",
"Chicli Chicla",
"Nachorilla",
"Eviledon",
"Orcaledon",
"Los Dragons",
"Moby Bros",
"Kraken",
"Sammyni Cakini",
"Grabatron",
"Bumbatron",
"Venuspino",
"Los Admins",
"Cerbère",
"Ta Ta Ta Ta Sahur",
"La Fuse Machine",
}
local function nk(x)
if type(_normName)=="function"then
return(_normName(tostring(x)))
end
return string.lower(tostring(x))
end
local have={}
for _,n in ipairs(_G.SHARED_PRIORITY_ITEMS)do
have[nk(n)]=true
end
for _,n in ipairs(extra)do
if not have[nk(n)]then
have[nk(n)]=true
table.insert(_G.SHARED_PRIORITY_ITEMS,n)
end
end
_G.ElitePrioMerged=true
task.spawn(function()
for _=1,60 do
if type(_G.EliteSaveSettings)=="function"then
pcall(_G.EliteSaveSettings)
return
end
task.wait(0.5)
end
end)
end
_G.ElitePrioOk=function(p)
local items=_G.SHARED_PRIORITY_ITEMS or{}
local function nk(x)
if type(_normName)=="function"then
return(_normName(tostring(x)))
end
return string.lower(tostring(x))
end
local pkey=#items..":"..tostring(_G.ElitePriVersion or 0)
if _G.__ElitePrioN~=pkey or not _G.__ElitePrioSet then
local set={}
for _,n in ipairs(items)do
set[nk(n)]=true
end
_G.__ElitePrioSet,_G.__ElitePrioN=set,pkey
end
local nm=p and p.name
if nm==nil or nm==""then
return false
end
return _G.__ElitePrioSet[nk(nm)]==true
end
UIS.InputBegan:Connect(function(input,gameProcessed)
if gameProcessed then return end
if _G.EliteBindListening then return end
if input.UserInputType~=Enum.UserInputType.Keyboard then return end
if input.KeyCode==Enum.KeyCode.V then
task.spawn(function()pcall(doClone)end)
end
local want=_G._stp_tpKeyName
if type(want)~="string"or want==""then want="T"end
if input.KeyCode.Name==want then
task.spawn(function()pcall(manualFullTP)end)
end
end)
task.spawn(function()pcall(loadModules)pcall(loadNet)end)
task.spawn(function()
pcall(function()
local R=game:GetService("ReplicatedStorage")
local d=R:FindFirstChild("Datas")or R:WaitForChild("Datas",3)
if d then
local a=d:FindFirstChild("Animals")or d:WaitForChild("Animals",3)
if a then _AD=require(a)end
local m=d:FindFirstChild("Mutations")or d:WaitForChild("Mutations",3)
if m then _MD=require(m)end
local t=d:FindFirstChild("Traits")or d:WaitForChild("Traits",3)
if t then _TD=require(t)end
end
end)
end)
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
task.wait(0.2)
for _=1,8 do
pcall(scanAllPetsCached,0)
task.wait(0.08)
end
while true do
pcall(scanAllPetsCached,0.3)
task.wait(0.2)
end
end)
task.spawn(function()
local char=LP.Character or LP.CharacterAdded:Wait()
char:WaitForChild("HumanoidRootPart",10)
char:WaitForChild("Humanoid",10)
pcall(loadModules)
if _G.EliteAutoTP==false then return end
local _carpetDone=false
task.spawn(function()
local _tw=os.clock()
while not _G.__EliteBootGrappleDone and os.clock()-_tw<12 do
task.wait(0.05)
end
local c=LP.Character
local has=false
for _,n in ipairs(CARPET_NAMES)do
if c and c:FindFirstChild(n)then has=true break end
end
if not has then
for _,n in ipairs(CARPET_NAMES)do
if findTool(n)then pcall(carpetEngage,false)break end
end
end
_carpetDone=true
end)
local _toolsReady=false
task.spawn(function()
if _G.EliteWaitForTools~=false and type(_G.EliteToolsReady)=="function"then
local _tt0=os.clock()
local _tcap=tonumber(_G.EliteToolWait)or 6
while os.clock()-_tt0<_tcap do
local ok,ready=pcall(_G.EliteToolsReady)
if ok and ready then break end
if _G.EliteAutoTP==false then return end
task.wait(tonumber(_G.EliteToolPoll)or 0.02)
end
end
_toolsReady=true
end)
local _bootT0=os.clock()
local _wMax=tonumber(_G.EliteAutoTPWait)or 15
local _chanGrace=tonumber(_G.EliteChanGrace)or 2
local _petsFound=nil
local function _itemsIn()
local bp=LP:FindFirstChildOfClass("Backpack")
local ch=LP.Character
if(bp and bp:FindFirstChild("Grapple Hook"))or(ch and ch:FindFirstChild("Grapple Hook"))then
return true
end
for _,n in ipairs(CARPET_NAMES)do
if(bp and bp:FindFirstChild(n))or(ch and ch:FindFirstChild(n))then return true end
end
return false
end
local _wake=Instance.new("BindableEvent")
local _wakeConns={}
local function _watch(bag)
if bag then
_wakeConns[#_wakeConns+1]=bag.ChildAdded:Connect(function()pcall(function()_wake:Fire()end)end)
end
end
_watch(LP:FindFirstChildOfClass("Backpack"))
_watch(LP.Character)
_wakeConns[#_wakeConns+1]=LP.ChildAdded:Connect(function(c)
if c:IsA("Backpack")then _watch(c)pcall(function()_wake:Fire()end)end
end)
local _hot=true
task.spawn(function()
while _hot do
pcall(scanAllPetsCached,0.05)
task.wait(0.05)
end
end)
local function _stopWatch()
_hot=false
for _,c in ipairs(_wakeConns)do pcall(function()c:Disconnect()end)end
pcall(function()_wake:Destroy()end)
end
_tpStage("waiting for items")
while os.clock()-_bootT0<_wMax do
if _G.EliteAutoTP==false then _stopWatch()return end
if LP:GetAttribute("Stealing")==true then _stopWatch()return end
if _itemsIn()then
local ok,pets=pcall(scanForTP)
if ok and pets and#pets>0 then
_petsFound=pets
break
end
_tpStage("items in - waiting for a target")
RunService.Heartbeat:Wait()
else
local _got=false
local _c=_wake.Event:Connect(function()_got=true end)
local _w0=os.clock()
while not _got and os.clock()-_w0<0.1 do RunService.Heartbeat:Wait()end
_c:Disconnect()
end
end
_stopWatch()
do
local _d=tonumber(_G._stp_tpDelay)or tonumber(_G.TPDelay)or 0
if _d>0 then task.wait(_d)end
end
if _G.EliteAutoTP==false then return end
_G.__EliteBootTP=true
pcall(doVelocityTP,true)
_G.__EliteBootTP=false
if _G.EliteScanProfile then _G.EliteScanProfile("normal")end
end)
do
local Players=game:GetService("Players")
local RunService=game:GetService("RunService")
local LP=Players.LocalPlayer
local PG=LP:FindFirstChild("PlayerGui")or LP:WaitForChild("PlayerGui",20)
local GUIHOST=(gethui and gethui())or game:GetService("CoreGui")
local _fspOverlap=OverlapParams.new()
_fspOverlap.FilterType=Enum.RaycastFilterType.Exclude
local function _promptWorldPos(p)
local pp=p and p.Parent
if not pp then
return nil
end
if pp:IsA("Attachment")then
return pp.WorldPosition
end
if pp:IsA("BasePart")then
return pp.Position
end
return nil
end
local function findStealPrompt(pet)
if not pet then
return nil
end
local podPrompt
if pet.plot and pet.slot then
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(pet.plot)
local podiums=plot and plot:FindFirstChild("AnimalPodiums")
local podium=podiums and podiums:FindFirstChild(tostring(pet.slot))
if podium then
local base=podium:FindFirstChild("Base")
local spawn=base and base:FindFirstChild("Spawn")
local attach=spawn and spawn:FindFirstChild("PromptAttachment")
if attach then
for _,p in ipairs(attach:GetChildren())do
if p:IsA("ProximityPrompt")then
podPrompt=p
break
end
end
end
if not podPrompt then
podPrompt=podium:FindFirstChildWhichIsA("ProximityPrompt",true)
end
end
end
if pet.position then
local pp=podPrompt and _promptWorldPos(podPrompt)
if(not podPrompt)or(pp and(pp-pet.position).Magnitude>15)then
_fspOverlap.FilterDescendantsInstances=LP.Character and{LP.Character}or{}
local okB,parts=pcall(workspace.GetPartBoundsInRadius,workspace,pet.position,14,_fspOverlap)
if okB and parts then
local best,bestD
for _,part in ipairs(parts)do
local pr=part:FindFirstChildOfClass("ProximityPrompt")
if not pr then
for _,ch in ipairs(part:GetChildren())do
if ch:IsA("Attachment")then
pr=ch:FindFirstChildOfClass("ProximityPrompt")
if pr then
break
end
end
end
end
if pr then
local pos=_promptWorldPos(pr)
local d=pos and(pos-pet.position).Magnitude or math.huge
if not best or d<bestD then
best,bestD=pr,d
end
end
end
if best then
return best
end
end
end
end
return podPrompt
end
local InternalStealCache={}
local STEAL_HOLD_DURATION=tonumber(_G.EliteStealHold)or 1.35
local STEAL_PROXIMITY=tonumber(_G.EliteStealProximity)or 60
local _stealHoldStart,_stealHoldActive=0,false
local _stealTarget,_stealArmedAt=nil,0
local _lastTargetPick,_lastPickUid,_currentTargetName=0,nil,nil
local _stealLastScan,_autoLastScan=0,0
local _inRangeLast=0
local _armCheckAt=0
local _petsCache,_petsCacheAt=nil,0
_G.ElitePrioFilter=function(pets)
if type(pets)~="table"or _G.ElitePriorityOnly==false or not _G.ElitePrioOk then
return pets
end
local f,rich={},{}
local th=tonumber(_G.ElitePrioFallbackMPS)or 50e6
for _,p in ipairs(pets)do
if _G.ElitePrioOk(p)then
f[#f+1]=p
elseif th>0 and(tonumber(p.mps)or 0)>=th then
rich[#rich+1]=p
end
end
if#f==0 then
return rich
end
return f
end
local function _scanCached(now,maxAge)
if _petsCache and(now-_petsCacheAt)<=(maxAge or 0.1)then
return _petsCache
end
local pets=scanAllPetsCached(0.08)
local ok=pets~=nil
if ok and type(pets)=="table"then
if _G.ElitePrioFilter then
pets=_G.ElitePrioFilter(pets)
end
_petsCache,_petsCacheAt=pets,now
return pets
end
return nil
end
local function _petListed(plot,slot)
local ch=getPlotChannel(plot)
local al=ch and channelGet(ch,"AnimalList")
if type(al)~="table"then
return true,false
end
local e=al[slot]
if e==nil then
e=al[tonumber(slot)or-1]
end
if e==nil then
e=al[tostring(slot)]
end
return e~=nil,true
end
local function _prox()
return tonumber(_G.EliteStealProximity)or STEAL_PROXIMITY
end
local STEAL_HOLD_MAX=2.95
local function _holdDur()
if _G.EliteStealHoldFull==true then
return STEAL_HOLD_MAX
end
local h=tonumber(_G.EliteStealHoldDuration)or STEAL_HOLD_DURATION
if h<STEAL_HOLD_DURATION then
h=STEAL_HOLD_DURATION
elseif h>STEAL_HOLD_MAX then
h=STEAL_HOLD_MAX
end
return h
end
local _cooldownUntil=0
local function _verifyFire(pet,path,judge)
task.delay(tonumber(_G.EliteVerifyDelay)or 0.35,function()
if not(pet and pet.plot and pet.slot~=nil)then
return
end
local listed,known=true,false
pcall(function()
listed,known=_petListed(pet.plot,pet.slot)
end)
if not known then
return
end
if not listed then
_G.EliteStealFails=0
_cooldownUntil=0
return
end
if not judge then
_cooldownUntil=0
return
end
end)
end
local function _holdBusy()
return _stealHoldActive
end
local _armedPet,_armLostSince=nil,0
local function _armLivePos(p)
if not(p and p.plot and p.slot~=nil)then
return nil
end
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(p.plot)
if not plot then
return nil
end
local ok,pos=pcall(getPetPosition,plot,p.slot)
if ok then
return pos
end
return nil
end
_G.EliteArmSteal=function(pet)
if type(pet)~="table"or type(pet.plot)~="string"or pet.slot==nil then
return
end
_armedPet={
name=pet.name,
index=pet.index,
mps=pet.mps,
_pri=pet._pri,
plot=pet.plot,
slot=tostring(pet.slot),
position=pet.position,
}
_armLostSince=0
_stealTarget=_armedPet
_stealArmedAt=os.clock()
if type(pet.name)=="string"and pet.name~=""then
_currentTargetName=pet.name
end
end
_G.EliteDisarmSteal=function()
_armedPet,_armLostSince=nil,0
end
_G.EliteArmedName=function()
return _armedPet and _armedPet.name or nil
end
_G.EliteAnimBorder=function(frame,thick,color)
local st=Instance.new("UIStroke")
st.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
st.Thickness=thick or 1.4
st.Color=color or Color3.new(1,1,1)
st.Transparency=0.2
st.Parent=frame
return st
end
local UIC={
bg=Color3.fromRGB(8,8,8),
bg2=Color3.fromRGB(14,14,14),
card=Color3.fromRGB(22,22,22),
hover=Color3.fromRGB(32,32,32),
track=Color3.fromRGB(48,48,48),
line=Color3.fromRGB(38,38,38),
acc=Color3.fromRGB(240,240,240),
acc2=Color3.fromRGB(200,200,200),
txt=Color3.fromRGB(245,245,245),
dim=Color3.fromRGB(140,140,140),
input=Color3.fromRGB(16,16,16),
green=Color3.fromRGB(235,235,235),
red=Color3.fromRGB(110,110,110),
edge=Color3.fromRGB(255,255,255),
}
local UIFB=(function()
for _,n in ipairs({"GothamBold"})do
local ok,f=pcall(function()
return Enum.Font[n]
end)
if ok and f then
return f
end
end
return Enum.Font.GothamBold
end)()
local UIF=Enum.Font.GothamMedium
local function mk(class,parent,props)
local o=Instance.new(class)
for k,v in pairs(props or{})do
o[k]=v
end
o.Parent=parent
return o
end
local function corner(o,r)
mk("UICorner",o,{CornerRadius=UDim.new(0,math.min(r or 6,6))})
return o
end
local function stroke(o,col)
mk("UIStroke",o,{Color=col or UIC.line,Thickness=1})
return o
end
pcall(function()
local _oldDbg=LP:FindFirstChild("PlayerGui")
_oldDbg=_oldDbg and _oldDbg:FindFirstChild(EN("EliteStealDbg"))
if _oldDbg then
_oldDbg:Destroy()
end
end)
local function _mirror(name,txt,frac)
local f=_G.EliteTargetsSteal
if type(f)=="function"then
pcall(f,name,txt,frac)
end
end
local function showStealBar(name,pct)
pct=math.clamp(tonumber(pct)or 0,0,1)
_mirror(name,math.floor(pct*100+0.5).."%",pct)
end
local function setStealBarPct(pct)
pct=math.clamp(tonumber(pct)or 0,0,1)
_mirror(nil,math.floor(pct*100+0.5).."%",pct)
end
local function hideStealBar()
_G.__EliteHudName=nil
_mirror("","0%",0)
end
task.defer(hideStealBar)
local function buildStealCallbacks(prompt)
if InternalStealCache[prompt]then
return
end
if not prompt or not prompt.Parent then
return
end
local data={holdCallbacks={},triggerCallbacks={},holdEndCallbacks={},ready=true}
local function grab(sig,into)
local ok,conns=pcall(getconnections,sig)
if ok and type(conns)=="table"then
for _,c in ipairs(conns)do
if type(c.Function)=="function"then
table.insert(into,c.Function)
end
end
end
end
grab(prompt.PromptButtonHoldBegan,data.holdCallbacks)
grab(prompt.Triggered,data.triggerCallbacks)
grab(prompt.PromptButtonHoldEnded,data.holdEndCallbacks)
if#data.holdCallbacks>0 or#data.triggerCallbacks>0 or#data.holdEndCallbacks>0 then
InternalStealCache[prompt]=data
end
end
local _rawFireServer=Instance.new("RemoteEvent").FireServer
local _reBegin,_reCommit=nil,nil
local _reState,_reRetryAt={},{}
local function _re(cache,hash)
if cache and cache.Parent then
return cache
end
local st=_reState[hash]
if typeof(st)=="Instance"then
if st.Parent then
return st
end
_reState[hash]=nil
st=nil
end
if st=="pending"then
return nil
end
if st=="failed"and os.clock()<(_reRetryAt[hash]or 0)then
return nil
end
_reState[hash]="pending"
task.spawn(function()
local got
pcall(function()
if _G.EliteGetRemote then
got=_G.EliteGetRemote("RemoteEvent",hash)
end
end)
if typeof(got)=="Instance"then
_reState[hash]=got
else
_reState[hash]="failed"
_reRetryAt[hash]=os.clock()+(tonumber(_G.EliteRemoteRetry)or 5)
end
end)
task.delay(tonumber(_G.EliteRemoteResolveWait)or 3,function()
if _reState[hash]=="pending"then
_reState[hash]="failed"
_reRetryAt[hash]=os.clock()+(tonumber(_G.EliteRemoteRetry)or 5)
end
end)
return nil
end
local function _stealBegin()
_reBegin=_re(_reBegin,"f40f7d9e-2f0d-4167-b250-899273f46874")
if not _reBegin then
return false
end
local t=workspace:GetServerTimeNow()+124
pcall(_rawFireServer,_reBegin,t,"68c86eb7-eb7e-4b4d-96ae-cf7cd847c5b0")
pcall(function()
_rawFireServer(_reBegin,t,"07b9cc25-2a1f-4a26-a0ec-f2fab578d8bd")
end)
return true
end
local function _stealCommit(plot,slot)
_reCommit=_re(_reCommit,"3ba148c9-7ed6-4675-93f8-9f7c356a2c54")
if not _reCommit then
return false
end
if type(plot)~="string"or slot==nil then
return false
end
local sl=tonumber(slot)or slot
local t=workspace:GetServerTimeNow()+31
pcall(_rawFireServer,_reCommit,t,"cda5c764-d4e3-45c4-94e4-53a538347590",plot,sl)
pcall(function()
_rawFireServer(_reCommit,t,"8c852fbf-d542-4ef4-aa28-612e24db8d4a",plot,sl)
end)
return true
end
_G.EliteStealBegin,_G.EliteStealCommit=_stealBegin,_stealCommit
local function _stealMargin()
return tonumber(_G.EliteStealMargin)or 0.08
end
local function _confirmGrab(prompt,data,pet)
if _G.EliteStealConfirm==false then
return
end
local ping=0.1
pcall(function()
ping=(_pingMs()or 100)/1000
end)
local gap=math.clamp(ping*1.2+0.05,0.15,0.4)
local tries=tonumber(_G.EliteStealRetries)or 2
local t0,n=os.clock(),0
while os.clock()-t0<gap*(tries+1)do
RunService.Heartbeat:Wait()
if LP:GetAttribute("Stealing")then
return
end
if n<tries and os.clock()-t0>=gap*(n+1)then
n=n+1
if prompt and prompt.Parent and prompt.Enabled~=false then
for _,fn in ipairs(data.triggerCallbacks)do
task.spawn(fn)
end
end
if n==tries and pet and pet.plot and pet.slot~=nil then
pcall(_stealCommit,pet.plot,pet.slot)
end
end
end
end
local _apCache=setmetatable({},{__mode="k"})
local function _apOf(prompt,data)
local ap=_apCache[prompt]
if ap~=nil then
return ap or nil
end
if debug and debug.getupvalues then
for _,fn in ipairs(data.holdCallbacks)do
local ok,ups=pcall(debug.getupvalues,fn)
if ok and type(ups)=="table"then
for _,v in pairs(ups)do
if type(v)=="table"and rawget(v,"State")~=nil and rawget(v,"ProximityPrompt")~=nil then
_apCache[prompt]=v
return v
end
end
end
end
end
_apCache[prompt]=false
return nil
end
local function _fireHold(prompt,data)
if _G.EliteForceHold~=false then
local ap=_apOf(prompt,data)
if ap and ap.State~="Steal"then
local old=ap.State
ap.State="Steal"
for _,fn in ipairs(data.holdCallbacks)do
pcall(fn)
end
ap.State=old
return
end
end
for _,fn in ipairs(data.holdCallbacks)do
task.spawn(fn)
end
end
do
local function hookHum(ch)
local hum=ch and ch:WaitForChild("Humanoid",5)
if hum then
hum.StateChanged:Connect(function(_,new)
if new==Enum.HumanoidStateType.Physics or new==Enum.HumanoidStateType.Ragdoll or new==Enum.HumanoidStateType.FallingDown then
_G.__EliteRagPhysT=tick()
end
end)
end
end
LP.CharacterAdded:Connect(hookHum)
if LP.Character then
task.spawn(hookHum,LP.Character)
end
LP:GetAttributeChangedSignal("RagdollEndTime"):Connect(function()
local et=tonumber(LP:GetAttribute("RagdollEndTime"))or 0
if et>workspace:GetServerTimeNow()then
_G.__EliteRagUntil=et
end
end)
end
local function _ragEnd()
local now=workspace:GetServerTimeNow()
local a=tonumber(LP:GetAttribute("RagdollEndTime"))or 0
if a>now then
return a
end
local c=tonumber(_G.__EliteRagUntil)or 0
if c>now then
return c
end
return 0
end
local function _ragBlocked()
if _G.EliteRagdollHold==false then
return false
end
return(_ragEnd()-workspace:GetServerTimeNow()+(tonumber(_G.EliteRagdollPad)or 0.1))>0
end
local function executeStealAsync(prompt,petName,restoreMax,pet)
if _holdBusy()then
return false
end
local data=InternalStealCache[prompt]
if not data or not data.ready then
return false
end
data.ready=false
_stealHoldStart=tick()
_stealHoldActive=true
do
local _tok={}
_G.__EliteHoldTok=_tok
task.delay(tonumber(_G.EliteStealFailsafe)or 12,function()
if _G.__EliteHoldTok==_tok and _stealHoldActive then
_stealHoldActive=false
data.ready=true
pcall(hideStealBar)
pcall(eliteSay,"[STEAL] a steal got stuck - reset it, auto steal continues")
end
end)
end
pcall(function()
prompt.MaxActivationDistance=math.huge
end)
showStealBar(petName,0)
if _G.EliteStealQuick==true then
task.spawn(function()
_fireHold(prompt,data)
local _beginT=os.clock()
pcall(function()
local st=prompt:GetAttribute("State")
if st~=nil and st~="Steal"then
_stealBegin()
end
end)
local _qd=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
_qd=math.max(_qd,hd+_stealMargin())
end
end)
_G.EliteStealSrvEnd=workspace:GetServerTimeNow()+_qd
local _barConn
pcall(function()
_barConn=RunService.RenderStepped:Connect(function()
local rem=_G.EliteStealSrvEnd and(_G.EliteStealSrvEnd-workspace:GetServerTimeNow())
or 0
if rem<=0 then
setStealBarPct(1)
else
setStealBarPct(1-rem/_qd)
end
end)
end)
local remaining=_G.EliteStealSrvEnd-workspace:GetServerTimeNow()
if remaining>0 then
task.wait(remaining)
end
if _ragBlocked()then
pcall(showStealBar,"RAGDOLL HOLD: "..tostring(petName),1)
local r0=os.clock()
local stale=tonumber(_G.EliteStealSrvHoldMax)or 2.4
while _ragBlocked()and os.clock()-r0<8 do
local remain=_ragEnd()-workspace:GetServerTimeNow()
if remain>0 and remain<=_qd+0.05 and(os.clock()-_beginT)+remain>stale and prompt and prompt.Parent then
_fireHold(prompt,data)
_beginT=os.clock()
end
RunService.Heartbeat:Wait()
end
pcall(showStealBar,petName,1)
local age=os.clock()-_beginT
if age>stale+0.1 and prompt and prompt.Parent and prompt.Enabled~=false then
_fireHold(prompt,data)
_beginT=os.clock()
age=0
end
if age<_qd then
task.wait(_qd-age)
end
end
if _barConn then
pcall(function()
_barConn:Disconnect()
end)
end
if prompt and prompt.Parent then
for _,fn in ipairs(data.triggerCallbacks)do
task.spawn(fn)
end
_confirmGrab(prompt,data,pet)
else
_armedPet,_armLostSince=nil,0
end
for _,fn in ipairs(data.holdEndCallbacks)do
task.spawn(fn)
end
task.wait(0.05)
_stealHoldActive=false
_G.EliteStealSrvEnd=nil
if restoreMax~=nil then
pcall(function()
if prompt and prompt.Parent then
prompt.MaxActivationDistance=restoreMax
end
end)
end
data.ready=true
hideStealBar()
end)
return true
end
task.spawn(function()
_fireHold(prompt,data)
local _beginT,_holdAbs,_ragShown=os.clock(),tick(),false
local GRAB_MIN=STEAL_HOLD_DURATION
local GRAB_MAX=tonumber(_G.EliteStealHoldMax)or STEAL_HOLD_MAX
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 and hd+0.1>GRAB_MIN then
GRAB_MIN=hd+0.1
end
end)
local _flashSteal=false
local landed=_G.__EliteTPLandedAt
local _fAt=_G.__EliteFlashTPAt
if _fAt and(os.clock()-_fAt)<(tonumber(_G.EliteFlashStealWindow)or 15)then
local fh=tonumber(_G.EliteFlashStealHold)or 1.37
GRAB_MIN=fh
_flashSteal=true
if landed then
_G.__EliteTPLandedAt=nil
end
elseif landed and(os.clock()-landed)<(tonumber(_G.EliteTPStealWindow)or 5)then
_G.__EliteTPLandedAt=nil
local post=(_G.__EliteLastTPTween==true)and(tonumber(_G.EliteTweenStealHold)or 2.15)
or(tonumber(_G.EliteTPStealHold)or 2.55)
if post>GRAB_MIN then
GRAB_MIN=post
end
end
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 and GRAB_MIN<hd+_stealMargin()and not _flashSteal then
GRAB_MIN=hd+_stealMargin()
end
end)
if GRAB_MAX<GRAB_MIN then
GRAB_MAX=GRAB_MIN
end
local _ppSeen,_ppKind,_charSeen,_hrpSeen=nil,0,nil,nil
local function _grabRange()
local char=LP.Character
if not char then
return true
end
if char~=_charSeen then
_charSeen=char
_hrpSeen=char:FindFirstChild("HumanoidRootPart")
end
local hrp=_hrpSeen
if not hrp or hrp.Parent~=char then
hrp=char:FindFirstChild("HumanoidRootPart")
_hrpSeen=hrp
if not hrp then
return true
end
end
local pp=prompt.Parent
if not pp then
return true
end
if pp~=_ppSeen then
_ppSeen=pp
_ppKind=(pp:IsA("Attachment")and 1)or(pp:IsA("BasePart")and 2)or 0
end
local pos
if _ppKind==1 then
pos=pp.WorldPosition
elseif _ppKind==2 then
pos=pp.Position
else
return true
end
return(hrp.Position-pos).Magnitude<=(tonumber(_G.EliteStealGrabDist)or 12)
end
local DWELL=tonumber(_G.EliteStealDwell)or 0.22
local readyAt=nil
local _gone=false
local _barConn
pcall(function()
_barConn=RunService.RenderStepped:Connect(function()
local el=tick()-_stealHoldStart
if not(prompt and prompt.Parent and prompt:IsDescendantOf(workspace))then
return
end
if el<GRAB_MIN then
setStealBarPct(el/GRAB_MIN)
else
setStealBarPct(1)
end
end)
end)
while true do
local el=tick()-_stealHoldStart
if not(prompt and prompt.Parent and prompt:IsDescendantOf(workspace))then
_gone=true
break
end
local _rb=_ragBlocked()
if _rb then
if not _ragShown then
_ragShown=true
pcall(showStealBar,"RAGDOLL HOLD: "..tostring(petName),1)
end
if el>=GRAB_MAX then
GRAB_MAX=el+0.1
end
do
local remain=_ragEnd()-workspace:GetServerTimeNow()
local need=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
need=math.max(need,hd+_stealMargin())
end
end)
if remain>0 and remain<=need+0.05 and(os.clock()-_beginT)+remain>(tonumber(_G.EliteStealSrvHoldMax)or 2.4)and prompt.Enabled~=false then
_fireHold(prompt,data)
_beginT=os.clock()
_stealHoldStart=tick()+remain-GRAB_MIN
GRAB_MAX=math.max(GRAB_MAX,GRAB_MIN+0.6)
end
end
elseif _ragShown then
_ragShown=false
pcall(showStealBar,petName,1)
end
if tick()-_holdAbs>(tonumber(_G.EliteStealHoldCap)or 8)then
break
end
if not _rb and os.clock()-_beginT>math.max(tonumber(_G.EliteStealSrvHoldMax)or 2.5,GRAB_MIN+0.6)
and prompt.Enabled~=false then
_fireHold(prompt,data)
_beginT=os.clock()
local _needSrv=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
_needSrv=math.max(_needSrv,hd+_stealMargin())
end
end)
_stealHoldStart=tick()-math.max(0,GRAB_MIN-_needSrv)
GRAB_MAX=math.max(GRAB_MAX,GRAB_MIN+0.6)
readyAt=nil
el=tick()-_stealHoldStart
end
if el>=GRAB_MAX and not _rb then
break
end
if _grabRange()then
if not readyAt then
readyAt=tick()
end
if el>=GRAB_MIN and(tick()-readyAt)>=DWELL and not _rb then
break
end
else
readyAt=nil
end
RunService.Heartbeat:Wait()
end
if _barConn then
pcall(function()
_barConn:Disconnect()
end)
end
setStealBarPct(0)
if not _gone and prompt and prompt.Parent then
for _,fn in ipairs(data.triggerCallbacks)do
task.spawn(fn)
end
_confirmGrab(prompt,data,pet)
elseif _gone then
_armedPet,_armLostSince=nil,0
end
for _,fn in ipairs(data.holdEndCallbacks)do
task.spawn(fn)
end
task.wait(0.05)
_stealHoldActive=false
if restoreMax~=nil then
pcall(function()
if prompt and prompt.Parent then
prompt.MaxActivationDistance=restoreMax
end
end)
end
data.ready=true
hideStealBar()
end)
return true
end
local function timeUntilCanSteal()
if
LP:GetAttribute("Stealing")
or LP:GetAttribute("IsTrading")
or LP:GetAttribute("IsDuelSelecting")
or LP:GetAttribute("Web")
then
return-1
end
local ragdoll=LP:GetAttribute("RagdollEndTime")
if ragdoll then
local r=ragdoll-workspace:GetServerTimeNow()
if r>0 then
return r
end
end
return 0
end
local stealOn=(_G.EliteStealMode~=nil)
local _emptyScans=0
local function _fireSteal(pet)
if not pet then
return false
end
if _holdBusy()then
_G.__EliteFireWhy="busy"
return false
end
if _G.EliteDropCatch~=false and _G.EliteDropTaken and _G.EliteDropTaken(pet)then
_G.__EliteFireWhy="someone is carrying it"
return false
end
_G.__EliteDropBeginAt=nil
local _fhrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local _fd=(_fhrp and pet.position)and(pet.position-_fhrp.Position).Magnitude or nil
local _judge=(_fd~=nil)and(_fd<=_prox()+2)or false
local _cd=_holdDur()+(tonumber(_G.EliteStealCycleGap)or 0)
local prompt=findStealPrompt(pet)
if not prompt or not prompt.Parent then
_G.__EliteFireWhy="no steal prompt"
local k=tostring(pet.plot).."_"..tostring(pet.slot)
_G.__EliteNoPromptAt=_G.__EliteNoPromptAt or{}
if os.clock()-(_G.__EliteNoPromptAt[k]or 0)>2 then
_G.__EliteNoPromptAt[k]=os.clock()
eliteSay("[STEAL] can't find the steal prompt for "..tostring(pet.name).." ("..k..")")
end
return false
end
local oldMax
pcall(function()
oldMax=prompt.MaxActivationDistance
end)
pcall(function()
prompt.MaxActivationDistance=math.huge
end)
buildStealCallbacks(prompt)
if InternalStealCache[prompt]then
_G.__EliteFireWhy="prompt not ready"
if executeStealAsync(prompt,pet.name,oldMax,pet)then
_G.EliteLastFire=os.clock()
_verifyFire(pet,"prompt",_judge)
return true
end
if oldMax~=nil then
pcall(function()
prompt.MaxActivationDistance=oldMax
end)
end
return false
else
pcall(function()
prompt.MaxActivationDistance=math.huge
end)
showStealBar(pet.name,0)
_stealHoldActive=true
task.spawn(function()
local need=STEAL_HOLD_DURATION
pcall(function()
local hd=prompt.HoldDuration
if type(hd)=="number"and hd>0 then
need=math.max(need,hd+0.1)
end
end)
local okB=pcall(function()
prompt:InputHoldBegin()
end)
local t0=os.clock()
while os.clock()-t0<need do
pcall(setStealBarPct,(os.clock()-t0)/need)
RunService.Heartbeat:Wait()
end
if okB then
pcall(function()
prompt:InputHoldEnd()
end)
end
task.wait(0.15)
if fireproximityprompt and not LP:GetAttribute("Stealing")then
pcall(function()
fireproximityprompt(prompt)
end)
end
pcall(function()
if oldMax~=nil and prompt and prompt.Parent then
prompt.MaxActivationDistance=oldMax
end
end)
hideStealBar()
_stealHoldActive=false
end)
_G.EliteLastFire=os.clock()
_verifyFire(pet,"prompt",_judge)
return true
end
end
_G.EliteFireSteal=_fireSteal
local _dropWatch,_seenOnPod,_missSince={},{},{}
local function _dropUid(p)
return tostring(p.plot).."_"..tostring(p.slot)
end
local function _dropNear(p)
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
return h~=nil and p~=nil and p.position~=nil and(h.Position-p.position).Magnitude<=(_prox()+6)
end
local function _onPodium(pet)
if not(pet and pet.plot and pet.slot~=nil)then
return nil
end
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(tostring(pet.plot))
local pods=plot and plot:FindFirstChild("AnimalPodiums")
local pod=pods and pods:FindFirstChild(tostring(pet.slot))
local b=pod and pod:FindFirstChild("Base")
local sp=b and b:FindFirstChild("Spawn")
if not sp then
return nil
end
for _,d in ipairs(sp:GetDescendants())do
if d:IsA("Model")then
return true
end
end
return false
end
_G.EliteDropTaken=function(pet)
if not(pet and pet.plot and pet.slot~=nil)or pet.conveyor then
return false
end
local uid=_dropUid(pet)
local on=_onPodium(pet)
if on==true then
_seenOnPod[uid]=true
_missSince[uid]=nil
_dropWatch[uid]=nil
return false
end
local function _someoneStealing()
for _,pl in ipairs(Players:GetPlayers())do
if pl~=LP and pl:GetAttribute("Stealing")==true then
return true
end
end
return false
end
if on==false and _seenOnPod[uid]and not _someoneStealing()then
_missSince[uid]=nil
_dropWatch[uid]=nil
return false
end
if on==false and _seenOnPod[uid]then
local ms=_missSince[uid]
if not ms then
_missSince[uid]=os.clock()
return false
end
if os.clock()-ms<0.4 then
return false
end
if not _dropWatch[uid]then
_dropWatch[uid]={pet=pet,at=os.clock(),since=_missSince[uid]or os.clock()}
eliteSay("[STEAL] "..tostring(pet.name).." is being carried by someone - grabbing it when it's dropped")
end
if not _dropNear(pet)then
if _armedPet and _armedPet.plot==pet.plot and tostring(_armedPet.slot)==tostring(pet.slot)then
_armedPet,_armLostSince=nil,0
end
if _stealTarget and _stealTarget.plot==pet.plot and tostring(_stealTarget.slot)==tostring(pet.slot)then
_stealTarget=nil
end
end
return true
end
return false
end
do
local _rawScan=_scanCached
_scanCached=function(now,maxAge)
local pets=_rawScan(now,maxAge)
if type(pets)~="table"or next(_dropWatch)==nil then
return pets
end
local out={}
for _,p in ipairs(pets)do
if not(p.plot and _dropWatch[_dropUid(p)])or _dropNear(p)then
out[#out+1]=p
end
end
return out
end
local _hudOn,_hudAt=false,0
local _holderCache={}
local function _holderName(pet)
local key=_dropUid(pet)
local c=_holderCache[key]
if c and os.clock()-c.t<0.5 then
return c.n
end
local best,bd
for _,pl in ipairs(Players:GetPlayers())do
if pl~=LP and pl:GetAttribute("Stealing")==true and pl.Character then
local ch=pl.Character
local d=math.huge
for _,m in ipairs(ch:GetChildren())do
if m:IsA("Model")and(m.Name==pet.index or m.Name==pet.name)then
d=-1
break
end
end
if d~=-1 then
local h=ch:FindFirstChild("HumanoidRootPart")
d=(h and pet.position)and(h.Position-pet.position).Magnitude or math.huge
end
if not bd or d<bd then
best,bd=pl,d
end
end
end
local n=best and best.DisplayName or"SOMEONE"
_holderCache[key]={n=n,t=os.clock()}
return n
end
local _lastSweep=0
RunService.Heartbeat:Connect(function()
if next(_dropWatch)==nil or _G.EliteDropCatch==false then
if _hudOn and not _holdBusy()then
_hudOn=false
pcall(_mirror,"","0%",0)
end
return
end
local now=os.clock()
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local carrying=LP:GetAttribute("Stealing")==true
local busy=_holdBusy()
if now-_lastSweep>=0.5 then
_lastSweep=now
local live={}
local ok,pets=pcall(_rawScan,now,0.5)
if ok and type(pets)=="table"then
for _,p in ipairs(pets)do
if p.plot then
live[_dropUid(p)]=true
end
end
for uid,w in pairs(_dropWatch)do
if(not live[uid]and next(live)~=nil)or now-w.at>(tonumber(_G.EliteDropWait)or 60)then
_dropWatch[uid]=nil
end
end
end
end
for uid,w in pairs(_dropWatch)do
local pet=w.pet
local near=hrp and pet.position and(hrp.Position-pet.position).Magnitude<=(_prox()+2)
if _onPodium(pet)==true then
_dropWatch[uid]=nil
if near and not carrying and not busy then
local pre=_G.__EliteDropBeginAt
local _stale=tonumber(_G.EliteStealSrvHoldMax)or 2.4
local age=pre and now-pre or nil
_G.__EliteDropBeginAt=nil
if _G.EliteDropInstant~=false and age and age<=_stale then
task.delay(math.max(0,STEAL_HOLD_DURATION-age+0.03),function()
if LP:GetAttribute("Stealing")or _holdBusy()then
return
end
if _stealCommit(pet.plot,pet.slot)then
task.delay(0.35,function()
if not LP:GetAttribute("Stealing")and not _holdBusy()then
pcall(_fireSteal,pet)
end
end)
else
pcall(_fireSteal,pet)
end
end)
else
pcall(_fireSteal,pet)
end
end
elseif near and not carrying and not busy and _G.EliteDropInstant~=false then
local pre=_G.__EliteDropBeginAt
if not pre or now-pre>=(tonumber(_G.EliteStealSrvHoldMax)or 2.4)-0.1 then
pcall(function()
local pr=findStealPrompt(pet)
local dt=pr and InternalStealCache[pr]
if dt and dt.ready and type(dt.holdCallbacks)=="table"then
_fireHold(pr,dt)
end
end)
if _stealBegin()then
_G.__EliteDropBeginAt=now
end
end
end
end
local show,showD=nil,nil
if hrp then
for _,w in pairs(_dropWatch)do
if w.pet and w.pet.position then
local dd=(hrp.Position-w.pet.position).Magnitude
if not showD or dd<showD then
show,showD=w,dd
end
end
end
end
if show and not _holdBusy()and not LP:GetAttribute("Stealing")and _G.EliteDropHud~=false then
if now-_hudAt>=0.1 then
_hudAt=now
_hudOn=true
pcall(_mirror,(_dropNear(show.pet)and("DROP HOLD: "..tostring(show.pet.name))or("HELD BY ".._holderName(show.pet)..": "..tostring(show.pet.name))),string.format("%.1fs",now-(show.since or show.at)),1)
end
elseif _hudOn and not _holdBusy()then
_hudOn=false
pcall(_mirror,"","0%",0)
end
end)
task.spawn(function()
local idleOn=false
while true do
task.wait(0.25)
pcall(function()
if _G.EliteStealMode==nil or _G.EliteIdleHud==false or _holdBusy()or LP:GetAttribute("Stealing")or _hudOn then
return
end
local t=_armedPet or _stealTarget
local h=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
if t and t.position and h then
idleOn=true
_mirror("TARGET: "..tostring(t.name)..(_G.__EliteStealWhy and("  -  ".._G.__EliteStealWhy)or""),string.format("%dm",math.floor((t.position-h.Position).Magnitude)),0)
elseif idleOn then
idleOn=false
_mirror("","0%",0)
end
end)
end
end)
end
local function _stealTick()
_G.EliteTickN=(_G.EliteTickN or 0)+1
stealOn=(_G.EliteStealMode~=nil)
if not stealOn then
return
end
local now=os.clock()
local _lockUid=_G.EliteStealTargetUID
local _lockChanged=(type(_lockUid)=="string"and _lockUid~=""and _lockUid~=_lastPickUid)
local _needPick=not _stealTarget
or _lockChanged
or(now-_lastTargetPick)>=(tonumber(_G.EliteRepickGap)or 0.1)
if _armedPet then
local _lp=_armLivePos(_armedPet)
if _lp then
_armedPet.position=_lp
_armLostSince=0
elseif _armLostSince==0 then
_armLostSince=now
elseif now-_armLostSince>(tonumber(_G.EliteArmLostGrace)or 1.0)then
_armedPet,_armLostSince=nil,0
end
if _armedPet and(now-_armCheckAt)>=(tonumber(_G.EliteArmCheckGap)or 0.3)then
_armCheckAt=now
local okL,listed=pcall(_petListed,_armedPet.plot,_armedPet.slot)
if okL and not listed then
_armedPet,_armLostSince=nil,0
end
end
if _armedPet and _G.EliteStealMode~="nearest"then
_stealTarget=_armedPet
if type(_armedPet.name)=="string"then
_currentTargetName=_armedPet.name
end
_needPick=false
end
end
local _scanGap=(_emptyScans>=3)and(tonumber(_G.EliteStealIdleGap)or 0.2)or 0.01
if not LP:GetAttribute("Stealing")and _needPick and(now-_autoLastScan)>=_scanGap then
_autoLastScan=now
_lastTargetPick=now
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hrp then
local pets=_scanCached(now,0.05)
local ok=pets~=nil
if ok and pets and#pets>0 then
_emptyScans=0
else
_emptyScans=_emptyScans+1
end
if ok and pets and#pets>0 then
local best
if type(_lockUid)=="string"and _lockUid~=""then
for _,p in ipairs(pets)do
if not p.conveyor and _petUid(p)==_lockUid then
best=p
break
end
end
end
if not best and _G.EliteStealMode=="nearest"then
local myPos=hrp.Position
local bestD=math.huge
for _,p in ipairs(pets)do
if not p.conveyor and p.position then
local d=(p.position-myPos).Magnitude
if d<bestD then
bestD=d
best=p
end
end
end
elseif not best then
for _,p in ipairs(pets)do
if not p.conveyor then
best=p
break
end
end
end
best=best or pets[1]
if best then
_stealTarget=best
_stealArmedAt=now
_lastPickUid=_lockUid
if type(best.name)=="string"and best.name~=""then
_currentTargetName=best.name
end
end
end
end
end
if _G.EliteStealMode=="nearest"and not(type(_lockUid)=="string"and _lockUid~="")then
local _c2=LP.Character
local _h2=_c2 and _c2:FindFirstChild("HumanoidRootPart")
if _h2 and(now-_inRangeLast)>=(tonumber(_G.EliteInRangeGap)or 0.15)then
_inRangeLast=now
local _pets2=_scanCached(now,0.15)
if _pets2~=nil and type(_pets2)=="table"then
local _near,_nd=nil,math.huge
local _mp=_h2.Position
for _,p in ipairs(_pets2)do
if not p.conveyor and p.position then
local d=(p.position-_mp).Magnitude
if d<_nd then
_nd,_near=d,p
end
end
end
if _near then
local _nu=_petUid(_near)
if _nu~=_G.EliteLastNearUid then
_G.EliteLastNearUid=_nu
end
_stealTarget=_near
_armedPet,_armLostSince=nil,0
_lastTargetPick=now
if type(_near.name)=="string"then
_currentTargetName=_near.name
end
end
end
end
end
if
_G.EliteNearGrab~=false
and _G.EliteStealMode~="nearest"
and not(type(_lockUid)=="string"and _lockUid~="")
and not _armedPet
and not isTeleporting
and not(_G.__EliteTPLandedAt and(os.clock()-_G.__EliteTPLandedAt)<6)
and(now-(_G.__EliteNearGrabAt or 0))>=0.15
then
_G.__EliteNearGrabAt=now
local _hN=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local _pN=_hN and _scanCached(now,0.15)
if type(_pN)=="table"then
local RANGE=tonumber(_G.EliteNearGrabRange)or 60
local near,nd=nil,math.huge
for _,p in ipairs(_pN)do
if not p.conveyor and p.position then
local d=(p.position-_hN.Position).Magnitude
if d<nd then
nd,near=d,p
end
end
end
if near and nd<=RANGE then
local cur=_stealTarget
local curD=(cur and cur.position)and(cur.position-_hN.Position).Magnitude or math.huge
if curD>RANGE then
_stealTarget=near
if type(near.name)=="string"then
_currentTargetName=near.name
end
end
end
end
end
local pet=_stealTarget
if not pet then
return
end
if type(pet.name)=="string"and pet.name~=""and pet.name~=_G.__EliteHudName and not LP:GetAttribute("Stealing")then
_G.__EliteHudName=pet.name
_mirror(pet.name,nil,nil)
end
if now-_stealLastScan<0.02 then
_G.EliteThrN=(_G.EliteThrN or 0)+1
return
end
_stealLastScan=now
local t=timeUntilCanSteal()
if t==-1 then
_G.__EliteStealWhy="can't steal right now"
if LP:GetAttribute("Stealing")then
_stealTarget=nil
_armedPet,_armLostSince=nil,0
end
return
end
if t>0 and t>_holdDur()then
_G.__EliteStealWhy="ragdolled"
return
end
_G.__EliteStealWhy="too far"
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if not hrp then
return
end
if pet.position then
local toPet=pet.position-hrp.Position
local dist=toPet.Magnitude
if(now-(_G.__eliteTgtAt or 0))>=0.15 then
_G.__eliteTgtAt=now
_G.EliteStealTgt=tostring(pet.name)
.." ["
..tostring(pet.plot)
.."/"
..tostring(pet.slot)
.."] d="
..math.floor(dist)
end
local hold=_holdDur()
local lead=tonumber(_G.EliteStealLead)or 0.6
local closing=dist>0.001 and(hrp.AssemblyLinearVelocity:Dot(toPet)/dist)or 0
local _nearBase=false
do
local _bi=getClosestBaseIdx(pet.position)
local _b=_bi and BASES_LOW[_bi]
if _b then
local _bx,_bz=hrp.Position.X-_b.X,hrp.Position.Z-_b.Z
if math.sqrt(_bx*_bx+_bz*_bz)<=(tonumber(_G.EliteCloseBaseRange)or 100)then
_nearBase=true
end
end
end
local _armed=_G.EliteStealQuick~=true
local _mul=_armed and 1.5 or 1
if _nearBase then
if dist>(tonumber(_G.EliteNearBaseStealStart)or 80)*_mul then
return
end
elseif closing>(tonumber(_G.EliteFastApproach)or 150)then
if dist>(tonumber(_G.EliteStealLeadMax)or 420)*_mul then
return
end
if(dist/closing)>hold*lead+(tonumber(_G.EliteStealEarly)or 0.35)*_mul then
return
end
elseif closing>5 then
if dist>(tonumber(_G.EliteCloseProximity)or 40)*_mul then
return
end
else
if dist>_prox()*_mul then
return
end
end
end
_G.__EliteFireWhy=nil
if _fireSteal(pet)then
_G.__EliteStealWhy=nil
else
_G.__EliteStealWhy=_G.__EliteFireWhy or"waiting"
end
end
local _stealThrottle=0
RunService.Heartbeat:Connect(function()
local __t0=os.clock()
_stealThrottle=_stealThrottle+1
if _stealThrottle<(tonumber(_G.EliteStealTickEvery)or 1)then
return
end
_stealThrottle=0
_G.EliteProf.mark("steal tick",__t0)
pcall(_stealTick)
end)
task.spawn(function()
while true do
task.wait(tonumber(_G.EliteWatchdogTick)or 0.1)
if
_G.EliteStealMode~=nil
and _G.EliteStealWatchdog~=false
and not LP:GetAttribute("Stealing")
and not _holdBusy()
and(os.clock()-(_G.EliteLastFire or 0))>(tonumber(_G.EliteWatchdogGap)or 0.35)
then
local c=LP.Character
local h=c and c:FindFirstChild("HumanoidRootPart")
if h then
local pets=_scanCached(os.clock(),0.15)
local ok=pets~=nil
if ok and type(pets)=="table"then
local near,nd=nil,math.huge
local mp=h.Position
if _G.EliteStealMode=="nearest"then
for _,p in ipairs(pets)do
if not p.conveyor and p.position then
local d=(p.position-mp).Magnitude
if d<nd then
nd,near=d,p
end
end
end
else
local want=_armedPet or _stealTarget
local wuid=want and _petUid(want)
if wuid then
for _,p in ipairs(pets)do
if not p.conveyor and p.position and _petUid(p)==wuid then
near,nd=p,(p.position-mp).Magnitude
break
end
end
end
end
if near and nd<=_prox()then
pcall(_fireSteal,near)
end
end
end
end
end
end)
do
local function applyUnwalkAlways(char)
if not char then
return
end
local hum=char:FindFirstChildOfClass("Humanoid")
local animator=hum and hum:FindFirstChildOfClass("Animator")
local animate=char:FindFirstChild("Animate")
if animate then
animate.Disabled=true
end
if animator then
local ok,tracks=pcall(function()
return animator:GetPlayingAnimationTracks()
end)
if ok and tracks then
for _,t in ipairs(tracks)do
pcall(function()
t:Stop(0)
end)
end
end
end
end
local function hook(char)
task.spawn(function()
char:WaitForChild("Humanoid",10)
task.wait(0.05)
for i=1,8 do
if LP.Character~=char then
break
end
applyUnwalkAlways(char)
task.wait(0.25)
end
end)
end
if LP.Character then
hook(LP.Character)
end
LP.CharacterAdded:Connect(hook)
local _unwalkLast=0
RunService.Heartbeat:Connect(function()
local now=os.clock()
if now-_unwalkLast<1.5 then
return
end
if _eliteAnimRestoreAt and now<_eliteAnimRestoreAt then
return
end
_unwalkLast=now
if LP.Character then
applyUnwalkAlways(LP.Character)
end
end)
end
local HS=game:GetService("HttpService")
local UIS=game:GetService("UserInputService")
local CFG_FILE=_G.EliteConfigFile or"elitevpriv.config"
local function loadCfgTable()
local t={}
if readfile then
pcall(function()
local raw=readfile(CFG_FILE)
if type(raw)=="string"and#raw>0 then
local ok,d=pcall(HS.JSONDecode,HS,raw)
if ok and type(d)=="table"then
t=d
end
end
end)
end
return t
end
local function saveTpSettings()
if not writefile then
return
end
local t=loadCfgTable()
t.tpVelocity=tonumber(_G.TPVelocity)or 400
t.climbSpeed=tonumber(_G.EliteClimb)or 160
t.goSpeed=tonumber(_G.EliteGoSpeed)or 200
t.cframeSpeed=tonumber(_G.EliteCFrameSpeed)or 450
t.walkSpeed=tonumber(_G.EliteWalkSpeed)or 27
t.landingDelay=tonumber(_G.LandingDelay)or 0.35
t.closeSpeed=tonumber(_G.EliteCloseSpeed)or 80
t.problemBaseSpeed=tonumber(_G.EliteProblemBaseSpeed)or 60
t.slowCrossRow=_G.EliteSlowCrossRow==true
t.autoTp=_G.EliteAutoTP~=false
t.autoKickOnSteal=_G.EliteAutoKickOnSteal==true
t.kickToPS=_G.EliteKickToPS==true
t.psLink=tostring(_G.ElitePrivateServerLink or"")
t.priAlert=_G.ElitePriAlert==true
t.alertSound=tostring(_G.EliteAlertSound or"111786441593851")
t.alertMinGen=tonumber(_G.EliteAlertMinGen)or 80e6
t.walkSpeedOn=_G.EliteWalkSpeedOn~=false
t.xray=_G.EliteXray~=false
t.invisAuto=_G.EliteInvisAuto==true
t.quickPanel=_G.EliteQuickPanel~=false
t.priorityOnly=_G.ElitePriorityOnly~=false
t.prioMerged=_G.ElitePrioMerged==true
t.quickX=tonumber(_G._elite_quickX)
t.quickY=tonumber(_G._elite_quickY)
t.invisDepth=tonumber(_G.EliteInvisDepth)or 4.2
t.invisAngle=tonumber(_G.EliteInvisAngle)or 180
t.autoSteal=stealOn
t.tpKey=type(_G._stp_tpKeyName)=="string"and _G._stp_tpKeyName or nil
t.invisKey=type(_G.EliteInvisKey)=="string"and _G.EliteInvisKey or nil
t.wsKey=type(_G.EliteWalkSpeedKey)=="string"and _G.EliteWalkSpeedKey or nil
t.stealHud=_G.EliteStealHud~=false
t.scanDelay=tonumber(_G.EliteScanDelay)or 1
t.tpDelay=tonumber(_G._stp_tpDelay)or 0
t.themeName=_G.EliteThemeName
t.tgtW,t.tgtH=tonumber(_G._elite_tgtW),tonumber(_G._elite_tgtH)
t.mainW,t.mainH=tonumber(_G._elite_mainW),tonumber(_G._elite_mainH)
t.tweenTp=_G.EliteTweenTP==true
t.flashTp=_G.EliteFlashTP==true
t.flingTp=_G.EliteFlingTP==true
t.turretEsp=_G.EliteTurretESP~=false
t.flashFire=tonumber(_G.EliteFlashGroundWait)
t.flashEquip=tonumber(_G.EliteFlashPreEquip)
t.holdESP=_G.EliteHoldESP~=false
t.hideCheap=_G.EliteHideCheap~=false
t.tweenStage=tonumber(_G.EliteTweenStage)or 14
t.tweenNear=tonumber(_G.EliteTweenNear)or 40
t.invisAuto=_G.EliteInvisAuto==true
t.invisDepth=tonumber(_G.EliteInvisDepth)or 4.2
t.invisAngle=tonumber(_G.EliteInvisAngle)or 180
t.stealMode=_G.EliteStealMode or false
t.stealTargetUID=nil
t.accent=_G.EliteAccent
t.bgColor=_G.EliteBgColor
t.textColor=_G.EliteTextColor
t.stealLead=tonumber(_G.EliteStealLead)or 0.6
t.stealFireKey=type(_G.EliteStealFireKey)=="string"and _G.EliteStealFireKey or nil
t.priorityList=_G.SHARED_PRIORITY_ITEMS
t.mutationList=_G.SHARED_MUTATION_PRIORITY
do
local d={}
for name,on in pairs(_G.SHARED_MUTATION_DISABLED)do
if on then
d[#d+1]=name
end
end
t.mutationDisabled=d
end
t.traitList=_G.SHARED_TRAIT_PRIORITY
t.panelX=tonumber(_G._stp_panelX)
t.panelY=tonumber(_G._stp_panelY)
t.panelPos=_G._stp_pos
if type(_G.EliteCloneKeyName)=="string"then
t.cloneKey=_G.EliteCloneKeyName
else
t.cloneKey=nil
end
if type(_G.EliteKickKeyName)=="string"then
t.kickKey=_G.EliteKickKeyName
else
t.kickKey=nil
end
if type(_G.EliteStopTPKeyName)=="string"then
t.stopTpKey=_G.EliteStopTPKeyName
else
t.stopTpKey=nil
end
if type(_G.EliteNearestKey)=="string"then
t.nearestKey=_G.EliteNearestKey
else
t.nearestKey=nil
end
if type(_G.EliteDropKeyName)=="string"then
t.dropKey=_G.EliteDropKeyName
else
t.dropKey=nil
end
if type(_G.EliteResetKeyName)=="string"then
t.resetKey=_G.EliteResetKeyName
else
t.resetKey=nil
end
if type(_G.EliteCarpetSpeedKeyName)=="string"then
t.carpetSpeedKey=_G.EliteCarpetSpeedKeyName
else
t.carpetSpeedKey=nil
end
if type(_G.EliteStealQuickKey)=="string"then
t.stealQuickKey=_G.EliteStealQuickKey
else
t.stealQuickKey=nil
end
t.antiFlash=_G.EliteAntiFlash~=false
t.faceAway=_G.EliteFaceAway==true
t.faceAwayNearest=_G.EliteFaceAwayNearest==true
t.faceAwayDelay=tonumber(_G.EliteFaceAwayDelay)or 2
t.antiBee=_G.EliteAntiBee~=false
t.antiAFK=_G.EliteAntiAFK~=false
t.playerESP=_G.ElitePlayerESP~=false
t.noPetAnim=_G.EliteNoPetAnim~=false
t.infJump=_G.EliteInfJump~=false
t.antiDie=_G.AntiDieDisabled~=true
t.carpetSpeedValue=tonumber(_G.EliteCarpetSpeedValue)or 140
if type(_G.EliteCarpetTool)=="string"then
t.carpetTool=_G.EliteCarpetTool
else
t.carpetTool=nil
end
t.autoBuy=_G.EliteAutoBuy==true
t.autoBuyRange=tonumber(_G.EliteAutoBuyRange)or 17
t.autoBuyHover=tonumber(_G.EliteAutoBuyHover)or 9
t.exX=tonumber(_G._elite_exX)
t.exY=tonumber(_G._elite_exY)
t.fX=tonumber(_G._elite_fX)
t.fY=tonumber(_G._elite_fY)
t.kX=tonumber(_G._elite_kX)
t.kY=tonumber(_G._elite_kY)
pcall(function()
writefile(CFG_FILE,HS:JSONEncode(t))
end)
end
_G.EliteSaveSettings=saveTpSettings
if _G.TPVelocity==nil then
_G.TPVelocity=400
end
if _G.EliteClimb==nil then
_G.EliteClimb=160
end
if _G.EliteGoSpeed==nil then
_G.EliteGoSpeed=200
end
if _G.EliteCFrameSpeed==nil then
_G.EliteCFrameSpeed=450
end
if _G.EliteWalkSpeed==nil then
_G.EliteWalkSpeed=24
end
if _G.LandingDelay==nil then
_G.LandingDelay=0.35
end
if _G.EliteCloseSpeed==nil then
_G.EliteCloseSpeed=80
end
if _G.EliteProblemBaseSpeed==nil then
_G.EliteProblemBaseSpeed=60
end
if _G.EliteSlowCrossRow==nil then
_G.EliteSlowCrossRow=false
end
if _G.EliteInvisDepth==nil then
_G.EliteInvisDepth=4.2
end
if _G.EliteInvisAngle==nil then
_G.EliteInvisAngle=180
end
local TS=game:GetService("TweenService")
local EASE=TweenInfo.new(0.16,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)
local function tween(o,props)
TS:Create(o,EASE,props):Play()
end
UIS.InputChanged:Connect(function(i)
local f=_G.__eliteDragSlider
if not f then
return
end
if i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch then
f(i.Position.X)
end
end)
UIS.InputEnded:Connect(function(i)
if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
_G.__eliteDragSlider=nil
for _,stop in ipairs(_G.__eliteSliderStop or{})do
pcall(stop)
end
end
end)
local guiParent=(gethui and gethui())or game:GetService("CoreGui")
for _,par in ipairs({guiParent,PG})do
pcall(function()
local old=par:FindFirstChild(EN("EliteTP"))
if old then
old:Destroy()
end
local oldBar=par:FindFirstChild(EN("EliteTopBar"))
if oldBar then
oldBar:Destroy()
end
end)
end
local sg=mk("ScreenGui",nil,{
Name=EN("EliteTP"),
ResetOnSpawn=false,
IgnoreGuiInset=true,
DisplayOrder=999999,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
})
EliteParentGui(sg)
sg.Enabled=false
UIS.InputBegan:Connect(function(input,gameProcessed)
if gameProcessed then
return
end
if input.KeyCode==Enum.KeyCode.LeftControl or input.KeyCode==Enum.KeyCode.RightControl then
sg.Enabled=not sg.Enabled
end
end)
_G.EliteToggleUI=function()
sg.Enabled=not sg.Enabled
end
do
local btnSg=mk("ScreenGui",nil,{
Name=EN("EliteOpen"),
ResetOnSpawn=false,
IgnoreGuiInset=true,
DisplayOrder=1000000,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
})
EliteParentGui(btnSg)
if not btnSg.Parent then
pcall(function()
btnSg.Parent=(gethui and gethui())or game:GetService("CoreGui")
end)
end
local SZ=(UIS.TouchEnabled and not UIS.KeyboardEnabled)and 54 or 44
local b=corner(
mk("TextButton",btnSg,{
Name="Open",
Size=UDim2.fromOffset(SZ,SZ),
Position=UDim2.fromOffset(tonumber(_G._elite_btnX)or 16,tonumber(_G._elite_btnY)or 120),
BackgroundColor3=UIC.bg2,
Text="",
AutoButtonColor=false,
Active=true,
BorderSizePixel=0,
ZIndex=60,
}),
14
)
mk("UIStroke",b,{Color=UIC.line,Thickness=1,Transparency=0.5})
mk("TextLabel",b,{
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
Text="E",
Font=UIFB,
TextSize=18,
TextColor3=UIC.txt,
ZIndex=61,
})
local down,moved,from,base,trackIn
b.InputBegan:Connect(function(i)
if
i.UserInputType~=Enum.UserInputType.MouseButton1
and i.UserInputType~=Enum.UserInputType.Touch
then
return
end
down,moved,from,base=true,false,i.Position,b.Position
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End and down then
down=false
if not moved then
sg.Enabled=not sg.Enabled
end
_G._elite_btnX=b.Position.X.Offset
_G._elite_btnY=b.Position.Y.Offset
end
end)
end)
b.InputChanged:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
then
trackIn=i
end
end)
UIS.InputChanged:Connect(function(i)
if not down or i~=trackIn then
return
end
local d=i.Position-from
if math.abs(d.X)>6 or math.abs(d.Y)>6 then
moved=true
end
b.Position=UDim2.fromOffset(base.X.Offset+d.X,base.Y.Offset+d.Y)
end)
end
task.delay(0.03,function()
local okHud,errHud=pcall(function()
local hudSg=mk("ScreenGui",nil,{
Name=EN("EliteTopBar"),
ResetOnSpawn=false,
IgnoreGuiInset=true,
DisplayOrder=999998,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
Enabled=(_G.EliteStealHud~=false),
})
EliteParentGui(hudSg)
_G.EliteHudGui=hudSg
local sc=(UIS.TouchEnabled and not UIS.KeyboardEnabled)and 0.8 or 1
local card=corner(
mk("Frame",hudSg,{
Name="hudCardA",
AnchorPoint=tonumber(_G._elite_hudX)and Vector2.new(0,0)or Vector2.new(0.5,1),
Position=(tonumber(_G._elite_hudX)and UDim2.fromOffset(_G._elite_hudX,_G._elite_hudY))
or UDim2.new(0.5,0,1,(UIS.TouchEnabled and not UIS.KeyboardEnabled)and-175 or-135),
Size=UDim2.fromOffset(260*sc,52*sc),
BackgroundColor3=UIC.bg2,
BorderSizePixel=0,
Active=true,
ZIndex=70,
}),
math.floor(10*sc)
)
mk("UIStroke",card,{Color=UIC.edge,Thickness=1.4,Transparency=0.2})
local name=mk("TextLabel",card,{
Name="TargetName",
Size=UDim2.new(1,-74*sc,0,14*sc),
Position=UDim2.fromOffset(12*sc,9*sc),
BackgroundTransparency=1,
Font=UIFB,
TextSize=12*sc,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
Text="Searching...",
ZIndex=72,
})
local pct=mk("TextLabel",card,{
Name="Percent",
Size=UDim2.fromOffset(56*sc,14*sc),
Position=UDim2.new(1,-68*sc,0,9*sc),
BackgroundTransparency=1,
Font=UIFB,
TextSize=12*sc,
TextColor3=UIC.acc2,
TextXAlignment=Enum.TextXAlignment.Right,
Text="0%",
ZIndex=72,
})
local track=mk("Frame",card,{
Name="ProgressBg",
Size=UDim2.new(1,-24*sc,0,6*sc),
Position=UDim2.fromOffset(12*sc,28*sc),
BackgroundColor3=UIC.card,
BorderSizePixel=0,
ZIndex=72,
})
mk("UICorner",track,{CornerRadius=UDim.new(1,0)})
local fill=mk("Frame",track,{
Name="ProgressFill",
Size=UDim2.new(0,0,1,0),
BackgroundColor3=UIC.acc,
BorderSizePixel=0,
ZIndex=73,
})
mk("UICorner",fill,{CornerRadius=UDim.new(1,0)})
mk("TextLabel",card,{
Size=UDim2.new(1,-24*sc,0,10*sc),
Position=UDim2.fromOffset(12*sc,38*sc),
BackgroundTransparency=1,
Font=UIF,
TextSize=8*sc,
TextColor3=UIC.dim,
TextXAlignment=Enum.TextXAlignment.Left,
Text="ELITE  •  @gsx_xog",
ZIndex=72,
})
_G.EliteHudSteal=function(nm,txt,frac)
if nm~=nil then
name.Text=(nm~=""and tostring(nm))or"Searching..."
if nm==""then
_G.__EliteHudName=nil
end
end
if txt then
pct.Text=txt
end
if frac then
frac=math.clamp(frac,0,1)
fill.Size=UDim2.new(frac,0,1,0)
fill.BackgroundColor3=(frac>=1)and UIC.acc2 or UIC.acc
end
end
LP:GetAttributeChangedSignal("Stealing"):Connect(function()
if LP:GetAttribute("Stealing")==true then
name.Text,pct.Text="Carrying Brainrot!","100%"
_G.__EliteHudName=nil
fill.Size,fill.BackgroundColor3=UDim2.new(1,0,1,0),UIC.acc2
end
end)
local drag,from,base
card.InputBegan:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
then
drag,from=true,i.Position
local ap=card.AbsolutePosition
card.AnchorPoint=Vector2.new(0,0)
card.Position=UDim2.fromOffset(ap.X,ap.Y)
base=card.Position
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End then
drag=false
_G._elite_hudX,_G._elite_hudY=card.Position.X.Offset,card.Position.Y.Offset
end
end)
end
end)
UIS.InputChanged:Connect(function(i)
if not drag then
return
end
if
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
then
local d=i.Position-from
card.Position=UDim2.fromOffset(base.X.Offset+d.X,base.Y.Offset+d.Y)
end
end)
end)
if not okHud then
warn("[ELITE] steal HUD failed: "..tostring(errHud))
end
end)
task.delay(0.06,function()
pcall(function()
local q=(UIS.TouchEnabled and not UIS.KeyboardEnabled)and 0.85 or 1
local qsg=mk("ScreenGui",nil,{
Name=EN("EliteQuick"),
ResetOnSpawn=false,
IgnoreGuiInset=true,
DisplayOrder=999997,
Enabled=(_G.EliteQuickPanel~=false),
})
EliteParentGui(qsg)
_G.EliteQuickGui=qsg
_G.EliteSetQuickPanel=function(on)
_G.EliteQuickPanel=on and true or false
qsg.Enabled=_G.EliteQuickPanel
end
local H,ROWS=30*q,8
local panel=corner(
mk("Frame",qsg,{
Position=(
tonumber(_G._elite_quickX)and UDim2.fromOffset(_G._elite_quickX,_G._elite_quickY)
)or UDim2.new(0,16,0.5,-140*q),
Size=UDim2.fromOffset(200*q,34*q+ROWS*(H+4*q)+2*q),
BackgroundColor3=UIC.bg,
BorderSizePixel=0,
Active=true,
}),
6
)
mk("UIStroke",panel,{Color=UIC.edge,Thickness=1.4,Transparency=0.2})
local head=mk("TextLabel",panel,{
Size=UDim2.new(1,-20,0,30*q),
Position=UDim2.fromOffset(10,2),
BackgroundTransparency=1,
Active=true,
Font=UIFB,
TextSize=13*q,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
Text="QUICK",
})
local refreshers={}
local function save()
pcall(saveTpSettings)
end
local function row(i,tag)
local r=corner(
mk("Frame",panel,{
Size=UDim2.new(1,-12,0,H),
Position=UDim2.fromOffset(6,34*q+(i-1)*(H+4*q)),
BackgroundColor3=UIC.card,
BorderSizePixel=0,
}),
6
)
mk("TextLabel",r,{
Size=UDim2.new(1,-100*q,1,0),
Position=UDim2.fromOffset(8,0),
BackgroundTransparency=1,
Font=UIF,
TextSize=11*q,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
Text=tag,
})
return r
end
local function switch(i,tag,get,flip)
local sw=corner(
mk("TextButton",row(i,tag),{
Size=UDim2.fromOffset(50*q,22*q),
Position=UDim2.new(1,-56*q,0.5,-11*q),
BorderSizePixel=0,
AutoButtonColor=false,
Font=UIFB,
TextSize=11*q,
Text="",
}),
6
)
local function refresh()
local on=get()==true
sw.Text=on and"ON"or"OFF"
sw.BackgroundColor3=on and UIC.acc or UIC.track
sw.TextColor3=on and UIC.bg or UIC.dim
end
sw.MouseButton1Click:Connect(function()
pcall(flip)
save()
refresh()
end)
refresh()
refreshers[#refreshers+1]=refresh
end
local function stepper(i,tag,get,set,step,lo,hi,fmt)
local r=row(i,tag)
local val=mk("TextLabel",r,{
Size=UDim2.fromOffset(36*q,H),
Position=UDim2.new(1,-62*q,0,0),
BackgroundTransparency=1,
Font=UIFB,
TextSize=11*q,
TextColor3=UIC.acc,
Text="",
})
local function refresh()
val.Text=string.format(fmt,tonumber(get())or lo)
end
for k,d in ipairs({-step,step})do
local b=corner(
mk("TextButton",r,{
Size=UDim2.fromOffset(22*q,22*q),
Position=UDim2.new(1,(k==1)and-86*q or-26*q,0.5,-11*q),
BackgroundColor3=UIC.hover,
BorderSizePixel=0,
Font=UIFB,
TextSize=13*q,
TextColor3=UIC.txt,
Text=(k==1)and"-"or"+",
}),
6
)
b.MouseButton1Click:Connect(function()
set(math.floor(math.clamp((tonumber(get())or lo)+d,lo,hi)/step+0.5)*step)
save()
refresh()
end)
end
refresh()
refreshers[#refreshers+1]=refresh
end
switch(1,"INVIS",function()
return _G.EliteInvisActive==true
end,function()
if _G.EliteInvisToggle then
_G.EliteInvisToggle()
end
end)
switch(2,"AUTO INVIS",function()
return _G.EliteInvisAuto==true
end,function()
_G.EliteInvisAuto=not(_G.EliteInvisAuto==true)
end)
stepper(3,"INVIS DEPTH",function()
return _G.EliteInvisDepth or 7
end,function(v)
_G.EliteInvisDepth=v
end,0.5,0,10,"%.1f")
stepper(4,"ROTATION",function()
return _G.EliteInvisAngle or 180
end,function(v)
_G.EliteInvisAngle=v
end,15,0,360,"%.0f")
switch(5,"STEAL SPEED",function()
return _G.EliteWalkSpeedOn~=false
end,function()
local on=not(_G.EliteWalkSpeedOn~=false)
if _G.EliteSetWalkSpeed then
_G.EliteSetWalkSpeed(on)
else
_G.EliteWalkSpeedOn=on
end
end)
stepper(6,"WALKSPEED",function()
return _G.EliteWalkSpeed or 26
end,function(v)
_G.EliteWalkSpeed=v
end,1,16,32,"%.0f")
switch(7,"AUTO KICK",function()
return _G.EliteAutoKickOnSteal==true
end,function()
_G.EliteAutoKickOnSteal=not(_G.EliteAutoKickOnSteal==true)
end)
switch(8,"AUTO BUY",function()
return _G.EliteAutoBuy==true
end,function()
_G.EliteAutoBuy=not(_G.EliteAutoBuy==true)
end)
task.spawn(function()
while qsg.Parent do
task.wait(0.5)
if qsg.Enabled then
for _,f in ipairs(refreshers)do
pcall(f)
end
end
end
end)
local drag,from,base=false,nil,nil
head.InputBegan:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
then
drag,from,base=true,i.Position,panel.Position
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End and drag then
drag=false
_G._elite_quickX,_G._elite_quickY=panel.AbsolutePosition.X,panel.AbsolutePosition.Y
save()
end
end)
end
end)
UIS.InputChanged:Connect(function(i)
if
drag
and(
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
)
then
local d=i.Position-from
panel.Position=UDim2.new(base.X.Scale,base.X.Offset+d.X,base.Y.Scale,base.Y.Offset+d.Y)
end
end)
end)
end)
task.spawn(function()
local Plr=game:GetService("Players").LocalPlayer
local function ownedTool()
local ch,bp=Plr.Character,Plr:FindFirstChild("Backpack")
for _,n in ipairs(CARPET_NAMES)do
local t=(ch and ch:FindFirstChild(n))or(bp and bp:FindFirstChild(n))
if t and t:IsA("Tool")then
return n
end
end
end
local function pick()
local n=ownedTool()
if n and n~=_G.EliteCarpetTool then
setCarpetTool(n)
if _G.EliteSaveSettings then
pcall(_G.EliteSaveSettings)
end
end
end
local function hook(bag)
if not bag then
return
end
bag.ChildAdded:Connect(function()
task.defer(pick)
end)
bag.ChildRemoved:Connect(function()
task.defer(pick)
end)
end
task.defer(pick)
hook(Plr:FindFirstChild("Backpack")or Plr:WaitForChild("Backpack",20))
Plr.CharacterAdded:Connect(function(c)
task.wait(1)
pick()
hook(c)
end)
while true do
task.wait(10)
pick()
end
end)
local _mainBuilt=false
local function buildMain()
if _mainBuilt then
return
end
_mainBuilt=true
local MOBILE=UIS.TouchEnabled and not UIS.KeyboardEnabled
local W,H,PAD,TABH,ROWH=
MOBILE and 352 or 340,MOBILE and 430 or 400,12,MOBILE and 36 or 32,MOBILE and 36 or 30
local root=mk("Frame",sg,{
Name="Root",
Active=true,
BackgroundTransparency=1,
Size=UDim2.fromOffset(W,H),
Position=UDim2.fromOffset(tonumber(_G._stp_panelX)or 40,tonumber(_G._stp_panelY)or 160),
})
local card=corner(
mk("Frame",root,{
BackgroundColor3=UIC.bg,
BorderSizePixel=0,
Size=UDim2.fromScale(1,1),
ClipsDescendants=true,
ZIndex=1,
}),
12
)
_G.EliteAnimBorder(card,1.6,UIC.edge)
local rail=mk("Frame",card,{
Name="Header",
Size=UDim2.new(1,0,0,46),
BackgroundTransparency=1,
ZIndex=2,
})
corner(
mk("Frame",rail,{
Size=UDim2.fromOffset(3,24),
Position=UDim2.fromOffset(14,11),
BackgroundColor3=UIC.acc,
BorderSizePixel=0,
ZIndex=3,
}),
2
)
mk("TextLabel",rail,{
Name="Wordmark",
Size=UDim2.fromOffset(110,18),
Position=UDim2.fromOffset(26,9),
BackgroundTransparency=1,
Text="ELITE HUB",
Font=UIFB,
TextSize=16,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=3,
})
local badge=corner(
mk("Frame",rail,{
Size=UDim2.fromOffset(50,13),
Position=UDim2.fromOffset(27,28),
BackgroundColor3=UIC.input,
BorderSizePixel=0,
ZIndex=3,
}),
4
)
mk("UIStroke",badge,{Color=UIC.acc,Thickness=1,Transparency=0.55})
mk("TextLabel",badge,{
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
Text="PRIVATE",
Font=UIFB,
TextSize=8,
TextColor3=UIC.acc,
ZIndex=4,
})
local pill=corner(
mk("Frame",rail,{
Size=UDim2.fromOffset(92,30),
Position=UDim2.new(1,-136,0,8),
BackgroundColor3=UIC.input,
BorderSizePixel=0,
ZIndex=3,
}),
8
)
mk("UIStroke",pill,{Color=UIC.line,Thickness=1,Transparency=0.3})
local stats=mk("TextLabel",pill,{
Size=UDim2.new(1,-16,1,-6),
Position=UDim2.fromOffset(8,3),
BackgroundTransparency=1,
Text="FPS: --\nPING: --",
Font=Enum.Font.Code,
TextSize=9,
TextColor3=UIC.dim,
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=4,
})
do
local frames,since,pingItem=0,0,nil
RunService.Heartbeat:Connect(function(dt)
if not sg.Enabled then
frames,since=0,0
return
end
frames,since=frames+1,since+dt
if since<0.5 then
return
end
local fps=math.floor(frames/since+0.5)
frames,since=0,0
if not pingItem then
pcall(function()
pingItem=game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
end)
end
local ok,v=pcall(function()
return pingItem:GetValue()
end)
stats.Text=("FPS: %d\nPING: %s"):format(fps,ok and(math.floor(v+0.5).."ms")or"--")
end)
end
local cls=corner(
mk("TextButton",rail,{
Name="WhiteTextBtn",
Size=UDim2.fromOffset(30,30),
Position=UDim2.new(1,-40,0,8),
BackgroundColor3=UIC.card,
Text="X",
TextColor3=Color3.new(1,1,1),
Font=UIFB,
TextSize=11,
AutoButtonColor=false,
Active=true,
ZIndex=5,
}),
8
)
cls.MouseEnter:Connect(function()
cls.BackgroundColor3=UIC.red
end)
cls.MouseLeave:Connect(function()
cls.BackgroundColor3=UIC.card
end)
cls.MouseButton1Click:Connect(function()
sg.Enabled=false
end)
mk("Frame",card,{
Name="HeaderRule",
Size=UDim2.new(1,-24,0,1),
Position=UDim2.fromOffset(12,46),
BackgroundColor3=UIC.line,
BorderSizePixel=0,
ZIndex=2,
})
local tabStrip=corner(
mk("Frame",card,{
Name="NavRail",
Size=UDim2.new(1,-20,0,32),
Position=UDim2.fromOffset(10,54),
BackgroundColor3=UIC.card,
BackgroundTransparency=0.4,
BorderSizePixel=0,
ZIndex=2,
}),
8
)
mk("UIPadding",tabStrip,{
PaddingLeft=UDim.new(0,3),
PaddingRight=UDim.new(0,3),
PaddingTop=UDim.new(0,3),
PaddingBottom=UDim.new(0,3),
})
mk("UIListLayout",tabStrip,{
FillDirection=Enum.FillDirection.Horizontal,
Padding=UDim.new(0,3),
SortOrder=Enum.SortOrder.LayoutOrder,
})
local body=mk("Frame",card,{
Position=UDim2.fromOffset(0,94),
Size=UDim2.new(1,0,1,-94),
BackgroundTransparency=1,
ZIndex=2,
})
do
if tonumber(_G._elite_mainW)then
root.Size=UDim2.fromOffset(_G._elite_mainW,_G._elite_mainH)
end
local g=mk("TextButton",card,{
Name="uiSizeGrip",
Size=UDim2.fromOffset(26,26),
Position=UDim2.new(1,-26,1,-26),
BackgroundTransparency=1,
Text="",
AutoButtonColor=false,
Active=true,
ZIndex=100,
})
local dots={
corner(
mk("Frame",g,{
Size=UDim2.fromOffset(10,10),
Position=UDim2.fromOffset(12,12),
BackgroundColor3=UIC.acc2,
BackgroundTransparency=0.35,
BorderSizePixel=0,
ZIndex=101,
}),
3
),
}
local function dotsT(t)
for _,d in ipairs(dots)do
d.BackgroundTransparency=t
end
end
g.MouseEnter:Connect(function()
dotsT(0)
end)
g.MouseLeave:Connect(function()
dotsT(0.35)
end)
local sizing,from,base
g.InputBegan:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
then
sizing,from,base=true,i.Position,root.AbsoluteSize
dotsT(0)
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End then
sizing=false
dotsT(0.35)
_G._elite_mainW,_G._elite_mainH=root.AbsoluteSize.X,root.AbsoluteSize.Y
pcall(saveTpSettings)
end
end)
end
end)
UIS.InputChanged:Connect(function(i)
if not sizing then
return
end
if
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
then
local d=i.Position-from
root.Size=UDim2.fromOffset(math.max(300,base.X+d.X),math.max(300,base.Y+d.Y))
end
end)
end
local pages,tabs={},{}
local tabOpenHook={}
local tabCount=0
local function selectTab(name)
local _h=tabOpenHook[name]
if _h then
tabOpenHook[name]=nil
pcall(_h)
end
for n,p in pairs(pages)do
p.Visible=(n==name)
end
for n,t in pairs(tabs)do
local on=(n==name)
t.btn.BackgroundTransparency=on and 0 or 1
t.lbl.TextColor3=on and UIC.txt or UIC.dim
tween(t.mark,{Size=UDim2.new(on and 0.55 or 0,0,0,3)})
end
end
local function tab(name,order)
tabCount=tabCount+1
local b=corner(
mk("TextButton",tabStrip,{
Name="Nav_"..name,
Size=UDim2.new(0.5,-2,1,0),
LayoutOrder=order or tabCount,
BackgroundColor3=UIC.card,
BackgroundTransparency=1,
Text="",
AutoButtonColor=false,
Active=true,
BorderSizePixel=0,
ZIndex=3,
}),
6
)
local mark=corner(
mk("Frame",b,{
Name="Mark",
AnchorPoint=Vector2.new(0.5,1),
Size=UDim2.new(0,0,0,3),
Position=UDim2.new(0.5,0,1,-2),
BackgroundColor3=UIC.acc,
BorderSizePixel=0,
ZIndex=4,
}),
1
)
local lbl=mk("TextLabel",b,{
Name="Label",
Size=UDim2.new(1,-4,1,-6),
Position=UDim2.fromOffset(2,0),
BackgroundTransparency=1,
Text=string.upper(name),
Font=UIFB,
TextColor3=UIC.dim,
TextScaled=true,
ZIndex=4,
})
mk("UITextSizeConstraint",lbl,{MinTextSize=7,MaxTextSize=12})
local page=mk("ScrollingFrame",body,{
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
BorderSizePixel=0,
Visible=false,
ScrollBarThickness=2,
ScrollBarImageColor3=UIC.acc,
CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,
ZIndex=2,
})
mk("UIPadding",page,{
PaddingLeft=UDim.new(0,PAD),
PaddingRight=UDim.new(0,PAD),
PaddingTop=UDim.new(0,2),
PaddingBottom=UDim.new(0,PAD),
})
mk("UIListLayout",page,{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
tabs[name],pages[name]={btn=b,lbl=lbl,mark=mark},page
b.MouseButton1Click:Connect(function()
selectTab(name)
end)
b.MouseEnter:Connect(function()
if not pages[name].Visible then
b.BackgroundTransparency=0.4
end
end)
b.MouseLeave:Connect(function()
if not pages[name].Visible then
b.BackgroundTransparency=1
end
end)
for _,t in pairs(tabs)do
t.btn.Size=UDim2.new(1/tabCount,-3,1,0)
end
return page
end
local function label(parent,txt,first)
return mk("TextLabel",parent,{
Size=UDim2.new(1,0,0,first and 18 or 24),
BackgroundTransparency=1,
Text=string.upper(txt),
Font=UIFB,
TextSize=11,
TextColor3=UIC.dim,
TextXAlignment=Enum.TextXAlignment.Left,
TextYAlignment=Enum.TextYAlignment.Bottom,
ZIndex=2,
})
end
local function shell(parent,h)
local row=corner(
mk("Frame",parent,{
Size=UDim2.new(1,0,0,h or ROWH),
BackgroundColor3=UIC.card,
BackgroundTransparency=0.5,
BorderSizePixel=0,
Active=true,
ZIndex=2,
}),
6
)
return row,row
end
local function toggle(parent,txt,get,fn)
local row=shell(parent,ROWH)
local hit=mk("TextButton",row,{
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
Text="",
Active=true,
AutoButtonColor=false,
ZIndex=5,
})
mk("TextLabel",row,{
Size=UDim2.new(1,-84,1,0),
Position=UDim2.fromOffset(14,-1),
BackgroundTransparency=1,
Text=string.upper(txt),
Font=UIF,
TextSize=12,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=4,
})
local W2,H2=MOBILE and 44 or 38,MOBILE and 24 or 20
local K=H2-4
local chip=corner(
mk("Frame",row,{
Size=UDim2.fromOffset(W2,H2),
Position=UDim2.new(1,-(W2+10),0.5,-H2/2),
BackgroundColor3=UIC.track,
BorderSizePixel=0,
ZIndex=4,
}),
H2/2
)
local knob=corner(
mk("Frame",chip,{
Size=UDim2.fromOffset(K,K),
Position=UDim2.new(0,2,0.5,-K/2),
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
ZIndex=5,
}),
K/2
)
local function paint(instant)
local v=get()and true or false
local c=v and UIC.acc or UIC.track
pcall(function()
knob.BackgroundColor3=v and UIC.bg or Color3.new(1,1,1)
end)
local pos=v and UDim2.new(1,-(K+3),0.5,-K/2)or UDim2.new(0,3,0.5,-K/2)
if instant then
chip.BackgroundColor3,knob.Position=c,pos
else
tween(chip,{BackgroundColor3=c})
tween(knob,{Position=pos})
end
end
hit.MouseEnter:Connect(function()
tween(row,{BackgroundTransparency=0.2})
end)
hit.MouseLeave:Connect(function()
tween(row,{BackgroundTransparency=0.5})
end)
hit.MouseButton1Click:Connect(function()
fn()
paint()
end)
paint(true)
return paint
end
local function input(parent,txt,hint,get,set)
local card2=shell(parent,52)
mk("TextLabel",card2,{
Size=UDim2.new(1,-24,0,12),
Position=UDim2.fromOffset(14,8),
BackgroundTransparency=1,
Text=txt,
Font=UIF,
TextSize=11,
TextColor3=UIC.dim,
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=3,
})
local box=mk("TextBox",card2,{
Size=UDim2.new(1,-24,0,20),
Position=UDim2.fromOffset(14,24),
BackgroundTransparency=1,
Font=UIFB,
TextSize=12,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
PlaceholderText=hint,
PlaceholderColor3=UIC.line,
ClearTextOnFocus=false,
Text=tostring(get()or""),
TextTruncate=Enum.TextTruncate.AtEnd,
Active=true,
ZIndex=4,
})
box.FocusLost:Connect(function()
set(box.Text)
end)
return box
end
local function slider(parent,txt,min,max,get,set,step)
step=step or 1
local row=shell(parent,62)
row.BackgroundTransparency=0
mk("TextLabel",row,{
Size=UDim2.new(1,-90,0,20),
Position=UDim2.fromOffset(16,10),
BackgroundTransparency=1,
Text=string.upper(txt),
Font=UIFB,
TextSize=14,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=4,
})
local val=mk("TextLabel",row,{
AnchorPoint=Vector2.new(1,0),
Position=UDim2.new(1,-30,0,10),
Size=UDim2.fromOffset(60,20),
BackgroundTransparency=1,
Font=UIFB,
TextSize=14,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Right,
ZIndex=4,
})
local hitPad=mk("TextButton",row,{
Position=UDim2.new(0,16,0,30),
Size=UDim2.new(1,-32,0,28),
BackgroundTransparency=1,
Text="",
AutoButtonColor=false,
Active=true,
ZIndex=4,
})
local track=corner(
mk("TextButton",row,{
Position=UDim2.new(0,16,0,40),
Size=UDim2.new(1,-32,0,10),
BackgroundColor3=UIC.track,
Text="",
AutoButtonColor=false,
Active=true,
BorderSizePixel=0,
ZIndex=4,
}),
5
)
local fill=corner(
mk("Frame",track,{
Size=UDim2.new(0,0,1,0),
BackgroundColor3=UIC.acc,
BorderSizePixel=0,
ZIndex=5,
}),
5
)
local knob=corner(
mk("Frame",track,{
Name="WhiteSliderKnob",
Size=UDim2.fromOffset(24,24),
AnchorPoint=Vector2.new(0.5,0.5),
Position=UDim2.new(0,0,0.5,0),
BackgroundColor3=Color3.new(1,1,1),
BorderSizePixel=0,
ZIndex=6,
}),
12
)
local function refresh()
local v=math.clamp(tonumber(get())or min,min,max)
local rel=(v-min)/math.max(max-min,1e-6)
fill.Size=UDim2.new(rel,0,1,0)
knob.Position=UDim2.new(rel,0,0.5,0)
val.Text=step<1 and string.format("%.2f",v)or tostring(math.floor(v+0.5))
end
local function applyAt(x)
local rel=math.clamp((x-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
set(math.clamp(math.floor((min+(max-min)*rel)/step+0.5)*step,min,max))
refresh()
end
local sliding=false
local function grab(i)
if
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
then
sliding=true
_G.__eliteDragSlider=applyAt
applyAt(i.Position.X)
end
end
hitPad.InputBegan:Connect(grab)
track.InputBegan:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
then
sliding=true
_G.__eliteDragSlider=applyAt
applyAt(i.Position.X)
end
end)
_G.__eliteSliderStop=_G.__eliteSliderStop or{}
_G.__eliteSliderStop[#_G.__eliteSliderStop+1]=function()
sliding=false
end
UIS.InputEnded:Connect(function(i)
if
sliding
and(
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
)
then
sliding=false
saveTpSettings()
end
end)
refresh()
end
do
local dragging,dragStart,startPos,dragInput
card.Active=true
rail.Active,body.Active=true,true
local function begin(i)
if
i.UserInputType~=Enum.UserInputType.MouseButton1
and i.UserInputType~=Enum.UserInputType.Touch
then
return
end
dragging,dragStart,startPos=true,i.Position,root.Position
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End and dragging then
dragging=false
_G._stp_panelX=root.Position.X.Offset
_G._stp_panelY=root.Position.Y.Offset
saveTpSettings()
end
end)
end
local function track(i)
if
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
then
dragInput=i
end
end
for _,o in ipairs({card,rail,body})do
o.InputBegan:Connect(begin)
o.InputChanged:Connect(track)
end
UIS.InputChanged:Connect(function(i)
if not dragging or i~=dragInput then
return
end
local d=i.Position-dragStart
root.Position=UDim2.fromOffset(startPos.X.Offset+d.X,startPos.Y.Offset+d.Y)
end)
end
local home=tab("Home",1)
local tune=home
label(home,"general",true)
_G.EliteRepaintAutoTP=toggle(home,"AUTO TP",function()
return _G.EliteAutoTP~=false
end,function()
_G.EliteAutoTP=not(_G.EliteAutoTP~=false)
saveTpSettings()
end)
toggle(home,"AUTO STEAL",function()
return _G.EliteStealMode~=nil
end,function()
if _G.EliteStealMode~=nil then
_G.__EliteLastMode=_G.EliteStealMode
_G.EliteStealMode=nil
else
_G.EliteStealMode=_G.__EliteLastMode or"priority"
end
saveTpSettings()
end)
toggle(home,"STEAL HUD",function()
return _G.EliteStealHud~=false
end,function()
_G.EliteStealHud=not(_G.EliteStealHud~=false)
if _G.EliteHudGui then
_G.EliteHudGui.Enabled=_G.EliteStealHud
end
saveTpSettings()
end)
toggle(home,"QUICK PANEL",function()
return _G.EliteQuickPanel~=false
end,function()
local on=not(_G.EliteQuickPanel~=false)
if _G.EliteSetQuickPanel then
_G.EliteSetQuickPanel(on)
else
_G.EliteQuickPanel=on
end
saveTpSettings()
end)
toggle(home,"NEAREST MODE (OFF = PRIORITY)",function()
return _G.EliteStealMode=="nearest"
end,function()
_G.EliteStealMode=(_G.EliteStealMode=="nearest")and"priority"or"nearest"
saveTpSettings()
end)
label(home,"movement",true)
toggle(home,"INFINITE JUMP",function()
return _G.EliteInfJump~=false
end,function()
_G.EliteInfJump=not(_G.EliteInfJump~=false)
saveTpSettings()
end)
local function bindRow(page,title,getKey,setKey)
local row=shell(page,ROWH)
mk("TextLabel",row,{
Size=UDim2.new(1,-90,1,0),
Position=UDim2.fromOffset(12,0),
BackgroundTransparency=1,
Text=title,
Font=UIF,
TextSize=11,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=4,
})
local chip=corner(
mk("TextButton",row,{
AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-12,0.5,0),
Size=UDim2.fromOffset(MOBILE and 64 or 56,MOBILE and 24 or 20),
BackgroundColor3=UIC.track,
Text="",
AutoButtonColor=false,
Active=true,
ZIndex=5,
}),
6
)
local txt=mk("TextLabel",chip,{
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
Font=UIFB,
TextSize=10,
TextColor3=UIC.txt,
ZIndex=6,
Text=tostring(getKey()),
})
local listening=false
chip.MouseButton1Click:Connect(function()
if listening or _G.EliteBindListening then
return
end
listening,_G.EliteBindListening=true,true
txt.Text="..."
chip.BackgroundColor3,txt.TextColor3=UIC.acc,UIC.bg
local conn
local function stop()
listening,_G.EliteBindListening=false,false
chip.BackgroundColor3,txt.TextColor3=UIC.track,UIC.txt
txt.Text=tostring(getKey())
if conn then
conn:Disconnect()
conn=nil
end
end
conn=UIS.InputBegan:Connect(function(i,typing)
if typing or i.UserInputType~=Enum.UserInputType.Keyboard then
return
end
local n=i.KeyCode.Name
if n=="Unknown"then
return
end
if n~="Escape"then
setKey(n)
pcall(saveTpSettings)
end
stop()
end)
task.delay(5,function()
if listening then
stop()
end
end)
end)
end
label(tune,"tp method")
toggle(home,"TWEEN TP",function()
return _G.EliteTweenTP==true
end,function()
_G.EliteTweenTP=not(_G.EliteTweenTP==true)
saveTpSettings()
end)
toggle(home,"FLING TP",function()
return _G.EliteFlingTP==true
end,function()
_G.EliteFlingTP=not(_G.EliteFlingTP==true)
saveTpSettings()
end)
toggle(home,"FLASH TP",function()
return _G.EliteFlashTP==true
end,function()
_G.EliteFlashTP=not(_G.EliteFlashTP==true)
saveTpSettings()
end)
do
local defs={
{"FIRE","EliteFlashGroundWait",0.12,0,0.25,2},
{"EQUIP","EliteFlashPreEquip",50,0,60},
}
local row=shell(home,64)
row.BackgroundTransparency=0
mk("TextLabel",row,{
Size=UDim2.new(1,-32,0,18),
Position=UDim2.fromOffset(16,6),
BackgroundTransparency=1,
Text="FLASH TUNING",
Font=UIFB,
TextSize=14,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=4,
})
local grid=mk("Frame",row,{
Position=UDim2.fromOffset(16,28),
Size=UDim2.new(1,-32,0,30),
BackgroundTransparency=1,
ZIndex=4,
})
mk("UIGridLayout",grid,{
CellSize=UDim2.new(1/#defs,-5,0,30),
CellPadding=UDim2.fromOffset(5,0),
SortOrder=Enum.SortOrder.LayoutOrder,
})
for i,d in ipairs(defs)do
local function fmt(v)
v=tonumber(v)or d[3]
if d[6]then return string.format("%."..d[6].."f",v)end
return tostring(math.floor(v+0.5))
end
local cell=corner(mk("Frame",grid,{
BackgroundColor3=UIC.track,
BorderSizePixel=0,
LayoutOrder=i,
ZIndex=4,
}),5)
mk("TextLabel",cell,{
Size=UDim2.new(1,0,0,11),
Position=UDim2.fromOffset(0,2),
BackgroundTransparency=1,
Text=d[1],
Font=UIFB,
TextSize=9,
TextColor3=UIC.txt,
TextTransparency=0.4,
ZIndex=5,
})
local box=mk("TextBox",cell,{
Size=UDim2.new(1,-4,0,16),
Position=UDim2.fromOffset(2,13),
BackgroundTransparency=1,
Text=fmt(_G[d[2]]),
Font=UIFB,
TextSize=13,
TextColor3=UIC.txt,
ClearTextOnFocus=false,
ZIndex=5,
})
box.FocusLost:Connect(function()
local v=tonumber(box.Text)
if v then
v=math.clamp(v,d[4],d[5])
if not d[6]then v=math.floor(v+0.5)end
_G[d[2]]=v
pcall(saveTpSettings)
end
box.Text=fmt(_G[d[2]])
end)
end
end
slider(home,"Tween Snap (studs)",20,60,function()
return _G.EliteTweenNear or 40
end,function(v)
_G.EliteTweenNear=v
saveTpSettings()
end,1)
slider(home,"Tween Hop (studs/frame)",3,40,function()
return tonumber(_G.EliteTweenStage)or 14
end,function(v)
_G.EliteTweenStage=v
saveTpSettings()
end,1)
label(tune,"tuning")
for _,s in ipairs({
{"TP Velocity",200,750,"TPVelocity",5},
{"Rise Speed",100,250,"EliteClimb",5},
{"Go To Brainrot Speed",80,600,"EliteGoSpeed",5},
{"Landing Delay",0.01,1.0,"LandingDelay",0.01},
{"100 Studs Base Speed",20,400,"EliteCloseSpeed",5},
})do
slider(tune,s[1],s[2],s[3],function()
return _G[s[4]]
end,function(v)
_G[s[4]]=v
end,s[5])
end
local pri=tab("Priority",2)
toggle(pri,"PRIORITY ONLY",function()
return _G.ElitePriorityOnly~=false
end,function()
_G.ElitePriorityOnly=not(_G.ElitePriorityOnly~=false)
saveTpSettings()
end)
local refreshPri,currentPriTab=nil,"brainrot"
local function mkSubTabs(parent)
local tabsFrame=mk("Frame",parent,{
Size=UDim2.new(1,0,0,26),
BackgroundTransparency=1,
})
local names={"Brainrots","Mutations"}
local w=1/#names
for i,n in ipairs(names)do
local b=corner(
mk("TextButton",tabsFrame,{
Size=UDim2.new(w,-4,1,0),
Position=UDim2.new(w*(i-1),2,0,0),
BackgroundColor3=UIC.acc,
Text=n,
Font=UIFB,
TextSize=11,
TextColor3=UIC.bg,
AutoButtonColor=false,
Active=true,
ZIndex=3,
}),
6
)
b.MouseButton1Click:Connect(function()
currentPriTab=n:lower():gsub("s$","")
for _,c in ipairs(tabsFrame:GetChildren())do
if c:IsA("TextButton")then
c.BackgroundColor3=(c==b)and UIC.acc or UIC.track
c.TextColor3=(c==b)and UIC.bg or UIC.txt
end
end
if refreshPri then
refreshPri()
end
end)
if i==1 then
b.BackgroundColor3,b.TextColor3=UIC.acc,UIC.bg
else
b.BackgroundColor3,b.TextColor3=UIC.track,UIC.txt
end
end
end
mkSubTabs(pri)
local addBox
do
local card2=shell(pri,36)
stroke(card2)
addBox=mk("TextBox",card2,{
Size=UDim2.new(1,-74,0,24),
Position=UDim2.fromOffset(10,6),
BackgroundColor3=UIC.track,
BorderSizePixel=0,
Font=UIF,
TextSize=12,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
PlaceholderText="type a name, then Enter",
PlaceholderColor3=UIC.dim,
ClearTextOnFocus=false,
Text="",
Active=true,
ZIndex=4,
})
corner(addBox,6)
mk("UIPadding",addBox,{PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)})
local addBtn=corner(
mk("TextButton",card2,{
Size=UDim2.fromOffset(52,24),
Position=UDim2.new(1,-60,0,6),
BackgroundColor3=UIC.acc,
Text="ADD",
Font=UIFB,
TextSize=11,
TextColor3=UIC.bg,
AutoButtonColor=false,
Active=true,
ZIndex=4,
}),
6
)
local function doAdd()
local name=(addBox.Text or""):match("^%s*(.-)%s*$")
if name and name~=""then
if currentPriTab=="brainrot"then
table.insert(_G.SHARED_PRIORITY_ITEMS,name)
elseif currentPriTab=="mutation"then
table.insert(_G.SHARED_MUTATION_PRIORITY,name)
else
table.insert(_G.SHARED_TRAIT_PRIORITY,name)
end
_G.ElitePriVersion=(_G.ElitePriVersion or 0)+1
pcall(saveTpSettings)
addBox.Text=""
if refreshPri then
refreshPri()
end
end
end
addBtn.MouseButton1Click:Connect(doAdd)
addBtn.MouseEnter:Connect(function()
tween(addBtn,{BackgroundColor3=UIC.txt})
end)
addBtn.MouseLeave:Connect(function()
tween(addBtn,{BackgroundColor3=UIC.acc})
end)
addBox.FocusLost:Connect(function(enter)
if enter then
doAdd()
end
end)
end
label(pri,"priority  -  top = highest")
local rowsHost=mk("Frame",pri,{
Size=UDim2.new(1,0,0,0),
BackgroundTransparency=1,
AutomaticSize=Enum.AutomaticSize.Y,
ZIndex=2,
})
mk("UIListLayout",rowsHost,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
local function getListAndIcon()
if currentPriTab=="brainrot"then
return _G.SHARED_PRIORITY_ITEMS,nil
elseif currentPriTab=="mutation"then
return _G.SHARED_MUTATION_PRIORITY,MUTATION_ICONS
else
return _G.SHARED_TRAIT_PRIORITY,TRAIT_ICONS
end
end
refreshPri=function()
for _,c in ipairs(rowsHost:GetChildren())do
if c:IsA("GuiObject")then
c:Destroy()
end
end
local L,icons=getListAndIcon()
for i=1,#L do
local nm=tostring(L[i])
local row=corner(
mk("Frame",rowsHost,{
Size=UDim2.new(1,0,0,30),
BackgroundColor3=UIC.card,
BorderSizePixel=0,
LayoutOrder=i,
ZIndex=2,
}),
6
)
stroke(row)
local iconId=icons and icons[nm]
local textOff=12
if iconId and type(iconId)=="string"then
mk("ImageLabel",row,{
Size=UDim2.fromOffset(22,22),
Position=UDim2.fromOffset(10,4),
BackgroundTransparency=1,
Image=tostring(iconId),
ZIndex=3,
})
textOff=40
end
mk("TextLabel",row,{
Size=UDim2.new(1,(currentPriTab=="mutation")and-148 or-104,1,0),
Position=UDim2.fromOffset(textOff,0),
BackgroundTransparency=1,
Text=i..".  "..nm,
Font=UIF,
TextSize=12,
TextColor3=UIC.txt,
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
ZIndex=3,
})
local function commit()
_G.ElitePriVersion=(_G.ElitePriVersion or 0)+1
pcall(saveTpSettings)
refreshPri()
end
local function mini(xoff,sym,act)
local b=corner(
mk("TextButton",row,{
Size=UDim2.fromOffset(26,22),
Position=UDim2.new(1,xoff,0.5,-11),
BackgroundColor3=UIC.track,
Text=sym,
Font=UIFB,
TextSize=12,
TextColor3=UIC.txt,
AutoButtonColor=false,
Active=true,
ZIndex=3,
}),
6
)
b.MouseEnter:Connect(function()
tween(b,{BackgroundColor3=UIC.line})
end)
b.MouseLeave:Connect(function()
tween(b,{BackgroundColor3=UIC.track})
end)
b.MouseButton1Click:Connect(act)
return b
end
mini(-98,"\u{25B2}",function()
if i>1 then
L[i],L[i-1]=L[i-1],L[i]
commit()
end
end)
mini(-68,"\u{25BC}",function()
if i<#L then
L[i],L[i+1]=L[i+1],L[i]
commit()
end
end)
mini(-36,"X",function()
table.remove(L,i)
commit()
end)
if currentPriTab=="mutation"then
local D=_G.SHARED_MUTATION_DISABLED
local off=D[nm]==true
local tg=corner(
mk("TextButton",row,{
Size=UDim2.fromOffset(34,22),
Position=UDim2.new(1,-136,0.5,-11),
BackgroundColor3=off and UIC.track or UIC.acc,
Text=off and"OFF"or"ON",
Font=UIFB,
TextSize=10,
TextColor3=off and UIC.dim or UIC.bg,
AutoButtonColor=false,
Active=true,
ZIndex=3,
}),
6
)
tg.MouseButton1Click:Connect(function()
if D[nm]then
D[nm]=nil
else
D[nm]=true
end
commit()
end)
if off then
for _,c in ipairs(row:GetChildren())do
if c:IsA("TextLabel")then
c.TextColor3=UIC.dim
end
if c:IsA("ImageLabel")then
c.ImageTransparency=0.6
end
end
end
end
end
end
tabOpenHook["Priority"]=function()
if refreshPri then
refreshPri()
end
end
local extras=tab("Misc",4)
local function xt(title,get,set)
toggle(extras,title,get,function()
set()
saveTpSettings()
end)
end
label(extras,"tp",true)
slider(extras,"Scanner Delay",0.3,1,function()
return tonumber(_G.EliteScanDelay)or 1
end,function(v)
_G.EliteScanDelay=v
if _G.EliteScanProfile then
pcall(_G.EliteScanProfile,_G.EliteScanMode or"normal")
end
saveTpSettings()
end,0.05)
label(extras,"vision")
xt("XRAY BASES",function()
return _G.EliteXray~=false
end,function()
if _G.EliteToggleXray then
_G.EliteToggleXray()
end
end)
xt("PLAYER ESP",function()
return _G.ElitePlayerESP~=false
end,function()
_G.ElitePlayerESP=not(_G.ElitePlayerESP~=false)
end)
xt("SHOW WHAT PEOPLE HOLD",function()
return _G.EliteHoldESP~=false
end,function()
_G.EliteHoldESP=not(_G.EliteHoldESP~=false)
saveTpSettings()
end)
xt("TURRET ESP",function()
return _G.EliteTurretESP~=false
end,function()
_G.EliteTurretESP=not(_G.EliteTurretESP~=false)
saveTpSettings()
end)
xt("HIDE 40M/S ON BELT",function()
return _G.EliteHideCheap~=false
end,function()
_G.EliteHideCheap=not(_G.EliteHideCheap~=false)
saveTpSettings()
end)
local keys=tab("Keys",5)
label(keys,"keybinds",true)
local function key(title,g,def)
bindRow(keys,title,function()
return _G[g]or def or"NONE"
end,function(k)
_G[g]=k
end)
end
key("TELEPORT","_stp_tpKeyName","T")
key("INVIS","EliteInvisKey","U")
key("KICK","EliteKickKeyName","K")
key("AUTO CLONE","EliteCloneKeyName","V")
key("STOP TP","EliteStopTPKeyName","X")
key("PRIORITY / NEAREST","EliteNearestKey","F")
key("STEAL QUICK","EliteStealQuickKey","C")
key("DROP BRAINROT","EliteDropKeyName","G")
key("RESET","EliteResetKeyName",nil)
key("CARPET SPEED","EliteCarpetSpeedKeyName","Q")
key("STEAL WALKSPEED","EliteWalkSpeedKey","Z")
selectTab("Home")
end
sg:GetPropertyChangedSignal("Enabled"):Connect(function()
if sg.Enabled and not _mainBuilt then
pcall(buildMain)
end
end)
task.delay(tonumber(_G.EliteUIPrebuild)or 8,function()
local t0=os.clock()
while
not _mainBuilt
and os.clock()-t0<20
and(_G.EliteStealHold or(_G.EliteIsTeleporting and _G.EliteIsTeleporting()))
do
task.wait(0.25)
end
if not _mainBuilt then
pcall(buildMain)
end
end)
end
do
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local RS=game:GetService("ReplicatedStorage")
local LP=game:GetService("Players").LocalPlayer
local BAD={Blue=true,DiscoEffect=true,BeeBlur=true,ColorCorrection=true}
local function nuke(o)if o and o.Parent and BAD[o.Name]then pcall(function()o:Destroy()end)end end
local buzz
local function muteBuzz()
pcall(function()
if not(buzz and buzz.Parent)then
local ctl=RS:FindFirstChild("Controllers")
local item=ctl and ctl:FindFirstChild("ItemController")
local bee=item and item:FindFirstChild("BeeLauncherController")
local s=bee and bee:FindFirstChild("Buzzing")
if s and s:IsA("Sound")then buzz=s end
end
if buzz then
buzz.Volume=0
if buzz.IsPlaying then buzz:Stop()end
end
end)
end
task.spawn(function()
LP:WaitForChild("PlayerScripts",8)
_G.EliteBootWait()
Lighting.DescendantAdded:Connect(nuke)
do local n=0
for _,o in ipairs(Lighting:GetDescendants())do
n=n+1;if n%150==0 then task.wait()end
nuke(o)
end
end
muteBuzz()
local acc=0
RunService.Heartbeat:Connect(function(dt)
local cam=workspace.CurrentCamera
local want=tonumber(_G.EliteFOV)or 120
if cam and math.abs(cam.FieldOfView-want)>0.01 then
cam.FieldOfView=want
end
acc=acc+dt
if acc>=1.0 then acc=0;muteBuzz()end
end)
end)
end
task.delay(0.1,function()
local C={
bg=Color3.fromRGB(8,8,8),
bg2=Color3.fromRGB(14,14,14),
row=Color3.fromRGB(22,22,22),
rowH=Color3.fromRGB(32,32,32),
track=Color3.fromRGB(48,48,48),
input=Color3.fromRGB(16,16,16),
line=Color3.fromRGB(38,38,38),
acc=Color3.fromRGB(240,240,240),
acc2=Color3.fromRGB(200,200,200),
txt=Color3.fromRGB(245,245,245),
dim=Color3.fromRGB(140,140,140),
edge=Color3.fromRGB(255,255,255),
}
do
local T=_G.EliteTheme
if type(T)=="table"then
for k,v in pairs(T)do
if C[k]~=nil and typeof(v)=="Color3"then
C[k]=v
end
end
end
_G.EliteThemeHooks=_G.EliteThemeHooks or{}
table.insert(_G.EliteThemeHooks,function(t)
local old={}
for k,v in pairs(C)do
old[k]=v
end
for k,v in pairs(t)do
if C[k]~=nil and typeof(v)=="Color3"then
C[k]=v
end
end
end)
end
local FB=(function()
for _,n in ipairs({"GothamBold"})do
local ok,f=pcall(function()
return Enum.Font[n]
end)
if ok and f then
return f
end
end
return Enum.Font.GothamBold
end)()
local FR=FB
local TS=game:GetService("TweenService")
local EASE=TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
local function tw(o,p)
TS:Create(o,EASE,p):Play()
end
local function mk(cls,parent,props)
local o=Instance.new(cls)
for k,v in pairs(props or{})do
o[k]=v
end
o.Parent=parent
return o
end
local function round(o,r)
mk("UICorner",o,{CornerRadius=UDim.new(0,r or 10)})
return o
end
local host=(gethui and gethui())or game:GetService("CoreGui")
pcall(function()
local old=host:FindFirstChild(EN("EliteTargets"))
if old then
old:Destroy()
end
end)
local sg=mk("ScreenGui",nil,{
Name=EN("EliteTargets"),
ResetOnSpawn=false,
IgnoreGuiInset=true,
DisplayOrder=999998,
ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
})
EliteParentGui(sg)
_G.EliteTargetsGui=sg
local root=round(
mk("Frame",sg,{
Name="Root",
Active=true,
BackgroundColor3=C.bg2,
BorderSizePixel=0,
Size=UDim2.fromOffset(tonumber(_G._elite_tgtW)or 310,tonumber(_G._elite_tgtH)or 400),
ClipsDescendants=true,
Position=UDim2.fromOffset(tonumber(_G._elite_tgtX)or 24,tonumber(_G._elite_tgtY)or 250),
}),
10
)
if _G.EliteAnimBorder then
_G.EliteAnimBorder(root,1.4,C.edge)
else
mk("UIStroke",root,{Thickness=1.4,Color=C.edge})
end
local head=mk("TextLabel",root,{
Position=UDim2.fromOffset(12,9),
Size=UDim2.new(1,-116,0,20),
BackgroundTransparency=1,
Text="TARGETS",
Font=FB,
TextSize=14,
TextColor3=C.txt,
TextXAlignment=Enum.TextXAlignment.Left,
ZIndex=3,
})
local distBadge=round(
mk("Frame",root,{
Size=UDim2.fromOffset(88,20),
Position=UDim2.new(1,-98,0,8),
BackgroundColor3=C.row,
BorderSizePixel=0,
ZIndex=6,
}),
10
)
local distLbl=mk("TextLabel",distBadge,{
Size=UDim2.fromScale(1,1),
BackgroundTransparency=1,
Text="-- studs",
Font=FB,
TextSize=11,
TextColor3=C.txt,
ZIndex=7,
})
local count=mk("TextLabel",root,{Visible=false,Text="0",BackgroundTransparency=1})
local modeContainer=round(
mk("Frame",root,{
Position=UDim2.fromOffset(10,36),
Size=UDim2.new(1,-20,0,30),
BackgroundColor3=C.input,
BorderSizePixel=0,
ZIndex=3,
}),
8
)
mk("UIPadding",modeContainer,{
PaddingLeft=UDim.new(0,3),
PaddingRight=UDim.new(0,3),
PaddingTop=UDim.new(0,3),
PaddingBottom=UDim.new(0,3),
})
mk("UIListLayout",modeContainer,{Padding=UDim.new(0,3),FillDirection=Enum.FillDirection.Horizontal})
local modeButtons,lastModeState={},false
local function updateAllModes()
local cur=_G.EliteStealMode
if cur==lastModeState then
return
end
lastModeState=cur
for _,bd in ipairs(modeButtons)do
local on=cur==bd.mode
tw(bd.btn,{BackgroundColor3=on and C.acc or C.input,BackgroundTransparency=on and 0 or 1})
bd.btn.TextColor3=on and C.bg or C.dim
end
end
local function modeBtn(txt,mode)
local btn=round(
mk("TextButton",modeContainer,{
Size=UDim2.new(0.5,-2,1,0),
BackgroundColor3=C.input,
BackgroundTransparency=1,
Text=txt,
Font=FB,
TextSize=11,
TextColor3=C.dim,
AutoButtonColor=false,
Active=true,
BorderSizePixel=0,
ZIndex=4,
}),
6
)
btn.MouseButton1Click:Connect(function()
_G.EliteStealMode=(_G.EliteStealMode==mode)and nil or mode
stealOn=_G.EliteStealMode~=nil
saveTpSettings()
updateAllModes()
end)
btn.MouseEnter:Connect(function()
if _G.EliteStealMode~=mode then
btn.BackgroundTransparency=0.5
btn.BackgroundColor3=C.rowH
end
end)
btn.MouseLeave:Connect(function()
if _G.EliteStealMode~=mode then
btn.BackgroundTransparency=1
end
end)
modeButtons[#modeButtons+1]={btn=btn,mode=mode}
end
modeBtn("PRIORITY","priority")
modeBtn("NEAREST","nearest")
task.spawn(function()
while sg.Parent do
updateAllModes()
task.wait(0.2)
end
end)
do
local grip=mk("TextButton",root,{
Name="uiSizeGrip",
Size=UDim2.fromOffset(26,26),
Position=UDim2.new(1,-26,1,-26),
BackgroundTransparency=1,
Text="",
AutoButtonColor=false,
Active=true,
ZIndex=100,
})
local dots={
round(
mk("Frame",grip,{
Size=UDim2.fromOffset(10,10),
Position=UDim2.fromOffset(12,12),
BackgroundColor3=C.acc2,
BackgroundTransparency=0.35,
BorderSizePixel=0,
ZIndex=101,
}),
3
),
}
local function dotsT(t)
for _,d in ipairs(dots)do
d.BackgroundTransparency=t
end
end
grip.MouseEnter:Connect(function()
dotsT(0)
end)
grip.MouseLeave:Connect(function()
dotsT(0.35)
end)
local sizing,from,base
grip.InputBegan:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseButton1
or i.UserInputType==Enum.UserInputType.Touch
then
sizing,from,base=true,i.Position,root.AbsoluteSize
dotsT(0)
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End then
sizing=false
dotsT(0.35)
_G._elite_tgtW,_G._elite_tgtH=root.AbsoluteSize.X,root.AbsoluteSize.Y
pcall(saveTpSettings)
end
end)
end
end)
game:GetService("UserInputService").InputChanged:Connect(function(i)
if not sizing then
return
end
if
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
then
local d=i.Position-from
root.Size=UDim2.fromOffset(math.max(240,base.X+d.X),math.max(220,base.Y+d.Y))
end
end)
end
_G.EliteTargetsSteal=function(name,txt,frac)
if _G.EliteHudSteal then
pcall(_G.EliteHudSteal,name,txt,frac)
end
end
local list=mk("ScrollingFrame",root,{
Position=UDim2.fromOffset(10,72),
Size=UDim2.new(1,-20,1,-98),
BackgroundTransparency=1,
BorderSizePixel=0,
ScrollBarThickness=3,
ScrollBarImageColor3=C.acc,
CanvasSize=UDim2.new(),
AutomaticCanvasSize=Enum.AutomaticSize.Y,
})
mk("UIListLayout",list,{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})
do
local on,from,base,tracked
head.InputBegan:Connect(function(i)
if
i.UserInputType~=Enum.UserInputType.MouseButton1
and i.UserInputType~=Enum.UserInputType.Touch
then
return
end
on,from,base=true,i.Position,root.Position
i.Changed:Connect(function()
if i.UserInputState==Enum.UserInputState.End then
on=false
_G._elite_tgtX=root.Position.X.Offset
_G._elite_tgtY=root.Position.Y.Offset
end
end)
end)
head.InputChanged:Connect(function(i)
if
i.UserInputType==Enum.UserInputType.MouseMovement
or i.UserInputType==Enum.UserInputType.Touch
then
tracked=i
end
end)
UIS.InputChanged:Connect(function(i)
if not on or i~=tracked then
return
end
local d=i.Position-from
root.Position=UDim2.fromOffset(base.X.Offset+d.X,base.Y.Offset+d.Y)
end)
end
local function short(n)
n=tonumber(n)or 0
if n>=1e9 then
return string.format("%.1fB",n/1e9)
end
if n>=1e6 then
return string.format("%.1fM",n/1e6)
end
if n>=1e3 then
return string.format("%.1fK",n/1e3)
end
return string.format("%d",n)
end
local _CTP_TOL_X,_CTP_TOL_Z=62,58
local function _ctpFloorFromY(y)
if y>=-6.9 and y<=8.9 then
return 1
end
if y>=11 and y<=23.15 then
return 2
end
if y>23.15 then
return 3
end
return nil
end
local function _ctpFloorFromSlot(slot,py)
local s=tonumber(slot)
if s then
if s>=19 then
return 3
end
if s>=11 then
return 2
end
if s>=1 then
return 1
end
end
if py then
return _ctpFloorFromY(py)
end
return nil
end
local function _ctpSameBase(petPos,myPos)
local pIdx=getClosestBaseIdx(petPos)
local mIdx=getClosestBaseIdx(myPos)
if pIdx~=mIdx then
return false
end
local b=BASES_LOW[mIdx]
if not b then
return false
end
return math.abs(myPos.X-b.X)<=_CTP_TOL_X and math.abs(myPos.Z-b.Z)<=_CTP_TOL_Z
end
local function _ctpAllowed(pet)
if not pet or not pet.position then
return false
end
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if not hrp then
return false
end
local myPos=hrp.Position
if not _ctpSameBase(pet.position,myPos)then
return false
end
local myFloor=_ctpFloorFromY(myPos.Y)
if not myFloor then
return false
end
local tgtFloor=_ctpFloorFromSlot(pet.slot,pet.position.Y)
if not tgtFloor then
return false
end
local diff=tgtFloor-myFloor
local up=tonumber(_G.EliteClickTPMaxUp)or 3
local down=tonumber(_G.EliteClickTPMaxDown)or 3
return diff<=up and diff>=-down
end
local TIER={
{1e9,Color3.fromRGB(255,199,64),0.00},
{1e8,Color3.fromRGB(190,120,255),0.00},
{1e7,Color3.fromRGB(92,152,255),0.10},
{1e6,Color3.fromRGB(90,220,140),0.25},
{0,Color3.fromRGB(138,150,178),0.60},
}
local MUT_TINT={
gold=Color3.fromRGB(255,199,64),
diamond=Color3.fromRGB(37,196,254),
rainbow=Color3.fromRGB(255,0,251),
candy=Color3.fromRGB(255,70,246),
lava=Color3.fromRGB(255,149,0),
galaxy=Color3.fromRGB(170,60,255),
bloodrot=Color3.fromRGB(200,40,60),
radioactive=Color3.fromRGB(104,245,0),
cursed=Color3.fromRGB(245,56,56),
divine=Color3.fromRGB(255,209,59),
cyber=Color3.fromRGB(121,219,255),
shiny=Color3.fromRGB(255,255,120),
yinyang=Color3.fromRGB(235,235,235),
crystal=Color3.fromRGB(150,200,255),
phantom=Color3.fromRGB(190,160,255),
frost=Color3.fromRGB(180,235,255),
}
local function tierOf(mps)
mps=tonumber(mps)or 0
for _,t in ipairs(TIER)do
if mps>=t[1]then
return t[2],t[3]
end
end
return TIER[#TIER][2],TIER[#TIER][3]
end
local rows={}
local function rowFor(uid)
local r=rows[uid]
if r and r.card.Parent then
return r
end
local card=round(
mk("TextButton",list,{
Size=UDim2.new(1,0,0,44),
BackgroundColor3=C.row,
BackgroundTransparency=0.2,
BorderSizePixel=0,
Text="",
AutoButtonColor=false,
Active=true,
}),
10
)
local selStroke=mk("UIStroke",card,{
Color=C.acc,
Thickness=1.75,
Enabled=false,
ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
})
local bg,rankBox,sub,stripe,chipTxt,pill=nil,nil,nil,nil,nil,nil
local imgHolder,initials=nil,nil
local rank=mk("TextLabel",card,{
Size=UDim2.fromOffset(28,44),
Position=UDim2.fromOffset(6,0),
BackgroundTransparency=1,
Font=FB,
TextSize=16,
TextColor3=C.dim,
Text="",
})
local nm=mk("TextLabel",card,{
Size=UDim2.new(1,-140,0,16),
Position=UDim2.fromOffset(36,6),
BackgroundTransparency=1,
Font=FB,
TextSize=12,
TextColor3=Color3.new(1,1,1),
TextXAlignment=Enum.TextXAlignment.Left,
TextTruncate=Enum.TextTruncate.AtEnd,
Text="",
})
local chip=round(
mk("Frame",card,{
Size=UDim2.fromOffset(8,8),
Position=UDim2.fromOffset(36,28),
BackgroundColor3=C.acc,
BorderSizePixel=0,
Visible=false,
}),
4
)
local icons={}
for k=1,4 do
icons[k]=mk("ImageLabel",card,{
Size=UDim2.fromOffset(12,12),
Position=UDim2.fromOffset(36+(k-1)*15,26),
BackgroundTransparency=1,
Image="",
Visible=false,
})
end
local mps=mk("TextLabel",card,{
AnchorPoint=Vector2.new(1,0.5),
Position=UDim2.new(1,-12,0.5,0),
Size=UDim2.fromOffset(96,20),
BackgroundTransparency=1,
Font=FB,
TextSize=13,
TextColor3=C.acc,
TextXAlignment=Enum.TextXAlignment.Right,
TextTruncate=Enum.TextTruncate.AtEnd,
Text="",
})
local hit=card
r={
card=card,
bg=bg,
rank=rank,
name=nm,
sub=sub,
mps=mps,
icons=icons,
hit=hit,
stripe=stripe,
pill=pill,
lastLocked=false,
rankBox=rankBox,
initials=initials,
selStroke=selStroke,
imgHolder=imgHolder,
chip=chip,
chipTxt=chipTxt,
}
rows[uid]=r
return r
end
task.spawn(function()
local _pd=tonumber(_G.ElitePanelStartDelay)or 0
if not game:IsLoaded()then
game.Loaded:Wait()
end
if _pd>0 then
task.wait(_pd)
end
local _filled=false
local _panelT0=os.clock()
while sg.Parent do
local _pw=os.clock()
while
_filled
and(_G.EliteStealHold or(_G.EliteIsTeleporting and _G.EliteIsTeleporting()))
and os.clock()-_pw<(tonumber(_G.ElitePanelPauseMax)or 3)
do
task.wait(0.2)
end
local bootActive=_gameLoadAt and(os.clock()-_gameLoadAt)<4
local __t0=os.clock()
local pets=scanAllPetsCached(bootActive and 0.1 or 0.15)
if type(pets)=="table"and _G.ElitePrioFilter then
pets=_G.ElitePrioFilter(pets)
end
local ok=pets~=nil
pcall(function()
local top=type(pets)=="table"and pets[1]
local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
local pos=top and top.position
if distLbl then
distLbl.Text=(hrp and typeof(pos)=="Vector3")
and(string.format("%.1f",(pos-hrp.Position).Magnitude).." studs")
or"-- studs"
end
end)
if ok and type(pets)=="table"then
local seen={}
for i,p in ipairs(pets)do
if not p.conveyor then
local uid=_petUid(p)
seen[uid]=true
local r=rowFor(uid)
r.pet=p
if r.lastOrder~=i then
r.lastOrder=i
r.card.LayoutOrder=i
r.rank.Text=tostring(i)
local MEDAL={
{Color3.fromRGB(255,199,64),Color3.fromRGB(38,30,8)},
{Color3.fromRGB(196,202,212),Color3.fromRGB(30,32,36)},
{Color3.fromRGB(205,127,50),Color3.fromRGB(38,24,10)},
}
local md=MEDAL[i]
r.rank.TextColor3=md and md[1]or C.dim
end
local nmTxt=tostring(p.name or"?")
if r.lastName~=nmTxt then
r.lastName=nmTxt
r.name.Text=nmTxt
end
local mpsTxt="$"..short(p.mps or 0).."/s"
if r.lastMps~=mpsTxt then
r.lastMps=mpsTxt
r.mps.Text=mpsTxt
local tint,fade=tierOf(p.mps)
if r.stripe then
r.stripe.BackgroundColor3=tint
r.stripe.BackgroundTransparency=fade
end
local m=tonumber(p.mps)or 0
local h=8
if m>=1e9 then
h=32
elseif m>=1e8 then
h=26
elseif m>=1e7 then
h=20
elseif m>=1e6 then
h=14
end
if r.stripe then
r.stripe.Size=UDim2.fromOffset(3,h)
end
r.mps.TextColor3=tint
end
local mutKey=tostring(p.mutation or"").."\0"..tostring(p.traits and#p.traits or 0)
if r.lastMut~=mutKey then
r.lastMut=mutKey
local extra=""
local iconIds={}
local function addIcon(v)
if v==nil then
return
end
local s=tostring(v)
if s:match("^%d+$")then
s="rbxassetid://"..s
end
iconIds[#iconIds+1]=s
end
if type(p.mutation)=="string"and p.mutation~=""and p.mutation~="None"then
extra=p.mutation
addIcon(MUTATION_ICONS[p.mutation])
end
if type(p.traits)=="table"then
local ts={}
for _,tv in pairs(p.traits)do
local tn
if type(tv)=="string"then
tn=tv
elseif type(tv)=="table"then
tn=tv.Name or tv.name or tv.Trait or tv.Id
end
if type(tn)=="string"then
ts[#ts+1]=tn
addIcon(TRAIT_ICONS[tn])
end
end
if#ts>0 then
extra=(extra~=""and(extra.."  |  ")or"")..table.concat(ts,", ")
end
end
local nIcons=math.min(#iconIds,#r.icons)
for k=1,#r.icons do
local ic=r.icons[k]
if k<=nIcons then
if ic.Image~=iconIds[k]then
ic.Image=iconIds[k]
end
ic.Visible=true
else
ic.Visible=false
end
end
local x=36
local mut=(type(p.mutation)=="string"and p.mutation~=""and p.mutation~="None")
and p.mutation
or nil
if r.chip then
if mut and not MUTATION_ICONS[mut]then
local key=mut:lower():gsub("[^%a]","")
r.chip.Visible=true
r.chip.BackgroundColor3=MUT_TINT[key]or C.acc
r.chip.Position=UDim2.fromOffset(x,28)
x=x+12
else
r.chip.Visible=false
end
end
for k=1,nIcons do
r.icons[k].Position=UDim2.fromOffset(x+(k-1)*15,26)
end
end
local locked=(_G.EliteStealTargetUID==uid)
if locked~=r.lastLocked then
r.lastLocked=locked
r.card.BackgroundColor3=locked and C.rowH or C.row
if r.selStroke then
r.selStroke.Enabled=locked
r.selStroke.Thickness=1.75
end
end
if not r.wired then
r.wired=true
local myUid=uid
local _crow=r
r.hit.MouseButton1Click:Connect(function()
if _G.EliteStealTargetUID==myUid then
_G.EliteStealTargetUID=nil
_G.EliteStealTarget=nil
else
_G.EliteStealTargetUID=myUid
local pet=_crow.pet
do
local okS,fresh=pcall(scanAllPets)
if okS and type(fresh)=="table"then
for _,fp in ipairs(fresh)do
if _petUid(fp)==myUid then
pet=fp
break
end
end
end
end
if
pet
and pet.position
and not isTeleporting
and not _G.EliteClickTPBusy
and _ctpAllowed(pet)
then
_G.EliteClickTPBusy=true
isTeleporting=true
if _G.EliteArmSteal then
pcall(_G.EliteArmSteal,pet)
end
task.spawn(function()
pcall(function()
goToBrainrot(pet.position,pet.slot)
end)
isTeleporting=false
_G.EliteClickTPBusy=false
end)
end
end
end)
r.hit.MouseEnter:Connect(function()
if _G.EliteStealTargetUID~=myUid then
tw(r.card,{BackgroundColor3=C.rowH})
end
end)
r.hit.MouseLeave:Connect(function()
if _G.EliteStealTargetUID~=myUid then
tw(r.card,{BackgroundColor3=C.row})
end
end)
end
end
end
local n=0
for uid,r in pairs(rows)do
if seen[uid]then
n=n+1
else
r.card:Destroy()
rows[uid]=nil
end
end
count.Text=tostring(n)
if n>0 then
_filled=true
end
end
if not _filled and(os.clock()-_panelT0)<(tonumber(_G.ElitePanelRush)or 10)then
task.wait(bootActive and 0.15 or(tonumber(_G.ElitePanelRushGap)or 0.15))
else
_G.EliteProf.mark("targets panel",__t0)
task.wait(tonumber(_G.ElitePanelScanGap)or 0.6)
end
end
end)
_G.EliteToggleTargets=function()
sg.Enabled=not sg.Enabled
end
end)
;if _G.EliteInvisDepth==nil then
_G.EliteInvisDepth=7
end
if _G.EliteInvisAngle==nil then
_G.EliteInvisAngle=180
end
(function()
local RS=RunService
local active,start,stop,armed=false,nil,nil,false
local userOff=false
local function boot()
if start then
return
end
local conns={}
local realHRP,cloneHRP,track,hip,origT
local stuck,restarting=false,false
local function add(c)
conns[#conns+1]=c
end
local function rewire(char,from,to)
for _,v in ipairs(char:GetDescendants())do
if v:IsA("Weld")or v:IsA("Motor6D")then
if v.Part0==from then
v.Part0=to
end
if v.Part1==from then
v.Part1=to
end
end
end
end
local function animTrick(char,hum)
if not(char and hum and hum.Health>0)then
return
end
local an=Instance.new("Animation")
an.AnimationId="http://www.roblox.com/asset/?id=18537363391"
local animator=hum:FindFirstChildOfClass("Animator")or Instance.new("Animator",hum)
track=animator:LoadAnimation(an)
track.Priority=Enum.AnimationPriority.Action4
track.Looped=true
track:Play(0,1,0)
an:Destroy()
add(track.Stopped:Connect(function()
if active then
animTrick(char,hum)
end
end))
task.defer(function()
if not track then
return
end
track.TimePosition=0.7
task.delay(0.1,function()
if track then
track:AdjustSpeed(math.huge)
end
end)
end)
end
stop=function()
active,stuck=false,false
_G.EliteInvisActive=false
for _,c in ipairs(conns)do
pcall(function()
c:Disconnect()
end)
end
conns={}
if origT then
for p,v in pairs(origT)do
if p and p.Parent then
pcall(function()
p.LocalTransparencyModifier=v
end)
end
end
origT=nil
end
if track then
pcall(function()
track:AdjustSpeed(1)
track:Stop(0)
track:Destroy()
end)
track=nil
end
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
if realHRP and realHRP:IsDescendantOf(game)and hum then
local tmp=Instance.new("Model")
tmp.Parent=game
char.Parent=tmp
realHRP.Parent=char
char.PrimaryPart=realHRP
char.Parent=workspace
realHRP.CanCollide=true
rewire(char,cloneHRP,realHRP)
if cloneHRP then
local at=cloneHRP.CFrame
cloneHRP:Destroy()
cloneHRP=nil
realHRP.CFrame=at
end
hum.HipHeight=hip or 0
tmp:Destroy()
end
realHRP,cloneHRP=nil,nil
end
start=function()
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
if not hum or active then
return false
end
if LP:GetAttribute("Stealing")~=true then
return false
end
local folder=workspace:FindFirstChild(LP.Name)
if folder then
for _,n in ipairs({"DoubleRig","Constraints"})do
local x=folder:FindFirstChild(n)
if x then
x:Destroy()
end
end
end
for _,s in ipairs({"Dead","FallingDown","Ragdoll"})do
hum:SetStateEnabled(Enum.HumanoidStateType[s],false)
end
hip=hum.HipHeight
realHRP=char:FindFirstChild("HumanoidRootPart")
if not(realHRP and realHRP.Parent)then
return false
end
local tmp=Instance.new("Model")
tmp.Parent=game
char.Parent=tmp
cloneHRP=realHRP:Clone()
cloneHRP.Parent=char
realHRP.Parent=workspace.CurrentCamera
cloneHRP.CFrame=realHRP.CFrame
char.PrimaryPart=cloneHRP
char.Parent=workspace
rewire(char,realHRP,cloneHRP)
tmp:Destroy()
active=true
_G.EliteInvisActive=true
animTrick(char,hum)
origT={}
for _,p in ipairs(char:GetDescendants())do
if p:IsA("BasePart")then
origT[p]=p.LocalTransparencyModifier
p.LocalTransparencyModifier=1
end
end
add(char.DescendantAdded:Connect(function(desc)
if not(active and desc:IsA("BasePart"))then
return
end
if origT and origT[desc]==nil then
origT[desc]=desc.LocalTransparencyModifier
end
pcall(function()
desc.LocalTransparencyModifier=1
end)
end))
local lastTarget,grace,protN=nil,60,0
add(RS.PreSimulation:Connect(function()
if not active then
return
end
protN=protN+1
if hum.Parent and protN%3==0 then
if hum.Health<hum.MaxHealth then
hum.Health=hum.MaxHealth
end
hum:SetStateEnabled(Enum.HumanoidStateType.Dead,false)
end
if not(realHRP and realHRP.Parent)then
return
end
local base=cloneHRP
if not(base and base.Parent)then
return
end
if grace>0 then
grace=grace-1
elseif not stuck and lastTarget and(realHRP.Position-lastTarget).Magnitude>2.25 then
stuck=true
if not restarting then
task.spawn(function()
restarting=true
stop()
task.wait(0.5)
restarting=false
start()
end)
end
end
if not(active and realHRP and realHRP.Parent and base.Parent)then
return
end
local dd=tonumber(_G.EliteInvisDepth)or 7
local aa=tonumber(_G.EliteInvisAngle)or 180
local z=0.01+(math.clamp(dd,0,10)/10)*0.19
local cf=base.CFrame-Vector3.new(0,hum.HipHeight+(base.Size.Y/2)-1+z,0)
realHRP.CFrame=cf*CFrame.Angles(math.rad(aa),0,0)
realHRP.AssemblyLinearVelocity=base.AssemblyLinearVelocity
realHRP.CanCollide=false
if realHRP.Parent~=workspace.CurrentCamera then
realHRP.Parent=workspace.CurrentCamera
end
lastTarget=cf.Position
end))
add(LP.CharacterAdded:Connect(function()
if active then
stop()
end
end))
return true
end
end
local function tryStart()
if _G.EliteInvisAuto~=true or userOff then
return
end
if active or armed then
return
end
if LP:GetAttribute("Stealing")~=true then
return
end
armed=true
task.delay(1.2,function()
armed=false
if _G.EliteInvisAuto~=true or userOff then
return
end
if active or LP:GetAttribute("Stealing")~=true then
return
end
boot()
pcall(start)
end)
end
_G.EliteInvisStart=function()
boot()
if active then
return true
end
local ok,r=pcall(start)
return ok and r
end
_G.EliteInvisStop=function()
armed=false
if active and stop then
pcall(stop)
end
end
_G.EliteInvisToggle=function()
if active then
userOff=true
_G.EliteInvisStop()
else
userOff=false
_G.EliteInvisStart()
end
end
LP:GetAttributeChangedSignal("Stealing"):Connect(function()
if LP:GetAttribute("Stealing")~=true then
armed=false
userOff=false
if active and stop then
pcall(stop)
end
return
end
tryStart()
end)
end)()
do
local MAXV=tonumber(_G.EliteFlingSpeed)or 350
local MAXA=tonumber(_G.EliteFlingSpin)or 40
local function guard()
if _G.EliteAntiFling==false then return end
if isTeleporting or _G.__EliteWalkFling==true then return end
local c=LP.Character
local r=c and c:FindFirstChild("HumanoidRootPart")
if not r then return end
local lv,av=r.AssemblyLinearVelocity,r.AssemblyAngularVelocity
if lv.Magnitude>MAXV then
r.AssemblyLinearVelocity=Vector3.zero
end
if av.Magnitude>MAXA then
r.AssemblyAngularVelocity=Vector3.zero
end
end
RunService.Stepped:Connect(function()pcall(guard)end)
RunService.Heartbeat:Connect(function()pcall(guard)end)
end
do
if _G.EliteHideCheap==nil then _G.EliteHideCheap=true end
local hidden={}
local FX={BillboardGui=true,SurfaceGui=true,ParticleEmitter=true,
Trail=true,Beam=true,PointLight=true,Highlight=true}
local function setHidden(model,on)
if not(model and model.Parent)then hidden[model]=nil return end
for _,d in ipairs(model:GetDescendants())do
if d:IsA("BasePart")or d:IsA("Decal")then
d.LocalTransparencyModifier=on and 1 or 0
elseif FX[d.ClassName]then
d.Enabled=not on
end
end
hidden[model]=on or nil
end
local function podiumModel(plotName,slot,index)
local plots=workspace:FindFirstChild("Plots")
local plot=plots and plots:FindFirstChild(tostring(plotName))
local pods=plot and plot:FindFirstChild("AnimalPodiums")
local pod=pods and pods:FindFirstChild(tostring(slot))
if not pod then return nil end
local att=pod:FindFirstChild("Base")
att=att and att:FindFirstChild("Spawn")
att=att and att:FindFirstChild("Attachment")
for _,d in ipairs((att or pod):GetChildren())do
if d:IsA("Model")then return d end
end
if index then
local m=pod:FindFirstChild(tostring(index),true)
if m and m:IsA("Model")then return m end
end
return nil
end
task.spawn(function()
while true do
task.wait(1)
pcall(function()
local want={}
if _G.EliteHideCheap~=false then
local min=40e6
local pets=(_G.EliteShowPlotBrainrots==false)and scanAllPetsCached and scanAllPetsCached(1)or{}
for _,pt in ipairs(pets or{})do
if(tonumber(pt.mps)or 0)<=min then
local m=podiumModel(pt.plot,pt.slot,pt.index)
if m then want[m]=true end
end
end
local belt=workspace:FindFirstChild("RenderedMovingAnimals")
if belt and _G._eliteGen then
for _,m in ipairs(belt:GetChildren())do
if m:IsA("Model")then
local ok,g=pcall(_G._eliteGen,m.Name,m:GetAttribute("Mutation"),nil)
if ok and tonumber(g)and g>0 and g<=min then want[m]=true end
end
end
end
end
for m in pairs(want)do
if not hidden[m]then pcall(setHidden,m,true)end
end
for m in pairs(hidden)do
if not want[m]then pcall(setHidden,m,false)end
end
end)
end
end)
end
if _G.EliteInfJump==nil then _G.EliteInfJump=true end
;(function()
local held=false
local function hop()
local c=LP.Character
local hrp=c and c:FindFirstChild("HumanoidRootPart")
local hum=c and c:FindFirstChildOfClass("Humanoid")
if not hrp or not hum or hum.Health<=0 then return end
hrp.Velocity=Vector3.new(hrp.Velocity.X,hum.JumpPower or 50,hrp.Velocity.Z)
end
local function on()return _G.EliteInfJump~=false end
UIS.JumpRequest:Connect(function()if on()then hop()end end)
UIS.InputBegan:Connect(function(i,g)
if not g and i.KeyCode==Enum.KeyCode.Space then held=true end
end)
UIS.InputEnded:Connect(function(i)
if i.KeyCode==Enum.KeyCode.Space then held=false end
end)
RunService.Heartbeat:Connect(function()if held and on()then hop()end end)
end)()
if _G.EliteInvisKey==nil then _G.EliteInvisKey="U"end
if _G.EliteWalkSpeedKey==nil then _G.EliteWalkSpeedKey="Z"end
UIS.InputBegan:Connect(function(input,typing)
if typing or _G.EliteBindListening then return end
if input.UserInputType~=Enum.UserInputType.Keyboard then return end
if input.KeyCode.Name==tostring(_G.EliteWalkSpeedKey)and _G.EliteSetWalkSpeed then
pcall(_G.EliteSetWalkSpeed,not(_G.EliteWalkSpeedOn~=false))
if _G.EliteSaveSettings then pcall(_G.EliteSaveSettings)end
end
end)
if _G.EliteKickKeyName==nil then _G.EliteKickKeyName="K"end
UIS.InputBegan:Connect(function(input,typing)
if typing then return end
if _G.EliteBindListening then return end
if input.UserInputType~=Enum.UserInputType.Keyboard then return end
if input.KeyCode.Name==tostring(_G.EliteInvisKey)then
if _G.EliteInvisToggle then pcall(_G.EliteInvisToggle)end
end
end)
task.spawn(function()
local was=false
while true do
task.wait(0.05)
local now=(isTeleporting==true)
if was and not now then
_G.__EliteTPLandedAt=os.clock()
if _G.EliteHudSteal then pcall(_G.EliteHudSteal,nil,"0%",0)end
end
was=now
end
end)
;(function()
local function equipCarpet()if _G.EliteEquipCarpet then return _G.EliteEquipCarpet()end end
if _G.EliteAntiFlash==nil then _G.EliteAntiFlash=true end
if _G.EliteAntiBee==nil then _G.EliteAntiBee=true end
if _G.EliteInfJump==nil then _G.EliteInfJump=true end
if _G.EliteInvisDepth==nil then _G.EliteInvisDepth=4.2 end
if _G.EliteInvisAngle==nil then _G.EliteInvisAngle=180 end
if _G.EliteCarpetSpeedValue==nil then _G.EliteCarpetSpeedValue=140 end
if _G.EliteCarpetSpeedKeyName==nil then _G.EliteCarpetSpeedKeyName="Q"end
;(function()
local FX={ParticleEmitter=true,Beam=true,Trail=true,Fire=true,
Smoke=true,Sparkles=true,Explosion=true,PointLight=true,
SpotLight=true,SurfaceLight=true}
local function kill(item)
if pcall(function()item:Destroy()end)then return end
pcall(function()
for _,d in ipairs(item:GetDescendants())do
if d:IsA("BasePart")then
d.Transparency=1
d.CanCollide=false
d.CanQuery=false
d.CastShadow=false
d.LocalTransparencyModifier=1
elseif FX[d.ClassName]then
d.Enabled=false
elseif d:IsA("Sound")then
d.Volume=0
d:Stop()
end
end
end)
end
local function strip(char)
if not char or _G.EliteAntiFlash==false then return end
for _,item in ipairs(char:GetChildren())do
if item:IsA("Accessory")then kill(item)end
end
end
local hooked=setmetatable({},{__mode="k"})
local function hookChar(char)
if not char or hooked[char]then return end
hooked[char]=true
strip(char)
char.ChildAdded:Connect(function(c)
if c:IsA("Accessory")and _G.EliteAntiFlash~=false then
task.defer(kill,c)
end
end)
end
local function hookPlayer(p)
if p.Character then task.spawn(hookChar,p.Character)end
p.CharacterAdded:Connect(hookChar)
end
task.defer(function()
for _,p in ipairs(Players:GetPlayers())do
pcall(hookPlayer,p)
task.wait(0.05)
end
end)
Players.PlayerAdded:Connect(function(p)
task.defer(hookPlayer,p)
end)
workspace.DescendantAdded:Connect(function(d)
if _G.EliteAntiFlash==false then return end
if d.ClassName=="Accessory"then
local par=d.Parent
if par and par:FindFirstChildOfClass("Humanoid")then task.defer(kill,d)end
end
end)
task.spawn(function()
while true do
if _G.EliteAntiFlash~=false then
for _,p in ipairs(Players:GetPlayers())do
if p.Character then strip(p.Character)end
task.wait(0.05)
end
for _,m in ipairs(workspace:GetChildren())do
if m:IsA("Model")and m:FindFirstChildOfClass("Humanoid")then
strip(m)
task.wait(0.05)
end
end
end
task.wait(10)
end
end)
end)()
;(function()
local TeleportService=game:GetService("TeleportService")
if _G.EliteCleanErrStop then pcall(_G.EliteCleanErrStop)end
local _ref=cloneref or function(x)return x end
local GS=_ref(game:GetService("GuiService"))
local running,conns=true,{}
task.spawn(function()
while running do
pcall(function()GS:ClearError()end)
task.wait(tonumber(_G.EliteClearErrGap)or 0.35)
end
end)
conns[#conns+1]=TeleportService.TeleportInitFailed:Connect(function(plr,result,message,placeId)
if plr~=LP then return end
local name="Unknown"
pcall(function()name=result and result.Name or tostring(result)end)
_G.EliteCleanErrLast={
result=name,message=tostring(message or""),
placeId=placeId,at=os.clock(),
}
end)
_G.EliteCleanErrStop=function()
running=false
for _,c in ipairs(conns)do pcall(function()c:Disconnect()end)end
conns={}
_G.EliteCleanErrStop=nil
end
end)()
if _G.AntiDieDisabled==nil then
_G.AntiDieDisabled=false
end
task.spawn(function()
local __P=game:GetService("Players")
while not __P.LocalPlayer do
task.wait()
end
pcall(function()
local RunService=game:GetService("RunService")
local RS=game:GetService("ReplicatedStorage")
local LP=__P.LocalPlayer
local ST=Enum.HumanoidStateType
local RAG={[ST.Physics]=true,[ST.Ragdoll]=true,[ST.FallingDown]=true,[ST.GettingUp]=true}
local JOINT={BallSocketConstraint=true,NoCollisionConstraint=true,HingeConstraint=true}
local MOVER={BodyVelocity=true,BodyPosition=true,BodyGyro=true}
local conns={}
local char,hum,root,animator
local lastVelocity=Vector3.zero
local function ragdolled()
return hum~=nil and RAG[hum:GetState()]==true
end
local function aOn()
return ragdolled()and not _G.EliteInvisActive
end
local function carpetOn()
if not char or not char:FindFirstChildWhichIsA("Tool")then
return false
end
local hrp=char:FindFirstChild("HumanoidRootPart")
if hrp then
for _,o in ipairs(hrp:GetChildren())do
if MOVER[o.ClassName]then
return true
end
end
end
return false
end
local function controls()
pcall(function()
require(LP:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",10)):GetControls():Enable()
end)
end
local function camera()
pcall(function()
workspace.CurrentCamera.CameraSubject=hum
end)
end
local function stopAnims()
if animator then
for _,t in pairs(animator:GetPlayingAnimationTracks())do
local n=t.Animation and t.Animation.Name:lower()or""
if n:find("rag")or n:find("fall")or n:find("hurt")or n:find("down")then
t:Stop(0)
end
end
end
end
local function junk(o)
return JOINT[o.ClassName]or(o:IsA("Attachment")and(o.Name=="A"or o.Name=="B"))
end
local function cleanupRagdoll()
if not char then
return
end
local carpet=carpetOn()
pcall(function()
for _,o in ipairs(char:GetChildren())do
if junk(o)then
o:Destroy()
elseif MOVER[o.ClassName]then
if not carpet then
o:Destroy()
end
elseif o:IsA("Motor6D")then
o.Enabled=true
elseif o:IsA("BasePart")then
for _,c in ipairs(o:GetChildren())do
if c:IsA("Motor6D")then
c.Enabled=true
elseif junk(c)then
c:Destroy()
end
end
end
end
end)
stopAnims()
end
local function fixA()
pcall(function()
for _,o in ipairs(char:GetDescendants())do
if o:IsA("AnimationConstraint")and not o.Enabled then
o.Enabled=true
end
end
end)
stopAnims()
end
local function recover()
if hum:GetState()==ST.Physics then
pcall(function()
hum:ChangeState(ST.GettingUp)
end)
end
if root and root.Parent and not _G.EliteInvisActive then
pcall(function()
root.AssemblyLinearVelocity=Vector3.zero
root.AssemblyAngularVelocity=Vector3.zero
end)
end
fixA()
if not _G.EliteInvisActive then
camera()
end
controls()
end
local function harden(h)
pcall(function()
h.BreakJointsOnDeath=false
end)
pcall(function()
h.RequiresNeck=false
end)
pcall(function()
h:SetStateEnabled(ST.Dead,false)
end)
pcall(function()
h:SetStateEnabled(ST.FallingDown,false)
end)
end
local function revive(h)
pcall(function()
h.Health=h.MaxHealth
end)
pcall(function()
h:ChangeState(ST.Running)
end)
end
local function setChar(c)
char=c
hum=c:WaitForChild("Humanoid",10)
root=c:WaitForChild("HumanoidRootPart",10)
animator=hum and hum:WaitForChild("Animator",10)
lastVelocity=Vector3.zero
if hum then
harden(hum)
end
end
local function clear()
for _,c in pairs(conns)do
pcall(function()
c:Disconnect()
end)
end
conns={}
end
local function add(c)
conns[#conns+1]=c
end
local function setup()
clear()
if not hum or not root then
return
end
harden(hum)
add(hum:GetPropertyChangedSignal("Health"):Connect(function()
if not _G.AntiDieDisabled and hum and hum.Parent and hum.Health<=0 then
revive(hum)
end
end))
add(hum.Died:Connect(function()
if not _G.AntiDieDisabled and hum and hum.Parent then
revive(hum)
end
end))
local lastH=0
add(RunService.Heartbeat:Connect(function()
if not hum or not hum.Parent then
return
end
if not _G.AntiDieDisabled then
local now=os.clock()
if now-lastH>=1.0 then
lastH=now
harden(hum)
end
if hum.Health<=0 then
revive(hum)
end
if _G.EliteStealHold and hum.Health<hum.MaxHealth then
pcall(function()
hum.Health=hum.MaxHealth
end)
end
end
if ragdolled()then
if _G.EliteStealHold then
return
end
if root.AssemblyLinearVelocity.Magnitude>60 then
lastVelocity=root.AssemblyLinearVelocity
return
end
cleanupRagdoll()
local v=root.AssemblyLinearVelocity
if(v-lastVelocity).Magnitude>40 and v.Magnitude>25 then
root.AssemblyLinearVelocity=v.Unit*math.min(v.Magnitude,15)
end
lastVelocity=v
end
end))
local f=0
add(RunService.Heartbeat:Connect(function()
f=f+1
if f<2 then
return
end
f=0
if aOn()then
recover()
end
end))
add(hum.StateChanged:Connect(function()
if ragdolled()then
if not carpetOn()then
hum:ChangeState(ST.Running)
end
cleanupRagdoll()
camera()
controls()
end
end))
add(hum.StateChanged:Connect(function()
if aOn()then
recover()
end
end))
pcall(function()
local impulse=_G.EliteGetRemote and _G.EliteGetRemote("RemoteEvent","CombatService/ApplyImpulse")
if not impulse then
local pkgs=RS:FindFirstChild("Packages")
local net=pkgs and pkgs:FindFirstChild("Net")
impulse=net and net:FindFirstChild("RE/CombatService/ApplyImpulse")
end
if impulse then
add(impulse.OnClientEvent:Connect(function()
if ragdolled()then
root.AssemblyLinearVelocity=Vector3.zero
end
end))
end
end)
add(char.DescendantAdded:Connect(function()
if ragdolled()then
cleanupRagdoll()
end
if aOn()then
fixA()
end
end))
controls()
cleanupRagdoll()
end
LP.CharacterAdded:Connect(function(c)
clear()
char,hum,root,animator=nil,nil,nil,nil
local h=c:WaitForChild("Humanoid",10)
local r=c:WaitForChild("HumanoidRootPart",10)
if not h or not r then
return
end
task.wait(0.2)
setChar(c)
setup()
end)
if LP.Character then
setChar(LP.Character)
setup()
end
end)
end)
;(function()
local Lighting=game:GetService("Lighting")
local BAD={Blue=true,DiscoEffect=true,BeeBlur=true,
Flashbang=true,ColorCorrection=true}
local KILL_CLASSES={
BlurEffect=true,
BloomEffect=true,
SunRaysEffect=true,
ColorCorrectionEffect=true,
DepthOfFieldEffect=true,
}
local function on()return _G.EliteAntiBee~=false end
local function nuke(o)
if not on()or not o or not o.Parent then return end
if BAD[o.Name]then
pcall(function()o:Destroy()end)
return
end
if KILL_CLASSES[o.ClassName]then
pcall(function()o.Enabled=false end)
end
end
local buzz
local function muteBuzz()
if not on()then return end
pcall(function()
if not(buzz and buzz.Parent)then
local ctl=RS:FindFirstChild("Controllers")
local item=ctl and ctl:FindFirstChild("ItemController")
local bee=item and item:FindFirstChild("BeeLauncherController")
local s=bee and bee:FindFirstChild("Buzzing")
if s and s:IsA("Sound")then buzz=s end
end
if buzz then
buzz.Volume=0
if buzz.IsPlaying then buzz:Stop()end
end
end)
end
local guarded={}
local function guard(Controls,original)
if not Controls or guarded[Controls]then return end
local base=original or Controls.moveFunction
if not base then return end
local function safeMove(self,mv,rtc)return base(self,mv,rtc)end
guarded[Controls]=safeMove
Controls.moveFunction=safeMove
local _mfTick=0
RunService.Heartbeat:Connect(function()
_mfTick=_mfTick+1
if _mfTick<10 then return end
_mfTick=0
if not on()then return end
if Controls.moveFunction~=safeMove then Controls.moveFunction=safeMove end
end)
end
local function protect()
pcall(function()
local cc=RS:FindFirstChild("Controllers")
local mod=cc and cc:FindFirstChild("CharacterController")
local m=mod and require(mod)
if type(m)=="table"then guard(m.Controls,m.originalMoveFunction)end
end)
pcall(function()
local ps=LP:WaitForChild("PlayerScripts",5)
local pm=ps and ps:FindFirstChild("PlayerModule")
if pm then guard(require(pm):GetControls())end
end)
end
task.spawn(function()
LP:WaitForChild("PlayerScripts",8)
_G.EliteBootWait()
Lighting.DescendantAdded:Connect(nuke)
for _,o in ipairs(Lighting:GetDescendants())do nuke(o)end
protect()
local acc=1
RunService.Heartbeat:Connect(function(dt)
if not on()then return end
local cam=workspace.CurrentCamera
if cam and math.abs(cam.FieldOfView-20)<0.01 then
cam.FieldOfView=tonumber(_G.EliteFOV)or 70
end
acc=acc+dt
if acc<0.5 then return end
acc=0
for _,o in ipairs(Lighting:GetDescendants())do nuke(o)end
muteBuzz()
end)
end)
LP.CharacterAdded:Connect(function()task.delay(1,protect)end)
end)()
;(function()
local conn
_G.EliteSetCarpetSpeed=function(enabled)
_G.EliteCarpetSpeed=enabled and true or false
if conn then conn:Disconnect()conn=nil end
if not _G.EliteCarpetSpeed then return end
task.spawn(function()pcall(equipCarpet)end)
local _csEquipAt=0
conn=RunService.Heartbeat:Connect(function()
if LP:GetAttribute("Stealing")==true then
_G.EliteSetCarpetSpeed(false)
return
end
local c=LP.Character
local hum=c and c:FindFirstChildOfClass("Humanoid")
local part=c and(c:FindFirstChild("UpperTorso")
or c:FindFirstChild("Torso")
or c:FindFirstChild("HumanoidRootPart"))
if not hum or not part then return end
local now=os.clock()
if not _G.EliteCarpetEngaging()and(now-_csEquipAt)>=1.0 then
_csEquipAt=now
pcall(equipCarpet)
end
local spd=math.clamp(tonumber(_G.EliteCarpetSpeedValue)or 140,20,400)
local md,keepY=hum.MoveDirection,part.Velocity.Y
if md.Magnitude>0 then
part.Velocity=Vector3.new(md.X*spd,keepY,md.Z*spd)
else
part.Velocity=Vector3.new(0,keepY,0)
end
end)
end
UIS.InputBegan:Connect(function(i,g)
if g or i.UserInputType~=Enum.UserInputType.Keyboard then return end
local _csk=_G.EliteCarpetSpeedKeyName
if type(_csk)~="string"or _csk==""then return end
if i.KeyCode.Name~=_csk then return end
if _G.EliteBindListening then return end
if LP:GetAttribute("Stealing")==true then return end
local on=not(_G.EliteCarpetSpeed==true)
_G.EliteSetCarpetSpeed(on)
if on then task.spawn(function()pcall(equipCarpet)end)end
end)
end)()
;(function()
local FOLDERS={"Base","PlotSign","FriendPanel","Cash","Laser",
"Decorations","Skin","Unlock","Purchases"}
local orig=setmetatable({},{__mode="k"})
local conns,gen={},0
local function paint(o,a)
if not o:IsA("BasePart")then return end
if orig[o]==nil then orig[o]=(o.Transparency==a)and 0 or o.Transparency end
local base=orig[o]
if base>=1 then return end
local want=base+(1-base)*a
if math.abs(o.Transparency-want)>0.01 then o.Transparency=want end
end
local function calm()
while _G.EliteStealHold do task.wait(0.15)end
end
local function track(root,a,id)
if not root or id~=gen then return end
paint(root,a)
local n=0
for _,d in ipairs(root:GetDescendants())do
if id~=gen then return end
paint(d,a)
n=n+1
if n%250==0 then task.wait()end
end
conns[#conns+1]=root.DescendantAdded:Connect(function(d)
if id==gen then paint(d,a)end
end)
end
local function doPlot(plot,a,id)
if not plot or id~=gen then return end
for _,fname in ipairs(FOLDERS)do
if id~=gen then return end
track(plot:FindFirstChild(fname),a,id)
end
if id~=gen then return end
conns[#conns+1]=plot.ChildAdded:Connect(function(c)
if id~=gen then return end
for _,fname in ipairs(FOLDERS)do
if c.Name==fname then track(c,a,id)break end
end
end)
local pods=plot:FindFirstChild("AnimalPodiums")
if not pods then return end
local function pod(pd)
for _,c in ipairs(pd:GetChildren())do
if c.Name=="Claim"then track(c,a,id)
elseif c.Name=="Base"then track(c:FindFirstChild("Decorations"),a,id)end
end
end
for _,pd in ipairs(pods:GetChildren())do pod(pd)end
conns[#conns+1]=pods.ChildAdded:Connect(function(pd)
if id~=gen then return end
task.wait(0.1)
if id==gen then pod(pd)end
end)
end
local function stop()
for _,c in ipairs(conns)do pcall(function()c:Disconnect()end)end
conns,gen={},gen+1
end
_G.EliteEnableXray=function()
stop()
local id=gen
local a=math.clamp(tonumber(_G.EliteXrayAlpha)or 0.9,0,1)
task.spawn(function()
while id==gen and not workspace:FindFirstChild("Plots")do task.wait(0.5)end
local plots=workspace:FindFirstChild("Plots")
if id~=gen or not plots then return end
calm()
for _,p in ipairs(plots:GetChildren())do
if id~=gen then return end
pcall(doPlot,p,a,id)
task.wait()
calm()
end
conns[#conns+1]=plots.ChildAdded:Connect(function(p)
if id~=gen then return end
task.wait(0.2)
pcall(doPlot,p,a,id)
end)
end)
end
_G.EliteDisableXray=function()
stop()
local snap=orig
orig=setmetatable({},{__mode="k"})
for o,t in pairs(snap)do
pcall(function()if o:IsA("BasePart")then o.Transparency=t end end)
end
end
_G.EliteToggleXray=function()
_G.EliteXray=not(_G.EliteXray~=false)
if _G.EliteXray then _G.EliteEnableXray()else _G.EliteDisableXray()end
return _G.EliteXray
end
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
_G.EliteBootWait()
task.wait(tonumber(_G.EliteXrayDelay)or 1)
if _G.EliteXray~=false then _G.EliteEnableXray()end
end)
end)()
;(function()
local function kickOut()
if pcall(function()game:Shutdown()end)then return end
pcall(function()LP:Kick("")end)
end
_G.EliteKickOut=kickOut
task.spawn(function()
local PG2=LP:FindFirstChildOfClass("PlayerGui")or LP:WaitForChild("PlayerGui",10)
if not PG2 then return end
local hooked=setmetatable({},{__mode="k"})
local function hit(t)
return type(t)=="string"and t:lower():find("you stole",1,true)~=nil
end
local function isText(o)
return o:IsA("TextLabel")or o:IsA("TextButton")or o:IsA("TextBox")
end
local function watch(o)
if hooked[o]then return end
hooked[o]=true
if _G.EliteAutoKickOnSteal==true and hit(o.Text)then kickOut()return end
o:GetPropertyChangedSignal("Text"):Connect(function()
if _G.EliteAutoKickOnSteal==true and hit(o.Text)then kickOut()end
end)
end
local function root(g)
g.DescendantAdded:Connect(function(d)if isText(d)then watch(d)end end)
local n=0
for _,d in ipairs(g:GetDescendants())do
n=n+1
if n%200==0 then task.wait()end
if isText(d)then watch(d)end
end
end
while _G.EliteAutoKickOnSteal~=true do task.wait(1)end
PG2.ChildAdded:Connect(root)
for _,g in ipairs(PG2:GetChildren())do root(g)end
end)
end)()
pcall(function()game:GetService("Players").RespawnTime=0 end)
do
local RunService=game:GetService("RunService")
local Players=game:GetService("Players")
local Workspace=game:GetService("Workspace")
local _wfConns,_wfActive={},false
local function stopWalkFling()
_wfActive=false
_G.__EliteWalkFling=false
for _,c in ipairs(_wfConns)do
if typeof(c)=="RBXScriptConnection"then pcall(function()c:Disconnect()end)end
end
_wfConns={}
end
local function startWalkFling()
_wfActive=true
_G.__EliteWalkFling=true
local ch=LP.Character
if not ch then return end
local rr
for _,o in pairs(Workspace.CurrentCamera:GetChildren())do
if o.Name=="UpperTorso"or o.Name=="Torso"then rr=o break end
end
if not rr then rr=ch:FindFirstChild("UpperTorso")or ch:FindFirstChild("Torso")end
if not rr then
for _,o in pairs(Workspace.CurrentCamera:GetChildren())do
if o.Name=="HumanoidRootPart"then rr=o break end
end
rr=rr or ch:FindFirstChild("HumanoidRootPart")
end
if not rr then return end
table.insert(_wfConns,RunService.Stepped:Connect(function()
if not _wfActive then return end
for _,p in ipairs(Players:GetPlayers())do
if p~=LP and p.Character then
for _,pt in ipairs(p.Character:GetChildren())do
if pt:IsA("BasePart")and pt.CanCollide then pt.CanCollide=false end
end
end
end
end))
local co=coroutine.create(function()
if _G.invisibleStealEnabled then rr.CFrame=rr.CFrame*CFrame.new(0,3,0)end
while _wfActive do
RunService.Heartbeat:Wait()
if not rr or not rr.Parent then break end
local v=rr.Velocity
rr.Velocity=v*10000+Vector3.new(0,10000,0)
RunService.RenderStepped:Wait()
if rr then rr.Velocity=v end
RunService.Stepped:Wait()
if rr then rr.Velocity=v+Vector3.new(0,0.1,0)end
end
end)
coroutine.resume(co)
table.insert(_wfConns,co)
end
_G.DropBrainrot=function()
if _wfActive then return end
startWalkFling()
local t0=os.clock()
local carrying=LP:GetAttribute("Stealing")==true
while _wfActive and os.clock()-t0<0.4 do
RunService.Heartbeat:Wait()
if carrying and LP:GetAttribute("Stealing")~=true then break end
end
stopWalkFling()
end
end
_G.__eliteResetBusy=false
_G.EliteInstaReset=function()
local _now=os.clock()
if _G.__eliteResetBusy
and(_now-(tonumber(_G.__eliteResetAt)or 0))<(tonumber(_G.EliteResetCooldown)or 2.5)then
return
end
_G.__eliteResetBusy=true
_G.__eliteResetAt=_now
task.spawn(function()
local RunService=game:GetService("RunService")
local _prevAntiDie=_G.AntiDieDisabled
_G.AntiDieDisabled=true
_G.EliteStealHold=false
local _restored=false
local function _restore()
if _restored then return end
_restored=true
_G.AntiDieDisabled=_prevAntiDie
_G.__eliteResetBusy=false
end
local _conn
_conn=LP.CharacterAdded:Connect(function(newChar)
if _conn then _conn:Disconnect();_conn=nil end
task.defer(function()
pcall(function()newChar:WaitForChild("Humanoid",12)end)
RunService.Heartbeat:Wait()
_restore()
end)
end)
task.delay(8,function()if _conn then _conn:Disconnect();_conn=nil end _restore()end)
local _origChar=LP.Character
local _hum=_origChar and _origChar:FindFirstChildOfClass("Humanoid")
if _hum then
pcall(function()_hum:SetStateEnabled(Enum.HumanoidStateType.Dead,true)end)
pcall(function()_hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,true)end)
pcall(function()_hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,true)end)
pcall(function()_hum:SetStateEnabled(Enum.HumanoidStateType.Physics,true)end)
pcall(function()_hum.BreakJointsOnDeath=true end)
pcall(function()_hum.RequiresNeck=true end)
end
RunService.Heartbeat:Wait()
pcall(function()
if _hum then _hum.Health=0 end
end)
task.delay(tonumber(_G.EliteResetFallbackGap)or 0.6,function()
if not _origChar or LP.Character~=_origChar then return end
local h=_origChar:FindFirstChildOfClass("Humanoid")
if h and h.Health>0 then pcall(function()_origChar:BreakJoints()end)end
end)
end)
end
task.spawn(function()
local _fired=false
while true do
if _G.EliteAutoClone==true then
if not _fired
and LP:GetAttribute("Stealing")~=true
and not(_G.EliteIsTeleporting and _G.EliteIsTeleporting())then
_fired=true
if _G.EliteDoClone then pcall(_G.EliteDoClone)end
if _G.EliteAutoCloneOneShot~=false then
_G.EliteAutoClone=false
if _G.EliteRepaintAutoClone then pcall(_G.EliteRepaintAutoClone)end
end
end
else
_fired=false
end
task.wait(0.15)
end
end)
local function _kb(kn,name)
return type(name)=="string"and name~=""and kn==name
end
UIS.InputBegan:Connect(function(input,gameProcessed)
if gameProcessed then return end
if input.UserInputType~=Enum.UserInputType.Keyboard then return end
if _G.EliteBindListening then return end
local kn=input.KeyCode.Name
if _kb(kn,_G.EliteCloneKeyName)then
_G.EliteAutoClone=not(_G.EliteAutoClone==true)
end
if _kb(kn,_G.EliteKickKeyName)then
task.spawn(function()
if _G.EliteKickOut then pcall(_G.EliteKickOut)end
end)
end
if _kb(kn,_G.EliteStopTPKeyName)then
_G.EliteTPStop=true
_G.EliteAutoTP=false
if _G.EliteRepaintAutoTP then pcall(_G.EliteRepaintAutoTP)end
local ch=LP.Character
local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
if hrp then pcall(function()hrp.AssemblyLinearVelocity=Vector3.zero end)end
end
if _kb(kn,_G.EliteNearestKey)then
_G.EliteStealMode=(_G.EliteStealMode=="nearest")and"priority"or"nearest"
end
if _kb(kn,_G.EliteStealQuickKey)then
_G.EliteStealQuick=not(_G.EliteStealQuick==true)
if _G.EliteRepaintStealMode then pcall(_G.EliteRepaintStealMode)end
if _G.EliteSaveSettings then pcall(_G.EliteSaveSettings)end
end
if _kb(kn,_G.EliteDropKeyName)then
task.spawn(function()if _G.DropBrainrot then pcall(_G.DropBrainrot)end end)
end
if _kb(kn,_G.EliteResetKeyName)then
task.spawn(function()if _G.EliteInstaReset then pcall(_G.EliteInstaReset)end end)
end
end)
if _G.EliteAutoBuyRange==nil then _G.EliteAutoBuyRange=17 end
if _G.EliteAutoBuyHover==nil then _G.EliteAutoBuyHover=9 end
do
local Workspace=game:GetService("Workspace")
local lockedPrompt,lockedPart,lockedModel
local _abBodyPos
local function firePurchase(prompt)
if not prompt or not prompt.Parent or not prompt.Enabled then return end
pcall(function()prompt.HoldDuration=0 end)
pcall(function()if fireproximityprompt then fireproximityprompt(prompt)end end)
end
local function partAlive()
return lockedPart and lockedPart.Parent and lockedModel and lockedModel.Parent
end
local function promptAlive()
return lockedPrompt and lockedPrompt.Parent and lockedPrompt.Enabled
end
local function destroyBodyPos()
if _abBodyPos then
pcall(function()_abBodyPos:Destroy()end)
_abBodyPos=nil
end
end
local function hoverPart(char)
return char:FindFirstChild("UpperTorso")or char:FindFirstChild("Torso")
end
local _promptCache,_promptCacheAt=nil,0
local function allPrompts()
if _promptCache and os.clock()-_promptCacheAt<5 then
local cleaned={}
for _,p in ipairs(_promptCache)do
if p and p.Parent then cleaned[#cleaned+1]=p end
end
_promptCache=cleaned
return cleaned
end
local out,n={},0
for _,obj in ipairs(Workspace:GetDescendants())do
n=n+1
if n%3000==0 then task.wait()end
if obj:IsA("ProximityPrompt")then out[#out+1]=obj end
end
_promptCache,_promptCacheAt=out,os.clock()
return out
end
Workspace.DescendantAdded:Connect(function(d)
if _G.EliteAutoBuy~=true or not _promptCache then return end
if d:IsA("ProximityPrompt")then _promptCache[#_promptCache+1]=d end
end)
local function scanConveyor()
local results={}
for _,obj in ipairs(allPrompts())do
if obj.Parent and obj.Enabled then
local tx=(obj.ActionText or""):lower()
if tx:find("purchase")or tx:find("comprar")or tx:find("buy")then
local part=obj.Parent
local realPart=(part and part:IsA("Attachment")and part.Parent)or part
if realPart and realPart:IsA("BasePart")then
local model,cur=nil,realPart
for _=1,8 do
if cur and cur:IsA("Model")then model=cur;break end
cur=cur and cur.Parent
end
results[#results+1]={prompt=obj,part=realPart,model=model}
end
end
end
end
return results
end
local _abRag={
[Enum.HumanoidStateType.Physics]=true,
[Enum.HumanoidStateType.Ragdoll]=true,
[Enum.HumanoidStateType.FallingDown]=true,
}
local _abHarden=0
local _abTick=0
RunService.Heartbeat:Connect(function()
if _G.EliteAutoBuy~=true or not partAlive()then return end
_abTick=_abTick+1
if _abTick<2 then return end
_abTick=0
local char=LP.Character
local part=char and hoverPart(char)
if not part then return end
local hum=char:FindFirstChildOfClass("Humanoid")
local now=os.clock()
if hum then
if now-_abHarden>0.5 then
_abHarden=now
pcall(function()hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)end)
pcall(function()hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false)end)
pcall(function()hum.BreakJointsOnDeath=false end)
end
local ragged=_abRag[hum:GetState()]==true
local et=tonumber(LP:GetAttribute("RagdollEndTime"))
if et and(et-workspace:GetServerTimeNow())>0 then ragged=true end
if ragged then
pcall(function()hum:ChangeState(Enum.HumanoidStateType.GettingUp)end)
local cam=workspace.CurrentCamera
if cam and cam.CameraSubject~=hum then
pcall(function()cam.CameraSubject=hum end)
end
end
end
local hover=tonumber(_G.EliteAutoBuyHover)or 9
local goal=lockedPart.Position+Vector3.new(0,hover,0)
if not(_abBodyPos and _abBodyPos.Parent==part)then
destroyBodyPos()
_abBodyPos=Instance.new("BodyPosition")
_abBodyPos.MaxForce=Vector3.new(math.huge,math.huge,math.huge)
_abBodyPos.P=20000
_abBodyPos.D=1000
_abBodyPos.Parent=part
end
_abBodyPos.Position=goal
end)
local _abJumped=false
RunService.Heartbeat:Connect(function()
if _G.EliteAutoBuy~=true or not partAlive()or not promptAlive()then return end
if not _abJumped then
_abJumped=true
local char=LP.Character
local hum=char and char:FindFirstChildOfClass("Humanoid")
if hum then
pcall(function()hum:ChangeState(Enum.HumanoidStateType.Jumping)end)
end
end
firePurchase(lockedPrompt)
end)
task.spawn(function()
while true do
task.wait(0.1)
if _G.EliteAutoBuy~=true then
lockedPrompt,lockedPart,lockedModel=nil,nil,nil
destroyBodyPos()
_abJumped=false
elseif lockedPart or lockedModel then
if not partAlive()then
lockedPrompt,lockedPart,lockedModel=nil,nil,nil
destroyBodyPos()
_abJumped=false
end
else
local ok,found=pcall(scanConveyor)
local list=(ok and found)or{}
local char=LP.Character
local hrp=char and char:FindFirstChild("HumanoidRootPart")
if hrp then
local best,bestDist=nil,math.huge
local radius=tonumber(_G.EliteAutoBuyRange)or 17
for _,e in ipairs(list)do
if e.prompt and e.prompt.Parent and e.prompt.Enabled and e.part and e.part.Parent then
local d=(hrp.Position-e.part.Position).Magnitude
if d<=radius and d<bestDist then bestDist=d;best=e end
end
end
if best then
lockedPrompt,lockedPart,lockedModel=best.prompt,best.part,best.model or best.part.Parent
pcall(function()best.prompt.HoldDuration=0 end)
firePurchase(best.prompt)
end
end
end
end
end)
LP.CharacterAdded:Connect(function()
destroyBodyPos()
end)
end
do
local _anSeen=setmetatable({},{__mode="k"})
local function _isPlayerRig(inst)
local m=inst:FindFirstAncestorOfClass("Model")
while m do
if Players:GetPlayerFromCharacter(m)then return true end
if Players:FindFirstChild(m.Name)then return true end
if m:FindFirstChildOfClass("Humanoid")and m.Parent==workspace then return true end
m=m:FindFirstAncestorOfClass("Model")
end
return false
end
local function _killTrack(t)
if not t then return end
pcall(function()t:Stop(0)end)
pcall(function()t:AdjustSpeed(0)end)
end
local function _hookAnimator(a)
if _G.EliteNoPetAnim==false then return end
if not a or not a.Parent or _anSeen[a]then return end
if _isPlayerRig(a)then return end
_anSeen[a]=true
pcall(function()
for _,t in ipairs(a:GetPlayingAnimationTracks())do _killTrack(t)end
end)
pcall(function()
a.AnimationPlayed:Connect(function(t)_killTrack(t)end)
end)
end
workspace.DescendantAdded:Connect(function(d)
if d.ClassName=="Animator"then task.delay(tonumber(_G.EliteAnimHookDelay)or 0.6,_hookAnimator,d)end
end)
local _busyAnim=false
local function _sweepAll()
if _G.EliteNoPetAnim==false then return end
if _busyAnim then return end
_busyAnim=true
task.spawn(function()
local all=workspace:GetDescendants()
local i,n=1,#all
while i<=n do
local t0=os.clock()
while i<=n and(os.clock()-t0)<0.004 do
local o=all[i]
i=i+1
if o and o.ClassName=="Animator"then _hookAnimator(o)end
end
RunService.Heartbeat:Wait()
end
_busyAnim=false
end)
end
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
task.wait(tonumber(_G.EliteNoPetAnimDelay)or 3)
for _=1,6 do
_sweepAll()
task.wait(1.5)
end
while true do
task.wait(tonumber(_G.EliteNoPetAnimGap)or 15)
_sweepAll()
end
end)
end
do
local KILL={Animator=true,AnimationController=true,Bone=true}
local function isPet(m)
return m and m.ClassName=="Model"and(m:FindFirstChild("RootPart")~=nil or m:FindFirstChild("FakeRootPart")~=nil)
end
local function petOf(inst)
local m=inst:FindFirstAncestorOfClass("Model")
while m do
if isPet(m)then return m end
m=m:FindFirstAncestorOfClass("Model")
end
return nil
end
local function stripPet(pet)
local dd=pet:GetDescendants()
for i=1,#dd do
local d=dd[i]
if KILL[d.ClassName]then pcall(function()d:Destroy()end)end
end
end
local function onAdded(d)
if _G.EliteNoPetAnim==false or not KILL[d.ClassName]then return end
task.defer(function()
if d.Parent and petOf(d)then pcall(function()d:Destroy()end)end
end)
end
local function hookFolder(f,petsAreKids)
if not f then return end
f.DescendantAdded:Connect(onAdded)
if _G.EliteNoPetAnim==false then return end
local kids=f:GetChildren()
for i=1,#kids do
local k=kids[i]
if petsAreKids then
if isPet(k)then stripPet(k)end
else
local sub=k:GetChildren()
for j=1,#sub do
if isPet(sub[j])then stripPet(sub[j])end
end
end
if i%4==0 then task.wait()end
end
end
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
hookFolder(workspace:FindFirstChild("Plots")or workspace:WaitForChild("Plots",30),false)
hookFolder(workspace:FindFirstChild("RenderedMovingAnimals")or workspace:WaitForChild("RenderedMovingAnimals",15),true)
end)
end
do
if _G.ElitePlayerESP==nil then _G.ElitePlayerESP=true end
local host=(gethui and gethui())or game:GetService("CoreGui")
local bin
local hls={}
local function _bin()
if bin and bin.Parent then return bin end
bin=Instance.new("Folder")
bin.Name=EN("ElitePlayerESP")
bin.Parent=host
return bin
end
local tags={}
if _G.EliteHoldESP==nil then _G.EliteHoldESP=true end
local function _drop(pl)
local h=hls[pl]
if h then pcall(function()h:Destroy()end)end
hls[pl]=nil
local t=tags[pl]
if t then pcall(function()t:Destroy()end)end
tags[pl]=nil
end
local function _tag(pl)
local t=tags[pl]
if t and t.Parent then return t end
t=Instance.new("BillboardGui")
t.Name="HOLD_"..pl.Name
t.Size=UDim2.fromOffset(200,38)
t.StudsOffset=Vector3.new(0,3.2,0)
t.AlwaysOnTop=true
t.MaxDistance=600
t.Parent=_bin()
local l=Instance.new("TextLabel")
l.Name="T"
l.Size=UDim2.fromScale(1,1)
l.BackgroundTransparency=1
l.Font=Enum.Font.GothamBold
l.TextSize=13
l.TextStrokeTransparency=0.25
l.TextColor3=Color3.new(1,1,1)
l.Parent=t
tags[pl]=t
return t
end
local function _carried(pl,ch)
if pl:GetAttribute("Stealing")~=true then return nil end
local AD=AnimalsData
for _,d in ipairs(ch:GetChildren())do
if d:IsA("Model")and type(AD)=="table"and type(AD[d.Name])=="table"then
return tostring(AD[d.Name].DisplayName or d.Name)
end
end
return"BRAINROT"
end
local function _ensure(pl)
local h=hls[pl]
if h and h.Parent then return h end
h=Instance.new("Highlight")
h.Name="ESP_"..pl.Name
h.FillTransparency=tonumber(_G.EliteESPFill)or 0.55
h.OutlineTransparency=0
h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
h.Parent=_bin()
hls[pl]=h
return h
end
Players.PlayerRemoving:Connect(_drop)
task.spawn(function()
if not game:IsLoaded()then game.Loaded:Wait()end
task.wait(tonumber(_G.EliteESPDelay)or 4)
local _lastCol
while true do
task.wait(tonumber(_G.EliteESPGap)or 0.4)
pcall(function()
local on=_G.ElitePlayerESP~=false
local col=_G.EliteESPColor
if typeof(col)~="Color3"then col=Color3.fromRGB(255,255,255)end
local colChanged=col~=_lastCol
_lastCol=col
for _,pl in ipairs(Players:GetPlayers())do
local ch=(pl~=LP)and pl.Character
local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
if on and hrp then
local h=_ensure(pl)
if h.Adornee~=ch then h.Adornee=ch end
if colChanged then
h.FillColor=col
h.OutlineColor=col
end
if not h.Enabled then h.Enabled=true end
else
local h=hls[pl]
if h then h.Enabled=false;h.Adornee=nil end
end
local tg=tags[pl]
if _G.EliteHoldESP~=false and hrp then
local tool=ch:FindFirstChildOfClass("Tool")
local rot=_carried(pl,ch)
if tool or rot then
tg=_tag(pl)
local head=ch:FindFirstChild("Head")or hrp
if tg.Adornee~=head then tg.Adornee=head end
local l=tg:FindFirstChild("T")
if l then
l.Text=(rot and("CARRYING: "..rot)or"")..((rot and tool)and"\n"or"")..(tool and tool.Name or"")
l.TextColor3=rot and Color3.fromRGB(255,90,90)or Color3.new(1,1,1)
end
tg.Enabled=true
elseif tg then
tg.Enabled=false
end
elseif tg then
tg.Enabled=false
end
end
end)
end
end)
end
do
local Players=game:GetService("Players")
local LP=Players.LocalPlayer
if _G.EliteAntiAFK==nil then _G.EliteAntiAFK=true end
if _G.__eliteAFKRan then return end
_G.__eliteAFKRan=true
local ref=(type(cloneref)=="function")and cloneref or function(x)return x end
local VU=select(2,pcall(function()return ref(game:GetService("VirtualUser"))end))
local VIM=select(2,pcall(function()return ref(game:GetService("VirtualInputManager"))end))
_G.EliteAFKHits=0
local function nudge()
if typeof(VU)=="Instance"then
local ok=pcall(function()
VU:CaptureController()
pcall(function()VU:ClickButton2(Vector2.new())end)
end)
if ok then return true end
end
if typeof(VIM)=="Instance"then
local ok=pcall(function()
VIM:SendMouseButtonEvent(0,0,1,true,game,1)
VIM:SendMouseButtonEvent(0,0,1,false,game,1)
end)
if ok then return true end
end
return false
end
LP.Idled:Connect(function()
if _G.EliteAntiAFK==false then return end
_G.EliteAFKHits=(_G.EliteAFKHits or 0)+1
nudge()
end)
task.spawn(function()
while true do
task.wait(tonumber(_G.EliteAFKGap)or 240)
if _G.EliteAntiAFK~=false then pcall(nudge)end
end
end)
end
end)()
_G.EliteAntiFlash,_G.EliteAntiBee=true,true
_G.AntiDieDisabled=false
_G.EliteAntiAFK,_G.EliteNoPetAnim=true,true
_G.EliteAutoBuyRange,_G.EliteAutoBuyHover=29,10
;(function()
local function strip()
local c=LP.Character
local h=c and c:FindFirstChild("HumanoidRootPart")
if not h or not getconnections or not getinfo then return end
for _,s in ipairs({"CFrame","Position"})do
pcall(function()
for _,cn in ipairs(getconnections(h:GetPropertyChangedSignal(s)))do
if cn.Function and cn.Enabled then
local ok,info=pcall(getinfo,cn.Function)
if ok and info and tostring(info.source)=="=ReplicatedFirst.test"then
pcall(function()cn:Disable()end)
end
end
end
end)
end
end
task.spawn(function()_G.EliteBootWait()while true do pcall(strip)task.wait(6)end end)
LP.CharacterAdded:Connect(function()task.wait(0.3)pcall(strip)end)
end)()
;(function()
local wsConn
_G.EliteSetWalkSpeed=function(enabled)
_G.EliteWalkSpeedOn=enabled and true or false
if wsConn then wsConn:Disconnect()wsConn=nil end
if not _G.EliteWalkSpeedOn then return end
wsConn=RunService.Heartbeat:Connect(function(dt)
if not _G.EliteWalkSpeedOn then return end
if LP:GetAttribute("Stealing")~=true then return end
local c=LP.Character
local hum=c and c:FindFirstChildOfClass("Humanoid")
local hrp=c and c:FindFirstChild("HumanoidRootPart")
if not hum or not hrp or hum.Health<=0 then return end
local md=hum.MoveDirection
if md.Magnitude<=0 then return end
local spd=math.clamp(tonumber(_G.EliteWalkSpeed)or 26,5,32)
if spd<=hum.WalkSpeed then return end
hrp.CFrame=hrp.CFrame+(md*(spd-hum.WalkSpeed)*(dt or 0.016))
end)
end
if _G.EliteWalkSpeedOn==nil then _G.EliteWalkSpeedOn=true end
if _G.EliteWalkSpeedOn==true then
task.defer(function()pcall(_G.EliteSetWalkSpeed,true)end)
end
end)()
task.spawn(function()
local Players=game:GetService("Players")
local function fuse(o)
local n=o.Name
if n:find(" ",1,true)or not n:lower():find("fuse",1,true)then
return
end
if not(o:IsA("Model")or o:IsA("Folder")or o:IsA("BasePart"))then
return
end
if Players:GetPlayerFromCharacter(o)or o:FindFirstChildWhichIsA("Humanoid")or o:FindFirstChildWhichIsA("AnimationController")then
return
end
pcall(function()
o:Destroy()
end)
end
for _,o in ipairs(workspace:GetChildren())do
fuse(o)
end
workspace.ChildAdded:Connect(fuse)
end)
;(function()
if _G.EliteOptimizer==false then return end
if _G.__EliteOptimizerLoaded then return end
_G.__EliteOptimizerLoaded=true
_G.__SXE_KillQ={}
_G.XenSyncGet=_G.XenSyncGet or function(idx)
if _G.EliteSyncGet then
return _G.EliteSyncGet(idx)
end
end
_G.SXE_IsMyPlot=_G.SXE_IsMyPlot or function(ch)
local ok,r=pcall(function()
return isMyPlot and isMyPlot(ch)
end)
return ok and r==true
end
do
local function keepAll()
if _G.EliteShowPlotBrainrots~=false then return true end
if _G.ElitePriorityOnly==false then return true end
if _G.EliteStealMode=="highest"then return true end
if type(_priIndexOf)~="function"then return true end
local ok,lk=pcall(function()
return _G.ElitePriLookup and _G.ElitePriLookup()
end)
if not ok or type(lk)~="table"or next(lk)==nil then return true end
return false
end
_G.SXE_PrioSet=setmetatable({},{
__index=function(_,k)
if type(k)~="string"then return nil end
if keepAll()then return true end
local ok,idx=pcall(_priIndexOf,k)
if ok and idx~=nil then return true end
return nil
end,
})
end
task.spawn(function()
local RunService=game:GetService("RunService")
local was=false
while true do
local now=(isTeleporting==true)
_G.__SXE_VelFlying=now
if _G.EliteMyPlot and _G.__SXE_MyPlot~=_G.EliteMyPlot then
_G.__SXE_MyPlot=_G.EliteMyPlot
end
if was and not now then
task.delay(1.2,function()
if not(isTeleporting==true)then
pcall(_G.SXE_FlushKills)
end
end)
end
was=now
RunService.Heartbeat:Wait()
end
end)
_G.__SXE_StripNoPrio=nil
task.defer(function()
if _G.__EliteOptWrapped then return end
_G.__EliteOptWrapped=true
local lastStrip=0
local function hookScan(orig)
return function(...)
local pets=orig(...)
if _G.__SXE_StripDone and not _G.__SXE_VelFlying and _G.__SXE_StripNoPrio then
local now=os.clock()
if now-lastStrip>=0.2 then
lastStrip=now
pcall(_G.__SXE_StripNoPrio)
end
end
if type(pets)=="table"and pets[1]and pets[1].plot and _G.SXE_LockPrioPlot then
if tostring(_G.__SXE_KeepPlot)~=tostring(pets[1].plot)then
pcall(_G.SXE_LockPrioPlot,pets[1].plot)
end
end
return pets
end
end
local g=scanAllPets
if type(g)=="function"then
local hooked=hookScan(g)
scanAllPets=hooked
_G.EliteScanAllPets=hooked
elseif type(_G.EliteScanAllPets)=="function"then
_G.EliteScanAllPets=hookScan(_G.EliteScanAllPets)
end
end)
if not game:IsLoaded()then game.Loaded:Wait()end
do
local Players=game:GetService("Players")
local lp=Players.LocalPlayer or Players.PlayerAdded:Wait()
if not lp.Character then lp.CharacterAdded:Wait()end
if not workspace:FindFirstChild("Plots")then workspace:WaitForChild("Plots",10)end
end
task.spawn(function()
local RS=game:GetService("ReplicatedStorage")
local KILL={
RNGMachineVFX=true,
LuckIcons=true,
GlossaryBackground=true,
AnimationGraphEditor=true,
ML=true,
PlayWaveEvents=true,
}
local function yeet(ch)
if not ch then return end
pcall(function()
ch:Destroy()
end)
end
local function dropKill(ch)
if ch and KILL[ch.Name]then yeet(ch)end
end
local kids=RS:GetChildren()
for i=1,#kids do dropKill(kids[i])end
RS.ChildAdded:Connect(dropKill)
end)
task.wait()
local sxeOptimization={}
local function _sxeBusy()
return _G.__SXE_VelFlying==true
end
function _G.SXE_Kill(inst)
if not inst then return end
if _sxeBusy()then
local q=_G.__SXE_KillQ
q[#q+1]=inst
return
end
pcall(function()inst:Destroy()end)
end
function _G.SXE_FlushKills()
local q=_G.__SXE_KillQ
_G.__SXE_KillQ={}
for i=1,#q do
local x=q[i]
if x and x.Parent then pcall(function()x:Destroy()end)end
end
if sxeOptimization.flushWallPlots then sxeOptimization.flushWallPlots()end
end
local function __sxeStrip()
local Players=game:GetService("Players")
local Lighting=game:GetService("Lighting")
local LP=Players.LocalPlayer
local function kill(inst)
_G.SXE_Kill(inst)
end
pcall(function()workspace.Terrain.Decoration=false end)
local WS_KILL={
FriendPanel=true,Cash=true,Unlock=false,Purchases=true,
PlotSign=false,CashPad=true,InvisibleWalls=false,Multiplier=true,
Slope=true,IncubatorMachine=false,FuseMachine=false,RobuxShop=true,
AdminBoard=false,SoccerScoreBoard=false,CrystalSpinWheel=false,
Beehive=false,CraftingMachine=true,Shop=false,Road=true,
EventBoard=false,TradePlazaPortal=true,LosTraders=false,
RNGMachine=false,Present=false,StPatricksPot=false,
ShopNPCRobuxIdle=false,RoadPanel=true,Honey=true,
Trap=false,Events=true,Sounds=false,rods=true,
JumpLTMMachine=true,HalloweenFuseMachine=true,
Dev=false,ToolsAdds=false,__PROJECTILES=false,CrystalMap=true,
SpawnLocation=true,UFO=true,Interacts=false,
}
local PLOT_KEEP={
Skin=true,Laser=true,AnimalPodiums=true,
DeliveryHitbox=true,StealHitbox=true,AnimalTarget=true,
MainRoot=true,Floor=true,Spawn=true,Door=true,Hitbox=true,
Base=true,Wall=true,Roof=true,SecondFloor=true,ThirdFloor=true,
["structure base home"]=true,Unlock=true,
}
local PLOT_NUKE={
FriendPanel=false,Cash=true,Purchases=false,
PlotSign=false,CashPad=true,InvisibleWalls=false,Multiplier=false,
LaserHitbox=false,Events=true,Sounds=false,
Slope=false,
}
local BODY_PART={
HumanoidRootPart=true,Head=true,Torso=true,
UpperTorso=true,LowerTorso=true,
LeftUpperArm=true,LeftLowerArm=true,LeftHand=true,
RightUpperArm=true,RightLowerArm=true,RightHand=true,
LeftUpperLeg=true,LeftLowerLeg=true,LeftFoot=true,
RightUpperLeg=true,RightLowerLeg=true,RightFoot=true,
["Left Arm"]=true,["Right Arm"]=true,
["Left Leg"]=true,["Right Leg"]=true,
}
local CHAR_KEEP_CLASS={
Humanoid=true,Animator=true,Attachment=true,
Motor6D=true,AnimationConstraint=true,
BallSocketConstraint=true,Weld=true,WeldConstraint=true,
}
local MAP_KEEP={Ground=true,Ground_Left=true,Ground_Right=true}
local PART_CLASS={
Part=true,MeshPart=true,UnionOperation=true,
WedgePart=true,CornerWedgePart=true,TrussPart=true,
SpawnLocation=true,Seat=true,VehicleSeat=true,
}
local function underUnlock(d)
local x=d
for _=1,12 do
if not x then return false end
if x.Name=="Unlock"then return true end
if x==workspace then return false end
x=x.Parent
end
return false
end
local function isMine(inst)
if not(LP and inst)then return false end
if inst==LP.Character or inst.Name==LP.Name then return true end
return false
end
local function isVisualJunk(d)
local cn=d.ClassName
return cn=="Beam"or cn=="Trail"or cn=="ParticleEmitter"
or cn=="PointLight"or cn=="SpotLight"or cn=="SurfaceLight"
or cn=="Fire"or cn=="Smoke"or cn=="Sparkles"
or cn=="BillboardGui"or cn=="SurfaceGui"or cn=="Highlight"
or cn=="Decal"or cn=="Texture"
end
local function isWallStructure(d)
return d and(d.Name=="Wall"or d.Name=="structure base home")
end
local function isSkinJunk(d)
if not d then return false end
local ancestor=d
while ancestor and ancestor~=workspace do
if isWallStructure(ancestor)then return false end
ancestor=ancestor.Parent
end
if isVisualJunk(d)then return true end
return PART_CLASS[d.ClassName]==true and not d.CanCollide
end
local function isPet(inst)
if not inst or inst.ClassName~="Model"then return false end
return inst:FindFirstChild("FakeRootPart")~=nil
or inst:FindFirstChild("RootPart")~=nil
end
local function stripSkin(skin)
if not(skin and skin.Parent)then return end
local dd=skin:GetDescendants()
local dump={}
for i=1,#dd do
if isSkinJunk(dd[i])then dump[#dump+1]=dd[i]end
end
for i=1,#dump do kill(dump[i])end
end
local function skipLaserStrip(plot)
local keep=_G.__SXE_KeepPlot
if not keep then
return true
end
return plot and tostring(plot.Name)==tostring(keep)
end
local function skipTimerStrip(plot)
return skipLaserStrip(plot)
end
local function plotOf(d)
local x=d
for _=1,16 do
if not x then return nil end
local p=x.Parent
if p and p.Name=="Plots"then return x end
x=p
end
return nil
end
local function isRemainingTimeGui(d)
if not d then return false end
local x=d
for _=1,16 do
if not x then break end
if x.Name=="RemainingTime"then return true end
x=x.Parent
end
local cn=d.ClassName
if cn=="BillboardGui"or cn=="SurfaceGui"then
local hit
pcall(function()
hit=d:FindFirstChild("RemainingTime",true)
end)
if hit then return true end
end
return false
end
local function stripPurchasesKeepTimer(purch)
if not(purch and purch.Parent)then return end
local kids=purch:GetChildren()
for i=1,#kids do
local ch=kids[i]
if ch.Name~="PlotBlock"then
kill(ch)
else
local dd=ch:GetDescendants()
for j=1,#dd do
local d=dd[j]
local cn=d.ClassName
if(cn=="BillboardGui"or cn=="SurfaceGui")and not isRemainingTimeGui(d)then
kill(d)
end
end
end
end
end
local laserPend={}
local function stripLaser(laser)
if not(laser and laser.Parent)then return end
if skipLaserStrip(laser.Parent)then return end
local bars={}
local beamPart={}
local dd=laser:GetDescendants()
for i=1,#dd do
local d=dd[i]
if d.ClassName=="Beam"then
local a0,a1=d.Attachment0,d.Attachment1
local p0=a0 and a0.Parent
local p1=a1 and a1.Parent
if p0 and p0:IsA("BasePart")then beamPart[p0]=true end
if p1 and p1:IsA("BasePart")then beamPart[p1]=true end
elseif d:IsA("BasePart")then
bars[#bars+1]=d
end
end
if#bars>0 then
local chosen={}
for i=1,#bars do
if beamPart[bars[i]]then chosen[#chosen+1]=bars[i]end
end
if#chosen==0 then
for i=1,#bars do
local d=bars[i]
local s=d.Size
local mx=math.max(s.X,s.Y,s.Z)
local mn=math.min(s.X,s.Y,s.Z)
local neon=false
pcall(function()
neon=d.Material==Enum.Material.Neon
or d.Material==Enum.Material.ForceField
end)
if neon or(mn<=1.5 and mx>=3)then
chosen[#chosen+1]=d
end
end
end
if#chosen==0 then chosen=bars end
local keep=chosen[1]
if keep then
for i=1,#bars do
if bars[i]~=keep then kill(bars[i])end
end
pcall(function()
if PART_CLASS[laser.ClassName]then
laser.CanCollide=false
laser.CanTouch=false
end
keep.CanCollide=false
keep.CanTouch=false
end)
end
end
end
local function queueStripLaser(laser)
if not laser or laserPend[laser]then return end
laserPend[laser]=true
task.defer(function()
laserPend[laser]=nil
stripLaser(laser)
end)
end
local function stripPetVfx(pet)
if not pet then return end
local dd=pet:GetDescendants()
local dump={}
for i=1,#dd do
local d=dd[i]
local n=d.Name
local cn=d.ClassName
if n=="VfxInstance"or n=="_VfxInstance"or n=="AnimationController"
or cn=="ParticleEmitter"or cn=="Beam"or cn=="Trail"
or cn=="Fire"or cn=="Smoke"or cn=="Sparkles"
or cn=="Animator"or cn=="AnimationController"
or cn=="Bone"
or cn=="BillboardGui"or cn=="SurfaceGui"then
dump[#dump+1]=d
end
end
for i=1,#dump do kill(dump[i])end
end
_G.SXE_StripPetVfx=stripPetVfx
local function isCharJunk(d)
if not d then return false end
local cn=d.ClassName
if cn=="PathfindingModifier"then return false end
if cn=="WrapTarget"or cn=="WrapLayer"then return true end
if cn=="Shirt"or cn=="ShirtGraphic"then return true end
if cn=="NoCollisionConstraint"then return true end
local nm=d.Name
if nm=="__HITBOX"or nm=="OriginalPosition"or nm=="OriginalSize"then return true end
if CHAR_KEEP_CLASS[cn]then return false end
if BODY_PART[nm]then return false end
return true
end
local function isUuidName(n)
return type(n)=="string"and#n==36
and string.match(n,"^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$")~=nil
end
local function isOtherAvatar(char)
if not(char and char.ClassName=="Model")then return false end
if isMine(char)then return false end
if isPet(char)then return false end
local n=char.Name
if type(n)=="string"and string.sub(n,-6)=="_Clone"then return false end
if Players:GetPlayerFromCharacter(char)then return true end
if Players:FindFirstChild(n)then return true end
return char:FindFirstChildOfClass("Humanoid")~=nil
end
local hookedChars={}
local function stripOtherChar(char)
if _G.__SXE_VelFlying then return end
if not(char and char.Parent)or isMine(char)or not isOtherAvatar(char)then return end
local function sweep()
local dd=char:GetDescendants()
local dump={}
for i=1,#dd do
if isCharJunk(dd[i])then dump[#dump+1]=dd[i]end
end
for i=1,#dump do kill(dump[i])end
end
sweep()
if hookedChars[char]then return end
hookedChars[char]=true
char.DescendantAdded:Connect(function(d)
if _G.__SXE_VelFlying then return end
if d and d.Parent and not isMine(char)and isCharJunk(d)then kill(d)end
end)
end
local strippedPlots={}
_G.__SXE_StrippedPlots=strippedPlots
local function near(a,b)
return math.abs(a-b)<0.2
end
local function isPlotPadPart(d)
if not d or PART_CLASS[d.ClassName]~=true then return false end
if d.Name=="structure base home"or d.Name=="Spawn"then return false end
local s=d.Size
if near(s.X,4)and near(s.Y,1)and near(s.Z,4)then return true end
if near(s.X,2)and near(s.Y,0.5)and near(s.Z,2)then return true end
return false
end
local function isPodiumPlate(d)
if not d or PART_CLASS[d.ClassName]~=true then return false end
if d.Name=="Spawn"then return false end
local s=d.Size
if near(s.X,6)and near(s.Y,0.2)and near(s.Z,6)then return true end
if near(s.X,4)and near(s.Y,0.2)and near(s.Z,4)then return true end
return false
end
local function stripPlotDecor(dec)
if not(dec and dec.Parent)then return end
local dump={}
local function walk(x)
local kids=x:GetChildren()
for i=1,#kids do
local d=kids[i]
local cn=d.ClassName
local nm=d.Name
if nm=="Spawn"or nm=="PromptAttachment"or cn=="ProximityPrompt"then
elseif cn=="Model"and isPet(d)then
elseif cn=="Beam"or cn=="PointLight"then
dump[#dump+1]=d
elseif isPlotPadPart(d)then
dump[#dump+1]=d
else
walk(d)
end
end
end
walk(dec)
for i=1,#dump do kill(dump[i])end
end
local function stripPodiumPlates(pods)
if not(pods and pods.Parent)then return end
local dump={}
local function scan(folder)
if not folder then return end
local dd=folder:GetDescendants()
for i=1,#dd do
local d=dd[i]
if d.Name~="Spawn"and d.Name~="PromptAttachment"
and d.ClassName~="ProximityPrompt"and isPodiumPlate(d)then
dump[#dump+1]=d
end
end
end
local slots=pods:GetChildren()
for i=1,#slots do
local slot=slots[i]
local base=slot:FindFirstChild("Base")
if base then scan(base:FindFirstChild("Decorations"))end
scan(slot:FindFirstChild("Decorations"))
end
for i=1,#dump do kill(dump[i])end
end
local function handlePlotChild(plot,ch)
if not(ch and ch.Parent)then return end
local n=ch.Name
if n=="Skin"then stripSkin(ch);return end
if n=="Laser"then
if not skipLaserStrip(plot)then stripLaser(ch)end
return
end
if n=="AnimalPodiums"then stripPodiumPlates(ch);return end
if n=="Decorations"then stripPlotDecor(ch);return end
if n=="Purchases"then
if skipTimerStrip(plot)then
stripPurchasesKeepTimer(ch)
else
kill(ch)
end
return
end
if PLOT_KEEP[n]then return end
if PLOT_NUKE[n]then kill(ch);return end
if isPet(ch)then
local set=_G.SXE_PrioSet
if type(set)=="table"and set[string.lower(n)]~=true and not(_G.EliteShowPlotBrainrots~=false)then
kill(ch)
else
stripPetVfx(ch)
end
return
end
end
local function stripPlotInteriorFast(plot)
if not(plot and plot.Parent)then return end
if _G.__SXE_MyPlot and plot.Name==_G.__SXE_MyPlot then return end
strippedPlots[plot.Name]=true
local kids=plot:GetChildren()
for i=1,#kids do
local ch=kids[i]
if ch and ch.Parent then
local n=ch.Name
if n=="Skin"or n=="Laser"or n=="AnimalPodiums"or n=="Decorations"then
elseif n=="Purchases"and skipTimerStrip(plot)then
stripPurchasesKeepTimer(ch)
elseif PLOT_KEEP[n]then
elseif PLOT_NUKE[n]then
kill(ch)
elseif isPet(ch)then
local set=_G.SXE_PrioSet
if type(set)=="table"and set[string.lower(n)]~=true and not(_G.EliteShowPlotBrainrots~=false)then
kill(ch)
end
end
end
end
end
local function stripPlotVisual(plot)
if not(plot and plot.Parent)then return end
if _G.__SXE_MyPlot and plot.Name==_G.__SXE_MyPlot then return end
local skin=plot:FindFirstChild("Skin")
if skin then stripSkin(skin)end
local laser=plot:FindFirstChild("Laser")
if laser and not skipLaserStrip(plot)then stripLaser(laser)end
local pods=plot:FindFirstChild("AnimalPodiums")
if pods then stripPodiumPlates(pods)end
local dec=plot:FindFirstChild("Decorations")
if dec then stripPlotDecor(dec)end
local kids=plot:GetChildren()
for i=1,#kids do
local ch=kids[i]
if isPet(ch)then stripPetVfx(ch)end
end
end
local function stripPlotInterior(plot)
stripPlotInteriorFast(plot)
stripPlotVisual(plot)
end
local wallOnlyPlots=setmetatable({},{__mode="k"})
local wallPrunePending=setmetatable({},{__mode="k"})
local function stripPlotToWalls(plot)
if not(plot and plot.Parent)then return end
if plot.Name==_G.__SXE_KeepPlot or plot.Name==_G.__SXE_MyPlot then return end
if not wallOnlyPlots[plot]then
wallOnlyPlots[plot]=true
plot.DescendantAdded:Connect(function()
if wallPrunePending[plot]then return end
wallPrunePending[plot]=true
task.defer(function()
wallPrunePending[plot]=nil
stripPlotToWalls(plot)
end)
end)
end
if _G.__SXE_VelFlying then return end
local keep,found={[plot]=true},false
for _,d in ipairs(plot:GetDescendants())do
if isWallStructure(d)then
found=true
local ancestor=d
while ancestor and ancestor~=plot do
keep[ancestor]=true
ancestor=ancestor.Parent
end
end
end
if not found then return end
local function prune(parent)
for _,child in ipairs(parent:GetChildren())do
if isWallStructure(child)then
elseif keep[child]then
prune(child)
else
kill(child)
end
end
end
prune(plot)
end
_G.SXE_StripPlotToWalls=stripPlotToWalls
sxeOptimization.flushWallPlots=function()
for plot in pairs(wallOnlyPlots)do stripPlotToWalls(plot)end
end
local function connectPlot(plot)
if not(plot and plot.Parent)then return end
plot.ChildAdded:Connect(function(ch)
if wallOnlyPlots[plot]then return end
if _G.__SXE_VelFlying then return end
handlePlotChild(plot,ch)
end)
plot.DescendantAdded:Connect(function(d)
if wallOnlyPlots[plot]then return end
if _G.__SXE_VelFlying then return end
if not d then return end
if underUnlock(d)then return end
local cn=d.ClassName
if cn=="BillboardGui"or cn=="SurfaceGui"then
if skipTimerStrip(plot)and isRemainingTimeGui(d)then return end
kill(d)
return
end
if d.Name=="Spawn"or d.Name=="PromptAttachment"or cn=="ProximityPrompt"then
return
end
if d.Name=="Decorations"and d.Parent==plot then
stripPlotDecor(d)
return
end
local p=d.Parent
if not p then return end
if p.Name=="LaserHitbox"then kill(d);return end
if PART_CLASS[d.ClassName]then
if isPlotPadPart(d)then
local x=p
local inPlotDec,skip=false,false
while x and x~=plot do
if isPet(x)or x.Name=="Spawn"or x.Name=="AnimalPodiums"then
skip=true;break
end
if x.Name=="Decorations"and x.Parent==plot then inPlotDec=true end
x=x.Parent
end
if inPlotDec and not skip then kill(d);return end
elseif isPodiumPlate(d)then
local x=p
local inDec,skip=false,false
while x and x~=plot do
if x.Name=="Spawn"then skip=true;break end
if x.Name=="Decorations"then inDec=true end
if x.Name=="AnimalPodiums"then
if inDec and not skip then kill(d)end
return
end
x=x.Parent
end
end
end
local sk=p
while sk and sk~=plot do
if sk.Name=="Skin"then
if isSkinJunk(d)then kill(d)end
return
end
sk=sk.Parent
end
local las=p
while las and las~=plot do
if las.Name=="Laser"then
if skipLaserStrip(plot)then return end
if PART_CLASS[d.ClassName]then
pcall(function()
d.CanCollide=false
d.CanTouch=false
end)
end
queueStripLaser(las)
return
end
las=las.Parent
end
end)
end
local function plotIsMine(plot)
if not plot then return false end
if _G.__SXE_MyPlot and plot.Name==_G.__SXE_MyPlot then return true end
local ch
pcall(function()
if _G.XenSyncGet then ch=_G.XenSyncGet(plot.Name)end
end)
if ch and _G.SXE_IsMyPlot and _G.SXE_IsMyPlot(ch)then
_G.__SXE_MyPlot=plot.Name
return true
end
return false
end
local function canDestroyPlot(plot)
if not plot then return false end
if plotIsMine(plot)then return false end
local keep=_G.__SXE_KeepPlot
if keep and plot.Name==keep then return false end
if not _G.__SXE_MyPlot then return false end
return plot.Name~=_G.__SXE_MyPlot
end
local hookedPlots
local function hookPlot(plot)
if plotIsMine(plot)then return end
stripPlotInterior(plot)
connectPlot(plot)
end
local function hookPlots(folder)
if not folder or hookedPlots==folder then return end
hookedPlots=folder
local kids=folder:GetChildren()
for i=1,#kids do
if not plotIsMine(kids[i])then
stripPlotInterior(kids[i])
connectPlot(kids[i])
end
end
folder.ChildAdded:Connect(function(plot)
hookPlot(plot)
if canDestroyPlot(plot)then
stripPlotToWalls(plot)
end
end)
end
_G.SXE_LockPrioPlot=function(plotName)
if not plotName then return end
_G.__SXE_KeepPlot=tostring(plotName)
local plots=workspace:FindFirstChild("Plots")
if not plots then return end
local kids=plots:GetChildren()
for i=1,#kids do
local plot=kids[i]
if canDestroyPlot(plot)then
stripPlotToWalls(plot)
end
end
local mine=_G.__SXE_MyPlot and plots:FindFirstChild(_G.__SXE_MyPlot)
if mine and _G.SXE_NukePlotPodiums then
pcall(_G.SXE_NukePlotPodiums,mine)
end
local keepPlot=_G.__SXE_KeepPlot and plots:FindFirstChild(_G.__SXE_KeepPlot)
if keepPlot and _G.SXE_StripNonPrioPodiums then
pcall(_G.SXE_StripNonPrioPodiums,keepPlot)
end
end
local function stripMap(map)
local function handle(x)
if _G.__SXE_VelFlying then return end
if x and not MAP_KEEP[x.Name]then kill(x)end
end
local kids=map:GetChildren()
for i=1,#kids do handle(kids[i])end
map.ChildAdded:Connect(handle)
end
local hookedRma
local rmaBoxDone=false
local function hookRma(rma)
if not rma then return end
if rmaBoxDone then
kill(rma)
return
end
if hookedRma==rma then return end
hookedRma=rma
local function nuke()
if _G.__SXE_VelFlying then return end
if rmaBoxDone then return end
rmaBoxDone=true
kill(rma)
end
if#rma:GetChildren()>0 then
nuke()
else
rma.ChildAdded:Connect(nuke)
end
end
local function onWsChild(ch)
if not ch then return end
if _G.__SXE_VelFlying then return end
local n=ch.Name
if ch.ClassName=="Camera"or ch.ClassName=="Terrain"then return end
if n=="Plots"then hookPlots(ch);return end
if n=="RenderedMovingAnimals"then hookRma(ch);return end
if n=="Map"then stripMap(ch);return end
if isMine(ch)then return end
if isUuidName(n)then kill(ch);return end
if isOtherAvatar(ch)then stripOtherChar(ch);return end
if ch.ClassName=="Model"then
ch.ChildAdded:Connect(function()
if isOtherAvatar(ch)then stripOtherChar(ch)end
end)
end
if string.sub(n,1,7)=="BeeHive"or(string.sub(n,1,7)=="Sentry_"and _G.EliteTurretESP==false)then
kill(ch)
return
end
if WS_KILL[n]or ch.ClassName=="Highlight"then kill(ch);return end
if ch.ClassName=="Model"and string.find(n,"'s Rainbow",1,true)then
kill(ch)
end
end
local wsch=workspace:GetChildren()
local plotsFolder,mapFolder,rmaFolder
local rest={}
for i=1,#wsch do
local ch=wsch[i]
local n=ch.Name
if n=="Plots"then plotsFolder=ch
elseif n=="Map"then mapFolder=ch
elseif n=="RenderedMovingAnimals"then rmaFolder=ch
else rest[#rest+1]=ch end
end
if mapFolder then stripMap(mapFolder)end
if rmaFolder then hookRma(rmaFolder)end
for i=1,#rest do onWsChild(rest[i])end
if plotsFolder then hookPlots(plotsFolder)end
workspace.ChildAdded:Connect(onWsChild)
local function hookPlrChar(plr)
if not plr or plr==LP then return end
if plr.Character then stripOtherChar(plr.Character)end
plr.CharacterAdded:Connect(stripOtherChar)
end
local plrs=Players:GetPlayers()
for i=1,#plrs do hookPlrChar(plrs[i])end
Players.PlayerAdded:Connect(hookPlrChar)
local function onLit(x)
if _G.__SXE_VelFlying then return end
if not x then return end
local cn=x.ClassName
if cn=="Sky"or cn=="Atmosphere"or cn=="Clouds"
or cn=="SunRaysEffect"or cn=="ColorCorrectionEffect"then
kill(x)
end
end
local lit=Lighting:GetChildren()
for i=1,#lit do onLit(lit[i])end
Lighting.ChildAdded:Connect(onLit)
local function stripCamFx(x)
if not x then return end
local cn=x.ClassName
if cn=="ColorCorrectionEffect"or cn=="BlurEffect"then kill(x)end
end
local hookedCam
local function hookCam(cam)
if not cam or hookedCam==cam then return end
hookedCam=cam
local ck=cam:GetChildren()
for i=1,#ck do stripCamFx(ck[i])end
cam.ChildAdded:Connect(stripCamFx)
end
hookCam(workspace.CurrentCamera)
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
hookCam(workspace.CurrentCamera)
end)
workspace.DescendantAdded:Connect(function(d)
if not d then return end
if _G.__SXE_VelFlying then return end
local cn=d.ClassName
if cn=="BillboardGui"or cn=="SurfaceGui"or cn=="Decal"or cn=="Texture"then
if underUnlock(d)then return end
if(cn=="BillboardGui"or cn=="SurfaceGui")
and skipTimerStrip(plotOf(d))and isRemainingTimeGui(d)then
return
end
kill(d)
end
end)
if mapFolder and mapFolder.Parent then
local md=mapFolder:GetDescendants()
local _t0=os.clock()
for i=1,#md do
local cn=md[i].ClassName
if cn=="Decal"or cn=="Texture"then kill(md[i])end
if os.clock()-_t0>0.004 then
task.wait()
_t0=os.clock()
end
end
end
do
local ter=workspace.Terrain
pcall(function()ter.Decoration=false end)
pcall(function()ter:Clear()end)
local kids=ter:GetChildren()
for i=1,#kids do kill(kids[i])end
ter.ChildAdded:Connect(function(ch)
if _G.__SXE_VelFlying then return end
kill(ch)
end)
ter.DescendantAdded:Connect(function(d)
if _G.__SXE_VelFlying then return end
if d then kill(d)end
end)
end
_G.__SXE_StripDone=true
end
do
local _noPrioN,_noPrioSt={},{}
local _prioSlots,_podHook,_myPodNuke={},{},{}
local function nukePlotPodiums(plot)
if not(plot and plot.Parent)then return end
if _G.EliteShowPlotBrainrots~=false then return end
if _myPodNuke[plot]then
local pods=plot:FindFirstChild("AnimalPodiums")
if pods then
local kids=pods:GetChildren()
for i=1,#kids do _G.SXE_Kill(kids[i])end
end
return
end
_myPodNuke[plot]=true
local function wipe(folder)
if not folder then return end
local kids=folder:GetChildren()
for i=1,#kids do _G.SXE_Kill(kids[i])end
folder.ChildAdded:Connect(function(ch)
_G.SXE_Kill(ch)
end)
end
wipe(plot:FindFirstChild("AnimalPodiums"))
plot.ChildAdded:Connect(function(ch)
if ch and ch.Name=="AnimalPodiums"then wipe(ch)end
end)
end
local function stripNonPrioPodiums(plot)
if not(plot and plot.Parent)then return end
if _G.EliteShowPlotBrainrots~=false then return end
if _G.__SXE_MyPlot and plot.Name==_G.__SXE_MyPlot then
nukePlotPodiums(plot)
return
end
local set=_G.SXE_PrioSet
if type(set)~="table"then return end
local ch
pcall(function()ch=_G.XenSyncGet(plot.Name)end)
if ch and isMyPlot(ch)then
_G.__SXE_MyPlot=plot.Name
nukePlotPodiums(plot)
return
end
local list=ch and channelGet(ch,"AnimalList")
if type(list)~="table"then return end
local keepSlots={}
for slot,ad in pairs(list)do
if type(ad)=="table"and type(ad.Index)=="string"
and set[string.lower(ad.Index)]then
keepSlots[tostring(slot)]=true
end
end
if not next(keepSlots)then return end
_prioSlots[plot.Name]=keepSlots
local pods=plot:FindFirstChild("AnimalPodiums")
if not pods then return end
local kids=pods:GetChildren()
for i=1,#kids do
local slotInst=kids[i]
if not keepSlots[tostring(slotInst.Name)]then
_G.SXE_Kill(slotInst)
end
end
if not _podHook[plot]then
_podHook[plot]=true
pods.ChildAdded:Connect(function(slotInst)
local ks=_prioSlots[plot.Name]
if slotInst and ks and not ks[tostring(slotInst.Name)]then
_G.SXE_Kill(slotInst)
end
end)
end
end
_G.SXE_NukePlotPodiums=nukePlotPodiums
_G.SXE_StripNonPrioPodiums=stripNonPrioPodiums
local function stripNoPrioPlots()
local plots=workspace:FindFirstChild("Plots")
if not plots then return end
local keep=_G.__SXE_KeepPlot
local set=_G.SXE_PrioSet
for _,plot in ipairs(plots:GetChildren())do
if plot.Name==_G.__SXE_MyPlot then
pcall(nukePlotPodiums,plot)
continue
end
if keep and plot.Name==keep then
pcall(stripNonPrioPodiums,plot)
continue
end
local ch
pcall(function()ch=_G.XenSyncGet(plot.Name)end)
if ch and isMyPlot(ch)then
_G.__SXE_MyPlot=plot.Name
pcall(nukePlotPodiums,plot)
continue
end
local list=ch and channelGet(ch,"AnimalList")
if type(list)~="table"then continue end
local n,hasPrio=0,false
for _,ad in pairs(list)do
n+=1
if type(ad)=="table"and type(ad.Index)=="string"
and set and set[string.lower(ad.Index)]then
hasPrio=true
end
end
if not hasPrio then
for _,c in ipairs(plot:GetChildren())do
if c:IsA("Model")and(c:FindFirstChild("RootPart")or c:FindFirstChild("FakeRootPart"))
and set and set[string.lower(c.Name)]then
hasPrio=true
break
end
end
end
if hasPrio then
_noPrioN[plot.Name]=nil
_noPrioSt[plot.Name]=nil
if _G.__SXE_StrippedPlots then _G.__SXE_StrippedPlots[plot.Name]=nil end
pcall(stripNonPrioPodiums,plot)
continue
end
local key=plot.Name
if n==(_noPrioN[key]or-1)then
_noPrioSt[key]=(_noPrioSt[key]or 0)+1
else
_noPrioN[key]=n
_noPrioSt[key]=0
end
if(_noPrioSt[key]or 0)>=1 then
if _G.__SXE_MyPlot and plot.Name~=_G.__SXE_MyPlot
and not(keep and plot.Name==keep)then
_G.SXE_StripPlotToWalls(plot)
end
end
end
end
_G.__SXE_StripNoPrio=stripNoPrioPlots
end
task.spawn(function()
pcall(__sxeStrip)
task.defer(function()
local plots=workspace:FindFirstChild("Plots")
if not plots then return end
local set=_G.SXE_PrioSet
if type(set)~="table"then return end
for _,plot in ipairs(plots:GetChildren())do
for _,ch in ipairs(plot:GetChildren())do
if not ch:IsA("Model")then continue end
if not(ch:FindFirstChild("RootPart")or ch:FindFirstChild("FakeRootPart")
or ch:FindFirstChildWhichIsA("AnimationController",true))then
continue
end
if not set[string.lower(ch.Name)]and not(_G.EliteShowPlotBrainrots~=false)then
_G.SXE_Kill(ch)
else
pcall(_G.SXE_StripPetVfx,ch)
end
end
end
end)
end)
end)()
end,function(e)
return tostring(e).."\n"..tostring(debug.traceback())
end)
if not __eliteOk then
pcall(function()if setclipboard then setclipboard(tostring(__eliteErr))end end)
end
task.spawn(function()
local holder
pcall(function()
local root=(type(gethui)=="function"and gethui())or game:GetService("CoreGui")
holder=root:FindFirstChild("EliteTurretESP")or Instance.new("Folder")
holder.Name="EliteTurretESP"
holder.Parent=root
end)
if not(holder and holder.Parent)then
holder=Instance.new("Folder")
holder.Name="EliteTurretESP"
holder.Parent=game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end
local RED=Color3.fromRGB(255,60,60)
local WORDS={"hit","range","zone","detect","radius","area","trigger","sensor"}
local tracked={}
local function isTurret(m)
if not(m and m.Parent==workspace and m:IsA("Model"))then
return false
end
return string.sub(m.Name,1,7)=="Sentry_"or string.find(string.lower(m.Name),"turret",1,true)~=nil
end
local function clear(m)
local t=tracked[m]
if t then
for _,o in ipairs(t.objs)do
pcall(function()o:Destroy()end)
end
tracked[m]=nil
end
end
local function build(m)
clear(m)
if _G.EliteTurretESP==false or not isTurret(m)then
return
end
local objs,hits,names={},{},{}
local all=m:GetDescendants()
local hl=Instance.new("Highlight")
hl.Adornee=m
hl.FillColor=RED
hl.FillTransparency=0.65
hl.OutlineColor=RED
hl.OutlineTransparency=0
hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
hl.Parent=holder
objs[#objs+1]=hl
for _,d in ipairs(all)do
if d:IsA("BasePart")then
local ln=string.lower(d.Name)
local named=false
for _,w in ipairs(WORDS)do
if string.find(ln,w,1,true)then
named=true
break
end
end
if named or d.Transparency>=0.95 then
hits[#hits+1]=d
names[#names+1]=d.Name
end
end
end
for _,p in ipairs(hits)do
local a
if p:IsA("Part")and p.Shape==Enum.PartType.Ball then
a=Instance.new("SphereHandleAdornment")
a.Radius=p.Size.X/2
else
a=Instance.new("BoxHandleAdornment")
a.Size=p.Size
end
a.Adornee=p
a.AlwaysOnTop=true
a.ZIndex=5
a.Color3=RED
a.Transparency=0.7
a.Parent=holder
objs[#objs+1]=a
end
local bb
if #hits==0 then
bb=Instance.new("BoxHandleAdornment")
bb.AlwaysOnTop=true
bb.ZIndex=5
bb.Color3=RED
bb.Transparency=0.75
bb.Parent=holder
objs[#objs+1]=bb
end
tracked[m]={objs=objs,bb=bb,n=#all}
pcall(eliteSay,"[TURRET] "..m.Name..": "..#all.." parts, hitbox "..(#hits>0 and table.concat(names,", ")or"= whole turret box"))
end
local function refresh(m,t)
local cnt=#m:GetDescendants()
if cnt~=t.n then
build(m)
return
end
local bb=t.bb
if not bb then
return
end
local base=m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart",true)
local ok,cf,size=pcall(function()
return m:GetBoundingBox()
end)
if ok and base then
bb.Adornee=base
bb.CFrame=base.CFrame:ToObjectSpace(cf)
bb.Size=size
end
end
local function consider(ch)
if isTurret(ch)then
task.wait(0.2)
build(ch)
end
end
for _,ch in ipairs(workspace:GetChildren())do
task.spawn(consider,ch)
end
workspace.ChildAdded:Connect(function(ch)
task.spawn(consider,ch)
end)
workspace.ChildRemoved:Connect(function(ch)
clear(ch)
end)
local lastOn=_G.EliteTurretESP~=false
while true do
task.wait(0.5)
local on=_G.EliteTurretESP~=false
if on~=lastOn then
lastOn=on
if on then
for _,ch in ipairs(workspace:GetChildren())do
if isTurret(ch)then
build(ch)
end
end
else
for m in pairs(tracked)do
clear(m)
end
end
end
for m,t in pairs(tracked)do
if m.Parent~=workspace then
clear(m)
else
pcall(refresh,m,t)
end
end
end
end)
task.spawn(function()
local LP2=game:GetService("Players").LocalPlayer
local RS2=game:GetService("RunService")
local params=RaycastParams.new()
params.FilterType=Enum.RaycastFilterType.Exclude
local lastGround,lastY,lastAt=nil,0,0
local pad,padAt=nil,0
local acc=0
RS2.Heartbeat:Connect(function(dt)
if _G.EliteGroundGuard==false then
return
end
local ch=LP2.Character
local h=ch and ch:FindFirstChild("HumanoidRootPart")
if not h then
return
end
local now=os.clock()
if pad then
local fx=Vector3.new(h.Position.X-pad.Position.X,0,h.Position.Z-pad.Position.Z).Magnitude
if now-padAt>8 or fx>14 or not pad.Parent then
pcall(function()
pad:Destroy()
end)
pad=nil
end
end
if lastGround and now-lastAt<0.5 and not lastGround:IsDescendantOf(workspace)then
lastGround=nil
if not pad then
pcall(function()
pad=Instance.new("Part")
pad.Name="EliteGroundGuard"
pad.Anchored=true
pad.CanCollide=true
pad.Transparency=1
pad.Size=Vector3.new(14,1,14)
pad.CFrame=CFrame.new(h.Position.X,lastY-0.5,h.Position.Z)
pad.Parent=workspace
padAt=now
end)
pcall(function()
local v=h.AssemblyLinearVelocity
if v.Y<0 then
h.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z)
end
end)
pcall(eliteSay,"[GROUND] the base under you vanished (owner left?) - holding you up")
end
return
end
acc=acc+dt
if acc<0.1 then
return
end
acc=0
params.FilterDescendantsInstances={ch}
local r=workspace:Raycast(h.Position,Vector3.new(0,-10,0),params)
local plots=workspace:FindFirstChild("Plots")
if r and plots and r.Instance:IsDescendantOf(plots)then
lastGround,lastY,lastAt=r.Instance,r.Position.Y,now
end
end)
end)