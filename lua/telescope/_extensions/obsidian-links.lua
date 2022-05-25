local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"



-- our picker function: colors
local link_to = function(opts)

    local find_command = (function(opts)
        if opts then
            if opts.find_command then
                return opts.find_command
            end
        elseif 1 == vim.fn.executable "fd" then
            return { "fd", "--type", "f" }
        elseif 1 == vim.fn.executable "fdfind" then
            return { "fdfind", "--type", "f" }
        elseif 1 == vim.fn.executable "rg" then
            return { "rg", "--files" }
        elseif 1 == vim.fn.executable "find" and vim.fn.has "win32" == 0 then
            return { "find", ".", "-type", "f" }
        elseif 1 == vim.fn.executable "where" then
            return { "where", "/r", ".", "*" }
        end
    end)()

    function split (inputstr, sep)
        if sep == nil then
            sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
        end
        return t
    end

    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "Link to file",
        finder = finders.new_oneshot_job(find_command, opts),
        previewer = conf.file_previewer(opts),
        sorter = conf.file_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                local split_path = split(selection[1], "/")
                vim.api.nvim_put({ split_path[#split_path] }, "", false, true)
            end)
            return true
        end,
    }):find()
end
