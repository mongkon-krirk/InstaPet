# InstaPET — MVP Technical Specification
## Flutter Mobile Application + Strapi v5 API + Cloudflare R2 + DigitalOcean

**Document type:** Implementation Specification for Cursor and classroom use  
**Project:** InstaPET  
**Version:** 1.1  
**Status:** MVP baseline — revised to use Strapi Upload Plugin with Cloudflare R2 provider  
**Primary purpose:** ใช้เป็นโครงการตัวอย่างสำหรับคลาสเรียนเขียน Mobile Application ด้วย AI และเป็นฐานให้นักเรียนพัฒนาต่อยอด

---

## Revision Note — Version 1.1

Specification รุ่นนี้แก้ไข Media Upload Architecture จากการ Upload ตรงไป Cloudflare R2 ด้วย Presigned URL เป็นการ Upload ผ่าน Strapi API ตาม Workflow มาตรฐาน:

```text
Flutter -> Strapi Upload Plugin -> Cloudflare R2
```

ไฟล์ทุกไฟล์ต้องถูกสร้างเป็น `plugin::upload.file` และมองเห็นได้ใน Strapi Media Library

## 1. Project Overview

InstaPET เป็น Mobile Application สำหรับแชร์รูปสัตว์เลี้ยงในลักษณะ Social Photo Feed โดยได้รับแรงบันดาลใจด้านรูปแบบการใช้งานจาก Instagram แต่ต้องพัฒนาเป็นระบบใหม่ภายใต้ชื่อและอัตลักษณ์ของ InstaPET

ระบบ MVP ประกอบด้วย:

- Mobile Application พัฒนาด้วย Flutter
- Backend API พัฒนาด้วย Strapi v5
- PostgreSQL บน DigitalOcean Managed Database
- Strapi Deployment บน DigitalOcean App Platform
- รูปภาพจัดเก็บบน Cloudflare R2
- ใช้ Strapi Admin Panel ที่มีมาให้สำหรับจัดการข้อมูลในช่วง MVP
- ยังไม่พัฒนา Web Portal Admin แยกต่างหาก
- รองรับ iOS และ Android จาก Flutter codebase เดียว

---

## 2. Product Goals

### 2.1 เป้าหมายหลัก

1. ผู้เรียนสามารถศึกษาการสร้าง Mobile App แบบครบวงจร
2. แยก Mobile, API, Database และ Object Storage อย่างถูกต้อง
3. ใช้แนวทางโครงสร้างโค้ดที่อ่านง่ายและต่อยอดได้
4. มีตัวอย่าง Authentication, CRUD, Upload, Feed, Like และ Follow
5. ใช้ AI/Cursor ช่วยพัฒนาโดยยังคงมี Specification และ Acceptance Criteria ที่ชัดเจน
6. สามารถ Deploy Production ได้จริงบน DigitalOcean และ Cloudflare R2

### 2.2 หลักการออกแบบสำหรับการเรียนการสอน

- ไม่ทำระบบซับซ้อนเกินความจำเป็น
- แยกโค้ดตาม Feature
- ทุก Feature ต้องมี Model, Repository, Service, State และ UI ที่ชัดเจน
- ใช้ Custom API เฉพาะกรณีที่ Strapi Generated API ไม่เหมาะสม
- หลีกเลี่ยง Business Logic สำคัญใน Flutter
- API ต้องตรวจสิทธิ์ฝั่ง Server เสมอ
- มี Seed Data และ Mock Mode เพื่อให้นักเรียนเริ่มจาก UI ได้
- มี TODO และ Extension Point สำหรับ Assignment เพิ่มเติม

---

## 3. MVP Scope

### 3.1 Features ที่ต้องมี

#### Authentication

- สมัครสมาชิกด้วย:
  - Username
  - Email
  - Password
- ไม่ต้องยืนยัน Email
- Login ด้วย Username หรือ Email และ Password
- Logout
- เก็บ Session อย่างปลอดภัยในอุปกรณ์
- ดึงข้อมูลผู้ใช้ปัจจุบัน
- เปลี่ยน Password ด้วย Password เดิมและ Password ใหม่
- เมื่อ Token หมดอายุหรือไม่ถูกต้อง ให้กลับหน้า Login
- ไม่รวม Facebook Login ใน MVP
- ไม่รวม Forgot Password ผ่าน Email ใน MVP แรก แต่เตรียม Extension Point ไว้

#### User Profile

- ดูโปรไฟล์ตนเอง
- ดูโปรไฟล์ผู้ใช้อื่น
- แก้ไข Display Name
- แก้ไข Bio
- แก้ไข Profile Photo
- กำหนดบัญชีเป็น Public หรือ Private
- MVP เริ่มต้นให้ค่าเริ่มต้นเป็น Public
- แสดงจำนวน Posts, Followers และ Following
- แสดง Grid รูปโพสต์ของผู้ใช้
- Username ต้องไม่ซ้ำ
- Email ต้องไม่ซ้ำ
- ยังไม่รองรับ Website, Phone, Gender และ Professional Account ใน MVP

#### Post

- สร้าง Post ได้ด้วยรูปภาพ 1–10 รูป
- ใส่ Caption ได้
- ไม่รองรับ Video
- ไม่แก้ไข Post หลังเผยแพร่
- เจ้าของ Post ลบ Post ได้
- แสดง Post Detail
- รองรับ Carousel เมื่อ Post มีหลายรูป
- แสดงตำแหน่งรูปปัจจุบัน เช่น 1/3 และ Page Indicator
- ย่อและบีบอัดรูปบนอุปกรณ์ก่อน Upload
- Server ตรวจสอบจำนวนไฟล์ ประเภทไฟล์ และขนาดซ้ำอีกครั้ง
- เมื่อลบ Post ต้องจัดการ Media Object ตามนโยบายที่กำหนด

#### Feed

- แสดงโพสต์ Public ล่าสุดจากผู้ใช้อื่นได้ง่าย
- แสดงโพสต์ของผู้ใช้ที่กำลัง Follow
- แสดงโพสต์ของตนเองได้
- เรียงใหม่ไปเก่า
- Pagination แบบ Cursor-based หรือ Page-based
- Pull to refresh
- Infinite scroll
- Empty state
- Loading skeleton
- Error state พร้อม Retry
- MVP ไม่ทำระบบ Algorithm Ranking ซับซ้อน

#### Like

- Like Post
- Unlike Post
- แสดง Like Count
- แสดงสถานะว่าผู้ใช้ปัจจุบัน Like แล้วหรือไม่
- ป้องกัน Like ซ้ำใน Database
- ใช้ Optimistic UI และ Rollback เมื่อ API ล้มเหลว

#### Follow

- Follow ผู้ใช้อื่น
- Unfollow ผู้ใช้อื่น
- ห้าม Follow ตนเอง
- ป้องกัน Follow ซ้ำ
- ดูรายการ Followers
- ดูรายการ Following
- บัญชี Public: Follow ได้ทันที
- บัญชี Private: สำหรับ MVP ให้แสดงว่าเป็น Private และไม่แสดงโพสต์ แต่ยังไม่ทำ Follow Request Workflow
- Follow Request เป็น Phase 2

#### Discover / Search

- Search ผู้ใช้จาก Username หรือ Display Name
- Discover Grid แสดง Public Posts ล่าสุด
- แตะรูปเพื่อเปิด Post Detail
- MVP ไม่ทำ Hashtag, Category, Shop, IGTV, QR Scan หรือ Advanced Recommendation

#### Activity

Activity เป็น Optional MVP+:

- แสดงรายการเมื่อมีคน Like Post ของเรา
- แสดงรายการเมื่อมีคน Follow เรา
- Activity เก็บใน Database
- ยังไม่ต้องมี Push Notification
- หากเวลาคลาสจำกัด สามารถใช้หน้าหัวใจเป็นรายการ Like/Follow แบบพื้นฐาน หรือซ่อนไว้ก่อน

### 3.2 Out of Scope

รายการต่อไปนี้ต้องไม่พัฒนาใน MVP เว้นแต่มีคำสั่งเพิ่ม:

- Video Post
- Story
- Live
- Comment และ Reply
- Direct Message
- Push Notification
- Facebook Login
- Google/Apple Login
- Email Verification
- Forgot Password Email Flow
- Post Editing
- Hashtag
- Mention
- Saved Post / Bookmark
- Tag People
- Location
- Content Recommendation Algorithm
- Follow Request สำหรับ Private Account
- Block / Mute
- Reporting Workflow เต็มรูปแบบ
- Web Portal Admin แยก
- Payment หรือ E-commerce
- Analytics เชิงธุรกิจ

---

## 4. UI Reference Mapping

ไฟล์ UI Reference ที่แนบมาใช้เป็นแนวทางด้าน Layout, Spacing, Navigation และ Interaction เท่านั้น ต้องเปลี่ยน Branding จาก Instagram เป็น InstaPET และใช้เนื้อหาเกี่ยวกับสัตว์เลี้ยง

| Reference File | InstaPET Screen | Implementation Note |
|---|---|---|
| `1.Welcome.png` | Welcome / Recent Account | เปลี่ยน Logo และข้อความเป็น InstaPET; Recent account เป็น Optional |
| `2.Login.png` | Login | ตัด Facebook Login และ Forgot Password ออกจาก MVP หรือแสดง Disabled |
| `3.Main.png` | Home Feed | ตัด Stories, Camera, Reels และ Message; คง Feed และ Bottom Navigation |
| `4.Search.png` | Discover | เปลี่ยน Category Chips เป็นประเภทสัตว์ได้ใน Phase 2; MVP ใช้ Search + Grid |
| `5.Likes.png` | Activity: You | ใช้เฉพาะ Like และ Follow Activity |
| `6.Profile.png` | Profile | ตัด Story Highlights; แสดง Profile, Stats, Edit/Follow และ Post Grid |
| `7.Search Pick.png` | Discover Result / All Posts | ใช้เป็น Public Post Grid |
| `8.Following.png` | Activity: Following | ไม่จำเป็นใน MVP; ใช้เป็น Phase 2 |
| `9.Profile Edit.png` | Edit Profile | ใช้เฉพาะ Photo, Display Name, Username, Bio และ Privacy |

### 4.1 Branding Rules

- ชื่อ Application: `InstaPET`
- ห้ามใช้คำว่า Instagram ใน Production UI
- Logo ต้องเป็นของ InstaPET
- ใช้ Pet-themed placeholder และ Seed Data
- ใช้ Material 3 เป็นพื้นฐาน แต่ปรับหน้าตาตาม Reference
- UI ต้องรองรับ Safe Area
- UI ต้องรองรับจอขนาดเล็กและใหญ่
- Text ต้องไม่ล้น
- รองรับ Dark Mode เป็น Phase 2
- ภาษา MVP: English UI ตาม Reference หรือเตรียม Localization สำหรับ Thai/English

### 4.2 Bottom Navigation

MVP ใช้ 4 หรือ 5 Tabs:

1. Home
2. Discover
3. Create Post
4. Activity — Optional
5. Profile

หากตัด Activity ให้ใช้ 4 Tabs และเพิ่มใน Phase 2

---

## 5. Recommended System Architecture

```text
Flutter Mobile App
    |
    | HTTPS + JWT
    | multipart/form-data image upload
    v
Strapi v5 API on DigitalOcean App Platform
    |
    +---- Strapi Upload Plugin
    |         |
    |         +---- Cloudflare R2 Upload Provider
    |                    |
    |                    +---- Stores image objects in R2
    |                    +---- Returns URL and metadata to Strapi
    |
    +---- Strapi Media Library
    |         |
    |         +---- plugin::upload.file records
    |         +---- Admin can browse and manage uploaded files
    |
    +---- PostgreSQL on DigitalOcean Managed Database
```

### 5.1 Upload Architecture

InstaPET ต้องใช้แนวทางมาตรฐานของ Strapi ตามรูปแบบที่โครงการใช้งานอยู่:

1. Flutter เลือกรูปจาก Gallery หรือ Camera
2. Flutter ทำ Auto-rotate, Resize และ Compress บนอุปกรณ์
3. Flutter ส่งไฟล์แบบ `multipart/form-data` ไปยัง Strapi API
4. Strapi ตรวจ JWT, จำนวนไฟล์, MIME type และขนาดไฟล์
5. Strapi Upload Plugin ส่งไฟล์ต่อไปยัง Cloudflare R2 ผ่าน Upload Provider ที่รองรับ S3-compatible storage
6. R2 เก็บตัวไฟล์จริง
7. Strapi สร้างข้อมูลไฟล์ใน `plugin::upload.file`
8. ไฟล์ปรากฏใน Strapi Media Library
9. Strapi ส่งข้อมูลไฟล์ เช่น `id`, `documentId`, `url`, `width`, `height`, `mime` กลับให้ Flutter
10. Flutter นำ Media File ID ที่ได้รับไปสร้าง Post หรือกำหนดเป็น Profile Photo
11. Strapi ตรวจว่าไฟล์ที่ถูกอ้างอิงเป็นไฟล์ที่ผู้ใช้ปัจจุบันเพิ่งอัปโหลดหรือได้รับอนุญาตให้ใช้งาน

Flow:

```text
Flutter
   |
   | POST multipart/form-data
   v
Strapi Upload API
   |
   | Upload Provider
   v
Cloudflare R2
   |
   +--> Strapi creates plugin::upload.file record
   |
   +--> File appears in Strapi Media Library
```

แนวทางนี้แทนที่ Direct-to-R2 Upload และ Presigned URL ทั้งหมดใน Specification รุ่นก่อนหน้า

ข้อดี:

- Admin สามารถจัดการไฟล์ผ่าน Strapi Media Library ได้โดยตรง
- ใช้ Workflow มาตรฐานของ Strapi
- ลดจำนวน Custom Endpoint และ Custom Entity
- เหมาะกับการเรียนการสอนและดูแลระบบได้ง่าย
- Flutter ไม่ได้รับ R2 Credential
- เปลี่ยน Storage Provider ภายหลังได้โดยไม่ต้องแก้ Mobile Upload Flow มาก
- Metadata ของไฟล์ถูกเก็บใน Strapi โดยอัตโนมัติ

ข้อควรระวัง:

- ไฟล์จะผ่าน Strapi Web Service ก่อนเข้า R2
- ต้องกำหนด Upload Limit, Request Timeout และ Memory ให้เหมาะสม
- Flutter ต้องย่อรูปก่อนส่งเพื่อลดโหลด Strapi
- App Platform ไม่ควรใช้ Local Disk เป็นที่เก็บไฟล์ถาวร
- Upload Provider ต้องตั้งค่าให้ส่งไฟล์ไป R2 ทุก Environment ที่ไม่ใช่ local fallback

### 5.2 Strapi Media Library and R2 Strategy

สำหรับ MVP:

- ใช้ Strapi Upload Plugin เป็นศูนย์กลางการจัดการไฟล์
- ใช้ Cloudflare R2 เป็น Storage Provider ของ Upload Plugin
- ตัวไฟล์จริงอยู่ใน R2
- Metadata อยู่ใน PostgreSQL ผ่าน `plugin::upload.file`
- ไฟล์ทุกไฟล์ต้องเห็นและจัดการได้ใน Strapi Media Library
- Post และ User Avatar ใช้ Media Relation ไปยัง Strapi upload file
- ใช้ Public R2 custom domain หรือ URL ที่ Upload Provider คืนให้
- ห้ามเก็บ R2 Access Key หรือ Secret ใน Flutter
- ห้ามให้ Flutter Upload ไป R2 โดยตรง
- ไม่ใช้ Strapi multipart upload ใน MVP
- ไม่สร้าง Custom `media-asset` entity
- ไม่สร้างระบบ `pending/ready/attached` สำหรับ Media เอง
- การลบไฟล์ต้องทำผ่าน Strapi Upload Service เพื่อให้ลบทั้ง record และ object ใน R2 อย่างสอดคล้องกัน

### 5.3 Recommended Upload Endpoint Strategy

มี 2 ทางเลือกที่ยอมรับได้:

#### Option A — ใช้ Strapi Upload Endpoint โดยตรง

```http
POST /api/upload
Authorization: Bearer <jwt>
Content-Type: multipart/form-data
```

เหมาะสำหรับ MVP และคลาส แต่ต้องตรวจ Permission และ Ownership เพิ่มเติม

#### Option B — ใช้ Custom Authenticated Upload Endpoint ครอบ Strapi Upload Service

```http
POST /api/app-media/upload
Authorization: Bearer <jwt>
Content-Type: multipart/form-data
```

Custom endpoint จะ:

- ตรวจจำนวนไฟล์
- ตรวจ MIME type
- ตรวจขนาด
- กำหนด folder หรือ metadata
- เรียก Strapi Upload Service ภายใน
- บันทึก owner/purpose เพิ่มเติม
- คืน DTO ที่ Mobile ใช้งานง่าย

**แนวทางแนะนำ:** ใช้ Option B เพื่อควบคุม Security และ Ownership แต่ยังคงใช้ Strapi Upload Plugin และ Media Library ตามมาตรฐานเดิม

## 6. Repository Structure

แนะนำ Monorepo เพื่อให้นักเรียนเห็นระบบทั้งชุด:

```text
instapet/
├── README.md
├── docs/
│   ├── SPEC.md
│   ├── API.md
│   ├── DATA_MODEL.md
│   ├── DEPLOYMENT.md
│   ├── CLASSROOM_GUIDE.md
│   └── ui-reference/
├── mobile/
│   ├── pubspec.yaml
│   ├── lib/
│   ├── test/
│   ├── integration_test/
│   └── README.md
├── backend/
│   ├── package.json
│   ├── config/
│   ├── database/
│   ├── src/
│   ├── public/
│   ├── tests/
│   └── README.md
├── scripts/
│   ├── seed.ts
│   └── reset-demo.sh
├── .env.example
├── .gitignore
└── docker-compose.dev.yml
```

---

## 7. Flutter Mobile Architecture

### 7.1 Architecture Pattern

ใช้ Feature-first + MVVM-inspired architecture:

```text
lib/
├── main.dart
├── bootstrap.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── theme/
│   └── config/
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   ├── api_exception.dart
│   │   └── auth_interceptor.dart
│   ├── storage/
│   │   ├── secure_token_storage.dart
│   │   └── local_preferences.dart
│   ├── widgets/
│   ├── utils/
│   ├── constants/
│   └── models/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── feed/
│   ├── post/
│   ├── profile/
│   ├── discover/
│   ├── social/
│   ├── activity/
│   └── settings/
└── l10n/
```

แต่ละ Feature:

```text
feature_name/
├── data/
│   ├── dto/
│   ├── services/
│   └── repositories/
├── domain/
│   ├── models/
│   └── repositories/
└── presentation/
    ├── screens/
    ├── widgets/
    └── controllers/
```

### 7.2 Recommended Packages

กำหนด Version จาก Flutter stable ที่ใช้ในวันเริ่มโครงการ ไม่ควรล็อก Version ในเอกสารนี้จนกว่าจะสร้างโครงการจริง

- `flutter_riverpod` — State management
- `go_router` — Navigation และ Auth redirect
- `dio` — HTTP client และ upload progress
- `flutter_secure_storage` — เก็บ Token
- `freezed` + `json_serializable` — Immutable model และ JSON mapping
- `cached_network_image` — Cache รูป
- `image_picker` — เลือกรูปจาก Camera/Gallery
- `image` หรือ package compression ที่รองรับ platform — Resize/Compress
- `photo_view` — Optional สำหรับดูรูปเต็ม
- `carousel_slider` หรือ `PageView` มาตรฐาน — Multi-image post
- `shimmer` — Optional loading skeleton
- `intl` — Date/time formatting
- `uuid` — Client request identifier
- `connectivity_plus` — Optional network state
- `mocktail` — Unit tests

### 7.3 State Management Rules

- ใช้ Riverpod เป็น state management หลัก
- Screen ไม่เรียก Dio โดยตรง
- Widget ไม่ควรมี Business Logic
- Repository เป็น Source of Truth ของข้อมูลจาก API
- Controller/ViewModel จัดการ loading, data, error
- Token อ่านผ่าน Auth Repository เท่านั้น
- Like/Follow ใช้ Optimistic State
- Feed State ต้องรองรับ refresh และ pagination
- Profile state แยก current user และ viewed user

### 7.4 Navigation Routes

```text
/
├── /splash
├── /welcome
├── /login
├── /register
├── /home
│   ├── /feed
│   ├── /discover
│   ├── /create
│   ├── /activity
│   └── /profile/me
├── /profile/:username
├── /profile/edit
├── /profile/:username/followers
├── /profile/:username/following
├── /post/:documentId
├── /settings
└── /settings/change-password
```

Router Guard:

- ไม่มี Token → Login/Welcome
- มี Token และเปิด Login → Home
- API ตอบ 401 → ล้าง Token แล้วกลับ Login
- Deep link ที่ต้อง Login → เก็บ intended route แล้วเปิดหลัง Login

---

## 8. Mobile Screens and Acceptance Criteria

### 8.1 Splash

- แสดง InstaPET branding
- อ่าน Token จาก Secure Storage
- หากไม่มี Token → Welcome/Login
- หากมี Token → เรียก `/api/users/me`
- สำเร็จ → Home
- ไม่สำเร็จ 401 → ล้าง Token → Login
- Network error → แสดง Retry โดยไม่ล้าง Token ทันที

### 8.2 Welcome

- แสดง Logo InstaPET
- ปุ่ม Log in
- ปุ่ม Sign up
- Recent Account เป็น Optional
- ห้ามฝังข้อมูลผู้ใช้จริงใน Source Code

### 8.3 Register

Fields:

- Username
- Email
- Password
- Confirm Password

Validation:

- Username 3–30 ตัว
- ใช้ตัวอักษรอังกฤษ ตัวเลข จุด และ underscore ตามกติกาที่กำหนด
- Email format ถูกต้อง
- Password อย่างน้อย 8 ตัว
- Confirm Password ตรงกัน
- Submit ซ้ำไม่ได้ขณะ Loading
- Error จาก Server ต้องแสดงแบบอ่านเข้าใจง่าย

หลังสมัครสำเร็จ:

- Login อัตโนมัติจาก JWT ที่ API ส่งกลับ
- เปิดหน้าตั้ง Profile เบื้องต้น หรือเข้า Home
- Profile เริ่มต้นเป็น Public

### 8.4 Login

- Login ด้วย Username หรือ Email
- Password ซ่อน/แสดงได้
- Disable ปุ่มเมื่อ Input ไม่ครบ
- แสดง Loading
- เก็บ Token ใน Secure Storage
- ไม่เก็บ Password
- Error ไม่ควรบอกละเอียดว่า Email หรือ Password ส่วนไหนผิด

### 8.5 Home Feed

Feed Card แสดง:

- Avatar
- Username
- เวลาโพสต์
- More menu
- Image/Carousel
- Image position
- Like button
- Like count
- Caption
- Delete menu เมื่อเป็นเจ้าของ

Behavior:

- Double tap รูปเพื่อ Like เป็น Optional
- Pull to refresh
- Infinite scroll
- ป้องกัน request pagination ซ้อน
- รูปใช้ aspect ratio จาก metadata
- ไม่โหลดรูป full-size ใน thumbnail/grid
- หาก Post ถูกลบระหว่างดู ให้ลบออกจาก state
- Feed ต้องแสดง Public Post แม้ผู้ใช้ยัง Follow คนไม่มาก เพื่อให้ App ไม่ว่าง

Feed Mode ที่แนะนำ:

```text
GET /api/feed?mode=home
```

Server รวม:

1. Posts จาก Following
2. Posts ของตนเอง
3. Public discovery posts ล่าสุดเพื่อเติม Feed

MVP สามารถเรียงทั้งหมดตาม `publishedAt DESC`

### 8.6 Create Post

Flow:

1. เลือกรูป 1–10 รูป
2. แสดง Preview
3. เรียงลำดับรูปใหม่ได้เป็น Optional
4. ลบรูปจากรายการได้
5. Resize และ Compress
6. แสดง Upload Progress
7. ใส่ Caption
8. Submit
9. สำเร็จ → Feed และ Profile ต้องเห็น Post ใหม่
10. ล้มเหลว → Retry โดยไม่ต้องเลือกรูปใหม่ ถ้าไฟล์ยังอยู่

### 8.7 Image Processing Requirements

ก่อน Upload:

- Auto-rotate จาก EXIF
- ลบ EXIF/GPS metadata หาก library รองรับ
- ความยาวด้านใหญ่สุดแนะนำ 1600–2048 px
- JPEG quality เริ่มต้น 80–85
- PNG ที่ไม่ต้องการ transparency ควรแปลงเป็น JPEG
- รองรับ JPEG, PNG, WebP ตามที่ทีมทดสอบแล้ว
- ไม่รับ GIF ใน MVP
- ขนาดหลัง Compress เป้าหมายไม่เกิน 2–3 MB ต่อรูป
- Server hard limit เช่น 5 MB ต่อรูป
- สร้าง thumbnail variant บนอุปกรณ์หรือ Worker เป็น Phase 2

ข้อมูลที่ส่งขอ Upload:

```json
{
  "purpose": "post",
  "fileName": "cat-photo.jpg",
  "contentType": "image/jpeg",
  "sizeBytes": 1245123,
  "width": 1600,
  "height": 1200
}
```

### 8.8 Post Detail

- แสดงรูปทั้งหมด
- แสดง Caption
- แสดง Like count
- Like/Unlike
- เปิด Profile เจ้าของ
- เจ้าของลบ Post ได้
- Confirm ก่อนลบ
- ไม่แสดง Edit

### 8.9 Discover

- Search bar
- Debounce 300–500 ms
- Search ผู้ใช้
- เมื่อไม่มี Query แสดง Public Post Grid
- Grid 3 columns
- Thumbnail ใช้ `cover`
- Multi-image Post แสดง icon ซ้อน
- แตะเปิด Post Detail
- Pagination

### 8.10 Profile

Own Profile:

- Avatar
- Display Name
- Username
- Bio
- Posts count
- Followers count
- Following count
- Edit Profile
- Post Grid

Other Public Profile:

- Follow/Following button
- เปิด Post Grid
- แสดง stats

Other Private Profile:

- แสดงข้อมูลพื้นฐานและ stats ตามนโยบาย
- ไม่แสดง Post
- แสดงข้อความ Private Account
- MVP ยังไม่ส่ง Follow Request

### 8.11 Edit Profile

Editable:

- Profile Photo
- Display Name
- Username
- Bio
- Public/Private

Rules:

- Username uniqueness ตรวจที่ Server
- Bio จำกัด 150 ตัว
- Display Name จำกัด 50 ตัว
- Profile photo ผ่าน upload flow เดียวกับ media
- กด Save ครั้งเดียว
- API ต้องรองรับ partial update
- หากเปลี่ยน Username สำเร็จ Routing และ cache ต้อง update

### 8.12 Change Password

Fields:

- Current Password
- New Password
- Confirm New Password

Rules:

- ตรวจ Current Password ฝั่ง Server
- New Password อย่างน้อย 8 ตัว
- ห้ามเหมือน Password เดิม
- หลังเปลี่ยนสำเร็จ:
  - ทางเลือก A: คง Session เดิม
  - ทางเลือกที่แนะนำสำหรับคลาส: Logout และให้ Login ใหม่
- ไม่ log password

---

## 9. Strapi v5 Backend Structure

```text
backend/src/
├── api/
│   ├── post/
│   │   ├── content-types/post/schema.json
│   │   ├── controllers/post.ts
│   │   ├── routes/post.ts
│   │   ├── routes/custom-post.ts
│   │   └── services/post.ts
│   ├── post-like/
│   ├── follow/
│   ├── app-media/
│   ├── activity/
│   └── feed/
├── extensions/
│   └── users-permissions/
│       ├── content-types/user/schema.json
│       └── strapi-server.ts
├── policies/
│   ├── is-owner.ts
│   └── rate-limit-key.ts
├── middlewares/
├── services/
│   └── upload-ownership.ts
├── utils/
└── index.ts
```

### 9.1 Strapi Rules

- ใช้ TypeScript
- ใช้ `documentId` เป็น Public Resource Identifier ตาม Strapi v5
- ไม่ expose numeric database `id` ให้ Mobile ยึดเป็นหลัก
- ไม่อนุญาต Generic Create/Update/Delete โดยตรงสำหรับ Entity ที่มี ownership-sensitive logic
- Like, Follow, Feed, Media และ Change Password ใช้ Custom Endpoint
- ใช้ Strapi Admin Panel สำหรับ:
  - ดู Users
  - ดู/ลบ Posts
  - ดูและจัดการไฟล์ผ่าน Media Library
  - ดู Likes/Follows
  - Moderation ขั้นพื้นฐาน
- ปิด Public Permission ทุก endpoint โดย default
- เปิด Public เฉพาะ Register/Login และ Public read ที่ตั้งใจ
- Authenticated role ต้องให้สิทธิ์เฉพาะ endpoints ที่กำหนด

---

## 10. Data Model

### 10.1 User Extension

Extend `plugin::users-permissions.user`

| Field | Type | Required | Notes |
|---|---|---:|---|
| username | string | yes | unique, normalized |
| email | email | yes | unique, lowercase |
| displayName | string | yes | default จาก username |
| bio | text | no | max 150 |
| avatar | media single image | no | relation to `plugin::upload.file` |
| isPrivate | boolean | yes | default false |
| status | enum | yes | active, suspended, deleted |
| postsCount | integer | yes | denormalized, default 0 |
| followersCount | integer | yes | denormalized, default 0 |
| followingCount | integer | yes | denormalized, default 0 |
| lastSeenAt | datetime | no | optional |
| profileCompleted | boolean | yes | default false |

หมายเหตุ:

- `blocked` และ `confirmed` เป็น field ที่ Strapi Users & Permissions มีอยู่แล้ว
- ห้าม expose email ของผู้ใช้อื่น
- API Public Profile ใช้ DTO เฉพาะ

### 10.2 Post

Collection type: `api::post.post`

| Field | Type | Required | Notes |
|---|---|---:|---|
| documentId | Strapi | yes | public identifier |
| author | many-to-one User | yes | immutable |
| caption | text | no | max 2,200; MVP อาจกำหนด 500 |
| mediaItems | one-to-many `post-media` | yes | 1–10 |
| visibility | enum | yes | public, followers |
| status | enum | yes | published, deleted, hidden |
| likesCount | integer | yes | default 0 |
| publishedAt | datetime | yes | Draft & Publish หรือ custom |
| deletedAt | datetime | no | soft delete optional |

MVP แนะนำ:

- ใช้ `status=published/deleted`
- API ไม่คืน deleted post
- `author` แก้ไม่ได้
- `mediaItems` แก้ไม่ได้หลัง publish
- `caption` แก้ไม่ได้ตาม Scope

### 10.3 Post Media

แนะนำให้ใช้ **Repeatable Component** ชื่อ `post.media-item` ภายใน Post แทน Collection Type แยก

| Field | Type | Required | Notes |
|---|---|---:|---|
| image | media single image | yes | relation to `plugin::upload.file` |
| sortOrder | integer | yes | 0–9 |
| altText | string | no | accessibility |
| width | integer | no | อ่านจาก upload file metadata ได้ |
| height | integer | no | อ่านจาก upload file metadata ได้ |
| aspectRatio | decimal | no | คำนวณตอน response หรือเก็บไว้ก็ได้ |

Post field:

| Field | Type | Required | Notes |
|---|---|---:|---|
| mediaItems | repeatable component `post.media-item` | yes | 1–10 items |

เหตุผล:

- รองรับหลายรูปและลำดับรูป
- ไฟล์ยังถูกจัดการผ่าน Strapi Media Library
- ไม่ต้องสร้าง Custom Media Asset Entity
- Post อ่านง่ายใน Strapi Admin
- สามารถเพิ่ม alt text หรือ metadata ต่อรูปได้

ข้อกำหนด:

- `sortOrder` ต้องไม่ซ้ำภายใน Post
- Custom Create Post API ต้องเรียง mediaItems ตาม `sortOrder`
- รูปต้องเป็น `plugin::upload.file` ที่มี MIME เป็น image
- รูปที่อ้างอิงต้องผ่าน ownership validation

### 10.4 Upload File Ownership Metadata

Strapi Media Library ใช้ `plugin::upload.file` เป็น record หลักของไฟล์

เพื่อป้องกันผู้ใช้หนึ่งนำ File ID ของอีกผู้ใช้ไปสร้าง Post แนะนำให้ Extend Upload File ด้วยข้อมูลต่อไปนี้ หรือสร้าง Mapping Entity ขนาดเล็ก:

| Field | Type | Required | Notes |
|---|---|---:|---|
| uploadedByAppUser | relation many-to-one User | yes for mobile upload | เจ้าของไฟล์ใน Mobile App |
| purpose | enum | yes | post, avatar |
| usageStatus | enum | yes | uploaded, attached, unused |
| appReference | string | no | optional request/reference id |

แนวทางที่แนะนำ:

- Extend `plugin::upload.file` หาก Strapi version และ plugin extension รองรับได้สะดวก
- หากไม่ต้องการแก้ schema ของ upload plugin ให้สร้าง `app-media-owner` collection type ที่ relation ไปยัง Upload File และ User
- ไม่สร้างระบบไฟล์ซ้ำซ้อน
- ตัวไฟล์และ metadata หลักยังคงอยู่ใน Media Library

เมื่อ Upload สำเร็จ:

- ตั้ง `uploadedByAppUser` เป็น current user
- ตั้ง `purpose`
- ตั้ง `usageStatus=uploaded`

เมื่อสร้าง Post หรือเปลี่ยน Avatar:

- ตรวจ owner
- เปลี่ยน `usageStatus=attached`

เมื่อยกเลิกการสร้าง Post:

- ไฟล์ยังอยู่ใน Media Library
- Cleanup Job สามารถลบไฟล์ `unused` ที่เกิน retention period ผ่าน Strapi Upload Service

### 10.5 Post Like

Collection type: `api::post-like.post-like`

| Field | Type | Required |
|---|---|---:|
| user | many-to-one User | yes |
| post | many-to-one Post | yes |
| createdAt | datetime | yes |

Database unique constraint:

```text
UNIQUE(user_id, post_id)
```

### 10.6 Follow

Collection type: `api::follow.follow`

| Field | Type | Required | Notes |
|---|---|---:|---|
| follower | many-to-one User | yes | ผู้กด Follow |
| following | many-to-one User | yes | ผู้ถูก Follow |
| status | enum | yes | accepted; requested reserved |
| createdAt | datetime | yes | |

Constraints:

```text
UNIQUE(follower_id, following_id)
CHECK(follower_id <> following_id)
```

### 10.7 Activity

Optional collection type: `api::activity.activity`

| Field | Type | Required | Notes |
|---|---|---:|---|
| recipient | many-to-one User | yes | owner of activity |
| actor | many-to-one User | yes | who performed action |
| type | enum | yes | post_like, follow |
| post | many-to-one Post | no | required for post_like |
| isRead | boolean | yes | default false |
| createdAt | datetime | yes | |

ควรมี deduplication ตามประเภท Event เมื่อเหมาะสม

---

## 11. Database Indexes and Constraints

Cursor ต้องเพิ่ม migration หรือ database customization สำหรับ index สำคัญ:

```text
users(username unique)
users(email unique)
posts(author_id, published_at desc)
posts(status, visibility, published_at desc)
upload_files(created_at)
app_media_owner(user_id, upload_file_id unique)    # only if mapping entity is used
post_likes(user_id, post_id unique)
post_likes(post_id, created_at desc)
follows(follower_id, following_id unique)
follows(following_id, created_at desc)
follows(follower_id, created_at desc)
activities(recipient_id, created_at desc)
```

Counter fields:

- `likesCount`
- `postsCount`
- `followersCount`
- `followingCount`

ต้อง update ใน Transaction เดียวกับการ Create/Delete relationship เท่าที่ Strapi/Database รองรับ

ต้องมี Periodic Reconciliation Script สำหรับคำนวณ Counter ใหม่จากข้อมูลจริง

---

## 12. API Conventions

### 12.1 Base URL

```text
Development: http://localhost:1337/api
Production:  https://api.instapet.example/api
```

### 12.2 Authentication Header

```http
Authorization: Bearer <token>
```

### 12.3 Response Envelope

Custom API ใช้มาตรฐานเดียวกัน:

```json
{
  "data": {},
  "meta": {},
  "error": null
}
```

Error:

```json
{
  "data": null,
  "meta": {},
  "error": {
    "code": "POST_NOT_FOUND",
    "message": "Post not found",
    "details": {}
  }
}
```

### 12.4 Error Codes

- `VALIDATION_ERROR`
- `UNAUTHORIZED`
- `FORBIDDEN`
- `RESOURCE_NOT_FOUND`
- `USERNAME_TAKEN`
- `EMAIL_TAKEN`
- `INVALID_CREDENTIALS`
- `CURRENT_PASSWORD_INVALID`
- `CANNOT_FOLLOW_SELF`
- `ALREADY_FOLLOWING`
- `POST_NOT_FOUND`
- `POST_NOT_OWNED`
- `MEDIA_NOT_READY`
- `MEDIA_NOT_OWNED`
- `MEDIA_LIMIT_EXCEEDED`
- `UNSUPPORTED_MEDIA_TYPE`
- `UPLOAD_EXPIRED`
- `RATE_LIMITED`

### 12.5 Pagination

Request:

```text
?page=1&pageSize=20
```

Response:

```json
{
  "data": [],
  "meta": {
    "pagination": {
      "page": 1,
      "pageSize": 20,
      "pageCount": 5,
      "total": 91,
      "hasNextPage": true
    }
  },
  "error": null
}
```

MVP ใช้ Page-based ได้เพื่อความเข้าใจง่าย  
Phase 2 เปลี่ยน Feed เป็น Cursor-based เพื่อความเสถียรเมื่อมี Post ใหม่

---

## 13. API Endpoint Specification

### 13.1 Authentication

#### Register

```http
POST /api/auth/local/register
```

Body:

```json
{
  "username": "milo_cat",
  "email": "milo@example.com",
  "password": "strong-password"
}
```

Server extension หลัง Register:

- normalize username/email
- สร้าง displayName จาก username
- isPrivate = false
- status = active
- counters = 0
- confirmed ตาม setting ที่ไม่ต้องยืนยัน email

#### Login

```http
POST /api/auth/local
```

Body:

```json
{
  "identifier": "milo_cat",
  "password": "strong-password"
}
```

#### Current User

```http
GET /api/users/me
```

ควรสร้าง Custom Sanitized DTO ไม่คืน private fields เกินจำเป็น

#### Change Password

```http
POST /api/account/change-password
```

Body:

```json
{
  "currentPassword": "old-password",
  "newPassword": "new-password",
  "newPasswordConfirmation": "new-password"
}
```

### 13.2 Profiles

```http
GET   /api/profiles/me
PATCH /api/profiles/me
GET   /api/profiles/:username
GET   /api/profiles/:username/posts?page=1&pageSize=18
GET   /api/profiles/:username/followers?page=1&pageSize=20
GET   /api/profiles/:username/following?page=1&pageSize=20
```

PATCH example:

```json
{
  "displayName": "Milo the Cat",
  "username": "milo_cat",
  "bio": "Sleep. Eat. Repeat.",
  "isPrivate": false,
  "avatarFileId": 123
}
```

Public profile response:

```json
{
  "data": {
    "documentId": "user-document-id",
    "username": "milo_cat",
    "displayName": "Milo the Cat",
    "bio": "Sleep. Eat. Repeat.",
    "avatarUrl": "https://media.example/...",
    "isPrivate": false,
    "postsCount": 12,
    "followersCount": 120,
    "followingCount": 34,
    "isFollowing": true,
    "isMe": false
  },
  "meta": {},
  "error": null
}
```

### 13.3 Media Upload

#### Upload Image through Strapi

```http
POST /api/app-media/upload
Authorization: Bearer <jwt>
Content-Type: multipart/form-data
```

Multipart fields:

```text
files: <binary image file, one or multiple>
purpose: post | avatar
```

สามารถส่งหลายไฟล์ใน Request เดียวได้ แต่ต้องจำกัดไม่เกิน 10 รูปสำหรับ Post

ตัวอย่าง response:

```json
{
  "data": [
    {
      "id": 123,
      "documentId": "upload-file-document-id",
      "name": "cat-photo.jpg",
      "url": "https://media.instapet.example/...",
      "mime": "image/jpeg",
      "sizeKb": 842.5,
      "width": 1600,
      "height": 1200,
      "purpose": "post"
    }
  ],
  "meta": {},
  "error": null
}
```

Implementation requirement:

1. Endpoint ต้อง require JWT
2. รับไฟล์แบบ multipart
3. ตรวจจำนวนไฟล์
4. ตรวจ MIME type
5. ตรวจ file size
6. เรียก Strapi Upload Plugin service
7. Upload Provider ส่งไฟล์ไป Cloudflare R2
8. Strapi สร้าง `plugin::upload.file`
9. ผูก ownership metadata กับ current user
10. คืน sanitized file DTO
11. ไฟล์ต้องปรากฏใน Strapi Media Library

#### Delete Unused Uploaded File

```http
DELETE /api/app-media/:fileId
Authorization: Bearer <jwt>
```

อนุญาตเมื่อ:

- current user เป็นผู้อัปโหลด
- ไฟล์ยังไม่ได้ถูกใช้ใน Post หรือ Avatar
- ลบผ่าน Strapi Upload Service
- ระบบลบทั้ง Upload File record และ R2 object

ห้ามให้ Mobile เรียก Generic Delete Upload File โดยไม่มี ownership policy

### 13.4 Posts

```http
POST   /api/posts
GET    /api/posts/:documentId
DELETE /api/posts/:documentId
```

Create body:

```json
{
  "caption": "My first InstaPET post",
  "visibility": "public",
  "mediaItems": [
    {
      "fileId": 123,
      "sortOrder": 0,
      "altText": "Orange cat sitting near a window"
    },
    {
      "fileId": 124,
      "sortOrder": 1,
      "altText": "Orange cat sleeping"
    }
  ]
}
```

Create Post ต้องทำ Transaction:

1. ตรวจ media 1–10
2. ตรวจว่า file ทุกชิ้นเป็น `plugin::upload.file`
3. ตรวจ MIME เป็น image
4. ตรวจ ownership ตรงกับ current user
5. ตรวจว่ายังไม่ถูกผูกกับ Post อื่นในกรณีที่กำหนด one-use policy
6. สร้าง Post พร้อม repeatable media component
7. เปลี่ยน ownership metadata เป็น attached
8. เพิ่ม postsCount
9. commit
10. เมื่อ error rollback

Delete Post:

- ตรวจ ownership
- เปลี่ยน post status เป็น deleted หรือ hard deleteตามนโยบาย
- ลด postsCount
- ลบ/ซ่อน likes และ activity ที่เกี่ยวข้อง
- ไฟล์ของ Post เปลี่ยน usage status เป็น unused หรือถูกลบตามนโยบาย
- หากต้องลบไฟล์จริง ให้เรียก Strapi Upload Service เพื่อให้ R2 object และ Media Library record ตรงกัน
- idempotent: ลบซ้ำต้องไม่ทำ counter ติดลบ

### 13.5 Feed

```http
GET /api/feed?mode=home&page=1&pageSize=10
GET /api/feed?mode=following&page=1&pageSize=10
GET /api/feed?mode=discover&page=1&pageSize=18
```

Post DTO:

```json
{
  "documentId": "post-document-id",
  "caption": "A happy day",
  "visibility": "public",
  "likesCount": 25,
  "likedByMe": true,
  "publishedAt": "2026-06-07T10:00:00Z",
  "author": {
    "documentId": "user-document-id",
    "username": "milo_cat",
    "displayName": "Milo",
    "avatarUrl": "https://..."
  },
  "mediaItems": [
    {
      "documentId": "post-media-id",
      "url": "https://...",
      "width": 1600,
      "height": 1200,
      "aspectRatio": 1.3333,
      "sortOrder": 0,
      "altText": "..."
    }
  ],
  "canDelete": false
}
```

### 13.6 Like

```http
PUT    /api/posts/:documentId/like
DELETE /api/posts/:documentId/like
GET    /api/posts/:documentId/likes?page=1&pageSize=20
```

PUT ต้อง idempotent:

- ถ้ามี Like แล้ว คืน success และ count ปัจจุบัน
- ถ้ายังไม่มี ให้สร้างและเพิ่ม counter

DELETE ต้อง idempotent:

- ถ้าไม่มี Like แล้ว คืน success
- ถ้ามี ให้ลบและลด counter โดยไม่ต่ำกว่า 0

### 13.7 Follow

```http
PUT    /api/profiles/:username/follow
DELETE /api/profiles/:username/follow
```

PUT response:

```json
{
  "data": {
    "following": true,
    "followersCount": 121
  },
  "meta": {},
  "error": null
}
```

### 13.8 Search

```http
GET /api/search/users?q=milo&page=1&pageSize=20
```

Rules:

- trim query
- minimum 2 characters
- search username/displayName
- ไม่คืน blocked/suspended/deleted users
- ไม่คืน email
- ป้องกัน wildcard query ที่หนักเกินไป

### 13.9 Activity

```http
GET  /api/activities?page=1&pageSize=20
POST /api/activities/read
```

Body:

```json
{
  "activityIds": ["activity-doc-1", "activity-doc-2"]
}
```

---

## 14. Authorization Matrix

| Action | Public | Authenticated | Owner Required |
|---|---:|---:|---:|
| Register | yes | no | no |
| Login | yes | no | no |
| Read public profile | optional | yes for MVP | no |
| Read private posts | no | no unless allowed later | no |
| Create post | no | yes | current user |
| Delete post | no | yes | yes |
| Like/unlike | no | yes | current user |
| Follow/unfollow | no | yes | current user |
| Edit profile | no | yes | yes |
| Upload image through Strapi | no | yes | yes |
| Delete unused uploaded file | no | yes | yes |
| View own activity | no | yes | recipient |

แนะนำให้ MVP บังคับ Login ก่อนใช้ App ทุกหน้า แม้ข้อมูลเป็น Public เพื่อให้ Flow การเรียนง่ายขึ้น แต่ API ควรออกแบบให้สามารถเปิด Public Read ในอนาคตได้

---

## 15. Security Requirements

- HTTPS เท่านั้นใน Production
- เก็บ JWT/Refresh token ใน Secure Storage
- ห้ามเก็บ R2 secret ใน Flutter
- Flutter ต้อง Upload ผ่าน Strapi API เท่านั้น
- R2 Credential อยู่เฉพาะใน Strapi Runtime Environment
- Validate file size ทั้งที่ Flutter และ Strapi
- จำกัด MIME:
  - image/jpeg
  - image/png
  - image/webp
- ไม่เชื่อถือ file extension
- จำกัดจำนวนไฟล์ต่อ Request
- กำหนด Strapi body/upload size limit
- ใช้ชื่อไฟล์และ key ที่ Upload Provider/Strapi จัดการอย่างปลอดภัย
- Sanitize Caption และ Bio
- Output encode บน client
- Rate limit:
  - login
  - register
  - app-media upload
  - create post
  - like/follow
  - search
- ป้องกัน Mass Assignment
- ไม่คืน Password hash, reset token, provider token หรือ private email
- ตรวจ ownership ของ Upload File ฝั่ง Server
- ห้ามผู้ใช้ส่ง File ID ของผู้อื่นเพื่อสร้าง Post หรือเปลี่ยน Avatar
- CORS จำกัด origin สำหรับ Admin/Web
- Log ห้ามมี JWT, password, multipart binary content หรือ secret
- Environment secrets ต้องอยู่ใน DigitalOcean encrypted runtime variables
- Database ใช้ SSL
- ตั้ง backup และ recovery plan
- Admin account ต้องใช้รหัสผ่านแข็งแรงและจำกัดผู้ดูแล
- เพิ่ม basic moderation status ให้ User/Post
- จำกัด Caption/Bio length
- Query ต้องมี pagination
- ห้ามให้ client ส่ง `likesCount`, `author`, `status` หรือ counters โดยตรง
- ใช้ Strapi Upload Service สำหรับการลบไฟล์ ห้ามลบ R2 object โดยตรงแล้วปล่อย Media Library record ค้าง

## 16. Media Lifecycle and Cleanup

### 16.1 Media Lifecycle

```text
Flutter selects image
    -> Flutter resize/compress
    -> Strapi Upload Plugin
    -> Cloudflare R2
    -> plugin::upload.file
    -> Media Library
    -> attached to Post or User Avatar
```

Application usage state:

```text
uploaded -> attached
uploaded -> unused
attached -> unused when Post/Avatar is removed
unused -> deleted by cleanup job
```

`uploaded`, `attached`, `unused` เป็น metadata ของ InstaPET สำหรับ ownership/usage เท่านั้น  
ตัวไฟล์หลักยังถูกจัดการด้วย Strapi Upload Plugin

### 16.2 Cleanup Job

รันตาม Schedule เช่นวันละครั้ง:

- หาไฟล์ Mobile Upload ที่ `usageStatus=uploaded/unused`
- อายุเกิน retention เช่น 24 ชั่วโมงหรือ 7 วัน
- ตรวจว่าไม่มี Post หรือ Avatar อ้างอิงอยู่
- เรียก Strapi Upload Service เพื่อลบไฟล์
- Upload Plugin ต้องลบทั้ง:
  - `plugin::upload.file` record
  - object บน Cloudflare R2
- Cleanup ต้อง idempotent
- เก็บ log จำนวนไฟล์ที่ลบ
- มี Dry-run mode สำหรับ Production safety
- ห้ามใช้ script ลบ R2 object ตรง ๆ โดยไม่อัปเดต Strapi

DigitalOcean App Platform สามารถใช้ Scheduled Job หรือ Worker แยก

## 17. Strapi Admin Usage

MVP ใช้ Built-in Strapi Admin:

- Content Manager:
  - User
  - Post
  - Post Media
  - Media Library
  - Post Like
  - Follow
  - Activity
- Admin สามารถ:
  - Suspend/Block User
  - Hide/Delete Post
  - ตรวจสอบข้อมูล
  - แก้ไข Seed Data
- ห้ามให้นักเรียนเปิด Public CRUD permissions แบบกว้างเพื่อแก้ปัญหาชั่วคราว
- สร้าง Admin account ผ่าน deployment setup
- แยก Admin User ออกจาก App End User ให้ชัดเจน

---

## 18. DigitalOcean Production Architecture

### 18.1 Components

```text
DigitalOcean App Platform App
├── instapet-api (Strapi Web Service)
├── instapet-cleanup (Scheduled Job / Worker)
└── Managed PostgreSQL binding

Cloudflare
├── DNS / optional proxy for API domain
└── R2 Bucket + media custom domain
```

### 18.2 Strapi App Platform Settings

- Runtime: Node.js LTS ที่ Strapi version รองรับ
- Build command: ตาม Strapi project
- Run command: production start
- HTTP port: อ่านจาก `PORT`
- Health check path: `/api/health`
- Instance count MVP: 1
- Production scale: เพิ่ม instance ภายหลัง
- Persistent local disk: ห้ามใช้เก็บ media
- App Platform logs สำหรับ runtime
- Alert เมื่อ deployment fail หรือ health check fail

### 18.3 Database

- DigitalOcean Managed PostgreSQL
- Region เดียวกับ App Platform ถ้าเป็นไปได้
- ใช้ private connection/VPC เมื่อรองรับใน topology
- SSL enabled
- Connection pool จำกัดตาม plan
- Automated backups
- กำหนด retention
- ทดสอบ restore เป็นระยะ
- แยก Development/Staging/Production database

### 18.4 Environment Variables

ตัวอย่าง:

```env
NODE_ENV=production
HOST=0.0.0.0
PORT=8080
APP_KEYS=...
API_TOKEN_SALT=...
ADMIN_JWT_SECRET=...
TRANSFER_TOKEN_SALT=...
JWT_SECRET=...

DATABASE_CLIENT=postgres
DATABASE_URL=${managed-db.DATABASE_URL}
DATABASE_SSL=true

PUBLIC_API_URL=https://api.instapet.example
CORS_ORIGINS=https://admin.instapet.example

R2_ACCOUNT_ID=...
R2_ACCESS_KEY_ID=...
R2_SECRET_ACCESS_KEY=...
R2_BUCKET=instapet-production
R2_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
R2_PUBLIC_BASE_URL=https://media.instapet.example
UPLOAD_PROVIDER=cloudflare-r2
UPLOAD_MAX_FILE_BYTES=5242880
UPLOAD_MAX_FILES_PER_REQUEST=10
UPLOAD_ALLOWED_TYPES=image/jpeg,image/png,image/webp
UPLOAD_UNUSED_RETENTION_HOURS=24
```

Secret variables ต้อง Encrypt ใน App Platform

### 18.5 Health Endpoint

```http
GET /api/health
```

Response:

```json
{
  "status": "ok",
  "version": "1.0.0",
  "time": "2026-06-07T10:00:00Z"
}
```

Health check พื้นฐานไม่ควรเปิดเผย secret หรือรายละเอียด infrastructure

Optional readiness endpoint ตรวจ database แบบ timeout สั้น

---

## 19. Development Environments

### 19.1 Local

- Flutter ใช้ Android Emulator/iOS Simulator/Device
- Strapi localhost
- PostgreSQL ผ่าน Docker Compose
- R2:
  - ใช้ R2 development bucket หรือ S3-compatible local service
  - ห้ามใช้ production bucket
- `.env` ไม่ commit
- มี `.env.example`

### 19.2 Staging

- App Platform แยกจาก Production
- Managed DB แยก
- R2 bucket แยก
- API domain แยก
- Seed users แบบ demo
- ใช้สำหรับ integration test และคลาส

### 19.3 Production

- ไม่มี demo password
- ไม่มี debug endpoint
- ไม่ใช้ seed ที่มี credential คงที่
- เปิด monitoring/alerts
- จำกัด Admin access
- ตั้ง backup

---

## 20. Testing Strategy

### 20.1 Flutter Unit Tests

- Auth repository
- Feed pagination
- Like optimistic update
- Follow optimistic update
- JSON parsing
- Validation
- Image processing config

### 20.2 Flutter Widget Tests

- Login form
- Feed card
- Multi-image carousel
- Empty state
- Error state
- Profile stats
- Edit Profile form

### 20.3 Integration Tests

- Register → Login → Create Post
- Upload multiple images
- Like → Unlike
- Follow → Unfollow
- Delete own post
- Cannot delete another user's post
- Change password
- Private profile does not expose posts
- Token invalidation

### 20.4 Backend Tests

- Authentication required
- Ownership policies
- Unique Like
- Unique Follow
- Cannot follow self
- Media ownership
- Media state transition
- Post create transaction rollback
- Counter correctness
- Pagination
- Sanitized profile response
- Rate limit behavior

### 20.5 Minimum Acceptance Test Scenario

1. User A สมัครและ Login
2. User A แก้ชื่อ Bio และรูป
3. User A โพสต์รูป 3 รูปพร้อม Caption
4. User B สมัครและ Login
5. User B ค้นหา User A
6. User B เปิด Profile A
7. User B Follow A
8. User B เห็น Post A ใน Feed
9. User B Like Post A
10. User A เห็นจำนวน Like และ Follower เพิ่ม
11. User A ลบ Post
12. User B Refresh แล้วไม่เห็น Post
13. User A เปลี่ยน Password และ Login ด้วย Password ใหม่ได้

---

## 21. Logging and Observability

Backend log fields:

- requestId
- route
- method
- status
- durationMs
- authenticatedUserId แบบ internal ID ที่ไม่ใช่ email
- errorCode

ห้าม log:

- password
- JWT
- Authorization header
- R2 secret
- Strapi multipart upload เต็ม
- Database connection string

Metrics ที่ควรติดตามภายหลัง:

- API error rate
- p95 response time
- Upload upload count
- Upload completion failure
- Post creation failure
- Database connections
- App memory
- R2 cleanup count

---

## 22. Classroom Development Plan

### Module 1 — Project Setup

- Flutter project
- Strapi v5 project
- PostgreSQL
- Environment config
- Git workflow
- Run UI with mock data

### Module 2 — Authentication

- Register
- Login
- Secure token storage
- Auth guard
- Current user

### Module 3 — Profile

- Profile model
- Edit profile
- Avatar upload
- Public/private state

### Module 4 — Media Upload

- Image picker
- Resize/compress
- Strapi multipart upload
- Upload progress
- Complete endpoint

### Module 5 — Posts and Feed

- Create Post
- Multi-image relation
- Feed API
- Carousel
- Pagination

### Module 6 — Social Features

- Like
- Follow
- Followers/Following
- Optimistic UI

### Module 7 — Discover and Search

- User search
- Public grid
- Post detail

### Module 8 — Testing and Deployment

- Unit/Widget/API tests
- App Platform
- Managed PostgreSQL
- Cloudflare R2
- Production checklist

---

## 23. Student Extension Assignments

นักเรียนสามารถเลือกพัฒนาต่อ:

- Comment system
- Saved posts
- Pet profiles แยกจาก Owner
- Hashtag
- Pet type/category filter
- Push notification
- Follow request สำหรับ Private Account
- Report post
- Block user
- Dark mode
- Thai/English localization
- Video upload
- Story
- Offline cache
- Image thumbnail worker
- Cursor-based pagination
- Search ranking
- Pet adoption post type
- Lost pet alert
- Map/location
- AI-generated caption
- AI pet image classification

Extension ต้องไม่แก้ core entity แบบทำลาย backward compatibility โดยไม่มี migration

---

## 24. Coding Standards for Cursor

Cursor ต้องปฏิบัติตาม:

1. อ่าน Specification ก่อนแก้โค้ด
2. ทำทีละ Feature และ Commit ขนาดเล็ก
3. ห้ามสร้าง endpoint ที่ไม่มีใน Spec โดยไม่แจ้ง
4. ห้ามเปิด Strapi permission ทั้งหมด
5. ห้ามฝัง secret
6. Flutter ต้อง Upload ผ่าน Strapi และห้ามเข้าถึง Database หรือ R2 secret โดยตรง
7. ทุก API ต้องมี validation
8. ทุก ownership-sensitive action ต้องตรวจฝั่ง Server
9. ใช้ `documentId` ใน external API
10. ห้ามใช้ `dynamic` ใน Dart โดยไม่จำเป็น
11. DTO และ Domain Model แยกกัน
12. Error ต้อง map เป็น typed exception
13. ทุก async UI ต้องมี loading/error/empty state
14. Pagination ต้องป้องกัน duplicate request
15. Like/Follow endpoints ต้อง idempotent
16. Database uniqueness ต้องบังคับจริง ไม่พึ่งแค่ code
17. Counter update ต้อง transaction-safe
18. เพิ่ม test สำหรับ bug ที่แก้
19. Update เอกสารเมื่อ API เปลี่ยน
20. ไม่แก้ generated/native files โดยไม่จำเป็น

---

## 25. Cursor Execution Workflow

ให้ Cursor ทำงานตามลำดับ:

### Phase A — Bootstrap

- สร้าง Monorepo
- สร้าง Flutter app
- สร้าง Strapi v5 TypeScript app
- เพิ่ม Docker PostgreSQL local
- สร้าง `.env.example`
- สร้าง health endpoint
- สร้าง CI lint/test ขั้นต้น

### Phase B — Backend Foundation

- Extend User
- สร้าง content types
- เพิ่ม DB indexes/constraints
- สร้าง DTO sanitizer
- ตั้ง permissions
- เพิ่ม seed script

### Phase C — Mobile UI Foundation

- Theme
- Router
- Auth shell
- Bottom navigation
- สร้าง Screens จาก Reference ด้วย mock data
- ทำ responsive layout

### Phase D — Authentication

- Register/Login/Logout
- Token storage
- Auth interceptor
- Profile me
- Change password

### Phase E — Media and Post

- Strapi Upload Provider for Cloudflare R2
- Authenticated multipart upload endpoint
- Image processor
- Create post
- Feed
- Delete post

### Phase F — Social

- Like
- Follow
- Search
- Profile grids
- Optional activity

### Phase G — QA and Deployment

- Tests
- staging
- production env
- App Platform spec
- DB binding
- R2 provider, public media domain และ Strapi Media Library
- smoke test

หลังจบแต่ละ Phase ให้ Cursor รายงาน:

- Files created/changed
- Commands to run
- Environment variables added
- API endpoints added
- Tests added
- Known limitations
- Manual verification steps

---

## 26. Definition of Done

Feature ถือว่าเสร็จเมื่อ:

- ทำงานตาม Acceptance Criteria
- API validation ครบ
- Authorization ถูกต้อง
- ไม่มี secret ใน repository
- มี loading/error/empty state
- มี test ขั้นต่ำ
- Lint ผ่าน
- Build ผ่าน Android และ iOS เท่าที่ environment รองรับ
- API response ใช้รูปแบบมาตรฐาน
- เอกสารอัปเดต
- ทดสอบกับ Staging
- ไม่มี Critical/High issue ที่ทราบและยังไม่บันทึก

---

## 27. Production Checklist

### Mobile

- [ ] App name และ bundle ID ถูกต้อง
- [ ] API production URL ถูกต้อง
- [ ] ไม่มี debug menu
- [ ] Secure storage ใช้งานจริง
- [ ] Permission camera/gallery มีข้อความอธิบาย
- [ ] Image compression ผ่านการทดสอบ
- [ ] Error message ไม่เปิดเผยข้อมูลระบบ

### Backend

- [ ] `NODE_ENV=production`
- [ ] Strapi secrets ไม่ใช้ค่า default
- [ ] Database SSL
- [ ] Public permissions ตรวจแล้ว
- [ ] Admin password แข็งแรง
- [ ] Rate limit
- [ ] CORS
- [ ] Health check
- [ ] Log redaction
- [ ] Unused media cleanup job
- [ ] Backup

### R2

- [ ] Development/Production bucket แยก
- [ ] API token จำกัด bucket
- [ ] Public read ผ่าน custom media domain
- [ ] Strapi Upload Provider เชื่อม R2 สำเร็จ
- [ ] Upload ผ่าน Strapi Media Library ได้
- [ ] Cache-Control
- [ ] R2 public/custom domain และ access policy ถูกต้อง
- [ ] Object lifecycle/cleanup

### DigitalOcean

- [ ] App Platform region เหมาะสม
- [ ] Managed DB ผูกด้วย runtime variable
- [ ] Environment variables encrypted
- [ ] Health check path
- [ ] Alerts
- [ ] Resource size ผ่าน load test ขั้นพื้นฐาน
- [ ] Domain/SSL
- [ ] Rollback procedure

---

## 28. Important Design Decisions

### Decision 1: ใช้ Strapi Admin แทนสร้าง Portal Admin

เหตุผล:

- ลด Scope
- Strapi มี Content Manager และ Media Library อยู่แล้ว
- เหมาะสำหรับ MVP และคลาส
- Portal แยกสามารถพัฒนาใน Phase 2

### Decision 2: Upload ผ่าน Strapi Upload Plugin

เหตุผล:

- เป็น Workflow มาตรฐานที่ทีมใช้งานอยู่
- Admin จัดการไฟล์ผ่าน Media Library ได้
- Flutter ไม่ต้องรู้รายละเอียดของ R2
- เปลี่ยน Storage Provider ได้ง่าย
- ลด Custom Media Infrastructure
- เหมาะกับ MVP และการเรียนการสอน

Trade-off:

- Strapi รับ multipart request และส่งไฟล์ต่อไป R2
- ต้อง Resize/Compress ที่ Flutter
- ต้องกำหนด memory, timeout และ upload size limit ให้เหมาะสม

### Decision 3: Cloudflare R2 เป็น Upload Provider ของ Strapi

เหตุผล:

- ตัวไฟล์ไม่อยู่บน Local Disk ของ App Platform
- รองรับ object storage และ custom media domain
- Strapi ยังเก็บ metadata ใน `plugin::upload.file`
- Media Library ใช้งานได้ตามปกติ

### Decision 4: Ownership Metadata ครอบ Strapi Upload File

เหตุผล:

- Strapi Media Library ไม่ได้หมายความว่า App User ทุกคนใช้ File ID ใดก็ได้
- ต้องทราบว่า Mobile User คนใดอัปโหลดไฟล์
- ป้องกันการนำไฟล์ของคนอื่นไปสร้าง Post
- รองรับ cleanup ไฟล์ที่ไม่ได้ใช้งาน

### Decision 5: Custom Social Endpoints

เหตุผล:

- Like/Follow ต้อง idempotent
- ต้องมี unique constraint
- ต้อง update counter
- Generic CRUD ไม่เหมาะกับ social action

### Decision 6: Feed แบบ Chronological

เหตุผล:

- เหมาะกับ MVP
- อธิบายง่าย
- Test ง่าย
- ยังไม่ต้องสร้าง ranking algorithm

### Decision 7: Feature-first Flutter Structure

เหตุผล:

- แบ่งงานนักเรียนง่าย
- Feature แยกขอบเขต
- ต่อขยายได้
- ลดไฟล์รวมที่ซับซ้อน

## 29. Official Technical References

Cursor ควรตรวจสอบเอกสารล่าสุดก่อนลง dependency หรือใช้ API เฉพาะ version:

- Flutter — Guide to app architecture
- Flutter — Navigation and routing
- Flutter — State management recommendations
- Strapi v5 — Users & Permissions
- Strapi v5 — REST API and plugin extension
- Cloudflare R2 — S3-compatible API
- Strapi v5 — Upload plugin and provider configuration
- Cloudflare R2 — S3-compatible storage and public/custom domains
- DigitalOcean — App Platform
- DigitalOcean — Environment variables and managed database binding
- DigitalOcean — Health checks and app specification

---

## 30. Initial Cursor Master Prompt

ใช้ Prompt ต่อไปนี้เป็นคำสั่งเริ่มงาน:

```text
You are implementing InstaPET, a Flutter + Strapi v5 educational MVP.

Read docs/SPEC.md completely before writing code.

Rules:
- Follow the scope and architecture in the specification.
- Use Flutter feature-first architecture with Riverpod, repositories, services, typed DTOs, and go_router.
- Use Strapi v5 TypeScript.
- Use Strapi documentId in external APIs.
- Use PostgreSQL.
- Store images in Cloudflare R2 through the Strapi Upload Plugin and an R2-compatible upload provider.
- Flutter must upload compressed images to an authenticated Strapi multipart endpoint.
- Uploaded files must be visible and manageable in Strapi Media Library.
- Do not implement direct-to-R2 upload or Strapi multipart uploads.
- Never expose R2 credentials to Flutter.
- Never enable broad public CRUD permissions.
- Validate ownership and input on the server.
- Implement Like and Follow as idempotent custom endpoints with database unique constraints.
- Do not implement video, stories, comments, chat, social login, post editing, or a custom admin portal.
- Use the provided UI images as visual references, but replace Instagram branding and unsupported features with InstaPET equivalents.
- Keep the project suitable for classroom learning.
- Add tests and documentation for each completed phase.
- Work one phase at a time and stop after each phase with a summary and verification instructions.

Start with Phase A — Bootstrap only.
```

---

## 31. Final MVP Deliverables

1. Flutter source code
2. Strapi v5 source code
3. PostgreSQL schema/migrations
4. Cloudflare R2 integration
5. Seed script
6. API documentation
7. Setup README
8. Deployment guide
9. Environment variable template
10. Unit/widget/API tests
11. Reference UI implementation
12. Classroom guide
13. Production checklist
14. Known limitations document

---

**End of Specification**
