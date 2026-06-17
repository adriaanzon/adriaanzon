-- Cmd+W in Ghostty with nvim: remap to F17 so Ghostty translates it
-- to CSI u sequence for <D-w>. Otherwise Cmd+W passes through normally.
cmdWTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    if event:getKeyCode() ~= 13 then return false end -- 13 = w
    if not event:getFlags().cmd then return false end

    local app = hs.application.frontmostApplication()
    if app and app:bundleID() == "com.mitchellh.ghostty" then
        local win = app:focusedWindow()
        if win and win:title():match(" - Nvim$") then
            event:setKeyCode(64) -- 64 = F17
            event:setFlags({})
        end
    end
    return false
end)
cmdWTap:start()

-- Ctrl+T in Firefox/Zen: transpose characters (standard macOS text editing).
-- These browsers don't support this Cocoa keybinding natively. We use the
-- accessibility API directly to avoid touching the clipboard. Requires
-- Firefox's accessibility engine to be enabled (about:config:
-- accessibility.force_disabled = -1).
ctrlTTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
    if event:getKeyCode() ~= 17 then return false end -- 17 = t
    local flags = event:getFlags()
    if not flags.ctrl or flags.cmd or flags.alt or flags.shift then return false end

    local app = hs.application.frontmostApplication()
    if not app then return false end
    local bid = app:bundleID()
    if bid ~= "org.mozilla.firefox" and bid ~= "app.zen-browser.zen" then return false end

    local appEl = hs.axuielement.applicationElement(app)
    local el = appEl and appEl:attributeValue("AXFocusedUIElement")
    if not el then return false end

    local range = el:attributeValue("AXSelectedTextRange")
    if not range then return false end

    local loc = range.loc or range.location
    local len = range.len or range.length
    if not loc or not len or len ~= 0 or loc < 1 then return false end

    local function mkRange(start, length)
        return { loc = start, len = length, location = start, length = length }
    end
    local function readChar(i)
        return el:parameterizedAttributeValue("AXStringForRange", mkRange(i, 1))
    end
    local function boundsAt(i)
        return el:parameterizedAttributeValue("AXBoundsForRange", mkRange(i, 1))
    end

    -- End-of-line detection: compare the on-screen Y coordinate of the char
    -- before the cursor and the char after the cursor. If they're on
    -- different visual lines (or there's no char after), the cursor is at
    -- end of line. This works across plain inputs, textareas, and editors
    -- like CodeMirror that expose each line as a separate AX text run with
    -- no \n character between them.
    local prevRect = boundsAt(loc - 1)
    local nextRect = boundsAt(loc)
    local function sameLine(a, b)
        if not a or not b then return false end
        local ay = (a.y or 0) + (a.h or 0) / 2
        local by = (b.y or 0) + (b.h or 0) / 2
        return math.abs(ay - by) < math.max(1, (a.h or 0) / 2)
    end
    -- First check for an explicit newline char (plain textareas): the
    -- newline's bounds rect often sits at the end of the current line, so
    -- the geometric check wouldn't catch it.
    local nextC = readChar(loc)
    local atEnd = (not nextC) or nextC == "" or nextC == "\n" or nextC == "\r"
    if not atEnd and prevRect and nextRect then
        atEnd = not sameLine(prevRect, nextRect)
    end

    local firstChar, secondChar
    if atEnd then
        if loc < 2 then return false end
        local prevPrevRect = boundsAt(loc - 2)
        if prevRect and prevPrevRect and not sameLine(prevPrevRect, prevRect) then
            return false
        end
        firstChar = readChar(loc - 2)
        secondChar = readChar(loc - 1)
    else
        firstChar = readChar(loc - 1)
        secondChar = readChar(loc)
    end
    if not firstChar or not secondChar or #firstChar == 0 or #secondChar == 0 then
        return false
    end
    if firstChar == "\n" or firstChar == "\r" or secondChar == "\n" or secondChar == "\r" then
        return false
    end

    if not atEnd then
        hs.eventtap.keyStroke({}, "right", 0)
    end
    hs.eventtap.keyStroke({}, "delete", 0)
    hs.eventtap.keyStroke({}, "delete", 0)
    hs.eventtap.keyStrokes(secondChar .. firstChar)
    return true
end)
ctrlTTap:start()

-- Toggle "System Settings > Trackpad > Tap to click" setting
local function toggleTapToClick()
    local currentSetting = hs.execute("defaults read com.apple.AppleMultitouchTrackpad Clicking")

    if currentSetting == "1\n" then
        hs.execute("defaults write com.apple.AppleMultitouchTrackpad Clicking -bool false")
    else
        hs.execute("defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true")
    end

    hs.execute("/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u")
end
hs.hotkey.bind({ "command", "option" }, ",", toggleTapToClick)

local function toggleApp(bundleID)
    return function()
        local app = hs.application.get(bundleID)
        if app and app:isFrontmost() then
            app:hide()
        else
            hs.application.launchOrFocusByBundleID(bundleID)
        end
    end
end

hs.hotkey.bind({ "ctrl", "cmd" }, "T", toggleApp("com.culturedcode.ThingsMac"))
hs.hotkey.bind({ "cmd" }, "J", toggleApp("com.mitchellh.ghostty"))
