local js_based_languages = {
	"typescript",
	"javascript",
	"typescriptreact",
	"javascriptreact",
	"svelte",
	"vue",
}

return {
	{
		"mfussenegger/nvim-dap",
		config = function()
			local Config = require("lazyvim.config")
			vim.api.nvim_set_hl(0, "DapStoppedLine", {default = true, link = "Visual"})
			
			for name, sign in pairs(Config.icons.dap) do
				sign = type(sign) == "table" and sign  or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", lihehl = sign[3], numhl = sign[3] }
			end

			for _, language in ipairs(js_based_languages) do
				dap.configurations[language] = {
					{
						type = "pwa-node",
						request = "launch",
						name = "Launch File",
						program = "${file}",
						sourceMaps = true,
					},
					-- Debug nodejs process (make sure to add --inspect when you run the process)
					{
						type = "pwa-node",
						request = "attach",
						name = "Attach",
						processId = require("dap.utils").pick_process,
						cwd = "${workspaceFolder}",
						sourceMaps = true,
					},
					{
						type = "pwa-chrome",
						request = "launch",
						name = "Launch & Debug Chrome",
						url = function()
							local co = coroutine.running()
							return coroutine.create(function()
								vim.ui.input({
									prompt = "Enter URL: ",
									default = "http://localhost:3000",
								}, function(url)
									if url == nil or url == "" then 
										return
									else
										coroutine.resume(co, url)
									end
								end)
							end)
						end,
						webroot = "${workspaceFolder}",
						skipFiles = { "<node_internals>/**/*.js" },
						protocol = "inspector",
						sourceMaps = true,
						useDataDir = false,
					},
					{
						name = "----- lauch.json configs -----",
						type = "",
						request = "launch",
					}

				}

			end
		end,
		keys = {
			{
				"<leader>dO",
				function()
					require("dap").step_out()
				end,
				desc = "Step [O]ut",
			},
			{
				"<leader>do",
				function()
					require("dap").step_over()
				end,
				desc = "Step [o]ver",
			},
			{
				"<leader>da",
				function()
					if vim.fn.filereadable(".vscode/launch.json") then
						local dap_vscode = require("dap.ext.vscode")
						dap_vscode.load_launchjs(nil, {
							["pwa-node"] = js_based_languages,
							["node"] = js_based_languages,
							["chrome"] = js_based_languages,
							["pwa-chrome"] = js_based_languages,
						})
					end
					require("dap").continue()
				end,
				desc = "Run with Args",
			}
		},
	},
	dependencies = {
		{
			"microsoft/vscode-js-debug",
			build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out"
		},
		{
			"mxsdev/nvim-dap-vscode-js",
			config = function()
				require("dap-vscode-js").setup({
					debugger_path = vim.fn.resolve(vim.fn.stdpath("data" .. "/lazy/vscode-js-debug"),
					adapters = {
						"chrome",
						"pwa-node",
						"pwa-chrome",
						"node",
						"pwa-msedge",
						"pwa-extensionHost",
						"node-terminal"
					},	
				})
			end,
		},
		{
			"Joakker/lua-json5",
			build = "./install.sh",
		}
	}
}

