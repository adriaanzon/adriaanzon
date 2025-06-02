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

-- URL handler for predefined terminal commands. This allows displaying
-- hyperlinks in iTerm2 that execute commands when clicked.
hs.urlevent.bind("iTermCommand", function(eventName, params, senderPID)
    -- First, verify that the sender is iTerm2
    if hs.application.applicationForPID(senderPID):bundleID() ~= "com.googlecode.iterm2" then
        return
    end

    -- Switch focus from Hammerspoon to iTerm2
    hs.application.launchOrFocus("iTerm")

    -- Execute one of the predefined commands
    if params.command == "brewOutdated" then
        hs.eventtap.keyStrokes("brew outdated | column")
        hs.eventtap.keyStroke({}, "return")
    end
end)
