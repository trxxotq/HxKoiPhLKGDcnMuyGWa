-- FLUX UI LIBRARY v1.0 - Delta Compatible
-- No gethui, no AutomaticSize, manual sizing throughout

local Flux = {}
Flux.__index = Flux

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

local Theme = {
    Background  = Color3.fromRGB(18, 18, 24),
    Sidebar     = Color3.fromRGB(13, 13, 18),
    Accent      = Color3.fromRGB(220, 50, 180),
    TabActive   = Color3.fromRGB(28, 28, 36),
    Toggle_On   = Color3.fromRGB(220, 50, 180),
    Toggle_Off  = Color3.fromRGB(50, 50, 65),
    Text        = Color3.fromRGB(240, 240, 255),
    TextDim     = Color3.fromRGB(140, 140, 160),
    TextMuted   = Color3.fromRGB(90, 90, 110),
    Divider     = Color3.fromRGB(35, 35, 48),
    SliderFill  = Color3.fromRGB(220, 50, 180),
    SliderTrack = Color3.fromRGB(40, 40, 55),
}

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Children" then
            pcall(function() obj[k] = v end)
        end
    end
    if props.Children then
        for _, child in ipairs(props.Children) do
            child.Parent = obj
        end
    end
    return obj
end

local function Corner(radius, parent)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
end

local function Tween(obj, props, t)
    TweenService:Create(obj, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad), props):Play()
end

local function Draggable(frame)
    local dragging, start, startPos = false, nil, nil
    frame.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            start = i.Position
            startPos = frame.Position
        end
    end)
    frame.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local d = i.Position - start
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

function Flux.new()
    local self = setmetatable({}, Flux)
    self.Tabs = {}
    self.ActiveTab = nil
    self._rowCount = 0

    -- Use CoreGui fallback safe for Delta
    local gui_parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")

    self.ScreenGui = Create("ScreenGui", {
        Name = "FluxUI",
        ResetOnSpawn = false,
        Parent = gui_parent,
    })

    self.Main = Create("Frame", {
        Name = "Main",
        Size = UDim2.new(0, 560, 0, 400),
        Position = UDim2.new(0.5, -280, 0.5, -200),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Parent = self.ScreenGui,
        Children = {
            Create("UICorner", { CornerRadius = UDim.new(0, 8) }),
            Create("UIStroke", {
                Color = Color3.fromRGB(55, 55, 75),
                Thickness = 1,
                ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
            }),
        }
    })

    -- Sidebar
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 44, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = self.Main,
    })
    Corner(8, self.Sidebar)

    -- Sidebar right-edge mask
    Create("Frame", {
        Size = UDim2.new(0, 8, 1, 0),
        Position = UDim2.new(1, -8, 0, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = self.Sidebar,
    })

    -- Logo F
    local logo = Create("TextLabel", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 7, 0, 10),
        BackgroundColor3 = Theme.Accent,
        Text = "F",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0,
        Parent = self.Sidebar,
    })
    Corner(6, logo)

    -- Sidebar icons
    for i = 1, 4 do
        local ic = Create("Frame", {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0, 7, 0, 50 + (i - 1) * 40),
            BackgroundColor3 = Color3.fromRGB(28, 28, 40),
            BorderSizePixel = 0,
            Parent = self.Sidebar,
        })
        Corner(6, ic)
    end

    -- Content area
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.Main,
    })

    -- Tab bar
    self.TabBar = Create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, -8, 0, 32),
        Position = UDim2.new(0, 8, 0, 4),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = self.ContentArea,
    })

    self._tabLayout = Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
        Parent = self.TabBar,
    })

    -- Divider
    Create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundColor3 = Theme.Divider,
        BorderSizePixel = 0,
        Parent = self.ContentArea,
    })

    -- Scroll frame
    self.ScrollFrame = Create("ScrollingFrame", {
        Name = "Scroll",
        Size = UDim2.new(1, -8, 1, -44),
        Position = UDim2.new(0, 4, 0, 40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.ContentArea,
    })

    self._scrollLayout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = self.ScrollFrame,
    })

    Create("UIPadding", {
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
        PaddingRight = UDim.new(0, 4),
        Parent = self.ScrollFrame,
    })

    -- Auto canvas size via layout
    self._scrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, self._scrollLayout.AbsoluteContentSize.Y + 12)
    end)

    Draggable(self.Main)

    return self
end

function Flux:AddTab(name)
    local tab = { Name = name, Rows = 0 }

    local btnWidth = math.max(60, #name * 9)

    tab.Button = Create("TextButton", {
        Name = name,
        Size = UDim2.new(0, btnWidth, 0, 26),
        BackgroundColor3 = Theme.TabActive,
        Text = name,
        TextColor3 = Theme.TextDim,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        BorderSizePixel = 0,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.TabBar,
    })
    Corner(5, tab.Button)

    tab.Container = Create("Frame", {
        Name = name .. "_Container",
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        Visible = false,
        LayoutOrder = #self.Tabs + 1,
        Parent = self.ScrollFrame,
    })

    tab._layout = Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 3),
        Parent = tab.Container,
    })

    tab._layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tab.Container.Size = UDim2.new(1, 0, 0, tab._layout.AbsoluteContentSize.Y + 6)
    end)

    tab.Button.MouseButton1Click:Connect(function()
        self:_SelectTab(tab)
    end)

    tab.Button.MouseEnter:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, { TextColor3 = Theme.Text })
        end
    end)

    tab.Button.MouseLeave:Connect(function()
        if self.ActiveTab ~= tab then
            Tween(tab.Button, { TextColor3 = Theme.TextDim })
        end
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then self:_SelectTab(tab) end

    return tab
end

function Flux:_SelectTab(tab)
    if self.ActiveTab then
        self.ActiveTab.Container.Visible = false
        Tween(self.ActiveTab.Button, { BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.TextDim })
    end
    self.ActiveTab = tab
    tab.Container.Visible = true
    Tween(tab.Button, { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255) })
end

local function Row(tab, height)
    local r = Create("Frame", {
        Size = UDim2.new(1, 0, 0, height or 44),
        BackgroundColor3 = Color3.fromRGB(22, 22, 30),
        BorderSizePixel = 0,
        LayoutOrder = tab.Rows,
        Parent = tab.Container,
    })
    Corner(6, r)
    Create("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = r,
    })
    tab.Rows = tab.Rows + 1
    return r
end

-- Toggle
function Flux:AddToggle(tab, label, desc, default, callback)
    local state = default or false
    local h = desc and 52 or 44
    local r = Row(tab, h)

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 0, 0, desc and 7 or 14),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = r,
    })

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, -50, 0, 13),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = r,
        })
    end

    local track = Create("Frame", {
        Size = UDim2.new(0, 36, 0, 20),
        Position = UDim2.new(1, -36, 0.5, -10),
        BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off,
        BorderSizePixel = 0,
        Parent = r,
    })
    Corner(10, track)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    Corner(7, knob)

    local btn = Create("TextButton", {
        Size = UDim2.new(1, 24, 1, 0),
        Position = UDim2.new(0, -12, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = r,
    })

    btn.MouseButton1Click:Connect(function()
        state = not state
        Tween(track, { BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off })
        Tween(knob, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
        if callback then callback(state) end
    end)

    return {
        Set = function(v)
            state = v
            Tween(track, { BackgroundColor3 = state and Theme.Toggle_On or Theme.Toggle_Off })
            Tween(knob, { Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) })
            if callback then callback(state) end
        end,
        Get = function() return state end,
    }
end

-- Slider
function Flux:AddSlider(tab, label, desc, min, max, default, callback)
    min, max = min or 0, max or 100
    local value = math.clamp(default or min, min, max)
    local r = Row(tab, desc and 62 or 54)

    Create("TextLabel", {
        Size = UDim2.new(1, -50, 0, 16),
        Position = UDim2.new(0, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = r,
    })

    local valLbl = Create("TextLabel", {
        Size = UDim2.new(0, 40, 0, 16),
        Position = UDim2.new(1, -40, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = Theme.Accent,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = r,
    })

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 12),
            Position = UDim2.new(0, 0, 0, 24),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = r,
        })
    end

    local trackY = desc and 42 or 36
    local track = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 4),
        Position = UDim2.new(0, 0, 0, trackY),
        BackgroundColor3 = Theme.SliderTrack,
        BorderSizePixel = 0,
        Parent = r,
    })
    Corner(2, track)

    local pct = (value - min) / (max - min)
    local fill = Create("Frame", {
        Size = UDim2.new(pct, 0, 1, 0),
        BackgroundColor3 = Theme.SliderFill,
        BorderSizePixel = 0,
        Parent = track,
    })
    Corner(2, fill)

    local knob = Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(pct, -6, 0.5, -6),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    Corner(6, knob)

    local dragging = false

    local function Update(x)
        local abs = track.AbsolutePosition.X
        local sz  = track.AbsoluteSize.X
        local rel = math.clamp((x - abs) / sz, 0, 1)
        value = math.floor(min + (max - min) * rel)
        valLbl.Text = tostring(value)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -6, 0.5, -6)
        if callback then callback(value) end
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            Update(i.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            Update(i.Position.X)
        end
    end)

    return {
        Set = function(v)
            value = math.clamp(v, min, max)
            local rel = (value - min) / (max - min)
            valLbl.Text = tostring(value)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -6, 0.5, -6)
            if callback then callback(value) end
        end,
        Get = function() return value end,
    }
end

-- Chips (Sheet / Bubble style)
function Flux:AddChips(tab, label, desc, options, default, callback)
    local selected = default or options[1]
    local h = 52
    if label then h = h + 0 end
    if desc then h = h + 14 end
    local r = Row(tab, h)

    local yOff = 0
    if label then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            Position = UDim2.new(0, 0, 0, 6),
            BackgroundTransparency = 1,
            Text = label,
            TextColor3 = Theme.Text,
            TextSize = 13,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = r,
        })
        yOff = 24
    end

    if desc then
        Create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 12),
            Position = UDim2.new(0, 0, 0, yOff),
            BackgroundTransparency = 1,
            Text = desc,
            TextColor3 = Theme.TextMuted,
            TextSize = 10,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = r,
        })
        yOff = yOff + 14
    end

    local chipRow = Create("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 0, yOff + 4),
        BackgroundTransparency = 1,
        Parent = r,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        Parent = chipRow,
    })

    local refs = {}

    for i, opt in ipairs(options) do
        local sel = opt == selected
        local w = math.max(40, #opt * 8 + 16)
        local chip = Create("TextButton", {
            Size = UDim2.new(0, w, 1, 0),
            BackgroundColor3 = sel and Theme.Accent or Color3.fromRGB(35, 35, 50),
            Text = opt,
            TextColor3 = sel and Color3.fromRGB(255, 255, 255) or Theme.TextDim,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            BorderSizePixel = 0,
            LayoutOrder = i,
            Parent = chipRow,
        })
        Corner(4, chip)
        refs[opt] = chip

        chip.MouseButton1Click:Connect(function()
            for _, c in pairs(refs) do
                Tween(c, { BackgroundColor3 = Color3.fromRGB(35, 35, 50), TextColor3 = Theme.TextDim })
            end
            Tween(chip, { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255) })
            selected = opt
            if callback then callback(opt) end
        end)
    end

    return {
        Get = function() return selected end,
        Set = function(v)
            for _, c in pairs(refs) do
                Tween(c, { BackgroundColor3 = Color3.fromRGB(35, 35, 50), TextColor3 = Theme.TextDim })
            end
            if refs[v] then
                Tween(refs[v], { BackgroundColor3 = Theme.Accent, TextColor3 = Color3.fromRGB(255, 255, 255) })
                selected = v
                if callback then callback(v) end
            end
        end,
    }
end

-- Label
function Flux:AddLabel(tab, text)
    local r = Row(tab, 26)
    r.BackgroundTransparency = 1
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = Theme.TextMuted,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = r,
    })
end

return Flux


-- ============================================================
-- USAGE — paste below the library or in a separate script
-- ============================================================

--[[

local Flux = loadstring(game:HttpGet("YOUR_RAW_URL_HERE"))()
local W = Flux.new()

local Aimbot = W:AddTab("Aimbot")
local Silent = W:AddTab("Silent Aim")
local Trigger = W:AddTab("Triggerbot")
local Rage = W:AddTab("Rage")

W:AddToggle(Aimbot, "Enabled", "Master switch for Aimbot", false, function(v)
    print("Aimbot:", v)
end)

W:AddChips(Aimbot, nil, nil, {"Mouse", "Camera", "Auto", "m5"}, "Camera", function(v)
    print("Mode:", v)
end)

W:AddToggle(Aimbot, "Sticky Aim", nil, false, function(v) end)
W:AddToggle(Aimbot, "Teamcheck", nil, false, function(v) end)

W:AddSlider(Aimbot, "Show FOV", "Master the FOV at which targets are found", 0, 200, 100, function(v)
    print("FOV:", v)
end)

W:AddToggle(Aimbot, "Hitsounds", "Will play a sound whenever damage is done to aimbot target", false, function(v) end)

W:AddChips(Aimbot, "Hit Skeleton", "Draw skeleton when damage is done to target", {"Sheet", "Bubble"}, "Sheet", function(v)
    print("Skeleton type:", v)
end)

W:AddToggle(Aimbot, "ForceField Check", "Won't lock on a person who has a forcefield around them", false, function(v) end)
W:AddToggle(Aimbot, "Invisible Check", "Won't lock on a person if they are invisible", false, function(v) end)
W:AddToggle(Aimbot, "Tool Check", "Won't lock on if you don't have a gun equipped (Da Hood)", false, function(v) end)

W:AddToggle(Silent, "Enabled", "Silent aim master switch", false, function(v) end)
W:AddToggle(Trigger, "Enabled", "Auto-fire on target", false, function(v) end)
W:AddToggle(Rage, "Enabled", "Rage mode", false, function(v) end)

]]
