require '../bootstrap'

ObjectId  = require('mongoose').Types.ObjectId;

require "../model/user"

#################################
# users

users =
  fakeUser:
    _id:        new ObjectId()
    firstName: 'Toto'
    lastName:  'Dupont'
    email:     'toto@toto.com'
    language:  'fr'

module.exports =
  testUser:
    User: fakeUser: users.fakeUser
