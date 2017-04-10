local setmetatable = setmetatable
local io = {
    popen = io.popen,
}
local date = {}

local function worker(format, warg)
    if type(warg) == "function" then
        warg = warg()
    end
    local f = io.popen(string.format("TZ=%s date '+%s'", warg, format))
    local d = f:read("*all")
    f:close()
    return d
end

return setmetatable(date, { __call = function(_, ...) return worker(...) end })
