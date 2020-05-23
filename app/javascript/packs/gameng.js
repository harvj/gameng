/* eslint no-console: 0 */

import Vue from 'vue/dist/vue.esm'

import App from '../components/app.vue'
import Flash from '../components/Flash.vue'

document.addEventListener('DOMContentLoaded', () => {
  const gameng = new Vue({
    el: '#gameng',
    components: {
      App,
      Flash
    }
  })
})
