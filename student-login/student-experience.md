# Student experience

The **Student Login** process in **Survey Center** is designed to offer a fast and simple way for students to access the surveys assigned to their department. This process ensures that only registered students — whose data has been pre-added by the admin — can log in and participate in surveys.\


**1- Enter Student ID**\
The student begins by entering their **Student ID** on the login screen.

* This **Student ID** is previously added and registered by the administrator in the system.
* Each Student ID is associated with their department and used to verify eligibility to access surveys.
* **ID Validation (Database Check)**\
  Once the student submits their ID:
  * The app queries the **Firestore database** to check if the entered ID exists in the list of registered students.
  * If the ID is **found** in the database, the student is successfully authenticated.
  * If the ID is **not found**, an error message is displayed informing the student that the ID is invalid or not registered.\


#### **--Security Measures**

* Only students registered by an administrator can log in — unauthorized access is blocked.
* The ID check happens securely using **Firestore queries**.
* No personal or sensitive information is stored locally, protecting student data.
