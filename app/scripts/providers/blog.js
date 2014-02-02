module.exports = function()
{
  jQuery('.trackCustomerLogin').each(function (idx) {
    this.$btn = jQuery(this);
    this.$btn.callToActionHtml = this.$btn.html()

    this.$btn.mouseover(function (emover) {
      btn = jQuery(this)
      btn.html("Sign in with Google for Video Chat");
      jQuery('<figure>We use your google account for G+ Hangouts <img src="//airpair-blog.s3.amazonaws.com/wp-content/uploads/2014/01/Node.js-Pair-Programming-Help-On-AirPair-300x176.png"></figure>').insertAfter(btn)
    }).mouseout(function (emout) {
      btn = jQuery(this)
      btn.html(btn.callToActionHtml);
      btn.next('figure').remove()
    })
  });
}
