class CreateStonks < ActiveRecord::Migration[6.0]
  def change
    create_table :stonks do |t|
      t.string :symbol
    end
  end
end
