<template>
  <div :id="containerId"
    class="row justify-content-between"
  >
    <div class="col-9">
      <span v-if="showPlayerCount" :class="playerCountBadgeClass">{{ session.playerCount }}er</span>
      <span v-if="showWinner">
        <img class="mx-1" :src="session.winnerImagePath" height="20"></img>
        <span class="badge gold font-weight-light">{{ session.winnerInitials }}</span>
      </span>
      <span class="ml-1"><a :href="session.uri">{{ session.uid }}</a></span>
    </div>
    <div class="col-3 text-right">
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
      },

      showWinner: function () {
        return this.session.winnerImagePath && this.session.winnerInitials
      },

      playerCountBadgeClass: function () {
        return {
          'badge': true,
          'bisque': this.session.active,
          'darkgreen': this.session.completed
        }
      }
    }
  }
</script>
