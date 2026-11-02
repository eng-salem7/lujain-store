'use client';

import React, { useState } from 'react';
import AdminSidebar from '@/components/AdminSidebar';
import { INITIAL_ORDERS } from '@/lib/mockData';
import { Order, OrderStatus } from '@/types';
import { 
  ShoppingBag, 
  Search, 
  CheckCircle2, 
  XCircle, 
  Truck, 
  Clock, 
  FileText,
  MapPin,
  Calendar
} from 'lucide-react';

export default function AdminOrdersPage() {
  const [orders, setOrders] = useState<Order[]>(INITIAL_ORDERS);
  const [statusFilter, setStatusFilter] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState('');
  const [selectedOrder, setSelectedOrder] = useState<Order | null>(null);

  // Status changer
  const handleUpdateStatus = (orderId: string, newStatus: OrderStatus) => {
    setOrders((prev) =>
      prev.map((o) => (o.id === orderId ? { ...o, status: newStatus } : o))
    );
    if (selectedOrder && selectedOrder.id === orderId) {
      setSelectedOrder((prev) => (prev ? { ...prev, status: newStatus } : null));
    }
  };

  const filteredOrders = orders.filter((o) => {
    const matchesStatus = statusFilter === 'all' || o.status === statusFilter;
    const matchesSearch =
      o.order_number.toLowerCase().includes(searchQuery.toLowerCase()) ||
      (o.guest_name && o.guest_name.toLowerCase().includes(searchQuery.toLowerCase())) ||
      (o.guest_phone && o.guest_phone.includes(searchQuery));
    return matchesStatus && matchesSearch;
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
                متابعة حركة المبيعات والشحنات
              </span>
              <h1 className="text-2xl font-black text-[#342419] mt-0.5">
                إدارة الطلبات والحالات
              </h1>
            </div>

            <span className="text-xs font-bold px-3 py-1 bg-[#FAF7F2] border border-[#EAE0D5] text-[#342419] rounded-xl">
              إجمالي الطلبات: {orders.length}
            </span>
          </div>

          {/* Controls */}
          <div className="bg-white p-4 sm:p-5 rounded-2xl border border-[#EAE0D5] shadow-sm flex flex-col sm:flex-row items-center justify-between gap-4">
            {/* Filter Tabs */}
            <div className="flex items-center gap-1.5 overflow-x-auto w-full sm:w-auto pb-2 sm:pb-0">
              <button
                onClick={() => setStatusFilter('all')}
                className={`text-xs px-3.5 py-1.5 rounded-xl font-bold whitespace-nowrap transition-all ${
                  statusFilter === 'all'
                    ? 'bg-[#342419] text-white'
                    : 'bg-[#FAF7F2] text-[#6E482F] hover:bg-[#EAE0D5]'
                }`}
              >
                الكل ({orders.length})
              </button>
              <button
                onClick={() => setStatusFilter('new')}
                className={`text-xs px-3.5 py-1.5 rounded-xl font-bold whitespace-nowrap transition-all ${
                  statusFilter === 'new'
                    ? 'bg-blue-600 text-white'
                    : 'bg-[#FAF7F2] text-blue-700 hover:bg-[#EAE0D5]'
                }`}
              >
                جديدة ({orders.filter((o) => o.status === 'new').length})
              </button>
              <button
                onClick={() => setStatusFilter('accepted_preparing')}
                className={`text-xs px-3.5 py-1.5 rounded-xl font-bold whitespace-nowrap transition-all ${
                  statusFilter === 'accepted_preparing'
                    ? 'bg-amber-600 text-white'
                    : 'bg-[#FAF7F2] text-amber-700 hover:bg-[#EAE0D5]'
                }`}
              >
                قيد التجهيز ({orders.filter((o) => o.status === 'accepted_preparing').length})
              </button>
              <button
                onClick={() => setStatusFilter('completed')}
                className={`text-xs px-3.5 py-1.5 rounded-xl font-bold whitespace-nowrap transition-all ${
                  statusFilter === 'completed'
                    ? 'bg-emerald-700 text-white'
                    : 'bg-[#FAF7F2] text-emerald-800 hover:bg-[#EAE0D5]'
                }`}
              >
                مكتملة ({orders.filter((o) => o.status === 'completed').length})
              </button>
            </div>

            {/* Search */}
            <div className="relative w-full sm:w-64">
              <input
                type="text"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                placeholder="ابحث برقم الطلب أو الاسم..."
                className="w-full pl-8 pr-3 py-2 text-xs rounded-xl border border-[#EAE0D5] bg-[#FAF7F2] focus:outline-none focus:border-[#C5A059]"
              />
              <Search className="w-3.5 h-3.5 text-gray-400 absolute left-2.5 top-2.5" />
            </div>
          </div>

          {/* Orders Table */}
          <div className="bg-white rounded-3xl border border-[#EAE0D5] overflow-hidden shadow-sm">
            <div className="overflow-x-auto">
              <table className="w-full text-right text-xs">
                <thead>
                  <tr className="bg-[#FAF7F2] text-[#8C7A6B] border-b border-[#EAE0D5]">
                    <th className="p-4">رقم الطلب</th>
                    <th className="p-4">العميلة والتواصل</th>
                    <th className="p-4">المدينة والعنوان</th>
                    <th className="p-4">المبلغ الإجمالي</th>
                    <th className="p-4">الحالة الحالية</th>
                    <th className="p-4 text-center">إجراءات الحالة</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#EAE0D5]">
                  {filteredOrders.map((o) => (
                    <tr key={o.id} className="hover:bg-[#FAF7F2]/50 transition-colors">
                      <td className="p-4">
                        <span className="font-mono font-bold text-[#342419] block">{o.order_number}</span>
                        <span className="text-[10px] text-[#8C7A6B]">
                          {new Date(o.created_at).toLocaleDateString('ar-YE')}
                        </span>
                      </td>

                      <td className="p-4">
                        <strong className="block text-[#342419]">{o.guest_name}</strong>
                        <span className="text-[11px] text-[#8C7A6B] font-mono">{o.guest_phone}</span>
                      </td>

                      <td className="p-4 text-[#6E482F]">
                        <span className="font-bold">{o.shipping_address_snapshot.city}</span>
                        <span className="block text-[11px] text-[#8C7A6B]">
                          {o.shipping_address_snapshot.area}
                        </span>
                      </td>

                      <td className="p-4">
                        <strong className="text-[#342419] text-sm">
                          {o.total_amount.toLocaleString('ar-YE')} ر.ي
                        </strong>
                        <span className="block text-[10px] text-[#C5A059] font-semibold">
                          {o.payments?.[0]?.payment_method || 'نقداً'}
                        </span>
                      </td>

                      <td className="p-4">
                        <span
                          className={`inline-block px-3 py-1 rounded-full text-[10px] font-bold ${
                            o.status === 'completed'
                              ? 'bg-emerald-100 text-emerald-800'
                              : o.status === 'accepted_preparing'
                              ? 'bg-amber-100 text-amber-800'
                              : o.status === 'cancelled'
                              ? 'bg-red-100 text-red-800'
                              : 'bg-blue-100 text-blue-800'
                          }`}
                        >
                          {o.status === 'completed' && 'مكتمل ومسلَّم'}
                          {o.status === 'accepted_preparing' && 'مقبول وقيد التجهيز'}
                          {o.status === 'new' && 'طلب جديد'}
                          {o.status === 'cancelled' && 'ملغي'}
                        </span>
                      </td>

                      {/* Actions */}
                      <td className="p-4">
                        <div className="flex items-center justify-center gap-1.5 flex-wrap">
                          {o.status === 'new' && (
                            <button
                              onClick={() => handleUpdateStatus(o.id, 'accepted_preparing')}
                              className="px-2.5 py-1 bg-[#342419] hover:bg-[#C5A059] text-white rounded-lg text-[10px] font-bold transition-colors"
                            >
                              قبول وحجز
                            </button>
                          )}
                          {o.status === 'accepted_preparing' && (
                            <button
                              onClick={() => handleUpdateStatus(o.id, 'completed')}
                              className="px-2.5 py-1 bg-emerald-700 hover:bg-emerald-800 text-white rounded-lg text-[10px] font-bold transition-colors"
                            >
                              تأكيد التسليم
                            </button>
                          )}
                          {o.status !== 'cancelled' && o.status !== 'completed' && (
                            <button
                              onClick={() => handleUpdateStatus(o.id, 'cancelled')}
                              className="px-2 py-1 bg-red-50 hover:bg-red-100 text-red-700 rounded-lg text-[10px] font-bold transition-colors"
                            >
                              إلغاء
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
