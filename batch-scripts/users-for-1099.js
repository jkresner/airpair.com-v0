//
// 
//

var year = 2013;
var cutoffFor1099 = 600;

var payments = {};


cursor = db.orders.find({'paymentStatus' : 'paidout'});

cursor.forEach(function (order) {

	order.lineItems.forEach(function (lineItem) {

		if (lineItem._id.getTimestamp().getYear() + 1900 !== year) {
			print ("WRONG YEAR! " + lineItem._id.getTimestamp().getYear())
			return;
		}

		var expert = lineItem.suggestion.expert;
		var email = expert.email;
		var expertPay = lineItem.suggestion.suggestedRate[lineItem.type].expert;

		if (!payments[email]) {
			payments[email] = {
				'name' : expert.name,
				'total' : expertPay
			}
		} else {
			payments[email].total += expertPay;
		}

		// print (expert.name + " " + expert.email + " " + expertPay);
	});
});

for (var email in payments) {
	if (payments[email].total < cutoffFor1099) {
		continue;
	}

	print (email + "\t" + payments[email].name + "\t" + payments[email].total);
};


