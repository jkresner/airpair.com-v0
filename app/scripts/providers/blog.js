module.exports = function()
{
  jQuery('.trackCustomerLogin').each(function (idx) {
    this.$btn = jQuery(this);
    callToActionHtml = $btn.html()

    this.$btn.mouseover(function (emover) {
      $(this).html("Sign in with Google for Video Chat");
      jQuery('<figure>We use your google account for G+ Hangouts</figure>').insertAfter($(this))
    }).mouseout(function (emout) {
      $(this).html(callToActionHtml);
      $(this).next('figure').remove()
    })
  });
}
