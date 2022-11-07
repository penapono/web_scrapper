# frozen_string_literal: true

require 'kimurai'
require 'byebug'

class SimpleSpider < Kimurai::Base
  @name = 'simple_spider'
  @engine = :selenium_chrome
  @start_urls = [
    'https://www.eventim.com.br/event/coldplay-sao-paulo-estadio-do-morumbi-16011136/',
    'https://www.eventim.com.br/event/coldplay-sao-paulo-estadio-do-morumbi-16011137/',
    'https://www.eventim.com.br/event/coldplay-sao-paulo-estadio-do-morumbi-16011139/',
    'https://www.eventim.com.br/event/coldplay-sao-paulo-estadio-do-morumbi-16011140/',
    'https://www.eventim.com.br/event/coldplay-sao-paulo-estadio-do-morumbi-16011141/',
    'https://www.eventim.com.br/event/coldplay-sao-paulo-estadio-do-morumbi-16011144/'
    # 'https://www.eventim.com.br/event/gpweek-the-killers-twenty-one-pilots-allianz-parque-15674924/'
  ]
  @config = {
    disable_images: true,
    ignore_ssl_errors: true
  }

  def parse(response, url:, data: {})
    availability = []

    response.xpath("//div[@class='event-list-item-wrapper pc-list-item-space clearfix js-product-type']").each do |item|
      item_crawler(item).each { |ic| availability << ic }
    end

    print_availability(response, availability)
  end

  private

  def print_availability(response, availability)
    return unless availability.any?

    print_header(response)

    availability.each { |available| puts available }

    puts "\n\n\n"
  end

  def print_header(response)
    event_data = response.xpath("//div[@class='stage-content-text']//h1").text
    event_time = response.xpath("//div[@class='stage-meta-infos stage-content-text-item']//time").first.text

    header = "#{event_data} - #{event_time}"
    output = '===============================================================' \
             '===============================================================' \
             '==============================================================='

    puts output[0, header.length]
    puts "#{event_data} - #{event_time}"
    puts output[0, header.length]
  end

  def item_crawler(item)
    category = item.css('div.pc-list-detail.event-list-head.theme-headline-color span').first rescue nil
    category_name = category.children.text
    form = category.parent.parent.parent

    tickets = form.css('div.clearfix.ticket-type-item-wrapper.js-ticket-type-item')
    ticket_crawler(tickets, category_name)
  end

  def ticket_crawler(tickets, category_name)
    availability = []

    tickets.each do |ticket|
      ticket_type = ticket.css('div.ticket-type-title.theme-text-color').text.gsub("\n", '').strip
      # price = ticket.css('div.ticket-type-price.theme-headline-color.text-nowrap').text.gsub("\n", '').strip
      # button_less = ticket.css(
      #   'div.btn-group.btn-stepper.js-stepper button.btn-stepper-left.js-stepper-less'
      # ).first rescue nil
      # button_more = ticket.css(
      #   'div.btn-group.btn-stepper.js-stepper button.btn-stepper-right.js-stepper-more'
      # ).first rescue nil
      # more_disabled = button_more.attributes['disabled'].blank? rescue nil
      sold = ticket.css('div.ticket-type-unavailable-sec.theme-text-color') rescue nil
      next unless sold.blank?

      availability << "\u{1F973}\u{1F973}\u{1F973}\u{1F973}\u{1F973}\u{1F973}"
      availability << "#{category_name}: #{ticket_type}: DISPONÍVEL"
      availability << "\u{1F973}\u{1F973}\u{1F973}\u{1F973}\u{1F973}\u{1F973}"
      # else
      # puts "#{category_name}: #{ticket_type}: ESGOTADO"
    end

    availability
  end
end

SimpleSpider.crawl!
