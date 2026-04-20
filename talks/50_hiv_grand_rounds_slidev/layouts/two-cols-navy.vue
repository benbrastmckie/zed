<script setup>
</script>

<template>
  <div class="two-cols-navy">
    <div class="navy-header">
      <slot name="title" />
    </div>
    <div class="navy-columns">
      <div class="navy-col navy-left">
        <slot name="left" />
      </div>
      <div class="navy-col navy-right">
        <slot name="right" />
      </div>
    </div>
  </div>
</template>

<style scoped>
.two-cols-navy {
  height: 100%;
  width: 100%;
  background: #052049;
  color: #ffffff;
  padding: 2rem 3rem;
  display: flex;
  flex-direction: column;
}
.navy-header {
  margin-bottom: 1.5rem;
}
.navy-header :deep(h1) {
  font-family: Garamond, Georgia, 'Times New Roman', serif;
  font-size: 2.2rem;
  font-weight: 700;
  color: #ffffff;
}
.navy-columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 2.5rem;
  flex: 1;
}
.navy-col :deep(h2),
.navy-col :deep(h3) {
  font-family: Garamond, Georgia, 'Times New Roman', serif;
  color: #16A0AC;
  font-size: 1.3rem;
  margin-bottom: 0.75rem;
}
.navy-col :deep(ul) {
  list-style: none;
  padding: 0;
}
.navy-col :deep(li) {
  font-family: Arial, 'Helvetica Neue', sans-serif;
  font-size: 1rem;
  padding: 0.35rem 0;
  color: rgba(255, 255, 255, 0.92);
  border-bottom: 1px solid rgba(255, 255, 255, 0.1);
}
.navy-col :deep(li:last-child) {
  border-bottom: none;
}
.navy-col :deep(strong) {
  color: #16A0AC;
}
</style>
