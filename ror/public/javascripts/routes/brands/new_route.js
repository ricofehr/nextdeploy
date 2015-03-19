var AuthenticatedRoute = require('../authenticated_route');

// Brand Ember Route Class (inherit from auth route because restricted)
var BrandsNewRoute = AuthenticatedRoute.extend({
  // Empty model
  model: function() {
    return Ember.Object.create();
  },

  // Setup controller
  setupController: function(controller, model) {
    this._super(controller, model) ;
    this.controllerFor('brands.new').clearForm() ;
  },
});

module.exports = BrandsNewRoute;

