-- ====================================================================
-- البيانات الأولية والتجريبية (Seed Data)
-- متجر لجين LUJAIN للأزياء النسائية
-- العملة الأساسية: الريال اليمني (YER)
-- ====================================================================

-- 1. مناطق التوصيل في اليمن
INSERT INTO public.delivery_zones (id, city_ar, city_en, area_ar, area_en, delivery_fee, free_delivery_threshold, estimated_delivery_days, is_active)
VALUES
    ('d1111111-1111-1111-1111-111111111111', 'صنعاء', 'Sanaa', 'كافة أحياء أمانة العاصمة', 'Capital Area', 2000.00, 45000.00, 'نفس اليوم أو خلال 24 ساعة', TRUE),
    ('d2222222-2222-2222-2222-222222222222', 'عدن', 'Aden', 'خورمكسر، المعلا، كريتر، الشيخ عثمان', 'Greater Aden', 3500.00, 60000.00, '2-3 أيام', TRUE),
    ('d3333333-3333-3333-3333-333333333333', 'تعز', 'Taiz', 'وسط المدينة والحوبان', 'Taiz City', 3500.00, 60000.00, '2-3 أيام', TRUE),
    ('d4444444-4444-4444-4444-444444444444', 'حضرموت', 'Hadramout', 'المكلا وسيئون', 'Mukalla & Seiyun', 4000.00, 70000.00, '3-4 أيام', TRUE),
    ('d5555555-5555-5555-5555-555555555555', 'إب', 'Ibb', 'مركز المحافظة والقاعدة', 'Ibb City', 3000.00, 50000.00, '1-2 أيام', TRUE),
    ('d6666666-6666-6666-6666-666666666666', 'استلام من المتجر', 'Store Pickup', 'فرع صنعاء - حدة، جوار مركز الكميم', 'Main Branch', 0.00, 0.00, 'جاهز خلال ساعتين', TRUE)
ON CONFLICT (id) DO NOTHING;

-- 2. الصناديق النقدية والمحافظ الإلكترونية
INSERT INTO public.cash_accounts (id, name_ar, name_en, account_type, account_number, current_balance, currency, is_active)
VALUES
    ('c1111111-1111-1111-1111-111111111111', 'صندوق المتجر الكاش', 'Store Cash Register', 'cash_box', 'CASH-MAIN-01', 345000.00, 'YER', TRUE),
    ('c2222222-2222-2222-2222-222222222222', 'حساب الكريمي (حاسب)', 'Kuraimi Bank Haseb', 'kuraimi', '30248911', 890000.00, 'YER', TRUE),
    ('c3333333-3333-3333-3333-333333333333', 'محفظة فلوسك (كريمي)', 'Floosak Wallet', 'floosak', '770123456', 215000.00, 'YER', TRUE),
    ('c4444444-4444-4444-4444-444444444444', 'محفظة جوالي (كاك بنك)', 'Jawali Wallet', 'jawali', '777987654', 160000.00, 'YER', TRUE),
    ('c5555555-5555-5555-5555-555555555555', 'محفظة ون كاش', 'OneCash Wallet', 'onecash', '771555666', 95000.00, 'YER', TRUE)
ON CONFLICT (id) DO NOTHING;

-- 3. الأقسام الرئيسية
INSERT INTO public.categories (id, name_ar, name_en, slug, description_ar, description_en, image_url, sort_order, is_active)
VALUES
    ('ca111111-1111-1111-1111-111111111111', 'فساتين سهرة ومناسبات', 'Evening Dresses', 'evening-dresses', 'فساتين أنيقة مصممة لأرقى المناسبات والسهرات بلمسات كلاسيكية وفخمة', 'Luxury evening and event dresses for special occasions', 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80', 1, TRUE),
    ('ca222222-2222-2222-2222-222222222222', 'جلابيات وعبايات راقية', 'Jalabiyas & Abayas', 'jalabiyas-abayas', 'أحدث تصاميم الجلابيات المطرزة والعبايات الخليجية الراقية', 'Modern luxury jalabiyas and embroidered abayas', 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80', 2, TRUE),
    ('ca333333-3333-3333-3333-333333333333', 'أطقم نسائية رسمية وكاجوال', 'Women Sets & Suits', 'women-sets', 'أطقم قطعتين وثلاث قطع مريحة وعملية تناسب العمل والإطلالات اليومية', 'Two and three-piece elegant sets for work and daily chic', 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80', 3, TRUE),
    ('ca444444-4444-4444-4444-444444444444', 'بلايز وقمصان أنيقة', 'Blouses & Shirts', 'blouses-shirts', 'بلايز حريرية وقطنية بتطاريز ناعمة وأكمام مميزة', 'Silk and cotton blouses with delicate details', 'https://images.unsplash.com/photo-1608234808654-2a8875faa7fd?w=800&q=80', 4, TRUE),
    ('ca555555-5555-5555-5555-555555555555', 'تنانير وبناطيل', 'Skirts & Pants', 'skirts-pants', 'قصات راقية وتنانير بليسيه وبناطيل قماشية واسعة', 'Pleated skirts and wide-leg trousers', 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&q=80', 5, TRUE),
    ('ca666666-6666-6666-6666-666666666666', 'شيل وإكسسوارات', 'Scarves & Accessories', 'scarves-accessories', 'طرح وشيل حريرية وأحزمة ومجوهرات مكملة للأناقة', 'Luxury silk scarves, belts, and statement accessories', 'https://images.unsplash.com/photo-1601924994987-69e26d50dc26?w=800&q=80', 6, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 4. المنتجات
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
    ),
    (
        'p4444444-4444-4444-4444-444444444444',
        'ca444444-4444-4444-4444-444444444444',
        'بلوزة حريرية أنيقة بأكمام بف وربطة عنق ناعمة',
        'Silk Chiffon Puffed Sleeve Elegant Blouse',
        'silk-chiffon-puffed-sleeve-blouse',
        'بلوزة ناعمة من الحرير الشيفون بدرجة البيج الكريمي الفاخرة، تتميز بأكمام بف راقية وياقة مع فيونكة ناعمة قابلة للربط بأكثر من أسلوب.',
        'Delicate silk chiffon blouse in creamy beige with romantic puff sleeves and versatile tie bow collar.',
        19500.00,
        16800.00,
        'حرير شيفون فاخر ذو ملمس انسيابي',
        FALSE,
        TRUE,
        TRUE
    ),
    (
        'p5555555-5555-5555-5555-555555555555',
        'ca555555-5555-5555-5555-555555555555',
        'تنورة بليسيه ميدي بدرجات البني والكراميل',
        'Caramel Pleated A-Line Midi Skirt',
        'caramel-pleated-a-line-midi-skirt',
        'تنورة بليسيه أنيقة بكسرات هندسية دقيقة وقصة A-Line واسعة مع خصر مطاطي مريح ولمعة هادئة تحت الإضاءة.',
        'Timeless pleated midi skirt with razor-sharp folds and gentle satin sheen in warm caramel hues.',
        22000.00,
        18500.00,
        'ساتان بليسيه مع بطانة داخلية قطنية',
        FALSE,
        FALSE,
        TRUE
    ),
    (
        'p6666666-6666-6666-6666-666666666666',
        'ca111111-1111-1111-1111-111111111111',
        'فستان سهرة كريب فرنسي بكاب ملكي انسيابي',
        'French Crepe Capelet Royal Evening Dress',
        'french-crepe-capelet-royal-evening-dress',
        'فستان فخم بقصة مستقيمة وكاب ملكي ينسدل برقة على الكتفين باللون الكحلي الملكي، مزين بكرستالات شوارفسكي ناعمة حول العنق.',
        'Regal French crepe evening gown with cascading shoulder cape and crystal embellishments around neckline.',
        52000.00,
        47000.00,
        'كريب فرنسي ثقيل مع بطانة ستان',
        TRUE,
        TRUE,
        TRUE
    )
ON CONFLICT (id) DO NOTHING;

-- 5. صور المنتجات المتعددة
INSERT INTO public.product_images (product_id, image_url, alt_text, is_primary, sort_order)
VALUES
    ('p1111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=800&q=80', 'فستان مخملي فاخر - الواجهة', TRUE, 1),
    ('p1111111-1111-1111-1111-111111111111', 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=800&q=80', 'تفاصيل التطريز الذهبي', FALSE, 2),
    ('p2222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1583391733956-3750e0ff4e8b?w=800&q=80', 'جلابية ريم العاجية', TRUE, 1),
    ('p2222222-2222-2222-2222-222222222222', 'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=800&q=80', 'تفاصيل التطريز والكم', FALSE, 2),
    ('p3333333-3333-3333-3333-333333333333', 'https://images.unsplash.com/photo-1539109136881-3be0616acf4b?w=800&q=80', 'طقم بليزر بيج كلاسيك', TRUE, 1),
    ('p4444444-4444-4444-4444-444444444444', 'https://images.unsplash.com/photo-1608234808654-2a8875faa7fd?w=800&q=80', 'بلوزة حريرية كريمي', TRUE, 1),
    ('p5555555-5555-5555-5555-555555555555', 'https://images.unsplash.com/photo-1583496661160-fb5886a0aaaa?w=800&q=80', 'تنورة بليسيه كراميل', TRUE, 1),
    ('p6666666-6666-6666-6666-666666666666', 'https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=800&q=80', 'فستان بكاب ملكي كحلي', TRUE, 1)
ON CONFLICT (id) DO NOTHING;

-- 6. متغيرات المنتجات (الألوان والمقاسات وSKU)
INSERT INTO public.product_variants (id, product_id, sku, barcode, color_name_ar, color_name_en, color_hex, size, additional_price, cost_price, is_active)
VALUES
    -- فستان المخمل
    ('v1011111-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 'LUJ-DRS-01-NAVY-M', '629104000101', 'كحلي ملكي', 'Royal Navy', '#1A2A44', 'M', 0.00, 24000.00, TRUE),
    ('v1022222-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 'LUJ-DRS-01-NAVY-L', '629104000102', 'كحلي ملكي', 'Royal Navy', '#1A2A44', 'L', 0.00, 24000.00, TRUE),
    ('v1033333-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 'LUJ-DRS-01-BUR-M', '629104000103', 'عنابي دافئ', 'Burgundy', '#6B1D2F', 'M', 0.00, 24000.00, TRUE),
    ('v1044444-1111-1111-1111-111111111111', 'p1111111-1111-1111-1111-111111111111', 'LUJ-DRS-01-BUR-L', '629104000104', 'عنابي دافئ', 'Burgundy', '#6B1D2F', 'L', 0.00, 24000.00, TRUE),

    -- جلابية ريم
    ('v2011111-2222-2222-2222-222222222222', 'p2222222-2222-2222-2222-222222222222', 'LUJ-JAL-02-CRM-FREE', '629104000201', 'عاجي كريمي', 'Ivory Cream', '#FAF5EE', 'Free Size', 0.00, 16000.00, TRUE),
    ('v2022222-2222-2222-2222-222222222222', 'p2222222-2222-2222-2222-222222222222', 'LUJ-JAL-02-BGE-FREE', '629104000202', 'بيج صحراوي', 'Warm Beige', '#D8C7B5', 'Free Size', 0.00, 16000.00, TRUE),

    -- طقم كلاسيك
    ('v3011111-3333-3333-3333-333333333333', 'p3333333-3333-3333-3333-333333333333', 'LUJ-SET-03-BGE-S', '629104000301', 'بيج كابتشينو', 'Beige Cappuccino', '#C8B29B', 'S', 0.00, 19000.00, TRUE),
    ('v3022222-3333-3333-3333-333333333333', 'p3333333-3333-3333-3333-333333333333', 'LUJ-SET-03-BGE-M', '629104000302', 'بيج كابتشينو', 'Beige Cappuccino', '#C8B29B', 'M', 0.00, 19000.00, TRUE),
    ('v3033333-3333-3333-3333-333333333333', 'p3333333-3333-3333-3333-333333333333', 'LUJ-SET-03-BGE-L', '629104000303', 'بيج كابتشينو', 'Beige Cappuccino', '#C8B29B', 'L', 0.00, 19000.00, TRUE),

    -- بلوزة حريرية
    ('v4011111-4444-4444-4444-444444444444', 'p4444444-4444-4444-4444-444444444444', 'LUJ-BLS-04-CRM-S', '629104000401', 'كريمي لؤلؤي', 'Pearl Cream', '#FFFDF9', 'S', 0.00, 9000.00, TRUE),
    ('v4022222-4444-4444-4444-444444444444', 'p4444444-4444-4444-4444-444444444444', 'LUJ-BLS-04-CRM-M', '629104000402', 'كريمي لؤلؤي', 'Pearl Cream', '#FFFDF9', 'M', 0.00, 9000.00, TRUE),
    ('v4033333-4444-4444-4444-444444444444', 'p4444444-4444-4444-4444-444444444444', 'LUJ-BLS-04-CRM-L', '629104000403', 'كريمي لؤلؤي', 'Pearl Cream', '#FFFDF9', 'L', 0.00, 9000.00, TRUE),

    -- تنورة بليسيه
    ('v5011111-5555-5555-5555-555555555555', 'p5555555-5555-5555-5555-555555555555', 'LUJ-SKT-05-CRM-M', '629104000501', 'كراميل دافئ', 'Warm Caramel', '#B47846', 'M', 0.00, 10000.00, TRUE),
    ('v5022222-5555-5555-5555-555555555555', 'p5555555-5555-5555-5555-555555555555', 'LUJ-SKT-05-CRM-L', '629104000502', 'كراميل دافئ', 'Warm Caramel', '#B47846', 'L', 0.00, 10000.00, TRUE),

    -- فستان الكاب الملكي
    ('v6011111-6666-6666-6666-666666666666', 'p6666666-6666-6666-6666-666666666666', 'LUJ-DRS-06-NAVY-M', '629104000601', 'كحلي ليلي', 'Midnight Navy', '#0F1D38', 'M', 0.00, 27000.00, TRUE),
    ('v6022222-6666-6666-6666-666666666666', 'p6666666-6666-6666-6666-666666666666', 'LUJ-DRS-06-NAVY-L', '629104000602', 'كحلي ليلي', 'Midnight Navy', '#0F1D38', 'L', 0.00, 27000.00, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 7. أرصدة المخزون (Inventory)
INSERT INTO public.inventory (variant_id, quantity, reserved_quantity, low_stock_threshold, last_restock_date)
VALUES
    ('v1011111-1111-1111-1111-111111111111', 8, 1, 2, NOW()),
    ('v1022222-1111-1111-1111-111111111111', 5, 0, 2, NOW()),
    ('v1033333-1111-1111-1111-111111111111', 12, 0, 3, NOW()),
    ('v1044444-1111-1111-1111-111111111111', 3, 0, 2, NOW()),

    ('v2011111-2222-2222-2222-222222222222', 15, 2, 4, NOW()),
    ('v2022222-2222-2222-2222-222222222222', 10, 0, 3, NOW()),

    ('v3011111-3333-3333-3333-333333333333', 6, 0, 2, NOW()),
    ('v3022222-3333-3333-3333-333333333333', 9, 1, 2, NOW()),
    ('v3033333-3333-3333-3333-333333333333', 2, 0, 2, NOW()), -- منخفض المخزون

    ('v4011111-4444-4444-4444-444444444444', 14, 0, 3, NOW()),
    ('v4022222-4444-4444-4444-444444444444', 18, 0, 3, NOW()),
    ('v4033333-4444-4444-4444-444444444444', 7, 0, 2, NOW()),

    ('v5011111-5555-5555-5555-555555555555', 11, 0, 3, NOW()),
    ('v5022222-5555-5555-5555-555555555555', 8, 0, 2, NOW()),

    ('v6011111-6666-6666-6666-666666666666', 4, 1, 2, NOW()),
    ('v6022222-6666-6666-6666-666666666666', 1, 0, 2, NOW())  -- منخفض المخزون جداً
ON CONFLICT (variant_id) DO NOTHING;

-- 8. الكوبونات الترويجية
INSERT INTO public.coupons (id, code, discount_type, discount_value, min_order_value, max_discount_amount, valid_from, valid_until, usage_limit, usage_count, is_active)
VALUES
    ('cp111111-1111-1111-1111-111111111111', 'LUJAIN10', 'percentage', 10.00, 20000.00, 8000.00, NOW() - INTERVAL '5 days', NOW() + INTERVAL '60 days', 500, 12, TRUE),
    ('cp222222-2222-2222-2222-222222222222', 'WELCOME', 'fixed', 3000.00, 25000.00, 3000.00, NOW() - INTERVAL '10 days', NOW() + INTERVAL '90 days', 1000, 35, TRUE),
    ('cp333333-3333-3333-3333-333333333333', 'ELEGANCE', 'percentage', 15.00, 50000.00, 15000.00, NOW() - INTERVAL '2 days', NOW() + INTERVAL '30 days', 200, 4, TRUE)
ON CONFLICT (id) DO NOTHING;

-- 9. عملاء تجريبيون
INSERT INTO public.customers (id, full_name, phone, email, notes, loyalty_points, total_spent, orders_count)
VALUES
    ('cu111111-1111-1111-1111-111111111111', 'سارة أحمد الكبسي', '771234567', 'sara.kebsi@gmail.com', 'عميلة مميزة - تفضل التواصل عبر واتساب', 120, 126000.00, 3),
    ('cu222222-2222-2222-2222-222222222222', 'أروى محمد الشامي', '772345678', 'arwa.shami@yahoo.com', 'تفضل مقاس L والألوان الداكنة', 45, 42000.00, 1),
    ('cu333333-3333-3333-3333-333333333333', 'فاطمة خالد العريقي', '733456789', 'fatima.areeqi@outlook.com', 'عميلة جديدة من عدن', 30, 34000.00, 1)
ON CONFLICT (id) DO NOTHING;

-- 10. طلبات تجريبية مكتملة وجديدة (لرؤية لوحة التحكم تعمل بالكامل)
INSERT INTO public.orders (
    id, order_number, customer_id, guest_name, guest_phone, guest_email, 
    delivery_type, delivery_zone_id, shipping_address_snapshot, 
    subtotal, delivery_fee, discount_amount, total_amount, status, source, created_at
)
VALUES
    (
        'o1111111-1111-1111-1111-111111111111',
        'LUJ-2026-01001',
        'cu111111-1111-1111-1111-111111111111',
        'سارة أحمد الكبسي',
        '771234567',
        'sara.kebsi@gmail.com',
        'home_delivery',
        'd1111111-1111-1111-1111-111111111111',
        '{"city": "صنعاء", "area": "حدة", "street_details": "شارع عمان، بجوار مدرسة الرسالة", "nearest_landmark": "صيدلية ابن حيان"}',
        42000.00,
        2000.00,
        4200.00,
        39800.00,
        'completed',
        'web',
        NOW() - INTERVAL '3 days'
    ),
    (
        'o2222222-2222-2222-2222-222222222222',
        'LUJ-2026-01002',
        'cu222222-2222-2222-2222-222222222222',
        'أروى محمد الشامي',
        '772345678',
        'arwa.shami@yahoo.com',
        'home_delivery',
        'd1111111-1111-1111-1111-111111111111',
        '{"city": "صنعاء", "area": "الأصبحي", "street_details": "شارع المقالح متفرع من شارع 24", "nearest_landmark": "سوبرماركت الهدى"}',
        34000.00,
        2000.00,
        0.00,
        36000.00,
        'accepted_preparing',
        'android',
        NOW() - INTERVAL '1 day'
    ),
    (
        'o3333333-3333-3333-3333-333333333333',
        'LUJ-2026-01003',
        NULL,
        'منى عبدالملك الآنسي',
        '777112233',
        'mona.ansi@gmail.com',
        'home_delivery',
        'd2222222-2222-2222-2222-222222222222',
        '{"city": "عدن", "area": "خورمكسر", "street_details": "حي السفارات بجوار القنصلية", "nearest_landmark": "مستشفى الجمهورية"}',
        28500.00,
        3500.00,
        0.00,
        32000.00,
        'new',
        'web',
        NOW() - INTERVAL '2 hours'
    )
ON CONFLICT (id) DO NOTHING;

-- 11. تفاصيل أسطر الطلبات (Order Items)
INSERT INTO public.order_items (
    order_id, variant_id, product_name_snapshot, sku_snapshot, color_snapshot, size_snapshot, unit_price_snapshot, cost_price_snapshot, quantity, total_line_price
)
VALUES
    ('o1111111-1111-1111-1111-111111111111', 'v1011111-1111-1111-1111-111111111111', 'فستان لجين المخملي الفاخر بتطريز ذهبي', 'LUJ-DRS-01-NAVY-M', 'كحلي ملكي', 'M', 42000.00, 24000.00, 1, 42000.00),
    ('o2222222-2222-2222-2222-222222222222', 'v3022222-3333-3333-3333-333333333333', 'طقم كلاسيك راقي (بليزر مع بنطال قماش واسع)', 'LUJ-SET-03-BGE-M', 'بيج كابتشينو', 'M', 34000.00, 19000.00, 1, 34000.00),
    ('o3333333-3333-3333-3333-333333333333', 'v2011111-2222-2222-2222-222222222222', 'جلابية ريم الرمضانية باللون العاجي والبيج', 'LUJ-JAL-02-CRM-FREE', 'عاجي كريمي', 'Free Size', 28500.00, 16000.00, 1, 28500.00)
ON CONFLICT (id) DO NOTHING;

-- 12. مدفوعات الطلبات
INSERT INTO public.payments (order_id, payment_method, amount, status, transaction_reference, notes)
VALUES
    ('o1111111-1111-1111-1111-111111111111', 'kuraimi', 39800.00, 'confirmed', 'KUR-78901234', 'تم الاستلام عبر الكريمي حاسب'),
    ('o2222222-2222-2222-2222-222222222222', 'floosak', 36000.00, 'confirmed', 'FLS-45612398', 'تم التحويل بمحفظة فلوسك'),
    ('o3333333-3333-3333-3333-333333333333', 'cash_on_delivery', 32000.00, 'pending', NULL, 'الدفع نقداً عند استلام الشحنة في عدن')
ON CONFLICT (id) DO NOTHING;

-- 13. آراء وتقييمات العملاء
INSERT INTO public.reviews (product_id, customer_id, rating, comment, reviewer_name, is_approved)
VALUES
    ('p1111111-1111-1111-1111-111111111111', 'cu111111-1111-1111-1111-111111111111', 5, 'الفستان خياطة ملكية متقنة جداً والقماش أفخم مما توقعت، والتوصيل في صنعاء كان في نفس اليوم! شكراً متجر لجين', 'سارة الكبسي', TRUE),
    ('p2222222-2222-2222-2222-222222222222', 'cu222222-2222-2222-2222-222222222222', 5, 'الجلابية باردة وخفيفة وراقية جداً باللبس، التطريز مرتب ونظيف.', 'أروى الشامي', TRUE)
ON CONFLICT (id) DO NOTHING;
