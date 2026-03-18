return {
	"lewis6991/gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("gitsigns").setup({
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "▎" }, -- ← VSCodeは全部同じバー
				topdelete = { text = "▎" },
				changedelete = { text = "▎" },
			},

			signcolumn = true,
			numhl = false,
			linehl = true,

			watch_gitdir = {
				follow_files = true,
			},

			current_line_blame = false, -- ← VSCodeはデフォOFF
			word_diff = false,
			update_debounce = 100,

			current_line_blame_opts = {
				delay = 500,
			},
		})

		-- VSCode風キーマップ
		vim.keymap.set("n", "]c", function()
			require("gitsigns").next_hunk()
		end)

		vim.keymap.set("n", "[c", function()
			require("gitsigns").prev_hunk()
		end)

		vim.keymap.set("n", "<leader>gp", function()
			require("gitsigns").preview_hunk()
		end)

		vim.keymap.set("n", "<leader>gt", function()
			require("gitsigns").toggle_current_line_blame()
		end)
	end,
}
