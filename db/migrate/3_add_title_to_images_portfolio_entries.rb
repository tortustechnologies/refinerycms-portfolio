class AddTitleToImagesPortfolioEntries < ActiveRecord::Migration

  def self.up
    add_column :images_portfolio_entries, :title, :string
  end

  def self.down
    remove_column :images_portfolio_entries, :title
  end

end
