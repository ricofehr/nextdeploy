var AuthenticatedRoute = require('../authenticated_route');

// User Ember Route Class (inherit from auth route because restricted)
var UsersEditRoute = AuthenticatedRoute.extend({
  // Init the model with the user_id parameter
  model: function(params) {
    return Ember.RSVP.hash({
      grouplist: this.store.all('group'),
      user: this.store.find('user', params.user_id) 
    });
  },

  // Same template than the create form
  renderTemplate:function () {
    this.render('users/new') ;
  },

  // Setup the controller "users.new" with this model
  setupController: function(controller, model) {
    model.user.set('password', null) ;
    model.user.set('password_confirmation', null) ;
    this.controllerFor('users.new').setProperties({content: model.user,
                                                  grouplist: model.grouplist});
  },
});

module.exports = UsersEditRoute;

