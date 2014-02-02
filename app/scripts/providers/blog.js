module.exports = function()
{
  jQuery('.trackCustomerLogin').each(function (e) {
    $btn = jQuery(this);
    callToActionHtml = $btn.html()

    $btn.mouseover(function (emover) {
      $btn.html("Sign in with Google for Video Chat");
      $btn.next('except').html('We use your google account for G+ Hangouts')
    }).mouseout(function (emout) {
      $btn.html(callToActionHtml);
      $btn.next('except').html('')
    })
  });
}
