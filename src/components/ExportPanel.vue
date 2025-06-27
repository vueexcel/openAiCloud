<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Export & Automation</h2>

    <!-- Export Format -->
    <div class="mb-4">
      <label class="block font-semibold text-sm mb-1">Export Format</label>
      <select v-model="exportFormat" class="input w-full max-w-xs" @change="emitSettings">
        <option v-for="fmt in exportFormats" :key="fmt" :value="fmt">{{ fmt }}</option>
      </select>
    </div>

    <!-- Export Destination -->
    <div class="mb-4">
      <label class="block font-semibold text-sm mb-1">Destination</label>
      <select v-model="exportDestination" class="input w-full max-w-xs" @change="emitSettings">
        <option value="download">Local Download</option>
        <option value="cloud">Cloud Storage</option>
        <option value="api">API Endpoint</option>
      </select>
      <div v-if="exportDestination === 'cloud'" class="mt-2">
        <input
          v-model="cloudPath"
          class="input w-full max-w-md"
          placeholder="Cloud path (e.g., s3://bucket/folder/)"
          @input="emitSettings"
        />
      </div>
      <div v-if="exportDestination === 'api'" class="mt-2">
        <input
          v-model="apiEndpoint"
          class="input w-full max-w-md"
          placeholder="API endpoint URL"
          @input="emitSettings"
        />
      </div>
    </div>

    <!-- Export File Name & Notes -->
    <div class="mb-4 grid grid-cols-1 md:grid-cols-2 gap-2">
      <div>
        <label class="block font-semibold text-sm mb-1">File Name</label>
        <input
          v-model="fileName"
          class="input w-full"
          @input="emitSettings"
          placeholder="output_data"
        />
      </div>
      <div>
        <label class="block font-semibold text-sm mb-1">Notes (optional)</label>
        <input
          v-model="exportNotes"
          class="input w-full"
          @input="emitSettings"
          placeholder="e.g., version, purpose, etc."
        />
      </div>
    </div>

    <!-- Automation & Scheduling (optional, simple demo) -->
    <div class="mb-4">
      <label class="block font-semibold text-sm mb-1">Automation</label>
      <div class="flex items-center space-x-2">
        <input type="checkbox" v-model="scheduled" id="scheduled" @change="emitSettings" />
        <label for="scheduled" class="text-sm">Schedule recurring export</label>
        <input
          v-if="scheduled"
          v-model="scheduleCron"
          class="input input-xs ml-2 w-36"
          placeholder="e.g., 0 8 * * *"
          @input="emitSettings"
        />
        <span v-if="scheduled" class="text-xs text-gray-400 ml-2">(CRON format)</span>
      </div>
    </div>

    <!-- Export Action Buttons -->
    <div class="flex items-center space-x-2 mt-4">
      <button class="btn btn-primary" @click="requestExport" :disabled="exporting">
        {{ exporting ? 'Exporting...' : 'Export Now' }}
      </button>
      <button class="btn btn-outline" @click="emitSettings">Save as Pipeline Template</button>
    </div>

    <!-- Status Message -->
    <div v-if="statusMsg" :class="statusClass" class="mt-4 px-3 py-2 rounded">
      {{ statusMsg }}
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue'

// Export format/destination options
const exportFormats = ['CSV', 'JSON', 'Parquet', 'Feather']
const exportFormat = ref('CSV')
const exportDestination = ref('download')
const cloudPath = ref('')
const apiEndpoint = ref('')
const fileName = ref('output_data')
const exportNotes = ref('')

const scheduled = ref(false)
const scheduleCron = ref('')

// Status for export
const exporting = ref(false)
const statusMsg = ref('')
const statusClass = computed(() =>
  statusMsg.value.includes('success') ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
)

// --- Emit export request/settings to parent ---
const emit = defineEmits(['export', 'update:export-settings'])

function emitSettings() {
  emit('update:export-settings', {
    format: exportFormat.value,
    destination: exportDestination.value,
    cloudPath: cloudPath.value,
    apiEndpoint: apiEndpoint.value,
    fileName: fileName.value,
    notes: exportNotes.value,
    scheduled: scheduled.value,
    scheduleCron: scheduleCron.value
  })
}

// --- Export Now button ---
async function requestExport() {
  exporting.value = true
  emit('export', {
    format: exportFormat.value,
    destination: exportDestination.value,
    cloudPath: cloudPath.value,
    apiEndpoint: apiEndpoint.value,
    fileName: fileName.value,
    notes: exportNotes.value,
    scheduled: scheduled.value,
    scheduleCron: scheduleCron.value
  })
  // Simulate export completion
  setTimeout(() => {
    exporting.value = false
    statusMsg.value = `Export success: File '${fileName.value}.${exportFormat.value.toLowerCase()}' ready!`
    setTimeout(() => (statusMsg.value = ''), 4000)
  }, 1300)
}
</script>
