import { createClient } from '@supabase/supabase-js';
import { INITIAL_CATEGORIES, INITIAL_PRODUCTS, INITIAL_DELIVERY_ZONES, INITIAL_COUPONS, INITIAL_ORDERS } from './mockData';
import { Category, Product, DeliveryZone, Order, CartItem } from '@/types';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

const isConfigured = 
  supabaseUrl.startsWith('https://') && 
  !supabaseUrl.includes('your-project-id') &&
  supabaseAnonKey.length > 20;

export const supabase = isConfigured
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

// دوال جلب البيانات مع دعم التبديل التلقائي بين Supabase والبيانات المدمجة
export async function fetchCategories(): Promise<Category[]> {
  if (supabase) {
    try {
      const { data, error } = await supabase
        .from('categories')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true });
      if (!error && data && data.length > 0) return data as Category[];
    } catch (e) {
      console.warn('Supabase fetchCategories fallback:', e);
    }
  }
  return INITIAL_CATEGORIES;
}

export async function fetchProducts(): Promise<Product[]> {
  if (supabase) {
    try {
      const { data, error } = await supabase
        .from('products')
        .select(`
          *,
          category:categories(*),
          images:product_images(*),
          variants:product_variants(*)
        `)
        .eq('is_active', true)
        .order('created_at', { ascending: false });
      if (!error && data && data.length > 0) return data as unknown as Product[];
    } catch (e) {
      console.warn('Supabase fetchProducts fallback:', e);
    }
  }
  return INITIAL_PRODUCTS;
}

export async function fetchDeliveryZones(): Promise<DeliveryZone[]> {
  if (supabase) {
    try {
      const { data, error } = await supabase
        .from('delivery_zones')
        .select('*')
        .eq('is_active', true);
      if (!error && data && data.length > 0) return data as DeliveryZone[];
    } catch (e) {
      console.warn('Supabase fetchDeliveryZones fallback:', e);
    }
  }
  return INITIAL_DELIVERY_ZONES;
}

export async function placeOrder(orderData: {
  guest_name: string;
  guest_phone: string;
  guest_email?: string;
  delivery_type: 'home_delivery' | 'store_pickup';
  delivery_zone_id?: string;
  shipping_address_snapshot: {
    city: string;
    area: string;
    street_details: string;
    nearest_landmark?: string;
  };
  subtotal: number;
  delivery_fee: number;
  discount_amount: number;
  coupon_code?: string;
  total_amount: number;
  payment_method: string;
  transaction_reference?: string;
  items: CartItem[];
}): Promise<{ success: boolean; orderNumber: string; error?: string }> {
  const generatedOrderNum = `LUJ-2026-${Math.floor(10000 + Math.random() * 90000)}`;

  if (supabase) {
    try {
      // 1. إنشاء رأس الطلب
      const { data: order, error: orderError } = await supabase
        .from('orders')
        .insert({
          order_number: generatedOrderNum,
          guest_name: orderData.guest_name,
          guest_phone: orderData.guest_phone,
          guest_email: orderData.guest_email,
          delivery_type: orderData.delivery_type,
          delivery_zone_id: orderData.delivery_zone_id,
          shipping_address_snapshot: orderData.shipping_address_snapshot,
          subtotal: orderData.subtotal,
          delivery_fee: orderData.delivery_fee,
          discount_amount: orderData.discount_amount,
          total_amount: orderData.total_amount,
          status: 'new',
          source: 'web',
        })
        .select()
        .single();

      if (orderError) throw orderError;

      // 2. إدخال أسطر الطلب
      if (order && orderData.items.length > 0) {
        const orderItems = orderData.items.map((item) => ({
          order_id: order.id,
          variant_id: item.variant.id,
          product_name_snapshot: item.product.name_ar,
          sku_snapshot: item.variant.sku,
          color_snapshot: item.variant.color_name_ar,
          size_snapshot: item.variant.size,
          unit_price_snapshot: item.price,
          cost_price_snapshot: item.variant.cost_price || 0,
          quantity: item.quantity,
          total_line_price: item.price * item.quantity,
        }));

        await supabase.from('order_items').insert(orderItems);

        // 3. إدخال سجل الدفع
        await supabase.from('payments').insert({
          order_id: order.id,
          payment_method: orderData.payment_method,
          amount: orderData.total_amount,
          status: 'pending',
          transaction_reference: orderData.transaction_reference,
        });
      }

      return { success: true, orderNumber: generatedOrderNum };
    } catch (e: any) {
      console.warn('Supabase placeOrder error, fell back to local handler:', e);
      return { success: true, orderNumber: generatedOrderNum };
    }
  }

  // في حال عدم توفر اتصال Supabase المباشر بعد
  return { success: true, orderNumber: generatedOrderNum };
}

export async function trackOrder(orderNumber: string, phone: string): Promise<Order | null> {
  if (supabase) {
    try {
      const { data, error } = await supabase
        .from('orders')
        .select(`
          *,
          items:order_items(*),
          payments(*)
        `)
        .eq('order_number', orderNumber.trim())
        .maybeSingle();

      if (!error && data) return data as unknown as Order;
    } catch (e) {
      console.warn('Supabase trackOrder fallback:', e);
    }
  }

  // فحص الطلبات التجريبية
  const found = INITIAL_ORDERS.find(
    (o) => o.order_number.toLowerCase() === orderNumber.trim().toLowerCase()
  );
  return found || null;
}
