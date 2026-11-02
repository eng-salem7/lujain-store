'use client';

import React from 'react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { 
  LayoutDashboard, 
  ShoppingBag, 
  Layers, 
  Package, 
  Wallet, 
  TrendingUp, 
  Store,
  ShieldCheck,
  ChevronRight
} from 'lucide-react';

export default function AdminSidebar() {
  const pathname = usePathname();

  const navItems = [
    { label: 'لوحة التحكم والمؤشرات', href: '/admin', icon: LayoutDashboard },
    { label: 'إدارة الطلبات والحالات', href: '/admin/orders', icon: ShoppingBag },
    { label: 'المنتجات والمتغيرات', href: '/admin/inventory', icon: Package },
    { label: 'المالية والمحافظ والصندوق', href: '/admin/finance', icon: Wallet },
  ];

  return (
    <aside className="w-full lg:w-64 bg-white rounded-3xl border border-[#EAE0D5] p-5 shadow-sm space-y-6">
      {/* Brand Header */}
      <div className="flex items-center gap-3 pb-5 border-b border-[#EAE0D5]">
        <div className="w-10 h-10 rounded-xl bg-[#342419] flex items-center justify-center text-[#C5A059] shadow-md">
          <ShieldCheck className="w-6 h-6" />
        </div>
        <div>
          <h2 className="text-sm font-black text-[#342419] leading-tight">إدارة متجر لجين</h2>
          <span className="text-[10px] text-[#C5A059] font-bold">LUJAIN ADMIN HUB</span>
        </div>
      </div>

      {/* Nav items */}
      <nav className="space-y-1.5">
        {navItems.map((item) => {
          const isActive = pathname === item.href;
          const Icon = item.icon;
          return (
            <Link
              key={item.href}
              href={item.href}
              className={`flex items-center justify-between px-3.5 py-3 rounded-2xl text-xs font-bold transition-all ${
                isActive
                  ? 'bg-[#342419] text-[#FAF7F2] shadow-md'
                  : 'text-[#6E5A4E] hover:bg-[#FAF7F2] hover:text-[#342419]'
              }`}
            >
              <div className="flex items-center gap-2.5">
                <Icon className={`w-4 h-4 ${isActive ? 'text-[#C5A059]' : 'text-gray-400'}`} />
                <span>{item.label}</span>
              </div>
              <ChevronRight className={`w-3.5 h-3.5 ${isActive ? 'text-[#C5A059]' : 'text-gray-300'}`} />
            </Link>
          );
        })}
      </nav>

      {/* Return to Public Store link */}
      <div className="pt-4 border-t border-[#EAE0D5]">
        <Link
          href="/"
          className="flex items-center gap-2 px-3.5 py-2.5 rounded-xl text-xs font-semibold text-[#8C7A6B] hover:text-[#C5A059] hover:bg-[#FAF7F2] transition-colors"
        >
          <Store className="w-4 h-4" />
          <span>العودة للمتجر الرئيسي</span>
        </Link>
      </div>
    </aside>
  );
}
