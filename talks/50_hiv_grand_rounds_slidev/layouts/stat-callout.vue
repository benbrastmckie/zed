<script setup>
</script>

<template>
  <div class="stat-callout-layout">
    <slot />
  </div>
</template>

<style scoped>
.stat-callout-layout {
  height: 100%;
  width: 100%;
  padding: 2rem 3rem;
  display: flex;
  flex-direction: column;
  justify-content: center;
  font-family: Arial, 'Helvetica Neue', sans-serif;
}
.stat-callout-layout :deep(h1) {
  font-family: Garamond, Georgia, 'Times New Roman', serif;
  font-size: 2rem;
  font-weight: 700;
  color: #052049;
  margin-bottom: 1rem;
}
.stat-callout-layout :deep(.stat-hero) {
  font-size: 4.5rem;
  font-weight: 800;
  color: #052049;
  text-align: center;
  margin: 0.5rem 0;
  line-height: 1.1;
}
.stat-callout-layout :deep(.stat-hero .accent) {
  color: #16A0AC;
}
.stat-callout-layout :deep(.stat-subtitle) {
  font-size: 1.3rem;
  text-align: center;
  color: #5f6b7a;
  margin-bottom: 1.5rem;
}
.stat-callout-layout :deep(ul) {
  list-style: none;
  padding: 0;
  max-width: 80%;
  margin: 0 auto;
}
.stat-callout-layout :deep(li) {
  font-size: 1rem;
  padding: 0.4rem 0;
  color: #1a202c;
  border-bottom: 1px solid #e5e7eb;
}
.stat-callout-layout :deep(li:last-child) {
  border-bottom: none;
}
.stat-callout-layout :deep(strong) {
  color: #052049;
}
</style>
