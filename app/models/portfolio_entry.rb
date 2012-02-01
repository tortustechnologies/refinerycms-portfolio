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
  accepts_nested_attributes_for :images_portfolio_entries, :allow_destroy => false

  def images_attributes=(data)
    self.images.clear

    self.images = (0..(data.length-1)).collect { |i|
      unless (image_id = data[i.to_s]['id'].to_i) == 0
        Image.find(image_id) rescue nil
      end
    }.compact
  end

  # This is done to eliminate the need to submit the id of the
  # ImagesPortfolioEntry records to update, as far as I can tell.
  def images_portfolio_entries_attributes=(data)
    logger.debug "!!!! " + data.inspect
    ImagesPortfolioEntry.delete_all(:portfolio_entry_id => self.id)

    (0..(data.length-1)).each do |i|
      unless (entry_data = data[i.to_s]).nil? or entry_data['image_id'].blank?
        entry = self.images_portfolio_entries.new({
          :image_id => entry_data['image_id'].to_i,
          :position => i,
          :link => entry_data['link']
        })
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
