local awful = require('awful')

themehome = awful.util.getdir("config") .. "/theme"

theme = {}

theme.font          = "Monospace Bold 16"

theme.bg_normal     = "#222222"
theme.bg_focus      = "#535d6c"
theme.bg_urgent     = "#ff0000"
theme.bg_minimize   = "#444444"

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.border_width  = "2"
theme.border_normal = "#000000"
theme.border_focus  = "#ff1493"
theme.border_marked = "#91231c"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- [taglist|tasklist]_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Display the taglist squares
theme.taglist_squares_sel   = themehome .. "/taglist/squarefw.png"
theme.taglist_squares_unsel = themehome .. "/taglist/squarew.png"

theme.tasklist_floating_icon = themehome .. "/tasklist/floatingw.png"

-- Variables set for theming the menu:
-- menu_[bg|fg]_[normal|focus]
-- menu_[border_color|border_width]
theme.menu_submenu_icon = themehome .. "/submenu.png"
theme.menu_height = "15"
theme.menu_width  = "100"

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the image to load
theme.titlebar_close_button_normal = themehome .. "/titlebar/close_normal.png"
theme.titlebar_close_button_focus  = themehome .. "/titlebar/close_focus.png"

theme.titlebar_ontop_button_normal_inactive = themehome .. "/titlebar/ontop_normal_inactive.png"
theme.titlebar_ontop_button_focus_inactive  = themehome .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_active = themehome .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_active  = themehome .. "/titlebar/ontop_focus_active.png"

theme.titlebar_sticky_button_normal_inactive = themehome .. "/titlebar/sticky_normal_inactive.png"
theme.titlebar_sticky_button_focus_inactive  = themehome .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_active = themehome .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_active  = themehome .. "/titlebar/sticky_focus_active.png"

theme.titlebar_floating_button_normal_inactive = themehome .. "/titlebar/floating_normal_inactive.png"
theme.titlebar_floating_button_focus_inactive  = themehome .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_active = themehome .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_active  = themehome .. "/titlebar/floating_focus_active.png"

theme.titlebar_maximized_button_normal_inactive = themehome .. "/titlebar/maximized_normal_inactive.png"
theme.titlebar_maximized_button_focus_inactive  = themehome .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_active = themehome .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_active  = themehome .. "/titlebar/maximized_focus_active.png"

-- You can use your own command to set your wallpaper
theme.wallpaper = os.getenv("HOME") .. "/media/image/Anihonetwallpaper17746.jpg"

-- You can use your own layout icons like this:
theme.layout_fairh = themehome .. "/layouts/fairhw.png"
theme.layout_fairv = themehome .. "/layouts/fairvw.png"
theme.layout_floating  = themehome .. "/layouts/floatingw.png"
theme.layout_magnifier = themehome .. "/layouts/magnifierw.png"
theme.layout_max = themehome .. "/layouts/maxw.png"
theme.layout_fullscreen = themehome .. "/layouts/fullscreenw.png"
theme.layout_tilebottom = themehome .. "/layouts/tilebottomw.png"
theme.layout_tileleft   = themehome .. "/layouts/tileleftw.png"
theme.layout_tile = themehome .. "/layouts/tilew.png"
theme.layout_tiletop = themehome .. "/layouts/tiletopw.png"
theme.layout_spiral  = themehome .. "/layouts/spiralw.png"
theme.layout_dwindle = themehome .. "/layouts/dwindlew.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

theme.bg_systray = "#000000"

theme.danger_color = "#ff0000"
theme.warning_color = "#f5f500"
theme.success_color = "#3cbc3c"

return theme
