# QR Scanner Navigation Hub

## Overview
The QR Scanner automatically detects the scanned ID type and navigates to the appropriate details page.

## QR Code Format

### Recommended Format (with prefix)
Use a prefix to instantly identify the type without database lookups:

```
TYPE:ID
```

**Examples:**
- Customer: `CUST:abc123` or `C:abc123`
- Inventory Item: `ITEM:xyz789` or `I:xyz789`
- Rental: `RENT:rental_001` or `R:rental_001`
- User/Staff: `USER:uid_456` or `U:uid_456`

### Supported Prefixes

| Entity | Long Prefix | Short Prefix | Example |
|--------|------------|--------------|---------|
| Customer | `CUST:` | `C:` | `CUST:customer_id` |
| Inventory | `ITEM:` | `I:` | `ITEM:surfboard_123` |
| Rental | `RENT:` | `R:` | `RENT:rental_456` |
| User | `USER:` | `U:` | `USER:staff_789` |

### Legacy Format (without prefix)
For backward compatibility, QR codes without prefixes are supported but require multiple database lookups:

```
abc123
```

## How It Works

### With Prefix (Optimized - Zero DB reads for routing)
```
1. Scan QR: "CUST:abc123"
2. Parse prefix: "CUST" → Customer type identified
3. Navigate directly to Customer Details
4. Fetch customer data (1 DB read)
```

### Without Prefix (Legacy - 1-4 DB reads for routing)
```
1. Scan QR: "abc123"
2. Check if Customer exists (1 DB read)
3. Check if Item exists (1 DB read)
4. Check if Rental exists (1 DB read)
5. Check if User exists (1 DB read)
6. Navigate to first match found
```

## Benefits of Prefix Format

✅ **Instant Routing** - No database lookups needed to identify type  
✅ **Faster Response** - Immediate navigation  
✅ **Lower DB Costs** - Reduces read operations  
✅ **Better UX** - Faster feedback to users  
✅ **Scalable** - Works with any number of entity types  

## Generating QR Codes

### In QR Dialogs
When generating QR codes in your dialogs, use the prefixed format:

```dart
// Customer QR
QrImageView(
  data: 'CUST:${customer.id}',  // ✅ Optimized
  // data: customer.id,          // ❌ Legacy (slower)
)

// Item QR
QrImageView(
  data: 'ITEM:${item.id}',      // ✅ Optimized
)

// Rental QR
QrImageView(
  data: 'RENT:${rental.id}',    // ✅ Optimized
)

// User QR
QrImageView(
  data: 'USER:${user.uid}',     // ✅ Optimized
)
```

### In Database
Optionally, store the full QR data in the database for consistency:

```dart
// When creating a customer
final customer = CustomerModel(
  id: customerId,
  qrCode: 'CUST:$customerId',  // Store prefixed format
  // ... other fields
);
```

## Navigation Flow

```
┌─────────────────┐
│   Scan QR Code  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Parse Format   │
│  TYPE:ID        │
└────────┬────────┘
         │
    ┌────┴────┐
    │ Switch  │
    │  Type   │
    └────┬────┘
         │
    ┌────┴───────┬───────────┬──────────┐
    │            │           │          │
    ▼            ▼           ▼          ▼
┌───────┐  ┌────────┐  ┌────────┐  ┌──────┐
│Customer│ │ Item   │  │ Rental │  │ User │
│Details │ │Details │  │Details │  │Details│
└────────┘ └────────┘  └────────┘  └──────┘
```

## Error Handling

- **Unknown prefix**: Shows "QR code type not recognized"
- **Not found**: Shows "Customer/Item/Rental/User not found"
- **Invalid format**: Falls back to legacy identification
- **Network error**: Shows error and allows retry

## Testing

Use the QR Scanner Test Button:

```dart
import 'package:surfboard_rental_app/app/modules/qrScanner/examples/qr_scanner_test_button.dart';

// In your widget
QrScannerTestButton()
```

Generate test QR codes at: https://www.qr-code-generator.com/

Test data examples:
- `CUST:test_customer_123`
- `ITEM:test_board_456`
- `RENT:test_rental_789`
- `USER:test_user_abc`
