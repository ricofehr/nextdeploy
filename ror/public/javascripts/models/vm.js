// Ember model for vm object
var Vm = DS.Model.extend({
  commit: DS.belongsTo('commit', {async: true}),
  name: DS.attr('string'),
  nova_id: DS.attr('string'),
  floating_ip: DS.attr('string'),
  user: DS.belongsTo('user', {async: true}),
  project: DS.belongsTo('project', {async: true}),
  systemimage: DS.belongsTo('systemimage', {async: true}),
  vmsize: DS.belongsTo('vmsize', {async: true}),
  created_at: DS.attr('date')
});

module.exports = Vm;

