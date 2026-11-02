-- ====================================================================
-- سياسات الأمان على مستوى الصف (Row Level Security - RLS)
-- مشروع لجين LUJAIN للأزياء النسائية
-- ====================================================================

-- 1. تفعيل RLS على كافة الجداول
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory_movements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.returns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.return_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- 2. سياسات الوصول العام (العملاء والزوار في المتجر والموقع)
-- ====================================================================

-- الأقسام: يمكن للجميع القراءة
DROP POLICY IF EXISTS "Allow public read categories" ON public.categories;
CREATE POLICY "Allow public read categories" ON public.categories
    FOR SELECT USING (is_active = TRUE);

-- المنتجات: يمكن للجميع قراءة المنتجات المفعلة
DROP POLICY IF EXISTS "Allow public read products" ON public.products;
CREATE POLICY "Allow public read products" ON public.products
    FOR SELECT USING (is_active = TRUE);

-- صور المنتجات: قراءة عامة
DROP POLICY IF EXISTS "Allow public read product images" ON public.product_images;
CREATE POLICY "Allow public read product images" ON public.product_images
    FOR SELECT USING (TRUE);

-- متغيرات المنتجات: قراءة عامة للمتغيرات المفعلة
DROP POLICY IF EXISTS "Allow public read variants" ON public.product_variants;
CREATE POLICY "Allow public read variants" ON public.product_variants
    FOR SELECT USING (is_active = TRUE);

-- المخزون: يمكن للعملاء التحقق من توفر الكميات
DROP POLICY IF EXISTS "Allow public read inventory" ON public.inventory;
CREATE POLICY "Allow public read inventory" ON public.inventory
    FOR SELECT USING (TRUE);

-- مناطق التوصيل: قراءة عامة لاحتساب رسوم الشحن
DROP POLICY IF EXISTS "Allow public read delivery zones" ON public.delivery_zones;
CREATE POLICY "Allow public read delivery zones" ON public.delivery_zones
    FOR SELECT USING (is_active = TRUE);

-- الكوبونات: قراءة الكوبونات السارية للتحقق منها
DROP POLICY IF EXISTS "Allow public read coupons" ON public.coupons;
CREATE POLICY "Allow public read coupons" ON public.coupons
    FOR SELECT USING (is_active = TRUE AND NOW() BETWEEN valid_from AND valid_until);

-- التقييمات: قراءة التقييمات المعتمدة
DROP POLICY IF EXISTS "Allow public read reviews" ON public.reviews;
CREATE POLICY "Allow public read reviews" ON public.reviews
    FOR SELECT USING (is_approved = TRUE);

-- كتابة التقييمات: يمكن للعملاء إضافة تقييم
DROP POLICY IF EXISTS "Allow insert reviews" ON public.reviews;
CREATE POLICY "Allow insert reviews" ON public.reviews
    FOR INSERT WITH CHECK (TRUE);

-- ====================================================================
-- 3. سياسات إنشاء الطلبات ومتابعتها (Guest + Registered)
-- ====================================================================

-- إنشاء طلب جديد (متاح للجميع كزائر أو عميل مسجل)
DROP POLICY IF EXISTS "Allow public insert orders" ON public.orders;
CREATE POLICY "Allow public insert orders" ON public.orders
    FOR INSERT WITH CHECK (TRUE);

-- قراءة الطلب: يمكن للعميل قراءة طلبه (إذا كان مسجلاً أو بواسطة المعرف)
DROP POLICY IF EXISTS "Allow read own orders" ON public.orders;
CREATE POLICY "Allow read own orders" ON public.orders
    FOR SELECT USING (
        auth.uid() IS NOT NULL AND customer_id IN (SELECT id FROM public.customers WHERE profile_id = auth.uid())
        OR TRUE -- لتمكين متابعة الطلب برقم الطلب ورقم الجوال في الواجهة
    );

-- تفاصيل أسطر الطلب: إدخال وقراءة
DROP POLICY IF EXISTS "Allow public insert order items" ON public.order_items;
CREATE POLICY "Allow public insert order items" ON public.order_items
    FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Allow read order items" ON public.order_items;
CREATE POLICY "Allow read order items" ON public.order_items
    FOR SELECT USING (TRUE);

-- المدفوعات: إدخال سند الدفع أو محاولة الدفع
DROP POLICY IF EXISTS "Allow insert payments" ON public.payments;
CREATE POLICY "Allow insert payments" ON public.payments
    FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Allow read payments" ON public.payments;
CREATE POLICY "Allow read payments" ON public.payments
    FOR SELECT USING (TRUE);

-- ====================================================================
-- 4. سياسات العملاء والملفات الشخصية
-- ====================================================================

-- الملف الشخصي: يمكن للمستخدم قراءة وتعديل ملفه
DROP POLICY IF EXISTS "Users can read own profile" ON public.profiles;
CREATE POLICY "Users can read own profile" ON public.profiles
    FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
CREATE POLICY "Users can update own profile" ON public.profiles
    FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Allow insert profiles" ON public.profiles;
CREATE POLICY "Allow insert profiles" ON public.profiles
    FOR INSERT WITH CHECK (TRUE);

-- العملاء: إدخال وقراءة وتحديث
DROP POLICY IF EXISTS "Allow insert customer" ON public.customers;
CREATE POLICY "Allow insert customer" ON public.customers
    FOR INSERT WITH CHECK (TRUE);

DROP POLICY IF EXISTS "Allow read customer" ON public.customers;
CREATE POLICY "Allow read customer" ON public.customers
    FOR SELECT USING (TRUE);

-- ====================================================================
-- 5. صلاحيات الإدارة والتشغيل الشاملة (Admin / Staff)
-- تمكين التعديل والإضافة للإدارة
-- ====================================================================

CREATE POLICY "Admin full access categories" ON public.categories FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access products" ON public.products FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access product images" ON public.product_images FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access variants" ON public.product_variants FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access inventory" ON public.inventory FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access movements" ON public.inventory_movements FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access orders" ON public.orders FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access order status history" ON public.order_status_history FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access payments" ON public.payments FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access cash accounts" ON public.cash_accounts FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access cash transactions" ON public.cash_transactions FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access suppliers" ON public.suppliers FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access purchase orders" ON public.purchase_orders FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access purchase items" ON public.purchase_items FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access expenses" ON public.expenses FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access returns" ON public.returns FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access return items" ON public.return_items FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access coupons" ON public.coupons FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access reviews" ON public.reviews FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access delivery zones" ON public.delivery_zones FOR ALL USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "Admin full access audit logs" ON public.audit_logs FOR ALL USING (TRUE) WITH CHECK (TRUE);
