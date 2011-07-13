$(function() {
    var css = "#rdb-article-content pre { word-wrap: normal !important; white-space: pre !important; background-color: #F0F1EE !important; border: 1px solid #D4D4D2 !important; padding: 10px; margin: 20px; }";

    if (typeof GM_addStyle != "undefined") {
        GM_addStyle(css);
    } else if (typeof PRO_addStyle != "undefined") {
        PRO_addStyle(css);
    } else if (typeof addStyle != "undefined") {
        addStyle(css);
    } else {
        var heads = document.getElementsByTagName("head");
        if (heads.length > 0) {
            var node = document.createElement("style");
            node.type = "text/css";
            node.appendChild(document.createTextNode(css));
            heads[0].appendChild(node); 
        }
    }
}());
