var UsersNewController = Ember.ObjectController.extend({
  quotavmlist: [0,1,2,3,4,5,6,7,8,9,10,15,20,30,50,100],
  password: null,
  password_confirmation: null,

  // sort group
  computeSorting: ['name'],
  groupSort: Ember.computed.sort('grouplist', 'computeSorting'),

  //validation variables
  errorCompany: false,
  errorEmail: false,

  errorPassword: false,
  successPassword: false,

  errorPasswordConfirmation: false,
  successPasswordConfirmation: false,

  errorPassword2: false,
  successPassword2: false,

  errorGroup: false,
  successGroup: false,

  //project checkboxes array
  projectSorting: ['name'],
  projectSort: Ember.computed.sort('projectlist', 'projectSorting'),
  checkedProjects: Ember.computed.map('projectSort', function(model){
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;
    var checked = false ;
    var readonly = false ;
    var projects = this.get('user_projects') ;
    var group_access = 0;
    var project = null ;

    if (this.get('id') && this.get('id') != null) group_access = this.get('group').get('access_level');
    if (access_level < 50 || group_access == 50) readonly = true ;

    if(projects) {
      project = projects.findBy('id', model.id) ;
      if(project) checked = true ;
    }

    return Ember.ObjectProxy.create({
      content: model,
      checked: checked,
      readonly: readonly
    });
  }),

  //validation function
  checkEmail: function() {
    var email = this.get('email');
    var re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    var errorEmail = false;

    if (!re.test(email)) {
      errorEmail = true;
    }

    this.set('errorEmail', errorEmail);
  }.observes('email'),

  checkCompany: function() {
    var company = this.get('company');
    var errorCompany = false;

    if (!company) {
      errorCompany = true;
    }

    this.set('errorCompany', errorCompany) ;
  }.observes('company'),

  checkGroup: function() {
    var group = this.get('group.content');
    var errorGroup = false;

    if (!group) {
      errorGroup = true;
    }

    this.set('errorGroup', errorGroup);
  }.observes('group.content'),

  checkPassword: function() {
    var password = this.get('password');
    var errorPassword = false;
    var successPassword = true;

    if (password && password.length < 8) {
      errorPassword = true;
      successPassword = false;
    }

    if (!password || password.length == 0) {
      errorPassword = false;
      successPassword = false;
    }

    this.set('errorPassword', errorPassword) ;
    this.set('successPassword', successPassword) ;
  }.observes('password'),

  checkPasswordConfirmation: function() {
    var passwordConfirmation = this.get('password_confirmation') ;
    var errorPasswordConfirmation = false;
    var successPasswordConfirmation = true;

    if (passwordConfirmation && passwordConfirmation.length < 8) {
      errorPasswordConfirmation = true;
      successPasswordConfirmation = false;
    }

    if (!passwordConfirmation || passwordConfirmation.length == 0) {
      errorPasswordConfirmation = false;
      successPasswordConfirmation = false;
    }

    this.set('errorPasswordConfirmation', errorPasswordConfirmation);
    this.set('successPasswordConfirmation', successPasswordConfirmation);
  }.observes('password_confirmation'),

  checkSamePassword: function() {
    var password = this.get('password');
    var password2 = this.get('password_confirmation');
    var errorPassword2 = false;
    var successPassword2 = true;

    if (password != password2) {
      errorPassword2 = true;
      successPassword2 = false;
    }

    this.set('errorPassword2', errorPassword2);
    this.set('successPassword2', successPassword2);
  }.observes('password', 'password_confirmation'),


  //check form before submit
  formIsValid: function() {
    this.checkEmail();
    this.checkCompany();
    this.checkGroup();
    this.checkPassword();
    this.checkPasswordConfirmation();
    this.checkSamePassword();

    if (!this.get('errorEmail') &&
        !this.get('errorCompany') &&
        !this.get('errorGroup') &&
        !this.get('errorPassword') &&
        !this.get('errorPasswordConfirmation') &&
        !this.get('errorPassword2')) return true;
    return false;
  },

  //clear form
  clearForm: function() {
    this.set('email', null);
    this.set('company', null);
    this.set('quotavm', null);
    this.set('password', null);
    this.set('password_confirmation', null);
    this.set('group', {content: null});
  },

  // Check if current user is lead and can change properties
  isDisableLead: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level >= 40) return false ;
    return true ;
  }.property('App.AuthManager.apiKey'),

  // Check if current user is admin and can change properties
  isDisableAdmin: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level >= 50) return false ;
    return true ;
  }.property('App.AuthManager.apiKey'),

  // Check if current user is same as current form / or admin and can change properties
  isDisable: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;
    var current_id = App.AuthManager.get('apiKey.user') ;
    var form_id = this.get('id');

    if (access_level >= 50) return false ;
    if (current_id == form_id) return false ;
    return true ;
  }.property('App.AuthManager.apiKey'),

  // show only if current user is same as current form / or admin
  isEnable: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;
    var current_id = App.AuthManager.get('apiKey.user') ;
    var form_id = this.get('id');

    if (access_level >= 50) return true ;
    if (current_id == form_id) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // actions binding with user event
  actions: {
    postItem: function() {
      var router = this.get('target');
      var data = this.getProperties('id', 'email', 'company', 'password', 'password_confirmation', 'quotavm');
      var store = this.store;
      var selectedGroup = this.get('group.content');
      var projects = this.get('checkedProjects').filterBy('checked', true).mapBy('content');
      var user;

      // get group selected
      data['group'] = selectedGroup;
      
      // check if form is valid
      if (!this.formIsValid()) {
        return
      }

      //if id is present, so update item, else create new one
      if(data['id']) {
        store.find('user', data['id']).then(function (user) {
          var projects_p = user.get('projects').toArray();

          // reset old values from object
          projects_p.forEach(function (item) {
            user.get('projects').removeObject(item);
            item.get('users').removeObject(user);
          }) ;

          // add projects association
          projects.toArray().forEach(function (item) {
            item.get('users').addObject(user);
            user.get('projects').pushObject(item);
          });

          user.get('group').get('users').removeObject(user);
          user.setProperties(data);

          Ember.Logger.debug(user) ;

          selectedGroup.get('users').pushObject(user);
          user.save();
        });
      } else {
        user = store.createRecord('user', data);

        // add projects association
        projects.toArray().forEach(function (item) {
          item.get('users').addObject(user) ;
          user.get('projects').pushObject(item) ;
        });

        selectedGroup.get('users').pushObject(user);
        user.save();
      }

      // Return to users list page
      router.transitionTo('users.list');
    }
  }
});

module.exports = UsersNewController;

