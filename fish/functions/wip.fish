function wip --wraps='git add . && git commit -m "WIP"' --description 'alias wip git add . && git commit -m "WIP"'
  git add . && git commit -m "WIP" $argv
        
end
