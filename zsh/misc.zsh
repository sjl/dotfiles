alias pbc='pbcopy'
alias pbp='pbpaste'

function mdown () {
    (echo '
        <head>
            <style>
                body {
                    font-family: Georgia;
                    font-size: 17px;
                    line-height: 1.4;
                    color: #222;
                    text-rendering: optimizeLegibility;
                    width: 700px;
                    margin: 20px auto;
                }
                h1, h2, h3, h4, h5, h6 {
                    font-family: Garamond;
                    font-weight: normal;
                }
                pre {
                    background-color: #f5f5f5;
                    font: normal 16px Menlo;
                    padding: 8px 10px;
                    overflow-x: scroll;
                }
            </style>
        </head>
    '; markdown $@) | bcat
}
