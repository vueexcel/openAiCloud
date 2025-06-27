<template>
  <div>
    <div class="flex space-x-2 mb-2">
      <button class="btn btn-xs btn-outline" :disabled="!canPrev" @click="prev">Prev</button>
      <span class="text-xs text-gray-500"
        >Rows {{ pageStart + 1 }}–{{ pageEnd }} of {{ data.length }}</span
      >
      <button class="btn btn-xs btn-outline" :disabled="!canNext" @click="next">Next</button>
    </div>
    <table class="w-full text-xs bg-white rounded shadow overflow-x-auto">
      <thead>
        <tr>
          <th v-for="col in columns" :key="col" class="px-2 py-1 border-b text-left">{{ col }}</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(row, ridx) in paged" :key="ridx">
          <td v-for="col in columns" :key="col" class="px-2 py-1 border-b font-mono">
            {{ row[col] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
const props = defineProps<{
  data: Record<string, any>[]
  pageSize?: number
}>()
const page = ref(0)
const pageSize = computed(() => props.pageSize || 10)
const columns = computed(() => (props.data[0] ? Object.keys(props.data[0]) : []))
const pageStart = computed(() => page.value * pageSize.value)
const pageEnd = computed(() => Math.min(pageStart.value + pageSize.value, props.data.length))
const canPrev = computed(() => page.value > 0)
const canNext = computed(() => pageEnd.value < props.data.length)
const paged = computed(() => props.data.slice(pageStart.value, pageEnd.value))

function prev() {
  if (page.value > 0) page.value--
}
function next() {
  if (pageEnd.value < props.data.length) page.value++
}
</script>

3️⃣ ChunkStats.vue vue

<template>
  <div class="flex flex-wrap gap-4">
    <div
      v-for="stat in statsList"
      :key="stat.label"
      class="bg-white rounded shadow p-3 flex flex-col items-center min-w-[100px]"
    >
      <span class="text-xs text-gray-400 mb-1">{{ stat.label }}</span>
      <span class="text-lg font-bold">{{ stat.value }}</span>
      <span v-if="stat.hint" class="text-[10px] text-gray-500 mt-1">{{ stat.hint }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  stats: {
    tokenCount?: number
    charCount?: number
    wordCount?: number
    lang?: string
    duplicate?: boolean
    warnings?: string[]
    [key: string]: any
  }
}>()

const statsList = [
  { label: 'Tokens', value: props.stats.tokenCount ?? '-', hint: '' },
  { label: 'Words', value: props.stats.wordCount ?? '-', hint: '' },
  { label: 'Chars', value: props.stats.charCount ?? '-', hint: '' },
  { label: 'Lang', value: props.stats.lang ?? '-', hint: '' },
  {
    label: 'Duplicate',
    value: props.stats.duplicate === true ? 'Yes' : props.stats.duplicate === false ? 'No' : '-',
    hint: ''
  }
]
</script>
