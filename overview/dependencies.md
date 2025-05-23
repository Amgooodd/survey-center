# Dependencies

This page provides a detailed overview of the technologies, frameworks, and libraries used in the Survey Center . It covers the core technologies, external dependencies, and their integration within the application.&#x20;

#### Flutter Framework <a href="#flutter-framework" id="flutter-framework"></a>

The application is developed using Flutter, a cross-platform UI toolkit that allows development for multiple platforms (Android, iOS, web, Windows, macOS) from a single codebase.

* **Dart Version**: SDK ^3.6.1&#x20;
* **Flutter Version**: The application uses Flutter's latest stable channel compatible with Dart 3.6.1

#### Firebase Services <a href="#firebase-services" id="firebase-services"></a>

Firebase provides the backend infrastructure for the application, including authentication and data storage.

* **Firebase Core**: ^3.13.0 - Base Firebase functionality
* **Firebase Auth**: ^5.5.2 - Authentication services
* **Cloud Firestore**: ^5.6.6 - NoSQL database for storing questionnaire data, user information, and responses

### <sup>State Management</sup> <a href="#state-management" id="state-management"></a>

The application uses Provider (^6.1.4) for state management, allowing efficient state sharing across the widget tree.

* **Provider**: Manages application state and provides dependency injection
* **Shared Preferences**: ^2.2.0 - Persistent key-value storage for local data

#### File Processing and Export <a href="#file-processing-and-export" id="file-processing-and-export"></a>

* **CSV**: ^5.1.1 - CSV file handling for data import/export
* **Excel**: ^4.0.6 - Excel file manipulation
* **Syncfusion Flutter XlsIO**: ^24.1.41 - Comprehensive Excel document creation
* **PDF**: ^3.11.3 - PDF document generation
* **Printing**: ^5.10.7 - Printing functionality
* **File Picker**: ^8.0.0 - File selection interface
* **File Saver**: ^0.2.14 - File saving functionality
* **Path Provider**: ^2.1.5 - File system path access
* **Permission Handler**: ^11.4.0 - Managing storage permissions

#### Data Visualization <a href="#data-visualization" id="data-visualization"></a>

* **FL Chart**: ^0.71.0 - Chart/graph visualization for analytics
