<template>
  <div :id="`game-${game.key}`">

    <div class="d-flex flex-row justify-content-between mt-2">
      <div class="px-2 pt-2">
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
          <input type="hidden" name="game_key" :value="game.key">
          <button type="submit" class="btn btn-dark btn-lg">
            New Game
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
        v-if="!session.archived || showArchived"
      >
      </game-session-row>
      <div class="mt-2">
        <a href="#" @click.prevent="toggleArchived">{{ showArchived ? 'Hide' : 'Show' }} Archived</a>
      </div>
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
        game: this.initGame,
        showArchived: false
      }
    },

    computed: {
      ...mapGetters({
        paths: 'paths',
        token: 'token',
      }),

      activeSessions: function () {
        return this.game.sessions.filter(i => i.active).sort((a,b) => (a['createdAt'] < b['createdAt']) ? 1 : -1)
      },

      completedSessions: function () {
        return this.game.sessions.filter(i => i.completed).sort((a,b) => (a['createdAt'] < b['createdAt']) ? 1 : -1)
      },

      waitingSessions: function () {
        return this.game.sessions.filter(i => i.waiting).sort((a,b) => (a['createdAt'] < b['createdAt']) ? 1 : -1)
      }
    },

    methods: {
      toggleArchived: function () {
        this.showArchived = !this.showArchived
      }
    }
  }
</script>
