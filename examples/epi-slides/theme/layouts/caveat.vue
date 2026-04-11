<template>
  <div class="slidev-layout caveat-layout">
    <div class="caveat-banner">
      Synthetic data -- not a clinical finding
    </div>
    <div class="caveat-body">
      <slot />
    </div>
    <div class="slide-footer">
      <span>The /epi Workflow -- Synthetic RCT Walkthrough</span>
      <span>examples/epi-study</span>
    </div>
  </div>
</template>

<style scoped>
.caveat-layout {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.caveat-body {
  flex: 1;
  padding-top: 1rem;
}
</style>
