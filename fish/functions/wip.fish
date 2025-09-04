function wip --wraps='git add . && git commit -m \$argv' --description 'alias wip && git commit -m \$argv'
    set message (string join " " $argv)
    if test -z "$message"
        set message wip
    end
    git add .
    git commit -m "$message"
end
