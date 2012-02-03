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
      javascript_include_tag "jquery.nivo.slider.pack.js"
    end
    portfolio = PortfolioEntry.find(portfolio_id) rescue nil
    if portfolio and portfolio.images_portfolio_entries.any?
      options.reverse_merge!({
        :geometry => '640x300#c',
        :animSpeed => portfolio.anim_speed,
        :pauseTime => portfolio.pause_time,
        :directionNav => portfolio.direction_nav,
        :controlNav => portfolio.control_nav,
        :effect => portfolio.effect
      })
      render "portfolio/slideshow",
        :portfolio_id => portfolio_id,
        :portfolio => portfolio,
        :options => options
    end
  end

end
