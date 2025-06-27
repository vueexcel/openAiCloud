<template>
  <Card>
    <div class="flex flex-col space-y-2">
      <h2 class="text-lg font-bold">AI Chunking Recommendation</h2>
      <p class="text-sm">
        Optimized for your selected LLM: <span class="font-mono">{{ llmModel }}</span>
      </p>
      <Button @click="getRecommendation" :loading="loading"> Get Recommendation </Button>
      <div v-if="recommendation">
        <p>
          Recommended chunk size: <b>{{ recommendation.size }}</b> tokens
        </p>
        <ul>
          <li v-for="(reason, idx) in recommendation.reasons" :key="idx">
            <span class="text-xs text-gray-600">- {{ reason }}</span>
          </li>
        </ul>
        <Button @click="applyRecommendation">Apply</Button>
      </div>
    </div>
  </Card>
</template>
<script setup>
import { ref } from 'vue'
const llmModel = ref('GPT-4')
const loading = ref(false)
const recommendation = ref(null)

function getRecommendation() {
  loading.value = true
  // fetch from API...
  setTimeout(() => {
    recommendation.value = {
      size: 2000,
      reasons: [
        'Matches context window of GPT-4',
        'Preserves semantic integrity',
        'Optimal for batch processing'
      ]
    }
    loading.value = false
  }, 1500)
}
function applyRecommendation() {
  // ...set chunk size etc.
}
</script>
<style scoped>
/* .input {
  @apply px-3 py-2 border rounded outline-none;
}
.range {
  @apply w-48 accent-blue-500;
}
.btn {
  @apply px-3 py-1 rounded font-medium cursor-pointer;
}
.btn-outline {
  @apply border border-blue-500 text-blue-500 hover:bg-blue-500 hover:text-white transition;
}
.btn-primary {
  @apply bg-blue-600 text-white hover:bg-blue-700 transition;
}
.btn-xs {
  @apply text-xs px-2 py-1;
} */
</style>
