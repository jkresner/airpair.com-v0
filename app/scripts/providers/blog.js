module.exports = function()
{
  jQuery('.trackCustomerLogin').each(function (idx) {
    this.$btn = jQuery(this);
    console.log(idx, this.$btn);
    callToActionHtml = this.$btn.html()

    this.$btn.mouseover(function (emover) {
      jQuery(this).html("Sign in with Google for Video Chat");
      jQuery('<figure>We use your google account for G+ Hangouts</figure>').insertAfter(jQuery(this))
    }).mouseout(function (emout) {
      jQuery(this).html(callToActionHtml);
      jQuery(this).next('figure').remove()
    })
  });
}
