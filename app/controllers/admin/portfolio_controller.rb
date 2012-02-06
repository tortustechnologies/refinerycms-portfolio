class Admin::PortfolioController < Admin::BaseController

  helper :portfolio

  crudify :portfolio_entry,
          :order => 'lft ASC',
          :conditions => {:parent_id => nil},
          :sortable => true

end
