var AuthenticatedRoute = require('../authenticated_route');

// Sshkey Ember Route Class (inherit from auth route because restricted)
var SshkeysListRoute = AuthenticatedRoute.extend({
  model: function() {
      return this.store.all('sshkey') ;
  }
});

module.exports = SshkeysListRoute;

