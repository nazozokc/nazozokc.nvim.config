return {
	"glepnir/lspsaga.nvim",
	event = "LspAttach",
	keys = { { "<leader>ca", "<cmd>Lspsaga code_action<CR>" } },
	branch = "main",
	config = function()
		-- デフォルト設定で使用
		require("lspsaga").setup({})
	end,
}
