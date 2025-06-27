<template>
  <div class="fixed inset-0 bg-black bg-opacity-30 z-50 flex items-center justify-center">
    <div class="bg-white rounded-lg shadow-xl max-w-lg w-full">
      <div class="px-4 py-3 border-b flex justify-between items-center">
        <slot name="header"><span class="font-bold text-lg">Modal</span></slot>
        <button class="text-gray-400 hover:text-red-500 text-xl font-bold" @click="$emit('close')">
          &times;
        </button>
      </div>
      <div class="px-4 py-3">
        <slot name="body" />
      </div>
      <div class="px-4 py-3 border-t flex justify-end space-x-2">
        <slot name="footer">
          <button class="btn btn-outline" @click="$emit('close')">Close</button>
        </slot>
      </div>
    </div>
  </div>
</template>
