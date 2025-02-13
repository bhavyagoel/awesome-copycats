-- ]]
-- {{{ Required libraries
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type

-- Standard awesome library
local gears = require("gears") -- Utilities such as color parsing and objects
local awful = require("awful") -- Everything related to window managment
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")
local lain = require("lain")
local freedesktop = require("freedesktop")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
local hotkeys_popup = require("awful.hotkeys_popup").widget
require("awful.hotkeys_popup.keys")
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility
local dpi = require("beautiful.xresources").apply_dpi
-- }}}

-- {{{ Autostart windowless processes
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end

run_once({"unclutter -root"}) -- entries must be comma-separated
-- }}}

-- This function implements the XDG autostart specification
-- [[
awful.spawn.with_shell('if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
                           'xrdb -merge <<< "awesome.started:true";' ..
    -- list each of your autostart commands, followed by ; inside single quotes, followed by ..
                           'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
)
-- ]]

-- }}}

-- {{{ Variable definitions
-- steamburn is noice
local themes = {"multicolor", -- 1
"powerarrow", -- 2
"powerarrow-dark", -- 3
"blackburn", -- 4
"rainbow"}

-- choose your theme here
local chosen_theme = themes[3]

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)

-- modkey or mod4 = super key
local modkey = "Mod4"
local altkey = "Mod1"
local modkey1 = "Control"

-- personal variables
-- change these variables if you want
local browser1 = "google-chrome-stable"
local browser2 = "firefox"
local editorgui = "code"
local filemanager = "thunar"
local mediaplayer = "vlc"
local terminal = "alacritty"

-- awesome variables
awful.util.terminal = terminal
awful.util.tagnames = {"① ", "② ", "③ ", "④ ", "⑤ ", "⑥ ", "⑦ ", "⑧ ", "⑨ "}

awful.layout.suit.tile.left.mirror = true
awful.layout.layouts = {awful.layout.suit.tile}

awful.util.tasklist_buttons = my_table.join(awful.button({}, 1, function(c)
    if c == client.focus then
        c.minimized = true
    else
        c.minimized = true
        if not c:isvisible() and c.first_tag then
            c.first_tag:view_only()
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
    end
end), awful.button({}, 3, function()
    local instance = nil

    return function()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({
                theme = {
                    width = dpi(250)
                }
            })
        end
    end
end), awful.button({}, 4, function()
    awful.client.focus.byidx(1)
end), awful.button({}, 5, function()
    awful.client.focus.byidx(-1)
end))

beautiful.init(string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme))
-- }}}

-- {{{ Menu
local myawesomemenu = {{"hotkeys", function()
    return false, hotkeys_popup.show_help
end}, {"arandr", "arandr"}}

awful.util.mymainmenu = freedesktop.menu.build({
    before = {{"Awesome", myawesomemenu} -- { "Atom", "atom" },
    -- other triads can be put here
    },
    after = {{"Terminal", terminal}, {"Log out", function()
        awesome.quit()
    end}, {"Sleep", "systemctl suspend"}, {"Restart", "systemctl reboot"}, {"Shutdown", "systemctl poweroff"},
             {"Hibernate", "systemctl hibernate"} -- other triads can be put here
    }
})
-- hide menu when mouse leaves it
awful.util.mymainmenu.wibox:connect_signal("mouse::leave", function()
    awful.util.mymainmenu:hide()
end)

-- No borders when rearranging only 1 non-floating or maximized client
screen.connect_signal("arrange", function(s)
    local only_one = #s.tiled_clients == 1
    for _, c in pairs(s.clients) do
        if only_one and not c.floating or c.maximized then
            c.border_width = 2
        else
            c.border_width = beautiful.border_width
        end
    end
end)

-- Create a wibox for each screen and add it
awful.screen.connect_for_each_screen(function(s)
    beautiful.at_screen_connect(s)
    s.systray = wibox.widget.systray()
    s.systray.visible = true
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(my_table.join(awful.button({}, 3, function()
    awful.util.mymainmenu:toggle()
end), awful.button({}, 4, awful.tag.viewnext), awful.button({}, 5, awful.tag.viewprev)))
-- }}}

-- {{{ Key bindings
globalkeys = my_table.join( -- {{{ Personal keybindings
awful.key({modkey}, "w", function()
    awful.util.spawn(browser1)
end, {
    description = browser1,
    group = "function keys"
}), -- dmenu
awful.key({modkey}, "d", function()
    awful.spawn(string.format("dmenu_run -i -nb '#191919' -nf '#fea63c' -sb '#fea63c' -sf '#191919'",
        beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus))
end, {
    description = "show dmenu",
    group = "hotkeys"
}), -- Function keys
awful.key({}, "F12", function()
    awful.util.spawn("xfce4-terminal --drop-down")
end, {
    description = "dropdown terminal",
    group = "function keys"
}), -- Rofi Key Bindings
awful.key({modkey}, "F11", function()
    awful.util.spawn("rofi -show run -fullscreen")
end, {
    description = "rofi fullscreen",
    group = "function keys"
}), awful.key({modkey}, "d", function()
    awful.util.spawn("rofi -show run")
end, {
    description = "rofi",
    group = "function keys"
}), -- super + ...
awful.key({modkey}, "t", function()
    awful.util.spawn(terminal)
end, {
    description = "terminal",
    group = "Super"
}), awful.key({modkey}, "f", function()
    awful.util.spawn(filemanager)
end, {
    description = filemanager,
    group = "function keys"
}), -- ctrl + shift + ...
awful.key({modkey1, "Shift"}, "Escape", function()
    awful.util.spawn("xfce4-taskmanager")
end), -- ctrl+alt +  ...
awful.key({altkey}, "space", function()
    awful.util.spawn("xfce4-appfinder")
end, {
    description = "Xfce appfinder",
    group = "alt+Space"
}), awful.key({modkey1, altkey}, "i", function()
    awful.util.spawn("nitrogen")
end, {
    description = nitrogen,
    group = "alt+ctrl"
}), -- alt + ...
-- screenshots
awful.key({}, "Print", function()
    awful.util.spawn("xfce4-screenshooter")
end, {
    description = "Xfce screenshot",
    group = "screenshots"
}), -- super + shift + ...
awful.key({modkey}, "p", function()
    awful.spawn.with_shell("evince")
end, {
    description = "Open Evince PDF",
    group = "Super"
}), awful.key({modkey}, "c", function()
    awful.spawn.with_shell("google-chrome-stable")
end, {
    description = "Open Google Chrome ",
    group = "Super"
}), awful.key({modkey}, "e", function()
    awful.spawn.with_shell("emacs")
end, {
    description = "Open Emacs ",
    group = "Super"
}), awful.key({altkey}, "v", function()
    awful.spawn.with_shell("code")
end, {
    description = "Open VsCode ",
    group = "altkey"
}), -- Hotkeys Awesome
awful.key({modkey}, "s", hotkeys_popup.show_help, {
    description = "show help",
    group = "awesome"
}), -- Tag browsing with modkey
awful.key({modkey}, "Left", awful.tag.viewprev, {
    description = "view previous",
    group = "tag"
}), awful.key({modkey}, "Right", awful.tag.viewnext, {
    description = "view next",
    group = "tag"
}), awful.key({modkey}, "Escape", awful.tag.history.restore, {
    description = "go back",
    group = "tag"
}), -- By direction client focus with arrows
awful.key({modkey1, modkey}, "Down", function()
    awful.client.focus.global_bydirection("down")
    if client.focus then
        client.focus:raise()
    end
end, {
    description = "focus down",
    group = "client"
}), awful.key({modkey1, modkey}, "Up", function()
    awful.client.focus.global_bydirection("up")
    if client.focus then
        client.focus:raise()
    end
end, {
    description = "focus up",
    group = "client"
}), awful.key({modkey1, modkey}, "Left", function()
    awful.client.focus.global_bydirection("left")
    if client.focus then
        client.focus:raise()
    end
end, {
    description = "focus left",
    group = "client"
}), awful.key({modkey1, modkey}, "Right", function()
    awful.client.focus.global_bydirection("right")
    if client.focus then
        client.focus:raise()
    end
end, {
    description = "focus right",
    group = "client"
}), -- Layout manipulation
awful.key({modkey}, "j", function()
    awful.client.swap.byidx(1)
end, {
    description = "swap with next client by index",
    group = "client"
}), awful.key({modkey}, "k", function()
    awful.client.swap.byidx(-1)
end, {
    description = "swap with previous client by index",
    group = "client"
}), -- Show/Hide Wibox
awful.key({modkey}, "b", function()
    for s in screen do
        s.mywibox.visible = not s.mywibox.visible
        if s.mybottomwibox then
            s.mybottomwibox.visible = not s.mybottomwibox.visible
        end
    end
end, {
    description = "Toggle top menu bar",
    group = "awesome"
}), -- Show/Hide Systray
awful.key({modkey}, "-", function()
    awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
end, {
    description = "Toggle systray visibility",
    group = "awesome"
}), -- Show/Hide Systray
awful.key({modkey}, "KP_Subtract", function()
    awful.screen.focused().systray.visible = not awful.screen.focused().systray.visible
end, {
    description = "Toggle systray visibility",
    group = "awesome"
}), -- On the fly useless gaps change
awful.key({altkey, "Control"}, "j", function()
    lain.util.useless_gaps_resize(1)
end, {
    description = "increment useless gaps",
    group = "tag"
}), awful.key({altkey, "Control"}, "h", function()
    lain.util.useless_gaps_resize(-1)
end, {
    description = "decrement useless gaps",
    group = "tag"
}), -- Dynamic tagging
awful.key({modkey, "Shift"}, "n", function()
    lain.util.add_tag()
end, {
    description = "add new tag",
    group = "tag"
}), awful.key({modkey, "Control"}, "r", function()
    lain.util.rename_tag()
end, {
    description = "rename tag",
    group = "tag"
}), awful.key({modkey, "Shift"}, "Left", function()
    lain.util.move_tag(-1)
end, {
    description = "move tag to the left",
    group = "tag"
}), awful.key({modkey, "Shift"}, "Right", function()
    lain.util.move_tag(1)
end, {
    description = "move tag to the right",
    group = "tag"
}), awful.key({modkey, "Shift"}, "y", function()
    lain.util.delete_tag()
end, {
    description = "delete tag",
    group = "tag"
}), -- Standard program
awful.key({modkey, "Shift"}, "r", awesome.restart, {
    description = "reload awesome",
    group = "awesome"
}), awful.key({modkey, modkey1}, "h", function()
    awful.tag.incmwfact(-0.05)
end, {
    description = "increase master width factor",
    group = "layout"
}), awful.key({modkey, modkey1}, "j", function()
    awful.tag.incmwfact(0.05)
end, {
    description = "decrease master width factor",
    group = "layout"
}), awful.key({modkey, "Control"}, "k", function()
    awful.tag.incncol(1, nil, true)
end, {
    description = "increase the number of columns",
    group = "layout"
}), awful.key({modkey, "Control"}, "l", function()
    awful.tag.incncol(-1, nil, true)
end, {
    description = "decrease the number of columns",
    group = "layout"
}), awful.key({modkey, "Control"}, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        client.focus = c
        c:raise()
    end
end, {
    description = "restore minimized",
    group = "client"
}), -- Brightness
awful.key({}, "XF86MonBrightnessUp", function()
    awful.spawn.with_shell("brightnessctl s +10%")
end, {
    description = "+10%",
    group = "hotkeys"
}), awful.key({}, "XF86MonBrightnessDown", function()
    awful.spawn.with_shell("brightnessctl s 10%-")
end, {
    description = "-10%",
    group = "hotkeys"
}), awful.key({modkey1}, "Up", function()
    awful.spawn.with_shell("brightnessctl s +10%")
end, {
    description = "+10%",
    group = "hotkeys"
}), awful.key({modkey1}, "Down", function()
    awful.spawn.with_shell("brightnessctl s 10%-")
end, {
    description = "-10%",
    group = "hotkeys"
}), -- ALSA volume control
-- awful.key({ modkey1 }, "Up",
awful.key({}, "XF86AudioRaiseVolume", function()
    --    os.execute(string.format("pactl -- set-sink-volume 0 +1%", beautiful.volume.channel))
    awful.spawn.with_shell("pactl -- set-sink-volume 0 +5%")
    beautiful.volume.update()
end), -- awful.key({ modkey1 }, "Down",
awful.key({}, "XF86AudioLowerVolume", function()
    awful.spawn.with_shell("pactl -- set-sink-volume 0 -5%")
    beautiful.volume.update()
end), awful.key({}, "XF86AudioMute", function()
    os.execute(string.format("amixer -q set %s toggle", beautiful.volume.togglechannel or beautiful.volume.channel))
    beautiful.volume.update()
end), awful.key({modkey1, "Shift"}, "m", function()
    os.execute(string.format("amixer -q set %s 100%%", beautiful.volume.channel))
    beautiful.volume.update()
end), awful.key({modkey1, "Shift"}, "0", function()
    os.execute(string.format("amixer -q set %s 0%%", beautiful.volume.channel))
    beautiful.volume.update()
end), -- Media keys supported by vlc, spotify, audacious, xmm2, ...
awful.key({}, "XF86AudioPlay", function()
    awful.util.spawn("playerctl play-pause", false)
end), awful.key({}, "XF86AudioNext", function()
    awful.util.spawn("playerctl next", false)
end), awful.key({}, "XF86AudioPrev", function()
    awful.util.spawn("playerctl previous", false)
end), awful.key({}, "XF86AudioStop", function()
    awful.util.spawn("playerctl stop", false)
end), -- Media keys supported by mpd.
awful.key({}, "XF86AudioPlay", function()
    awful.util.spawn("mpc toggle")
end), awful.key({}, "XF86AudioNext", function()
    awful.util.spawn("mpc next")
end), awful.key({}, "XF86AudioPrev", function()
    awful.util.spawn("mpc prev")
end), awful.key({}, "XF86AudioStop", function()
    awful.util.spawn("mpc stop")
end))

clientkeys = my_table.join(awful.key({altkey, "Shift"}, "m", lain.util.magnify_client, {
    description = "magnify client",
    group = "client"
}), awful.key({modkey, "Shift"}, "q", function(c)
    c:kill()
end, {
    description = "close",
    group = "hotkeys"
}), awful.key({modkey}, "q", function(c)
    c:kill()
end, {
    description = "close",
    group = "hotkeys"
}), awful.key({modkey, "Shift"}, "space", awful.client.floating.toggle, {
    description = "toggle floating",
    group = "client"
}), awful.key({modkey}, "Return", function(c)
    c:swap(awful.client.getmaster())
end, {
    description = "move to master",
    group = "client"
}), awful.key({modkey}, "o", function(c)
    c:move_to_screen()
end, {
    description = "move to screen",
    group = "client"
}), awful.key({modkey}, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end, {
    description = "minimize",
    group = "client"
}), awful.key({modkey}, "v", function()
    awful.util.spawn("pavucontrol")
end, {
    description = "pulseaudio control",
    group = "Super"
}), awful.key({modkey}, "m", function(c)
    c.maximized = not c.maximized
    c:raise()
end, {
    description = "maximize",
    group = "client"
}))

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
    local descr_view, descr_toggle, descr_move, descr_toggle_focus
    if i == 1 or i == 9 then
        descr_view = {
            description = "view tag #",
            group = "tag"
        }
        descr_toggle = {
            description = "toggle tag #",
            group = "tag"
        }
        descr_move = {
            description = "move focused client to tag #",
            group = "tag"
        }
        descr_toggle_focus = {
            description = "toggle focused client on tag #",
            group = "tag"
        }
    end
    globalkeys = my_table.join(globalkeys, -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
            tag:view_only()
        end
    end, descr_view), -- Move client to tag.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then
                client.focus:move_to_tag(tag)
                tag:view_only()
            end
        end
    end, descr_move))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
end), awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.move(c)
end), awful.button({modkey}, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {
        raise = true
    })
    awful.mouse.client.resize(c)
end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = { -- All clients will match this rule.
{
    rule = {},
    properties = {
        border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        size_hints_honor = false
    }
}, -- Titlebars
{
    rule_any = {
        type = {"dialog", "normal"}
    },
    properties = {
        titlebars_enabled = false
    }
}, -- Set applications to be maximized at startup.
-- find class or role via xprop command
{
    rule = {
        class = editorgui
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "Geany"
    },
    properties = {
        maximized = false,
        floating = false
    }
}, {
    rule = {
        class = "Gimp*",
        role = "gimp-image-window"
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "Gnome-disks"
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "inkscape"
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = mediaplayer
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "Vlc"
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "VirtualBox Manager"
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "VirtualBox Machine"
    },
    properties = {
        maximized = true
    }
}, {
    rule = {
        class = "Vivaldi-stable"
    },
    properties = {
        maximized = false,
        floating = false
    }
}, {
    rule = {
        class = "Vivaldi-stable"
    },
    properties = {
        callback = function(c)
            c.maximized = false
        end
    }
}, {
    rule = {
        class = "Xfce4-settings-manager"
    },
    properties = {
        floating = false
    }
}, -- Floating clients.
{
    rule_any = {
        instance = {"DTA", -- Firefox addon DownThemAll.
        "copyq" -- Includes session name in class.
        },
        class = {"Arandr", "Arcolinux-welcome-app.py", "Blueberry", "Galculator", "Gnome-font-viewer", "Gpick",
                 "Imagewriter", "Font-manager", "Kruler", "MessageWin", -- kalarm.
        "arcolinux-logout", "Peek", "Skype", "System-config-printer.py", "Sxiv", "Unetbootin.elf", "Wpa_gui",
                 "pinentry", "veromix", "xtightvncviewer", "Xfce4-terminal"},

        name = {"Event Tester" -- xev.
        },
        role = {"AlarmWindow", -- Thunderbird's calendar.
        "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
        "Preferences", "setup"}
    },
    properties = {
        floating = true
    }
}, -- Floating clients but centered in screen
{
    rule_any = {
        class = {"Polkit-gnome-authentication-agent-1"}
    },
    properties = {
        floating = true
    },
    callback = function(c)
        awful.placement.centered(c, nil)
    end
}}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- Custom
    if beautiful.titlebar_fun then
        beautiful.titlebar_fun(c)
        return
    end

    -- Default
    -- buttons for the titlebar
    local buttons = my_table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {
            raise = true
        })
        awful.mouse.client.resize(c)
    end))

    awful.titlebar(c, {
        size = dpi(21)
    }):setup{
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

-- }}}
-- Autostart applications
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
beautiful.useless_gap = 0
client.connect_signal("focus", function(c)
    c.border_color = "#FF6347"
end)
awful.key({modkey}, "a", function()
    awful.layout.set(awful.layout.suit.corner.nw)
    for _, c in ipairs(client.get()) do
        if c.maximized then
            c.maximized = not c.maximized
            c:raise()
        end
    end
end, {
    description = "show all open windows of workspace",
    group = "client"
})
