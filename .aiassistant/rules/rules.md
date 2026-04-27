---
apply: always
---

# 📜 Global Project Rules (RULES.md)

## ⚠️ Authority

This file is the **highest priority rule set**.
If any conflict occurs between files → THIS FILE WINS.

---

## 1. Absolute Completion Rule

* No task is considered complete unless:

    * Fully implemented
    * Fully functional
    * Fully tested
* Partial delivery is strictly forbidden.

---

## 2. Architecture Enforcement

All code MUST follow structured architecture:

* Presentation Layer (UI)
* Business Logic Layer
* Data Layer

Violation of architecture = invalid implementation.

---

## 3. Feature Isolation Rule

* Each feature must be self-contained.
* No cross-feature dependency unless explicitly required.
* No random file placement.

---

## 4. Naming Convention

* Consistent naming across entire project.
* Clear, descriptive names only.
* No abbreviations unless standard.

---

## 5. Design System Rule

* All UI must strictly follow:

    * Colors
    * Typography
    * Spacing
    * Radius

❌ Forbidden:

* Hardcoded values

---

## 6. Responsiveness Rule

Every UI must:

* Adapt to all screen sizes
* Support:

    * Mobile
    * Tablet
    * Desktop/Web

Non-responsive UI = rejected.

---

## 7. Error Handling Rule

Every system must:

* Handle failures safely
* Provide meaningful error messages
* Avoid crashes

---

## 8. Validation Rule

Before finalizing ANY task:

* Check:

    * Syntax
    * Logic
    * Imports
    * Dependencies

If ANY issue exists → FIX IT FIRST.

---

## 9. Retry & Recovery Rule

If failure occurs:

1. Retry automatically
2. Try alternative approach
3. Provide fallback solution

---

## 10. No Silent Failure Rule

Forbidden:

* Stopping without explanation
* Ignoring errors

Required:

* Explain issue
* Provide fix
* Provide workaround

---

## 11. Code Quality Rule

Code MUST be:

* Clean
* Readable
* Modular
* Maintainable

Must follow:

* DRY (Don't Repeat Yourself)
* Separation of Concerns

---

## 12. Performance Rule

* Optimize rendering
* Minimize unnecessary rebuilds
* Efficient API usage

---

## 13. Testing Rule

Each feature must be:

* Tested logically
* Tested for edge cases
* Stable under normal usage

---

## 14. Documentation Rule

Each feature must include:

* Description
* Usage
* Dependencies
* API details
* Edge cases

---

## 15. Security Rule

* Validate inputs
* Protect sensitive data
* Avoid exposing secrets

---

## 16. Consistency Rule

* Follow existing project patterns
* Do NOT introduce new patterns without reason

---

## 17. Maintainability Rule

* Code must be easy to update
* Avoid tight coupling
* Prefer reusable components

---

## 18. Final Validation Gate 🚨

Before ANY output is delivered:

✔ No errors
✔ Fully working
✔ Responsive
✔ Structured correctly
✔ Follows ALL rules

If ANY condition fails → output is INVALID.

---

## 🔥 Final Statement

Breaking ANY of these rules results in:
→ Rejection of the implementation
→ Mandatory rework until compliance
