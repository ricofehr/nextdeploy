var AuthenticatedRoute = require('../authenticated_route');

// Vm Ember Route Class (inherit from auth route because restricted)
var VmsByprojectRoute = AuthenticatedRoute.extend({
  // Get the vms following an project_id
  model: function(params) {
    return this.store.find('vm', { project_id: params.project_id }) ;
  },

  // Same template than the standard list of vms
  renderTemplate:function () {
    this.render('vms/list') ;
  },

  // Setup the controller for vms.list with this model 
  setupController: function(controller, model) {
    this.controllerFor('vms.list').setProperties({content:model});
  },
});

module.exports = VmsByprojectRoute;

