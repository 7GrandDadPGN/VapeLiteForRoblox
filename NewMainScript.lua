local websocketfunc = syn and syn.websocket.connect or Krnl and Krnl.WebSocket.connect or websocket and websocket.connect
local suc, web = pcall(function() return websocketfunc("ws://127.0.0.1:6892/") end)
repeat 
    task.wait()
    if not suc or suc and type(web) == "boolean" then
        suc, web = pcall(function() return websocketfunc("ws://127.0.0.1:6892/") end)
    end
until suc and type(web) ~= "boolean"
local readsettings = Instance.new("BindableEvent")
local modules = {}
local modulefunctions = {}
local modulesenabled = {}
local players = game:GetService("Players")
local lplr = players.LocalPlayer
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local RenderStepTable = {}

local function BindToRenderStep(name, num, func)
	if RenderStepTable[name] == nil then
		RenderStepTable[name] = game:GetService("RunService").RenderStepped:connect(func)
	end
end
local function UnbindFromRenderStep(name)
	if RenderStepTable[name] then
		RenderStepTable[name]:Disconnect()
		RenderStepTable[name] = nil
	end
end

local function isAlive(plr)
	if plr then
		return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
	end
	return lplr and lplr.Character and lplr.Character.Parent ~= nil and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character:FindFirstChild("Head") and lplr.Character:FindFirstChild("Humanoid")
end

local function sendrequest(tab)
    local newstr = game:GetService("HttpService"):JSONEncode(tab)
    if suc then
        web:Send(newstr)
    end
end

local function addModule(name, desc, func)
    local tab = {
        name = name,
        desc = desc,
        options = {}
    }
    table.insert(modules, tab)
    modulefunctions[name] = func
    modulesenabled[name] = false
    return {
        addToggle = function(name2, func2)
            table.insert(tab.options, {
                name = name2,
                type = "Toggle",
                toggled = false
            })
            modulefunctions[name..name2] = func2
        end,
        addSlider = function(name2, min, max, default, func2)
            table.insert(tab.options, {
                name = name2,
                type = "Slider",
                min = min,
                max = max,
                state = default
            })
            modulefunctions[name..name2] = func2
        end
    }
end 

local function makerandom(min, max)
	return Random.new().NextNumber(Random.new(), min, max)
end

local function findModule(name)
    for i,v in pairs(modules) do 
        if v.name == name then 
            return v
        end
    end
    return nil
end

local function findOption(name, name2)
    for i,v in pairs(modules) do 
        if v.name == name then 
            for i2,v2 in pairs(v.options) do 
                if v2.name == name2 then
                    return v2
                end
            end
        end
    end
    return nil
end
local uninjectfunc = lplr.OnTeleport:connect(function(state)
    shared.noinject = true
end)

if suc and type(web) ~= "boolean" then
    if game.GameId == 2619619496 then
        local Flamework = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@flamework"].core.out).Flamework
		repeat task.wait() until Flamework.isInitialized
        local KnitClient = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"].knit.src).KnitClient
        local Client = require(game:GetService("ReplicatedStorage").TS.remotes).default.Client
        if game.PlaceId == 6872265039 then
            local bedwars = {
                ["sprintTable"] = KnitClient.Controllers.SprintController,
            }
            local sprint = addModule("Sprint", "Automatically sprints for you.", function(callback)
                if callback then
                    spawn(function()
                        repeat
                            task.wait()
                            if bedwars["sprintTable"].sprinting == false then
                                bedwars["sprintTable"]:startSprinting()
                            end
                        until modulesenabled["Sprint"] == false
                    end)
                end
            end)
        else
            local function getremote(tab)
                for i,v in pairs(tab) do
                    if v == "Client" then
                        return tab[i + 1]
                    end
                end
                return ""
            end

            local InventoryUtil = require(game:GetService("ReplicatedStorage").TS.inventory["inventory-util"]).InventoryUtil
            local bedwars = {   
                ["AppController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out.client.controllers["app-controller"]).AppController,
                ["BlockController"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["block-engine"].out).BlockEngine,
                ["BlockPlacementController"] = KnitClient.Controllers.BlockPlacementController,
                ["BlockEngine"] = require(lplr.PlayerScripts.TS.lib["block-engine"]["client-block-engine"]).ClientBlockEngine,
                ["ClientHandlerSyncEvents"] = require(lplr.PlayerScripts.TS["client-sync-events"]).ClientSyncEvents,
                ["ClientStoreHandler"] = require(game.Players.LocalPlayer.PlayerScripts.TS.ui.store).ClientStore,
                ["getEntityTable"] = require(game:GetService("ReplicatedStorage").TS.entity["entity-util"]).EntityUtil,
                ["getItemMetadata"] = require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta,
                ["getInventory"] = function(plr)
                    local suc, result = pcall(function() return InventoryUtil.getInventory(plr) end)
                    return (suc and result or {
                        ["items"] = {},
                        ["armor"] = {},
                        ["hand"] = nil
                    })
                end,
                ["ItemTable"] = debug.getupvalue(require(game:GetService("ReplicatedStorage").TS.item["item-meta"]).getItemMeta, 1),
                ["prepareHashing"] = require(game:GetService("ReplicatedStorage").TS["remote-hash"]["remote-hash-util"]).RemoteHashUtil.prepareHashVector3,
                ["PlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
                ["SoundManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
			    ["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
                ["sprintTable"] = KnitClient.Controllers.SprintController,
                ["SwordController"] = KnitClient.Controllers.SwordController,
                ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
            }

            local function hashvec(vec)
                return {
                    ["hash"] = bedwars["AttackHashFunction"](bedwars["AttackHashText"], bedwars["prepareHashing"](vec)), 
                    ["value"] = vec
                }
            end

            bedwars["AttackRemote"] = getremote(debug.getconstants(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"]))
            for i,v in pairs(debug.getupvalues(getmetatable(KnitClient.Controllers.SwordController)["attackEntity"])) do
                if tostring(v) == "AC" then
                    bedwars["AttackHashTable"] = v
                    for i2,v2 in pairs(v) do
                        if i2:find("constructor") == nil and i2:find("__index") == nil and i2:find("new") == nil then
                            bedwars["AttackHashFunction"] = v2
                            bedwars["AttachHashText"] = i2
                        end
                    end
                end
            end

            local function getEquipped()
                local typetext = ""
                local obj = (isAlive() and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value or nil)
                if obj then
                    if obj.Name:find("sword") or obj.Name:find("blade") or obj.Name:find("baguette") or obj.Name:find("scythe") or obj.Name:find("dao") then
                        typetext = "sword"
                    end
                    if obj.Name:find("wool") or bedwars["ItemTable"][obj.Name]["block"] then
                        typetext = "block"
                    end
                    if obj.Name:find("bow") then
                        typetext = "bow"
                    end
                end
                return {["Object"] = obj, ["Type"] = typetext}
            end

            local function getItemFromHotbar(item)
                for i,v in pairs(bedwars["ClientStoreHandler"]:getState().Inventory.observedInventory.hotbar) do 
                    if type(v.item) == "table" and v.item.itemType == item then
                        return i - 1
                    end
                end
                return nil
            end

            local function getBestTool(block)
                local tool = nil
                local toolnum = 0
                local blockmeta = bedwars["getItemMetadata"](block)
                local blockType = ""
                if blockmeta["block"] and blockmeta["block"]["breakType"] then
                    blockType = blockmeta["block"]["breakType"]
                end
                for i,v in pairs(bedwars["getInventory"](lplr)["items"]) do
                    local meta = bedwars["getItemMetadata"](v["itemType"])
                    if meta["breakBlock"] and meta["breakBlock"][blockType] then
                        tool = v
                        break
                    end
                end
                return tool
            end

            local updateitem = Instance.new("BindableEvent")
            local inputobj = nil
            local tempconnection
            tempconnection = game:GetService("UserInputService").InputBegan:connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    inputobj = input
                    tempconnection:Disconnect()
                end
            end)
            updateitem.Event:connect(function(inputObj)
                if uis:IsMouseButtonPressed(0) then
                    game:GetService("ContextActionService"):CallFunction("block-break", Enum.UserInputState.Begin, inputobj)
                end
            end)

            local function switchToAndUseTool(block)
                local tool = getBestTool(block.Name)
                if tool and (isAlive() and lplr.Character:FindFirstChild("HandInvItem") and lplr.Character.HandInvItem.Value ~= tool["tool"]) then
                    bedwars["ClientStoreHandler"]:dispatch({
                        type = "InventorySelectHotbarSlot", 
                        slot = getItemFromHotbar(tool["itemType"])
                    })
                    task.wait(0.1)
                    updateitem:Fire(inputobj)
                end
            end

            local function targetCheck(plr, check)
                return (check and plr.Character.Humanoid.Health > 0 and plr.Character:FindFirstChild("ForceField") == nil or check == false)
            end

            local function isPlayerTargetable(plr, target, friend, team, naked)
                return plr ~= lplr and plr and isAlive(plr) and targetCheck(plr, target) and bedwars["PlayerUtil"].getGamePlayer(lplr):getTeamId() ~= bedwars["PlayerUtil"].getGamePlayer(plr):getTeamId()
            end

            local function GetNearestHumanoidToPosition(player, distance)
                local closest, returnedplayer = distance, nil
                if isAlive() then
                    for i, v in pairs(players:GetChildren()) do
                        if isPlayerTargetable((player and v or nil), true, true) and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Head") then
                            local mag = (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude
                            if mag <= closest then
                                closest = mag
                                returnedplayer = v
                            end
                        end
                    end
                end
                return returnedplayer
            end

            local function isNotHoveringOverGui()
                local mousepos = game:GetService("UserInputService"):GetMouseLocation() - Vector2.new(0, 36)
                for i,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui:GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
                    if v.Active then
                        return false
                    end
                end
                for i,v in pairs(game:GetService("CoreGui"):GetGuiObjectsAtPosition(mousepos.X, mousepos.Y)) do 
                    if v.Active then
                        return false
                    end
                end
                return true
            end
            
            local autoclickertick = tick()
            local autoclickerconnection1
            local autoclickerconnection2
            local aimbegan
            local aimended
            local aimactive = false
            local aimassist = addModule("AimAssist", "Automatically aims for you.", function(callback)
                if callback then
                    aimbegan = uis.InputBegan:connect(function(input1)
                        if uis:GetFocusedTextBox() == nil and input1.UserInputType == Enum.UserInputType.MouseButton1 then
                            aimactive = true
                        end
                    end)
                    
                    aimended = uis.InputEnded:connect(function(input1)
                        if input1.UserInputType == Enum.UserInputType.MouseButton1 then
                            aimactive = false
                        end
                    end)

                    local function aimpos(vec, multiplier)
                        local newvec = (vec - uis:GetMouseLocation() - Vector2.new(0, 36)) * tonumber(multiplier)
                        mousemoverel(newvec.X, newvec.Y)
                    end

                    local aimmulti = findOption("AimAssist", "Smoothness")
                    BindToRenderStep("AimAssist", 1, function()
                        if aimactive then
                            local targettable = {}
                            local targetsize = 0
                            local plr = GetNearestHumanoidToPosition(true, 18)
                            if plr and getEquipped()["Type"] == "sword" and #bedwars["AppController"]:getOpenApps() <= 1 and isNotHoveringOverGui() and bedwars["SwordController"]:canSee({["instance"] = plr.Character, ["player"] = plr, ["getInstance"] = function() return plr.Character end}) then
                                local pos, vis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                                if vis and isrbxactive() then
                                    local senst = UserSettings():GetService("UserGameSettings").MouseSensitivity * (1 - (aimmulti.state / 100))
                                    aimpos(Vector2.new(pos.X, pos.Y), senst)
                                end
                                --cam.CFrame = cam.CFrame:lerp(CFrame.new(cam.CFrame.p, plr.Character.HumanoidRootPart.Position), (1 / AimSpeed["Value"]) - (AimAssistStrafe["Enabled"] and (uis:IsKeyDown(Enum.KeyCode.A) or uis:IsKeyDown(Enum.KeyCode.D)) and 0.01 or 0))
                            end
                        end
                    end)
                else
                    UnbindFromRenderStep("AimAssist")
                    aimbegan:Disconnect()
                    aimended:Disconnect()
                    aimactive = false
                end
            end)
            aimassist.addSlider("Smoothness", 0, 100, 80, function() end)
            local balloondebounce = false
            local autoballoon = addModule("AutoBalloon", "Inflates balloons after under a certain y level", function(callback)
                if callback then
                    local balloonylevel = findOption("AutoBalloon", "Y Level")
                    local balloondelay = findOption("AutoBalloon", "Delay")
                    spawn(function()
                        repeat
                            task.wait(0.1)
                            if isAlive() then
                                if (lplr.Character.HumanoidRootPart.Position.Y <= (balloonylevel.state - 100)) and lplr.Character.HumanoidRootPart.Velocity.Y <= -20 and balloondebounce == false then
                                    local oldhotbarslot = bedwars["ClientStoreHandler"]:getState().Inventory.observedInventory.hotbarSlot
                                    local balloonslot = getItemFromHotbar("balloon")
                                    if balloonslot then 
                                        balloondebounce = true
                                        for i = 1, 3 do
                                            bedwars["ClientStoreHandler"]:dispatch({
                                                type = "InventorySelectHotbarSlot", 
                                                slot = balloonslot
                                            })
                                            task.wait(balloondelay.state / 100)
                                            KnitClient.Controllers.BalloonController:inflateBalloon()
                                        end
                                        task.wait(balloondelay.state / 100)
                                        bedwars["ClientStoreHandler"]:dispatch({
                                            type = "InventorySelectHotbarSlot", 
                                            slot = oldhotbarslot
                                        })
                                        balloondebounce = false
                                    end
                                end
                            end
                        until modulesenabled["AutoBalloon"] == false
                    end)
                end
            end)
            autoballoon.addSlider("Y Level", 1, 100, 20, function() end)
            autoballoon.addSlider("Delay", 1, 100, 60, function() end)
            local autoclicker = addModule("AutoClicker", "Automatically clicks for you.", function(callback)
                if callback then
                    autoclickerconnection1 = uis.InputBegan:connect(function(input, gameProcessed)
                        if gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
                            autoclickermousedown = true
                        end
                    end)
                    autoclickerconnection2 = uis.InputEnded:connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            autoclickermousedown = false
                        end
                    end)
                    local cpsmodule = findOption("AutoClicker", "CPS")
                    spawn(function()
                        repeat
                            task.wait((1 / makerandom(math.clamp(cpsmodule.state - 2, 1, 20), cpsmodule.state)))
                            if isAlive() and autoclickermousedown and #bedwars["AppController"]:getOpenApps() <= 1 and isNotHoveringOverGui() then 
                                if getEquipped()["Type"] == "sword" then 
                                    spawn(function()
                                        bedwars["SwordController"]:swingSwordAtMouse()
                                    end)
                                end
                                if getEquipped()["Type"] == "block" and modulesenabled["AutoClicker/Place Block"] and bedwars["BlockPlacementController"].blockPlacer then 
                                    local mouseinfo = bedwars["BlockPlacementController"].blockPlacer.clientManager:getBlockSelector():getMouseInfo(0)
                                    if mouseinfo then
                                        spawn(function()
                                            if bedwars["BlockPlacementController"].blockPlacer then
                                                bedwars["BlockPlacementController"].blockPlacer:placeBlock(mouseinfo.placementPosition)
                                            end
                                        end)
                                    end
                                end
                            end
                        until modulesenabled["AutoClicker"] == false
                    end)
                else
                    UnbindFromRenderStep("AutoClicker")
                    if autoclickerconnection1 then
                        autoclickerconnection1:Disconnect()
                    end
                    if autoclickerconnection2 then
                        autoclickerconnection2:Disconnect()
                    end
                end
            end)
            autoclicker.addSlider("CPS", 1, 20, 10, function() end)
            autoclicker.addToggle("Place Block", function(callback) end)
            local autotoolconnection
            local autotool = addModule("AutoTool", "Switches tool to highlighted block", function(callback)
                if callback then
                   autotoolconnection = KnitClient.Controllers.BlockBreakController.blockBreaker.onBreak:Connect(function()
                        local mouseinfo = KnitClient.Controllers.BlockBreakController.blockBreaker.clientManager:getBlockSelector():getMouseInfo(1)
                        if mouseinfo and mouseinfo.target then
                            switchToAndUseTool(mouseinfo.target.blockInstance)
                        end
                   end)
                else
                    if autotoolconnection then
                        autotoolconnection:Disconnect()
                    end
                end
            end)
            local sprint = addModule("Sprint", "Automatically sprints for you.", function(callback)
                if callback then
                    spawn(function()
                        repeat
                            task.wait()
                            if bedwars["sprintTable"].sprinting == false then
                                bedwars["sprintTable"]:startSprinting()
                            end
                        until modulesenabled["Sprint"] == false
                    end)
                end
            end)
            local reachfunc
            local reach = addModule("Reach", "Gives you 3 studs of extra reach.", function(callback)
                if callback then
                    reachfunc = cam.Viewmodel.Humanoid.Animator.AnimationPlayed:connect(function(anim)
                        if anim.Animation.AnimationId == "rbxassetid://8089691925" then
                            local equipped = getEquipped()
                            if equipped["Type"] == "sword" then
                                local rayparams = RaycastParams.new()
                                rayparams.FilterDescendantsInstances = {lplr.Character}
                                rayparams.FilterType = Enum.RaycastFilterType.Blacklist
                                local ray = workspace:Raycast(lplr:GetMouse().UnitRay.Origin, lplr:GetMouse().UnitRay.Direction * 17.4, rayparams)
                                if ray and ray.Instance and (lplr.Character.PrimaryPart.Position - ray.Instance.Position).Magnitude > 14.4 then
                                    local entity = bedwars["getEntityTable"]:getEntity(ray.Instance)
                                    if entity and bedwars["SwordController"]:canSee(entity) then
                                        local tool = equipped["Object"]
                                        local plr = {Character = entity:getInstance()}
                                        Client:Get(bedwars["AttackRemote"]):CallServer({
                                            ["weapon"] = tool,
                                            ["entityInstance"] = plr.Character,
                                            ["validate"] = {
                                                ["raycast"] = {
                                                    ["cameraPosition"] = hashvec(cam.CFrame.p), 
                                                    ["cursorDirection"] = hashvec(Ray.new(cam.CFrame.p, plr.Character.HumanoidRootPart.Position).Unit.Direction)
                                                },
                                                ["targetPosition"] = hashvec(plr.Character.HumanoidRootPart.Position),
                                                ["selfPosition"] = hashvec(lplr.Character.HumanoidRootPart.Position + (CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, plr.Character.HumanoidRootPart.Position).lookVector * 4))
                                            }
                                        })
                                    end
                                end
                            end
                        end
                    end)
                else
                    reachfunc:Disconnect()
                end
            end)
            local oldhori = 10000
            local oldvert = 300
            local velocity = addModule("Velocity", "Reduces knockback.", function(callback)
                if callback then
                    oldhori = game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:GetAttribute("ConstantManager_kbDirectionStrength")
                    oldvert = game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:GetAttribute("ConstantManager_kbUpwardStrength")
                    local velohori = findOption("Velocity", "Horizontal")
                    local velovert = findOption("Velocity", "Vertical")
                    game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:SetAttribute("ConstantManager_kbDirectionStrength", oldhori * (velohori.state / 100))
                    game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:SetAttribute("ConstantManager_kbUpwardStrength", oldvert * (velovert.state / 100))
                else
                    game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:SetAttribute("ConstantManager_kbDirectionStrength", oldhori)
                    game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:SetAttribute("ConstantManager_kbUpwardStrength", oldvert)
                end
            end)
            velocity.addSlider("Horizontal", 0, 100, 70, function(state) 
                if modulesenabled["Velocity"] then 
                    game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:SetAttribute("ConstantManager_kbDirectionStrength", oldhori * (state / 100))
                end
            end)
            velocity.addSlider("Vertical", 0, 100, 100, function(state) 
                if modulesenabled["Velocity"] then 
                    game:GetService("ReplicatedStorage").TS.damage["knockback-util"]:SetAttribute("ConstantManager_kbUpwardStrength", oldvert * (state / 100))
                end
            end)
        end
    end
    web.OnMessage:connect(function(msg)
        local tab = game:GetService("HttpService"):JSONDecode(msg)
        if tab.msg == "togglemodule" then
            local module = findModule(tab.module)
            if module then 
                modulefunctions[tab.module](tab.state)
                module.toggled = tab.state
                modulesenabled[tab.module] = tab.state
                sendrequest({
                    msg = "writesettings",
                    id = (game.PlaceId == 6872265039 and "bedwarslobby" or "bedwarsmain"),
                    content = game:GetService("HttpService"):JSONEncode(modulesenabled)
                })
            end
        elseif tab.msg == "togglebuttontoggle" then
            local module = findOption(tab.module, tab.setting)
            if module then 
                modulefunctions[tab.module..tab.setting](tab.state)
                module.toggled = tab.state
                modulesenabled[tab.module.."/"..tab.setting] = tab.state
                sendrequest({
                    msg = "writesettings",
                    id = (game.PlaceId == 6872265039 and "bedwarslobby" or "bedwarsmain"),
                    content = game:GetService("HttpService"):JSONEncode(modulesenabled)
                })
            end
        elseif tab.msg == "togglebuttonslider" then
            local module = findOption(tab.module, tab.setting)
            if module then 
                modulefunctions[tab.module..tab.setting](tab.state)
                module.state = tab.state
                modulesenabled[tab.module.."/"..tab.setting] = tab.state
                sendrequest({
                    msg = "writesettings",
                    id = (game.PlaceId == 6872265039 and "bedwarslobby" or "bedwarsmain"),
                    content = game:GetService("HttpService"):JSONEncode(modulesenabled)
                })
            end
        elseif tab.msg == "readsettings" then
            readsettings:Fire(tab.result)
        end
    end)
    sendrequest({
        msg = "readsettings",
        id = (game.PlaceId == 6872265039 and "bedwarslobby" or "bedwarsmain")
    })
    local settingss = readsettings.Event:Wait()
    local suc2, settingstab = pcall(function() return game:GetService("HttpService"):JSONDecode(settingss) end)
    local loaded = false
    if suc2 then
        for i,v in pairs(settingstab) do 
            local module = i:find("/") and findOption(unpack(i:split("/"))) or findModule(i)
            local modulename = i:gsub("/", "")
            if module then
                if module.type then
                    if module.type == "Toggle" and v == true then
                        modulefunctions[modulename](true)
                        module.toggled = true
                        modulesenabled[i] = true
                    elseif module.type == "Slider" then 
                        modulefunctions[modulename](v)
                        module.state = v
                        modulesenabled[i] = v
                    end
                elseif v == true then
                    modulefunctions[modulename](true)
                    module.toggled = true
                    modulesenabled[modulename] = true
                end
            end
        end
        loaded = true
    else
        sendrequest({
            msg = "writesettings",
            id = (game.PlaceId == 6872265039 and "bedwarslobby" or "bedwarsmain"),
            content = "{}"
        })
        loaded = true
    end
    repeat task.wait() until loaded
    sendrequest({
        msg = "connectrequest",
        modules = modules
    })
    web.OnClose:connect(function()
        for i,v in pairs(modulefunctions) do 
            local ok = findModule(i)
            if ok ~= nil and modulesenabled[i] then
                v(false)
                modulesenabled[i] = false
            end
        end
        spawn(function()
            if shared.noinject == nil then
                repeat task.wait() until game:IsLoaded()
                repeat task.wait(5) until isfile("vapelite.injectable.txt")
                delfile("vapelite.injectable.txt")
                loadstring(readfile("vapelite.lua"))()
            end
        end)
    end)
else
    print("websocket error:", web)
end