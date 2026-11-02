/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        lujain: {
          50: '#FDFBF7',   // Ultra soft cream
          100: '#FAF4EB',  // Light cream
          200: '#F3ECE2',  // Warm beige
          300: '#E7DCce',  // Soft sand
          400: '#D5C4B0',  // Muted beige
          500: '#C5A059',  // Elegant gold
          600: '#A9843F',  // Deep gold
          700: '#6E482F',  // Warm medium brown
          800: '#462C1E',  // Dark rich brown
          900: '#2A1810',  // Midnight chocolate
        },
        gold: {
          light: '#F4E7CB',
          DEFAULT: '#C5A059',
          dark: '#9A7736',
        }
      },
      fontFamily: {
        sans: ['Cairo', 'Tajawal', 'sans-serif'],
      },
    },
  },
  plugins: [],
};
