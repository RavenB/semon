class WelcomeController < ApplicationController
  def index
    # store credentials in yml and .gitignore the file?? or database??
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.secrets.twitter["consumer_key"]
      config.consumer_secret     = Rails.application.secrets.twitter["consumer_secret"]
      config.access_token        = Rails.application.secrets.twitter["access_token"]
      config.access_token_secret = Rails.application.secrets.twitter["access_token_secret"]
    end

    texts = client.search("#hurricane15 #southside15").collect do |tweet|
      tweet.text
    end

    # response = HTTParty.get("https://api.vineapp.com/tags/search/love?page=4")
    # text = response

    @texts = texts
  end
end