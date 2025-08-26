function wip --wraps='git add . && git commit -m "WIP"' --wraps='git add . && git commit -m "wip"' --description 'alias wip git add . && git commit -m "wip"'
  git add . && git commit -m "wip" $argv
        
end
