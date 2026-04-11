<script setup>
/**
 * CodeDiff - Two-band before/after code/content comparison
 *
 * Props:
 *   beforeTitle (String, optional) - Title of the "before" band (default: "Before")
 *   afterTitle  (String, optional) - Title of the "after" band  (default: "After")
 *   beforeLang  (String, optional) - Language label / badge for the before band
 *   afterLang   (String, optional) - Language label / badge for the after band
 *
 * Slots:
 *   before - Content for the left/before band
 *   after  - Content for the right/after band
 *
 * Usage:
 *   <CodeDiff beforeTitle="Hostile environment" afterTitle="Upgraded stack"
 *             beforeLang="base-R" afterLang="survival::coxph">
 *     <template #before>... old code ...</template>
 *     <template #after>... new code ...</template>
 *   </CodeDiff>
 */
const props = defineProps({
  beforeTitle: { type: String, default: 'Before' },
  afterTitle: { type: String, default: 'After' },
  beforeLang: { type: String, default: '' },
  afterLang: { type: String, default: '' }
})
</script>

<template>
  <div class="code-diff">
    <div class="code-band code-band-before">
      <div class="band-header">
        <span class="band-title">{{ beforeTitle }}</span>
        <span v-if="beforeLang" class="band-lang">{{ beforeLang }}</span>
      </div>
      <div class="band-body">
        <slot name="before" />
      </div>
    </div>
    <div class="code-band code-band-after">
      <div class="band-header">
        <span class="band-title">{{ afterTitle }}</span>
        <span v-if="afterLang" class="band-lang">{{ afterLang }}</span>
      </div>
      <div class="band-body">
        <slot name="after" />
      </div>
    </div>
  </div>
</template>

<style scoped>
.code-diff {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1rem;
  align-items: stretch;
  width: 100%;
}
.code-band {
  display: flex;
  flex-direction: column;
  border-radius: 6px;
  overflow: hidden;
  font-size: 0.8em;
}
.code-band-before {
  border: 1px solid #d97706;
  background: #fffbeb;
}
.code-band-after {
  border: 1px solid #059669;
  background: #ecfdf5;
}
.band-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.4rem 0.75rem;
  font-weight: 600;
  border-bottom: 1px solid rgba(0, 0, 0, 0.08);
}
.code-band-before .band-header {
  background: #fef3c7;
  color: #92400e;
}
.code-band-after .band-header {
  background: #d1fae5;
  color: #065f46;
}
.band-title {
  font-size: 0.95em;
}
.band-lang {
  font-family: 'Courier New', monospace;
  font-size: 0.75em;
  padding: 0.1rem 0.4rem;
  background: rgba(0, 0, 0, 0.06);
  border-radius: 3px;
}
.band-body {
  padding: 0.75rem;
  flex: 1;
  line-height: 1.4;
}
.band-body :deep(pre) {
  margin: 0;
  background: transparent !important;
  font-size: 0.85em;
}
.band-body :deep(code) {
  font-family: 'Courier New', monospace;
}
</style>
