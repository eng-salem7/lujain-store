'use client';

import React, { useState, useEffect } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useStore } from '@/lib/store';
import { fetchDeliveryZones, placeOrder } from '@/lib/supabase';
import { DeliveryZone, PaymentMethod } from '@/types';
import { INITIAL_COUPONS } from '@/lib/mockData';
import { ShieldCheck, Truck, CheckCircle2, ArrowRight, Tag, Wallet, CreditCard, Banknote, Sparkles } from 'lucide-react';

export default function CheckoutPage() {
  const router = useRouter();
  const { cart, cartTotal, formatPrice, clearCart } = useStore();
  const [deliveryZones, setDeliveryZones] = useState<DeliveryZone[]>([]);
  const [selectedZoneId, setSelectedZoneId] = useState<string>('');
  const [deliveryType, setDeliveryType] = useState<'home_delivery' | 'store_pickup'>('home_delivery');

  // Customer Details Form
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [area, setArea] = useState('');
  const [streetDetails, setStreetDetails] = useState('');
  const [landmark, setLandmark] = useState('');
  const [customerNotes, setCustomerNotes] = useState('');

  // Payment & Coupon
  const [paymentMethod, setPaymentMethod] = useState<PaymentMethod>('cash_on_delivery');
  const [transactionRef, setTransactionRef] = useState('');
  const [couponCode, setCouponCode] = useState('');
  const [appliedCoupon, setAppliedCoupon] = useState<{ code: string; discount: number } | null>(null);
  const [couponError, setCouponError] = useState('');

  // Submission State
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [orderSuccess, setOrderSuccess] = useState<{ orderNumber: string } | null>(null);

  useEffect(() => {
    async function loadZones() {
      const zones = await fetchDeliveryZones();
      setDeliveryZones(zones);
      if (zones.length > 0) {
        setSelectedZoneId(zones[0].id);
      }
    }
    loadZones();
  }, []);

  const selectedZone = deliveryZones.find((z) => z.id === selectedZoneId);

  // Delivery Fee Calculation
  let deliveryFee = deliveryType === 'store_pickup' ? 0 : (selectedZone?.delivery_fee || 2000);
  if (selectedZone?.free_delivery_threshold && cartTotal >= selectedZone.free_delivery_threshold) {
    deliveryFee = 0;
  }

  // Coupon Logic
  const handleApplyCoupon = () => {
    setCouponError('');
    const found = INITIAL_COUPONS.find(
      (c) => c.code.toUpperCase() === couponCode.trim().toUpperCase() && c.is_active
    );

    if (!found) {
      setCouponError('كود الخصم غير صالح أو منتهي الصلاحية');
      return;
    }

    if (cartTotal < found.min_order_value) {
      setCouponError(`الحد الأدنى لاستخدام هذا الكود هو ${formatPrice(found.min_order_value)}`);
      return;
    }

    let discount = 0;
    if (found.discount_type === 'percentage') {
      discount = (cartTotal * found.discount_value) / 100;
      if (found.max_discount_amount) {
        discount = Math.min(discount, found.max_discount_amount);
      }
    } else {
      discount = found.discount_value;
    }

    setAppliedCoupon({ code: found.code, discount });
  };

  const discountAmount = appliedCoupon ? appliedCoupon.discount : 0;
  const finalTotal = Math.max(0, cartTotal + deliveryFee - discountAmount);

  const handleSubmitOrder = async (e: React.FormEvent) => {
    e.preventDefault();
    if (cart.length === 0) return;

    if (!name || !phone) {
      alert('يرجى إدخال اسم المستلمة ورقم الجوال للتواصل');
      return;
    }

    if (deliveryType === 'home_delivery' && (!area || !streetDetails)) {
      alert('يرجى تحديد الحي وتفاصيل الشارع لتوصيل الطلب');
      return;
    }

    setIsSubmitting(true);

    try {
      const result = await placeOrder({
        guest_name: name,
        guest_phone: phone,
        guest_email: email,
        delivery_type: deliveryType,
        delivery_zone_id: selectedZoneId,
        shipping_address_snapshot: {
          city: deliveryType === 'store_pickup' ? 'صنعاء' : (selectedZone?.city_ar || 'صنعاء'),
          area: deliveryType === 'store_pickup' ? 'فرع حدة' : area,
          street_details: deliveryType === 'store_pickup' ? 'استلام شخصي من المتجر' : streetDetails,
          nearest_landmark: landmark,
        },
        subtotal: cartTotal,
        delivery_fee: deliveryFee,
        discount_amount: discountAmount,
        coupon_code: appliedCoupon?.code,
        total_amount: finalTotal,
        payment_method: paymentMethod,
        transaction_reference: transactionRef,
        items: cart,
      });

      if (result.success) {
        clearCart();
        setOrderSuccess({ orderNumber: result.orderNumber });
      }
    } catch (err) {
      console.error(err);
      alert('حدث خطأ أثناء إرسال الطلب، يرجى المحاولة ثانية');
    } finally {
      setIsSubmitting(false);
    }
  };

  if (orderSuccess) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-16 sm:py-24 text-center">
        <div className="bg-white p-8 sm:p-12 rounded-3xl border border-[#EAE0D5] shadow-xl space-y-6">
          <div className="w-20 h-20 bg-emerald-50 rounded-full flex items-center justify-center mx-auto text-emerald-600 border border-emerald-100">
            <CheckCircle2 className="w-10 h-10" />
          </div>

          <div className="space-y-2">
            <span className="text-xs font-bold text-[#C5A059] uppercase tracking-widest">
              تم استلام طلبك بنجاح
            </span>
            <h1 className="text-2xl sm:text-3xl font-extrabold text-[#342419]">
              شكراً لتسوقكِ من متجر لجين
            </h1>
            <p className="text-xs sm:text-sm text-[#8C7A6B]">
              سيقوم فريقنا بمراجعة تفاصيل طلبك والتواصل معك عبر الواتساب لتأكيد الشحن والتسليم.
            </p>
          </div>

          {/* Order Details Card */}
          <div className="bg-[#FAF7F2] p-5 rounded-2xl border border-[#EAE0D5] text-right space-y-2.5">
            <div className="flex justify-between items-center text-xs sm:text-sm">
              <span className="text-[#8C7A6B]">رقم الطلب الخاص بك:</span>
              <span className="font-mono font-bold text-[#342419] bg-white px-3 py-1 rounded-lg border border-[#EAE0D5]">
                {orderSuccess.orderNumber}
              </span>
            </div>
            <div className="flex justify-between items-center text-xs sm:text-sm">
              <span className="text-[#8C7A6B]">المبلغ الإجمالي:</span>
              <span className="font-bold text-[#342419]">{formatPrice(finalTotal)}</span>
            </div>
            <div className="flex justify-between items-center text-xs sm:text-sm">
              <span className="text-[#8C7A6B]">طريقة الدفع:</span>
              <span className="font-bold text-[#C5A059]">
                {paymentMethod === 'cash_on_delivery' && 'نقداً عند الاستلام'}
                {paymentMethod === 'store_cash' && 'نقداً بالمتجر'}
                {paymentMethod === 'kuraimi' && 'حساب الكريمي (حاسب)'}
                {paymentMethod === 'floosak' && 'محفظة فلوسك'}
                {paymentMethod === 'jawali' && 'محفظة جوالي'}
                {paymentMethod === 'onecash' && 'محفظة ون كاش'}
              </span>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-3 pt-2">
            <Link
              href={`/track-order?num=${orderSuccess.orderNumber}`}
              className="flex-1 py-3.5 bg-[#342419] hover:bg-[#C5A059] text-white rounded-full font-bold text-xs shadow-md transition-all"
            >
              تتبع مسار الطلب الآن
            </Link>
            <Link
              href="/"
              className="flex-1 py-3.5 bg-white border border-[#EAE0D5] hover:border-[#C5A059] text-[#342419] rounded-full font-bold text-xs transition-all"
            >
              العودة للرئيسية
            </Link>
          </div>
        </div>
      </div>
    );
  }

  if (cart.length === 0) {
    return (
      <div className="max-w-2xl mx-auto px-4 py-20 text-center space-y-4">
        <h2 className="text-2xl font-bold text-[#342419]">حقيبة التسوق فارغة</h2>
        <p className="text-xs text-[#8C7A6B]">أضيفي بعض المنتجات لتتمكني من إتمام الطلب</p>
        <Link
          href="/"
          className="inline-block px-8 py-3 bg-[#342419] text-white text-xs font-bold rounded-full hover:bg-[#C5A059] transition-colors"
        >
          تصفحي التشكيلة
        </Link>
      </div>
    );
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 sm:py-16">
      <div className="mb-8">
        <Link href="/" className="inline-flex items-center gap-1.5 text-xs text-[#8C7A6B] hover:text-[#C5A059] mb-2">
          <ArrowRight className="w-3.5 h-3.5" />
          <span>متابعة التسوق</span>
        </Link>
        <h1 className="text-2xl sm:text-3xl font-extrabold text-[#342419]">
          إتمام الطلب والشحن
        </h1>
      </div>

      <form onSubmit={handleSubmitOrder} className="grid grid-cols-1 lg:grid-cols-12 gap-8">
        {/* Left Form: Customer & Shipping Details (7 Cols) */}
        <div className="lg:col-span-7 space-y-6">
          {/* 1. Delivery Type Selection */}
          <div className="bg-white p-5 sm:p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-4">
            <h2 className="text-base font-bold text-[#342419] flex items-center gap-2">
              <Truck className="w-5 h-5 text-[#C5A059]" />
              <span>طريقة استلام الطلب</span>
            </h2>

            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={() => setDeliveryType('home_delivery')}
                className={`p-4 rounded-xl border text-right transition-all ${
                  deliveryType === 'home_delivery'
                    ? 'border-[#C5A059] bg-[#FAF7F2] ring-1 ring-[#C5A059]'
                    : 'border-[#EAE0D5] bg-white hover:border-gray-400'
                }`}
              >
                <strong className="block text-xs sm:text-sm text-[#342419]">توصيل للمنزل</strong>
                <span className="text-[11px] text-[#8C7A6B] mt-0.5 block">توصيل لكافة المحافظات</span>
              </button>

              <button
                type="button"
                onClick={() => setDeliveryType('store_pickup')}
                className={`p-4 rounded-xl border text-right transition-all ${
                  deliveryType === 'store_pickup'
                    ? 'border-[#C5A059] bg-[#FAF7F2] ring-1 ring-[#C5A059]'
                    : 'border-[#EAE0D5] bg-white hover:border-gray-400'
                }`}
              >
                <strong className="block text-xs sm:text-sm text-[#342419]">استلام من المتجر</strong>
                <span className="text-[11px] text-[#8C7A6B] mt-0.5 block">صنعاء - فرع حدة (مجاني)</span>
              </button>
            </div>
          </div>

          {/* 2. Recipient Info */}
          <div className="bg-white p-5 sm:p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-4">
            <h2 className="text-base font-bold text-[#342419]">بيانات المستلمة والتواصل</h2>

            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
              <div>
                <label className="block text-xs font-bold text-[#342419] mb-1.5">
                  الاسم الكامل <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="مثال: سارة أحمد"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-[#342419] mb-1.5">
                  رقم الهاتف / الواتساب <span className="text-red-500">*</span>
                </label>
                <input
                  type="tel"
                  required
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="مثال: 771234567"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                />
              </div>

              <div className="sm:col-span-2">
                <label className="block text-xs font-bold text-[#342419] mb-1.5">
                  البريد الإلكتروني (اختياري)
                </label>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="name@example.com"
                  className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                />
              </div>
            </div>
          </div>

          {/* 3. Shipping Address (If Home Delivery) */}
          {deliveryType === 'home_delivery' && (
            <div className="bg-white p-5 sm:p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-4">
              <h2 className="text-base font-bold text-[#342419]">عنوان التوصيل</h2>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div>
                  <label className="block text-xs font-bold text-[#342419] mb-1.5">
                    المحافظة / المدينة <span className="text-red-500">*</span>
                  </label>
                  <select
                    value={selectedZoneId}
                    onChange={(e) => setSelectedZoneId(e.target.value)}
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                  >
                    {deliveryZones.filter(z => z.city_ar !== 'استلام من المتجر').map((zone) => (
                      <option key={zone.id} value={zone.id}>
                        {zone.city_ar} — ({formatPrice(zone.delivery_fee)})
                      </option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold text-[#342419] mb-1.5">
                    المنطقة / الحي <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={area}
                    onChange={(e) => setArea(e.target.value)}
                    placeholder="مثال: حدة / الأصبحي / كريتر"
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                  />
                </div>

                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-[#342419] mb-1.5">
                    تفاصيل الشارع ورقم المبنى <span className="text-red-500">*</span>
                  </label>
                  <input
                    type="text"
                    required
                    value={streetDetails}
                    onChange={(e) => setStreetDetails(e.target.value)}
                    placeholder="اسم الشارع، رقم المنزل أو العمارة"
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                  />
                </div>

                <div className="sm:col-span-2">
                  <label className="block text-xs font-bold text-[#342419] mb-1.5">
                    أقرب معلم بارز (اختياري)
                  </label>
                  <input
                    type="text"
                    value={landmark}
                    onChange={(e) => setLandmark(e.target.value)}
                    placeholder="مثال: بجوار مدرسة... أو سوبرماركت..."
                    className="w-full px-3.5 py-2.5 rounded-xl border border-[#EAE0D5] text-xs focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2]"
                  />
                </div>
              </div>
            </div>
          )}

          {/* 4. Payment Methods */}
          <div className="bg-white p-5 sm:p-6 rounded-2xl border border-[#EAE0D5] shadow-sm space-y-4">
            <h2 className="text-base font-bold text-[#342419] flex items-center gap-2">
              <Wallet className="w-5 h-5 text-[#C5A059]" />
              <span>طريقة الدفع المعتمدة</span>
            </h2>

            <div className="space-y-2.5">
              {deliveryType === 'home_delivery' ? (
                <label className="flex items-center gap-3 p-3.5 rounded-xl border border-[#EAE0D5] cursor-pointer hover:bg-[#FAF7F2] transition-colors">
                  <input
                    type="radio"
                    name="payment"
                    value="cash_on_delivery"
                    checked={paymentMethod === 'cash_on_delivery'}
                    onChange={() => setPaymentMethod('cash_on_delivery')}
                    className="w-4 h-4 text-[#C5A059] focus:ring-[#C5A059]"
                  />
                  <div>
                    <strong className="text-xs sm:text-sm text-[#342419] block">نقداً عند الاستلام</strong>
                    <span className="text-[11px] text-[#8C7A6B]">الدفع لمندوب التوصيل بعد استلام ومعاينة الشحنة</span>
                  </div>
                </label>
              ) : (
                <label className="flex items-center gap-3 p-3.5 rounded-xl border border-[#EAE0D5] cursor-pointer hover:bg-[#FAF7F2] transition-colors">
                  <input
                    type="radio"
                    name="payment"
                    value="store_cash"
                    checked={paymentMethod === 'store_cash'}
                    onChange={() => setPaymentMethod('store_cash')}
                    className="w-4 h-4 text-[#C5A059] focus:ring-[#C5A059]"
                  />
                  <div>
                    <strong className="text-xs sm:text-sm text-[#342419] block">نقداً عند الاستلام من الفرع</strong>
                    <span className="text-[11px] text-[#8C7A6B]">الدفع كاش في فرع صنعاء - حدة</span>
                  </div>
                </label>
              )}

              {/* Kuraimi */}
              <label className="flex items-center gap-3 p-3.5 rounded-xl border border-[#EAE0D5] cursor-pointer hover:bg-[#FAF7F2] transition-colors">
                <input
                  type="radio"
                  name="payment"
                  value="kuraimi"
                  checked={paymentMethod === 'kuraimi'}
                  onChange={() => setPaymentMethod('kuraimi')}
                  className="w-4 h-4 text-[#C5A059] focus:ring-[#C5A059]"
                />
                <div>
                  <strong className="text-xs sm:text-sm text-[#342419] block">بنك الكريمي (حاسب / إيداع)</strong>
                  <span className="text-[11px] text-[#8C7A6B]">حساب رقم: <strong>30248911</strong> باسم متجر لجين للأزياء</span>
                </div>
              </label>

              {/* Floosak */}
              <label className="flex items-center gap-3 p-3.5 rounded-xl border border-[#EAE0D5] cursor-pointer hover:bg-[#FAF7F2] transition-colors">
                <input
                  type="radio"
                  name="payment"
                  value="floosak"
                  checked={paymentMethod === 'floosak'}
                  onChange={() => setPaymentMethod('floosak')}
                  className="w-4 h-4 text-[#C5A059] focus:ring-[#C5A059]"
                />
                <div>
                  <strong className="text-xs sm:text-sm text-[#342419] block">محفظة فلوسك (كريمي)</strong>
                  <span className="text-[11px] text-[#8C7A6B]">رقم المحفظة: <strong>770123456</strong></span>
                </div>
              </label>

              {/* Jawali */}
              <label className="flex items-center gap-3 p-3.5 rounded-xl border border-[#EAE0D5] cursor-pointer hover:bg-[#FAF7F2] transition-colors">
                <input
                  type="radio"
                  name="payment"
                  value="jawali"
                  checked={paymentMethod === 'jawali'}
                  onChange={() => setPaymentMethod('jawali')}
                  className="w-4 h-4 text-[#C5A059] focus:ring-[#C5A059]"
                />
                <div>
                  <strong className="text-xs sm:text-sm text-[#342419] block">محفظة جوالي (كاك بنك)</strong>
                  <span className="text-[11px] text-[#8C7A6B]">رقم المحفظة: <strong>777987654</strong></span>
                </div>
              </label>
            </div>

            {/* If electronic payment, show transaction input */}
            {paymentMethod !== 'cash_on_delivery' && paymentMethod !== 'store_cash' && (
              <div className="bg-[#FAF7F2] p-4 rounded-xl border border-[#C5A059]/40 space-y-2 mt-3">
                <label className="block text-xs font-bold text-[#342419]">
                  رقم الحوالة أو المرجع للتحويل (اختياري الآن)
                </label>
                <input
                  type="text"
                  value={transactionRef}
                  onChange={(e) => setTransactionRef(e.target.value)}
                  placeholder="مثال: KUR-998811 أو رقم سند الإرسال"
                  className="w-full px-3 py-2 rounded-lg border border-[#EAE0D5] text-xs bg-white focus:outline-none focus:border-[#C5A059]"
                />
                <p className="text-[10px] text-[#8C7A6B]">
                  يمكنكِ أيضاً إرسال صورة الإشعار عبر الواتساب فور استلام رقم الطلب.
                </p>
              </div>
            )}
          </div>
        </div>

        {/* Right Sidebar: Order Summary (5 Cols) */}
        <div className="lg:col-span-5 space-y-6">
          <div className="bg-white p-6 rounded-3xl border border-[#EAE0D5] shadow-lg sticky top-28 space-y-6">
            <h3 className="text-base font-bold text-[#342419] pb-3 border-b border-[#EAE0D5]">
              ملخص الطلب ({cart.length} أصناف)
            </h3>

            {/* Items mini list */}
            <div className="space-y-3 max-h-60 overflow-y-auto pr-1">
              {cart.map((item) => (
                <div key={item.id} className="flex gap-3 text-xs items-center justify-between">
                  <div className="flex gap-2.5 items-center">
                    <img
                      src={item.product.images?.[0]?.image_url}
                      alt=""
                      className="w-12 h-14 rounded-lg object-cover bg-gray-100"
                    />
                    <div>
                      <strong className="block text-[#342419] line-clamp-1">{item.product.name_ar}</strong>
                      <span className="text-[#8C7A6B] text-[11px]">
                        {item.variant.color_name_ar} • {item.variant.size} • x{item.quantity}
                      </span>
                    </div>
                  </div>
                  <span className="font-bold text-[#342419]">
                    {formatPrice(item.price * item.quantity)}
                  </span>
                </div>
              ))}
            </div>

            {/* Coupon Box */}
            <div className="pt-3 border-t border-[#EAE0D5]">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={couponCode}
                  onChange={(e) => setCouponCode(e.target.value)}
                  placeholder="كود الخصم (مثال: LUJAIN10)"
                  className="flex-1 px-3 py-2 rounded-xl border border-[#EAE0D5] text-xs bg-[#FAF7F2] uppercase focus:outline-none focus:border-[#C5A059]"
                />
                <button
                  type="button"
                  onClick={handleApplyCoupon}
                  className="px-4 py-2 bg-[#FAF7F2] border border-[#C5A059] text-[#342419] font-bold text-xs rounded-xl hover:bg-[#C5A059] hover:text-white transition-colors"
                >
                  تطبيق
                </button>
              </div>
              {appliedCoupon && (
                <span className="text-[11px] text-emerald-700 font-bold block mt-1.5 flex items-center gap-1">
                  <Sparkles className="w-3.5 h-3.5 text-emerald-600" />
                  تم تطبيق كود {appliedCoupon.code} (خصم {formatPrice(appliedCoupon.discount)})
                </span>
              )}
              {couponError && (
                <span className="text-[11px] text-red-600 font-medium block mt-1">
                  {couponError}
                </span>
              )}
            </div>

            {/* Calculations Breakdown */}
            <div className="space-y-2 pt-3 border-t border-[#EAE0D5] text-xs sm:text-sm">
              <div className="flex justify-between text-[#8C7A6B]">
                <span>المجموع الفرعي:</span>
                <span className="font-medium text-[#342419]">{formatPrice(cartTotal)}</span>
              </div>

              <div className="flex justify-between text-[#8C7A6B]">
                <span>رسوم التوصيل:</span>
                <span className="font-medium text-[#342419]">
                  {deliveryFee === 0 ? (
                    <span className="text-emerald-700 font-bold">مجاني</span>
                  ) : (
                    formatPrice(deliveryFee)
                  )}
                </span>
              </div>

              {discountAmount > 0 && (
                <div className="flex justify-between text-emerald-700 font-bold">
                  <span>قيمة الخصم:</span>
                  <span>- {formatPrice(discountAmount)}</span>
                </div>
              )}

              <div className="flex justify-between text-base sm:text-lg font-black text-[#342419] pt-2 border-t border-[#EAE0D5]">
                <span>المجموع النهائي:</span>
                <span className="text-[#C5A059]">{formatPrice(finalTotal)}</span>
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isSubmitting}
              className="w-full py-4 bg-[#342419] hover:bg-[#C5A059] text-white rounded-2xl font-bold text-sm shadow-xl hover:shadow-2xl transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-70"
            >
              {isSubmitting ? (
                <span>جاري تأكيد طلبكِ...</span>
              ) : (
                <>
                  <ShieldCheck className="w-5 h-5 text-[#C5A059]" />
                  <span>تأكيد الطلب الآن ({formatPrice(finalTotal)})</span>
                </>
              )}
            </button>

            <div className="text-center text-[10px] text-[#8C7A6B]">
              بالضغط على تأكيد، توافقين على شروط البيع وسياسة الاستبدال لمتجر لجين.
            </div>
          </div>
        </div>
      </form>
    </div>
  );
}
