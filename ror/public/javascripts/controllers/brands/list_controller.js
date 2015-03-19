// Ember controller for list brands into html array
var BrandsListController = Ember.ArrayController.extend({
  // Sort order
  sortProperties: ['name'],
  
  // Show / hide on html side
  isShowingDeleteConfirmation: false,
  isAllDelete: false,

  // Check if current user is admin
  isAdmin: function() {
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;
    if (access_level == 50) return true ;
    return false ;
  }.property('App.AuthManager.apiKey'),

  // actions binding with user event
  actions: {
    // action for delete event
    deleteItems: function() {
      var router = this.get('target');
      var items = this.filterProperty('todelete', true) ;

      items.forEach(function(model) {
        model.destroyRecord() ;
      }) ;

      this.set('isShowingDeleteConfirmation', false) ;
      this.set('isAllDelete', false) ;
      router.transitionTo('brands.list');
    },

    // Change hide/show for delete confirmation
    showDeleteConfirmation: function() {
      this.toggleProperty('isShowingDeleteConfirmation') ;
    },

    // Action for add a new item, change current page to create form
    newItem: function() {
      var router = this.get('target') ;
      router.transitionTo('brands.new') ;
    },

    // Toggle or untoggle all items
    toggleDeleteAll: function() {
      if (this.get('isAllDelete')) this.set('isAllDelete', false) ;
      else this.set('isAllDelete', true) ;
      this.setEach('todelete', this.get('isAllDelete'));
    },
  }
});

module.exports = BrandsListController;

