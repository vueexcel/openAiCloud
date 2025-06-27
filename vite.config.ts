import { defineConfig } from '@opencloud-eu/extension-sdk'
import tailwindcss from '@tailwindcss/vite'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export default defineConfig({
  name: 'web-app-skeleton',
  server: {
    port: 9224
  },
  build: {
    rollupOptions: {
      output: {
        entryFileNames: 'index.js'
      }
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src') // <-- this adds support for @/
    }
  },
  plugins: [tailwindcss()]
})
