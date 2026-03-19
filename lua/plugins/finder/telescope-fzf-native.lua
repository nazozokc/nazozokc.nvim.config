return {
	"nvim-telescope/telescope-fzf-native.nvim",
	event = "VeryLazy",
	build = "make",
	config = function()
		require("telescope").load_extension("fzf")
	end,
}
