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
          <button type="submit" class="btn btn-dark">
            Play
          </button>
        </form>
      </div>
    </div>

    <div v-if="anySessions" class="pt-4">
      <h4>Sessions</h4>
      <div v-for="session in game.sessions"
        :key="session.uid"
        class="d-flex flex-row justify-content-between"
      >
        <div class="d-flex flex-row">
          <div class="p-2"><a :href="session.uri">{{ session.uid }}</a></div>
          <div class="p-2">{{ session.state }}</div>
        </div>
        <div class="p-2">
          <a :href="session.uri" data-method="delete" class="btn btn-danger">
            <i class="fas fa-trash"></i>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    name: 'game',

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

      anySessions: function () {
        return this.game.sessions.length > 0
      }
    }
  }
</script>
