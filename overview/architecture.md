# Architecture

### System Architecture <a href="#system-architecture" id="system-architecture"></a>

The application follows a client-server architecture using Flutter for the frontend and Firebase services for the backend.

<figure><img src="../.gitbook/assets/image (1).png" alt=""><figcaption></figcaption></figure>

### User Roles and Permissions <a href="#user-roles-and-permissions" id="user-roles-and-permissions"></a>

The system implements three distinct user roles, each with specific permissions and access levels.

<figure><img src="../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

### Data Model <a href="#data-model" id="data-model"></a>

The system organizes data into several collections stored in Firestore, representing surveys, students, admins, and their interactions.

<figure><img src="../.gitbook/assets/image (3).png" alt=""><figcaption></figcaption></figure>

### Navigation and Routing <a href="#navigation-and-routing" id="navigation-and-routing"></a>

The app uses Flutter's built-in navigation system with a centralized route definition in `AppRoutes`. This allows for consistent navigation between screens and supports passing parameters when needed.

<figure><img src="../.gitbook/assets/image (4).png" alt=""><figcaption></figcaption></figure>

### Authentication System <a href="#id-2-authentication-system" id="id-2-authentication-system"></a>

The application uses a combined authentication system that handles both student and admin authentication from a single entry point.

<figure><img src="../.gitbook/assets/image (6).png" alt=""><figcaption></figcaption></figure>

### Bottom Navigation <a href="#bottom-navigation" id="bottom-navigation"></a>

The bottom navigation bar is a key UI component that changes based on the user's role, with super admins seeing additional options.\


<figure><img src="../.gitbook/assets/image (5).png" alt=""><figcaption></figcaption></figure>

The navigation bar dynamically adjusts its items and callbacks based on the current screen and user role, providing consistent navigation throughout the app.
