// Ember model for branche object
var Branche = DS.Model.extend({
  name: DS.attr('string'),
  project: DS.belongsTo('project', {async: true}),
  commits: DS.hasMany('commit', {async: true})
});

module.exports = Branche;