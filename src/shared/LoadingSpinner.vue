<template>
  <div class="flex items-center justify-center p-8">
    <svg class="animate-spin h-8 w-8 text-blue-600" fill="none" viewBox="0 0 24 24">
      <circle
        class="opacity-30"
        cx="12"
        cy="12"
        r="10"
        stroke="currentColor"
        stroke-width="4"
      ></circle>
      <path class="opacity-70" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
    </svg>
    <span class="ml-3 text-blue-600" v-if="text">{{ text }}</span>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ text?: string }>()
</script>
