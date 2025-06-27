<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Preprocessing Pipeline Builder</h2>

    <!-- Pipeline Steps List (Draggable) -->
    <VueDraggableNext
      v-model="pipeline"
      item-key="id"
      class="space-y-3"
      handle=".handle"
      @end="emitPipeline"
    >
      <template #item="{ element, index }">
        <div
          class="flex items-center justify-between bg-white border rounded-lg shadow-sm p-3 hover:bg-blue-50 transition"
        >
          <div class="flex items-center space-x-3">
            <span class="handle cursor-grab text-blue-500 mr-1">
              <svg width="18" height="18" fill="none" viewBox="0 0 24 24">
                <circle cx="7" cy="7" r="1.5" fill="#3b82f6" />
                <circle cx="7" cy="12" r="1.5" fill="#3b82f6" />
                <circle cx="7" cy="17" r="1.5" fill="#3b82f6" />
                <circle cx="12" cy="7" r="1.5" fill="#3b82f6" />
                <circle cx="12" cy="12" r="1.5" fill="#3b82f6" />
                <circle cx="12" cy="17" r="1.5" fill="#3b82f6" />
                <circle cx="17" cy="7" r="1.5" fill="#3b82f6" />
                <circle cx="17" cy="12" r="1.5" fill="#3b82f6" />
                <circle cx="17" cy="17" r="1.5" fill="#3b82f6" />
              </svg>
            </span>
            <span class="font-medium">{{ element.label }}</span>
            <span
              class="text-xs bg-blue-100 text-blue-700 rounded px-2 py-0.5 ml-1"
              v-if="element.custom"
              >custom</span
            >
            <span class="ml-2 text-gray-400 text-xs" v-if="!element.enabled">(disabled)</span>
          </div>
          <div class="flex items-center space-x-2">
            <button
              class="btn btn-xs btn-outline"
              @click="toggleStep(index)"
              :title="element.enabled ? 'Disable' : 'Enable'"
            >
              {{ element.enabled ? 'Disable' : 'Enable' }}
            </button>
            <button
              class="btn btn-xs btn-outline"
              @click="editStep(index)"
              title="Edit step settings"
            >
              Edit
            </button>
            <button
              class="btn btn-xs btn-outline text-red-500 border-red-300"
              @click="removeStep(index)"
              title="Remove step"
            >
              Delete
            </button>
          </div>
        </div>
      </template>
    </VueDraggableNext>

    <!-- Add Step Button -->
    <div class="mt-5">
      <button class="btn btn-primary" @click="showStepMenu = true">+ Add Step</button>
    </div>

    <!-- Add Step Modal -->
    <Modal v-if="showStepMenu" @close="showStepMenu = false">
      <template #header> Add Preprocessing Step </template>
      <template #body>
        <div class="grid grid-cols-1 gap-3">
          <button
            v-for="step in availableSteps"
            :key="step.type"
            class="btn btn-outline w-full justify-start"
            @click="addStep(step)"
          >
            {{ step.label }}
          </button>
          <button class="btn btn-outline w-full justify-start" @click="addCustomStep">
            Custom Function (Python/JS)
          </button>
        </div>
      </template>
      <template #footer>
        <button class="btn" @click="showStepMenu = false">Cancel</button>
      </template>
    </Modal>

    <!-- Custom Step Modal -->
    <Modal v-if="showCustomStepModal" @close="showCustomStepModal = false">
      <template #header> Custom Function Step </template>
      <template #body>
        <div>
          <label class="block font-semibold text-sm mb-1">Language</label>
          <select v-model="customStepLanguage" class="input w-full mb-2">
            <option value="python">Python</option>
            <option value="javascript">JavaScript</option>
          </select>
          <label class="block font-semibold text-sm mb-1">Code</label>
          <textarea v-model="customStepCode" rows="4" class="input w-full font-mono"></textarea>
        </div>
      </template>
      <template #footer>
        <button class="btn btn-outline mr-2" @click="showCustomStepModal = false">Cancel</button>
        <button class="btn btn-primary" @click="confirmAddCustomStep">Add</button>
      </template>
    </Modal>

    <!-- Edit Step Modal (basic) -->
    <Modal v-if="editStepIndex !== null" @close="closeEditModal">
      <template #header>Edit Step Settings</template>
      <template #body>
        <div v-if="editingStep">
          <label class="block font-semibold text-sm mb-1">Step: {{ editingStep.label }}</label>
          <!-- Example: for Tokenization step, show extra options -->
          <div v-if="editingStep.type === 'tokenize'">
            <label class="block text-xs mb-1">Tokenizer Type</label>
            <select v-model="editingStep.settings.tokenizer" class="input w-full mb-2">
              <option value="word">Word</option>
              <option value="sentence">Sentence</option>
              <option value="character">Character</option>
            </select>
          </div>
          <!-- For custom steps, show language and code -->
          <div v-if="editingStep.custom">
            <label class="block text-xs mb-1">Language</label>
            <input type="text" class="input w-full mb-2" v-model="editingStep.language" disabled />
            <label class="block text-xs mb-1">Code</label>
            <textarea class="input w-full font-mono" v-model="editingStep.code" rows="4"></textarea>
          </div>
          <div v-if="!editingStep.custom && !['tokenize'].includes(editingStep.type)">
            <div class="text-xs text-gray-500">No additional settings available.</div>
          </div>
        </div>
      </template>
      <template #footer>
        <button class="btn btn-outline mr-2" @click="closeEditModal">Cancel</button>
        <button class="btn btn-primary" @click="confirmEditStep">Save</button>
      </template>
    </Modal>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, toRaw } from 'vue'
import { VueDraggableNext } from 'vue-draggable-next'
import Modal from '@/shared/Modal.vue'

const availableSteps = [
  { type: 'tokenize', label: 'Tokenization', settings: { tokenizer: 'word' } },
  { type: 'lowercase', label: 'Lowercase' },
  { type: 'remove_stopwords', label: 'Stopword Removal' },
  { type: 'lemmatize', label: 'Lemmatization' },
  { type: 'stem', label: 'Stemming' },
  { type: 'normalize', label: 'Normalization' },
  { type: 'remove_special', label: 'Remove Special Characters' },
  { type: 'remove_emoji', label: 'Remove Emoji' },
  { type: 'remove_html', label: 'Remove HTML' },
  { type: 'deduplicate', label: 'Dedupe (Duplicate Filter)' },
  { type: 'lang_filter', label: 'Language Filter' },
  { type: 'anonymize', label: 'Anonymization' }
]

// Pipeline step state
let stepId = 1
const pipeline = ref<any[]>([])

// Add Step Menu
const showStepMenu = ref(false)

// Add Custom Step
const showCustomStepModal = ref(false)
const customStepLanguage = ref('python')
const customStepCode = ref('')

function addStep(step: any) {
  pipeline.value.push({
    id: 'step-' + stepId++,
    type: step.type,
    label: step.label,
    enabled: true,
    custom: false,
    settings: step.settings ? { ...step.settings } : {}
  })
  showStepMenu.value = false
  emitPipeline()
}

function addCustomStep() {
  showStepMenu.value = false
  showCustomStepModal.value = true
  customStepLanguage.value = 'python'
  customStepCode.value = ''
}

function confirmAddCustomStep() {
  pipeline.value.push({
    id: 'step-' + stepId++,
    type: 'custom',
    label: 'Custom Function',
    enabled: true,
    custom: true,
    language: customStepLanguage.value,
    code: customStepCode.value,
    settings: {}
  })
  showCustomStepModal.value = false
  emitPipeline()
}

// Edit Step Modal
const editStepIndex = ref<number | null>(null)
const editingStep = ref<any>(null)
function editStep(index: number) {
  editStepIndex.value = index
  editingStep.value = JSON.parse(JSON.stringify(pipeline.value[index]))
}
function closeEditModal() {
  editStepIndex.value = null
  editingStep.value = null
}
function confirmEditStep() {
  if (editStepIndex.value !== null) {
    pipeline.value[editStepIndex.value] = JSON.parse(JSON.stringify(editingStep.value))
    emitPipeline()
  }
  closeEditModal()
}

// Toggle/Remove
function toggleStep(idx: number) {
  pipeline.value[idx].enabled = !pipeline.value[idx].enabled
  emitPipeline()
}
function removeStep(idx: number) {
  pipeline.value.splice(idx, 1)
  emitPipeline()
}

// Emit to parent
const emit = defineEmits(['update:pipeline'])
function emitPipeline() {
  emit('update:pipeline', pipeline.value.map(toRaw))
}
</script>

<style>
/* .btn {
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
}
.handle {
  @apply cursor-grab;
} */
</style>
