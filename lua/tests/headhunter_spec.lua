local stub = require("luassert.stub")
local headhunter = require("headhunter")

describe("headhunter.nvim", function()
    local keymap_set

    before_each(function()
        keymap_set = stub(vim.keymap, "set")
    end)

    after_each(function()
        keymap_set:revert()
    end)

    it("registers default keymaps", function()
        headhunter.setup()

        local seen = {}
        for _, call in ipairs(keymap_set.calls) do
            seen[call.vals[2]] = call.vals[3]
        end

        assert.are.equal(headhunter.prev_conflict, seen["[g"])
        assert.are.equal(headhunter.next_conflict, seen["]g"])
        assert.are.equal(headhunter.take_head, seen["<leader>gh"])
        assert.are.equal(headhunter.take_origin, seen["<leader>go"])
        assert.are.equal(headhunter.take_both, seen["<leader>gb"])
    end)

    it("allows overriding keymaps", function()
        headhunter.setup({
            keymaps = {
                next_conflict = "]c",
            },
        })

        local found_override = false
        for _, call in ipairs(keymap_set.calls) do
            local lhs = call.vals[2]
            local rhs = call.vals[3]
            if lhs == "]c" and rhs == headhunter.next_conflict then
                found_override = true
            end
        end

        assert.is_true(found_override)
    end)

    it("skips keymap when explicitly disabled", function()
        headhunter.setup({
            keymaps = {
                take_origin = false,
            },
        })

        local seen = {}
        for _, call in ipairs(keymap_set.calls) do
            seen[call.vals[2]] = true
        end

        assert.is_nil(seen["<leader>go"])
        assert.is_true(seen["[g"]) -- other defaults remain
    end)

    it("returns empty table when no conflicts", function()
        local conflicts = headhunter._get_conflicts_mock("")
        assert.are.same({}, conflicts)
    end)

    it("parses single conflict correctly", function()
        local sample = [[
file1.txt:3:<<<<<<< HEAD
file1.txt:5:=======
file1.txt:7:>>>>>>> branch
]]
        local conflicts = headhunter._get_conflicts_mock(sample)
        assert.are.equal(1, #conflicts)
        assert.are.equal("file1.txt", conflicts[1].file)
        assert.are.equal(3, conflicts[1].lnum)
    end)

    it("parses multiple conflicts correctly", function()
        local sample = [[
file1.txt:3:<<<<<<< HEAD
file1.txt:5:=======
file1.txt:7:>>>>>>> branch
file2.txt:10:<<<<<<< HEAD
file2.txt:12:=======
file2.txt:14:>>>>>>> branch
]]
        local conflicts = headhunter._get_conflicts_mock(sample)
        assert.are.equal(2, #conflicts)
        assert.are.equal("file1.txt", conflicts[1].file)
        assert.are.equal(3, conflicts[1].lnum)
        assert.are.equal("file2.txt", conflicts[2].file)
        assert.are.equal(10, conflicts[2].lnum)
    end)

    it("parses stash-style conflict markers", function()
        local sample = [[
file1.txt:3:<<<<<<< Updated upstream
file1.txt:5:=======
file1.txt:7:>>>>>>> Stashed changes
]]
        local conflicts = headhunter._get_conflicts_mock(sample)
        assert.are.equal(1, #conflicts)
        assert.are.equal("file1.txt", conflicts[1].file)
        assert.are.equal(3, conflicts[1].lnum)
    end)
end)
