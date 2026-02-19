class SalesHistoryFetcher
  attr_reader :company

  def initialize(company)
    @company = company
  end

  def progress
    # In a real scenario, this would track actual sync progress

    {
      products_count: 236,
      sync_percent: 0
    }
  end
end
