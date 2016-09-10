local setmetatable = setmetatable
local wrequire = require("vicious.helpers").wrequire

local widgets = { _NAME = "widgets" }

return setmetatable(widgets, { __index = wrequire })
