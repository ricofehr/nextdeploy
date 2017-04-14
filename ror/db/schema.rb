# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170413134410) do

  create_table "brands", force: true do |t|
    t.string   "name"
    t.string   "logo"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "endpoints", force: true do |t|
    t.integer "project_id"
    t.integer "framework_id"
    t.string  "prefix"
    t.string  "path"
    t.string  "envvars",      limit: 512
    t.string  "aliases",      limit: 1024
    t.integer "port"
    t.string  "ipfilter",     limit: 512,  default: ""
    t.string  "customvhost",  limit: 4096, default: ""
    t.boolean "is_sh",                     default: false
    t.boolean "is_import",                 default: true
    t.boolean "is_main",                   default: false
  end

  add_index "endpoints", ["framework_id"], name: "index_endpoints_on_framework_id", using: :btree
  add_index "endpoints", ["project_id"], name: "index_endpoints_on_project_id", using: :btree

  create_table "frameworks", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "publicfolder"
    t.text     "rewrites"
    t.string   "dockercompose", limit: 8192
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.integer  "access_level"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hpmessages", force: true do |t|
    t.string  "title"
    t.text    "message"
    t.integer "access_level_min"
    t.integer "access_level_max"
    t.integer "expiration"
    t.integer "ordering"
    t.boolean "is_twitter"
    t.string  "date",             default: ""
  end

  create_table "project_systemimages", force: true do |t|
    t.integer "project_id"
    t.integer "systemimage_id"
  end

  add_index "project_systemimages", ["project_id"], name: "index_project_systemimages_on_project_id", using: :btree
  add_index "project_systemimages", ["systemimage_id"], name: "index_project_systemimages_on_systemimage_id", using: :btree

  create_table "project_technos", force: true do |t|
    t.integer  "project_id"
    t.integer  "techno_id"
    t.text     "setting_override"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_technos", ["project_id"], name: "index_project_technos_on_project_id", using: :btree
  add_index "project_technos", ["techno_id"], name: "index_project_technos_on_techno_id", using: :btree

  create_table "project_vmsizes", force: true do |t|
    t.integer "project_id"
    t.integer "vmsize_id"
  end

  add_index "project_vmsizes", ["project_id"], name: "index_project_vmsizes_on_project_id", using: :btree
  add_index "project_vmsizes", ["vmsize_id"], name: "index_project_vmsizes_on_vmsize_id", using: :btree

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "gitpath"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id"
    t.boolean  "enabled"
    t.integer  "gitlab_id"
    t.string   "login"
    t.string   "password"
    t.integer  "owner_id"
    t.boolean  "is_ht",      default: false
  end

  add_index "projects", ["brand_id"], name: "index_projects_on_brand_id", using: :btree
  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree

  create_table "sshkeys", force: true do |t|
    t.integer  "user_id"
    t.text     "key"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "gitlab_id"
    t.string   "shortname"
  end

  add_index "sshkeys", ["user_id"], name: "index_sshkeys_on_user_id", using: :btree

  create_table "systemimages", force: true do |t|
    t.string   "name"
    t.string   "glance_id"
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "systemimagetype_id"
  end

  add_index "systemimages", ["systemimagetype_id"], name: "index_systemimages_on_systemimagetype_id", using: :btree

  create_table "systemimagetypes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technos", force: true do |t|
    t.string   "name"
    t.string   "puppetclass"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "hiera"
    t.integer  "ordering"
    t.integer  "technotype_id"
    t.string   "dockercompose"
    t.string   "playbook",      limit: 8192
  end

  add_index "technos", ["technotype_id"], name: "index_technos_on_technotype_id", using: :btree

  create_table "technotypes", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uris", force: true do |t|
    t.integer "vm_id"
    t.integer "framework_id"
    t.string  "absolute",       limit: 512
    t.string  "path"
    t.string  "envvars",        limit: 512
    t.string  "aliases",        limit: 2048
    t.integer "port"
    t.string  "ipfilter",       limit: 512,  default: ""
    t.string  "customvhost",    limit: 4096, default: ""
    t.boolean "is_sh",                       default: false
    t.boolean "is_import",                   default: true
    t.boolean "is_redir_alias",              default: false
    t.boolean "is_main",                     default: false
  end

  add_index "uris", ["framework_id"], name: "index_uris_on_framework_id", using: :btree
  add_index "uris", ["vm_id"], name: "index_uris_on_vm_id", using: :btree

  create_table "user_projects", force: true do |t|
    t.integer  "user_id"
    t.integer  "project_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_projects", ["project_id"], name: "index_user_projects_on_project_id", using: :btree
  add_index "user_projects", ["user_id"], name: "index_user_projects_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                             default: "",    null: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token"
    t.integer  "quotavm"
    t.string   "company"
    t.integer  "gitlab_id"
    t.integer  "group_id"
    t.string   "firstname"
    t.string   "lastname"
    t.boolean  "is_project_create",                 default: false
    t.string   "layout",                 limit: 15
    t.boolean  "is_user_create",                    default: false
    t.integer  "quotaprod",                         default: 0
    t.integer  "nbpages",                           default: 11
    t.boolean  "is_recv_vms",                       default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["group_id"], name: "index_users_on_group_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vm_technos", force: true do |t|
    t.integer  "vm_id"
    t.integer  "techno_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",     default: true
  end

  add_index "vm_technos", ["techno_id"], name: "index_vm_technos_on_techno_id", using: :btree
  add_index "vm_technos", ["vm_id"], name: "index_vm_technos_on_vm_id", using: :btree

  create_table "vms", force: true do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "systemimage_id"
    t.string   "commit_id"
    t.string   "nova_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "vmsize_id"
    t.integer  "status"
    t.boolean  "is_auth",                   default: true
    t.string   "htlogin"
    t.string   "htpassword"
    t.string   "termpassword"
    t.string   "layout",         limit: 15
    t.boolean  "is_prod",                   default: false
    t.boolean  "is_cached",                 default: false
    t.boolean  "is_ht",                     default: false
    t.boolean  "is_backup",                 default: false
    t.boolean  "is_ci",                     default: false
    t.boolean  "is_cors"
    t.string   "topic"
    t.boolean  "is_ro",                     default: false
  end

  add_index "vms", ["project_id"], name: "index_vms_on_project_id", using: :btree
  add_index "vms", ["systemimage_id"], name: "index_vms_on_systemimage_id", using: :btree
  add_index "vms", ["user_id"], name: "index_vms_on_user_id", using: :btree

  create_table "vmsizes", force: true do |t|
    t.string "title"
    t.text   "description"
  end

end
