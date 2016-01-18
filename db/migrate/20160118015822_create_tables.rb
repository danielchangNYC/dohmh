class CreateTables < ActiveRecord::Migration
  def change
    create_table :establishments do |t|
      t.string  :camis,               null: false # dohmh's uniq indentifier
      t.string  :dba,                 null: false # establishment name, e.g. Nobu
      t.string  :boro,                null: false
      t.integer :zipcode,             null: false
      t.integer :phone
      t.string  :cuisine_description, null: false

      t.timestamps null: false
    end

    create_table :inspections do |t|
      # An inspection is an one inspection on a single day. there can be multiple violations
      t.integer  :establishment_id,   null: false
      t.string   :action,             null: false
      t.datetime :inspection_date,    null: false
      t.integer  :score
      t.string   :grade
      t.datetime :grade_date
      t.datetime :record_date
      t.string   :inspection_type

      t.timestamps null: false
    end

    create_table :inspection_violations do |t|
      # Inspections and Violations are a many-to-many relationship
      t.integer  :inspection_id,      null: false
      t.integer  :violation_id,       null: false

      t.timestamps null: false
    end

    create_table :violations do |t|
      # pulled violations out so that a user can view violations or view by violation
      t.string  :code,                null: false  # Unique identifier from CSV. CSV Field: violation_code.
      t.string  :description               # from violation_description
      t.boolean :critical,            null: false  # from critical_flag, which can be "Not Critical", "Critical" or nil

      t.timestamps null: false
    end
  end
end
