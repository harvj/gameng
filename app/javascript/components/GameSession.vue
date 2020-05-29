<template>
  <div :id="`session-${session.uid}`">
    <div class="d-flex flex-row justify-content-between">
      <div class="p-2">
        <h2><a :href="session.game.uri">{{ session.game.name }}</a></h2>
      </div>
      <div v-if="showActionButton" class="p-2">
        <button
          class="btn btn-dark"
          @click="updateSession"
        >
          <i v-if="awaitingSessionUpdate" class="fas fa-spinner fa-pulse"></i>
          <span v-else>{{ session.nextActionText }}</span>
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
          <tr v-if="session.completed">
            <td>completed:</td><td>{{ session.completedAt }}</td>
          </tr>
          <tr v-else>
            <td>status:</td><td>{{ session.state }}</td>
          </tr>
          <tr>
            <td>players:</td>
            <td>
              <div class="d-flex flex-row flex-wrap">
                <div v-for="player in session.players" class="p-2 mr-2 mb-2 bg-light">
                  <span v-if="player.moderator" class="badge badge-dark mr-1">mod</span>
                  {{ player.user.name }}
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="loggedInPlayer" class="player-field">
      <div class="d-flex flex-row justify-content-between p-2">
        <div>
          <h5>Your Cards</h5>
        </div>
        <div class="align-self-center">
          <a href="#" @click.prevent="changeCardGrouping">
            regroup
          </a>
        </div>
        <div class="align-self-center">
          <a href="#" @click.prevent="changeCardSort">
            change sort
          </a>
        </div>
      </div>

      <div class="d-flex flex-row" v-for="group in cardGroups" :key="group.title">
        <div class="align-self-top">
          <div class="badge badge-light mt-2 mr-2 p-2">{{ group.title }}</div>
        </div>
        <div class="d-flex flex-row flex-wrap">
          <div v-for="card in group.cards" class="p-1">
            <button :class="`btn btn-primary my-1 ${card.color}`">
              <i :class="`fas fa-${card.iconClass}`"></i>
              {{ card.name }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="px-2 mb-2" v-else-if="session.joinable">
      <button class="btn btn-dark" @click.prevent="addPlayer">
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
        awaitingAddPlayer: false,
        awaitingSessionUpdate: false,
        groupCardsBy: 'status',
        session: this.initGameSession,
        sortCardsBy: 'dealtAt'
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

      displayCards: function () {
        if (!this.loggedInPlayer) { return [] }
        return this.session.cards.filter(i => i.playerId === this.loggedInPlayer.id).sort((a,b) => a[this.sortCardsBy] - b[this.sortCardsBy])
      },

      cardGroups: function () {
        return [...new Set(this.displayCards.map(i => i[this.groupCardsBy]))].map(
          title => {
            return {
              title: title,
              cards: this.displayCards.filter(i => i[this.groupCardsBy] === title)
            }
          }
        )
      },

      loggedInPlayer: function () {
        return this.session.players.find(i => i.user.username === this.currentUser.username)
      },

      showActionButton: function () {
        if (!this.loggedInPlayer) { return false }
        return this.session.playable && (!this.session.started || this.loggedInPlayer.moderator)
      }

    },

    methods: {
      changeCardSort: function () {
        const map = {
          dealtAt: 'nameSort',
          nameSort: 'valueSort',
          valueSort: 'dealtAt'
        }
        this.sortCardsBy = map[this.sortCardsBy]
      },

      changeCardGrouping: function () {
        const map = {
          status: 'name',
          name: 'value',
          value: 'status'
        }
        this.groupCardsBy = map[this.groupCardsBy]
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
