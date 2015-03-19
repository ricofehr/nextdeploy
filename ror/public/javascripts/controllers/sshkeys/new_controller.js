var SshkeysNewController = Ember.ObjectController.extend({
  //user combobox
  computeSorting: ['email'],
  usersSort: Ember.computed.sort('userlist', 'computeSorting'),
  transitionList: false,

  //validation variables
  errorUser: false,
  errorName: false,
  errorKey: false,

  //validation function
  checkName: function() {
    var name = this.get('name') ;
    var errorName = false ;

    if (!name) {
      errorName = true ;
    }

    this.set('errorName', errorName) ;
  }.observes('name'),

  checkUser: function() {
    var user = this.get('user.content') ;
    var errorUser = false ;

    if (!user) {
      errorUser = true ;
    }

    this.set('errorUser', errorUser) ;
  }.observes('user.content'),

  checkKey: function() {
    var key = this.get('key') ;
    var errorKey = false ;

    if (!key) {
      errorKey = true ;
    }

    this.set('errorKey', errorKey) ;
  }.observes('key'),

  //check form before submit
  formIsValid: function() {
    this.checkUser() ;
    this.checkName() ;
    this.checkKey() ;

    if (!this.get('errorUser') &&
        !this.get('errorName') &&
        !this.get('errorKey')) return true ;
    return false ;
  }.observes('model'),

  //clear form
  clearForm: function() {
    this.set('name', null) ;
    this.set('user.content', null) ;
    this.set('key', null) ;
  },

  actions: {
    postItem: function() {
      var router = this.get('target');
      var data = this.getProperties('id', 'name', 'key')
      var store = this.store;

      // check if form is valid
      if (!this.formIsValid()) {
        return ;
      }

      data['user'] = this.get('user.content') ;

      //if id is present, so update item, else create new one
      if(data['id']) {
        store.find('sshkey', data['id']).then(function (sshkey) {
          sshkey.setProperties(data) ;
          sshkey.save();
        });
      } else {
        sshkey = store.createRecord('sshkey', data) ;
        sshkey.save() ;
      }

      if (this.get('transitionList')) {
        // Return to keys list page
        router.transitionTo('sshkeys.list');
      } else {
        // Return to user profile page
        router.transitionTo('users.edit', this.get('user.content.id'));
      }
    }
  }
});

module.exports = SshkeysNewController;