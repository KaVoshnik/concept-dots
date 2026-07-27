function lazygit_commit --description "git add . && commit && push in one go"
    if test (count $argv) -eq 0
        echo "Usage: lazygit_commit <commit message>"
        return 1
    end

    git add .
    git commit -m "$argv"
    git push
end
