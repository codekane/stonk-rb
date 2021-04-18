class RenameSearchesStonksToSearchStonks < ActiveRecord::Migration[6.0]
  def change
    rename_table :searches_stonks, :search_stonks
  end
end
