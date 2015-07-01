module SentimentModule
  STIMMUNG = Stimmung.new

  def self.score(text)
    STIMMUNG.score(text)
  end
end
