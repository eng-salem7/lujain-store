'use client';

import React, { useState } from 'react';
import AdminSidebar from '@/components/AdminSidebar';
import { INITIAL_PRODUCTS } from '@/lib/mockData';
import { Product, ProductVariant } from '@/types';
import { 
  Package, 
  Search, 
  AlertTriangle, 
  Plus, 
  Minus, 
  CheckCircle2, 
  Sparkles,
  Layers
} from 'lucide-react';

export default function AdminInventoryPage() {
  const [products, setProducts] = useState<Product[]>(INITIAL_PRODUCTS);
  const [searchQuery, setSearchQuery] = useState('');
  const [filterLowStock, setFilterLowStock] = useState(false);

  // Update Stock function
  const handleUpdateStock = (productId: string, variantId: string, delta: number) => {
    setProducts((prev) =>
      prev.map((p) => {
        if (p.id !== productId) return p;
        return {
          ...p,
          variants: p.variants.map((v) => {
            if (v.id !== variantId) return v;
            const currentStock = v.stock || 0;
            const newStock = Math.max(0, currentStock + delta);
            return { ...v, stock: newStock };
          }),
        };
      })
    );
  };

  // Flattened variant rows for inventory table
  const rows: {
    product: Product;
    variant: ProductVariant;
  }[] = [];

  products.forEach((p) => {
    p.variants.forEach((v) => {
      const isLow = (v.stock || 0) <= 3;
      if (filterLowStock && !isLow) return;
      if (
        searchQuery &&
        !p.name_ar.toLowerCase().includes(searchQuery.toLowerCase()) &&
        !v.sku.toLowerCase().includes(searchQuery.toLowerCase())
      ) {
        return;
      }
      rows.push({ product: p, variant: v });
    });
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex flex-col lg:flex-row gap-8">
        <AdminSidebar />

        <div className="flex-1 space-y-6">
          {/* Header */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-6 rounded-3xl border border-[#EAE0D5] shadow-sm">
            <div>
              <span className="text-xs font-bold text-[#C5A059] uppercase tracking-wider block">
                متابعة الأرصدة والمقاسات والألوان
              </span>
              <h1 className="text-2xl font-black text-[#342419] mt-0.5">
                إدارة المخزون والمتغيرات (SKU)
              </h1>
            </div>

            <div className="flex items-center gap-2">
              <button
                onClick={() => setFilterLowStock(!filterLowStock)}
                className={`px-4 py-2 rounded-xl text-xs font-bold flex items-center gap-1.5 transition-all ${
                  filterLowStock
                    ? 'bg-red-600 text-white'
                    : 'bg-red-50 text-red-700 border border-red-200 hover:bg-red-100'
                }`}
              >
                <AlertTriangle className="w-3.5 h-3.5" />
                <span>المنخفض فقط</span>
              </button>
            </div>
          </div>

          {/* Search bar */}
          <div className="bg-white p-4 rounded-2xl border border-[#EAE0D5] shadow-sm">
            <div className="relative">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="ابحث باسم الموديل أو رمز SKU (مثال: LUJ-DRS-01)..."
                className="w-full pl-8 pr-4 py-2.5 rounded-xl border border-[#EAE0D5] text-xs bg-[#FAF7F2] focus:outline-none focus:border-[#C5A059]"
              />
              <Search className="w-4 h-4 text-gray-400 absolute left-3 top-3" />
            </div>
          </div>

          {/* Inventory Table */}
          <div className="bg-white rounded-3xl border border-[#EAE0D5] overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-right text-xs">
                <thead>
                  <tr className="bg-[#FAF7F2] text-[#8C7A6B] border-b border-[#EAE0D5]">
                    <th className="p-4">المنتج والموديل</th>
                    <th className="p-4">كود SKU</th>
                    <th className="p-4">اللون</th>
                    <th className="p-4">المقاس</th>
                    <th className="p-4">سعر البيع (YER)</th>
                    <th className="p-4">التكلفة (YER)</th>
                    <th className="p-4 text-center">الرصيد المتبقي</th>
                    <th className="p-4 text-center">تعديل المخزون</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#EAE0D5]">
                  {rows.map(({ product, variant }) => {
                    const isLow = (variant.stock || 0) <= 3;
                    return (
                      <tr key={variant.id} className="hover:bg-[#FAF7F2]/50 transition-colors">
                        <td className="p-4">
                          <div className="flex items-center gap-3">
                            <img
                              src={product.images[0]?.image_url}
                              alt=""
                              className="w-10 h-12 rounded-lg object-cover bg-gray-100"
                            />
                            <div>
                              <strong className="block text-[#342419]">{product.name_ar}</strong>
                              <span className="text-[10px] text-[#8C7A6B]">{product.fabric_details}</span>
                            </div>
                          </div>
                        </td>

                        <td className="p-4 font-mono font-bold text-[#342419]">
                          {variant.sku}
                        </td>

                        <td className="p-4">
                          <div className="flex items-center gap-1.5">
                            <span
                              className="w-3.5 h-3.5 rounded-full border border-black/10"
                              style={{ backgroundColor: variant.color_hex }}
                            />
                            <span className="font-medium text-[#342419]">{variant.color_name_ar}</span>
                          </div>
                        </td>

                        <td className="p-4 font-bold text-[#342419]">
                          {variant.size}
                        </td>

                        <td className="p-4 font-bold text-[#342419]">
                          {(product.discount_price || product.base_price).toLocaleString('ar-YE')}
                        </td>

                        <td className="p-4 font-mono text-[#8C7A6B]">
                          {variant.cost_price.toLocaleString('ar-YE')}
                        </td>

                        {/* Stock Balance Indicator */}
                        <td className="p-4 text-center">
                          <span
                            className={`inline-block px-3 py-1 rounded-full font-bold text-[11px] ${
                              isLow
                                ? 'bg-red-100 text-red-800 animate-pulse'
                                : 'bg-emerald-100 text-emerald-800'
                            }`}
                          >
                            {variant.stock || 0} قطع
                          </span>
                        </td>

                        {/* Quick stock +/- adjuster */}
                        <td className="p-4 text-center">
                          <div className="inline-flex items-center border border-[#EAE0D5] rounded-xl overflow-hidden bg-[#FAF7F2]">
                            <button
                              onClick={() => handleUpdateStock(product.id, variant.id, -1)}
                              className="px-2.5 py-1 text-gray-700 hover:bg-[#EAE0D5] transition-colors"
                              title="خصم قطعة"
                            >
                              <Minus className="w-3 h-3" />
                            </button>
                            <span className="px-2 font-mono font-bold text-xs">{variant.stock || 0}</span>
                            <button
                              onClick={() => handleUpdateStock(product.id, variant.id, 1)}
                              className="px-2.5 py-1 text-gray-700 hover:bg-[#EAE0D5] transition-colors"
                              title="إضافة توريد قطعة"
                            >
                              <Plus className="w-3 h-3" />
                            </button>
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
