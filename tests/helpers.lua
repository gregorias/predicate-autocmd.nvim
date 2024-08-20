--- Test utilities.
local M = {}

---Creates a buffer with the given content lines.
---
---Also sets the buffer as the current buffer.
---
---@param content_lines table<string>
---@return number buf_no The buffer number.
M.create_buf = function(content_lines)
  local buf = vim.api.nvim_create_buf(--[[listed]] false, --[[scratch]] true)
  vim.api.nvim_buf_set_lines(
    --[[buffer]]
    buf,
    --[[start]]
    0,
    --[[end]]
    -1,
    --[[strict_indexing]]
    true,
    content_lines
  )
  vim.cmd("buffer " .. buf)
  return buf
end

return M
