var AuthenticatedRoute = require('../authenticated_route');

// Project Ember Route Class (inherit from auth route because restricted)
var ProjectsListRoute = AuthenticatedRoute.extend({
  // Get all projects object, but name must be valid
  model: function() {
    return this.store.all('project').filterBy('name').sort(['brand.name', 'name']) ;
  }
});

module.exports = ProjectsListRoute;

