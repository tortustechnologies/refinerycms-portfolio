class AddNavSettingsToPortfolioEntries < ActiveRecord::Migration

  def self.up
    change_table :portfolio_entries do |t|
      t.boolean :direction_nav, :default => false, :null => false
      t.boolean :control_nav, :default => false, :null => false
    end
  end

  def self.down
    change_table :portfolio_entries do |t|
      t.remove :direction_nav
      t.remove :control_nav
    end
  end

end

