<template>
  <button class="btn btn-xs btn-outline flex items-center" @click="copy">
    <slot>
      <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <rect width="16" height="16" x="4" y="4" rx="2" />
        <path d="M8 2v2a2 2 0 002 2h8a2 2 0 012 2v12a2 2 0 01-2 2h-2" />
      </svg>
    </slot>
    <span v-if="copied" class="text-green-600 ml-1">Copied!</span>
    <span v-else>{{ label }}</span>
  </button>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const props = defineProps<{ text: string; label?: string }>()
const copied = ref(false)
async function copy() {
  await navigator.clipboard.writeText(props.text)
  copied.value = true
  setTimeout(() => (copied.value = false), 1200)
}
</script>
