module.exports = () ->
  jQuery('.trackCustomerLogin, .trackBookLogin').each (idx) ->
    this.$btn = jQuery(this)
    this.$btn.mouseover((emover) ->
      btn = jQuery(this)
      jQuery(this).data('act', btn.html())
      btn.html("Sign in with Google for Video Chat")
      jQuery('<figure class="gSignin"><p>We use your google account for G+ Hangouts</p><img src="//airpair-blog.s3.amazonaws.com/wp-content/uploads/2014/01/Node.js-Pair-Programming-Help-On-AirPair-300x176.png"></figure>').insertAfter(btn)
    ).mouseout((emout) ->
      btn = jQuery(this)
      btn.html(jQuery(this).data('act'))
      btn.next('figure').remove()
    )
