//
// mongo -quiet airpair_dev users-for-1099.js
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
		var expertPay = lineItem.suggestion.suggestedRate[lineItem.type].expert * lineItem.qty;

		if (!payments[email]) {
			payments[email] = {
				'name' : expert.name,
				'total' : expertPay
			}
		} else {
			payments[email].total += expertPay;
		}

			print ("XXX " + expert.name + " " + expert.email + " " + expertPay);
	});
});

process_manual_payments (payments);

for (var email in payments) {
	if (payments[email].total < cutoffFor1099) {
		continue;
	}

	print (email + "\t" + payments[email].name + "\t" + payments[email].total);
};






function process_manual_payments (payments) {

	//
	// this was used to generate manual_2013 after downloading csv from paypal:
	//    cat ~/Downloads/paypal.csv | grep 'Payment Sent' | grep -v '//airpair.com/review' | awk -F, '{print "{ \"name\" : " $4 ", \"email\" : " $12 ", \"amount\" : " substr($7, 3, length($7)-6) ", \"date\" : " $1 " }"}'
	//

	var manual_2013 = [
{ "name" : "DANIEL TYLENDA EMMONS", "email" : "SINGLETON.INSTANCE@YAHOO.COM", "amount" : 110, "date" : "12/10/2013" },
{ "name" : "evanrse@gmail.com", "email" : "evanrse@gmail.com", "amount" : 70, "date" : "12/9/2013" },
{ "name" : "Luke Ruebbelke", "email" : "lukas@venturplex.com", "amount" : 300, "date" : "12/8/2013" },
{ "name" : "Euclidity SL", "email" : "paypal@euclidity.com", "amount" : 420, "date" : "12/6/2013" },
{ "name" : "Felienne Hermans", "email" : "felienne@gmail.com", "amount" : 80, "date" : "12/5/2013" },
{ "name" : "Cloud Spark pty ltd", "email" : "paypal@cloudspark.com.au", "amount" : 280, "date" : "11/18/2013" },
{ "name" : "Dhananjay D Godse", "email" : "jgodse@gmail.com", "amount" : 17, "date" : "10/31/2013" },
{ "name" : "Evan Richards", "email" : "evan.rse@gmail.com", "amount" : 70, "date" : "10/20/2013" },
{ "name" : "Michael Grassotti", "email" : "mike@redroverhq.com", "amount" : 40, "date" : "10/18/2013" },
{ "name" : "Laurent ROGER", "email" : "rogerl@wanadoo.fr", "amount" : 170, "date" : "10/15/2013" },
{ "name" : "Canavese Consulting", "email" : "paul@canavese.org", "amount" : 140, "date" : "10/9/2013" },
{ "name" : "Adam Bliss", "email" : "abliss@gmail.com", "amount" : 50, "date" : "10/2/2013" },
{ "name" : "Zane Prickett", "email" : "zprickett01@hotmail.com", "amount" : 10, "date" : "9/30/2013" },
{ "name" : "Michael Melanson", "email" : "michael@michaelmelanson.net", "amount" : 50, "date" : "9/26/2013" },
{ "name" : "Michael Heu", "email" : "mheu@clickbooq.com", "amount" : 50, "date" : "9/26/2013" },
{ "name" : "Jonathon Kresner", "email" : "jkresner@gmail.com", "amount" : 60, "date" : "9/26/2013" },
{ "name" : "Emile Baizel", "email" : "ebaizel@gmail.com", "amount" : 1, "date" : "9/10/2013" },
{ "name" : "Morgan Allen", "email" : "apx.mra@gmail.com", "amount" : 40, "date" : "8/28/2013" },
{ "name" : "apmra@gmail.com", "email" : "apmra@gmail.com", "amount" : 40, "date" : "8/23/2013" },
{ "name" : "Pedro Nascimento", "email" : "pnascimento@gmail.com", "amount" : 350, "date" : "8/23/2013" },
{ "name" : "Kevin Cruz", "email" : "cruzkrc@gmail.com", "amount" : 220, "date" : "8/23/2013" },
{ "name" : "Pedro Nascimento", "email" : "pnascimento@gmail.com", "amount" : 140, "date" : "8/23/2013" },
{ "name" : "Jonathan Lettvin", "email" : "jdl@alum.mit.edu", "amount" : 40, "date" : "8/22/2013" },
{ "name" : "Juan Pemberthy", "email" : "jpemberthy@gmail.com", "amount" : 140, "date" : "8/22/2013" },
{ "name" : "morgan@morglog.org", "email" : "morgan@morglog.org", "amount" : 40, "date" : "8/21/2013" },
{ "name" : "1322487 Ontario Inc", "email" : "igor@cunko.ca", "amount" : 40, "date" : "8/21/2013" },
{ "name" : "Mark Simoneau", "email" : "mark@quarternotecoda.com", "amount" : 70, "date" : "8/19/2013" },
{ "name" : "Michael Risse", "email" : "rissem@gmail.com", "amount" : 30, "date" : "8/16/2013" },
{ "name" : "Emile Baizel", "email" : "ebaizel@gmail.com", "amount" : 30, "date" : "8/16/2013" },
{ "name" : "1322487 Ontario Inc", "email" : "igor@cunko.ca", "amount" : 40, "date" : "8/15/2013" },
{ "name" : "Vladimir Orany", "email" : "vladimir.orany@gmail.com", "amount" : 40, "date" : "8/13/2013" },
{ "name" : "Emily Bergen", "email" : "emily@taskrabbit.com", "amount" : 100, "date" : "8/12/2013" },
{ "name" : "1322487 Ontario Inc", "email" : "igor@cunko.ca", "amount" : 40, "date" : "8/12/2013" },
{ "name" : "ANGELOS ALEXELIS", "email" : "angelos.alexelis@gmail.com", "amount" : 70, "date" : "8/11/2013" },
{ "name" : "Lucas Vogelsang", "email" : "l@lucasvo.com", "amount" : 70, "date" : "8/8/2013" },
{ "name" : "Semion Sidorenko", "email" : "semion@rolepoint.com", "amount" : 98, "date" : "8/6/2013" },
{ "name" : "Semion Sidorenko", "email" : "semion@rolepoint.com", "amount" : 21, "date" : "8/1/2013" },
{ "name" : "Ed Anderson", "email" : "nilbus@nilbus.com", "amount" : 70, "date" : "8/1/2013" },
{ "name" : "Ed Anderson", "email" : "nilbus@gmail.com", "amount" : 300, "date" : "7/23/2013" },
{ "name" : "Jennifer Head", "email" : "jennifer@jenniferhead.net", "amount" : 280, "date" : "7/21/2013" },
{ "name" : "Felipe Lima", "email" : "felipecsl@me.com", "amount" : 82, "date" : "7/16/2013" },
{ "name" : "Geert-Johan Riemer", "email" : "gjr19912@gmail.com", "amount" : 60, "date" : "7/15/2013" },
{ "name" : "Justin Campbell", "email" : "cmsjustin@gmail.com", "amount" : 80, "date" : "7/10/2013" },
{ "name" : "Amos King", "email" : "amos.l.king@gmail.com", "amount" : 350, "date" : "7/9/2013" },
{ "name" : "Geert-Johan Riemer", "email" : "gjr19912@gmail.com", "amount" : 80, "date" : "7/9/2013" },
{ "name" : "Max Masnick", "email" : "max@masnick.me", "amount" : 70, "date" : "7/9/2013" }
	]

	for (var i = 0; i < manual_2013.length; i++) {
		var m = manual_2013[i];
		//print ("loop " + m.name + " " + m.amount);
		if (!payments[m.email]) {
			payments[m.email] = {
				'name' : m.name,
				'total' : m.amount
			}
		} else {
			payments[m.email].total += m.amount;
			//print ("adding " + m.amount + " for " + m.name);
		}

		//print (m.name + " (" + m.email + ") now has " + m.amount);
	}
}

