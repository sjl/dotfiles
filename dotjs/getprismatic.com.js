var banned_sites = ['Bits', 'Forbes.com'];
var banned_tags = ['Venture Capital', 'Social', 'Startups'];
var banned_words = ['Node'];

var scrubber = function(){
  $('.article').each(function(index, object){
    var hideit = false;

    var publisher = $(object).find('.publisher').find('.interest').text();

    var title = $(object).find('.title').find('.external').text();

    //loop through interests against our banned tags
    $(object).find('.meta').find('.interest').each(function(i, rawinterest){

      var interest = $(rawinterest).text();

      $(banned_tags).each(function(index, object){
        if(object.toLowerCase() == interest.toLowerCase()){
          hideit = true;
        }
      });

    });

    //loop through our sites checking if it matches the publisher
    $(banned_sites).each(function(index, object){
      if(object.toLowerCase() == publisher.toLowerCase()){
        hideit = true;
      }
    });

    //check title against banned_words
    $(banned_words).each(function(index, object){
      if(title.toLowerCase().indexOf(object.toLowerCase()) != -1){
        hideit = true;
      }
    });

    //hide the article if deemed garbage
    if(hideit == true){
      $(object).hide();
    }

  });
}

setInterval(scrubber, 2000);
