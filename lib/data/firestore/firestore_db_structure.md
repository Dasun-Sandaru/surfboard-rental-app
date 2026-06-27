erDiagram
  Shops ||--o{ Member : "has"
  Shops ||--o{ Customers : "manages"
  Shops ||--o{ Inventory : "owns"
  Shops ||--o{ Rentals : "records"
  Shops ||--o{ AgreementTemplates : "uses"
  Shops ||--o{ ActivityLogs : "generates"
  Users ||--o{ Shops : "owns"

  Customers ||--o{ Rentals : "makes"
  Inventory ||--o{ Rentals : "used in"
  Rentals ||--o{ Payments : "has"
  Rentals ||--o{ DamageReports : "has"
  DamageReports ||--o{ Photos : "has"
  Inventory ||--o{ DamageFees : "has"
  AgreementTemplates ||--o{ Rentals : "attached to"

  Users {
    string uid PK
    string name
    string email
    string phone
    string role
    string shop_id FK
    boolean is_active
    boolean verified
    timestamp created_at
  }

  Shops {
    string id PK
    string name
    string owner_admin_uid FK
    string location
    string currency
    string time_zone
    string date_format
    float default_daily_rate
    float default_hourly_rate
    int daily_grace_period_hours
    int hourly_grace_period_minutes
    boolean is_tax_enabled
    float tax_rate
    string agreement_template
    json staff_access
    timestamp created_at
  }

  Member {
    string uid PK
    string name
    string email
    string phone
    string role
    boolean is_active
    boolean verified
    timestamp created_at
  }

  Customers {
    string id PK
    string first_name
    string last_name
    string name_lowercase
    string email
    string phone
    string nic
    string image_url
    string notes
    float rating
    int rating_count
    int rentals_count
    timestamp last_rental_date
    timestamp created_at
  }

  Inventory {
    string id PK
    string shop_id FK
    string name
    string brand
    string type
    string color
    float size_feet
    int size_inches
    float size_total_inches
    float volume
    float rental_rate_hour
    float rental_rate_day
    float purchase_cost
    string damage_fee_rule
    string status
    string image_url
    string note
    timestamp created_at
    timestamp updated_at
  }

  DamageFees {
    string id PK
    string itemId FK
    string damage_type
    string description
    float fee_amount
    string active_status
    timestamp created_at
    timestamp updated_at
  }

  AgreementTemplates {
    string id PK
    string shop_id FK
    string template_name
    string templateName_lowercase
    string header
    string description
    boolean is_default
    json sections
    string assumption_of_risk
    string condition_of_equipment
    string damage_responsibility
    string governing_law
    string liability_waiver
    string signature_statement
    string use_of_equipment
    timestamp created_at
    timestamp updated_at
  }

  Rentals {
    string id PK
    string shop_id FK
    string customerId FK
    string itemId FK
    string staffId FK
    string agreementLink
    string invoiceLink
    string rentType
    float rate
    float amountExpected
    float amountPaid
    float securityDeposit
    string paymentStatus
    string status
    timestamp startTime
    timestamp expectedReturnTime
    timestamp actualReturnTime
    timestamp overdueTime
    string cached_customer_name
    string cached_item_name
    string cached_staff_name
    int customer_rating
    string customer_rating_comment
    timestamp created_at
  }

  Payments {
    string id PK
    string rentalId FK
    float amount
    string category
    string method
    string handledBy
    string note
    timestamp timestamp
  }

  DamageReports {
    string id PK
    string rentalId FK
    string itemId FK
    string damageType
    float estimatedCost
    float finalCost
    string note
    string reportedBy
    string status
    timestamp reportedAt
    timestamp resolvedAt
  }

  Photos {
    string id PK
    string damageId FK
    string photoUrl
    string uploadedBy
    timestamp uploadedAt
  }

  ActivityLogs {
    string id PK
    string shop_id FK
    string actor_id
    string actor_name
    string activity_type
    string entity_type
    string entity_id
    string description
    json metadata
    timestamp timestamp
  }