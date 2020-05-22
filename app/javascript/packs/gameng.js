/* eslint no-console: 0 */

import Vue from 'vue/dist/vue.esm'
import App from '../components/app.vue'

document.addEventListener('DOMContentLoaded', () => {
  const gameng = new Vue({
    el: '#gameng',
    components: { App }
  })
})
