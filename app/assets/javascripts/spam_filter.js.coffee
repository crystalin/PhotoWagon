jQuery ->
  $('#new_comment').submit ->
    $(this).find('#comment_website_input').val('verified');