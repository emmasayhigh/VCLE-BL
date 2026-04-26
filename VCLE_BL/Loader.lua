-- VCLE_BL/Loader.lua

local isLocal = true
local githubPath = "https://raw.githubusercontent.com/YOUR_GITHUB_NAME/VCLE_BL/main/"
local localPath = "VCLE_BL/"

local function GetModule(path)
    if isLocal then
        if isfile and readfile then
            local func, err = loadstring(readfile(localPath .. path))
            if func then return func() else error("Lỗi load file: " .. err) end
        end
    else
        return loadstring(game:HttpGet(githubPath .. path))()
    end
end

-- 1. Tải ConfigManager
local ConfigManager = GetModule("Core/ConfigManager.lua")
ConfigManager:Load()
getgenv().VCLE_BL_ConfigManager = ConfigManager

-- TỪ ĐIỂN SONG NGỮ (ENG / VN)
local currentLang = ConfigManager:Get("Language") or "ENG"
local LOCALES = {
    ["ENG"] = {
        TAB_FARM = "Farm", TAB_RAID = "Raids", TAB_STATS = "Stats", TAB_ESP = "ESP", TAB_SETTING = "Settings",
        FARM_LABEL1 = "Quest & Level Farm",
        AUTO_QUEST = "Auto Quest",
        AUTO_LVL = "Auto Level Farm",
        AUTO_MEDI = "Auto Meditation",
        FARM_LABEL2 = "Stand & Items",
        AUTO_ARROW = "Auto Use Arrow",
        STOP_WORTH = "Stop if Worthiness = 0",
        DESIRED_STAND = "Desired Stand",
        RAID_LABEL = "Auto Raids",
        AUTO_RAID = "Auto Raid",
        AUTO_RESTART = "Auto Restart",
        STATS_LABEL = "Character Stats",
        AUTO_STATS = "Auto Add Stats",
        AUTO_PRESTIGE = "Auto Prestige",
        ESP_LABEL = "Visuals (ESP)",
        ESP_ITEMS = "Item ESP",
        ESP_PEOPLE = "Player ESP",
        ESP_NPC = "NPC/Mob ESP",
        SETTING_LABEL = "General Settings",
        LANGUAGE = "Language",
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
        AUTO_RAID = "Tự động đánh Raid",
        AUTO_RESTART = "Tự động Khởi động lại",
        STATS_LABEL = "Chỉ số cá nhân",
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
local UILibrary = GetModule("Core/UI_Library.lua")
local Window = UILibrary:CreateWindow("VCLE BL", "BIZZARE LINEAGE - PRO EDITION BY EMMA")

-- 3. Tạo các Tab
local TabFarm = Window:CreateTab(L("TAB_FARM"), "⚔️")
local TabRaid = Window:CreateTab(L("TAB_RAID"), "🔥")
local TabStats = Window:CreateTab(L("TAB_STATS"), "📈")
local TabESP = Window:CreateTab(L("TAB_ESP"), "👁️")
local TabSettings = Window:CreateTab(L("TAB_SETTING"), "⚙️")

-- 4. Liên kết UI với ConfigManager
TabFarm:CreateLabel(L("FARM_LABEL1"))
TabFarm:CreateToggle(L("AUTO_QUEST"), ConfigManager:Get("AutoQuest"), function(state) ConfigManager:Set("AutoQuest", state) end)
TabFarm:CreateToggle(L("AUTO_LVL"), ConfigManager:Get("AutoLvlFarm"), function(state) ConfigManager:Set("AutoLvlFarm", state) end)
TabFarm:CreateToggle(L("AUTO_MEDI"), ConfigManager:Get("AutoMeditation"), function(state) ConfigManager:Set("AutoMeditation", state) end)

TabFarm:CreateLabel(L("FARM_LABEL2"))
TabFarm:CreateToggle(L("AUTO_ARROW"), ConfigManager:Get("AutoArrow"), function(state) ConfigManager:Set("AutoArrow", state) end)
TabFarm:CreateToggle(L("STOP_WORTH"), ConfigManager:Get("StopWorth0"), function(state) ConfigManager:Set("StopWorth0", state) end)
TabFarm:CreateInput(L("DESIRED_STAND"), ConfigManager:Get("DesiredStand"), function(val) ConfigManager:Set("DesiredStand", val) end)

TabRaid:CreateLabel(L("RAID_LABEL"))
TabRaid:CreateToggle(L("AUTO_RAID"), ConfigManager:Get("AutoRaid"), function(state) ConfigManager:Set("AutoRaid", state) end)
TabRaid:CreateToggle(L("AUTO_RESTART"), ConfigManager:Get("AutoRestart"), function(state) ConfigManager:Set("AutoRestart", state) end)

TabStats:CreateLabel(L("STATS_LABEL"))
TabStats:CreateToggle(L("AUTO_STATS"), ConfigManager:Get("AutoAddStats"), function(state) ConfigManager:Set("AutoAddStats", state) end)
TabStats:CreateToggle(L("AUTO_PRESTIGE"), ConfigManager:Get("AutoPrestige"), function(state) ConfigManager:Set("AutoPrestige", state) end)

TabESP:CreateLabel(L("ESP_LABEL"))
TabESP:CreateToggle(L("ESP_ITEMS"), ConfigManager:Get("EspItems"), function(state) ConfigManager:Set("EspItems", state) end)
TabESP:CreateToggle(L("ESP_PEOPLE"), ConfigManager:Get("EspPeople"), function(state) ConfigManager:Set("EspPeople", state) end)
TabESP:CreateToggle(L("ESP_NPC"), ConfigManager:Get("EspNPC"), function(state) ConfigManager:Set("EspNPC", state) end)

TabSettings:CreateLabel(L("SETTING_LABEL"))
TabSettings:CreateDropdown(L("LANGUAGE"), {"ENG", "VN"}, ConfigManager:Get("Language"), function(val) 
    ConfigManager:Set("Language", val) 
    ConfigManager:Save()
    -- Cần load lại script để áp dụng ngôn ngữ
end)
TabSettings:CreateToggle(L("AUTO_STAND"), ConfigManager:Get("AutoStand"), function(state) ConfigManager:Set("AutoStand", state) end)

TabSettings:CreateLabel(L("SKILL_LABEL"))
local skills = {"E", "R", "T", "Y", "F", "G", "H", "Z", "X", "C", "V", "B"}
for _, key in ipairs(skills) do
    TabSettings:CreateToggle(L("USE_SKILL") .. key, ConfigManager.State.AutoSkills[key], function(state) ConfigManager:SetSkill(key, state) end)
end

-- 5. Tải Logic Core
GetModule("Features/Logic.lua")

print("[VCLE BL] Script Loaded Successfully!")
