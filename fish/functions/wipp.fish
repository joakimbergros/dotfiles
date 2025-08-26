function wipp --wraps='git add . && git commit -m "wip" && git push' --description 'alias wipp git add . && git commit -m "wip" && git push'
  git add . && git commit -m "wip" && git push $argv
        
end
