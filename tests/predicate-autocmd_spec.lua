local predicate_autocmd = require("predicate-autocmd")
describe("predicate-autocmd", function()
  it("should trigger callback on user event", function()
    local done = false
    predicate_autocmd.create_autocmd({
      [1] = "User",
      pattern = "Test",
    }, function()
      done = true
    end)

    assert.is.False(done)

    vim.api.nvim_exec_autocmds("User", { pattern = "Test" })

    assert.is.True(done)
  end)

  it("should trigger callback on one user event once", function()
    local done = false
		local count = 0
    local predicate = { "or", { [1] = "User", pattern = "Test1" }, { [1] = "User", pattern = "Test2" } }
    predicate_autocmd.create_autocmd(predicate, function()
      done = true
			count = count + 1
    end)

    assert.is.False(done)

    vim.api.nvim_exec_autocmds("User", { pattern = "Test1" })

    assert.is.True(done)
		assert.are.same(count, 1)

    vim.api.nvim_exec_autocmds("User", { pattern = "Test2" })

		assert.are.same(count, 1)
  end)

  it("should trigger callback on all user events", function()
    local done = false
    local predicate = { "and", { [1] = "User", pattern = "Test1" }, { [1] = "User", pattern = "Test2" } }
    predicate_autocmd.create_autocmd(predicate, function()
      done = true
    end)

    assert.is.False(done)

    vim.api.nvim_exec_autocmds("User", { pattern = "Test1" })

    assert.is.False(done)

    vim.api.nvim_exec_autocmds("User", { pattern = "Test2" })

    assert.is.True(done)
  end)
end)
