export type OrderStatus = 
  | 'new'
  | 'under_review'
  | 'accepted_preparing'
  | 'ready_for_pickup'
  | 'out_for_delivery'
  | 'completed'
  | 'cancelled'
  | 'returned';

export type PaymentMethod = 
  | 'cash_on_delivery'
  | 'store_cash'
  | 'kuraimi'
  | 'floosak'
  | 'jawali'
  | 'onecash'
  | 'bank_transfer';

export type PaymentStatus = 'pending' | 'confirmed' | 'failed' | 'refunded';

export type DeliveryType = 'home_delivery' | 'store_pickup';

export interface Category {
  id: string;
  name_ar: string;
  name_en: string;
  slug: string;
  description_ar?: string;
  description_en?: string;
  image_url?: string;
  sort_order: number;
  is_active: boolean;
}

export interface ProductVariant {
  id: string;
  product_id: string;
  sku: string;
  barcode?: string;
  color_name_ar: string;
  color_name_en: string;
  color_hex: string;
  size: string;
  additional_price: number;
  cost_price: number;
  is_active: boolean;
  stock?: number;
}

export interface ProductImage {
  id: string;
  product_id: string;
  image_url: string;
  alt_text?: string;
  is_primary: boolean;
  sort_order: number;
}

export interface Product {
  id: string;
  category_id: string;
  category?: Category;
  name_ar: string;
  name_en: string;
  slug: string;
  description_ar: string;
  description_en: string;
  base_price: number; // in YER
  discount_price?: number;
  fabric_details?: string;
  is_featured: boolean;
  is_new: boolean;
  is_active: boolean;
  images: ProductImage[];
  variants: ProductVariant[];
  created_at: string;
}

export interface CartItem {
  id: string;
  product: Product;
  variant: ProductVariant;
  quantity: number;
  price: number;
}

export interface DeliveryZone {
  id: string;
  city_ar: string;
  city_en: string;
  area_ar?: string;
  area_en?: string;
  delivery_fee: number;
  free_delivery_threshold?: number;
  estimated_delivery_days: string;
  is_active: boolean;
}

export interface Coupon {
  id: string;
  code: string;
  discount_type: 'percentage' | 'fixed';
  discount_value: number;
  min_order_value: number;
  max_discount_amount?: number;
  valid_from: string;
  valid_until: string;
  is_active: boolean;
}

export interface OrderItem {
  id: string;
  order_id: string;
  variant_id: string;
  product_name_snapshot: string;
  sku_snapshot: string;
  color_snapshot: string;
  size_snapshot: string;
  unit_price_snapshot: number;
  cost_price_snapshot: number;
  quantity: number;
  total_line_price: number;
}

export interface Order {
  id: string;
  order_number: string;
  customer_id?: string;
  guest_name?: string;
  guest_phone?: string;
  guest_email?: string;
  delivery_type: DeliveryType;
  delivery_zone_id?: string;
  shipping_address_snapshot: {
    city: string;
    area: string;
    street_details: string;
    nearest_landmark?: string;
    recipient_name?: string;
    recipient_phone?: string;
  };
  subtotal: number;
  delivery_fee: number;
  discount_amount: number;
  coupon_id?: string;
  total_amount: number;
  status: OrderStatus;
  cancellation_reason?: string;
  customer_notes?: string;
  internal_notes?: string;
  source: 'web' | 'android' | 'ios';
  items?: OrderItem[];
  payments?: {
    payment_method: PaymentMethod;
    amount: number;
    status: PaymentStatus;
    transaction_reference?: string;
  }[];
  created_at: string;
  updated_at: string;
}

export interface CashAccount {
  id: string;
  name_ar: string;
  name_en: string;
  account_type: 'cash_box' | 'kuraimi' | 'floosak' | 'jawali' | 'onecash' | 'bank';
  account_number?: string;
  current_balance: number;
  currency: string;
  is_active: boolean;
}

export interface Expense {
  id: string;
  category: string;
  title: string;
  amount: number;
  payment_method: PaymentMethod;
  expense_date: string;
  notes?: string;
}
