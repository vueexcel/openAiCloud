<template>
  <div v-if="msg" class="bg-red-100 text-red-800 px-4 py-2 rounded mb-2 flex items-center">
    <svg class="w-5 h-5 mr-2" fill="none" viewBox="0 0 24 24">
      <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" />
      <path d="M12 8v4m0 4h.01" stroke="currentColor" stroke-width="2" />
    </svg>
    <span>{{ msg }}</span>
  </div>
</template>
<script setup lang="ts">
const props = defineProps<{ msg: string }>()
</script>
