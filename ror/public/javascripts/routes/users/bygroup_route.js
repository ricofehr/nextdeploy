var AuthenticatedRoute = require('../authenticated_route');

// User Ember Route Class (inherit from auth route because restricted)
var UsersBygroupRoute = AuthenticatedRoute.extend({
  // Get the users following an group_id
  model: function(params) {
    return this.store.find('user', { group_id: params.group_id }) ;
  },

  // Same template than the standard list of users
  renderTemplate:function () {
    this.render('users/list') ;
  },

  // Setup the controller for users.list with this model 
  setupController: function(controller, model) {
    this.controllerFor('users.list').setProperties({content:model});
  },
});

module.exports = UsersBygroupRoute;

