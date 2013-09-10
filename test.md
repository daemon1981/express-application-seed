# TOC
   - [user](#user)
     - [#signup()](#user-signup)
     - [#accountValidator()](#user-accountvalidator)
     - [#isValidUserPassword()](#user-isvaliduserpassword)
       - [user not validated](#user-isvaliduserpassword-user-not-validated)
         - [when password is correct](#user-isvaliduserpassword-user-not-validated-when-password-is-correct)
       - [user validated](#user-isvaliduserpassword-user-validated)
         - [when password is correct](#user-isvaliduserpassword-user-validated-when-password-is-correct)
         - [when password is not correct](#user-isvaliduserpassword-user-validated-when-password-is-not-correct)
     - [#requestResetPassword()](#user-requestresetpassword)
     - [#findOrCreateFaceBookUser()](#user-findorcreatefacebookuser)
       - [when not existing](#user-findorcreatefacebookuser-when-not-existing)
       - [when existing](#user-findorcreatefacebookuser-when-existing)
   - [mailer](#mailer)
     - [#sendSignupConfirmation()](#mailer-sendsignupconfirmation)
     - [#sendAccountValidatedConfirmation()](#mailer-sendaccountvalidatedconfirmation)
     - [#sendForgotPassword()](#mailer-sendforgotpassword)
     - [#sendPasswordReseted()](#mailer-sendpasswordreseted)
     - [#sendContactConfirmation()](#mailer-sendcontactconfirmation)
   - [image](#image)
     - [#validate()](#image-validate)
     - [#createUserDir()](#image-createuserdir)
     - [#saveUserPicture()](#image-saveuserpicture)
   - [** locale **](#-locale-)
     - [by default inspect Accept-Language in http header](#-locale--by-default-inspect-accept-language-in-http-header)
       - [when signing up (using req.locale)](#-locale--by-default-inspect-accept-language-in-http-header-when-signing-up-using-reqlocale)
     - [next priority goes to req.user.language](#-locale--next-priority-goes-to-requserlanguage)
       - [when going to homepage with user connected (language = "fr")](#-locale--next-priority-goes-to-requserlanguage-when-going-to-homepage-with-user-connected-language--fr)
     - [next priority goes to query ?lang=](#-locale--next-priority-goes-to-query-lang)
       - [when ?lang=fr](#-locale--next-priority-goes-to-query-lang-when-langfr)
   - [** /login **](#-login-)
     - [** Logged in **](#-login---logged-in-)
       - [GET](#-login---logged-in--get)
     - [** Logged out **](#-login---logged-out-)
       - [GET](#-login---logged-out--get)
       - [POST](#-login---logged-out--post)
         - [User is validated](#-login---logged-out--post-user-is-validated)
         - [User is not validated](#-login---logged-out--post-user-is-not-validated)
   - [** profile **](#-profile-)
     - [** /profile **](#-profile---profile-)
       - [** Logged in **](#-profile---profile---logged-in-)
         - [GET](#-profile---profile---logged-in--get)
         - [POST](#-profile---profile---logged-in--post)
       - [** Logged out **](#-profile---profile---logged-out-)
         - [GET](#-profile---profile---logged-out--get)
     - [** /forgot/password **](#-profile---forgotpassword-)
       - [** Logged in **](#-profile---forgotpassword---logged-in-)
         - [GET](#-profile---forgotpassword---logged-in--get)
         - [POST](#-profile---forgotpassword---logged-in--post)
       - [** Logged out **](#-profile---forgotpassword---logged-out-)
         - [GET](#-profile---forgotpassword---logged-out--get)
         - [POST](#-profile---forgotpassword---logged-out--post)
     - [** /reset/password **](#-profile---resetpassword-)
       - [** Logged in **](#-profile---resetpassword---logged-in-)
         - [GET](#-profile---resetpassword---logged-in--get)
         - [POST](#-profile---resetpassword---logged-in--post)
       - [** Logged out **](#-profile---resetpassword---logged-out-)
         - [GET](#-profile---resetpassword---logged-out--get)
         - [POST](#-profile---resetpassword---logged-out--post)
   - [** signing up **](#-signing-up-)
     - [** /signup **](#-signing-up---signup-)
       - [** Logged in **](#-signing-up---signup---logged-in-)
         - [GET](#-signing-up---signup---logged-in--get)
       - [** Logged out **](#-signing-up---signup---logged-out-)
         - [GET](#-signing-up---signup---logged-out--get)
         - [POST](#-signing-up---signup---logged-out--post)
           - [User not already registered](#-signing-up---signup---logged-out--post-user-not-already-registered)
           - [User already registered](#-signing-up---signup---logged-out--post-user-already-registered)
     - [** /signupConfirmation **](#-signing-up---signupconfirmation-)
       - [** Logged in **](#-signing-up---signupconfirmation---logged-in-)
         - [GET](#-signing-up---signupconfirmation---logged-in--get)
       - [** Logged out **](#-signing-up---signupconfirmation---logged-out-)
         - [GET](#-signing-up---signupconfirmation---logged-out--get)
     - [** /signupValidation **](#-signing-up---signupvalidation-)
       - [** Logged in **](#-signing-up---signupvalidation---logged-in-)
         - [GET](#-signing-up---signupvalidation---logged-in--get)
       - [** Logged out **](#-signing-up---signupvalidation---logged-out-)
         - [GET](#-signing-up---signupvalidation---logged-out--get)
     - [** /signup/validation **](#-signing-up---signupvalidation-)
       - [** Logged in **](#-signing-up---signupvalidation---logged-in-)
         - [GET](#-signing-up---signupvalidation---logged-in--get)
       - [** Logged out **](#-signing-up---signupvalidation---logged-out-)
         - [GET](#-signing-up---signupvalidation---logged-out--get)
<a name=""></a>

<a name="user"></a>
# user
<a name="user-signup"></a>
## #signup()
should create a user and set validated to false.

```js
var email;
email = 'toto@toto.com';
return User.signup(email, 'passwd', 'fr', function(err) {
  should.not.exist(err);
  return User.find({}, function(err, users) {
    users.length.should.equal(1);
    users[0].email.should.equal(email);
    should.exist(users[0].salt);
    should.exist(users[0].passwordHash);
    users[0].validated.should.equal(false);
    should.exist(users[0].validationKey);
    return done();
  });
});
```

should not be possible to create a user with the same email.

```js
var email;
email = 'toto@toto.com';
return User.signup(email, 'passwd', 'fr', function(err) {
  return User.signup(email, 'other-passwd', 'fr', function(err) {
    should.exist(err);
    return done();
  });
});
```

<a name="user-accountvalidator"></a>
## #accountValidator()
should valid account.

```js
var email, userTest;
email = 'toto@toto.com';
userTest = {};
return async.series([
  function(callback) {
    return User.signup(email, 'passwd', 'fr', function(err, user) {
      userTest = user;
      return callback();
    });
  }, function(callback) {
    return User.accountValidator(userTest.validationKey, callback);
  }, function(callback) {
    return User.findOne({
      email: email
    }, function(err, user) {
      user.validated.should.equal(true);
      should.not.exist(user.validationKey);
      return done();
    });
  }
], done);
```

should fails if validationKey doesn't exist.

```js
return User.accountValidator('key-not-exists', function(err, user) {
  should.exist(err);
  return done();
});
```

<a name="user-isvaliduserpassword"></a>
## #isValidUserPassword()
<a name="user-isvaliduserpassword-user-not-validated"></a>
### user not validated
<a name="user-isvaliduserpassword-user-not-validated-when-password-is-correct"></a>
#### when password is correct
should not valid user password.

```js
return User.isValidUserPassword(email, passwd, function(err, data, msg) {
  should.not.exist(err);
  should.exist(msg);
  assert.equal(false, data);
  assert.deepEqual(msg, {
    message: 'Account not validated.'
  });
  return done();
});
```

<a name="user-isvaliduserpassword-user-validated"></a>
### user validated
<a name="user-isvaliduserpassword-user-validated-when-password-is-correct"></a>
#### when password is correct
should valid user password.

```js
return User.isValidUserPassword(email, passwd, function(err, data, msg) {
  should.not.exist(err);
  should.not.exist(msg);
  assert.equal(user.email, data.email);
  return done();
});
```

<a name="user-isvaliduserpassword-user-validated-when-password-is-not-correct"></a>
#### when password is not correct
should not valid user password.

```js
return User.isValidUserPassword(email, 'badpasswd', function(err, data, msg) {
  should.not.exist(err);
  should.exist(msg);
  assert.equal(false, data);
  assert.deepEqual(msg, {
    message: 'Incorrect password.'
  });
  return done();
});
```

<a name="user-requestresetpassword"></a>
## #requestResetPassword()
should set required fields for forgot password process.

```js
return user.requestResetPassword(function(err, modifedUser) {
  should.not.exist(err);
  should.exist(modifedUser.regeneratePasswordKey);
  should.exist(modifedUser.regeneratePasswordDate);
  return done();
});
```

<a name="user-findorcreatefacebookuser"></a>
## #findOrCreateFaceBookUser()
<a name="user-findorcreatefacebookuser-when-not-existing"></a>
### when not existing
should create facebook user.

```js
return User.findOrCreateFaceBookUser(profile, function(err, user) {
  should.not.exist(err);
  return User.find({}, function(err, users) {
    users.length.should.equal(1);
    users[0].email.should.equal(email);
    users[0].validated.should.equal(true);
    return done();
  });
});
```

<a name="user-findorcreatefacebookuser-when-existing"></a>
### when existing
should retrieve facebook user.

```js
return User.findOrCreateFaceBookUser(profile, function(err, user) {
  var userId;
  should.not.exist(err);
  userId = user._id;
  return User.findOrCreateFaceBookUser(profile, function(err, user) {
    should.not.exist(err);
    assert.deepEqual(userId, user._id);
    return User.find({}, function(err, users) {
      users.length.should.equal(1);
      users[0].email.should.equal(email);
      return done();
    });
  });
});
```

<a name="mailer"></a>
# mailer
<a name="mailer-sendsignupconfirmation"></a>
## #sendSignupConfirmation()
should call sendMail.

```js
return mailer.sendSignupConfirmation('en', 'toto@toto.com', 'http://dummy-url.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-sendaccountvalidatedconfirmation"></a>
## #sendAccountValidatedConfirmation()
should call sendMail.

```js
return mailer.sendAccountValidatedConfirmation('en', 'toto@toto.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-sendforgotpassword"></a>
## #sendForgotPassword()
should call sendMail.

```js
return mailer.sendForgotPassword('en', 'toto@toto.com', 'http://dummy-url.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-sendpasswordreseted"></a>
## #sendPasswordReseted()
should call sendMail.

```js
return mailer.sendPasswordReseted('en', 'toto@toto.com', 'http://dummy-url.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-sendcontactconfirmation"></a>
## #sendContactConfirmation()
should call sendMail.

```js
return mailer.sendContactConfirmation('en', 'toto@toto.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="image"></a>
# image
<a name="image-validate"></a>
## #validate()
should validate when file is correct.

```js
return image.validate({
  size: 30,
  name: 'dummy.jpg'
}, function(err) {
  should.not.exists(err);
  return done();
});
```

should fails when file too small.

```js
return image.validate({
  size: 0,
  name: 'dummy.jpg'
}, function(err) {
  should.exists(err);
  assert.equal('File is too small', err.message);
  return done();
});
```

should fails when file too big.

```js
return image.validate({
  size: 20000000,
  name: 'dummy.jpg'
}, function(err) {
  should.exists(err);
  assert.equal('File is too big', err.message);
  return done();
});
```

should validate when file name is not allowed.

```js
return image.validate({
  size: 30,
  name: 'dummy'
}, function(err) {
  should.exists(err);
  assert.equal('Filetype not allowed', err.message);
  return done();
});
```

<a name="image-createuserdir"></a>
## #createUserDir()
should create user directories.

```js
return image.createUserDir(userTest, testDir, function(err) {
  should.not.exists(err);
  return fs.exists(testDir + '/user/' + userTest._id + '/picture/thumbnail', function(exists) {
    assert.ok(exists);
    return done();
  });
});
```

<a name="image-saveuserpicture"></a>
## #saveUserPicture()
should save image in user directories.

```js
var file;
file = {
  size: 30,
  name: fileName,
  path: filePath,
  type: 'image/jpeg'
};
return image.saveUserPicture(userTest, file, function(err, pictureInfo) {
  var checkExists, expectedPictureInfo;
  should.not.exists(err);
  expectedPictureInfo = {
    name: file.name,
    size: file.size,
    thumbnailUrl: 'user/' + userTest._id + '/picture/thumbnail/homer.jpg',
    type: file.type,
    url: 'user/' + userTest._id + '/picture/thumbnail/homer.jpg'
  };
  assert.deepEqual(expectedPictureInfo, pictureInfo);
  checkExists = function(file, next) {
    return fs.exists(file, function(exists) {
      assert.ok(exists, file + ' doesn\'t exist');
      return next();
    });
  };
  return async.eachSeries([testDir + '/user/' + userTest._id + '/picture/thumbnail', testDir + '/user/' + userTest._id + '/picture/thumbnail/homer.jpg'], checkExists, function(err) {
    should.not.exists(err);
    return User.findOne({
      email: userEmail
    }, function(err, user) {
      should.not.exists(err);
      assert.equal(fileName, user.picture);
      return done();
    });
  });
});
```

<a name="-locale-"></a>
# ** locale **
<a name="-locale--by-default-inspect-accept-language-in-http-header"></a>
## by default inspect Accept-Language in http header
<a name="-locale--by-default-inspect-accept-language-in-http-header-when-signing-up-using-reqlocale"></a>
### when signing up (using req.locale)
with Accept-Language fr-FR should register language "fr" to user.

```js
return requestTest.post('/signup').set('Accept-Language', 'fr-FR,fr;q=0.8,en-US;q=0.6,en;q=0.4').send({
  email: email,
  password: 'password'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  return User.findOne({
    email: email
  }, function(err, user) {
    should.exist(user);
    user.language.should.equal = 'fr';
    return done();
  });
});
```

with Accept-Language fr should register language "fr" to user.

```js
return requestTest.post('/signup').set('Accept-Language', 'fr;q=0.8,en-US;q=0.6,en;q=0.4').send({
  email: email,
  password: 'password'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  return User.findOne({
    email: email
  }, function(err, user) {
    should.exist(user);
    user.language.should.equal = 'fr';
    return done();
  });
});
```

with Accept-Language en-US should register language "en" to user.

```js
return requestTest.post('/signup').set('Accept-Language', 'en-US;q=0.6,en;q=0.4').send({
  email: email,
  password: 'password'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  return User.findOne({
    email: email
  }, function(err, user) {
    should.exist(user);
    user.language.should.equal = 'en';
    return done();
  });
});
```

with Accept-Language en should register language "en" to user.

```js
return requestTest.post('/signup').set('Accept-Language', 'en;q=0.6,en;q=0.4').send({
  email: email,
  password: 'password'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  return User.findOne({
    email: email
  }, function(err, user) {
    should.exist(user);
    user.language.should.equal = 'en';
    return done();
  });
});
```

<a name="-locale--next-priority-goes-to-requserlanguage"></a>
## next priority goes to req.user.language
<a name="-locale--next-priority-goes-to-requserlanguage-when-going-to-homepage-with-user-connected-language--fr"></a>
### when going to homepage with user connected (language = "fr")
with Accept-Language en-US should display in french.

```js
return requestConnected.get('/').set('Accept-Language', 'en;q=0.6,en;q=0.4').expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  assert.equal('Profil', $body.find('a[href="/profile"]:eq(0)').text());
  return done();
});
```

<a name="-locale--next-priority-goes-to-query-lang"></a>
## next priority goes to query ?lang=
<a name="-locale--next-priority-goes-to-query-lang-when-langfr"></a>
### when ?lang=fr
with Accept-Language en-US and connected user language "en" should display in french.

```js
return requestConnected.get('/?lang=fr').set('Accept-Language', 'en;q=0.6,en;q=0.4').expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  assert.equal('Profil', $body.find('a[href="/profile"]:eq(0)').text());
  return done();
});
```

<a name="-login-"></a>
# ** /login **
<a name="-login---logged-in-"></a>
## ** Logged in **
<a name="-login---logged-in--get"></a>
### GET
should redirect to /profile.

```js
return requestTest.get('/login').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header.location.should.equal('/profile');
  return done();
});
```

<a name="-login---logged-out-"></a>
## ** Logged out **
<a name="-login---logged-out--get"></a>
### GET
should return 200.

```js
return request(new App()).get('/login').expect(200).end(function(err, res) {
  should.not.exist(err);
  return done();
});
```

<a name="-login---logged-out--post"></a>
### POST
<a name="-login---logged-out--post-user-is-validated"></a>
#### User is validated
should redirect to /profile when authentication is successfull.

```js
return request(new App()).post('/login').send({
  email: userData.email,
  password: 'plop'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

should redirect to /login when authentication is wrong.

```js
return request(new App()).post('/login').send({
  email: userData.email,
  password: 'badpassword'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/login');
  return done();
});
```

<a name="-login---logged-out--post-user-is-not-validated"></a>
#### User is not validated
should redirect to /login even if password is correct.

```js
return request(new App()).post('/login').send({
  email: userData.email,
  password: 'plip'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/login');
  return done();
});
```

<a name="-profile-"></a>
# ** profile **
<a name="-profile---profile-"></a>
## ** /profile **
<a name="-profile---profile---logged-in-"></a>
### ** Logged in **
<a name="-profile---profile---logged-in--get"></a>
#### GET
should return 200.

```js
return connectedRequest.get('/profile').expect(200).end(function(err, res) {
  should.not.exist(err);
  return done();
});
```

<a name="-profile---profile---logged-in--post"></a>
#### POST
should not delete already saved params.

```js
var newFirstName;
newFirstName = 'Titi';
return connectedRequest.post('/profile').send({
  firstName: newFirstName
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return User.findOne({
    firstName: newFirstName
  }, function(err, modifiedUser) {
    should.not.exist(err);
    assert.equal(fakeUser.lastName, modifiedUser.lastName);
    return done();
  });
});
```

<a name="-profile---profile---logged-out-"></a>
### ** Logged out **
<a name="-profile---profile---logged-out--get"></a>
#### GET
should redirect to /login.

```js
return request(new App()).get('/profile').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/login');
  return done();
});
```

<a name="-profile---forgotpassword-"></a>
## ** /forgot/password **
<a name="-profile---forgotpassword---logged-in-"></a>
### ** Logged in **
<a name="-profile---forgotpassword---logged-in--get"></a>
#### GET
should redirect to /profile.

```js
return connectedRequest.get('/forgot/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="-profile---forgotpassword---logged-in--post"></a>
#### POST
should redirect to /profile.

```js
return connectedRequest.post('/forgot/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="-profile---forgotpassword---logged-out-"></a>
### ** Logged out **
<a name="-profile---forgotpassword---logged-out--get"></a>
#### GET
should return 200.

```js
return request(new App()).get('/forgot/password').expect(200).end(done);
```

<a name="-profile---forgotpassword---logged-out--post"></a>
#### POST
should return 200 with warning "×Email was not found" if email not found.

```js
return request(new App()).post('/forgot/password').send({
  email: 'not@known.email'
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  $body.find('.alert.alert-warning').text().should.equal('×Email was not found');
  return done();
});
```

should redirect to / if email is found.

```js
return request(new App()).post('/forgot/password').send({
  email: fixturesData.testUser.User.fakeUser.email
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

<a name="-profile---resetpassword-"></a>
## ** /reset/password **
<a name="-profile---resetpassword---logged-in-"></a>
### ** Logged in **
<a name="-profile---resetpassword---logged-in--get"></a>
#### GET
should redirect to /profile.

```js
return connectedRequest.get('/reset/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="-profile---resetpassword---logged-in--post"></a>
#### POST
should redirect to /profile.

```js
return connectedRequest.post('/reset/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="-profile---resetpassword---logged-out-"></a>
### ** Logged out **
<a name="-profile---resetpassword---logged-out--get"></a>
#### GET
should redirect to homepage if not key in query.

```js
return request(new App()).get('/reset/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should redirect to homepage if key in query but no value.

```js
return request(new App()).get('/reset/password?key=').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should redirect to homepage if regeneratePasswordKey is not found.

```js
return request(new App()).get('/reset/password?key=not-found-regenerate-password-key').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should redirect to homepage if regeneratePasswordKey is found but account is not validated.

```js
var url;
url = '/reset/password?key=' + fixturesData.testUser.User.fakeUserNotValidated.regeneratePasswordKey;
return request(new App()).get(url).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should return 200 if regeneratePasswordKey is found and account is validated.

```js
var url;
url = '/reset/password?key=' + fixturesData.testUser.User.fakeUser.regeneratePasswordKey;
return request(new App()).get(url).expect(200).end(done);
```

<a name="-profile---resetpassword---logged-out--post"></a>
#### POST
should redirect to homepage if regeneratePasswordKey is not found.

```js
return request(new App()).post('/reset/password').send({
  regeneratePasswordKey: 'not-found-regenerate-password-key'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should redirect to homepage if regeneratePasswordKey is found but account is not validated.

```js
return request(new App()).post('/reset/password').send({
  regeneratePasswordKey: fixturesData.testUser.User.fakeUserNotValidated.regeneratePasswordKey
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should return 200 with error "×You must provide a password" if password not defined.

```js
return request(new App()).post('/reset/password').send({
  regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  $body.find('.alert.alert-danger').text().should.equal('×You must provide a password');
  return done();
});
```

should return 200 with error "×You must provide a password" if password empty string.

```js
return request(new App()).post('/reset/password').send({
  regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey,
  password: ''
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  $body.find('.alert.alert-danger').text().should.equal('×You must provide a password');
  return done();
});
```

should return 200 with error "×You must provide a password more complicated" if password too simple.

```js
return request(new App()).post('/reset/password').send({
  regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey,
  password: 'yo'
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  $body.find('.alert.alert-danger').text().should.equal('×You must provide a password more complicated');
  return done();
});
```

should redirect to /login if email is found and password enough complex.

```js
return request(new App()).post('/reset/password').send({
  regeneratePasswordKey: fixturesData.testUser.User.fakeUser.regeneratePasswordKey,
  password: 'enough complex'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/login');
  return done();
});
```

<a name="-signing-up-"></a>
# ** signing up **
<a name="-signing-up---signup-"></a>
## ** /signup **
<a name="-signing-up---signup---logged-in-"></a>
### ** Logged in **
<a name="-signing-up---signup---logged-in--get"></a>
#### GET
should redirect to /profile.

```js
return connectedRequest.get('/signup').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header.location.should.equal('/profile');
  return done();
});
```

<a name="-signing-up---signup---logged-out-"></a>
### ** Logged out **
<a name="-signing-up---signup---logged-out--get"></a>
#### GET
should return 200.

```js
return request(new App()).get('/signup').expect(200).end(done);
```

<a name="-signing-up---signup---logged-out--post"></a>
#### POST
<a name="-signing-up---signup---logged-out--post-user-not-already-registered"></a>
##### User not already registered
should redirect to /signupConfirmation when signup is successfull.

```js
return request(new App()).post('/signup').send({
  email: 'new@email.com',
  password: 'password'
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/signupConfirmation');
  return done();
});
```

should render /signup with error "×Form has errors" if email is missing.

```js
return request(new App()).post('/signup').send({
  password: 'password'
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  $body.find('.alert.alert-danger').text().should.equal('×Form has errors');
  return done();
});
```

<a name="-signing-up---signup---logged-out--post-user-already-registered"></a>
##### User already registered
should render /signup with error "×Email already exists.".

```js
return request(new App()).post('/signup').send({
  email: userData.email,
  password: 'password'
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  $body.find('.alert.alert-danger').text().should.equal('×Email already exists.');
  return done();
});
```

<a name="-signing-up---signupconfirmation-"></a>
## ** /signupConfirmation **
<a name="-signing-up---signupconfirmation---logged-in-"></a>
### ** Logged in **
<a name="-signing-up---signupconfirmation---logged-in--get"></a>
#### GET
should return 200.

```js
return connectedRequest.get('/signupConfirmation').expect(200).end(done);
```

<a name="-signing-up---signupconfirmation---logged-out-"></a>
### ** Logged out **
<a name="-signing-up---signupconfirmation---logged-out--get"></a>
#### GET
should return 200.

```js
return request(new App()).get('/signupConfirmation').expect(200).end(done);
```

<a name="-signing-up---signupvalidation-"></a>
## ** /signupValidation **
<a name="-signing-up---signupvalidation---logged-in-"></a>
### ** Logged in **
<a name="-signing-up---signupvalidation---logged-in--get"></a>
#### GET
should return 200.

```js
return connectedRequest.get('/signupValidation').expect(200).end(done);
```

<a name="-signing-up---signupvalidation---logged-out-"></a>
### ** Logged out **
<a name="-signing-up---signupvalidation---logged-out--get"></a>
#### GET
should return 200.

```js
return request(new App()).get('/signupValidation').expect(200).end(done);
```

<a name="-signing-up---signupvalidation-"></a>
## ** /signup/validation **
<a name="-signing-up---signupvalidation---logged-in-"></a>
### ** Logged in **
<a name="-signing-up---signupvalidation---logged-in--get"></a>
#### GET
should return 200.

```js
return connectedRequest.get('/signup/validation').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="-signing-up---signupvalidation---logged-out-"></a>
### ** Logged out **
<a name="-signing-up---signupvalidation---logged-out--get"></a>
#### GET
should redirect to homepage if no user has this key.

```js
var url;
url = '/signup/validation?key=not-existing-key';
return request(new App()).get(url).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

should redirect to /signupValidation if key is correct.

```js
var url;
url = '/signup/validation?key=' + fixturesData.testUser.User.fakeUserNotValidated.validationKey;
return request(new App()).get(url).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/signupValidation');
  return done();
});
```
