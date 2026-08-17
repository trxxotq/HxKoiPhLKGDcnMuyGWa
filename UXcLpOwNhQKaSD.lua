-- ============================================================
-- MM2 CHEAT — DELTA EXECUTOR BUILD
-- loadstring(game:HttpGet("YOUR_RAW_URL"))()
-- ============================================================

if not game or not Drawing then
    error("[MM2] Delta executor required.")
end

local CHEAT_VERSION = "1.1.0"
local GAME_ID       = 142823291

if game.PlaceId ~= GAME_ID then
    warn("[MM2] Wrong game — expected MM2. Remove this check to test in Studio.")
    return
end

print("[MM2 Cheat] v" .. CHEAT_VERSION .. " loading on Delta...")

-- ============================================================
-- DRAWING WRAPPER — Delta-safe, no :setProps()
-- ============================================================
local function newDraw(type, props)
    local ok, d = pcall(function() return Drawing.new(type) end)
    if not ok or not d then return nil end
    for k, v in pairs(props) do
        pcall(function() d[k] = v end)
    end
    return d
end

local function removeDrawing(d)
    if d then pcall(function() d:Remove() end) end
end

-- ============================================================
-- ICONS — line-based, Delta-safe
-- ============================================================
local Icons = {}

local function drawLine(x1, y1, x2, y2, color, thickness)
    return newDraw("Line", {
        From      = Vector2.new(x1, y1),
        To        = Vector2.new(x2, y2),
        Color     = color,
        Thickness = thickness or 1.5,
        Visible   = true,
        Transparency = 1,
    })
end

local function drawCircle(cx, cy, r, color, filled, thickness)
    return newDraw("Circle", {
        Position     = Vector2.new(cx, cy),
        Radius       = r,
        Color        = color,
        Filled       = filled or false,
        Thickness    = thickness or 1.5,
        Visible      = true,
        Transparency = 1,
    })
end

function Icons.crosshair(x, y, s, c, pool)
    pool = pool or {}
    table.insert(pool, drawCircle(x, y, s/2, c, false, 1.5))
    table.insert(pool, drawLine(x-s/2, y, x+s/2, y, c, 1))
    table.insert(pool, drawLine(x, y-s/2, x, y+s/2, c, 1))
    return pool
end

function Icons.eye(x, y, s, c, pool)
    pool = pool or {}
    table.insert(pool, drawCircle(x, y, s/2*0.9, c, false, 1.5))
    table.insert(pool, drawCircle(x, y, s/2*0.35, c, true))
    return pool
end

function Icons.zap(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2
    local pts = {
        {x+h*0.2, y-h}, {x-h*0.3, y},
        {x+h*0.1, y},   {x-h*0.2, y+h}
    }
    for i = 1, #pts-1 do
        table.insert(pool, drawLine(pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], c, 1.5))
    end
    return pool
end

function Icons.shield(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2
    local segs = {
        {x-h, y-h*0.3, x-h,   y-h},
        {x-h, y-h,     x,     y-h*1.1},
        {x,   y-h*1.1, x+h,   y-h},
        {x+h, y-h,     x+h,   y-h*0.3},
        {x+h, y-h*0.3, x,     y+h},
        {x,   y+h,     x-h,   y-h*0.3},
    }
    for _, seg in ipairs(segs) do
        table.insert(pool, drawLine(seg[1], seg[2], seg[3], seg[4], c, 1.5))
    end
    return pool
end

function Icons.settings(x, y, s, c, pool)
    pool = pool or {}
    table.insert(pool, drawCircle(x, y, s*0.28, c, false, 1.5))
    table.insert(pool, drawCircle(x, y, s*0.48, c, false, 1))
    return pool
end

function Icons.user(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2
    table.insert(pool, drawCircle(x, y-h*0.3, h*0.4,  c, false, 1.5))
    table.insert(pool, drawCircle(x, y+h*0.6, h*0.85, c, false, 1.5))
    return pool
end

function Icons.map(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2
    local pts = {
        {x-h,y+h},{x-h,y-h},{x,y-h*0.5},
        {x+h,y-h},{x+h,y+h},{x,y+h*0.5},{x-h,y+h}
    }
    for i = 1, #pts-1 do
        table.insert(pool, drawLine(pts[i][1],pts[i][2],pts[i+1][1],pts[i+1][2],c,1.5))
    end
    table.insert(pool, drawLine(x,y-h*0.5,x,y+h*0.5,c,1))
    return pool
end

function Icons.chevron_down(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2
    table.insert(pool, drawLine(x-h, y-h*0.3, x,   y+h*0.3, c, 1.5))
    table.insert(pool, drawLine(x,   y+h*0.3, x+h, y-h*0.3, c, 1.5))
    return pool
end

function Icons.check(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2
    table.insert(pool, drawLine(x-h,     y,        x-h*0.2, y+h*0.6, c, 1.5))
    table.insert(pool, drawLine(x-h*0.2, y+h*0.6,  x+h,     y-h*0.5, c, 1.5))
    return pool
end

function Icons.xmark(x, y, s, c, pool)
    pool = pool or {}
    local h = s/2*0.7
    table.insert(pool, drawLine(x-h, y-h, x+h, y+h, c, 1.5))
    table.insert(pool, drawLine(x+h, y-h, x-h, y+h, c, 1.5))
    return pool
end

-- ============================================================
-- THEME
-- ============================================================
local T = {
    bg        = Color3.fromRGB(12, 12, 16),
    surface   = Color3.fromRGB(20, 20, 26),
    surface2  = Color3.fromRGB(28, 28, 36),
    border    = Color3.fromRGB(45, 45, 58),
    accent    = Color3.fromRGB(139, 92, 246),
    accentDim = Color3.fromRGB(80, 50, 160),
    text      = Color3.fromRGB(230, 230, 240),
    muted     = Color3.fromRGB(110, 110, 130),
    white     = Color3.fromRGB(255, 255, 255),
    black     = Color3.fromRGB(0, 0, 0),
    danger    = Color3.fromRGB(240, 80, 80),
    success   = Color3.fromRGB(80, 220, 140),
}

-- ============================================================
-- DELTA-SAFE DRAW PRIMITIVES
-- ============================================================
local function drawRect(x, y, w, h, color, filled, thickness)
    return newDraw("Square", {
        Position     = Vector2.new(x, y),
        Size         = Vector2.new(w, h),
        Color        = color,
        Filled       = filled or false,
        Thickness    = thickness or 1,
        Visible      = true,
        Transparency = 1,
    })
end

local function drawText(str, x, y, size, color, bold, center)
    return newDraw("Text", {
        Text         = tostring(str),
        Position     = Vector2.new(x, y),
        Size         = size or 13,
        Color        = color or T.text,
        Bold         = bold or false,
        Center       = center or false,
        Outline      = true,
        OutlineColor = Color3.fromRGB(0,0,0),
        Visible      = true,
        Transparency = 1,
    })
end

-- ============================================================
-- MENU STATE
-- ============================================================
local Menu = {
    visible      = true,
    x            = 120,
    y            = 80,
    width        = 540,
    height       = 480,
    dragging     = false,
    dragOffX     = 0,
    dragOffY     = 0,
    activeTab    = 1,
    drawings     = {},
    tabs         = {},
    openDropdown = nil,
}

local HEADER_H = 42
local TAB_H    = 34

-- ============================================================
-- FRAME MANAGER
-- ============================================================
local function clearFrame()
    for _, d in ipairs(Menu.drawings) do removeDrawing(d) end
    Menu.drawings = {}
end

local function push(d)
    if d then table.insert(Menu.drawings, d) end
    return d
end

local function pushIcon(fn, x, y, s, c)
    local pool = fn(x, y, s, c, {})
    for _, d in ipairs(pool) do push(d) end
end

-- ============================================================
-- RENDER
-- ============================================================
local function isInside(pos, x, y, w, h)
    return pos.X >= x and pos.X <= x+w and pos.Y >= y and pos.Y <= y+h
end

local function renderFrame()
    clearFrame()
    if not Menu.visible then return end

    local mx, my = Menu.x, Menu.y
    local mw, mh = Menu.width, Menu.height
    local bodyY  = my + HEADER_H + TAB_H

    -- Shadow
    push(drawRect(mx+4, my+4, mw, mh, T.black, true))
    -- Body
    push(drawRect(mx, my, mw, mh, T.bg, true))
    push(drawRect(mx, my, mw, mh, T.border, false, 1))

    -- Header
    push(drawRect(mx, my, mw, HEADER_H, T.surface, true))
    push(drawLine(mx, my+HEADER_H, mx+mw, my+HEADER_H, T.border, 1))
    push(drawRect(mx, my, 3, HEADER_H, T.accent, true))
    push(drawText("MM2 CHEAT",         mx+18, my+10, 15, T.text, true))
    push(drawText("Murder Mystery 2  |  v"..CHEAT_VERSION, mx+18, my+27, 11, T.muted))

    -- Close button
    local cx = mx + mw - 26
    push(drawRect(cx-4, my+10, 20, 20, T.surface2, true))
    pushIcon(Icons.xmark, cx+6, my+20, 10, T.muted)

    -- Tab bar
    push(drawRect(mx, my+HEADER_H, mw, TAB_H, T.surface, true))
    push(drawLine(mx, my+HEADER_H+TAB_H, mx+mw, my+HEADER_H+TAB_H, T.border, 1))

    local tabCount = math.max(1, #Menu.tabs)
    local tabW     = mw / tabCount

    for i, tab in ipairs(Menu.tabs) do
        local tx      = mx + (i-1)*tabW
        local ty      = my + HEADER_H
        local active  = (Menu.activeTab == i)
        local bgColor = active and T.surface2 or T.surface

        push(drawRect(tx, ty, tabW, TAB_H, bgColor, true))
        if active then
            push(drawRect(tx, ty+TAB_H-2, tabW, 2, T.accent, true))
        end
        if tab.icon then
            pushIcon(tab.icon, tx+14, ty+TAB_H/2, 11, active and T.accent or T.muted)
        end
        push(drawText(tab.name, tx+(tab.icon and 26 or 6), ty+10, 12, active and T.text or T.muted, active))
        if i < tabCount then
            push(drawLine(tx+tabW, ty+5, tx+tabW, ty+TAB_H-5, T.border, 1))
        end
    end

    -- Body bg
    push(drawRect(mx, bodyY, mw, mh-HEADER_H-TAB_H, T.bg, true))

    -- Active tab content
    local activeTab = Menu.tabs[Menu.activeTab]
    if activeTab then
        local cx2   = mx + 10
        local cy2   = bodyY + 8
        local cw    = mw - 20
        local yOff  = cy2

        for _, section in ipairs(activeTab.sections or {}) do
            yOff = renderSection(section, cx2, yOff, cw) + 6
        end
    end

    -- Dropdown overlay (on top)
    if Menu.openDropdown then
        renderDropdownOverlay(Menu.openDropdown)
    end
end

-- ============================================================
-- SECTION
-- ============================================================
function renderSection(section, sx, sy, sw)
    local padX   = 8
    local secH   = 24
    local contentH = secH + 6

    for _, el in ipairs(section.elements or {}) do
        if     el.type == "slider"      then contentH = contentH + 48
        elseif el.type == "dropdown"    then contentH = contentH + 40
        elseif el.type == "colorpicker" then contentH = contentH + 36
        elseif el.type == "button"      then contentH = contentH + 30
        elseif el.type == "label"       then contentH = contentH + 20
        else                                 contentH = contentH + 28
        end
    end
    contentH = contentH + 6

    push(drawRect(sx, sy, sw, contentH, T.surface, true))
    push(drawRect(sx, sy, sw, contentH, T.border, false, 1))
    push(drawRect(sx, sy, sw, secH, T.surface2, true))
    push(drawLine(sx, sy+secH, sx+sw, sy+secH, T.border, 1))

    if section.icon then
        pushIcon(section.icon, sx+12, sy+secH/2, 10, T.accent)
    end
    push(drawText(section.name or "Section", sx+(section.icon and 26 or padX), sy+5, 12, T.text, true))

    local ey = sy + secH + 6
    for _, el in ipairs(section.elements or {}) do
        ey = renderElement(el, sx+padX, ey, sw-padX*2)
    end

    section._x, section._y, section._w, section._h = sx, sy, sw, contentH
    return sy + contentH
end

-- ============================================================
-- ELEMENTS
-- ============================================================
function renderElement(el, ex, ey, ew)
    el._x, el._y, el._w = ex, ey, ew
    if     el.type == "toggle"      then return renderToggle(el, ex, ey, ew)
    elseif el.type == "slider"      then return renderSlider(el, ex, ey, ew)
    elseif el.type == "dropdown"    then return renderDropdown(el, ex, ey, ew)
    elseif el.type == "button"      then return renderButton(el, ex, ey, ew)
    elseif el.type == "label"       then return renderLabel(el, ex, ey, ew)
    elseif el.type == "colorpicker" then return renderColorPicker(el, ex, ey, ew)
    end
    return ey + 28
end

function renderToggle(el, ex, ey, ew)
    local rowH  = 26
    local trkW  = 36
    local trkH  = 16
    local tx    = ex + ew - trkW
    local ty    = ey + (rowH - trkH)/2
    local onCol = el.value and T.accent or T.surface2

    push(drawText(el.name or "Toggle", ex, ey+4, 13, T.text))
    if el.desc then push(drawText(el.desc, ex, ey+16, 10, T.muted)) end

    push(drawRect(tx, ty, trkW, trkH, onCol, true))
    push(drawRect(tx, ty, trkW, trkH, el.value and T.accent or T.border, false, 1))

    local knobX = el.value and (tx + trkW - trkH + 2) or (tx + 2)
    push(drawCircle(knobX+(trkH-4)/2, ty+trkH/2, (trkH-4)/2, T.white, true))

    el._trackX, el._trackY, el._trackW, el._trackH = tx, ty, trkW, trkH
    return ey + rowH + 4
end

function renderSlider(el, ex, ey, ew)
    local trkH  = 4
    local trkY  = ey + 24
    local val   = el.value or el.min or 0
    local minV  = el.min or 0
    local maxV  = el.max or 100
    local pct   = (val - minV) / (maxV - minV)
    local fillW = math.max(0, math.floor(pct * ew))

    push(drawText(el.name or "Slider", ex, ey+2, 13, T.text))
    push(drawText(tostring(math.floor(val))..(el.suffix or ""), ex+ew, ey+2, 12, T.accent, true))

    push(drawRect(ex, trkY, ew, trkH, T.surface2, true))
    push(drawRect(ex, trkY, ew, trkH, T.border, false, 1))
    if fillW > 0 then
        push(drawRect(ex, trkY, fillW, trkH, T.accent, true))
    end

    -- Thumb
    local thumbX = ex + fillW
    push(drawCircle(thumbX, trkY+trkH/2, 7, T.accent, true))
    push(drawCircle(thumbX, trkY+trkH/2, 3, T.white, true))

    push(drawText(tostring(minV), ex,    trkY+trkH+5, 10, T.muted))
    push(drawText(tostring(maxV), ex+ew, trkY+trkH+5, 10, T.muted))

    el._trackX  = ex
    el._trackY  = trkY
    el._trackW  = ew
    el._trackH  = trkH
    el._dragging = el._dragging or false

    return ey + 48
end

function renderDropdown(el, ex, ey, ew)
    local isOpen = (Menu.openDropdown == el)
    local selVal = (el.options and el.value) and el.options[el.value] or "Select..."
    local bx, by, bh = ex, ey+16, 20

    push(drawText(el.name or "Dropdown", ex, ey+2, 13, T.text))
    push(drawRect(bx, by, ew, bh, T.surface2, true))
    push(drawRect(bx, by, ew, bh, isOpen and T.accent or T.border, false, 1))
    push(drawText(selVal, bx+6, by+3, 12, T.text))
    pushIcon(Icons.chevron_down, bx+ew-10, by+bh/2, 9, T.muted)

    el._btnX, el._btnY, el._btnW, el._btnH = bx, by, ew, bh
    return ey + 40
end

function renderDropdownOverlay(el)
    if not el or not el.options then return end
    local optH   = 20
    local totalH = #el.options * optH + 2
    local ox     = el._btnX
    local oy     = el._btnY + el._btnH
    if oy + totalH > Menu.y + Menu.height - 10 then oy = el._btnY - totalH end

    push(drawRect(ox, oy, el._btnW, totalH, T.surface2, true))
    push(drawRect(ox, oy, el._btnW, totalH, T.accent, false, 1))

    el._opts = {}
    for i, opt in ipairs(el.options) do
        local iy   = oy + (i-1)*optH
        local isSel = (el.value == i)
        if isSel then push(drawRect(ox+1, iy, el._btnW-2, optH, T.accentDim, true)) end
        push(drawText(opt, ox+8, iy+3, 12, isSel and T.text or T.muted, isSel))
        if isSel then pushIcon(Icons.check, ox+el._btnW-12, iy+optH/2, 9, T.accent) end
        el._opts[i] = { x=ox, y=iy, w=el._btnW, h=optH }
    end
end

function renderButton(el, ex, ey, ew)
    local bh = 22
    push(drawRect(ex, ey, ew, bh, T.surface2, true))
    push(drawRect(ex, ey, ew, bh, T.border, false, 1))
    if el.icon then pushIcon(el.icon, ex+14, ey+bh/2, 11, T.accent) end
    push(drawText(el.name or "Button", ex+ew/2, ey+4, 12, T.text, true, true))
    el._btnX, el._btnY, el._btnW, el._btnH = ex, ey, ew, bh
    return ey + 30
end

function renderLabel(el, ex, ey, ew)
    push(drawText(el.name or "", ex, ey+2, el.size or 11, el.color or T.muted))
    return ey + 20
end

function renderColorPicker(el, ex, ey, ew)
    push(drawText(el.name or "Color", ex, ey+2, 13, T.text))
    local swatches = el.swatches or {
        Color3.fromRGB(240,80,80), Color3.fromRGB(80,200,120),
        Color3.fromRGB(80,130,240), Color3.fromRGB(240,200,60),
        Color3.fromRGB(200,80,240), Color3.fromRGB(255,255,255),
    }
    local swW, swGap = 16, 4
    local startX = ex + ew - #swatches*(swW+swGap)
    el._swatches = {}
    for i, col in ipairs(swatches) do
        local sx = startX + (i-1)*(swW+swGap)
        local sy = ey + 14
        push(drawRect(sx, sy, swW, swW, col, true))
        push(drawRect(
            sx-(el.value==i and 1 or 0),
            sy-(el.value==i and 1 or 0),
            swW+(el.value==i and 2 or 0),
            swW+(el.value==i and 2 or 0),
            el.value==i and T.accent or T.border,
            false, el.value==i and 2 or 1
        ))
        el._swatches[i] = { x=sx, y=sy, w=swW, h=swW }
    end
    return ey + 36
end

-- ============================================================
-- INPUT
-- ============================================================
local uis = game:GetService("UserInputService")
local connections = {}

-- Mouse down
table.insert(connections, uis.InputBegan:Connect(function(inp, gpe)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    local pos = inp.Position
    local mx, my = Menu.x, Menu.y

    -- Dropdown close / option select
    if Menu.openDropdown then
        local dd = Menu.openDropdown
        if not isInside(pos, dd._btnX, dd._btnY, dd._btnW, dd._btnH) then
            if dd._opts then
                for i, opt in pairs(dd._opts) do
                    if isInside(pos, opt.x, opt.y, opt.w, opt.h) then
                        dd.value = i
                        if dd.onChange then dd.onChange(i, dd.options[i]) end
                        break
                    end
                end
            end
            Menu.openDropdown = nil
            renderFrame()
            return
        end
    end

    -- Header: drag or close
    if isInside(pos, mx, my, Menu.width, HEADER_H) then
        local closeX = mx + Menu.width - 26
        if isInside(pos, closeX-4, my+10, 20, 20) then
            Menu.visible = false; renderFrame(); return
        end
        Menu.dragging = true
        Menu.dragOffX = pos.X - mx
        Menu.dragOffY = pos.Y - my
        return
    end

    -- Tab clicks
    if isInside(pos, mx, my+HEADER_H, Menu.width, TAB_H) then
        local tabW = Menu.width / math.max(1, #Menu.tabs)
        local idx  = math.floor((pos.X - mx) / tabW) + 1
        idx = math.max(1, math.min(idx, #Menu.tabs))
        Menu.activeTab = idx
        Menu.openDropdown = nil
        renderFrame()
        return
    end

    -- Element clicks
    local tab = Menu.tabs[Menu.activeTab]
    if not tab then return end
    for _, sect in ipairs(tab.sections or {}) do
        for _, el in ipairs(sect.elements or {}) do

            if el.type == "toggle" and el._trackX then
                if isInside(pos, el._trackX-16, el._trackY-6, el._trackW+20, el._trackH+12) then
                    el.value = not el.value
                    if el.onChange then el.onChange(el.value) end
                    renderFrame(); return
                end
            end

            if el.type == "slider" and el._trackX then
                if isInside(pos, el._trackX, el._trackY-10, el._trackW, el._trackH+20) then
                    el._dragging = true; return
                end
            end

            if el.type == "dropdown" and el._btnX then
                if isInside(pos, el._btnX, el._btnY, el._btnW, el._btnH) then
                    Menu.openDropdown = (Menu.openDropdown == el) and nil or el
                    renderFrame(); return
                end
            end

            if el.type == "button" and el._btnX then
                if isInside(pos, el._btnX, el._btnY, el._btnW, el._btnH) then
                    if el.onClick then el.onClick() end
                    renderFrame(); return
                end
            end

            if el.type == "colorpicker" and el._swatches then
                for i, sw in pairs(el._swatches) do
                    if isInside(pos, sw.x, sw.y, sw.w, sw.h) then
                        el.value = i
                        if el.onChange then el.onChange(i) end
                        renderFrame(); return
                    end
                end
            end

        end
    end
end))

-- Mouse up
table.insert(connections, uis.InputEnded:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    Menu.dragging = false
    for _, tab in ipairs(Menu.tabs) do
        for _, sect in ipairs(tab.sections or {}) do
            for _, el in ipairs(sect.elements or {}) do
                if el.type == "slider" then el._dragging = false end
            end
        end
    end
end))

-- Mouse move
table.insert(connections, uis.InputChanged:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement then return end
    local pos = inp.Position

    if Menu.dragging then
        Menu.x = pos.X - Menu.dragOffX
        Menu.y = pos.Y - Menu.dragOffY
        renderFrame(); return
    end

    for _, tab in ipairs(Menu.tabs) do
        for _, sect in ipairs(tab.sections or {}) do
            for _, el in ipairs(sect.elements or {}) do
                if el.type == "slider" and el._dragging then
                    local pct  = math.max(0, math.min(1, (pos.X - el._trackX) / el._trackW))
                    local minV = el.min or 0
                    local maxV = el.max or 100
                    local step = el.step or 1
                    local raw  = minV + (maxV - minV) * pct
                    el.value   = math.max(minV, math.min(maxV, math.floor(raw/step+0.5)*step))
                    if el.onChange then el.onChange(el.value) end
                    renderFrame(); return
                end
            end
        end
    end
end))

-- Toggle keybind
table.insert(connections, uis.InputBegan:Connect(function(inp, gpe)
    if inp.KeyCode == Enum.KeyCode.RightShift then
        Menu.visible = not Menu.visible
        renderFrame()
    end
end))

-- ============================================================
-- PUBLIC API
-- ============================================================
local DrawLib = {}

function DrawLib.addTab(cfg)
    local t = { name=cfg.name or "Tab", icon=cfg.icon, sections={} }
    table.insert(Menu.tabs, t); return t
end
function DrawLib.addSection(tab, cfg)
    local s = { name=cfg.name or "Section", icon=cfg.icon, elements={} }
    table.insert(tab.sections, s); return s
end
function DrawLib.addToggle(s, cfg)
    local el = { type="toggle", name=cfg.name, desc=cfg.desc, value=cfg.default or false, onChange=cfg.onChange }
    table.insert(s.elements, el); return el
end
function DrawLib.addSlider(s, cfg)
    local el = { type="slider", name=cfg.name, min=cfg.min or 0, max=cfg.max or 100, value=cfg.default or cfg.min or 0, step=cfg.step or 1, suffix=cfg.suffix, onChange=cfg.onChange }
    table.insert(s.elements, el); return el
end
function DrawLib.addDropdown(s, cfg)
    local el = { type="dropdown", name=cfg.name, options=cfg.options or {}, value=cfg.default or 1, onChange=cfg.onChange }
    table.insert(s.elements, el); return el
end
function DrawLib.addButton(s, cfg)
    local el = { type="button", name=cfg.name, icon=cfg.icon, onClick=cfg.onClick }
    table.insert(s.elements, el); return el
end
function DrawLib.addLabel(s, cfg)
    local el = { type="label", name=cfg.name, size=cfg.size, color=cfg.color }
    table.insert(s.elements, el); return el
end
function DrawLib.addColorPicker(s, cfg)
    local el = { type="colorpicker", name=cfg.name, swatches=cfg.swatches, value=cfg.default or 1, onChange=cfg.onChange }
    table.insert(s.elements, el); return el
end
function DrawLib.destroy()
    for _, c in ipairs(connections) do c:Disconnect() end
    clearFrame()
end

-- ============================================================
-- BUILD THE MENU
-- ============================================================
local I = Icons

local espTab  = DrawLib.addTab({ name="ESP",    icon=I.eye })
local espSect = DrawLib.addSection(espTab, { name="Entity Visuals", icon=I.eye })
DrawLib.addToggle(espSect,     { name="Player ESP",   desc="Box + name labels", default=true })
DrawLib.addToggle(espSect,     { name="Murderer ESP", desc="Knife holder",      default=true })
DrawLib.addToggle(espSect,     { name="Coin ESP",     default=false })
DrawLib.addToggle(espSect,     { name="Sheriff ESP",  default=false })
DrawLib.addDropdown(espSect,   { name="ESP Style",    options={"Box","Corner Box","Skeleton","Dot"}, default=1 })
DrawLib.addColorPicker(espSect,{ name="ESP Color",    default=3 })

local distSect = DrawLib.addSection(espTab, { name="Distance & Filters", icon=I.map })
DrawLib.addSlider(distSect, { name="Max Distance", min=50,  max=1000, default=400, step=10, suffix="m" })
DrawLib.addSlider(distSect, { name="Text Size",    min=8,   max=24,   default=13,  step=1 })

local combatTab = DrawLib.addTab({ name="Combat", icon=I.crosshair })
local aimSect   = DrawLib.addSection(combatTab, { name="Aim Assist", icon=I.crosshair })
DrawLib.addToggle(aimSect,   { name="Aim Assist", default=false })
DrawLib.addSlider(aimSect,   { name="FOV",        min=10, max=250, default=80, step=5, suffix="°" })
DrawLib.addSlider(aimSect,   { name="Smoothness", min=1,  max=20,  default=6,  step=1 })
DrawLib.addDropdown(aimSect, { name="Target Priority", options={"Murderer Only","All Players","Nearest","Lowest HP"}, default=1 })
DrawLib.addToggle(aimSect,   { name="Silent Aim",  default=false })
DrawLib.addToggle(aimSect,   { name="Triggerbot",  default=false })

local playerTab = DrawLib.addTab({ name="Player", icon=I.user })
local movSect   = DrawLib.addSection(playerTab, { name="Movement", icon=I.zap })
DrawLib.addToggle(movSect, { name="Infinite Jump", default=false })
DrawLib.addToggle(movSect, { name="No Clip",       default=false })
DrawLib.addToggle(movSect, { name="Speed Hack",    default=false })
DrawLib.addSlider(movSect, {
    name="Walk Speed", min=16, max=200, default=16, step=2, suffix=" ws",
    onChange=function(v)
        local hum = game.Players.LocalPlayer.Character and
                    game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end
})
DrawLib.addSlider(movSect, {
    name="Jump Power", min=50, max=400, default=50, step=5,
    onChange=function(v)
        local hum = game.Players.LocalPlayer.Character and
                    game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end
})

local cfgTab  = DrawLib.addTab({ name="Config", icon=I.settings })
local cfgSect = DrawLib.addSection(cfgTab, { name="Configuration", icon=I.settings })
DrawLib.addLabel(cfgSect,  { name="Changes persist this session only.", color=Color3.fromRGB(100,100,120), size=11 })
DrawLib.addButton(cfgSect, { name="Save Config", icon=I.check, onClick=function() print("[MM2] Saved") end })
DrawLib.addButton(cfgSect, { name="Reset All",   icon=I.xmark, onClick=function() print("[MM2] Reset") end })

-- ============================================================
-- CLEANUP
-- ============================================================
game.Players.LocalPlayer.AncestryChanged:Connect(function()
    DrawLib.destroy()
end)

-- ============================================================
-- FIRST DRAW
-- ============================================================
renderFrame()
print("[MM2 Cheat] v"..CHEAT_VERSION.." ready. RightShift = toggle.")
