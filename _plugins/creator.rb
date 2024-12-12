require 'dotenv/load'
require 'trello'
module Jekyll
  class ContentCreatorGenerator < Generator
    safe true
    ACCEPTED_COLOR = "green"

    def setup
      @trello_api_key = ENV['TRELLO_API_KEY']
      @trello_token = ENV['TRELLO_TOKEN']

      Trello.configure do |config|
        config.developer_public_key = @trello_api_key
        config.member_token = @trello_token
      end
    end

    def generate(site)
      setup
      
      cards = Trello::List.find("6759340a1d34518a01005ae7").cards
      cards.each do |card|
        # binding.pry
        labels = card.labels.map { |label| label.color}
        next unless labels.include?("green")
        due_on = card.due&.to_date.to_s 
        slug = card.name.split.join("-").downcase
        created_on = DateTime.strptime(card.id[0..7].to_i(16).to_s, '%s').to_date.to_s
        article_date = due_on.empty? ? created_on : due_on
        content = """---
layout: post
title: #{card.name}
date: #{article_date}
---

#{card.desc}
        """
        file = File.open("./_posts/#{article_date}-#{slug}.md", "w+") {|f| f.write(content) }
        # binding.pry
      end
    end
  end
end


# timestamp
# hex = "4d5ea62fene3ne43"
# date_hex = hex[0..7]
# date_int =  date_hex.to_i(16)
# DateTime.strptime(hex[0..7].to_i(16).to_s, '%s')