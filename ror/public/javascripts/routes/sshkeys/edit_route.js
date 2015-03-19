var AuthenticatedRoute = require('../authenticated_route');

// Sshkey Ember Route Class (inherit from auth route because restricted)
var SshkeysEditRoute = AuthenticatedRoute.extend({
  // Return all users for the sshkey form and the sshkey object following the parameter
  model: function(params) {
    return Ember.RSVP.hash({
      userlist: this.store.all('user'),
      sshkey: this.store.find('sshkey', params.sshkey_id)
    });
  },

  // Same template than the create form
  renderTemplate:function () {
    this.render('sshkeys/new') ;
  },

  // Setup the controller sshkeys.new with this model
  setupController: function(controller, model) {
    this.controllerFor('sshkeys.new').setProperties({model: model.sshkey,
                                                     userlist: model.userlist});
  },
});

module.exports = SshkeysEditRoute;

