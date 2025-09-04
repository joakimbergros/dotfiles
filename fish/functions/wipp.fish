function wipp --wraps='wip \$argv && git push' --description 'wip \$argv && git push'
    set message (string join " " $argv)
    if test -z "$message"
        set message wip
    end
    wip "$message" && git push
end
