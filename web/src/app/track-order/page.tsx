'use client';

import React, { useState, useEffect } from 'react';
import { useSearchParams } from 'next/navigation';
import { trackOrder } from '@/lib/supabase';
import { Order, OrderStatus } from '@/types';
import { Search, Package, Clock, CheckCircle2, Truck, AlertCircle, ShoppingBag, MapPin, Calendar } from 'lucide-react';

export default function TrackOrderPage() {
  const searchParams = useSearchParams();
  const initialOrderNum = searchParams.get('num') || '';

  const [orderNumber, setOrderNumber] = useState(initialOrderNum);
  const [phone, setPhone] = useState('');
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(false);
  const [searched, setSearched] = useState(false);

  useEffect(() => {
    if (initialOrderNum) {
      handleSearch(null, initialOrderNum);
    }
  }, [initialOrderNum]);

  const handleSearch = async (e: React.FormEvent | null, autoNum?: string) => {
    if (e) e.preventDefault();
    const targetNum = autoNum || orderNumber;
    if (!targetNum.trim()) return;

    setLoading(true);
    setSearched(true);
    try {
      const result = await trackOrder(targetNum, phone);
      setOrder(result);
    } catch (err) {
      console.error(err);
      setOrder(null);
    } finally {
      setLoading(false);
    }
  };

  const steps: { key: OrderStatus; label: string; desc: string }[] = [
    { key: 'new', label: 'طلب جديد', desc: 'تم استلام طلبك في النظام' },
    { key: 'under_review', label: 'قيد المراجعة', desc: 'التحقق من المخزون والعنوان' },
    { key: 'accepted_preparing', label: 'مقبول وقيد التجهيز', desc: 'تجهيز وتغليف القطع وحجز المخزون' },
    { key: 'ready_for_pickup', label: 'جاهز للتسليم', desc: 'تم التجهيز للمندوب أو للاستلام من الفرع' },
    { key: 'out_for_delivery', label: 'خرج للتوصيل', desc: 'الشحنة في طريقها لعنوانك' },
    { key: 'completed', label: 'مكتمل ومسلَّم', desc: 'تم تسليم الطلب بنجاح' },
  ];

  const getStepStatus = (stepKey: OrderStatus, currentStatus: OrderStatus) => {
    const orderIndex = steps.findIndex((s) => s.key === currentStatus);
    const thisIndex = steps.findIndex((s) => s.key === stepKey);

    if (currentStatus === 'cancelled') return 'cancelled';
    if (thisIndex < orderIndex) return 'completed';
    if (thisIndex === orderIndex) return 'current';
    return 'upcoming';
  };

  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12 sm:py-20 space-y-10">
      {/* Header */}
      <div className="text-center space-y-3">
        <div className="w-16 h-16 bg-[#F3ECE2] text-[#C5A059] rounded-2xl flex items-center justify-center mx-auto shadow-sm">
          <Truck className="w-8 h-8" />
        </div>
        <h1 className="text-3xl font-extrabold text-[#342419]">تتبع حالة طلبك</h1>
        <p className="text-xs sm:text-sm text-[#8C7A6B] max-w-md mx-auto">
          أدخلي رقم الطلب الخاص بكِ (مثال: LUJ-2026-01001) لمتابعة مساره وتحديثات التسليم فوراً
        </p>
      </div>

      {/* Search Box */}
      <form
        onSubmit={(e) => handleSearch(e)}
        className="bg-white p-4 sm:p-6 rounded-3xl border border-[#EAE0D5] shadow-lg max-w-2xl mx-auto flex flex-col sm:flex-row gap-3"
      >
        <div className="flex-1 relative">
          <input
            type="text"
            required
            value={orderNumber}
            onChange={(e) => setOrderNumber(e.target.value)}
            placeholder="أدخلي رقم الطلب (مثال: LUJ-2026-01001)"
            className="w-full pl-4 pr-10 py-3 rounded-2xl border border-[#EAE0D5] text-xs sm:text-sm focus:outline-none focus:border-[#C5A059] bg-[#FAF7F2] font-mono"
          />
          <Search className="w-4 h-4 text-gray-400 absolute right-3.5 top-3.5" />
        </div>

        <button
          type="submit"
          disabled={loading}
          className="px-8 py-3 bg-[#342419] hover:bg-[#C5A059] text-white font-bold text-xs sm:text-sm rounded-2xl transition-all shadow-md flex items-center justify-center gap-2"
        >
          {loading ? 'جاري البحث...' : 'تتبع الطلب'}
        </button>
      </form>

      {/* Results Section */}
      {searched && !order && !loading && (
        <div className="text-center py-12 bg-white rounded-3xl border border-[#EAE0D5] max-w-2xl mx-auto space-y-3">
          <AlertCircle className="w-12 h-12 text-[#A82B2B] mx-auto" />
          <h3 className="text-base font-bold text-[#342419]">لم يتم العثور على هذا الطلب</h3>
          <p className="text-xs text-[#8C7A6B]">
            يرجى التأكد من كتابة رقم الطلب بصورة صحيحة (مثال: LUJ-2026-01001).
          </p>
        </div>
      )}

      {order && (
        <div className="bg-white rounded-3xl border border-[#EAE0D5] shadow-xl overflow-hidden space-y-8 p-6 sm:p-10">
          {/* Order Header Summary */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-6 border-b border-[#EAE0D5]">
            <div>
              <span className="text-xs font-bold text-[#C5A059] uppercase tracking-wider block">
                تفاصيل الشحنة
              </span>
              <h2 className="text-xl sm:text-2xl font-black text-[#342419] font-mono mt-0.5">
                {order.order_number}
              </h2>
              <span className="text-xs text-[#8C7A6B] flex items-center gap-1.5 mt-1">
                <Calendar className="w-3.5 h-3.5" />
                <span>تاريخ الإنشاء: {new Date(order.created_at).toLocaleDateString('ar-YE')}</span>
              </span>
            </div>

            {/* Current Status Badge */}
            <div className="text-right sm:text-left">
              <span className="text-xs text-[#8C7A6B] block mb-1">الحالة الحالية:</span>
              <span className="inline-block px-4 py-1.5 rounded-full text-xs font-black bg-[#FAF7F2] text-[#342419] border border-[#C5A059]">
                {order.status === 'new' && 'طلب جديد'}
                {order.status === 'under_review' && 'قيد المراجعة والتحقق'}
                {order.status === 'accepted_preparing' && 'مقبول وقيد التجهيز'}
                {order.status === 'ready_for_pickup' && 'جاهز للتسليم'}
                {order.status === 'out_for_delivery' && 'خرج للتوصيل'}
                {order.status === 'completed' && 'مكتمل ومسلَّم'}
                {order.status === 'cancelled' && 'ملغي'}
                {order.status === 'returned' && 'مرتجع'}
              </span>
            </div>
          </div>

          {/* Stepper Timeline */}
          {order.status !== 'cancelled' && (
            <div className="py-4">
              <h3 className="text-sm font-bold text-[#342419] mb-6">مراحل تنفيذ وتوصيل الطلب:</h3>
              <div className="relative">
                {/* Connecting Line */}
                <div className="hidden md:block absolute top-1/2 right-4 left-4 h-1 bg-[#EAE0D5] -translate-y-1/2 z-0" />

                <div className="grid grid-cols-2 md:grid-cols-6 gap-4 relative z-10">
                  {steps.map((step, idx) => {
                    const status = getStepStatus(step.key, order.status);
                    return (
                      <div key={step.key} className="flex flex-col items-center text-center space-y-2">
                        <div
                          className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-xs transition-all ${
                            status === 'completed'
                              ? 'bg-emerald-600 text-white shadow-md'
                              : status === 'current'
                              ? 'bg-[#342419] text-[#C5A059] ring-4 ring-[#C5A059]/30 shadow-lg scale-110'
                              : 'bg-white text-gray-400 border-2 border-[#EAE0D5]'
                          }`}
                        >
                          {status === 'completed' ? (
                            <CheckCircle2 className="w-5 h-5" />
                          ) : (
                            idx + 1
                          )}
                        </div>
                        <strong className="text-xs text-[#342419] leading-tight block">
                          {step.label}
                        </strong>
                        <span className="text-[10px] text-[#8C7A6B] leading-tight hidden md:block">
                          {step.desc}
                        </span>
                      </div>
                    );
                  })}
                </div>
              </div>
            </div>
          )}

          {/* Order Details Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-6 border-t border-[#EAE0D5] text-xs">
            {/* Delivery Details */}
            <div className="bg-[#FAF7F2] p-5 rounded-2xl border border-[#EAE0D5] space-y-2">
              <h4 className="font-bold text-[#342419] flex items-center gap-1.5 text-sm mb-3">
                <MapPin className="w-4 h-4 text-[#C5A059]" />
                <span>عنوان الاستلام</span>
              </h4>
              <p><strong>المستلمة:</strong> {order.guest_name || 'عميلة متجر لجين'}</p>
              <p><strong>الهاتف:</strong> {order.guest_phone}</p>
              <p><strong>المدينة والمنطقة:</strong> {order.shipping_address_snapshot.city} — {order.shipping_address_snapshot.area}</p>
              <p><strong>تفاصيل العنوان:</strong> {order.shipping_address_snapshot.street_details}</p>
            </div>

            {/* Financial Details */}
            <div className="bg-[#FAF7F2] p-5 rounded-2xl border border-[#EAE0D5] space-y-2">
              <h4 className="font-bold text-[#342419] flex items-center gap-1.5 text-sm mb-3">
                <ShoppingBag className="w-4 h-4 text-[#C5A059]" />
                <span>الملخص المالي للطلب</span>
              </h4>
              <div className="flex justify-between">
                <span>المجموع الفرعي:</span>
                <span className="font-semibold">{order.subtotal?.toLocaleString('ar-YE')} ر.ي</span>
              </div>
              <div className="flex justify-between">
                <span>رسوم التوصيل:</span>
                <span className="font-semibold">{order.delivery_fee?.toLocaleString('ar-YE')} ر.ي</span>
              </div>
              {order.discount_amount > 0 && (
                <div className="flex justify-between text-emerald-700 font-bold">
                  <span>الخصم المطبق:</span>
                  <span>- {order.discount_amount?.toLocaleString('ar-YE')} ر.ي</span>
                </div>
              )}
              <div className="flex justify-between text-sm font-black text-[#342419] pt-2 border-t border-[#EAE0D5]">
                <span>المبلغ الإجمالي:</span>
                <span className="text-[#C5A059]">{order.total_amount?.toLocaleString('ar-YE')} ر.ي</span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
