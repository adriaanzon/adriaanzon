-- Switch menu bar clock to analog when only the MacBook's internal display is active.
local function toggleClockDisplay()
    local screens = hs.screen.allScreens()
    local clockShouldBeAnalog = #screens == 1 and screens[1]:name() == "Built-in Retina Display"

    os.execute("defaults write com.apple.menuextra.clock IsAnalog -bool " .. tostring(clockShouldBeAnalog))
end
hs.screen.watcher.new(toggleClockDisplay):start()
