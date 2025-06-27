<template>
  <div class="flex items-center space-x-2">
    <button class="btn btn-xs btn-outline" :disabled="page <= 1" @click="update(page - 1)">
      Prev
    </button>
    <span class="text-xs text-gray-500">Page {{ page }} / {{ totalPages }}</span>
    <button class="btn btn-xs btn-outline" :disabled="page >= totalPages" @click="update(page + 1)">
      Next
    </button>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ page: number; totalPages: number }>()
const emit = defineEmits(['update:page'])
function update(newPage: number) {
  if (newPage >= 1 && newPage <= props.totalPages) emit('update:page', newPage)
}
</script>
