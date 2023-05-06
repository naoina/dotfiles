local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet

local unimplemented = "-- TODO: not implemented yet"

return {
  s(
    { trig = "if" },
    fmta(
      [[
      if <cond> then<>
      end
      ]],
      {
        cond = i(1, { "cond" }),
        i(0, { "" }),
      }
    )
  ),

  s(
    { trig = "fn", name = "function" },
    fmta(
      [[
      function(<>)<>
      end
      ]],
      {
        i(1, { "" }),
        i(0, { "" }),
      }
    )
  ),

  s(
    { trig = "lfn", name = "local function" },
    fmta(
      [[
      local function <funcname>(<>)<>
      end
      ]],
      {
        funcname = i(1, { "funcname" }),
        i(2, { "" }),
        i(0, { "" }),
      }
    )
  ),

  ms({
    { trig = "l", name = "local" },
    { trig = "lo", name = "local" },
  }, fmta("local ", {})),

  s(
    { trig = "=", name = "local =" },
    fmta("<varname> = <value>", {
      varname = i(1, { "varname" }),
      value = i(2, { "value" }),
    })
  ),

  s({ trig = "r", name = "return" }, fmta("return <>", { i(1, { "" }) })),
  s(
    { trig = "req", name = "require" },
    fmta([[require("<modname>")]], {
      modname = i(1, { "modname" }),
    })
  ),

  s(
    { trig = "forr", name = "for-in" },
    fmta(
      [[
      for <_>, <v> in pairs(<table>) do<>
      end
      ]],
      {
        _ = i(1, { "_" }),
        v = i(2, { "v" }),
        table = i(3, { "table" }),
        i(0, { "" }),
      }
    )
  ),

  s(
    {
      trig = "p",
      name = "print(vim.inspect(v))",
      condition = function(line_to_cursor, matched_trigger)
        return line_to_cursor:match("^%s*" .. matched_trigger .. "$")
      end,
    },
    fmta("print(vim.inspect(<v>))", {
      v = i(1, { "v" }),
    })
  ),
}
