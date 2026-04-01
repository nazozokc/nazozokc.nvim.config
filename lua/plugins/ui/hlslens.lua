-- lua/plugins/hlslens.lua
return {
	"kevinhwang91/nvim-hlslens",
	event = { "BufReadPost", "BufNewFile" }, -- 必要に応じて
	config = function()
		local hlslens = require("hlslens")

		hlslens.setup({
			calm_down = true,
			nearest_only = true,
			nearest_float_when = "auto",
			enable_incsearch = true,
		})

		-- Auto activate hlslens on search
		local opts = { noremap = true, silent = true }

		map(
			"n",
			"n",
			"<Cmd>execute('normal! ' .. v:count1 .. 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
			{ silent = true, desc = "Next search" }
		)
		map(
			"n",
			"N",
			"<Cmd>execute('normal! ' .. v:count1 .. 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
			{ silent = true, desc = "Prev search" }
		)
		map("n", "*", "*<Cmd>lua require('hlslens').start()<CR>", { silent = true, desc = "Search word forward" })
		map("n", "#", "#<Cmd>lua require('hlslens').start()<CR>", { silent = true, desc = "Search word backward" })
		map(
			"n",
			"<Leader>l",
			"<Cmd>lua require('hlslens').toggle_virtual_text()<CR>",
			{ silent = true, desc = "Toggle hlslens virtual text" }
		)
	end,
}
