// The indexcontroller for the welcome page
var IndexController = Ember.Controller.extend({
  // Return the current user
  currentUser: function() {
    return App.AuthManager.get('apiKey.user')
  }.property('App.AuthManager.apiKey'),

  // Return true if user is authenticated
  isAuthenticated: function() {
    return App.AuthManager.isAuthenticated()
  }.property('App.AuthManager.apiKey'),
});

module.exports = IndexController;

