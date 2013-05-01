(function(){var uv=document.createElement('script');uv.type='text/javascript';uv.async=true;uv.src='//widget.uservoice.com/mR3VvBofcDuVX51PtVfpqw.js';var s=document.getElementsByTagName('script')[0];s.parentNode.insertBefore(uv,s)})()

module.exports = function()
{
  if (document.location.hostname != "localhost")
  {
    UserVoice = window.UserVoice || [];
    UserVoice.push(['showTab', 'classic_widget', {
      mode: 'full',
      primary_color: '#cc6d00',
      link_color: '#007dbf',
      default_mode: 'support',
      forum_id: 205019,
      tab_label: 'Feedback & Support',
      tab_color: '#7f771c',
      tab_position: 'middle-left',
      tab_inverted: false
    }]);
  }
}