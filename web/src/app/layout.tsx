import type { Metadata } from 'next';
import './globals.css';
import { StoreProvider } from '@/lib/store';
import Navbar from '@/components/Navbar';
import Footer from '@/components/Footer';
import CartDrawer from '@/components/CartDrawer';

export const metadata: Metadata = {
  title: 'متجر لُجين LUJAIN للأزياء النسائية | أناقتك تبدأ من هنا',
  description: 'المتجر الإلكتروني الرائد للأزياء النسائية الفاخرة، فساتين سهرة، جلابيات مطرزة، أطقم راقية، وشحن لكافة المحافظات اليمنية.',
  keywords: 'أزياء نسائية, متجر لجين, فساتين سهرة, جلابيات, اليمن, صنعاء, عدن, ملابس نسائية',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="ar" dir="rtl" className="scroll-smooth">
      <body className="bg-[#FAF7F2] text-[#342419] min-h-screen flex flex-col font-sans antialiased selection:bg-[#C5A059] selection:text-white">
        <StoreProvider>
          <Navbar />
          <main className="flex-grow">{children}</main>
          <CartDrawer />
          <Footer />
        </StoreProvider>
      </body>
    </html>
  );
}
