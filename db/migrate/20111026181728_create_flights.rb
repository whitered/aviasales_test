class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.references :origin
      t.references :destination
      t.datetime :departure
      t.datetime :arrival
      t.integer :price

      t.timestamps
    end

    add_index :flights, :origin_id
    add_index :flights, :destination_id
    add_index :flights, :departure
    add_index :flights, :arrival
  end
end
