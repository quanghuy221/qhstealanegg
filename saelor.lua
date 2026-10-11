-- =========================================================================
--   🌶️ CHILLI HUB V2 X RONNEI - STEAL AN EGG 🥚 (PHẦN 1/4)
--   VELVET RUBY EDITION · AUTHOR: RONNEI7.HTK · NO-KEY UNLIMITED
-- =========================================================================

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local TargetScriptUrl = "https://raw.githubusercontent.com/robvxs24/freemium/refs/heads/main/chillihubv2.lua"

local InitialGuis = {}
local ScriptConnections = {}
local ActiveBlurEffect = nil
local InputBlockerScreen = nil
local OpenKeySystemUI = nil

-- HÀM SAO LƯU GUI BAN ĐẦU (dùng cho cleanup nếu cần)
local function TakeGuiSnapshot()
    table.clear(InitialGuis)
    local containers = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
    for _, c in ipairs(containers) do
        if c then
            for _, child in ipairs(c:GetChildren()) do
                InitialGuis[child] = true
            end
        end
    end
end

-- HÀM NGẮT SCRIPT CHÍNH (dùng khi reload UI)
local function TerminateTargetScript()
    getgenv().ChilliV2_Active = false

    for _, conn in ipairs(ScriptConnections) do
        if typeof(conn) == "RBXScriptConnection" and conn.Connected then
            conn:Disconnect()
        end
    end
    table.clear(ScriptConnections)

    local containers = { CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }
    for _, c in ipairs(containers) do
        if c then
            for _, child in ipairs(c:GetChildren()) do
                if not InitialGuis[child] and child.Name ~= "ChilliV2_GetKeyUI" and child.Name ~= "ChilliV2_ToastUI" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end
end

-- HÀM KHỞI ĐỘNG SCRIPT CHÍNH
local function LaunchTargetScriptWithWatcher()
    TakeGuiSnapshot()
    getgenv().ChilliV2_Active = true

    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet(TargetScriptUrl))()
        end)
    end)
end

-- HÀM FORMAT THỜI GIAN
local function FormatTime(seconds: number): string
    if seconds < 0 then seconds = 0 end
    local m = math.floor(seconds / 60)
    local s = seconds % 60
    return string.format("%02d phút %02d giây", m, s)
end


-- =========================================================================
--   🌶️ CHILLI HUB V2 X RONNEI - STEAL AN EGG 🥚 (PHẦN 2/4)
--   SNAPSHOT UI · TOAST HUD · VELVET LIVE HUD
-- =========================================================================

local ActiveToastLabel = nil

local function ShowLiveToast(titleText: string, initialSeconds: number, color: Color3)
    if CoreGui:FindFirstChild("ChilliV2_ToastUI") then CoreGui.ChilliV2_ToastUI:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ChilliV2_ToastUI") then
        LocalPlayer.PlayerGui.ChilliV2_ToastUI:Destroy()
    end

    local ToastGui = Instance.new("ScreenGui")
    ToastGui.Name = "ChilliV2_ToastUI"
    ToastGui.ResetOnSpawn = false
    pcall(function() ToastGui.Parent = CoreGui end)
    if not ToastGui.Parent then ToastGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    local ToastFrame = Instance.new("Frame")
    ToastFrame.Size = UDim2.new(0, 385, 0, 74)
    ToastFrame.Position = UDim2.new(0.5, -192, 0, -100)
    ToastFrame.BackgroundColor3 = Color3.fromRGB(20, 8, 12)
    ToastFrame.BorderSizePixel = 0
    ToastFrame.ZIndex = 50
    ToastFrame.Parent = ToastGui

    Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 16)
    local Stroke = Instance.new("UIStroke", ToastFrame)
    Stroke.Thickness = 1.4
    Stroke.Color = color or Color3.fromRGB(225, 75, 105)

    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 42, 1, 0)
    Icon.Position = UDim2.new(0, 10, 0, 0)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🌶️"
    Icon.TextSize = 22
    Icon.ZIndex = 51
    Icon.Parent = ToastFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -65, 0, 20)
    Title.Position = UDim2.new(0, 52, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Text = titleText
    Title.TextColor3 = color or Color3.fromRGB(245, 195, 210)
    Title.TextSize = 11.5
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.ZIndex = 51
    Title.Parent = ToastFrame

    local Msg = Instance.new("TextLabel")
    Msg.Size = UDim2.new(1, -65, 0, 20)
    Msg.Position = UDim2.new(0, 52, 0, 32)
    Msg.BackgroundTransparency = 1
    Msg.Text = "NO-KEY · Unlimited Access"
    Msg.TextColor3 = Color3.fromRGB(240, 230, 235)
    Msg.TextSize = 11
    Msg.Font = Enum.Font.GothamMedium
    Msg.TextXAlignment = Enum.TextXAlignment.Left
    Msg.ZIndex = 51
    Msg.Parent = ToastFrame

    ActiveToastLabel = Msg

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -24, 0, 3)
    BarBg.Position = UDim2.new(0, 12, 1, -6)
    BarBg.BackgroundColor3 = Color3.fromRGB(36, 12, 18)
    BarBg.BorderSizePixel = 0
    BarBg.ZIndex = 51
    BarBg.Parent = ToastFrame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, 0, 1, 0)
    Bar.BackgroundColor3 = color or Color3.fromRGB(225, 75, 105)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 52
    Bar.Parent = BarBg

    TweenService:Create(ToastFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0.5, -192, 0, 24) }):Play()
    TweenService:Create(Bar, TweenInfo.new(10, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 1, 0) }):Play()

    task.delay(10, function()
        if ToastFrame and ToastFrame.Parent then
            local t = TweenService:Create(ToastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0.5, -192, 0, -100), BackgroundTransparency = 1 })
            t:Play()
            t.Completed:Connect(function()
                if ToastGui and ToastGui.Parent then ToastGui:Destroy() end
                ActiveToastLabel = nil
            end)
        end
    end)
end


-- =========================================================================
--   🌶️ CHILLI HUB V2 X RONNEI - STEAL AN EGG 🥚 (PHẦN 3/4)
--   GIAO DIỆN VELVET RUBY MỜ · TYPOGRAPHY DỊU MẮT · CHỮ NGHỆ THUẬT
-- =========================================================================

local Languages = {
    VI = {
        LangBtnText = "🇻🇳 VN ▾",
        SelectLangTitle = "🌶️ NGÔN NGỮ HỆ THỐNG / LANGUAGE",
        Title = "Chilli Hub V2 X Ronnei",
        Subtitle = "chilli hub v2 được tạo bởi ronnei7.htk",
        CenterTitle = "CHILLI HUB V2 × RONNEI",
        CenterSub = "Steal An Egg 🥚 Edition · NO KEY",
        Placeholder = "Chế độ NO-KEY · Bấm KÍCH HOẠT để vào Chilli Hub V2...",
        GetKey = "🔄 RELOAD UI",
        CheckKey = "🌶️ KÍCH HOẠT V2",
        Notice = "📌 Bản NO-KEY: Không cần key, không giới hạn thời gian sử dụng. Nhấn KÍCH HOẠT V2 để khởi động Chilli Hub ngay lập tức.",
        CopiedLink = "📋 ĐÃ KHỞI ĐỘNG LẠI GIAO DIỆN!",
        Checking = "ĐANG KHỞI ĐỘNG...",
        CheckingMsg = "⏳ Đang kết nối tới máy chủ Chilli...",
        Success = "✔ Khởi động thành công! Đang mở Chilli Hub V2...",
        Error = "✖ Không thể tải script chính, vui lòng thử lại!"
    },
    EN = {
        LangBtnText = "🇺🇸 EN ▾",
        SelectLangTitle = "🌶️ SELECT SYSTEM LANGUAGE",
        Title = "Chilli Hub V2 X Ronnei",
        Subtitle = "chilli hub v2 created by ronnei7.htk",
        CenterTitle = "CHILLI HUB V2 × RONNEI",
        CenterSub = "Steal An Egg 🥚 Edition · NO KEY",
        Placeholder = "NO-KEY mode · Press ACTIVATE to enter Chilli Hub V2...",
        GetKey = "🔄 RELOAD UI",
        CheckKey = "🌶️ ACTIVATE V2",
        Notice = "📌 NO-KEY build: No key needed, no time limit. Press ACTIVATE V2 to launch Chilli Hub instantly.",
        CopiedLink = "📋 UI HAS BEEN RELOADED!",
        Checking = "LAUNCHING...",
        CheckingMsg = "⏳ Connecting to Chilli server...",
        Success = "✔ Launched successfully! Opening Chilli Hub V2...",
        Error = "✖ Failed to load main script, please retry!"
    }
}
local CurrentLang = "VI"

local function PlayDeepBounce(btn: TextButton)
    local origSize = btn.Size
    local origPos = btn.Position
    local shrinkSize = UDim2.new(origSize.X.Scale, origSize.X.Offset - 5, origSize.Y.Scale, origSize.Y.Offset - 3)
    local shrinkPos = UDim2.new(origPos.X.Scale, origPos.X.Offset + 2.5, origPos.Y.Scale, origPos.Y.Offset + 1.5)

    local t1 = TweenService:Create(btn, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = shrinkSize, Position = shrinkPos })
    local t2 = TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = origSize, Position = origPos })
    t1:Play()
    t1.Completed:Connect(function() t2:Play() end)
end

OpenKeySystemUI = function()
    if CoreGui:FindFirstChild("ChilliV2_GetKeyUI") then CoreGui.ChilliV2_GetKeyUI:Destroy() end
    if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("ChilliV2_GetKeyUI") then
        LocalPlayer.PlayerGui.ChilliV2_GetKeyUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ChilliV2_GetKeyUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() ScreenGui.Parent = CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- Khung thẻ chính: Tone đen rượu vang mờ (440 x 380)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Size = UDim2.new(0, 440, 0, 380)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 6, 9)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.ZIndex = 30
    MainFrame.Parent = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 22)

    local MainScale = Instance.new("UIScale", MainFrame)
    MainScale.Scale = 0.5

    -- Viền lụa hồng nhung dịu mắt
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Thickness = 1.4
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Color = Color3.fromRGB(220, 68, 98)

    RunService.RenderStepped:Connect(function()
        local val = (math.sin(tick() * 1.8) + 1) / 2
        local r = (190 + math.floor(val * 35)) / 255
        local g = (45 + math.floor(val * 25)) / 255
        local b = (75 + math.floor(val * 30)) / 255
        MainStroke.Color = Color3.new(r, g, b)
    end)

    -- HEADER TOP BAR
    local HeaderBar = Instance.new("Frame")
    HeaderBar.Size = UDim2.new(1, -24, 0, 42)
    HeaderBar.Position = UDim2.new(0, 12, 0, 10)
    HeaderBar.BackgroundTransparency = 1
    HeaderBar.ZIndex = 31
    HeaderBar.Parent = MainFrame

    local MiniLogo = Instance.new("Frame")
    MiniLogo.Size = UDim2.new(0, 28, 0, 28)
    MiniLogo.Position = UDim2.new(0, 0, 0.5, -14)
    MiniLogo.BackgroundColor3 = Color3.fromRGB(28, 9, 14)
    MiniLogo.ZIndex = 32
    MiniLogo.Parent = HeaderBar
    Instance.new("UICorner", MiniLogo).CornerRadius = UDim.new(1, 0)
    local MiniLogoStroke = Instance.new("UIStroke", MiniLogo)
    MiniLogoStroke.Color = Color3.fromRGB(220, 68, 98)
    MiniLogoStroke.Thickness = 1.2

    local MiniLogoTxt = Instance.new("TextLabel")
    MiniLogoTxt.Size = UDim2.new(1, 0, 1, 0)
    MiniLogoTxt.BackgroundTransparency = 1
    MiniLogoTxt.Text = "🌶️"
    MiniLogoTxt.TextSize = 13
    MiniLogoTxt.ZIndex = 33
    MiniLogoTxt.Parent = MiniLogo

    -- TIÊU ĐỀ: Chilli Hub V2 X Ronnei
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -115, 0, 18)
    TitleLabel.Position = UDim2.new(0, 36, 0, 2)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Languages[CurrentLang].Title
    TitleLabel.TextColor3 = Color3.fromRGB(248, 232, 236)
    TitleLabel.TextSize = 12
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.ZIndex = 32
    TitleLabel.Parent = HeaderBar

    -- DÒNG CHỮ: chilli hub v2 được tạo bởi ronnei7.htk
    local SubTitleLabel = Instance.new("TextLabel")
    SubTitleLabel.Size = UDim2.new(1, -115, 0, 16)
    SubTitleLabel.Position = UDim2.new(0, 36, 0, 20)
    SubTitleLabel.BackgroundTransparency = 1
    SubTitleLabel.Text = Languages[CurrentLang].Subtitle
    SubTitleLabel.TextColor3 = Color3.fromRGB(235, 148, 170)
    SubTitleLabel.TextSize = 10
    SubTitleLabel.Font = Enum.Font.GothamMedium
    SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubTitleLabel.ZIndex = 32
    SubTitleLabel.Parent = HeaderBar

    local OpenLangBtn = Instance.new("TextButton")
    OpenLangBtn.Size = UDim2.new(0, 76, 0, 26)
    OpenLangBtn.Position = UDim2.new(1, -76, 0.5, -13)
    OpenLangBtn.BackgroundColor3 = Color3.fromRGB(26, 8, 13)
    OpenLangBtn.Text = Languages[CurrentLang].LangBtnText
    OpenLangBtn.TextColor3 = Color3.fromRGB(245, 195, 210)
    OpenLangBtn.TextSize = 10.5
    OpenLangBtn.Font = Enum.Font.GothamBold
    OpenLangBtn.AutoButtonColor = false
    OpenLangBtn.ZIndex = 32
    OpenLangBtn.Parent = HeaderBar
    Instance.new("UICorner", OpenLangBtn).CornerRadius = UDim.new(0, 8)
    local LangStroke = Instance.new("UIStroke", OpenLangBtn)
    LangStroke.Color = Color3.fromRGB(180, 50, 75)
    LangStroke.Thickness = 1

    -- LOGO TRUNG TÂM
    local CenterLogoBox = Instance.new("Frame")
    CenterLogoBox.Size = UDim2.new(0, 56, 0, 56)
    CenterLogoBox.Position = UDim2.new(0.5, -28, 0, 52)
    CenterLogoBox.BackgroundColor3 = Color3.fromRGB(24, 7, 12)
    CenterLogoBox.ZIndex = 31
    CenterLogoBox.Parent = MainFrame
    Instance.new("UICorner", CenterLogoBox).CornerRadius = UDim.new(0, 18)
    local CenterLogoStroke = Instance.new("UIStroke", CenterLogoBox)
    CenterLogoStroke.Color = Color3.fromRGB(220, 68, 98)
    CenterLogoStroke.Thickness = 1.2

    local CenterLogoTxt = Instance.new("TextLabel")
    CenterLogoTxt.Size = UDim2.new(1, 0, 1, 0)
    CenterLogoTxt.BackgroundTransparency = 1
    CenterLogoTxt.Text = "🥚"
    CenterLogoTxt.TextSize = 27
    CenterLogoTxt.ZIndex = 32
    CenterLogoTxt.Parent = CenterLogoBox

    local CenterTitle = Instance.new("TextLabel")
    CenterTitle.Size = UDim2.new(1, -30, 0, 20)
    CenterTitle.Position = UDim2.new(0, 15, 0, 116)
    CenterTitle.BackgroundTransparency = 1
    CenterTitle.Text = Languages[CurrentLang].CenterTitle
    CenterTitle.TextColor3 = Color3.fromRGB(250, 240, 243)
    CenterTitle.TextSize = 13.5
    CenterTitle.Font = Enum.Font.GothamBold
    CenterTitle.ZIndex = 31
    CenterTitle.Parent = MainFrame

    local CenterSub = Instance.new("TextLabel")
    CenterSub.Size = UDim2.new(1, -30, 0, 16)
    CenterSub.Position = UDim2.new(0, 15, 0, 136)
    CenterSub.BackgroundTransparency = 1
    CenterSub.Text = Languages[CurrentLang].CenterSub
    CenterSub.TextColor3 = Color3.fromRGB(235, 148, 170)
    CenterSub.TextSize = 10
    CenterSub.Font = Enum.Font.GothamMedium
    CenterSub.ZIndex = 31
    CenterSub.Parent = MainFrame

    -- Ô TEXT (thay chỗ nhập key — hiển thị trạng thái NO-KEY)
    local InputBox = Instance.new("TextBox")
    InputBox.Size = UDim2.new(1, -36, 0, 38)
    InputBox.Position = UDim2.new(0, 18, 0, 158)
    InputBox.BackgroundColor3 = Color3.fromRGB(22, 7, 12)
    InputBox.TextColor3 = Color3.fromRGB(248, 235, 238)
    InputBox.PlaceholderColor3 = Color3.fromRGB(135, 75, 90)
    InputBox.PlaceholderText = Languages[CurrentLang].Placeholder
    InputBox.Text = "🌶️ NO-KEY MODE · UNLIMITED ACCESS"
    InputBox.TextEditable = false
    InputBox.TextSize = 11.5
    InputBox.Font = Enum.Font.GothamMedium
    InputBox.ClearTextOnFocus = false
    InputBox.ZIndex = 31
    InputBox.Parent = MainFrame
    Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 10)
    local InputStroke = Instance.new("UIStroke", InputBox)
    InputStroke.Color = Color3.fromRGB(60, 18, 28)

    -- HÀNG NÚT BẤM
    local ButtonsRow = Instance.new("Frame")
    ButtonsRow.Size = UDim2.new(1, -36, 0, 42)
    ButtonsRow.Position = UDim2.new(0, 18, 0, 204)
    ButtonsRow.BackgroundTransparency = 1
    ButtonsRow.ZIndex = 31
    ButtonsRow.Parent = MainFrame

    -- Nút 1: Reload UI
    local GetKeyBtn = Instance.new("TextButton")
    GetKeyBtn.Size = UDim2.new(0.5, -6, 1, 0)
    GetKeyBtn.Position = UDim2.new(0, 0, 0, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(215, 60, 90)
    GetKeyBtn.Text = Languages[CurrentLang].GetKey
    GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GetKeyBtn.TextSize = 11.5
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.AutoButtonColor = false
    GetKeyBtn.ZIndex = 32
    GetKeyBtn.Parent = ButtonsRow
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 10)
    local GetKeyStroke = Instance.new("UIStroke", GetKeyBtn)
    GetKeyStroke.Color = Color3.fromRGB(240, 95, 125)

    -- Nút 2: Kích Hoạt V2
    local CheckKeyBtn = Instance.new("TextButton")
    CheckKeyBtn.Size = UDim2.new(0.5, -6, 1, 0)
    CheckKeyBtn.Position = UDim2.new(0.5, 6, 0, 0)
    CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(26, 8, 14)
    CheckKeyBtn.Text = Languages[CurrentLang].CheckKey
    CheckKeyBtn.TextColor3 = Color3.fromRGB(245, 195, 210)
    CheckKeyBtn.TextSize = 11.5
    CheckKeyBtn.Font = Enum.Font.GothamBold
    CheckKeyBtn.AutoButtonColor = false
    CheckKeyBtn.ZIndex = 32
    CheckKeyBtn.Parent = ButtonsRow
    Instance.new("UICorner", CheckKeyBtn).CornerRadius = UDim.new(0, 10)
    local CheckStroke = Instance.new("UIStroke", CheckKeyBtn)
    CheckStroke.Color = Color3.fromRGB(180, 50, 75)
    CheckStroke.Thickness = 1.2

    -- BẢNG THÔNG BÁO LƯU Ý
    local NoticeCard = Instance.new("Frame")
    NoticeCard.Size = UDim2.new(1, -36, 0, 68)
    NoticeCard.Position = UDim2.new(0, 18, 0, 256)
    NoticeCard.BackgroundColor3 = Color3.fromRGB(20, 6, 11)
    NoticeCard.ZIndex = 31
    NoticeCard.Parent = MainFrame
    Instance.new("UICorner", NoticeCard).CornerRadius = UDim.new(0, 10)
    local NoticeStroke = Instance.new("UIStroke", NoticeCard)
    NoticeStroke.Color = Color3.fromRGB(50, 14, 22)

    local NoticeText = Instance.new("TextLabel")
    NoticeText.Size = UDim2.new(1, -16, 1, -10)
    NoticeText.Position = UDim2.new(0, 8, 0, 5)
    NoticeText.BackgroundTransparency = 1
    NoticeText.Text = Languages[CurrentLang].Notice
    NoticeText.TextColor3 = Color3.fromRGB(245, 215, 222)
    NoticeText.TextSize = 10.5
    NoticeText.Font = Enum.Font.GothamMedium
    NoticeText.TextWrapped = true
    NoticeText.TextYAlignment = Enum.TextYAlignment.Center
    NoticeText.TextXAlignment = Enum.TextXAlignment.Left
    NoticeText.ZIndex = 32
    NoticeText.Parent = NoticeCard

    local StatusMsg = Instance.new("TextLabel")
    StatusMsg.Size = UDim2.new(1, -36, 0, 22)
    StatusMsg.Position = UDim2.new(0, 18, 0, 332)
    StatusMsg.BackgroundTransparency = 1
    StatusMsg.Text = "Chilli Hub V2 X Ronnei · NO-KEY · Unlimited Access"
    StatusMsg.TextColor3 = Color3.fromRGB(145, 80, 95)
    StatusMsg.TextSize = 9.5
    StatusMsg.Font = Enum.Font.GothamMedium
    StatusMsg.ZIndex = 31
    StatusMsg.Parent = MainFrame


-- =========================================================================
--   🌶️ CHILLI HUB V2 X RONNEI - STEAL AN EGG 🥚 (PHẦN 4/4)
--   SỰ KIỆN NÚT BẤM · ĐIỀU HƯỚNG BILINGUAL · AUTO LOAD
-- =========================================================================

    -- MODAL NGÔN NGỮ
    local LangModal = Instance.new("Frame")
    LangModal.Name = "LangModal"
    LangModal.Size = UDim2.new(1, 0, 1, 0)
    LangModal.Position = UDim2.new(0, 0, 1, 0)
    LangModal.BackgroundColor3 = Color3.fromRGB(12, 4, 7)
    LangModal.BackgroundTransparency = 0.02
    LangModal.ZIndex = 40
    LangModal.Parent = MainFrame
    Instance.new("UICorner", LangModal).CornerRadius = UDim.new(0, 22)

    local ModalTitle = Instance.new("TextLabel")
    ModalTitle.Size = UDim2.new(1, -60, 0, 30)
    ModalTitle.Position = UDim2.new(0, 20, 0, 18)
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.Text = Languages[CurrentLang].SelectLangTitle
    ModalTitle.TextColor3 = Color3.fromRGB(220, 68, 98)
    ModalTitle.TextSize = 12
    ModalTitle.Font = Enum.Font.GothamBold
    ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
    ModalTitle.ZIndex = 41
    ModalTitle.Parent = LangModal

    local CloseModalBtn = Instance.new("TextButton")
    CloseModalBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseModalBtn.Position = UDim2.new(1, -40, 0, 18)
    CloseModalBtn.BackgroundColor3 = Color3.fromRGB(28, 8, 14)
    CloseModalBtn.Text = "✕"
    CloseModalBtn.TextColor3 = Color3.fromRGB(220, 68, 98)
    CloseModalBtn.TextSize = 12
    CloseModalBtn.Font = Enum.Font.GothamBold
    CloseModalBtn.ZIndex = 41
    CloseModalBtn.Parent = LangModal
    Instance.new("UICorner", CloseModalBtn).CornerRadius = UDim.new(0, 6)

    local LangList = Instance.new("Frame")
    LangList.Size = UDim2.new(1, -40, 0, 150)
    LangList.Position = UDim2.new(0, 20, 0, 65)
    LangList.BackgroundTransparency = 1
    LangList.ZIndex = 41
    LangList.Parent = LangModal

    local OptViBtn = Instance.new("TextButton")
    OptViBtn.Size = UDim2.new(1, 0, 0, 56)
    OptViBtn.BackgroundColor3 = Color3.fromRGB(28, 8, 14)
    OptViBtn.Text = "🇻🇳  Tiếng Việt (Vietnamese)  ✓"
    OptViBtn.TextColor3 = Color3.fromRGB(245, 195, 210)
    OptViBtn.TextSize = 13
    OptViBtn.Font = Enum.Font.GothamBold
    OptViBtn.ZIndex = 42
    OptViBtn.AutoButtonColor = false
    OptViBtn.Parent = LangList
    Instance.new("UICorner", OptViBtn).CornerRadius = UDim.new(0, 12)
    local OptViStroke = Instance.new("UIStroke", OptViBtn)
    OptViStroke.Color = Color3.fromRGB(220, 68, 98)
    OptViStroke.Thickness = 1.3

    local OptEnBtn = Instance.new("TextButton")
    OptEnBtn.Size = UDim2.new(1, 0, 0, 56)
    OptEnBtn.Position = UDim2.new(0, 0, 0, 68)
    OptEnBtn.BackgroundColor3 = Color3.fromRGB(18, 5, 9)
    OptEnBtn.Text = "🇺🇸  English (Global)"
    OptEnBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
    OptEnBtn.TextSize = 13
    OptEnBtn.Font = Enum.Font.GothamMedium
    OptEnBtn.ZIndex = 42
    OptEnBtn.AutoButtonColor = false
    OptEnBtn.Parent = LangList
    Instance.new("UICorner", OptEnBtn).CornerRadius = UDim.new(0, 12)
    local OptEnStroke = Instance.new("UIStroke", OptEnBtn)
    OptEnStroke.Color = Color3.fromRGB(50, 14, 22)

    local function SetLanguage(code: string)
        CurrentLang = code
        local data = Languages[code]
        OpenLangBtn.Text = data.LangBtnText
        TitleLabel.Text = data.Title
        SubTitleLabel.Text = data.Subtitle
        CenterTitle.Text = data.CenterTitle
        CenterSub.Text = data.CenterSub
        InputBox.PlaceholderText = data.Placeholder
        GetKeyBtn.Text = data.GetKey
        CheckKeyBtn.Text = data.CheckKey
        NoticeText.Text = data.Notice
        ModalTitle.Text = data.SelectLangTitle

        if code == "VI" then
            OptViBtn.Text = "🇻🇳  Tiếng Việt (Vietnamese)  ✓"
            OptViBtn.TextColor3 = Color3.fromRGB(245, 195, 210)
            OptViBtn.Font = Enum.Font.GothamBold
            OptViStroke.Color = Color3.fromRGB(220, 68, 98)
            OptViBtn.BackgroundColor3 = Color3.fromRGB(28, 8, 14)

            OptEnBtn.Text = "🇺🇸  English (Global)"
            OptEnBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
            OptEnBtn.Font = Enum.Font.GothamMedium
            OptEnStroke.Color = Color3.fromRGB(50, 14, 22)
            OptEnBtn.BackgroundColor3 = Color3.fromRGB(18, 5, 9)
        else
            OptEnBtn.Text = "🇺🇸  English (Global)  ✓"
            OptEnBtn.TextColor3 = Color3.fromRGB(245, 195, 210)
            OptEnBtn.Font = Enum.Font.GothamBold
            OptEnStroke.Color = Color3.fromRGB(220, 68, 98)
            OptEnBtn.BackgroundColor3 = Color3.fromRGB(28, 8, 14)

            OptViBtn.Text = "🇻🇳  Tiếng Việt (Vietnamese)"
            OptViBtn.TextColor3 = Color3.fromRGB(156, 163, 175)
            OptViBtn.Font = Enum.Font.GothamMedium
            OptViStroke.Color = Color3.fromRGB(50, 14, 22)
            OptViBtn.BackgroundColor3 = Color3.fromRGB(18, 5, 9)
        end
    end

    local function OpenLangModal()
        TweenService:Create(LangModal, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Position = UDim2.new(0, 0, 0, 0) }):Play()
    end
    local function CloseLangModal()
        TweenService:Create(LangModal, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), { Position = UDim2.new(0, 0, 1, 0) }):Play()
    end

    OpenLangBtn.MouseButton1Click:Connect(function() PlayDeepBounce(OpenLangBtn); OpenLangModal() end)
    CloseModalBtn.MouseButton1Click:Connect(function() PlayDeepBounce(CloseModalBtn); CloseLangModal() end)
    OptViBtn.MouseButton1Click:Connect(function() PlayDeepBounce(OptViBtn); SetLanguage("VI"); task.wait(0.15); CloseLangModal() end)
    OptEnBtn.MouseButton1Click:Connect(function() PlayDeepBounce(OptEnBtn); SetLanguage("EN"); task.wait(0.15); CloseLangModal() end)

    MainFrame.BackgroundTransparency = 1
    MainScale.Scale = 0.4
    TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 0 }):Play()
    TweenService:Create(MainScale, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()

    -- SỰ KIỆN BẤM NÚT RELOAD UI
    GetKeyBtn.MouseButton1Click:Connect(function()
        PlayDeepBounce(GetKeyBtn)

        GetKeyBtn.Text = "RELOADING..."
        GetKeyBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        GetKeyStroke.Color = Color3.fromRGB(52, 211, 153)
        StatusMsg.Text = Languages[CurrentLang].CopiedLink
        StatusMsg.TextColor3 = Color3.fromRGB(52, 211, 153)

        task.delay(0.9, function()
            if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
            task.wait(0.15)
            OpenKeySystemUI()
        end)
    end)

    -- SỰ KIỆN BẤM KÍCH HOẠT V2
    local isChecking = false
    CheckKeyBtn.MouseButton1Click:Connect(function()
        if isChecking then return end
        isChecking = true
        PlayDeepBounce(CheckKeyBtn)

        CheckKeyBtn.Text = Languages[CurrentLang].Checking
        StatusMsg.Text = Languages[CurrentLang].CheckingMsg
        StatusMsg.TextColor3 = Color3.fromRGB(245, 195, 210)

        task.wait(0.6)

        -- Thành công luôn (NO-KEY)
        CheckKeyBtn.Text = "SUCCESS"
        CheckKeyBtn.BackgroundColor3 = Color3.fromRGB(22, 101, 52)
        CheckStroke.Color = Color3.fromRGB(74, 222, 128)
        StatusMsg.Text = Languages[CurrentLang].Success
        StatusMsg.TextColor3 = Color3.fromRGB(74, 222, 128)

        ShowLiveToast("CHILLI HUB V2 X RONNEI (NO KEY)", 0, Color3.fromRGB(220, 68, 98))
        LaunchTargetScriptWithWatcher()

        task.wait(0.4)
        TweenService:Create(MainScale, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Scale = 0.5 }):Play()
        task.wait(0.25)
        if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    end)
end

-- =========================================================================
--   🌶️ LUỒNG CHÍNH: NO-KEY · AUTO LOAD CHILLI HUB V2
-- =========================================================================

OpenKeySystemUI()
