var ulOptions = { connectWith: [ "#list ul", "#list ol" ] 
                , stop: cleanUp
                , placeholder: "dropzone"
                , opacity: 0.8
                };

var olOptions = { stop: cleanUp
                , placeholder: "dropzone"
                , opacity: 0.8
                };

function cleanUp() {
    $("#list ol > li").each(function(i, oli){
        var oli   = $(oli);
        // Test if the li is empty
        if (oli.attr('id') != "") {
            oli.wrap("<li><ul></ul></li>");
            oli.parent().sortable(ulOptions);
        } else if (oli.find("li").length == 0) {
            oli.remove();
        }
    });
}

$(document).ready(function() {
    $("#list ol").sortable(olOptions);
    $("#list ul").sortable(ulOptions);

    $("form").bind("submit", function() {
        var vote = [];

        $("#list ol ul").each(function(i, ul){
            vote.push($(ul).sortable("toArray").join('=').replace(/t/g, ''))
        });

        $("#vote").val(vote.join());

        $.ajax({
            type: "POST",
            data: $("form").serialize(),
            success: function(msg) { alert(msg); window.location.href = "result" },
            error:   function(xhr) { alert(xhr.responseText); } 
        });

        return false;
    })
});
