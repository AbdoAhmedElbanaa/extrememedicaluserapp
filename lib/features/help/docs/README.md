# Help & Support Feature

## Description
This feature provides users with access to help topics, FAQs, contact information, and user guides. It serves as a central hub for support-related resources.

## Usage
The feature is accessed via the `/help` route. It uses GetX for state management and follows a clean architecture pattern.

## API Integration
- `HelpService`: Currently simulates data fetching with a delay. In the future, this will connect to a backend API or Firestore to fetch dynamic help topics.

## Dependencies
- `get`: For state management and routing.
- `flutter`: For UI components.

## Edge Cases
- **Loading State**: Handled with a `CircularProgressIndicator`.
- **Error State**: Handled with a retry button and error message if the service fails.
- **Empty State**: Currently displays the list, but should handle empty responses from the service.

## Responsive Design
- **Mobile**: Single column list.
- **Tablet**: Centered constrained width list.
- **Desktop**: Two-pane layout with header on the left and topics on the right.
