# 🏄 Surfboard Rental Management System
## Complete User Manual

> **Version:** 1.0.0  
> **Platform:** Android · iOS  
> **Last Updated:** September 2026  
> **Document Type:** End-User & Administrator Reference Guide

---

## Table of Contents

1. [Introduction & System Overview](#1-introduction--system-overview)
2. [Getting Started](#2-getting-started)
   - 2.1 [Installing the App](#21-installing-the-app)
   - 2.2 [First-Time Admin Setup](#22-first-time-admin-setup)
   - 2.3 [Signing In](#23-signing-in)
   - 2.4 [Email Verification](#24-email-verification)
   - 2.5 [Forgot Password](#25-forgot-password)
3. [User Roles & Permissions](#3-user-roles--permissions)
   - 3.1 [Admin Role](#31-admin-role)
   - 3.2 [Staff Role](#32-staff-role)
   - 3.3 [Permissions Matrix](#33-permissions-matrix)
4. [Admin Dashboard](#4-admin-dashboard)
   - 4.1 [Dashboard Overview](#41-dashboard-overview)
   - 4.2 [Quick Stats Cards](#42-quick-stats-cards)
   - 4.3 [Management Grid](#43-management-grid)
   - 4.4 [Analytics Button](#44-analytics-button)
   - 4.5 [QR Scanner Button](#45-qr-scanner-button)
   - 4.6 [Alerts Tab](#46-alerts-tab)
5. [Staff Dashboard](#5-staff-dashboard)
   - 5.1 [Dashboard Overview](#51-dashboard-overview)
   - 5.2 [Quick Stats Cards](#52-quick-stats-cards)
   - 5.3 [Operations Grid](#53-operations-grid)
6. [Surfboard Inventory Management](#6-surfboard-inventory-management)
   - 6.1 [Viewing the Inventory List](#61-viewing-the-inventory-list)
   - 6.2 [Adding a New Surfboard](#62-adding-a-new-surfboard)
   - 6.3 [Editing a Surfboard](#63-editing-a-surfboard)
   - 6.4 [Viewing Item Details](#64-viewing-item-details)
   - 6.5 [Damage Fee Rules per Board](#65-damage-fee-rules-per-board)
   - 6.6 [Board Status Reference](#66-board-status-reference)
   - 6.7 [QR Code Labels](#67-qr-code-labels)
7. [Customer Management](#7-customer-management)
   - 7.1 [Viewing the Customer List](#71-viewing-the-customer-list)
   - 7.2 [Adding a New Customer](#72-adding-a-new-customer)
   - 7.3 [Editing a Customer Profile](#73-editing-a-customer-profile)
   - 7.4 [Customer Details & Rental History](#74-customer-details--rental-history)
   - 7.5 [Customer Contact Actions](#75-customer-contact-actions)
   - 7.6 [Customer Rating System](#76-customer-rating-system)
8. [Creating a New Rental](#8-creating-a-new-rental)
   - 8.1 [Overview of the Rental Creation Flow](#81-overview-of-the-rental-creation-flow)
   - 8.2 [Step 1: Select Customer](#82-step-1-select-customer)
   - 8.3 [Step 2: Set Rental Period](#83-step-2-set-rental-period)
   - 8.4 [Step 3: Add Surfboard Items](#84-step-3-add-surfboard-items)
   - 8.5 [Step 4: Proceed to Agreement Wizard](#85-step-4-proceed-to-agreement-wizard)
9. [Agreement Wizard (Rental Contract)](#9-agreement-wizard-rental-contract)
   - 9.1 [Wizard Overview](#91-wizard-overview)
   - 9.2 [Step 1 — Board Details Review](#92-step-1--board-details-review)
   - 9.3 [Step 2 — Pricing & Security Deposit](#93-step-2--pricing--security-deposit)
   - 9.4 [Step 3 — Damage Fee Agreement](#94-step-3--damage-fee-agreement)
   - 9.5 [Step 4 — Review & Digital Signature](#95-step-4--review--digital-signature)
   - 9.6 [Generating & Sharing the Agreement](#96-generating--sharing-the-agreement)
10. [Active Rentals & Rental Management](#10-active-rentals--rental-management)
    - 10.1 [Rentals List View](#101-rentals-list-view)
    - 10.2 [Rental Detail Screen](#102-rental-detail-screen)
    - 10.3 [Rental Status Reference](#103-rental-status-reference)
11. [Board Inspection & Return Processing](#11-board-inspection--return-processing)
    - 11.1 [Accessing the Inspection Screen](#111-accessing-the-inspection-screen)
    - 11.2 [Reading the Countdown Timer](#112-reading-the-countdown-timer)
    - 11.3 [Reviewing Rental & Payment Summary](#113-reviewing-rental--payment-summary)
    - 11.4 [Confirm Return — No Damage](#114-confirm-return--no-damage)
    - 11.5 [Report Damage — Board Damaged](#115-report-damage--board-damaged)
12. [Damage Reports & Incident Management](#12-damage-reports--incident-management)
    - 12.1 [Viewing Pending Damages](#121-viewing-pending-damages)
    - 12.2 [Damage Type Reference](#122-damage-type-reference)
    - 12.3 [Damage Status Workflow](#123-damage-status-workflow)
    - 12.4 [Resolving a Damage Report](#124-resolving-a-damage-report)
13. [Payments & Financial Ledger](#13-payments--financial-ledger)
    - 13.1 [Opening the Payment Screen](#131-opening-the-payment-screen)
    - 13.2 [Recording a Payment](#132-recording-a-payment)
    - 13.3 [Security Deposit Tracking](#133-security-deposit-tracking)
    - 13.4 [Payment Categories Reference](#134-payment-categories-reference)
    - 13.5 [Payment Methods](#135-payment-methods)
14. [QR Scanner](#14-qr-scanner)
    - 14.1 [Scanning a Surfboard QR Code](#141-scanning-a-surfboard-qr-code)
    - 14.2 [Scanning a Customer Badge](#142-scanning-a-customer-badge)
15. [Alerts & Notifications](#15-alerts--notifications)
    - 15.1 [Alerts Tab Overview](#151-alerts-tab-overview)
    - 15.2 [Scheduled Notifications](#152-scheduled-notifications)
16. [Reports & Data Export](#16-reports--data-export)
    - 16.1 [Accessing Reports](#161-accessing-reports)
    - 16.2 [Report Types](#162-report-types)
    - 16.3 [Filtering & Date Range](#163-filtering--date-range)
    - 16.4 [Exporting to PDF](#164-exporting-to-pdf)
17. [Analytics Dashboard](#17-analytics-dashboard)
    - 17.1 [Revenue Trend Chart](#171-revenue-trend-chart)
    - 17.2 [Board Status Distribution](#172-board-status-distribution)
    - 17.3 [Board Type Utilization](#173-board-type-utilization)
    - 17.4 [Popular Boards Leaderboard](#174-popular-boards-leaderboard)
18. [Agreement Templates](#18-agreement-templates)
    - 18.1 [Creating a Template](#181-creating-a-template)
    - 18.2 [Editing Template Sections](#182-editing-template-sections)
    - 18.3 [Setting a Default Template](#183-setting-a-default-template)
19. [Settings & Configuration](#19-settings--configuration)
    - 19.1 [Profile Management](#191-profile-management)
    - 19.2 [Shop Details](#192-shop-details)
    - 19.3 [Currency Configuration](#193-currency-configuration)
    - 19.4 [Date Format & Timezone](#194-date-format--timezone)
    - 19.5 [Rental Pricing Configuration](#195-rental-pricing-configuration)
    - 19.6 [Inventory Configuration](#196-inventory-configuration)
    - 19.7 [Staff Access Control](#197-staff-access-control)
    - 19.8 [Language Settings](#198-language-settings)
    - 19.9 [Dark Mode](#199-dark-mode)
    - 19.10 [Notifications Settings](#1910-notifications-settings)
    - 19.11 [Billing & Usage Monitor](#1911-billing--usage-monitor)
20. [Staff User Management](#20-staff-user-management)
    - 20.1 [Viewing All Users](#201-viewing-all-users)
    - 20.2 [Creating a Staff Account](#202-creating-a-staff-account)
    - 20.3 [Activating / Deactivating Staff](#203-activating--deactivating-staff)
21. [Rental History](#21-rental-history)
22. [Maintenance Mode](#22-maintenance-mode)
23. [Frequently Asked Questions (FAQ)](#23-frequently-asked-questions-faq)
24. [Troubleshooting Guide](#24-troubleshooting-guide)
25. [Glossary of Terms](#25-glossary-of-terms)

---

## 1. Introduction & System Overview

The **Surfboard Rental Management System** is a comprehensive mobile application designed specifically for surf shops, beach rental outfits, and water sports equipment centres. It digitises the entire rental lifecycle — from customer onboarding and board cataloguing, through contract generation and digital signatures, to real-time board inspections, damage incident handling, and payment reconciliation.

### What the App Does

| Capability | Description |
| :--- | :--- |
| **Digital Waivers** | Automatically generates signed rental agreements as PDF documents |
| **Inventory Control** | Real-time tracking of every surfboard's status (Available, Rented, Repair, etc.) |
| **Customer CRM** | Encrypted storage of customer profiles, NIC/passport details, and rental history |
| **Smart Pricing** | Configurable hourly and daily rates with grace periods, late fees, and tax support |
| **Damage Management** | Photo-backed incident reporting with automated fee deduction from security deposits |
| **Analytics** | Revenue trends, fleet utilization, and popular board reporting |
| **Multi-Staff Support** | Granular role-based access control for each staff member |
| **Multi-Language** | English and Sinhala (සිංහල) support |

### System Architecture at a Glance

```
┌──────────────────────────────────────────────────────────┐
│                   Surfboard Rental App                   │
│                   (Flutter Mobile App)                   │
├────────────────────────┬─────────────────────────────────┤
│   Firebase Services    │     Supabase Storage            │
│   ─────────────────    │     ─────────────────           │
│   • Authentication     │     • Board Photos              │
│   • Firestore DB       │     • Damage Photos             │
│   • Real-time Sync     │     • Customer ID Images        │
├────────────────────────┴─────────────────────────────────┤
│   Document Layer: PDF Generation + Digital Signatures    │
│   Email Layer: EmailJS — Automatic Waiver Delivery       │
│   Security Layer: AES Encryption (Customer PII Data)     │
└──────────────────────────────────────────────────────────┘
```

---

## 2. Getting Started

### 2.1 Installing the App

**Android:**
1. Download the `.apk` installer file from your shop's provided distribution link.
2. On your Android device, go to **Settings → Security → Install Unknown Apps** and enable installation for your file manager or browser.
3. Open the `.apk` file and tap **Install**.
4. The app icon will appear on your home screen.

> **Note:** The app supports Android 5.0 (Lollipop / API 21) and above.

**iOS:**
1. Download and install through the provided TestFlight link or App Store listing.
2. Open the link on your iPhone or iPad and tap **Install**.

---

### 2.2 First-Time Admin Setup

When an administrator launches the app for the first time with a new account, they are guided through a **Shop Setup Wizard**.

**Steps:**

1. **Launch the App** → Tap **Sign Up** on the login screen.
2. Enter your **Full Name**, **Email Address**, and a secure **Password** (minimum 8 characters).
3. Tap **Create Account** and then **Verify your email** using the link sent to your inbox.
4. After verification, sign in. You will be redirected to the **Shop Setup Wizard**.
5. Fill in the following:
   - **Business Name** *(e.g., "Arugam Bay Surf Co.")*
   - **Shop Location** *(e.g., "Main Street, Arugam Bay, Sri Lanka")*
   - **Contact Phone Number**
   - **Shop Email Address**
   - **Default Currency** *(e.g., LKR, USD, AUD)*
   - **Default Hourly Rate** and **Default Daily Rate**
6. Tap **Save Shop Details**.

> **[Screenshot Placeholder: Shop Setup Wizard — Business Information Form]**

After setup, you will be directed to the **Admin Dashboard**. A banner at the top of the dashboard will alert you if any required configurations are still missing (e.g., agreement template not set, rental pricing not configured).

---

### 2.3 Signing In

1. Launch the app. You will see the **Sign In** screen.
2. Enter your registered **Email Address** and **Password**.
3. Tap **Sign In**.
4. The app will authenticate your credentials and route you to:
   - **Admin Dashboard** — if your account has the `admin` role.
   - **Staff Dashboard** — if your account has the `staff` role.

> **[Screenshot Placeholder: Sign In Screen with Email and Password Fields]**

---

### 2.4 Email Verification

All new accounts must verify their email address before accessing the application.

1. After registration, check your inbox for a verification email from the system.
2. Click the **Verify Email** link in the email.
3. Return to the app and sign in. The system will confirm your verified status automatically.

> **Tip:** If the email hasn't arrived within 2 minutes, check your **Spam / Junk** folder.

---

### 2.5 Forgot Password

1. On the **Sign In** screen, tap **Forgot Password?**
2. Enter your registered email address.
3. Tap **Send Reset Link**.
4. Open the reset link in your inbox and set a new password.
5. Return to the app and sign in with your new credentials.

---

## 3. User Roles & Permissions

### 3.1 Admin Role

An **Admin** has unrestricted access to every feature in the application. Admins are typically the shop owner or senior manager responsible for:

- Configuring rental pricing, tax rates, and grace periods.
- Managing staff accounts and adjusting their access levels.
- Accessing financial analytics, PDF reports, and revenue data.
- Creating and editing legal agreement waiver templates.
- Managing shop profile and EmailJS document delivery settings.

### 3.2 Staff Role

A **Staff** member has a default set of operational permissions focused on day-to-day activities. Their access level is determined by the **Admin** through the Staff Access Control panel. Staff members can:

- Create, start, and complete rentals (if permitted).
- Register and search for customers.
- Perform board inspections and log returns.
- Process payments and record damage reports.
- View inventory and surfboard details.

### 3.3 Permissions Matrix

The following table shows the default access level for each feature. Admins can toggle each item on or off per staff member from **Settings → Staff Access Control**.

| Feature | Admin | Staff (Default) |
| :--- | :---: | :---: |
| New Rental Check-Out | ✅ | ✅ |
| View Active Rentals | ✅ | ✅ |
| View Rental History | ✅ | ✅ |
| Alerts & Notifications | ✅ | ✅ |
| Activity Logs | ✅ | ✅ |
| QR Scanner | ✅ | ✅ |
| View Inventory | ✅ | ✅ |
| View Damage Fee Schedules | ✅ | ✅ |
| Add Inventory Items | ✅ | ❌ |
| Edit Inventory Items | ✅ | ❌ |
| Delete Inventory Items | ✅ | ❌ |
| View Customers | ✅ | ✅ |
| Add Customers | ✅ | ✅ |
| Edit Customers | ✅ | ✅ |
| Contact Customer (Call/Email) | ✅ | ❌ |
| Process Payments | ✅ | ✅ |
| Manage Damage Fees | ✅ | ✅ |
| Generate Reports & Analytics | ✅ | ❌ |
| Manage Staff Accounts | ✅ | ❌ |
| View Shop Details | ✅ | ✅ |
| Edit Shop Details | ✅ | ❌ |
| Edit Currency Setting | ✅ | ❌ |
| Edit Date / Timezone Settings | ✅ | ❌ |
| Manage Agreement Templates | ✅ | ❌ |
| Manage Staff Access Control | ✅ | ❌ |
| Billing & Usage Monitor | ✅ | ❌ |

---

## 4. Admin Dashboard

### 4.1 Dashboard Overview

The Admin Dashboard is the central hub for store managers. It provides a real-time snapshot of the shop's operational status.

> **[Screenshot Placeholder: Admin Dashboard — Full Screen Overview]**

The dashboard has **three tabs** accessible from the **Bottom Navigation Bar**:
- **Home** — Dashboard & Quick Stats.
- **New Rental** (centre button) — Starts a new rental check-out directly.
- **Alerts** — Notifications and alerts log.

---

### 4.2 Quick Stats Cards

The top section of the dashboard displays **four live stat cards**:

| Card | What it Shows | Tap Action |
| :--- | :--- | :--- |
| **Active Rentals** | Count of currently active rentals | Opens the Active Rentals list |
| **Boards Available** | Count of boards ready to rent | Opens the Available Inventory list |
| **Damages Pending** | Count of unresolved damage incidents | Opens the Damages Pending list |
| **Total Customers** | Count of registered customers | No navigation (display only) |

> **[Screenshot Placeholder: Four Stats Cards Grid]**

---

### 4.3 Management Grid

Below the stats cards is the **Management Grid**, providing quick navigation to all core management sections:

| Grid Item | Destination Screen |
| :--- | :--- |
| **Manage Users** | Staff account management |
| **Inventory** | Full surfboard inventory list |
| **Customers** | Customer CRM list |
| **Rentals** | Rental History archive |
| **Reports** | PDF Report generation dashboard |
| **Agreements** | Legal agreement template library |
| **Settings** | Full settings configuration panel |
| **Seed Data** | *(Admin utility)* Load sample test data |

> **[Screenshot Placeholder: Management Grid with Icons]**

---

### 4.4 Analytics Button

The **chart icon** (📊) in the top-right corner of the dashboard opens the **Analytics Dashboard**, providing visual revenue and fleet utilization charts.

---

### 4.5 QR Scanner Button

The **barcode icon** (📷) in the top-right corner opens the **QR Scanner**, allowing rapid board lookup and customer identification directly from the dashboard.

---

### 4.6 Alerts Tab

Tapping the **Alerts** icon on the bottom navigation bar opens the notifications log, which includes:
- Overdue rental warnings.
- Damage report alerts.
- System notifications and reminders.

---

## 5. Staff Dashboard

### 5.1 Dashboard Overview

The Staff Dashboard is a streamlined version of the Admin Dashboard, limited to operational functions. It shares the same layout structure.

> **[Screenshot Placeholder: Staff Dashboard — Full Screen Overview]**

---

### 5.2 Quick Stats Cards

Staff see the same four live stats cards:
- Active Rentals
- Boards Available
- Damages Pending
- Total Customers

---

### 5.3 Operations Grid

The staff operations grid includes only the tools relevant to their role:

| Grid Item | Destination Screen |
| :--- | :--- |
| **Inventory** | View surfboard inventory list |
| **Customers** | View and manage customers |
| **Rentals** | View rental history |
| **Settings** | Personal profile and view-only settings |

---

## 6. Surfboard Inventory Management

### 6.1 Viewing the Inventory List

**Path:** Dashboard → **Inventory**

The inventory screen displays all surfboards belonging to your shop. You can:
- Browse boards by scrolling.
- Filter by **status** (Available, Rented, Repair, Damaged, Retired).
- Search by board name or board ID.

> **[Screenshot Placeholder: Inventory List with Board Cards and Status Chips]**

---

### 6.2 Adding a New Surfboard

> **Required Role:** Admin only (or Staff with `inventory_add` permission enabled).

1. Open the **Inventory** screen.
2. Tap the **"+"** button (Add Inventory).
3. Fill in the surfboard details:

| Field | Description | Example |
| :--- | :--- | :--- |
| **Name / Label** | A short identifier for the board | "Blue Fish #3" |
| **Board Type** | Shortboard, Longboard, Fish, Funboard, Hybrid, SUP | Fish |
| **Brand** | Manufacturer brand | Channel Islands |
| **Length — Feet** | Board length in feet | 6 |
| **Length — Inches** | Remaining inches beyond feet measurement | 2 |
| **Volume (L)** | Buoyancy volume in litres | 35 |
| **Color** | Primary board colour | Blue / White |
| **Purchase Cost** | Original acquisition cost (for records) | 45000 |
| **Hourly Rental Rate** | Price per hour for this board | 1500 |
| **Daily Rental Rate** | Price per day for this board | 5000 |
| **Damage Fee Rule** | Reference to which damage fee schedule applies | Standard / Premium |
| **Note** | Optional internal note for staff | "Has ding on tail — cosmetic only" |
| **Photo** | Upload a board photo (from gallery or camera) | — |

4. Tap **Save**.
5. The board will appear in the Inventory list with status **Available**.

> **[Screenshot Placeholder: Add Inventory Form]**

---

### 6.3 Editing a Surfboard

1. Open the **Inventory** screen.
2. Tap on a board card to open **Item Details**.
3. Tap the **Edit** (pencil icon) button.
4. Update the required fields.
5. Tap **Save Changes**.

---

### 6.4 Viewing Item Details

Tapping a surfboard card on the inventory list opens its detailed profile, which includes:
- Board photo.
- All technical specifications.
- Current status badge.
- Attached damage fee rules.
- Rental history for that specific board.

> **[Screenshot Placeholder: Item Details Screen]**

---

### 6.5 Damage Fee Rules per Board

Each board can have one or more **Damage Fee Rules** configured. These define pre-agreed repair costs that customers accept at check-out.

| Rule Field | Description |
| :--- | :--- |
| **Damage Type** | Fin Damaged, Board Cracked, Leash Broken, or Lost |
| **Fee Amount** | Cost charged to the customer for this damage |
| **Description** | Explanation shown to the customer on the agreement |
| **Active Status** | Toggle to enable/disable this rule |

**To add a Damage Fee Rule:**
1. Open **Item Details** → Tap **Damage Fees** section.
2. Tap **"+" Add Rule**.
3. Select damage type, enter fee amount and description.
4. Tap **Save**.

---

### 6.6 Board Status Reference

| Status | Meaning |
| :--- | :--- |
| 🟢 **Available** | Board is in good condition and ready to be rented |
| 🔵 **Rented** | Board is currently checked out on an active rental |
| 🟡 **Repair** | Board is undergoing maintenance or damage repair |
| 🔴 **Damaged** | Board has been returned with confirmed damage |
| ⚫ **Retired** | Board has been decommissioned or removed from service |

---

### 6.7 QR Code Labels

Every board in the inventory has an associated **QR code** that encodes its unique board ID.

**To view and print a QR code:**
1. Open **Item Details** for the board.
2. Locate the **QR Code** section.
3. Tap **Share** or **Print** to output the label.
4. Attach the printed QR label to the surfboard rail or fin box area.

> **Tip:** Using a QR scanner during check-out is the fastest and most accurate way to assign the correct board to a rental.

---

## 7. Customer Management

### 7.1 Viewing the Customer List

**Path:** Dashboard → **Customers**

The customer list screen shows all registered customers. Use the **search bar** to find customers by:
- First or last name.
- Phone number.

> **[Screenshot Placeholder: Customer List Screen with Search Bar]**

---

### 7.2 Adding a New Customer

1. Open the **Customers** screen.
2. Tap the **"+"** button.
3. Fill in the required details:

| Field | Description | Required? |
| :--- | :--- | :---: |
| **First Name** | Customer's given name | ✅ |
| **Last Name** | Customer's family name | ✅ |
| **Phone Number** | Contact number (with country code) | ✅ |
| **NIC / Passport Number** | National ID or Passport (*encrypted before storage*) | ✅ |
| **Email Address** | For agreement delivery | Optional |
| **Notes** | Internal staff notes about the customer | Optional |
| **Profile Photo** | Upload from camera or gallery | Optional |

4. Tap **Save Customer**.

> **[Screenshot Placeholder: Add Customer Form]**

> **Security Note:** The NIC / Passport field is encrypted using AES encryption before being stored in the cloud database. The original value is never stored in plain text.

---

### 7.3 Editing a Customer Profile

1. Open the **Customer List** → Tap on a customer.
2. On the **Customer Details** screen, tap **Edit** (pencil icon).
3. Update the required fields.
4. Tap **Save Changes**.

---

### 7.4 Customer Details & Rental History

The **Customer Details** screen shows:
- Full profile with photo.
- Total number of completed rentals.
- Average customer rating.
- Date of last rental.
- Full list of past rentals with status and dates.

> **[Screenshot Placeholder: Customer Details Screen — Rental History Section]**

---

### 7.5 Customer Contact Actions

Admins (and staff with `customer_contact` permission) can directly:
- **Call** the customer by tapping the phone icon.
- **Send SMS** via the device's native messaging app.
- **Email** the customer using the device's email client.

---

### 7.6 Customer Rating System

After a rental is completed, staff can rate the customer's conduct (1–5 stars) and add a comment. This rating is visible on the customer's profile and helps future staff assess trust levels for high-value equipment.

---

## 8. Creating a New Rental

### 8.1 Overview of the Rental Creation Flow

```
[Select Customer] → [Set Dates & Times] → [Add Surfboard(s)] → [Draft Agreement]
       │                    │                      │                   │
  Search/Scan          Pick start &             Scan QR or        Enter 4-step
   Customer              due dates           choose from list    wizard & sign
```

**Access:** Tap the **centre "+" button** on the Bottom Navigation Bar.

> **[Screenshot Placeholder: New Rental Screen — Full View]**

---

### 8.2 Step 1: Select Customer

1. Tap the **Customer Selector** field at the top of the New Rental screen.
2. In the search dialog that opens, type the customer's name or phone number to find them.
3. Tap on the customer's name to select them.

**Alternatively:**
- Tap the **QR scan icon** next to the customer field to scan the customer's registered badge or QR card.

> **[Screenshot Placeholder: Customer Selector with Search Field and QR Scan Button]**

---

### 8.3 Step 2: Set Rental Period

1. Under **Rental Period**, tap the **Start Date/Time** card.
2. Use the date and time pickers to select the check-out date and exact time.
3. Tap the **Due Date/Time** card and repeat for the expected return date and time.

> **Tip:** The system automatically detects the duration and applies the configured grace period tolerance when checking for overdue status.

---

### 8.4 Step 3: Add Surfboard Items

**Method A — Scan QR Code:**
1. Tap the **Scan Barcode** icon on the Items section header.
2. Point the camera at the surfboard's QR code label.
3. The board is automatically found and added to the rental.

**Method B — Manual Selection:**
1. Tap **+ Add Item**.
2. A list of all Available boards appears.
3. Tap on the board you wish to add.

**For each item added,** you can also configure:
- The **Rent Type** (Hourly or Daily) for that individual item.
- Custom rate override (if the board has a specific rate).

> **[Screenshot Placeholder: Items Section with a Selected Board Card]**

---

### 8.5 Step 4: Proceed to Agreement Wizard

Once all details are set (customer, dates, and at least one board selected):

1. Tap **Draft Agreement** at the bottom of the New Rental screen.
2. You will be taken to the **Agreement Wizard** (4-step process).

---

## 9. Agreement Wizard (Rental Contract)

### 9.1 Wizard Overview

The Agreement Wizard collects pricing, damage liability, and customer consent in a structured, step-by-step flow.

```
Step 1: Board Details  →  Step 2: Pricing  →  Step 3: Damage Fees  →  Step 4: Review & Sign
```

A **progress bar** at the top shows the current step. Tap **Previous** to go back.

> **[Screenshot Placeholder: Agreement Wizard with Progress Bar — Step 2 Active]**

---

### 9.2 Step 1 — Board Details Review

Displays a summary of the selected surfboard(s):
- Board name, type, brand.
- Physical dimensions (length and volume).
- Assigned rental rate.

Review the details carefully. Tap **Continue** when ready.

---

### 9.3 Step 2 — Pricing & Security Deposit

Configure the final financial terms:

| Field | Description |
| :--- | :--- |
| **Rent Type** | Hourly or Daily |
| **Rental Rate** | Hourly or daily rate (auto-filled from board or shop default) |
| **Expected Amount** | Total rental cost based on duration and rate |
| **Tax Enabled** | Whether VAT/GST is applied (configured in shop settings) |
| **Tax Amount** | Auto-calculated if tax is enabled |
| **Security Deposit Required** | Toggle to collect a refundable security deposit |
| **Deposit Amount** | Amount held as collateral against damage |

Tap **Continue** when ready.

> **[Screenshot Placeholder: Pricing Step — Deposit Toggle and Amount Fields]**

---

### 9.4 Step 3 — Damage Fee Agreement

Displays all applicable damage fee rules for the selected board(s):

| Damage Type | Description | Fee Amount |
| :--- | :--- | :--- |
| Fin Damaged | Fin is broken or missing | *(per rule)* |
| Board Cracked | Body of the board is cracked | *(per rule)* |
| Leash Broken | Leash is snapped or missing | *(per rule)* |
| Lost | Board is lost completely | *(per rule)* |

These fees are presented to the customer as part of the rental agreement. The customer's signature in Step 4 confirms they have read and agreed to these terms.

Tap **Continue** when ready.

> **[Screenshot Placeholder: Damage Fees Step — Listed Fees with Amounts]**

---

### 9.5 Step 4 — Review & Digital Signature

A complete summary of the rental agreement is displayed, including:
- Customer name and contact details.
- Board details and rental period.
- Total rental cost, tax, and security deposit.
- Damage fee schedule summary.
- Agreement clauses (from the configured agreement template).

**To collect the customer's signature:**
1. Show the screen to the customer.
2. The customer draws their signature in the **Signature Pad** using their finger.
3. Tap **Clear** if a re-do is needed.

Tap **Generate Agreement** to finalize.

> **[Screenshot Placeholder: Review Step with Signature Pad Canvas]**

---

### 9.6 Generating & Sharing the Agreement

After tapping **Generate Agreement**:
1. The app compiles a full PDF rental contract including all terms and the customer's digital signature.
2. The PDF is uploaded to secure cloud storage.
3. A **Share** button appears — tap it to:
   - **Print** wirelessly via AirPrint / Cloud Print.
   - **Share via WhatsApp, Email, or AirDrop.**
4. If **EmailJS** is configured in shop settings, the agreement is automatically emailed to the customer.

> The rental status is now set to **Active**, and the surfboard status changes to **Rented**.

---

## 10. Active Rentals & Rental Management

### 10.1 Rentals List View

**Path:** Dashboard → **Rentals** (Admin) or Dashboard → **Rentals** (Staff)

The rentals screen shows a paginated list of rentals. You can filter by status:
- Active
- Overdue
- Completed
- Cancelled

> **[Screenshot Placeholder: Rentals List with Status Filter Chips]**

---

### 10.2 Rental Detail Screen

Tapping on any rental card opens the **Rental Detail** screen, which shows:
- Full rental information (customer, board, dates, duration, rate).
- Current status badge.
- Payment summary (amount expected, amount paid, balance due).
- Security deposit status.
- Quick action buttons (navigate to Inspection/Return, Payments, Damage Reports).

> **[Screenshot Placeholder: Rental Detail Screen — Full Information Card]**

---

### 10.3 Rental Status Reference

| Status | Meaning |
| :--- | :--- |
| 🟢 **Active** | Rental is ongoing and within the due time |
| 🔴 **Overdue** | Rental has passed the expected return time (minus grace period) |
| ✅ **Item Returned** | Board returned successfully — pending admin sign-off |
| ✅ **Completed** | Rental fully settled and closed |
| 🟡 **Mark as Damaged** | Board returned but with a damage incident logged |
| ❌ **Cancelled** | Rental was cancelled before board dispatch |

---

## 11. Board Inspection & Return Processing

### 11.1 Accessing the Inspection Screen

From an **Active Rental**:
1. Open the rental from the Rentals list.
2. Tap **Inspection & Return** button.

Alternatively, from the **Active Rentals** list, swipe or tap the return action.

> **[Screenshot Placeholder: Board Inspection Screen — Timer Card and Details]**

---

### 11.2 Reading the Countdown Timer

The inspection screen shows a live countdown timer at the top:

| Timer Color | Meaning |
| :--- | :--- |
| 🟢 **Green** | Board is within the expected return window |
| 🟠 **Orange** | Return is approaching (within grace period margin) |
| 🔴 **Red** | Board is overdue — late fees may apply |

The timer shows the label **"Time Remaining"** or **"Overdue By"** dynamically.

---

### 11.3 Reviewing Rental & Payment Summary

The inspection screen also shows:
- **Rental Details:** Customer name (tappable to open profile), board name (tappable to open item details), start time, expected return, and hourly/daily rate.
- **Payment Info:** Security deposit amount, and current balance due.

Tap the **Payment Info** section header to navigate directly to the full Payment Ledger for that rental.

---

### 11.4 Confirm Return — No Damage

If the board is returned in satisfactory condition:

1. Physically inspect the board — check fins, leash, deck, rails, and tail.
2. Tap **Confirm Return** (primary blue button).
3. A confirmation dialog will appear — review the final balance due.
4. Tap **Confirm**.
5. The rental status updates to **Item Returned**.
6. The surfboard status reverts to **Available**.

> **Next Step:** Process the **Security Deposit Refund** from the Payments screen if applicable.

---

### 11.5 Report Damage — Board Damaged

If the board is returned with visible damage:

1. Tap **Report Damage** (orange secondary button).
2. The **Damage Report** screen opens.
3. Select the **Damage Type**:
   - Fin Damaged
   - Board Cracked
   - Leash Broken
   - Lost
4. Tap **Add Photos** and capture or select clear photographs of the damage.
5. Add an optional **Note** describing the damage in detail.
6. The system auto-applies the matching damage fee from the pre-agreed fee schedule.
7. Review the **Estimated Cost** and adjust to a **Final Cost** if needed.
8. Tap **Submit Damage Report**.

The rental status is updated to **Mark as Damaged**, and the board status moves to **Damaged** (then **Repair** when maintenance begins).

> **[Screenshot Placeholder: Damage Report Screen with Photo Capture and Damage Type Selector]**

---

## 12. Damage Reports & Incident Management

### 12.1 Viewing Pending Damages

**Path:** Dashboard → **Damages Pending** (from Quick Stats card)

This screen lists all damage incidents that have been reported but not yet fully resolved.

> **[Screenshot Placeholder: Damages Pending List Screen]**

---

### 12.2 Damage Type Reference

| Damage Type | Description |
| :--- | :--- |
| **Fin Damaged** | Fin is broken, cracked, detached, or missing screws |
| **Board Cracked** | Structural crack on the deck, rails, or tail — may allow water ingress |
| **Leash Broken** | Leash cord is snapped, frayed, or the velcro cuff has failed |
| **Lost** | The surfboard has been lost at sea or cannot be recovered |

---

### 12.3 Damage Status Workflow

```
[Reported] → [Approved] → [Charged] → [Resolved]
   Staff       Manager      Payment     Closed
  Reports      Reviews      Created     & Archived
```

| Status | Description |
| :--- | :--- |
| **Reported** | Damage logged by staff — awaiting admin review |
| **Approved** | Admin has reviewed and confirmed the damage assessment |
| **Charged** | A damage fee payment has been created and sent to the customer |
| **Resolved** | Payment collected, board repaired — incident fully closed |

---

### 12.4 Resolving a Damage Report

> **Required Role:** Admin.

1. Open the **Damages Pending** list.
2. Tap on the damage incident.
3. Review the damage details, photos, and estimated/final cost.
4. Tap **Approve** to confirm the damage assessment.
5. Create a **Damage Fee** payment from the rental's Payment screen.
6. Once payment is settled, return and mark the incident as **Resolved**.
7. Update the board status to **Repair** while it is being fixed, then back to **Available** once complete.

---

## 13. Payments & Financial Ledger

### 13.1 Opening the Payment Screen

**From a Rental:**
- Open the **Rental Detail** screen → Tap **Payments**.
- From the **Board Inspection** screen → Tap the **Payment Info** card.

---

### 13.2 Recording a Payment

1. On the **Payments** screen, tap **+ Add Payment**.
2. Fill in the payment details:

| Field | Description |
| :--- | :--- |
| **Amount** | The exact amount received or refunded |
| **Category** | Select from: Rental, Deposit, Late Fee, Damage Fee, Partial Payment, Refund |
| **Payment Method** | Cash, Card, or Online Transfer |
| **Note** | Optional reference note (e.g., "cash collected at counter") |

3. Tap **Save Payment**.
4. The ledger updates immediately, recalculating the total amount paid and balance due.

> **[Screenshot Placeholder: Add Payment Form with Category Dropdown]**

---

### 13.3 Security Deposit Tracking

The Payment screen shows a dedicated **Security Deposit** summary card:

| Column | Description |
| :--- | :--- |
| **Required** | Deposit amount agreed at check-out |
| **Paid** | Amount actually collected as deposit |
| **Refunded** | Amount returned to the customer at check-out |
| **Balance** | Remaining deposit balance (required minus refunded) |

---

### 13.4 Payment Categories Reference

| Category | Direction | Description |
| :--- | :---: | :--- |
| **Rental** | Debit | Customer owes for the rental period |
| **Security Deposit** | Debit | Refundable collateral collected at check-out |
| **Late Fee** | Debit | Additional charge for overdue return |
| **Damage Fee** | Debit | Repair cost for reported board damage |
| **Partial Payment** | Credit | Advance or instalment payment received |
| **Refund** | Credit | Money returned to the customer (e.g., deposit refund) |

---

### 13.5 Payment Methods

| Method | Description |
| :--- | :--- |
| **Cash** | Physical currency collected at the counter |
| **Card** | Credit or debit card payment via POS terminal |
| **Online** | Bank transfer, mobile payment, or online gateway |

---

## 14. QR Scanner

### 14.1 Scanning a Surfboard QR Code

**Access:** Tap the **Barcode / Scan icon** on the Dashboard top bar, or from the **New Rental → Items Section → Scan icon**.

1. The camera opens with a live scanning view.
2. Point the camera at the **QR label** on the surfboard.
3. The app decodes the board ID and:
   - If scanning during **New Rental:** Adds the board to the rental items list.
   - If scanning from the **Dashboard:** Opens the board's Item Details page directly.

> **[Screenshot Placeholder: QR Scanner Camera View with Scan Frame]**

---

### 14.2 Scanning a Customer Badge

During **New Rental → Customer Selection**, tap the **QR scan icon** next to the customer field:

1. Scan the customer's QR card or badge.
2. The system matches the encoded customer ID.
3. The customer profile is automatically selected.

> **Tip:** Print customer QR cards when registering frequent renters to speed up future check-outs.

---

## 15. Alerts & Notifications

### 15.1 Alerts Tab Overview

The **Alerts Tab** (accessible from the bottom navigation bar) provides a real-time log of important events:

- **Overdue Rentals:** Boards that have passed their expected return time.
- **Damage Incidents:** New damage reports submitted by staff.
- **System Alerts:** App updates, maintenance notices, and configuration warnings.

Tapping any alert card navigates directly to the relevant rental or screen.

---

### 15.2 Scheduled Notifications

**Path:** Settings → **Notifications**

Admins and staff (with alerts permission) can configure **scheduled reminders** that trigger at specific times:

| Notification Type | Example Use Case |
| :--- | :--- |
| **Rental Due Reminder** | Notify staff 30 minutes before a rental is due back |
| **Daily Summary** | End-of-day rental count summary |
| **Custom Reminder** | Any user-configured reminder |

1. Go to **Settings → Notifications**.
2. Tap **+ Add Notification**.
3. Set the notification title, message, and trigger time.
4. Tap **Save**.

> **[Screenshot Placeholder: Scheduled Notifications Screen with Existing Reminders]**

---

## 16. Reports & Data Export

### 16.1 Accessing Reports

**Path:** Admin Dashboard → **Reports**  
*(Staff require `reports` permission to access this screen.)*

---

### 16.2 Report Types

| Report Type | Data Included |
| :--- | :--- |
| **Rentals Report** | All rentals with status, amounts, staff member, dates |
| **Customers Report** | Full customer list with rental count, rating, last rental |
| **Inventory Report** | All boards with status, rates, condition, and board type |
| **Damages Report** | All damage incidents with type, cost, and resolution status |

---

### 16.3 Filtering & Date Range

For each report, you can apply:
- **Report Type** — Select from the dropdown.
- **Date Range** — Set a Start Date and End Date filter.
- **Status Filter** — Filter by a specific status (e.g., only "Active" rentals, only "Available" boards).

1. Select your report type from the dropdown.
2. Tap **Start Date** and **End Date** to set the date range.
3. Select the desired **Status** filter.
4. Tap **Generate Report**.

> **[Screenshot Placeholder: Reports Filter Panel with Type Selector and Date Pickers]**

---

### 16.4 Exporting to PDF

Once a report is generated:
1. A **Download icon** appears in the app bar.
2. Tap the **Download icon** to render the results as a PDF.
3. The PDF opens in the print preview.
4. Tap **Print** to send to a wireless printer, or **Share** to save/send via other apps.

---

## 17. Analytics Dashboard

**Path:** Admin Dashboard → **Chart icon (📊)** in the top-right

> **[Screenshot Placeholder: Analytics Dashboard — Full Screen with All Charts]**

---

### 17.1 Revenue Trend Chart

A **line chart** showing daily or monthly revenue over the selected period. Use the **date selector** at the top to switch between weekly and monthly views.

---

### 17.2 Board Status Distribution

A **pie chart** showing the current distribution of the fleet by status:
- 🟢 Available
- 🔵 Rented
- 🟡 Repair
- 🔴 Damaged
- ⚫ Retired

---

### 17.3 Board Type Utilization

A **bar chart** showing the breakdown of the fleet by surfboard type:
- Shortboard, Longboard, Fish, Funboard, Hybrid, SUP

---

### 17.4 Popular Boards Leaderboard

A ranked list showing which surfboards have been rented the most frequently during the selected period. This helps identify high-demand inventory and underperforming assets.

---

## 18. Agreement Templates

**Path:** Admin Dashboard → **Agreements**

---

### 18.1 Creating a Template

1. On the Agreement Templates screen, tap **+ New Template**.
2. Enter a **Template Name** (e.g., "Standard Rental Waiver 2026").
3. Optionally add a **Description**.
4. Build the template content by filling in individual **sections** (clauses).
5. Tap **Save**.

> **[Screenshot Placeholder: Agreement Template Editor with Section Fields]**

---

### 18.2 Editing Template Sections

Templates are divided into named **sections** (e.g., "Liability", "Terms of Use", "Damage Policy"). Each section has:
- A **Section Name** (key).
- A **Section Body** (rich text content displayed on the agreement).

---

### 18.3 Setting a Default Template

1. Open the template you want to use as default.
2. Tap the **Set as Default** toggle.
3. Confirm in the dialog that appears.
4. The marked template will be auto-loaded in every new Agreement Wizard.

---

## 19. Settings & Configuration

**Path:** Dashboard → Management Grid → **Settings**

---

### 19.1 Profile Management

Tap your **Profile Card** at the top of the Settings screen.

You can update:
- **Full Name**
- **Phone Number**
- **Email Address** *(requires re-authentication)*

Tap **Save Changes** to apply.

---

### 19.2 Shop Details

> **Required Role:** Admin (or Staff with `settings_view_shop` and `settings_edit_shop` permission)

**Path:** Settings → **Shop Management → Shop Details**

Update your shop's public-facing profile:
- Business Name
- Location Address
- Contact Phone Number
- Shop Email Address

You can also configure **EmailJS** integration here for automatic PDF emailing:
- EmailJS Service ID
- EmailJS Template ID
- EmailJS Public Key

---

### 19.3 Currency Configuration

> **Required Role:** Admin (or Staff with `settings_edit_currency` permission)

**Path:** Settings → **Configurations → Currency**

Available currencies:
- USD — US Dollar
- EUR — Euro
- LKR — Sri Lankan Rupee
- AUD — Australian Dollar
- GBP — British Pound Sterling

Tap the **Currency** row → Select from the list → Tap **Confirm**.

---

### 19.4 Date Format & Timezone

> **Required Role:** Admin (or Staff with `settings_edit_date_format` / `settings_edit_timezone` permission)

**Date Format options:**
| Format | Example |
| :--- | :--- |
| dd/MM/yyyy | 22/09/2026 |
| MM/dd/yyyy | 09/22/2026 |
| yyyy-MM-dd | 2026-09-22 |
| dd MMM yyyy | 22 Sep 2026 |
| MMM dd, yyyy | Sep 22, 2026 |

**Timezone:** Select from a comprehensive list of IANA timezone identifiers (Americas, Europe, Asia, Africa, Oceania). This ensures all timestamps are shown in your local time zone.

---

### 19.5 Rental Pricing Configuration

> **Required Role:** Admin only

**Path:** Settings → **Rental Pricing**

Configure the shop's global pricing rules:

| Setting | Description |
| :--- | :--- |
| **Default Hourly Rate** | Fallback hourly rate when a board has no specific rate |
| **Default Daily Rate** | Fallback daily rate when a board has no specific rate |
| **Tax Enabled** | Toggle to apply VAT / GST to all rentals |
| **Tax Rate (%)** | Tax percentage applied to the rental subtotal |
| **Hourly Grace Period (minutes)** | Tolerance window before hourly late fees trigger |
| **Daily Grace Period (minutes)** | Tolerance window before daily late fees trigger |

A **Price Simulator** at the bottom of this screen lets you test how pricing rules apply to different rental durations before saving.

> **[Screenshot Placeholder: Rental Pricing Config with Simulator Panel]**

---

### 19.6 Inventory Configuration

> **Required Role:** Admin (or Staff with `shop_setup` permission)

**Path:** Settings → **Shop Management → Inventory Configuration**

- **Add Custom Brands:** Add new surfboard manufacturers to the brand dropdown in the Add Inventory form.
- **Manage Board Types:** View and manage available board type classifications.

---

### 19.7 Staff Access Control

> **Required Role:** Admin only

**Path:** Settings → **Staff Access Control**

The Access Control screen displays all configurable staff permissions grouped by category:

| Group | Permissions Managed |
| :--- | :--- |
| **Operations** | New Rental, Active Rentals, History, Alerts, QR Scanner |
| **Inventory** | View, View Damage Fees, Add, Edit, Delete |
| **Customers** | View, Add, Edit, Contact |
| **Financials** | Payments, Damage Fees, Reports |
| **User Management** | Manage Staff Accounts |
| **Settings** | View Shop, Edit Shop, Currency, Date Format, Timezone, Access Control |

Toggle each permission **On** or **Off**. Changes apply immediately to all staff members.

> **[Screenshot Placeholder: Staff Access Control Screen with Permission Toggle Switches]**

---

### 19.8 Language Settings

**Path:** Settings → **App Settings → Language**

Switch the application language between:
- **English**
- **සිංහල (Sinhala)**

Tap the **Language** row → Select your preferred language → The app reloads in the selected language.

---

### 19.9 Dark Mode

**Path:** Settings → **App Settings → Dark Mode**

Tap the **Dark Mode toggle** to switch between Light Mode and Dark Mode. The change applies instantly throughout the app.

---

### 19.10 Notifications Settings

**Path:** Settings → **App Settings → Notifications**

Opens the **Scheduled Notifications** screen (see [Section 15.2](#152-scheduled-notifications)).

---

### 19.11 Billing & Usage Monitor

> **Required Role:** Admin only (or Staff with `shop_setup` permission)

**Path:** Settings → **Shop Management → Billing & Usage**

Tracks your application's real-time **Google Cloud Firestore usage**:

| Metric | Description |
| :--- | :--- |
| **Document Reads** | Total Firestore document reads in the current billing period |
| **Document Writes** | Total Firestore document writes |
| **Document Deletes** | Total Firestore document deletes |
| **Estimated Cost** | Approximate billing cost based on Google Firestore pricing |

A **daily usage history chart** shows trends over the past 30 days to help identify usage spikes.

> **[Screenshot Placeholder: Billing & Usage Screen with Bar Chart and Summary Card]**

---

## 20. Staff User Management

> **Required Role:** Admin only

**Path:** Admin Dashboard → **Manage Users**

---

### 20.1 Viewing All Users

The Manage Users screen shows all staff accounts linked to your shop. Each user card shows:
- Name and email.
- Role (Admin / Staff).
- Account status (Active / Inactive).
- Registration date.

---

### 20.2 Creating a Staff Account

1. Tap **+ Add User** (or the add icon in the app bar).
2. Fill in the staff member's details:
   - Full Name
   - Email Address
   - Temporary Password *(the staff member will be prompted to change it on first login)*
   - Role (Staff)
3. Tap **Create Account**.
4. The staff member can now sign in using the provided email and password.

> **[Screenshot Placeholder: Create Staff Account Form]**

---

### 20.3 Activating / Deactivating Staff

1. Open the **Manage Users** screen.
2. Tap on a staff member's card.
3. Toggle the **Active** switch to enable or disable their access.
4. A deactivated staff member cannot sign in until the account is re-activated.

---

## 21. Rental History

**Path:** Dashboard → **Rentals** (or Admin Dashboard → Management Grid → **Rentals**)

The Rental History screen provides a full archive of all past, present, and future rentals.

**Filtering Options:**
- **Status Filter:** All, Active, Completed, Overdue, Cancelled, Mark as Damaged, Item Returned.
- **Date Range Filter:** Filter rentals within a specified date range.

Tapping any rental card opens the full **Rental Detail** screen with all associated payments and documents.

---

## 22. Maintenance Mode

If the system is taken offline for maintenance or system updates, users will see a **Maintenance Screen** upon launching the app. No data can be modified during this period.

- **Maintenance Status:** Controlled by the backend configuration.
- **Typical Duration:** Minor updates: 5–15 minutes. Major updates: up to 1 hour.
- Contact your system administrator for the estimated downtime schedule.

---

## 23. Frequently Asked Questions (FAQ)

**Q: Can I have multiple shops under one account?**  
A: Each Admin account is linked to a single shop identified by its unique `shopCode`. Multi-shop support would require separate accounts per shop at this time.

---

**Q: Is customer data safe?**  
A: Yes. Sensitive identity fields like NIC/Passport numbers are encrypted using AES encryption on the device before being stored in the cloud database. They are never stored or transmitted as plain text.

---

**Q: What happens if the internet connection drops during a rental?**  
A: The app requires an active internet connection for real-time data operations (creating rentals, processing payments, etc.). It will display a **"No Internet Connection"** notice and prevent operations until connectivity is restored.

---

**Q: Can a staff member create a new surfboard?**  
A: Only if the Admin has explicitly enabled the `inventory_add` permission for that staff member via **Settings → Staff Access Control**. By default, this is disabled for staff.

---

**Q: What is the difference between "Item Returned" and "Completed"?**  
A: **Item Returned** means the board has been physically handed back, but the rental may still have an outstanding balance. **Completed** means all financial obligations are settled and the rental is fully closed.

---

**Q: How do I refund a security deposit?**  
A: After confirming a board return with no damage, go to the rental's **Payments** screen → Tap **+ Add Payment** → Select Category: **Refund** → Enter the deposit amount → Save.

---

**Q: Can I edit a rental after it has been created?**  
A: Some fields (like payment records and damage notes) can be updated after creation. However, core rental terms (dates, board, rate) are locked once the agreement is generated and signed to maintain the integrity of the legal contract.

---

**Q: How many boards can I add to a single rental?**  
A: Multiple boards can be added to a single rental (e.g., a group booking where multiple boards are checked out to one customer simultaneously).

---

**Q: What is the grace period?**  
A: The grace period is a configurable buffer window (in minutes) during which a rental is not marked as overdue even if the due time has passed. For example, with a 15-minute hourly grace period, a board due back at 3:00 PM is only flagged overdue at 3:15 PM.

---

**Q: Can I send the rental agreement to the customer by email automatically?**  
A: Yes. Configure **EmailJS** credentials in **Settings → Shop Details** (Service ID, Template ID, Public Key). Once configured, agreement PDFs are automatically emailed to the customer's registered email address upon generation.

---

**Q: How do I switch between Sinhala and English?**  
A: Go to **Settings → App Settings → Language** → Select **English** or **සිංහල**.

---

## 24. Troubleshooting Guide

### Problem: App shows "No Internet Connection" permanently

**Solution:**
1. Check your device's Wi-Fi or mobile data connection.
2. Turn Airplane Mode on and off.
3. Restart the router if on Wi-Fi.
4. Re-launch the app.

---

### Problem: Agreement PDF is not being emailed to the customer

**Solution:**
1. Go to **Settings → Shop Details**.
2. Verify that **EmailJS Service ID**, **Template ID**, and **Public Key** are correctly entered.
3. Check the customer's **email address** in their profile — it must be a valid address.
4. Check the **EmailJS dashboard** at emailjs.com to see if the email was rejected or bounced.

---

### Problem: QR Code is not scanning

**Solution:**
1. Ensure the camera has sufficient **focus** and the QR label is flat and clean.
2. Improve **lighting** — avoid direct glare or dark shadows on the label.
3. If the label is worn or damaged, generate and re-print a fresh QR code from **Item Details**.
4. Grant the app **Camera Permission** if it was previously denied (Device Settings → Apps → Surfboard Rental → Permissions → Camera).

---

### Problem: A staff member cannot log in

**Solution:**
1. Verify the **email address** is spelled correctly.
2. Check the staff account is **Active** in **Manage Users**.
3. Confirm the email address has been **verified** (a verification email was sent upon account creation).
4. Use **Forgot Password** to reset the staff member's credentials if needed.

---

### Problem: A board is still showing as "Rented" after return

**Solution:**
1. Open the specific rental in the **Rentals** list.
2. Navigate to **Inspection & Return**.
3. Tap **Confirm Return** (or **Report Damage** if applicable) to complete the return flow.
4. The board status will revert to **Available** (or **Damaged**) automatically.

---

### Problem: Overdue timer is not correct

**Solution:**
1. Check the **Timezone** setting in **Settings → Configurations → Timezone**.
2. Ensure the timezone matches your physical location.
3. The rental start and due times are recorded in the configured timezone — mismatched timezone settings will cause clock drift on the timer.

---

### Problem: Damage fee is not shown in the Agreement Wizard

**Solution:**
1. Open **Inventory → Item Details** for the specific board.
2. Ensure at least one **Damage Fee Rule** is configured and its **Active Status** is toggled ON.
3. Verify the rule is associated with the correct board or is set to apply to all boards (`itemId = ALL`).

---

## 25. Glossary of Terms

| Term | Definition |
| :--- | :--- |
| **Active Rental** | A rental that has been started and the board is currently with the customer |
| **Agreement Wizard** | The 4-step checkout flow for generating and signing a rental contract |
| **AES Encryption** | A standard cryptographic algorithm used to protect sensitive customer data |
| **Daily Rate** | The price charged per full calendar day of rental |
| **Damage Fee** | A pre-agreed charge for a specific type of physical damage to a surfboard |
| **Grace Period** | A buffer window after the due time before late fees are applied |
| **Hourly Rate** | The price charged per hour of rental |
| **IANA Timezone** | Standardized timezone identifiers (e.g., "Asia/Colombo") used by the app |
| **Inventory Status** | The current operational state of a surfboard (Available, Rented, Repair, etc.) |
| **Late Fee** | An additional charge applied when a board is returned after the grace period |
| **Ledger** | A financial record of all charges and payments associated with a rental |
| **NIC** | National Identity Card — used as a form of customer identification |
| **PDF Waiver** | A generated document combining the rental terms, damage fees, and customer signature |
| **QR Code** | A scannable 2D barcode identifying a specific surfboard or customer |
| **Rental Status** | The current state of a rental transaction (Active, Overdue, Completed, etc.) |
| **Security Deposit** | A refundable amount held as collateral against possible damage or loss |
| **shopCode** | A unique identifier that isolates one shop's data from others in the system |
| **SUP** | Stand-Up Paddleboard — a type of surfboard in the inventory |
| **Tenant** | A single business entity (shop) operating within the multi-tenant system |
| **UserRole** | The assigned permission tier of a system user — either `admin` or `staff` |

---

## Document Information

| Field | Value |
| :--- | :--- |
| **Application Name** | Surfboard Rental Management System |
| **Package Name** | `surfboard_rental_app` |
| **Version** | 1.0.0+1 |
| **Platform** | Android (min SDK 21) · iOS |
| **Framework** | Flutter / Dart |
| **Cloud Services** | Firebase (Auth, Firestore) · Supabase Storage |
| **Document Version** | 1.0 |
| **Prepared By** | Development Team |
| **Last Reviewed** | September 2026 |

---

*For technical support, feature requests, or bug reports, contact your system administrator or the development team.*
