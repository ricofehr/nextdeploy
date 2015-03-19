var AuthenticatedRoute = require('../authenticated_route');

// User Ember Route Class (inherit from auth route because restricted)
var UsersListRoute = AuthenticatedRoute.extend({
  // Get all users for thie model
  model: function() {
    return this.store.all('user') ;
  },

  // Setup the controller
  setupController: function(controller, model) {
    this._super(controller, model);
    controller.sortModel() ;
  }
});

module.exports = UsersListRoute;

