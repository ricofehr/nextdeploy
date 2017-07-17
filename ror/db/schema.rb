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

ActiveRecord::Schema.define(version: 20170626135653) do

  create_table "brands", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "logo",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "endpoints", force: :cascade do |t|
    t.integer "project_id",   limit: 4
    t.integer "framework_id", limit: 4
    t.string  "prefix",       limit: 255
    t.string  "path",         limit: 255
    t.string  "envvars",      limit: 512
    t.string  "aliases",      limit: 1024
    t.integer "port",         limit: 4
    t.string  "ipfilter",     limit: 512,  default: ""
    t.string  "customvhost",  limit: 4096, default: ""
    t.boolean "is_sh",                     default: false
    t.boolean "is_import",                 default: true
    t.boolean "is_main",                   default: false
    t.boolean "is_ssl",                    default: false
  end

  add_index "endpoints", ["framework_id"], name: "index_endpoints_on_framework_id", using: :btree
  add_index "endpoints", ["project_id"], name: "index_endpoints_on_project_id", using: :btree

  create_table "frameworks", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "publicfolder",  limit: 255
    t.text     "rewrites",      limit: 65535
    t.string   "dockercompose", limit: 8192
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.integer  "access_level", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "hpmessages", force: :cascade do |t|
    t.string  "title",            limit: 255
    t.text    "message",          limit: 65535
    t.integer "access_level_min", limit: 4
    t.integer "access_level_max", limit: 4
    t.integer "expiration",       limit: 4
    t.integer "ordering",         limit: 4
    t.boolean "is_twitter"
    t.string  "date",             limit: 255,   default: ""
  end

  create_table "project_systemimages", force: :cascade do |t|
    t.integer "project_id",     limit: 4
    t.integer "systemimage_id", limit: 4
  end

  add_index "project_systemimages", ["project_id"], name: "index_project_systemimages_on_project_id", using: :btree
  add_index "project_systemimages", ["systemimage_id"], name: "index_project_systemimages_on_systemimage_id", using: :btree

  create_table "project_technos", force: :cascade do |t|
    t.integer  "project_id",       limit: 4
    t.integer  "techno_id",        limit: 4
    t.text     "setting_override", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "project_technos", ["project_id"], name: "index_project_technos_on_project_id", using: :btree
  add_index "project_technos", ["techno_id"], name: "index_project_technos_on_techno_id", using: :btree

  create_table "project_vmsizes", force: :cascade do |t|
    t.integer "project_id", limit: 4
    t.integer "vmsize_id",  limit: 4
  end

  add_index "project_vmsizes", ["project_id"], name: "index_project_vmsizes_on_project_id", using: :btree
  add_index "project_vmsizes", ["vmsize_id"], name: "index_project_vmsizes_on_vmsize_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "gitpath",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brand_id",   limit: 4
    t.boolean  "enabled"
    t.integer  "gitlab_id",  limit: 4
    t.string   "login",      limit: 255
    t.string   "password",   limit: 255
    t.integer  "owner_id",   limit: 4
    t.boolean  "is_ht",                  default: false
  end

  add_index "projects", ["brand_id"], name: "index_projects_on_brand_id", using: :btree
  add_index "projects", ["owner_id"], name: "index_projects_on_owner_id", using: :btree

  create_table "sshkeys", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.text     "key",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
    t.integer  "gitlab_id",  limit: 4
    t.string   "shortname",  limit: 255
  end

  add_index "sshkeys", ["user_id"], name: "index_sshkeys_on_user_id", using: :btree

  create_table "systemimages", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "glance_id",          limit: 255
    t.boolean  "enabled"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "systemimagetype_id", limit: 4
  end

  add_index "systemimages", ["systemimagetype_id"], name: "index_systemimages_on_systemimagetype_id", using: :btree

  create_table "systemimagetypes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "technos", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.string   "puppetclass",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "hiera",         limit: 65535
    t.integer  "ordering",      limit: 4
    t.integer  "technotype_id", limit: 4
    t.string   "dockercompose", limit: 255
    t.string   "playbook",      limit: 8192
  end

  add_index "technos", ["technotype_id"], name: "index_technos_on_technotype_id", using: :btree

  create_table "technotypes", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "uris", force: :cascade do |t|
    t.integer "vm_id",          limit: 4
    t.integer "framework_id",   limit: 4
    t.string  "absolute",       limit: 512
    t.string  "path",           limit: 255
    t.string  "envvars",        limit: 512
    t.string  "aliases",        limit: 2048
    t.integer "port",           limit: 4
    t.string  "ipfilter",       limit: 512,  default: ""
    t.string  "customvhost",    limit: 4096, default: ""
    t.boolean "is_sh",                       default: false
    t.boolean "is_import",                   default: true
    t.boolean "is_redir_alias",              default: false
    t.boolean "is_main",                     default: false
    t.boolean "is_ssl",                      default: false
  end

  add_index "uris", ["framework_id"], name: "index_uris_on_framework_id", using: :btree
  add_index "uris", ["vm_id"], name: "index_uris_on_vm_id", using: :btree

  create_table "user_projects", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "project_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_projects", ["project_id"], name: "index_user_projects_on_project_id", using: :btree
  add_index "user_projects", ["user_id"], name: "index_user_projects_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "authentication_token",   limit: 255
    t.integer  "quotavm",                limit: 4
    t.string   "company",                limit: 255
    t.integer  "gitlab_id",              limit: 4
    t.integer  "group_id",               limit: 4
    t.string   "firstname",              limit: 255
    t.string   "lastname",               limit: 255
    t.boolean  "is_project_create",                  default: false
    t.string   "layout",                 limit: 15
    t.boolean  "is_user_create",                     default: false
    t.integer  "quotaprod",              limit: 4,   default: 0
    t.integer  "nbpages",                limit: 4,   default: 11
    t.boolean  "is_recv_vms",                        default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["group_id"], name: "index_users_on_group_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vm_technos", force: :cascade do |t|
    t.integer  "vm_id",      limit: 4
    t.integer  "techno_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "status",               default: true
  end

  add_index "vm_technos", ["techno_id"], name: "index_vm_technos_on_techno_id", using: :btree
  add_index "vm_technos", ["vm_id"], name: "index_vm_technos_on_vm_id", using: :btree

  create_table "vms", force: :cascade do |t|
    t.integer  "project_id",     limit: 4
    t.integer  "user_id",        limit: 4
    t.integer  "systemimage_id", limit: 4
    t.string   "commit_id",      limit: 255
    t.string   "nova_id",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",           limit: 255
    t.integer  "vmsize_id",      limit: 4
    t.integer  "status",         limit: 4
    t.boolean  "is_auth",                    default: true
    t.string   "htlogin",        limit: 255
    t.string   "htpassword",     limit: 255
    t.string   "termpassword",   limit: 255
    t.string   "layout",         limit: 15
    t.boolean  "is_prod",                    default: false
    t.boolean  "is_cached",                  default: false
    t.boolean  "is_ht",                      default: false
    t.boolean  "is_backup",                  default: false
    t.boolean  "is_ci",                      default: false
    t.boolean  "is_cors"
    t.string   "topic",          limit: 255
    t.boolean  "is_ro",                      default: false
    t.boolean  "is_jenkins",                 default: false
    t.boolean  "is_offline",                 default: false
  end

  add_index "vms", ["project_id"], name: "index_vms_on_project_id", using: :btree
  add_index "vms", ["systemimage_id"], name: "index_vms_on_systemimage_id", using: :btree
  add_index "vms", ["user_id"], name: "index_vms_on_user_id", using: :btree

  create_table "vmsizes", force: :cascade do |t|
    t.string "title",       limit: 255
    t.text   "description", limit: 65535
  end

end
