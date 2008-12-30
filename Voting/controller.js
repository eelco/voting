var sort;

window.addEvent('domready', function() {
    sort = new Sortables($$('#list ol, #list ul'),
                    { clone:   true
                    , opacity: 0.8
                    , onComplete:  cleanUp
                    });
    // Override default behaviour
    sort.getDroppables = $lambda($$('li'));

    $$('form').addEvent('submit', function(e){
        e.preventDefault();
        var vote = [];

        $$('#list ol ul').each(function(ul) {
            vote.push(ul.getChildren().get('id').join('=').replace(/t/g, ''));
        });
        
        $('vote').set('value', vote.join());

        $$('form').set('send', 
            { onSuccess: function(msg){ alert(msg); window.location.href = "result"; }
            , onFailure: function(xhr){ alert(xhr.responseText); }
            });
        $$('form').send();

    });
    
});

function cleanUp() {
    $$("#list ol > li").each(function(oli) {
        // Make sure there is always a surrounding <ul>
        if (oli.get('id') != null) {
            ul = new Element('ul');
            li = new Element('li');
            li.wraps(ul.wraps(oli));
            // Add the new li
            sort.getDroppables = $lambda($$('li'));
        // <li>s with empty <ul>s are removed
        } else if (oli.getElement('li') == null) {
            oli.destroy();
        }
    });
}
