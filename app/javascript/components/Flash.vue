<template>
  <div id='flash-js'>
    <div v-for='message in activeMessages'
      :key='message.uid'
      :class='messageClass(message)'
    >
      <span v-html="message.content"></span>
    </div>
  </div>
</template>

<script>
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

    methods: {
      messageClass: function (message) {
        return `alert alert-${this.messageType(message.status)}`
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
