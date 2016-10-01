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

-- Notification
naughty.config.defaults.timeout       = 0
naughty.config.defaults.screen        = 1
naughty.config.defaults.position      = "bottom_right"
naughty.config.defaults.margin        = 4
naughty.config.defaults.height        = 80
naughty.config.defaults.width         = 300
naughty.config.defaults.gap           = 1
naughty.config.defaults.ontop         = true
naughty.config.defaults.font          = beautiful.font or "Verdana 8"
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

local net_dev = "wlp1s0"
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
         awful.tag.viewonly(ctags[1])
      end
      -- And then focus the client
      client.focus = c
      c:raise()
      return
   end
   awful.util.spawn(cmd)
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

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(awful.util.getdir("config") .. "/theme/theme.lua")

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
local layouts =
{
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

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   -- { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
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
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

local separatorwidget = wibox.widget.textbox()
separatorwidget:set_markup(" <b>|</b> ")
local spacerwidget = wibox.widget.textbox()
spacerwidget:set_text(" ")

local timeformat = "%a %b %d %H:%M:%S"
local localtimewidget = wibox.widget.textbox()
local anothertimewidget = wibox.widget.textbox()

vicious.register(localtimewidget, vicious.widgets.date, timeformat .. " %Z", 1)
vicious.register(anothertimewidget, widgets.date, timeformat, 1, function () return timezone end)
timezonetextwidget = wibox.widget.textbox()
timezonewidget = wibox.widget.background(timezonetextwidget)
timezone_menu_items = {}
for i, v in ipairs({
    "America/Los_Angeles",
    "UTC",
    "Asia/Tokyo",
}) do
    table.insert(timezone_menu_items, { v,
        function ()
            timezone = v
            timezonetextwidget:set_text(widgets.date(" %Z ", timezone))
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
        font = "Monospace 12"
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
local cpumeterwidget = awful.widget.progressbar({
    width = 10,
})
cpumeterwidget:set_vertical(true)
cpumeterwidget:set_max_value(100)  -- percentage
cpumeterwidget:set_border_color(meter_border_color)
cpumeterwidget:set_background_color(meter_background_color)
vicious.register(cpupercentagewidget, vicious.widgets.cpu,
    function (widget, data)
        local total_percentage = data[1]
        local color
        if total_percentage < 70 then
            color = beautiful.fg_normal
            cpumeterwidget:set_color(meter_border_color)
        else
            color = beautiful.danger_color
            cpumeterwidget:set_color(beautiful.danger_color)
        end
        cpumeterwidget:set_value(total_percentage)
        return string.format("CPU <span color='%s'>%s%%</span>", color, total_percentage)
    end, 1)

local thermalwidget = wibox.widget.textbox()
vicious.register(thermalwidget, vicious.widgets.thermal, "$1C", 2, "thermal_zone0")

local memorymeterwidget = awful.widget.progressbar({
    width = 10,
})
memorymeterwidget:set_vertical(true)
memorymeterwidget:set_max_value(100)  -- percentage
memorymeterwidget:set_border_color(meter_border_color)
memorymeterwidget:set_background_color(meter_background_color)
local swapwidget = wibox.widget.textbox()
local memorypercentagewidget = wibox.widget.textbox()
vicious.register(memorypercentagewidget, vicious.widgets.mem,
    function (widget, data)
        used_percentage = data[1]
        local color
        if used_percentage < 70 then
            memorymeterwidget:set_color(meter_border_color)
            color = beautiful.fg_normal
        elseif used_percentage < 90 then
            memorymeterwidget:set_color(beautiful.warning_color)
            color = beautiful.warning_color
        else
            memorymeterwidget:set_color(beautiful.danger_color)
            color = beautiful.danger_color
        end
        memorymeterwidget:set_value(used_percentage)
        swapwidget:set_text(string.format("Swap %d/%dMB", data[6], data[7]))
        return string.format("Mem <span color='%s'>%d/%dMB</span>", color, data[2], data[3])
    end, 1)

local batterymeterwidget = awful.widget.progressbar({
    width = 10,
})
batterymeterwidget:set_vertical(true)
batterymeterwidget:set_max_value(100)  -- percentage
batterymeterwidget:set_border_color(meter_border_color)
batterymeterwidget:set_background_color(meter_background_color)
local batteryremainingwidget = wibox.widget.textbox()
local batterypercentagewidget = wibox.widget.textbox()
local battery_notified = false
vicious.register(batterypercentagewidget, vicious.widgets.bat,
    function (widget, data)
        local state = data[1]
        local battery_percentage = data[2]
        if battery_percentage <= 10 then
            batterymeterwidget:set_color(meter_warning_color)
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
                batterymeterwidget:set_color("#5fd700")
            else
                batterymeterwidget:set_color("#009700")
            end
        end
        batterymeterwidget:set_value(battery_percentage)
        batteryremainingwidget:set_text(data[3])
        return string.format("%d%%", battery_percentage)
    end, 10, "BAT1")

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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({
        position = "bottom",
        screen = s,
        bg = "#000000",
    })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    -- right_layout:add(mytasklist[s])
    right_layout:add(separatorwidget)
    right_layout:add(localtimewidget)
    right_layout:add(separatorwidget)
    right_layout:add(wifiwidget)
    right_layout:add(separatorwidget)
    right_layout:add(netwidget)
    right_layout:add(separatorwidget)
    right_layout:add(cpupercentagewidget)
    right_layout:add(spacerwidget)
    right_layout:add(cpumeterwidget)
    right_layout:add(spacerwidget)
    right_layout:add(thermalwidget)
    right_layout:add(separatorwidget)
    right_layout:add(memorypercentagewidget)
    right_layout:add(spacerwidget)
    right_layout:add(memorymeterwidget)
    right_layout:add(spacerwidget)
    right_layout:add(swapwidget)
    right_layout:add(separatorwidget)
    right_layout:add(batterypercentagewidget)
    right_layout:add(spacerwidget)
    right_layout:add(batterymeterwidget)
    right_layout:add(spacerwidget)
    right_layout:add(batteryremainingwidget)
    right_layout:add(separatorwidget)
    right_layout:add(anothertimewidget)
    right_layout:add(timezonewidget)
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    -- layout:set_middle(middle_layout)
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
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
    awful.key({ "Control",        }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control", "Shift" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "n",     function () awful.layout.inc(layouts,  1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey }, "p",
        function()
            awful.util.spawn("dmenu_run -b -nb '".. beautiful.bg_normal .."' -nf '".. beautiful.fg_normal .."' -sb '#955'")
        end),

    awful.key({}, "Print",
        function ()
            awful.util.spawn("shutter -s -e")
            -- awful.util.spawn("import -window root " .. os.getenv("HOME") .. "/media/screenshot/" .. os.date("%Y%m%d%H%M%S") .. ".png")
        end)
)

clientkeys = awful.util.table.join(
    -- awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
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
                     focus = true,
                     floating = true,
                     keys = clientkeys,
                     size_hints_honor = false,
                     buttons = clientbuttons } },
    { rule = { class = "dzen2" },
      properties = { sticky = true } },
    { rule = { class = "Eclipse" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Libreoffice" },
      properties = { tag = tags[1][8] } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][9], ontop = true } },
    { rule = { class = terminal_class },
      properties = { floating = false } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][6] } },
    { rule = { class = "chromium" },
      properties = { tag = tags[1][2], border_width = 0 } },
    { rule = { class = "Google-chrome" },
      properties = { tag = tags[1][2], border_width = 0 } },
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2], border_width = 0 } },
    { rule = { class = "Zeal" },
      properties = { tag = tags[1][9], border_width = 0 } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
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
        if c.class == terminal_class then
            c.opacity = 0.95
        end
    end)
client.connect_signal("unfocus",
    function(c)
        c.border_color = beautiful.border_normal
        if c.class == terminal_class then
            c.opacity = 0.85
        end
    end)
-- }}}

-- Startup applications
awful.util.spawn("compton")
awful.util.spawn("zeal")
