module Sentiment
  STIMMUNG = Stimmung.new

  def self.score(text)
    STIMMUNG.score(text)
  end
end
