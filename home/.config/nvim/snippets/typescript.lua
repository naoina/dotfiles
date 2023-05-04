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

local unimplemented = "// TODO: not implemented yet"

return {
  s(
    { trig = "for" },
    fmta(
      [[
      for (let <i> = 0; <i> << <n>; ++<i>) {
        <unimplemented>
      }
      ]],
      {
        i = i(1, { "i" }),
        n = i(2, { "n" }),
        unimplemented = i(3, { unimplemented }),
      },
      {
        repeat_duplicates = true,
      }
    )
  ),

  s(
    { trig = "forr", name = "for-of" },
    fmta(
      [[
      for (const <v> of <arr>) {
        <unimplemented>
      }
      ]],
      {
        v = i(1, { "v" }),
        arr = i(2, { "arr" }),
        unimplemented = i(3, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "if" },
    fmta(
      [[
      if (<cond>) {
        <unimplemented>
      }
      ]],
      {
        cond = i(1, { "cond" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "fn", name = "function" },
    fmta(
      [[
      function <funcName>(<>): Promise<<<type>>> {
        <unimplemented>
      }
      ]],
      {
        funcName = i(1, { "funcName" }),
        i(2, { "" }),
        type = i(3, { "string" }),
        unimplemented = { unimplemented },
      }
    )
  ),

  s(
    { trig = "f>", name = "() => {}" },
    fmta(
      [[
      (<>) =>> {
        <unimplemented>
      }
      ]],
      {
        i(1, { "" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s({ trig = "r", name = "return" }, fmta("return <>;", { i(0, { "" }) })),
  s({ trig = "log", name = "console.log" }, fmta("console.log(<>);", { i(1, { "" }) })),
  s({ trig = "err", name = "console.error" }, fmta("console.error(<>);", { i(1, { "" }) })),

  s(
    { trig = "de", name = "describe" },
    fmta(
      [[
      describe('<describe>', () =>> {
        <unimplemented>
      });
      ]],
      {
        describe = i(1, { "describe" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "test" },
    fmta(
      [[
      test("should <>", async () =>> {
        <unimplemented>
      });
      ]],
      {
        i(1, { "" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "be", name = "beforeEach" },
    fmta(
      [[
      beforeEach(async () =>> {
        <unimplemented>
      });
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "af", name = "afterEach" },
    fmta(
      [[
      afterEach(async () =>> {
        <unimplemented>
      });
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s({ trig = "co", name = "const" }, fmta("const ", {})),
  s(
    { trig = "as", name = "assert" },
    fmta("assert(<expected> === <actual>);", {
      expected = i(1, { "expected" }),
      actual = i(2, { "actual" }),
    })
  ),

  s(
    { trig = "try", name = "try-catch" },
    fmta(
      [[
      try {
        <>
      } catch (err) {
        <>
      }
      ]],
      {
        i(1, { "" }),
        i(2, { "" }),
      }
    )
  ),

  s(
    { trig = "class" },
    fmta(
      [[
      class <ClassName> {
        constructor() {
        }
      }
      ]],
      {
        ClassName = i(1, { "ClassName" }),
      }
    )
  ),

  s(
    { trig = "m", name = "method" },
    fmta(
      [[
      <methodName>(<>): Promise<<<type>>> {
        <unimplemented>
      }
      ]],
      {
        methodName = i(1, { "methodName" }),
        i(2, { "" }),
        type = i(3, { "string" }),
        unimplemented = i(4, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "sw", name = "switch" },
    fmta(
      [[
      switch (<cond>) {
        <unimplemented>
      }
      ]],
      {
        cond = i(1, { "cond" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),
}
