--[[
    KamuHub v2.0 - Universal Hub
    Abrir/fechar: LeftShift (PC) ou botao "-" / pilula (celular)
]]

if getgenv and getgenv().KamuHubDestroy then pcall(getgenv().KamuHubDestroy) end

------------------------------------------------------------------
-- CONFIG DO DONO
------------------------------------------------------------------
local CFG = {
    Premium = {
        -- [123456789] = true,   -- UserIds
    },
    PremiumNames = {
        ["daviizzinn15"] = true, -- nomes de usuario em minusculo
    },
    LogoAsset = "", -- ex: "rbxassetid://123456"
    LogoURL = "https://cdn.discordapp.com/attachments/1571550185547505774/1571589803089338550/1000048381.jpg?ex=6afb488f&is=6af9f70f&hm=e4a7921196678030bfcbfade5a9af544ff51a901f34016a7e5c992d0daa97e64&",
}

------------------------------------------------------------------
-- SERVICOS
------------------------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local TS = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local PPS = game:GetService("ProximityPromptService")
local lp = Players.LocalPlayer

------------------------------------------------------------------
-- TEMA / ESTADO
------------------------------------------------------------------
local WHITE = Color3.new(1, 1, 1)
local function lighten(c, a) return c:Lerp(WHITE, a) end

local theme = {
    Accent = Color3.fromRGB(150, 90, 255),
    Accent2 = lighten(Color3.fromRGB(150, 90, 255), 0.4),
    Side = Color3.fromRGB(20, 20, 30),
    Card = Color3.fromRGB(30, 30, 44),
    CardHover = Color3.fromRGB(40, 40, 58),
    Off = Color3.fromRGB(58, 58, 78),
    Text = Color3.fromRGB(242, 242, 252),
    Sub = Color3.fromRGB(145, 145, 170),
    Gold = Color3.fromRGB(255, 200, 60),
}

local S = {
    fly = false, flySpeed = 60, noclip = false, infJump = false,
    speedOn = false, speed = 32, jumpOn = false, jump = 90,
    spin = false, spinSpeed = 12, esp = false, clickTp = false, fullbright = false,
    antiafk = true, autoclick = false, cps = 10, instPrompt = false,
    farm = false, weapon = "Melee", farmH = 8, doorsHl = false,
}

local lang = "pt"
local isPremium = (CFG.Premium[lp.UserId] == true) or (CFG.PremiumNames[lp.Name:lower()] == true)

local L = {
    pt = {
        tab_main = "Main", tab_player = "Player", tab_tp = "Teleport", tab_visual = "Visual", tab_config = "Config",
        sec_move = "Movimento", sec_misc = "Diversos", sec_bf = "Blox Fruits", sec_char = "Personagem",
        sec_players = "Jogadores", sec_tools = "Ferramentas", sec_view = "Visao", sec_doors = "Doors",
        sec_look = "Aparencia", sec_general = "Geral",
        fly = "Fly (voar)", flyspeed = "Velocidade do Fly", noclip = "Noclip", infjump = "Pulo infinito",
        speedon = "Ativar velocidade", speedval = "Velocidade", jumpon = "Ativar pulo alto", jumpval = "Forca do pulo",
        spin = "Spin (girar)", spinspeed = "Velocidade do spin", antiafk = "Anti-AFK",
        instprompt = "Interacao instantanea", autoclick = "Auto Click", cps = "Cliques por segundo",
        refresh = "Atualizar lista", rejoin = "Reentrar no servidor", serverhop = "Trocar de servidor",
        esp = "ESP de jogadores", clicktp = "Click TP (Ctrl + clique)", fullbright = "Fullbright",
        fps = "Boost de FPS", language = "Idioma", accent = "Cor do painel", bgtrans = "Transparencia do fundo",
        togglekey = "Tecla abrir/fechar", pressakey = "Aperte uma tecla...", destroy = "Fechar KamuHub",
        yourid = "Seu UserId: ", game_detected = "Jogo detectado: ",
        farm = "Auto Farm (mob mais proximo)", weapon = "Arma", farmh = "Altura do farm",
        doorshl = "Destacar itens/interacoes", mm2info = "Murder Mystery 2: ESP mostra assassino (vermelho) e xerife (azul).",
        loaded = "KamuHub carregado!", needprem = "Recurso exclusivo Premium!",
        premium_user = "Usuario Premium", free_user = "Conta Free", tpdone = "Teleportado para ",
    },
    en = {
        tab_main = "Main", tab_player = "Player", tab_tp = "Teleport", tab_visual = "Visual", tab_config = "Config",
        sec_move = "Movement", sec_misc = "Misc", sec_bf = "Blox Fruits", sec_char = "Character",
        sec_players = "Players", sec_tools = "Tools", sec_view = "View", sec_doors = "Doors",
        sec_look = "Appearance", sec_general = "General",
        fly = "Fly", flyspeed = "Fly speed", noclip = "Noclip", infjump = "Infinite jump",
        speedon = "Enable speed", speedval = "Speed", jumpon = "Enable high jump", jumpval = "Jump power",
        spin = "Spin", spinspeed = "Spin speed", antiafk = "Anti-AFK",
        instprompt = "Instant interact", autoclick = "Auto Click", cps = "Clicks per second",
        refresh = "Refresh list", rejoin = "Rejoin server", serverhop = "Server hop",
        esp = "Player ESP", clicktp = "Click TP (Ctrl + click)", fullbright = "Fullbright",
        fps = "FPS boost", language = "Language", accent = "Panel color", bgtrans = "Background transparency",
        togglekey = "Toggle key", pressakey = "Press a key...", destroy = "Close KamuHub",
        yourid = "Your UserId: ", game_detected = "Game detected: ",
        farm = "Auto Farm (nearest mob)", weapon = "Weapon", farmh = "Farm height",
        doorshl = "Highlight items/interactions", mm2info = "Murder Mystery 2: ESP shows murderer (red) and sheriff (blue).",
        loaded = "KamuHub loaded!", needprem = "Premium-only feature!",
        premium_user = "Premium user", free_user = "Free account", tpdone = "Teleported to ",
    },
}
local function tr(k) return (L[lang] and L[lang][k]) or L.en[k] or k end

local conns = {}
local function bind(sig, fn) local c = sig:Connect(fn); conns[#conns + 1] = c; return c end
local accentFns, langFns = {}, {}
local function onAccent(fn) accentFns[#accentFns + 1] = fn; fn() end
local function onLang(fn) langFns[#langFns + 1] = fn; fn() end
local function setAccent(c)
    theme.Accent = c
    theme.Accent2 = lighten(c, 0.4)
    for _, fn in ipairs(accentFns) do pcall(fn) end
end

local function hum() local c = lp.Character return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c = lp.Character return c and c:FindFirstChild("HumanoidRootPart") end

local function tw(o, t, p, style, dir)
    local tn = TS:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), p)
    tn:Play()
    return tn
end

------------------------------------------------------------------
-- GUI BASE
------------------------------------------------------------------
local gui = Instance.new("ScreenGui")
gui.Name = "KamuHub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
local okParent = pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okParent or not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function corner(o, r) return new("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function accentSeq() return ColorSequence.new(theme.Accent, theme.Accent2) end

-- logo (baixa uma vez e aplica em todos)
local logoImage, logoTargets = nil, {}
local function applyLogo(img)
    logoTargets[#logoTargets + 1] = img
    if logoImage then img.Image = logoImage end
end
task.spawn(function()
    if CFG.LogoAsset ~= "" then
        logoImage = CFG.LogoAsset
    elseif CFG.LogoURL ~= "" and writefile and getcustomasset then
        pcall(function()
            writefile("kamuhub_logo.png", game:HttpGet(CFG.LogoURL))
            logoImage = getcustomasset("kamuhub_logo.png")
        end)
    end
    if logoImage then for _, i in ipairs(logoTargets) do i.Image = logoImage end end
end)

local function makeLogo(parent, size, pos)
    local circle = new("Frame", { Size = UDim2.fromOffset(size, size), Position = pos, BorderSizePixel = 0 }, parent)
    corner(circle, size)
    local grad = new("UIGradient", { Rotation = 45 }, circle)
    circle.BackgroundColor3 = WHITE
    onAccent(function() grad.Color = accentSeq() end)
    new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "K", Font = Enum.Font.GothamBlack,
        TextSize = size * 0.5, TextColor3 = WHITE,
    }, circle)
    local img = new("ImageLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Crop }, circle)
    corner(img, size)
    applyLogo(img)
    local st = new("UIStroke", { Thickness = 2, Transparency = 0.2 }, circle)
    onAccent(function() st.Color = theme.Accent2 end)
    return circle
end

local function makeBadge(parent)
    local b = new("Frame", { AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, parent)
    corner(b, 9)
    local g = new("UIGradient", { Rotation = 20 }, b)
    new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, b)
    if isPremium then
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 185, 40)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 245, 190)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 185, 40)),
        })
        g.Offset = Vector2.new(-1, 0)
        TS:Create(g, TweenInfo.new(1.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false, 1), { Offset = Vector2.new(1, 0) }):Play()
    else
        g.Color = ColorSequence.new(Color3.fromRGB(90, 90, 110), Color3.fromRGB(70, 70, 90))
    end
    new("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 18), BackgroundTransparency = 1,
        Text = isPremium and "PREMIUM" or "FREE", Font = Enum.Font.GothamBold, TextSize = 10,
        TextColor3 = isPremium and Color3.fromRGB(45, 30, 0) or Color3.fromRGB(225, 225, 235),
    }, b)
    return b
end

local function makeTitle(parent, pos, size, textSize)
    local box = new("Frame", { Size = size, Position = pos, BackgroundTransparency = 1 }, parent)
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder,
    }, box)
    local t = new("TextLabel", {
        AutomaticSize = Enum.AutomaticSize.X, Size = UDim2.fromOffset(0, 26), BackgroundTransparency = 1,
        Text = "KamuHub", Font = Enum.Font.GothamBlack, TextSize = textSize, TextColor3 = WHITE, LayoutOrder = 1,
    }, box)
    local g = new("UIGradient", {}, t)
    onAccent(function() g.Color = accentSeq() end)
    local b = makeBadge(box)
    b.LayoutOrder = 2
    return box
end

------------------------------------------------------------------
-- NOTIFICACOES
------------------------------------------------------------------
local toastHolder = new("Frame", {
    Size = UDim2.fromOffset(270, 300), AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, -14, 1, -14), BackgroundTransparency = 1,
}, gui)
new("UIListLayout", {
    VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right,
    Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder,
}, toastHolder)

local function notify(msg)
    local f = new("Frame", { Size = UDim2.fromOffset(260, 42), BackgroundColor3 = theme.Side, BackgroundTransparency = 1, BorderSizePixel = 0 }, toastHolder)
    corner(f, 10)
    local bar = new("Frame", { Size = UDim2.new(0, 4, 1, -14), Position = UDim2.fromOffset(8, 7), BackgroundColor3 = theme.Accent, BackgroundTransparency = 1, BorderSizePixel = 0 }, f)
    corner(bar, 2)
    local t = new("TextLabel", {
        Size = UDim2.new(1, -30, 1, 0), Position = UDim2.fromOffset(22, 0), BackgroundTransparency = 1, Text = msg,
        TextColor3 = theme.Text, TextTransparency = 1, Font = Enum.Font.GothamMedium, TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true,
    }, f)
    local st = new("UIStroke", { Color = theme.Accent, Thickness = 1, Transparency = 1 }, f)
    tw(f, 0.25, { BackgroundTransparency = 0.05 }); tw(bar, 0.25, { BackgroundTransparency = 0 })
    tw(t, 0.25, { TextTransparency = 0 }); tw(st, 0.25, { Transparency = 0.5 })
    task.delay(2.6, function()
        tw(f, 0.3, { BackgroundTransparency = 1 }); tw(bar, 0.3, { BackgroundTransparency = 1 })
        tw(t, 0.3, { TextTransparency = 1 }); tw(st, 0.3, { Transparency = 1 })
        task.delay(0.35, function() f:Destroy() end)
    end)
end

------------------------------------------------------------------
-- JANELA
------------------------------------------------------------------
local BASE_W, BASE_H = 640, 410
local cam0 = workspace.CurrentCamera
local vp = cam0 and cam0.ViewportSize or Vector2.new(1280, 720)
local baseScale = math.clamp(math.min(vp.X / (BASE_W + 40), vp.Y / (BASE_H + 40)), 0.5, 1)

local rootF = new("Frame", {
    Name = "Root", Size = UDim2.fromOffset(BASE_W, BASE_H), AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5), BackgroundTransparency = 1,
}, gui)
local uiscale = new("UIScale", { Scale = baseScale * 0.8 }, rootF)

local shadow = new("ImageLabel", {
    BackgroundTransparency = 1, Image = "rbxassetid://6014261993", ImageColor3 = Color3.new(0, 0, 0),
    ImageTransparency = 0.4, ScaleType = Enum.ScaleType.Slice, SliceCenter = Rect.new(49, 49, 450, 450),
    Size = UDim2.new(1, 60, 1, 60), Position = UDim2.fromOffset(-30, -22), ZIndex = 0,
}, rootF)

local win = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 1 }, rootF)
corner(win, 16)
new("UIGradient", { Rotation = 60, Color = ColorSequence.new(Color3.fromRGB(28, 22, 44), Color3.fromRGB(12, 12, 19)) }, win)
local winStroke = new("UIStroke", { Thickness = 1.6, Transparency = 0.25 }, win)
local winStrokeGrad = new("UIGradient", { Rotation = 45 }, winStroke)
onAccent(function() winStrokeGrad.Color = accentSeq() end)

local glow1 = new("Frame", { Size = UDim2.fromOffset(320, 320), Position = UDim2.new(1, -170, 0, -180), BackgroundTransparency = 0.88, BorderSizePixel = 0 }, win)
corner(glow1, 160)
local glow2 = new("Frame", { Size = UDim2.fromOffset(260, 260), Position = UDim2.new(0, -120, 1, -110), BackgroundTransparency = 0.92, BorderSizePixel = 0 }, win)
corner(glow2, 130)
onAccent(function() glow1.BackgroundColor3 = theme.Accent; glow2.BackgroundColor3 = theme.Accent end)

-- header
local header = new("Frame", { Size = UDim2.new(1, 0, 0, 52), BackgroundTransparency = 1, ZIndex = 2 }, win)
makeLogo(header, 36, UDim2.fromOffset(14, 8))
makeTitle(header, UDim2.fromOffset(60, 0), UDim2.fromOffset(300, 52), 20)
new("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 0.92, BorderSizePixel = 0 }, header)

local function headerBtn(text, xOff, hoverColor)
    local b = new("TextButton", {
        Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, xOff, 0, 11), BackgroundColor3 = theme.Card,
        Text = text, TextColor3 = theme.Text, Font = Enum.Font.GothamBold, TextSize = 18, AutoButtonColor = false, BorderSizePixel = 0,
    }, header)
    corner(b, 9)
    b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = hoverColor or theme.CardHover }) end)
    b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = theme.Card }) end)
    return b
end
local minBtn = headerBtn("-", -78)
local closeBtn = headerBtn("x", -42, Color3.fromRGB(220, 60, 80))

-- arrastar
do
    local dragging, startPos, startIn
    header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startPos, startIn = true, rootF.Position, i.Position
        end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = (i.Position - startIn) / uiscale.Scale
            rootF.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    bind(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- sidebar
local side = new("Frame", { Size = UDim2.new(0, 150, 1, -52), Position = UDim2.fromOffset(0, 52), BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.78, BorderSizePixel = 0, ZIndex = 2 }, win)
new("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 0.92, BorderSizePixel = 0 }, side)

local TAB_Y0, TAB_STEP, TAB_H = 12, 42, 36
local selector = new("Frame", {
    Size = UDim2.new(1, -16, 0, TAB_H), Position = UDim2.fromOffset(8, TAB_Y0), BackgroundTransparency = 0.82, BorderSizePixel = 0,
}, side)
corner(selector, 10)
local selStroke = new("UIStroke", { Thickness = 1, Transparency = 0.55 }, selector)
local selBar = new("Frame", { Size = UDim2.fromOffset(3, 18), Position = UDim2.new(0, 0, 0.5, -9), BorderSizePixel = 0 }, selector)
corner(selBar, 2)
onAccent(function() selector.BackgroundColor3 = theme.Accent; selStroke.Color = theme.Accent; selBar.BackgroundColor3 = theme.Accent2 end)

-- rodape do usuario
local foot = new("Frame", {
    Size = UDim2.new(1, -16, 0, 56), AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 8, 1, -8),
    BackgroundColor3 = theme.Card, BorderSizePixel = 0,
}, side)
corner(foot, 12)
local avatar = new("ImageLabel", { Size = UDim2.fromOffset(38, 38), Position = UDim2.fromOffset(9, 9), BackgroundColor3 = theme.Off, BorderSizePixel = 0 }, foot)
corner(avatar, 19)
task.spawn(function()
    pcall(function()
        avatar.Image = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
end)
new("TextLabel", {
    Size = UDim2.new(1, -56, 0, 18), Position = UDim2.fromOffset(52, 10), BackgroundTransparency = 1, Text = lp.DisplayName,
    Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
}, foot)
local statusLbl = new("TextLabel", {
    Size = UDim2.new(1, -56, 0, 16), Position = UDim2.fromOffset(52, 28), BackgroundTransparency = 1,
    Font = Enum.Font.Gotham, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
}, foot)
onLang(function() statusLbl.Text = isPremium and tr("premium_user") or tr("free_user") end)
onAccent(function() statusLbl.TextColor3 = isPremium and theme.Gold or theme.Sub end)

-- conteudo
local content = new("Frame", { Size = UDim2.new(1, -150, 1, -52), Position = UDim2.fromOffset(150, 52), BackgroundTransparency = 1, ZIndex = 2 }, win)
local titleLbl = new("TextLabel", {
    Size = UDim2.fromOffset(320, 30), Position = UDim2.fromOffset(18, 8), BackgroundTransparency = 1,
    Font = Enum.Font.GothamBlack, TextSize = 20, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
}, content)

------------------------------------------------------------------
-- ABAS
------------------------------------------------------------------
local tabs, currentTab = {}, nil

local function selectTab(t, instant)
    if currentTab == t and not instant then return end
    currentTab = t
    for _, x in ipairs(tabs) do
        local on = (x == t)
        tw(x.lbl, 0.2, { TextColor3 = on and theme.Text or theme.Sub })
        if on then
            x.page.Visible = true
            if not instant then
                x.page.Position = UDim2.fromOffset(10, 62)
                tw(x.page, 0.35, { Position = UDim2.fromOffset(10, 44) })
            end
        else
            x.page.Visible = false
        end
    end
    tw(selector, instant and 0 or 0.35, { Position = UDim2.fromOffset(8, TAB_Y0 + (t.index - 1) * TAB_STEP) }, Enum.EasingStyle.Back)
    titleLbl.Text = tr(t.key)
    if not instant then titleLbl.TextTransparency = 1; tw(titleLbl, 0.3, { TextTransparency = 0 }) end
end
onLang(function() if currentTab then titleLbl.Text = tr(currentTab.key) end end)

local function addTab(key)
    local index = #tabs + 1
    local btn = new("TextButton", {
        Size = UDim2.new(1, -16, 0, TAB_H), Position = UDim2.fromOffset(8, TAB_Y0 + (index - 1) * TAB_STEP),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 3,
    }, side)
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3,
    }, btn)
    onLang(function() lbl.Text = tr(key) end)
    local page = new("ScrollingFrame", {
        Size = UDim2.new(1, -20, 1, -54), Position = UDim2.fromOffset(10, 44), BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
    }, content)
    new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)
    new("UIPadding", { PaddingBottom = UDim.new(0, 8) }, page)
    onAccent(function() page.ScrollBarImageColor3 = theme.Accent end)
    local t = { key = key, index = index, btn = btn, lbl = lbl, page = page }
    tabs[index] = t
    btn.MouseButton1Click:Connect(function() selectTab(t) end)
    btn.MouseEnter:Connect(function() if currentTab ~= t then tw(lbl, 0.15, { TextColor3 = theme.Text }) end end)
    btn.MouseLeave:Connect(function() if currentTab ~= t then tw(lbl, 0.15, { TextColor3 = theme.Sub }) end end)
    return page
end

------------------------------------------------------------------
-- COMPONENTES
------------------------------------------------------------------
local function ripple(c, x)
    local sc = uiscale.Scale
    local rx = (x - c.AbsolutePosition.X) / sc
    local r = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, rx, 0.5, 0), Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = WHITE, BackgroundTransparency = 0.8, BorderSizePixel = 0, ZIndex = 2,
    }, c)
    corner(r, 999)
    local s = math.max(c.AbsoluteSize.X / sc * 1.6, 60)
    tw(r, 0.55, { Size = UDim2.fromOffset(s, s), BackgroundTransparency = 1 })
    task.delay(0.6, function() r:Destroy() end)
end

local function shake(c)
    task.spawn(function()
        local p = c.Position
        for _, dx in ipairs({ 8, -8, 5, -5, 0 }) do
            tw(c, 0.05, { Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset) })
            task.wait(0.05)
        end
    end)
end

local function card(page, h)
    local holder = new("Frame", { Size = UDim2.new(1, -8, 0, h or 44), BackgroundTransparency = 1 }, page)
    local c = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = theme.Card, BorderSizePixel = 0, ClipsDescendants = true }, holder)
    corner(c, 12)
    new("UIStroke", { Color = WHITE, Transparency = 0.93, Thickness = 1 }, c)
    local sc = new("UIScale", {}, c)
    return c, sc
end

local function isPress(i) return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch end

local function interact(c, sc, onClick, noHover)
    local b = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 10, AutoButtonColor = false }, c)
    b.MouseEnter:Connect(function() if not noHover then tw(c, 0.15, { BackgroundColor3 = theme.CardHover }) end end)
    b.MouseLeave:Connect(function()
        if not noHover then tw(c, 0.15, { BackgroundColor3 = theme.Card }) end
        tw(sc, 0.15, { Scale = 1 })
    end)
    b.InputBegan:Connect(function(i) if isPress(i) then tw(sc, 0.1, { Scale = 0.97 }); ripple(c, i.Position.X) end end)
    b.InputEnded:Connect(function(i) if isPress(i) then tw(sc, 0.25, { Scale = 1 }, Enum.EasingStyle.Back) end end)
    b.MouseButton1Click:Connect(onClick)
    return b
end

local function cardLabel(c, key, widthOff, h)
    local l = new("TextLabel", {
        Size = UDim2.new(1, widthOff or -80, 0, h or 44), Position = UDim2.fromOffset(16, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
    }, c)
    onLang(function() l.Text = tr(key) end)
    return l
end

local function premTag(c, xRight)
    local t = new("TextLabel", {
        Size = UDim2.fromOffset(58, 16), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, xRight, 0.5, 0),
        BackgroundColor3 = WHITE, Text = "PREMIUM", Font = Enum.Font.GothamBold, TextSize = 9,
        TextColor3 = Color3.fromRGB(45, 30, 0), BorderSizePixel = 0,
    }, c)
    corner(t, 8)
    new("UIGradient", { Color = ColorSequence.new(Color3.fromRGB(255, 190, 45), Color3.fromRGB(255, 232, 150)), Rotation = 20 }, t)
end

local function Section(page, key)
    local f = new("Frame", { Size = UDim2.new(1, -8, 0, 22), BackgroundTransparency = 1 }, page)
    local l = new("TextLabel", {
        Size = UDim2.fromScale(1, 1), Position = UDim2.fromOffset(4, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
    }, f)
    onLang(function() l.Text = string.upper(tr(key)) end)
    onAccent(function() l.TextColor3 = theme.Accent2 end)
end

local function Info(page, textFn, h)
    local c = card(page, h or 40)
    local l = new("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0), Position = UDim2.fromOffset(14, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
    }, c)
    onLang(function() l.Text = textFn() end)
    onAccent(function() l.TextColor3 = theme.Accent2 end)
end

local function Toggle(page, key, default, cb, prem)
    local c, sc = card(page, 44)
    cardLabel(c, key, prem and -170 or -80)
    local track = new("Frame", { Size = UDim2.fromOffset(44, 22), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), BackgroundColor3 = theme.Off, BorderSizePixel = 0 }, c)
    corner(track, 11)
    local knob = new("Frame", { Size = UDim2.fromOffset(18, 18), Position = UDim2.fromOffset(2, 2), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, track)
    corner(knob, 9)
    if prem then premTag(c, -70) end
    local state = default
    local function render(anim)
        tw(track, anim and 0.2 or 0, { BackgroundColor3 = state and theme.Accent or theme.Off })
        tw(knob, anim and 0.3 or 0, { Position = state and UDim2.fromOffset(24, 2) or UDim2.fromOffset(2, 2) }, Enum.EasingStyle.Back)
    end
    onAccent(function() render(false) end)
    interact(c, sc, function()
        if prem and not isPremium then shake(c); notify(tr("needprem")) return end
        local n = not state
        if cb(n) == false then return end
        state = n
        render(true)
    end)
end

local function Slider(page, key, min, max, def, cb)
    local c = card(page, 60)
    cardLabel(c, key, -90, 34)
    local val = new("TextLabel", {
        Size = UDim2.fromOffset(60, 34), AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -14, 0, 0), BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold, TextSize = 13, Text = tostring(def), TextXAlignment = Enum.TextXAlignment.Right,
    }, c)
    local bar = new("Frame", { Size = UDim2.new(1, -32, 0, 8), Position = UDim2.fromOffset(16, 40), BackgroundColor3 = theme.Off, BorderSizePixel = 0 }, c)
    corner(bar, 4)
    local rel0 = (def - min) / (max - min)
    local fill = new("Frame", { Size = UDim2.fromScale(rel0, 1), BorderSizePixel = 0, BackgroundColor3 = WHITE }, bar)
    corner(fill, 4)
    local fg = new("UIGradient", {}, fill)
    local knob = new("Frame", { Size = UDim2.fromOffset(14, 14), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(rel0, 0.5), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, bar)
    corner(knob, 7)
    local ks = new("UIStroke", { Thickness = 2 }, knob)
    onAccent(function() fg.Color = accentSeq(); ks.Color = theme.Accent; val.TextColor3 = theme.Accent2 end)
    local hit = new("TextButton", { Size = UDim2.new(1, -16, 0, 30), Position = UDim2.fromOffset(8, 30), BackgroundTransparency = 1, Text = "", ZIndex = 5 }, c)
    local dragging = false
    local function upd(x)
        local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * rel + 0.5)
        rel = (v - min) / (max - min)
        tw(fill, 0.08, { Size = UDim2.fromScale(rel, 1) })
        tw(knob, 0.08, { Position = UDim2.fromScale(rel, 0.5) })
        val.Text = tostring(v)
        cb(v)
    end
    hit.InputBegan:Connect(function(i)
        if isPress(i) then dragging = true; tw(knob, 0.15, { Size = UDim2.fromOffset(19, 19) }, Enum.EasingStyle.Back); upd(i.Position.X) end
    end)
    bind(UIS.InputChanged, function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    bind(UIS.InputEnded, function(i)
        if isPress(i) and dragging then dragging = false; tw(knob, 0.2, { Size = UDim2.fromOffset(14, 14) }, Enum.EasingStyle.Back) end
    end)
end

local function Button(page, key, cb, prem, dyn)
    local c, sc = card(page, 44)
    c.BackgroundColor3 = WHITE
    local g = new("UIGradient", { Rotation = 0 }, c)
    onAccent(function() g.Color = accentSeq() end)
    local l = new("TextLabel", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = WHITE,
    }, c)
    onLang(function() l.Text = dyn and dyn() or tr(key) end)
    if prem then premTag(c, -12) end
    local b = interact(c, sc, function()
        if prem and not isPremium then shake(c); notify(tr("needprem")) return end
        cb()
    end, true)
    b.MouseEnter:Connect(function() tw(c, 0.15, { BackgroundTransparency = 0.12 }) end)
    b.MouseLeave:Connect(function() tw(c, 0.15, { BackgroundTransparency = 0 }) end)
    return l
end

local function Choice(page, key, options, defIndex, cb)
    local c, sc = card(page, 44)
    cardLabel(c, key, -170)
    local pill = new("Frame", { Size = UDim2.fromOffset(120, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -12, 0.5, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, c)
    corner(pill, 13)
    local pg = new("UIGradient", {}, pill)
    onAccent(function() pg.Color = accentSeq() end)
    local pscale = new("UIScale", {}, pill)
    local txt = new("TextLabel", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = options[defIndex], Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = WHITE }, pill)
    local idx = defIndex
    interact(c, sc, function()
        idx = idx % #options + 1
        txt.Text = options[idx]
        pscale.Scale = 0.8
        tw(pscale, 0.3, { Scale = 1 }, Enum.EasingStyle.Back)
        cb(idx, options[idx])
    end)
end

------------------------------------------------------------------
-- LOGICA
------------------------------------------------------------------
local flyBV, flyBG
local function stopFly()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local h = hum()
    if h then h.PlatformStand = false end
end
local function startFly()
    local r, h = root(), hum()
    if not r or not h then return end
    stopFly()
    flyBV = new("BodyVelocity", { MaxForce = Vector3.new(9e9, 9e9, 9e9), Velocity = Vector3.zero }, r)
    flyBG = new("BodyGyro", { MaxTorque = Vector3.new(9e9, 9e9, 9e9), P = 9e4, CFrame = r.CFrame }, r)
    h.PlatformStand = true
end

bind(RS.Heartbeat, function()
    local r, h = root(), hum()
    if not r or not h then return end
    local cam = workspace.CurrentCamera
    if S.fly and flyBV and flyBG then
        local look = cam.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        flatLook = flatLook.Magnitude > 0 and flatLook.Unit or Vector3.new(0, 0, -1)
        local right = cam.CFrame.RightVector
        local flatRight = Vector3.new(right.X, 0, right.Z)
        flatRight = flatRight.Magnitude > 0 and flatRight.Unit or Vector3.new(1, 0, 0)
        local dir = h.MoveDirection
        local vel = look * dir:Dot(flatLook) + right * dir:Dot(flatRight)
        if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then vel += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then vel -= Vector3.new(0, 1, 0) end
        flyBV.Velocity = vel * S.flySpeed
        flyBG.CFrame = CFrame.new(r.Position, r.Position + look)
    end
    if S.speedOn then h.WalkSpeed = S.speed end
    if S.jumpOn then h.UseJumpPower = true; h.JumpPower = S.jump end
    if S.spin then r.CFrame = r.CFrame * CFrame.Angles(0, math.rad(S.spinSpeed), 0) end
end)

bind(RS.Stepped, function()
    if (S.noclip or S.farm) and lp.Character then
        for _, p in ipairs(lp.Character:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

bind(UIS.JumpRequest, function()
    if S.infJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

bind(lp.CharacterAdded, function()
    task.wait(1)
    if S.fly then startFly() end
end)

bind(lp.Idled, function()
    if S.antiafk then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

bind(PPS.PromptShown, function(prompt)
    if S.instPrompt then prompt.HoldDuration = 0 end
end)

task.spawn(function()
    while gui.Parent do
        if S.autoclick then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(900, 500))
            end)
            task.wait(1 / math.max(S.cps, 1))
        else
            task.wait(0.3)
        end
    end
end)

local mouse = lp:GetMouse()
bind(mouse.Button1Down, function()
    if S.clickTp and isPremium and UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
        local r = root()
        if r and mouse.Hit then r.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
    end
end)

local origLight
local function setFullbright(on)
    if on then
        origLight = origLight or {
            Brightness = Lighting.Brightness, ClockTime = Lighting.ClockTime, FogEnd = Lighting.FogEnd,
            GlobalShadows = Lighting.GlobalShadows, Ambient = Lighting.Ambient,
        }
        Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 1e6
        Lighting.GlobalShadows = false; Lighting.Ambient = Color3.fromRGB(190, 190, 190)
    elseif origLight then
        for k, v in pairs(origLight) do Lighting[k] = v end
    end
end

local espObjs = {}
local function roleColor(p)
    local c, b = p.Character, p:FindFirstChildOfClass("Backpack")
    local function has(n) return (c and c:FindFirstChild(n)) or (b and b:FindFirstChild(n)) end
    if has("Knife") then return Color3.fromRGB(255, 60, 60) end
    if has("Gun") then return Color3.fromRGB(70, 140, 255) end
    return theme.Accent
end
local function clearEsp()
    for _, o in pairs(espObjs) do
        if o.hl then o.hl:Destroy() end
        if o.bb then o.bb:Destroy() end
    end
    table.clear(espObjs)
end
task.spawn(function()
    while gui.Parent do
        task.wait(0.5)
        if S.esp then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local o = espObjs[p]
                    if not o or not o.hl.Parent or o.hl.Adornee ~= p.Character then
                        if o then o.hl:Destroy() o.bb:Destroy() end
                        local hl = new("Highlight", { Adornee = p.Character, FillTransparency = 0.6, OutlineTransparency = 0 }, gui)
                        local head = p.Character:FindFirstChild("Head") or p.Character.HumanoidRootPart
                        local bb = new("BillboardGui", { Adornee = head, Size = UDim2.fromOffset(120, 20), StudsOffset = Vector3.new(0, 2.5, 0), AlwaysOnTop = true }, gui)
                        new("TextLabel", {
                            Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = p.DisplayName,
                            TextColor3 = WHITE, TextStrokeTransparency = 0, Font = Enum.Font.GothamBold, TextSize = 13,
                        }, bb)
                        o = { hl = hl, bb = bb }
                        espObjs[p] = o
                    end
                    local col = roleColor(p)
                    o.hl.FillColor = col; o.hl.OutlineColor = col
                end
            end
        elseif next(espObjs) then
            clearEsp()
        end
    end
end)

------------------------------------------------------------------
-- DETECCAO DE JOGO
------------------------------------------------------------------
local GAMES = {
    [2753915549] = "Blox Fruits", [4442272183] = "Blox Fruits", [7449423635] = "Blox Fruits",
    [142823291] = "Murder Mystery 2",
    [6516141723] = "Doors", [6839171747] = "Doors",
}
local gameName = GAMES[game.PlaceId]

------------------------------------------------------------------
-- PAGINAS
------------------------------------------------------------------
-- MAIN
local pMain = addTab("tab_main")
if gameName then Info(pMain, function() return tr("game_detected") .. gameName end) end
Section(pMain, "sec_move")
Toggle(pMain, "fly", false, function(v) S.fly = v; if v then startFly() else stopFly() end end)
Slider(pMain, "flyspeed", 10, 250, S.flySpeed, function(v) S.flySpeed = v end)
Toggle(pMain, "noclip", false, function(v) S.noclip = v end)
Toggle(pMain, "infjump", false, function(v) S.infJump = v end)
Section(pMain, "sec_misc")
Toggle(pMain, "spin", false, function(v) S.spin = v end)
Slider(pMain, "spinspeed", 1, 60, S.spinSpeed, function(v) S.spinSpeed = v end)
Toggle(pMain, "antiafk", true, function(v) S.antiafk = v end)
Toggle(pMain, "instprompt", false, function(v)
    S.instPrompt = v
    if v then
        for _, d in ipairs(workspace:GetDescendants()) do
            if d:IsA("ProximityPrompt") then d.HoldDuration = 0 end
        end
    end
end)
Toggle(pMain, "autoclick", false, function(v) S.autoclick = v end)
Slider(pMain, "cps", 1, 30, S.cps, function(v) S.cps = v end)

if gameName == "Blox Fruits" then
    Section(pMain, "sec_bf")
    Toggle(pMain, "farm", false, function(v) S.farm = v end)
    Choice(pMain, "weapon", { "Melee", "Sword", "Blox Fruit", "Gun" }, 1, function(_, name) S.weapon = name end)
    Slider(pMain, "farmh", 3, 25, S.farmH, function(v) S.farmH = v end)

    task.spawn(function()
        while gui.Parent do
            task.wait(0.1)
            if S.farm then
                pcall(function()
                    local r, h = root(), hum()
                    if not r or not h or h.Health <= 0 then return end
                    local enemies = workspace:FindFirstChild("Enemies")
                    if not enemies then return end
                    local best, bd
                    for _, m in ipairs(enemies:GetChildren()) do
                        local mh, mr = m:FindFirstChildOfClass("Humanoid"), m:FindFirstChild("HumanoidRootPart")
                        if mh and mr and mh.Health > 0 then
                            local d = (mr.Position - r.Position).Magnitude
                            if not bd or d < bd then best, bd = m, d end
                        end
                    end
                    if not best then return end
                    local tool = lp.Character:FindFirstChildOfClass("Tool")
                    if not tool or tool.ToolTip ~= S.weapon then
                        for _, t in ipairs(lp.Backpack:GetChildren()) do
                            if t:IsA("Tool") and t.ToolTip == S.weapon then h:EquipTool(t) break end
                        end
                    end
                    r.CFrame = best.HumanoidRootPart.CFrame * CFrame.new(0, S.farmH, 0) * CFrame.Angles(math.rad(-90), 0, 0)
                    r.AssemblyLinearVelocity = Vector3.zero
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(900, 500))
                end)
            end
        end
    end)
end

-- PLAYER
local pPlayer = addTab("tab_player")
Section(pPlayer, "sec_char")
Toggle(pPlayer, "speedon", false, function(v)
    S.speedOn = v
    if not v then local h = hum() if h then h.WalkSpeed = 16 end end
end)
Slider(pPlayer, "speedval", 16, 300, S.speed, function(v) S.speed = v end)
Toggle(pPlayer, "jumpon", false, function(v)
    S.jumpOn = v
    if not v then local h = hum() if h then h.JumpPower = 50 end end
end)
Slider(pPlayer, "jumpval", 50, 300, S.jump, function(v) S.jump = v end)

-- TELEPORT
local pTp = addTab("tab_tp")
Section(pTp, "sec_players")
local listCard = card(pTp, 180)
local listScroll = new("ScrollingFrame", {
    Size = UDim2.new(1, -16, 1, -16), Position = UDim2.fromOffset(8, 8), BackgroundTransparency = 1,
    BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, listCard)
new("UIListLayout", { Padding = UDim.new(0, 5) }, listScroll)
onAccent(function() listScroll.ScrollBarImageColor3 = theme.Accent end)
local function refreshPlayers()
    for _, c in ipairs(listScroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local b = new("TextButton", {
                Size = UDim2.new(1, -6, 0, 32), BackgroundColor3 = theme.Off, BackgroundTransparency = 0.35, AutoButtonColor = false,
                Text = "   " .. p.DisplayName .. "  @" .. p.Name, TextColor3 = theme.Text, Font = Enum.Font.GothamMedium, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left, BorderSizePixel = 0,
            }, listScroll)
            corner(b, 8)
            b.MouseEnter:Connect(function() tw(b, 0.15, { BackgroundColor3 = theme.Accent, BackgroundTransparency = 0.2 }) end)
            b.MouseLeave:Connect(function() tw(b, 0.15, { BackgroundColor3 = theme.Off, BackgroundTransparency = 0.35 }) end)
            b.MouseButton1Click:Connect(function()
                local r, tr_ = root(), p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if r and tr_ then
                    r.CFrame = tr_.CFrame * CFrame.new(0, 0, 3)
                    notify(tr("tpdone") .. p.DisplayName)
                end
            end)
        end
    end
end
refreshPlayers()
bind(Players.PlayerAdded, refreshPlayers)
bind(Players.PlayerRemoving, function() task.defer(refreshPlayers) end)
Button(pTp, "refresh", refreshPlayers)
Section(pTp, "sec_tools")
Toggle(pTp, "clicktp", false, function(v) S.clickTp = v end, true)
Button(pTp, "serverhop", function()
    pcall(function()
        local data = HttpService:JSONDecode(game:HttpGet(
            "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in ipairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, lp)
                break
            end
        end
    end)
end, true)
Button(pTp, "rejoin", function() TeleportService:Teleport(game.PlaceId, lp) end)

-- VISUAL
local pVis = addTab("tab_visual")
Section(pVis, "sec_view")
Toggle(pVis, "fullbright", false, function(v) S.fullbright = v; setFullbright(v) end)
Toggle(pVis, "esp", false, function(v) S.esp = v; if not v then clearEsp() end end, true)
Button(pVis, "fps", function()
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    Lighting.GlobalShadows = false
    for _, d in ipairs(workspace:GetDescendants()) do
        if d:IsA("BasePart") then d.Material = Enum.Material.SmoothPlastic; d.CastShadow = false
        elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then d.Enabled = false end
    end
end)
if gameName == "Murder Mystery 2" then
    Info(pVis, function() return tr("mm2info") end, 48)
elseif gameName == "Doors" then
    Section(pVis, "sec_doors")
    Toggle(pVis, "doorshl", false, function(v) S.doorsHl = v end)
    task.spawn(function()
        while gui.Parent do
            task.wait(1)
            local rooms = workspace:FindFirstChild("CurrentRooms")
            if rooms then
                for _, d in ipairs(rooms:GetDescendants()) do
                    if d:IsA("ProximityPrompt") and d.Parent then
                        local existing = d.Parent:FindFirstChild("KamuHL")
                        if S.doorsHl and not existing then
                            new("Highlight", { Name = "KamuHL", FillColor = theme.Accent, FillTransparency = 0.6 }, d.Parent)
                        elseif not S.doorsHl and existing then
                            existing:Destroy()
                        end
                    end
                end
            end
        end
    end)
end

-- CONFIG
local pCfg = addTab("tab_config")
Section(pCfg, "sec_look")
do
    local c = card(pCfg, 82)
    cardLabel(c, "accent", -20, 38)
    local presets = {
        Color3.fromRGB(150, 90, 255), Color3.fromRGB(255, 70, 110), Color3.fromRGB(60, 160, 255),
        Color3.fromRGB(50, 210, 140), Color3.fromRGB(255, 170, 40), Color3.fromRGB(240, 240, 245),
    }
    local rings, scales = {}, {}
    local function select_(i)
        for k, r in ipairs(rings) do tw(r, 0.2, { Thickness = k == i and 2.5 or 0 }) end
    end
    for i, col in ipairs(presets) do
        local b = new("TextButton", {
            Size = UDim2.fromOffset(28, 28), Position = UDim2.fromOffset(16 + (i - 1) * 38, 42),
            BackgroundColor3 = col, Text = "", BorderSizePixel = 0, AutoButtonColor = false,
        }, c)
        corner(b, 14)
        local sc = new("UIScale", {}, b)
        rings[i] = new("UIStroke", { Color = WHITE, Thickness = i == 1 and 2.5 or 0 }, b)
        scales[i] = sc
        b.MouseEnter:Connect(function() tw(sc, 0.15, { Scale = 1.15 }, Enum.EasingStyle.Back) end)
        b.MouseLeave:Connect(function() tw(sc, 0.15, { Scale = 1 }) end)
        b.MouseButton1Click:Connect(function()
            select_(i)
            setAccent(col)
        end)
    end
end
Slider(pCfg, "bgtrans", 0, 70, 0, function(v)
    win.BackgroundTransparency = v / 100
    shadow.ImageTransparency = 0.4 + v / 200
end)
Section(pCfg, "sec_general")
Choice(pCfg, "language", { "Portugues", "English" }, 1, function(i)
    lang = (i == 1) and "pt" or "en"
    for _, fn in ipairs(langFns) do pcall(fn) end
end)

local toggleKey = Enum.KeyCode.LeftShift
local binding = false
local keyLbl
keyLbl = Button(pCfg, "togglekey", function()
    binding = true
    keyLbl.Text = tr("pressakey")
end, false, function() return tr("togglekey") .. ": " .. toggleKey.Name end)
Button(pCfg, "destroy", function() if getgenv and getgenv().KamuHubDestroy then pcall(getgenv().KamuHubDestroy) end end)

------------------------------------------------------------------
-- PILULA + ABRIR/FECHAR ANIMADO
------------------------------------------------------------------
local pill = new("Frame", {
    Size = UDim2.fromOffset(230, 46), AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0, -70),
    BackgroundColor3 = Color3.fromRGB(18, 18, 28), BorderSizePixel = 0, Visible = false,
}, gui)
corner(pill, 23)
local pillStroke = new("UIStroke", { Thickness = 1.8 }, pill)
local pillGrad = new("UIGradient", { Rotation = 30 }, pillStroke)
onAccent(function() pillGrad.Color = accentSeq() end)
local pillScale = new("UIScale", {}, pill)
makeLogo(pill, 34, UDim2.fromOffset(6, 6))
makeTitle(pill, UDim2.fromOffset(50, 0), UDim2.new(1, -56, 1, 0), 16)
local pillBtn = new("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 10 }, pill)
pillBtn.MouseEnter:Connect(function() tw(pillScale, 0.2, { Scale = 1.06 }, Enum.EasingStyle.Back) end)
pillBtn.MouseLeave:Connect(function() tw(pillScale, 0.2, { Scale = 1 }) end)

local isOpen, busy = true, false
local function setMenu(open)
    if busy or open == isOpen then return end
    busy = true
    isOpen = open
    task.spawn(function()
        if open then
            tw(pill, 0.3, { Position = UDim2.new(0.5, 0, 0, -70) }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
            task.wait(0.25)
            pill.Visible = false
            uiscale.Scale = baseScale * 0.8
            rootF.Visible = true
            tw(uiscale, 0.4, { Scale = baseScale }, Enum.EasingStyle.Back)
        else
            tw(uiscale, 0.22, { Scale = baseScale * 0.8 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
            task.wait(0.22)
            rootF.Visible = false
            pill.Position = UDim2.new(0.5, 0, 0, -70)
            pill.Visible = true
            tw(pill, 0.45, { Position = UDim2.new(0.5, 0, 0, 14) }, Enum.EasingStyle.Back)
        end
        task.wait(0.15)
        busy = false
    end)
end
minBtn.MouseButton1Click:Connect(function() setMenu(false) end)
pillBtn.MouseButton1Click:Connect(function() setMenu(true) end)

bind(UIS.InputBegan, function(i, gp)
    if binding and i.UserInputType == Enum.UserInputType.Keyboard then
        toggleKey = i.KeyCode
        binding = false
        keyLbl.Text = tr("togglekey") .. ": " .. toggleKey.Name
        notify(toggleKey.Name)
        return
    end
    if gp then return end
    if i.KeyCode == toggleKey then setMenu(not isOpen) end
end)

------------------------------------------------------------------
-- DESTRUIR
------------------------------------------------------------------
local function destroyAll()
    for k in pairs(S) do if type(S[k]) == "boolean" then S[k] = false end end
    stopFly(); clearEsp(); setFullbright(false)
    local h = hum()
    if h then h.WalkSpeed = 16; h.JumpPower = 50 end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    gui:Destroy()
    if getgenv then getgenv().KamuHubDestroy = nil end
end
closeBtn.MouseButton1Click:Connect(destroyAll)
if getgenv then getgenv().KamuHubDestroy = destroyAll end

------------------------------------------------------------------
-- INICIO
------------------------------------------------------------------
selectTab(tabs[1], true)
tw(uiscale, 0.5, { Scale = baseScale }, Enum.EasingStyle.Back)
task.delay(0.4, function() notify(tr("loaded")) end)
