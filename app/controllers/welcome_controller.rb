class WelcomeController < ApplicationController
  def index
    # store credentials in yml and .gitignore the file?? or database??
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "xxx"
      config.consumer_secret     = "xxx"
      config.access_token        = "xxx"
      config.access_token_secret = "xxx"
    end

    text = client.search("#hurricane #southside").take(20).collect do |tweet|
      tweet.text
    end

    response = HTTParty.get("https://api.vineapp.com/tags/search/love?page=4")
    text = response

    render json: text
  end
end