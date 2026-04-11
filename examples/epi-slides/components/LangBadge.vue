<script setup>
/**
 * LangBadge - Small language/tool badge (Py / R / Quarto / shell / etc.)
 *
 * Props:
 *   lang  (String, required) - One of: py, python, r, quarto, shell, bash, sql
 *   label (String, optional) - Override the displayed label
 *
 * Usage:
 *   <LangBadge lang="r" />
 *   <LangBadge lang="quarto" />
 *   <LangBadge lang="py" label="Python 3.12" />
 */
const props = defineProps({
  lang: { type: String, required: true },
  label: { type: String, default: '' }
})

const spec = {
  py:     { label: 'Py',     color: '#1e40af', bg: '#dbeafe' },
  python: { label: 'Python', color: '#1e40af', bg: '#dbeafe' },
  r:      { label: 'R',      color: '#1e3a8a', bg: '#e0e7ff' },
  quarto: { label: 'Quarto', color: '#065f46', bg: '#d1fae5' },
  shell:  { label: 'sh',     color: '#374151', bg: '#e5e7eb' },
  bash:   { label: 'bash',   color: '#374151', bg: '#e5e7eb' },
  sql:    { label: 'SQL',    color: '#7c2d12', bg: '#ffedd5' }
}

const resolved = () => {
  const s = spec[props.lang.toLowerCase()] || { label: props.lang, color: '#374151', bg: '#e5e7eb' }
  return { ...s, label: props.label || s.label }
}
</script>

<template>
  <span
    class="lang-badge"
    :style="{ color: resolved().color, background: resolved().bg }"
  >
    {{ resolved().label }}
  </span>
</template>

<style scoped>
.lang-badge {
  display: inline-block;
  font-family: 'Courier New', monospace;
  font-size: 0.7em;
  font-weight: 700;
  padding: 0.1rem 0.45rem;
  border-radius: 3px;
  letter-spacing: 0.02em;
  vertical-align: middle;
}
</style>
