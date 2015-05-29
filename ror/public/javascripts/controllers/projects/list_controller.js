// Ember controller for list projects into html array
var ProjectsListController = Ember.ArrayController.extend({
  // Sort order
  sortProperties: ['brand', 'name'],
  
  // Show / hide on html side
  isShowingDeleteConfirmation: false,
  isAllDelete: false,

  //filter projects array only with valid item for current user
  projects: Ember.computed.map('model', function(model){
    model.set('gitpath_href', "git@" + model.get('gitpath')) ;
    model.set('created_at_short', model.get('created_at').getDate() + "/" + (model.get('created_at').getMonth()+1) + "/" + model.get('created_at').getFullYear()) ;

    return model ;
  }),
  
  // Check if current user is admin
  isAdmin: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level == 50) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // Check if current user is lead
  isLead: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level >= 40) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // actions binding with user event
  actions: {
    // action to show gitpath into popin modal
    showGitpath: function(gitpath_href) {
      var modal = $('#textModal') ;
      modal.find('.modal-title').text('Git Path') ;
      modal.find('.modal-body').text('git clone ' + gitpath_href) ;
      modal.modal() ;
    },

    // action for delete event
    deleteItems: function() {
      var router = this.get('target');
      var projects = this.get('projects') ;
      var items = this.get('projects').filterBy('todelete', true) ;

      items.forEach(function(model) {
          model.destroyRecord() ;
          projects.removeObject(model) ;
      }) ;

      this.set('isShowingDeleteConfirmation', false) ;
      this.set('isAllDelete', false) ;
    },

    // Change hide/show for delete confirmation
    showDeleteConfirmation: function() {
      this.toggleProperty('isShowingDeleteConfirmation') ;
    },

    // Action for add a new item, change current page to create form
    newItem: function() {
      var router = this.get('target') ;
      router.transitionTo('projects.new') ;
    },

    // Toggle or untoggle all items
    toggleDeleteAll: function() {
      if (this.get('isAllDelete')) this.set('isAllDelete', false) ;
      else this.set('isAllDelete', true) ;

      this.setEach('todelete', this.get('isAllDelete'));
    },
  }
});

module.exports = ProjectsListController;