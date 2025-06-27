<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Data Anonymization & GDPR/DSGVO</h2>

    <div v-if="!piiFields.length" class="text-gray-400 mb-4">
      No PII detected in the current dataset.
    </div>
    <div v-else>
      <!-- GDPR Check Indicator -->
      <div class="mb-4 flex items-center space-x-3">
        <div :class="['w-3 h-3 rounded-full', gdprStatusColor]" />
        <span class="text-sm font-semibold"> GDPR Compliance: {{ gdprStatusText }} </span>
        <span class="ml-3 text-xs text-gray-500"
          >({{ activeCount }}/{{ piiFields.length }} fields anonymized)</span
        >
      </div>

      <!-- PII Fields Table -->
      <table class="w-full text-xs bg-white rounded shadow mb-6">
        <thead>
          <tr class="border-b">
            <th class="px-2 py-1 text-left">Field</th>
            <th class="px-2 py-1 text-left">Type</th>
            <th class="px-2 py-1 text-left">Sample Value</th>
            <th class="px-2 py-1 text-left">Anonymize?</th>
            <th class="px-2 py-1 text-left">Method</th>
            <th class="px-2 py-1 text-left">Preview</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(field, idx) in piiFields" :key="field.name" class="border-b">
            <td class="px-2 py-1 font-mono">{{ field.name }}</td>
            <td class="px-2 py-1">{{ field.type }}</td>
            <td class="px-2 py-1 font-mono">{{ field.sample }}</td>
            <td class="px-2 py-1">
              <input type="checkbox" v-model="field.anonymize" @change="emitSettings" />
            </td>
            <td class="px-2 py-1">
              <select
                v-model="field.method"
                class="input input-xs"
                :disabled="!field.anonymize"
                @change="emitSettings"
              >
                <option value="mask">Mask</option>
                <option value="hash">Hash</option>
                <option value="redact">Redact</option>
                <option value="custom">Custom</option>
              </select>
            </td>
            <td class="px-2 py-1 font-mono">
              <span v-if="field.anonymize">{{ anonymizeSample(field) }}</span>
              <span v-else class="text-gray-400">-</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="flex space-x-2 mt-2">
      <button class="btn btn-primary" @click="emitSettings">Apply Settings</button>
      <button class="btn btn-outline" @click="resetPanel">Reset</button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, reactive, watch } from 'vue'

// --- Props: expects detected PII fields from parent or profiling step ---
interface PiiField {
  name: string
  type: string
  sample: string
  anonymize: boolean
  method: 'mask' | 'hash' | 'redact' | 'custom'
}

const props = defineProps<{
  fields: PiiField[]
}>()

// --- Local state: clone for local edits (avoid mutating prop directly) ---
const piiFields = reactive(props.fields.map((f) => ({ ...f })))

watch(
  () => props.fields,
  (val) => {
    // Re-sync on parent change
    for (let i = 0; i < piiFields.length; i++) {
      Object.assign(piiFields[i], val[i] || {})
    }
  }
)

// --- GDPR Compliance Calculation ---
const activeCount = computed(() => piiFields.filter((f) => f.anonymize).length)

const gdprStatusColor = computed(() => {
  if (piiFields.length === 0) return 'bg-green-500'
  if (activeCount.value === piiFields.length) return 'bg-green-500'
  if (activeCount.value > 0) return 'bg-yellow-400'
  return 'bg-red-500'
})

const gdprStatusText = computed(() => {
  if (piiFields.length === 0) return 'No PII'
  if (activeCount.value === piiFields.length) return 'Ready'
  if (activeCount.value > 0) return 'Partial'
  return 'Not compliant'
})

// --- Methods for anonymization preview (simple) ---
function anonymizeSample(field: PiiField) {
  if (!field.anonymize) return field.sample
  if (field.method === 'mask') {
    if (field.type.toLowerCase().includes('email')) {
      // Mask all but first/last char before @
      return field.sample.replace(/(\w)\w+(\w)(@.*)/, '$1***$2$3')
    }
    if (field.type.toLowerCase().includes('phone')) {
      return field.sample.replace(/.(?=.{3})/g, '*')
    }
    return field.sample.length > 2
      ? field.sample[0] + '*'.repeat(field.sample.length - 2) + field.sample.slice(-1)
      : '**'
  }
  if (field.method === 'hash') {
    // Simulated hash
    return 'hash_' + btoa(field.sample).slice(0, 6)
  }
  if (field.method === 'redact') {
    return '[REDACTED]'
  }
  if (field.method === 'custom') {
    return '[CUSTOM]'
  }
  return field.sample
}

// --- Emit settings to parent for downstream use ---
const emit = defineEmits(['update:anonymization'])

function emitSettings() {
  emit(
    'update:anonymization',
    piiFields.map((f) => ({
      name: f.name,
      type: f.type,
      anonymize: f.anonymize,
      method: f.method
    }))
  )
}

// --- Reset panel to all anonymize, method 'mask' ---
function resetPanel() {
  piiFields.forEach((f) => {
    f.anonymize = true
    f.method = 'mask'
  })
  emitSettings()
}
</script>

<style scoped>
/* .input {
  @apply px-2 py-1 border rounded outline-none;
}
.input-xs {
  @apply text-xs px-1 py-0.5;
}
.btn {
  @apply px-3 py-1 rounded font-medium cursor-pointer;
}
.btn-primary {
  @apply bg-blue-600 text-white hover:bg-blue-700 transition;
}
.btn-outline {
  @apply border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white transition;
} */
</style>
