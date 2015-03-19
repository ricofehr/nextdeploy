// Ember model for flavor object
var Flavor = DS.Model.extend({
  title: DS.attr('string'),
  description: DS.attr('string'),
  projects: DS.hasMany('project', {async: true}),
  vms: DS.hasMany('vm', {async: true})
});

module.exports = Flavor;

