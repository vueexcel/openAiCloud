<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">NER & Semantic Chunking</h2>

    <!-- Entity Type Selection -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-2">Select Entity Types for Chunking</label>
      <div class="flex flex-wrap gap-2">
        <button
          v-for="etype in entityTypes"
          :key="etype"
          class="btn btn-xs"
          :class="{
            'btn-primary': selectedEntityTypes.includes(etype),
            'btn-outline': !selectedEntityTypes.includes(etype)
          }"
          @click="toggleEntityType(etype)"
        >
          {{ etype }}
        </button>
      </div>
      <div class="text-xs text-gray-500 mt-1">
        Chunks will be created at boundaries of the selected entity types.
      </div>
    </div>

    <!-- Example Text Input / Selection (for preview) -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-2">Sample Text</label>
      <textarea
        v-model="sampleText"
        class="input w-full font-mono"
        rows="3"
        placeholder="Paste or type sample text to see NER preview"
        @input="runNER"
      ></textarea>
      <div class="text-xs text-gray-500 mt-1">
        The system will highlight recognized entities in the sample.
      </div>
    </div>

    <!-- Live NER Preview -->
    <div class="mb-4">
      <label class="block text-sm font-semibold mb-1">Entity Preview</label>
      <div
        class="bg-gray-100 p-2 rounded min-h-12 text-sm font-mono leading-relaxed"
        style="white-space: pre-wrap"
      >
        <template v-if="!entityPreview.length && !runningNER">
          <span class="text-gray-400">No entities detected.</span>
        </template>
        <template v-else-if="runningNER">
          <span class="text-gray-400 italic">Analyzing...</span>
        </template>
        <template v-else>
          <span v-for="(part, idx) in entityPreview" :key="idx">
            <template v-if="part.entity">
              <span
                :class="['rounded px-1 py-0.5 mx-0.5 text-white', getEntityColor(part.entity)]"
                :title="part.entity"
                >{{ part.text }}</span
              >
            </template>
            <template v-else>
              {{ part.text }}
            </template>
          </span>
        </template>
      </div>
    </div>

    <!-- Settings & Emit -->
    <div class="mb-2">
      <label class="block text-sm font-semibold mb-1">Chunk Overlap (Entities)</label>
      <input
        type="number"
        min="0"
        max="5"
        class="input w-20"
        v-model.number="entityOverlap"
        @input="emitSettings"
      />
      <span class="text-xs text-gray-500 ml-2">How many entities overlap between chunks</span>
    </div>

    <div>
      <button class="btn btn-primary mt-2" @click="emitSettings">Update Chunking Settings</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, watch } from 'vue'

// --- NER Entity Types (common) ---
const entityTypes = [
  'Person',
  'Organization',
  'Location',
  'Date',
  'Event',
  'Product',
  'Money',
  'Percent',
  'Time',
  'Ordinal'
]

// --- State ---
const selectedEntityTypes = ref<string[]>(['Person', 'Organization', 'Location'])
const entityOverlap = ref(0)
const sampleText = ref(
  'Barack Obama visited Berlin in July 2008 with Angela Merkel. Microsoft acquired GitHub for $7.5 billion.'
)
const entityPreview = ref<any[]>([])
const runningNER = ref(false)

// --- Emits ---
const emit = defineEmits(['update:ner-settings'])

// --- Simulated NER function (replace with real API) ---
function runNER() {
  runningNER.value = true
  setTimeout(() => {
    // Simulate spaCy/transformers result structure
    const text = sampleText.value
    // Fake entity detection on the demo string; in real use, replace with backend API call
    const demoEntities = [
      { start: 0, end: 12, label: 'Person' }, // Barack Obama
      { start: 21, end: 27, label: 'Location' }, // Berlin
      { start: 31, end: 40, label: 'Date' }, // July 2008
      { start: 47, end: 61, label: 'Person' }, // Angela Merkel
      { start: 63, end: 72, label: 'Organization' }, // Microsoft
      { start: 82, end: 88, label: 'Organization' }, // GitHub
      { start: 94, end: 106, label: 'Money' } // $7.5 billion
    ]

    // Only include selected entity types
    const entities = demoEntities.filter((ent) => selectedEntityTypes.value.includes(ent.label))
    // Build preview: split text and highlight entities
    let parts = []
    let lastIdx = 0
    for (const ent of entities) {
      if (ent.start > lastIdx) {
        parts.push({ text: text.slice(lastIdx, ent.start) })
      }
      parts.push({ text: text.slice(ent.start, ent.end), entity: ent.label })
      lastIdx = ent.end
    }
    if (lastIdx < text.length) {
      parts.push({ text: text.slice(lastIdx) })
    }
    entityPreview.value = parts
    runningNER.value = false
  }, 600)
}

// Watchers for real-time updates
watch([selectedEntityTypes, sampleText], runNER, { immediate: true })

function toggleEntityType(etype: string) {
  const idx = selectedEntityTypes.value.indexOf(etype)
  if (idx === -1) selectedEntityTypes.value.push(etype)
  else selectedEntityTypes.value.splice(idx, 1)
  runNER()
  emitSettings()
}

function getEntityColor(entity: string) {
  // Assign colors per entity type (tailwind colors)
  const colorMap: Record<string, string> = {
    Person: 'bg-pink-500',
    Organization: 'bg-indigo-600',
    Location: 'bg-green-600',
    Date: 'bg-yellow-600',
    Event: 'bg-orange-500',
    Product: 'bg-blue-400',
    Money: 'bg-teal-500',
    Percent: 'bg-purple-500',
    Time: 'bg-cyan-500',
    Ordinal: 'bg-gray-500'
  }
  return colorMap[entity] || 'bg-gray-700'
}

// Emit settings to parent
function emitSettings() {
  emit('update:ner-settings', {
    entityTypes: [...selectedEntityTypes.value],
    overlap: entityOverlap.value
  })
}
</script>

<style scoped>
/* .input {
  @apply px-3 py-2 border rounded outline-none;
}
.btn {
  @apply px-3 py-1 rounded font-medium cursor-pointer;
}
.btn-primary {
  @apply bg-blue-600 text-white hover:bg-blue-700 transition;
}
.btn-outline {
  @apply border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white transition;
}
.btn-xs {
  @apply text-xs px-2 py-1;
} */
</style>
