class ImagesPortfolioEntry < ActiveRecord::Base

  belongs_to :image
  belongs_to :portfolio_entry

  validates_presence_of :portfolio_entry_id, :image_id

  before_validation :strip_whitespace
  before_save :move_to_bottom

private

  def strip_whitespace
    self.link = self.link.strip if self.link
  end

  def move_to_bottom
    self.position ||= (ImagesPortfolioEntry.maximum(:position) || -1) + 1
  end

end
