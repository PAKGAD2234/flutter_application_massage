# 🌿 ZenTouch AI-Powered Massage Booking Application (MiniPoject)

<p align="center">
  <img src="https://github.com/user-attachments/assets/ba998142-0346-4eaf-aced-3877461b8f3a" width="190" alt="ZenTouch Splash Screen"/>
</p>

<h3 align="center">Your Relaxation, Just a Conversation Away.</h3>

<p align="center">
  เว็บแอปพลิเคชันสำหรับจองบริการนวด ที่ผสานการพัฒนาด้วย Flutter เข้ากับ Google Gemini AI<br/>
  เพื่อสร้างประสบการณ์การจองที่สะดวกสบาย ผ่านทั้งการสนทนากับ AI และการจองด้วยตนเอง
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?style=for-the-badge&logo=flutter&logoColor=white"/>
  <img src="https://img.shields.io/badge/Dart-Programming%20Language-0175C2?style=for-the-badge&logo=dart&logoColor=white"/>
  <img src="https://img.shields.io/badge/Google%20Gemini-Generative%20AI-8E75B2?style=for-the-badge&logo=googlegemini&logoColor=white"/>
  <img src="https://img.shields.io/badge/Focus-Frontend%20Development-2E8B57?style=for-the-badge"/>
</p>

---

## 📌 เกี่ยวกับโปรเจกต์ (Project Overview)

**ZenTouch** เป็นโปรเจกต์พัฒนาเว็บแอปพลิเคชันสำหรับจองบริการนวด โดยใช้ Flutter และ Dart ในการพัฒนาส่วนติดต่อผู้ใช้งาน (User Interface) พร้อมนำ Google Gemini AI มาประยุกต์ใช้กับแนวคิดการจองบริการผ่านบทสนทนา (AI Conversational Booking)

แนวคิดหลักของโปรเจกต์คือการลดความยุ่งยากในขั้นตอนการจอง ลูกค้าสามารถเลือกได้ว่าจะจองผ่าน AI โดยการพูดคุยและระบุความต้องการ หรือเลือกบริการและกำหนดเวลานัดหมายด้วยตนเอง

นอกจากระบบจองแล้ว ยังออกแบบหน้าจอสำหรับติดตามสถานะการจอง จัดการข้อมูลส่วนตัว และตั้งค่าบัญชี เพื่อให้การใช้งานภายในแอปพลิเคชันเป็นไปอย่างต่อเนื่องและเป็นระบบ

## ✨ จุดเด่นของโปรเจกต์ (Key Highlights)

- **AI-Powered Booking:** ประยุกต์ใช้ Google Gemini AI กับแนวคิดการจองบริการผ่านบทสนทนา
- **Dual Booking Experience:** รองรับทั้งการจองผ่าน AI และการจองด้วยตนเอง
- **Booking Management:** ออกแบบระบบแสดงรายการและติดตามสถานะการจอง
- **Customer-Centric UI:** ออกแบบหน้าจอโดยคำนึงถึงความสะดวกและประสบการณ์ของลูกค้า
- **Responsive Web Application:** พัฒนาด้วย Flutter สำหรับประสบการณ์ใช้งานบนหน้าจอที่หลากหลาย

---

## 🚀 ฟีเจอร์ภายในแอปพลิเคชัน (Application Features)

### 01. 🏠 Home & Service Discovery

หน้าหลักสำหรับค้นหาและเลือกบริการนวด

- แสดงรายการบริการนวดที่เปิดให้บริการ
- แสดงรายละเอียดและราคาของแต่ละบริการ
- เข้าถึงระบบจองผ่าน AI ได้โดยตรง
- ออกแบบหน้าจอให้เรียบง่ายและสื่อถึงบรรยากาศแห่งการผ่อนคลาย

### 02. 🤖 AI Conversational Booking

ระบบช่วยจองบริการผ่านบทสนทนา โดยใช้ Google Gemini AI

- ออกแบบ Chat Interface สำหรับการพูดคุยระหว่างลูกค้ากับ AI
- รองรับการโต้ตอบและรวบรวมความต้องการในการจอง
- ช่วยจัดระเบียบข้อมูลการจองให้อยู่ในรูปแบบที่เข้าใจง่าย
- แสดงสรุปรายละเอียดการจองเพื่อให้ลูกค้าตรวจสอบ

**รายละเอียดที่รวบรวมในการจอง**
- ชื่อผู้จอง
- บริการที่เลือก
- ราคาค่าบริการ
- วันที่และเวลานัดหมาย

### 03. 📅 Manual Booking

ระบบจองบริการด้วยตนเอง โดยไม่จำเป็นต้องผ่าน AI

- เลือกรายการบริการนวด
- เลือกระยะเวลาการนวดเป็นชั่วโมง
- เลือกวันและเวลาที่ต้องการเข้ารับบริการ
- ตรวจสอบรายละเอียดการจอง

### 04. 📋 Booking Management

หน้าจัดการรายการจองสำหรับลูกค้า

- แสดงรายการจองทั้งหมด
- แสดงจำนวนรายการจองและบริการที่เลือก
- แสดงสถานะของแต่ละรายการ
- แยกรายการที่กำลังดำเนินการและรายการที่เสร็จสิ้นแล้ว
- ตรวจสอบรายละเอียดการจองแต่ละรายการ

### 05. 👤 Profile & Settings

หน้าจัดการข้อมูลส่วนตัวและการตั้งค่าบัญชี

- แสดงข้อมูลโปรไฟล์ผู้ใช้งาน
- จัดการข้อมูลบัญชีเบื้องต้น
- เปลี่ยนรหัสผ่าน
- เปิดและปิดเสียงแจ้งเตือน
- เข้าถึงเมนูตั้งค่าต่าง ๆ

---

# 📱 ภาพตัวอย่างการใช้งาน (Application Showcase)

## 01 — Splash Screen

<p align="center">
  <img src="https://github.com/user-attachments/assets/ba998142-0346-4eaf-aced-3877461b8f3a" width="250" alt="ZenTouch Splash Screen"/>
</p>

หน้าจอเริ่มต้นของแอปพลิเคชัน ZenTouch ออกแบบให้สื่อถึงความผ่อนคลายและเอกลักษณ์ของแบรนด์

## 02  Home Screen

<p align="center">
  <img src="https://github.com/user-attachments/assets/853d8ef1-0516-495d-a273-d291a3ddcd88" width="280" alt="ZenTouch Home Screen"/>
</p>

หน้าหลักที่รวบรวมบริการนวด พร้อมช่องทางเข้าสู่ระบบจองผ่าน AI

## 03  AI Booking & Chat Interface

<p align="center">
  <img src="https://github.com/user-attachments/assets/5122b569-72d2-4d58-a322-2d111e30bb7f" width="280" alt="AI Booking"/>
</p>

<p align="center">
  <img src="https://github.com/user-attachments/assets/b9bd1ee7-0143-4865-b2f8-d80f1fa7f35e" width="350" alt="AI Chat Interface"/>
</p>

ออกแบบประสบการณ์การจองผ่านบทสนทนา โดยนำ Google Gemini AI มาประยุกต์ใช้เพื่อช่วยให้การระบุความต้องการและรวบรวมข้อมูลการจองเป็นธรรมชาติมากขึ้น

## 04  AI Booking Summary

<p align="center">
  <img src="https://github.com/user-attachments/assets/609e6871-1f27-4a8b-b07e-9681b0b59348" width="350" alt="AI Booking Summary"/>
</p>

แสดงสรุปข้อมูลการจองที่รวบรวมจากบทสนทนา ช่วยให้ลูกค้าตรวจสอบรายละเอียดบริการ ราคา และวันนัดหมายได้อย่างชัดเจน

## 05  Manual Booking

<p align="center">
  <img src="https://github.com/user-attachments/assets/bf3ad72e-4c6c-4a8b-b07b-6a70c20dbc59" width="280" alt="Manual Booking Interface"/>
</p>

รองรับการจองด้วยตนเอง ลูกค้าสามารถเลือกบริการ ระยะเวลาการนวด และวันเวลาที่ต้องการได้โดยตรง

## 06  Booking Management

<p align="center">
  <img src="https://github.com/user-attachments/assets/ea1661cf-f858-416c-ace3-1cbef6145961" width="250" alt="Booking List"/>
  <img src="https://github.com/user-attachments/assets/a87871a1-fd69-431f-a60d-00e5018436c9" width="250" alt="Booking Details"/>
</p>

หน้าจัดการรายการจองที่ช่วยให้ลูกค้าติดตามการจองและตรวจสอบสถานะการใช้บริการได้

## 07  Profile & Settings

<p align="center">
  <img src="https://github.com/user-attachments/assets/1ae59da8-adba-485f-b50b-d97f116daa1f" width="280" alt="Profile and Settings"/>
</p>

หน้าจัดการข้อมูลส่วนตัวและการตั้งค่าพื้นฐานภายในแอปพลิเคชัน

---

## 🛠️ Technology Stack

| เทคโนโลยี | รายละเอียดการใช้งาน |
|---|---|
| Flutter | Framework สำหรับพัฒนาเว็บแอปพลิเคชัน |
| Dart | ภาษาหลักที่ใช้ในการพัฒนา |
| Google Gemini AI | Generative AI สำหรับการสนทนาและช่วยรวบรวมข้อมูลการจอง |
| AI Chat Interface | ส่วนติดต่อผู้ใช้งานสำหรับระบบสนทนากับ AI |
| UI/UX Design | ออกแบบหน้าจอและ User Flow |

## 🧠 Development Skills

ทักษะที่ได้ประยุกต์ใช้ในการพัฒนาโปรเจกต์นี้

- **Frontend Development:** พัฒนาส่วนติดต่อผู้ใช้งานด้วย Flutter และ Dart
- **AI Integration:** ประยุกต์ใช้ Google Gemini AI กับแนวคิดการจองผ่านบทสนทนา
- **UI/UX Design:** ออกแบบหน้าจอและลำดับการใช้งานให้เหมาะสมกับผู้ใช้
- **User Flow Design:** วางโครงสร้างการใช้งานตั้งแต่เลือกบริการจนถึงสรุปการจอง
- **Information Presentation:** ออกแบบการแสดงผลข้อมูลและสถานะการจองให้อ่านง่าย

## 📂 Project Information

| รายละเอียด | ข้อมูล |
|---|---|
| ชื่อโปรเจกต์ | ZenTouch |
| ประเภทโปรเจกต์ | Web Application |
| กลุ่มผู้ใช้งาน | ลูกค้า (Customer) |
| Framework | Flutter |
| Language | Dart |
| AI Technology | Google Gemini |
| Development Focus | Frontend Development |
| Design Focus | UI/UX Design |

## 📍 Project Scope

โปรเจกต์นี้มุ่งเน้นการพัฒนาส่วนติดต่อผู้ใช้งานฝั่งลูกค้า (Customer-side UI) ครอบคลุมหน้าหลัก ระบบจองผ่าน AI ระบบจองด้วยตนเอง หน้าจัดการรายการจอง และหน้าโปรไฟล์

ขอบเขตปัจจุบันเน้นการพัฒนาประสบการณ์การใช้งานและส่วนติดต่อผู้ใช้ ไม่ใช่ระบบจัดการร้านนวดแบบครบวงจรที่เชื่อมต่อ Backend ทุกส่วน

---

<p align="center">
  <b>🌿 ZenTouch</b>
</p>
<p align="center">
  <b>Developed by</b><br/>
  <strong>นางสาวรัตนากร สุระ</strong><br/>
  <sub>Student ID: 6752410029</sub>
  <br/><br/>
  <i>Crafted with passion, powered by technology.</i>
</p>

<p align="center">
  Designed with Care. Powered by Flutter & Gemini AI.
</p>

