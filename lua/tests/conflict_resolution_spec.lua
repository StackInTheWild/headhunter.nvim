local headhunter = require("headhunter")

describe("headhunter conflict resolution", function()
    local bufnr

    before_each(function()
        bufnr = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(bufnr)
    end)

    it("takes HEAD block", function()
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "<<<<<<< HEAD",
            "my change",
            "=======",
            "their change",
            ">>>>>>> branch",
        })
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        headhunter.take_head()

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        assert.are.same({ "my change" }, lines)
    end)

    it("takes ORIGIN block", function()
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "<<<<<<< HEAD",
            "my change",
            "=======",
            "their change",
            ">>>>>>> branch",
        })
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        headhunter.take_origin()

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        assert.are.same({ "their change" }, lines)
    end)

    it("takes BOTH blocks", function()
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
            "<<<<<<< HEAD",
            "my change",
            "=======",
            "their change",
            ">>>>>>> branch",
        })
        vim.api.nvim_win_set_cursor(0, { 1, 0 })

        headhunter.take_both()

        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        assert.are.same({ "my change", "their change" }, lines)
    end)
end)
