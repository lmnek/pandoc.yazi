local function fail(s, ...)
    ya.notify { title = "Pandoc", content = string.format(s, ...), level = "error", timeout = 5, }
end

local function run_pandoc(in_url, out_url)
    if Url(in_url) == Url(out_url) then
        fail("Input and output file are the same:\n%s", in_url)
        return nil, nil
    end
    -- TODO: check if file already exists -> skip/warn

    local output, err = Command("pandoc")
        :arg("-o"):arg(out_url)
        :arg(in_url)
        :stderr(Command.PIPED)
        :output()

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

local function single_conversion(url)
    local u = Url(url)
    local out_filename, event = ya.input {
        title = "Pandoc (output file):",
        value = u.stem .. ".",
        pos = INPUT_POS,
        position = INPUT_POS,
    }
    if event ~= 1 then return end

    local out_url = tostring(u.parent:join(out_filename))
    run_pandoc(url, out_url)
end


local function bulk_conversion(urls)
    local ext, event = ya.input {
        title = "Pandoc (output extension):",
        pos = INPUT_POS,
        position = INPUT_POS,
    }
    if event ~= 1 then return end
    ext = ext:gsub("^%.*", ""):lower() -- strip leading dots

    -- TODO: progress notif on fail
    for _, url in ipairs(urls) do
        local u = Url(url)
        local out_url = tostring(u.parent:join(u.stem .. "." .. ext))
        local output, _ = run_pandoc(url, out_url)
        if output == nil then return end
    end

    ya.notify { title = "Pandoc", content = "Successfully finished bulk conversion", level = "info", timeout = 3, }
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
    entry = function()
        ya.emit("escape", { visual = true })

        local urls = selected_else_hovered()
        if #urls == 0 then
            return ya.notify { title = "Pandoc", content = "No file selected", level = "warn", timeout = 5 }
        end

        if #urls == 1 then
            single_conversion(urls[1])
        else
            bulk_conversion(urls)
        end
    end,
}
