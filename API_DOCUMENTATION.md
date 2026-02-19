# Onboarding API Documentation

## Overview
This API supports an 8-step onboarding flow for inventory planning. Steps can be locked based on sync progress or dependency on other steps. Users can return to any completed step at any time. The API uses a service-oriented architecture with background job processing for resource-intensive operations.

## Base URL
```
http://localhost:3000/api/v1
```

## Authentication
For demo purposes, the API uses the first company in the database. In production, this would be replaced with proper authentication middleware.

## Endpoints

### 1. GET /api/v1/onboarding/status

Returns the current onboarding status, including all steps and their states.

**Response:**
```json
{
  "current_step": {
    "id": 1,
    "name": "Welcome",
    "slug": "welcome"
  },
  "overall_status": "in_progress",
  "steps": [
    {
      "id": 1,
      "name": "Welcome",
      "slug": "welcome",
      "position": 1,
      "status": "active",
      "required_step_id": null,
      "required_sync_type": null,
      "skippable": false
    },
    {
      "id": 2,
      "name": "Lead Time",
      "slug": "lead_time",
      "position": 2,
      "status": "pending",
      "required_step_id": 1,
      "required_sync_type": null,
      "skippable": true
    },
    {
      "id": 5,
      "name": "PO Upload",
      "slug": "po_upload",
      "position": 5,
      "status": "locked",
      "required_step_id": 1,
      "required_sync_type": "products",
      "skippable": true
    }
  ],
  "sync_progress": {
    "products": {
      "count": 100,
      "sync_percent": 75
    },
    "warehouses": {
      "count": 2,
      "sync_percent": 60
    },
    "vendors": {
      "count": 7,
      "sync_percent": 33
    },
    "sales_history": {
      "products_count": 236,
      "sync_percent": 0
    }
  }
}
```

**Step Status Values:**
- `completed` - Step has been completed
- `active` - Current step user is on
- `locked` - Step is locked due to incomplete sync requirements
- `skipped` - Step has been skip by user
- `pending` - Step is available but not yet started

---

### 2. PATCH /api/v1/onboarding/steps/:slug

Updates a specific onboarding step with user data and marks it as completed.

**Parameters:**
- `slug` (path parameter) - The step identifier (welcome, lead_time, days_of_stock, etc.)

**Request Body:**
```json
{
  "step_params": {
    // Step-specific parameters (see below)
  }
}
```

**Note:** All step parameters must be nested under a `step_params` key.

#### Step: welcome
No parameters required. Simply marks the welcome step as completed.

#### Step: lead_time
```json
{
  "step_params": {
    "default_lead_time": 63
  }
}
```
- `default_lead_time` (required): Integer, must be >= 0
- Triggers `LeadTimeUpdater` background job

#### Step: days_of_stock
```json
{
  "step_params": {
    "days_of_stock": 30
  }
}
```
- `days_of_stock` (required): Integer, must be >= 0
- Triggers `RefreshCalculationsWorker` background job

#### Step: forecasting
```json
{
  "step_params": {
    "forecasting_days": 90
  }
}
```
- `forecasting_days` (required): Integer, must be >= 0
- Triggers `RefreshCalculationsWorker` background job

#### Step: po_upload
```json
{
  "step_params": {
    "po_upload_file": "<file_data>"
  }
}
```
OR to skip:
```json
{
  "step_params": {
    "skip_step": true
  }
}
```
- `po_upload_file` (optional): File upload
- `skip_step` (optional): Boolean, set to true to skip this step (only if step is skippable)
- Requires products sync at 100%

#### Step: suppliers_match
```json
{
  "step_params": {
    "copy_vendors_to_suppliers": true
  }
}
```
- `copy_vendors_to_suppliers` (optional): Boolean
- `skip_step` (optional): Boolean, set to true to skip this step (only if step is skippable)
- Requires warehouses sync at 100%

#### Step: bundles
```json
{
  "step_params": {
    "bundles_file": "<file_data>"
  }
}
```
OR to skip:
```json
{
  "step_params": {
    "skip_step": true
  }
}
```
- `bundles_file` (optional): File upload
- `skip_step` (optional): Boolean, set to true to skip this step (only if step is skippable)

#### Step: integrations
```json
{
  "step_params": {
    "integration_type": "shopify"
  }
}
```
- `integration_type` (optional): String, type of integration to configure

**Success Response (200):**
```json
{
  "message": "Step updated successfully",
  "current_step": {
    "id": 3,
    "name": "Days of Stock",
    "slug": "days_of_stock"
  },
  "overall_status": "in_progress"
}
```

**Error Response - Locked Step (423):**
```json
{
  "error": "Step is locked. You can't proceed until it's unlocked."
}
```

**Error Response - Validation Error (423):**
```json
{
  "error": "Default lead time is required for this step."
}
```
OR
```json
{
  "error": "Days of stock is required for this step."
}
```
OR
```json
{
  "error": "Forecasting days is required for this step."
}
```
OR
```json
{
  "error": "You should upload a file or choose skip option for this step."
}
```
OR
```json
{
  "error": "You can't skip this step."
}
```
OR
```json
{
  "error": "Step has not been implemented yet."
}
```

**Side Effects:**
- Updating `lead_time` step triggers `LeadTimeUpdater.perform_async(company_id)` background job
- Updating `days_of_stock` step triggers `RefreshCalculationsWorker.perform_async(company_id)` background job
- Updating `forecasting` step triggers `RefreshCalculationsWorker.perform_async(company_id)` background job
- Successfully completing any step advances the `current_step` to the next unlocked step
- Completing the last step changes `overall_status` to "completed"
- Skipping a step marks it as skipped in `completed_steps` JSON column

---

### 3. GET /api/v1/onboarding/sync_progress

Returns detailed sync progress for all data types.

**Response:**
```json
{
  "sync_progress": {
    "products": {
      "count": 100,
      "sync_percent": 75
    },
    "warehouses": {
      "count": 2,
      "sync_percent": 60
    },
    "vendors": {
      "count": 7,
      "sync_percent": 33
    },
    "sales_history": {
      "products_count": 236,
      "sync_percent": 0
    }
  }
}
```

**Progress Values:**
- `0` - Sync might be not started
- `1-99` - Sync in progress
- `100` - Sync completed

---

## Onboarding Steps

### Step 1: Welcome
- **Slug:** `welcome`
- **Purpose:** Initial entry point
- **Requirements:** None
- **Data:** None required

### Step 2: Lead Time
- **Slug:** `lead_time`
- **Purpose:** Set default lead time for inventory
- **Requirements:** Welcome step must be completed
- **Data:** `default_lead_time` (integer)

### Step 3: Days of Stock
- **Slug:** `days_of_stock`
- **Purpose:** Configure target days of stock
- **Requirements:** Welcome step must be completed
- **Data:** `days_of_stock` (integer)

### Step 4: Forecasting
- **Slug:** `forecasting`
- **Purpose:** Set forecasting period
- **Requirements:** Welcome step must be completed
- **Data:** `forecasting_days` (integer)

### Step 5: PO Upload
- **Slug:** `po_upload`
- **Purpose:** Upload purchase orders or skip
- **Requirements:** Products sync must be 100%
- **Data:** `file` (optional)

### Step 6: Suppliers Match
- **Slug:** `suppliers_match`
- **Purpose:** Copy vendors to suppliers
- **Requirements:** Warehouses sync must be 100%
- **Data:** `copy_vendors_to_suppliers` (boolean)

### Step 7: Bundles
- **Slug:** `bundles`
- **Purpose:** Upload bundles
- **Requirements:** Suppliers Match step must be completed or skipped
- **Data:** Integration-specific

### Step 8: Integrations
- **Slug:** `integrations`
- **Purpose:** Integration setup. Final step completion
- **Requirements:** Bundles step must be completed or skipped
- **Data:** Integration-specific

---

## Step Locking Mechanism

Steps can be locked by two mechanisms:

### 1. Sync-based Locking
Steps with a `required_sync_type` will be locked until the corresponding sync reaches 100% progress.

**Locked Steps:**
- **PO Upload** (`po_upload`) - Requires `products` sync at 100%
- **Suppliers Match** (`suppliers_match`) - Requires `warehouses` sync at 100%

The sync progress is calculated by `SyncStatusService`

### 2. Step Dependency Locking
Steps can have a `required_step_id` which references another step that must be completed or skipped before the dependent step becomes available. This is checked by the `locked_by_step?` method in `UpdateProgressService`.

---

## Background Jobs

### LeadTimeUpdater
Triggered when `default_lead_time` is updated.
```ruby
LeadTimeUpdater.perform_async(company.id)
```

### RefreshCalculationsWorker
Triggered when `forecasting_days` is updated.
```ruby
RefreshCalculationsWorker.perform_async(company.id)
```

---

## Example Usage Flow

### 1. Check onboarding status
```bash
curl -X GET http://localhost:3000/api/v1/onboarding/status
```

### 2. Complete Welcome step
```bash
curl -X PATCH http://localhost:3000/api/v1/onboarding/steps/welcome \
  -H "Content-Type: application/json" \
  -d '{"step_params": {}}'
```

### 3. Update Lead Time
```bash
curl -X PATCH http://localhost:3000/api/v1/onboarding/steps/lead_time \
  -H "Content-Type: application/json" \
  -d '{"step_params": {"default_lead_time": 45}}'
```

### 4. Check sync progress
```bash
curl -X GET http://localhost:3000/api/v1/onboarding/sync_progress
```

### 5. Attempt locked step (will fail if sync incomplete)
```bash
curl -X PATCH http://localhost:3000/api/v1/onboarding/steps/po_upload \
  -H "Content-Type: application/json" \
  -d '{"step_params": {"po_upload_file": "<file_data>"}}'
# Returns 423 if products sync < 100%
```

### 6. Skip a step
```bash
curl -X PATCH http://localhost:3000/api/v1/onboarding/steps/po_upload \
  -H "Content-Type: application/json" \
  -d '{"step_params": {"skip_step": true}}'
```

---

## Data Models

### Company
Represents the company using the onboarding system.

**Fields:**
- `id`: Integer (primary key)
- `name`: String
- `size`: String
- `location`: String
- `subscription_tier`: String
- `industry_id`: Integer (foreign key to industries)
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `has_one :company_setting`
- `has_one :onboarding_progress`
- `has_many :products`
- `has_many :warehouses`
- `has_many :vendors`
- `has_many :sales_histories`
- `has_many :users`
- `belongs_to :industry`

### CompanySetting
Stores configuration settings for a company's inventory management.

**Fields:**
- `id`: Integer (primary key)
- `company_id`: Integer (foreign key, not null)
- `default_lead_time`: Integer (>= 0, nullable)
- `days_of_stock`: Integer (>= 0, nullable)
- `forecasting_days`: Integer (>= 0, nullable)
- `integration_type`: String (nullable)
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `belongs_to :company`

### OnboardingProgress
Tracks a company's progress through the onboarding flow.

**Fields:**
- `id`: Integer (primary key)
- `company_id`: Integer (foreign key, not null)
- `current_step_id`: Integer (foreign key to onboarding_steps, nullable)
- `status`: Integer (enum, default: 1 = not_started)
- `completed_steps`: JSON (default: {})
- `created_at`: DateTime
- `updated_at`: DateTime

**Status Enum:**
- `1`: not_started
- `2`: in_progress
- `3`: completed

**Completed Steps JSON Format:**
```json
{
  "welcome": "completed",
  "lead_time": "completed",
  "po_upload": "skipped"
}
```

**Relationships:**
- `belongs_to :company`
- `belongs_to :current_step, class_name: 'OnboardingStep', optional: true`

### OnboardingStep
Defines the steps in the onboarding flow.

**Fields:**
- `id`: Integer (primary key)
- `name`: String (not null)
- `slug`: String (unique, not null)
- `position`: Integer (not null)
- `skippable`: Boolean (default: true)
- `required_sync_type`: String (nullable, values: 'products', 'warehouses', 'vendors', 'sales_history')
- `required_step_id`: Integer (nullable, references another OnboardingStep)
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `has_many :onboarding_progresses, foreign_key: :current_step_id`

**Default Steps:**
1. Welcome (welcome) - position 1
2. Lead Time (lead_time) - position 2, requires Welcome step completion
3. Days of Stock (days_of_stock) - position 3, requires Welcome step completion
4. Forecasting (forecasting) - position 4, requires Welcome step completion
5. PO Upload (po_upload) - position 5, requires products sync
6. Suppliers Match (suppliers_match) - position 6, requires warehouses sync
7. Bundles (bundles) - position 7, requires Suppliers Match step completion
8. Integrations (integrations) - position 8, requires Bundles step completion

### Product
Represents products in the company's inventory.

**Fields:**
- `id`: Integer (primary key)
- `company_id`: Integer (foreign key, not null)
- `category_id`: Integer (foreign key, not null)
- `name`: String
- `sku`: String
- `price`: Decimal
- `cost`: Decimal
- `lead_time`: Integer
- `supplier_id_id`: Integer (foreign key to vendors)
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `belongs_to :company`
- `belongs_to :category`
- `belongs_to :supplier, class_name: 'Vendor', foreign_key: :supplier_id_id, optional: true`

### Warehouse
Represents warehouse locations for the company.

**Fields:**
- `id`: Integer (primary key)
- `company_id`: Integer (foreign key, not null)
- `name`: String
- `location`: String
- `type`: String
- `capacity`: String
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `belongs_to :company`

### Vendor
Represents suppliers/vendors for the company.

**Fields:**
- `id`: Integer (primary key)
- `company_id`: Integer (foreign key, not null)
- `name`: String
- `country`: String
- `avg_lead_time`: String
- `reliability_score`: String
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `belongs_to :company`
- `has_many :products, foreign_key: :supplier_id_id`

### SalesHistory
Records historical sales data.

**Fields:**
- `id`: Integer (primary key)
- `company_id`: Integer (foreign key, not null)
- `product_id`: Integer (foreign key, not null)
- `date`: Date
- `quantity`: Decimal
- `sales_price`: Decimal
- `created_at`: DateTime
- `updated_at`: DateTime

**Relationships:**
- `belongs_to :company`
- `belongs_to :product`

---

## Services

### OnboardingStatusService
Calculates and returns the current onboarding status for a company.

**Location:** `app/services/onboarding_status_service.rb`

**Usage:**
```ruby
service = OnboardingStatusService.new(company)
service.call
data = service.status_data
```

### UpdateProgressService
Handles updating onboarding progress and executing step-specific logic.

**Location:** `app/services/update_progress_service.rb`

**Step Handlers:**
- `welcome`: Initial setup
- `set_lead_time`: Updates default_lead_time, triggers LeadTimeUpdater
- `set_days_of_stock`: Updates days_of_stock, triggers RefreshCalculationsWorker
- `set_forecasting`: Updates forecasting_days, triggers RefreshCalculationsWorker
- `po_upload`: Handles PO file upload or skip
- `suppliers_match`: Copies vendors to suppliers or skip
- `bundles`: Handles bundles file upload or skip
- `integrations`: Sets integration type

**Usage:**
```ruby
service = UpdateProgressService.new(company: company, slug: 'lead_time', params: {default_lead_time: 45})
service.call

if service.error
  # Handle error
else
  progress = service.progress
end
```

### SyncStatusService
Calculates sync progress for different data types based on record counts.

**Location:** `app/services/sync_status_service.rb`

**Usage:**
```ruby
service = SyncStatusService.new(company)
all_progress = service.all_progress # Returns hash of all progress
product_progress = service.progress_for('products') # Returns progress for specific type
```

### StepsProgressService
Manages step status calculations and locking logic.

**Location:** `app/services/steps_progress_service.rb`

---

## Notes

- Users can return to any step at any time by calling the PATCH endpoint for that step
- Completed steps remain accessible and can be updated
- The system automatically advances to the next unlocked step after completion
- When the last step is completed, `overall_status` changes to "completed"
- Sidekiq must be running for background jobs (`LeadTimeUpdater`, `RefreshCalculationsWorker`) to execute
- All step parameters must be nested under the `step_params` key in request bodies
- Steps can be skipped if `skippable` is true and `skip_step: true` is provided
- The controller uses `Company.first` for demo purposes instead of proper authentication
- Step validation errors return HTTP 423 (Locked) status code
