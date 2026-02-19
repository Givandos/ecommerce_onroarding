class VendorFetcher
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def progress
    # In a real scenario, this would track actual sync progress

    {
      count: 7,
      sync_percent: 33
    }
  end
end
