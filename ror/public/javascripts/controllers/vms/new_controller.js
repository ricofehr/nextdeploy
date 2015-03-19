// Ember controller for create vm form
var VmsNewController = Ember.ObjectController.extend({
  computeSorting: ['name'],

  //project combobox
  projectsFilter: Ember.computed.filterBy('projects', 'name'),
  projectsSort: Ember.computed.sort('projectsFilter', 'computeSorting'),

  //system combobox
  selectedSystem: null,
  osSort: null,

  //users combobox
  emailSorting: ['email'],
  usersSort: Ember.computed.sort('users', 'emailSorting'),

  //init to null parameters
  selectedProject: null,
  selectedUser: null,
  selectedBranch: null,
  selectedCommit: null,
  selectedOs: null,
  usersList: null,
  flavorsList: null,
  selectedFlavor: null,
  
  //validation variables
  errorProject: false,
  errorUser: false,
  errorBranch: false,
  errorCommit: false,
  errorOs: false,
  errorFlavor: false,

  //validation function
  checkProject: function() {
    var project = this.get('selectedProject') ;
    var errorProject = false ;

    if (!project) {
      errorProject = true ;
    }

    this.set('errorProject', errorProject) ;
  }.observes('selectedProject'),

  checkUser: function() {
    var user = this.get('selectedUser') ;
    var errorUser = false ;

    if (user == null) {
      errorUser = true ;
    }

    this.set('errorUser', errorUser) ;
  }.observes('selectedUser'),

  checkBranch: function() {
    var branch = this.get('selectedBranch') ;
    var errorBranch = false ;

    if (!branch) {
      errorBranch = true ;
    }

    this.set('errorBranch', errorBranch) ;
  }.observes('selectedBranch'),

  checkCommit: function() {
    var commit = this.get('selectedCommit') ;
    var errorCommit = false ;

    if (!commit) {
      errorCommit = true ;
    }

    this.set('errorCommit', errorCommit) ;
  }.observes('selectedCommit'),

  checkOs: function() {
    var os = this.get('selectedOs') ;
    var errorOs = false ;

    if (!os) {
      errorOs = true ;
    }

    this.set('errorOs', errorOs) ;
  }.observes('selectedOs'),

  checkFlavor: function() {
    var flavor = this.get('selectedFlavor') ;
    var errorFlavor = false ;

    if (!flavor) {
      errorFlavor = true ;
    }

    this.set('errorFlavor', errorFlavor) ;
  }.observes('selectedFlavor'),

  //check form before submit
  formIsValid: function() {
    this.checkProject() ;
    this.checkUser() ;
    this.checkBranch() ;
    this.checkCommit() ;
    this.checkOs() ;
    this.checkFlavor() ;

    if (!this.get('errorProject') &&
        !this.get('errorUser') &&
        !this.get('errorBranch') &&
        !this.get('errorCommit') &&
        !this.get('errorOs') &&
        !this.get('errorFlavor')) return true ;
    return false ;
  },

  //clear form
  clearForm: function() {
    this.set('selectedProject', null) ;
    this.set('selectedUser', null) ;
    this.set('selectedBranch', null) ;
    this.set('selectedCommit', null) ;
    this.set('selectedOs', null) ;
    this.set('selectedFlavor', null) ;
  },

  // project change event
  projectChange: function() {
    //if selectedproject was flushed, flush usersList
    if (!this.get('selectedProject')) {
      this.set('usersList', []) ;
      this.set('osSort', []) ;
      this.set('flavorsList', []) ;
      return ;
    }

    //first, change users combobox
    var users = this.get('selectedProject').get('users').toArray() ;
    var access_level = App.AuthManager.get('apiKey.accessLevel') ;
    var systemtype = null ;

    if (access_level < 40) {
      this.get('selectedProject').get('users').toArray().forEach(function (user){
        if (user && user.id != App.AuthManager.get('apiKey.user')) {
              users.removeObject(user) ;
        }
      });
    }

    this.set('usersList', users) ;

    //flavor combobox
    this.set('flavorsList', this.get('selectedProject').get('flavors')) ;

    //and the system combobox
    systemtype = this.get('selectedProject').get('systemimagetype') ;
    this.set('osSort', this.get('systemimages').filterBy('systemimagetype.id', systemtype.get('id'))) ;
  }.observes('selectedProject'),


  actions: {
    // Submit form
    createItem: function() {
      var router = this.get('target');

      var data = {} ;
      var store = this.store;

      // get the values from the form
      var selectedProject = this.get('selectedProject') ;
      var selectedCommit = this.get('selectedCommit') ;
      var selectedUser = this.get('selectedUser') ;
      var selectedOs = this.get('selectedOs') ;
      var selectedFlavor = this.get('selectedFlavor') ;

      // check if form is valid
      if (!this.formIsValid()) {
        return ;
      }

      // format value for the post request
      data['commit'] = selectedCommit ;
      data['project'] = selectedProject ;
      data['user'] = selectedUser ;
      data['systemimage'] = selectedOs ;
      data['flavor'] = selectedFlavor ;
      
      // create a vm object for the rest post request
      vm = store.createRecord('vm', data) ;

      selectedUser.get('vms').pushObject(vm) ;
      selectedProject.get('vms').pushObject(vm) ;
      selectedOs.get('vms').pushObject(vm) ;
      selectedCommit.get('vms').pushObject(vm) ;

      //loader because 10s to complete create vm
      $('#waitingModal').modal() ;
      vm.save().then(function() {
        router.transitionTo('vms.list');
        $('#waitingModal').modal('hide') ;
      }) ;

    }
  }
});

module.exports = VmsNewController;