<template>
  <div class="slidev-layout section-layout">
    <div class="section-content">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.section-layout {
  height: 100%;
  display: flex;
  align-items: center;
  background: #16213e;
  color: #ffffff;
  padding: 2rem 3rem;
}
.section-content :deep(h1) {
  font-size: 2.4rem;
  color: #ffffff;
  border-bottom: 3px solid #3b5998;
  padding-bottom: 0.5rem;
}
.section-content :deep(h2) {
  color: #ebf0f9;
}
</style>
