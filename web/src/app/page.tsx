'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { fetchCategories, fetchProducts } from '@/lib/supabase';
import { Product, Category } from '@/types';
import ProductCard from '@/components/ProductCard';
import ProductDetailModal from '@/components/ProductDetailModal';
import { Sparkles, ArrowDown, Filter, Search, Award, Star, ShieldCheck, HeartHandshake } from 'lucide-react';

export default function HomePage() {
  const [categories, setCategories] = useState<Category[]>([]);
  const [products, setProducts] = useState<Product[]>([]);
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [sortBy, setSortBy] = useState<'newest' | 'price-asc' | 'price-desc'>('newest');
  const [quickViewProduct, setQuickViewProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function loadData() {
      setLoading(true);
      const [cats, prods] = await Promise.all([
        fetchCategories(),
        fetchProducts(),
      ]);
      setCategories(cats);
      setProducts(prods);
      setLoading(false);
    }
    loadData();
  }, []);

  // Filtering
  const filteredProducts = products.filter((p) => {
    const matchesCategory =
      selectedCategory === 'all' || p.category_id === selectedCategory;
    const matchesSearch =
      p.name_ar.toLowerCase().includes(searchQuery.toLowerCase()) ||
      p.description_ar.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  // Sorting
  const sortedProducts = [...filteredProducts].sort((a, b) => {
    const priceA = a.discount_price || a.base_price;
    const priceB = b.discount_price || b.base_price;
    if (sortBy === 'price-asc') return priceA - priceB;
    if (sortBy === 'price-desc') return priceB - priceA;
    return new Date(b.created_at).getTime() - new Date(a.created_at).getTime();
  });

  return (
    <div className="space-y-16 sm:space-y-24">
      {/* 1. Hero Section */}
      <section className="relative overflow-hidden bg-gradient-to-b from-[#F3ECE2] via-[#FAF7F2] to-[#FAF7F2] py-16 sm:py-24 border-b border-[#EAE0D5]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
            {/* Text Content */}
            <div className="space-y-6 text-center lg:text-right">
              <div className="inline-flex items-center gap-2 bg-[#FAF7F2] border border-[#C5A059]/40 px-4 py-1.5 rounded-full shadow-sm text-xs font-bold text-[#6E482F]">
                <Sparkles className="w-3.5 h-3.5 text-[#C5A059]" />
                <span>التشكيلة الحصرية الجديدة لعام 2026</span>
              </div>

              <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold text-[#342419] leading-tight tracking-tight">
                أناقتكِ تبدأ من <span className="text-[#C5A059] relative inline-block underline decoration-[#C5A059]/40">هنا</span>
              </h1>

              <p className="text-base sm:text-lg text-[#6E5A4E] leading-relaxed max-w-xl mx-auto lg:mx-0">
                متجر <strong>لجين LUJAIN</strong> يضع بين يديكِ أرقى الفساتين المخملية، الجلابيات الرمضانية المطرزة، والأطقم الكلاسيكية المصممة بأعلى جودة مع خدمة التوصيل المباشر لكافة المحافظات اليمنية.
              </p>

              {/* CTAs */}
              <div className="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
                <a
                  href="#products"
                  className="w-full sm:w-auto px-8 py-3.5 bg-[#342419] hover:bg-[#C5A059] text-white rounded-full font-bold text-sm shadow-xl hover:shadow-2xl transition-all duration-300 flex items-center justify-center gap-2 group"
                >
                  <span>تسوقي الآن</span>
                  <ArrowDown className="w-4 h-4 text-[#C5A059] group-hover:text-white transition-colors" />
                </a>

                <Link
                  href="/track-order"
                  className="w-full sm:w-auto px-8 py-3.5 bg-white border border-[#EAE0D5] hover:border-[#C5A059] text-[#342419] rounded-full font-bold text-sm shadow-sm hover:shadow-md transition-all text-center"
                >
                  تتبع حالة طلبك
                </Link>
              </div>

              {/* Trust Badges */}
              <div className="grid grid-cols-3 gap-4 pt-6 border-t border-[#EAE0D5] text-center">
                <div>
                  <span className="block text-xl sm:text-2xl font-black text-[#342419]">+500</span>
                  <span className="text-[11px] text-[#8C7A6B]">تصميم فاخر</span>
                </div>
                <div>
                  <span className="block text-xl sm:text-2xl font-black text-[#342419]">100%</span>
                  <span className="text-[11px] text-[#8C7A6B]">أقمشة أصلية</span>
                </div>
                <div>
                  <span className="block text-xl sm:text-2xl font-black text-[#342419]">اليمن</span>
                  <span className="text-[11px] text-[#8C7A6B]">توصيل لجميع المدن</span>
                </div>
              </div>
            </div>

            {/* Visual Hero Image Collage */}
            <div className="relative">
              <div className="aspect-[4/5] rounded-3xl overflow-hidden shadow-2xl border-4 border-white bg-[#F3ECE2]">
                <img
                  src="https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=1000&q=85"
                  alt="فساتين لجين الفاخرة"
                  className="w-full h-full object-cover object-top"
                />
              </div>

              {/* Floating Badge */}
              <div className="absolute -bottom-6 -right-6 sm:bottom-8 sm:-right-6 bg-white/95 backdrop-blur-md p-4 rounded-2xl shadow-xl border border-[#EAE0D5] max-w-xs flex items-center gap-3">
                <div className="w-12 h-12 rounded-xl bg-[#FAF7F2] border border-[#C5A059]/30 flex items-center justify-center shrink-0">
                  <Award className="w-6 h-6 text-[#C5A059]" />
                </div>
                <div>
                  <h4 className="font-bold text-xs text-[#342419]">علامة تجارية يمنية رائدة</h4>
                  <p className="text-[10px] text-[#8C7A6B] mt-0.5">ضمان استبدال وحرص على أدق تفاصيل الخياطة</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* 2. Categories Section */}
      <section id="categories" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="text-center max-w-2xl mx-auto mb-10 space-y-2">
          <span className="text-xs font-bold tracking-widest text-[#C5A059] uppercase">
            تشكيلاتنا الراقية
          </span>
          <h2 className="text-2xl sm:text-3xl font-extrabold text-[#342419]">
            تصفحي حسب الأقسام
          </h2>
          <p className="text-xs sm:text-sm text-[#8C7A6B]">
            اختاري القسم المفضل لديك لاكتشاف القطع المصممة خصيصاً لإبراز تميزك
          </p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
          {categories.map((cat) => (
            <button
              key={cat.id}
              onClick={() => {
                setSelectedCategory(cat.id);
                document.getElementById('products')?.scrollIntoView({ behavior: 'smooth' });
              }}
              className={`group flex flex-col items-center p-3 rounded-2xl border transition-all text-center ${
                selectedCategory === cat.id
                  ? 'bg-[#342419] text-white border-[#342419] shadow-md'
                  : 'bg-white text-[#342419] border-[#EAE0D5] hover:border-[#C5A059] hover:shadow-sm'
              }`}
            >
              <div className="w-16 h-16 sm:w-20 sm:h-20 rounded-xl overflow-hidden mb-3 bg-[#F3ECE2] group-hover:scale-105 transition-transform duration-300">
                <img
                  src={cat.image_url || ''}
                  alt={cat.name_ar}
                  className="w-full h-full object-cover"
                />
              </div>
              <span className="text-xs font-bold leading-tight line-clamp-2">
                {cat.name_ar}
              </span>
            </button>
          ))}
        </div>
      </section>

      {/* 3. Catalog & Products Section */}
      <section id="products" className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 scroll-mt-24">
        {/* Controls Bar: Filter, Search, Sort */}
        <div className="bg-white p-4 sm:p-6 rounded-2xl border border-[#EAE0D5] shadow-sm mb-8 space-y-4">
          <div className="flex flex-col md:flex-row items-center justify-between gap-4">
            {/* Category Filter Chips */}
            <div className="flex items-center gap-2 overflow-x-auto w-full md:w-auto pb-2 md:pb-0">
              <button
                onClick={() => setSelectedCategory('all')}
                className={`text-xs px-4 py-2 rounded-full font-bold whitespace-nowrap transition-all ${
                  selectedCategory === 'all'
                    ? 'bg-[#342419] text-white'
                    : 'bg-[#FAF7F2] text-[#6E482F] hover:bg-[#EAE0D5]'
                }`}
              >
                الكل ({products.length})
              </button>
              {categories.map((cat) => (
                <button
                  key={cat.id}
                  onClick={() => setSelectedCategory(cat.id)}
                  className={`text-xs px-4 py-2 rounded-full font-bold whitespace-nowrap transition-all ${
                    selectedCategory === cat.id
                      ? 'bg-[#342419] text-white'
                      : 'bg-[#FAF7F2] text-[#6E482F] hover:bg-[#EAE0D5]'
                  }`}
                >
                  {cat.name_ar}
                </button>
              ))}
            </div>

            {/* Search Input & Sort */}
            <div className="flex items-center gap-3 w-full md:w-auto">
              <div className="relative flex-1 md:w-64">
                <input
                  type="text"
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  placeholder="ابحثي عن فستان أو جلابية..."
                  className="w-full pl-9 pr-4 py-2 rounded-full border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                />
                <Search className="w-4 h-4 text-gray-400 absolute left-3 top-2.5" />
              </div>

              <select
                value={sortBy}
                onChange={(e: any) => setSortBy(e.target.value)}
                className="text-xs px-3 py-2 rounded-full border border-[#EAE0D5] bg-[#FAF7F2] text-[#342419] font-medium focus:outline-none focus:border-[#C5A059]"
              >
                <option value="newest">الأحدث وصولاً</option>
                <option value="price-asc">السعر: من الأقل</option>
                <option value="price-desc">السعر: من الأعلى</option>
              </select>
            </div>
          </div>
        </div>

        {/* Product Grid */}
        {sortedProducts.length === 0 ? (
          <div className="text-center py-16 bg-white rounded-3xl border border-[#EAE0D5]">
            <Filter className="w-12 h-12 text-[#C5A059] mx-auto mb-3" />
            <h3 className="text-lg font-bold text-[#342419]">لم يتم العثور على منتجات مطابقة</h3>
            <p className="text-xs text-[#8C7A6B] mt-1">جربي تغيير خيارات الفلترة أو مصطلح البحث</p>
            <button
              onClick={() => {
                setSelectedCategory('all');
                setSearchQuery('');
              }}
              className="mt-4 px-6 py-2 bg-[#342419] text-white text-xs font-bold rounded-full hover:bg-[#C5A059]"
            >
              عرض كل المنتجات
            </button>
          </div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
            {sortedProducts.map((product) => (
              <ProductCard
                key={product.id}
                product={product}
                onQuickView={(p) => setQuickViewProduct(p)}
              />
            ))}
          </div>
        )}
      </section>

      {/* 4. Promotional Banner */}
      <section className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="bg-[#342419] text-[#FAF7F2] rounded-3xl p-8 sm:p-12 relative overflow-hidden shadow-2xl border-2 border-[#C5A059]/40">
          <div className="relative z-10 max-w-xl space-y-4">
            <span className="text-xs font-bold text-[#C5A059] tracking-widest uppercase">
              عرض حصري لفترة محدودة
            </span>
            <h3 className="text-2xl sm:text-4xl font-extrabold leading-snug">
              احصلي على خصم 10% إضافي على كافة الطلبات
            </h3>
            <p className="text-xs sm:text-sm text-[#C5B7A9] leading-relaxed">
              استخدمي كود الخصم <strong>LUJAIN10</strong> عند إتمام الطلب، واستمتعي بإطلالة تأسر الأنظار في مناسباتك القادمة.
            </p>
            <div className="pt-2">
              <a
                href="#products"
                className="inline-block bg-[#C5A059] hover:bg-[#FAF7F2] text-[#342419] font-bold text-xs px-6 py-3 rounded-full transition-all shadow-md"
              >
                تسوقي العرض الآن
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* 5. Customer Testimonials */}
      <section className="bg-[#F3ECE2] py-16 border-y border-[#EAE0D5]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center space-y-10">
          <div>
            <span className="text-xs font-bold tracking-widest text-[#C5A059] uppercase">
              آراء عميلاتنا العزيزات
            </span>
            <h2 className="text-2xl sm:text-3xl font-extrabold text-[#342419] mt-1">
              ماذا يقلن عن متجر لجين؟
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 text-right">
            <div className="bg-white p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-3">
              <div className="flex items-center gap-1 text-[#C5A059]">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-4 h-4 fill-[#C5A059]" />
                ))}
              </div>
              <p className="text-xs sm:text-sm text-[#462C1E] leading-relaxed">
                «الفستان المخملي خياطة ملكية متقنة جداً، والتطريز الذهبي هادئ وفخم. التوصيل في صنعاء كان في نفس اليوم! شكراً لكم على الرقي والاهتمام.»
              </p>
              <div className="pt-2 border-t border-[#EAE0D5]">
                <strong className="block text-xs text-[#342419]">سارة الكبسي</strong>
                <span className="text-[10px] text-[#8C7A6B]">صنعاء - حدة</span>
              </div>
            </div>

            <div className="bg-white p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-3">
              <div className="flex items-center gap-1 text-[#C5A059]">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-4 h-4 fill-[#C5A059]" />
                ))}
              </div>
              <p className="text-xs sm:text-sm text-[#462C1E] leading-relaxed">
                «طلبت الجلابية العاجية ووصلتني عدن خلال يومين فقط. القماش بارد ومريح جداً والتفاصيل بالواقع أجمل من الصور بكثير!»
              </p>
              <div className="pt-2 border-t border-[#EAE0D5]">
                <strong className="block text-xs text-[#342419]">أروى الشامي</strong>
                <span className="text-[10px] text-[#8C7A6B]">عدن - خورمكسر</span>
              </div>
            </div>

            <div className="bg-white p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-3">
              <div className="flex items-center gap-1 text-[#C5A059]">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} className="w-4 h-4 fill-[#C5A059]" />
                ))}
              </div>
              <p className="text-xs sm:text-sm text-[#462C1E] leading-relaxed">
                «طقم البليزر البيج رسمي ومثالي لاجتماعات العمل، المقاس مضبوط تماماً، والدفع عبر محفظة الكريمي كان سهلاً وسريعاً.»
              </p>
              <div className="pt-2 border-t border-[#EAE0D5]">
                <strong className="block text-xs text-[#342419]">فاطمة العريقي</strong>
                <span className="text-[10px] text-[#8C7A6B]">تعز</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Quick View Modal */}
      {quickViewProduct && (
        <ProductDetailModal
          product={quickViewProduct}
          onClose={() => setQuickViewProduct(null)}
        />
      )}
    </div>
  );
}
