module GenderModule
  GENDER = GenderDetector.new(case_sensitive: false)

  def self.get_gender(text)
    GENDER.get_gender(text)
  end
end
