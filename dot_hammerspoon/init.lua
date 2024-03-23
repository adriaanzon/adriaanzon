-- Switch menu bar clock to analog when only the MacBook's internal display is active.
local function toggleClockDisplay()
    local screens = hs.screen.allScreens()
    local clockShouldBeAnalog = #screens == 1 and screens[1]:name() == "Built-in Retina Display"
    os.execute("defaults write com.apple.menuextra.clock IsAnalog -bool " .. tostring(clockShouldBeAnalog))
end
hs.screen.watcher.new(toggleClockDisplay):start()
unlockWatcher = hs.caffeinate.watcher.new(function(eventType)
    if eventType == hs.caffeinate.watcher.screensDidUnlock
        or eventType == hs.caffeinate.watcher.systemDidWake then
        toggleClockDisplay()
    end
end)
unlockWatcher:start()
toggleClockDisplay()
