function fish_prompt
    set -l last_status $status
    set -l last_duration $CMD_DURATION

    # Hostname — bold cyan
    set_color --bold cyan
    printf '%s' (hostname)
    set_color normal
    printf ' '

    # Directory — bold magenta, last 3 components
    set_color --bold magenta
    printf '%s' (prompt_pwd -D 3)
    set_color normal
    printf ' '

    # Git branch + status
    set -l branch (git branch --show-current 2>/dev/null)
    if test -n "$branch"
        set_color --bold magenta
        printf 'on  %s' $branch
        set_color normal
        printf ' '

        # Dirty indicators
        set -l porcelain (git status --porcelain 2>/dev/null)
        if test -n "$porcelain"
            set -l indicators ''
            string match -rq '^\?\?' $porcelain; and set indicators $indicators'?'
            string match -rq '^.[MD]' $porcelain; and set indicators $indicators'!'
            string match -rq '^[MADRCU]' $porcelain; and set indicators $indicators'+'
            set_color --bold red
            printf '[%s]' $indicators
            set_color normal
            printf ' '
        end

        # Ahead/behind
        set -l upstream (git rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
        if test -n "$upstream"
            set -l counts (git rev-list --left-right --count HEAD...$upstream 2>/dev/null)
            if test -n "$counts"
                set -l ahead (printf '%s' $counts | awk '{print $1}')
                set -l behind (printf '%s' $counts | awk '{print $2}')
                if test "$ahead" -gt 0 -o "$behind" -gt 0
                    set_color --bold red
                    test "$ahead" -gt 0; and printf '⇡%s' $ahead
                    test "$behind" -gt 0; and printf '⇣%s' $behind
                    printf ' '
                    set_color normal
                end
            end
        end
    end

    # Command duration (only if >= 500ms)
    if test $last_duration -ge 500
        set_color --bold yellow
        if test $last_duration -ge 60000
            printf 'took %dm%ds ' (math --scale=0 $last_duration / 60000) (math --scale=0 "($last_duration % 60000) / 1000")
        else if test $last_duration -ge 1000
            printf 'took %.1fs ' (math $last_duration / 1000.0)
        else
            printf 'took %dms ' $last_duration
        end
        set_color normal
    end

    # Prompt character — green on success, red on failure
    if test $last_status -eq 0
        set_color --bold green
    else
        set_color --bold red
    end
    printf '❯ '
    set_color normal
end
