/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        'mesh-bg':       '#0D1B2A',
        'mesh-card':     '#1B2E45',
        'mesh-accent':   '#FF6B35',
        'mesh-danger':   '#E63946',
        'mesh-success':  '#2DC653',
        'mesh-info':     '#4A9EFF',
        'mesh-warning':  '#FFB703',
        'mesh-text':     '#FFFFFF',
        'mesh-muted':    '#8899AA',
        'mesh-disabled': '#445566',
      },
      fontFamily: {
        bebas: ['Bebas Neue', 'cursive'],
        nunito: ['Nunito', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
