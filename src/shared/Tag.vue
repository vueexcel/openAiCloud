<template>
  <span :class="['inline-block px-2 py-0.5 rounded text-xs font-semibold mr-1', tagColor]">{{
    label
  }}</span>
</template>

<script setup lang="ts">
const props = defineProps<{
  label: string
  type?: string
}>()
function colorMap(type: string) {
  switch (type) {
    case 'Person':
      return 'bg-pink-500 text-white'
    case 'Org':
    case 'Organization':
      return 'bg-indigo-600 text-white'
    case 'Location':
      return 'bg-green-600 text-white'
    case 'Language':
      return 'bg-blue-400 text-white'
    case 'Warning':
      return 'bg-yellow-400 text-black'
    case 'Error':
      return 'bg-red-500 text-white'
    case 'Success':
      return 'bg-green-500 text-white'
    default:
      return 'bg-gray-200 text-gray-800'
  }
}
const tagColor = colorMap(props.type || props.label)
</script>
