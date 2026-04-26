-- VCLE_BL/Core/ConfigManager.lua
local HttpService = game:GetService("HttpService")

local ConfigManager = {
    FileName = "VCLE_BL_Config.json",
    
    -- Trạng thái các tính năng (Giá trị mặc định)
    State = {
        Language = "ENG", -- Ngôn ngữ mặc định
        
        -- Tab Farm
        AutoQuest = false,
        AutoLvlFarm = false,
        AutoArrow = false,
        StopWorth0 = false,
        AutoMeditation = false,
        AutoStand = false,
        DesiredStand = "Star Platinum",
        
        -- Tab Raids
        AutoRaid = false,
        AutoRestart = false,
        
        -- Tab Stats
        AutoAddStats = false,
        AutoPrestige = false,
        
        -- Tab ESP
        EspItems = false,
        EspPeople = false,
        EspNPC = false,
        EspHighlight = true,
        EspBox = true,
        EspName = true,
        EspHealth = true,
        EspDist = true,
        
        -- Tab Settings (Skills)
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
            V = false,
            B = false
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
