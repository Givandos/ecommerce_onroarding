class SyncStatusService
  SYNC_TYPES = [:products, :warehouses, :vendors, :sales_history].freeze

  attr_reader :company

  def initialize(company)
    @company = company
  end

  def progress_for(sync_type)
    if sync_type.to_sym.in?(SYNC_TYPES)
      sync_result = get_sync_data(sync_type)
      sync_result[:percent] || 0
    else
      100
    end
  end

  def all_progress
    SYNC_TYPES.each_with_object({}) do |sync_type, res|
      res[sync_type] = get_sync_data(sync_type)
    end
  end

  private

  # memorize sync data to avoid multiple calls of the same service
  def get_sync_data(sync_type)
    sync_name = sync_type.to_s + "_progress"
    return instance_variable_get("@#{sync_name}") if instance_variable_defined?("@#{sync_name}")

    instance_variable_set("@#{sync_name}", send(sync_name))
  end

  def products_progress
    ProductFetcher.new(company).progress
  end

  def warehouses_progress
    WarehouseFetcher.new(company).progress
  end

  def vendors_progress
    VendorFetcher.new(company).progress
  end

  def sales_history_progress
    SalesHistoryFetcher.new(company).progress
  end
end
