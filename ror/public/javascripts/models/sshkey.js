// Ember model for sshkey object
var Sshkey = DS.Model.extend({
  name: DS.attr('string'),
  key: DS.attr('string'),
  user: DS.belongsTo('user', {async: true})
});

module.exports = Sshkey;

