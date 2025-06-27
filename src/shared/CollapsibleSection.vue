<template>
  <div>
    <button class="flex items-center text-blue-700" @click="show = !show">
      <span>{{ title }}</span>
      <svg
        class="w-4 h-4 ml-1 transform"
        :class="{ 'rotate-180': show }"
        fill="none"
        viewBox="0 0 24 24"
      >
        <path d="M6 9l6 6 6-6" stroke="currentColor" stroke-width="2" fill="none" />
      </svg>
    </button>
    <div v-show="show" class="mt-2">
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
const props = defineProps<{ title: string }>()
const show = ref(false)
</script>
