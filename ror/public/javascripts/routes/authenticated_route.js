// The Route class parent for all authenticated part of the app
var AuthenticatedRoute = Ember.Route.extend({
  // Before model loading, check if user is authenticated
  beforeModel: function(transition) {
    if (!App.AuthManager.isAuthenticated()) {
      this.redirectToLogin(transition);
    }
  },

  // return the current user
  currentUser: function() {
    return App.AuthManager.get('apiKey.user')
  },

  // Redirect to the login page and store the current transition so we can
  // run it again after login
  redirectToLogin: function(transition) {
    var sessionNewController = this.controllerFor('sessions.new');
    sessionNewController.set('attemptedTransition', transition);
    this.transitionTo('sessions.new');
  },

  events: {
    // Log an error
    error: function(reason, transition) {
      Ember.Logger.debug(reason) ;
      this.redirectToLogin(transition);
    }
  }
});

module.exports = AuthenticatedRoute;

