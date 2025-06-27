<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Data Sources</h2>

    <!-- File Upload -->
    <div
      class="border-2 border-dashed border-blue-400 rounded-lg p-6 flex flex-col items-center justify-center mb-6 bg-gray-50 hover:bg-blue-50 transition"
      @dragover.prevent
      @drop.prevent="handleDrop"
    >
      <input
        type="file"
        class="hidden"
        ref="fileInput"
        multiple
        @change="handleFileSelect"
        :accept="acceptTypes"
      />
      <IconUpload class="w-10 h-10 text-blue-400 mb-2" />
      <p class="text-sm text-gray-600 mb-2">
        Drag & drop files here or
        <span
          class="text-blue-600 font-medium cursor-pointer hover:underline"
          @click="openFilePicker"
          >browse</span
        >
      </p>
      <div class="text-xs text-gray-400">Supported: CSV, JSON, Parquet, TXT</div>
    </div>

    <!-- API/Data Lake Connect -->
    <div class="flex items-center space-x-2 mb-6">
      <input
        v-model="apiUrl"
        type="text"
        placeholder="API/Data Lake URL (optional)"
        class="input input-bordered w-full max-w-xs"
      />
      <button class="btn btn-primary text-white" @click="handleApiConnect" :disabled="!apiUrl">
        Connect
      </button>
    </div>

    <!-- Data Source List -->
    <h3 class="font-semibold text-lg mb-2">Recent Sources</h3>
    <div v-if="sources.length === 0" class="text-gray-400">No data sources uploaded yet.</div>
    <ul v-else class="divide-y divide-gray-200 bg-white rounded-lg shadow-sm">
      <li
        v-for="(source, idx) in sources"
        :key="source.id"
        class="flex items-center justify-between p-3 hover:bg-blue-50 transition"
      >
        <div>
          <div class="font-medium">
            <IconFile class="inline w-5 h-5 mr-1" />
            {{ source.name }}
          </div>
          <div class="text-xs text-gray-500">
            {{ source.type }} • {{ humanFileSize(source.size) }}
            <span
              v-if="source.previewable"
              class="ml-1 text-blue-500 cursor-pointer hover:underline"
              @click="previewSource(source)"
            >
              Preview
            </span>
          </div>
        </div>
        <button class="btn btn-xs btn-primary" @click="$emit('select', source)">Use</button>
      </li>
    </ul>

    <!-- Data Preview Modal -->
    <Modal v-if="showPreview" @close="showPreview = false">
      <template #header> Preview: {{ previewSourceObj.name }} </template>
      <template #body>
        <pre class="bg-gray-100 p-4 rounded max-h-80 overflow-auto text-xs">{{
          previewContent
        }}</pre>
      </template>
      <template #footer>
        <button class="btn" @click="showPreview = false">Close</button>
      </template>
    </Modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { v4 as uuidv4 } from 'uuid'
// Icons & Modal (replace with your own or from shadcn/ui)
import IconUpload from '@/Icon/IconUpload.vue'
import IconFile from '@/Icon/IconFile.vue'
import Modal from '@/shared/Modal.vue'

const acceptTypes = '.csv,.json,.txt,.parquet'
const apiUrl = ref('')
const sources = reactive<any[]>([])

const fileInput = ref<HTMLInputElement>()
const showPreview = ref(false)
const previewContent = ref('')
const previewSourceObj = ref<any>({})

function openFilePicker() {
  fileInput.value?.click()
}

function handleFileSelect(e: Event) {
  const files = (e.target as HTMLInputElement).files
  if (!files) return
  for (const file of Array.from(files)) {
    readFileSource(file)
  }
}

function handleDrop(e: DragEvent) {
  const files = e.dataTransfer?.files
  if (!files) return
  for (const file of Array.from(files)) {
    readFileSource(file)
  }
}

function readFileSource(file: File) {
  const reader = new FileReader()
  reader.onload = () => {
    // Only preview the first 5kb for UI
    const previewable = ['csv', 'json', 'txt'].includes(
      file.name.split('.').pop()?.toLowerCase() || ''
    )
    sources.unshift({
      id: uuidv4(),
      name: file.name,
      type: file.type || 'text/plain',
      size: file.size,
      preview: previewable ? (reader.result as string).slice(0, 5000) : '',
      file,
      previewable
    })
  }
  reader.readAsText(file)
}

function previewSource(source: any) {
  previewSourceObj.value = source
  previewContent.value = source.preview
  showPreview.value = true
}

function handleApiConnect() {
  // Placeholder for API/data lake integration
  sources.unshift({
    id: uuidv4(),
    name: apiUrl.value,
    type: 'API/Data Lake',
    size: 0,
    preview: '',
    previewable: false,
    url: apiUrl.value
  })
  apiUrl.value = ''
}

// Helper: Human readable file size

function humanFileSize(size: number): string {
  const i = size === 0 ? 0 : Math.floor(Math.log(size) / Math.log(1024))
  return (size / Math.pow(1024, i)).toFixed(1) + ' ' + ['B', 'kB', 'MB', 'GB', 'TB'][i]
}

// Register filter globally or use as computed
</script>
