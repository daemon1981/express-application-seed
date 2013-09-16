# TOC
   - [Signup](#signup)
     - [Signup page](#signup-signup-page)
       - [When logged in](#signup-signup-page-when-logged-in)
         - [Accessing signup page](#signup-signup-page-when-logged-in-accessing-signup-page)
       - [When logged out](#signup-signup-page-when-logged-out)
         - [Accessing signup page](#signup-signup-page-when-logged-out-accessing-signup-page)
         - [Submitting signup information](#signup-signup-page-when-logged-out-submitting-signup-information)
           - [User not already registered](#signup-signup-page-when-logged-out-submitting-signup-information-user-not-already-registered)
           - [User already registered](#signup-signup-page-when-logged-out-submitting-signup-information-user-already-registered)
     - [Signup confirmation page](#signup-signup-confirmation-page)
       - [When logged in](#signup-signup-confirmation-page-when-logged-in)
         - [Accessing signup confirmation page](#signup-signup-confirmation-page-when-logged-in-accessing-signup-confirmation-page)
       - [When logged out](#signup-signup-confirmation-page-when-logged-out)
         - [Accessing signup confirmation page](#signup-signup-confirmation-page-when-logged-out-accessing-signup-confirmation-page)
     - [Validate account](#signup-validate-account)
       - [When logged in](#signup-validate-account-when-logged-in)
         - [Trying validate account](#signup-validate-account-when-logged-in-trying-validate-account)
       - [When logged out](#signup-validate-account-when-logged-out)
         - [Query to validate account](#signup-validate-account-when-logged-out-query-to-validate-account)
     - [Signup validation page](#signup-signup-validation-page)
       - [When logged in](#signup-signup-validation-page-when-logged-in)
         - [Accessing signup validation page](#signup-signup-validation-page-when-logged-in-accessing-signup-validation-page)
       - [When logged out](#signup-signup-validation-page-when-logged-out)
         - [Accessing signup validation page](#signup-signup-validation-page-when-logged-out-accessing-signup-validation-page)
   - [Login](#login)
     - [When logged in](#login-when-logged-in)
       - [Accessing login page](#login-when-logged-in-accessing-login-page)
     - [When logged out](#login-when-logged-out)
       - [Accessing login page](#login-when-logged-out-accessing-login-page)
       - [Submitting login and password](#login-when-logged-out-submitting-login-and-password)
         - [User is validated](#login-when-logged-out-submitting-login-and-password-user-is-validated)
         - [User is not validated](#login-when-logged-out-submitting-login-and-password-user-is-not-validated)
   - [Profile](#profile)
     - [Profile page](#profile-profile-page)
       - [When logged in](#profile-profile-page-when-logged-in)
         - [Accessing profile page](#profile-profile-page-when-logged-in-accessing-profile-page)
         - [Submitting profile information](#profile-profile-page-when-logged-in-submitting-profile-information)
       - [When logged out](#profile-profile-page-when-logged-out)
         - [Accessing profile page](#profile-profile-page-when-logged-out-accessing-profile-page)
     - [Forgot password page](#profile-forgot-password-page)
       - [When logged in](#profile-forgot-password-page-when-logged-in)
         - [Accessing forgot password page](#profile-forgot-password-page-when-logged-in-accessing-forgot-password-page)
         - [Submitting email](#profile-forgot-password-page-when-logged-in-submitting-email)
       - [When logged out](#profile-forgot-password-page-when-logged-out)
         - [Accessing forgot password page](#profile-forgot-password-page-when-logged-out-accessing-forgot-password-page)
         - [Submitting email](#profile-forgot-password-page-when-logged-out-submitting-email)
     - [Reset password page](#profile-reset-password-page)
       - [When logged in](#profile-reset-password-page-when-logged-in)
         - [Accessing reset password page](#profile-reset-password-page-when-logged-in-accessing-reset-password-page)
         - [Trying submitting by http post call](#profile-reset-password-page-when-logged-in-trying-submitting-by-http-post-call)
       - [When logged out](#profile-reset-password-page-when-logged-out)
         - [Accessing reset password page](#profile-reset-password-page-when-logged-out-accessing-reset-password-page)
         - [Submitting new password](#profile-reset-password-page-when-logged-out-submitting-new-password)
   - [Locale](#locale)
     - [By default inspect Accept-Language in http header](#locale-by-default-inspect-accept-language-in-http-header)
       - [Study case when using req.locale (signing up)](#locale-by-default-inspect-accept-language-in-http-header-study-case-when-using-reqlocale-signing-up)
     - [Next priority goes to req.user.language](#locale-next-priority-goes-to-requserlanguage)
       - [Study case when going to homepage with user connected (language = "fr")](#locale-next-priority-goes-to-requserlanguage-study-case-when-going-to-homepage-with-user-connected-language--fr)
     - [Next priority goes to query ?lang=](#locale-next-priority-goes-to-query-lang)
       - [Study case when ?lang=fr](#locale-next-priority-goes-to-query-lang-study-case-when-langfr)
<a name=""></a>

<a name="signup"></a>
# Signup
<a name="signup-signup-page"></a>
## Signup page
<a name="signup-signup-page-when-logged-in"></a>
### When logged in
<a name="signup-signup-page-when-logged-in-accessing-signup-page"></a>
#### Accessing signup page
should redirect to /profile.

```js
return connectedRequest.get('/signup').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header.location.should.equal('/profile');
  return done();
});
```

<a name="signup-signup-page-when-logged-out"></a>
### When logged out
<a name="signup-signup-page-when-logged-out-accessing-signup-page"></a>
#### Accessing signup page
should return 200.

```js
return request(new App()).get('/signup').expect(200).end(done);
```

<a name="signup-signup-page-when-logged-out-submitting-signup-information"></a>
#### Submitting signup information
<a name="signup-signup-page-when-logged-out-submitting-signup-information-user-not-already-registered"></a>
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

<a name="signup-signup-page-when-logged-out-submitting-signup-information-user-already-registered"></a>
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

<a name="signup-signup-confirmation-page"></a>
## Signup confirmation page
<a name="signup-signup-confirmation-page-when-logged-in"></a>
### When logged in
<a name="signup-signup-confirmation-page-when-logged-in-accessing-signup-confirmation-page"></a>
#### Accessing signup confirmation page
should return 200.

```js
return connectedRequest.get('/signupConfirmation').expect(200).end(done);
```

<a name="signup-signup-confirmation-page-when-logged-out"></a>
### When logged out
<a name="signup-signup-confirmation-page-when-logged-out-accessing-signup-confirmation-page"></a>
#### Accessing signup confirmation page
should return 200.

```js
return request(new App()).get('/signupConfirmation').expect(200).end(done);
```

<a name="signup-validate-account"></a>
## Validate account
<a name="signup-validate-account-when-logged-in"></a>
### When logged in
<a name="signup-validate-account-when-logged-in-trying-validate-account"></a>
#### Trying validate account
should return 200.

```js
return connectedRequest.get('/signup/validation').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="signup-validate-account-when-logged-out"></a>
### When logged out
<a name="signup-validate-account-when-logged-out-query-to-validate-account"></a>
#### Query to validate account
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

<a name="signup-signup-validation-page"></a>
## Signup validation page
<a name="signup-signup-validation-page-when-logged-in"></a>
### When logged in
<a name="signup-signup-validation-page-when-logged-in-accessing-signup-validation-page"></a>
#### Accessing signup validation page
should return 200.

```js
return connectedRequest.get('/signupValidation').expect(200).end(done);
```

<a name="signup-signup-validation-page-when-logged-out"></a>
### When logged out
<a name="signup-signup-validation-page-when-logged-out-accessing-signup-validation-page"></a>
#### Accessing signup validation page
should return 200.

```js
return request(new App()).get('/signupValidation').expect(200).end(done);
```

<a name="login"></a>
# Login
<a name="login-when-logged-in"></a>
## When logged in
<a name="login-when-logged-in-accessing-login-page"></a>
### Accessing login page
should redirect to /profile.

```js
return requestTest.get('/login').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header.location.should.equal('/profile');
  return done();
});
```

<a name="login-when-logged-out"></a>
## When logged out
<a name="login-when-logged-out-accessing-login-page"></a>
### Accessing login page
should return 200.

```js
return request(new App()).get('/login').expect(200).end(function(err, res) {
  should.not.exist(err);
  return done();
});
```

<a name="login-when-logged-out-submitting-login-and-password"></a>
### Submitting login and password
<a name="login-when-logged-out-submitting-login-and-password-user-is-validated"></a>
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

<a name="login-when-logged-out-submitting-login-and-password-user-is-not-validated"></a>
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

<a name="profile"></a>
# Profile
<a name="profile-profile-page"></a>
## Profile page
<a name="profile-profile-page-when-logged-in"></a>
### When logged in
<a name="profile-profile-page-when-logged-in-accessing-profile-page"></a>
#### Accessing profile page
should return 200.

```js
return connectedRequest.get('/profile').expect(200).end(function(err, res) {
  should.not.exist(err);
  return done();
});
```

<a name="profile-profile-page-when-logged-in-submitting-profile-information"></a>
#### Submitting profile information
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

<a name="profile-profile-page-when-logged-out"></a>
### When logged out
<a name="profile-profile-page-when-logged-out-accessing-profile-page"></a>
#### Accessing profile page
should redirect to /login.

```js
return request(new App()).get('/profile').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/login');
  return done();
});
```

<a name="profile-forgot-password-page"></a>
## Forgot password page
<a name="profile-forgot-password-page-when-logged-in"></a>
### When logged in
<a name="profile-forgot-password-page-when-logged-in-accessing-forgot-password-page"></a>
#### Accessing forgot password page
should return 200.

```js
return connectedRequest.get('/request/reset/password').expect(200).end(done);
```

<a name="profile-forgot-password-page-when-logged-in-submitting-email"></a>
#### Submitting email
should return 200 with warning "×Email was not found" if email not found.

```js
return connectedRequest.post('/request/reset/password').send({
  email: 'not@known.email'
}).expect(200).end(function(err, res) {
  var $body;
  should.not.exist(err);
  $body = $(res.text);
  should.exist($body.find('.alert.alert-warning'));
  should.exist($body.find('.alert.alert-warning').text());
  return done();
});
```

should redirect to / if email is found.

```js
return connectedRequest.post('/request/reset/password').send({
  email: fixturesData.testUser.User.fakeUser.email
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

<a name="profile-forgot-password-page-when-logged-out"></a>
### When logged out
<a name="profile-forgot-password-page-when-logged-out-accessing-forgot-password-page"></a>
#### Accessing forgot password page
should return 200.

```js
return request(new App()).get('/request/reset/password').expect(200).end(done);
```

<a name="profile-forgot-password-page-when-logged-out-submitting-email"></a>
#### Submitting email
should return 200 with warning "×Email was not found" if email not found.

```js
return request(new App()).post('/request/reset/password').send({
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
return request(new App()).post('/request/reset/password').send({
  email: fixturesData.testUser.User.fakeUser.email
}).expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/');
  return done();
});
```

<a name="profile-reset-password-page"></a>
## Reset password page
<a name="profile-reset-password-page-when-logged-in"></a>
### When logged in
<a name="profile-reset-password-page-when-logged-in-accessing-reset-password-page"></a>
#### Accessing reset password page
should redirect to /profile.

```js
return connectedRequest.get('/reset/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="profile-reset-password-page-when-logged-in-trying-submitting-by-http-post-call"></a>
#### Trying submitting by http post call
should redirect to /profile.

```js
return connectedRequest.post('/reset/password').expect(302).end(function(err, res) {
  should.not.exist(err);
  res.header['location'].should.include('/profile');
  return done();
});
```

<a name="profile-reset-password-page-when-logged-out"></a>
### When logged out
<a name="profile-reset-password-page-when-logged-out-accessing-reset-password-page"></a>
#### Accessing reset password page
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

<a name="profile-reset-password-page-when-logged-out-submitting-new-password"></a>
#### Submitting new password
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

<a name="locale"></a>
# Locale
<a name="locale-by-default-inspect-accept-language-in-http-header"></a>
## By default inspect Accept-Language in http header
<a name="locale-by-default-inspect-accept-language-in-http-header-study-case-when-using-reqlocale-signing-up"></a>
### Study case when using req.locale (signing up)
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

<a name="locale-next-priority-goes-to-requserlanguage"></a>
## Next priority goes to req.user.language
<a name="locale-next-priority-goes-to-requserlanguage-study-case-when-going-to-homepage-with-user-connected-language--fr"></a>
### Study case when going to homepage with user connected (language = "fr")
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

<a name="locale-next-priority-goes-to-query-lang"></a>
## Next priority goes to query ?lang=
<a name="locale-next-priority-goes-to-query-lang-study-case-when-langfr"></a>
### Study case when ?lang=fr
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
