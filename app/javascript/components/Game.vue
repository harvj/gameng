<template>
  <div :id="`game-${game.slug}`">

    <div class="d-flex flex-row justify-content-between">
      <div class="p-2">
        <h2>{{ game.name }}</h2>
      </div>
      <div class="p-2">
        <form
          id='play-game'
          accept-charset="UTF-8"
          method="post"
          :action="paths.gameSessionsPath"
        >
          <input name="utf8" type="hidden" value="✓">
          <input type="hidden" name="authenticity_token" :value="token">
          <input type="hidden" name="slug" :value="game.slug">
          <button type="submit" class="btn btn-dark btn-lg">
            Play
          </button>
        </form>
      </div>
    </div>

    <div v-if="waitingSessions.length > 0"
      id="waiting-sessions"
      class="rounded mt-4 bg-light p-3"
    >
      <h5>Waiting for players...</h5>
      <game-session-row v-for="session in waitingSessions"
        :key="session.uid"
        :init-session="session"
      >
      </game-session-row>
    </div>

    <div v-if="activeSessions.length > 0"
      id="active-sessions"
      class="rounded mt-4 bg-warning p-3"
    >
      <h5>In Progress</h5>
      <game-session-row v-for="session in activeSessions"
        :key="session.uid"
        :init-session="session"
      >
      </game-session-row>
    </div>

    <div v-if="completedSessions.length > 0"
      id="completed-sessions"
      class="rounded mt-4 bg-success p-3"
    >
      <h5>Completed</h5>
      <game-session-row v-for="session in completedSessions"
        :key="session.uid"
        :init-session="session"
      >
      </game-session-row>
    </div>

  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import GameSessionRow from '../components/GameSessionRow.vue'

  export default {
    name: 'game',
    components: {
      GameSessionRow
    },

    props: {
      initGame: Object
    },

    data: function () {
      return {
        game: this.initGame
      }
    },

    computed: {
      ...mapGetters({
        paths: 'paths',
        token: 'token',
      }),

      activeSessions: function () {
        return this.game.sessions.filter(i => i.active)
      },

      completedSessions: function () {
        return this.game.sessions.filter(i => i.completed)
      },

      waitingSessions: function () {
        return this.game.sessions.filter(i => i.waiting)
      }
    }
  }
</script>
