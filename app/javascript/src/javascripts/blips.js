import Utility from './utility.js';

let Blip = {};

Blip.atme = function (id) {
  $.ajax({
    url: `/blips/${id}.json`,
    type: 'GET',
    dataType: 'json',
    accept: 'text/javascript',
    data: {
      id: id
    }
  }).done(function (data) {
    $('#blip_body_for_')[0].value += '@' + data.creator_name.replace(/ /g, "_") + ': ';
    $("#blip_body_for_")[0].focus();
    $('#blip_response_to')[0].value = data.id;
  }).fail(function (data) {
    Utility.error(data.responseText);
  });
};

Blip.quote = function (id) {
  $.ajax({
    url: `/blips/${id}.json`,
    type: 'GET',
    dataType: 'json',
    accept: 'text/javascript',
    data: {
      id: id
    }
  }).done(function (data) {
    const stripped_body = data.body.replace(/\[quote\](?:.|\n|\r)+?\[\/quote\][\n\r]*/gm, "");
    $('#blip_body_for_')[0].value += `[quote]"${data.creator_name}":/users/${data.creator_id} said:
${stripped_body}
[/quote]

`;
    $("#blip_body_for_")[0].focus();
    $('#blip_response_to')[0].value = data.id;
  }).fail(function (data) {
    Utility.error(data.responseText);
  });
};
// TODO
Blip.block = function(e) {
  e.preventDefault();
  if (!confirm("Are you sure you want to blacklist this user? Their posts will be blacklisted as well. Additionally, all blacklisted users will also have both their posts and non-posts blocked.")) return;
  const parent = $(e.target).parents('article.comment');
  const buid = parent.data('creator-id');
  $.ajax({
    url:`/users/${Utility.meta("current-user-id")}.json`, 
    type: 'PATCH',
    data:{
      'user[blacklist_users]':true,
      'user[blacklisted_tags]':`\nuser:${buid}`
    },
    headers: {
      accept: '*/*;q=0.5,text/javascript',
      Cookie: document.cookie,
    }
  }).done(function(data) {
    $(window).trigger("danbooru:notice", "User blocked");
  }).fail(function (data) {
    Utility.error("Failed to block user.");
  });
};

Blip.initialize_all = function() {
  if($("#c-blips").length) {
    $(".blip-atme-link").on('click', e => {
      Blip.atme($(e.target).data('bid'));
      e.preventDefault();
    });
    $(".blip-reply-link").on('click', e => {
      Blip.quote($(e.target).data('bid'));
      e.preventDefault();
    });
  }
}

Blip.reinitialize_all = function() {
  if($("#c-blips").length) {
    $(".blip-atme-link").off('click');
    $(".blip-reply-link").off('click');
    Blip.initialize_all();
  }
}

$(function() {
  Blip.initialize_all();
});

export default Blip;
