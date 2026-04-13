<script setup>
defineProps({
  title: { type: String, default: '' },
  subtitle: { type: String, default: '' }
})
</script>

<template>
  <div class="divider-teal">
    <div class="divider-content">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.divider-teal {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  width: 100%;
  background: #16A0AC;
  color: #ffffff;
  text-align: center;
  padding: 2rem 3rem;
}
.divider-content {
  max-width: 80%;
}
.divider-content :deep(h1) {
  font-family: Garamond, Georgia, 'Times New Roman', serif;
  font-size: 3rem;
  font-weight: 700;
  margin-bottom: 0.5rem;
  color: #ffffff;
}
.divider-content :deep(h2) {
  font-family: Arial, 'Helvetica Neue', sans-serif;
  font-size: 1.5rem;
  font-weight: 400;
  color: rgba(255, 255, 255, 0.9);
  margin-bottom: 0.25rem;
}
.divider-content :deep(p) {
  font-family: Arial, 'Helvetica Neue', sans-serif;
  font-size: 1.2rem;
  color: rgba(255, 255, 255, 0.85);
  margin: 0.25rem 0;
}
</style>
