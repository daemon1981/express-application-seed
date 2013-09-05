require '../bootstrap'

ObjectId  = require('mongoose').Types.ObjectId;

require "../model/user"

convertUnicodesToString = (unicodes) ->
  i = 0
  passwordHash = ''
  while i < unicodes.length
    passwordHash += String.fromCharCode unicodes[i]
    i++
  passwordHash

passwordHashTotoUnicodes = [86, 109, 174, 74, 109, 220, 92, 23, 162, 45, 233, 96, 171, 188, 129, 205, 167, 8, 180, 248, 42, 128, 151, 5, 10, 171, 28, 152, 124, 191, 25, 190, 218, 172, 145, 148, 76, 190, 98, 68, 90, 61, 175, 235, 108, 243, 154, 188, 48, 243, 166, 49, 183, 30, 54, 37, 46, 171, 0, 117, 74, 90, 36, 102, 84, 241, 210, 109, 86, 112, 156, 146, 214, 115, 68, 51, 202, 107, 114, 6, 144, 228, 210, 253, 13, 175, 172, 214, 207, 15, 197, 62, 132, 165, 30, 98, 108, 240, 222, 169, 2, 58, 82, 164, 178, 110, 150, 218, 174, 148, 126, 82, 200, 43, 53, 254, 91, 239, 37, 6, 84, 122, 239, 209, 50, 151, 250, 11]
passwordHashUnicodesTiti = [167, 241, 215, 67, 248, 153, 191, 131, 22, 165, 54, 15, 24, 115, 165, 183, 76, 55, 147, 164, 240, 156, 34, 92, 241, 179, 21, 11, 2, 211, 140, 158, 124, 255, 25, 99, 177, 131, 209, 122, 218, 239, 218, 13, 229, 248, 151, 13, 97, 84, 246, 74, 6, 141, 116, 49, 42, 184, 80, 20, 214, 239, 90, 170, 100, 156, 136, 67, 84, 63, 245, 218, 19, 230, 110, 61, 213, 113, 165, 109, 73, 228, 24, 207, 223, 158, 80, 89, 243, 99, 126, 172, 102, 78, 192, 169, 39, 234, 83, 162, 152, 225, 34, 204, 92, 8, 59, 211, 147, 222, 29, 73, 141, 166, 217, 253, 218, 115, 207, 53, 196, 35, 42, 80, 188, 154, 80, 16]
passwordHashToto = convertUnicodesToString(passwordHashTotoUnicodes)
passwordHashTiti = convertUnicodesToString(passwordHashUnicodesTiti)

#################################
# users

users =
  fakeUser:
    _id:          new ObjectId()
    firstName:    'Toto'
    lastName:     'Dupont'
    email:        'toto@toto.com'
    salt:         'toto'
    passwordHash: passwordHashToto # hash for password 'toto' and salt 'toto'
    language:     'fr'
    validated:    true
  fakeUserNotValidated:
    _id:          new ObjectId()
    firstName:    'Titi'
    lastName:     'Dupont'
    email:        'titi@titi.com'
    salt:         'titi'
    passwordHash: passwordHashTiti # hash for password 'titi' and salt 'titi'
    language:     'fr'

module.exports =
  testUser:
    User:
      fakeUser: users.fakeUser
      fakeUserNotValidated: users.fakeUserNotValidated
