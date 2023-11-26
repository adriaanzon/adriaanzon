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

        # TODO: Also detect Vim on SSH connections. On Ubuntu and Debian, the
        # 'ruler' option is enabled by default, so I could check if the bottom
        # right corner matches "All", "Top", "Bot" or "\d+%".
        if re.search(r"\bNVIM\b", await session.async_get_variable('name')):
            # Send CTRL-W_CTRL-Q sequence.
            await session.async_send_text("\x17\x11")
        else:
            # Close window like normal ⌘W.
            await asyncio.gather(session.async_close())

    await command_w_handler.async_register(connection)

iterm2.run_forever(main)
