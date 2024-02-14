-- Remap § to `
hs.hotkey.bind({}, "§", function() hs.eventtap.keyStroke({}, "`") end )
hs.hotkey.bind({ "cmd" }, "§", function() hs.eventtap.keyStroke({ "cmd" }, "`") end )
hs.hotkey.bind({ "shift" }, "§", function() hs.eventtap.keyStroke({ "shift" }, "`") end )
hs.hotkey.bind({ "cmd", "shift" }, "§", function() hs.eventtap.keyStroke({ "cmd", "shift" }, "`") end )
