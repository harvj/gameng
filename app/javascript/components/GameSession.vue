<template>
  <div :id="`session-${session.uid}`">
    <div class="d-flex flex-row justify-content-between">
      <div class="p-2">
        <h2>{{ session.game.name }}</h2>
      </div>
      <div v-if="session.config.playable" class="p-2">
        <button
          class="btn btn-dark"
          @click="updateSession"
        >
          <i v-if="awaitingSessionUpdate" class="fas fa-spinner fa-pulse"></i>
          <span v-else>{{ session.config.nextActionText }}</span>
        </button>
      </div>
    </div>

    <div class="session-info">
      <table class="table">
        <tbody>
          <tr>
            <td>session:</td><td>{{ session.uid }}</td>
          </tr>
          <tr>
            <td>started:</td><td>{{ session.startedAt }}</td>
          </tr>
          <tr>
            <td>players:</td>
            <td>
              <div class="d-flex flex-row flex-wrap">
                <div v-for="player in session.players" class="p-2 mr-2 mb-2 bg-light">
                  {{ player.user.name }}
                </div>
              </div>
            </td>
          </tr>
          <tr v-if="session.completed">
            <td>completed:</td><td>{{ session.endedAt }}</td>
          </tr>
          <tr v-else>
            <td>status:</td><td>{{ session.state }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="loggedInPlayer" class="player-field">
      <div v-if="playerHasCards" class="d-flex flex-row session-cards">
        <div class="p-2">
          <h4>Your Hand</h4>
        </div>
        <div class="px-2 py-3">
          <a href="#" @click="sortCards">sort</a>
        </div>
      </div>

      <div class="d-flex flex-row flex-wrap">
        <div v-for="card in this.loggedInPlayer.cards" class="p-1">
          <button :class="`btn btn-primary my-1 ${card.color}`">
            <i :class="`fas fa-${card.iconClass}`"></i>
            {{ card.name }}
          </button>
        </div>
      </div>
    </div>

    <div class="px-2 mb-2" v-else-if="session.config.joinable">
      <button class="btn btn-dark" @click="addPlayer">
        <i v-if="awaitingAddPlayer" class="fas fa-spinner fa-pulse"></i>
        <span v-else>Join</span>
      </button>
    </div>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import callEndpoint   from '../mixins/httpClient'

  export default {
    name: 'game-session',
    mixins: [callEndpoint],

    props: {
      initGameSession: Object
    },

    data: function () {
      return {
        session: this.initGameSession,
        awaitingSessionUpdate: false,
        awaitingAddPlayer: false
      }
    },

    computed: {
      ...mapGetters(['currentUser', 'token', 'paths']),

      updateParams: function () {
        return {
          uid: this.session.uid,
          authenticity_token: this.token
        }
      },

      loggedInPlayer: function () {
        return this.session.players.find(i => i.user.username == this.currentUser.username)
      },

      playerHasCards: function () {
        return this.loggedInPlayer.cards.length > 0
      }

    },

    methods: {
      sortCards: function () {
        this.loggedInPlayer.cards = this.loggedInPlayer.cards.sort((a,b) => a.sort - b.sort)
      },

      updateSession: async function () {
        this.awaitingSessionUpdate = true
        try {
          const response = await this.callEndpoint('PATCH', this.session.uri, this.updateParams)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          this.awaitingSessionUpdate = false
        }
      },

      addPlayer: async function () {
        this.awaitingAddPlayer = true
        try {
          const response = await this.callEndpoint('POST', this.paths.playersPath, this.updateParams)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          this.awaitingAddPlayer = false
        }
      }
    }
  }
</script>
