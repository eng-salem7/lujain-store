-- ====================================================================
-- الملف الشامل لإعداد قاعدة بيانات مشروع «لجين LUJAIN» للأزياء النسائية
-- يشمل: الهيكل (Schema) + سياسات الأمان (RLS) + البيانات الأولية (Seed)
-- انسخ هذا الملف والصقه مباشرة في SQL Editor في لوحة تحكم Supabase واضغط Run
-- ====================================================================

-- تفعيل الامتدادات الضرورية
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. الأنواع والحالات المخصصة (ENUMs)
DO $$ BEGIN
    CREATE TYPE public.user_role AS ENUM (
        'owner', 'store_manager', 'orders_staff', 'inventory_staff', 'accountant', 'customer_service', 'customer'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.order_status AS ENUM (
        'new', 'under_review', 'accepted_preparing', 'ready_for_pickup', 'out_for_delivery', 'completed', 'cancelled', 'returned'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.payment_method AS ENUM (
        'cash_on_delivery', 'store_cash', 'kuraimi', 'floosak', 'jawali', 'onecash', 'bank_transfer'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.payment_status AS ENUM ('pending', 'confirmed', 'failed', 'refunded');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.delivery_type AS ENUM ('home_delivery', 'store_pickup');
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.movement_type AS ENUM (
        'supply', 'sale', 'reservation', 'release_reservation', 'damage', 'adjustment', 'return'
    );
EXCEPTION WHEN duplicate_object THEN null; END $$;

DO $$ BEGIN
    CREATE TYPE public.account_type AS ENUM ('cash_box', 'kuraimi', 'floosak', 'jawali', 'onecash', 'bank');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- 2. الجداول
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

CREATE TABLE IF NOT EXISTS public.delivery_zones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    city_ar VARCHAR(100) NOT NULL,
    city_en VARCHAR(100) NOT NULL,
    area_ar VARCHAR(150),
    area_en VARCHAR(150),
    delivery_fee NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    free_delivery_threshold NUMERIC(12,2),
    estimated_delivery_days VARCHAR(50) DEFAULT '1-2 أيام',
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

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

CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name_ar VARCHAR(255) NOT NULL,
    name_en VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description_ar TEXT,
    description_en TEXT,
    base_price NUMERIC(12,2) NOT NULL,
    discount_price NUMERIC(12,2),
    fabric_details VARCHAR(255),
    is_featured BOOLEAN DEFAULT FALSE NOT NULL,
    is_new BOOLEAN DEFAULT TRUE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    views_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    image_url TEXT NOT NULL,
    alt_text VARCHAR(255),
    is_primary BOOLEAN DEFAULT FALSE NOT NULL,
    sort_order INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES public.products(id) ON DELETE CASCADE NOT NULL,
    sku VARCHAR(100) UNIQUE NOT NULL,
    barcode VARCHAR(100),
    color_name_ar VARCHAR(80) NOT NULL,
    color_name_en VARCHAR(80) NOT NULL,
    color_hex VARCHAR(20) NOT NULL,
    size VARCHAR(40) NOT NULL,
    additional_price NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    cost_price NUMERIC(12,2) DEFAULT 0.00 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE CASCADE UNIQUE NOT NULL,
    quantity INTEGER DEFAULT 0 NOT NULL CHECK (quantity >= 0),
    reserved_quantity INTEGER DEFAULT 0 NOT NULL CHECK (reserved_quantity >= 0),
    low_stock_threshold INTEGER DEFAULT 3 NOT NULL,
    last_restock_date TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE CASCADE NOT NULL,
    movement_type public.movement_type NOT NULL,
    quantity INTEGER NOT NULL,
    previous_quantity INTEGER NOT NULL,
    new_quantity INTEGER NOT NULL,
    reference_id VARCHAR(100),
    reference_type VARCHAR(50),
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(50) UNIQUE NOT NULL,
    discount_type VARCHAR(20) DEFAULT 'percentage' NOT NULL,
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

CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    guest_name VARCHAR(150),
    guest_phone VARCHAR(30),
    guest_email VARCHAR(255),
    delivery_type public.delivery_type DEFAULT 'home_delivery' NOT NULL,
    delivery_zone_id UUID REFERENCES public.delivery_zones(id) ON DELETE SET NULL,
    shipping_address_snapshot JSONB NOT NULL,
    subtotal NUMERIC(14,2) NOT NULL,
    delivery_fee NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    discount_amount NUMERIC(10,2) DEFAULT 0.00 NOT NULL,
    coupon_id UUID REFERENCES public.coupons(id) ON DELETE SET NULL,
    total_amount NUMERIC(14,2) NOT NULL,
    status public.order_status DEFAULT 'new' NOT NULL,
    cancellation_reason TEXT,
    customer_notes TEXT,
    internal_notes TEXT,
    source VARCHAR(30) DEFAULT 'web' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE RESTRICT NOT NULL,
    product_name_snapshot VARCHAR(255) NOT NULL,
    sku_snapshot VARCHAR(100) NOT NULL,
    color_snapshot VARCHAR(80) NOT NULL,
    size_snapshot VARCHAR(40) NOT NULL,
    unit_price_snapshot NUMERIC(12,2) NOT NULL,
    cost_price_snapshot NUMERIC(12,2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    total_line_price NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.order_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    old_status public.order_status,
    new_status public.order_status NOT NULL,
    notes TEXT,
    changed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE NOT NULL,
    payment_method public.payment_method NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    status public.payment_status DEFAULT 'pending' NOT NULL,
    transaction_reference VARCHAR(150),
    proof_image_url TEXT,
    notes TEXT,
    confirmed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

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

CREATE TABLE IF NOT EXISTS public.cash_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES public.cash_accounts(id) ON DELETE RESTRICT NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    amount NUMERIC(14,2) NOT NULL,
    related_account_id UUID REFERENCES public.cash_accounts(id) ON DELETE SET NULL,
    reference_type VARCHAR(50),
    reference_id VARCHAR(100),
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

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

CREATE TABLE IF NOT EXISTS public.purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number VARCHAR(50) UNIQUE NOT NULL,
    supplier_id UUID REFERENCES public.suppliers(id) ON DELETE RESTRICT NOT NULL,
    invoice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    total_cost NUMERIC(14,2) NOT NULL,
    paid_amount NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    status VARCHAR(30) DEFAULT 'received' NOT NULL,
    notes TEXT,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.purchase_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_order_id UUID REFERENCES public.purchase_orders(id) ON DELETE CASCADE NOT NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE RESTRICT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_cost NUMERIC(12,2) NOT NULL,
    total_cost NUMERIC(14,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category VARCHAR(80) NOT NULL,
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

CREATE TABLE IF NOT EXISTS public.returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_number VARCHAR(50) UNIQUE NOT NULL,
    order_id UUID REFERENCES public.orders(id) ON DELETE RESTRICT NOT NULL,
    customer_id UUID REFERENCES public.customers(id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    status VARCHAR(30) DEFAULT 'requested' NOT NULL,
    total_refund_amount NUMERIC(14,2) DEFAULT 0.00 NOT NULL,
    inspected_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

CREATE TABLE IF NOT EXISTS public.return_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    return_id UUID REFERENCES public.returns(id) ON DELETE CASCADE NOT NULL,
    order_item_id UUID REFERENCES public.order_items(id) ON DELETE RESTRICT NOT NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE RESTRICT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    return_reason TEXT,
    item_condition VARCHAR(30) DEFAULT 'resellable',
    restocked_quantity INTEGER DEFAULT 0 NOT NULL,
    refund_amount NUMERIC(12,2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

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

CREATE TABLE IF NOT EXISTS public.loyalty_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID REFERENCES public.customers(id) ON DELETE CASCADE NOT NULL,
    points INTEGER NOT NULL,
    transaction_type VARCHAR(30) NOT NULL,
    order_id UUID REFERENCES public.orders(id) ON DELETE SET NULL,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

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

-- 3. الدوال والمحفزات
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

-- 4. تفعيل سياسات الأمان RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_variants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.delivery_zones ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cash_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read categories" ON public.categories FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read products" ON public.products FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read images" ON public.product_images FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read variants" ON public.product_variants FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read inventory" ON public.inventory FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read delivery zones" ON public.delivery_zones FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read coupons" ON public.coupons FOR SELECT USING (TRUE);
CREATE POLICY "Allow public read reviews" ON public.reviews FOR SELECT USING (TRUE);
CREATE POLICY "Allow insert orders" ON public.orders FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow read orders" ON public.orders FOR SELECT USING (TRUE);
CREATE POLICY "Allow update orders" ON public.orders FOR UPDATE USING (TRUE);
CREATE POLICY "Allow insert order items" ON public.order_items FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow read order items" ON public.order_items FOR SELECT USING (TRUE);
CREATE POLICY "Allow insert payments" ON public.payments FOR INSERT WITH CHECK (TRUE);
CREATE POLICY "Allow read payments" ON public.payments FOR SELECT USING (TRUE);
CREATE POLICY "Allow read cash accounts" ON public.cash_accounts FOR SELECT USING (TRUE);
CREATE POLICY "Allow read customers" ON public.customers FOR SELECT USING (TRUE);
CREATE POLICY "Allow insert customers" ON public.customers FOR INSERT WITH CHECK (TRUE);

-- 5. إدراج البيانات الأولية
INSERT INTO public.delivery_zones (id, city_ar, city_en, area_ar, area_en, delivery_fee, free_delivery_threshold, estimated_delivery_days, is_active)
VALUES
    ('d1111111-1111-1111-1111-111111111111', 'صنعاء', 'Sanaa', 'كافة أحياء أمانة العاصمة', 'Capital Area', 2000.00, 45000.00, 'نفس اليوم أو خلال 24 ساعة', TRUE),
    ('d2222222-2222-2222-2222-222222222222', 'عدن', 'Aden', 'خورمكسر، المعلا، كريتر، الشيخ عثمان', 'Greater Aden', 3500.00, 60000.00, '2-3 أيام', TRUE),
    ('d3333333-3333-3333-3333-333333333333', 'تعز', 'Taiz', 'وسط المدينة والحوبان', 'Taiz City', 3500.00, 60000.00, '2-3 أيام', TRUE),
    ('d4444444-4444-4444-4444-444444444444', 'حضرموت', 'Hadramout', 'المكلا وسيئون', 'Mukalla & Seiyun', 4000.00, 70000.00, '3-4 أيام', TRUE),
    ('d5555555-5555-5555-5555-555555555555', 'إب', 'Ibb', 'مركز المحافظة والقاعدة', 'Ibb City', 3000.00, 50000.00, '1-2 أيام', TRUE),
    ('d6666666-6666-6666-6666-666666666666', 'استلام من المتجر', 'Store Pickup', 'فرع صنعاء - حدة، جوار مركز الكميم', 'Main Branch', 0.00, 0.00, 'جاهز خلال ساعتين', TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.cash_accounts (id, name_ar, name_en, account_type, account_number, current_balance, currency, is_active)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'صندوق المتجر الكاش', 'Store Cash Register', 'cash_box', 'CASH-MAIN-01', 345000.00, 'YER', TRUE),
    ('c2222222-2222-2222-2222-222222222222', 'حساب الكريمي (حاسب)', 'Kuraimi Bank Haseb', 'kuraimi', '30248911', 890000.00, 'YER', TRUE),
    ('c3333333-3333-3333-3333-333333333333', 'محفظة فلوسك (كريمي)', 'Floosak Wallet', 'floosak', '770123456', 215000.00, 'YER', TRUE),
    ('c4444444-4444-4444-4444-444444444444', 'محفظة جوالي (كاك بنك)', 'Jawali Wallet', 'jawali', '777987654', 160000.00, 'YER', TRUE),
    ('c5555555-5555-5555-5555-555555555555', 'محفظة ون كاش', 'OneCash Wallet', 'onecash', '771555666', 95000.00, 'YER', TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.categories (id, name_ar, name_en, slug, description_ar, description_en, image_url, sort_order, is_active)
VALUES
    ('ca111111-1111-1111-1111-111111111111', 'فساتين سهرة ومناسبات', 'Evening Dresses', 'evening-dresses', 'فساتين أنيقة مصممة لأرقى المناسبات والسهرات بلمسات كلاسيكية وفخمة', 'Luxury evening and event dresses for special occasions', 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80', 1, TRUE),
    ('ca222222-2222-2222-2222-222222222222', 'جلابيات وعبايات راقية', 'Jalabiyas & Abayas', 'jalabiyas-abayas', 'أحدث تصاميم الجلابيات المطرزة والعبايات الخليجية الراقية', 'Modern luxury jalabiyas and embroidered abayas', 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80', 2, TRUE),
    ('ca333333-3333-3333-3333-333333333333', 'أطقم نسائية رسمية وكاجوال', 'Women Sets & Suits', 'women-sets', 'أطقم قطعتين وثلاث قطع مريحة وعملية تناسب العمل والإطلالات اليومية', 'Two and three-piece elegant sets for work and daily chic', 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80', 3, TRUE),
    ('ca444444-4444-4444-4444-444444444444', 'بلايز وقمصان أنيقة', 'Blouses & Shirts', 'blouses-shirts', 'بلايز حريرية وقطنية بتطاريز ناعمة وأكمام مميزة', 'Silk and cotton blouses with delicate details', 'https://images.unsplash.com/photo-1608234808654-2a8875faa7fd?w=800&q=80', 4, TRUE),
    ('ca555555-5555-5555-5555-555555555555', 'تنانير وبناطيل', 'Skirts & Pants', 'skirts-pants', 'قصات راقية وتنانير بليسيه وبناطيل قماشية واسعة', 'Pleated skirts and wide-leg trousers', 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&q=80', 5, TRUE),
    ('ca666666-6666-6666-6666-666666666666', 'شيل وإكسسوارات', 'Scarves & Accessories', 'scarves-accessories', 'طرح وشيل حريرية وأحزمة ومجوهرات مكملة للأناقة', 'Luxury silk scarves, belts, and statement accessories', 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=800&q=80', 6, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.products (id, category_id, name_ar, name_en, slug, description_ar, description_en, base_price, discount_price, fabric_details, is_featured, is_new, is_active)
VALUES
    (
        'p1111111-1111-1111-1111-111111111111',
        'ca111111-1111-1111-1111-111111111111',
        'فستان لجين المخملي الفاخر بتطريز ذهبي',
        'Lujain Velvet Luxury Evening Gown',
        'lujain-velvet-luxury-evening-gown',
        'فستان سهرة استثنائي مصمم من المخمل الكوري الفاخر مع لمسات تطريز يدوي بخيوط ذهبية هادئة وقصة تبرز القوام برقي وأناقة، مبطن بالكامل بالحرير الناعم.',
        'Exclusive evening gown crafted in premium Korean velvet with subtle gold metallic hand embroidery and fully lined in soft silk.',
        48000.00,
        42000.00,
        'مخمل كوري فاخر مبطن بحرير ساتان',
        TRUE,
        TRUE,
        TRUE
    ),
    (
        'p2222222-2222-2222-2222-222222222222',
        'ca222222-2222-2222-2222-222222222222',
        'جلابية ريم الرمضانية باللون العاجي والبيج',
        'Reem Luxury Embroidered Cream Jalabiya',
        'reem-luxury-embroidered-cream-jalabiya',
        'جلابية ملكية باللون العاجي المميز تجمع بين الأصالة والعصرية مع نقوش تطريز عربية متقنة وأكمام كلوش انسيابية خفيفة وباردة.',
        'Royal ivory jalabiya blending classic Arabian motifs with modern cut, featuring bell sleeves and delicate craftsmanship.',
        32000.00,
        28500.00,
        'كتان طبيعي مخلوط بالحرير البارد',
        TRUE,
        TRUE,
        TRUE
    ),
    (
        'p3333333-3333-3333-3333-333333333333',
        'ca333333-3333-3333-3333-333333333333',
        'طقم كلاسيك راقي (بليزر مع بنطال قماش واسع)',
        'Classic Elegant Two-Piece Blazer Suit',
        'classic-elegant-two-piece-blazer-suit',
        'طقم نسائي متميز يتكون من بليزر رسمي بأزرار مزدوجة مغطاة بنفس القماش مع بنطال واسع مريح، يمنحك حضوراً رسمياً واثقاً في الاجتماعات والمناسبات.',
        'Two-piece chic suit with double-breasted structured blazer and flowing wide-leg trousers.',
        39000.00,
        34000.00,
        'كريب تركي عالي الجودة مقاوم للتجعد',
        TRUE,
        FALSE,
        TRUE
    )
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.product_images (product_id, image_url, alt_text, is_primary, sort_order)
VALUES
    ('p1111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&q=80', 'فستان مخملي فاخر - الواجهة', TRUE, 1),
    ('p2222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80', 'جلابية ريم العاجية', TRUE, 1),
    ('p3333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80', 'طقم بليزر بيج كلاسيك', TRUE, 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.product_variants (id, product_id, sku, barcode, color_name_ar, color_name_en, color_hex, size, additional_price, cost_price, is_active)
VALUES
    ('v1011111-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 'LUJ-DRS-01-NAVY-M', '629104000101', 'كحلي ملكي', 'Royal Navy', '#1A2A44', 'M', 0.00, 24000.00, TRUE),
    ('v1022222-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 'LUJ-DRS-01-BUR-L', '629104000104', 'عنابي دافئ', 'Burgundy', '#6B1D2F', 'L', 0.00, 24000.00, TRUE),
    ('v2011111-2222-2222-2222-222222222222', 'p2222222-2222-2222-2222-222222222222', 'LUJ-JAL-02-CRM-FREE', '629104000201', 'عاجي كريمي', 'Ivory Cream', '#FAF5EE', 'Free Size', 0.00, 16000.00, TRUE),
    ('v3011111-3333-3333-3333-333333333333', 'p3333333-3333-3333-3333-333333333333', 'LUJ-SET-03-BGE-M', '629104000302', 'بيج كابتشينو', 'Beige Cappuccino', '#C8B29B', 'M', 0.00, 19000.00, TRUE)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.inventory (variant_id, quantity, reserved_quantity, low_stock_threshold, last_restock_date)
VALUES
    ('v1011111-1111-1111-1111-111111111111', 8, 1, 2, NOW()),
    ('v1022222-1111-1111-1111-111111111111', 5, 0, 2, NOW()),
    ('v2011111-2222-2222-2222-222222222222', 15, 2, 4, NOW()),
    ('v3011111-3333-3333-3333-333333333333', 9, 1, 2, NOW())
ON CONFLICT (variant_id) DO NOTHING;

INSERT INTO public.coupons (id, code, discount_type, discount_value, min_order_value, max_discount_amount, valid_from, valid_until, usage_limit, usage_count, is_active)
VALUES
    ('cp111111-1111-1111-1111-111111111111', 'LUJAIN10', 'percentage', 10.00, 20000.00, 8000.00, NOW() - INTERVAL '5 days', NOW() + INTERVAL '60 days', 500, 12, TRUE),
    ('cp222222-2222-2222-2222-222222222222', 'WELCOME', 'fixed', 3000.00, 25000.00, 3000.00, NOW() - INTERVAL '10 days', NOW() + INTERVAL '90 days', 1000, 35, TRUE)
ON CONFLICT (id) DO NOTHING;
