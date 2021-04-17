class CreateStonk < ActiveRecord::Migration[6.0]
  def change
    create_table :stonks do |t|
      t.string :symbol, null: false
    end
  end
end
