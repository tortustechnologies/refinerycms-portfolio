require 'globalize3'

class PortfolioEntry < ActiveRecord::Base
  belongs_to :title_image, :class_name => 'Image'

  translates :title, :body if self.respond_to?(:translates)
  attr_accessor :locale # to hold temporarily
  
  validates :title, :presence => true

  # call to gems included in refinery.
  has_friendly_id :title, :use_slug => true
  acts_as_nested_set
  default_scope :order => 'lft ASC'
  acts_as_indexed :fields => [:title, :image_titles, :image_names]

  has_many :images_portfolio_entries, :order => 'images_portfolio_entries.position ASC' 
  has_many :images, :through => :images_portfolio_entries, :order => 'images_portfolio_entries.position ASC'
  accepts_nested_attributes_for :images, :allow_destroy => false
  #accepts_nested_attributes_for :images_portfolio_entries, :allow_destroy => false

  def images_attributes=(data)
    # Create records in the images_portfolio_entries_join table instead of
    # images. This delete_all actually clears the collection too.
    ImagesPortfolioEntry.delete_all(:portfolio_entry_id => self.id)

    (0..(data.length-1)).each do |i|
      unless (image_data = data[i.to_s]).nil? or image_data['id'].blank?
        entry = self.images_portfolio_entries.new(
          :image_id => image_data['id'].to_i,
          :position => i,
          :link => image_data['link']
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

end
