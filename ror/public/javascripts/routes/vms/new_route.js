var AuthenticatedRoute = require('../authenticated_route');

// Vm Ember Route Class (inherit from auth route because restricted)
var VmsNewRoute = AuthenticatedRoute.extend({
  // Prepare model for create vm form
  model: function() {
    // Get all prjects, users and systemimages
    return Ember.RSVP.hash({
      projects: this.store.all('project'),
      users: this.store.all('user'),
      systemimages: this.store.all('systemimage'),
    });
  },

  // Setup the controller associated to the create form template
  setupController: function(controller, model) {
    this._super(controller, model);

    // Create a content empty object
    content = Ember.Object.create() ;
    
    // Bind models to the controller
    controller.set('model', content);
    controller.set('projects', model.projects);
    controller.set('users', model.users);
    controller.set('systemimages', model.systemimages);
    
    // Clear form
    controller.clearForm() ;

    // Check form
    controller.formIsValid() ;
  }
});

module.exports = VmsNewRoute;

