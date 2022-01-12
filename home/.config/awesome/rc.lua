-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local vicious = require("vicious")
local widgets = require("./widgets")

-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/theme/theme.lua")

-- Notification
naughty.config.defaults.timeout       = 0
naughty.config.defaults.screen        = 1
naughty.config.defaults.position      = "bottom_right"
naughty.config.defaults.margin        = 4
naughty.config.defaults.height        = 80
naughty.config.defaults.width         = 300
naughty.config.defaults.gap           = 1
naughty.config.defaults.ontop         = true
naughty.config.defaults.font          = beautiful.font or "Verdana 7"
naughty.config.defaults.icon          = nil
naughty.config.defaults.icon_size     = 16
-- naughty.config.defaults.fg            = beautiful.fg_focus or '#ffffff'
-- naughty.config.defaults.bg            = beautiful.bg_focus or '#535d6c'
-- naughty.config.defaults.border_color  = beautiful.border_focus or '#535d6c'
naughty.config.defaults.border_width  = 1
naughty.config.defaults.hover_timeout = nil
-- Urgency level specification
-- low
naughty.config.presets.low.timeout          = naughty.config.defaults.timeout
naughty.config.presets.low.height           = naughty.config.defaults.height
naughty.config.presets.low.width            = naughty.config.defaults.width
naughty.config.presets.low.position         = naughty.config.defaults.position
naughty.config.presets.low.font             = naughty.config.defaults.font
naughty.config.presets.critical.fg          = naughty.config.defaults.fg
naughty.config.presets.critical.bg          = naughty.config.defaults.bg
naughty.config.defaults.hover_timeout = naughty.config.defaults.hover_timeout
-- critical
naughty.config.presets.critical.timeout     = 0
naughty.config.presets.critical.height      = naughty.config.defaults.height
naughty.config.presets.critical.width       = naughty.config.defaults.width
naughty.config.presets.critical.position    = naughty.config.defaults.position
naughty.config.presets.critical.font        = naughty.config.defaults.font
naughty.config.presets.critical.fg          = '#eeeeee'
naughty.config.presets.critical.bg          = '#ff0000'

local timezone = ""

--- Spawns cmd if no client can be found matching properties
-- If such a client can be found, pop to first tag where it is visible, and give it focus
-- @param cmd the command to execute
-- @param properties a table of properties to match against clients. Possible entries: any properties of the client object
function run_or_raise(cmd, properties)
   local clients = client.get()
   local focused = awful.client.next(0)
   local findex = 0
   local matched_clients = {}
   local n = 0
   for i, c in pairs(clients) do
      --make an array of matched clients
      if match(properties, c) then
         n = n + 1
         matched_clients[n] = c
         if c == focused then
            findex = n
         end
      end
   end
   if n > 0 then
      local c = matched_clients[1]
      -- if the focused window matched switch focus to next in list
      if 0 < findex and findex < n then
         c = matched_clients[findex+1]
      end
      local ctags = c:tags()
      if table.getn(ctags) == 0 then
         -- ctags is empty, show client on current tag
         local curtag = awful.tag.selected()
         awful.client.movetotag(curtag, c)
      else
         -- Otherwise, pop to first tag client is visible on
         ctags[1]:view_only()
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end
   awful.spawn(cmd)
end

-- Returns true if all pairs in table1 are present in table2
function match(table1, table2)
   for k, v in pairs(table1) do
      if table2[k] ~= v and not table2[k]:find(v) then
         return false
      end
   end
   return true
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

-- This is used later as the default terminal and editor to run.
terminal = "mlterm -e " .. os.getenv("HOME") .. "/bin/tmux.sh"
terminal_class = "mlterm"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = "xterm -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.tile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier
    -- awful.layout.suit.floating,
}
-- }}}

local function client_menu_toggle_fn()
    local instance = nil

    return function ()
        if instance and instance.wibox.visible then
            instance:hide()
            instance = nil
        else
            instance = awful.menu.clients({ theme = { width = 250 } })
        end
    end
end

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   -- { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox

-- Create a wibox for each screen and add it
local taglist_buttons = awful.util.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                    )
local tasklist_buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() and c.first_tag then
                                                      c.first_tag:view_only()
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, client_menu_toggle_fn()),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local separatorwidget = wibox.widget.textbox()
separatorwidget:set_markup(" <b>|</b> ")
local spacerwidget = wibox.widget.textbox()
spacerwidget.text = " "

local timeformat = "%a %b %d %H:%M:%S"
local localtimewidget = wibox.widget.textbox()
local anothertimewidget = wibox.widget.textbox()

vicious.register(localtimewidget, vicious.widgets.date, timeformat .. " %Z", 1)
vicious.register(anothertimewidget, widgets.date, timeformat, 1, function () return timezone end)
timezonetextwidget = wibox.widget.textbox()
timezonewidget = wibox.container.background(timezonetextwidget)
timezone_menu_items = {}
for i, v in ipairs({
    "America/Los_Angeles",
    "UTC",
    "Asia/Tokyo",
}) do
    table.insert(timezone_menu_items, { v,
        function ()
            timezone = v
            timezonetextwidget.text = widgets.date(" %Z ", timezone)
            timezonewidget:set_fg(beautiful.fg_normal)
            timezonewidget:set_bg(beautiful.bg_systray)
        end
    })
end
timezone_menu_items[1][2]()
timezone_menu = awful.menu({
    items = timezone_menu_items,
    theme = {
        width = 200,
        font = "Monospace 7"
    }
})
timezonewidget:buttons(
    awful.button({}, 1,
        function ()
            local fg = timezonewidget.foreground
            timezonewidget.foreground = timezonewidget.background
            timezonewidget:set_bg(fg)
        end,
        function ()
        end)
)
timezonewidget:buttons(
    awful.util.table.join(
        timezonewidget:buttons(),
        awful.button({}, 1, nil, function () timezone_menu:toggle() end)))

local meter_border_color = "#777777"
local meter_background_color = "#000000"

local cpupercentagewidget = wibox.widget.textbox()
local cpumeterwidget = wibox.widget {
    {
        max_value = 100, -- percentage
        border_color = meter_border_color,
        background_color = meter_background_color,
        widget = wibox.widget.progressbar,
    },
    forced_width = 10,
    direction = "east",
    layout = wibox.container.rotate,
}
vicious.register(cpupercentagewidget, vicious.widgets.cpu,
    function (widget, data)
        local total_percentage = data[1]
        local color
        local meter_widget = cpumeterwidget:get_widget()
        if total_percentage < 70 then
            color = beautiful.fg_normal
            meter_widget:set_color(meter_border_color)
        else
            color = beautiful.danger_color
            meter_widget:set_color(beautiful.danger_color)
        end
        meter_widget:set_value(total_percentage)
        return string.format("CPU <span color='%s'>%s%%</span>", color, total_percentage)
    end, 1)

local thermalwidget = wibox.widget.textbox()
vicious.register(thermalwidget, vicious.widgets.thermal, "$1C", 2, "thermal_zone0")

local memorymeterwidget = wibox.widget {
    {
        max_value = 100, -- percentage
        border_color = meter_border_color,
        background_color = meter_background_color,
        widget = wibox.widget.progressbar,
    },
    forced_width = 10,
    direction = "east",
    layout = wibox.container.rotate,
}
local swapwidget = wibox.widget.textbox()
local memorypercentagewidget = wibox.widget.textbox()
vicious.register(memorypercentagewidget, vicious.widgets.mem,
    function (widget, data)
        used_percentage = data[1]
        local color
        local meter_widget = memorymeterwidget:get_widget()
        if used_percentage < 70 then
            meter_widget:set_color(meter_border_color)
            color = beautiful.fg_normal
        elseif used_percentage < 90 then
            meter_widget:set_color(beautiful.warning_color)
            color = beautiful.warning_color
        else
            meter_widget:set_color(beautiful.danger_color)
            color = beautiful.danger_color
        end
        meter_widget:set_value(used_percentage)
        swapwidget.text = string.format("Swap %d/%dMB", data[6], data[7])
        return string.format("Mem <span color='%s'>%d/%dMB</span>", color, data[2], data[3])
    end, 1)

local batterymeterwidget = wibox.widget {
    {
        max_value = 100, -- percentage
        border_color = meter_border_color,
        background_color = meter_background_color,
        widget = wibox.widget.progressbar,
    },
    forced_width = 10,
    direction = "east",
    layout = wibox.container.rotate,
}

local battery_dir = "/sys/class/power_supply"
local dir = io.popen("ls " .. battery_dir)
local bat = "BAT1"
for d in dir:lines() do
    local f = io.open(battery_dir .. "/" .. d .. "/type")
    local candidate = f:read("*line")
    f:close()
    if candidate == "Battery" then
        bat = d
        break
    end
end
dir:close()
local batteryremainingwidget = wibox.widget.textbox()
local batterypercentagewidget = wibox.widget.textbox()
function timer_start_new(timeout, callback)
    local t = gears.timer.new({ timeout = timeout })
    t:connect_signal("timeout", function()
        local cont = gears.protected_call(callback)
        if not cont then
            t:stop()
        end
    end)
    t:start()
    t:emit_signal("timeout")
    return t
end
timer_start_new(
    5, -- sec
    function()
        local readable, _ = pcall(
            function()
            end)
        local f = io.open(battery_dir .. "/" .. bat .. "/power_now")
        local _, err, _ = f:read("*all")
        f:close()
        if err then
            return true
        end
        local battery_notified = false
        vicious.register(batterypercentagewidget, vicious.widgets.bat,
            function (widget, data)
                local state = data[1]
                local battery_percentage = data[2]
                local meter_widget = batterymeterwidget:get_widget()
                if battery_percentage <= 5 then
                    if state == "-" then -- Discharging
                        awesome.emit_signal("battery::threshold")
                    end
                elseif battery_percentage <= 10 then
                    meter_widget:set_color(meter_warning_color)
                    if not battery_notified then
                        naughty.notify({
                            title = "Low battery notification",
                            text = string.format("A current battery remaining is %d%%.\nIncidentally, lower than 5%% will immediatelly go to hibernate mode.", battery_percentage),
                            preset = naughty.config.presets.critical,
                        })
                        battery_notified = true
                    end
                else
                    battery_notified = false
                    if battery_percentage <= 30 then
                        meter_widget:set_color("#5fd700")
                    else
                        meter_widget:set_color("#009700")
                    end
                end
                meter_widget:set_value(battery_percentage)
                batteryremainingwidget.text = data[3]
                return string.format("%d%%", battery_percentage)
            end, 10, bat)
        return false
    end)

local net_dir = "/sys/class/net"
local dir = io.popen("ls " .. net_dir)
local net_dev = "wlan0"
for d in dir:lines() do
    local f = io.open(net_dir .. "/" .. d .. "/wireless")
    if f then
        f:close()
        net_dev = d
    end
end
dir:close()
local wifiwidget = wibox.widget.textbox()
vicious.register(wifiwidget, widgets.wifi,
    function (widget, data)
        local linp = data["{linp}"]
        local ssid = data["{ssid}"]
        local ip = data["{ip}"]
        if linp == 0 and ssid == "N/A" then
            return string.format("W: <span color='%s'>down</span>", beautiful.danger_color)
        end
        local color = beautiful.danger_color
        if ip ~= "N/A" then
            color = beautiful.success_color
        end
        return string.format("W: <span color='%s'>(%s%% at %s) %s</span>", color, data["{linp}"], data["{ssid}"], data["{ip}"])
    end, 1, net_dev)

local netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
    function (widget, data)
        local up = tonumber(data["{"..net_dev.." up_kb}"])
        local down = tonumber(data["{"..net_dev.." down_kb}"])
        local up_unit = "K"
        local down_unit = "K"
        if up > 1024^2 then
            up = data["{"..net_dev.." up_mb}"]
            up_unit = "M"
        elseif up > 1024^3 then
            up = data["{"..net_dev.." up_gb}"]
            up_unit = "G"
        else
            up = data["{"..net_dev.." up_kb}"]
        end

        if down > 1024^2 then
            down = data["{"..net_dev.." down_mb}"]
            down_unit = "M"
        elseif down > 1024^3 then
            down = data["{"..net_dev.." down_gb}"]
            down_unit = "G"
        else
            down = data["{"..net_dev.." down_kb}"]
        end
        local uarr = "&#8593;"
        local darr = "&#8595;"
        return string.format("%s%s/s%s %s%s/s%s", up, up_unit, uarr, down, down_unit, darr)
    end, 1)

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true, { y = -beautiful.menu_height - 10 })
    end
end

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "bottom",
        screen = s,
        bg = "#000000",
    })

    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        { -- Middle widgets
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            separatorwidget,
            localtimewidget,
            separatorwidget,
            wifiwidget,
            separatorwidget,
            netwidget,
            separatorwidget,
            cpupercentagewidget,
            spacerwidget,
            cpumeterwidget,
            spacerwidget,
            thermalwidget,
            separatorwidget,
            memorypercentagewidget,
            spacerwidget,
            memorymeterwidget,
            spacerwidget,
            swapwidget,
            separatorwidget,
            batterypercentagewidget,
            spacerwidget,
            batterymeterwidget,
            spacerwidget,
            batteryremainingwidget,
            separatorwidget,
            anothertimewidget,
            timezonewidget,
            wibox.widget.systray(),
            s.mylayoutbox,
        }
    })
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "j",
        function ()
            i = awful.layout.get(mouse.screen) == awful.layout.suit.tile.bottom and -1 or 1
            awful.client.focus.byidx(i)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            i = awful.layout.get(mouse.screen) == awful.layout.suit.tile.bottom and 1 or -1
            awful.client.focus.byidx(i)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",
        function ()
            i = awful.layout.get(mouse.screen) == awful.layout.suit.tile.bottom and -1 or 1
            awful.client.swap.byidx(i)
        end),
    awful.key({ modkey, "Shift"   }, "k",
        function ()
            i = awful.layout.get(mouse.screen) == awful.layout.suit.tile.bottom and 1 or -1
            awful.client.swap.byidx(i)
        end),
    awful.key({ modkey, }, "w", function () awful.screen.focus(1) end),
    awful.key({ modkey, }, "e", function () awful.screen.focus(2) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,        }, "Return", function () awful.spawn(terminal) end),
    awful.key({ modkey, "Control", "Shift" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end),
    awful.key({ modkey,           }, "n",     function () awful.layout.inc( 1)                end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "p",
        function()
            awful.spawn("dmenu_run -b -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'")
        end),

    awful.key({}, "Print",
        function ()
            awful.spawn("shutter -s -e")
            -- awful.util.spawn("import -window root " .. os.getenv("HOME") .. "/media/screenshot/" .. os.date("%Y%m%d%H%M%S") .. ".png")
        end)
)

clientkeys = awful.util.table.join(
    -- awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "space",  function (c) c.floating = not c.floating      end),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    -- awful.key({ modkey,           }, "n",
        -- function (c)
            -- -- The client currently has the input focus, so it cannot be
            -- -- minimized, since minimized clients can't have the focus.
            -- c.minimized = true
        -- end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                            tag:view_only()
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                          awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          if client.focus then
                              local tag = client.focus.screen.tags[i]
                              if tag then
                                  client.focus:toggle_tag(tag)
                              end
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = 1,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     floating = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap + awful.placement.no_offscreen,
     }
    },
    { rule = { class = "dzen2" },
      properties = { sticky = true } },
    { rule = { class = "Eclipse" },
      properties = { screen = 1, tag = "5" } },
    { rule = { class = "Libreoffice" },
      properties = { screen = 1, tag = "8" } },
    { rule = { class = "Skype" },
      properties = { screen = 1, tag = "9", ontop = true } },
    { rule = { name = terminal_class },
      properties = { floating = false } },
    { rule = { class = "VirtualBox" },
      properties = { screen = 1, tag = "6" } },
    { rule = { class = "Chromium" },
      properties = { screen = 1, tag = "2", border_width = 0 } },
    { rule = { class = "Google-chrome" },
      properties = { screen = 1, tag = "2", border_width = 0 } },
    { rule = { class = "Firefox" },
      properties = { screen = 1, tag = "2", border_width = 0 } },
    { rule = { class = "Zeal" },
      properties = { screen = 1, tag = "9", border_width = 0, floating = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not awesome.startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus",
    function(c)
        c.border_color = beautiful.border_focus
        if c.name == terminal_class then
            c.opacity = 0.90
        end
    end)
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
        if c.name == terminal_class then
            c.opacity = 0.85
        end
    end)
-- }}}

awesome.connect_signal("battery::threshold",
    function()
        awful.spawn("systemctl hibernate")
    end)

-- Startup applications
if awesome.startup then
    awful.spawn("picom")
    awful.spawn("zeal")
end
