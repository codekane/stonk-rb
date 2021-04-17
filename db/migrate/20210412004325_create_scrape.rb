class CreateScrape < ActiveRecord::Migration[6.0]
  def change
    create_table :scrapes do |t|
      t.datetime :date
    end
  end
end
