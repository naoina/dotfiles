vim.g.author = "Naoya Inada"
vim.g.email = "naoina@kuune.org"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- latest stable release
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local win_border = { "+", "-", "+", "|", "+", "-", "+", "|" }

local function get_main(plugin)
  return require("lazy.core.loader").get_main(plugin)
end

local function default_setup(plugin)
  local main = get_main(plugin)
  if main then
    pcall(require(main).setup)
  end
end

local function setup(f)
  return function(plugin)
    local main = get_main(plugin)
    local _, M = pcall(require, main)
    f(M, main)
  end
end

local function init(f)
  return function(plugin)
    return f(get_main(plugin))
  end
end

local function exists(expr)
  return vim.fn.exists(expr) ~= 0
end

local function winhighlight(t)
  local tt = {}
  for k, v in pairs(t) do
    table.insert(tt, k .. ":" .. v)
  end
  return table.concat(tt, ",")
end

local function get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

local function tbl_find(f, t)
  for k, v in pairs(t) do
    if f(v, k) then
      return v
    end
  end
  return nil
end

local function after_lazy_done(f)
  if require("lazy").stats().times.LazyDone then
    f()
    return
  end
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyDone",
    group = vim.api.nvim_create_augroup("AfterLazyDone", { clear = false }),
    once = true,
    callback = function()
      f()
      return true
    end,
  })
end

local function define_keymap(modes, lhs, rhs, opts)
  after_lazy_done(function()
    opts = opts or {}
    modes = type(modes) == "string" and { modes } or modes
    for _, mode in pairs(modes) do
      local defined = tbl_find(function(item)
        return item.class.name == "Keymap"
          and vim.api.nvim_replace_termcodes(item.keys, true, false, true) == vim.api.nvim_replace_termcodes(
            lhs,
            true,
            false,
            true
          )
          and (item.mode_mappings[mode] ~= nil or vim.tbl_contains(item.mode_mappings, mode))
      end, require("legendary.data.state").items.items)
      local desc = defined and "" or opts.desc
      require("legendary").keymap({ lhs, rhs, mode = mode, description = desc, opts = opts })
    end
  end)
  return { lhs, rhs, mode = modes }
end

local function define_command(name, cmd, opts)
  after_lazy_done(function()
    opts = opts or {}
    local cmd_name = ":" .. name
    if not exists(cmd_name) or not cmd then
      local desc = opts.desc or (type(cmd) == "string" and cmd or cmd_name)
      require("legendary").command({ cmd_name, cmd, description = desc })
    end
  end)
  return vim.split(name, " ")[1]
end

local function augroup(group, f)
  f(vim.api.nvim_create_augroup(group, { clear = true }))
end

local function feed_keys(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "nx", false)
end

local function create_goimpl_complete_func()
  local clients = vim.tbl_filter(function(c)
    return c.server_capabilities.completionProvider and c.name == "gopls"
  end, vim.lsp.get_active_clients({ bufnr = vim.api.nvim_get_current_buf() }))
  if #clients == 0 then
    return nil
  end
  local uri =
    vim.uri_from_fname(require("plenary.path").new(clients[1].config.root_dir, "xxx_dressing_goimpl_comp.go").filename)
  local lines = {
    "package main",
    "var _ = ",
  }
  local version = 0
  for _, c in pairs(clients) do
    c.notify("textDocument/didOpen", {
      textDocument = {
        uri = uri,
        languageId = "go",
        version = version,
        text = table.concat(lines, "\n"),
      },
    })
  end
  augroup("GoImplCompletion", function(group)
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "DressingInput" },
      once = true,
      callback = function(ev)
        vim.api.nvim_create_autocmd("BufLeave", {
          group = group,
          buffer = ev.buf,
          once = true,
          callback = function()
            for _, c in pairs(clients) do
              c.notify("textDocument/didClose", {
                textDocument = {
                  uri = uri,
                },
              })
            end
          end,
        })
      end,
    })
  end)
  return function(A)
    local position = {
      line = #lines - 1,
      character = vim.api.nvim_strwidth(lines[#lines]) - 1,
    }
    version = version + 1
    local contentChanges = {}
    for ch in A:gmatch(".") do
      position.character = position.character + 1
      table.insert(contentChanges, {
        range = {
          start = {
            line = position.line,
            character = position.character,
          },
          ["end"] = {
            line = position.line,
            character = position.character,
          },
        },
        rangeLength = 0,
        text = ch,
      })
    end
    local items = {}
    for _, c in pairs(clients) do
      c.notify("textDocument/didChange", {
        textDocument = {
          uri = uri,
          version = version,
        },
        contentChanges = contentChanges,
      })
      local result = assert(c.request_sync("textDocument/completion", {
        textDocument = {
          uri = uri,
        },
        position = {
          line = position.line,
          character = position.character + 1,
        },
      }))
      for _, item in pairs(result.result.items or {}) do
        -- Only interface type
        if item.kind == 8 then
          table.insert(items, item)
        end
      end
    end
    return vim.tbl_map(function(item)
      local mod = item.detail:match([[%(from "(.+)"%)$]])
      return mod .. "." .. item.textEdit.newText
    end, items)
  end
end

local function to_snake_case(s)
  return s:gsub("%u", "_%1"):gsub("^_", ""):lower()
end

local function to_upper_case(s)
  return s:gsub("_%l", string.upper):gsub("^%l", string.upper)
end

require("lazy").setup({
  { "folke/lazy.nvim" },
  {
    "mrjones2014/legendary.nvim",
    lazy = false,
    priority = 99,
    config = setup(function(M)
      M.setup({
        include_builtin = false,
        include_legendary_cmds = false,
        which_key = {
          auto_register = true,
        },
      })
      define_keymap({ "n", "v" }, "<C-c>", M.find)
    end),
  },
  {
    "folke/which-key.nvim",
    config = setup(function(M)
      M.setup({
        window = {
          border = win_border,
        },
      })
    end),
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = init(function(main)
      local filtered = {}
      for _, v in pairs({ "w", "q", "xa", "cq!", "vsp", "sp", "qal" }) do
        filtered[v] = true
      end
      local filter_fn = function(cmd)
        return not filtered[cmd]
      end
      local builtin = main .. ".builtin"
      return {
        define_keymap("n", "<C-p>", function()
          require(builtin).find_files({ cwd = get_git_root() })
        end, { desc = "Telescope find_files cwd=git_root" }),
        define_keymap("c", "<C-p>", function()
          if vim.fn.getcmdtype():match("[/?]") then
            require(builtin).search_history()
            return
          end
          vim.fn.setcmdline("")
          require(builtin).command_history({
            filter_fn = filter_fn,
          })
        end, { desc = "Telescope command_history" }),
        define_keymap("n", "<C-x><C-p><C-p>", function()
          require(builtin).find_files()
        end, { desc = "Telescope find_files" }),
        define_keymap("n", "<C-x><C-p><C-b>", function()
          require(builtin).buffers()
        end, { desc = "Telescope buffers" }),
        define_keymap("n", "<C-x><C-p><C-h>", function()
          require(builtin).highlights()
        end, { desc = "Telescope highlights" }),
        define_keymap("n", "<C-x><C-p><C-g>", function()
          local cwd = get_git_root()
          if vim.fn.getreg("/") == "" then
            require(builtin).live_grep({ cwd = cwd })
          else
            require(builtin).grep_string({ cwd = cwd })
          end
        end, { desc = "Telescope grep" }),
        define_keymap("n", "<C-q>", function()
          require(builtin).diagnostics()
        end, { desc = "Telescope diagnostics" }),
        define_keymap("n", "<C-y>", function()
          require(builtin).registers()
        end, { desc = "Telescope registers" }),
        define_keymap("n", "gd", function()
          require(builtin).lsp_definitions()
        end, { desc = "Telescope definitions" }),
        define_keymap("n", "gi", function()
          require(builtin).lsp_implementations()
        end, { desc = "Telescope lsp_implementations" }),
      }
    end),
    config = setup(function(M, main)
      local actions = require(main .. ".actions")
      local layout_strategies = require(main .. ".pickers.layout_strategies")
      local builtin = require(main .. ".builtin")
      local bottom_pane = layout_strategies.bottom_pane
      layout_strategies.bottom_pane = function(...)
        local layout = bottom_pane(...)
        layout.prompt.width = layout.results.width
        layout.prompt.col = layout.results.col
        layout.results.height = layout.results.height - 1
        if layout.preview then
          layout.preview.height = layout.results.height + layout.prompt.height + 1
        end
        return layout
      end
      local bottom_layout = {
        sorting_strategy = "descending",
        layout_strategy = "bottom_pane",
        layout_config = {
          height = 15,
          prompt_position = "bottom",
        },
        borderchars = { "-", "|", "-", " ", "-", "+", "+", "-" },
        results_title = false,
        preview_title = false,
        prompt_title = false,
      }
      local pickers = {}
      for k, _ in pairs(builtin) do
        pickers[k] = bottom_layout
      end
      M.setup({
        defaults = {
          mappings = {
            i = {
              ["<C-n>"] = actions.move_selection_next,
              ["<C-p>"] = actions.move_selection_previous,
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<Esc>"] = actions.close,
              ["<C-u>"] = false,
              ["<C-f>"] = actions.results_scrolling_down,
              ["<C-b>"] = actions.results_scrolling_up,
            },
          },
          scroll_strategy = "limit",
        },
        pickers = vim.tbl_deep_extend("force", pickers, {
          find_files = {
            sorting_strategy = "ascending",
          },
          live_grep = {
            sorting_strategy = "ascending",
          },
          grep_string = {
            sorting_strategy = "ascending",
          },
          highlights = {
            sorting_strategy = "ascending",
          },
          command_history = {
            mappings = {
              i = {
                ["<CR>"] = actions.edit_command_line,
              },
            },
          },
        }),
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
        },
      })
      for k, _ in pairs(builtin) do
        local cmd = "Telescope " .. k
        define_command(cmd, nil, { desc = cmd })
      end
    end),
  },
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  {
    "kana/vim-altr",
    cmd = { "An", "Ap" },
    config = function()
      local define = vim.fn["altr#define"]
      define("%.go", "%_test.go", "%_bench_test.go")
      vim.api.nvim_create_user_command("An", function()
        vim.fn["altr#forward"]()
      end)
      vim.api.nvim_create_user_command("Ap", function()
        vim.fn["altr#back"]()
      end)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    keys = init(function()
      return {
        define_keymap("n", "caf", nil, { desc = "Cut @function.outer" }),
        define_keymap("n", "daf", nil, { desc = "Delete @function.outer" }),
        define_keymap("n", "vaf", nil, { desc = "Visual @function.outer" }),
        define_keymap("n", "cif", nil, { desc = "Cut @function.inner" }),
        define_keymap("n", "dif", nil, { desc = "Delete @function.inner" }),
        define_keymap("n", "vif", nil, { desc = "Visual @function.inner" }),
        define_keymap("n", "]]", nil, { desc = "Go to next @function.outer" }),
        define_keymap("n", "[[", nil, { desc = "Go to previous @function.outer" }),
      }
    end),
    config = setup(function(_, main)
      require(main .. ".configs").setup({
        ensure_installed = {
          "go",
          "lua",
          "bash",
          "query",
          "typescript",
          "css",
          "dockerfile",
          "git_config",
          "gitignore",
          "graphql",
          "html",
          "javascript",
          "json",
          "make",
          "proto",
          "python",
          "sql",
          "toml",
          "tsx",
          "yaml",
        },
        highlight = {
          enable = true,
        },

        -- For JoosepAlviste/nvim-ts-context-commentstring
        context_commentstring = {
          enable = true,
        },

        -- For nvim-treesitter/nvim-treesitter-textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
              ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            },
            selection_modes = {
              ["@function.inner"] = "V",
            },
          },
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]]"] = "@function.outer",
            },
            goto_previous_start = {
              ["[["] = "@function.outer",
            },
          },
        },

        -- For andymass/vim-matchup
        matchup = {
          enable = true,
        },

        playground = {
          enable = true,
        },
      })
    end),
  },
  {
    "nvim-treesitter/playground",
    config = default_setup,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = default_setup,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    config = default_setup,
  },
  {
    "numToStr/Comment.nvim",
    keys = init(function(main)
      local api = main .. ".api"
      return {
        define_keymap("n", "<C-_>", function()
          if vim.v.count == 0 then
            require(api).toggle.linewise.current()
          else
            require(api).toggle.linewise.count(vim.v.count)
          end
        end, { desc = "Comment toggle current line" }),
        define_keymap("x", "<C-_>", function()
          feed_keys("<Esc>")
          require(api).locked("toggle.linewise")(vim.fn.visualmode())
        end, { desc = "Comment toggle linewise (visual)" }),
      }
    end),
    config = setup(function(M)
      M.setup({
        mappings = false,
      })
    end),
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = default_setup,
  },
  {
    "tpope/vim-fugitive",
    config = setup(function()
      define_command("Git blame", nil, { desc = "git blame" })
    end),
  },
  {
    "michaelb/sniprun",
    build = "bash ./install.sh",
    keys = init(function(main)
      local api = main .. ".api"
      return {
        define_keymap("n", "<leader>r", function()
          require(api).run_range(1, vim.api.nvim_buf_line_count(0))
        end, { silent = true, desc = "Run code" }),
      }
    end),
    config = default_setup,
  },
  {
    "norcalli/nvim-colorizer.lua",
    cmd = init(function()
      return {
        define_command("ColorizerToggle", nil, { desc = "Toggle colorizer" }),
      }
    end),
    config = default_setup,
  },
  {
    "kevinhwang91/nvim-hlslens",
    dependencies = {
      "daisuzu/rainbowcyclone.vim",
    },
    config = setup(function(M, main)
      M.setup()
      local star = exists(":RCReset") and "<Plug>(rc_highlight_with_cursor_complete)" or "*"
      vim.keymap.set(
        "n",
        "n",
        [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require(']] .. main .. [[').start()<CR>]],
        { silent = true }
      )
      vim.keymap.set(
        "n",
        "N",
        [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require(']] .. main .. [[').start()<CR>]],
        { silent = true }
      )
      vim.keymap.set("n", "*", star .. [[<Cmd>lua require(']] .. main .. [[').start()<CR>]], { silent = true })
    end),
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = init(function()
      return {
        define_command("Mason", nil, { desc = "Mason" }),
      }
    end),
    config = setup(function(M)
      M.setup({
        ui = {
          border = win_border,
          keymaps = {
            toggle_package_expand = "<Space>",
            install_package = "<C-i>",
            uninstall_package = "<C-d>",
            apply_language_filter = "<Nop>",
          },
        },
      })
    end),
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = default_setup,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "lukas-reineke/lsp-format.nvim",
    },
    config = setup(function(M)
      local function on_attach(client, _bufnr)
        require("lsp-format").on_attach(client)
      end
      M.setup({
        sources = {
          -- Managed by jay-babu/mason-null-ls
        },
        on_attach = on_attach,
      })
    end),
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
    config = setup(function(M)
      M.setup({
        automatic_setup = true,
        handlers = {}, -- truthy value is needed to do automatic_setup
      })
    end),
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = setup(function(M, main)
      M.setup()
      for k, v in pairs({
        typescriptreact = { "typescript" },
      }) do
        M.filetype_extend(k, v)
      end
      require(main .. ".loaders.from_lua").lazy_load()
      vim.api.nvim_create_user_command("LuaSnipEdit", function()
        require("luasnip.loaders").edit_snippet_files({
          ft_filter = function(filetype)
            return vim.opt.filetype:get() == filetype
          end,
          extend = function(ft, ft_paths)
            if #ft_paths ~= 0 then
              return {}
            end
            local util = require(main .. ".loaders.util")
            return vim.tbl_map(function(path)
              local ft_path = path .. "/" .. ft .. ".lua"
              return { ft_path, ft_path }
            end, util.normalize_paths(nil, "luasnippets"))
          end,
        })
      end, {})
    end),
  },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    config = setup(function(M)
      M.setup({
        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "buffer" },
          { name = "path" },
          { name = "nvim_lua" },
          { name = "luasnip" },
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        window = {
          completion = M.config.window.bordered({
            border = win_border,
            winhighlight = winhighlight({
              Normal = "Normal",
              FloatBorder = "Normal",
              CursorLine = "PmenuSel",
              Search = "None",
            }),
          }),
          documentation = M.config.window.bordered({
            border = win_border,
          }),
        },
        mapping = M.mapping.preset.insert({
          ["<Esc>"] = M.mapping(function(fallback)
            require("luasnip").unlink_current()
            fallback()
          end, { "i", "s" }),
          ["<Tab>"] = M.mapping(function(fallback)
            if require("luasnip").expand_or_locally_jumpable() then
              if not require("luasnip").expand_or_jump() then
                fallback()
              end
              return
            end
            if not M.confirm({ select = true }) then
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = M.mapping(function(fallback)
            if require("luasnip").jumpable(-1) then
              require("luasnip").jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = M.mapping.confirm({ select = true }),
          ["<C-e>"] = M.mapping(function(fallback)
            local has_copilot, copilot_enabled = pcall(vim.fn["copilot#Enabled"])
            if has_copilot and copilot_enabled and vim.fn["copilot#GetDisplayedSuggestion"]().text ~= "" then
              vim.api.nvim_feedkeys(vim.fn["copilot#Accept"](fallback), "i", false)
              return
            end
            fallback()
          end, { "i" }),
        }),
      })
    end),
  },
  {
    "hrsh7th/cmp-nvim-lsp",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = setup(function(M)
      local capabilities = M.default_capabilities()
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            settings = {
              gopls = {
                matcher = "Fuzzy",
                usePlaceholders = false,
                staticcheck = true,
                verboseOutput = false,
              },
            },
          })
        end,
      })
    end),
  },
  {
    "hrsh7th/cmp-nvim-lsp-signature-help",
    config = default_setup,
  },
  {
    "hrsh7th/cmp-buffer",
    config = default_setup,
  },
  {
    "hrsh7th/cmp-path",
    config = default_setup,
  },
  {
    "hrsh7th/cmp-cmdline",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
        }, {
          { name = "cmdline" },
        }),
      })
    end,
  },
  {
    "hrsh7th/cmp-nvim-lua",
    config = default_setup,
  },
  {
    "saadparwaiz1/cmp_luasnip",
    dependencies = {
      "L3MON4D3/LuaSnip",
    },
    config = default_setup,
  },
  {
    "hrsh7th/cmp-omni",
    config = default_setup,
  },
  {
    "editorconfig/editorconfig-vim",
    config = default_setup,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    keys = {
      {
        "<C-g>",
        function()
          vim.opt_local.cursorcolumn = not vim.opt_local.cursorcolumn:get()
          require("indent_blankline.commands").toggle()
        end,
        mode = "n",
        silent = true,
      },
    },
    config = setup(function(M)
      M.setup({
        enabled = false,
      })
    end),
  },
  {
    "naoina/previm",
    cmd = "PrevimOpen",
    init = function()
      vim.g.previm_open_cmd = "xdg-open"
      vim.g.previm_show_header = false
    end,
    config = default_setup,
  },
  {
    "andymass/vim-matchup",
    config = default_setup,
  },
  {
    "windwp/nvim-autopairs",
    dependencies = {
      "hrsh7th/nvim-cmp",
    },
    config = setup(function(M, main)
      M.setup()
      require("cmp").event:on("confirm_done", require(main .. ".completion.cmp").on_confirm_done())
    end),
  },
  {
    "nvim-lualine/lualine.nvim",
    config = setup(function(M)
      local color = { fg = "#949494", bg = "#87ffff", gui = "bold" }
      local colors = {
        a = color,
        b = color,
        c = color,
      }
      local highlight = require("lualine.highlight")
      local enc_hl_format = highlight.component_format_highlight({ name = "FileEncoding", no_mode = true })
      local ff_hl_format = highlight.component_format_highlight({ name = "FileFormatCRLF", no_mode = true })
      M.setup({
        options = {
          icons_enabled = false,
          theme = {
            normal = colors,
            insert = colors,
            visual = colors,
            replace = colors,
            inactive = colors,
            command = colors,
          },
          section_separators = "",
          component_separators = "",
          globalstatus = true,
        },
        sections = {
          lualine_a = {
            {
              "branch",
              fmt = function(s)
                return "[Git(" .. s .. ")]"
              end,
            },
          },
          lualine_b = {
            {
              "diagnostics",
              diagnostics_color = {
                error = "DiagnosticError",
                warn = "DiagnosticWarn",
                info = "DiagnosticInfo",
                hint = "DiagnosticHint",
              },
            },
            {
              "filename",
              path = 3,
            },
            {
              "encoding",
              fmt = function(s)
                if s ~= "utf-8" then
                  s = enc_hl_format .. s .. highlight.format_highlight("b")
                end
                return "[" .. s .. "]"
              end,
            },
            {
              "fileformat",
              icons_enabled = true,
              symbols = {
                unix = "LF",
                dos = ff_hl_format .. "CRLF",
                mac = ff_hl_format .. "CR",
              },
              fmt = function(s)
                return "[" .. s .. highlight.format_highlight("b") .. "]"
              end,
            },
          },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {
            { "%=[0x%B]" },
            {
              "location",
              fmt = function(s)
                return s
              end,
            },
          },
          lualine_z = {
            {
              "filetype",
              fmt = function(s)
                return "[" .. s .. "]"
              end,
            },
          },
        },
      })
    end),
  },
  {
    "stevearc/aerial.nvim",
    config = setup(function(M)
      M.setup({
        close_on_select = true,
        keymaps = {
          ["<C-j>"] = false,
          ["<C-k>"] = false,
          ["<Esc>"] = "actions.close",
          ["<Space>"] = "actions.close",
        },
        on_attach = function(bufnr)
          vim.keymap.set("n", "<Space>", function()
            M.toggle()
          end, { buffer = bufnr })
        end,
      })
    end),
  },
  {
    "rbtnn/vim-ambiwidth",
  },
  {
    "folke/todo-comments.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = setup(function(M)
      M.setup({
        signs = false,
        keywords = {
          FIX = { icon = "x", color = "error", alt = { "FIXME" } },
          TODO = { icon = "x", color = "info" },
          NOTE = { icon = "x", color = "hint" },
        },
        merge_keywords = false,
        highlight = {
          before = "",
          keyword = "bg",
          after = "",
          pattern = [[<(KEYWORDS)>]],
        },
        colors = {
          info = { "DiagnosticInfo" },
          error = { "DiagnosticError" },
          hint = { "DiagnosticHint" },
        },
        search = {
          pattern = [[\b(KEYWORDS)\b]],
        },
      })
      define_keymap("n", "<C-t>", function()
        require("telescope").load_extension("todo-comments").todo()
      end, { desc = "todo-comments" })
    end),
  },
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = setup(function(M)
      M.setup({
        input = {
          border = win_border,
          insert_only = true,
          win_options = {
            listchars = "precedes:.,extends:.",
          },
          get_config = function(opts)
            -- for goimpl
            if vim.opt.filetype:get() == "go" and opts.prompt == "Enter interface name: " then
              _G.goimpl_complete = create_goimpl_complete_func()
              opts.completion = "customlist,v:lua.goimpl_complete"
            end
          end,
        },
        select = {
          telescope = require("telescope.config").pickers.find_files,
        },
      })
    end),
  },
  {
    "aznhe21/actions-preview.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    event = "LspAttach",
    config = setup(function(M)
      M.setup({
        telescope = require("telescope.config").pickers.find_files,
      })
    end),
  },
  {
    "github/copilot.vim",
    config = setup(function()
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_no_tab_map = true
    end),
  },
}, {
  git = {
    url_format = "https://git::@github.com/%s",
  },
})

vim.keymap.set("n", "Q", "<Nop>")
vim.keymap.set("n", "j", "gj", { silent = true })
vim.keymap.set("n", "k", "gk", { silent = true })
vim.keymap.set("n", "gj", "j", { silent = true })
vim.keymap.set("n", "gk", "k", { silent = true })
vim.keymap.set({ "n", "i" }, "<C-s>", "<Nop>")
vim.keymap.set("n", "<C-j>", "<C-w>w", { silent = true })
vim.keymap.set("n", "<C-l>", function()
  vim.cmd("nohlsearch")
  vim.cmd("redraw!")
  if exists(":RCReset") then
    vim.cmd("RCReset")
  end
  vim.fn.setreg("/", "")
  vim.api.nvim_echo({ { "", "" } }, false, {})
end, { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>W", { silent = true })
-- vim.keymap.set("n", "<Space>", "za")
vim.keymap.set("n", "<C-d>", function()
  local cur_bufnr = vim.api.nvim_get_current_buf()
  local bufnr = tbl_find(function(candidate)
    return candidate ~= cur_bufnr
      and vim.api.nvim_buf_is_loaded(candidate)
      and vim.api.nvim_buf_get_option(candidate, "buftype") == ""
  end, vim.fn.reverse(vim.api.nvim_list_bufs()))
  if bufnr then
    local winnr = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(winnr, bufnr)
  end
  vim.api.nvim_buf_delete(cur_bufnr, { force = true })
end, { silent = true })
vim.keymap.set("n", "QQ", "<Cmd>q!<CR>")
vim.keymap.set("n", "yu", "<Cmd>%y +<CR>", { silent = true })
vim.keymap.set("c", "<C-n>", "<Down>")
vim.keymap.set("n", "<C-n>", "<Cmd>bnext<CR>", { silent = true })
vim.keymap.set("i", "<C-h>", "<Bs>")
vim.keymap.set({ "i", "c" }, "<C-a>", "<Home>")
vim.keymap.set({ "i", "c" }, "<C-e>", "<End>")
vim.keymap.set({ "i", "c" }, "<C-f>", "<Right>")
vim.keymap.set({ "i", "c" }, "<C-b>", "<Left>")

if vim.opt.diff:get() then
  vim.keymap.set("n", "<C-l>", "<Cmd>diffupdate<CR>")
  vim.keymap.set("n", "<C-g>", "<Cmd>diffget<CR>")
  vim.keymap.set("n", "<C-n>", "]czz")
  vim.keymap.set("n", "<C-p>", "[czz")
  vim.keymap.set("n", "ZZ", "<Cmd>xa!<CR>", { silent = true })
  vim.keymap.set("n", "QQ", "<Cmd>cq!<CR>", { silent = true })
end

for k, v in pairs({
  background = "light",
  termguicolors = true,
  swapfile = false,
  backup = true,
  backupdir = vim.fn.stdpath("cache") .. "/backup",
  directory = vim.fn.stdpath("cache") .. "/swap",
  writebackup = false,
  viminfo = { "'1000", "<500", "f1" },
  backspace = { "indent", "eol", "start" },
  list = true,
  listchars = { tab = ">-", eol = "$" },
  number = true,
  hidden = true,
  hlsearch = true,
  ignorecase = true,
  smartcase = true,
  laststatus = 3,
  wrapscan = false,
  showcmd = true,
  iminsert = 1,
  foldopen = { "block", "hor", "jump", "mark", "percent", "quickfix", "search", "tag", "undo" },
  foldlevel = 0,
  browsedir = "buffer",
  grepprg = "grep -nH",
  writeany = true,
  pastetoggle = "<F9>",
  tags = "tags",
  tabstop = 4,
  softtabstop = 4,
  shiftwidth = 4,
  expandtab = true,
  display = "lastline",
  mouse = "n",
  fileencoding = "utf-8",
  fileencodings = { "ucs-bom", "utf-8", "japan", "cp932", "utf-16" },
  fileformats = { "unix", "dos", "mac" },
  fixendofline = false,
  updatetime = 300,
  fillchars = {
    foldsep = "|",
    horiz = "-",
    horizup = "-",
    horizdown = "-",
    vert = "|",
    vertleft = "|",
    vertright = "|",
    verthoriz = "+",
  },
  autochdir = true,
  ambiwidth = "double",
}) do
  vim.opt[k] = v
end
vim.opt.shortmess:append({ I = true, w = true })
vim.opt.cinkeys:append({ ";" })
vim.opt.formatoptions:append({ c = true, q = true, m = true, M = true })

vim.cmd.colorscheme("naoina")

define_command("EncUTF8", "e ++enc=utf-8", {})
define_command("EncSJIS", "e ++enc=cp932", {})
define_command("EncISO2022JP", "e ++enc=iso-2022-jp", {})
define_command("EncEUCJP", "e ++enc=euc-jp", {})

vim.diagnostic.config({
  underline = true,
  virtual_text = {
    prefix = "",
    spacing = 2,
  },
})

-- Auto restore last cursor position.
augroup("vimrc", function(group)
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function()
      if vim.fn.line([['"]]) > 1 or vim.fn.line([['"]]) <= vim.fn.line("$") then
        vim.cmd([[normal! g`"]])
      end
    end,
  })
end)

augroup("cursorline", function(group)
  vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
    group = group,
    callback = function()
      vim.opt.cursorline = true
    end,
  })
  vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
    group = group,
    callback = function()
      vim.opt.cursorline = false
    end,
  })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = { "TelescopePrompt" },
    callback = function()
      vim.opt.cursorline = false
    end,
  })
end)

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = win_border,
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = win_border,
})
vim.lsp.set_log_level("debug") -- TODO

augroup("LspAttach", function(group)
  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(ev)
      local bufnr = ev.buf
      define_keymap("n", "[d", vim.diagnostic.goto_prev, { buffer = bufnr, desc = "vim.diagnostic.goto_prev" })
      define_keymap("n", "]d", vim.diagnostic.goto_next, { buffer = bufnr, desc = "vim.diagnostic.goto_next" })
      define_keymap("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = [[LSP request "textDocument/hover"]] })
      define_command("LspDiagnosticOpenFloat", vim.diagnostic.open_float, { desc = "vim.diagnostic.open_float" })
      local methods = {}
      for k, _ in pairs(vim.lsp.handlers) do
        if k:match("^textDocument/") and k ~= "textDocument/publishDiagnostics" and k ~= "textDocument/codeAction" then
          table.insert(methods, k)
        end
      end
      for _, k in pairs(methods) do
        local base = k:gsub("^textDocument/", "")
        local method = to_snake_case(base)
        if vim.lsp.buf[method] then
          define_command("Lsp" .. to_upper_case(base), function()
            vim.lsp.buf[method]()
          end, { desc = [[LSP request "]] .. k .. [["]] })
        end
      end
      define_command("LspCodeAction", function()
        require("actions-preview").code_actions()
      end, { desc = [[LSP request "textDocument/codeAction"]] })
      local client = vim.lsp.get_client_by_id(ev.data.client_id)
      if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          group = group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.document_highlight()
          end,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          group = group,
          buffer = bufnr,
          callback = function()
            vim.lsp.buf.clear_references()
          end,
        })
      end
    end,
  })
end)
