local function fail(s, ...)
    ya.notify { title = "Pandoc", content = string.format(s, ...), level = "error", timeout = 5, }
end

local function run_pandoc(in_url, out_url, args)
    local uniq_out_url, err = fs.unique_name(Url(out_url))
    if uniq_out_url == nil or err ~= nil then
        fail("Failed to get unique output file name: %s", err)
        return nil, nil
    end

    local cmd = Command("pandoc")
        :arg("--output"):arg(tostring(uniq_out_url))
        :arg(in_url)

    if args.defaults ~= nil then
        cmd:arg("--defaults"):arg(args.defaults)
    end

    local output, err = cmd:stderr(Command.PIPED):output()

    if not output then
        fail("Failed to run pandoc: %s", err)
        return nil, nil
    elseif not output.status.success then
        fail("Pandoc failed with stderr:\n%s", output.stderr)
        return nil, nil
    end

    return output, err
end

local INPUT_POS = { "top-center", y = 3, w = 40 }

local function single_rename_conversion(url, args)
    local u = Url(url)
    local out_filename, event = ya.input {
        title = "Pandoc (output file):",
        value = u.stem .. ".",
        pos = INPUT_POS,
        position = INPUT_POS,
    }
    if event ~= 1 then return end

    local out_url = tostring(u.parent:join(out_filename))
    run_pandoc(url, out_url, args)
end


local function bulk_conversion(urls, args)
    local ext
    if args.to_ext == nil then
        local value, event = ya.input {
            title = "Pandoc (output extension):",
            pos = INPUT_POS,
            position = INPUT_POS,
        }
        if event ~= 1 then return end
        ext = value:gsub("^%.*", ""):lower() -- strip leading dots
    else
        ext = args.to_ext
    end

    -- FEAT: track progress + progress notif on fail
    for _, url in ipairs(urls) do
        local u = Url(url)
        local out_url = tostring(u.parent:join(u.stem .. "." .. ext))
        local output, _ = run_pandoc(url, out_url, args)
        if output == nil then return end
    end

    if #urls > 1 then
        ya.notify {
            title = "Pandoc",
            content = string.format("Converted %d file(s) to .%s", #urls, ext),
            level = "info",
            timeout = 3,
        }
    end
end

local selected_else_hovered = ya.sync(function()
    local tab, paths = cx.active, {}
    for _, u in pairs(tab.selected) do
        paths[#paths + 1] = tostring(u)
    end
    if #paths == 0 and tab.current.hovered then
        paths[1] = tostring(tab.current.hovered.url)
    end
    return paths
end)

return {
    -- args: --to_ext, --defaults
    -- FEAT: mode for directly inputing pandoc arguments
    entry = function(self, job)
        ya.emit("escape", { visual = true })

        local urls = selected_else_hovered()
        if #urls == 0 then
            return ya.notify { title = "Pandoc", content = "No file selected", level = "warn", timeout = 5 }
        end

        if #urls == 1 and job.args.to_ext == nil then
            single_rename_conversion(urls[1], job.args)
        else
            bulk_conversion(urls, job.args)
        end
    end,
}
