#  E-Commerce Mobile App  

**EN:**  
This repository contains both the **web-based admin panel** and the **mobile application** of my e-commerce project.  
The **Admin Panel** is built with **ASP.NET Core MVC** and **SQL Server**, providing full management of products, categories, users, and orders.  
The **Mobile App**, developed with **Flutter**, will communicate with the backend through a custom **ASP.NET Web API** for all data operations such as product listing, user authentication, and order management.

**TR:**  
Bu depo, e-ticaret projemin hem **web tabanlı yönetici panelini** hem de **mobil uygulamasını** içermektedir.  
**Admin Panel**, ürün, kategori, kullanıcı ve sipariş yönetimini sağlamak için **ASP.NET Core MVC** ve **SQL Server** kullanılarak geliştirilmiştir.  
**Mobil Uygulama**, **Flutter** ile geliştirilecek ve veritabanı işlemleri (ürün listeleme, kullanıcı girişi, sipariş yönetimi vb.) için özel olarak geliştirilen **ASP.NET Web API** üzerinden iletişim kuracaktır.

---

## Technologies Used / Kullanılan Teknolojiler

| Layer / Katman | Technologies / Teknolojiler |
|----------------|-----------------------------|
| **Frontend (Mobile)** | Flutter |
| **Backend API** | ASP.NET Core Web API |
| **Admin Panel** | ASP.NET Core MVC |
| **Database** | SQL Server |
| **ORM** | Entity Framework Core |
| **Design** | Bootstrap 5, CSS, HTML |
| **Language** | C#, Dart |

---

## Admin Panel Features / Admin Panel Özellikleri

**EN:**  
- Product management (add, edit, delete)  
- Category and subcategory management  
- User and order management  
- Dashboard with real-time data  
- Secure authentication system  

**TR:**  
- Ürün yönetimi (ekleme, düzenleme, silme)  
- Kategori ve alt kategori yönetimi  
- Kullanıcı ve sipariş yönetimi  
- Gerçek zamanlı veriler içeren gösterge paneli  
- Güvenli kimlik doğrulama sistemi  

---

## Web API Features / Web API Özellikleri

**EN:**  
- RESTful endpoints for mobile and web communication  
- JSON-based responses  
- Token-based authentication  
- Separate layers for controllers, services, and repositories  
- Connected to the same SQL Server database used by the Admin Panel  

**TR:**  
- Mobil ve web arasındaki iletişim için RESTful endpoint’ler  
- JSON tabanlı yanıtlar  
- Token tabanlı kimlik doğrulama sistemi  
- Controller, Service ve Repository katmanlarıyla katmanlı yapı  
- Admin Panel ile aynı SQL Server veritabanına bağlı çalışma  

---

## Database / Veritabanı

**EN:**  
The database is designed with **SQL Server** and accessed via **Entity Framework Core**.  
A script file named `database_script.sql` is located under the `Database` folder in the AdminPanel project.  

**TR:**  
Veritabanı **SQL Server** kullanılarak tasarlanmış ve **Entity Framework Core** aracılığıyla erişilmektedir.  
`AdminPanel` projesindeki `Database` klasöründe `database_script.sql` adlı veritabanı script dosyası bulunmaktadır.  

---

## Future Plans / Gelecek Planları

**EN:**  
- Complete the Web API development  
- Integrate the Flutter mobile app with Web API  
- Add secure payment gateway integration  
- Implement product recommendation system  

**TR:**  
- Web API geliştirmesini tamamlamak  
- Flutter mobil uygulamasını Web API ile entegre etmek  
- Güvenli ödeme sistemi entegrasyonu eklemek  
- Ürün öneri sistemi uygulamak  

---

## Author / Geliştirici

**Name / İsim:** Zişan Yüce  
**Role / Rol:** Full Stack Developer & Computer Engineering Student  

---

## Screenshots / Ekran Görüntüleri
*(Will be added later when UI is finalized / Arayüz tamamlandığında eklenecek)*  

---

⭐ If you like this project, don’t forget to give it a star!  
⭐ Bu projeyi beğendiysen, yıldız vermeyi unutma!


