-- BIZZARE LINEAGE ULTIMATE SCRIPT (PRO EDITION)
-- Single File Version

local function loadConfigManager()
-- VCLE_BL/Core/ConfigManager.lua
local HttpService = game:GetService("HttpService")

local ConfigManager = {
    FileName = "VCLE_BL_Config.json",
    
    -- Trạng thái các tính năng (Giá trị mặc định)
        State = {
        Language = "ENG",
        AutoQuest = false,
        AutoLvlFarm = false,
        LvlFarmType = "PVE Mission Boards",
        AutoMeditation = false,
        AutoFarmItems = false,
        AutoArrow = false,
        StopWorth0 = false,
        DesiredStand = "Star Platinum",
        AutoRaid = false,
        AutoRestart = false,
        AutoAddStats = false,
        SelectedRaidBoss = "Kira",
        AddStatType = "Strength",
        AutoPrestige = false,
        EspItems = false,
        EspPeople = false,
        EspNPC = false,
        EspHighlight = true,
        EspBox = true,
        EspName = true,
        EspHealth = true,
        EspDist = true,
        AntiAfk = false,
        SpeedHack = false,
        InfJump = false,
        AutoStand = false,
        FastAttack = false,
        AutoSkills = {
            E = false,
            R = false,
            T = false,
            Y = false,
            F = false,
            G = false,
            H = false,
            Z = false,
            X = false,
            C = false,
            V = false
        }
    }
}

-- Gọi hàm này để lấy trạng thái hiện tại của một biến (VD: ConfigManager.State.AutoMeditation)
function ConfigManager:Get(key)
    return self.State[key]
end

-- Đặt trạng thái mới
function ConfigManager:Set(key, value)
    self.State[key] = value
end

function ConfigManager:SetSkill(key, value)
    self.State.AutoSkills[key] = value
end

-- Tải cấu hình từ ổ cứng
function ConfigManager:Load()
    if isfile and readfile and isfile(self.FileName) then
        local success, decoded = pcall(function()
            return HttpService:JSONDecode(readfile(self.FileName))
        end)
        
        if success and type(decoded) == "table" then
            -- Cập nhật vào State nhưng giữ nguyên những key không tồn tại trong file cũ
            for k, v in pairs(decoded) do
                if type(v) == "table" and k == "AutoSkills" then
                    for sk, sv in pairs(v) do
                        self.State.AutoSkills[sk] = sv
                    end
                else
                    self.State[k] = v
                end
            end
            print("[VCLE BL] Đã tải cấu hình thành công!")
        end
    end
end

-- Lưu cấu hình xuống ổ cứng
function ConfigManager:Save()
    if writefile then
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(self.State)
        end)
        if success then
            writefile(self.FileName, encoded)
        end
    end
end

-- Tự động lưu mỗi 5 giây
task.spawn(function()
    while task.wait(5) do
        ConfigManager:Save()
    end
end)



    return ConfigManager
end

local function loadUILibrary()
-- VCLE_BL/Core/UI_Library.lua
local UILibrary = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local UI_COLOR = {
    Background = Color3.fromRGB(8, 8, 8),
    Sidebar = Color3.fromRGB(12, 12, 12),
    Primary = Color3.fromRGB(57, 255, 20), -- Hacker Neon Green
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(0, 180, 0),
    Element = Color3.fromRGB(18, 18, 18),
    Hover = Color3.fromRGB(30, 60, 30)
}

function UILibrary:CreateWindow(title, credits)
    -- Xóa UI cũ nếu tồn tại
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name == "VCLE_BL_UI" then v:Destroy() end
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VCLE_BL_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    MainFrame.BackgroundColor3 = UI_COLOR.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = UI_COLOR.Primary
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.2
    UIStroke.Parent = MainFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font = Enum.Font.Code
    CloseBtn.TextSize = 18
    CloseBtn.Parent = MainFrame
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 30)
    MinBtn.Position = UDim2.new(1, -65, 0, 5)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "-"
    MinBtn.TextColor3 = UI_COLOR.Text
    MinBtn.Font = Enum.Font.Code
    MinBtn.TextSize = 18
    MinBtn.Parent = MainFrame
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        MainFrame.ClipsDescendants = true
        if minimized then
            game:GetService("TweenService"):Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 600, 0, 40)}):Play()
        else
            game:GetService("TweenService"):Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(0, 600, 0, 400)}):Play()
        end
    end)

    -- Kéo thả UI
    local dragging, dragInput, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Thanh bên (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = UI_COLOR.Sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 50)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = UI_COLOR.Text
    TitleLabel.Font = Enum.Font.Code
    TitleLabel.TextSize = 18
    TitleLabel.Parent = Sidebar

    local CreditsLabel = Instance.new("TextLabel")
    CreditsLabel.Size = UDim2.new(1, 0, 0, 30)
    CreditsLabel.Position = UDim2.new(0, 0, 1, -40)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Text = credits
    CreditsLabel.TextColor3 = UI_COLOR.SubText
    CreditsLabel.Font = Enum.Font.Code
    CreditsLabel.TextSize = 10
    CreditsLabel.Parent = Sidebar

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Size = UDim2.new(1, 0, 1, -90)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    TabContainer.Parent = Sidebar

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)
    UIListLayout.Parent = TabContainer

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -160, 1, 0)
    ContentContainer.Position = UDim2.new(0, 160, 0, 0)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local Window = {
        CurrentTab = nil,
        Tabs = {}
    }

    function Window:CreateTab(tabName, icon)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(1, -20, 0, 35)
        TabBtn.Position = UDim2.new(0, 10, 0, 0)
        TabBtn.BackgroundColor3 = UI_COLOR.Element
        TabBtn.Text = "  " .. (icon and (icon .. " ") or "") .. tabName
        TabBtn.TextColor3 = UI_COLOR.SubText
        TabBtn.Font = Enum.Font.Code
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.Parent = TabContainer
        
        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 8)
        TabBtnCorner.Parent = TabBtn

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Size = UDim2.new(1, -30, 1, -30)
        TabPage.Position = UDim2.new(0, 15, 0, 15)
        TabPage.BackgroundTransparency = 1
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = UI_COLOR.Primary
        TabPage.Visible = false
        TabPage.Parent = ContentContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout.Parent = TabPage

        -- Tự động dãn cuộn
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for _, btn in pairs(Window.Tabs) do
                TweenService:Create(btn.Button, TweenInfo.new(0.3), {BackgroundColor3 = UI_COLOR.Element, TextColor3 = UI_COLOR.SubText}):Play()
                btn.Page.Visible = false
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.3), {BackgroundColor3 = UI_COLOR.Primary, TextColor3 = UI_COLOR.Text}):Play()
            TabPage.Visible = true
        end)

        local TabElements = {Button = TabBtn, Page = TabPage}
        table.insert(Window.Tabs, TabElements)
        
        -- Mặc định chọn tab đầu tiên
        if #Window.Tabs == 1 then
            TabBtn.BackgroundColor3 = UI_COLOR.Primary
            TabBtn.TextColor3 = UI_COLOR.Text
            TabPage.Visible = true
        end

        local Elements = {}

        function Elements:CreateToggle(text, default, callback)
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 45)
            ToggleFrame.BackgroundColor3 = UI_COLOR.Element
            ToggleFrame.Parent = TabPage
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = UI_COLOR.Text
            Label.Font = Enum.Font.Code
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = ToggleFrame

            local ToggleBtn = Instance.new("TextButton")
            ToggleBtn.Size = UDim2.new(0, 44, 0, 24)
            ToggleBtn.Position = UDim2.new(1, -60, 0.5, -12)
            ToggleBtn.BackgroundColor3 = default and UI_COLOR.Primary or Color3.fromRGB(100, 100, 100)
            ToggleBtn.Text = ""
            ToggleBtn.Parent = ToggleFrame
            Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            Indicator.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
            Indicator.BackgroundColor3 = Color3.new(1,1,1)
            Indicator.Parent = ToggleBtn
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)

            local state = default
            ToggleBtn.MouseButton1Click:Connect(function()
                state = not state
                TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and UI_COLOR.Primary or Color3.fromRGB(100, 100, 100)}):Play()
                TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
                if callback then callback(state) end
            end)

            return {
                Set = function(val)
                    if state == val then return end
                    state = val
                    TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = state and UI_COLOR.Primary or Color3.fromRGB(100, 100, 100)}):Play()
                    TweenService:Create(Indicator, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)}):Play()
                    if callback then callback(state) end
                end
            }
        end

        function Elements:CreateLabel(text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Size = UDim2.new(1, -10, 0, 30)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Parent = TabPage

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -15, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = UI_COLOR.Primary
            Label.Font = Enum.Font.Code
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = LabelFrame
            return Label
        end

        function Elements:CreateButton(text, callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -10, 0, 40)
            Button.BackgroundColor3 = UI_COLOR.Element
            Button.Text = text
            Button.TextColor3 = UI_COLOR.Text
            Button.Font = Enum.Font.Code
            Button.TextSize = 14
            Button.Parent = TabPage
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

            Button.MouseEnter:Connect(function() TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = UI_COLOR.Hover}):Play() end)
            Button.MouseLeave:Connect(function() TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = UI_COLOR.Element}):Play() end)
            Button.MouseButton1Click:Connect(callback)
        end

        function Elements:CreateDropdown(text, options, default, callback)
            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -10, 0, 45)
            DropFrame.BackgroundColor3 = UI_COLOR.Element
            DropFrame.Parent = TabPage
            DropFrame.ClipsDescendants = true
            Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 0, 45)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = UI_COLOR.Text
            Label.Font = Enum.Font.Code
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0, 120, 0, 30)
            SelectedLabel.Position = UDim2.new(1, -135, 0, 7.5)
            SelectedLabel.BackgroundColor3 = UI_COLOR.Hover
            SelectedLabel.Text = default or (options[1] or "N/A")
            SelectedLabel.TextColor3 = UI_COLOR.Text
            SelectedLabel.Font = Enum.Font.Code
            SelectedLabel.TextSize = 12
            SelectedLabel.Parent = DropFrame
            Instance.new("UICorner", SelectedLabel).CornerRadius = UDim.new(0, 6)

            local DropBtn = Instance.new("TextButton")
            DropBtn.Size = UDim2.new(1, 0, 0, 45)
            DropBtn.BackgroundTransparency = 1
            DropBtn.Text = ""
            DropBtn.Parent = DropFrame

            local OptionContainer = Instance.new("Frame")
            OptionContainer.Size = UDim2.new(1, 0, 1, -45)
            OptionContainer.Position = UDim2.new(0, 0, 0, 45)
            OptionContainer.BackgroundTransparency = 1
            OptionContainer.Parent = DropFrame
            
            local OptionLayout = Instance.new("UIListLayout")
            OptionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionLayout.Parent = OptionContainer

            local isDropped = false
            DropBtn.MouseButton1Click:Connect(function()
                isDropped = not isDropped
                TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = isDropped and UDim2.new(1, -10, 0, 45 + (#options * 35)) or UDim2.new(1, -10, 0, 45)}):Play()
            end)

            local function RefreshOptions(newOpts)
                for _, v in pairs(OptionContainer:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
                for _, opt in pairs(newOpts) do
                    local btn = Instance.new("TextButton")
                    btn.Size = UDim2.new(1, 0, 0, 35)
                    btn.BackgroundColor3 = UI_COLOR.Element
                    btn.Text = "    " .. opt
                    btn.TextColor3 = UI_COLOR.SubText
                    btn.Font = Enum.Font.Code
                    btn.TextSize = 13
                    btn.TextXAlignment = Enum.TextXAlignment.Left
                    btn.Parent = OptionContainer

                    btn.MouseEnter:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = UI_COLOR.Hover, TextColor3 = UI_COLOR.Primary}):Play() end)
                    btn.MouseLeave:Connect(function() TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = UI_COLOR.Element, TextColor3 = UI_COLOR.SubText}):Play() end)
                    btn.MouseButton1Click:Connect(function()
                        SelectedLabel.Text = opt
                        isDropped = false
                        TweenService:Create(DropFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, -10, 0, 45)}):Play()
                        if callback then callback(opt) end
                    end)
                end
            end
            RefreshOptions(options)

            return {
                Refresh = function(opts)
                    RefreshOptions(opts)
                end,
                Set = function(opt)
                    SelectedLabel.Text = opt
                    if callback then callback(opt) end
                end
            }
        end

        function Elements:CreateInput(text, default, callback)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, -10, 0, 45)
            InputFrame.BackgroundColor3 = UI_COLOR.Element
            InputFrame.Parent = TabPage
            Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 8)

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -130, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = UI_COLOR.Text
            Label.Font = Enum.Font.Code
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0, 100, 0, 30)
            TextBox.Position = UDim2.new(1, -115, 0, 7.5)
            TextBox.BackgroundColor3 = UI_COLOR.Hover
            TextBox.Text = default or ""
            TextBox.TextColor3 = UI_COLOR.Text
            TextBox.Font = Enum.Font.Code
            TextBox.TextSize = 12
            TextBox.Parent = InputFrame
            Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 6)

            TextBox.FocusLost:Connect(function()
                if callback then callback(TextBox.Text) end
            end)
            
            return TextBox
        end
        return Elements
    end

    return Window
end



    return UILibrary
end

local ConfigManager = loadConfigManager()
ConfigManager:Load()
getgenv().VCLE_BL_ConfigManager = ConfigManager

local UILibrary = loadUILibrary()

-- TỪ ĐIỂN SONG NGỮ (ENG / VN)
local currentLang = ConfigManager:Get("Language") or "ENG"
local LOCALES = {
    ["ENG"] = {
        TAB_FARM = "Farm", TAB_RAID = "Raids", TAB_STATS = "Stats", TAB_ESP = "ESP", TAB_SETTING = "Settings",
        FARM_LABEL1 = "Quest & Level Farm", LVL_TYPE = "Level Farm Mode", AUTO_FARM_ITEMS = "Auto Farm Items/Arrows",
        AUTO_QUEST = "Auto Quest",
        AUTO_LVL = "Auto Level Farm",
        AUTO_MEDI = "Auto Meditation",
        FARM_LABEL2 = "Stand & Items",
        AUTO_ARROW = "Auto Use Arrow",
        STOP_WORTH = "Stop if Worthiness = 0",
        DESIRED_STAND = "Desired Stand",
        RAID_LABEL = "Auto Raids",
        CHOOSE_BOSS_RAID = "Choose Raid Boss",
        AUTO_RAID = "Auto Raid",
        AUTO_RESTART = "Auto Restart",
        STATS_LABEL = "Character Stats",
        STAT_TYPE = "Select Stat",
        AUTO_STATS = "Auto Add Stats",
        AUTO_PRESTIGE = "Auto Prestige",
        ESP_LABEL = "Visuals (ESP)",
        ESP_ITEMS = "Item ESP",
        ESP_PEOPLE = "Player ESP",
        ESP_NPC = "NPC/Mob ESP", ESP_BOX = "Box ESP", ESP_NAME = "Name ESP", ESP_HEALTH = "Health ESP", ESP_DIST = "Distance ESP",
        SETTING_LABEL = "General Settings",
        LANGUAGE = "Language", ANTI_AFK = "Anti AFK", SPEED_HACK = "Speed Hack", INF_JUMP = "Infinite Jump",
        AUTO_STAND = "Auto Summon Stand",
        SKILL_LABEL = "Auto Skills",
        USE_SKILL = "Use Skill "
    },
    ["VN"] = {
        TAB_FARM = "Cày Cuốc", TAB_RAID = "Vượt Ải", TAB_STATS = "Chỉ Số", TAB_ESP = "Nhìn Xuyên", TAB_SETTING = "Cài Đặt",
        FARM_LABEL1 = "Cày Cấp & Nhiệm Vụ",
        AUTO_QUEST = "Tự động Làm Nhiệm Vụ",
        AUTO_LVL = "Tự động Đánh Quái",
        AUTO_MEDI = "Tự động Ngồi Thiền",
        FARM_LABEL2 = "Tìm Stand & Đồ",
        AUTO_ARROW = "Tự động Dùng Mũi Tên",
        STOP_WORTH = "Dừng lại nếu Worthiness = 0",
        DESIRED_STAND = "Stand mong muốn",
        RAID_LABEL = "Tự động vượt Ải",
        CHOOSE_BOSS_RAID = "Chọn Boss Raid",
        AUTO_RAID = "Tự động đánh Raid",
        AUTO_RESTART = "Tự động Khởi động lại",
        STATS_LABEL = "Chỉ số cá nhân",
        STAT_TYPE = "Chọn Chỉ số",
        AUTO_STATS = "Tự động Cộng điểm",
        AUTO_PRESTIGE = "Tự động Chuyển sinh",
        ESP_LABEL = "Hiển thị (ESP)",
        ESP_ITEMS = "ESP Vật phẩm",
        ESP_PEOPLE = "ESP Người chơi",
        ESP_NPC = "ESP Quái vật/NPC",
        SETTING_LABEL = "Cài đặt Chung",
        LANGUAGE = "Ngôn ngữ (Language)",
        AUTO_STAND = "Tự động gọi Stand",
        SKILL_LABEL = "Tự động xả chiêu (Skills)",
        USE_SKILL = "Dùng chiêu "
    }
}
local function L(key) return LOCALES[currentLang][key] or key end

-- 2. Tải UI Library
local Window = UILibrary:CreateWindow("VCLE BL", "BIZZARE LINEAGE - PRO EDITION BY EMMA")

-- 3. Tạo các Tab
local TabFarm = Window:CreateTab(L("TAB_FARM"), ">_")
local TabRaid = Window:CreateTab(L("TAB_RAID"), ">_")
local TabStats = Window:CreateTab(L("TAB_STATS"), ">_")
local TabESP = Window:CreateTab(L("TAB_ESP"), ">_")
local TabSettings = Window:CreateTab(L("TAB_SETTING"), ">_")

-- 4. Liên kết UI với ConfigManager
TabFarm:CreateLabel(L("FARM_LABEL1"))
TabFarm:CreateDropdown(L("LVL_TYPE"), {"PVE Mission Boards", "Boss Farm"}, ConfigManager:Get("LvlFarmType"), function(val) ConfigManager:Set("LvlFarmType", val) end)
TabFarm:CreateToggle(L("AUTO_QUEST"), ConfigManager:Get("AutoQuest"), function(state) ConfigManager:Set("AutoQuest", state) end)
TabFarm:CreateToggle(L("AUTO_LVL"), ConfigManager:Get("AutoLvlFarm"), function(state) ConfigManager:Set("AutoLvlFarm", state) end)
TabFarm:CreateToggle(L("AUTO_MEDI"), ConfigManager:Get("AutoMeditation"), function(state) ConfigManager:Set("AutoMeditation", state) end)

TabFarm:CreateLabel(L("FARM_LABEL2"))
TabFarm:CreateToggle(L("AUTO_FARM_ITEMS"), ConfigManager:Get("AutoFarmItems"), function(state) ConfigManager:Set("AutoFarmItems", state) end)
TabFarm:CreateToggle(L("AUTO_ARROW"), ConfigManager:Get("AutoArrow"), function(state) ConfigManager:Set("AutoArrow", state) end)
TabFarm:CreateToggle(L("STOP_WORTH"), ConfigManager:Get("StopWorth0"), function(state) ConfigManager:Set("StopWorth0", state) end)
TabFarm:CreateInput(L("DESIRED_STAND"), ConfigManager:Get("DesiredStand"), function(val) ConfigManager:Set("DesiredStand", val) end)

local selectedRaidBoss = ConfigManager:Get("SelectedRaidBoss") or "Kira"
TabRaid:CreateLabel(L("RAID_LABEL"))
TabRaid:CreateDropdown(L("CHOOSE_BOSS_RAID"), {"Kira", "Dio", "Avdol", "Jotaro", "PrisonEscape", "Death13", "HeavenAscDIO"}, selectedRaidBoss, function(val) selectedRaidBoss = val; ConfigManager:Set("SelectedRaidBoss", val) end)
TabRaid:CreateToggle(L("AUTO_RAID"), ConfigManager:Get("AutoRaid"), function(state) ConfigManager:Set("AutoRaid", state) end)
TabRaid:CreateToggle(L("AUTO_RESTART"), ConfigManager:Get("AutoRestart"), function(state) ConfigManager:Set("AutoRestart", state) end)

TabStats:CreateLabel(L("STATS_LABEL"))
TabStats:CreateToggle(L("AUTO_STATS"), ConfigManager:Get("AutoAddStats"), function(state) ConfigManager:Set("AutoAddStats", state) end)
TabStats:CreateInput("Target Strength", tostring(ConfigManager:Get("Target_Strength") or 0), function(val) ConfigManager:Set("Target_Strength", tonumber(val) or 0) end)
TabStats:CreateInput("Target Health", tostring(ConfigManager:Get("Target_Health") or 0), function(val) ConfigManager:Set("Target_Health", tonumber(val) or 0) end)
TabStats:CreateInput("Target Power", tostring(ConfigManager:Get("Target_Power") or 0), function(val) ConfigManager:Set("Target_Power", tonumber(val) or 0) end)
TabStats:CreateInput("Target Weapon", tostring(ConfigManager:Get("Target_Weapon") or 0), function(val) ConfigManager:Set("Target_Weapon", tonumber(val) or 0) end)
TabStats:CreateInput("Target Destructive Power", tostring(ConfigManager:Get("Target_Destructive_Power") or 0), function(val) ConfigManager:Set("Target_Destructive_Power", tonumber(val) or 0) end)
TabStats:CreateInput("Target Destructive Energy", tostring(ConfigManager:Get("Target_Destructive_Energy") or 0), function(val) ConfigManager:Set("Target_Destructive_Energy", tonumber(val) or 0) end)
TabStats:CreateToggle(L("AUTO_PRESTIGE"), ConfigManager:Get("AutoPrestige"), function(state) ConfigManager:Set("AutoPrestige", state) end)

TabESP:CreateLabel(L("ESP_LABEL"))
TabESP:CreateToggle(L("ESP_ITEMS"), ConfigManager:Get("EspItems"), function(state) ConfigManager:Set("EspItems", state) end)
TabESP:CreateToggle(L("ESP_PEOPLE"), ConfigManager:Get("EspPeople"), function(state) ConfigManager:Set("EspPeople", state) end)
TabESP:CreateToggle(L("ESP_NPC"), ConfigManager:Get("EspNPC"), function(state) ConfigManager:Set("EspNPC", state) end)
TabESP:CreateToggle(L("ESP_BOX"), ConfigManager:Get("EspBox"), function(state) ConfigManager:Set("EspBox", state) end)
TabESP:CreateToggle(L("ESP_NAME"), ConfigManager:Get("EspName"), function(state) ConfigManager:Set("EspName", state) end)
TabESP:CreateToggle(L("ESP_HEALTH"), ConfigManager:Get("EspHealth"), function(state) ConfigManager:Set("EspHealth", state) end)
TabESP:CreateToggle(L("ESP_DIST"), ConfigManager:Get("EspDist"), function(state) ConfigManager:Set("EspDist", state) end)

TabSettings:CreateLabel(L("SETTING_LABEL"))
TabSettings:CreateDropdown(L("LANGUAGE"), {"ENG", "VN"}, ConfigManager:Get("Language"), function(val) 
    ConfigManager:Set("Language", val) 
    ConfigManager:Save()
    if Window.ScreenGui then Window.ScreenGui:Destroy() end
    -- To properly reload UI, we need to restart the script, we will just notify the user
    print("Language changed. Please execute the script again to apply changes.")
end)
TabSettings:CreateLabel("Change Language requires script restart")
TabSettings:CreateToggle(L("AUTO_STAND"), ConfigManager:Get("AutoStand"), function(state) ConfigManager:Set("AutoStand", state) end)
TabSettings:CreateToggle(L("ANTI_AFK"), ConfigManager:Get("AntiAfk"), function(state) ConfigManager:Set("AntiAfk", state) end)
TabSettings:CreateToggle(L("SPEED_HACK"), ConfigManager:Get("SpeedHack"), function(state) ConfigManager:Set("SpeedHack", state) end)
TabSettings:CreateToggle(L("INF_JUMP"), ConfigManager:Get("InfJump"), function(state) ConfigManager:Set("InfJump", state) end)
TabSettings:CreateToggle("Fast Attack (x3)", ConfigManager:Get("FastAttack"), function(state) ConfigManager:Set("FastAttack", state) end)

TabSettings:CreateLabel(L("SKILL_LABEL"))
local skills = {"E", "R", "Z", "X", "C", "V", "1", "2", "3", "4", "5", "6", "7", "8", "9"}
for _, key in ipairs(skills) do
    TabSettings:CreateToggle(L("USE_SKILL") .. key, ConfigManager.State.AutoSkills[key], function(state) ConfigManager:SetSkill(key, state) end)
end

-- 5. Tải Logic Core



-- FAST ATTACK (Animation Speed Hack)
task.spawn(function()
    while task.wait(0.2) do
        if ConfigManager:Get("FastAttack") then
            pcall(function()
                local char = workspace.Live:FindFirstChild(player.Name) or player.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    if hum then
                        local animator = hum:FindFirstChildOfClass("Animator")
                        if animator then
                            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                                if track.Speed > 0 and track.Speed < 3 then
                                    track:AdjustSpeed(3)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)
print("[VCLE BL] Script Loaded Successfully!")

-- [[ LOGIC CORE ]] --
local Config = ConfigManager.State
local currentTarget = nil
local targetCFrame = nil

-- SERVICES
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- HELPERS
local function toNum(v) return tonumber(v) or 0 end

-- RAID BOSSES CONFIGURATION
local RAID_BOSSES = {
    ["Kira"] = { BossName = "Kira", TalkName = "Yoshikage Kira" },
    ["Dio"] = { BossName = "DIO", TalkName = "???" },
    ["Avdol"] = { BossName = "Avdol", TalkName = "Avdol" },
    ["Jotaro"] = { BossName = "Jotaro", TalkName = "Chumbo" },
    ["PrisonEscape"] = { BossName = "Pucci", TalkName = "Prison Escape" },
    ["Death13"] = { BossName = "Death 13", TalkName = "Death 13" },
    ["HeavenAscDIO"] = { BossName = "DIO", TalkName = "Heaven Ascended DIO" }
}

-- STAT SYSTEM
local STAT_NAME_MAP = {
    ["Strength"] = "StrengthStat", ["Health"] = "DefenseStat", ["Power"] = "PowerStat",
    ["Weapon"] = "WeaponStat", ["Destructive Power"] = "DestructivePowerStat", ["Destructive Energy"] = "DestructiveEnergyStat"
}
local spAmount = 1

-- QUEST DATA READER
local function getQuestData()
    local sd = player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("SlotData")
    if not sd then return nil end
    local questNames = {"Quest", "Quests", "StorylineQuest", "QuestData", "CurrentQuest", "SideQuest"}
    for _, qName in pairs(questNames) do
        local obj = sd:FindFirstChild(qName)
        if obj then
            local ok, questList = pcall(function()
                local raw = obj.Value
                if type(raw) == "string" then return HttpService:JSONDecode(raw) end
                return nil
            end)
            if ok and type(questList) == "table" then
                local quests = questList
                if questList.Talk or questList.Defeat or questList.Kills then quests = {questList} end
                for _, quest in pairs(quests) do
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
        local label = Instance.new("TextLabel"); label.Name = "Info"; label.Size = UDim2.new(1,0,1,0); label.BackgroundTransparency = 1; label.TextColor3 = color; label.TextStrokeTransparency = 0; label.TextSize = 14; label.Font = Enum.Font.Code; label.Parent = bb
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

--// TELEPORT LOOP
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

-- HELPER: Get current stand name
local function getStand()
    local ok, val = pcall(function() return player.PlayerData.SlotData.Stand.Value end)
    return ok and val or "None"
end

-- AUTOMATION: Auto Arrow
task.spawn(function()
    while task.wait(1) do if Config.AutoArrow then local stand = getStand()
    if Config.DesiredStand ~= "" and string.lower(stand) == string.lower(Config.DesiredStand) then Config.AutoArrow = false
    elseif Config.StopWorth0 and player.PlayerData.SlotData.Worthiness.Value == 0 then Config.AutoArrow = false
    else ReplicatedStorage.requests.character.use_item:FireServer("Stand Arrow") end end end
end)

task.spawn(function()
    while task.wait(0.5) do if Config.AutoFarmItems then local char = workspace.Live:FindFirstChild(player.Name)
    if char and char:FindFirstChild("HumanoidRootPart") then for _, o in pairs(workspace:GetChildren()) do if not Config.AutoFarmItems then break end
    if o.Name == "Stand Arrow" or o:FindFirstChild("Stand Arrow") then char.HumanoidRootPart.CFrame = o:GetPivot(); task.wait(0.2); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(1.0); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(1.0); break end end end end end
end)

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoAddStats then
            local sd = player:FindFirstChild("PlayerData") and player.PlayerData:FindFirstChild("SlotData")
            if sd and sd:FindFirstChild("StatPoints") then
                local points = toNum(sd.StatPoints.Value)
                if points > 0 then
                    local statTargets = {
                        ["Strength"] = ConfigManager:Get("Target_Strength") or 0,
                        ["Health"] = ConfigManager:Get("Target_Health") or 0,
                        ["Power"] = ConfigManager:Get("Target_Power") or 0,
                        ["Weapon"] = ConfigManager:Get("Target_Weapon") or 0,
                        ["Destructive Power"] = ConfigManager:Get("Target_Destructive_Power") or 0,
                        ["Destructive Energy"] = ConfigManager:Get("Target_Destructive_Energy") or 0
                    }
                    for display, target in pairs(statTargets) do
                        if not Config.AutoAddStats then break end
                        local exact = STAT_NAME_MAP[display]
                        if target > 0 and exact and toNum(sd[exact].Value) < target then
                            ReplicatedStorage.requests.character.increase_stat:FireServer(exact, spAmount)
                            task.wait(0.3)
                            break
                        end
                    end
                end
            end
        end
    end
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

    while task.wait(0.1) do pcall(function() -- Quest
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
        end) -- pcall
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
            pcall(function()
                local sd = player.PlayerData.SlotData; local lvl = toNum(sd.Level.Value); local money = toNum(sd.Money.Value)
                if lvl >= 50 and money >= 10000 then
                    local npcs = workspace:FindFirstChild("Npcs")
                    local mage = npcs and npcs:FindFirstChild("Arch Mage")
                    if not mage then
                        -- Fallback: search in ReplicatedStorage
                        local assets = ReplicatedStorage:FindFirstChild("assets")
                        local cache = assets and assets:FindFirstChild("npc_cache")
                        mage = cache and cache:FindFirstChild("Arch Mage")
                    end
                    local char = workspace.Live:FindFirstChild(player.Name); local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if mage and mage:FindFirstChild("HumanoidRootPart") and hrp then
                        targetCFrame = nil; currentTarget = nil
                        hrp.CFrame = mage.HumanoidRootPart.CFrame * CFrame.new(0,0,-3.5)
                        task.wait(0.5); VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.8); VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game); task.wait(0.5)
                        for i=1,3 do VIM:SendKeyEvent(true, Enum.KeyCode.One, false, game); task.wait(0.2); VIM:SendKeyEvent(false, Enum.KeyCode.One, false, game); task.wait(0.5) end
                    end
                end
            end)
        end
    end
end)

-- PVE MISSION BOARD AUTO FARM
task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoLvlFarm and Config.LvlFarmType == "PVE Mission Boards" then
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
        if Config.AutoLvlFarm and Config.LvlFarmType == "Boss Farm" then
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
local medicineName = "Yoga Mat"
local meditationNpcName = "The Self"

task.spawn(function()
    while task.wait(0.5) do
        if Config.AutoMeditation then
            pcall(function()
                local char = workspace.Live:FindFirstChild(player.Name)
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                
                -- 1. Find hostile clone
                local hostile = nil
                for _, v in pairs(workspace.Live:GetChildren()) do
                    if v ~= char and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 and not Players:GetPlayerFromCharacter(v) then
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
                
                -- No fight, clear target
                currentTarget = nil
                targetCFrame = nil
                
                -- 2. Find NPC to talk (only when inside meditation zone, NPC must be < 2000m)
                local npcToTalk = nil
                if workspace:FindFirstChild("Npcs") then
                    local closestDist = math.huge
                    for _, npc in pairs(workspace.Npcs:GetChildren()) do
                        if npc.Name == meditationNpcName and npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") then
                            local dist = (hrp.Position - npc.HumanoidRootPart.Position).Magnitude
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
                
                -- 3. If no NPC found, find Medicine (Yoga Mat) to teleport in
                local med = nil
                for _, v in pairs(workspace:GetDescendants()) do
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

local VirtualUser = game:GetService("VirtualUser")
player.Idled:Connect(function()
    if Config.AntiAfk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

UIS.JumpRequest:Connect(function()
    if Config.InfJump then
        local char = workspace.Live:FindFirstChild(player.Name) or player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

task.spawn(function()
    while task.wait(0.1) do
        if Config.SpeedHack then
            local char = workspace.Live:FindFirstChild(player.Name) or player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum then
                hum.WalkSpeed = 50
            end
        end
    end
end)







