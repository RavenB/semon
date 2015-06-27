module CampaignsHelper
  # checks if the current page belongs to an existing campaign
  #
  # the regexp is checking for an url containing 'campaigns' and
  # a digit of an campaign id
  #
  # returns true or false
  def is_campaign?
    !!(/\/campaigns\/\d/ =~ (request.url)) if request.present? && request.url.present?
  end

  # returns a formatted campaign date range in format '10.06.2015 - 20.06.2015'
  # for a given campaign
  def campaign_date_range(campaign)
    "#{campaign.c_start.strftime('%d.%m.%Y')} - #{campaign.c_end.strftime('%d.%m.%Y')}"
  end

  # returns the name of a given campaign
  def campaign_name(campaign)
    campaign.c_name
  end
end
