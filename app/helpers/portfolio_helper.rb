module PortfolioHelper

  def portfolio_image_link(master, portfolio, image_index)
    if ::Refinery::Portfolio.multi_level?
      portfolio_image_url(master, portfolio, image_index)
    else
      portfolio_image_url(master, image_index)
    end
  end

  def link_to_portfolio_image(master, portfolio, image, index)
    link_to(image_fu(image, '96x96#c'),
            portfolio_image_link(master, portfolio, index))
  end

  def slideshow_for_portfolio(portfolio_id, options = {})
    content_for :stylesheets do
      stylesheet_link_tag "nivo-slider.css"
    end
    content_for :scripts do
      if Rails.env.production?
        javascript_include_tag "jquery.nivo.slider.pack.js"
      else
        javascript_include_tag "jquery.nivo.slider.js"
      end
    end
    portfolio = PortfolioEntry.find(portfolio_id) rescue nil
    if portfolio and portfolio.images_portfolio_entries.any?
      options.reverse_merge!({
        :geometry => '640x300#c',
        :animSpeed => portfolio.anim_speed,
        :pauseTime => portfolio.pause_time,
        :directionNav => portfolio.direction_nav,
        :controlNav => portfolio.control_nav,
        :effect => portfolio.effect.blank? ? Portfolio::DEFAULT_EFFECT : portfolio.effect,
        :captionOpacity => 0.0,
        :randomStart => portfolio.random_start?
      })
      render "portfolio/slideshow",
        :portfolio_id => portfolio_id,
        :portfolio => portfolio,
        :options => options
    end
  end

  def checkbox_group object_name, property_name, possible_values, options = {}
    group_name = html_escape("#{object_name.to_s}[#{property_name.to_s}_values][]")
    options.reverse_merge! :other_field_label => "Other:"
    object_params = params[object_name.to_sym] || nil
    if object_params
      group_values = object_params["#{property_name.to_s}_values".to_sym]
    else
      group_values = []
    end

    tags = []
    possible_values.each do |value|
      tags << check_box_tag(group_name, html_escape(value),
        (!group_values.empty? && group_values.include?(value))) +
        "&nbsp;".html_safe +
        html_escape(value)
    end
    html = tags.join "<br />"

    if options[:include_other_field]
      other_field_value = group_values.last
      html = html + "<br />" +
        html_escape(options[:other_field_label].to_s) + "<br />" +
        text_field_tag(group_name, other_field_value, :size => 40)
    end

    html.html_safe
  end

end
