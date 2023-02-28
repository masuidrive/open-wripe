class CreatePageDates < ActiveRecord::Migration[4.2]
  def change
    create_table :page_dates do |t|
      t.integer :page_id
      t.integer :user_id
      t.date :date

      t.timestamps
    end
    add_index :page_dates, [:page_id]
    add_index :page_dates, [:user_id, :date]
  end
end
