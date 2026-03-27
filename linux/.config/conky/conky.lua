-- conky.lua — smooth bars + helpers

dofile(os.getenv('HOME') .. '/.config/conky/coat-theme.lua')

local function smooth_bar(pct, width)
    local partial = {"▏","▎","▍","▌","▋","▊","▉"}
    pct = math.max(0, math.min(100, tonumber(pct) or 0))
    local filled  = math.floor(width * pct / 100)
    local rem     = (width * pct / 100) - filled
    local idx     = math.floor(rem * 7)

    local s = string.rep("█", filled)
    if idx > 0 and filled < width then
        s = s .. partial[idx]
        filled = filled + 1
    end
    return s .. string.rep("░", width - filled)
end

function conky_cpubar(core, width)
    local pct = tonumber(conky_parse("${cpu cpu" .. (core or "0") .. "}")) or 0
    return smooth_bar(pct, tonumber(width) or 32)
end

function conky_membar(width)
    return smooth_bar(tonumber(conky_parse("${memperc}")) or 0, tonumber(width) or 32)
end

function conky_diskbar(width)
    return smooth_bar(tonumber(conky_parse("${fs_used_perc /}")) or 0, tonumber(width) or 32)
end

function conky_batbar(width)
    return smooth_bar(tonumber(conky_parse("${battery_percent BAT1}")) or 0, tonumber(width) or 32)
end

function conky_gpubar(width)
    local raw = conky_parse("${exec nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits}")
    return smooth_bar(tonumber(raw:match("%d+")) or 0, tonumber(width) or 32)
end

function conky_cores(from, to)
    local parts = {}
    for i = tonumber(from), tonumber(to) do
        local pct = tonumber(conky_parse("${cpu cpu" .. i .. "}")) or 0
        table.insert(parts, string.format("%d·%3d%%", i, pct))
    end
    return table.concat(parts, "   ")
end

function conky_proc(n)
    local name = conky_parse("${top name " .. n .. "}"):gsub("%s+$", "")
    local cpu  = conky_parse("${top cpu "  .. n .. "}"):gsub("%s+", "")
    local mem  = conky_parse("${top_mem mem_res " .. n .. "}"):gsub("%s+", "")
    return string.format("%-16s  %6s%%  %7s", name, cpu, mem)
end

function conky_playing()
    local artist = conky_parse("${exec playerctl metadata --format '{{artist}}' 2>/dev/null}")
    local title  = conky_parse("${exec playerctl metadata --format '{{title}}'  2>/dev/null}")
    artist = artist:gsub("^%s+",""):gsub("%s+$","")
    title  = title:gsub("^%s+",""):gsub("%s+$","")
    if artist == "" and title == "" then return "─  nothing playing" end
    if #artist > 30 then artist = artist:sub(1,29).."…" end
    if #title  > 30 then title  = title:sub(1,29).."…"  end
    return artist .. "\n  " .. title
end
