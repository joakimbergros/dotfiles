function wipp --wraps='wip \$argv && git push' --description 'wip \$argv && git push'
    wip $argv && git push
end
