# TOC
   - [User](#user)
     - [When signing up 'signup()'](#user-when-signing-up-signup)
     - [When validating an account 'accountValidator()'](#user-when-validating-an-account-accountvalidator)
     - [When checking user password is valid 'isValidUserPassword()'](#user-when-checking-user-password-is-valid-isvaliduserpassword)
       - [User not validated](#user-when-checking-user-password-is-valid-isvaliduserpassword-user-not-validated)
         - [Password is correct](#user-when-checking-user-password-is-valid-isvaliduserpassword-user-not-validated-password-is-correct)
       - [User validated](#user-when-checking-user-password-is-valid-isvaliduserpassword-user-validated)
         - [Password is correct](#user-when-checking-user-password-is-valid-isvaliduserpassword-user-validated-password-is-correct)
         - [Password is not correct](#user-when-checking-user-password-is-valid-isvaliduserpassword-user-validated-password-is-not-correct)
     - [When requesting for password reset 'requestResetPassword()'](#user-when-requesting-for-password-reset-requestresetpassword)
     - [When finding facebook user 'findOrCreateFaceBookUser()'](#user-when-finding-facebook-user-findorcreatefacebookuser)
       - [When user doesn't exists](#user-when-finding-facebook-user-findorcreatefacebookuser-when-user-doesnt-exists)
       - [When user exists](#user-when-finding-facebook-user-findorcreatefacebookuser-when-user-exists)
   - [Mailer](#mailer)
     - [When sending signup confirmation 'sendSignupConfirmation()'](#mailer-when-sending-signup-confirmation-sendsignupconfirmation)
     - [When sending account validation confirmation 'sendAccountValidatedConfirmation()'](#mailer-when-sending-account-validation-confirmation-sendaccountvalidatedconfirmation)
     - [When sending request for reseting password 'sendRequestForResetingPassword()'](#mailer-when-sending-request-for-reseting-password-sendrequestforresetingpassword)
     - [When sending password reset process 'sendPasswordReseted()'](#mailer-when-sending-password-reset-process-sendpasswordreseted)
     - [When sending contact confirmation 'sendContactConfirmation()'](#mailer-when-sending-contact-confirmation-sendcontactconfirmation)
   - [Image](#image)
     - [When validating image 'validate()'](#image-when-validating-image-validate)
     - [When creating user directory 'createUserDir()'](#image-when-creating-user-directory-createuserdir)
     - [When saving user picture 'saveUserPicture()'](#image-when-saving-user-picture-saveuserpicture)
<a name=""></a>

<a name="user"></a>
# User
<a name="user-when-signing-up-signup"></a>
## When signing up 'signup()'
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

<a name="user-when-validating-an-account-accountvalidator"></a>
## When validating an account 'accountValidator()'
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

<a name="user-when-checking-user-password-is-valid-isvaliduserpassword"></a>
## When checking user password is valid 'isValidUserPassword()'
<a name="user-when-checking-user-password-is-valid-isvaliduserpassword-user-not-validated"></a>
### User not validated
<a name="user-when-checking-user-password-is-valid-isvaliduserpassword-user-not-validated-password-is-correct"></a>
#### Password is correct
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

<a name="user-when-checking-user-password-is-valid-isvaliduserpassword-user-validated"></a>
### User validated
<a name="user-when-checking-user-password-is-valid-isvaliduserpassword-user-validated-password-is-correct"></a>
#### Password is correct
should valid user password.

```js
return User.isValidUserPassword(email, passwd, function(err, data, msg) {
  should.not.exist(err);
  should.not.exist(msg);
  assert.equal(user.email, data.email);
  return done();
});
```

<a name="user-when-checking-user-password-is-valid-isvaliduserpassword-user-validated-password-is-not-correct"></a>
#### Password is not correct
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

<a name="user-when-requesting-for-password-reset-requestresetpassword"></a>
## When requesting for password reset 'requestResetPassword()'
should set required fields for forgot password process.

```js
return user.requestResetPassword(function(err, modifedUser) {
  should.not.exist(err);
  should.exist(modifedUser.regeneratePasswordKey);
  should.exist(modifedUser.regeneratePasswordDate);
  return done();
});
```

<a name="user-when-finding-facebook-user-findorcreatefacebookuser"></a>
## When finding facebook user 'findOrCreateFaceBookUser()'
<a name="user-when-finding-facebook-user-findorcreatefacebookuser-when-user-doesnt-exists"></a>
### When user doesn't exists
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

<a name="user-when-finding-facebook-user-findorcreatefacebookuser-when-user-exists"></a>
### When user exists
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
# Mailer
<a name="mailer-when-sending-signup-confirmation-sendsignupconfirmation"></a>
## When sending signup confirmation 'sendSignupConfirmation()'
should call sendMail.

```js
return mailer.sendSignupConfirmation('en', 'toto@toto.com', 'http://dummy-url.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-when-sending-account-validation-confirmation-sendaccountvalidatedconfirmation"></a>
## When sending account validation confirmation 'sendAccountValidatedConfirmation()'
should call sendMail.

```js
return mailer.sendAccountValidatedConfirmation('en', 'toto@toto.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-when-sending-request-for-reseting-password-sendrequestforresetingpassword"></a>
## When sending request for reseting password 'sendRequestForResetingPassword()'
should call sendMail.

```js
return mailer.sendRequestForResetingPassword('en', 'toto@toto.com', 'http://dummy-url.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-when-sending-password-reset-process-sendpasswordreseted"></a>
## When sending password reset process 'sendPasswordReseted()'
should call sendMail.

```js
return mailer.sendPasswordReseted('en', 'toto@toto.com', 'http://dummy-url.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="mailer-when-sending-contact-confirmation-sendcontactconfirmation"></a>
## When sending contact confirmation 'sendContactConfirmation()'
should call sendMail.

```js
return mailer.sendContactConfirmation('en', 'toto@toto.com', function(err, response) {
  should.not.exists(err);
  assert(mailer.sendMail.called);
  return done();
});
```

<a name="image"></a>
# Image
<a name="image-when-validating-image-validate"></a>
## When validating image 'validate()'
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

<a name="image-when-creating-user-directory-createuserdir"></a>
## When creating user directory 'createUserDir()'
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

<a name="image-when-saving-user-picture-saveuserpicture"></a>
## When saving user picture 'saveUserPicture()'
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
