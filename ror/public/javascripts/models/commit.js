// Ember model for commit object
var Commit = DS.Model.extend({
  commit_hash: DS.attr('string'),
  short_id: DS.attr('string'),
  title: DS.attr('string'),
  author_name: DS.attr('string'),
  author_email: DS.attr('string'),
  message: DS.attr('string'),
  created_at: DS.attr('date'),
  branche: DS.belongsTo('branche', {async: true}),
  vms: DS.hasMany('vm', {async: true})
});

module.exports = Commit;

