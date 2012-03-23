var profile_pictures = [];
var profile_picture_index_1 = 0;
var profile_picture_index_2 = 1;
 
$(document).live("facebook:ready", function() {
  FB.getLoginStatus(function(response) {
    console.log("a");
    console.log(response); 

    if (response.status == "connected") {
      FB.api('/me/albums', function(albums) {
        console.log("albums");
        console.log(albums);
        for (var i = 0; i < albums.data.length; i++) {
          if (albums.data[i].name == "Profile Pictures") {
            FB.api(albums.data[i].id + '/photos', function(pictures) {
              profile_pictures = pictures;
              console.log("profile_pictures");
              console.log(profile_pictures);
              /*
              var img = $("<img id='active_picture' />").attr('src', profile_pictures.data[profile_picture_index].source)
                                    .load(function() {
                                       if (!this.complete || typeof this.naturalWidth == "undefined" || this.naturalWidth == 0) {
                                         alert('broken image!');
                                       } 
                                       else {
                                         $("#photos").append(img);
                                       }
                                    });

              */
              $("#photo_1").attr('src', profile_pictures.data[profile_picture_index_1].source);
              $("#photo_2").attr('src', profile_pictures.data[profile_picture_index_2].source);
              $(".photo_nav").show(); 


            });
          }
        }
      });
    }
  });

  $("#fb_link").click( function(e) {
    e.preventDefault();
    FB.getLoginStatus(function(response) {
      if (response.session) {
        // logged in and connected user, someone you know
        console.log("b");
        console.log(response);
      } 
      else {
        // no user session available, someone you dont know
        FB.login(function(response) {
          if (response.session) {
              // user successfully logged in
              console.log("c");
              console.log(response);
              FB.api('/me', function(response) {
                console.log('Good to see you, ' + response.name + '.');
              });
            } 
          else {
            // user cancelled login, do nothing
            console.log('login cancelled');
            console.log(response);
          }
        }, {scope:'user_photos'});
      }
    });
  });

  $(".photo_nav").click( function(e) {
    e.preventDefault();

    console.log($(this).parent());
    console.log($(this).parent().height());
    console.log($(this).siblings(".photo"));
    console.log($(this).siblings(".photo").height());

    //var top_placement = ($(this).parent().height() - $(this).siblings(".photo").height()) / 2;

    var top_placement = $(this).siblings(".photo").height() / 2;
    console.log(top_placement)
    $(this).siblings(".photo").css('margin-top', top_placement * -1);
  });

  $("#next_photo_1").click( function(e) {
    e.preventDefault();
    profile_picture_index_1 += 1;
    if (profile_picture_index_1 == profile_picture_index_2) {
      profile_picture_index_1 += 1;
    }
    $("#photo_1").attr('src', profile_pictures.data[profile_picture_index_1].source);
  });

  $("#prev_photo_1").click( function(e) {
    e.preventDefault();
    profile_picture_index_1 -= 1;
    if (profile_picture_index_1 == profile_picture_index_2) {
      profile_picture_index_1 -= 1;
    }
    $("#photo_1").attr('src', profile_pictures.data[profile_picture_index_1].source);
  });

  $("#next_photo_2").click( function(e) {
    e.preventDefault();
    profile_picture_index_2 += 1;
    if (profile_picture_index_1 == profile_picture_index_2) {
      profile_picture_index_2 += 1;
    }
    $("#photo_2").attr('src', profile_pictures.data[profile_picture_index_2].source);
  });

  $("#prev_photo_2").click( function(e) {
    e.preventDefault();
    profile_picture_index_2 -= 1;
    if (profile_picture_index_1 == profile_picture_index_2) {
      profile_picture_index_2 -= 1;
    }
    $("#photo_2").attr('src', profile_pictures.data[profile_picture_index_2].source);
  });

});


