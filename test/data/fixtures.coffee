module.exports =

  request:   "<div id='welcome' class='route'></div>
              <div id='info' class='route'></div>
              <div id='request' class='route'><div id='requestForm'></div></div>"

  beexpert:  "<div id='welcome' class='route'>welcome</div>
              <div id='connect' class='route'><div id='connectForm'></div></div>
              <div id='info' class='route'><div id='infoForm'></div></div>"

  inbound:   "<div id='list' class='route'><div id='requests'></div></div>
              <div id='request' class='route'></div>"

  review:    "<div id='detail' class='route'><div id='request'></div></div>
              <div id='book' class='route'></div>"

  dashboard: "<div id='requests' class='route'><div id='requestslist'></div></div>"

  feedback:  "<div id='feedback' class='route'></div>"

  tags:      "<div id='list' class='route'></div>"

  settings:  "<div id='payment' class='route'>
                <div id='paypalSettings'></div>
                <div id='stripeSettings'></div>
              </div>
              <div id='stripe' class='route'>
                <div id='stripeRegister'></div>
              </div>"
  orders:   "<div id='list' class='route'>
              <table id='orders' class='table table-striped'>
                <thead>
                  <tr id='rowsSummary'></tr>
                </thead>
                <tbody></tbody>
              </table>3
            </div>"
  callSchedule: "<div id='schedule' class='route'>
                  <div id='scheduleForm'></div>
                </div>"
  callEdit: "<div id='edit' class='route'>
                <div id='callEdit'></div>
                <div id='videos'></div>

                <div class='form-actions'>
                  <button class='save button'>Save</button>
                </div>
            </div>"
