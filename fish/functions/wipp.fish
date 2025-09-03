function wipp --wraps='git add . && git commit -m "wip" && git push' --description 'alias wipp git add . && git commit -m "wip" && git push'
    wip $argv && git push
end
