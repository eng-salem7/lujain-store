'use client';

import React, { useState } from 'react';
import Link from 'next/link';
import { useStore } from '@/lib/store';
import { ShoppingBag, Heart, Search, ShieldCheck, Menu, X, Sparkles } from 'lucide-react';

export default function Navbar() {
  const { cartCount, wishlist, setIsCartOpen } = useStore();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <header className="sticky top-0 z-40 bg-[#FAF7F2]/95 backdrop-blur-md border-b border-[#EAE0D5] transition-all">
      {/* Top Banner */}
      <div className="bg-[#342419] text-[#FAF7F2] text-xs py-2 px-4 text-center font-medium flex items-center justify-center gap-2">
        <Sparkles className="w-3.5 h-3.5 text-[#C5A059] animate-pulse" />
        <span>شحن مجاني لكافة المحافظات اليمنية للطلبات فوق 50,000 ر.ي • كود خصم: <strong>LUJAIN10</strong></span>
      </div>

      {/* Main Navbar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-20">
          {/* Mobile Menu Button */}
          <div className="flex items-center lg:hidden">
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="p-2 text-[#342419] hover:text-[#C5A059] transition-colors"
              aria-label="القائمة"
            >
              {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>

          {/* Brand Logo & Slogan */}
          <div className="flex items-center gap-4">
            <Link href="/" className="flex flex-col items-center sm:items-start group">
              <span className="text-2xl sm:text-3xl font-extrabold tracking-wider text-[#342419] group-hover:text-[#C5A059] transition-colors">
                لُــجَــيْــن
              </span>
              <span className="text-[10px] sm:text-xs font-semibold tracking-widest text-[#C5A059] uppercase -mt-1">
                LUJAIN FASHION
              </span>
            </Link>
          </div>

          {/* Desktop Navigation Links */}
          <nav className="hidden lg:flex items-center gap-8 text-sm font-semibold text-[#342419]">
            <Link href="/" className="hover:text-[#C5A059] transition-colors py-1 border-b-2 border-transparent hover:border-[#C5A059]">
              الرئيسية
            </Link>
            <Link href="/#products" className="hover:text-[#C5A059] transition-colors py-1 border-b-2 border-transparent hover:border-[#C5A059]">
              كل التشكيلة
            </Link>
            <Link href="/#categories" className="hover:text-[#C5A059] transition-colors py-1 border-b-2 border-transparent hover:border-[#C5A059]">
              الأقسام
            </Link>
            <Link href="/track-order" className="hover:text-[#C5A059] transition-colors py-1 border-b-2 border-transparent hover:border-[#C5A059]">
              تتبع طلبك
            </Link>
            <Link href="/admin" className="text-xs px-2.5 py-1 bg-[#F3ECE2] border border-[#C5A059]/40 text-[#6E482F] rounded-full hover:bg-[#342419] hover:text-[#FAF7F2] transition-colors flex items-center gap-1">
              <ShieldCheck className="w-3.5 h-3.5 text-[#C5A059]" />
              لوحة الإدارة
            </Link>
          </nav>

          {/* Actions: Wishlist, Cart Drawer Trigger */}
          <div className="flex items-center gap-3">
            <Link
              href="/#products"
              className="p-2 text-[#342419] hover:text-[#C5A059] transition-colors"
              title="البحث"
            >
              <Search className="w-5 h-5" />
            </Link>

            <Link
              href="/#products"
              className="p-2 text-[#342419] hover:text-[#C5A059] transition-colors relative"
              title="المفضلة"
            >
              <Heart className="w-5 h-5" />
              {wishlist.length > 0 && (
                <span className="absolute top-1 -right-1 bg-[#C5A059] text-white text-[10px] w-4 h-4 rounded-full flex items-center justify-center font-bold">
                  {wishlist.length}
                </span>
              )}
            </Link>

            <button
              onClick={() => setIsCartOpen(true)}
              className="flex items-center gap-2 bg-[#342419] hover:bg-[#C5A059] text-[#FAF7F2] px-4 py-2.5 rounded-full transition-all duration-300 shadow-md hover:shadow-lg group"
            >
              <ShoppingBag className="w-4 h-4 text-[#C5A059] group-hover:text-white transition-colors" />
              <span className="text-xs font-bold font-sans">حقيبة التسوق</span>
              <span className="bg-[#FAF7F2] text-[#342419] text-xs font-bold px-2 py-0.5 rounded-full">
                {cartCount}
              </span>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="lg:hidden bg-[#FAF7F2] border-b border-[#EAE0D5] px-4 pt-2 pb-6 space-y-3">
          <Link
            href="/"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-[#342419] border-b border-[#EAE0D5]"
          >
            الرئيسية
          </Link>
          <Link
            href="/#products"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-[#342419] border-b border-[#EAE0D5]"
          >
            كل التشكيلة
          </Link>
          <Link
            href="/#categories"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-[#342419] border-b border-[#EAE0D5]"
          >
            الأقسام
          </Link>
          <Link
            href="/track-order"
            onClick={() => setMobileMenuOpen(false)}
            className="block py-2 text-base font-semibold text-[#342419] border-b border-[#EAE0D5]"
          >
            تتبع طلبك
          </Link>
          <Link
            href="/admin"
            onClick={() => setMobileMenuOpen(false)}
            className="flex items-center gap-2 py-2 text-base font-semibold text-[#C5A059]"
          >
            <ShieldCheck className="w-4 h-4" />
            تطبيق ولوحة الإدارة
          </Link>
        </div>
      )}
    </header>
  );
}
