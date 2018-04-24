document.addEventListener('DOMContentLoaded', function() {
    document.getElementById("button").addEventListener('click', function() {
        chrome.tabs.executeScript( {
            file: "thirdParty/jquery-3.3.1.js"
        },  function() {
                $.post({
                    url: "http://dv-test.perplelab.com:9003/manage/get_dv_info",
                    type : "post",
                    data : {
                        did: document.getElementById("text").value
                    },
                    success : function(data) {
                        var str = JSON.stringify(data, null, 2);
                        str = str.replace("{", "");
                        str = str.replace("}", "");
                        str = str.replace(/,/g, "<br/ >");
                        document.getElementById("output").innerHTML = str;
                }
            });
        });
    });

    chrome.tabs.executeScript( {
        code: 'window.getSelection().toString();'
    }, function(selection) {
        if (selection != null)
        document.getElementById("text").value = selection[0];
    });
});
