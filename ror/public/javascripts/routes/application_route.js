var AuthManager = require('../config/auth_manager');

// The default Route class for the main view of ember app
var ApplicationRoute = Ember.Route.extend({
  // Init an new authmanager object
  init: function() {
    this._super();
    App.AuthManager = AuthManager.create();
  },

  events: {
    // Unload all objects in ember memory
    logout: function() {
      var models = ['branche', 'brand', 'commit', 'framework', 'group', 'project',
       'sshkey', 'systemimage', 'systemimagetype', 'techno', 'user', 'vm'] ;

      for (var i=0; i<models.length; i++) {
        this.store.unloadAll(models[i]) ;
      }

      // Redirect to login page
      App.AuthManager.reset().then(function() {
        this.transitionTo('index') ;
      }) ;
    }
  }
});

module.exports = ApplicationRoute;

