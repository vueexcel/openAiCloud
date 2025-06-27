<template>
  <div
    v-if="show"
    :class="['fixed z-50 top-4 right-4 px-4 py-2 rounded shadow-lg text-sm', toastClass]"
    @click="show = false"
  >
    {{ msg }}
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const show = ref(false)
const msg = ref('')
const type = ref<'success' | 'error' | 'info'>('info')
const toastClass = {
  success: 'bg-green-500 text-white',
  error: 'bg-red-500 text-white',
  info: 'bg-blue-500 text-white'
}[type.value]

// Usage: import and use with a simple API
export function useToast() {
  return (message: string, t: 'success' | 'error' | 'info' = 'info') => {
    msg.value = message
    type.value = t
    show.value = true
    setTimeout(() => (show.value = false), 3000)
  }
}
</script>
