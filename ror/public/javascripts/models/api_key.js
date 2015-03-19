// Ember.Object instead of DS.Model because this will never persist to or query the server
var ApiKey = Ember.Object.extend({
  access_token: '',
  user: 0,
  group: 0,
  access_level: 0
});

module.exports = ApiKey;

