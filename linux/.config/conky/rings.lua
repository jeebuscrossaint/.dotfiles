require 'cairo'

dofile(os.getenv('HOME') .. '/.config/conky/coat-theme.lua')

function conky_rings()
    -- dump conky_window fields
    if conky_window then
        for k, v in pairs(conky_window) do
            print("conky_window." .. tostring(k) .. " = " .. tostring(v))
        end
    else
        print("conky_window is nil")
    end

    -- dump available cairo_* globals
    local hits = {}
    for k, v in pairs(_G) do
        if tostring(k):sub(1,6) == "cairo_" then
            table.insert(hits, tostring(k) .. " = " .. type(v))
        end
    end
    table.sort(hits)
    for _, s in ipairs(hits) do print(s) end
end

function conky_playing()
    local artist = conky_parse("${exec playerctl metadata --format '{{artist}}' 2>/dev/null}")
    local title  = conky_parse("${exec playerctl metadata --format '{{title}}'  2>/dev/null}")
    artist = artist:gsub("^%s+",""):gsub("%s+$","")
    title  = title:gsub("^%s+",""):gsub("%s+$","")
    if artist == "" and title == "" then return "─ nothing playing" end
    if #artist > 32 then artist = artist:sub(1,31).."…" end
    if #title  > 32 then title  = title:sub(1,31).."…"  end
    return artist .. "\n  " .. title
end
