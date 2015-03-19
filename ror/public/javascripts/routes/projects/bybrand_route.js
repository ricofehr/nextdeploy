var AuthenticatedRoute = require('../authenticated_route');

// Project Ember Route Class (inherit from auth route because restricted)
var ProjectsBybrandRoute = AuthenticatedRoute.extend({
  // Get the projects following an brand_id
  model: function(params) {
    return this.store.find('project', { brand_id: params.brand_id }) ;
  },

  // Same template than the standard list
  renderTemplate:function () {
    this.render('projects/list') ;
  },

  // Setup the controller "projects.list" with this model
  setupController: function(controller, model) {
    this.controllerFor('projects.list').setProperties({content:model});
  },
});

module.exports = ProjectsBybrandRoute;

