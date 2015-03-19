var AuthenticatedRoute = require('../authenticated_route');

// Brand Ember Route Class (inherit from auth route because restricted)
var BrandsListRoute = AuthenticatedRoute.extend({
  // Get all brands ember object
  model: function() {
    return this.store.all('brand') ;
  }
});

module.exports = BrandsListRoute;

