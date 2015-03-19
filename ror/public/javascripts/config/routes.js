var App = require('./app');

// EMber router
App.Router.map(function() {
  // Signin routes
  this.resource('sessions', function() {
    this.route('new');
  });

  // User routes
  this.resource('users', function() {
    this.route('list');
    this.route('new');
    this.route('bygroup', { path:'/bygroup/:group_id' });
    this.route('byproject', { path:'/byproject/:project_id' });
    this.route('edit', { path:'/edit/:user_id' });
  })

  // Vm routes
  this.resource('vms', function() {
    this.route('list');
    this.route('new');
    this.route('byuser', { path:'/byuser/:user_id' });
    this.route('byproject', { path:'/byproject/:project_id' });
  })

  // Project routes
  this.resource('projects', function() {
    this.route('list');
    this.route('new');
    this.route('edit', { path:'/edit/:project_id' });
    this.route('bybrand', { path:'/bybrand/:brand_id' });
    this.route('byuser', { path:'/byuser/:user_id' });
  })

  // Sshkey routes
  this.resource('sshkeys', function() {
    this.route('list');
    this.route('byuser', { path:'/byuser/:user_id' });
    this.route('bygroup', { path:'/bygroup/:group_id' });
    this.route('new');
    this.route('edit', { path:'/edit/:sshkey_id' });
  })

  // Brand routes
  this.resource('brands', function() {
    this.route('list');
    this.route('new');
    this.route('edit', { path:'/edit/:brand_id' });
  })
});
