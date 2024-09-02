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
