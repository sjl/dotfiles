alias v='vagrant'
alias vs='vagrant suspend'
alias vu='vagrant up'
alias vh='vagrant halt'
alias vss='vagrant ssh'

function turnoffthedamnboxvagrant () {
    VBoxManage list vms | grep "$1" | cut -d' ' -f1 | tr -d '"\n ' | xargs -0 -I BOX VBoxManage controlvm BOX poweroff
}

alias biv='bcvi --install vagrant'
