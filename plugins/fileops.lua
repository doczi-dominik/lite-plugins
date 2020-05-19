local core = require "core"
local common = require "core.common"
local config = require "core.config"
local commands = require "core.command"


config.fileops_disable_log  = false
config.fileops_show_confirm = false

----------------------------------------------------------------------------

local delFilePattern, delDirPattern, newDirPattern, movePattern, copyPattern

if PLATFORM == "Windows" then
  delFilePattern = "del /q %s"
  delDirPattern  = "rd /s %s"
  newDirPattern  = "md %s"
  movePattern    = "move /y %s %s"
  copyPattern    = "copy /y %s %s"
else
  delFilePattern = "rm %s"
  delDirPattern  = "rm -rf %s"
  newDirPattern  = "mkdir %s"
  movePattern    = "mv %s %s"
  copyPattern    = "cp -r %s %s"
end

----------------------------------------------------------------------------

local function _write_log(op, success, command)
  if config.fileops_disable_log then
    return
  end

  local message = string.format("%s  |  success: %s  |  command: %q", op, tostring(success), command)

  if config.fileops_show_confirm then
    core.log(message)
  else
    core.log_quiet(message)
  end
end

local function _execute(op, command)
  local success = os.execute(command)

  if not success then
    core.log("Files: Operation failed. Check the log for details.")
  end

  _write_log(op, success, command)
end

----------------------------------------------------------------------------

commands.add(nil, {
  ["files:delete-file"] = function()
    core.command_view:enter("Delete File", function(filename)
      if filename then
        local command = string.format(delFilePattern, filename)

        _execute("files:delete-file", command)
      end
    end, common.path_suggest)
  end,

  ["files:delete-directory"] = function()
    core.command_view:enter("RECURSIVELY Delete Directory", function(dirname)
      if dirname then
        local command = string.format(delDirPattern, dirname)

        _execute("files:delete-directory", command)
      end
    end, common.path_suggest)
  end,

  ["files:new-directory"] = function()
    core.command_view:enter("New Directory Name", function(dirname)
      local command = string.format(newDirPattern, dirname)

      _execute("files:new-directory", command)
    end, common.path_suggest)
  end,

  ["files:move"] = function()
    core.command_view:enter("Move From", function(src)
      core.command_view:enter("Move To", function(dest)
        local command = string.format(movePattern, src, dest)

        _execute("files:move", command)
      end, common.path_suggest)
    end, common.path_suggest)
  end,

  ["files:copy"] = function()
    core.command_view:enter("Copy From", function(src)
      core.command_view:enter("Copy To", function(dest)
        local command = string.format(copyPattern, src, dest)

        _execute("files:copy", command)
      end, common.path_suggest)
    end, common.path_suggest)
  end
})
