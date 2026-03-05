# Insurance Claim Management System (Oracle PL/SQL)

## Project Overview

This project implements a **database-driven Insurance Claim Management System** using **Oracle SQL and PL/SQL**.
The solution focuses on enforcing **business rules, data integrity, and transaction safety directly at the database layer**.

The system manages the complete lifecycle of insurance claims, including:

* Policy creation and management
* Claim submission with detailed claim items
* Claim validation and coverage verification
* Claim approval or rejection workflow
* Policy coverage utilization tracking
* Audit logging for claim processing actions

The design follows **production-grade database development practices**, ensuring the solution is scalable and suitable for integration with enterprise applications such as web portals or microservices.

---

## System Architecture

The system follows a **three-layer logical architecture inside the database**:

### 1. Data Layer

Tables store normalized insurance data with strict constraints to enforce integrity.

Core entities include:

* **POLICY** – Stores insurance policy details
* **CLAIM** – Stores claim submissions for policies
* **CLAIM_ITEMS** – Stores individual expense items for a claim
* **CLAIM_AUDIT** – Tracks status changes and processing actions

---

### 2. Business Logic Layer

All core business logic is implemented using a centralized PL/SQL package:

`PKG_CLAIM_MANAGEMENT`

The package provides reusable APIs for:

* Claim submission
* Claim validation
* Claim processing (approve/reject)
* Policy utilization calculation

This ensures that **business rules are enforced consistently regardless of the calling application**.

---

### 3. Transaction Control Layer

Transaction integrity is maintained using:

* **SAVEPOINT**
* **COMMIT / ROLLBACK**
* **Custom error handling with RAISE_APPLICATION_ERROR**

This ensures safe recovery from partial failures during claim processing.

---

## Database Schema

### POLICY

Stores policy information.

Key attributes include:

* policy_number
* policy_holder_name
* policy_type
* coverage_amount
* premium_amount
* start_date / end_date
* status

Supported policy types:

* AUTO
* HEALTH
* PROPERTY
* LIFE

Policy status values:

* ACTIVE
* EXPIRED
* CANCELLED

---

### CLAIM

Represents a claim submitted against a policy.

Key attributes include:

* claim_number
* policy_id
* incident_date
* claim_amount
* claim_status
* submitted_by
* approved_by
* rejection_reason

Claim lifecycle status:

```
SUBMITTED → UNDER_REVIEW → APPROVED / REJECTED → PAID
```

---

### CLAIM_ITEMS

Stores individual expense items for a claim.

Examples include:

* medical expenses
* vehicle repairs
* property damage
* supporting documentation references

Each claim may contain **multiple items**.

---

### CLAIM_AUDIT

Maintains an audit trail for claim processing.

Tracks:

* status transitions
* user performing the action
* timestamp
* remarks

This ensures **traceability for regulatory and operational auditing**.

---

## Business Rules Implemented

### Policy Validation

A claim can only be submitted if:

* The policy exists
* The policy status is **ACTIVE**
* The incident date falls within the policy coverage period

---

### 30-Day Filing Rule

Claims must be submitted **within 30 days of the incident date**.

```
SYSDATE - INCIDENT_DATE ≤ 30
```

---

### Duplicate Claim Prevention

The system prevents duplicate claims for the same policy and incident date.

---

### Coverage Limit Enforcement

Total approved claims must not exceed policy coverage.

```
SUM(APPROVED + PAID CLAIMS) + NEW CLAIM ≤ COVERAGE_AMOUNT
```

---

### Claim Item Validation

Each claim item must contain:

* Valid amount
* Positive quantity
* Positive unit price

---

### Approval / Rejection Rules

A claim may only be processed if its status is:

```
SUBMITTED or UNDER_REVIEW
```

If rejected, a **rejection reason is mandatory**.

---

## PL/SQL Package

### Package Name

```
PKG_CLAIM_MANAGEMENT
```

### Components

#### Procedure: PRC_SUBMIT_CLAIM

Creates a new claim and inserts claim items.

Responsibilities:

* Validate policy
* Check incident date validity
* Prevent duplicate claims
* Enforce filing window
* Insert claim and claim items

---

#### Procedure: PRC_PROCESS_CLAIM

Processes a claim for approval or rejection.

Responsibilities:

* Validate claim eligibility
* Enforce status transition rules
* Record approval or rejection details
* Write audit log

---

#### Function: FN_VALIDATE_CLAIM

Performs comprehensive validation checks before processing.

Returns:

```
VALID
```

or a detailed error message.

---

#### Function: FN_GET_POLICY_UTILIZATION

Calculates policy coverage utilization percentage.

Formula:

```
(Total Approved + Paid Claims) / Coverage Amount × 100
```

---

## Index Strategy

Indexes are created to optimize query performance:

* `IDX_CLAIM_POLICY`
* `IDX_CLAIM_STATUS`
* `IDX_CLAIM_DATE`
* `IDX_ITEM_CLAIM`

These indexes support frequent queries such as:

* claim lookup by policy
* claim status filtering
* claim processing operations

---

## Execution Order

Run the SQL scripts in the following sequence:

```
1. 01_create_tables.sql
2. 02_create_sequences.sql
3. 03_pkg_claim_management_spec.sql
4. 04_pkg_claim_management_body.sql
5. 05_test_data.sql
6. 06_test_execution.sql
```

---

## Test Coverage

The test scripts demonstrate multiple scenarios:

Valid cases:

* successful claim submission
* claim approval
* policy utilization calculation

Failure cases:

* duplicate claim submission
* claim filed after 30 days
* rejection without reason
* claim exceeding coverage limit

---

## Error Handling Strategy

Custom error codes are used for controlled failure handling.

Example error categories include:

* Invalid policy
* Duplicate claim
* Invalid filing window
* Coverage limit exceeded
* Invalid status transition
* Missing rejection reason

This allows applications calling the package to handle errors reliably.

---

## Design Considerations

Key design principles followed:

* Normalized relational schema
* Database-level validation
* Centralized business logic
* Transaction safety
* Performance optimization through indexing
* Clear separation between data and logic

---

## Future Enhancements

Possible extensions include:

* Fraud detection algorithms
* Automated claim settlement workflows
* Policy renewal management
* Reporting and analytics functions
* REST API integration using Oracle REST Data Services
* Integration with external document storage systems

---

## Author

**Linganathan G**

This project was developed as part of an advanced database development exercise focusing on enterprise-grade Oracle PL/SQL design and implementation.
