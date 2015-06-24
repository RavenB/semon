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

  # returns the dashboard url of a campaign if a campaign id is given
  # otherwise root url
  def dashboard_path(campaign_id)
    if campaign_id
      "/campaigns/#{campaign_id}/dashboard"
    else
      root_path
    end
  end
end
