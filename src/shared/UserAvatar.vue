<template>
  <div
    class="inline-flex items-center justify-center rounded-full font-bold text-white bg-blue-500"
    :style="{
      width: size + 'px',
      height: size + 'px',
      fontSize: size / 2 + 'px',
      background: bgColor
    }"
  >
    <img v-if="src" :src="src" :alt="name" class="w-full h-full object-cover rounded-full" />
    <span v-else>{{ initials }}</span>
  </div>
</template>

<script setup lang="ts">
const props = defineProps({
  name: { type: String, required: true },
  src: { type: String, default: '' },
  size: { type: Number, default: 32 }
})
const initials = props.name
  .split(' ')
  .map((w) => w[0])
  .join('')
  .toUpperCase()
const bgColor = '#' + ((props.name.charCodeAt(0) * 1343) % 0xffffff).toString(16).padStart(6, '0')
</script>
