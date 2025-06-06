class RemoveAraskJob < ActiveRecord::Migration[8.0]
  def change
    drop_table "arask_jobs", force: :cascade do |t|
      t.string "job"
      t.datetime "execute_at", precision: nil
      t.string "interval"
      t.index ["execute_at"], name: "index_arask_jobs_on_execute_at"
    end
  end
end
