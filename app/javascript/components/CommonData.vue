<template>
  <div></div>
</template>

<script>
  export default {
    name: 'common-data',

    props: {
      commonData: { type: Object, required: true }
    },

    created () {
      this.$store.commit('loadCommon', this.commonData)
    }
  }
</script>
