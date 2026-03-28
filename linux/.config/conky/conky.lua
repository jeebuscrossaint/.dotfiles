-- conky.lua — hardware auto-detection + helpers

dofile(os.getenv('HOME') .. '/.config/conky/coat-theme.lua')

-- ── detection helpers ────────────────────────────────────────────────────────

local function read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local s = f:read("*l"); f:close(); return s
end

local function shell(cmd)
    local f = io.popen(cmd .. " 2>/dev/null")
    local r = f:read("*l"); f:close()
    return r and r:gsub("^%s+", ""):gsub("%s+$", "") or ""
end

local function find_hwmon(name)
    for i = 0, 30 do
        local n = read_file("/sys/class/hwmon/hwmon" .. i .. "/name")
        if n and n:gsub("%s+$","") == name then return i end
    end
    return nil
end

local function detect_gpu()
    if shell("command -v nvidia-smi") ~= "" then return "nvidia" end
    if shell("command -v rocm-smi")   ~= "" then return "amd"    end
    return "none"
end

-- ── hardware table (detected once at startup) ────────────────────────────────

local HW = {
    iface    = shell("ip route show default | awk 'NR==1{print $5}'"),
    battery  = shell("ls /sys/class/power_supply/ | grep -m1 BAT"),
    gpu      = detect_gpu(),
    cores    = tonumber(shell("nproc")) or 4,
    cpu_hwmon  = find_hwmon("coretemp") or find_hwmon("k10temp") or find_hwmon("zentemp"),
    nvme_hwmon = find_hwmon("nvme"),
}

if HW.iface   == "" then HW.iface   = "eth0" end
if HW.battery == "" then HW.battery = "BAT0" end

-- ── smooth bar ───────────────────────────────────────────────────────────────

local function smooth_bar(pct, width)
    local partial = {"▏","▎","▍","▌","▋","▊","▉"}
    pct = math.max(0, math.min(100, tonumber(pct) or 0))
    local filled = math.floor(width * pct / 100)
    local idx    = math.floor(((width * pct / 100) - filled) * 7)
    local s = string.rep("█", filled)
    if idx > 0 and filled < width then s = s .. partial[idx]; filled = filled + 1 end
    return s .. string.rep("░", width - filled)
end

-- ── bar functions ────────────────────────────────────────────────────────────

function conky_cpubar(core, width)
    local pct = tonumber(conky_parse("${cpu cpu" .. (core or "0") .. "}")) or 0
    return smooth_bar(pct, tonumber(width) or 40)
end

function conky_membar(width)
    return smooth_bar(tonumber(conky_parse("${memperc}")) or 0, tonumber(width) or 40)
end

function conky_diskbar(width)
    return smooth_bar(tonumber(conky_parse("${fs_used_perc /}")) or 0, tonumber(width) or 40)
end

function conky_batbar(width)
    local pct = tonumber(conky_parse("${battery_percent " .. HW.battery .. "}")) or 0
    return smooth_bar(pct, tonumber(width) or 40)
end

function conky_gpubar(width)
    local pct = 0
    if HW.gpu == "nvidia" then
        local raw = shell("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits")
        pct = tonumber(raw:match("%d+")) or 0
    elseif HW.gpu == "amd" then
        local raw = shell("rocm-smi --showuse --csv | awk -F',' 'NR==2{print $2}'")
        pct = tonumber(raw) or 0
    end
    return smooth_bar(pct, tonumber(width) or 40)
end

-- ── hardware stat functions (use detected HW) ────────────────────────────────

function conky_cpu_temp()
    if not HW.cpu_hwmon then return "?" end
    local raw = read_file("/sys/class/hwmon/hwmon" .. HW.cpu_hwmon .. "/temp1_input")
    if not raw then return "?" end
    return math.floor(tonumber(raw) / 1000) .. "°C"
end

function conky_nvme_temp()
    if not HW.nvme_hwmon then return "?" end
    local raw = read_file("/sys/class/hwmon/hwmon" .. HW.nvme_hwmon .. "/temp1_input")
    if not raw then return "?" end
    return math.floor(tonumber(raw) / 1000) .. "°C"
end

function conky_gpu_temp()
    if HW.gpu == "nvidia" then
        return shell("nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits") .. "°C"
    elseif HW.gpu == "amd" then
        return shell("rocm-smi --showtemp --csv | awk -F',' 'NR==2{print $2}'") .. "°C"
    end
    return "N/A"
end

function conky_gpu_util()
    if HW.gpu == "nvidia" then
        return shell("nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits") .. "%"
    elseif HW.gpu == "amd" then
        return shell("rocm-smi --showuse --csv | awk -F',' 'NR==2{print $2}'") .. "%"
    end
    return "N/A"
end

function conky_gpu_vram()
    if HW.gpu == "nvidia" then
        local used  = shell("nvidia-smi --query-gpu=memory.used  --format=csv,noheader,nounits")
        local total = shell("nvidia-smi --query-gpu=memory.total --format=csv,noheader,nounits")
        return used .. " / " .. total .. " MiB"
    elseif HW.gpu == "amd" then
        return shell("rocm-smi --showmemuse --csv | awk -F',' 'NR==2{print $2}'") .. "%"
    end
    return "N/A"
end

function conky_net_header()
    local f = io.open("/proc/net/wireless", "r")
    if f then
        for line in f:lines() do
            if line:match(HW.iface) then
                f:close()
                local quality = line:match(HW.iface .. ":%s+%S+%s+(%S+)")
                if quality then
                    local q = tonumber(quality:gsub("%.", ""))
                    if q then
                        local pct = math.min(100, math.floor(q / 70 * 100))
                        return HW.iface .. "  wifi " .. pct .. "%"
                    end
                end
            end
        end
        f:close()
    end
    return HW.iface
end

function conky_upspeed()   return conky_parse("${upspeed "   .. HW.iface .. "}") end
function conky_downspeed() return conky_parse("${downspeed " .. HW.iface .. "}") end
function conky_totalup()   return conky_parse("${totalup "   .. HW.iface .. "}") end
function conky_totaldown() return conky_parse("${totaldown " .. HW.iface .. "}") end

function conky_bat_status() return conky_parse("${battery_status "  .. HW.battery .. "}") end
function conky_bat_pct()    return conky_parse("${battery_percent " .. HW.battery .. "}") .. "%" end
function conky_bat_time()   return conky_parse("${battery_time "    .. HW.battery .. "}") end

-- ── cores (adapts to actual cpu count) ───────────────────────────────────────

function conky_cores(from, to)
    local parts = {}
    for i = tonumber(from), math.min(tonumber(to), HW.cores) do
        local pct = tonumber(conky_parse("${cpu cpu" .. i .. "}")) or 0
        table.insert(parts, string.format("%d·%3d%%", i, pct))
    end
    return table.concat(parts, "   ")
end

-- ── now playing ──────────────────────────────────────────────────────────────

function conky_playing()
    local artist = shell("playerctl metadata --format '{{artist}}'")
    local title  = shell("playerctl metadata --format '{{title}}'")
    if artist == "" and title == "" then return "─  nothing playing" end
    if #artist > 30 then artist = artist:sub(1,29).."…" end
    if #title  > 30 then title  = title:sub(1,29).."…"  end
    return artist .. "\n  " .. title
end
