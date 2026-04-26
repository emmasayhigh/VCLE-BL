-- VCLE_BL/Core/UI_Library.lua
local UILibrary = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local UI_COLOR = {
    Background = Color3.fromRGB(28, 28, 30),
    Sidebar = Color3.fromRGB(44, 44, 46),
    Primary = Color3.fromRGB(10, 132, 255), -- iOS Blue
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(174, 174, 178),
    Element = Color3.fromRGB(58, 58, 60),
    Hover = Color3.fromRGB(72, 72, 74)
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
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 18
    TitleLabel.Parent = Sidebar

    local CreditsLabel = Instance.new("TextLabel")
    CreditsLabel.Size = UDim2.new(1, 0, 0, 30)
    CreditsLabel.Position = UDim2.new(0, 0, 1, -40)
    CreditsLabel.BackgroundTransparency = 1
    CreditsLabel.Text = credits
    CreditsLabel.TextColor3 = UI_COLOR.SubText
    CreditsLabel.Font = Enum.Font.Gotham
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
        TabBtn.Font = Enum.Font.GothamSemibold
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
            Label.Font = Enum.Font.Gotham
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
            Label.Font = Enum.Font.GothamBold
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
            Button.Font = Enum.Font.GothamSemibold
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
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = DropFrame

            local SelectedLabel = Instance.new("TextLabel")
            SelectedLabel.Size = UDim2.new(0, 120, 0, 30)
            SelectedLabel.Position = UDim2.new(1, -135, 0, 7.5)
            SelectedLabel.BackgroundColor3 = UI_COLOR.Hover
            SelectedLabel.Text = default or (options[1] or "N/A")
            SelectedLabel.TextColor3 = UI_COLOR.Text
            SelectedLabel.Font = Enum.Font.Gotham
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
                    btn.Font = Enum.Font.Gotham
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
            Label.Font = Enum.Font.Gotham
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0, 100, 0, 30)
            TextBox.Position = UDim2.new(1, -115, 0, 7.5)
            TextBox.BackgroundColor3 = UI_COLOR.Hover
            TextBox.Text = default or ""
            TextBox.TextColor3 = UI_COLOR.Text
            TextBox.Font = Enum.Font.Gotham
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
