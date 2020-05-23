import Vue from 'vue/dist/vue.esm'
import Vuex from 'vuex'
import commonData from './modules/commonData'

Vue.use(Vuex)

export default new Vuex.Store({
  modules: {
    commonData
  }
})
