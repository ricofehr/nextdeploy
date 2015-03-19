// Ember model for systemimage object
var Systemimage = DS.Model.extend({
  name: DS.attr('string'),
  glance_id: DS.attr('string'),
  enabled: DS.attr('boolean'),
  vms: DS.hasMany('vm', {async: true}),
  systemimagetype: DS.belongsTo('systemimagetype', {async: true})
});

module.exports = Systemimage;

