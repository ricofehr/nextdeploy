var AuthenticatedRoute = require('../authenticated_route');

// Sshkey Ember Route Class (inherit from auth route because restricted)
var SshkeysNewRoute = AuthenticatedRoute.extend({
  // Return all users for the sshkey create form
  model: function() {
    return Ember.RSVP.hash({
      userlist: this.store.all('user')
    });
  },

  // Setup the controller with the model
  setupController: function(controller, model) {
    this._super(controller, model);

    content = Ember.Object.create() ;
    content.set('user', {content: null}) ;
    content.set('transitionList', true) ;
    this.controllerFor('sshkeys.new').setProperties({model: content,
                                                      userlist: model.userlist}) ;
  }
});

module.exports = SshkeysNewRoute;

