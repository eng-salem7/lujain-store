'use client';

import React from 'react';
import Link from 'next/link';
import { useStore } from '@/lib/store';
import { X, Trash2, Plus, Minus, ShoppingBag, ArrowLeft, Sparkles } from 'lucide-react';

export default function CartDrawer() {
  const { cart, removeFromCart, updateQuantity, cartTotal, formatPrice, isCartOpen, setIsCartOpen } = useStore();

  const FREE_SHIPPING_LIMIT = 50000;
  const progressPercent = Math.min(100, Math.round((cartTotal / FREE_SHIPPING_LIMIT) * 100));
  const remainingForFreeShipping = Math.max(0, FREE_SHIPPING_LIMIT - cartTotal);

  if (!isCartOpen) return null;

  return (
    <div className="fixed inset-0 z-50 overflow-hidden">
      {/* Backdrop */}
      <div
        onClick={() => setIsCartOpen(false)}
        className="absolute inset-0 bg-black/50 backdrop-blur-sm transition-opacity"
      />

      <div className="fixed inset-y-0 left-0 max-w-full flex pl-0 sm:pl-10">
        <div className="w-screen max-w-md bg-[#FAF7F2] shadow-2xl flex flex-col justify-between border-r border-[#EAE0D5]">
          {/* Header */}
          <div className="p-5 border-b border-[#EAE0D5] flex items-center justify-between bg-white">
            <div className="flex items-center gap-2.5">
              <div className="w-8 h-8 rounded-full bg-[#F3ECE2] flex items-center justify-center">
                <ShoppingBag className="w-4 h-4 text-[#C5A059]" />
              </div>
              <h2 className="text-lg font-bold text-[#342419]">حقيبة التسوق ({cart.length})</h2>
            </div>
            <button
              onClick={() => setIsCartOpen(false)}
              className="p-2 text-gray-500 hover:text-black transition-colors rounded-full hover:bg-gray-100"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Free Shipping Progress */}
          <div className="bg-[#F3ECE2] p-3.5 border-b border-[#EAE0D5] text-xs">
            {remainingForFreeShipping > 0 ? (
              <p className="text-[#6E482F] font-medium mb-1.5 flex items-center gap-1">
                <Sparkles className="w-3.5 h-3.5 text-[#C5A059]" />
                أضيفي بـ <strong>{formatPrice(remainingForFreeShipping)}</strong> إضافية للحصول على <strong>شحن مجاني</strong>!
              </p>
            ) : (
              <p className="text-emerald-700 font-bold mb-1.5 flex items-center gap-1">
                <Sparkles className="w-3.5 h-3.5 text-emerald-600" />
                تهانينا! مؤهلة للشحن المجاني لكافة المحافظات اليمنية 🎉
              </p>
            )}
            <div className="w-full bg-[#E5DACB] h-2 rounded-full overflow-hidden">
              <div
                className="bg-[#C5A059] h-full transition-all duration-500 rounded-full"
                style={{ width: `${progressPercent}%` }}
              />
            </div>
          </div>

          {/* Cart Items List */}
          <div className="flex-1 overflow-y-auto p-5 space-y-4">
            {cart.length === 0 ? (
              <div className="text-center py-16 space-y-4">
                <div className="w-16 h-16 rounded-full bg-[#F3ECE2] flex items-center justify-center mx-auto text-[#A08E80]">
                  <ShoppingBag className="w-8 h-8" />
                </div>
                <h3 className="font-bold text-[#342419] text-base">حقيبتك فارغة حالياً</h3>
                <p className="text-xs text-[#8C7A6B]">
                  تصفحي أرقى الفساتين والجلابيات النسائية وابدئي بالتسوق
                </p>
                <button
                  onClick={() => setIsCartOpen(false)}
                  className="mt-3 bg-[#342419] text-white text-xs font-bold px-6 py-2.5 rounded-full hover:bg-[#C5A059] transition-colors"
                >
                  استكشفي التشكيلة
                </button>
              </div>
            ) : (
              cart.map((item) => (
                <div
                  key={item.id}
                  className="flex gap-4 p-3 bg-white rounded-2xl border border-[#EAE0D5] shadow-sm relative group"
                >
                  {/* Thumbnail */}
                  <div className="w-20 h-24 rounded-xl bg-[#F3ECE2] overflow-hidden shrink-0">
                    <img
                      src={item.product.images?.[0]?.image_url || ''}
                      alt={item.product.name_ar}
                      className="w-full h-full object-cover"
                    />
                  </div>

                  {/* Details */}
                  <div className="flex-1 flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-start">
                        <h4 className="font-bold text-[#342419] text-xs sm:text-sm line-clamp-1 pr-1">
                          {item.product.name_ar}
                        </h4>
                        <button
                          onClick={() => removeFromCart(item.variant.id)}
                          className="text-gray-400 hover:text-red-600 transition-colors p-1"
                          title="حذف"
                        >
                          <Trash2 className="w-3.5 h-3.5" />
                        </button>
                      </div>

                      {/* Variant Specs */}
                      <div className="flex items-center gap-2 text-[11px] text-[#8C7A6B] mt-1">
                        <span>اللون: {item.variant.color_name_ar}</span>
                        <span>•</span>
                        <span>المقاس: {item.variant.size}</span>
                      </div>
                    </div>

                    {/* Quantity & Line Total */}
                    <div className="flex items-center justify-between pt-2">
                      <div className="flex items-center border border-[#EAE0D5] rounded-lg overflow-hidden bg-[#FAF7F2]">
                        <button
                          onClick={() => updateQuantity(item.variant.id, item.quantity - 1)}
                          className="p-1 hover:bg-[#EAE0D5] text-gray-700 transition-colors"
                        >
                          <Minus className="w-3 h-3" />
                        </button>
                        <span className="px-2 text-xs font-bold font-mono">{item.quantity}</span>
                        <button
                          onClick={() => updateQuantity(item.variant.id, item.quantity + 1)}
                          className="p-1 hover:bg-[#EAE0D5] text-gray-700 transition-colors"
                        >
                          <Plus className="w-3 h-3" />
                        </button>
                      </div>

                      <span className="font-bold text-sm text-[#342419]">
                        {formatPrice(item.price * item.quantity)}
                      </span>
                    </div>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Footer & Checkout button */}
          {cart.length > 0 && (
            <div className="p-5 border-t border-[#EAE0D5] bg-white space-y-3">
              <div className="flex items-center justify-between text-sm">
                <span className="text-[#8C7A6B] font-medium">المجموع الفرعي:</span>
                <span className="font-black text-lg text-[#342419]">{formatPrice(cartTotal)}</span>
              </div>
              <p className="text-[11px] text-[#A08E80]">
                * رسوم التوصيل والخصم تُحسب بدقة في خطوة إتمام الطلب حسب المنطقة.
              </p>

              <Link
                href="/checkout"
                onClick={() => setIsCartOpen(false)}
                className="w-full py-3.5 bg-[#342419] hover:bg-[#C5A059] text-white rounded-2xl font-bold text-sm flex items-center justify-center gap-2 shadow-lg hover:shadow-xl transition-all duration-300"
              >
                <span>متابعة إتمام الطلب</span>
                <ArrowLeft className="w-4 h-4" />
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
