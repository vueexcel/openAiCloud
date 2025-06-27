<template>
  <div class="relative w-full max-w-xs">
    <input
      type="text"
      v-model="query"
      @input="emitSearch"
      class="input w-full pl-8"
      placeholder="Search…"
    />
    <svg
      class="absolute left-2 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400"
      fill="none"
      stroke="currentColor"
      viewBox="0 0 24 24"
    >
      <circle cx="11" cy="11" r="8" stroke-width="2" />
      <line x1="21" y1="21" x2="16.65" y2="16.65" stroke-width="2" />
    </svg>
  </div>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
const query = ref('')
const emit = defineEmits(['search'])
let timer: any = null
function emitSearch() {
  clearTimeout(timer)
  timer = setTimeout(() => emit('search', query.value), 300)
}
</script>

1️⃣2️⃣ ProgressBar.vue vue

<template>
  <div>
    <div class="w-full h-3 bg-gray-200 rounded mb-1">
      <div
        :style="{ width: pct + '%' }"
        class="h-3 bg-blue-600 rounded transition-all duration-300"
      ></div>
    </div>
    <div class="text-xs text-gray-500 text-right">
      {{ pct }}% <span v-if="status">({{ status }})</span>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ value: number; max?: number; status?: string }>()
const pct = Math.round((props.value / (props.max || 100)) * 100)
</script>
