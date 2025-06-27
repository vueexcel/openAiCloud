<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Chunking Controls</h2>

    <!-- Chunking Mode Selection -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-2">Chunking Mode</label>
      <select v-model="mode" class="input w-full max-w-xs" @change="onModeChange">
        <option v-for="opt in chunkingModes" :key="opt.value" :value="opt.value">
          {{ opt.label }}
        </option>
      </select>
    </div>

    <!-- AI Chunking Recommendation -->
    <div class="mb-4">
      <div class="flex items-center justify-between">
        <span class="text-sm font-semibold">AI Recommendation</span>
        <button class="btn btn-xs btn-outline" @click="fetchAIRecommendation" :disabled="loadingAI">
          {{ loadingAI ? 'Loading...' : 'Get Recommendation' }}
        </button>
      </div>
      <div v-if="aiRecommendation" class="mt-2 p-2 rounded bg-blue-50 text-blue-900 text-xs">
        <div>
          Chunk size: <span class="font-bold">{{ aiRecommendation.size }}</span> ({{
            aiRecommendation.unit
          }})
        </div>
        <ul>
          <li v-for="(reason, idx) in aiRecommendation.reasons" :key="idx">- {{ reason }}</li>
        </ul>
        <button class="btn btn-xs btn-primary mt-2" @click="applyAIRecommendation">Apply</button>
      </div>
    </div>

    <!-- Chunk Size Controls -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-1">
        Chunk Size
        <span class="text-xs text-gray-500">({{ currentUnitLabel }})</span>
      </label>
      <div class="flex items-center space-x-3">
        <input
          type="range"
          class="range"
          :min="sizeMin"
          :max="sizeMax"
          v-model.number="size"
          @input="emitSettings"
        />
        <input
          type="number"
          class="input input-bordered w-20"
          v-model.number="size"
          :min="sizeMin"
          :max="sizeMax"
          @input="emitSettings"
        />
      </div>
    </div>

    <!-- Overlap Control -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-1"
        >Chunk Overlap <span class="text-xs text-gray-500">(optional)</span></label
      >
      <div class="flex items-center space-x-3">
        <input
          type="range"
          class="range"
          min="0"
          :max="size - 1"
          v-model.number="overlap"
          @input="emitSettings"
        />
        <input
          type="number"
          class="input input-bordered w-20"
          v-model.number="overlap"
          min="0"
          :max="size - 1"
          @input="emitSettings"
        />
      </div>
      <div class="text-xs text-gray-500 mt-1">
        Defines how much context from previous chunk to keep (sliding window).
      </div>
    </div>

    <!-- Regex Pattern Input (Conditional) -->
    <div v-if="mode === 'regex'" class="mb-4">
      <label class="block text-sm font-semibold mb-1">Regex Pattern</label>
      <input
        type="text"
        class="input w-full"
        v-model="regexPattern"
        @input="emitSettings"
        placeholder="e.g. ^[A-Z].*$"
      />
      <div class="text-xs text-gray-500 mt-1">Chunk on matches of this pattern.</div>
    </div>

    <!-- NER/Semantic Options (Conditional) -->
    <div v-if="mode === 'ner'" class="mb-4">
      <label class="block text-sm font-semibold mb-1">NER/Semantic Chunking</label>
      <select v-model="entityType" class="input w-full max-w-xs" @change="emitSettings">
        <option value="">All Entities</option>
        <option v-for="et in nerEntityTypes" :key="et" :value="et">{{ et }}</option>
      </select>
      <div class="text-xs text-gray-500 mt-1">Chunk at boundaries of selected entity type(s).</div>
    </div>

    <!-- Chunk Preview -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-1">Live Preview</label>
      <div class="bg-gray-100 p-2 rounded text-xs max-h-40 overflow-auto font-mono">
        <span v-if="!previewLoading && preview.length === 0" class="text-gray-400"
          >No preview available.</span
        >
        <div v-else-if="previewLoading" class="italic text-gray-400">Loading preview...</div>
        <ul v-else>
          <li v-for="(chunk, idx) in preview" :key="idx">
            <span class="font-semibold text-blue-600">[{{ idx + 1 }}]</span>
            {{ trimPreview(chunk) }}
          </li>
        </ul>
      </div>
      <button
        class="btn btn-xs btn-outline mt-2"
        @click="refreshPreview"
        :disabled="previewLoading"
      >
        Refresh Preview
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'

// --- Chunking modes (expandable) ---
const chunkingModes = [
  { value: 'row', label: 'By Row (Records)' },
  { value: 'size', label: 'By Size (Bytes/KB/MB)' },
  { value: 'regex', label: 'By Regex Pattern' },
  { value: 'time', label: 'Time-based Window' },
  { value: 'ner', label: 'Semantic (NER-based)' },
  { value: 'custom', label: 'Custom Function' }
]

// NER entity types (expand as needed)
const nerEntityTypes = ['Person', 'Organization', 'Location', 'Date', 'Event']

// --- State ---
const mode = ref('row')
const size = ref(1000)
const overlap = ref(0)
const regexPattern = ref('')
const entityType = ref('')
const sizeMin = 10
const sizeMax = 5000

// AI recommendation
const aiRecommendation = ref<null | { size: number; unit: string; reasons: string[] }>(null)
const loadingAI = ref(false)

const preview = ref<string[]>([])
const previewLoading = ref(false)

// --- Computed ---
const currentUnitLabel = computed(() => {
  if (mode.value === 'row') return 'rows'
  if (mode.value === 'size') return 'bytes'
  if (mode.value === 'regex') return 'pattern match'
  if (mode.value === 'time') return 'seconds'
  if (mode.value === 'ner') return 'entities'
  if (mode.value === 'custom') return 'custom'
  return ''
})

// --- Emits to parent (composition API) ---
const emit = defineEmits(['update:settings'])

function emitSettings() {
  emit('update:settings', {
    mode: mode.value,
    size: size.value,
    overlap: overlap.value,
    regexPattern: regexPattern.value,
    entityType: entityType.value
  })
}
watch([mode, size, overlap, regexPattern, entityType], emitSettings)

// --- Mode change handler ---
function onModeChange() {
  // Reset specific controls
  if (mode.value === 'row') size.value = 1000
  if (mode.value === 'size') size.value = 50000
  if (mode.value === 'time') size.value = 60
  if (mode.value === 'regex') regexPattern.value = ''
  if (mode.value === 'ner') entityType.value = ''
  emitSettings()
}

// --- AI Recommendation (simulate, replace with API call) ---
function fetchAIRecommendation() {
  loadingAI.value = true
  setTimeout(() => {
    aiRecommendation.value = {
      size: mode.value === 'row' ? 2000 : mode.value === 'size' ? 4000 : 1000,
      unit: currentUnitLabel.value,
      reasons: [
        'Optimized for LLM context window',
        'Preserves semantic boundaries',
        'Improved downstream model performance'
      ]
    }
    loadingAI.value = false
  }, 1200)
}
function applyAIRecommendation() {
  if (!aiRecommendation.value) return
  size.value = aiRecommendation.value.size
  emitSettings()
}

// --- Chunk preview (simulate, replace with real data) ---
function refreshPreview() {
  previewLoading.value = true
  setTimeout(() => {
    preview.value = Array.from({ length: 5 }, (_, i) =>
      mode.value === 'row'
        ? `Sample record data chunk ${i + 1}`
        : mode.value === 'regex'
          ? `Chunk based on regex: pattern match ${i + 1}`
          : mode.value === 'ner'
            ? `NER-based entity chunk ${i + 1} (${entityType.value || 'Any'})`
            : `Generic chunk preview ${i + 1}`
    )
    previewLoading.value = false
  }, 800)
}
function trimPreview(val: string) {
  return val.length > 80 ? val.slice(0, 80) + '...' : val
}

// --- Initial emit on mount
emitSettings()
</script>
