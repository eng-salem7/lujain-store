-- ====================================================================
-- مشروع لجين LUJAIN للأزياء النسائية
-- مخطط قاعدة البيانات المتكامل على Supabase PostgreSQL
-- المتجر الإلكتروني • تطبيق العملاء • تطبيق الإدارة
-- ====================================================================

-- 1. تفعيل الامتدادات الضرورية
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 2. الأنواع والحالات المخصصة (Custom ENUM Types)
DO $$ BEGIN
    CREATE TYPE public.user_role AS ENUM (
        'owner', 
        'store_manager', 
        'orders_staff', 
        'inventory_staff', 
        'accountant', 
        'customer_service', 
        'customer'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.order_status AS ENUM (
        'new',                  -- طلب جديد
        'under_review',        -- قيد المراجعة
        'accepted_preparing',  -- مقبول وقيد التجهيز (حجز المخزون)
        'ready_for_pickup',    -- جاهز للتسليم
        'out_for_delivery',    -- خرج للتوصيل
        'completed',           -- مكتمل (تأكيد التسليم وتسجيل الإيراد وخصم المخزون)
        'cancelled',           -- مرفوض / ملغي (تحرير حجز المخزون)
        'returned'             -- مرتجع / مستبدل
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.payment_method AS ENUM (
        'cash_on_delivery',    -- نقداً عند الاستلام
        'store_cash',          -- نقداً بالمتجر
        'kuraimi',             -- بنك / محفظة الكريمي
        'floosak',             -- محفظة فلوسك
        'jawali',              -- محفظة جوالي
        'onecash',             -- محفظة ون كاش
        'bank_transfer'        -- تحويل بنكي
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.payment_status AS ENUM (
        'pending',             -- قيد الانتظار
        'confirmed',           -- مؤكد ومستلم
        'failed',              -- فشل
        'refunded'             -- مسترد
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.delivery_type AS ENUM (
        'home_delivery',       -- توصيل للمنزل
        'store_pickup'         -- استلام من المتجر
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.movement_type AS ENUM (
        'supply',              -- توريد جديد
        'sale',                -- بيع نهائي
        'reservation',         -- حجز لطلب
        'release_reservation', -- تحرير حجز ملغي
        'damage',              -- إتلاف أو تالف
        'adjustment',          -- تسوية جرد
        'return'               -- إرجاع للمخزون
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.account_type AS ENUM (
        'cash_box',            -- صندوق النقدية
        'kuraimi',             -- حساب الكريمي
        'floosak',             -- محفظة فلوسك
        'jawali',              -- محفظة جوالي
        'onecash',             -- محفظة ون كاش
        'bank'                 -- حساب بنكي آخر
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ====================================================================
-- 3. الجداول الأساسية
-- ====================================================================

-- جدول الملفات الشخصية المرتبطة بمصادقة Supabase
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30),
    email VARCHAR(255),
    role public.user_role DEFAULT 'customer' NOT NULL,
    avatar_url TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول العملاء
CREATE TABLE IF NOT EXISTS public.customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    profile_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(255),
    notes TEXT,
    loyalty_points INTEGER DEFAULT 0 NOT NULL,
    total_spent NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    orders_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول مناطق التوصيل والرسوم
CREATE TABLE IF NOT EXISTS public.delivery_zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city_ar VARCHAR(100) NOT NULL,
    city_en VARCHAR(100) NOT NULL,
    area_ar VARCHAR(150),
    area_en VARCHAR(150),
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0.00, -- بالريال اليمني YER
    free_delivery_threshold NUMERIC(12,2),             -- حد الشحن المجاني
    estimated_delivery_days VARCHAR(50) DEFAULT '1-2 أيام',
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول عناوين العملاء
CREATE TABLE IF NOT EXISTS public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE NOT NULL,
    delivery_zone_id UUID REFERENCES public.delivery_zones(id) ON DELETE SET NULL,
    title VARCHAR(100) DEFAULT 'المنزل',
    city VARCHAR(100) NOT NULL,
    area VARCHAR(150) NOT NULL,
    street_details TEXT NOT NULL,
    nearest_landmark VARCHAR(255),
    recipient_name VARCHAR(150),
    recipient_phone VARCHAR(30),
    is_default BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول الأقسام (Categories) - يدعم الشجرة والتسلسل الهرمي
CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name_ar VARCHAR(150) NOT NULL,
    name_en VARCHAR(150) NOT NULL,
    slug VARCHAR(150) UNIQUE NOT NULL,
    description_ar TEXT,
    description_en TEXT,
    image_url TEXT,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول المنتجات (Products)
CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description_ar TEXT,
    description_en TEXT,
    base_price NUMERIC(12,2) NOT NULL, -- السعر الأساسي بالريال اليمني
    discount_price NUMERIC(12,2),      -- سعر التخفيض إن وجد
    fabric_details VARCHAR(255),       -- نوع القماش وتفاصيله
    is_featured BOOLEAN DEFAULT FALSE NOT NULL,
    is_new BOOLEAN DEFAULT TRUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    views_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول صور المنتج المتعددة
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول متغيرات المنتج (الألوان، المقاسات، SKU)
CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    barcode VARCHAR(100),
    color_name_ar VARCHAR(80) NOT NULL,
    color_name_en VARCHAR(80) NOT NULL,
    color_hex VARCHAR(20) NOT NULL,    -- كود اللون للتصميم مثلا #3D2B1F
    size VARCHAR(40) NOT NULL,         -- S, M, L, XL, XXL, Free Size
    additional_price NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    cost_price NUMERIC(12,2) DEFAULT 0.00 NOT NULL, -- تكلفة الشراء لاحتساب الأرباح بدقة
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول رصيد المخزون الحالي (Inventory)
CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE CASCADE UNIQUE NOT NULL,
    quantity INTEGER DEFAULT 0 NOT NULL CHECK (quantity >= 0),
    reserved_quantity INTEGER DEFAULT 0 NOT NULL CHECK (reserved_quantity >= 0),
    low_stock_threshold INTEGER DEFAULT 3 NOT NULL,
    last_restock_date TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول حركات المخزون (سجل غير قابل للتعديل لتتبع أي تغيير)
CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE CASCADE NOT NULL,
    movement_type public.movement_type NOT NULL,
    quantity INTEGER NOT NULL,          -- القيمة موجبة للزيادة وسالبة للنقص
    previous_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    reference_id VARCHAR(100),          -- رقم الطلب أو فاتورة الشراء
    reference_type VARCHAR(50),        -- 'order', 'purchase', 'manual_adjustment'
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول الكوبونات والعروض
CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(20) DEFAULT 'percentage' NOT NULL, -- 'percentage' أو 'fixed'
    discount_value NUMERIC(10,2) NOT NULL,
    min_order_value NUMERIC(12,2) DEFAULT 0.00,
    max_discount_amount NUMERIC(10,2),
    valid_from TIMESTAMPTZ NOT NULL,
    valid_until TIMESTAMPTZ NOT NULL,
    usage_limit INTEGER,
    usage_count INTEGER DEFAULT 0 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول رأس الطلب (Orders)
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL, -- اختياري لتمكين طلبات الزوار
    guest_name VARCHAR(150),
    guest_phone VARCHAR(30),
    guest_email VARCHAR(255),
    delivery_type public.delivery_type DEFAULT 'home_delivery' NOT NULL,
    delivery_zone_id UUID REFERENCES public.delivery_zones(id) ON DELETE SET NULL,
    shipping_address_snapshot JSONB NOT NULL, -- لقطة تفصيلية لعنوان التوصيل لحمايته من التغيير
    subtotal NUMERIC(14,2) NOT NULL,
    delivery_fee NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    discount_amount NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    coupon_id UUID REFERENCES public.coupons(id) ON DELETE SET NULL,
    total_amount NUMERIC(14,2) NOT NULL,     -- الإجمالي النهائي بالريال اليمني
    status public.order_status DEFAULT 'new' NOT NULL,
    cancellation_reason TEXT,
    customer_notes TEXT,
    internal_notes TEXT,
    source VARCHAR(30) DEFAULT 'web' NOT NULL, -- 'web', 'android', 'ios'
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول تفاصيل أسطر الطلب (Order Items)
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE RESTRICT NOT NULL,
    -- حفظ لقطات ثابتة لبيانات المنتج وقت الشراء
    product_name_snapshot VARCHAR(255) NOT NULL,
    sku_snapshot VARCHAR(100) NOT NULL,
    color_snapshot VARCHAR(80) NOT NULL,
    size_snapshot VARCHAR(40) NOT NULL,
    unit_price_snapshot NUMERIC(12,2) NOT NULL,
    cost_price_snapshot NUMERIC(12,2) NOT NULL, -- لحساب الربح بدقة حتى لو تغيرت التكلفة مستقبلاً
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_line_price NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول سجل حالات الطلب (Order Status History)
CREATE TABLE IF NOT EXISTS public.order_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    old_status public.order_status,
    new_status public.order_status NOT NULL,
    notes TEXT,
    changed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول المدفوعات (Payments)
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    payment_method public.payment_method NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    status public.payment_status DEFAULT 'pending' NOT NULL,
    transaction_reference VARCHAR(150),       -- رقم الحوالة أو المرجع
    proof_image_url TEXT,                     -- صورة سند أو إشعار التحويل
    notes TEXT,
    confirmed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول الحسابات النقدية والمحافظ (Cash Accounts)
CREATE TABLE IF NOT EXISTS public.cash_accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_ar VARCHAR(100) NOT NULL,
    name_en VARCHAR(100) NOT NULL,
    account_type public.account_type NOT NULL,
    account_number VARCHAR(100),
    current_balance NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    currency VARCHAR(10) DEFAULT 'YER' NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول حركات الصندوق والمحافظ (Cash Transactions)
CREATE TABLE IF NOT EXISTS public.cash_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES public.cash_accounts(id) ON DELETE RESTRICT NOT NULL,
    transaction_type VARCHAR(50) NOT NULL, -- 'order_revenue', 'expense_payment', 'purchase_payment', 'deposit', 'withdrawal', 'transfer'
    amount NUMERIC(14,2) NOT NULL,         -- موجب للإيداع وسالب للصرف
    related_account_id UUID REFERENCES public.cash_accounts(id) ON DELETE SET NULL,
    reference_type VARCHAR(50),            -- 'order', 'expense', 'purchase_order'
    reference_id VARCHAR(100),
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول الموردين (Suppliers)
CREATE TABLE IF NOT EXISTS public.suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(150) NOT NULL,
    company_name VARCHAR(200),
    phone VARCHAR(30) NOT NULL,
    email VARCHAR(255),
    address TEXT,
    balance_due NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول فواتير المشتريات (Purchase Orders)
CREATE TABLE IF NOT EXISTS public.purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number VARCHAR(50) UNIQUE NOT NULL,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE RESTRICT NOT NULL,
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_cost NUMERIC(14,2) NOT NULL,
    paid_amount NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    status VARCHAR(30) DEFAULT 'received' NOT NULL, -- 'draft', 'ordered', 'received', 'cancelled'
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول تفاصيل أصناف الشراء (Purchase Items)
CREATE TABLE IF NOT EXISTS public.purchase_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_order_id UUID REFERENCES public.purchase_orders(id) ON DELETE CASCADE NOT NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE RESTRICT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(12,2) NOT NULL,
    total_cost NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول المصروفات التشغيلية (Expenses)
CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(80) NOT NULL, -- 'rent', 'salaries', 'marketing', 'packaging', 'utilities', 'other'
    title VARCHAR(200) NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    payment_method public.payment_method DEFAULT 'cash_on_delivery' NOT NULL,
    account_id UUID REFERENCES public.cash_accounts(id) ON DELETE SET NULL,
    receipt_image_url TEXT,
    expense_date DATE DEFAULT CURRENT_DATE NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول المرتجعات والاستبدال (Returns)
CREATE TABLE IF NOT EXISTS public.returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_number VARCHAR(50) UNIQUE NOT NULL,
    order_id UUID REFERENCES public.orders(id) ON DELETE RESTRICT NOT NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'requested' NOT NULL, -- 'requested', 'inspected', 'approved', 'rejected', 'refunded'
    total_refund_amount NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    inspected_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول أصناف المرتجعات (Return Items)
CREATE TABLE IF NOT EXISTS public.return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES public.returns(id) ON DELETE CASCADE NOT NULL,
    order_item_id UUID REFERENCES public.order_items(id) ON DELETE RESTRICT NOT NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE RESTRICT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    return_reason TEXT,
    item_condition VARCHAR(30) DEFAULT 'resellable', -- 'resellable', 'damaged'
    restocked_quantity INTEGER DEFAULT 0 NOT NULL,
    refund_amount NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول التقييمات والآراء (Reviews)
CREATE TABLE IF NOT EXISTS public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    reviewer_name VARCHAR(150),
    is_approved BOOLEAN DEFAULT FALSE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول حركة نقاط الولاء (Loyalty Transactions)
CREATE TABLE IF NOT EXISTS public.loyalty_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE NOT NULL,
    points INTEGER NOT NULL, -- موجب عند الاكتساب، سالب عند الاستبدال
    transaction_type VARCHAR(30) NOT NULL, -- 'earned', 'redeemed', 'adjusted'
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- جدول سجل التدقيق الأمني (Audit Logs)
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    entity_name VARCHAR(100) NOT NULL,
    entity_id VARCHAR(100),
    old_values JSONB,
    new_values JSONB,
    ip_address VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ====================================================================
-- 4. الدوال والإجراءات التلقائية (Triggers & Functions)
-- ====================================================================

-- دالة توليد رقم الطلب تلقائياً (مثال: LUJ-2026-1001)
CREATE OR REPLACE FUNCTION public.generate_order_number()
RETURNS TRIGGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(SUBSTRING(order_number FROM '[0-9]+$')::INTEGER), 1000) + 1
    INTO next_num
    FROM public.orders;

    NEW.order_number := 'LUJ-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(next_num::TEXT, 5, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_generate_order_number ON public.orders;
CREATE TRIGGER trigger_generate_order_number
BEFORE INSERT ON public.orders
FOR EACH ROW
WHEN (NEW.order_number IS NULL OR NEW.order_number = '')
EXECUTE FUNCTION public.generate_order_number();

-- دالة تسجيل تغيير حالة الطلب في السجل تلقائياً
CREATE OR REPLACE FUNCTION public.log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') OR (OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO public.order_status_history (
            order_id,
            old_status,
            new_status,
            notes
        ) VALUES (
            NEW.id,
            CASE WHEN TG_OP = 'INSERT' THEN NULL ELSE OLD.status END,
            NEW.status,
            'تم التحديث تلقائياً'
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_log_order_status ON public.orders;
CREATE TRIGGER trigger_log_order_status
AFTER INSERT OR UPDATE OF status ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.log_order_status_change();

-- دالة حجز المخزون الآمن عند قبول الطلب
CREATE OR REPLACE FUNCTION public.reserve_stock_for_order(p_order_id UUID)
RETURNS VOID AS $$
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT variant_id, quantity FROM public.order_items WHERE order_id = p_order_id) LOOP
        -- التحقق من توفر الكمية الكافية
        IF (SELECT quantity - reserved_quantity FROM public.inventory WHERE variant_id = r.variant_id) < r.quantity THEN
            RAISE EXCEPTION 'المخزون غير كافٍ للمتغير %', r.variant_id;
        END IF;

        -- زيادة الكمية المحجوزة
        UPDATE public.inventory
        SET reserved_quantity = reserved_quantity + r.quantity,
            updated_at = NOW()
        WHERE variant_id = r.variant_id;

        -- تسجيل حركة المخزون
        INSERT INTO public.inventory_movements (
            variant_id,
            movement_type,
            quantity,
            previous_quantity,
            new_quantity,
            reference_id,
            reference_type,
            notes
        )
        SELECT 
            r.variant_id,
            'reservation',
            r.quantity,
            quantity,
            quantity,
            p_order_id::TEXT,
            'order',
            'حجز كمية للطلب المعتمد'
        FROM public.inventory WHERE variant_id = r.variant_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- دالة إتمام الطلب والخصم النهائي للمخزون
CREATE OR REPLACE FUNCTION public.complete_order(p_order_id UUID)
RETURNS VOID AS $$
DECLARE
    r RECORD;
    prev_qty INTEGER;
BEGIN
    FOR r IN (SELECT variant_id, quantity FROM public.order_items WHERE order_id = p_order_id) LOOP
        SELECT quantity INTO prev_qty FROM public.inventory WHERE variant_id = r.variant_id;

        -- خصم من الإجمالي ومن المحجوز
        UPDATE public.inventory
        SET quantity = quantity - r.quantity,
            reserved_quantity = GREATEST(0, reserved_quantity - r.quantity),
            updated_at = NOW()
        WHERE variant_id = r.variant_id;

        -- تسجيل حركة البيع النهائي
        INSERT INTO public.inventory_movements (
            variant_id,
            movement_type,
            quantity,
            previous_quantity,
            new_quantity,
            reference_id,
            reference_type,
            notes
        ) VALUES (
            r.variant_id,
            'sale',
            -r.quantity,
            prev_qty,
            prev_qty - r.quantity,
            p_order_id::TEXT,
            'order',
            'خصم نهائي للمخزون لاكتمال الطلب'
        );
    END LOOP;

    -- تحديث حالة الطلب
    UPDATE public.orders SET status = 'completed', updated_at = NOW() WHERE id = p_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
