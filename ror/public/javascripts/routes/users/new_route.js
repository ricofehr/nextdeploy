var AuthenticatedRoute = require('../authenticated_route');

// User Ember Route Class (inherit from auth route because restricted)
var UsersNewRoute = AuthenticatedRoute.extend({
  // The model is empty
  model: function() {
    return Ember.Object.create();
  },

  // Setup the controller, empty the form before diplay this one
  setupController: function(controller, model) {
    this._super(controller, model) ;
    this.controllerFor('users.new').clearForm() ;
  },
});

module.exports = UsersNewRoute;

