<template>
  <div id='flash-js'>
    <div v-for='(message, index) in activeMessages'
      :key='message.uid'
      :class='messageClass(message)'
    >
      <div class="mr-3">
        <a :href="paths.gamesPath">Home</a>
      </div>
      <div v-if="loggedIn" class="d-flex px-2">
        <div class="mr-3">
          <span v-html="message.content"></span>
        </div>
        <div id="user-config" class="mr-3">
          <span :title="`${currentUser.config.showAllBadges ? 'Hide User' : 'Show All'} Badges`">
            <i v-if="awaiting.includes('show_all_badges')" class="fas fa-spinner fa-pulse"></i>
            <a v-else href="#"
              @click.prevent="updateUserConfig({show_all_badges: !currentUser.config.showAllBadges})"
            >
              <i :class="eyeClass"></i>
            </a>
          </span>
          <span :title="`${currentUser.config.showBadgeValues ? 'Hide' : 'Show'} Badge Values`">
            <i v-if="awaiting.includes('show_badge_values')" class="fas fa-spinner fa-pulse"></i>
            <a v-else href="#"
              @click.prevent="updateUserConfig({show_badge_values: !currentUser.config.showBadgeValues})"
            >
              <i :class="commentClass"></i>
            </a>
          </span>
        </div>
        <div>
          <a :href="paths.logoutPath" data-method="delete" rel="nofollow">Logout</a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import httpClient     from '../mixins/httpClient'

  export default {
    name: 'flash',
    mixins: [httpClient],

    props: {
      railsMessages: { type: String, required: true }
    },

    data: function () {
      return {
        activeMessages: [],
        awaiting: []
      }
    },

    computed: {
      ...mapGetters(['loggedIn', 'paths', 'currentUser', 'token']),

      eyeClass: function () {
        return {
          'fas': true,
          'fa-eye': this.currentUser.config.showAllBadges,
          'fa-eye-slash text-muted': !this.currentUser.config.showAllBadges
        }
      },

      commentClass: function () {
        return {
          'fas': true,
          'fa-comment': this.currentUser.config.showBadgeValues,
          'fa-comment-slash text-muted': !this.currentUser.config.showBadgeValues
        }
      }
    },

    methods: {
      messageClass: function (message) {
        return `d-flex justify-content-between alert alert-${this.messageType(message.status)} mb-0 py-2`
      },

      messageType: function (status) {
        const types = {
          notice: 'info',
          alert: 'danger'
        }
        return types[status] || status
      },

      updateUserConfig: async function (config_params) {
        const action = Object.keys(config_params)[0]
        this.awaiting.push(action)
        const params = {
          authenticity_token: this.token,
          config: config_params
        }
        try {
          const response = await this.callEndpoint('PATCH', this.currentUser.configPath, params)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.$store.commit('updateCurrentUser', response.data.content.user)
            }
            const index = this.awaiting.indexOf(action)
            this.awaiting.splice(index,1)
          }, 250)
        } catch (e) {
          console.log (e)
        }
      },
    },

    mounted () {
      const messages = JSON.parse(this.railsMessages)
      Object.keys(messages).forEach(key => {
        this.messagesCreated += 1
        this.activeMessages.push(
          Object.assign({
            uid: this.messagesCreated,
            status: key,
            content: messages[key]
          })
        )
      })
    }
  }
</script>
