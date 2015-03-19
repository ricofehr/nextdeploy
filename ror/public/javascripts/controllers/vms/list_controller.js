// Ember controller for list vm into html array
var VmsListController = Ember.ArrayController.extend({
  // Sort order
  sortProperties: ['project', 'commit'],
  
  // Show / hide on html side
  isShowingDeleteConfirmation: false,
  isAllDelete: false,

  // Filter model values for html display
  sortModel: function() {
    var model = this.get('model') ;
    var vmsFilter = model.filterBy('nova_id') ;
    var vmsSort = vmsFilter.sort('sortProperties') ;
    var vms = vmsSort.map(function (model) {
      model.set('created_at_short', model.get('created_at').getDate() + "/" + (model.get('created_at').getMonth() + 1) + "/" + model.get('created_at').getFullYear()) ;
      model.set('todelete', false) ;
      return model ;
    }) ;

    this.set('vms', vms) ;
  }.observes('model'),

  // Check if current user is admin
  isAdmin: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;

    if (access_level == 50) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // actions binding with user event
  actions: {
    // action to show vm uri into popin modal
    showUri: function(uri, login, password) {
      var modal = $('#textModal');
      modal.find('.modal-title').text('Urls');
      modal.find('.modal-body').html(
        '<a href="http://' + login + ':' + password + '@' + uri + '" target="_blank">'+ uri + '</a><br/>' +
        '<a href="http://' + login + ':' + password + '@' + 'admin.' + uri + '" target="_blank">admin.'+ uri + '</a><br/>' +
        '<a href="http://' + login + ':' + password + '@' + 'm.' + uri + '" target="_blank">m.'+ uri + '</a><br/>'
      );
      modal.modal();
    },

    // action for delete event
    deleteItems: function() {
      var router = this.get('target');
      var vms = this.get('vms') ;
      var items = this.filterProperty('todelete', true) ;

      items.forEach(function(model) {
        model.destroyRecord() ;
        vms.removeObject(model) ;
      }) ;

      this.set('isShowingDeleteConfirmation', false) ;
      this.set('isAllDelete', false) ;
      router.transitionTo('vms.list');
    },

    // Change hide/show for delete confirmation
    showDeleteConfirmation: function() {
      this.toggleProperty('isShowingDeleteConfirmation') ;
    },

    // Action for add a new item, change current page to create form
    newItem: function() {
      var router = this.get('target');
      router.transitionTo('vms.new');
    },

    // Toggle or untoggle all items
    toggleDeleteAll: function() {
      if (this.get('isAllDelete')) this.set('isAllDelete', false) ;
      else this.set('isAllDelete', true) ;
      this.setEach('todelete', this.get('isAllDelete'));
    },
  }
});

module.exports = VmsListController;
