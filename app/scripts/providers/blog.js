module.exports = function()
{
  jQuery('.trackCustomerLogin').each(function (idx, btn) {
    $btn = jQuery(btn);
    callToActionHtml = $btn.html()

    $btn.mouseover(function (emover) {
      $btn.html("Sign in with Google for Video Chat");
      jQuery('<figure>We use your google account for G+ Hangouts</figure>').insertAfter($btn)
    }).mouseout(function (emout) {
      $btn.html(callToActionHtml);
      $btn.next('figure').remove()
    })
  });
}
