/* ishlist 1.0 jsilver */

// TODO: stop using stop_all_audio and destroy_players to change song.
// continued: destroying a player html element is enough to kill it.

// special
$(document).ready(function() {
    //alert(rails_env);
    if (rails_env == "development") {
      browser_base_url = "localhost:3000/radio/";
      facebook_path = "http://localhost:3000/admin/auth/facebook?display=popup";
      facebook_app_id = '339163289483791';
    }
    else if (rails_env == "staging") {
      browser_base_url = "staging.ishlist.com/radio/";
      facebook_path = "http://staging.ishlist.com/admin/auth/facebook?display=popup";
      facebook_app_id = "461416740553715";
    }
    else {
      browser_base_url = "www.ishlist.com/radio/";
      facebook_path = "http://www.ishlist.com/admin/auth/facebook?display=popup";
      facebook_app_id = "230386677076159";
    }
});

login_fb = function() {
  // $('#loginframe').css('visibility', 'visible');
  // $('#loginframe').attr('src', '/admin/auth/facebook');
  w = window.open(facebook_path);
  setTimeout(facebook_frame_changed, 1000);
};

facebook_track = function() {
  if (check_logged_in('share')) {
    FB.init({appId: facebook_app_id, status: true, cookie: true});
    postToFeed();
  }
};

$(document).ajaxError(function(e, XHR, options) {
  if (XHR.status == 401) {
    show_a_dialog_message("Access Denied", "Couldn't log U Bboo ... Check that Yr Info Are Correct");
  }
});

// used to establish secure communications channel
readCookie = function(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ') c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
  }
  return null;
};


post_comment = function() {

  if (check_logged_in('comment')) {

    //data = new FormData(document.getElementById('comment-form'));
    comment = $('#comment-text').val();
    $.ajax(
      {
      dataType: "json",
      cache: false,
      url: '/main/post_comment?song_id='+ current_song_id +'&comment[comment]='+comment,
      success: function(data)
      {
        show_a_message(data['message']);
      }
    });

    return false;
  }

};

post_comment_from_activity_page = function() {

  if (check_logged_in('comment')) {

    //data = new FormData(document.getElementById('comment-form'));
    comment = $('#comment_text_on_activity_page').val();
    activity_song_id = $('#song_id').val();
    $.ajax(
      {
      dataType: "json",
      cache: false,
      url: '/main/post_comment?song_id='+ activity_song_id +'&comment[comment]='+comment,
      success: function(data)
      {
        $.get('/recent_activities', 'song_id=' + current_song_id, function(data, code, xhr) {
          pop_under(data);
          rebind_controls();
        });
        //show_a_message(data['message']);
      }
    });

    return false;
  }
  else {
     $('#registration_required_box').css("margin-top",'1000px');
  }

};


post_new_comment = function() {
    if(event.keyCode==13){

      if (check_logged_in('comment')) {

    //data = new FormData(document.getElementById('comment-form'));
    comment = $('#comment-text').val();
    $.ajax(
      {
      dataType: "json",
      cache: false,
      url: '/main/post_comment?song_id='+ current_song_id +'&comment[comment]='+comment,
      success: function(data)
      {
        show_a_message(data['message']);
      }
    });

    return false;
  }
    }

};

login = function() {

  data = new FormData(document.getElementById('login-form'));

  $.ajax({
    url: '/users/sign_in.json',
    data: data,
    cache: false,
    contentType: false,
    processData: false,
    type: 'POST',
    success: function(data) {
      chat_token = data['chat_token'];
      show_a_message(data['message']);
    }
  });

  return false;

};

upload_art = function() {

  data = new FormData(document.getElementById('tag_form'));

  $.ajax({
    url: '/upload_art/' + uploaded_song_id,
    data: data,
    cache: false,
    contentType: false,
    processData: false,
    type: 'POST',
    success: function(data) {
      show_a_message(data['message']);
      window.location = browser_base_url + 'Latest-Shares/' + data.latest_song
    }
  });

  return false;

};

logout = function() {
  $.get('/logout', function() {
    show_a_message("logged out!");
    logged_in = false;
  });
};

register = function() {

  data = new FormData(document.getElementById('register-form'));

  $.ajax({
    url: '/users/register.json',
    data: data,
    cache: false,
    contentType: false,
    processData: false,
    type: 'POST',
    success: function(data) {
      $('#registration_required_box').hide();
      //alert(data['message'].match("logged_in"));
      show_a_message(data['message'],data['errors']);
      $('.ui-dialog').css("z-index",'100000');
    }
  });


  return false;
};


// gui
show_a_message = function(message,errors) {
  console.log(message);
  if (message.match("login")) {
    if(message == "login_share") {
      image_str = "<img src='/assets/" + message + ".png' style='padding-left: 40px;'/>";
    }
    else {
      image_str = "<img src='/assets/" + message + ".png' />";
    }
    $('#login_message').html(image_str);
    $('#registration_required_box').show();
    $('#registration_required_box').draggable();
    $('#yes_no_box_copy_1').bind('click', function(e, i) {
      $('#registration_required_box').hide();
    });
    $('#login_1').bind("click", function() {
      $('#registration_required_box').hide();
      $('#login_box').show();
      $('#login_box').draggable();
      $('#login_close_button').bind('click', function(e, i) {
        $('#login_box').hide();
      });
    });
    $('#new_user_1').bind("click", function() {
      $('#registration_required_box').hide();

      // take off dialog next
      $('#registration_box').show();
      $('#registration_box').draggable();

      $('#registration_close_button').bind('click', function(e, i) {
        $('#registration_box').hide();
      });

      $('#user_password_registrations').change(function() {
        $('#user_password_confirmation').val($(this).val());
      });

      $('#profile_pic_button_upload_songs').click(function() {
        $('#user_photo').click();
        old_val = $('#user_photo').val().replace(/^.*[\\\/]/, '')
        check_user_pic_file_name(old_val);
      });

      $('#submit_registration_button').click(function() {
        $('#sign_up').click();
      });

    });
    return;
  } else if (message.match("logged_in")) {
    logged_in = true;
    //create_juggernaut();
    $('#login_box').hide();
    $('#register-form').hide();
    if (message.match("admin")) {
      show_a_dialog_message("Alert", "Welcome Admin!");
      $('#logged_in').html("true");
      window.open("/admin", "", {});
    } else {
      show_a_dialog_message("Alert", "Welcome!");
       $('#logged_in').html("true");
    }
    return;
  } else if (message == "register_fail") {
    message = errors;
    show_a_dialog_message("Error",message);
    return;
  } else if (message == "song_success") {
    tag_songs();
    $('#wait_for_mp3').hide();
    $('#wait_for_youtube').hide();
    $('#processing_dots').hide();
    return;
  } else if (message == "tag_success") {
    show_a_dialog_message("Big Up", "You just posted a track up to the best music database online homie. Thanks for contributing!!");
    hide_bottom_pages();
    return;
  } else if (message == "facebook_success") {
    show_a_dialog_message("Nice one", "Posted song to your Facebook wall. Thanks!");
    return;
  } else if (message == "song_fail") {
    $('#next_thingy_upload_songs').show();
    $('#wait_for_mp3').hide();
    $('#wait_for_youtube').hide();
    $('#processing_dots').hide();
    show_a_dialog_message("Song Failed to Upload", "Song failed. We cannot play this song because it is blocked from embedding or already exists in database. Please try another.");
    return;
  } else if (message == "art_success") {
    hide_bottom_pages();
    scroll_home();
    show_a_dialog_message("Alert", "Woooooord.  Here is your track in all it's Glory.  Share with your peoples!!");
    return;
  } else if (message == "comment_success") {
    get_comments();
    show_a_dialog_message("Alert", "Your comment was added to the song!");
    $('#comment-text').val('');
    return;
  } else if (message == "rate_success") {
    fade_stars();
    return;
  } else if (message == "rate_success_with_congrats") {
    fade_stars();
    show_a_dialog_message("Alert", "Congrats! You have earned an entry for today's Hookup.");
    return;
  }else if (message == "heard_success") {
    fade_heard();
    return;
  }

  show_a_dialog_message("Alert", message);
};

hide_bottom_pages = function() {
  scroll_to(0, 0);
  $('#page-holder').html('');
  $('#page-holder-2').html('');
};


check_logged_in = function(key) {
  if (logged_in === false) {
    show_a_message('login_' + key);
    $('#registration_required_box').css("margin-top",'0px');
  }
  return logged_in;
};

show_a_dialog_message = function(title, message) {
  $('#dialog_message').html("<p>" + message + "</p>");
  $("#dialog_message").dialog({
    title: title,
    modal: true,
    draggable: true,
    resizable: false,
    buttons: {
      Ok: function() {
        $(this).dialog("close");
      }
    }
  });
};


playlist = ''; //default station == top25
player_state = '';
player_type = '';
download_permission = "no";

// ids
last_song_id = ''; // used in paneling
current_song_id = ''; // used to seek in playlist, downloads, etc
previous_song_id = ''; // used on playbtns... next/prev
next_song_id = '';



volume = 70;
download_link = '';
mute_status = 'unmuted';
stations = []; /* station list */
fx_time = 1000;
current_art_url = '';
future_art_url = '';
previous_art_url = '';
next_art_url = '';
past_art_url = '';

over_player = false;

player_loaded = false;

chat_token = readCookie('chat_token');

time_in_seconds = 0;
start_time = 0;

uploaded_song_id = 0;

textbox_focused = false;

scroller_paused = false;

keyheld = false;


//
// FX
scale_effect = function(time) {
  $('*').each(function(i, e) {
    $(e).attr('w', $(e).css('width'));
    $(e).attr('h', $(e).css('height'));
  });
  $('*').css({
    "width": 0,
    "height": 0
  });
  $('*').each(function(i, e) {
    $(e).animate({
      "height": $(e).attr("h"),
      "width": $(e).attr("w")
    }, time);
  });
  $('*').removeAttr("w");
  $('*').removeAttr("h");
};

blinds_effect = function(time) {
  $('*').each(function(i, e) {
    $(e).attr('h', $(e).css('height'));
  });
  $('*').css({
    "height": 0
  });
  $('*').each(function(i, e) {
    $(e).animate({
      "height": $(e).attr("h")
    }, time);
  });
  $('*').removeAttr("h");
};

fade_in_effect = function(time) {
  $('*').hide();
  $('*').fadeIn(time);
};

fade_out_effect = function(time) {
  $('*').fadeOut(time);
};

intro_effect = function() {
  time = 7000;
  $('body > *').each(function(i, e) {
    $(e).attr('w', $(e).css('width'));
    $(e).attr('h', $(e).css('height'));
  });
  $('body > *').css({
    "width": 0,
    "height": 0
  });
  $('body > *').each(function(i, e) {
    $(e).animate({
      "height": $(e).attr("h"),
      "width": $(e).attr("w")
    }, time);
  });
  $('body > *').removeAttr("w");
  $('body > *').removeAttr("h");
  // style nuke disable the below for Firebug Move Element(tm)
  setTimeout(function() {
    $('body > *').removeAttr("style");
  }, time);

  // eventually load player after above insanity
  setTimeout(get_ready, time);
};







fade_heard = function() {
  $('#heard_before').fadeOut(3000);
  $('#no').fadeOut(3000);
  $('#yes').fadeOut(3000);
  $('#heard').fadeIn(3000);
  $('#heard_text').fadeIn(3000);

};

reset_heard = function() {
  $('#heard_before').fadeIn(3000);
  $('#heard').fadeOut(3000);
  $('#heard_text').fadeOut(3000);
  $('#no').fadeIn(3000);
  $('#yes').fadeIn(3000);
};


fade_stars = function() {
  $('#rate_it').fadeOut(3000);
  $('#ave_rating').fadeIn(3000);
  $('#avg_rating_text').fadeIn(3000);
  $('.star').fadeOut(3000);
};

reset_rating_stars = function() {
  $('#rate_it').fadeIn(3000);
  $('#ave_rating').fadeOut(3000);
  $('#avg_rating_text').fadeOut(3000);
  $('.star').fadeIn(3000);
};


next_song_animation = function(time) {

  var future_art = $('#album_art_future');
  var next_art = $('#album_art_next');
  var current_art = $('#album_art_current');
  var previous_art = $('#album_art_previous');
  var past_art = $('#album_art_past');

  var future_img = $('#album_img_future');
  var next_img = $('#album_img_next');
  var current_img = $('#album_img_current');
  var previous_img = $('#album_img_previous');
  var past_img = $('#album_img_past');

  // future -> next
  future_art.animate({
    'left': next_left,
    'width': small_width,
    'height': small_height
  }, time, null, function() {
    future_art.attr('id', 'album_art_next');
    future_img.attr('id', 'album_img_next');
  });

  // next -> current
  next_art.animate({
    'left': current_left,
    'top': current_top
  }, time, null, function() {
    next_art.attr('id', 'album_art_current');
    next_img.attr('id', 'album_img_current');
  });
  next_img.animate({
    'width': big_width,
    'height': big_height
  }, time);

  // current -> previous
  current_art.animate({
    'left': previous_left,
    'top': previous_top
  }, time, null, function() {
    current_art.attr('id', 'album_art_previous');
    current_img.attr('id', 'album_img_previous');
  });
  current_img.animate({
    'width': small_width,
    'height': small_height
  }, time);

  // previous -> past
  previous_art.animate({
    'left': past_left
  }, time, null, function() {
    // id
    previous_art.attr('id', 'album_art_past');
    previous_img.attr('id', 'album_img_past');
    
    
    change_arts();
    load_player();
    get_comments();
  });

};

previous_song_animation = function(time) {

  var future_art = $('#album_art_future');
  var next_art = $('#album_art_next');
  var current_art = $('#album_art_current');
  var previous_art = $('#album_art_previous');
  var past_art = $('#album_art_past');

  var future_img = $('#album_img_future');
  var next_img = $('#album_img_next');
  var current_img = $('#album_img_current');
  var previous_img = $('#album_img_previous');
  var past_img = $('#album_img_past');

  // past -> previous
  past_art.animate({
    'left': previous_left
  }, time, null, function() {
    past_art.attr('id', 'album_art_previous');
    past_img.attr('id', 'album_img_previous');
  });

  // previous -> current
  previous_art.animate({
    'left': current_left,
    'top': current_top
  }, time, null, function() {
    // id
    previous_art.attr('id', 'album_art_current');
    previous_img.attr('id', 'album_img_current');
  });
  previous_img.animate({
    'width': big_width,
    'height': big_height
  }, time);

  // current -> next
  current_art.animate({
    'left': next_left,
    'top': next_top
  }, time, null, function() {
    current_art.attr('id', 'album_art_next');
    current_img.attr('id', 'album_img_next');
  });
  current_img.animate({
    'width': small_width,
    'height': small_height
  }, time);

  // next -> future
  next_art.animate({
    'left': future_left
  }, time, null, function() {
    next_art.attr('id', 'album_art_future');
    next_img.attr('id', 'album_img_future');
    change_arts();
    load_player();
  });

};

change_arts = function() {

  var future_art = $('#album_art_future');
  var next_art = $('#album_art_next');
  var current_art = $('#album_art_current');
  var previous_art = $('#album_art_previous');
  var past_art = $('#album_art_past');

  var future_img = $('#album_img_future');
  var next_img = $('#album_img_next');
  var current_img = $('#album_img_current');
  var previous_img = $('#album_img_previous');
  var past_img = $('#album_img_past');

  future_img.show();
  past_img.show();
  next_img.show();
  previous_img.show();
  current_img.show();

  // past -> future
  past_art.css('left', future_left);
  // id
  past_art.attr('id', 'album_art_future');
  past_img.attr('id', 'album_img_future');

  // future -> past
  future_art.css('left', past_left);
  // id
  future_art.attr('id', 'album_art_past');
  future_img.attr('id', 'album_img_past');

  // change arts
  $('#album_img_future').attr('src', future_art_url);
  $('#album_img_past').attr('src', past_art_url);

};


show_controls = function() {

  $('#ish_rating').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#ish_circle').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#fan').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#by_1').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#artist_name').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#title').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#lil_heart').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#play_button').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#previous_song_button').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#next_song_button').css({
    'opacity': 1,
    'display': 'block'
  });

  $('#artist_title_box').css({
    'opacity': 0.7,
    'display': 'block'
  });
  show_hide_download_link();
  hide_show_record_hole();
  $('#fbook_icon').css({
    'opacity': 1,
    'display': 'block'
  });
  $('#twitter_icon').css({
    'opacity': 1,
    'display': 'block'
  });

  if (typeof(stop_scroller) !== "undefined") stop_scroller();

};

hide_controls_fast = function() {
  hide_controls(500);
};

hide_controls_slow = function() {
  hide_controls(3000);
};

hide_controls = function(time) {
  $('#ish_rating').fadeOut(time);
  $('#ish_circle').fadeOut(time);
  $('#fan').fadeOut(time);
  $('#by_1').fadeOut(time);
  $('#artist_name').fadeOut(time);
  $('#title').fadeOut(time);
  $('#lil_heart').fadeOut(time);
  $('#play_button').fadeOut(time);
  $('#artist_title_box').fadeOut(time);
  $('#download_link').fadeOut(time);
  $('#fbook_icon').fadeOut(time);
  $('#twitter_icon').fadeOut(time);
  $("#station_play_button_img").hide();
  $("#previous_song_button").fadeOut(time);
  $('#next_song_button').fadeOut(time);
  if (player_type === 'youtube') {
    $("#mid_of_record_hole").fadeOut(3000);
  } else {
    $("#mid_of_record_hole").fadeIn(3000);
  }
  hide_controls_next();
  hide_controls_previous();

  if (typeof(stop_scroller) !== "undefined") start_scroller();


};

favorite_track = function() {
  $.get('/favorite_track', 'song_id=' + current_song_id, function(data, code, xhr) {
    show_a_message(data['message']);
    if(data['is_fav'])
  {
    $('#lil_heart').css("background-image", "url(/assets/cross_lil_heart.png)")
  }
  else
  {
    $('#lil_heart').css("background-image", "url(/assets/lil_heart.png)")
  }
  });
};

fan_track = function() {
  $.get('/fan_track', 'song_id=' + current_song_id, function(data, code, xhr) {
    show_a_message(data['message']);
  });
};

change_volumes = function() {
  console.log("vol: " + volume);
  if (player_type == "mp3") {
    $("#jquery_jplayer_1").jPlayer("volume", volume / 100);
  } else if (player_type == "youtube") {
    $('#tube_player').tubeplayer('unmute');
    $('#tube_player').tubeplayer('volume', volume);
  } else if (player_type == "soundcloud") {
    if (soundcloud_player.tagName == "AUDIO") {
      soundcloud_player.volume = volume / 100;
    } else {
      soundcloud_player.api_setVolume(volume);
    }
  }
  mute_unmute();
};

seek = function() {
  if (start_time > 0) {
    console.log("seeking to: " + start_time);
    if (player_type == "mp3") {
      $("#jquery_jplayer_1").jPlayer("play", start_time);
    } else if (player_type == "youtube") {
      $('#tube_player').tubeplayer('seek', start_time);
    } else if (player_type == "soundcloud") {
      if (soundcloud_player.tagName == "AUDIO") {
        soundcloud_player.seek(start_time);
      } else {
        soundcloud_player.api_seek(start_time);
      }
    }
  }
  start_time = 0;
};

auto_play = function() {
  // a hack
  //dont_auto_play_on_local();

  // init and dont show
  change_volumes();
  show_controls();
  if (player_type == "youtube") {
    $("#album_img_current").fadeOut(3000);
    $('#yt_ad_killer').show();
  } else {
    $("#album_img_current").fadeIn(3000);
    $('#yt_ad_killer').hide();
  }
  player_state = 'playing';
  $('#play_button').css({
    'background-image': "url('/assets/pause_copy.png')"
  });
  player_loaded = true;
  if(over_player === false){
    get_comments();
    setTimeout(function() {
      hide_controls_fast();
    }, 3000);
  }
};

scroll_home = function() {
  scroll_to(0, 0);
};

on_load = function() {
  ShowPicture('Style',0);
  Picture('pop',4);
};

volume_up = function() {
  if (volume <= 90) {
    volume = volume + 10;
    change_volumes();
  }
};

volume_down = function() {
  if (volume > 0) {
    volume = volume - 10;
    change_volumes();
  }
};

mute_unmute = function() {
  if (volume === 0) {
    if (player_type == "mp3") {
      $("#jquery_jplayer_1").jPlayer("mute");
    } else if (player_type == "youtube") {
      $('#tube_player').tubeplayer('mute');
    } else if (player_type == "soundcloud") {
      if (soundcloud_player.tagName == "AUDIO") {
        soundcloud_player.volume = 0;
      } else {
        soundcloud_player.api_setVolume(0);
      }
    }
    mute_status = 'muted';
  } else {
    if (mute_status == "muted") {
      if (player_type == "mp3") {
        $("#jquery_jplayer_1").jPlayer("unmute");
      } else if (player_type == "youtube") {
        $('#tube_player').tubeplayer('unmute');
      } else if (player_type == "soundcloud") {
        if (soundcloud_player.tagName == "AUDIO") {
          soundcloud_player.volume = 10;
        } else {
          soundcloud_player.api_setVolume(0);
        }
      }
      mute_status = "unmuted";
    }
  }
};

stop_all_audio = function() {
  if (player_type == "mp3") {
    $("#jquery_jplayer_1").jPlayer("pause");
  } else if (player_type == "youtube") {
    $('#album_img_current').show();
    $('#tube_player').tubeplayer('pause');
  } else if (player_type == "soundcloud") {
    try {
      if (soundcloud_player.tagName == "AUDIO") {
        soundcloud_player.pause();
      } else {
        soundcloud_player.api_pause();
      }
    } catch (e) {
      console.log("Failed to pause soundcloud.");
    }
  }
  player_state = "stopped";
  $('#play_button').css({
    'background-image': "url('/assets/play_copy_2.png')"
  });
};

start_all_audio = function() {
  change_volumes();
  if (player_type == "mp3") {
    $("#jquery_jplayer_1").jPlayer("play");
  } else if (player_type == "youtube") {
    $('#album_img_current').hide();
    $('#tube_player').tubeplayer('play');
  } else if (player_type == "soundcloud") {
    if (soundcloud_player.tagName == "AUDIO") {
      soundcloud_player.play();
    } else {
      soundcloud_player.api_play();
    }
  }
  player_state = "playing";
  $('#play_button').css({
    'background-image': "url('/assets/pause_copy.png')"
  });
};

lr_accepted = function() {

  stop_all_audio();
  destroy_players();

  $.get('/next_song', 'playlist=' + playlist + "&current_song_id=" + current_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    update_html_station_changed(data);
  }, 'text');


  $('#play_button').css({
    'background-image': "url('/assets/pause_copy.png')"
  });
  player_state = 'playing';
};


change_station = function() {
  stop_all_audio();
  destroy_players();
  show_controls();

  $.get('/next_song', 'playlist=' + playlist + '&current_song_id=' + next_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    update_html_next(data);
    if (logged_in === true) {
      $.get('/fetch_rating', 'song_id=' + current_song_id , function(data, code, xhr) {
      console.log(data);
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#avg_rating_text').html(data['avg_rating']);
        fade_stars();
      }
      });
      $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#heard_text').html(data['avg_listens']);
        show_a_message(data['message']);
      }
      });
    }
  }, 'text');

  $('#play_button').css({
    'background-image': "url('/assets/pause_copy.png')"
  });
  player_state = 'playing';
  var stateObj = { foo: "bar" };
  history.pushState(stateObj, "The Ishlist","http://"+browser_base_url+playlist.replace(/\s+/g,"-")+'/'+document.getElementById('album_title_next').innerHTML.replace(/\s+/g, '_').replace(/\./g,'~'));
  return false;
};

next_song = function() {
  if (player_loaded === true) {
    stop_all_audio();
    destroy_players();
    show_controls();
    force_next_song();
    //url = "http://localhost:3000/radio/"+playlist+'/track/'+next_song_id;
    //window.location.replace(url);
    var stateObj = { foo: "bar" };
    history.pushState(stateObj, "The Ishlist","http://"+browser_base_url+playlist.replace(/\s+/g,"-")+'/'+document.getElementById('album_title_next').innerHTML.replace(/\s+/g, '_').replace(/\./g,'~'));
    return false;
  }
};

play_media_source = function(type, url) {
  if (url == media_source_url) {
    // Playing the same source twice in a row breaks sc-player,
    // So check the player state and behave appropriately...
    if (player_state == "playing") stop_all_audio();
    else start_all_audio();
    return;
  }
  player_type = type;
  media_source_url = url;
  console.log("playing a " + type + " media source: " + url);
  console.log('stopping audio');
  stop_all_audio();
  destroy_players();
  $('#tube_player').remove();
  $('#jplayer_container').append($('<div id="tube_player"></div>'));
  load_player();
  start_all_audio();
};

force_next_song = function() {

  $.get('/next_song', 'playlist=' + playlist + '&current_song_id=' + next_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    update_html_next(data);
    if (logged_in === true) {
      $.get('/fetch_rating', 'song_id=' + current_song_id , function(data, code, xhr) {
      console.log(data);
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#avg_rating_text').html(data['avg_rating']);
        fade_stars();
      }
      });
      $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#heard_text').html(data['avg_listens']);
        show_a_message(data['message']);
      }
      });
    }
  }, 'text');


  $('#play_button').css({
    'background-image': "url('/assets/pause_copy.png')"
  });
  player_state = 'playing';

};

previous_song = function() {
  if (player_loaded === true) {
    stop_all_audio();
    destroy_players();
    show_controls();
    force_previous_song();
    var stateObj = { foo: "bar" };
    history.pushState(stateObj, "The Ishlist","http://"+browser_base_url+playlist.replace(/\s+/g,"-")+'/'+document.getElementById('album_title_previous').innerHTML.replace(/\s+/g, '_').replace(/\./g,'~'));
    return false;
  }
};

force_previous_song = function() {

  $.get('/previous_song', '&playlist=' + playlist + '&current_song_id=' + previous_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    update_html_previous(data);
    if (logged_in === true) {
      $.get('/fetch_rating', 'song_id=' + current_song_id , function(data, code, xhr) {
      console.log(data);
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#avg_rating_text').html(data['avg_rating']);
        fade_stars();
      }
      });
      $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#heard_text').html(data['avg_listens']);
        show_a_message(data['message']);
      }
      });
    }
  }, 'text');

  $('#play_button').css({
    'background-image': "url('/assets/pause_copy.png')"
  });
  player_state = 'playing';
};


play_pause = function() {
  if (player_state != "playing") {
    start_all_audio();
  } else {
    stop_all_audio();
  }
  player.stopVideo();
  $('#dilly_play_button').show();
};


onkeydown = function(e) {

  if (player_loaded === true && !textbox_focused && !player_locked && !keyheld) {

    if (e.keyCode == 32) {
      play_pause();
    }
    if (e.keyCode == 37) {
      previous_song();
    }
    if (e.keyCode == 39) {
      next_song();
    }

    if (e.keyCode == 65) {
      panel_previous();
    }

    if (e.keyCode == 83) {
      panel_next();
    }

    if (e.keyCode == 88) {
      panel_play_previous();
    }

    if (e.keyCode == 90) {
      panel_play_next();
    }

    if (e.keyCode == 68) {
      playlist_up();
    }

    if (e.keyCode == 67) {
      playlist_down();
    }


    if (e.keyCode == 70) {
      change_station();
    }

    if (e.keyCode == 38) {
      volume_up();
    }
    if (e.keyCode == 40) {
      volume_down();
    }

    keyheld = true;

    return false;

  }



};

onkeyup = function(e) {
  keyheld = false;
};


heard_it = function() {
  if (check_logged_in('ratings')) {
  $.get('/heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
    $('.ish_rating').html(data['rating']);
    $('#heard_text').html(data['avg_listens']);
    show_a_message(data['message']);
  });
  }
  else {
    $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
    $('.ish_rating').html(data['rating']);
    $('#heard_text').html(data['avg_listens']);
    show_a_message(data['message']);
    setTimeout(reset_heard,2000);
  });
  }
};

havent_heard = function() {
  if (check_logged_in('ratings')) {
  $.get('/havent_heard', 'song_id=' + current_song_id, function(data, code, xhr) {
    $('.ish_rating').html(data['rating']);
    $('#heard_text').html(data['avg_listens']);
    show_a_message(data['message']);
  });
  }
  else {
    $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
    $('.ish_rating').html(data['rating']);
    $('#heard_text').html(data['avg_listens']);
    show_a_message(data['message']);
    setTimeout(reset_heard,2000);
  });
  }
};

change_stars = function() {
  star_number = $(this).attr('id').split('_')[1];
  for (i = 1; i <= 10; i++) {
    if (i <= star_number) {
      $('#star_' + i).addClass('star_' + i + '_active');
    } else {
      $('#star_' + i).removeClass('star_' + i + '_active');
    }
  }
};

blank_stars = function() {
  for (i = 1; i <= 10; i++) {
    $('#star_' + i).removeClass('star_' + i + '_active');
  }
};

rate_song = function() {
  if (check_logged_in('ratings')) {
    star_number = $(this).attr('id').split('_')[1];
    $.get('/rate_it', 'song_id=' + current_song_id + '&rating=' + star_number, function(data, code, xhr) {
      console.log(data);
      $('.ish_rating').html(data['rating']);
      $('#avg_rating_text').html(data['avg_rating']);
      show_a_message(data['message']);
    });
  }
  else {
    $.get('/fetch_rating', 'song_id=' + current_song_id , function(data, code, xhr) {
      console.log(data);
      $('.ish_rating').html(data['rating']);
      $('#avg_rating_text').html(data['avg_rating']);
      fade_stars();
      setTimeout(reset_rating_stars,2000);
    });
  }
};


postToFeed = function() {

  // calling the API ...
  var obj = {
    method: 'feed',
    link: 'http://'+browser_base_url+playlist.replace(/\s+/g,"-")+'/'+document.getElementsByClassName('title')[0].innerHTML.replace(/\s+/g, '_').replace(/\./g,'~'),
    picture: $('#album_img_current').attr('src'),
    name: document.getElementsByClassName('title')[0].innerHTML,
    caption: 'www.ishlist.com'
    };

  function callback(response) {
    $.ajax({
      url: '/create_hook_up_entry/'+ $('#current_user_id').html(),
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: function(data) {
        console.log(data);
        if (data['new_entry'] == "true") show_a_dialog_message("Alert", "Congrats! You have earned an entry for today's Hookup.");;
      }
    });
    //document.getElementById('msg').innerHTML = "Post ID: " + response['post_id'];
  }

  FB.ui(obj, callback);

}

tweeter_track = function() {
    $.get('/tweeter_a_track', 'song_id=' + current_song_id + '&playlist=' + playlist, function(data, code, xhr) {
      window.location = data['url'];
    });
};

download_track = function() {
  if (check_logged_in('download')) {
    var thanks = "Enjoy your free Download. Now give back to the Ish by showing us some love on the Fbooks, the Tweeternets, and generally blowing up our spot. Word.";
    $.get('/download_track', 'song_id=' + current_song_id, function(data, code, xhr) {
      download_link = data['link'];
      params = player_type == "soundcloud" ? 'width: 0px,height: 0px;' : '';
      window.open(download_link, "", params);
      show_a_message(thanks);
    });
  }
};

set_playlist = function() {
  playlist = $('#playlist').val();
  change_selected_playlist_image();
};

load_playlists = function() {
  $('.station').each(function(i, s) {
    stations.push($(s).attr('name'));
  });
  set_playlist();
};

// left
playlist_up = function() {
  login_status = $('#logged_in').html() == "true";
  if((stations[9] == undefined) && login_status) {
    stations.push("My Favorites");
    $('#playlist').append('<option value="My Favorites">My Favorites</option>');
  }
  index = jQuery.inArray(playlist, stations);
  index = index - 1;
  if (index === -1) index = stations.length - 1;
  $('#playlist').val(stations[index]);
  set_playlist();
  $("#station_play_button_img").show();
  update_next_and_previous_art();
};

// right
playlist_down = function() {
  login_status = ($('#logged_in').html() == "true");
  if((stations[9] == undefined) && login_status) {
    stations.push("My Favorites");
    $('#playlist').append('<option value="My Favorites">My Favorites</option>');
  }
  index = jQuery.inArray(playlist, stations);
  index = index + 1;
  if (index === stations.length) index = 0;
  $('#playlist').val(stations[index]);
  set_playlist();
  $("#station_play_button_img").show();
  update_next_and_previous_art();
};

change_selected_playlist_image = function() {
  if (typeof(playlist) == 'undefined') return;
  playlist_id = playlist.toLowerCase().replace(/ /g, "_");
  if ($('#' + playlist_id + ' > img').attr('src') == undefined){
    station_image_url = "http://s3.amazonaws.com/ishlist/station_name_images/3/original/my_faves.png?1330594680"
  }
  else{
   station_image_url = $('#' + playlist_id + ' > img').attr('src')
  }
  console.log(station_image_url);
  $('#station_img').attr("src", station_image_url);
};

update_next_and_previous_art = function() {
  $.get('/next_and_previous', '&playlist=' + playlist, function(data) {
    next_song_id = data['next_id'];
    previous_song_id = data['previous_id'];
    $('#album_img_next').attr('src', data['next_art']);
    $('#album_img_previous').attr('src', data['previous_art']);
    $('#album_title_previous').html(data['previous_title']);
    $('#album_title_next').html(data['next_title']);
    if(playlist_id == "my_favorites") {
      $('#album_img_future').attr('src', data['future_art']);
      $('#album_img_past').attr('src', data['past_art']);
    }
  });
};

// album art
update_html_station_changed = function(data) {
  update_html(data);
  $('#album_img_future').attr('src', future_art_url);
  $('#album_img_current').attr('src', current_art_url);
  $('#album_img_next').attr('src', next_art_url);
  $('#album_img_previous').attr('src', previous_art_url);
  $('#album_img_past').attr('src', past_art_url);
  load_player();
};

update_html_next = function(data) {
  update_html(data);
  next_song_animation(fx_time);
};

update_html_previous = function(data) {
  update_html(data);
  previous_song_animation(fx_time);
};

// ajax callback
update_html = function(data) {
  if(data['is_fav'])
  {
    $('#lil_heart').css("background-image", "url(/assets/cross_lil_heart.png)")
  }
  else
  {
    $('#lil_heart').css("background-image", "url(/assets/lil_heart.png)")
  }
  $('#album_title_previous').html(data['previous_title']);
  $('#album_title_next').html(data['next_title']);
  $('.title').html(data["title"]);
  $('.artist').html(data["artist"]);
  $('.favorites').html(data["favorites"]);
  $('.ish_rating').html(data["ish_rating"]);
  $('#user_sharer_text').html(data['shared_by']);
  $('#user-img').attr("src", data['user_picture']);
  future_art_url = data['future_art'];
  past_art_url = data['past_art'];
  next_art_url = data['next_art'];
  previous_art_url = data['previous_art'];
  current_art_url = data['art'];
  current_song_id = data['id'];
  previous_song_id = data['previous_id'];
  next_song_id = data['next_id'];
  player_type = data['type'];
  media_source_url = data['media_source_url'];
  download_link = data['download'];
  show_hide_download_link();
  $('#track_link').attr('href', encodeURI('/playlist/' + playlist + '/track/' + current_song_id));

  // make dependent of direction
  // after animate
  show_controls();
};

hide_show_record_hole = function() {
  if (player_type == "youtube") {
    $('#mid_of_record_hole').hide();
  } else {
    $('#mid_of_record_hole').show();
  }
};

load_player = function() {
  if (player_type == 'soundcloud') {
    $('#jplayer_container').html('<a href="' + media_source_url + '" class="sc-player">' + media_source_url + '</a>');
    $("a.sc-player").scPlayer({
      autoPlay: true
    });
    $("#behind_vinyl").css("display","block");
    soundcloud.addEventListener("onMediaEnd", next_song);
    soundcloud.addEventListener("onPlayerReady", auto_play);
    soundcloud.addEventListener("onMediaDoneBuffering", seek);
    return 'loaded soundcloud player';
  } else if (player_type == 'youtube') {
    v = media_source_url.split("?v=").pop();
    $('#album_art_current').append('<div id="tube_player"></div>');
    $("#tube_player").tubeplayer({
      width: 600,
      // the width of the player
      height: 450,
      // the height of the player
      autoPlay: true,
      iframed: false,
      allowFullScreen: "false",
      // true by default, allow user to go full screen
      initialVideo: v,
      // the video that is loaded into the player
      preferredQuality: "default",
      // preferred quality: default, small, medium, large, hd720
      onPlayerEnded: next_song,
      onPlayerPlaying: function() {
        seek();
        auto_play();
        if(playlist_id == "videos") {
          $("#behind_vinyl").css("display","none");
        }
        else {
         $("#behind_vinyl").css("display","block"); 
        }
      }
    });
  } else if (player_type == 'mp3') {
    $('#jplayer_container').html('<div id="jquery_jplayer_1" class="jp-jplayer"></div>');
    $("#jquery_jplayer_1").jPlayer({
      swfPath: "/jplayer.swf",
      wmode: "window",
      ready: function(event) {
        $(this).jPlayer("setMedia", {
          mp3: media_source_url
        }).jPlayer("play");
        // player_loaded = true;
      },
      canplay: function() {
        seek();
      },
      playing: function() {
        auto_play();
      },
      ended: function() {
        next_song();
      },
      timeupdate: function(e) {
        time_in_seconds = e.jPlayer.status.currentTime;
      }
    });
    $("#behind_vinyl").css("display","block");
  }
};

destroy_players = function() {

  reset_rating_stars();
  reset_heard();


  //if(player_loaded) {
  // if(player_type == "mp3") {
  //   $("#jplayer_container").jPlayer("destroy");
  // } else if(player_type == "youtube") {
  //   $('#tube_player').tubeplayer('destroy');
  //   $('#tube_player').remove();
  // } else if(player_type == "soundcloud") {
  //   soundcloud.removeEventListener("onMediaEnd", next_song);
  //   soundcloud.removeEventListener("onPlayerReady", auto_play);
  //   soundcloud.removeEventListener("onMediaDoneBuffering", seek);
  //   $('.sc-player').remove();
  //   $('#scPlayerEngine').remove();
  // }
  //destroy all players
  $("#jquery_jplayer_1").jPlayer("destroy");
  $('.jquery-youtube-tubeplayer').remove();
  soundcloud.removeEventListener("onMediaEnd", next_song);
  soundcloud.removeEventListener("onPlayerReady", auto_play);
  soundcloud.removeEventListener("onMediaDoneBuffering", seek);
  $('.sc-player').remove();
  $('#scPlayerEngine').remove();
  //   $("#jplayer_container").jPlayer("destroy");
  player_loaded = false;
  //}
};


show_hide_download_link = function() {
  if (download_link === "" || download_link === null || player_type == "youtube") {
    $('#download_link').hide();
  } else {
    $('#download_link').show();
  }
};

set_page_vars = function() {
  player_type = $('#player_type').html();
  media_source_url = $('#media_source_url').html();
  download_link = $('#download_url').html();
  show_hide_download_link();
  logged_in = $('#logged_in').html() == "true";
  current_song_id = $('#current_song_id').html();
  previous_song_id = $('#previous_song_id').html();
  next_song_id = $('#next_song_id').html();
  last_song_id = next_song_id;
  index = jQuery.inArray(playlist, stations);
  $('#playlist').val($('#current_playlist').html());
  playlist = $('#playlist').val();
  $('#track_link').attr('href', encodeURI('/playlist/' + playlist + '/track/' + current_song_id));
};

player_pos = function() {
  if (player_type == "mp3") {
    time_in_seconds = time_in_seconds;
  } else if (player_type == "youtube") {
    time_in_seconds = $.tubeplayer.getPlayers()["tubeplayer-player-container"].getCurrentTime();
  } else if (player_type == "soundcloud") {
    time_in_seconds = soundcloud_player.getPosition();
  }
  return time_in_seconds;
};

create_juggernaut = function() {
  jug = new Juggernaut({
    secure: false,
    host: document.location.hostname,
    port: 8080
  });
  jug.subscribe(chat_token, function(data) {
    parse_message(data);
  });
  join_chat();
};

// juggernaut
join_chat = function() {
  send_message("", "join", playlist);
};

chat = function(message) {
  send_message(message, "chat", playlist);
};

pm = function(email, message) {
  send_message(message, "pm", email);
};

lr = function(email, message) {
  send_message(message, "lr", email);
};

lr_accept = function(email, message) {
  message = playlist + "!!!" + current_song_id + "!!!" + player_pos() + "!!!" + message;
  send_message(message, "lraccept", email);
};

lr_deny = function(email, message) {
  send_message(message, "lrdeny", email);
};

send_message = function(message, method, channel) {
  $.ajax({
    url: '/parse?message=' + message + '&channel=' + channel + "&method=" + method + "&chat_token=" + chat_token,
    type: "get"
  });
};

parse_message = function(data) {
  console.log(data);

  method = data.split("!!|!!")[0];
  sender = data.split("!!|!!")[1].split(": ")[0];
  message = data.split("!!|!!")[1].split(": ")[1];

  if (method == "CHAT") {
    console.log(sender + ": " + message);
  } else if (method == "PM") {
    console.log(sender + ": " + message);
  } else if (method == "LR") {
    accept = confirm("Listening Request from " + sender + ": " + message);
    message = prompt("Message?");
    if (accept) {
      lr_accept(sender, message);
    } else {
      lr_deny(sender, message);
    }
  } else if (method == "LRACCEPT") {
    playlist = message.split("!!!")[0];
    current_song_id = message.split("!!!")[1];
    start_time = message.split("!!!")[2];
    message = message.split("!!!")[3];
    //show_a_message(message);
    change_selected_playlist_image();
    lr_accepted();
  } else if (method == "LRDENY") {
    show_a_message("Sorry, " + sender + " denied listen request. ");
  }

};

show_controls_next = function() {
  $('#play_button_next').show();
  $('#album_title_next').show();
};

show_controls_previous = function() {
  $('#play_button_previous').show();
  $('#album_title_previous').show();
};

hide_controls_next = function() {
  $('#play_button_next').hide();
  $('#album_title_next').hide();
};

hide_controls_previous = function() {
  $('#play_button_previous').hide();
  $('#album_title_previous').hide();
};

panel_previous = function() {
  show_controls_next();
  show_controls_previous();
  $.get('/previous_song_paneled', 'playlist=' + playlist + '&current_song_id=' + current_song_id + '&previous_song_id=' + previous_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    console.log(data);
    last_song_id = data['next_id'];
    previous_song_id = data['previous_id'];
    next_song_id = data['next_id'];
    $('#album_img_next').attr("src", data['next_art']);
    $('#album_img_previous').attr("src", data['previous_art']);
    $('#album_title_previous').html(data['previous_title']);
    $('#album_title_next').html(data['next_title']);
    $('#album_img_future').attr('src', data['future_art']);
    $('#album_img_past').attr('src', data['past_art']);
  }, 'text');
};

panel_next = function() {
  show_controls_next();
  show_controls_previous();
  $.get('/next_song_paneled', 'playlist=' + playlist + '&current_song_id=' + current_song_id + '&next_song_id=' + next_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    console.log(data);
    last_song_id = data['next_id'];
    previous_song_id = data['previous_id'];
    next_song_id = data['next_id'];
    $('#album_img_next').attr("src", data['next_art']);
    $('#album_img_previous').attr("src", data['previous_art']);
    $('#album_title_previous').html(data['previous_title']);
    $('#album_title_next').html(data['next_title']);
    $('#album_img_future').attr('src', data['future_art']);
    $('#album_img_past').attr('src', data['past_art']);
  }, 'text');
};

panel_play_next = function() {
  stop_all_audio();
  destroy_players();
  $.get('/next_song', 'playlist=' + playlist + "&current_song_id=" + next_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    console.log(data);
    update_html_station_changed(data);
    if (logged_in === true) {
      $.get('/fetch_rating', 'song_id=' + current_song_id , function(data, code, xhr) {
      console.log(data);
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#avg_rating_text').html(data['avg_rating']);
        fade_stars();
      }
      });
      $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#heard_text').html(data['avg_listens']);
        show_a_message(data['message']);
      }
      });
    }
  }, 'text');
  var stateObj = { foo: "bar" };
  history.pushState(stateObj, "The Ishlist","http://"+browser_base_url+playlist.replace(/\s+/g,"-")+'/'+document.getElementById('album_title_next').innerHTML.replace(/\s+/g, '_').replace(/\./g,'~'));
  return false;
};

panel_play_previous = function() {
  stop_all_audio();
  destroy_players();
  $.get('/previous_song', 'playlist=' + playlist + "&current_song_id=" + previous_song_id, function(data, code, xhr) {
    data = JSON.parse(data);
    console.log(data);
    update_html_station_changed(data);
    if (logged_in === true) {
      $.get('/fetch_rating', 'song_id=' + current_song_id , function(data, code, xhr) {
      console.log(data);
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#avg_rating_text').html(data['avg_rating']);
        fade_stars();
      }
      });
      $.get('/fetch_heard_it', 'song_id=' + current_song_id, function(data, code, xhr) {
      if (data.already_rated) {
        $('.ish_rating').html(data['rating']);
        $('#heard_text').html(data['avg_listens']);
        show_a_message(data['message']);
      }
      });
    }
  }, 'text');
  var stateObj = { foo: "bar" };
  history.pushState(stateObj, "The Ishlist","http://"+browser_base_url+playlist.replace(/\s+/g,"-")+'/'+document.getElementById('album_title_previous').innerHTML.replace(/\s+/g, '_').replace(/\./g,'~'));
  return false;
};

scroll_to = function(x, y) {
  setTimeout(function() {
    window.scroll(x, y);
  }, 2500);
};


pop_under = function(html) {
  $('#page-holder').html(html);
  $('#main_body').css("height", 'auto');
  $('#page-bottom').css("height",'1035');
  $('#main_body').css("overflow", 'visible');
  $('#page-holder').ready(function() {
    scroll_to(0, 1000);
  });
  //window.location.hash="1stpage";
};

pop_right = function(html) {
  $('#page-holder-2').html(html);
  $('#main_body').css("height", 'auto');
  $('#page-bottom').css("height",'2000');
  $('#page-holder-2').ready(function() {
    scroll_to(0, 1960);
  });
  //window.location.hash="2ndpage";
};

tag_songs = function() {
  if (check_logged_in('tag')) {
    $.get('/tag_songs', '&song_id=' + uploaded_song_id, function(data, code, xhr) {
      pop_right(data);
      rebind_controls();
    });
  }
};

show_upload_songs = function() {
  if (check_logged_in('share')) {
    $.get('/upload_songs', '', function(data, code, xhr) {
      pop_under(data);
      rebind_controls();
    });
  }
};

show_recent_activities_on_song = function() {
    $.get('/recent_activities', 'song_id=' + current_song_id, function(data, code, xhr) {
      pop_under(data);
      rebind_controls();
    });
};

show_my_ishlist = function() {
  show_a_dialog_message("My Ishlist", "My IshList page and features are coming soon!");
  //if (check_logged_in('myish')) {
  //  $.get('/my_ishlist', '', function(data, code, xhr) {
  //    pop_under(data);
  //  });
  //}
};

show_users_ishlist = function(id) {
  if (check_logged_in('users')) {
    $.get('/user_profile/' + id, '', function(data, code, xhr) {
      pop_under(data);
    });
  }
};


unbind_controls = function() {
  $('*').unbind();
  player_locked = true;
  $.each($('*'), function(i, e) {
    try {
      if ($(e).data('events').click.length > 0) $(e).css('cursor', 'default');
    } catch (e) {}
  });
};

rebind_controls = function() {

  // bind everything all pages
  unbind_controls();

  set_up_facebook();

  // tag songs
  $('.chooseable-art').bind('click', function() {

    art_src = $(this).attr('src');
    console.log(art_src);
    $('#chosen_img').attr('src', art_src);
    $('#chosen_img_left').attr('src', art_src);
    $('#chosen_img_right').attr('src', art_src);
    $('#chosen_img').show();
    $('#chosen_img_left').show();
    $('#chosen_img_right').show();
    $('#art_url').val(art_src);
    $('#blank_torn_paper_2').fadeOut(2000);
    $('#explain_text').fadeOut(2000);
    $('#lastly_text').fadeOut(2000);
    $('.chooseable-art').fadeOut(2000);
    $('#tag_songs_top_desc').fadeOut(2000);
    $('#ref-holder').fadeOut(2000);
    $('#logo_tag_songs').fadeOut(2000);
    $('#done_button_tag_songs').fadeOut(2000);
    setTimeout(function() {
      $('#blank_torn_paper_2').fadeIn(2000);
      $('#explain_text').fadeIn(2000);
      $('#lastly_text').fadeIn(2000);
      $('.chooseable-art').fadeIn(2000);
      $('#tag_songs_top_desc').fadeIn(2000);
      $('#ref-holder').fadeIn(2000);
      $('#logo_tag_songs').fadeIn(2000);
    $('#done_button_tag_songs').fadeIn(2000);
    },2000);
  });
  $('#select_album_art_button').bind('click', function() {
    $('#album-art').click();
  });
  $('#done_button_tag_songs').bind('click', upload_art);

  // uploader
  $('#select_file').bind('click', function() {
    $('#song-file').click();
    old_val = $('#song-file').val().replace(/^.*[\\\/]/, '')
    check_file_name(old_val);
  });
  $('#next_thingy_upload_songs').bind('click', upload_a_song);
  $('#search_go').bind('click', show_search_results_page);
  $('#todays_entries').bind('click', show_todays_hookup_entries_page);
  $('#close_button').bind('click', hide_bottom_pages);
  $('#close_button_dilly_yo').bind('click', hide_bottom_pages);
  $('#close_button_search').bind('click', hide_bottom_pages);
  $('#close_button_hookup_entry').bind('click', hide_bottom_pages);
  $('#close_popup_button').bind('click', hide_activity_comment_popup);
  $('#more_on_recent_activities').bind('click', show_more_recent_activities);
  $('#next_on_recent_activities').bind('click', show_next_recent_activities);
  $('#prev_on_recent_activities').bind('click', show_prev_recent_activities);
  $('#the_dilly-yo').bind('click',show_dilly_yo_page);
  $('#search_browse').bind('click',show_search_browse_page);
  $('#the-hook-ups').bind('click',show_hook_up_page);
  $('#fbook_icon').bind('click', facebook_track);
  $('#dilly_play_button').bind('click',play_dilly_video);
  $('#dilly_pause_button').bind('click',pause_dilly_video);
  $('#twitter_icon').bind('click', tweeter_track);

  $('#my_ishlist').bind('click', show_my_ishlist);

  $('#yup_download_permission').bind('click', close_download_permission_popup);

  $('#yup_on_holler').bind('click', post_comment);

  $('#yup_on_holler_on_activity_page').bind('click', post_comment_from_activity_page);

  $('#yup_on_holler_on_activity_popup').bind('click', post_comment_from_activity_comment_popup);

  $('#sign_in').bind('click', login);

  $('#sign_up').bind('click', register);

  $('#next_arrow').bind('click', panel_next);
  $('#previous_arrow').bind('click', panel_previous);

  $('#album_art_next_overlay').bind("click", panel_play_next);
  $('#album_art_previous_overlay').bind("click", panel_play_previous);

  $('#album_art_next_overlay').bind("mouseover", show_controls_next);
  $('#album_art_next_overlay').bind("mouseleave", hide_controls_next);
  $('#album_art_previous_overlay').bind("mouseover", show_controls_previous);
  $('#album_art_previous_overlay').bind("mouseleave", hide_controls_previous);

  $('#next_song_button').bind('click', next_song);
  $('#previous_song_button').bind('click', previous_song);

  // show controls
  // .on_player
  $('.over_player').bind('mouseover', function() {
    if (!over_player) {
      show_controls();
      over_player = true;
      //fade_out_radio_page_elements();
    }
  });
  $('#background').bind('mouseover', function() {
    if (over_player) {
      hide_controls_fast();
      over_player = false;
      //fade_in_radio_page_elements();
    }
  });

  $("input[type='text']").focus(function() {
    textbox_focused = true;
  });
  $("input[type='text']").blur(function() {
    textbox_focused = false;
  });
  $("input[type='password']").focus(function() {
    textbox_focused = true;
  });
  $("input[type='password']").blur(function() {
    textbox_focused = false;
  });
  $("textarea").focus(function() {
    textbox_focused = true;
  });
  $("textarea").blur(function() {
    textbox_focused = false;
  });
  // share_track
  $('#share_a_track').bind("click", show_upload_songs);
  //recent activities on current song
  $('#small_latest_chart').bind("click", show_recent_activities_on_song);
  //playlist
  $('#station_up_arrow').bind("click", playlist_up);
  $('#station_down_arrow').bind("click", playlist_down);
  $('#station_img').bind("click", change_station);

  // bind controls
  $("#play_button").bind("click", play_pause);

  //download link
  $("#download_link").bind('click', download_track);

  // need fan artist
  $('#lil_heart').bind('click', favorite_track);
  $('#fan').bind('click', fan_track);
  $('#heard_it').bind('click', heard_it);
  $('#havent_heard').bind('click', havent_heard);

  $('.star').bind('mouseover', change_stars);
  $('.star').bind('mouseout', blank_stars);
  $('.star').bind('click', rate_song);

  $('#yes').bind('click', heard_it);
  $('#no').bind('click', havent_heard);

  // keyboard
  $(document).keydown(onkeydown);
  $(document).keyup(onkeyup);
  player_locked = false;

  // has the effect of giving pointer finger to every thing with a click event
  $.each($('*'), function(i, e) {
    try {
      if ($(e).data('events').click.length > 0) $(e).css('cursor', 'pointer');
    } catch (e) {}
  });
};

close_download_permission_popup = function() {
  $('#download_permission').hide();
  $('#download_permission_no').hide();
  $('#download_permission_yes').hide();
  $('#yup_download_permission').hide();
  $('#wait_for_mp3').show();
  $('#processing_dots').show();
  var data = new FormData(document.getElementById('song_form'));
    $.ajax({
      url: '/post_track?can_download='+download_permission,
      data: data,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: function(data) {
        console.log(data);
        uploaded_song_id = data['song_id'];
        show_a_message(data['message']);
      }
    }); 
}

check_file_name = function(old_val) {
  if ($('#song-file').val() != "" && $('#song-file').val().replace(/^.*[\\\/]/, '') != old_val) {
    $('#select_file_text')[0].innerHTML = $('#song-file').val().replace(/^.*[\\\/]/, '')
  } else {
    setTimeout(check_file_name, 3000);
  }
};

check_user_pic_file_name = function(old_val) {
  if ($('#user_photo').val() != "" && $('#user_photo').val().replace(/^.*[\\\/]/, '') != old_val) {
    $('#select_pic_file_text')[0].innerHTML = $('#user_photo').val().replace(/^.*[\\\/]/, '')
  } else {
    setTimeout(check_user_pic_file_name, 3000);
  }
};

bind_animation_vars = function() {
  future_left = $('#album_art_future').css('left');
  current_left = $('#album_art_current').css('left');
  current_top = $('#album_art_current').css('top');
  next_left = $('#album_art_next').css('left');
  next_top = $('#album_art_next').css('top');
  previous_left = $('#album_art_previous').css('left');
  past_left = $('#album_art_past').css('left');
  previous_top = $('#album_art_previous').css('top');

  small_height = $('#album_img_previous').css('height');
  small_width = $('#album_img_previous').css('width');

  big_height = $('#album_img_current').css('height');
  big_width = $('#album_img_current').css('height');
};


remove_scrollies_and_set_size = function() {
  //document.documentElement.style.overflow = 'hidden';
  document.documentElement.style.overflowX = 'hidden';
  window.resizeTo(1281, 1224);
};

dont_auto_play_on_local = function() {
  if (window.location.hostname == "localhost") {
    volume = 0;
    change_volumes();
  }
};

facebook_frame_changed = function() {
  data = JSON.parse($(w.document).find("pre").html());
  if(data !== null) {
    chat_token = data['chat_token'];
    show_a_message(data['message']);
    w.close();
    window.location = window.location.href;
  } else {
    setTimeout(facebook_frame_changed, 1000);
  }
};

set_up_facebook = function() {
  $(".fbconnectbtn").click(login_fb);
};

get_ready = function() {
  remove_scrollies_and_set_size();

  bind_animation_vars();

  rebind_controls();

  // start radio
  set_page_vars();
  load_playlists();

  if (logged_in === true) {
    // server push
    create_juggernaut();
  }

  load_player();

  scroll_home();
  on_load();
  // TODO: hook to audio processing if possible
  //initScreenSaver();
};

// page_scripters = function() {
//   if(window.location.pathname.match('admin')) {
//     admin_ready();
//     console.log("Admin got ready");
//   }
// };
$(document).ready(function() {
  get_ready();
  // page_scripters();
});

get_comments = function() {
  $("#comment_scroller").remove();
  $.get('/get_comments/' + current_song_id, '', function(data, code, xhr) {
    console.log(data);
    $('#comment_scroller').ready(function() {
      setTimeout(function() {
        $('#behind_vinyl').html('<ul id="comment_scroller"></ul>');
        $('#comment_scroller').html(data['html']);
        scroll_comments();
      }, 4000);   
    });
  });
};

scroll_comments = function() {
  $("#comment_scroller").simplyScroll({
    orientation: 'vertical',
    auto: true,
    loop: true
  });
};

upload_a_song = function() {
  if ($('#song-file').val() != "" || $('#song-link').val() != "") {
  $('#next_thingy_upload_songs').hide();
  //show_a_dialog_message("Hi","Uploading your song... Disabled the upload button for convenience. Please wait...");
  if ($('#song-file').val() != "") {
    $('#download_permission').show();
    $('#download_permission_no').show();
    $('#download_permission_yes').show();
    $('#yup_download_permission').show();
  }
  else
  {
    $('#wait_for_youtube').show();
    $('#processing_dots').show(); 
    var data = new FormData(document.getElementById('song_form'));
    $.ajax({
      url: '/post_track',
      data: data,
      cache: false,
      contentType: false,
      processData: false,
      type: 'POST',
      success: function(data) {
        console.log(data);
        uploaded_song_id = data['song_id'];
        show_a_message(data['message']);
      }
    });
  }
}
else{
  show_a_dialog_message("Error - ","You must select a file or provide a link first");
}
  return false;
};
function change_download_permission(check)
{
  if (check == 'no')
  {
    download_permission = "no";
    $('#download_permission_no').css("background-image","url(/assets/X.png)");
    $('#download_permission_yes').css("background-image",'none');
  }
  else
  {
    download_permission = "yes";
    $('#download_permission_yes').css("background-image","url(/assets/X.png)");
    $('#download_permission_no').css("background-image",'none');
  }
}

function like_a_comment(obj_class, obj_id) 
{
  if (check_logged_in('comment')) {

    $.ajax(
      {
      dataType: "json",
      cache: false,
      url: '/like_activity?id='+ obj_id +'&class=' + obj_class,
      success: function(data)
      {
        $('#'+obj_class+'_'+obj_id).html("("+data.count+")");
      }
    });
  }
  else {
     $('#registration_required_box').css("margin-top",'1000px');
  }
    return false;
}
function show_comments_on_activity(obj_class, obj_id)
{
  $('#activity_class').val(obj_class);
  $('#activity_id').val(obj_id);
  $('#comment_text_on_activity_popup').val("");
  $.get('/comments_on_activity/' + obj_class +'/'+ obj_id, function(data, code, xhr) {
    $('#older_activity_comments').html(data)
    $('.comment_on_activity_popup').show();
  });
}
function hide_activity_comment_popup()
{
  $('.comment_on_activity_popup').hide();
}

post_comment_from_activity_comment_popup = function() {

  if (check_logged_in('comment')) {

    comment = $('#comment_text_on_activity_popup').val();
    activity_id = $('#activity_id').val();
    activity_class = $('#activity_class').val();
    $.ajax(
      {
      dataType: "json",
      cache: false,
      url: '/post_comment_on_activity?activity_id='+ activity_id +'&activity_class='+ activity_class +'&activity_comment='+comment,
      success: function(data)
      {
        $('#comments-'+activity_class+'_'+activity_id).html("("+data.count+")");
        $('#comment_text_on_activity_popup').val("");
        $.get('/comments_on_activity/' + activity_class +'/'+ activity_id, function(data, code, xhr) {
          $('#older_activity_comments').html(data)
        });
      }
    });

    return false;
  }
  else {
     $('#registration_required_box').css("margin-top",'1000px');
  }

};

function show_more_recent_activities()
{
  count = $('#count').val();
  song_id = $('#song_id').val();
  $.get('/more_recent_activities/' + song_id +'/'+ count, function(data, code, xhr) {
    $('.song_activities').html(data);
    $('#count').val(parseInt(count)+1);
    $('#more_on_recent_activities').hide();
    $('#prev_on_recent_activities').show();
    if ($('#next_flag').val() != "true") {
      $('#next_on_recent_activities').show();
    }
  });

};

function show_next_recent_activities()
{
  count = $('#count').val();
  song_id = $('#song_id').val();
  $.get('/more_recent_activities/' + song_id +'/'+ count, function(data, code, xhr) {
    $('.song_activities').html(data);
    $('#count').val(parseInt(count)+1);
    if ($('#next_flag').val() == "true") {
      $('#next_on_recent_activities').hide();
    }
    $('#prev_on_recent_activities').show();
  });

};

function show_prev_recent_activities()
{
  count = $('#count').val();
  song_id = $('#song_id').val();
  $.get('/prev_recent_activities/' + song_id +'/'+ count, function(data, code, xhr) {
    $('.song_activities').html(data);
    $('#count').val(parseInt(count) - 1);
    if ($('#prev_flag').val() == "true") {
      $('#prev_on_recent_activities').hide();
    }
    $('#next_on_recent_activities').show();
  });

};


function ShowPicture(id,Source) {
if (Source=="1"){
	if (document.layers) document.layers[''+id+''].visibility = "show"
	else if (document.all) document.all[''+id+''].style.visibility = "visible"
	else if (document.getElementById) document.getElementById(''+id+'').style.visibility = "visible"
}
else
	if (Source=="0"){
	if (document.layers) document.layers[''+id+''].visibility = "hide"
	else if (document.all) document.all[''+id+''].style.visibility = "hidden"
	else if (document.getElementById) document.getElementById(''+id+'').style.visibility = "hidden"
	}
}

function Picture(id,Source) {
	if (Source=="3"){
	if (document.layers) document.layers[''+id+''].visibility = "show"
	else if (document.all) document.all[''+id+''].style.visibility = "visible"
	else if (document.getElementById) document.getElementById(''+id+'').style.visibility = "visible"
}
else
	if (Source=="4"){
	if (document.layers) document.layers[''+id+''].visibility = "hide"
	else if (document.all) document.all[''+id+''].style.visibility = "hidden"
	else if (document.getElementById) document.getElementById(''+id+'').style.visibility = "hidden"
	}
}

function fade_out_radio_page_elements() {
  $('#shared_by').fadeOut(1000);
  $('#share_a_track').fadeOut(1000);
  $('#user_picture').fadeOut(1000);
  $('#blank_polaroid').fadeOut(1000);
  $('#comment_box').fadeOut(1000);
  $('#yup_on_holler').fadeOut(1000);
  $('#small_latest_chart').fadeOut(1000);
  $('#my_ishlist').fadeOut(1000);
}
function fade_in_radio_page_elements() {
  $('#shared_by').fadeIn(1000);
  $('#share_a_track').fadeIn(1000);
  $('#user_picture').fadeIn(1000);
  $('#blank_polaroid').fadeIn(1000);
  $('#comment_box').fadeIn(1000);
  $('#yup_on_holler').fadeIn(1000);
  $('#small_latest_chart').fadeIn(1000);
  $('#my_ishlist').fadeIn(1000);
}

show_dilly_yo_page = function() {
    $.get('/dilly_yo', function(data, code, xhr) {
      pop_under(data);
      rebind_controls();
    });
};

show_hook_up_page = function() {
    $.get('/hook_ups', function(data, code, xhr) {
      pop_under(data);
      rebind_controls();
    });
};

show_search_browse_page = function() {
    $.get('/search_browse', function(data, code, xhr) {
      pop_under(data);
      rebind_controls();
    });
};

show_search_results_page = function() {
$.get('/search_results', function(data, code, xhr) {
      pop_right(data);
      rebind_controls();
    });
};

show_todays_hookup_entries_page = function() {
  $.get('/todays_hookup_entries', function(data, code, xhr) {
      pop_under(data);
      rebind_controls();
    });
}

play_dilly_video = function() {
  stop_all_audio();
  player.playVideo();
  $('#dilly_play_button').hide();
  $('#dilly_pause_button').hide();
}
mouse_over_check_video_state = function () {
  if (player.getPlayerState() == 1)
    $('#dilly_pause_button').show();
  else
    $('#dilly_play_button').show();
}
mouse_out_check_video_state = function () {
  if (player.getPlayerState() == 1) {  
    $('#dilly_pause_button').hide();   
    $('#dilly_play_button').hide();
  }
  else {
    $('#dilly_play_button').show();
  }
}
pause_dilly_video = function() {
  player.pauseVideo();
  start_all_audio();
  $('#dilly_play_button').show();
  $('#dilly_pause_button').hide();
}


