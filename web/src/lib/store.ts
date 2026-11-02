'use client';

import React, { createContext, useContext, useState, useEffect } from 'react';
import { CartItem, Product, ProductVariant } from '@/types';

interface StoreContextType {
  cart: CartItem[];
  wishlist: string[];
  addToCart: (product: Product, variant: ProductVariant, quantity?: number) => void;
  removeFromCart: (variantId: string) => void;
  updateQuantity: (variantId: string, quantity: number) => void;
  clearCart: () => void;
  toggleWishlist: (productId: string) => void;
  isInWishlist: (productId: string) => boolean;
  cartCount: number;
  cartTotal: number;
  formatPrice: (price: number) => string;
  isCartOpen: boolean;
  setIsCartOpen: (open: boolean) => void;
}

const StoreContext = createContext<StoreContextType | undefined>(undefined);

export function StoreProvider({ children }: { children: React.ReactNode }) {
  const [cart, setCart] = useState<CartItem[]>([]);
  const [wishlist, setWishlist] = useState<string[]>([]);
  const [isCartOpen, setIsCartOpen] = useState(false);
  const [isHydrated, setIsHydrated] = useState(false);

  useEffect(() => {
    try {
      const savedCart = localStorage.getItem('lujain_cart');
      if (savedCart) setCart(JSON.parse(savedCart));

      const savedWishlist = localStorage.getItem('lujain_wishlist');
      if (savedWishlist) setWishlist(JSON.parse(savedWishlist));
    } catch (e) {
      console.error('Failed to load local storage:', e);
    }
    setIsHydrated(true);
  }, []);

  useEffect(() => {
    if (isHydrated) {
      localStorage.setItem('lujain_cart', JSON.stringify(cart));
      localStorage.setItem('lujain_wishlist', JSON.stringify(wishlist));
    }
  }, [cart, wishlist, isHydrated]);

  const addToCart = (product: Product, variant: ProductVariant, quantity = 1) => {
    setCart((prev) => {
      const existingIndex = prev.findIndex((item) => item.variant.id === variant.id);
      const effectivePrice = product.discount_price || product.base_price;

      if (existingIndex > -1) {
        const updated = [...prev];
        updated[existingIndex].quantity += quantity;
        return updated;
      }

      return [
        ...prev,
        {
          id: `${product.id}-${variant.id}`,
          product,
          variant,
          quantity,
          price: effectivePrice,
        },
      ];
    });
    setIsCartOpen(true);
  };

  const removeFromCart = (variantId: string) => {
    setCart((prev) => prev.filter((item) => item.variant.id !== variantId));
  };

  const updateQuantity = (variantId: string, quantity: number) => {
    if (quantity <= 0) {
      removeFromCart(variantId);
      return;
    }
    setCart((prev) =>
      prev.map((item) =>
        item.variant.id === variantId ? { ...item, quantity } : item
      )
    );
  };

  const clearCart = () => {
    setCart([]);
  };

  const toggleWishlist = (productId: string) => {
    setWishlist((prev) =>
      prev.includes(productId)
        ? prev.filter((id) => id !== productId)
        : [...prev, productId]
    );
  };

  const isInWishlist = (productId: string) => wishlist.includes(productId);

  const cartCount = cart.reduce((total, item) => total + item.quantity, 0);
  const cartTotal = cart.reduce((total, item) => total + item.price * item.quantity, 0);

  const formatPrice = (price: number) => {
    return `${new Intl.NumberFormat('ar-YE').format(price)} ر.ي`;
  };

  return (
    <StoreContext.Provider
      value={{
        cart,
        wishlist,
        addToCart,
        removeFromCart,
        updateQuantity,
        clearCart,
        toggleWishlist,
        isInWishlist,
        cartCount,
        cartTotal,
        formatPrice,
        isCartOpen,
        setIsCartOpen,
      }}
    >
      {children}
    </StoreContext.Provider>
  );
}

export function useStore() {
  const context = useContext(StoreContext);
  if (!context) {
    throw new Error('useStore must be used within a StoreProvider');
  }
  return context;
}
