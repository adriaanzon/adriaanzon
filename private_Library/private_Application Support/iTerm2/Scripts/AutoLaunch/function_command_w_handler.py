#!/usr/bin/env python3
#
# Close Neovim when it is opened, otherwise close the iTerm tab. Relies on the
# 'title' option to be set in Neovim.
#
# This should be mapped to ⌘W in Preferences > Profiles > Keys. Add a new entry
# with the "Invoke Script Function" action, with value "command_w_handler()".

import asyncio
import iterm2
import re

async def main(connection):
    app = await iterm2.async_get_app(connection)

    @iterm2.RPC
    async def command_w_handler():
        session = app.current_terminal_window.current_tab.current_session

        if re.search(r"\b(NVIM|Nvim)\b", await session.async_get_variable('name')):
            # Send Command-W escape sequence.
            await session.async_send_text("\033[119;9u")
        else:
            # Close window like normal ⌘W.
            await asyncio.gather(session.async_close())

    await command_w_handler.async_register(connection)

iterm2.run_forever(main)
