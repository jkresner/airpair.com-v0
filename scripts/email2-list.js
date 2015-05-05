//
// to generate a .csv file for MailChimp import:
//
//	mongo -quiet airpair_dev email2-list.js > email2-list.csv
//

print ("First Name, Last Name, email address, isFormerCustomer, isRepeatCustomer, Revenue, isExpert, isCustomer, isFromMongo, Company");

cursor = db.users.find();

var cust = 0;
var repeat = 0;

cursor.forEach(function (el) {
	if (!el.email || !el.emailVerified) {
		return;
	}

	var firstName = el.name.split(' ')[0];
	var lastName = el.name.replace(firstName+' ','');
	var email = el.email;

	var isFormerCustomer = '?';
	var isRepeatCustomer = '?';
	// var allOrders = db.orders.find({'userId' : el._id}).toArray();
	var revenue = 0;

	// if (allOrders.length > 0) {
	// 	isFormerCustomer = 'Y';
	// 	cust++;

	// 	for (var i = 0; i < allOrders.length; i++) {
	// 		revenue += allOrders[i].total;
	// 	}

	// 	if (allOrders.length > 1) {
	// 		isRepeatCustomer = 'Y';
	// 		repeat++;
	// 	}
	// }

	var isExpert = '?';
	// if (db.experts.find({'userId' : el._id}).length() >= 1) {
	// 	isExpert = 'Y';
	// }

	var isCustomer = '?';
	var company = '';
	// var co = db.companies.find({'contacts.userId' : el._id}).toArray()[0];
	// if (co) {
	// 	isCustomer = 'Y';
	// 	company = co.name;
	// }


	print (firstName + ", " +
		   lastName + ", " +
		   email + ", " +
		   isFormerCustomer + ", " +
		   isRepeatCustomer + ", " +
		   revenue + ", " +
		   isExpert + ", " +
		   isCustomer +  ", " +
		   "Y, " +
		   company
	);
});

// print ("total customers = " + cust + ", repeat customers = " + repeat);
