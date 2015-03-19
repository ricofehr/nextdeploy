// Ember model for brand object
var Brand = DS.Model.extend({
  name: DS.attr('string'),
  logo: DS.attr('string'),
  projects: DS.hasMany('project', {async: true})
});

module.exports = Brand;

