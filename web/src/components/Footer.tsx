import React from 'react';
import Link from 'next/link';
import { Phone, Mail, MapPin, MessageCircle, HeartHandshake, ShieldCheck, Truck } from 'lucide-react';

export default function Footer() {
  return (
    <footer className="bg-[#241810] text-[#EFE8DE] pt-16 pb-8 border-t-2 border-[#C5A059]/30">
      {/* Features Bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pb-12 border-b border-[#3E2D22]">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 text-center md:text-right">
          <div className="flex items-center gap-4 bg-[#2C1D13] p-5 rounded-2xl border border-[#C5A059]/20">
            <div className="w-12 h-12 rounded-xl bg-[#C5A059]/20 flex items-center justify-center shrink-0">
              <Truck className="w-6 h-6 text-[#C5A059]" />
            </div>
            <div>
              <h4 className="font-bold text-white text-base">توصيل سريع لكافة المحافظات</h4>
              <p className="text-xs text-[#C5B7A9] mt-1">صنعاء، عدن، تعز، حضرموت، إب وكافة المناطق</p>
            </div>
          </div>

          <div className="flex items-center gap-4 bg-[#2C1D13] p-5 rounded-2xl border border-[#C5A059]/20">
            <div className="w-12 h-12 rounded-xl bg-[#C5A059]/20 flex items-center justify-center shrink-0">
              <ShieldCheck className="w-6 h-6 text-[#C5A059]" />
            </div>
            <div>
              <h4 className="font-bold text-white text-base">جودة أقمشة أصلية 100%</h4>
              <p className="text-xs text-[#C5B7A9] mt-1">مخمل كوري، كريب فرنسي، وحرير شيفون أصلي</p>
            </div>
          </div>

          <div className="flex items-center gap-4 bg-[#2C1D13] p-5 rounded-2xl border border-[#C5A059]/20">
            <div className="w-12 h-12 rounded-xl bg-[#C5A059]/20 flex items-center justify-center shrink-0">
              <HeartHandshake className="w-6 h-6 text-[#C5A059]" />
            </div>
            <div>
              <h4 className="font-bold text-white text-base">دفع آمن ومحافظ إلكترونية</h4>
              <p className="text-xs text-[#C5B7A9] mt-1">كاش، الكريمي حاسب، فلوسك، جوالي، ون كاش</p>
            </div>
          </div>
        </div>
      </div>

      {/* Main Footer Content */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-10">
          {/* Brand Col */}
          <div className="space-y-4">
            <div className="flex flex-col">
              <span className="text-3xl font-extrabold text-[#FAF7F2] tracking-wider">
                لُــجَــيْــن
              </span>
              <span className="text-xs font-semibold text-[#C5A059] tracking-widest uppercase">
                LUJAIN FASHION
              </span>
            </div>
            <p className="text-sm text-[#C5B7A9] leading-relaxed">
              «أناقتكِ تبدأ من هنا» — متجر أزياء نسائية فاخر يجمع بين أصالة الحشمة ورقي أحدث صيحات الموضة العصرية.
            </p>
            <div className="pt-2 flex items-center gap-3">
              <a
                href="https://wa.me/967771234567"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 bg-[#25D366] text-white px-4 py-2 rounded-xl text-xs font-bold hover:opacity-90 transition-opacity"
              >
                <MessageCircle className="w-4 h-4" />
                تواصل واتساب
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="space-y-3">
            <h4 className="text-white font-bold text-base border-r-2 border-[#C5A059] pr-3">
              روابط المتجر
            </h4>
            <ul className="space-y-2 text-sm text-[#C5B7A9]">
              <li><Link href="/" className="hover:text-[#C5A059] transition-colors">الرئيسية</Link></li>
              <li><Link href="/#products" className="hover:text-[#C5A059] transition-colors">أحدث الفساتين والجلابيات</Link></li>
              <li><Link href="/#categories" className="hover:text-[#C5A059] transition-colors">تصفح الأقسام</Link></li>
              <li><Link href="/track-order" className="hover:text-[#C5A059] transition-colors">تتبع حالة طلبك</Link></li>
              <li><Link href="/admin" className="hover:text-[#C5A059] transition-colors">بوابة الإدارة والموظفين</Link></li>
            </ul>
          </div>

          {/* Payment Methods Info */}
          <div className="space-y-3">
            <h4 className="text-white font-bold text-base border-r-2 border-[#C5A059] pr-3">
              طرق الدفع المعتمدة
            </h4>
            <p className="text-xs text-[#C5B7A9] leading-relaxed">
              نوفر خيارات دفع مريحة وآمنة للعميلات داخل اليمن:
            </p>
            <div className="flex flex-wrap gap-2 pt-2">
              <span className="bg-[#342419] border border-[#C5A059]/30 text-xs px-2.5 py-1 rounded-lg text-white font-medium">نقداً عند الاستلام</span>
              <span className="bg-[#342419] border border-[#C5A059]/30 text-xs px-2.5 py-1 rounded-lg text-white font-medium">الكريمي حاسب</span>
              <span className="bg-[#342419] border border-[#C5A059]/30 text-xs px-2.5 py-1 rounded-lg text-white font-medium">محفظة فلوسك</span>
              <span className="bg-[#342419] border border-[#C5A059]/30 text-xs px-2.5 py-1 rounded-lg text-white font-medium">محفظة جوالي</span>
              <span className="bg-[#342419] border border-[#C5A059]/30 text-xs px-2.5 py-1 rounded-lg text-white font-medium">محفظة ون كاش</span>
            </div>
          </div>

          {/* Contact Details */}
          <div className="space-y-3">
            <h4 className="text-white font-bold text-base border-r-2 border-[#C5A059] pr-3">
              تواصل معنا
            </h4>
            <ul className="space-y-3 text-sm text-[#C5B7A9]">
              <li className="flex items-start gap-2.5">
                <MapPin className="w-4 h-4 text-[#C5A059] shrink-0 mt-0.5" />
                <span>اليمن، صنعاء - حدة، جوار مركز الكميم التجاري</span>
              </li>
              <li className="flex items-center gap-2.5">
                <Phone className="w-4 h-4 text-[#C5A059] shrink-0" />
                <span dir="ltr">+967 771 234 567</span>
              </li>
              <li className="flex items-center gap-2.5">
                <Mail className="w-4 h-4 text-[#C5A059] shrink-0" />
                <span>support@lujain-store.ye</span>
              </li>
            </ul>
          </div>
        </div>
      </div>

      {/* Bottom Bar */}
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-8 border-t border-[#3E2D22] text-center text-xs text-[#9E8E80] flex flex-col sm:flex-row items-center justify-between gap-4">
        <p>© 2026 جميع الحقوق محفوظة لـ <strong>متجر لجين LUJAIN</strong> — أناقتك تبدأ من هنا.</p>
        <p className="flex items-center gap-1">
          <span>صُمم بعناية للمرأة اليمنية والعربية</span>
          <span className="text-[#C5A059]">✦</span>
        </p>
      </div>
    </footer>
  );
}
