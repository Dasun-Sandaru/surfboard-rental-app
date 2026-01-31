# Firestore Data Structure

> Last Updated: 2026-01-31

This document defines the confirmed Firestore collection hierarchy for the Surfboard Rental App.

---

## 📁 Collection Hierarchy

```
├── shops/
│   └── {shopId}/
│       ├── customers/
│       │   └── {customerId}
│       ├── inventory/
│       │   └── {itemId}/
│       │       └── damage_fees/          ← Sub-collection
│       │           └── {feeId}
│       ├── rentals/
│       │   └── {rentalId}/
│       │       ├── payments/             ← Sub-collection
│       │       │   └── {paymentId}
│       │       └── damage_reports/       ← Sub-collection
│       │           └── {reportId}/
│       │               └── photos/       ← Sub-collection
│       │                   └── {photoId}
│       ├── members/
│       │   └── {memberId}
│       ├── agreement_templates/
│       │   └── {templateId}
│       └── activity_logs/
│           └── {logId}
│
└── users/
    └── {userId}                          ← Global user accounts
```

---

## 🏪 SHOP

**Path:** `shops/{shopId}`

| Field | Type | Description |
|-------|------|-------------|
| `name` | `string` | Business name |
| `location` | `string` | Shop location/address |
| `contact_number` | `string` | Phone number |
| `shop_code` | `string` | Unique shop code for joining |
| `owner_admin_uid` | `string` | UID of the owner/admin |
| `currency` | `string` | Currency code (e.g., 'LKR') |
| `default_daily_rate` | `number` | Default daily rental rate |
| `default_hourly_rate` | `number` | Default hourly rental rate |
| `is_tax_enabled` | `boolean` | Whether tax is applied |
| `tax_rate` | `number` | Tax rate percentage |
| `date_format` | `string` | Preferred date format |
| `time_zone` | `string` | Shop timezone |

---

## 👤 MEMBER

**Path:** `shops/{shopId}/members/{memberId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Member ID |
| `shop_id` | `string` | FK to shop |
| `name` | `string` | Full name |
| `email` | `string` | Email address |
| `phone` | `string` | Phone number |
| `role` | `string` | Role: `admin`, `staff` |
| `verified` | `boolean` | Email verified status |
| `is_active` | `boolean` | Account active status |
| `created_at` | `timestamp` | Created timestamp |

---

## 🧑‍🤝‍🧑 CUSTOMER

**Path:** `shops/{shopId}/customers/{customerId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Customer ID |
| `first_name` | `string` | First name |
| `last_name` | `string` | Last name |
| `phone` | `string` | Phone number |
| `email` | `string` | Email address |
| `nic` | `string` | National ID card number |
| `notes` | `string` | Additional notes |
| `image_url` | `string` | Profile image URL |
| `rentals_count` | `number` | Total rentals count |
| `last_rental_date` | `timestamp` | Last rental timestamp |
| `created_at` | `timestamp` | Created timestamp |
| `name_lowercase` | `string` | Lowercase full name (for search) |

---

## 🏄 INVENTORY_ITEM

**Path:** `shops/{shopId}/inventory/{itemId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Item ID |
| `shop_id` | `string` | FK to shop |
| `name` | `string` | Item name |
| `type` | `string` | Type: `Surfboard`, `SUP`, etc. |
| `brand` | `string` | Brand name |
| `color` | `string` | Color |
| `volume` | `number` | Volume in liters |
| `size_feet` | `number` | Size in feet |
| `size_inches` | `number` | Additional inches |
| `size_total_inches` | `number` | Total size in inches |
| `purchase_cost` | `number` | Purchase cost |
| `rental_rate_hour` | `number` | Hourly rental rate |
| `rental_rate_day` | `number` | Daily rental rate |
| `damage_fee_rule` | `string` | Damage fee rule identifier |
| `status` | `string` | Status: `available`, `rented`, `damaged`, `maintenance` |
| `note` | `string` | Additional notes |
| `image_url` | `string` | Item image URL |
| `created_at` | `timestamp` | Created timestamp |
| `updated_at` | `timestamp` | Last updated timestamp |

---

## 💰 DAMAGE_FEE

**Path:** `shops/{shopId}/inventory/{itemId}/damage_fees/{feeId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Fee ID |
| `damage_type` | `string` | Type of damage |
| `fee_amount` | `number` | Fee amount |
| `description` | `string` | Description |
| `active_status` | `boolean` | Whether fee is active |
| `created_at` | `timestamp` | Created timestamp |
| `updated_at` | `timestamp` | Last updated timestamp |

---

## 📋 RENTAL

**Path:** `shops/{shopId}/rentals/{rentalId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Rental ID |
| `shop_id` | `string` | FK to shop |
| `customerId` | `string` | FK to customer |
| `itemId` | `string` | FK to inventory item |
| `staffId` | `string` | FK to staff member |
| `rentType` | `string` | Type: `hourly`, `daily` |
| `startTime` | `timestamp` | Rental start time |
| `expectedReturnTime` | `timestamp` | Expected return time |
| `actualReturnTime` | `timestamp?` | Actual return time |
| `status` | `string` | Status: `active`, `completed`, `cancelled`, `overdue` |
| `paymentStatus` | `string` | Status: `unpaid`, `partial`, `paid` |
| `rate` | `number` | Applied rate |
| `amountExpected` | `number` | Total expected amount |
| `amountPaid` | `number` | Amount paid so far |
| `securityDeposit` | `object` | Security deposit details |
| `agreementLink` | `string` | Agreement PDF URL |
| `invoiceLink` | `string?` | Invoice PDF URL |
| `overdueTime` | `string?` | Overdue duration |
| `cached_customer_name` | `string` | Cached customer name |
| `cached_item_name` | `string` | Cached item name |
| `cached_staff_name` | `string` | Cached staff name |
| `created_at` | `timestamp` | Created timestamp |

### Security Deposit (embedded object)

| Field | Type | Description |
|-------|------|-------------|
| `enabled` | `boolean` | Whether deposit is enabled |
| `amount` | `number` | Deposit amount |
| `paid` | `number` | Amount paid |
| `refunded` | `number` | Amount refunded |

---

## 💵 PAYMENT

**Path:** `shops/{shopId}/rentals/{rentalId}/payments/{paymentId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Payment ID |
| `rentalId` | `string` | FK to rental |
| `handledBy` | `string` | FK to staff member |
| `amount` | `number` | Payment amount |
| `method` | `string` | Method: `cash`, `card`, `bank_transfer` |
| `category` | `string` | Category: `rental`, `deposit`, `damage`, `refund` |
| `note` | `string` | Additional notes |
| `timestamp` | `timestamp` | Payment timestamp |

---

## 🔨 DAMAGE_REPORT

**Path:** `shops/{shopId}/rentals/{rentalId}/damage_reports/{reportId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Report ID |
| `rentalId` | `string` | FK to rental |
| `itemId` | `string` | FK to inventory item |
| `reportedBy` | `string` | FK to staff member |
| `damage_type` | `string` | Type of damage |
| `note` | `string` | Damage description |
| `estimatedCost` | `number` | Estimated repair cost |
| `finalCost` | `number?` | Final cost after resolution |
| `status` | `string` | Status: `pending`, `resolved`, `waived` |
| `reportedAt` | `timestamp` | Report timestamp |
| `resolvedAt` | `timestamp?` | Resolution timestamp |

---

## 📷 DAMAGE_PHOTO

**Path:** `shops/{shopId}/rentals/{rentalId}/damage_reports/{reportId}/photos/{photoId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Photo ID |
| `reportId` | `string` | FK to damage report |
| `photoUrl` | `string` | Photo URL |
| `uploadedAt` | `timestamp` | Upload timestamp |
| `uploadedBy` | `string` | FK to staff member |

---

## 📄 AGREEMENT_TEMPLATE

**Path:** `shops/{shopId}/agreement_templates/{templateId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Template ID |
| `shop_id` | `string` | FK to shop |
| `template_name` | `string` | Template name |
| `description` | `string` | Template description |
| `is_default` | `boolean` | Whether this is the default template |
| `sections` | `string` | Template sections (JSON or formatted text) |
| `created_at` | `timestamp` | Created timestamp |
| `updated_at` | `timestamp` | Last updated timestamp |

---

## 📊 ACTIVITY_LOG

**Path:** `shops/{shopId}/activity_logs/{logId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | Log ID |
| `shop_id` | `string` | FK to shop |
| `activity_type` | `string` | Activity type enum |
| `entity_type` | `string` | Entity type: `Rental`, `Customer`, `Inventory`, etc. |
| `entity_id` | `string` | ID of affected entity |
| `actor_id` | `string` | FK to user who performed action |
| `actor_name` | `string` | Cached actor name |
| `description` | `string` | Activity description |
| `metadata` | `object` | Additional metadata |
| `timestamp` | `timestamp` | Activity timestamp |

---

## 👥 USER (Global)

**Path:** `users/{userId}`

| Field | Type | Description |
|-------|------|-------------|
| `id` | `string` | User ID (Firebase Auth UID) |
| `email` | `string` | Email address |
| `name` | `string` | Full name |
| `phone` | `string` | Phone number |
| `shop_id` | `string` | FK to associated shop |
| `role` | `string` | Role: `admin`, `staff` |
| `verified` | `boolean` | Email verified status |
| `is_active` | `boolean` | Account active status |
| `created_at` | `timestamp` | Created timestamp |

---

## 🔗 Relationships Summary

```
SHOP ||--o{ MEMBER : has
SHOP ||--o{ CUSTOMER : has
SHOP ||--o{ INVENTORY_ITEM : has
SHOP ||--o{ RENTAL : has
SHOP ||--o{ AGREEMENT_TEMPLATE : has
SHOP ||--o{ ACTIVITY_LOG : logs

INVENTORY_ITEM ||--o{ DAMAGE_FEE : has
RENTAL ||--o{ PAYMENT : has
RENTAL ||--o{ DAMAGE_REPORT : reports
DAMAGE_REPORT ||--o{ DAMAGE_PHOTO : photos

RENTAL }o--|| CUSTOMER : belongs_to
RENTAL }o--|| INVENTORY_ITEM : rents
RENTAL }o--|| MEMBER : handled_by
DAMAGE_REPORT }o--|| INVENTORY_ITEM : for_item
DAMAGE_REPORT }o--|| MEMBER : reported_by
PAYMENT }o--|| MEMBER : handled_by
```



erDiagram
    %% ===== ENTITIES =====
    SHOP {
        string id PK
        string name
        string location
        string contact_number
        string shop_code
        string owner_admin_uid
        string currency
        decimal default_daily_rate
        decimal default_hourly_rate
        boolean is_tax_enabled
        decimal tax_rate
        string date_format
        string time_zone
    }

    MEMBER {
        string id PK
        string shop_id FK
        string name
        string email
        string phone
        string role
        boolean verified
        boolean is_active
        timestamp created_at
    }

    CUSTOMER {
        string id PK
        string shop_id FK
        string first_name
        string last_name
        string phone
        string email
        string nic
        string notes
        string image_url
        decimal rentals_count
        timestamp last_rental_date
        timestamp created_at
        string name_lowercase
    }

    INVENTORY_ITEM {
        string id PK
        string shop_id FK
        string name
        string type
        string brand
        string color
        decimal volume
        decimal size_feet
        decimal size_inches
        decimal size_total_inches
        decimal purchase_cost
        decimal rental_rate_hour
        decimal rental_rate_day
        string damage_fee_rule
        string status
        string note
        string image_url
        timestamp created_at
        timestamp updated_at
    }

    DAMAGE_FEE {
        string id PK
        string itemId FK
        string damage_type
        decimal fee_amount
        string description
        boolean active_status
        timestamp created_at
        timestamp updated_at
    }

    RENTAL {
        string id PK
        string shop_id FK
        string customerId FK
        string itemId FK
        string staffId FK
        string rentType
        timestamp startTime
        timestamp expectedReturnTime
        timestamp actualReturnTime
        string status
        string paymentStatus
        decimal rate
        decimal amountExpected
        decimal amountPaid
        string agreementLink
        string invoiceLink
        string overdueTime
        string cached_customer_name
        string cached_item_name
        string cached_staff_name
        timestamp created_at
    }

    SECURITY_DEPOSIT {
        string id PK
        string rentalId FK
        decimal amount
        decimal paid
        decimal refunded
        boolean enabled
    }

    PAYMENT {
        string id PK
        string rentalId FK
        string handledBy FK
        decimal amount
        string method
        string category
        string note
        timestamp timestamp
    }

    DAMAGE_REPORT {
        string id PK
        string rentalId FK
        string itemId FK
        string reportedBy FK
        string damage_type
        decimal estimatedCost
        decimal finalCost
        string note
        string status
        timestamp reportedAt
        timestamp resolvedAt
    }

    DAMAGE_PHOTO {
        string id PK
        string reportId FK
        string photoUrl
        timestamp uploadedAt
        string uploadedBy FK
    }

    AGREEMENT_TEMPLATE {
        string id PK
        string shop_id FK
        string template_name
        string description
        boolean is_default
        string sections
        timestamp created_at
        timestamp updated_at
    }

    ACTIVITY_LOG {
        string id PK
        string shop_id FK
        string activity_type
        string entity_type
        string entity_id
        string actor_id FK
        string actor_name
        object metadata
        timestamp timestamp
    }

    USER {
        string id PK
        string email
        string name
        string phone
        string shop_id FK
        string role
        boolean verified
        boolean is_active
        timestamp created_at
    }

    %% ===== RELATIONSHIPS =====
    SHOP ||--o{ MEMBER : has
    SHOP ||--o{ CUSTOMER : has
    SHOP ||--o{ INVENTORY_ITEM : has
    SHOP ||--o{ RENTAL : has
    SHOP ||--o{ AGREEMENT_TEMPLATE : has
    SHOP ||--o{ ACTIVITY_LOG : logs

    INVENTORY_ITEM ||--o{ DAMAGE_FEE : has
    RENTAL ||--o{ PAYMENT : has
    RENTAL ||--o{ DAMAGE_REPORT : reports
    DAMAGE_REPORT ||--o{ DAMAGE_PHOTO : photos
    RENTAL ||--|| SECURITY_DEPOSIT : has

    RENTAL }o--|| CUSTOMER : belongs_to
    RENTAL }o--|| INVENTORY_ITEM : rents
    RENTAL }o--|| MEMBER : handled_by

    DAMAGE_REPORT }o--|| INVENTORY_ITEM : for_item
    DAMAGE_REPORT }o--|| MEMBER : reported_by
    PAYMENT }o--|| MEMBER : handled_by

---

## **1. Shop (`shops/{shopId}`)**

* This is the top-level entity representing a surf shop.
* Each shop contains **members**, **customers**, **inventory**, **rentals**, **agreement templates**, and **activity logs**.
* Fields store general shop info: `name`, `location`, `contact_number`, `shop_code` (used for staff/customer join), financial info (`currency`, default rates), tax info, and timezone/date format.

**Purpose:** Organizes all shop-specific data in one place, making multi-shop support easier.

---

## **2. Member (`shops/{shopId}/members/{memberId}`)**

* Represents shop staff or admins.
* Fields include `role`, `verified` status, and `is_active`.
* Linked to `RENTAL`, `PAYMENT`, and `DAMAGE_REPORT` to track which staff handled which operations.

**Purpose:** Access control and accountability.

---

## **3. Customer (`shops/{shopId}/customers/{customerId}`)**

* Represents people who rent surfboards.
* Fields store personal info (`name`, `phone`, `email`, `NIC`) and metadata (`rentals_count`, `last_rental_date`) for tracking customer history.
* The `name_lowercase` is optimized for searching in Firestore.

**Purpose:** Keeps customer info separate but linked to rentals for easy queries and reporting.

---

## **4. Inventory Item (`shops/{shopId}/inventory/{itemId}`)**

* Represents rentable items (surfboards, SUPs, etc.).
* Stores all physical attributes (`size`, `volume`, `brand`, `color`) and pricing (`rental_rate_day`, `rental_rate_hour`).
* `status` tracks availability (`available`, `rented`, `damaged`, `maintenance`).
* Each item can have multiple **damage fees** as a sub-collection.

**Purpose:** Centralized inventory management.

---

## **5. Damage Fee (`shops/{shopId}/inventory/{itemId}/damage_fees/{feeId}`)**

* Defines fee rules for different types of damage (e.g., fin damaged, lost).
* Each fee has `damage_type`, `fee_amount`, and `description`.

**Purpose:** Keeps damage rules flexible and tied directly to each inventory item.

---

## **6. Rental (`shops/{shopId}/rentals/{rentalId}`)**

* Core transactional entity.
* Links to **customer**, **inventory item**, and **staff member** who handled it.
* Stores rental type (`hourly`, `daily`), timing (`startTime`, `expectedReturnTime`, `actualReturnTime`), and financials (`rate`, `amountExpected`, `amountPaid`).
* Caches customer/item/staff names for easier reporting without additional queries.
* Tracks `status` (`active`, `completed`, `cancelled`, `overdue`) and `paymentStatus` (`unpaid`, `partial`, `paid`).

**Purpose:** Main record of every rental transaction.

---

## **7. Security Deposit (embedded in rental)**

* Stored as an **embedded object** inside `RENTAL`:

```json
"securityDeposit": {
    "enabled": true,
    "amount": 500,
    "paid": 0,
    "refunded": 0
}
```

* Fields:

  * `enabled`: If the deposit is required for this rental.
  * `amount`: Total deposit amount.
  * `paid`: Amount actually received.
  * `refunded`: Amount returned after rental.

**Purpose:** Keeps deposit info tightly coupled to the rental, no need for a separate collection. It allows partial refunds and deposit tracking per rental.

---

## **8. Payment (`shops/{shopId}/rentals/{rentalId}/payments/{paymentId}`)**

* Stores individual payment events, including:

  * Rental payments
  * Security deposits
  * Damage fees
  * Refunds
* Linked to **staff** who handled the payment.

**Purpose:** Full financial audit trail per rental.

---

## **9. Damage Report (`shops/{shopId}/rentals/{rentalId}/damage_reports/{reportId}`)**

* Tracks reported damage for a rental.
* Fields: `damage_type`, `estimatedCost`, `finalCost`, `status`, timestamps.
* Linked to **staff** who reported damage and **item** affected.
* Each report can have multiple **photos** as a sub-collection.

**Purpose:** Organizes damage tracking and fee calculation for reporting and billing.

---

## **10. Agreement Template (`shops/{shopId}/agreement_templates/{templateId}`)**

* Stores PDF or structured templates for rental agreements.
* Linked to **shop**.
* Can mark a template as default for the shop.

**Purpose:** Streamlines rental agreements per shop.

---

## **11. Activity Log (`shops/{shopId}/activity_logs/{logId}`)**

* Tracks all significant actions:

  * Rentals created
  * Payments processed
  * Damage reports
  * Customer edits
* Includes metadata and actor info (`actor_id`, `actor_name`).

**Purpose:** Provides auditing and tracking of shop activities.

---

## **12. User (`users/{userId}`)**

* Global user accounts, tied to Firebase Auth UID.
* Contains role, verification, and shop association.
* Links to member activity in shops.

**Purpose:** Allows login, global management, and staff/admin access across multiple shops.

---

## **🔗 Relationships Summary**

1. **Shop-centric:** Members, customers, inventory, rentals, agreement templates, and activity logs are all tied to a specific shop.
2. **Rental-centric:** Rentals link to customers, items, staff, payments, damage reports, and include security deposit details.
3. **Inventory-centric:** Items have damage fees; damage reports point back to the item.
4. **Payments and Damage Fees:** Payments can represent deposits, rental fees, and damage fees, all linked to rentals.
5. **Audit & Reporting:** Activity logs and cached names make reporting easier without multiple joins.

---

### ✅ **Key Advantages of This Structure**

* **Firestore-friendly:** Minimizes the need for joins by caching names (`cached_customer_name`) and embedding deposits inside rentals.
* **Hierarchical:** Sub-collections allow fast access to related data (`payments`, `damage_reports`, `photos`).
* **Scalable:** Each shop is isolated, making multi-shop support easy.
* **Flexible:** Damage fees, deposits, and payment categories are extendable without schema changes.
* **Auditable:** Activity logs and detailed payment tracking provide accountability.

---


**relationships in your updated Firestore structure**

---

## **1. Shop Relationships**

* **Shop → Member (1:N)**

  * A shop **has many members** (staff/admin).
  * Each member **belongs to exactly one shop**.
  * Purpose: Manage staff per shop and link them to rentals, payments, and reports.

* **Shop → Customer (1:N)**

  * A shop **has many customers**.
  * Each customer **belongs to one shop**.
  * Purpose: Track which customers rent from which shop.

* **Shop → Inventory Item (1:N)**

  * A shop **owns multiple inventory items**.
  * Each item **belongs to one shop**.
  * Purpose: Organize rentable items per shop.

* **Shop → Rental (1:N)**

  * A shop **has multiple rentals**.
  * Each rental **belongs to one shop**.
  * Purpose: Track all rental transactions per shop.

* **Shop → Agreement Template (1:N)**

  * A shop can have **multiple agreement templates**.
  * Each template **belongs to one shop**.
  * Purpose: Store shop-specific rental agreements.

* **Shop → Activity Log (1:N)**

  * A shop **records multiple activity logs**.
  * Each log **belongs to one shop**.
  * Purpose: Audit all actions performed in the shop.

---

## **2. Inventory Item Relationships**

* **Inventory Item → Damage Fee (1:N)**

  * Each item **can have multiple damage fees**.
  * Each damage fee **belongs to exactly one item**.
  * Purpose: Define rules for damages specific to each item (e.g., fin broken, lost).

* **Inventory Item → Rental (1:N indirect)**

  * An inventory item **can be rented multiple times**, each represented as a rental.
  * Rental references the item using `itemId`.
  * Purpose: Track which item was rented in each transaction.

* **Inventory Item → Damage Report (1:N)**

  * Each item **can have multiple damage reports** via rentals.
  * Each damage report **refers to one item**.
  * Purpose: Track damages for reporting and billing.

---

## **3. Customer Relationships**

* **Customer → Rental (1:N)**

  * A customer **can have many rentals**.
  * Each rental **belongs to one customer** via `customerId`.
  * Purpose: Track customer rental history.

---

## **4. Rental Relationships**

* **Rental → Payment (1:N)**

  * Each rental **can have multiple payments** (rental fee, deposit, damage fee, refund).
  * Each payment **belongs to one rental** via `rentalId`.
  * Purpose: Track full financial history per rental.

* **Rental → Damage Report (1:N)**

  * Each rental **can have multiple damage reports**.
  * Each damage report **belongs to one rental**.
  * Purpose: Record all damages reported for a rental.

* **Rental → Customer (N:1)**

  * Each rental **belongs to exactly one customer**.
  * Purpose: Link rentals to the renter.

* **Rental → Inventory Item (N:1)**

  * Each rental **belongs to exactly one item**.
  * Purpose: Track which item was rented.

* **Rental → Member (N:1)**

  * Each rental **is handled by exactly one staff**.
  * Purpose: Track staff responsibility for rental.

* **Rental → Security Deposit (embedded)**

  * Security deposit is **embedded within rental**.
  * Purpose: Track deposit per rental without separate collection.

---

## **5. Damage Report Relationships**

* **Damage Report → Damage Photo (1:N)**

  * Each damage report **can have multiple photos**.
  * Each photo **belongs to exactly one report**.
  * Purpose: Visual evidence of damage.

* **Damage Report → Member (N:1)**

  * Each report **is created by one staff member**.
  * Purpose: Accountability for reporting.

* **Damage Report → Inventory Item (N:1)**

  * Each report **refers to one inventory item**.
  * Purpose: Identify damaged item.

---

## **6. Payment Relationships**

* **Payment → Member (N:1)**

  * Each payment **is handled by one staff**.
  * Purpose: Track payment responsibility.

* **Payment → Rental (N:1)**

  * Each payment **belongs to one rental**.
  * Purpose: Associate payment to a rental transaction.

---

## **7. Agreement Template Relationships**

* **Template → Shop (N:1)**

  * Each template **belongs to one shop**.
  * Purpose: Templates are shop-specific.

---

## **8. Activity Log Relationships**

* **Log → Shop (N:1)**

  * Each activity log **belongs to one shop**.
  * Purpose: Track shop activities.

* **Log → Actor (Member/User) (N:1)**

  * Each log **references the staff/user who performed the action**.
  * Purpose: Audit trail.

---

## **9. User Relationships**

* **User → Member (1:1 per shop)**

  * A global user account can **be linked to a member in a shop**.
  * Purpose: Authenticate globally while managing shop-specific roles.

---

### **Summary of Cardinalities**

| Relationship                   | Type |
| ------------------------------ | ---- |
| Shop → Member                  | 1:N  |
| Shop → Customer                | 1:N  |
| Shop → Inventory Item          | 1:N  |
| Shop → Rental                  | 1:N  |
| Shop → Agreement Template      | 1:N  |
| Shop → Activity Log            | 1:N  |
| Inventory Item → Damage Fee    | 1:N  |
| Rental → Payment               | 1:N  |
| Rental → Damage Report         | 1:N  |
| Damage Report → Damage Photo   | 1:N  |
| Rental → Customer              | N:1  |
| Rental → Inventory Item        | N:1  |
| Rental → Member                | N:1  |
| Payment → Member               | N:1  |
| Damage Report → Member         | N:1  |
| Damage Report → Inventory Item | N:1  |
| Agreement Template → Shop      | N:1  |
| Activity Log → Shop            | N:1  |
| Activity Log → Actor           | N:1  |

---

✅ **Key Takeaways:**

1. **One-to-many dominates:** Firestore works well with hierarchical structures. Most entities are sub-collections of shop or rental.
2. **Embedded objects for simplicity:** Security deposit is embedded in rental instead of a separate collection.
3. **Caching names:** Rentals cache `cached_customer_name`, `cached_item_name`, `cached_staff_name` for faster queries without joins.
4. **Auditability:** Activity logs, payments, damage reports, and photos are all linked to responsible members.
5. **Extensible:** Damage fees and templates can be added without changing existing structures.

---
