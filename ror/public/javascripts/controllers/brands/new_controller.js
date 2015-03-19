// Ember controller for create brand form
var BrandsNewController = Ember.ObjectController.extend({
  //validation variables
  errorName: false,

  //validation function
  checkName: function() {
    var name = this.get('name') ;
    var errorName = false ;

    if (!name) {
      errorName = true ;
    }

    this.set('errorName', errorName) ;
  }.observes('name'),

  //check form before submit
  formIsValid: function() {
    this.checkName() ;

    if (!this.get('errorName')) return true ;
    return false ;
  }.observes('model'),

  //clear form
  clearForm: function() {
    this.set('name', null) ;
  },

  // actions binding with user event
  actions: {
    postItem: function() {
      var store = this.store;
      var router = this.get('target');
      var data = this.getProperties('id', 'name')
      var brand ;

      // check if form is valid
      if (!this.formIsValid()) {
        return ;
      }

      data['logo'] = null ;

      //if id is present, so update item, else create new one
      if(data['id']) {
        store.find('brand', data['id']).then(function (brand) {
          brand.setProperties(data) ;
          brand.save();
        });
      } else {
        brand = store.createRecord('brand', data) ;
        brand.save() ;
      }

      // Return to brands list page
      router.transitionTo('brands.list') ;
    },
  }
});

module.exports = BrandsNewController;

