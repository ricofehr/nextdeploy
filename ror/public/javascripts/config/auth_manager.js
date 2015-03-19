// Manage authentification session
var AuthManager = Ember.Object.extend({

  // Load the current user if the cookies exist and is valid
  init: function() {
    this._super();
    var accessToken = $.cookie('access_token');
    if (!Ember.isEmpty(accessToken)) {
      this.authenticate(accessToken);
    }
  },

  // get access_level
  access_level: function() {
    var apiKey = this.get('apiKey') ;
    if(!apiKey) {
      this.init() ;
    }

    return this.get('apiKey.access_level') ;
  },

  // Determine if the user is currently authenticated.
  isAuthenticated: function() {
    return !Ember.isEmpty(this.get('apiKey.accessToken')) && !Ember.isEmpty(this.get('apiKey.user'));
  },

  ajaxSetup: function(token) {
    $.ajaxSetup({
      headers: { 'Authorization': 'Token token=' + token }
    });
  },

  ajaxSetupSync: function(token) {
    $.ajaxSetup({
      headers: { 'Authorization': 'Token token=' + token },
      async: false
    });
  },

  //init apikey object from user model
  initUser: function(user, group, access_token, access_level) {
    var apiKey = App.ApiKey.create({
          accessToken: access_token,
          user: user,
          group: group,
          accessLevel: access_level
    }) ;

    this.set('apiKey', apiKey) ;
  },

  authenticate: function(accessToken) {
    var store = App.store ;

    this.ajaxSetup(accessToken) ;
    $.get('/api/v1/user', [], function(results) {
      var user = results.user.id ;
      var group = results.user.group ;
      var auth_token = results.user.authentication_token ;
      App.AuthManager.initUser(user, group, auth_token, 0) ;

      $.get('/api/v1/group', [], function(results) {
        App.AuthManager.initUser(user, group, auth_token, results.group.access_level) ;
      });
    });
  },

  // Log out the user
  reset: function() {
    App.__container__.lookup("route:application").transitionTo('sessions.new');
    Ember.run.sync();
    Ember.run.next(this, function(){
      this.set('apiKey', null);
      this.ajaxSetup('none') ;
    });
  },

  // Ensure that when the apiKey changes, we store the data in cookies in order for us to load
  // the user when the browser is refreshed.
  apiKeyObserver: function() {
    if (Ember.isEmpty(this.get('apiKey'))) {
      $.removeCookie('access_token');
    } else {
      $.cookie('access_token', this.get('apiKey.accessToken'));
    }
  }.observes('apiKey')
});

// Reset the authentication if any ember data request returns a 401 unauthorized error
DS.rejectionHandler = function(reason) {
  if (reason.status === 401) {
    App.AuthManager.reset();
  }
  throw reason;
};

module.exports = AuthManager;
