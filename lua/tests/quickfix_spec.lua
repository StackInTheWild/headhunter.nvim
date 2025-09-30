local headhunter = require("headhunter")

describe("headhunter quickfix integration", function()
    local original_get_conflicts

    before_each(function()
        original_get_conflicts = headhunter._get_conflicts
        vim.fn.setqflist({})
    end)

    after_each(function()
        headhunter._get_conflicts = original_get_conflicts
        vim.fn.setqflist({})
    end)

    it("populates quickfix with conflicts", function()
        local file = vim.fn.fnamemodify("lua/headhunter/init.lua", ":p")
        headhunter._get_conflicts = function()
            return {
                { file = file, lnum = 12 },
            }
        end

        headhunter.populate_quickfix()

        local items = vim.fn.getqflist()
        assert.are.equal(1, #items)
        local listed_path = items[1].filename
            or vim.fn.fnamemodify(vim.fn.bufname(items[1].bufnr), ":.")
        assert.are.equal(vim.fn.fnamemodify(file, ":."), listed_path)
        assert.are.equal(12, items[1].lnum)
        assert.are.equal("Merge conflict marker", items[1].text)
    end)

    it("clears quickfix when no conflicts", function()
        headhunter._get_conflicts = function()
            return {}
        end
        vim.fn.setqflist({
            {
                filename = "dummy.lua",
                lnum = 1,
            },
        })

        headhunter.populate_quickfix()

        local items = vim.fn.getqflist()
        assert.are.equal(0, #items)
    end)
end)
