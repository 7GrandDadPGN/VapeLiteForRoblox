local websocketfunc = syn and syn.websocket.connect or Krnl and Krnl.WebSocket.connect or WebSocket and WebSocket.connect or websocket and websocket.connect
local suc, web = pcall(function() return websocketfunc("ws://127.0.0.1:6892/") end)
repeat 
    task.wait(5)
    if not suc or suc and type(web) == "boolean" then
        suc, web = pcall(function() return websocketfunc("ws://127.0.0.1:6892/") end)
        if not suc or suc and type(web) == "boolean" then
            print("websocket error:", web)
        end
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

local function getplayersnear(range)
    if isAlive() then
        for i,v in pairs(players:GetChildren()) do 
            if v ~= lplr and v:GetAttribute("Team") ~= lplr:GetAttribute("Team") and isAlive(v) and (lplr.Character.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude <= range then 
                return v
            end
        end
    end 
    return nil
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
    local vapelite
    local vapelite2
    local draw
    local textguitextdrawings = {}
    local textguitextdrawings2 = {}
    pcall(function()
        draw = Drawing.new("Text")
        draw.Visible = false
        vapelite = Drawing.new("Image")
        vapelite2 = Drawing.new("Image")
        local logocheck = syn and "VapeLiteLogoSyn.png" or "VapeLiteLogo.png"
        vapelite.Data = shared.VapeDeveloper and readfile(logocheck) or game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeLiteForRoblox/main/"..logocheck, true) or ""
        vapelite.Size = Vector2.new(140, 64)
        vapelite.ZIndex = 2
        vapelite.Position = Vector2.new(3, 36)
        vapelite.Visible = false
        vapelite2.Data = shared.VapeDeveloper and readfile("VapeLiteLogoShadow.png") or game:HttpGet("https://raw.githubusercontent.com/7GrandDadPGN/VapeLiteForRoblox/main/VapeLiteLogoShadow.png", true) or ""
        vapelite2.Size = Vector2.new(140, 64)
        vapelite2.Position = Vector2.new(5, 38)
        vapelite2.ZIndex = 1
        vapelite2.Visible = false
    end)
    local robloxgui = game:GetService("CoreGui"):WaitForChild("RobloxGui", 10)

    local function UpdateHud()
        if modulesenabled["TextGUI"] then
            local text = ""
            local text2 = ""
            local tableofmodules = {}
            local first = true
            
            for i,v in pairs(modulesenabled) do
                local rendermodule = i:find("/") == nil and v 
                if rendermodule and i ~= "TextGUI" then 
                    table.insert(tableofmodules, {["Text"] = i})
                end
            end
            table.sort(tableofmodules, function(a, b) 
                draw.Text = a["Text"]
                textsize1 = draw.TextBounds
                draw.Text = b["Text"]
                textsize2 = draw.TextBounds
                return textsize1.X > textsize2.X 
            end)
            for i,v in pairs(textguitextdrawings) do 
                pcall(function()
                    v:Remove()
                    textguitextdrawings[i] = nil
                end)
            end
            for i,v in pairs(textguitextdrawings2) do 
                pcall(function()
                    v:Remove()
                    textguitextdrawings2[i] = nil
                end)
            end
            local num = 0
            vapelite.Position = Vector2.new((robloxgui.AbsoluteSize.X - 4) - 140, 36)
            vapelite2.Position = Vector2.new((robloxgui.AbsoluteSize.X - 4) - 139, 37)
            for i,v in pairs(tableofmodules) do 
                local newpos = robloxgui.AbsoluteSize.X - 4
                local draw = Drawing.new("Text")
                draw.Color = Color3.fromRGB(67, 117, 255)
                draw.Size = 25
                draw.Font = 0
                draw.Text = v.Text
                newpos = (newpos - (draw.TextBounds.X))

                --onething.Visible and (textguirenderbkg["Enabled"] and 50 or 45) or
                draw.Position = Vector2.new(newpos - 5, (70 + num + draw.TextBounds.Y))
                local draw2 = Drawing.new("Text")
                draw2.Color = Color3.fromRGB(22, 37, 81)
                draw2.Size = 25
                draw2.Font = 0
                draw2.Text = v.Text
                draw2.Position = draw.Position + Vector2.new(1, 1)
                num = num + (draw.TextBounds.Y - 2)
                draw2.ZIndex = 1
                draw.ZIndex = 2
                draw.Visible = true
                draw2.Visible = true
                textguitextdrawings[i] = draw
                textguitextdrawings2[i] = draw2
            end
        end
    end

    local textguiconnection
    local textgui = addModule("TextGUI", "Shows enabled modules", function(callback)
        vapelite.Visible = callback
        vapelite2.Visible = callback
        if callback then 
            textguiconnection = robloxgui:GetPropertyChangedSignal("AbsoluteSize"):connect(function()
                UpdateHud()
            end)
            UpdateHud()
        else
            for i,v in pairs(textguitextdrawings) do 
                pcall(function()
                    v:Remove()
                    textguitextdrawings[i] = nil
                end)
            end
            for i,v in pairs(textguitextdrawings2) do 
                pcall(function()
                    v:Remove()
                    textguitextdrawings2[i] = nil
                end)
            end
        end
    end)
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
                ["PlayerUtil"] = require(game:GetService("ReplicatedStorage").TS.player["player-util"]).GamePlayerUtil,
                ["SoundManager"] = require(game:GetService("ReplicatedStorage")["rbxts_include"]["node_modules"]["@easy-games"]["game-core"].out).SoundManager,
			    ["SoundList"] = require(game:GetService("ReplicatedStorage").TS.sound["game-sound"]).GameSound,
                ["sprintTable"] = KnitClient.Controllers.SprintController,
                ["SwordController"] = KnitClient.Controllers.SwordController,
                ["ViewmodelController"] = KnitClient.Controllers.ViewmodelController,
            }

            local function hashvec(vec)
                return {
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
            local reach = addModule("Reach", "Gives you 4 studs of extra reach.", function(callback)
                if callback then
                    reachfunc = cam.Viewmodel.Humanoid.Animator.AnimationPlayed:connect(function(anim)
                        if anim.Animation.AnimationId == "rbxassetid://8089691925" then
                            local equipped = getEquipped()
                            if equipped["Type"] == "sword" then
                                local rayparams = RaycastParams.new()
                                rayparams.FilterDescendantsInstances = {lplr.Character}
                                rayparams.FilterType = Enum.RaycastFilterType.Blacklist
                                local ray = workspace:Raycast(lplr:GetMouse().UnitRay.Origin, lplr:GetMouse().UnitRay.Direction * 17.99, rayparams)
                                if ray and ray.Instance and (lplr.Character.PrimaryPart.Position - ray.Instance.Position).Magnitude > 14.4 then
                                    local entity = bedwars["getEntityTable"]:getEntity(ray.Instance)
                                    if entity and bedwars["SwordController"]:canSee(entity) then
                                        local tool = equipped["Object"]
                                        local plr = {Character = entity:getInstance()}
                                        Client:Get(bedwars["AttackRemote"]):CallServer({
                                            ["weapon"] = tool,
                                            ["entityInstance"] = plr.Character,
                                            ["chargedAttack"] = {chargeRatio = 1},
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
            local killaurafunc
            local killaura = addModule("Killaura", "Hits no matter where you aim", function(callback)
                if callback then
                    local killaurafov = findOption("Killaura", "Max angle")
                    local killaurareach = findOption("Killaura", "Attack range")
                    killaurafunc = cam.Viewmodel.Humanoid.Animator.AnimationPlayed:connect(function(anim)
                        if anim.Animation.AnimationId == "rbxassetid://8089691925" then
                            local equipped = getEquipped()
                            if equipped["Type"] == "sword" then
                                local plr = getplayersnear(killaurareach.state - 0.001)
                                if plr then 
                                    local entity = bedwars["getEntityTable"]:getEntity(plr.Character)
                                    if entity and bedwars["SwordController"]:canSee(entity) then
                                        local localfacing = lplr.Character.HumanoidRootPart.CFrame.lookVector
                                        local vec = (plr.Character.HumanoidRootPart.Position - lplr.Character.HumanoidRootPart.Position).unit
                                        local ylevel = (lplr.Character.HumanoidRootPart.Position.Y - plr.Character.HumanoidRootPart.Position.Y)
                                        local angle = math.acos(localfacing:Dot(vec))
                                        if angle <= math.rad(killaurafov.state) then
                                            local tool = equipped["Object"]
                                            local pos = (lplr.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).magnitude >= 14 and ((not modulesenabled["Killaura/Vertical Check"]) or ylevel <= 9) and ((not modulesenabled["Killaura/Only reach while moving"]) and lplr.Character.Humanoid.MoveDirection ~= Vector3.new(0, 0, 0)) and CFrame.lookAt(lplr.Character.HumanoidRootPart.Position, plr.Character.HumanoidRootPart.Position).lookVector * 4 or Vector3.new(0, 0, 0)
                                            Client:Get(bedwars["AttackRemote"]):CallServer({
                                                ["weapon"] = tool,
                                                ["entityInstance"] = plr.Character,
                                                ["chargedAttack"] = {chargeRatio = 1},
                                                ["validate"] = {
                                                    ["raycast"] = {
                                                        ["cameraPosition"] = hashvec(cam.CFrame.p), 
                                                        ["cursorDirection"] = hashvec(Ray.new(cam.CFrame.p, plr.Character.HumanoidRootPart.Position).Unit.Direction)
                                                    },
                                                    ["targetPosition"] = hashvec(plr.Character.HumanoidRootPart.Position),
                                                    ["selfPosition"] = hashvec(lplr.Character.HumanoidRootPart.Position + pos)
                                                }
                                            })
                                        end
                                    end
                                end
                            --[[ local rayparams = RaycastParams.new()
                                rayparams.FilterDescendantsInstances = {lplr.Character}
                                rayparams.FilterType = Enum.RaycastFilterType.Blacklist
                                local ray = workspace:Raycast(lplr:GetMouse().UnitRay.Origin, lplr:GetMouse().UnitRay.Direction * 17.99, rayparams)
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
                                end]]
                            end
                        end
                    end)
                else
                    if killaurafunc then 
                        killaurafunc:Disconnect()
                    end
                end
            end)
            killaura.addSlider("Attack range", 1, 18, 18, function() end)
            killaura.addSlider("Max angle", 1, 360, 360, function() end)
            killaura.addToggle("Only reach while moving", function() end)
            killaura.addToggle("Vertical Check", function() end)

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

            local healthColorToPosition = {
                [Vector3.new(Color3.fromRGB(255, 28, 0).r,
              Color3.fromRGB(255, 28, 0).g,
              Color3.fromRGB(255, 28, 0).b)] = 0.1;
                [Vector3.new(Color3.fromRGB(250, 235, 0).r,
              Color3.fromRGB(250, 235, 0).g,
              Color3.fromRGB(250, 235, 0).b)] = 0.5;
                [Vector3.new(Color3.fromRGB(27, 252, 107).r,
              Color3.fromRGB(27, 252, 107).g,
              Color3.fromRGB(27, 252, 107).b)] = 0.8;
            }
            local min = 0.1
            local minColor = Color3.fromRGB(255, 28, 0)
            local max = 0.8
            local maxColor = Color3.fromRGB(27, 252, 107)
            
            local function HealthbarColorTransferFunction(healthPercent)
                if healthPercent < min then
                    return minColor
                elseif healthPercent > max then
                    return maxColor
                end
            
            
                local numeratorSum = Vector3.new(0,0,0)
                local denominatorSum = 0
                for colorSampleValue, samplePoint in pairs(healthColorToPosition) do
                    local distance = healthPercent - samplePoint
                    if distance == 0 then
                        
                        return Color3.new(colorSampleValue.x, colorSampleValue.y, colorSampleValue.z)
                    else
                        local wi = 1 / (distance*distance)
                        numeratorSum = numeratorSum + wi * colorSampleValue
                        denominatorSum = denominatorSum + wi
                    end
                end
                local result = numeratorSum / denominatorSum
                return Color3.new(result.x, result.y, result.z)
            end

            local function isAlive(plr)
                if plr then
                    return plr and plr.Character and plr.Character.Parent ~= nil and plr.Character:FindFirstChild("HumanoidRootPart") and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid")
                end
                return lplr and lplr.Character and lplr.Character.Parent ~= nil and lplr.Character:FindFirstChild("HumanoidRootPart") and lplr.Character:FindFirstChild("Head") and lplr.Character:FindFirstChild("Humanoid")
            end

            local function CalculateObjectPosition(pos)
                local newpos = cam:WorldToViewportPoint(cam.CFrame:pointToWorldSpace(cam.CFrame:pointToObjectSpace(pos)))
                return Vector2.new(newpos.X, newpos.Y)
            end
            
            local function CalculateLine(startVector, endVector, obj)
                local Distance = (startVector - endVector).Magnitude
                obj.Size = UDim2.new(0, Distance, 0, 2)
                obj.Position = UDim2.new(0, (startVector.X + endVector.X) / 2, 0, ((startVector.Y + endVector.Y) / 2) - 36)
                obj.Rotation = math.atan2(endVector.Y - startVector.Y, endVector.X - startVector.X) * (180 / math.pi)
            end

            local function floorpos(pos)
                return Vector2.new(math.floor(pos.X), math.floor(pos.Y))
            end

            local espfolderdrawing = {}
            local espconnection
            local esp = addModule("ESP", "Renders players through wall", function(callback)
                if callback then 
                    espconnection = players.PlayerRemoving:connect(function(plr)
                        if espfolderdrawing[plr.Name] then
                            pcall(function()
                                pcall(function()
                                    espfolderdrawing[plr.Name].Quad1:Remove()
                                    espfolderdrawing[plr.Name].Quad2:Remove()
                                    espfolderdrawing[plr.Name].Quad3:Remove()
                                    espfolderdrawing[plr.Name].Quad4:Remove()
                                end)
                                pcall(function()
                                    espfolderdrawing[plr.Name].Head:Remove()
                                    espfolderdrawing[plr.Name].Head2:Remove()
                                    espfolderdrawing[plr.Name].Torso:Remove()
                                    espfolderdrawing[plr.Name].Torso2:Remove()
                                    espfolderdrawing[plr.Name].Torso3:Remove()
                                    espfolderdrawing[plr.Name].LeftArm:Remove()
                                    espfolderdrawing[plr.Name].RightArm:Remove()
                                    espfolderdrawing[plr.Name].LeftLeg:Remove()
                                    espfolderdrawing[plr.Name].RightLeg:Remove()
                                end)
                                espfolderdrawing[plr.Name] = nil
                            end)
                        end
                    end)
                    BindToRenderStep("ESP", 500, function()
                        for i,plr in pairs(players:GetChildren()) do
                            local thing
                            if not modulesenabled["ESP/Skeleton"] then
                                if espfolderdrawing[plr.Name] then
                                    thing = espfolderdrawing[plr.Name]
                                    thing.Quad1.Visible = false
                                    thing.Quad1.Color = plr.TeamColor.Color
                                    thing.Quad2.Visible = false
                                    thing.Quad3.Visible = false
                                    thing.Quad4.Visible = false
                                else
                                    espfolderdrawing[plr.Name] = {}
                                    espfolderdrawing[plr.Name].Quad1 = Drawing.new("Quad")
                                    espfolderdrawing[plr.Name].Quad1.Thickness = 1
                                    espfolderdrawing[plr.Name].Quad1.ZIndex = 2
                                    espfolderdrawing[plr.Name].Quad1.Color = Color3.new(1, 1, 1)
                                    espfolderdrawing[plr.Name].Quad2 = Drawing.new("Quad")
                                    espfolderdrawing[plr.Name].Quad2.Thickness = 2
                                    espfolderdrawing[plr.Name].Quad2.ZIndex = 1
                                    espfolderdrawing[plr.Name].Quad2.Color = Color3.new(0, 0, 0)
                                    espfolderdrawing[plr.Name].Quad3 = Drawing.new("Line")
                                    espfolderdrawing[plr.Name].Quad3.Thickness = 1
                                    espfolderdrawing[plr.Name].Quad3.ZIndex = 2
                                    espfolderdrawing[plr.Name].Quad3.Color = Color3.new(0, 0, 0)
                                    espfolderdrawing[plr.Name].Quad4 = Drawing.new("Line")
                                    espfolderdrawing[plr.Name].Quad4.Thickness = 2
                                    espfolderdrawing[plr.Name].Quad4.ZIndex = 1
                                    espfolderdrawing[plr.Name].Quad4.Color = Color3.new(0, 0, 0)
                                    thing = espfolderdrawing[plr.Name]
                                end
                                
                                
                                if isAlive(plr) and plr ~= lplr and (modulesenabled["ESP/Teammates"] or plr:GetAttribute("Team") ~= lplr:GetAttribute("Team")) then
                                    local rootPos, rootVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                                    local rootSize = (plr.Character.HumanoidRootPart.Size.X * 1200) * (cam.ViewportSize.X / 1920)
                                    local headPos, headVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position + Vector3.new(0, 1 + (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or plr.Character.Humanoid.HipHeight), 0))
                                    local legPos, legVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position - Vector3.new(0, 1 + (plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and 2 or plr.Character.Humanoid.HipHeight), 0))
                                    rootPos = rootPos
                                    if rootVis then
                                        --thing.Visible = rootVis
                                        local sizex, sizey = (rootSize / rootPos.Z), (headPos.Y - legPos.Y) 
                                        local posx, posy = (rootPos.X - sizex / 2),  ((rootPos.Y - sizey / 2))
                                        if modulesenabled["ESP/Health Bar"] then
                                            local color = HealthbarColorTransferFunction(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
                                            thing.Quad3.Color = color
                                            thing.Quad3.Visible = true
                                            thing.Quad4.From = floorpos(Vector2.new(posx - 4, posy + 1))
                                            thing.Quad4.To = floorpos(Vector2.new(posx - 4, posy + sizey - 1))
                                            thing.Quad4.Visible = true
                                            local healthposy = sizey * math.clamp(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth, 0, 1)
                                            thing.Quad3.From = floorpos(Vector2.new(posx - 4, posy + sizey - (sizey - healthposy)))
                                            thing.Quad3.To = floorpos(Vector2.new(posx - 4, posy))
                                            --thing.HealthLineMain.Size = UDim2.new(0, 1, math.clamp(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth, 0, 1), (math.clamp(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth, 0, 1) == 0 and 0 or -2))
                                        end
                                        thing.Quad1.PointA = floorpos(Vector2.new(posx + sizex, posy))
                                        thing.Quad1.PointB = floorpos(Vector2.new(posx, posy))
                                        thing.Quad1.PointC = floorpos(Vector2.new(posx, posy + sizey))
                                        thing.Quad1.PointD = floorpos(Vector2.new(posx + sizex, posy + sizey))
                                        thing.Quad1.Visible = true
                                        thing.Quad2.PointA = floorpos(Vector2.new(posx + sizex, posy))
                                        thing.Quad2.PointB = floorpos(Vector2.new(posx, posy))
                                        thing.Quad2.PointC = floorpos(Vector2.new(posx, posy + sizey))
                                        thing.Quad2.PointD = floorpos(Vector2.new(posx + sizex, posy + sizey))
                                        thing.Quad2.Visible = true
                                    end
                                end
                            else
                                if espfolderdrawing[plr.Name] then
                                    thing = espfolderdrawing[plr.Name]
                                    for linenum, line in pairs(thing) do
                                        line.Color = plr.TeamColor.Color
                                        line.Visible = false
                                    end
                                else
                                    thing = {}
                                    thing.Head = Drawing.new("Line")
                                    thing.Head2 = Drawing.new("Line")
                                    thing.Torso = Drawing.new("Line")
                                    thing.Torso2 = Drawing.new("Line")
                                    thing.Torso3 = Drawing.new("Line")
                                    thing.LeftArm = Drawing.new("Line")
                                    thing.RightArm = Drawing.new("Line")
                                    thing.LeftLeg = Drawing.new("Line")
                                    thing.RightLeg = Drawing.new("Line")
                                    espfolderdrawing[plr.Name] = thing
                                end
                                
                                if isAlive(plr) and plr ~= lplr and (modulesenabled["ESP/Teammates"] or plr:GetAttribute("Team") ~= lplr:GetAttribute("Team")) then
                                    local rootPos, rootVis = cam:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
                                    if rootVis and plr.Character:FindFirstChild((plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")) and plr.Character:FindFirstChild((plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Left Arm" or "LeftHand")) and plr.Character:FindFirstChild((plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Right Arm" or "RightHand")) and plr.Character:FindFirstChild((plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Left Leg" or "LeftFoot")) and plr.Character:FindFirstChild((plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Right Leg" or "RightFoot")) and plr.Character:FindFirstChild("Head") then
                                        local head = CalculateObjectPosition((plr.Character["Head"].CFrame).p)
                                        local headfront = CalculateObjectPosition((plr.Character["Head"].CFrame * CFrame.new(0, 0, -0.5)).p)
                                        local toplefttorso = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")].CFrame * CFrame.new(-1.5, 0.6, 0)).p)
                                        local toprighttorso = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")].CFrame * CFrame.new(1.5, 0.6, 0)).p)
                                        local toptorso = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")].CFrame * CFrame.new(0, 0.6, 0)).p)
                                        local bottomtorso = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")].CFrame * CFrame.new(0, -0.6, 0)).p)
                                        local bottomlefttorso = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")].CFrame * CFrame.new(-0.5, -0.6, 0)).p)
                                        local bottomrighttorso = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Torso" or "UpperTorso")].CFrame * CFrame.new(0.5, -0.6, 0)).p)
                                        local leftarm = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Left Arm" or "LeftHand")].CFrame * CFrame.new(0, -0.2, 0)).p)
                                        local rightarm = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Right Arm" or "RightHand")].CFrame * CFrame.new(0, -0.2, 0)).p)
                                        local leftleg = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Left Leg" or "LeftFoot")].CFrame * CFrame.new(0, -0.2, 0)).p)
                                        local rightleg = CalculateObjectPosition((plr.Character[(plr.Character.Humanoid.RigType == Enum.HumanoidRigType.R6 and "Right Leg" or "RightFoot")].CFrame * CFrame.new(0, -0.2, 0)).p)
                                        thing.Torso.From = toplefttorso
                                        thing.Torso.To = toprighttorso
                                        thing.Torso.Visible = true
                                        thing.Torso2.From = toptorso
                                        thing.Torso2.To = bottomtorso
                                        thing.Torso2.Visible = true
                                        thing.Torso3.From = bottomlefttorso
                                        thing.Torso3.To = bottomrighttorso
                                        thing.Torso3.Visible = true
                                        thing.LeftArm.From = toplefttorso
                                        thing.LeftArm.To = leftarm
                                        thing.LeftArm.Visible = true
                                        thing.RightArm.From = toprighttorso
                                        thing.RightArm.To = rightarm
                                        thing.RightArm.Visible = true
                                        thing.LeftLeg.From = bottomlefttorso
                                        thing.LeftLeg.To = leftleg
                                        thing.LeftLeg.Visible = true
                                        thing.RightLeg.From = bottomrighttorso
                                        thing.RightLeg.To = rightleg
                                        thing.RightLeg.Visible = true
                                        thing.Head.From = toptorso
                                        thing.Head.To = head
                                        thing.Head.Visible = true
                                        thing.Head2.From = head
                                        thing.Head2.To = headfront
                                        thing.Head2.Visible = true
                                        --[[CalculateLine(toplefttorso, toprighttorso, thing.TopTorsoLine)
                                        CalculateLine(toptorso, bottomtorso, thing.MiddleTorsoLine)
                                        CalculateLine(bottomlefttorso, bottomrighttorso, thing.BottomTorsoLine)
                                        CalculateLine(toplefttorso, leftarm, thing.LeftArm)
                                        CalculateLine(toprighttorso, rightarm, thing.RightArm)
                                        CalculateLine(bottomlefttorso, leftleg, thing.LeftLeg)
                                        CalculateLine(bottomrighttorso, rightleg, thing.RightLeg)
                                        CalculateLine(toptorso, head, thing.Head)
                                        CalculateLine(head, headfront, thing.HeadForward)]]
                                    end
                                end     
                            end                               
                        end
                    end)
                else
                    if espconnection then 
                        espconnection:Disconnect()
                    end
                    UnbindFromRenderStep("ESP") 
                    for i,v in pairs(espfolderdrawing) do 
                        pcall(function()
                            espfolderdrawing[i].Quad1:Remove()
                            espfolderdrawing[i].Quad2:Remove()
                            espfolderdrawing[i].Quad3:Remove()
                            espfolderdrawing[i].Quad4:Remove()
                            espfolderdrawing[i] = nil
                        end)
                        pcall(function()
                            espfolderdrawing[i].Head:Remove()
                            espfolderdrawing[i].Head2:Remove()
                            espfolderdrawing[i].Torso:Remove()
                            espfolderdrawing[i].Torso2:Remove()
                            espfolderdrawing[i].Torso3:Remove()
                            espfolderdrawing[i].LeftArm:Remove()
                            espfolderdrawing[i].RightArm:Remove()
                            espfolderdrawing[i].LeftLeg:Remove()
                            espfolderdrawing[i].RightLeg:Remove()
                            espfolderdrawing[i] = nil
                        end)
                    end
                end
            end)

            esp.addToggle("Teammates", function(callback) end)
            esp.addToggle("Health Bar", function(callback) end)
            esp.addToggle("Skeleton", function(callback) 
                for i,v in pairs(espfolderdrawing) do 
                    pcall(function()
                        espfolderdrawing[i].Quad1:Remove()
                        espfolderdrawing[i].Quad2:Remove()
                        espfolderdrawing[i].Quad3:Remove()
                        espfolderdrawing[i].Quad4:Remove()
                        espfolderdrawing[i] = nil
                    end)
                    pcall(function()
                        espfolderdrawing[i].Head:Remove()
                        espfolderdrawing[i].Head2:Remove()
                        espfolderdrawing[i].Torso:Remove()
                        espfolderdrawing[i].Torso2:Remove()
                        espfolderdrawing[i].Torso3:Remove()
                        espfolderdrawing[i].LeftArm:Remove()
                        espfolderdrawing[i].RightArm:Remove()
                        espfolderdrawing[i].LeftLeg:Remove()
                        espfolderdrawing[i].RightLeg:Remove()
                        espfolderdrawing[i] = nil
                    end)
                end
            end)

            local nametagsfolderdrawing = {}
            local nametagsconnection
            local NameTags = addModule("NameTags", "See player names through walls", function(callback)
                if callback then 
                    nametagsconnection = players.PlayerRemoving:connect(function(plr)
                        if nametagsfolderdrawing[plr.Name] then 
                            pcall(function()
                                nametagsfolderdrawing[plr.Name].Text:Remove()
                                nametagsfolderdrawing[plr.Name].BG:Remove()
                                nametagsfolderdrawing[plr.Name] = nil
                            end)
                        end
                    end)
                    local nametagscale = findOption("NameTags", "Scale")
                    BindToRenderStep("NameTags", 500, function()
                        for i,plr in pairs(players:GetChildren()) do
                            local thing
                            if nametagsfolderdrawing[plr.Name] then
                                thing = nametagsfolderdrawing[plr.Name]
                                thing.Text.Visible = false
                                thing.BG.Visible = false
                            else
                                nametagsfolderdrawing[plr.Name] = {}
                                nametagsfolderdrawing[plr.Name].Text = Drawing.new("Text")
                                nametagsfolderdrawing[plr.Name].Text.Size = 17	
                                nametagsfolderdrawing[plr.Name].Text.Font = 0
                                nametagsfolderdrawing[plr.Name].Text.Text = ""
                                nametagsfolderdrawing[plr.Name].Text.ZIndex = 2
                                nametagsfolderdrawing[plr.Name].BG = Drawing.new("Square")
                                nametagsfolderdrawing[plr.Name].BG.Filled = true
                                nametagsfolderdrawing[plr.Name].BG.Transparency = 0.5
                                nametagsfolderdrawing[plr.Name].BG.Color = Color3.new(0, 0, 0)
                                nametagsfolderdrawing[plr.Name].BG.ZIndex = 1
                                thing = nametagsfolderdrawing[plr.Name]
                            end

                            if isAlive(plr) and plr ~= lplr and (modulesenabled["NameTags/Teammates"] or plr:GetAttribute("Team") ~= lplr:GetAttribute("Team")) then
                                local headPos, headVis = cam:WorldToViewportPoint((plr.Character.HumanoidRootPart:GetRenderCFrame() * CFrame.new(0, plr.Character.Head.Size.Y + plr.Character.HumanoidRootPart.Size.Y, 0)).Position)
                                
                                if headVis then
                                    local alivecheck = isAlive()
                                    local displaynamestr = (modulesenabled["NameTags/Display Name"] and plr.DisplayName ~= nil and plr.DisplayName or plr.Name)
                                    local blocksaway = math.floor(((alivecheck and lplr.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)) - plr.Character.HumanoidRootPart.Position).magnitude / 3)
                                    local color = HealthbarColorTransferFunction(plr.Character.Humanoid.Health / plr.Character.Humanoid.MaxHealth)
                                    thing.Text.Text = (modulesenabled["NameTags/Distance"] and alivecheck and '['..blocksaway..'] ' or '')..displaynamestr..(modulesenabled["NameTags/Health"] and ' '..math.floor(plr.Character.Humanoid.Health).."" or '')
                                    thing.Text.Size = 17 * (nametagscale.state / 10)
                                    thing.Text.Color = plr.TeamColor.Color
                                    thing.Text.Visible = headVis
                                    thing.Text.Font = 0
                                    thing.Text.Position = floorpos(Vector2.new(headPos.X - thing.Text.TextBounds.X / 2, (headPos.Y - thing.Text.TextBounds.Y)))
                                    thing.BG.Visible = headVis and modulesenabled["NameTags/Background"] or false
                                    thing.BG.Size = floorpos(Vector2.new(thing.Text.TextBounds.X + 4, thing.Text.TextBounds.Y))
                                    thing.BG.Position = floorpos(Vector2.new((headPos.X - 2) - thing.Text.TextBounds.X / 2, (headPos.Y - thing.Text.TextBounds.Y) + 1.5))
                                end
                            end
                        end
                    end)
                else
                    if nametagsconnection then 
                        nametagsconnection:Disconnect()
                    end
                    UnbindFromRenderStep("NameTags")
                    for i,v in pairs(nametagsfolderdrawing) do 
                        pcall(function()
                            nametagsfolderdrawing[i].Text:Remove()
                            nametagsfolderdrawing[i].BG:Remove()
                            nametagsfolderdrawing[i] = nil
                        end)
                    end
                end
            end)
            NameTags.addSlider("Scale", 1, 50, 10, function(callback) end)
            NameTags.addToggle("Teammates", function(callback) end)
            NameTags.addToggle("Health", function(callback) end)
            NameTags.addToggle("Display Name", function(callback) end)
            NameTags.addToggle("Distance", function(callback) end)
            NameTags.addToggle("Background", function(callback) end)

            local tracersdrawingtab = {}
            local tracersconnection
            local tracers = addModule("Tracers", "Shows a line to the players", function(callback)
                if callback then 
                    tracersconnection = players.PlayerRemoving:connect(function(plr)
                        if tracersdrawingtab[plr.Name] then 
                            pcall(function()
                                tracersdrawingtab[plr.Name]:Remove()
                                tracersdrawingtab[plr.Name] = nil
                            end)
                        end
                    end)
                    local tracerstransparency = findOption("Tracers", "Transparency")
                    BindToRenderStep("Tracers", 500, function()
                        for i,plr in pairs(players:GetChildren()) do
                            local thing
                            if tracersdrawingtab[plr.Name] then 
                                thing = tracersdrawingtab[plr.Name]
                                thing.Visible = false
                            else
                                thing = Drawing.new("Line")
                                thing.Thickness = 1
                                thing.Visible = false
                                tracersdrawingtab[plr.Name] = thing
                            end

                            if isAlive(plr) and plr ~= lplr and (modulesenabled["Tracers/Teammates"] or plr:GetAttribute("Team") ~= lplr:GetAttribute("Team")) then
                                local rootScrPos = cam:WorldToViewportPoint((modulesenabled["Tracers/End Head Position"] and plr.Character.Head or plr.Character.HumanoidRootPart).Position)
                                local tempPos = cam.CFrame:pointToObjectSpace((modulesenabled["Tracers/End Head Position"] and plr.Character.Head or plr.Character.HumanoidRootPart).Position)
                                if rootScrPos.Z < 0 then
                                    tempPos = CFrame.Angles(0, 0, (math.atan2(tempPos.Y, tempPos.X) + math.pi)):vectorToWorldSpace((CFrame.Angles(0, math.rad(89.9), 0):vectorToWorldSpace(Vector3.new(0, 0, -1))));
                                end
                                local tracerPos = cam:WorldToViewportPoint(cam.CFrame:pointToWorldSpace(tempPos))
                                local screensize = cam.ViewportSize
                                local startVector = Vector2.new(screensize.X / 2, ((not modulesenabled["Tracers/Start Bottom Position"]) and screensize.Y / 2 or screensize.Y))
                                local endVector = Vector2.new(tracerPos.X, tracerPos.Y)
                                local Distance = (startVector - endVector).Magnitude
                                startVector = startVector
                                endVector = endVector
                                thing.Visible = true
                                thing.Transparency = 1 - tracerstransparency.state / 100
                                thing.Color = plr.TeamColor.Color
                                thing.From = startVector
                                thing.To = endVector
                            end
                        end
                    end)
                else
                    if tracersconnection then 
                        tracersconnection:Disconnect()
                    end
                    UnbindFromRenderStep("Tracers") 
                    for i,v in pairs(tracersdrawingtab) do 
                        pcall(function()
                            v:Remove()
                            tracersdrawingtab[i] = nil
                        end)
                    end
                end
            end)
            tracers.addSlider("Transparency", 1, 100, 1, function() end)
            tracers.addToggle("Teammates", function() end)
            tracers.addToggle("End Head Position", function() end)
            tracers.addToggle("Start Bottom Position", function() end)
        end
    end
    web.OnMessage:Connect(function(msg)
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
            UpdateHud()
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
                    UpdateHud()
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
    web.OnClose:Connect(function()
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