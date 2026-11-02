'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import AdminSidebar from '@/components/AdminSidebar';
import { INITIAL_ORDERS, INITIAL_PRODUCTS, INITIAL_CASH_ACCOUNTS } from '@/lib/mockData';
import { 
  TrendingUp, 
  ShoppingBag, 
  AlertTriangle, 
  Wallet, 
  Clock, 
  CheckCircle2, 
  Truck,
  ArrowUpRight,
  ShieldCheck
} from 'lucide-react';

export default function AdminDashboardPage() {
  const [orders, setOrders] = useState(INITIAL_ORDERS);

  // Compute key stats
  const totalSales = orders.reduce((sum, o) => sum + (o.status !== 'cancelled' ? o.total_amount : 0), 0);
  const totalCashBalance = INITIAL_CASH_ACCOUNTS.reduce((sum, a) => sum + a.current_balance, 0);

  // Find low stock variants
  const lowStockItems: { productName: string; sku: string; color: string; size: string; stock: number }[] = [];
  INITIAL_PRODUCTS.forEach((p) => {
    p.variants.forEach((v) => {
      if ((v.stock || 0) <= 3) {
        lowStockItems.push({
          productName: p.name_ar,
          sku: v.sku,
          color: v.color_name_ar,
          size: v.size,
          stock: v.stock || 0,
        });
      }
    });
  });

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex flex-col lg:flex-row gap-8">
        {/* Sidebar */}
        <AdminSidebar />

        {/* Main Content Area */}
        <div className="flex-1 space-y-8">
          {/* Header */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-6 rounded-3xl border border-[#EAE0D5] shadow-sm">
            <div>
              <span className="text-xs font-bold text-[#C5A059] uppercase tracking-wider block">
                نظام إدارة العمليات الشامل
              </span>
              <h1 className="text-2xl font-black text-[#342419] mt-0.5">
                لوحة المعلومات والمؤشرات التشغيلية
              </h1>
            </div>

            <div className="flex items-center gap-2">
              <span className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                <span className="w-2 h-2 rounded-full bg-emerald-500 animate-ping" />
                المتجر وقاعدة البيانات متصلان
              </span>
            </div>
          </div>

          {/* 4 Stat Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {/* Stat 1: Total Sales */}
            <div className="bg-white p-5 rounded-2xl border border-[#EAE0D5] shadow-sm flex flex-col justify-between space-y-3">
              <div className="flex justify-between items-start">
                <span className="text-xs font-semibold text-[#8C7A6B]">إجمالي المبيعات</span>
                <div className="w-8 h-8 rounded-lg bg-[#FAF7F2] text-[#C5A059] flex items-center justify-center">
                  <TrendingUp className="w-4 h-4" />
                </div>
              </div>
              <div>
                <span className="text-2xl font-black text-[#342419]">
                  {totalSales.toLocaleString('ar-YE')}
                </span>
                <span className="text-xs font-bold text-[#C5A059] mr-1">ر.ي</span>
              </div>
              <span className="text-[10px] text-emerald-600 font-bold flex items-center gap-1">
                <ArrowUpRight className="w-3 h-3" />
                محدثة لحظياً من الطلبات
              </span>
            </div>

            {/* Stat 2: Orders Count */}
            <div className="bg-white p-5 rounded-2xl border border-[#EAE0D5] shadow-sm flex flex-col justify-between space-y-3">
              <div className="flex justify-between items-start">
                <span className="text-xs font-semibold text-[#8C7A6B]">عدد الطلبات الكلي</span>
                <div className="w-8 h-8 rounded-lg bg-[#FAF7F2] text-[#C5A059] flex items-center justify-center">
                  <ShoppingBag className="w-4 h-4" />
                </div>
              </div>
              <div>
                <span className="text-2xl font-black text-[#342419]">{orders.length}</span>
                <span className="text-xs font-bold text-[#8C7A6B] mr-1">طلبات</span>
              </div>
              <span className="text-[10px] text-[#8C7A6B]">
                {orders.filter((o) => o.status === 'new').length} طلبات جديدة بحاجة لمراجعة
              </span>
            </div>

            {/* Stat 3: Low Stock Alerts */}
            <div className="bg-white p-5 rounded-2xl border border-[#EAE0D5] shadow-sm flex flex-col justify-between space-y-3">
              <div className="flex justify-between items-start">
                <span className="text-xs font-semibold text-[#8C7A6B]">تنبيهات المخزون</span>
                <div className="w-8 h-8 rounded-lg bg-red-50 text-red-600 flex items-center justify-center">
                  <AlertTriangle className="w-4 h-4" />
                </div>
              </div>
              <div>
                <span className="text-2xl font-black text-red-600">{lowStockItems.length}</span>
                <span className="text-xs font-bold text-red-600 mr-1">أصناف قاربت النفاد</span>
              </div>
              <span className="text-[10px] text-red-500 font-bold">
                تحتاج لتوريد فوري
              </span>
            </div>

            {/* Stat 4: Cash & E-wallets */}
            <div className="bg-white p-5 rounded-2xl border border-[#EAE0D5] shadow-sm flex flex-col justify-between space-y-3">
              <div className="flex justify-between items-start">
                <span className="text-xs font-semibold text-[#8C7A6B]">أرصدة الصناديق والمحافظ</span>
                <div className="w-8 h-8 rounded-lg bg-[#FAF7F2] text-[#C5A059] flex items-center justify-center">
                  <Wallet className="w-4 h-4" />
                </div>
              </div>
              <div>
                <span className="text-2xl font-black text-[#342419]">
                  {totalCashBalance.toLocaleString('ar-YE')}
                </span>
                <span className="text-xs font-bold text-[#C5A059] mr-1">ر.ي</span>
              </div>
              <span className="text-[10px] text-[#8C7A6B]">
                الكاش + الكريمي + فلوسك + جوالي
              </span>
            </div>
          </div>

          {/* Recent Orders Section */}
          <div className="bg-white rounded-3xl border border-[#EAE0D5] p-6 shadow-sm space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-[#EAE0D5]">
              <h2 className="text-base font-bold text-[#342419] flex items-center gap-2">
                <ShoppingBag className="w-5 h-5 text-[#C5A059]" />
                <span>أحدث الطلبات المستلمة</span>
              </h2>
              <Link
                href="/admin/orders"
                className="text-xs font-bold text-[#C5A059] hover:underline"
              >
                عرض كافة الطلبات ({orders.length}) ←
              </Link>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-right text-xs">
                <thead>
                  <tr className="bg-[#FAF7F2] text-[#8C7A6B] border-b border-[#EAE0D5]">
                    <th className="p-3">رقم الطلب</th>
                    <th className="p-3">العميلة</th>
                    <th className="p-3">المنطقة</th>
                    <th className="p-3">المبلغ</th>
                    <th className="p-3">طريقة الدفع</th>
                    <th className="p-3">الحالة</th>
                    <th className="p-3 text-center">الإجراء</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#EAE0D5]">
                  {orders.map((o) => (
                    <tr key={o.id} className="hover:bg-[#FAF7F2]/50 transition-colors">
                      <td className="p-3 font-mono font-bold text-[#342419]">{o.order_number}</td>
                      <td className="p-3 font-medium text-[#342419]">{o.guest_name}</td>
                      <td className="p-3 text-[#8C7A6B]">
                        {o.shipping_address_snapshot.city} - {o.shipping_address_snapshot.area}
                      </td>
                      <td className="p-3 font-bold text-[#342419]">
                        {o.total_amount.toLocaleString('ar-YE')} ر.ي
                      </td>
                      <td className="p-3 text-[#6E482F] font-semibold">
                        {o.payments?.[0]?.payment_method || 'نقداً'}
                      </td>
                      <td className="p-3">
                        <span
                          className={`inline-block px-2.5 py-1 rounded-full text-[10px] font-bold ${
                            o.status === 'completed'
                              ? 'bg-emerald-100 text-emerald-800'
                              : o.status === 'accepted_preparing'
                              ? 'bg-amber-100 text-amber-800'
                              : 'bg-blue-100 text-blue-800'
                          }`}
                        >
                          {o.status === 'completed' && 'مكتمل ومسلَّم'}
                          {o.status === 'accepted_preparing' && 'مقبول وقيد التجهيز'}
                          {o.status === 'new' && 'طلب جديد'}
                        </span>
                      </td>
                      <td className="p-3 text-center">
                        <Link
                          href={`/track-order?num=${o.order_number}`}
                          className="px-3 py-1 rounded-lg bg-[#FAF7F2] hover:bg-[#342419] hover:text-white text-[#342419] border border-[#EAE0D5] font-bold text-[11px] transition-colors"
                        >
                          معاينة
                        </Link>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>

          {/* Low Stock Warning Box */}
          <div className="bg-white rounded-3xl border border-[#EAE0D5] p-6 shadow-sm space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-[#EAE0D5]">
              <h2 className="text-base font-bold text-[#342419] flex items-center gap-2">
                <AlertTriangle className="w-5 h-5 text-red-500" />
                <span>أصناف شارفت على النفاد (تنبيهات المخزون)</span>
              </h2>
              <Link
                href="/admin/inventory"
                className="text-xs font-bold text-[#C5A059] hover:underline"
              >
                إدارة المخزون الكامل ←
              </Link>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
              {lowStockItems.map((item) => (
                <div
                  key={item.sku}
                  className="p-4 bg-red-50/50 rounded-2xl border border-red-100 space-y-1.5 text-xs"
                >
                  <strong className="block text-[#342419] line-clamp-1">{item.productName}</strong>
                  <div className="text-[#8C7A6B] flex items-center gap-2">
                    <span>{item.color}</span>
                    <span>•</span>
                    <span>مقاس {item.size}</span>
                  </div>
                  <div className="flex items-center justify-between pt-1">
                    <span className="font-mono text-[10px] text-gray-500">{item.sku}</span>
                    <span className="px-2 py-0.5 rounded-full bg-red-600 text-white font-bold text-[10px]">
                      المتبقي: {item.stock} قطع فقط
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
