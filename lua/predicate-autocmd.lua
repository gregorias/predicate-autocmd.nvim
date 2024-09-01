local M = {}
local L = {}

---Types relevant for `nvim_create_autocmd`.
---
---@alias AutocmdEvent string | string[]
---
---@class AutocmdArgs
---@field [1] AutocmdEvent
---@field pattern? string | string[]
---@field buffer? integer
---
---@class AutocmdOpts
---@field pattern? string | string[]
---@field buffer? integer

--- Gets the autocmd options from the autocmd args.
---
---@param autocmd_args AutocmdArgs
---@return AutocmdOpts
local get_opts_from_autocmd_args = function(autocmd_args)
  return { pattern = autocmd_args.pattern, buffer = autocmd_args.buffer }
end

--- Transforms input into autocmd args.
---
---@param input AutocmdEvent | AutocmdArgs
---@return AutocmdArgs
local to_autocmd_args = function(input)
  if type(input) == "string" then
    return { input }
  elseif input.pattern ~= nil or input.buffer ~= nil then
    return input
  else
    return { input }
  end
end

---@alias Predicate AutocmdEvent | AutocmdArgs | table<string | Predicate>

---@param predicate Predicate
---@return any, any
local parse_predicate_to_proposition = function(predicate)
  if type(predicate) == "table" and (predicate[1] == "and" or predicate[1] == "or") then
    local propositions = {}
    for i = 2, #predicate do
      table.insert(propositions, predicate[i])
    end
    return predicate[1], propositions
  else
    return nil
  end
end

--- Event is a runtime object representing a tree of autocmd events that are waiting to be triggered.
---
--- An event can represent an atomic autocmd event or a boolean tree of events.
---
---@class Event
---@field is_true fun():boolean Returns true if the event has been triggered.
---@field stop fun():nil Stops listening for the event.

--- Creates an autocmd that runs once the predicate evaluates to true.
---
--- Example call that runs foo once "BufRead" and "User/VeryLazy" events have happened:
---
--- ```lua
--- create_autocmd(
---   {"and", "BufRead", {"User", pattern = "VeryLazy"}},
---   foo
--- )
--- ```
---
---@param predicate Predicate
---@param autocmd_cb fun():nil
function M.create_autocmd(predicate, autocmd_cb)
  L.wait_for_predicate(predicate, autocmd_cb)
end

--- Turns a predicate into an active Event object.
---
---@param predicate Predicate
---@return Event
L.wait_for_predicate = function(predicate, cb)
  local operator, propositions = parse_predicate_to_proposition(predicate)
  if operator ~= nil then
    return L.proposition_event(operator, propositions, cb)
  else
    return L.autocmd_event(to_autocmd_args(predicate), cb)
  end
end

--- Creates an Event that waits for a proposition of predicates to be true.
---
---@param operator "and" | "or"
---@param predicates Predicate[]
---@param cb fun():nil A callback.
---@return Event
L.proposition_event = function(operator, predicates, cb)
  if operator == "and" then
    local has_triggered = false
    local events = {}
    local event_cb = function()
      for _, event in ipairs(events) do
        if not event.is_true() then
          return
        end
      end
      has_triggered = true
      cb()
    end

    for _, predicate in ipairs(predicates) do
      table.insert(events, L.wait_for_predicate(predicate, event_cb))
    end

    return {
      is_true = function()
        return has_triggered
      end,
      stop = function()
        for _, event in ipairs(events) do
          event.stop()
        end
        events = {}
      end,
    }
  elseif operator == "or" then
    local events = {}
    local has_triggered = false
    local event_cb = function()
      if has_triggered then
        return
      end
      has_triggered = true
      for _, event in ipairs(events) do
        event.stop()
      end
      events = {}
      cb()
    end

    for _, predicate in ipairs(predicates) do
      table.insert(events, L.wait_for_predicate(predicate, event_cb))
    end
    return {
      is_true = function()
        return has_triggered
      end,
      stop = function()
        for _, event in ipairs(events) do
          event.stop()
        end
        events = {}
      end,
    }
  else
    error("Invalid operator: " .. operator)
  end
end

--- Creates an Event that waits for an autocmd event.
---
---@param autocmd_args AutocmdArgs
---@param cb fun():nil A callback.
---@return Event
L.autocmd_event = function(autocmd_args, cb)
  local has_triggered = false
  ---@type any
  local autocmd_opts = get_opts_from_autocmd_args(autocmd_args)
  local autocmd_id = nil
  autocmd_opts.once = true
  autocmd_opts.callback = function()
    has_triggered = true
    autocmd_id = nil
    cb()
  end

  autocmd_id = vim.api.nvim_create_autocmd(autocmd_args[1], autocmd_opts)

  return {
    is_true = function()
      return has_triggered
    end,
    stop = function()
      if autocmd_id then
        vim.api.nvim_del_autocmd(autocmd_id)
        autocmd_id = nil
      end
    end,
  }
end

return M
