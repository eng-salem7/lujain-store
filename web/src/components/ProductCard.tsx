'use client';

import React, { useState } from 'react';
import Image from 'next/image';
import Link from 'next/link';
import { Product, ProductVariant } from '@/types';
import { useStore } from '@/lib/store';
import { Heart, ShoppingBag, Eye, Check } from 'lucide-react';

interface ProductCardProps {
  product: Product;
  onQuickView?: (product: Product) => void;
}

export default function ProductCard({ product, onQuickView }: ProductCardProps) {
  const { addToCart, toggleWishlist, isInWishlist, formatPrice } = useStore();
  const [selectedVariant, setSelectedVariant] = useState<ProductVariant>(product.variants[0]);
  const [isAdded, setIsAdded] = useState(false);

  const primaryImage = product.images?.find((img) => img.is_primary)?.image_url || product.images?.[0]?.image_url || '';
  const hasDiscount = product.discount_price && product.discount_price < product.base_price;
  const discountPercent = hasDiscount
    ? Math.round(((product.base_price - product.discount_price!) / product.base_price) * 100)
    : 0;
  const savings = hasDiscount ? product.base_price - product.discount_price! : 0;

  const handleAddToCart = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    if (!selectedVariant) return;

    addToCart(product, selectedVariant, 1);
    setIsAdded(true);
    setTimeout(() => setIsAdded(false), 1800);
  };

  const handleWishlist = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    toggleWishlist(product.id);
  };

  return (
    <div className="group bg-[#FAF7F2] rounded-2xl overflow-hidden border border-[#EAE0D5] hover:border-[#C5A059]/60 hover:shadow-xl transition-all duration-300 flex flex-col justify-between">
      {/* Product Image Box */}
      <div className="relative aspect-[3/4] w-full bg-[#F3ECE2] overflow-hidden">
        {primaryImage && (
          <img
            src={primaryImage}
            alt={product.name_ar}
            className="w-full h-full object-cover object-top group-hover:scale-105 transition-transform duration-500"
          />
        )}

        {/* Badges */}
        <div className="absolute top-3 right-3 flex flex-col gap-1.5 z-10">
          {hasDiscount && (
            <span className="bg-[#A82B2B] text-white text-[11px] font-extrabold px-2.5 py-1 rounded-full shadow-sm">
              خصم {discountPercent}%
            </span>
          )}
          {product.is_new && (
            <span className="bg-[#342419] text-[#FAF7F2] text-[10px] font-bold px-2 py-0.5 rounded-full shadow-sm">
              وصل حديثاً
            </span>
          )}
        </div>

        {/* Wishlist Button */}
        <button
          onClick={handleWishlist}
          aria-label="إضافة للمفضلة"
          className="absolute top-3 left-3 w-9 h-9 rounded-full bg-white/80 backdrop-blur-sm flex items-center justify-center text-[#342419] hover:text-[#A82B2B] hover:bg-white transition-all shadow-sm z-10"
        >
          <Heart
            className={`w-4 h-4 transition-colors ${
              isInWishlist(product.id) ? 'fill-[#A82B2B] text-[#A82B2B]' : ''
            }`}
          />
        </button>

        {/* Quick View Button on Hover */}
        {onQuickView && (
          <div className="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
            <button
              onClick={() => onQuickView(product)}
              className="bg-[#FAF7F2]/95 text-[#342419] font-bold text-xs px-4 py-2.5 rounded-full shadow-lg hover:bg-[#342419] hover:text-white transition-colors flex items-center gap-1.5"
            >
              <Eye className="w-4 h-4 text-[#C5A059]" />
              نظرة سريعة
            </button>
          </div>
        )}
      </div>

      {/* Product Details Content */}
      <div className="p-4 sm:p-5 flex flex-col flex-grow justify-between">
        <div>
          {/* Fabric & SKU info */}
          <div className="flex items-center justify-between text-[11px] text-[#8C7A6B] mb-1.5 font-medium">
            <span>{product.fabric_details || 'أقمشة فاخرة'}</span>
            <span className="font-mono text-[10px]">{selectedVariant?.sku}</span>
          </div>

          {/* Product Title */}
          <h3 className="font-bold text-[#342419] text-sm sm:text-base leading-snug line-clamp-2 hover:text-[#C5A059] transition-colors mb-2">
            {product.name_ar}
          </h3>

          {/* Color & Size Variant Selectors */}
          {product.variants && product.variants.length > 0 && (
            <div className="space-y-2 my-2.5 pt-2 border-t border-[#EAE0D5]/60">
              {/* Colors */}
              <div className="flex items-center gap-1.5">
                <span className="text-[11px] text-[#8C7A6B] ml-1">اللون:</span>
                <div className="flex items-center gap-1 flex-wrap">
                  {Array.from(new Set(product.variants.map((v) => v.color_hex))).map((hex) => {
                    const match = product.variants.find((v) => v.color_hex === hex);
                    const isSelected = selectedVariant?.color_hex === hex;
                    return (
                      <button
                        key={hex}
                        type="button"
                        onClick={() => match && setSelectedVariant(match)}
                        title={match?.color_name_ar}
                        className={`w-4 h-4 rounded-full border transition-all ${
                          isSelected ? 'ring-2 ring-[#C5A059] scale-110' : 'border-gray-300'
                        }`}
                        style={{ backgroundColor: hex }}
                      />
                    );
                  })}
                </div>
              </div>

              {/* Sizes */}
              <div className="flex items-center gap-1.5">
                <span className="text-[11px] text-[#8C7A6B] ml-1">المقاس:</span>
                <div className="flex items-center gap-1 flex-wrap">
                  {product.variants.map((v) => (
                    <button
                      key={v.id}
                      type="button"
                      onClick={() => setSelectedVariant(v)}
                      className={`text-[10px] px-2 py-0.5 rounded border font-semibold transition-all ${
                        selectedVariant?.id === v.id
                          ? 'bg-[#342419] text-[#FAF7F2] border-[#342419]'
                          : 'bg-white text-[#342419] border-[#EAE0D5] hover:border-[#C5A059]'
                      }`}
                    >
                      {v.size}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Pricing & Add to Cart Button */}
        <div className="pt-3 border-t border-[#EAE0D5]/60 mt-2 flex items-center justify-between gap-2">
          <div>
            <div className="flex items-baseline gap-1.5">
              <span className="text-base sm:text-lg font-black text-[#342419]">
                {formatPrice(product.discount_price || product.base_price)}
              </span>
              {hasDiscount && (
                <span className="text-xs text-[#A08E80] line-through font-medium">
                  {formatPrice(product.base_price)}
                </span>
              )}
            </div>
            {hasDiscount && (
              <span className="text-[10px] text-emerald-700 font-bold block">
                توفير: {formatPrice(savings)}
              </span>
            )}
          </div>

          <button
            onClick={handleAddToCart}
            disabled={isAdded}
            className={`p-2.5 sm:px-3 sm:py-2 rounded-xl font-bold text-xs flex items-center gap-1.5 transition-all shadow-sm ${
              isAdded
                ? 'bg-emerald-700 text-white'
                : 'bg-[#342419] hover:bg-[#C5A059] text-white hover:shadow-md'
            }`}
          >
            {isAdded ? (
              <>
                <Check className="w-4 h-4" />
                <span className="hidden sm:inline">أُضيفت!</span>
              </>
            ) : (
              <>
                <ShoppingBag className="w-4 h-4 text-[#C5A059] group-hover:text-white" />
                <span className="hidden sm:inline">إضافة</span>
              </>
            )}
          </button>
        </div>
      </div>
    </div>
  );
}
