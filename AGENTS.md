Always verify widget parameters against actual framework API before writing code.

## 1. General Behavior

* Always complete tasks fully; never leave partial implementations.
* Do not stop unless the feature is fully working or a clear blocker is explained.
* Never produce placeholder code.

---

## 2. Feature Implementation (Mandatory)

Each feature must include:

* UI (Views + Widgets)
* Logic (Controllers / ViewModels)
* Data Layer (Models + Services)
* State Management integration

---

## 3. Feature Folder Structure

Every new feature must follow:

feature_name/
├── views/
├── widgets/
├── controllers/
├── models/
├── data/
├── services/
├── docs/

* No code outside its proper layer.
* Follow consistent naming conventions.

---

## 4. Design System Enforcement

* Use ONLY global theme, colors, typography, spacing.
* No hardcoded values allowed.

❌ مثال غلط:
Color(0xFF123456)

✅ الصح:
AppColors.primary

---

## 5. Responsiveness (Required)

All UI must support:

* Mobile
* Tablet (iPad)
* Web/Desktop

Use:

* MediaQuery
* LayoutBuilder
* Responsive patterns

Avoid fixed sizes.

---

## 6. Documentation

Each feature must include:

* Description
* Usage
* API integration
* Dependencies
* Edge cases

---

## 7. Error Handling

Every feature must:

* Use try/catch
* Show user-friendly messages
* Log errors properly

---

## 8. Self-Verification Rule (Critical)

Before finishing ANY task:

* Ensure no errors or warnings
* Ensure all imports are correct
* Ensure feature works logically

If failure:

* Retry automatically
* OR provide a working fix

---

## 9. No Silent Failure

* Never stop without explanation
* Always provide:

  * reason
  * fix
  * or workaround

---

## 10. Code Quality

* Clean, readable, modular code
* DRY principle
* Reusable components
* Separation of concerns

---

## 11. Performance

* Optimize rendering
* Avoid unnecessary rebuilds
* Efficient API usage

---

## 12. Completion Criteria

A task is NOT complete unless:

* Feature works end-to-end
* UI is responsive
* No errors exist
* Documentation is written
* Code follows all rules above
