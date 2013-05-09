module.exports = [

  # 0 - Admin USER: used for session user in most test
  {
    "_id": "51708da81dd90b04cddccc9e",
    "google": {
      "_json": {
        "hd": "airpair.com",
        "locale": "en",
        "birthday": "0000-02-05",
        "gender": "male",
        "picture": "https://lh3.googleusercontent.com/-NKYL9eK5Gis/AAAAAAAAAAI/AAAAAAAAABY/291KLuvT0iI/photo.jpg",
        "link": "https://plus.google.com/117132380360243205600",
        "family_name": "Kresner",
        "given_name": "Airpair",
        "name": "Airpair Kresner",
        "verified_email": true,
        "email": "jk@airpair.com",
        "id": "117132380360243205600"
      },
      "emails": [ { "value": "jk@airpair.com" }
      ],
      "name": { "givenName": "Airpair", "familyName": "Kresner" },
      "displayName": "Airpair Kresner", "id": "117132380360243205600",
      "provider": "google"
    },
    "googleId": "117132380360243205600"
  }

  # 1 - Non Admin user
  {
    "_id": "5181d1f666a6f999a465f280",
    "google": {
      "_json": {
        "hd": "airpair.com",
        "locale": "en",
        "birthday": "0000-02-05",
        "gender": "male",
        "picture": "https://lh3.googleusercontent.com/-NKYL9eK5Gis/AAAAAAAAAAI/AAAAAAAAABY/291KLuvT0iI/photo.jpg",
        "link": "https://plus.google.com/127132380360243205611",
        "family_name": "Kresner",
        "given_name": "Jonathon",
        "name": "Jonathon Kresner",
        "verified_email": true,
        "email": "jkresner@gmail.com",
        "id": "127132380360243205611"
      },
      "emails": [ { "value": "jkresner@gmail.com" }
      ],
      "name": { "givenName": "Jonathon", "familyName": "Kresner" },
      "displayName": "Jonathon Kresner", "id": "127132380360243205611",
      "provider": "google"
    },
    "googleId": "127132380360243205611"
  }

  # 2 - used in test 2 of server/api/users.coffee
  {
    "_id": "516ac6941dd90b04cddccc5d",
    "google": {
      "id": "https://www.google.com/accounts/o8/id?id=AItOawl34O5Xvp9G3OS3h1oEohhTE9xcq2oTdQk",
      "name": {
        "givenName": "Jonathon",
        "familyName": "Kresner"
      },
      "emails": [
        {
          "value": "jk@airpair.co"
        }
      ],
      "displayName": "Jonathon Kresner"
    },
    "googleId": "https://www.google.com/accounts/o8/id?id=AItOawl34O5Xvp9G3OS3h1oEohhTE9xcq2oTdQk"
  }
]