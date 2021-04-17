class CreateSearchesLinkStonks < ActiveRecord::Migration[6.0]
  def change
    create_table :searches do |t|
      t.timestamps
    end

    create_table :stonks do |t|
      t.references :stock, foreign_key: true
      t.references :search, foreign_key: true
      t.integer :count
    end
  end
end
