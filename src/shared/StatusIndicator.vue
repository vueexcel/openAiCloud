<template>
  <span :class="['inline-block w-3 h-3 rounded-full', color]" :title="label"></span>
</template>

<script setup lang="ts">
const props = defineProps<{ status: string; label?: string }>()
const color =
  props.status === 'ok'
    ? 'bg-green-500'
    : props.status === 'warn'
      ? 'bg-yellow-400'
      : props.status === 'error'
        ? 'bg-red-500'
        : 'bg-gray-300'
</script>
