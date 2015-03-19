// Ember controller for list ssh keys into html array
var SshkeysListController = Ember.ArrayController.extend({
  // Sort order
  sortProperties: ['user.group', 'user.email', 'name'],

  // Show / hide on html side
  isShowingDeleteConfirmation: false,
  isAllDelete: false,

  // actions binding with user event
  actions: {
    // action for delete event
    deleteItems: function() {
      var router = this.get('target');
      var items = this.filterProperty('todelete', true) ;

      for(i=0; i<items.length; i++) {
        if (items[i].todelete) { items[i].destroyRecord() ; }
      }

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
      router.transitionTo('sshkeys.new') ;
    },

    // Toggle or untoggle all items
    toggleDeleteAll: function() {
      if (this.get('isAllDelete')) this.set('isAllDelete', false) ;
      else this.set('isAllDelete', true) ;
      this.setEach('todelete', this.get('isAllDelete'));
    }
  }
});

module.exports = SshkeysListController;

