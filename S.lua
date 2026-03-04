--[[
    ╔══════════════════════════════════════════════╗
    ║         DELTA PRO v4.0                       ║
    ║   Fly · Speed · ESP · God · Aimbot · Fun     ║
    ║   PC + Mobile · CoreGui · Draggable          ║
    ╚══════════════════════════════════════════════╝
    Delta Executor için optimize edildi
]]

-- SERVICES
local Players          = game:GetService("Players")
local CoreGui          = game:GetService("CoreGui")   -- PlayerGui değil!
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")

local LP      = Players.LocalPlayer
local Camera  = workspace.CurrentCamera
local Mouse   = LP:GetMouse()
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ESKİ GUI TEMİZLE
if CoreGui:FindFirstChild("DeltaPro4") then
    CoreGui.DeltaPro4:Destroy()
end

-- RENKLER
local C = {
    BG       = Color3.fromRGB(8, 10, 20),
    Panel    = Color3.fromRGB(13, 16, 30),
    Card     = Color3.fromRGB(18, 22, 40),
    CardHov  = Color3.fromRGB(26, 32, 54),
    Accent   = Color3.fromRGB(0, 200, 255),
    AccDim   = Color3.fromRGB(0, 80, 120),
    Green    = Color3.fromRGB(0, 230, 120),
    GrnDim   = Color3.fromRGB(0, 90, 50),
    Red      = Color3.fromRGB(255, 55, 70),
    RedDim   = Color3.fromRGB(110, 18, 28),
    Gold     = Color3.fromRGB(255, 200, 50),
    Purple   = Color3.fromRGB(160, 80, 255),
    PurDim   = Color3.fromRGB(60, 20, 110),
    Orange   = Color3.fromRGB(255, 120, 30),
    Text     = Color3.fromRGB(210, 228, 255),
    TextDim  = Color3.fromRGB(85, 110, 155),
    White    = Color3.new(1, 1, 1),
}

-- FEATURE STATE
local State = {
    Fly      = false,
    Speed    = false, SpeedVal  = 30,
    Jump     = false, JumpVal   = 80,
    InfJump  = false,
    NoClip   = false,
    BHop     = false,
    GodMode  = false,
    AntiVoid = false,
    AimBot   = false, AimRange  = 60,
    Hitbox   = false, HitboxSz  = 8,
    ESP      = false,
    FullBrt  = false,
    NightM   = false,
    ClickTP  = false,
    SpinOn   = false, SpinSpd   = 8,
    Platform = false,
    AntiAFK  = false,
    AutoWalk = false,
    FreezeChar = false,
}

-- FLY
local BodyGyro, BodyVelocity

-- PLATFORM
local PlatPart = nil

-- LIGHTING cache
local origAmb, origFog, origBrt = Lighting.Ambient, Lighting.FogEnd, Lighting.Brightness
local fbApplied = false

-- SPIN
local spinConn = nil

-- ── UTILITY ──────────────────────────────────────────────────
local function Tween(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18,
        style or Enum.EasingStyle.Quad,
        dir   or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Corner(p, r)
    local c = Instance.new("UICorner", p)
    c.CornerRadius = UDim.new(0, r or 8)
    return c
end

local function Stroke(p, col, th)
    local s = Instance.new("UIStroke", p)
    s.Color = col or C.Accent
    s.Thickness = th or 1.2
    s.Transparency = 0.4
    return s
end

local function Pad(p, px)
    local pad = Instance.new("UIPadding", p)
    pad.PaddingLeft   = UDim.new(0, px)
    pad.PaddingRight  = UDim.new(0, px)
    pad.PaddingTop    = UDim.new(0, px)
    pad.PaddingBottom = UDim.new(0, px)
end

-- ── NOTIFICATION ─────────────────────────────────────────────
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DeltaPro4"
ScreenGui.Parent         = CoreGui
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 999

local function Toast(msg, col, dur)
    col = col or C.Panel; dur = dur or 2.8
    task.spawn(function()
        local f = Instance.new("Frame", ScreenGui)
        f.Size = UDim2.new(0, 260, 0, 38)
        f.Position = UDim2.new(0.5, -130, 1, 10)
        f.BackgroundColor3 = C.Panel
        f.BackgroundTransparency = 0.05
        f.ZIndex = 200
        Corner(f, 10); Stroke(f, col, 1.5)
        local l = Instance.new("TextLabel", f)
        l.Size = UDim2.new(1, -14, 1, 0)
        l.Position = UDim2.new(0, 7, 0, 0)
        l.BackgroundTransparency = 1
        l.Text = msg; l.TextColor3 = C.White
        l.Font = Enum.Font.Gotham
        l.TextSize = IsMobile and 12 or 11
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.ZIndex = 201
        Tween(f, {Position = UDim2.new(0.5,-130,1,-50)}, 0.3, Enum.EasingStyle.Back)
        task.wait(dur)
        Tween(f, {Position = UDim2.new(0.5,-130,1,10), BackgroundTransparency=1}, 0.25)
        task.delay(0.3, function() f:Destroy() end)
    end)
end

-- ── TOGGLE BUTTON ─────────────────────────────────────────────
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Parent           = ScreenGui
ToggleBtn.Size             = IsMobile and UDim2.new(0,130,0,44) or UDim2.new(0,120,0,36)
ToggleBtn.Position         = UDim2.new(0, 14, 0.42, 0)
ToggleBtn.BackgroundColor3 = C.BG
ToggleBtn.Text             = "✦ DELTA PRO"
ToggleBtn.TextColor3       = C.Accent
ToggleBtn.Font             = Enum.Font.GothamBold
ToggleBtn.TextSize         = IsMobile and 13 or 11
ToggleBtn.AutoButtonColor  = false
ToggleBtn.ZIndex           = 20
Corner(ToggleBtn, 10); Stroke(ToggleBtn, C.Accent, 1.5)

-- Pulse animasyonu
TweenService:Create(ToggleBtn, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {TextColor3 = Color3.fromRGB(100, 220, 255)}):Play()

-- ToggleBtn drag — NovatexV3 ile aynı sistem
do
    local dragging, dragStart, startPos = false, nil, nil
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = ToggleBtn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ── MAIN PANEL ────────────────────────────────────────────────
local PW = IsMobile and 320 or 290
local PH = IsMobile and 520 or 490

local MainFrame = Instance.new("Frame")
MainFrame.Parent           = ScreenGui
MainFrame.Size             = UDim2.new(0, PW, 0, PH)
MainFrame.Position         = UDim2.new(0.5, -PW/2, 0.5, -PH/2)
MainFrame.BackgroundColor3 = C.BG
MainFrame.BackgroundTransparency = 0.06
MainFrame.Visible          = false
MainFrame.Active           = true
MainFrame.ZIndex           = 10
Corner(MainFrame, 14); Stroke(MainFrame, C.Accent, 1.5)

-- Arkaplan gradyanı
local bg = Instance.new("UIGradient", MainFrame)
bg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(12,15,28)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(9,11,22)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(7,9,18)),
})
bg.Rotation = 130

-- ── HEADER ────────────────────────────────────────────────────
local Header = Instance.new("Frame", MainFrame)
Header.Size             = UDim2.new(1,0,0,52)
Header.BackgroundColor3 = C.Panel
Header.ZIndex           = 11
Corner(Header, 14)

local hGrad = Instance.new("UIGradient", Header)
hGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,30,58)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,18,40)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,8,22)),
})
hGrad.Rotation = 90

-- Accent çizgi
local ALine = Instance.new("Frame", MainFrame)
ALine.Size = UDim2.new(1,0,0,2); ALine.Position = UDim2.new(0,0,0,52)
ALine.BackgroundColor3 = C.Accent; ALine.ZIndex = 12
local aGrad = Instance.new("UIGradient", ALine)
aGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.25,C.Accent),
    ColorSequenceKeypoint.new(0.75,C.Accent),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,0,0)),
})

-- Başlık
local TitleLbl = Instance.new("TextLabel", Header)
TitleLbl.Size = UDim2.new(1,-60,0,28); TitleLbl.Position = UDim2.new(0,14,0,4)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "✦ DELTA PRO  v4"
TitleLbl.TextColor3 = C.White; TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextSize = IsMobile and 16 or 14
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left; TitleLbl.ZIndex = 12

-- Başlık animasyonu
local tGrad = Instance.new("UIGradient", TitleLbl)
tGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(0,200,255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,240,255)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,160,220)),
})
task.spawn(function()
    local t = 0
    while MainFrame and MainFrame.Parent do
        t = (t + 0.4) % 360
        tGrad.Rotation = t
        task.wait(0.016)
    end
end)

local SubLbl = Instance.new("TextLabel", Header)
SubLbl.Size = UDim2.new(1,-60,0,14); SubLbl.Position = UDim2.new(0,14,0,34)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = (IsMobile and "Mobil" or "PC").."  •  "..LP.Name.."  •  Delta Edition"
SubLbl.TextColor3 = C.TextDim; SubLbl.Font = Enum.Font.Gotham
SubLbl.TextSize = IsMobile and 10 or 9
SubLbl.TextXAlignment = Enum.TextXAlignment.Left; SubLbl.ZIndex = 12

-- Kapat butonu
local CloseBtn = Instance.new("TextButton", Header)
CloseBtn.Size = UDim2.new(0,28,0,28); CloseBtn.Position = UDim2.new(1,-36,0.5,-14)
CloseBtn.BackgroundColor3 = C.RedDim; CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.Red; CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12; CloseBtn.AutoButtonColor = false
CloseBtn.ZIndex = 13; Corner(CloseBtn, 6)

-- ── HEADER DRAG (NovatexV3 ile aynı) ──────────────────────────
do
    local dragging, dragStart, startPos = false, nil, nil
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or
                         input.UserInputType == Enum.UserInputType.Touch) then
            local d = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ── TAB BAR ──────────────────────────────────────────────────
local TabBar = Instance.new("Frame", MainFrame)
TabBar.Size = UDim2.new(1,0,0,28); TabBar.Position = UDim2.new(0,0,0,54)
TabBar.BackgroundColor3 = C.Panel; TabBar.ZIndex = 11
local TBL = Instance.new("UIListLayout", TabBar)
TBL.FillDirection = Enum.FillDirection.Horizontal

local TABS = {"HAREKET","GORSEL","COMBAT","UTIL","FUN"}
local tabPages = {}; local tabBtns = {}

for i, name in ipairs(TABS) do
    local tb = Instance.new("TextButton", TabBar)
    tb.Size = UDim2.new(1/#TABS, 0, 1, 0)
    tb.BackgroundColor3 = i==1 and C.Card or C.Panel
    tb.Text = name; tb.TextColor3 = i==1 and C.Accent or C.TextDim
    tb.TextSize = IsMobile and 8 or 7.5; tb.Font = Enum.Font.GothamBold
    tb.AutoButtonColor = false; tb.ZIndex = 12
    local ln = Instance.new("Frame", tb)
    ln.Size = UDim2.new(1,0,0,2); ln.Position = UDim2.new(0,0,1,-2)
    ln.BackgroundColor3 = i==1 and C.Accent or C.Panel; ln.ZIndex = 13
    tabBtns[name] = {btn=tb, line=ln}
end

-- Scroll area
local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1,-6,1,-88); Scroll.Position = UDim2.new(0,3,0,84)
Scroll.BackgroundTransparency = 1; Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = C.Accent
Scroll.CanvasSize = UDim2.new(0,0,0,0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.ZIndex = 11

local Layout = Instance.new("UIListLayout", Scroll)
Layout.Padding = UDim.new(0,5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Pad(Scroll, 7)

local secOrder = 0

local function switchTab(name)
    for n, d in pairs(tabBtns) do
        local on = (n==name)
        d.btn.BackgroundColor3 = on and C.Card or C.Panel
        d.btn.TextColor3       = on and C.Accent or C.TextDim
        d.line.BackgroundColor3 = on and C.Accent or C.Panel
    end
    -- Hide/show pages by LayoutOrder range
    for _, child in ipairs(Scroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") or child:IsA("TextLabel") then
            if child:GetAttribute("Tab") then
                child.Visible = (child:GetAttribute("Tab") == name)
            end
        end
    end
end

for name, d in pairs(tabBtns) do
    d.btn.MouseButton1Click:Connect(function() switchTab(name) end)
end

-- ── WIDGET BUILDERS ──────────────────────────────────────────
local function Section(txt, tab)
    secOrder += 1
    local lbl = Instance.new("TextLabel", Scroll)
    lbl.Size = UDim2.new(1,-14,0,22); lbl.BackgroundTransparency = 1
    lbl.Text = "◈  "..txt; lbl.TextColor3 = C.Accent
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = IsMobile and 11 or 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 12
    lbl.LayoutOrder = secOrder; lbl:SetAttribute("Tab", tab)
    -- Separator
    local sep = Instance.new("Frame", Scroll)
    sep.Size = UDim2.new(1,-14,0,1); sep.BackgroundColor3 = C.AccDim
    sep.BackgroundTransparency = 0.35; sep.ZIndex = 12; sep.LayoutOrder = secOrder
    sep:SetAttribute("Tab", tab)
    local sg = Instance.new("UIGradient", sep)
    sg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
        ColorSequenceKeypoint.new(0.5, C.Accent),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0)),
    })
end

local function Toggle(lbl, stateKey, tab, col, onCB, offCB)
    secOrder += 1
    local active = col or C.Green
    local dim    = col==C.Red and C.RedDim or col==C.Gold and Color3.fromRGB(90,60,0) or C.GrnDim

    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1,-14,0, IsMobile and 44 or 38)
    btn.BackgroundColor3 = C.Card; btn.AutoButtonColor = false
    btn.LayoutOrder = secOrder; btn.ZIndex = 12; btn.Text = ""
    btn:SetAttribute("Tab", tab)
    Corner(btn, 8); local bStr = Stroke(btn, C.AccDim, 1)

    local lbTxt = Instance.new("TextLabel", btn)
    lbTxt.Size = UDim2.new(1,-68,1,0); lbTxt.Position = UDim2.new(0,12,0,0)
    lbTxt.BackgroundTransparency = 1; lbTxt.Text = lbl
    lbTxt.TextColor3 = C.Text; lbTxt.Font = Enum.Font.Gotham
    lbTxt.TextSize = IsMobile and 13 or 11
    lbTxt.TextXAlignment = Enum.TextXAlignment.Left; lbTxt.ZIndex = 13

    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0,44,0,18); pill.Position = UDim2.new(1,-52,0.5,-9)
    pill.BackgroundColor3 = dim; pill.ZIndex = 13; Corner(pill, 9)

    local pTxt = Instance.new("TextLabel", pill)
    pTxt.Size = UDim2.new(1,0,1,0); pTxt.BackgroundTransparency = 1
    pTxt.Text = "OFF"; pTxt.TextColor3 = C.TextDim
    pTxt.Font = Enum.Font.GothamBold; pTxt.TextSize = IsMobile and 9 or 8; pTxt.ZIndex = 14

    local function refresh()
        local on = State[stateKey]
        Tween(pill,  {BackgroundColor3 = on and active or dim}, 0.15)
        Tween(pTxt,  {TextColor3 = on and C.White or C.TextDim}, 0.15)
        Tween(btn,   {BackgroundColor3 = on and C.CardHov or C.Card}, 0.15)
        Tween(bStr,  {Color = on and active or C.AccDim, Transparency = on and 0.15 or 0.5}, 0.15)
        pTxt.Text = on and "ON" or "OFF"
    end

    btn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        Tween(btn, {Size=UDim2.new(1,-14,0,IsMobile and 41 or 35)}, 0.06)
        task.delay(0.06, function()
            Tween(btn, {Size=UDim2.new(1,-14,0,IsMobile and 44 or 38)}, 0.1)
        end)
        refresh()
        if State[stateKey] and onCB  then pcall(onCB)  end
        if not State[stateKey] and offCB then pcall(offCB) end
    end)
end

local function Action(lbl, tab, col, cb)
    secOrder += 1
    local c = col or C.AccDim
    local btn = Instance.new("TextButton", Scroll)
    btn.Size = UDim2.new(1,-14,0,IsMobile and 38 or 32)
    btn.BackgroundColor3 = c; btn.AutoButtonColor = false
    btn.LayoutOrder = secOrder; btn.ZIndex = 12; btn.Text = ""
    btn:SetAttribute("Tab", tab); Corner(btn, 7)

    local lbTxt = Instance.new("TextLabel", btn)
    lbTxt.Size = UDim2.new(1,-12,1,0); lbTxt.Position = UDim2.new(0,6,0,0)
    lbTxt.BackgroundTransparency = 1; lbTxt.Text = "▶  "..lbl
    lbTxt.TextColor3 = C.White; lbTxt.Font = Enum.Font.GothamBold
    lbTxt.TextSize = IsMobile and 12 or 10
    lbTxt.TextXAlignment = Enum.TextXAlignment.Left; lbTxt.ZIndex = 13

    btn.MouseButton1Click:Connect(function()
        Tween(btn, {BackgroundColor3=C.Green}, 0.08)
        task.delay(0.35, function() Tween(btn, {BackgroundColor3=c}, 0.28) end)
        if cb then pcall(cb) end
    end)
end

local function Adjuster(lbl, stateKey, minV, maxV, def, tab)
    secOrder += 1
    local card = Instance.new("Frame", Scroll)
    card.Size = UDim2.new(1,-14,0,IsMobile and 86 or 76)
    card.BackgroundColor3 = C.Card; card.ZIndex = 12
    card.LayoutOrder = secOrder; card:SetAttribute("Tab", tab)
    Corner(card, 8); Stroke(card, C.AccDim, 1)

    local lbTxt = Instance.new("TextLabel", card)
    lbTxt.Size = UDim2.new(0.6,0,0,22); lbTxt.Position = UDim2.new(0,10,0,5)
    lbTxt.BackgroundTransparency = 1; lbTxt.Text = lbl
    lbTxt.TextColor3 = C.Text; lbTxt.Font = Enum.Font.GothamBold
    lbTxt.TextSize = IsMobile and 12 or 10
    lbTxt.TextXAlignment = Enum.TextXAlignment.Left; lbTxt.ZIndex = 13

    local valLbl = Instance.new("TextLabel", card)
    valLbl.Size = UDim2.new(0.38,0,0,22); valLbl.Position = UDim2.new(0.6,0,0,5)
    valLbl.BackgroundTransparency = 1; valLbl.Text = tostring(def)
    valLbl.TextColor3 = C.Accent; valLbl.Font = Enum.Font.GothamBold
    valLbl.TextSize = IsMobile and 14 or 12
    valLbl.TextXAlignment = Enum.TextXAlignment.Right; valLbl.ZIndex = 13

    -- Slider track
    local track = Instance.new("Frame", card)
    track.Size = UDim2.new(1,-20,0,5); track.Position = UDim2.new(0,10,0,32)
    track.BackgroundColor3 = C.AccDim; track.ZIndex = 13; Corner(track, 3)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((def-minV)/math.max(maxV-minV,1),0,1,0)
    fill.BackgroundColor3 = C.Accent; fill.ZIndex = 14; Corner(fill, 3)

    -- Minus / Plus butonları
    local minusBtn = Instance.new("TextButton", card)
    minusBtn.Size = UDim2.new(0,IsMobile and 36 or 30,0,IsMobile and 26 or 22)
    minusBtn.Position = UDim2.new(0,10,0,44)
    minusBtn.BackgroundColor3 = C.RedDim; minusBtn.Text = "-"
    minusBtn.TextColor3 = C.Red; minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 15; minusBtn.AutoButtonColor = false; minusBtn.ZIndex = 13
    Corner(minusBtn, 5)

    local plusBtn = Instance.new("TextButton", card)
    plusBtn.Size = UDim2.new(0,IsMobile and 36 or 30,0,IsMobile and 26 or 22)
    plusBtn.Position = UDim2.new(0,IsMobile and 54 or 46,0,44)
    plusBtn.BackgroundColor3 = C.GrnDim; plusBtn.Text = "+"
    plusBtn.TextColor3 = C.Green; plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 15; plusBtn.AutoButtonColor = false; plusBtn.ZIndex = 13
    Corner(plusBtn, 5)

    -- Hızlı slider dokunma
    local dragSld = false
    local sliderHit = Instance.new("TextButton", card)
    sliderHit.Size = UDim2.new(1,-20,0,20); sliderHit.Position = UDim2.new(0,10,0,22)
    sliderHit.BackgroundTransparency = 1; sliderHit.Text = ""; sliderHit.ZIndex = 15

    local function setVal(v)
        v = math.clamp(math.floor(v), minV, maxV)
        State[stateKey] = v
        local pct = (v-minV)/math.max(maxV-minV,1)
        fill.Size = UDim2.new(pct,0,1,0)
        valLbl.Text = tostring(v)
    end

    local function updateFromX(px)
        local pct = math.clamp((px-track.AbsolutePosition.X)/math.max(track.AbsoluteSize.X,1),0,1)
        setVal(minV + pct*(maxV-minV))
    end

    sliderHit.MouseButton1Down:Connect(function() dragSld=true end)
    sliderHit.MouseButton1Click:Connect(function()
        updateFromX(UserInputService:GetMouseLocation().X)
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragSld and (i.UserInputType==Enum.UserInputType.MouseMovement or
                        i.UserInputType==Enum.UserInputType.Touch) then
            updateFromX(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or
           i.UserInputType==Enum.UserInputType.Touch then dragSld=false end
    end)

    local step = math.max(1, math.floor((maxV-minV)/20))
    minusBtn.MouseButton1Click:Connect(function() setVal((State[stateKey] or def)-step) end)
    plusBtn.MouseButton1Click:Connect(function()  setVal((State[stateKey] or def)+step) end)

    setVal(def)
end

-- ── ESP ───────────────────────────────────────────────────────
local espData = {}
local function clearESP()
    for _, objs in pairs(espData) do
        for _, o in ipairs(objs) do pcall(function() o:Destroy() end) end
    end; espData = {}
end

local function updateESP()
    if not State.ESP then clearESP(); return end
    local existing = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            existing[plr] = true
            local char = plr.Character
            local hrp  = char:FindFirstChild("HumanoidRootPart")
            local hum  = char:FindFirstChildOfClass("Humanoid")
            if hrp and hum then
                if not espData[plr] then
                    espData[plr] = {}
                    local box = Instance.new("SelectionBox")
                    box.Adornee=char; box.Color3=C.Accent
                    box.LineThickness=0.03; box.SurfaceTransparency=0.92
                    box.SurfaceColor3=C.Accent; box.Parent=workspace
                    table.insert(espData[plr], box)
                    local bb = Instance.new("BillboardGui")
                    bb.Size=UDim2.new(0,130,0,58); bb.StudsOffset=Vector3.new(0,3.5,0)
                    bb.AlwaysOnTop=true; bb.Adornee=hrp; bb.Parent=workspace
                    local nl=Instance.new("TextLabel",bb)
                    nl.Size=UDim2.new(1,0,0,20); nl.BackgroundTransparency=1
                    nl.Text=plr.Name; nl.TextColor3=C.Gold
                    nl.TextSize=13; nl.Font=Enum.Font.GothamBold
                    nl.TextStrokeTransparency=0
                    local hpBg=Instance.new("Frame",bb)
                    hpBg.Name="HPBg"; hpBg.Size=UDim2.new(0.9,0,0,6)
                    hpBg.Position=UDim2.new(0.05,0,0,23)
                    hpBg.BackgroundColor3=Color3.fromRGB(35,35,35); hpBg.BorderSizePixel=0
                    Corner(hpBg,3)
                    local hpF=Instance.new("Frame",hpBg)
                    hpF.Name="HPFill"; hpF.Size=UDim2.new(1,0,1,0)
                    hpF.BackgroundColor3=C.Green; hpF.BorderSizePixel=0; Corner(hpF,3)
                    local hpT=Instance.new("TextLabel",bb)
                    hpT.Name="HPTxt"; hpT.Size=UDim2.new(1,0,0,14)
                    hpT.Position=UDim2.new(0,0,0,32)
                    hpT.BackgroundTransparency=1; hpT.TextSize=9
                    hpT.Font=Enum.Font.GothamBold; hpT.TextStrokeTransparency=0
                    local dT=Instance.new("TextLabel",bb)
                    dT.Name="DistTxt"; dT.Size=UDim2.new(1,0,0,12)
                    dT.Position=UDim2.new(0,0,0,46)
                    dT.BackgroundTransparency=1; dT.TextColor3=C.TextDim
                    dT.TextSize=8; dT.Font=Enum.Font.Gotham; dT.TextStrokeTransparency=0
                    table.insert(espData[plr], bb)
                end
                for _, obj in ipairs(espData[plr]) do
                    if obj:IsA("BillboardGui") then
                        local pct = math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                        local hpF = obj:FindFirstChild("HPBg") and obj.HPBg:FindFirstChild("HPFill")
                        local hpT = obj:FindFirstChild("HPTxt")
                        local dT  = obj:FindFirstChild("DistTxt")
                        if hpF then hpF.Size=UDim2.new(pct,0,1,0)
                            hpF.BackgroundColor3=pct>.6 and C.Green or pct>.3 and C.Gold or C.Red end
                        if hpT then
                            hpT.Text=math.floor(hum.Health).."/"..math.floor(hum.MaxHealth)
                            hpT.TextColor3=pct>.6 and C.Green or pct>.3 and C.Gold or C.Red
                        end
                        if dT then
                            local myH=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                            if myH then dT.Text=math.floor((hrp.Position-myH.Position).Magnitude).."m" end
                        end
                    end
                end
            end
        end
    end
    for plr in pairs(espData) do
        if not existing[plr] then
            for _,o in ipairs(espData[plr]) do pcall(function() o:Destroy() end) end
            espData[plr]=nil
        end
    end
end

-- ── PLATFORM ─────────────────────────────────────────────────
local function createPlatform()
    if PlatPart then PlatPart:Destroy(); PlatPart=nil end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    PlatPart = Instance.new("Part")
    PlatPart.Name="DeltaPlatform4"; PlatPart.Size=Vector3.new(10,0.4,10)
    PlatPart.Material=Enum.Material.Neon; PlatPart.Color=C.Purple
    PlatPart.Anchored=true; PlatPart.CanCollide=true
    PlatPart.CFrame=CFrame.new(hrp.Position-Vector3.new(0,3.5,0))
    PlatPart.Parent=workspace
end
local function removePlatform()
    if PlatPart then PlatPart:Destroy(); PlatPart=nil end
end

-- ── POPULATE TABS ─────────────────────────────────────────────

-- HAREKET
Section("HAREKET", "HAREKET")
Toggle("Fly (Ucus)", "Fly", "HAREKET", nil,
    function()
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        hum.PlatformStand = true
        BodyGyro = Instance.new("BodyGyro", hrp)
        BodyGyro.P=9e4; BodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
        BodyVelocity = Instance.new("BodyVelocity", hrp)
        BodyVelocity.MaxForce=Vector3.new(9e9,9e9,9e9)
        Toast("Fly ACIK - Hareket et + E/Q(yukari/asagi)", C.Accent)
    end,
    function()
        if BodyGyro then BodyGyro:Destroy(); BodyGyro=nil end
        if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity=nil end
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand=false end
    end
)
Adjuster("Fly/Yurume Hizi", "SpeedVal", 10, 300, 30, "HAREKET")
Section("", "HAREKET")
Toggle("Speed Hack", "Speed", "HAREKET", nil,
    function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=State.SpeedVal end
    end,
    function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=16 end
    end
)
Toggle("Jump Boost",  "Jump",    "HAREKET", nil,
    function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower=true; hum.JumpPower=State.JumpVal end
    end,
    function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.UseJumpPower=true; hum.JumpPower=50 end
    end
)
Adjuster("Zipla Gucu", "JumpVal", 50, 500, 80, "HAREKET")
Toggle("Sonsuz Zipla", "InfJump",  "HAREKET", C.Gold)
Toggle("NoClip",       "NoClip",   "HAREKET", C.Gold)
Toggle("BunnyHop",     "BHop",     "HAREKET", C.Gold)
Toggle("Auto Yurume",  "AutoWalk", "HAREKET")
Toggle("Anti Void",    "AntiVoid", "HAREKET")
Section("", "HAREKET")
Action("Spawn'a Isinla", "HAREKET", Color3.fromRGB(0,45,90), function()
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local sp=workspace:FindFirstChild("SpawnLocation")
    if hrp then hrp.CFrame=(sp and sp.CFrame or CFrame.new(0,10,0))+Vector3.new(0,5,0) end
    Toast("Spawn'a isinlandin!", C.Accent)
end)
Action("Rastgele Oyuncuya Isin", "HAREKET", Color3.fromRGB(45,18,70), function()
    local tgts={}
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(tgts,p)
        end
    end
    if #tgts==0 then Toast("Hedef bulunamadi!",C.Red); return end
    local t=tgts[math.random(1,#tgts)]
    local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame=t.Character.HumanoidRootPart.CFrame+Vector3.new(0,4,0) end
    Toast(t.Name.." yanina isinlandin!",C.Purple)
end)
Action("Click Teleport AC/KAPAT", "HAREKET", C.PurDim, function()
    State.ClickTP = not State.ClickTP
    Toast("Click TP: "..(State.ClickTP and "ACIK" or "KAPALI"), C.Purple)
end)

-- GORSEL
Section("GORSEL", "GORSEL")
Toggle("ESP (Isim+HP+Mesafe)", "ESP", "GORSEL", nil,
    function() Toast("ESP ACIK",C.Accent) end,
    function() clearESP() end
)
Toggle("Fullbright", "FullBrt", "GORSEL", C.Gold,
    function()
        origAmb=Lighting.Ambient; origFog=Lighting.FogEnd; origBrt=Lighting.Brightness
        Lighting.Ambient=Color3.new(1,1,1); Lighting.FogEnd=1e6; Lighting.Brightness=2.2
    end,
    function()
        Lighting.Ambient=origAmb; Lighting.FogEnd=origFog; Lighting.Brightness=origBrt
    end
)
Toggle("Gece Modu", "NightM", "GORSEL", C.Purple,
    function()
        Lighting.ClockTime=0; Lighting.FogEnd=200
        Lighting.FogColor=Color3.fromRGB(4,4,16)
        Lighting.Ambient=Color3.fromRGB(20,20,48)
    end,
    function()
        Lighting.ClockTime=14; Lighting.FogEnd=100000
        Lighting.Ambient=Color3.fromRGB(127,127,127)
    end
)
Section("", "GORSEL")
Action("FOV 110 (Max)", "GORSEL", C.AccDim, function() Camera.FieldOfView=110; Toast("FOV 110",C.Accent) end)
Action("FOV 70 (Normal)", "GORSEL", Color3.fromRGB(22,32,55), function() Camera.FieldOfView=70 end)

-- COMBAT
Section("COMBAT", "COMBAT")
Toggle("God Mode", "GodMode", "COMBAT", C.Gold,
    function() Toast("God Mode ACIK",C.Green) end,
    function()
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.MaxHealth=100; hum.Health=100 end
    end
)
Toggle("Aimbot",  "AimBot", "COMBAT", C.Orange)
Adjuster("Aim Menzili", "AimRange", 10, 200, 60, "COMBAT")
Section("", "COMBAT")
Toggle("Hitbox Genislet", "Hitbox", "COMBAT", C.Orange,
    function() Toast("Hitbox ACIK - Vurmasi kolay!",C.Orange) end,
    function()
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                for _,p in ipairs(plr.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p:GetAttribute("OrigSz") then
                        p.Size=p:GetAttribute("OrigSz"); p:SetAttribute("OrigSz",nil)
                        p.Transparency=p:GetAttribute("OrigTr") or 0
                    end
                end
            end
        end
    end
)
Adjuster("Hitbox Boyutu", "HitboxSz", 2, 28, 8, "COMBAT")
Section("", "COMBAT")
Action("Tam Can", "COMBAT", Color3.fromRGB(12,62,28), function()
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health=hum.MaxHealth end
    Toast("Tam can!",C.Green)
end)

-- UTIL
Section("UTIL", "UTIL")
Toggle("Anti-AFK", "AntiAFK", "UTIL", C.Green,
    function() Toast("Anti-AFK ACIK",C.Green) end, nil
)
Toggle("Karakter Dondur", "FreezeChar", "UTIL", C.Red,
    function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored=true end
    end,
    function()
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored=false end
    end
)
Section("", "UTIL")
Action("Oyun Bilgisi", "UTIL", C.AccDim, function()
    local ping=math.floor(LP:GetNetworkPing()*1000)
    Toast(#Players:GetPlayers().." oyuncu | "..ping.."ms | Place:"..game.PlaceId, C.Accent, 5)
end)
Action("PlaceId Kopyala", "UTIL", Color3.fromRGB(18,42,62), function()
    pcall(function() setclipboard(tostring(game.PlaceId)) end)
    Toast("PlaceId: "..tostring(game.PlaceId), C.Accent, 4)
end)
Action("Sunucu Degistir", "UTIL", Color3.fromRGB(28,42,72), function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)
Action("GUI Kaldir", "UTIL", C.RedDim, function()
    ScreenGui:Destroy()
end)

-- FUN
Section("FUN", "FUN")
Toggle("Spin", "SpinOn", "FUN", C.Purple,
    function()
        spinConn=RunService.Heartbeat:Connect(function()
            local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame=hrp.CFrame*CFrame.Angles(0,math.rad(State.SpinSpd),0) end
        end)
        Toast("Spin ACIK",C.Purple)
    end,
    function()
        if spinConn then spinConn:Disconnect(); spinConn=nil end
    end
)
Adjuster("Spin Hizi", "SpinSpd", 1, 30, 8, "FUN")
Toggle("Platform (Ayak Alti)", "Platform", "FUN", C.Purple,
    function() createPlatform(); Toast("Platform ACIK",C.Purple) end,
    function() removePlatform() end
)
Section("", "FUN")
Action("Karakter Buyut", "FUN", C.PurDim, function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Size=p.Size*1.5 end
    end; Toast("Buyutuldu!",C.Purple)
end)
Action("Karakter Kucult", "FUN", Color3.fromRGB(18,44,52), function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Size=p.Size*0.65 end
    end; Toast("Kucultuldu!",C.Accent)
end)
Action("Neon Karakter", "FUN", Color3.fromRGB(26,34,62), function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Material=Enum.Material.Neon end
    end; Toast("Neon!",C.Gold)
end)
Action("Renk Degistir", "FUN", Color3.fromRGB(42,16,58), function()
    local c=LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then p.Color=Color3.fromHSV(math.random(),0.85,1) end
    end; Toast("Renkler degisti!",C.Purple)
end)
Action("Karakteri Sifirla", "FUN", C.RedDim, function()
    local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health=0 end
end)

-- Başlangıçta HAREKET sekmesini göster
switchTab("HAREKET")

-- ── RUNTIME ──────────────────────────────────────────────────
RunService.RenderStepped:Connect(function()
    local char = LP.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")

    -- FLY
    if State.Fly and hrp and hum then
        if BodyGyro then BodyGyro.CFrame = Camera.CFrame end
        if BodyVelocity then
            local spd = math.max(State.SpeedVal, 30)
            local mv  = hum.MoveDirection
            if mv.Magnitude > 0.1 then
                BodyVelocity.Velocity = Camera.CFrame.LookVector * spd
            else
                BodyVelocity.Velocity = Vector3.new(0, 0.05, 0)
            end
            -- PC E/Q = up/down
            if UserInputService:IsKeyDown(Enum.KeyCode.E) or
               UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                BodyVelocity.Velocity = Vector3.new(0, spd, 0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.Q) or
                   UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                BodyVelocity.Velocity = Vector3.new(0, -spd, 0)
            end
        end
        hum.PlatformStand = true
    elseif not State.Fly then
        if BodyGyro then BodyGyro:Destroy(); BodyGyro=nil end
        if BodyVelocity then BodyVelocity:Destroy(); BodyVelocity=nil end
        if hum and not State.FreezeChar then hum.PlatformStand=false end
    end

    -- SPEED
    if State.Speed and hum then hum.WalkSpeed = State.SpeedVal end
    -- JUMP
    if State.Jump  and hum then hum.UseJumpPower=true; hum.JumpPower=State.JumpVal end
    -- GOD
    if State.GodMode and hum then hum.Health = hum.MaxHealth end
    -- NOCLIP
    if State.NoClip and char then
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end
    end
    -- BHOP
    if State.BHop and hum then
        if hum:GetState()==Enum.HumanoidStateType.Landed then hum.Jump=true end
    end
    -- AUTO WALK
    if State.AutoWalk and hum then hum:Move(Vector3.new(0,0,-1),true) end
    -- ANTI VOID
    if State.AntiVoid and hrp then
        if hrp.Position.Y < -80 then
            hrp.CFrame = CFrame.new(hrp.Position.X,20,hrp.Position.Z)
        end
    end
    -- FREEZE
    if State.FreezeChar and hrp then hrp.Anchored=true
    elseif hrp and not State.FreezeChar and not State.Fly then hrp.Anchored=false end
    -- AIMBOT
    if State.AimBot and hrp then
        local best, bd = nil, State.AimRange
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                local tgt=plr.Character:FindFirstChild("Head") or
                          plr.Character:FindFirstChild("HumanoidRootPart")
                if tgt then
                    local d=(tgt.Position-hrp.Position).Magnitude
                    if d<bd then bd=d; best=tgt end
                end
            end
        end
        if best then Camera.CFrame=CFrame.new(Camera.CFrame.Position,best.Position) end
    end
    -- HITBOX
    if State.Hitbox then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LP and plr.Character then
                local root=plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    if not root:GetAttribute("OrigSz") then
                        root:SetAttribute("OrigSz",root.Size)
                        root:SetAttribute("OrigTr",root.Transparency)
                    end
                    root.Size=Vector3.new(State.HitboxSz,State.HitboxSz,State.HitboxSz)
                    root.Transparency=0.85
                end
            end
        end
    end
    -- PLATFORM follow
    if State.Platform and PlatPart and hrp then
        local tgt = hrp.Position - Vector3.new(0,3.5,0)
        PlatPart.CFrame = CFrame.new(PlatPart.Position:Lerp(tgt,0.3))
    end
end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local hum=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- CLICK TP
Mouse.Button1Down:Connect(function()
    if State.ClickTP then
        local hrp=LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp and Mouse.Hit then
            hrp.CFrame=CFrame.new(Mouse.Hit.Position+Vector3.new(0,4,0))
        end
    end
end)

-- ANTI AFK
LP.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:Button2Down(Vector2.zero,Camera.CFrame)
        task.wait(0.1)
        VirtualUser:Button2Up(Vector2.zero,Camera.CFrame)
    end
end)

-- ESP
RunService.RenderStepped:Connect(updateESP)

-- Spawn sonrası
LP.CharacterAdded:Connect(function(char)
    task.wait(1.5)
    local hum=char:FindFirstChildOfClass("Humanoid")
    if hum then
        if State.Speed then hum.WalkSpeed=State.SpeedVal end
        if State.Jump  then hum.UseJumpPower=true; hum.JumpPower=State.JumpVal end
    end
    if State.Fly then task.wait(0.5)
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then
            BodyGyro=Instance.new("BodyGyro",hrp); BodyGyro.P=9e4; BodyGyro.MaxTorque=Vector3.new(9e9,9e9,9e9)
            BodyVelocity=Instance.new("BodyVelocity",hrp); BodyVelocity.MaxForce=Vector3.new(9e9,9e9,9e9)
            hum.PlatformStand=true
        end
    end
end)

-- ── MENU OPEN/CLOSE ───────────────────────────────────────────
local menuOpen = false
local function ToggleMenu()
    menuOpen = not menuOpen
    if menuOpen then
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, PW, 0, 0)
        Tween(MainFrame, {Size=UDim2.new(0,PW,0,PH)}, 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    else
        Tween(MainFrame, {Size=UDim2.new(0,PW,0,0)}, 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.18, function() MainFrame.Visible=false end)
    end
end

ToggleBtn.MouseButton1Click:Connect(ToggleMenu)
CloseBtn.MouseButton1Click:Connect(function()
    menuOpen=true; ToggleMenu()
end)
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn,{BackgroundColor3=C.Red,TextColor3=C.White},0.12) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn,{BackgroundColor3=C.RedDim,TextColor3=C.Red},0.12) end)

UserInputService.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode==Enum.KeyCode.RightShift then ToggleMenu() end
    if inp.KeyCode==Enum.KeyCode.F then
        State.Fly=not State.Fly
        Toast("Fly: "..(State.Fly and "ACIK" or "KAPALI"), C.Accent)
    end
    if inp.KeyCode==Enum.KeyCode.G then
        State.GodMode=not State.GodMode
        Toast("God: "..(State.GodMode and "ACIK" or "KAPALI"), C.Green)
    end
    if inp.KeyCode==Enum.KeyCode.H then
        State.ESP=not State.ESP
        if not State.ESP then clearESP() end
        Toast("ESP: "..(State.ESP and "ACIK" or "KAPALI"), C.Accent)
    end
    if inp.KeyCode==Enum.KeyCode.K then
        State.NoClip=not State.NoClip
        Toast("NoClip: "..(State.NoClip and "ACIK" or "KAPALI"), C.Gold)
    end
end)

-- BASLANGIC
task.delay(0.5, function()
    Toast("Delta Pro v4 Yuklendi  •  RightShift = Menu", C.Panel, 3.5)
end)
print("[Delta Pro v4] Yuklendi — CoreGui — "..(IsMobile and "Mobil" or "PC"))
