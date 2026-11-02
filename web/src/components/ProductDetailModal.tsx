'use client';

import React, { useState } from 'react';
import { Product, ProductVariant } from '@/types';
import { useStore } from '@/lib/store';
import { X, Heart, ShoppingBag, Check, ShieldCheck, Sparkles } from 'lucide-react';

interface ProductDetailModalProps {
  product: Product | null;
  onClose: () => void;
}

export default function ProductDetailModal({ product, onClose }: ProductDetailModalProps) {
  const { addToCart, toggleWishlist, isInWishlist, formatPrice } = useStore();
  const [selectedVariant, setSelectedVariant] = useState<ProductVariant | null>(
    product?.variants[0] || null
  );
  const [selectedImage, setSelectedImage] = useState<string>(
    product?.images[0]?.image_url || ''
  );
  const [quantity, setQuantity] = useState(1);
  const [isAdded, setIsAdded] = useState(false);

  if (!product) return null;

  const currentVariant = selectedVariant || product.variants[0];
  const hasDiscount = product.discount_price && product.discount_price < product.base_price;
  const discountPercent = hasDiscount
    ? Math.round(((product.base_price - product.discount_price!) / product.base_price) * 100)
    : 0;

  const handleAddToCart = () => {
    if (!currentVariant) return;
    addToCart(product, currentVariant, quantity);
    setIsAdded(true);
    setTimeout(() => {
      setIsAdded(false);
      onClose();
    }, 1200);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 overflow-y-auto">
      <div onClick={onClose} className="fixed inset-0 bg-black/60 backdrop-blur-sm transition-opacity" />

      <div className="relative bg-[#FAF7F2] rounded-3xl max-w-3xl w-full overflow-hidden shadow-2xl border border-[#EAE0D5] z-10 my-8">
        {/* Close Button */}
        <button
          onClick={onClose}
          className="absolute top-4 left-4 z-20 w-10 h-10 rounded-full bg-white/80 hover:bg-white text-gray-700 flex items-center justify-center shadow-md transition-all"
        >
          <X className="w-5 h-5" />
        </button>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 p-6 sm:p-8">
          {/* Images Section */}
          <div className="space-y-4">
            <div className="aspect-[3/4] w-full rounded-2xl bg-[#F3ECE2] overflow-hidden border border-[#EAE0D5]">
              <img
                src={selectedImage || product.images[0]?.image_url}
                alt={product.name_ar}
                className="w-full h-full object-cover object-top"
              />
            </div>

            {/* Thumbnail selector */}
            {product.images && product.images.length > 1 && (
              <div className="flex gap-2 overflow-x-auto pb-1">
                {product.images.map((img) => (
                  <button
                    key={img.id}
                    onClick={() => setSelectedImage(img.image_url)}
                    className={`w-16 h-20 rounded-xl overflow-hidden border-2 transition-all shrink-0 ${
                      (selectedImage || product.images[0]?.image_url) === img.image_url
                        ? 'border-[#C5A059] scale-105'
                        : 'border-transparent opacity-70 hover:opacity-100'
                    }`}
                  >
                    <img src={img.image_url} alt="" className="w-full h-full object-cover" />
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Details Section */}
          <div className="flex flex-col justify-between space-y-4">
            <div>
              {/* Category & Badge */}
              <div className="flex items-center gap-2 mb-2">
                <span className="text-xs font-bold px-2.5 py-0.5 rounded-full bg-[#F3ECE2] text-[#6E482F]">
                  {product.category?.name_ar || 'أزياء فاخرة'}
                </span>
                {hasDiscount && (
                  <span className="text-xs font-bold px-2.5 py-0.5 rounded-full bg-[#A82B2B] text-white">
                    خصم {discountPercent}%
                  </span>
                )}
              </div>

              {/* Title */}
              <h2 className="text-xl sm:text-2xl font-bold text-[#342419] leading-snug">
                {product.name_ar}
              </h2>

              {/* Price */}
              <div className="flex items-baseline gap-3 my-3">
                <span className="text-2xl font-black text-[#342419]">
                  {formatPrice(product.discount_price || product.base_price)}
                </span>
                {hasDiscount && (
                  <span className="text-sm text-[#A08E80] line-through font-medium">
                    {formatPrice(product.base_price)}
                  </span>
                )}
              </div>

              {/* Description */}
              <p className="text-xs sm:text-sm text-[#6E5A4E] leading-relaxed border-t border-[#EAE0D5] pt-3">
                {product.description_ar}
              </p>

              {/* Fabric Specs */}
              {product.fabric_details && (
                <div className="bg-white p-3 rounded-xl border border-[#EAE0D5] text-xs text-[#6E482F] my-3 flex items-center gap-2">
                  <Sparkles className="w-4 h-4 text-[#C5A059]" />
                  <span><strong>خامة القماش:</strong> {product.fabric_details}</span>
                </div>
              )}

              {/* Variants Selector */}
              <div className="space-y-3 pt-2">
                {/* Color Choice */}
                <div>
                  <span className="text-xs font-bold text-[#342419] block mb-1.5">
                    اختاري اللون: <span className="font-normal text-[#C5A059]">{currentVariant?.color_name_ar}</span>
                  </span>
                  <div className="flex items-center gap-2 flex-wrap">
                    {product.variants.map((v) => (
                      <button
                        key={v.id}
                        onClick={() => setSelectedVariant(v)}
                        className={`px-3 py-1.5 rounded-xl border text-xs font-semibold flex items-center gap-1.5 transition-all ${
                          currentVariant?.id === v.id
                            ? 'bg-[#342419] text-white border-[#342419]'
                            : 'bg-white text-gray-800 border-[#EAE0D5] hover:border-[#C5A059]'
                        }`}
                      >
                        <span
                          className="w-3.5 h-3.5 rounded-full border border-black/10"
                          style={{ backgroundColor: v.color_hex }}
                        />
                        <span>{v.color_name_ar}</span>
                      </button>
                    ))}
                  </div>
                </div>

                {/* Size Choice */}
                <div>
                  <span className="text-xs font-bold text-[#342419] block mb-1.5">
                    المقاس: <span className="font-normal text-[#C5A059]">{currentVariant?.size}</span>
                  </span>
                  <div className="flex items-center gap-2 flex-wrap">
                    {Array.from(new Set(product.variants.map((v) => v.size))).map((size) => (
                      <button
                        key={size}
                        onClick={() => {
                          const match = product.variants.find((v) => v.size === size);
                          if (match) setSelectedVariant(match);
                        }}
                        className={`min-w-10 px-3 py-1.5 rounded-xl border text-xs font-bold transition-all ${
                          currentVariant?.size === size
                            ? 'bg-[#C5A059] text-white border-[#C5A059]'
                            : 'bg-white text-gray-800 border-[#EAE0D5] hover:border-[#C5A059]'
                        }`}
                      >
                        {size}
                      </button>
                    ))}
                  </div>
                </div>

                {/* Stock info */}
                <div className="text-xs text-emerald-700 font-semibold flex items-center gap-1.5 pt-1">
                  <ShieldCheck className="w-4 h-4 text-emerald-600" />
                  <span>متوفر في المخزون وجاهز للتجهيز الفوري</span>
                </div>
              </div>
            </div>

            {/* Action buttons */}
            <div className="pt-4 border-t border-[#EAE0D5] flex items-center gap-3">
              {/* Quantity */}
              <div className="flex items-center border border-[#EAE0D5] rounded-xl overflow-hidden bg-white">
                <button
                  onClick={() => setQuantity(Math.max(1, quantity - 1))}
                  className="px-3 py-2.5 hover:bg-[#F3ECE2] text-gray-700 font-bold"
                >
                  -
                </button>
                <span className="px-3 text-sm font-bold font-mono">{quantity}</span>
                <button
                  onClick={() => setQuantity(quantity + 1)}
                  className="px-3 py-2.5 hover:bg-[#F3ECE2] text-gray-700 font-bold"
                >
                  +
                </button>
              </div>

              {/* Add to Cart */}
              <button
                onClick={handleAddToCart}
                disabled={isAdded}
                className={`flex-1 py-3 rounded-xl font-bold text-sm flex items-center justify-center gap-2 shadow-lg transition-all ${
                  isAdded
                    ? 'bg-emerald-700 text-white'
                    : 'bg-[#342419] hover:bg-[#C5A059] text-white hover:shadow-xl'
                }`}
              >
                {isAdded ? (
                  <>
                    <Check className="w-4 h-4" />
                    <span>تمت الإضافة لحقيبتك!</span>
                  </>
                ) : (
                  <>
                    <ShoppingBag className="w-4 h-4 text-[#C5A059]" />
                    <span>إضافة إلى الحقيبة</span>
                  </>
                )}
              </button>

              {/* Wishlist */}
              <button
                onClick={() => toggleWishlist(product.id)}
                className="w-12 h-12 rounded-xl border border-[#EAE0D5] bg-white flex items-center justify-center text-[#342419] hover:text-[#A82B2B] transition-colors shadow-sm"
              >
                <Heart
                  className={`w-5 h-5 ${
                    isInWishlist(product.id) ? 'fill-[#A82B2B] text-[#A82B2B]' : ''
                  }`}
                />
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
