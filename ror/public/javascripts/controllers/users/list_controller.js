// Ember controller for list users into html array
var UsersListController = Ember.ArrayController.extend({
  // Sort order
  sortProperties: ['company', 'email'],
  
  // Show / hide on html side
  isShowingDeleteConfirmation: false,
  isAllDelete: false,

  // Return model array with email setted, sorted by email and with isCurrent parameter
  sortModel: function() {
    var model = this.get('model') ;
    var usersFilter = model.filterBy('email') ;
    var usersSort = usersFilter.sort('sortProperties') ;

    this.set('users', usersSort.map(function(model){
      var user_id = model.get('id') ;
      var current_id = App.AuthManager.get('apiKey.user') ;

      model.set('isCurrent', (user_id == current_id)) ;
      return model ;
    })) ;

  }.observes('model'),

  // Check if current user is admin
  isAdmin: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level == 50) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // Check if current user is admin
  isLead: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level >= 40) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // Return current user
  isCurrent: function(user_id) {
    var current_id = App.AuthManager.get('apiKey.user') ;

    if (user_id == current_id) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // actions binding with user event
  actions: {
    // action for delete event
    deleteItems: function() {
      var router = this.get('target');
      var users = this.get('users') ;
      var items = this.filterProperty('todelete', true) ;

      items.forEach(function(model) {
        model.destroyRecord() ;
        users.removeObject(model) ;
      }) ;

      this.set('isShowingDeleteConfirmation', false) ;
      this.set('isAllDelete', false) ;
    },

    // Change hide/show for delete confirmation
    showDeleteConfirmation: function() {
      this.toggleProperty('isShowingDeleteConfirmation') ;
    },

    // Action for add a new item, change current page to create form
    newItem: function() {
      var router = this.get('target') ;
      router.transitionTo('users.new') ;
    },

    // Toggle or untoggle all items
    toggleDeleteAll: function() {
      if (this.get('isAllDelete')) this.set('isAllDelete', false) ;
      else this.set('isAllDelete', true) ;
      this.setEach('todelete', this.get('isAllDelete'));
    }
  }
});

module.exports = UsersListController;