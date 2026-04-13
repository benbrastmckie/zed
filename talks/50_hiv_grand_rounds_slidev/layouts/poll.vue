<script setup>
defineProps({
  question: { type: String, default: '' }
})
</script>

<template>
  <div class="poll-layout">
    <div class="poll-content">
      <slot />
    </div>
    <div class="poll-placeholder">
      <div class="poll-qr-area">
        <p class="poll-label">Poll Everywhere</p>
        <div class="poll-qr-box">
          <p>[ QR Code ]</p>
        </div>
        <p class="poll-url">pollev.com/nickymehtani</p>
      </div>
    </div>
  </div>
</template>

<style scoped>
.poll-layout {
  display: flex;
  flex-direction: row;
  height: 100%;
  padding: 2rem 3rem;
  gap: 2rem;
  font-family: Arial, 'Helvetica Neue', sans-serif;
}
.poll-content {
  flex: 2;
  display: flex;
  flex-direction: column;
  justify-content: center;
}
.poll-content :deep(h1) {
  font-family: Garamond, Georgia, 'Times New Roman', serif;
  font-size: 1.8rem;
  font-weight: 700;
  color: #052049;
  margin-bottom: 1.5rem;
  line-height: 1.3;
}
.poll-content :deep(ul) {
  list-style: none;
  padding: 0;
  margin: 0;
}
.poll-content :deep(li) {
  font-size: 1.15rem;
  padding: 0.6rem 1rem;
  margin: 0.3rem 0;
  border-radius: 6px;
  background: #f0f7fa;
  border-left: 4px solid #0093D0;
  color: #1a202c;
}
.poll-placeholder {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.poll-qr-area {
  text-align: center;
  padding: 1.5rem;
  border: 2px dashed #0093D0;
  border-radius: 12px;
  background: #f8fbfd;
}
.poll-label {
  font-size: 0.9rem;
  font-weight: 600;
  color: #0093D0;
  margin-bottom: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
.poll-qr-box {
  width: 140px;
  height: 140px;
  border: 1px solid #d1d5db;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 0.75rem;
  border-radius: 8px;
  background: #ffffff;
  color: #9ca3af;
  font-size: 0.85rem;
}
.poll-url {
  font-size: 0.8rem;
  color: #5f6b7a;
}
</style>
