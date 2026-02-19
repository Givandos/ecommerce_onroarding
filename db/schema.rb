# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_17_151213) do
  create_table "categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "industry_id", null: false
    t.string "location"
    t.string "name"
    t.string "size"
    t.string "subscription_tier"
    t.datetime "updated_at", null: false
    t.index ["industry_id"], name: "index_companies_on_industry_id"
  end

  create_table "company_settings", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "days_of_stock"
    t.integer "default_lead_time"
    t.integer "forecasting_days"
    t.string "integration_type"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_company_settings_on_company_id"
  end

  create_table "industries", force: :cascade do |t|
    t.string "name"
  end

  create_table "onboarding_progresses", force: :cascade do |t|
    t.integer "company_id", null: false
    t.json "completed_steps", default: {}
    t.datetime "created_at", null: false
    t.integer "current_step_id"
    t.integer "status", default: 1
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_onboarding_progresses_on_company_id"
    t.index ["current_step_id"], name: "index_onboarding_progresses_on_current_step_id"
  end

  create_table "onboarding_steps", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.integer "position"
    t.integer "required_step_id"
    t.string "required_sync_type"
    t.boolean "skippable", default: true
    t.string "slug"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.integer "category_id", null: false
    t.integer "company_id", null: false
    t.decimal "cost"
    t.datetime "created_at", null: false
    t.integer "lead_time"
    t.string "name"
    t.decimal "price"
    t.string "sku"
    t.integer "supplier_id_id"
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_products_on_category_id"
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["supplier_id_id"], name: "index_products_on_supplier_id_id"
  end

  create_table "sales_histories", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.date "date"
    t.integer "product_id", null: false
    t.decimal "quantity"
    t.decimal "sales_price"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_sales_histories_on_company_id"
    t.index ["product_id"], name: "index_sales_histories_on_product_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "avg_lead_time"
    t.integer "company_id", null: false
    t.string "country"
    t.datetime "created_at", null: false
    t.string "name"
    t.string "reliability_score"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_vendors_on_company_id"
  end

  create_table "warehouses", force: :cascade do |t|
    t.string "capacity"
    t.integer "company_id", null: false
    t.datetime "created_at", null: false
    t.string "location"
    t.string "name"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_warehouses_on_company_id"
  end

  add_foreign_key "companies", "industries"
  add_foreign_key "company_settings", "companies"
  add_foreign_key "onboarding_progresses", "companies"
  add_foreign_key "onboarding_progresses", "onboarding_steps", column: "current_step_id"
  add_foreign_key "products", "categories"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "vendors", column: "supplier_id_id"
  add_foreign_key "sales_histories", "companies"
  add_foreign_key "sales_histories", "products"
  add_foreign_key "users", "companies"
  add_foreign_key "vendors", "companies"
  add_foreign_key "warehouses", "companies"
end
