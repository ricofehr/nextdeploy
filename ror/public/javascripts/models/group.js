// Ember model for group object
var Group = DS.Model.extend({
  name: DS.attr('string'),
  access_level: DS.attr('number'),
  users: DS.hasMany('user', {async: true})
});

module.exports = Group;

