// Ember model for framework object
var Framework = DS.Model.extend({
  name: DS.attr('string'),
  publicfolder: DS.attr('string'),
  rewrites: DS.attr('string'),
  projects: DS.hasMany('project', {async: true})
});

module.exports = Framework;

