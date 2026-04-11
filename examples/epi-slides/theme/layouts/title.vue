<template>
  <div class="slidev-layout title-layout">
    <div class="title-content">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.title-layout {
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(180deg, #ffffff 0%, #ebf0f9 100%);
}
.title-content {
  text-align: center;
  max-width: 80%;
}
.title-content :deep(h1) {
  font-size: 2.8rem;
  border-bottom: none;
  color: #16213e;
  margin-bottom: 0.5rem;
}
.title-content :deep(h2) {
  font-size: 1.4rem;
  color: #3b5998;
  font-weight: 400;
  margin-top: 0.25rem;
}
</style>
