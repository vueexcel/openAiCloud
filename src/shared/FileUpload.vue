<template>
  <div
    class="border-2 border-dashed border-blue-400 rounded-lg p-6 flex flex-col items-center justify-center bg-gray-50 hover:bg-blue-50 transition cursor-pointer"
    @dragover.prevent
    @drop.prevent="onDrop"
    @click="open"
  >
    <input
      type="file"
      class="hidden"
      ref="input"
      :multiple="multiple"
      :accept="accept"
      @change="onChange"
    />
    <slot>
      <IconUpload class="w-8 h-8 text-blue-400 mb-2" />
      <div class="text-sm text-gray-600 mb-1">
        Drag & drop or <span class="underline text-blue-600">browse</span>
      </div>
      <div class="text-xs text-gray-400">Supported: CSV, JSON, Parquet, TXT</div>
    </slot>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import IconUpload from './icons/IconUpload.vue'

const props = defineProps({
  accept: { type: String, default: '' },
  multiple: { type: Boolean, default: false }
})
const emit = defineEmits(['change'])

const input = ref<HTMLInputElement | null>(null)
function open() {
  input.value?.click()
}
function onChange(e: Event) {
  const files = (e.target as HTMLInputElement).files
  if (files && files.length) emit('change', Array.from(files))
}
function onDrop(e: DragEvent) {
  const files = e.dataTransfer?.files
  if (files && files.length) emit('change', Array.from(files))
}
</script>
