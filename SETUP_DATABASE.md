# دليل إعداد وربط قاعدة بيانات Supabase — متجر لجين LUJAIN

تم إعداد هذا الدليل لربط مشروع **متجر لجين LUJAIN للأزياء النسائية** مع قاعدة بيانات Supabase (PostgreSQL) بشكل سليم وآمن ومطابق لكافة المتطلبات.

---

## 1. إنشاء المشروع على Supabase

1. افتح الرابط: [Supabase Dashboard](https://supabase.com/dashboard).
2. انقر على **New Project**.
3. قم بتعبئة بيانات المشروع كالتالي:
   - **Name**: `lujain-store`
   - **Database Password**: اختر كلمة مرور قوية واحتفظ بها.
   - **Region**: اختر `Frankfurt (eu-central-1)` أو `Bahrain` لقرب المسافة وسرعة الاستجابة.
   - **Pricing Plan**: Free Plan (أو حسب رغبتك).
4. اضغط على **Create new project** وانتظر دقيقة حتى يكتمل التجهيز.

---

## 2. تنفيذ مخطط الجداول وسياسات الأمان والبيانات الأولية

تم دمج كامل المخطط (Schema + RLS + Seed Data) في ملف موحد جاهز للتنفيذ بنقرة واحدة:

1. من القائمة الجانبية في لوحة Supabase، اختر **SQL Editor**.
2. اضغط على زر **New Query** الأخضر في الأعلى.
3. افتح الملف الموجود في المشروع:
   [`supabase/full_setup.sql`](./supabase/full_setup.sql)
4. انسخ كامل محتواه والصقه داخل محرر SQL في Supabase.
5. اضغط على زر **Run** (أو اضغط `Ctrl + Enter`).
6. ستظهر رسالة النجاح: `Success. No rows returned`.

---

## 3. التحقق من الجداول المنشأة

بعد التنفيذ، توجه إلى **Table Editor** في القائمة الجانبية؛ ستجد الجداول التالية منشأة وجاهزة:
- `categories`: الأقسام الرئيسية (فساتين سهرة، جلابيات، أطقم، بلايز، تنانير).
- `products`: المنتجات النسائية وأسعارها بالريال اليمني (YER).
- `product_images`: روابط صور المنتجات المتعددة.
- `product_variants`: تفاصيل الألوان، المقاسات (S, M, L, XL)، ورموز الـ SKU.
- `inventory`: رصيد المخزون الحالي لكل متغير وتنبيهات انخفاض المخزون.
- `inventory_movements`: سجل الحركات غير القابل للتعديل.
- `orders`: رأس الطلبات مع حفظ لقطات ثابتة لعنوان الشحن والأسعار.
- `order_items`: تفاصيل أصناف كل طلب وأسعاره وتكلفته.
- `delivery_zones`: مناطق ورسوم التوصيل في المحافظات اليمنية (صنعاء، عدن، تعز، حضرموت، إب، الاستلام من الفرع).
- `cash_accounts`: حسابات الصندوق والمحافظ الإلكترونية (الكريمي، فلوسك، جوالي، ون كاش).
- `coupons`: كوبونات الخصم (`LUJAIN10`, `WELCOME`).
- `reviews`: تقييمات وآراء العميلات.

---

## 4. إعداد وسائط التخزين (Storage Buckets)

من القائمة الجانبية، توجه إلى **Storage**:
1. أنشئ Bucket باسم `product-images` واجعله **Public Bucket** لصور المنتجات.
2. أنشئ Bucket باسم `payment-proofs` لصور إشعارات وسندات تحويل الكريمي وفلوسك.
3. أنشئ Bucket باسم `expense-receipts` لفواتير المصروفات.

---

## 5. ربط المفاتيح في المتجر وتطبيق الهاتف

من لوحة Supabase، توجه إلى:
**Project Settings** ➔ **API**

انسخ:
- **Project URL** (مثل: `https://xyzcompany.supabase.co`)
- **Project API Keys -> anon public** (المفتاح العام)

### في متجر الويب ولوحة الإدارة (Next.js):
افتح الملف `web/.env.local` وضع القيم كالتالي:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
NEXT_PUBLIC_STORE_NAME=LUJAIN
NEXT_PUBLIC_DEFAULT_CURRENCY=YER
```

### في تطبيق الهاتف (Flutter):
افتح الملف `mobile/lib/core/supabase_config.dart` وضع نفس القيم:
```dart
static const String supabaseUrl = 'https://your-project-id.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

---

## 6. ميزة التشغيل التلقائي (Zero-Config Fallback)

إذا تم تشغيل المتجر أو التطبيق قبل وضع مفاتيح Supabase، فإن النظام مزود بطبقة بيانات تجريبية واقعية مدمجة بالريال اليمني تعمل فوراً بنسبة 100% دون أي توقف أو أخطاء، وبمجرد وضع مفاتيح Supabase ينتقل النظام تلقائياً للاستعلام من قاعدة بياناتك الحية!
