import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  base: process.env.PAGES_BASE || '/',
  plugins: [react()],
  server: {
    proxy: {
      '/predict': 'http://localhost:8000',
      '/stats': 'http://localhost:8000',
      '/recent': 'http://localhost:8000',
      '/metrics': 'http://localhost:8000',
      '/health': 'http://localhost:8000',
    }
  }
})
