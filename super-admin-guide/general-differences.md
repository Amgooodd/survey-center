# General differences

The **Super Admin Interface** in **Survey Center** offers a comprehensive set of controls to manage and maintain the app at a system-wide level. This interface is similar to the admin interface but with additional privileges and options to manage all surveys, students, and even reset the app entirely if necessary. The super admin can perform high-level actions that affect the entire application, ensuring that the system operates smoothly.

#### 1. **Home Page (Super Admin View)**

The **Home Page** for the super admin provides a global overview of the app, and unlike regular admins, the super admin can view **all surveys** created by all admins.

* **Survey Overview**: The super admin can see all surveys that have been created across the entire system, regardless of which admin created them.
* **Survey Sorting and Filtering**: The surveys can be sorted by various criteria (newest first, oldest first, or A-Z) and filtered for easier management.

<figure><img src="../.gitbook/assets/image (32).png" alt="" width="375"><figcaption></figcaption></figure>

#### 2. **Settings Icon in the Head Bar**

In the super admin’s **head bar**, there is a **Settings Icon** that opens a settings menu with additional high-level options.

* **Delete All Surveys**: This option allows the super admin to delete **all surveys** created in the app. This action comes with **three layers of warnings** to prevent accidental deletion.

<figure><img src="../.gitbook/assets/image (34).png" alt="" width="375"><figcaption></figcaption></figure>

* **Delete All Students**: The super admin can delete **all students** from the app. Like the delete surveys action, this comes with **three warning layers**:
* **Reset the App**: This option allows the super admin to reset the app, which **deletes all surveys, students, and responses**, but **keeps the admin accounts intact**. This is useful in situations where the super admin needs to clear all survey data but retain the user structure of the app.
  * **Warning**: This action also comes with a strong warning, ensuring that the super admin understands the consequences of a full reset.

<figure><img src="../.gitbook/assets/image (33).png" alt="" width="375"><figcaption></figcaption></figure>

#### 3. **Recycle Bin Tab**

One of the key features in the super admin’s **Settings Menu** is the **Recycle Bin Tab**:

* **View Deleted Surveys**: The Recycle Bin allows the super admin to view all surveys that have been deleted within a **specific time frame**.
  * **Time Frame**: Admins can specify a window of time (e.g., the past 30 days) during which deleted surveys are stored in the Recycle Bin.
* **Restore Deleted Surveys**: Super admins can restore deleted surveys from the Recycle Bin within the specified time frame.
  * **Restore Option**: Clicking on a deleted survey in the Recycle Bin provides an option to **restore** the survey back to its original state, including all questions and responses, if applicable.

<figure><img src="../.gitbook/assets/image (36).png" alt="" width="375"><figcaption></figcaption></figure>

#### 4. **Add Admin Page (Bottom Bar)**

In the **bottom bar** of the super admin’s home page, there is an **Add Admin** button that opens a page dedicated to adding new admin accounts.

<figure><img src="../.gitbook/assets/image (37).png" alt="" width="375"><figcaption></figcaption></figure>
