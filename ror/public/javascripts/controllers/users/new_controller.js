var UsersNewController = Ember.ObjectController.extend({
  quotavmlist: [0,1,2,3,4,5,6,7,8,9,10,15,20,30,50,100],
  password: null,
  password_confirmation: null,

  //validation variables
  errorCompany: false,
  errorEmail: false,

  errorPassword: false,
  successPassword: false,

  errorPasswordConfirmation: false,
  successPasswordConfirmation: false,

  errorPassword2: false,
  successPassword2: false,

  //validation function
  checkEmail: function() {
    var email = this.get('email') ;
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    var errorEmail = false ;

    if (!re.test(email)) {
      errorEmail = true ;
    }

    this.set('errorEmail', errorEmail) ;
  }.observes('email'),

  checkCompany: function() {
    var company = this.get('company') ;
    var errorCompany = false ;

    if (!company) {
      errorCompany = true ;
    }

    this.set('errorCompany', errorCompany) ;
  }.observes('company'),

  checkPassword: function() {
    var password = this.get('password') ;
    var errorPassword = false ;
    var successPassword = true ;

    if (password && password.length < 8) {
      errorPassword = true ;
      successPassword = false ;
    }

    if (!password || password.length == 0) {
      errorPassword = false ;
      successPassword = false ;
    }

    this.set('errorPassword', errorPassword) ;
    this.set('successPassword', successPassword) ;
  }.observes('password'),

  checkPasswordConfirmation: function() {
    var passwordConfirmation = this.get('password_confirmation') ;
    var errorPasswordConfirmation = false ;
    var successPasswordConfirmation = true ;

    if (passwordConfirmation && passwordConfirmation.length < 8) {
      errorPasswordConfirmation = true ;
      successPasswordConfirmation = false ;
    }

    if (!passwordConfirmation || passwordConfirmation.length == 0) {
      errorPasswordConfirmation = false ;
      successPasswordConfirmation = false ;
    }

    this.set('errorPasswordConfirmation', errorPasswordConfirmation) ;
    this.set('successPasswordConfirmation', successPasswordConfirmation) ;
  }.observes('password_confirmation'),

  checkSamePassword: function() {
    var password = this.get('password') ;
    var password2 = this.get('password_confirmation') ;
    var errorPassword2 = false ;
    var successPassword2 = true ;

    if (password != password2) {
      errorPassword2 = true ;
      successPassword2 = false ;
    }

    this.set('errorPassword2', errorPassword2) ;
    this.set('successPassword2', successPassword2) ;
  }.observes('password', 'password_confirmation'),


  //check form before submit
  formIsValid: function() {
    this.checkEmail() ;
    this.checkCompany() ;
    this.checkPassword() ;
    this.checkPasswordConfirmation() ;
    this.checkSamePassword() ;

    if (!this.get('errorEmail') &&
        !this.get('errorCompany') &&
        !this.get('errorPassword') &&
        !this.get('errorPasswordConfirmation') &&
        !this.get('errorPassword2')) return true ;
    return false ;
  },

  //clear form
  clearForm: function() {
    this.set('email', null) ;
    this.set('company', null) ;
    this.set('quotavm', null) ;
    this.set('password', null) ;
    this.set('password_confirmation', null) ;
  },

  // actions binding with user event
  actions: {
    postItem: function() {
      var router = this.get('target');
      var data = this.getProperties('id', 'email', 'company', 'password', 'password_confirmation', 'quotavm')
      var store = this.store;

      // check if form is valid
      if (!this.formIsValid()) {
        return
      }

      //if id is present, so update item, else create new one
      if(data['id']) {
        store.find('user', data['id']).then(function (user) {
          user.setProperties(data) ;
          user.save();
        });
      } else {
        user = store.createRecord('user', data) ;
        user.save() ;
      }

      // Clear the form before exit page
      this.clearForm() ;

      // Return to users list page
      router.transitionTo('users.list');
    }
  }
});

module.exports = UsersNewController;

