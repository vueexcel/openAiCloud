<template>
  <div class="overflow-y-auto">
    <div class="m-4 p-4 rounded-lg border border-stone-400">
      <DataSourceManager @select="uploadedFile" />
      <ChunkingControls />
    </div>
    <div class="m-4 p-4 rounded-lg border border-stone-400">
      <PipelineBuilder />
      <NERChunking />
    </div>
    <!-- <AIChunkingRecommendation /> -->
    <div class="m-4 p-4 rounded-lg border border-stone-400">
      <!-- <DataProfiler :profile="exampleProfile" /> -->
      <AnonymizationPanel :fields="piiFields" />
    </div>
    <div class="m-4 p-4 rounded-lg border border-stone-400">
      <AudioLog />
      <ExportPanel />
    </div>

    <!-- <PipelineBuilder /> -->
  </div>
  <!-- <AnonymizationPanel/> -->
  <!-- <UserAvatar name="Jane Doe" /> -->
</template>
<script setup lang="ts">
import AIChunkingRecommendation from '../components/AIChunkingRecommendation.vue'
import AnonymizationPanel from '../components/AnonymizationPanel.vue'
import ChunkingControls from '../components/ChunkingControls.vue'
import DataProfiler from '../components/DataProfiler.vue'
import DataSourceManager from '../components/DataSourceManager.vue'
import NERChunking from '../components/NERChunking.vue'
import PipelineBuilder from '../components/PipelineBuilder.vue'
import UserAvatar from '../shared/UserAvatar.vue'
import AuditLog from '../components/AuditLog.vue'
import ExportPanel from '../components/ExportPanel.vue'

// Import the PiiField type if not already imported
// import type { PiiField } from '../components/AnonymizationPanel.vue'

const piiFields: Array<{
  name: string
  type: string
  sample: string
  anonymize: boolean
  method: 'mask' | 'hash' | 'redact' | 'custom'
}> = [
  { name: 'email', type: 'Email', sample: 'jane@company.com', anonymize: true, method: 'mask' },
  { name: 'phone', type: 'Phone', sample: '+4912345678', anonymize: false, method: 'mask' }
]
const auditEntries = [
  {
    id: 1,
    user: 'Alice',
    type: 'Edit',
    description: 'Changed chunk size from 1000 to 2000.',
    timestamp: '2024-06-22T14:20:10Z'
  },
  {
    id: 2,
    user: 'Bob',
    type: 'Export',
    description: 'Exported pipeline as JSON.',
    timestamp: '2024-06-22T15:40:12Z'
  },
  {
    id: 3,
    user: 'Alice',
    type: 'Comment',
    description: 'Added note: Check GDPR for PII columns.',
    timestamp: '2024-06-21T09:12:30Z'
  }
]

const exampleProfile: {
  rowCount: number
  uniqueCount: number
  missingPct: number
  languages: string[]
  warnings?: string[]
  valueHistogram?: { [key: string]: number }
  piiStats?: { type: string; sample: string; risk: 'High' | 'Medium' | 'Low' }[]
  encodingIssues?: string[]
} = {
  rowCount: 1200,
  uniqueCount: 1080,
  missingPct: 1,
  languages: ['en', 'de'],
  warnings: ['High duplicate ratio detected', 'Possible mixed encoding'],
  valueHistogram: { A: 120, B: 340, C: 230, D: 510 },
  piiStats: [
    { type: 'Email', sample: 'john.doe@email.com', risk: 'High' },
    { type: 'Phone', sample: '+4912345678', risk: 'Medium' }
  ],
  encodingIssues: ['Found invalid UTF-8 in rows 44, 301, 1058']
}
function uploadedFile(src) {
  console.log(src, 'source')
}
</script>
