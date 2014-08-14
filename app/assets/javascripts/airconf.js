function validateEmail(email) {
  var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  return re.test(email);
}

function storage(k, v) {
  if (window.localStorage)
  {
    if (typeof v == 'undefined')
    {
      return localStorage[k];
    }
    localStorage[k] = v;
    return v;
  }
}

function setCalendarTimes() {
  $('.calendar').each(function (idx, time) {
    var $time = $(time);
    var timeString = $time.attr('datetime');
    var format = 'YYYYMMDDTHHmmss';
    var localTime = moment(timeString, 'ddd MMM Do YYYY HH:mmZ').format(format);
    var localTimeEnd = moment(timeString, 'ddd MMM Do YYYY HH:mmZ').add('hours', 1).format(format);
    var href = $time.attr("href");
    href = href.replace("CALSTART", localTime);
    href = href.replace("CALEND", localTimeEnd);
    $time.attr("href", href);
  });
}

function showLocalTimes() {
  $('time').each(function (idx, time) {
    $time = $(time);
    utc = $time.attr('datetime');
    offset = moment().format('ZZ')
    if (utc!='') {
      timeString = utc.split('GMT')[0]
      if ($time.attr('format')) {
        format = $time.attr('format');
      } else if ($time.hasClass('long')) {
        format = 'ddd Do MMM h:mma ZZ';
      } else {
        format = 'ddd Do MMM ha ZZ';
      }
      localTime = moment(timeString, 'ddd MMM Do YYYY HH:mmZ').format(format);
      $time.html( localTime.replace(offset,'<span>'+offset+'</span>') );
    }
    else
    {
      $time.html('Confirming time');
    }
  });
}

function fixFloatAction() {
  // Fixed #floataction subscribe on scroll
  try {
    var floataction = $('#floataction').offset().top - 20;
    $(window).scroll(function(e){
      if (window.scrollY > floataction) {
        $('#floataction').addClass('affix');
      } else {
        $('#floataction').removeClass('affix');
      }
    });
  }
  catch(e) {
    //noop
  }
}

function showSubscribe() {
  if (storage('subscribed') !== 'true')
  {
    $('.subscribe').show();

    $('.btnSubscribe').click(function(e){
      $input = $($(this).closest('.container').find('input'));
      $button = $($(this).closest('.container').find('button'));
      email = $input.val()
      if (validateEmail(email))
      {
        $input.parent().removeClass('has-error');
        $button.html('Thanks');

        $.post("/api/landing/mailchimp/subscribe", { "listId": "39f4769300", "email": email })
          .done(function(data) {
            $('.subscribe .container').html("<p>Thank you. Check your email.</p>");
            addjs.trackEvent('airconf', 'airconfSubscribe', email);
            storage('subscribed', true);
            $('.subscribe').fadeOut(1500);
          })
          .fail(function(resp, data) {
            d = JSON.parse(resp.responseText);
            console.log('args', arguments);
            $input.parent().addClass('has-error'); alert(d.error);
          });

      } else {
        $input.parent().addClass('has-error');
      }
    });
  }
}
