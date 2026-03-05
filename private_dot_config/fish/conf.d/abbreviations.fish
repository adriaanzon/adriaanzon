status is-interactive || exit

abbr -g !! --position anywhere --function abbr_last_history_item
abbr -g - 'cd -'
abbr -g ap 'ansible-playbook'
abbr -g apl 'ansible-playbook -i local'
abbr -g app 'ansible-playbook -i production'
abbr -g aps 'ansible-playbook -i staging'
abbr -g art --function abbr_artisan
abbr -g av 'ansible-vault'
abbr -g cdd 'cd ~/.local/share/chezmoi'
abbr -g cg 'cargo'
abbr -g ch 'chezmoi'
abbr -g ci 'composer install'
abbr -g composer --function abbr_develop
abbr -g cr 'composer require'
abbr -g crn 'composer run'
abbr -g crun 'composer run'
abbr -g cu 'composer update'
abbr -g curn 'composer run'
abbr -g dc 'docker compose'
abbr -g dcb 'docker compose build'
abbr -g dcbu 'docker compose build && docker compose up -d'
abbr -g dcd 'docker compose down'
abbr -g dce 'docker compose exec'
abbr -g dcu 'docker compose up -d'
abbr -g ga 'git add'
abbr -g gaa 'git add --all'
abbr -g gb 'git browse'
abbr -g gc 'git commit'
abbr -g gc# 'gh pr checkout'
abbr -g gca 'git commit -a'
abbr -g gco 'git checkout'
abbr -g gd 'git diff'
abbr -g gdn 'git diff --name-only' # use it like this: vim (gdn)
abbr -g gds 'git diff --staged'
abbr -g gf 'git fetch'
abbr -g gl 'git pull'
abbr -g gm 'git merge'
abbr -g gmc 'git merge --continue'
abbr -g gp 'git push'
abbr -g gpF 'git push --force'
abbr -g gpf 'git push --force-with-lease'
abbr -g gr 'git rebase'
abbr -g grc 'git rebase --continue'
abbr -g grd 'git rebase develop'
abbr -g gri 'git rebase -i'
abbr -g grm 'git rebase master'
abbr -g grs 'git restore'
abbr -g gs 'git switch'
abbr -g gs- 'git switch -'
abbr -g gsc 'git switch -c'
abbr -g gsd --function abbr_git_switch_develop
abbr -g gsm --function abbr_git_switch_master
abbr -g gst 'git status'
abbr -g haiku 'claude --model=haiku'
abbr -g i --position anywhere --function abbr_install --regex '\b(i(n(s(t(al??)?)?)?)?)\b'
abbr -g multicd_as_argument --command cd --regex '^\.{3,}$' --function abbr_multicd
abbr -g multicd_as_command --regex '^\.{3,}$' --function abbr_multicd
abbr -g nah 'git reset --hard && trash -v (git ls-files --others --exclude-standard --directory --no-empty-directory)'
abbr -g npm --function abbr_develop
abbr -g npx --function abbr_develop
abbr -g opus 'claude --model=opus'
abbr -g opusplan 'claude --model=opusplan'
abbr -g php --function abbr_develop
abbr -g sl 'ls'
abbr -g sonnet 'claude --model=sonnet'
abbr -g tinker 'php artisan tinker'
abbr -g vi 'nvim'
abbr -g vim 'nvim'
abbr -g zap --position anywhere --function abbr_zap
