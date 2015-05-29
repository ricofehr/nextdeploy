// Ember model for project object
var Project = DS.Model.extend({
  name: DS.attr('string'),
  gitpath: DS.attr('string'),
  enabled: DS.attr('boolean'),
  login: DS.attr('string'),
  password: DS.attr('string'),
  created_at: DS.attr('date'),
  brand: DS.belongsTo('brand', {async: true}),
  framework: DS.belongsTo('framework', {async: true}),
  systemimagetype: DS.belongsTo('systemimagetype', {async: true}),
  technos: DS.hasMany('techno', {async: true}),
  vmsizes: DS.hasMany('vmsize', {async: true}),
  users: DS.hasMany('user', {async: true}),
  vms: DS.hasMany('vm', {async: true}),
  branches: DS.hasMany('branche', {async: true})
});

module.exports = Project;

