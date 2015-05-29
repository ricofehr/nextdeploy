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
      vmsizelist: this.store.all('vmsize'),
      userlist: this.store.all('user'),
      systemlist: this.store.all('systemimagetype'),
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
                                                      project_vmsizes: model.project.get('vmsizes'),
                                                      brandlist: model.brandlist,
                                                      frameworklist: model.frameworklist,
                                                      technolist: model.technolist,
                                                      vmsizelist: model.vmsizelist,
                                                      userlist: model.userlist,
                                                      systemlist: model.systemlist});
  },
  
});

module.exports = ProjectsEditRoute;