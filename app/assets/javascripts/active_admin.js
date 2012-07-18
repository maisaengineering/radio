//= require jquery
//= require soundcloud.player.api
//= require_tree ./libs
//= require_tree ./swfupload
//= require jquery.swfupload



$(document).ready(function () {
  console.log("Getting ready admin");
  $("input[type='text']").focus(function() { textbox_focused = true; });
  $("input[type='text']").blur(function() { textbox_focused = false; });
  //-- Search Button
  //if (searching) return;
  $('#search_submit').click(function () {
    $.ajax({
      url:'/admin/songs/search', type:"get",
      data:search_params(), success:search_success
    });
  });
  $('#search_query').keypress(function (e) {
    //if(searching) return;
    if(e.which == 13)
      submit_button().click();
  });
  $('#search_type_title').click();
  console.log("Admin ready.");
});

//---- Search
var searching = false;
var query_input_tag = function () { return $('#search_query'); };
var search_filters_div = function () { return $('#search_filters'); };
var results_div = function () { return $('#search_results'); };
var submit_button = function () { return $('#search_submit'); };
var get_search_type = function () {
  var selected = [];
  filters = search_filters_div();
  filters.find('input[name="search_type"]').each(function (i, v) {
    if ($(v).is(":checked")) selected.push($(v).val());
  });
  if (selected.length > 0) return selected[0];
};
var search_params = function () {
  return {
    "query":query_input_tag().val(),
    "type":get_search_type()
  }
};
var search_success = function (data) {
  results_div().html(data);
  searching = false;
}

//-- Search Result Event Binding
var bind_song_functions = function () {
  results_div().each(function (i,song) {
    //player
    $('.play_pause').click(function () {
      play_media_source(
        $(this).siblings('#song_source').val(),
        $(this).siblings('#song_url').val()
      );
    });
    //nuke comment
    $('.nuke_comment').click(function () {
      nuke_comment($(this).attr('id'));
    });
    //title
    title_edit_button(song).click(edit_title);
    title_edit_cancel_button(song).click(cancel_edit_title);
    title_edit_save_button(song).click(update_title);
    //artist
    artist_edit_button(song).click(edit_artist);
    artist_edit_cancel_button(song).click(cancel_edit_artist);
    artist_edit_save_button(song).click(update_artist);
    //playlist
    playlist_add_button(song).click(playlist_add);
    playlist_remove_buttons(song).each(function (i, btn) {
      $(btn).click(playlist_remove);
    });
    //album title
    album_title_edit_button(song).click(edit_album_title);
    album_title_edit_cancel_button(song).click(cancel_edit_album_title);
    album_title_edit_save_button(song).click(update_album_title);
    //nuke
    $('button.nuke').click(function () {
      if (confirm("Really nuke this track from the database?"))
        nuke($(this).parents('.song'));
    });
    
  });
}

//---- Song
var song_id = function (song) { return $(song).find('input#song_id').val() }
var find_song = function (id) { return $('div#song_'+id) }
var song_url = function (song) { return $(this).siblings('#song_url').val() }

//-- Nuke!
var nuke = function (song) {
  $.ajax({
    url:'/admin/songs/'+song_id(song)+'/nuke', type:"post",
    data:{ 'authenticity_token':AUTH_TOKEN },
    success:function (data) {
      if (data['success'] == true) {
        var song = $('#song_'+data['id']);
        song.remove();
      } else {
        alert('Failed to nuke track.');
      }
    }
  });
}

//-- Nuke comment!
var nuke_comment = function (comment_id) {
  $.ajax({
    url:'/admin/songs/delete_comment?id='+comment_id, type:"post",
    data:{ 'authenticity_token':AUTH_TOKEN },
    success:function (data) {
      $('#comment_'+comment_id).remove();
      alert("success");
    }
  });
}

//-- Album Title
var album_title_span = function (song) { return $(song).find('.album_title span') };
var album_title_input = function (song) { return $(song).find('.album_title input') };
//-- Album Title Buttons
var album_title_edit_button = function (song) { return $(song).find('.album_title button.edit') };
var album_title_edit_cancel_button = function (song) { return $(song).find('.album_title button.cancel') };
var album_title_edit_save_button = function (song) { return $(song).find('.album_title button.save') };
//-- Album Title Actions
var edit_album_title = function () {
  var song = $(this).parents('.song')
  album_title_span(song).hide();
  album_title_input(song).val(album_title_span(song).text());
  album_title_input(song).show();
  album_title_edit_button(song).hide();
  album_title_edit_save_button(song).show();
  album_title_edit_cancel_button(song).show();
}
var cancel_edit_album_title = function () {
  var song = $(this).parents('.song')
  album_title_input(song).hide();
  album_title_input(song).val(album_title_span(song).text());
  album_title_span(song).show();
  album_title_edit_save_button(song).hide();
  album_title_edit_cancel_button(song).hide();
  album_title_edit_button(song).show();
}
var update_album_title = function () {
  var song = $(this).parents('.song')
  album_title = $(this).siblings('input').val();
  $.ajax({
    url:'/admin/songs/'+song_id(song)+'/update_album_title', type:"put",
    data:{ 'new_album_title':album_title, 'authenticity_token':AUTH_TOKEN },
    success:function (data) {
      if (data['success'] == true) {
        var song = $('#song_'+data['id']);
        //fields
        album_title_input(song).hide();
        album_title_span(song).text(album_title).show();
        //buttons
        album_title_edit_save_button(song).hide();
        album_title_edit_cancel_button(song).hide();
        album_title_edit_button(song).show();
      } else {
        alert('Could not change album title!');
      }
    }
  });
}

//-- Playlist buttons
var playlist_add_button = function (song) { return $(song).find('.playlist button.add') };
var playlist_remove_buttons = function (song) { return $(song).find('.playlist button.remove') };
//-- Playlist Actions
var playlist_add = function () {
  song = $(this).parents('.song');
  $.ajax({
    url:'/admin/playlists/add_to_playlist', type:"post",
    data:{
      'playlist':$(this).siblings('select').val(),
      'song_ids':[song_id(song)],
      'authenticity_token':AUTH_TOKEN,
      'dashboard':true
    },
    success:function (data) {
      if (data['success'] == true) {
        var button = '<button id="playlist_'+data['id'];
        button += '" type="submit" name="button" class="remove">Remove</button>';
        var id = '<input type="hidden" value="'+data['id']+'" name="playlist_id" id="playlist_id">';
        var html = '<span id="playlist_'+data['id']+'">'+data['name']+id+button+'</span>';
        var song = find_song(data['song_id']);
        song.find('.playlists').append(html);
        song.find('button#playlist_'+data['id']).click(playlist_remove);
      } else {
        alert('Could not add to playlist!');
      }
    }
  });
}
var playlist_remove = function () {
  var song = $(this).parents('.song');
  var playlist = {}
  pid = $(this).siblings('input#playlist_id').val();
  playlist[pid] = { 'songs':[song_id(song)] }
  $.ajax({
    url:'/admin/playlists/remove_songs', type:"post",
    data:{
      'playlist':playlist,
      'authenticity_token':AUTH_TOKEN,
      'dashboard':true
    },
    success:function (data) {
      if (data['success'] == true) {
        var song = find_song(data['song_id']);
        song.find('span#playlist_'+data['id']).hide().remove();
      } else {
        alert('Could not remove from playlist!');
      }
    }
  });
}

//-- Title Fields
var title_span = function (song) { return $(song).find('.title span') };
var title_input = function (song) { return $(song).find('.title input') };
//-- Title Buttons
var title_edit_button = function (song) { return $(song).find('.title button.edit') };
var title_edit_cancel_button = function (song) { return $(song).find('.title button.cancel') };
var title_edit_save_button = function (song) { return $(song).find('.title button.save') };
//-- Title Actions
var edit_title = function () {
  var song = $(this).parents('.song')
  title_span(song).hide();
  title_input(song).val(title_span(song).text());
  title_input(song).show();
  title_edit_button(song).hide();
  title_edit_save_button(song).show();
  title_edit_cancel_button(song).show();
}
var cancel_edit_title = function () {
  var song = $(this).parents('.song')
  title_input(song).hide();
  title_input(song).val(title_span(song).text());
  title_span(song).show();
  title_edit_save_button(song).hide();
  title_edit_cancel_button(song).hide();
  title_edit_button(song).show();
}
var update_title = function () {
  var song = $(this).parents('.song')
  title = $(this).siblings('input').val();
  $.ajax({
    url:'/admin/songs/'+song_id(song)+'/update_song_title', type:"put",
    data:{ 'new_title':title, 'authenticity_token':AUTH_TOKEN },
    success:function (data) {
      if (data['success'] == true) {
        var song = $('#song_'+data['id']);
        //fields
        title_input(song).hide();
        title_span(song).text(title).show();
        //buttons
        title_edit_save_button(song).hide();
        title_edit_cancel_button(song).hide();
        title_edit_button(song).show();
      } else {
        alert('Could not change title!');
      }
    }
  });
}

//-- Artist Fields
var artist_span = function (song) { return $(song).find('.artist span') };
var artist_input = function (song) { return $(song).find('.artist input') };
//-- Artist Buttons
var artist_edit_button = function (song) { return $(song).find('.artist button.edit') };
var artist_edit_cancel_button = function (song) { return $(song).find('.artist button.cancel') };
var artist_edit_save_button = function (song) { return $(song).find('.artist button.save') };
//-- Artist Actions
var edit_artist = function () {
  var song = $(this).parents('.song');
  artist_span(song).hide();
  artist_input(song).val(artist_span(song).text());
  artist_input(song).show();
  artist_edit_button(song).hide();
  artist_edit_save_button(song).show();
  artist_edit_cancel_button(song).show();
}
var cancel_edit_artist = function () {
  var song = $(this).parents('.song')
  artist_input(song).hide();
  artist_input(song).val(artist_span(song).text());
  artist_span(song).show();
  artist_edit_save_button(song).hide();
  artist_edit_cancel_button(song).hide();
  artist_edit_button(song).show();
}
var update_artist = function () {
  var song = $(this).parents('.song')
  artist = $(this).siblings('input').val();
  $.ajax({
    url:'/admin/songs/'+song_id(song)+'/update_artist_name', type:"put",
    data:{ 'artist_name':artist, 'authenticity_token':AUTH_TOKEN },
    success:function (data) {
      if (data['success'] == true) {
        var song = $('#song_'+data['id']);
        //fields
        artist_input(song).hide();
        artist_span(song).text(artist).show();;
        //buttons
        artist_edit_save_button(song).hide();
        artist_edit_cancel_button(song).hide();
        artist_edit_button(song).show();
      } else {
        alert('Could not change artist!');
      }
    }
  });
}
