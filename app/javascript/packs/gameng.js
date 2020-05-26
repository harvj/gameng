/* eslint no-console: 0 */
import store from '../vuex/store'

import Vue from 'vue/dist/vue.esm'

import CommonData from '../components/CommonData.vue'
import Flash from '../components/Flash.vue'
import Game from '../components/Game.vue'
import GamesIndex from '../components/GamesIndex.vue'
import GameSession from '../components/GameSession.vue'
import LandingPage from '../components/LandingPage.vue'

document.addEventListener('DOMContentLoaded', () => {
  const gameng = new Vue({
    el: '#gameng',
    components: {
      CommonData,
      Flash,
      Game,
      GamesIndex,
      GameSession,
      LandingPage
    },

    store
  })
})
