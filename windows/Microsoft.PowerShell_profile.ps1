fastfetch
Set-Alias -Name jit -Value git
Set-Alias -Name cl -Value clear
Invoke-Expression (&scoop-search --hook)

# Remove any PS alias that has a matching executable in PATH (lets uutils win)
Get-Alias | Where-Object {
    Get-Command $_.Name -CommandType Application -ErrorAction SilentlyContinue
} | ForEach-Object {
    Remove-Item "Alias:\$($_.Name)" -Force -ErrorAction SilentlyContinue
}

# Cache slow queries
$script:_memCacheTime = [datetime]::MinValue
$script:_memCache     = $null
$script:_ipCacheTime  = [datetime]::MinValue
$script:_ipCache      = $null

function prompt {
    # Capture before anything else runs
    $lastSuccess  = $?
    $lastExitCode = $global:LASTEXITCODE

    # ANSI helpers
    $r  = "`e[0m"
    $bG = "`e[1;37m"   # bold white
    $dG = "`e[2;37m"   # dim white
    $W  = "`e[1;37m"   # bold white
    $B  = "`e[1;37m"   # bold white
    $Y  = "`e[0;37m"   # white
    $C  = "`e[1;37m"   # bold white
    $P  = "`e[2;37m"   # dim white
    $R  = "`e[1;31m"   # bold red (errors only)

    # Time
    $time = Get-Date -Format "hh:mm:ss tt"

    # Memory (cached 30s)
    if (([datetime]::Now - $script:_memCacheTime).TotalSeconds -gt 30) {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        $script:_memCache = if ($os) {
            [math]::Round(($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100)
        } else { $null }
        $script:_memCacheTime = [datetime]::Now
    }
    $memStr = if ($null -ne $script:_memCache) { "$dG $script:_memCache%$r" } else { "" }

    # IP (cached 60s)
    if (([datetime]::Now - $script:_ipCacheTime).TotalSeconds -gt 60) {
        $script:_ipCache = (Get-NetIPAddress -AddressFamily IPv4 -Type Unicast -ErrorAction SilentlyContinue |
            Where-Object { $_.InterfaceAlias -notmatch 'Loopback' } |
            Select-Object -First 1).IPAddress
        $script:_ipCacheTime = [datetime]::Now
    }
    $ipStr = if ($script:_ipCache) { "$Y@$($script:_ipCache)$r " } else { "" }

    # Directory (truncated to 3 parts, forward slashes)
    $dir   = $PWD.Path -replace [regex]::Escape($HOME), '~'
    $parts = $dir -split '\\'
    if ($parts.Count -gt 3) { $dir = ".../" + ($parts[-2..-1] -join '/') }
    else { $dir = $dir -replace '\\', '/' }

    # Command duration (from history)
    $durationStr = ""
    $lastCmd = Get-History -Count 1
    if ($lastCmd -and $lastCmd.Duration.TotalMilliseconds -ge 500) {
        $d = $lastCmd.Duration
        $durationStr = " $Y" + $(
            if    ($d.TotalHours   -ge 1) { "$([math]::Floor($d.TotalHours))h$($d.Minutes)m$($d.Seconds)s" }
            elseif($d.TotalMinutes -ge 1) { "$($d.Minutes)m$($d.Seconds)s" }
            else                          { "$([math]::Round($d.TotalSeconds, 1))s" }
        ) + $r
    }

    # Battery
    $batteryStr = ""
    $bat = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue
    if ($bat) {
        $pct  = $bat.EstimatedChargeRemaining
        $icon = if ($bat.BatteryStatus -eq 2) { "" }
                elseif ($pct -le 10)          { "" }
                elseif ($pct -le 30)          { "" }
                else                          { "" }
        $batteryStr = " $icon$pct%"
    }

    # Git — read .git/HEAD directly, no external process
    $gitStr = ""
    $dir2 = $PWD.Path
    while ($dir2) {
        $head = Join-Path $dir2 ".git/HEAD"
        if (Test-Path $head -ErrorAction SilentlyContinue) {
            $headContent = Get-Content $head -Raw -ErrorAction SilentlyContinue
            if ($headContent -match 'ref: refs/heads/(.+)') {
                $branch = $Matches[1].Trim()
                $dirty = if ((Get-ChildItem (Join-Path $dir2 ".git/index") -ErrorAction SilentlyContinue) -and
                             (git status --porcelain 2>$null)) { "*" } else { "" }
                $gitStr = " on $P $branch$dirty$r"
            }
            break
        }
        $parent = Split-Path $dir2 -Parent
        if ($parent -eq $dir2) { break }
        $dir2 = $parent
    }

    # Build lines
    $line1  = "$bG╭─$r $W$time$r $B$($env:USERNAME)$r$memStr $ipStr$C$($env:COMPUTERNAME.ToLower())$r in $P$dir$r"
    $line1 += $gitStr
    $line1 += $durationStr
    $line1 += $batteryStr

    $hasError  = $lastExitCode -and $lastExitCode -ne 0
    $statusStr = if ($hasError) { "$R$lastExitCode$r " } else { "" }
    $char      = if ($hasError) { "$R>$r" } else { "$bG>$r" }
    $line2     = "$bG╰─$r $statusStr$char"

    # Restore state so PSReadLine doesn't pick up stale exit codes
    $global:LASTEXITCODE = $lastExitCode
    $null = $null  # resets $? to $true

    "$line1`n$line2 "
}
