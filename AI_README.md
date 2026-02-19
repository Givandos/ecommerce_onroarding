## AI Prompt Template

Role:
You are a Smart Onboarding Guide for an E-Commerce platform. Your specialization is supply chain management, inventory planning, and e-commerce logistics.

Objective:
Your goal is to assist new users in setting up the system based on their unique business data (context). You must provide specific recommendations for the current onboarding step to help the user get started as quickly as possible.

Contextual Awareness:
You will receive data about the company (industry, company size, SKU count/statistics, supplier locations, order history) and the current onboarding status. Use this data to ensure your advice feels personalized (e.g., "Since you have over 500 SKUs..." instead of "For large companies...").

Guidelines:

Tone: Professional, supportive, and concise.

Actions: If there is sufficient data for analysis, suggest specific figures (e.g., "lead time of 21 days"). If there is insufficient data, explain general industry standards. Do not ask follow-up questions.

Constraints: Do not invent data that is not present in the context. Do not provide financial advice beyond the scope of inventory planning. Do not provide any hyperlinks to external resources.


###
###

#### Example of data which we can use for the AI:

```json
{
  "step": "Setup of lead_time",
  "company": {
    "industry": "Fashion",
    "products_list_size": "500-1000 SKU",
    "suppliers_locations": [
      "USA",
      "Asia"
    ],
    "warehouses_locations": [
      "USA",
      "Europe"
    ]
  },
  "sales_history": {
    "total": 123456,
    "top_category": "Woman shoes",
    "last_month": 3456,
    "average_price": "€212"
  },
  "current_settings": {
    "default_lead_time": 63,
    "forecasting_days": 14
  }
}
```
 These data we can get from our DB:
- `step` - current step of onboarding
- `company`:
 - - `industry` - industry of company
 - - `products_list_size` - size of synchronized products
 - - `supliers_locations` - uniq locations of company suppliers
 - - `warehouses_locations` - uniq locations of company warehouses
- `sales_history` - sales history of company
 - - `total` - total sales of company
 - - `top_category` - most popular category of products
 - - `last_month` - sales in last month
 - - `average_price` - average price of products
- `current_settings` - current settings of company, based on completed steps
 - - `default_lead_time` - default lead time of company
 - - `forecasting_days` - forecasting days

Some of these fields are natively present in the database but some of them we need to calculate with the existing/synchronized data



## Examples:

### 1. Set Lead Time
### User Prompt (Context):
```
Current Step: "Setup of lead time"
Company Data: Industry: Fashion, Products list size: 500 SKUs, Warehouses locations: Europe
Supply Data: Most suppliers are located in Asia (China, Vietnam).
Task: Provide a recommendation for the average lead time.
```

### Expected answer:
```
Based on your profile (Fashion industry, 500 SKUs) and the fact that your suppliers are located in Asia, we recommend setting a baseline lead time of 45–60 days.
This accounts for average production times and ocean freight. You will be able to refine these details later for each supplier individually
```

### 2. Set Days of Stock

### User Prompt (Context):

```
Current Step: Set days of stock
Company Data:
  Subscription: Enterprise,
  Warehouse Capacity: High.
Sales Data: High reliability score for main vendors.
Task: Recommend how many days of stock to maintain.
```

### Expected answer:

```
Given your high warehouse capacity and reliable suppliers, you can optimize costs by setting a 30-day inventory buffer (Days of Supply). This will help maintain high capital turnover without the risk of stockouts.
For 'Category A' items (bestsellers), we recommend increasing this to 45 days.
```


### 3: Match Suppliers and Products
Scenario:\
The user must decide how to map vendor data from an external system (e.g., Shopify) to the platform's supplier entities.

### User Prompt (Context):

```
Current Step: match_suppliers
Data Status: 45 vendors synced from Shopify, 25 products added.
Observation: Vendor names in Shopify perfectly match the 'Supplier' field in your product CSV.
Task: Suggest the best way to complete this step.
```

### Expected AI Response:

```
We noticed that your Shopify data already contains vendor information that matches your products.
We recommend selecting the 'Copy vendors as suppliers' option. This will automatically link all 25 products to the corresponding 45 vendors, saving you the time of manual configuration.
```




## 
## How to integrate this into the architecture
### Backend:
When the frontend opens a step, it sends a GET request to `/api/v1/onboarding/guide_recommendation`

### Service on our backend:
A Rails service aggregates data from `Company`, `CompanySetting`, `Product`, `Vendor`, and other models into a JSON object.

### LLM:
This data is sent to the AI along with the System Prompt, and the user sees the generated result in the `"Smart Guide" widget`.


##
## Edge cases:

### Case 1: No Synchronized Products Found
Description:\
This occurs when a user has just connected Shopify, but the background import process is still in progress.

AI Strategy:\
The assistant cannot provide recommendations for specific SKUs. Instead, we offer industry-standard settings based on available data (company size, industry, and warehouse locations).

User Message:\
"We are currently importing your products. In the meantime, you can apply standard settings based on your industry (Fashion) or wait for the synchronization to complete for a more precise analysis. The average lead time for the Fashion industry is 25 days."

Technical Implementation:\
In the AI System Prompt, we explicitly indicate that the product count and SKU data are currently unavailable (products_list_size: 0).


### Case 2: No Sales History (Brand New)
Scenario:\
For new businesses that have just launched and have no historical data.

AI Strategy:\
Since the forecasting algorithm lacks historical data, the AI should propose a "Launch Strategy".

User Message:\
"Since you don't have a sales history yet, we recommend setting the Forecasting Window to 30 days and using a conservative Lead Time (20 days). As soon as the first orders come in, the system will automatically adjust the forecasts."


### Case 3: Context Exceeds Token Limit
Scenario:\
This occurs when a company has thousands of products or warehouses, making it impossible to pass every individual record into the LLM.

Strategy:\
Aggregation and Ranking

Technical Implementation:\
Instead of passing each product individually, the backend prepares a statistical snapshot for the AI:
* Top 5 Suppliers by product count.
* Product distribution by category.
* Average price and lead time across the entire catalog.

This allows the AI to see the "big picture" without overwhelming the context window.


Ось технічний переклад четвертого сценарію, адаптований для розробників та архітекторів системи:

### Case 4: AI Returns Incorrect or Invalid Response
Scenario:\
The model might "hallucinate" or return plain text instead of the expected structured format.

Strategy:\
Fallback & Validation

Technical Implementation:\
* Validation:\
If a JSON response is expected, the backend parses it. If the structure is invalid, the response is discarded.
* Fallback:\
The user is shown a pre-written "static" tip for the current step, prepared by the developers (hardcoded tips).
* Retry:\
An automatic regeneration attempt can be configured with a stricter prompt for the second try.
