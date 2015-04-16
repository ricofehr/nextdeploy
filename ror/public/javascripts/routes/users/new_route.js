var AuthenticatedRoute = require('../authenticated_route');

// User Ember Route Class (inherit from auth route because restricted)
var UsersNewRoute = AuthenticatedRoute.extend({
  // This controller needs lot of datas: brands, frameworks, technos, flavors, users 
  model: function() {
    return Ember.RSVP.hash({
      grouplist: this.store.all('group'),
      projectlist: this.store.all('project')
    });
  },

  // Setup the controller with thie model
  setupController: function(controller, model) {
    content = Ember.Object.create() ;
    content.set('group', {content: null}) ;

    this.controllerFor('users.new').setProperties({model: content}) ;
    this.controllerFor('users.new').clearForm() ;
    this.controllerFor('users.new').setProperties({grouplist: model.grouplist,
                                                   projectlist: model.projectlist});
  }
});

module.exports = UsersNewRoute;

