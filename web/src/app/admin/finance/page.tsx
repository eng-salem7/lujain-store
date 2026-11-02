'use client';

import React, { useState } from 'react';
import AdminSidebar from '@/components/AdminSidebar';
import { INITIAL_CASH_ACCOUNTS, INITIAL_ORDERS } from '@/lib/mockData';
import { CashAccount } from '@/types';
import { 
  Wallet, 
  ArrowDownLeft, 
  ArrowUpRight, 
  Building2, 
  Smartphone, 
  Plus, 
  ShieldCheck,
  Receipt
} from 'lucide-react';

export default function AdminFinancePage() {
  const [accounts, setAccounts] = useState<CashAccount[]>(INITIAL_CASH_ACCOUNTS);
  const [selectedAccount, setSelectedAccount] = useState<string>('all');

  const totalBalance = accounts.reduce((sum, a) => sum + a.current_balance, 0);

  // Sample transactions
  const transactions = [
    { id: 'tx1', type: 'order_revenue', title: 'إيراد طلب LUJ-2026-01001', account: 'حساب الكريمي (حاسب)', amount: 39800, date: '2026-10-30', isIncome: true },
    { id: 'tx2', type: 'order_revenue', title: 'إيراد طلب LUJ-2026-01002', account: 'محفظة فلوسك (كريمي)', amount: 36000, date: '2026-11-01', isIncome: true },
    { id: 'tx3', type: 'expense', title: 'شراء كراتين وتغليف فاخر بشعار لجين', account: 'صندوق المتجر الكاش', amount: 25000, date: '2026-10-28', isIncome: false },
    { id: 'tx4', type: 'expense', title: 'فاتورة كهرباء وإنترنت المتجر', account: 'حساب الكريمي (حاسب)', amount: 18000, date: '2026-10-25', isIncome: false },
  ];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10">
      <div className="flex flex-col lg:flex-row gap-8">
        <AdminSidebar />

        <div className="flex-1 space-y-6">
          {/* Header */}
          <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 bg-white p-6 rounded-3xl border border-[#EAE0D5] shadow-sm">
            <div>
              <span className="text-xs font-bold text-[#C5A059] uppercase tracking-wider block">
                الصندوق النقدي والمحافظ الإلكترونية
              </span>
              <h1 className="text-2xl font-black text-[#342419] mt-0.5">
                المالية وسجل المعاملات
              </h1>
            </div>

            <div className="text-left">
              <span className="text-[11px] text-[#8C7A6B] block">إجمالي السيولة المتاحة:</span>
              <strong className="text-xl font-black text-[#342419]">
                {totalBalance.toLocaleString('ar-YE')} <span className="text-xs text-[#C5A059]">ر.ي</span>
              </strong>
            </div>
          </div>

          {/* Account Cards */}
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {accounts.map((acc) => (
              <div
                key={acc.id}
                className="bg-white p-5 rounded-2xl border border-[#EAE0D5] shadow-sm flex flex-col justify-between space-y-3"
              >
                <div className="flex justify-between items-start">
                  <span className="text-xs font-bold text-[#342419]">{acc.name_ar}</span>
                  <div className="w-8 h-8 rounded-lg bg-[#FAF7F2] text-[#C5A059] flex items-center justify-center">
                    {acc.account_type === 'cash_box' && <Wallet className="w-4 h-4" />}
                    {acc.account_type === 'kuraimi' && <Building2 className="w-4 h-4" />}
                    {acc.account_type === 'floosak' && <Smartphone className="w-4 h-4" />}
                    {acc.account_type === 'jawali' && <Smartphone className="w-4 h-4" />}
                  </div>
                </div>

                <div>
                  <span className="text-xl font-black text-[#342419]">
                    {acc.current_balance.toLocaleString('ar-YE')}
                  </span>
                  <span className="text-xs font-bold text-[#C5A059] mr-1">ر.ي</span>
                </div>

                <div className="pt-2 border-t border-[#EAE0D5] text-[10px] text-[#8C7A6B] font-mono">
                  رقم الحساب: {acc.account_number || 'خزينة المتجر'}
                </div>
              </div>
            ))}
          </div>

          {/* Financial Transactions Ledger */}
          <div className="bg-white rounded-3xl border border-[#EAE0D5] p-6 shadow-sm space-y-4">
            <div className="flex items-center justify-between pb-3 border-b border-[#EAE0D5]">
              <h2 className="text-base font-bold text-[#342419] flex items-center gap-2">
                <Receipt className="w-5 h-5 text-[#C5A059]" />
                <span>سجل الحركات المالية الموثقة (Audit Ledger)</span>
              </h2>
            </div>

            <div className="overflow-x-auto">
              <table className="w-full text-right text-xs">
                <thead>
                  <tr className="bg-[#FAF7F2] text-[#8C7A6B] border-b border-[#EAE0D5]">
                    <th className="p-3">نوع العملية والبيان</th>
                    <th className="p-3">الحساب المالي</th>
                    <th className="p-3">التاريخ</th>
                    <th className="p-3 text-left">المبلغ بالريال اليمني</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-[#EAE0D5]">
                  {transactions.map((tx) => (
                    <tr key={tx.id} className="hover:bg-[#FAF7F2]/50 transition-colors">
                      <td className="p-3 font-medium text-[#342419]">
                        <div className="flex items-center gap-2">
                          <div
                            className={`w-6 h-6 rounded-full flex items-center justify-center shrink-0 ${
                              tx.isIncome
                                ? 'bg-emerald-100 text-emerald-700'
                                : 'bg-red-100 text-red-700'
                            }`}
                          >
                            {tx.isIncome ? (
                              <ArrowDownLeft className="w-3.5 h-3.5" />
                            ) : (
                              <ArrowUpRight className="w-3.5 h-3.5" />
                            )}
                          </div>
                          <span>{tx.title}</span>
                        </div>
                      </td>

                      <td className="p-3 text-[#6E482F] font-semibold">{tx.account}</td>
                      <td className="p-3 text-[#8C7A6B] font-mono">{tx.date}</td>

                      <td className="p-3 text-left font-black">
                        <span className={tx.isIncome ? 'text-emerald-700' : 'text-red-600'}>
                          {tx.isIncome ? '+' : '-'} {tx.amount.toLocaleString('ar-YE')} ر.ي
                        </span>
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
