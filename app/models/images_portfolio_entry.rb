class ImagesPortfolioEntry < ActiveRecord::Base

  belongs_to :image
  belongs_to :portfolio_entry

  validates_presence_of :portfolio_entry_id, :image_id

  before_save do |image_portfolio_entry|
    image_portfolio_entry.position ||= (ImagesPortfolioEntry.maximum(:position) || -1) + 1
  end

end
