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
