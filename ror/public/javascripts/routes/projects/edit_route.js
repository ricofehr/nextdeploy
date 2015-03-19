var AuthenticatedRoute = require('../authenticated_route');

// Project Ember Route Class (inherit from auth route because restricted)
var ProjectsEditRoute = AuthenticatedRoute.extend({
  // This controller needs lot of datas: brands, frameworks, technos, flavors, users 
  // and ofcourse the project following the parameter
  model: function(params) {
    return Ember.RSVP.hash({
      brandlist: this.store.all('brand'),
      frameworklist: this.store.all('framework'),
      technolist: this.store.all('techno'),
      flavorlist: this.store.all('flavor'),
      userlist: this.store.all('user'),
      project: this.store.find('project', params.project_id)
    });

  },

  // Same template than the create form
  renderTemplate:function () {
    this.render('projects/new') ;
  },

  // Setup the controller "projects.new" with this model
  setupController: function(controller, model) {
    this.controllerFor('projects.new').setProperties({model: model.project,
                                                      loadingButton: false,
                                                      gitpath: model.project.get('gitpath').replace(/^.*\//, ''),
                                                      project_users: model.project.get('users'),
                                                      project_technos: model.project.get('technos'),
                                                      project_flavors: model.project.get('flavors'),
                                                      brandlist: model.brandlist,
                                                      frameworklist: model.frameworklist,
                                                      technolist: model.technolist,
                                                      flavorlist: model.flavorlist,
                                                      userlist: model.userlist});
  },
});

module.exports = ProjectsEditRoute;