class ImagesPortfolioEntry < ActiveRecord::Base

  # Relations
  belongs_to :image
  belongs_to :portfolio_entry

  # Validations
  validates_presence_of :portfolio_entry_id, :image_id

  # Callbacks
  before_validation :strip_whitespace
  before_save :move_to_bottom

  def after_initialize
    if new_record? and self[:title].blank? and image
      self.title = image.title
    end
  end

  # Scopes
  scope :by_random, :order => 'random()'
  scope :by_position, :order => 'images_portfolio_entries.position ASC'

  # Properties

  # if no title is set, falls back to image's title
  def title
    if self[:title]
      self[:title]
    elsif image
      image.title
    end
  end

private

  # Callbacks
  def strip_whitespace
    self.link = self.link.strip if self.link
    self.title = self.title.strip if self.title
  end

  def move_to_bottom
    self.position ||= (ImagesPortfolioEntry.maximum(:position) || -1) + 1
  end

end
