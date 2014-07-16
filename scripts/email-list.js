//
// to generate a .csv file for MailChimp import:
//
//	mongo -quiet airpair_dev email-list.js > email-list.csv
// 

print ("First Name, Last Name, email address, isFormerCustomer, isRepeatCustomer, Revenue, isExpert, isCustomer, isFromMongo, Company");

cursor = db.users.find();

var cust = 0;
var repeat = 0;

cursor.forEach(function (el) {
	if (!el.google) {
		return;
	}

	var firstName = el.google._json.given_name;
	var lastName = el.google._json.family_name;
	var email = el.google.emails[0].value;

	var isFormerCustomer = 'N';
	var isRepeatCustomer = 'N';
	var allOrders = db.orders.find({'userId' : el._id}).toArray();
	var revenue = 0;

	if (allOrders.length > 0) {
		isFormerCustomer = 'Y';
		cust++;

		for (var i = 0; i < allOrders.length; i++) {
			revenue += allOrders[i].total;
		}

		if (allOrders.length > 1) {
			isRepeatCustomer = 'Y';
			repeat++;
		}
	}

	var isExpert = 'N';
	if (db.experts.find({'gmail' : email}).length() >= 1) {
		isExpert = 'Y';
	}

	var isCustomer = 'N';
	var company = '';
	var co = db.companies.find({'contacts.userId' : el._id}).toArray()[0];
	if (co) {
		isCustomer = 'Y';
		company = co.name;	
	}


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
