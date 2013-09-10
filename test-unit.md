NODE_ENV=test mocha --compilers coffee:coffee-script --recursive --reporter markdown test/unit
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
