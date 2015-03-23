// Controller who manage user session creation
var SessionsNewController = Ember.ObjectController.extend({
  attemptedTransition: null,

  // Get current user
  currentUser: function() {
    var userId = App.AuthManager.get('apiKey.user') ;
    return this.store.find('user', userId) ;
  }.property('App.AuthManager.apiKey'),

  // Return true if authenticated
  isAuthenticated: function() {
    return App.AuthManager.isAuthenticated()
  }.property('App.AuthManager.apiKey'),

  // load model datas if authentification is success
  redirectToTransition: function() {
    var self = this;
    var attemptedTrans = self.get('attemptedTransition');
    var router = this.get('target');

    if (App.AuthManager.isAuthenticated()) {
      $('#waitingModal').modal() ;
      this.loadModel() ;
    }
  }.observes('App.AuthManager.apiKey'),

  // Redirect to the targetting page after authentification
  attemptedToTransition: function() {
    var self = this;
    var attemptedTrans = self.get('attemptedTransition');

    if (attemptedTrans) {
          attemptedTrans.retry() ;
          self.set('attemptedTransition', null);
      }
  },

  // load model datas into ember memory
  loadModel: function() {
    var store = this.store ;
    var self = this ;

    // Reset ember datas to empty state
    self.resetModel ;

    // chained calls for synchronous load
    // .... ugly !
    store.findAll('brand').then(function() {
      store.findAll('vmsize').then(function() {
        store.findAll('framework').then(function() {
          store.findAll('techno').then(function() {
            store.findAll('systemimagetype').then(function() {
              store.findAll('systemimage').then(function() {
                store.findAll('group').then(function() {
                  store.findAll('user').then(function() {
                    store.findAll('sshkey').then(function() {
                      store.findAll('project').then(function() {
                        store.findAll('vm').then(function() {
                          var attemptedTrans = self.get('attemptedTransition');
                          if (attemptedTrans) {
                            attemptedTrans.retry() ;
                            self.set('attemptedTransition', null);
                          }
                          $('#waitingModal').modal('hide') ;
                        }) ;
                      }) ;
                    }) ;
                  }) ;
                }) ;
              }) ;
            }) ;
          }) ;
        }) ;
      }) ;
    }) ;
  },

  // Empty all ember datas
  resetModel: function() {
    var models = ['branche', 'brand', 'commit', 'flavor', 'framework', 'group', 'project',
       'sshkey', 'systemimage', 'systemimagetype', 'techno', 'user', 'vm'] ;

    for (var i=0; i<models.length; i++) {
      this.store.unloadAll(models[i]) ;
    }
  },

  // actions binding with user event
  actions: {
    // submit form for authentification
    loginUser: function() {
      var self = this;
      var router = this.get('target');
      var data = this.getProperties('email', 'password');
      var store = this.store ;
      var attemptedTrans = this.get('attemptedTransition');

      self.set('error401', false) ;
      self.set('error500', false) ;

      $.ajax({
            url: '/api/v1/users/sign_in',
            type: "POST",
            dataType: "json",
            data: data,
            /**
             * A function to be called if the request fails. 
             */
            error: function(jqXHR, textStatus, errorThrown) {
                if (jqXHR.status == 401) self.set('error401', true) ;
                else self.set('error500', true) ;
            },

            /**
             * A function to be called if the request succeeds.
             */
            success: function(results, textStatus, jqXHR) {
                var user = results.user.id ;
                var group = results.user.group ;
                var auth_token = results.user.authentication_token ;

                App.AuthManager.ajaxSetup(auth_token) ;
                // Get rest request for getting group value
                $.get('/api/v1/group', [], function(results) {
                  // Init authmanager object for record session
                  App.AuthManager.initUser(user, group, auth_token, results.group.access_level) ;

                  // Redirect to targetting page
                  if (attemptedTrans) {
                    attemptedTrans.retry();
                    self.set('attemptedTransition', null);
                  } else {
                    router.transitionTo('index');
                  }
                }, 'json');
            }
        });



      // Post rest request for sign-in
      /*
      $.post('/api/v1/users/sign_in', data, function(results) {
        var user = results.user.id ;
        var group = results.user.group ;
        var auth_token = results.user.authentication_token ;

        App.AuthManager.ajaxSetup(auth_token) ;
        // Get rest request for getting group value
        $.get('/api/v1/group', [], function(results) {
          // Init authmanager object for record session
          App.AuthManager.initUser(user, group, auth_token, results.group.access_level) ;

          // Redirect to targetting page
          if (attemptedTrans) {
            attemptedTrans.retry();
            self.set('attemptedTransition', null);
          } else {
            router.transitionTo('index');
          }
        }, 'json');
      }, 'json');
      */
    }
  }
});

module.exports = SessionsNewController;

