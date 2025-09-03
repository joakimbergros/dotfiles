function wip --wraps='git add . && git commit -m \$argv' --description 'alias wip git add . && git commit -m \$argv'
    git add . && git commit -m $argv
end
