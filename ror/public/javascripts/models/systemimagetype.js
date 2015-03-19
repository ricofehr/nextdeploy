// Ember model for systemimagetype object
var Systemimagetype = DS.Model.extend({
  name: DS.attr('string'),
  systemimages: DS.hasMany('systemimages', {async: true}),
  projects: DS.hasMany('projects', {async: true}),
});

module.exports = Systemimagetype;

