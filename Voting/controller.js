var ulOptions = { connectWith: [ "#list ul", "#list ol" ] 
                , stop: keepInUl
                , placeholder: "dropzone"
                , opacity: 0.8
                , tolerance: "pointer"
                };

var olOptions = { stop: keepInUl
                , placeholder: "dropzone"
                , opacity: 0.8
                , tolerance: "pointer"
                };

function keepInUl() {
    $("#list ol > li").each(function(i, oli){
        var oli   = $(oli);
        var subul = oli.find("ul");
        var subli = oli.find("li");
        // Test if the li is empty
        if (subul.length == 1 && subli.length == 0) {
            oli.remove();
            return;
        } // else

        // Create/merge an ul
        var ul = $("<ul></ul>");
        if (subli.length == 0) {
            ul.append(oli.clone());
        } else {
            ul.append(subli);
        }
        
        ul.sortable(ulOptions);
        oli.empty();
        oli.removeAttr("id");
        oli.append(ul);
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
