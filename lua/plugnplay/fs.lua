local fs = {}

---Check if file exists
---@param location string The location of the file
---@return boolean exists Whether the file exists or not
function fs.file_exists(location)
    local fd = vim.loop.fs_open(location, "r", 438)
    if fd then
        vim.loop.fs_close(fd)
        return true
    end
    return false
end

function fs.write_file(location, mode, contents)
    -- 644 sets read and write permissions for the owner, and it sets read-only
    -- mode for the group and others
    vim.loop.fs_open(location, mode, tonumber("644", 8), function(err, file)
        if not err then
            local file_pipe = vim.loop.new_pipe(false)
            vim.loop.pipe_open(file_pipe, file)
            vim.loop.write(file_pipe, contents)
            vim.loop.fs_close(file)
        end
    end)
end

---Reads or creates from a file
---@param location string The location of the file
---@param default string The contents to write to the file if it doesn't exist
function fs.read_or_create(location, default)
    local content
    if fs.file_exists(location) then
        local file = vim.loop.fs_open(location, "r", 438)
        local stat = vim.loop.fs_fstat(file)
        content = vim.loop.fs_read(file, stat.size, 0)
        vim.loop.fs_close(file)
    else
        content = vim.trim(default)
        fs.write_file(location, "w+", content)
    end

    return content
end

return fs
