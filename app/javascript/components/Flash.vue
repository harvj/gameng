<template>
  <div id='flash-js'>
    <div v-for='(message, index) in activeMessages'
      :key='message.uid'
      :class='messageClass(message)'
    >
      <div class="px-2">
        <span v-html="message.content"></span>
      </div>
      <div v-if="loggedIn" class="d-flex px-2">
        <div class="mr-3">
          <a :href="paths.gamesPath">Lobby</a>
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

  export default {
    name: 'flash',

    props: {
      railsMessages: { type: String, required: true }
    },

    data: function () {
      return {
        activeMessages: []
      }
    },

    computed: {
      ...mapGetters(['loggedIn', 'paths'])
    },

    methods: {
      messageClass: function (message) {
        return `d-flex justify-content-between alert alert-${this.messageType(message.status)}`
      },

      messageType: function (status) {
        const types = {
          notice: 'info',
          alert: 'danger'
        }
        return types[status] || status
      }
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
