local headhunter = require("headhunter")

describe("headhunter.nvim", function()
    it("shoul register keymaps by default", function()
        headhunter.keymaps_registered = false
        headhunter._register_keymaps = function(config)
            headhunter.keymaps_registered = true
        end

        headhunter.setup()

        assert.is_true(headhunter.keymaps_registered)
    end)

    it(
        "should skip keymaps registration when explicitly specified in the config",
        function()
            headhunter.keymaps_registered = false
            headhunter._register_keymaps = function(config)
                headhunter.keymaps_registered = true
            end

            headhunter.setup({
                -- Disable keymap registration
                register_keymaps = false,
            })

            assert.is_false(headhunter.keymaps_registered)
        end
    )

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
end)
