// Ember model for techno object
var Techno = DS.Model.extend({
  name: DS.attr('string'),
  puppetclass: DS.attr('string'),
  hiera: DS.attr('string'),
  projects: DS.hasMany('project', {async: true})
});

module.exports = Techno;

