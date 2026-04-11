<template>
  <div class="slidev-layout two-column-layout">
    <div class="heading-row">
      <slot name="heading" />
    </div>
    <div class="columns">
      <div class="col col-left">
        <slot name="left" />
      </div>
      <div class="col col-right">
        <slot name="right" />
      </div>
    </div>
    <div class="footer-row">
      <slot name="footer" />
    </div>
  </div>
</template>

<style scoped>
.two-column-layout {
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 1rem;
}
.columns {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.5rem;
  flex: 1;
}
.col {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
</style>
