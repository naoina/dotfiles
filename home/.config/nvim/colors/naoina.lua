if vim.g.colors_name then
  vim.cmd.highlight("clear")
end

vim.g.colors_name = "naoina"
vim.o.termguicolors = true

local colors = {
  black = "#000000",
  white = "#ffffff",
  red = "#d70000",
  pink = "#ff005f",
  aqua = "#d7ffff",
  blue = "#005fff",
  dark_blue = "#000087",
  light_blue = "#00afd7",
  yellow = "#ffff00",
  orange = "#ffa500",
  gray = "#555555",
}

local groups = {
  Normal = { fg = colors.black, bg = colors.white },
  String = { fg = colors.red },
  Number = { fg = colors.red },
  Boolean = { fg = colors.dark_blue, bold = true },
  Operator = { fg = colors.dark_blue },
  Conditional = { fg = colors.dark_blue, bold = true },
  Identifier = { fg = colors.black, bg = colors.white },
  LineNr = { fg = colors.pink },
  CursorLine = { bg = colors.aqua },
  CursorLineNr = { fg = colors.pink, bold = true },
  Pmenu = { fg = "#a8a8a8", bg = "#eeeeee" },
  PmenuSel = { bg = colors.aqua, bold = true },
  Visual = { reverse = true },
  SpecialKey = { fg = "#ffd7ff" },
  NonText = { fg = "#87ffff" },
  Search = { fg = "#e4e4e4", bg = colors.black, bold = true },
  Todo = { fg = "#080808", bg = colors.yellow, bold = true },
  Comment = { fg = colors.light_blue },
  Keyword = { fg = colors.dark_blue, bold = true },
  Statement = { fg = colors.dark_blue, bold = true },
  Constant = { fg = "#00d700", bold = true },
  Type = { fg = "#00d700" },
  Function = { fg = colors.blue },
  Folded = { fg = "#c6c6c6", bg = "NONE", bold = true },
  Include = { fg = "#8700af" },
  Special = { fg = colors.dark_blue, bold = true },
  Delimiter = { fg = "#8700af" },
  Define = { fg = "#8700af" },
  Structure = { fg = "#00af5f" },
  StatusLine = { fg = "#949494", bg = "#87ffff", bold = true },
  StatusLineNC = { fg = "#949494", bold = true, underline = true },
  SignColumn = { bg = "NONE" },
  Error = { fg = colors.red, bg = colors.yellow, bold = true },
  NormalFloat = { fg = colors.black, bg = colors.white },

  FileFormatCRLF = { fg = "#a100ff", bg = "#87ffff", bold = true },
  FileEncoding = { link = "FileFormatCRLF" },

  CmpItemMenu = { link = "Normal" },
  CmpItemAbbr = { fg = colors.gray },
  CmpItemAbbrMatch = { fg = colors.gray, bold = true },

  LspReferenceText = { bg = "grey90" },
  DiagnosticError = { link = "Error" },
  DiagnosticWarn = { fg = colors.black, bg = colors.orange, sp = colors.orange },
  DiagnosticUnderlineError = { fg = colors.black, bg = colors.yellow, bold = true, underline = true },
  DiagnosticUnderlineWarn = { fg = colors.black, bg = colors.white, underline = true },
  DiagnosticInfo = { fg = "#999999", bold = true },

  TelescopePromptCounter = { link = "TelescopeNormal" },
  TelescopeMatching = { fg = "#00afaf" },
  TelescopePromptPrefix = { bold = true },
  TelescopeSelection = { link = "PmenuSel" },
}

for k, v in pairs(groups) do
  vim.api.nvim_set_hl(0, k, v)
end
