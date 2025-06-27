<template>
  <div class="p-6">
    <h2 class="text-xl font-bold mb-4">Data Profiler</h2>
    <div v-if="!profile || !profile.rowCount" class="text-gray-400">
      No data loaded for profiling.
    </div>
    <div v-else>
      <!-- Summary Cards -->
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-6">
        <div class="bg-white rounded shadow p-4 flex flex-col items-center">
          <span class="text-xs text-gray-400 mb-1">Rows</span>
          <span class="text-xl font-bold">{{ profile.rowCount }}</span>
        </div>
        <div class="bg-white rounded shadow p-4 flex flex-col items-center">
          <span class="text-xs text-gray-400 mb-1">Unique Values</span>
          <span class="text-xl font-bold">{{ profile.uniqueCount }}</span>
        </div>
        <div class="bg-white rounded shadow p-4 flex flex-col items-center">
          <span class="text-xs text-gray-400 mb-1">Missing (%)</span>
          <span class="text-xl font-bold">{{ profile.missingPct }}%</span>
        </div>
        <div class="bg-white rounded shadow p-4 flex flex-col items-center">
          <span class="text-xs text-gray-400 mb-1">Languages</span>
          <span class="text-xl font-bold">{{ profile.languages.join(', ') || 'n/a' }}</span>
        </div>
      </div>

      <!-- Warnings -->
      <div v-if="profile.warnings && profile.warnings.length" class="mb-6">
        <div class="bg-yellow-100 text-yellow-900 rounded p-3 flex flex-col space-y-1">
          <div class="font-semibold">Warnings</div>
          <ul class="list-disc ml-4 text-xs">
            <li v-for="(warn, idx) in profile.warnings" :key="idx">{{ warn }}</li>
          </ul>
        </div>
      </div>

      <!-- Value Distribution -->
      <div v-if="profile.valueHistogram" class="mb-6">
        <h3 class="font-semibold text-md mb-2">Value Distribution</h3>
        <canvas ref="histCanvas" height="80"></canvas>
      </div>

      <!-- PII Table -->
      <div v-if="profile.piiStats && profile.piiStats.length" class="mb-6">
        <h3 class="font-semibold text-md mb-2">PII Detection</h3>
        <table class="w-full text-xs bg-white rounded shadow">
          <thead>
            <tr class="border-b">
              <th class="px-2 py-1 text-left">Type</th>
              <th class="px-2 py-1 text-left">Sample Value</th>
              <th class="px-2 py-1 text-left">Risk</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="pii in profile.piiStats" :key="pii.type" class="border-b">
              <td class="px-2 py-1">{{ pii.type }}</td>
              <td class="px-2 py-1 font-mono">{{ pii.sample }}</td>
              <td class="px-2 py-1">
                <span :class="riskColor(pii.risk)" class="px-2 rounded">{{ pii.risk }}</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Encoding Issues -->
      <div v-if="profile.encodingIssues && profile.encodingIssues.length" class="mb-6">
        <h3 class="font-semibold text-md mb-2">Encoding Issues</h3>
        <ul class="list-disc ml-5 text-xs text-red-500">
          <li v-for="(issue, idx) in profile.encodingIssues" :key="idx">{{ issue }}</li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'

// --- Props: expects a pre-profiled object, but could also accept raw data ---
const props = defineProps<{
  profile: {
    rowCount: number
    uniqueCount: number
    missingPct: number
    languages: string[]
    warnings?: string[]
    valueHistogram?: { [key: string]: number }
    piiStats?: { type: string; sample: string; risk: 'Low' | 'Medium' | 'High' }[]
    encodingIssues?: string[]
  }
}>()

// --- Chart.js (for histogram, lazy load for SSR) ---
let chart: any = null
const histCanvas = ref<HTMLCanvasElement | null>(null)

watch(
  () => props.profile.valueHistogram,
  (hist) => {
    if (hist && histCanvas.value) {
      renderHistogram(hist)
    }
  },
  { immediate: true }
)

onMounted(() => {
  if (props.profile.valueHistogram && histCanvas.value) {
    renderHistogram(props.profile.valueHistogram)
  }
})

async function renderHistogram(hist: { [key: string]: number }) {
  // Lazy import Chart.js (not in SSR)
  if (typeof window === 'undefined') return
  const { Chart, registerables } = await import('chart.js')
  Chart.register(...registerables)
  if (chart) chart.destroy()
  chart = new Chart(histCanvas.value as HTMLCanvasElement, {
    type: 'bar',
    data: {
      labels: Object.keys(hist),
      datasets: [
        {
          label: 'Count',
          data: Object.values(hist),
          borderRadius: 4
        }
      ]
    },
    options: {
      plugins: { legend: { display: false } },
      scales: { y: { beginAtZero: true } },
      responsive: true,
      maintainAspectRatio: false
    }
  })
}

// Helper: Risk color
function riskColor(risk: string) {
  if (risk === 'High') return 'bg-red-500 text-white'
  if (risk === 'Medium') return 'bg-yellow-400 text-black'
  return 'bg-green-500 text-white'
}
</script>

<style scoped>
table {
  border-collapse: collapse;
}
</style>
