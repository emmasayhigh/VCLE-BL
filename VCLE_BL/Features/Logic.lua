local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

                    if not quest.Name or string.find(quest.Name, "Storyline", 1, true) then
                    -- Check Talk quests: find one with at least one NPC not yet talked to (false)
                    if quest.Talk then
                        for npcName, talked in pairs(quest.Talk) do
                            if talked == false then return quest end
                        end
                    end
                    -- Check Defeat/Kills quests
                    if quest.Defeat then
                        for n, p in pairs(quest.Defeat) do
                            if type(p) == "number" and p < 999 then return quest end
                            if type(p) == "table" and (p.Current or 0) < (p.Target or 999) then return quest end
                        end
                    end
                    if quest.Kills then
                        for n, p in pairs(quest.Kills) do
                            if type(p) == "number" and p < 999 then return quest end
                            if type(p) == "table" and (p.Current or 0) < (p.Target or 999) then return quest end
                        end
                    end
                    end -- Storyline filter
                end -- for quest
            end -- if ok
        end -- if obj
    end -- for qName
    return nil
end
local function findNPC(name)
    if not name or name == "" then return nil end
    -- Priority 1: exact match in known NPC containers (NO HRP requirement — handles Power Box etc.)
    local paths = {workspace:FindFirstChild("Npcs"), workspace:FindFirstChild("NPCs"), ReplicatedStorage:FindFirstChild("assets") and ReplicatedStorage.assets:FindFirstChild("npc_cache")}
    for _, f in pairs(paths) do if f and f:FindFirstChild(name) then return f[name] end end
    -- Priority 2: exact match in Live (but NOT other players)
    local live = workspace:FindFirstChild("Live")
    if live then
        local exact = live:FindFirstChild(name)
        if exact and not Players:GetPlayerFromCharacter(exact) then return exact end
    end
    -- Priority 3: partial match in NPC containers
    for _, f in pairs(paths) do
        if f then
            for _, npc in pairs(f:GetChildren()) do
                if string.find(npc.Name, name, 1, true) then return npc end
            end
        end
    end
    -- Priority 4: partial match in Live (non-players only, prefer models with HRP)
    if live then
        local fallback = nil
        for _, v in pairs(live:GetChildren()) do
            if not Players:GetPlayerFromCharacter(v) and string.find(v.Name, name, 1, true) then
                if v:FindFirstChild("HumanoidRootPart") then return v end
                fallback = v
            end
        end
        if fallback then return fallback end
    end
    return nil
end
-- Safe position getter for NPCs (works with and without HumanoidRootPart)
local function getNpcCFrame(npc)
    if npc:FindFirstChild("HumanoidRootPart") then return npc.HumanoidRootPart.CFrame end
    local ok, cf = pcall(function() return npc:GetPivot() end)
    if ok and cf then return cf end
    if npc:FindFirstChild("Part") then return npc.Part.CFrame end
    for _, p in pairs(npc:GetDescendants()) do if p:IsA("BasePart") then return p.CFrame end end
    return nil
end
local function isStandActive()
    local effects = workspace:FindFirstChild("Effects")
    if not effects then return false end
    -- Check multiple possible stand name formats
    local standNames = {
        "." .. player.Name .. "'s Stand",
        player.Name .. "'s Stand",
        player.Name .. "'s stand"
    }
    for _, sName in pairs(standNames) do
        local stand = effects:FindFirstChild(sName)
        if stand then return true end -- Don't require HumanoidRootPart — stand may still be loading
    end
    -- Fallback: check if any child contains player name and "Stand"
    for _, v in pairs(effects:GetChildren()) do
        if string.find(v.Name, player.Name, 1, true) and string.find(v.Name, "Stand", 1, true) then return true end
    end
    return false
end
local lastSummon = 0
local standWasActive = false
local function summonStand()
    local active = isStandActive()
    if active then standWasActive = true; return end -- Stand is out, do nothing
    -- Stand is NOT active
    if standWasActive then
        -- Stand was just deactivated (maybe by game mechanic) — wait before resummoning
        standWasActive = false
        lastSummon = tick() -- reset cooldown
        return
    end
    if tick() - lastSummon < 6 then return end -- 6s cooldown to avoid rapid toggling
    VIM:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
    task.wait(0.1)
    VIM:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
    lastSummon = tick()
end

--// V63: ADVANCED ESP LOGIC
local function applyESP(obj, color, nameText)
    local hl = obj:FindFirstChild("V63_HL")
    if hl then hl.Enabled = Config.EspHighlight; hl.FillColor = color else
        hl = Instance.new("Highlight"); hl.Name = "V63_HL"; hl.FillColor = color; hl.FillTransparency = 0.5; hl.OutlineColor = Color3.new(1,1,1); hl.OutlineTransparency = 0; hl.Enabled = Config.EspHighlight; hl.Adornee = obj; hl.Parent = obj
    end
    local box = obj:FindFirstChild("V63_BOX")
    if box then box.Visible = Config.EspBox; box.Color3 = color else
        box = Instance.new("SelectionBox"); box.Name = "V63_BOX"; box.Color3 = color; box.LineThickness = 0.05; box.Visible = Config.EspBox; box.Adornee = obj; box.Parent = obj
    end
    local bb = obj:FindFirstChild("V63_BB")
    if not bb then
        bb = Instance.new("BillboardGui"); bb.Name = "V63_BB"; bb.Size = UDim2.new(0,200,0,50); bb.AlwaysOnTop = true; bb.ExtentsOffset = Vector3.new(0,3,0); bb.Parent = obj
        local label = Instance.new("TextLabel"); label.Name = "Info"; label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1; label.TextColor3 = color; label.TextStrokeTransparency = 0; label.TextSize = 14; label.Font = Enum.Font.GothamBold; label.Parent = bb
    end
    local finalStr = ""
    if Config.EspName then finalStr = nameText .. "\n" end
    if Config.EspDist then local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then local d = math.floor((hrp.Position - obj:GetPivot().Position).Magnitude); finalStr = finalStr .. "[" .. d .. "m] " end end
    if Config.EspHealth and obj:FindFirstChild("Humanoid") then finalStr = finalStr .. "(" .. math.floor(obj.Humanoid.Health) .. " HP)" end
    bb.Enabled = (Config.EspName or Config.EspHealth or Config.EspDist); bb.Info.Text = finalStr; bb.Info.TextColor3 = color
end

local function removeESP(obj)
    if obj:FindFirstChild("V63_HL") then obj.V63_HL:Destroy() end
    if obj:FindFirstChild("V63_BOX") then obj.V63_BOX:Destroy() end
    if obj:FindFirstChild("V63_BB") then obj.V63_BB:Destroy() end
end
-- ESP: Instant item detection via ChildAdded (no lag)
local espTrackedItems = {}
workspace.ChildAdded:Connect(function(o)
    task.wait(0.1)
    if Config.EspItems then
        local itemName = o.Name
        if itemName == "Model" then for _, c in pairs(o:GetChildren()) do if c:IsA("Tool") or c.Name == "Stand Arrow" then itemName = c.Name; break end end end
        if (o.Name == "Stand Arrow" or o:FindFirstChild("Stand Arrow") or o:IsA("Tool")) then
            local isEffect = string.find(string.lower(itemName), "effect") or string.find(string.lower(itemName), "hit")
            local pos = Vector3.new(0, 50, 0)
            pcall(function() pos = o:GetPivot().Position end)
            if not isEffect and pos.Y > -50 then
                applyESP(o, Color3.fromRGB(230,190,0), itemName)
                espTrackedItems[o] = true
            end
        end
    end
end)
workspace.DescendantRemoving:Connect(function(o)
    if espTrackedItems[o] then
        removeESP(o)
        espTrackedItems[o] = nil
    end
end)

task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            -- Validate existing tracked items first
            if Config.EspItems then
                for o, _ in pairs(espTrackedItems) do
                    local isValid = false
                    if o and o.Parent == workspace then
                        if o.Name == "Stand Arrow" or o:FindFirstChild("Stand Arrow") or o:IsA("Tool") then
                            isValid = true
                        end
                    end
                    
                    if not isValid then
                        pcall(function()
                            if o:FindFirstChild("V63_HL") then o.V63_HL:Destroy() end
                            if o:FindFirstChild("V63_BOX") then o.V63_BOX:Destroy() end
                            if o:FindFirstChild("V63_BB") then o.V63_BB:Destroy() end
                        end)
                        espTrackedItems[o] = nil
                    end
                end
                
                for _, o in pairs(workspace:GetChildren()) do
                    if (o.Name == "Stand Arrow" or o:FindFirstChild("Stand Arrow") or o:IsA("Tool")) then
                        local itemName = o.Name
                        if itemName == "Model" then for _, c in pairs(o:GetChildren()) do if c:IsA("Tool") or c.Name == "Stand Arrow" then itemName = c.Name; break end end end
                        local isEffect = string.find(string.lower(itemName), "effect") or string.find(string.lower(itemName), "hit")
                        local pos = Vector3.new(0, 50, 0)
                        pcall(function() pos = o:GetPivot().Position end)
                        if not isEffect and pos.Y > -50 then
                            applyESP(o, Color3.fromRGB(230,190,0), itemName)
                            espTrackedItems[o] = true
                        end
                    end
                end
            else
                -- Clean up item ESP when disabled
                for obj, _ in pairs(espTrackedItems) do
                    if obj and obj.Parent then removeESP(obj) end
                end
                espTrackedItems = {}
            end
            
            -- People & NPC ESP (only scan Live folder)
            local live = workspace:FindFirstChild("Live")
            if live then 
                local myChar = live:FindFirstChild(player.Name)
                for _, v in pairs(live:GetChildren()) do
                    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") and v ~= myChar then
                        local isP = Players:GetPlayerFromCharacter(v)
                        if isP and Config.EspPeople then 
                            applyESP(v, Color3.fromRGB(0,180,255), v.Name)
                        elseif not isP and Config.EspNPC then 
                            applyESP(v, Color3.fromRGB(50,220,50), v.Name)
                        elseif v:FindFirstChild("V63_HL") then 
                            removeESP(v) 
                        end
                    end 
                end 
                -- Clean up NPC/People ESP when both disabled
                if not Config.EspPeople and not Config.EspNPC then
                    for _, v in pairs(live:GetChildren()) do
                        if v:FindFirstChild("V63_HL") and not Players:GetPlayerFromCharacter(v) then removeESP(v) end
                    end
                end
            end
        end)
    end
end)

--// SKILLS LOGIC (FIXED)
function getNil(name,class) for _,v in pairs(getnilinstances())do if v.ClassName==class and v.Name==name then return v;end end end
local function fireSkill(skillKey, state)
    local char = workspace.Live:FindFirstChild(player.Name); local controller = char and char:FindFirstChild("client_character_controller")
    if controller and controller:FindFirstChild("Skill") then controller.Skill:FireServer(skillKey, state) end
end

task.spawn(function()
    while task.wait(0.1) do -- Faster check
        if (Config.AutoQuest or Config.AutoRaid or Config.AutoLvlFarm or Config.AutoMeditation) and currentTarget then
            for key, enabled in pairs(Config.AutoSkills) do 
                if enabled then 
                    if key == "E" then 
                        fireSkill(key, true); task.wait(0.6); fireSkill(key, false); task.wait(0.1)
                    else 
                        fireSkill(key, true); task.wait(0.05); fireSkill(key, false); task.wait(0.05)
                    end
                end 
            end
        end
    end
end)

local ConfigManager = getgenv().VCLE_BL_ConfigManager
local Config = ConfigManager.State
local currentTarget = nil
local targetCFrame = nil
local isHoveringMenu = false

--// SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer



--// V64: LOCALIZATION SYSTEM (INJECTED)
local currentLang = "ENG" -- Default
local LOCALES = {
--// LOOPS
RunService.Heartbeat:Connect(function()
    if targetCFrame then local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = targetCFrame; hrp.AssemblyLinearVelocity = Vector3.new(0,0,0); hrp.AssemblyAngularVelocity = Vector3.new(0,0,0) end end
end)

local function summonStand()
    if Config.AutoStand then
        -- Kiểm tra chính xác xem Stand đã xuất hiện trong thư mục Effects chưa
        local standName = "." .. player.Name .. "'s Stand"
        local hasStand = workspace:FindFirstChild("Effects") and workspace.Effects:FindFirstChild(standName) ~= nil
        
        if not hasStand then
            VIM:SendKeyEvent(true, Enum.KeyCode.Tab, false, game)
            task.wait(0.1)
            VIM:SendKeyEvent(false, Enum.KeyCode.Tab, false, game)
            task.wait(0.5)
        end
    end
end

-- CLICKER VÀ AUTO SAVE
task.spawn(function()
    while true do
        if (Config.AutoQuest or Config.AutoRaid or Config.AutoLvlFarm or Config.AutoMeditation) and currentTarget and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
            -- Nếu người chơi đang giữ chuột (kéo menu, xoay camera), tạm dừng đánh để không cướp chuột
            if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
                task.wait(0.5)
            else
                -- Click ở tọa độ an toàn (giữa mép trên màn hình) để không trúng bất kỳ nút GUI nào
                local safeX = workspace.CurrentCamera and (workspace.CurrentCamera.ViewportSize.X / 2) or 500
                VIM:SendMouseButtonEvent(safeX, 5, 0, true, game, 0); task.wait(0.12)
                VIM:SendMouseButtonEvent(safeX, 5, 0, false, game, 0); task.wait(0.08)
            end
        else 
            task.wait(0.5) 
        end
    end
end)

-- AUTO SAVE CONFIG
task.spawn(function()
    while task.wait(5) do
        SaveSettings()
    end
end)

-- BINDINGS
autoArrowBtn.MouseButton1Click:Connect(function() Config.AutoArrow = not Config.AutoArrow; updateArrow(Config.AutoArrow) end)
worthBtn.MouseButton1Click:Connect(function() Config.StopWorth0 = not Config.StopWorth0; updateWorth(Config.StopWorth0) end)
farmBtn.MouseButton1Click:Connect(function() autoFarm = not autoFarm; updateFarm(autoFarm) end)
questBtn.MouseButton1Click:Connect(function() Config.AutoQuest = not Config.AutoQuest; updateQuest(Config.AutoQuest); if not Config.AutoQuest then currentTarget = nil; targetCFrame = nil end end)
raidToggleBtn.MouseButton1Click:Connect(function() Config.AutoRaid = not Config.AutoRaid; updateRaid(Config.AutoRaid); if not Config.AutoRaid then currentTarget = nil; targetCFrame = nil end end)
restartToggleBtn.MouseButton1Click:Connect(function() Config.AutoRestart = not Config.AutoRestart; updateRestart(Config.AutoRestart) end)
autoStatsBtn.MouseButton1Click:Connect(function() Config.AutoAddStats = not Config.AutoAddStats; updateAutoStats(Config.AutoAddStats) end)
prestigeBtn.MouseButton1Click:Connect(function() Config.AutoPrestige = not Config.AutoPrestige; updatePrestige(Config.AutoPrestige); if Config.AutoPrestige then currentTarget = nil; targetCFrame = nil end end)
lvlFarmBtn.MouseButton1Click:Connect(function() Config.AutoLvlFarm = not Config.AutoLvlFarm; updateLvlFarm(Config.AutoLvlFarm); if not Config.AutoLvlFarm then currentTarget = nil; targetCFrame = nil end end)
meditationBtn.MouseButton1Click:Connect(function() Config.AutoMeditation = not Config.AutoMeditation; updateMeditation(Config.AutoMeditation); if not Config.AutoMeditation then currentTarget = nil; targetCFrame = nil end end)
standToggleBtn.MouseButton1Click:Connect(function() Config.AutoStand = not Config.AutoStand; updateStand(Config.AutoStand) end)

espItemsBtn.MouseButton1Click:Connect(function() Config.EspItems = not Config.EspItems; updateEspItems(Config.EspItems) end)
espPeopleBtn.MouseButton1Click:Connect(function() Config.EspPeople = not Config.EspPeople; updateEspPeople(Config.EspPeople) end)
espNpcBtn.MouseButton1Click:Connect(function() Config.EspNPC = not Config.EspNPC; updateEspNpc(Config.EspNPC) end)
hLEspBtn.MouseButton1Click:Connect(function() Config.EspHighlight = not Config.EspHighlight; updateHL(Config.EspHighlight) end)
boxEspBtn.MouseButton1Click:Connect(function() Config.EspBox = not Config.EspBox; updateBox(Config.EspBox) end)
nameEspBtn.MouseButton1Click:Connect(function() Config.EspName = not Config.EspName; updateName(Config.EspName) end)
healthEspBtn.MouseButton1Click:Connect(function() Config.EspHealth = not Config.EspHealth; updateHHealth(Config.EspHealth) end)
distEspBtn.MouseButton1Click:Connect(function() Config.EspDist = not Config.EspDist; updateDist(Config.EspDist) end)

-- UI SYNC
task.spawn(function()
    while task.wait(0.5) do pcall(function()
        local sd = player.PlayerData.SlotData; standLabel.Text = getLoc("CURR_STAND") .. getStand(); worthLabel.Text = getLoc("CURR_WORTH") .. sd.Worthiness.Value
        lvlLbl.Text = getLoc("LEVEL_TEXT") .. toNum(sd.Level.Value); conjLbl.Text = getLoc("CONJ_TEXT") .. getConj(); prestigeLbl.Text = getLoc("PRESTIGE_TEXT") .. toNum(sd.Prestige.Value); spLabel.Text = getLoc("SP_TEXT") .. toNum(sd.StatPoints.Value)
        sL.Text = "Current: " .. toNum(sd.StrengthStat.Value); hL.Text = "Current: " .. toNum(sd.DefenseStat.Value); pL.Text = "Current: " .. toNum(sd.PowerStat.Value)
        wL.Text = "Current: " .. toNum(sd.WeaponStat.Value); dpL.Text = "Current: " .. toNum(sd.DestructivePowerStat.Value); deL.Text = "Current: " .. toNum(sd.DestructiveEnergyStat.Value)
    end) end
end)

-- AUTOMATION
task.spawn(function()
    while task.wait(1) do if Config.AutoArrow then local stand = getStand()
    if Config.DesiredStand ~= "" and string.lower(stand) == string.lower(Config.DesiredStand) then Config.AutoArrow = false; updateArrow(false)
    elseif Config.StopWorth0 and player.PlayerData.SlotData.Worthiness.Value == 0 then Config.AutoArrow = false; updateArrow(false)
    else ReplicatedStorage.requests.character.use_item:FireServer("Stand Arrow") end end end
end)

task.spawn(function()
    while task.wait(0.5) do if autoFarm then local char = workspace.Live:FindFirstChild(player.Name)
    if char and char:FindFirstChild("HumanoidRootPart") then for _, o in pairs(workspace:GetChildren()) do if not autoFarm then break end
    if o.Name == "Stand Arrow" or o:FindFirstChild("Stand Arrow") then char.HumanoidRootPart.CFrame = o:GetPivot(); task.wait(0.2); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(1.0); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(1.0); break end end end end end
end)

task.spawn(function()
    while task.wait(0.5) do if Config.AutoAddStats then local sd = player.PlayerData.SlotData; local points = toNum(sd.StatPoints.Value)
    if points > 0 then for display, target in pairs(statTargets) do if not Config.AutoAddStats then break end; local exact = STAT_NAME_MAP[display]
    if target > 0 and toNum(sd[exact].Value) < target then ReplicatedStorage.requests.character.increase_stat:FireServer(exact, spAmount); task.wait(0.3); break end end end end end
end)

local function getKiraTarget()
    local map = workspace:FindFirstChild("Map"); local kiraMap = map and map:FindFirstChild("Yoshikage Kira Bites the Dust")
    if not kiraMap then return nil end; local rooms = kiraMap:FindFirstChild("Gamemode Rooms"); if not rooms then return nil end
    local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    for i = 1, 4 do local room = rooms:FindFirstChild("Room " .. i); local spawns = room and room:FindFirstChild("Mob Spawns")
    if spawns then for _, live in pairs(workspace.Live:GetChildren()) do if live:FindFirstChild("Humanoid") and live.Humanoid.Health > 0 and live ~= char and not string.find(string.lower(live.Name), "hostage") then
    for _, s in pairs(spawns:GetChildren()) do if (live.HumanoidRootPart.Position - s.Position).Magnitude < 100 then return live end end end end end end
    
    -- Only target Kira boss if we are actually in the raid map (kiraMap exists)
    for _, v in pairs(workspace.Live:GetChildren()) do if string.find(v.Name, "Yoshikage Kira") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then return v end end; return nil
end

-- DIO 2-PHASE TARGETING
local function getDioTarget()
    local map = workspace:FindFirstChild("Map"); local dioMap = map and map:FindFirstChild("DIO")
    if not dioMap then return nil end; local rooms = dioMap:FindFirstChild("Gamemode Rooms"); if not rooms then return nil end
    local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart"); if not hrp then return nil end
    for i = 1, 2 do local room = rooms:FindFirstChild("Room " .. i); local spawns = room and room:FindFirstChild("Mob Spawns")
    if spawns then for _, live in pairs(workspace.Live:GetChildren()) do if live:FindFirstChild("Humanoid") and live.Humanoid.Health > 0 and live ~= char and not string.find(string.lower(live.Name), "hostage") then
    for _, s in pairs(spawns:GetChildren()) do if (live.HumanoidRootPart.Position - s.Position).Magnitude < 100 then return live end end end end end end
    for _, v in pairs(workspace.Live:GetChildren()) do if v.Name == "DIO" and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then return v end end; return nil
end

task.spawn(function()
    while task.wait(0.1) do -- Extreme Speed
        if Config.AutoRaid and RAID_BOSSES[selectedRaidBoss] then
            local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then local bossData = RAID_BOSSES[selectedRaidBoss]; local found = nil
            -- Special targeting per boss
            if selectedRaidBoss == "Kira" then 
                found = getKiraTarget()
            elseif selectedRaidBoss == "Dio" then
                found = getDioTarget()
            else
                -- For other bosses: search by exact boss name in Live
                for _, v in pairs(workspace.Live:GetChildren()) do if string.find(v.Name, bossData.BossName) and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then found = v; break end end
            end
            -- DIO Phase 1: kill mobs if DIO exists or raid started
            if not found and selectedRaidBoss == "Dio" then found = getDioTarget() end
            
            if found then 
                currentTarget = found; summonStand(); targetCFrame = found.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(-math.pi/2, 0, 0) -- H=9
            else 
                targetCFrame = nil; currentTarget = nil
                local npc = nil
                if selectedRaidBoss == "Dio" then
                    if workspace:FindFirstChild("Npcs") and workspace.Npcs:FindFirstChild("???") then npc = workspace.Npcs["???"]
                    elseif ReplicatedStorage:FindFirstChild("assets") and ReplicatedStorage.assets:FindFirstChild("npc_cache") and ReplicatedStorage.assets.npc_cache:FindFirstChild("???") then npc = ReplicatedStorage.assets.npc_cache["???"] end
                else
                    npc = findNPC(bossData.TalkName)
                end
                
                if npc and npc:FindFirstChild("HumanoidRootPart") then 
                    local tp = npc.HumanoidRootPart.CFrame
                    hrp.CFrame = tp * CFrame.new(0,0,-3.5)
                    task.wait(0.5)
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(0.6)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.5)
                    if selectedRaidBoss == "Dio" then
                        VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                        task.wait(0.2)
                        VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                        task.wait(10) -- 10 seconds wait per user instruction
                    else
                        for i=1,2 do 
                            VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                            task.wait(0.2)
                            VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                            task.wait(0.4) 
                        end
                        -- Push player into the red ring to trigger the raid for Kira/Avdol
                        hrp.CFrame = tp * CFrame.new(0, 0, -16) 
                        task.wait(10)
                    end
                end 
            end 
            end -- Added missing end for 'if hrp then'
        end
    end
end)

task.spawn(function()
    -- Debug label for auto quest
    local debugLbl = Instance.new("TextLabel")
    debugLbl.Size = UDim2.new(0,500,0,100); debugLbl.Position = UDim2.new(0,10,0,10)
    debugLbl.BackgroundColor3 = Color3.new(0,0,0); debugLbl.BackgroundTransparency = 0.5
    debugLbl.TextColor3 = Color3.new(1,1,0); debugLbl.TextSize = 12; debugLbl.Font = Enum.Font.Code
    debugLbl.TextWrapped = true; debugLbl.TextXAlignment = Enum.TextXAlignment.Left; debugLbl.TextYAlignment = Enum.TextYAlignment.Top
    debugLbl.Visible = false; debugLbl.ZIndex = 9999
    pcall(function() debugLbl.Parent = game:GetService("CoreGui") end)
    if not debugLbl.Parent then debugLbl.Parent = player:WaitForChild("PlayerGui") end

    while task.wait(0.1) do -- Extreme Speed
        if Config.AutoQuest then
            debugLbl.Visible = true
            local data = getQuestData(); local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not data then
                local slotNames = "[Config.AutoQuest] No quest data found!\nSlotData children: "
                pcall(function()
                    local sd = player.PlayerData:FindFirstChild("SlotData")
                    if sd then
                        for _, c in pairs(sd:GetChildren()) do
                            slotNames = slotNames .. c.Name .. "(" .. c.ClassName .. "), "
                        end
                    end
                end)
                debugLbl.Text = slotNames
            elseif not hrp then
                debugLbl.Text = "[Config.AutoQuest] No character/HRP found"
            elseif data.Talk then
                targetCFrame = nil; currentTarget = nil
                local dbgTalk = "[Config.AutoQuest] TALK quest\nNPCs: "
                for npcName, talked in pairs(data.Talk) do
                    dbgTalk = dbgTalk .. npcName .. "=" .. tostring(talked) .. ", "
                end
                -- Try ALL un-talked NPCs
                local npcObj = nil
                local triedNames = ""
                for npcName, talked in pairs(data.Talk) do
                    if talked == false then
                        triedNames = triedNames .. npcName .. " "
                        npcObj = findNPC(npcName)
                        if npcObj then
                            local cf = getNpcCFrame(npcObj)
                            if cf then
                                dbgTalk = dbgTalk .. "\nFOUND: " .. npcObj.Name .. " at " .. tostring(cf.Position)
                                break
                            end
                        end
                        npcObj = nil
                    end
                end
                if not npcObj then dbgTalk = dbgTalk .. "\nNOT FOUND! Tried: " .. triedNames end
                debugLbl.Text = dbgTalk

                if npcObj then
                    local cf = getNpcCFrame(npcObj)
                    if cf then
                        hrp.CFrame = cf * CFrame.new(0,0,-3.5)
                        task.wait(0.6)
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.5); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(0.4)
                        for i=1,7 do if not Config.AutoQuest then break end; VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game); task.wait(0.2); VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game); task.wait(0.3) end
                    end
                end
            elseif data.Defeat or data.Kills then
                local tbl = data.Defeat or data.Kills; local targetStr = nil
                local dbgKill = "[Config.AutoQuest] KILL quest\nTargets: "
                for n, p in pairs(tbl) do dbgKill = dbgKill .. n .. "=" .. tostring(p) .. ", " end
                local lowestCount = math.huge
                for n, p in pairs(tbl) do
                    -- Skip completed targets: true = done, string = info text
                    if p == true or type(p) == "string" then
                        -- completed, skip
                    elseif type(p) == "table" then
                        local cur = p.Current or 0
                        local tgt = p.Target or 999
                        if cur < tgt and cur < lowestCount then lowestCount = cur; targetStr = n end
                    elseif type(p) == "number" then
                        -- Pick the one with LOWEST count (least progress = most incomplete)
                        if p < lowestCount then lowestCount = p; targetStr = n end
                    elseif p == false then
                        targetStr = n; lowestCount = -1; break -- false = not started, highest priority
                    end
                end
                dbgKill = dbgKill .. "\nSearching: " .. tostring(targetStr)
                
                -- LOCK ON: if we already have a target and it's still alive, keep fighting it
                if currentTarget and currentTarget.Parent and currentTarget:FindFirstChild("Humanoid") and currentTarget.Humanoid.Health > 0 then
                    dbgKill = dbgKill .. "\nLOCKED ON: " .. currentTarget.Name .. " HP=" .. math.floor(currentTarget.Humanoid.Health)
                    summonStand()
                    targetCFrame = currentTarget.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                    debugLbl.Text = dbgKill
                else
                    -- Target is dead or missing — search for new one
                    currentTarget = nil; targetCFrame = nil
                    local enemy = nil
                    local primeMatch = nil
                    local partialMatch = nil
                    for _, v in pairs(workspace.Live:GetChildren()) do
                        if targetStr and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(v) then
                            if v.Name == targetStr then enemy = v; break end
                            if string.find(v.Name, targetStr, 1, true) then
                                -- Prefer non-PRIME, but keep PRIME as fallback
                                if string.find(v.Name, "PRIME", 1, true) then
                                    primeMatch = v
                                else
                                    partialMatch = v
                                end
                            end
                        end
                    end
                    if not enemy then enemy = partialMatch or primeMatch end
                    
                    if enemy then
                        dbgKill = dbgKill .. "\nFOUND: " .. enemy.Name
                        currentTarget = enemy; summonStand(); targetCFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                    else
                        -- Enemy not spawned — try to talk to NPC to spawn it
                        dbgKill = dbgKill .. "\nNOT FOUND! Trying to talk to NPC..."
                        local npcToTalk = findNPC(targetStr)
                        if npcToTalk then
                            local cf = getNpcCFrame(npcToTalk)
                            if cf then
                                dbgKill = dbgKill .. "\nTalking to: " .. npcToTalk.Name
                                hrp.CFrame = cf * CFrame.new(0,0,-3.5)
                                task.wait(0.6)
                                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.5); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(0.4)
                                for i=1,3 do if not Config.AutoQuest then break end; VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game); task.wait(0.2); VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game); task.wait(0.3) end
                            end
                        end
                    end
                    debugLbl.Text = dbgKill
                end
            else
                local dbgRaw = "[Config.AutoQuest] Unknown quest format\nKeys: "
                for k, v in pairs(data) do dbgRaw = dbgRaw .. tostring(k) .. " " end
                debugLbl.Text = dbgRaw
            end
        else
            debugLbl.Visible = false
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do if Config.AutoRestart then local pGui = player:FindFirstChild("PlayerGui")
    if pGui then for _, v in pairs(pGui:GetDescendants()) do if v:IsA("TextButton") and string.find(string.lower(v.Text), "play again") and v.Visible then
    local pos = v.AbsolutePosition + (v.AbsoluteSize / 2); VIM:SendMouseButtonEvent(pos.X, pos.Y + 58, 0, true, game, 0); task.wait(0.1); VIM:SendMouseButtonEvent(pos.X, pos.Y + 58, 0, false, game, 0); break end end end end end
end)

task.spawn(function()
    while task.wait(2) do
        if Config.AutoPrestige then
            local sd = player.PlayerData.SlotData; local lvl = toNum(sd.Level.Value); local money = toNum(sd.Money.Value)
            if lvl >= 50 and money >= 10000 then
                local mage = workspace.Npcs:FindFirstChild("Arch Mage")
                local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if mage and hrp then
                    targetCFrame = nil; currentTarget = nil
                    hrp.CFrame = mage.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.5)
                    task.wait(0.5); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.8); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(0.5)
                    for i=1,3 do VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game); task.wait(0.2); VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game); task.wait(0.5) end
                end
            end
        end
    end
end)

-- PVE MISSION BOARD AUTO FARM
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoLvlFarm and selectedLvlFarm == "PVE Mission Boards" then
            pcall(function()
                local char = workspace.Live:FindFirstChild(player.Name)
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- PRIORITY 1: DELIVERY QUEST - search workspace.Effects for Quest Markers with "Delivery"
                local deliveryMarker = nil
                
                local effects = workspace:FindFirstChild("Effects")
                if effects then
                    for _, obj in pairs(effects:GetChildren()) do
                        pcall(function()
                            local qm = obj:FindFirstChild("Quest Marker")
                            if qm then
                                local img = qm:FindFirstChild("Image")
                                if img then
                                    local title = img:FindFirstChild("Title")
                                    if title and string.find(title.Text or "", "Delivery") then
                                        deliveryMarker = obj
                                    end
                                end
                            end
                        end)
                        if deliveryMarker then break end
                    end
                end
                
                if deliveryMarker then
                    -- Teleport to the delivery marker and hold E
                    local markerPos = nil
                    pcall(function() markerPos = deliveryMarker:GetPivot() end)
                    if markerPos then
                        targetCFrame = nil; currentTarget = nil
                        hrp.CFrame = markerPos * CFrame.new(0, 0, -3)
                        task.wait(0.3)
                        -- Hold E to interact
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                        task.wait(1.5)
                        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                        task.wait(0.5)
                        -- Press 1 a few times to progress dialogue
                        for i = 1, 3 do
                            VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                            task.wait(0.2)
                            VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                            task.wait(0.3)
                        end
                    end
                    return
                end
                
                -- PRIORITY 2: KILL QUEST - find NPCs with red Highlight (OutlineColor = 255,0,25)
                local enemy = nil
                for _, v in pairs(workspace.Live:GetChildren()) do
                    if v ~= char and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") and not Players:GetPlayerFromCharacter(v) then
                        for _, hl in pairs(v:GetChildren()) do
                            if hl:IsA("Highlight") and hl.Name ~= "V63_HL" then
                                -- Check if OutlineColor is red (quest target marker)
                                local c = hl.OutlineColor
                                if c.R > 0.9 and c.G < 0.1 and c.B < 0.2 then
                                    enemy = v; break
                                end
                            end
                        end
                    end
                    if enemy then break end
                end
                
                if enemy then
                    currentTarget = enemy
                    summonStand()
                    targetCFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                    return
                end
                
                -- NO QUEST DETECTED - Go to the nearest Mission Board to accept one
                targetCFrame = nil; currentTarget = nil
                
                local map = workspace:FindFirstChild("Map")
                local boards = map and map:FindFirstChild("Mission Boards")
                local pve = boards and boards:FindFirstChild("PvE")
                if not pve then return end
                
                local children = pve:GetChildren()
                if #children == 0 then return end
                
                -- Find the nearest board
                local nearest = nil
                local nearestDist = math.huge
                for _, board in pairs(children) do
                    local boardPos = nil
                    pcall(function() boardPos = board:GetPivot().Position end)
                    if boardPos then
                        local dist = (hrp.Position - boardPos).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = board
                        end
                    end
                end
                
                if nearest then
                    -- Position player in front of the board, facing it
                    local boardCFrame = nearest:GetPivot()
                    local frontCFrame = boardCFrame * CFrame.new(0, 0, 5)
                    hrp.CFrame = CFrame.new(frontCFrame.Position, boardCFrame.Position)
                    task.wait(0.1)
                    -- Align camera behind player facing board
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        cam.CameraType = Enum.CameraType.Scriptable
                        cam.CFrame = CFrame.new(frontCFrame.Position + Vector3.new(0, 2, 3), boardCFrame.Position)
                        task.wait(0.1)
                        cam.CameraType = Enum.CameraType.Custom
                    end)
                    task.wait(0.3)
                    
                    -- Hold E to interact with board
                    VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                    task.wait(1.5)
                    VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    task.wait(0.5)
                    
                    -- Press 1 to accept mission
                    VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    task.wait(0.2)
                    VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game)
                    task.wait(1)
                end
            end)
        end
    end
end)

-- BOSS FARM AUTO FARM
local bossNames = {"Akira Otoishi", "Yoshikage Kira", "Okuyasu Nijimura PRIME", "Miyamoto Musashi"}
local currentBossIndex = 1

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoLvlFarm and selectedLvlFarm == "Boss Farm" then
            pcall(function()
                local char = workspace.Live:FindFirstChild(player.Name)
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- Try to find the current boss in workspace.Live
                local bossTarget = nil
                local bossName = bossNames[currentBossIndex]
                
                for _, v in pairs(workspace.Live:GetChildren()) do
                    if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and v:FindFirstChild("HumanoidRootPart") then
                        if string.find(v.Name, bossName) then
                            bossTarget = v; break
                        end
                    end
                end
                
                if bossTarget then
                    currentTarget = bossTarget
                    summonStand()
                    targetCFrame = bossTarget.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                else
                    -- Boss not found or dead - move to next boss
                    targetCFrame = nil; currentTarget = nil
                    currentBossIndex = currentBossIndex + 1
                    if currentBossIndex > #bossNames then
                        currentBossIndex = 1
                    end
                end
            end)
        end
    end
end)

-- AUTO MEDITATION LOGIC
local medicineName = "Yoga Mat" -- Tên vật phẩm medicine trong game
local meditationNpcName = "The Self" -- Tên con NPC khi vào khu vực

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoMeditation then
            pcall(function()
                local char = workspace.Live:FindFirstChild(player.Name)
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- 1. Tìm NPC địch (khi nó đã thù địch và hiện trong Live)
                local hostile = nil
                for _, v in pairs(workspace.Live:GetChildren()) do
                    if v ~= char and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                        -- Phân biệt clone của mình bằng cách bắt buộc phải có tên người chơi
                        if string.find(string.lower(v.Name), string.lower(player.Name)) and string.find(string.lower(v.Name), "clone") then
                            hostile = v
                            break
                        end
                    end
                end
                
                if hostile then
                    currentTarget = hostile
                    summonStand()
                    targetCFrame = hostile.HumanoidRootPart.CFrame * CFrame.new(0, 9, 0) * CFrame.Angles(-math.pi/2, 0, 0)
                    return
                end
                
                -- Nếu không đánh nhau thì xóa target cũ
                currentTarget = nil
                targetCFrame = nil
                
                -- 2. Tìm NPC để nói chuyện (CHỈ KHI ĐÃ VÀO TRONG KHU VỰC THIỀN, tức là NPC phải ở gần < 2000m)
                local npcToTalk = nil
                if workspace:FindFirstChild("Npcs") then
                    local closestDist = math.huge
                    for _, npc in pairs(workspace.Npcs:GetChildren()) do
                        if npc.Name == meditationNpcName and npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                            local dist = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
                            -- Nếu ở trong phòng thiền (khoảng cách < 2000) thì lấy con gần nhất với mình
                            if dist < 2000 and dist < closestDist then
                                closestDist = dist
                                npcToTalk = npc
                            end
                        end
                    end
                end
                if npcToTalk then
                    local cf = getNpcCFrame(npcToTalk)
                    if cf then
                        hrp.CFrame = cf * CFrame.new(0,0,-3.5)
                        task.wait(0.5)
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(1); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(0.5)
                        for i=1,5 do 
                            VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game); task.wait(0.2); VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game); task.wait(0.4) 
                        end
                        return
                    end
                end
                
                -- 3. Nếu chưa thấy NPC, tìm Medicine ở ngoài để teleport vào trong
                local med = nil
                for _, v in pairs(workspace:GetDescendants()) do
                    -- Tìm đúng thảm trong khu vực Meditation và chưa có người khác ngồi
                    if string.find(string.lower(v.Name), string.lower(medicineName)) and v.Parent and string.find(string.lower(v.Parent.Name), "meditation") then
                        local occupied = false
                        for _, p in pairs(Players:GetPlayers()) do
                            if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                                local dist = (p.Character.HumanoidRootPart.Position - (v:IsA("Model") and v:GetPivot().Position or v.Position)).Magnitude
                                if dist < 5 then occupied = true; break end
                            end
                        end
                        if not occupied then med = v; break end
                    end
                end
                
                if med then
                    local cf = nil
                    if med:IsA("Model") and med.PrimaryPart then cf = med.PrimaryPart.CFrame
                    elseif med:IsA("BasePart") then cf = med.CFrame end
                    
                    if cf then
                        hrp.CFrame = cf * CFrame.new(0,0,-3.5)
                        task.wait(0.5)
                        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(2); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                    end
                end
            end)
        end
    end
end)

updateLocale("ENG")

--// NEW FEATURES LOGIC
local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    if antiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

UIS.JumpRequest:Connect(function()
    if infJump then
        local char = workspace.Live:FindFirstChild(player.Name) or player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if speedHack then
            local char = workspace.Live:FindFirstChild(player.Name) or player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 50
            end
        end
    end
end)

-- Auto-Load on startup
task.spawn(function()
    task.wait(1)
    LoadSettings()
end)

-- Set Stand tab as active on startup
if activeNavBtn == nil then
    -- Trigger the first nav button click to set active state
    for _, child in pairs(sidebar:GetChildren()) do
        if child:IsA("TextButton") then
            child.BackgroundColor3 = Color3.fromRGB(30,25,55)
            child.TextColor3 = Color3.new(1,1,1)
            local acc = child:FindFirstChild("Frame")
            if acc then acc.Visible = true end
            local glowStroke = Instance.new("UIStroke")
            glowStroke.Color = Color3.fromRGB(100,70,200)
            glowStroke.Thickness = 1
            glowStroke.Transparency = 0.6
            glowStroke.Parent = child
            activeNavBtn = child
            break
        end
    end
end
