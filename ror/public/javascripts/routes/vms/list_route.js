var AuthenticatedRoute = require('../authenticated_route');

// Vm Ember Route Class (inherit from auth route because restricted)
var VmsListRoute = AuthenticatedRoute.extend({
  // Init model for the list
  model: function() {
    // Get all vms from ember datas
    return this.store.all('vm').filterBy('project').sort(['project']) ;
  },
});

module.exports = VmsListRoute;

