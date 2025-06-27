<template>
  <div>
    <div class="cursor-pointer flex items-center py-2" @click="open = !open">
      <svg
        class="w-4 h-4 mr-2 transition-transform"
        :class="{ 'rotate-90': open }"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path d="M9 5l7 7-7 7" stroke="currentColor" stroke-width="2" fill="none" />
      </svg>
      <span class="font-medium">{{ title }}</span>
    </div>
    <div v-show="open" class="pl-6 py-2">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const props = defineProps<{ title: string }>()
const open = ref(false)
</script>
