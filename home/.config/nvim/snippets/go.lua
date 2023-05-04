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
    { trig = "main", name = "func main()" },
    fmta(
      [[
      func main() {
          <unimplemented>
      }
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "init", name = "func init()" },
    fmta(
      [[
      func init() {
          <unimplemented>
      }
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "v", name = "var" },
    fmta("var <name> <type>", {
      name = i(1, { "name" }),
      type = i(2, { "string" }),
    })
  ),

  s({ trig = "co", name = "const" }, fmta("const ", {})),

  s(
    { trig = "=" },
    fmta("<name> <assign> <value>", {
      name = i(1, { "name" }),
      assign = f(function()
        local line = vim.api.nvim_get_current_line()
        return line:match("^s*const%s") and "=" or ":="
      end),
      value = i(2, { "value" }),
    })
  ),

  s(
    { trig = "," },
    fmta("<>, <>", {
      i(1, { "_" }),
      i(2, { "err" }),
    })
  ),

  s(
    { trig = "for" },
    fmta(
      [[
      for <cond> {
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
    { trig = "forr", name = "for _, v := range ..." },
    fmta(
      [[
      for <key>, <value> := range <collection> {
          <unimplemented>
      }
      ]],
      {
        key = i(2, { "_" }),
        value = i(3, { "v" }),
        collection = i(1, { "collection" }),
        unimplemented = i(4, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "fori", name = "for i := 0; i < n; i++" },
    fmta(
      [[
      for <i> := 0; <i> << <n>; <i>++ {
          <unimplemented>
      }
      ]],
      {
        i = i(2, { "i" }),
        n = i(1, { "n" }),
        unimplemented = i(3, { unimplemented }),
      },
      {
        repeat_duplicates = true,
      }
    )
  ),

  s(
    { trig = "if" },
    fmta(
      [[
      if <cond> {
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
    { trig = "ife", name = "if err != nil" },
    fmta(
      [[
      if err != nil {
          <unimplemented>
      }
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "ifo", name = "if !ok" },
    fmta(
      [[
      if !ok {
          <unimplemented>
      }
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "ifel", name = "if err := fn(); err != nil" },
    fmta(
      [[
      if <err> := <fn>; err != <nil> {
          <unimplemented>
      }
      ]],
      {
        err = i(1, { "err" }),
        fn = i(2, { "fn()" }),
        ["nil"] = i(3, { "nil" }),
        unimplemented = i(4, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "f", name = "func" },
    fmta(
      [[
      func <FuncName>(<>) <>{
          <unimplemented>
      }
      ]],
      {
        FuncName = i(1, { "FuncName" }),
        i(2, { "" }),
        i(3, { "" }),
        unimplemented = i(4, { unimplemented }),
      }
    )
  ),
  s({ trig = "fn", name = "func()" }, {
    d(1, function()
      local line = vim.api.nvim_get_current_line()
      local parenthesis = line:match("^%s*$") and "()" or ""
      return sn(
        nil,
        fmta([[
          func() {
              <unimplemented>
          }]] .. parenthesis, {
          unimplemented = i(1, { unimplemented }),
        })
      )
    end),
  }),

  s(
    { trig = "fne", name = "func() error" },
    fmta(
      [[
      func() error {
          <unimplemented>
      }
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "go", name = "go func()" },
    fmta(
      [[
      go func() {
          <unimplemented>
      }()
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s(
    {
      trig = "m",
      name = "method",
      condition = function(line_to_cursor, matched_trigger)
        return line_to_cursor:match("^%s*" .. matched_trigger .. "$")
      end,
      show_condition = function()
        return false
      end,
    },
    fmta(
      [[
      func (<receiver>) <MethodName>(<>) <>{
          <unimplemented>
      }
      ]],
      {
        receiver = i(1, { "r" }),
        MethodName = i(2, { "MethodName" }),
        i(3, { "" }),
        i(4, { "" }),
        unimplemented = i(5, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "type" },
    fmta("type <name> <type>", {
      name = i(1, { "name" }),
      type = i(2, { "type" }),
    })
  ),

  s(
    { trig = "t", name = "type ... struct" },
    fmta(
      [[
      type <name> struct {
          <unimplemented>
      }
      ]],
      {
        name = i(1, { "name" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "ti", name = "type ... interface" },
    fmta(
      [[
      type <name> interface {
          <unimplemented>
      }
      ]],
      {
        name = i(1, { "name" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "sw", name = "switch" },
    fmta(
      [[
      switch <expr> {
      case <cond>:
          <unimplemented>
      }
      ]],
      {
        expr = i(1, { "expr" }),
        cond = i(2, { "cond" }),
        unimplemented = i(3, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "sel", name = "select" },
    fmta(
      [[
      select {
      case <<-<ch>:
          <unimplemented>
      }
      ]],
      {
        ch = i(1, { "ch" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "p", name = "fmt.Printf" },
    fmta([[fmt.Printf("%+v\n", <>)]], {
      i(0, { "" }),
    })
  ),

  s(
    { trig = "ft", name = "func TestXxx" },
    fmta(
      [[
      func Test<Xxx>(t *testing.T) {
          t.Error("pending")
      }
      ]],
      {
        Xxx = i(1, { "Xxx" }),
      }
    )
  ),

  s(
    { trig = "ftm", name = "func TestMain" },
    fmta(
      [[
      func TestMain(m *testing.M) {
          os.Exit(func() int {
              return m.Run()
          })
      }
      ]],
      {}
    )
  ),

  s(
    { trig = "tr", name = "t.Run" },
    fmta(
      [[
      t.Run(fmt.Sprintf("%v", <v>), func(t *testing.T) {
          <unimplemented>
      })
      ]],
      {
        v = i(1, { "v" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "fb", name = "func BenchmarkXxx" },
    fmta(
      [[
      func Benchmark<Xxx>(b *testing.B) {
          for i := 0; i << b.N; i++ {
              <unimplemented>
          }
      }
      ]],
      {
        Xxx = i(1, { "Xxx" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "fe", name = "func ExampleXxx" },
    fmta(
      [[
      func Example<Xxx>() {
          <unimplemented>
      }
      ]],
      {
        Xxx = i(1, { "Xxx" }),
        unimplemented = i(2, { unimplemented }),
      }
    )
  ),

  s(
    { trig = "rec", name = "if err := recover(); err != nil" },
    fmta(
      [[
      if err := recover(); err != nil {
          <panic>
      }
      ]],
      {
        panic = i(1, { "panic(err)" }),
      }
    )
  ),

  s(
    { trig = "def", name = "defer func()" },
    fmta(
      [[
      defer func() {
          <unimplemented>
      }()
      ]],
      {
        unimplemented = i(0, { unimplemented }),
      }
    )
  ),

  s({ trig = "pe", name = "panic(err)" }, fmta("panic(err)", {})),
  s({
    trig = "r",
    name = "return",
    condition = function(line_to_cursor)
      return not line_to_cursor:match(":=")
    end,
  }, fmta("return <>", { i(0, { "" }) })),

  s({ trig = "re", name = "return err" }, fmta("return err", {})),
  s({ trig = "rn", name = "return nil" }, fmta("return nil", {})),
  s({ trig = "rne", name = "return nil, err" }, fmta("return nil, err", {})),
  s(
    { trig = "ree", name = "return fmt.Errorf()" },
    fmta([[return fmt.Errorf("<format><>: %w", err)]], {
      format = i(1, { "failed to " }),
      i(2, { "" }),
    })
  ),
  s(
    { trig = "rnee", name = "return nil, fmt.Errorf()" },
    fmta([[return nil, fmt.Errorf("<format><>: %w", err)]], {
      format = i(1, { "failed to " }),
      i(2, { "" }),
    })
  ),
  s({ trig = "tfe", name = "t.Fatal(err)" }, fmta("t.Fatal(err)", {})),
  s(
    { trig = "ifcmp", name = "if diff := cmp.Diff()" },
    fmta(
      [[
      if diff := cmp.Diff(got, want); diff != "" {
          t.Errorf("(-got +want)\n%v", diff)
      }
      ]],
      {}
    )
  ),
  s(
    { trig = "ifet", name = "if err != nil; t.Fatalf()" },
    fmta(
      [[
      if err != nil {
          t.Fatalf("%+v", err)
      }
      ]],
      {}
    )
  ),
  s(
    { trig = "ifeb", name = "if err != nil; b.Fatalf()" },
    fmta(
      [[
      if err != nil {
          b.Fatalf("%+v", err)
      }
      ]],
      {}
    )
  ),

  s({
    trig = "c",
    name = "context.Context",
    condition = function(line_to_cursor, matched_trigger)
      return line_to_cursor:match("%(%s*" .. matched_trigger .. "$")
    end,
    show_condition = function()
      return false
    end,
  }, fmta("ctx context.Context", {})),
}
