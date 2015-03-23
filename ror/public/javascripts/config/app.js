
// Enable transitions logging
var App = window.App = Ember.Application.create({
  LOG_TRANSITIONS:          true,
  LOG_TRANSITIONS_INTERNAL: true
});

// Define Api endpoint
App.ApplicationAdapter = DS.RESTAdapter.extend({
  namespace: 'api/v1',
});

// Define store object
App.Store = DS.Store.extend({
   revision: 11,
   adapter: App.ApplicationAdapter
});

module.exports = App;

