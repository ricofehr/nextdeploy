// Application controller, used by the main view
var ApplicationController = Ember.Controller.extend({
  isMenulogin: false,

  // Return current user
  currentUser: function() {
    var userId = App.AuthManager.get('apiKey.user') ;
    return this.store.find('user', userId) ;
  }.property('App.AuthManager.apiKey'),

  // Return true if user is authenticated
  isAuthenticated: function() {
    return App.AuthManager.isAuthenticated()
  }.property('App.AuthManager.apiKey'),

  // Return true if user is an admin
  isAdmin: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level == 50) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // Return true if user is a Lead Dev
  isLead: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level >= 40) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),
});

module.exports = ApplicationController;

