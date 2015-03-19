var AuthenticatedRoute = require('../authenticated_route');

// Sshkey Ember Route Class (inherit from auth route because restricted)
var SshkeysByuserRoute = AuthenticatedRoute.extend({
  // Get the sshkeys following an user_id
  model: function(params) {
    return this.store.find('sshkey', { user_id: params.user_id }) ;
  },

  // Same template than the standard list of sshkeys
  renderTemplate:function () {
    this.render('sshkeys/list') ;
  },

  // Setup the controller for sshkeys.list with this model
  setupController: function(controller, model) {
    this.controllerFor('sshkeys.list').setProperties({content:model});
  },
});

module.exports = SshkeysByuserRoute;

