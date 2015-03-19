var AuthenticatedRoute = require('../authenticated_route');

// Brand Ember Route Class (inherit from auth route because restricted)
var BrandsEditRoute = AuthenticatedRoute.extend({
  // Get the bran following the parameter
  model: function(params) {
    return this.store.find('brand', params.brand_id) ;
  },

  // Same template than the create form
  renderTemplate:function () {
    this.render('brands/new') ;
  },

  // Setup the controller "brands.new" with this model
  setupController: function(controller, model) {
    this.controllerFor('brands.new').setProperties({content:model});
  },
});

module.exports = BrandsEditRoute;

