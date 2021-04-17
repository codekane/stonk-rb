class CreateJoinTableScrapeStonk < ActiveRecord::Migration[6.0]
  def change
    create_join_table :scrapes, :stonks do |t|
      # t.index [:scrape_id, :stonk_id]
      # t.index [:stonk_id, :scrape_id]
    end
  end
end
