<template>
  <div class="slidev-layout default-layout">
    <slot />
    <div class="slide-footer">
      <span>The /epi Workflow -- Synthetic RCT Walkthrough</span>
      <span>examples/epi-study</span>
    </div>
  </div>
</template>

<style scoped>
.default-layout {
  height: 100%;
  display: flex;
  flex-direction: column;
}
</style>
