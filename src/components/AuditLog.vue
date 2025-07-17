<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Audit Log</h2>
    <div v-if="!entries.length" class="text-gray-400">No audit events yet.</div>
    <div v-else>
      <!-- Filters (optional, remove if not needed) -->
      <div class="flex space-x-3 mb-4 items-center">
        <label class="text-xs font-medium">Filter by:</label>
        <select v-model="filterUser" class="input input-xs">
          <option value="">All Users</option>
          <option v-for="user in uniqueUsers" :key="user" :value="user">{{ user }}</option>
        </select>
        <select v-model="filterType" class="input input-xs">
          <option value="">All Types</option>
          <option v-for="type in uniqueTypes" :key="type" :value="type">{{ type }}</option>
        </select>
      </div>
      <!-- Timeline Grouped by Date -->
      <div v-for="(group, date) in groupedEntries" :key="date" class="mb-6">
        <div class="text-sm text-gray-600 font-semibold mb-2">{{ formatDate(date) }}</div>
        <ul>
          <li v-for="entry in group" :key="entry.id" class="flex items-start space-x-4 mb-2">
            <img
              :src="entry.avatar || defaultAvatar(entry.user)"
              alt="avatar"
              class="w-8 h-8 rounded-full border object-cover"
            />
            <div class="flex-1">
              <div class="flex items-center space-x-2">
                <span class="font-semibold text-sm">{{ entry.user }}</span>
                <span
                  class="inline-block rounded text-xs py-0.5"
                  :class="typeColor(entry.type)"
                  >{{ entry.type }}</span
                >
                <span class="text-xs text-gray-400 ml-1">{{ formatTime(entry.timestamp) }}</span>
              </div>
              <div class="text-xs text-gray-700 mt-0.5">
                {{ entry.description }}
              </div>
            </div>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'

// --- Props ---
interface AuditEntry {
  id: string | number
  user: string
  avatar?: string
  type: string
  description: string
  timestamp: string | number | Date // ISO or unix ms
}
const props = defineProps<{
  entries: AuditEntry[]
}>()

// --- Filters ---
const filterUser = ref('')
const filterType = ref('')

const filteredEntries = computed(() =>
  props.entries.filter(
    (e) =>
      (!filterUser.value || e.user === filterUser.value) &&
      (!filterType.value || e.type === filterType.value)
  )
)

// --- Unique users/types for filtering ---
const uniqueUsers = computed(() => Array.from(new Set(props.entries.map((e) => e.user))))
const uniqueTypes = computed(() => Array.from(new Set(props.entries.map((e) => e.type))))

// --- Group by date (YYYY-MM-DD) ---
function dateKey(ts: string | number | Date) {
  const d = new Date(ts)
  return d.toISOString().slice(0, 10)
}
const groupedEntries = computed(() => {
  const grouped: Record<string, AuditEntry[]> = {}
  for (const e of filteredEntries.value) {
    const key = dateKey(e.timestamp)
    if (!grouped[key]) grouped[key] = []
    grouped[key].push(e)
  }
  // Sort by date descending
  return Object.fromEntries(Object.entries(grouped).sort((a, b) => (a[0] < b[0] ? 1 : -1)))
})

// --- Helpers ---
function formatDate(key: string) {
  const d = new Date(key)
  return d.toLocaleDateString(undefined, { year: 'numeric', month: 'long', day: 'numeric' })
}
function formatTime(ts: string | number | Date) {
  const d = new Date(ts)
  return d.toLocaleTimeString(undefined, { hour: '2-digit', minute: '2-digit', second: '2-digit' })
}
function typeColor(type: string) {
  // Simple color mapping by event type (customize as needed)
  switch (type) {
    case 'Edit':
      return 'bg-blue-100 text-blue-700'
    case 'Export':
      return 'bg-green-100 text-green-700'
    case 'Delete':
      return 'bg-red-100 text-red-700'
    case 'Comment':
      return 'bg-yellow-100 text-yellow-700'
    default:
      return 'bg-gray-200 text-gray-700'
  }
}
function defaultAvatar(user: string) {
  // Use a letter avatar if no avatar URL (e.g., from UI Avatars)
  const bg = '0074D9'
  return `https://ui-avatars.com/api/?name=${encodeURIComponent(user)}&background=${bg}&color=fff&size=64`
}
</script>

<style scoped>
/* .input {
  @apply px-2 py-1 border rounded outline-none;
}
.input-xs {
  @apply text-xs px-1 py-0.5;
} */
</style>
