// Ember model for vmsize object
var Vmsize = DS.Model.extend({
  title: DS.attr('string'),
  description: DS.attr('string'),
  projects: DS.hasMany('project', {async: true}),
  vms: DS.hasMany('vm', {async: true})
});

module.exports = Vmsize;

