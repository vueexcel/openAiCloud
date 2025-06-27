<template>
  <span>
    <input
      v-if="editing"
      v-model="editValue"
      @blur="save"
      @keyup.enter="save"
      class="input input-xs w-auto"
      :style="{ width: (editValue.length + 1) * 0.6 + 'em' }"
      ref="inputEl"
    />
    <span v-else @dblclick="editing = true" class="hover:underline cursor-pointer">
      <slot>{{ value }}</slot>
    </span>
  </span>
</template>

<script setup lang="ts">
import { ref, nextTick } from 'vue'
const props = defineProps<{ value: string }>()
const emit = defineEmits(['update:value'])
const editing = ref(false)
const editValue = ref(props.value)
const inputEl = ref<HTMLInputElement>()
function save() {
  editing.value = false
  if (editValue.value !== props.value) emit('update:value', editValue.value)
}
watch(editing, (open) => {
  if (open) nextTick(() => inputEl.value?.focus())
})
</script>
