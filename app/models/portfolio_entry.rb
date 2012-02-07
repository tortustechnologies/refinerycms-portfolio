require 'globalize3'

class PortfolioEntry < ActiveRecord::Base
  # Constants
  alias_attribute :effect, :transitions
  EFFECT_OPTIONS = [
    ["Random",              "random"],
    ["Fade",                "fade"],
    ["Slice down",          "sliceDown"],
    ["Slice down left",     "sliceDownLeft"],
    ["Slice up",            "sliceUp"],
    ["Slice up left",       "sliceUpLeft"],
    ["Slice up down",       "sliceUpDown"],
    ["Slice up down left",  "sliceUpDownLeft"],
    ["Fold",                "fold"],
    ["Slide in right",      "slideInRight"],
    ["Slide in left",       "slideInLeft"],
    ["Box random",          "boxRandom"],
    ["Box rain",            "boxRain"],
    ["Box rain reverse",    "boxRainReverse"],
    ["Box rain grow",       "boxRainGrow"],
    ["Box rain grow reverse", "boxRainGrowReverse"]
  ]
  EFFECT_VALUES = EFFECT_OPTIONS.collect(&:last)
  DEFAULT_EFFECT = 'fade'

  belongs_to :title_image, :class_name => 'Image'

  translates :title, :body if self.respond_to?(:translates)
  attr_accessor :locale # to hold temporarily
  
  # Validations
  validates :title, :presence => true
  validates :effect, :presence => true
  validates :anim_speed, :presence => true,
    :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}
  validates :pause_time, :presence => true,
    :numericality => {:only_integer => true, :greater_than_or_equal_to => 0}

  # call to gems included in refinery.
  has_friendly_id :title, :use_slug => true
  acts_as_nested_set
  default_scope :order => 'lft ASC'
  acts_as_indexed :fields => [:title, :image_titles, :image_names]

  has_many :images_portfolio_entries, :order => 'images_portfolio_entries.position ASC' 
  has_many :images, :through => :images_portfolio_entries, :order => 'images_portfolio_entries.position ASC'
  accepts_nested_attributes_for :images, :allow_destroy => false

  # Callbacks

  before_validation :set_default_values
  def set_default_values
    self.effect = DEFAULT_EFFECT if self.effect.blank?
  end

  # Properties

  def images_attributes=(data)
    # Create records in the images_portfolio_entries_join table instead of
    # images. This delete_all actually clears the collection array too.
    ImagesPortfolioEntry.delete_all(:portfolio_entry_id => self.id)

    (0..(data.length-1)).each do |i|
      unless (image_data = data[i.to_s]).nil? or image_data['id'].blank?
        entry = self.images_portfolio_entries.new(
          :image_id => image_data['id'].to_i,
          :position => i,
          :link => image_data['link'],
          :title => image_data['title']
        )
        self.images_portfolio_entries << entry
      end
    end
  end
  
  def image_titles
    self.images.collect{|i| i.title}
  end
  
  def image_names
    self.images.collect{|i| i.image_name}
  end

  alias_attribute :content, :body

  def image_id_for_entry_index index
    id = self.images_portfolio_entries[index].image_id
    logger.debug "!!!! image_id_for_entry_index(#{index}) = #{id}"
    id
  end

  def link_for_entry_index index
    link = self.images_portfolio_entries[index].link
    logger.debug "!!!! link_for_entry_index(#{index}) = #{link}"
    link
  end

  def title_for_entry_index index
    title = self.images_portfolio_entries[index].title
    logger.debug "!!!! title_for_entry_index(#{index}) = #{title}"
    title
  end

  def effect_values= values
    unless values and values.is_a?(Array) and not values.empty?
      values = [DEFAULT_EFFECT]
    end
    self.effect = values.collect(&:strip).join(",")
  end

  def effect_values
    self.effect.split "," if self.effect
  end

  def random_order?; random_order; end
  def random_start?; false; end

end
