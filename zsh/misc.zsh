alias pbc='pbcopy'
alias pbp='pbpaste'

alias m='mvim .'

alias f='fab'
alias fd='fab dev'

alias spotlight-off='sudo mdutil -a -i off && sudo mv /System/Library/CoreServices/Search.bundle/ /System/Library/CoreServices/SearchOff.bundle/ && killall SystemUIServer'
alias spotlight-on='sudo mdutil -a -i on && sudo mv /System/Library/CoreServices/SearchOff.bundle/ /System/Library/CoreServices/Search.bundle/ && killall SystemUIServer'

alias mutt='cd ~/Desktop; mutt'

function mdown () {
    (echo '
        <head>
            <style>
                body {
                    font-family: Georgia;
                    font-size: 17px;
                    line-height: 24px;
                    color: #222;
                    text-rendering: optimizeLegibility;
                    width: 670px;
                    margin: 20px auto;
                    padding-bottom: 80px;
                }
                h1, h2, h3, h4, h5, h6 {
                    font-weight: normal;
                    margin-top: 48px;
                }
                h1 { font-size: 48px; }
                h2 {
                    font-size: 36px;
                    border-bottom: 6px solid #ddd;
                    padding: 0 0 6px 0;
                }
                h3 {
                    font-size: 24px;
                    border-bottom: 6px solid #eee;
                    padding: 0 0 2px 0;
                }
                h4 { font-size: 20px; }
                pre {
                    background-color: #f5f5f5;
                    font: normal 15px Menlo;
                    line-height: 24px;
                    padding: 8px 10px;
                    overflow-x: scroll;
                }
            </style>
        </head>
    '; markdown $@) | bcat
}

function pull_everything() {
    for repo in $( ls -1 ); do
        if [[ -d $repo && -d $repo/.hg ]]; then
            echo "Pulling" $repo
            hg -R $repo pull -u
            echo
        fi
    done
}

# Updated verison of SVN.
export DYLD_LIBRARY_PATH="/opt/subversion/lib:$DYLD_LIBRARY_PATH"
export PYTHONPATH="/opt/subversion/lib/svn-python:$PYTHONPATH"
export PATH="/opt/subversion/bin:$PATH"

# hgd
test -f "$HOME/src/hgd/hd" && alias h='~/src/hgd/hd' || alias h=hg

# What the hell did I do the other day?
function whatthehelldididoon() {
    for repo in `find . -name '.hg'`
    do
        echo $repo
        h .. -R $repo/.. -d "$1" -u 'Steve Losh'
    done
}

alias dv='dvtm -m "^f"'
alias dvt='dtach -A /tmp/dvtm-session.sock -r winch dvtm -m "^f"'

alias goawayswapfilesyouareswapfilesidontevenneedyou='rm ~/.vim/tmp/swap/*'
