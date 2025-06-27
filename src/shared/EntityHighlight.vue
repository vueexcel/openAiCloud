<template>
  <span>
    <template v-for="(part, idx) in parts" :key="idx">
      <span
        v-if="part.entity"
        :class="['rounded px-1', entityColor(part.entity)]"
        :title="part.entity"
        >{{ part.text }}</span
      >
      <span v-else>{{ part.text }}</span>
    </template>
  </span>
</template>

<script setup lang="ts">
// props: text, entities: [{ start, end, entity }]
const props = defineProps<{
  text: string
  entities: { start: number; end: number; entity: string }[]
}>()
function entityColor(entity: string) {
  // Color mapping as before
  switch (entity) {
    case 'Person':
      return 'bg-pink-200'
    case 'Organization':
      return 'bg-blue-200'
    case 'Location':
      return 'bg-green-200'
    default:
      return 'bg-yellow-200'
  }
}
// Split text for highlight
const parts = []
let last = 0
for (const ent of props.entities) {
  if (ent.start > last) parts.push({ text: props.text.slice(last, ent.start) })
  parts.push({ text: props.text.slice(ent.start, ent.end), entity: ent.entity })
  last = ent.end
}
if (last < props.text.length) parts.push({ text: props.text.slice(last) })
</script>
