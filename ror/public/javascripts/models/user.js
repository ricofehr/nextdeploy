// Ember model for user object
var User = DS.Model.extend({
  email:    DS.attr('string'),
  authentication_token: DS.attr('string'),
  company: DS.attr('string'),
  quotavm: DS.attr('number'),
  password: DS.attr('string'),
  password_confirmation: DS.attr('string'),
  group: DS.belongsTo('group', {async: true}),
  vms: DS.hasMany('vm', {async: true}),
  projects: DS.hasMany('project', {async: true}),
  sshkeys: DS.hasMany('sshkey', {async: true})
});

module.exports = User;