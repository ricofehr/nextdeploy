var AuthenticatedRoute = require('../authenticated_route');

// Project Ember Route Class (inherit from auth route because restricted)
var ProjectsNewRoute = AuthenticatedRoute.extend({
  // This controller needs lot of datas: brands, frameworks, technos, flavors, users 
  model: function() {
    return Ember.RSVP.hash({
      brandlist: this.store.all('brand'),
      frameworklist: this.store.all('framework'),
      technolist: this.store.all('techno'),
      vmsizelist: this.store.all('vmsize'),
      userlist: this.store.all('user'),
      systemlist: this.store.all('systemimagetype'),
      groups: this.store.all('group')
    });
  },

  // Setup the controller with thie model
  setupController: function(controller, model) {
    content = Ember.Object.create() ;
    content.set('brand', {content: null}) ;
    content.set('framework', {content: null}) ;
    content.set('systemimagetype', {content: null}) ;

    this.controllerFor('projects.new').setProperties({model: content}) ;
    this.controllerFor('projects.new').clearForm() ;
    this.controllerFor('projects.new').setProperties({brandlist: model.brandlist,
                                                      frameworklist: model.frameworklist,
                                                      technolist: model.technolist,
                                                      vmsizelist: model.vmsizelist,
                                                      userlist: model.userlist,
                                                      systemlist: model.systemlist,
                                                      groups: model.groups});
  }
});

module.exports = ProjectsNewRoute;

