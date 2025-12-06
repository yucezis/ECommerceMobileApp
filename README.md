# Books E-Commerce | .NET Web API & MVC Admin & Flutter App

This project is a comprehensive Full Stack E-Commerce solution developed using modern software architectures and principles. The system consists of three main layers: a central Web API for data management, an ASP.NET Core MVC Admin Panel for administrative operations, and a Flutter Mobile Application for the end-user experience.

## Architectural Structure

The project is designed with a modular structure, prioritizing sustainability and scalability.

- **Backend:** .NET Core Web API (Central Data Provider)
- **Frontend (Web):** ASP.NET Core MVC (Admin Interface)
- **Frontend (Mobile):** Flutter (Customer Shopping Interface)
- **Database:** MS SQL Server

<p align="center">
  <img src="https://r.resimlink.com/HXKA9z.png" alt="Resim Açıklaması" width="350">
  <br>
  <small>This diagram illustrates the overall system architecture of the project, including the API, Admin Panel, Mobile App, and Database layers.</small>
</p>

---

## Project Status & Features

The management panel and backend infrastructure are largely complete, while the mobile application development process is actively ongoing.

### Admin Panel & Backend
-  **API Architecture:** RESTful services and database integration with Entity Framework Core.
-  **Category & Product Management:** Full-scope CRUD (Create, Read, Update, Delete) operations.
-  **Customer Support Module:** Real-time messaging interface for Admins to reply to customer inquiries.
-  **Advanced Product Features:** Stock tracking, Active/Passive status control, and Featured products.
-  **Customer Management:** Customer listing with data privacy masking (Hiding Name, Surname, Phone).
-  **Sales History:** Detailed viewing of customer-specific past orders.
-  **Security & Session:** Admin login and secure Session management.
-  **Dashboard:** Summary data and statistical charts.
-  **Review Management:** System to view and moderate user comments, photos, and ratings.

### Mobile App
**Core Features**
-  **Home Page:** Banner areas, Category list, and Featured products showcase.
-  **API Integration:** Fetching product and category data from the live database.
-  **Sorting Algorithm:** Dynamic listing of "Best Sellers" based on sales quantity.
-  **Authentication:** User registration (Register) and login (Login) processes.
-  **E-Invoice Generation:** Automatic creation of digital invoices (PDF) for completed orders.

**Shopping & Checkout**
-  **Cart Operations:** Functions to add, update, and remove products from the cart.
-  **Address Management:** Saving and managing multiple shipping addresses.
-  **Purchasing Process:** Payment screen interface and order creation service.
-  **Order History:** Displaying past orders and their status details.
-  **Shipment Tracking:** Visual interface to track the delivery status (Preparing, Shipped, Delivered).
-  **Conditional Shipping Fee:** Automatically adds a shipping fee for orders below 500 TL.

**User Experience & Interaction**
-  **Email Verification:** Mandatory validation step via email for new registrations and profile updates.
-  **Secure Profile Updates:** Mandatory email verification for updating passwords and personal information.
-  **Account Deletion:** Users can permanently close their accounts, secured via email confirmation.
-  **Live Support:** Direct chat interface for users to communicate with store admins.
-  **AI-Powered Chat:** Integrated **Google Gemini** to provide real-time support and personalized book recommendations.
-  **OTP / SMS Verification Simulation:** Simulating code verification for secure registration.
-  **Wishlist:** Ability to favorite products for quick access.
-  **Advanced Search:** Filtering products by price, author, or publisher.
-  **Profile Page:** Displaying and editing user information via API.
-  **Reviews & Ratings:** Users can rate books (1-5 stars) and write comments, and upload photos.
      
---

## Tech Stack

### Backend (API)
- .NET 9
- Entity Framework Core (Code First)
- LINQ
- Swagger UI

### Admin Panel (Web)
- ASP.NET Core MVC
- Bootstrap 5 (Responsive)
- HttpClient
- HTML5 / CSS3 / JavaScript

### Mobile (Cross-Platform)
- Flutter & Dart
- Http Package
- State Management: Provider 

---

## Screenshots

| Admin Panel - Products | Admin Panel - Customers |
| :---: | :---: |
| <img src="https://r.resimlink.com/8Rxg6.png" width="400"> | <img src="https://r.resimlink.com/IAExP.png" width="400"> |

| Mobile - Home Page | Mobile - Profile Screen | Mobile - AI Screen |
| :---: | :---: | :---: |
| <img src="https://r.resimlink.com/TJE1lIszk.jpg" width="200"> | <img src="https://r.resimlink.com/JUL-oO.jpg" width="200"> | <img src="https://r.resimlink.com/pQHEqgRdJ.png" width="200"> |

---

## Installation & Setup

Follow the steps below to run the project on your local machine.

### 1. Backend (API) Settings
Update the `Connection String` in `appsettings.json` and create the database via Package Manager Console:

```bash
Update-Database
```
*Note the HTTP port from `launchSettings.json` (e.g., 5126).*

### 2. Network Settings (⚠️ Important)
To allow the Mobile App (Emulator/Device) to communicate with the Local API:
1.  Find your IPv4 address (`cmd` -> `ipconfig`).
2.  Ensure both devices are on the same Wi-Fi network.
3.  Allow the port through Firewall if necessary.

### 3. Mobile (Flutter) Settings
Update the `baseUrl` in your service file (e.g., `lib/services/api_service.dart`):

```dart
String getBaseUrl() {
  // Replace with your IPv4 address
  return "http://192.168.1.XX:5126/api";
}
```
---

## Developer

- **Name:** Zişan Yüce  
- **Role:** Computer Engineering Student 
- **Goal:** This project was developed as a **Graduation Project** for the Computer Engineering department. It aims to demonstrate advanced Full Stack development capabilities by building a scalable, real-world e-commerce ecosystem.The project showcases the integration of a robust .NET Core backend with both Web (MVC) and Mobile (Flutter) interfaces, applying best practices in **N-Layer Architecture**,**RESTful API design**, and **Cross-Platform development**.

---

⭐ **If you like this project, don't forget to give it a star!**
