<template>
  <div :id="containerId"
    class="d-flex flex-row justify-content-between"
  >
    <div class="d-flex flex-row">
      <div class="align-self-center">
        <span v-if="showPlayerCount" class="badge mr-1">{{ session.playerCount }}er</span>
        <a :href="session.uri">{{ session.uid }}</a>
      </div>
    </div>
    <div class="d-flex flex-row">
      <div v-if="session.active"
        class="align-self-center pr-2"
      >
        {{ session.startedAtDate }}
      </div>
      <div v-if="session.completed">
        {{ session.completedAtDate }}
      </div>
      <div class="align-items-start">
        <a v-if="!session.completed"
          :href="session.uri"
          data-method="delete"
          class="btn btn-danger"
        >
          <i class="fas fa-trash"></i>
        </a>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'game-session-row',

    props: {
      initSession: Object
    },

    data: function () {
      return {
        session: this.initSession
      }
    },

    computed: {
      containerId: function () {
        return `session-${this.session.uid}-row`
      },

      showPlayerCount: function () {
        return this.session.playerCount > 0
      }
    }
  }
</script>
