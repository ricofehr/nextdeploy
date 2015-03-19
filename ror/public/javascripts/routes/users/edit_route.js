var AuthenticatedRoute = require('../authenticated_route');

// User Ember Route Class (inherit from auth route because restricted)
var UsersEditRoute = AuthenticatedRoute.extend({
  // Init the model with the user_id parameter
  model: function(params) {
    return this.store.find('user', params.user_id) ;
  },

  // Same template than the create form
  renderTemplate:function () {
    this.render('users/new') ;
  },

  // Setup the controller "users.new" with this model
  setupController: function(controller, model) {
    model.set('password', null) ;
    model.set('password_confirmation', null) ;
    this.controllerFor('users.new').setProperties({content:model});
  },
});

module.exports = UsersEditRoute;

