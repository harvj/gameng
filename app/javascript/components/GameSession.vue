<template>
  <div :id="`session-${session.uid}`">
    <div class="d-flex flex-row justify-content-between">
      <div class="p-2">
        <h2><a :href="session.game.uri">{{ session.game.name }}</a></h2>
      </div>
      <div v-if="showActionButton" class="p-2">
        <button
          class="btn btn-dark"
          @click.prevent="updateSession"
        >
          <i v-if="awaitingSessionUpdate" class="fas fa-spinner fa-pulse"></i>
          <span v-else>{{ session.nextActionPrompt }}</span>
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
                <div v-for="player in session.players" :class="playerBadgeClass(player)">
                  <span v-if="player.turnOrder" class="badge badge-info mr-1">{{ player.turnOrder }}</span>
                  {{ player.user.name }}
                  <span v-if="player.score" class="badge badge-dark mr-1">{{ player.score }}</span>
                </div>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <div v-if="session.loggedInPlayer && this.session.started" class="player-field">
      <div v-if="this.session.completed" class="p-2">
        <h5>Your Play History</h5>
        <div class="p-2">
          <div v-for="frame in session.loggedInPlayer.playHistory" :key="frame.id" class="row">
            <div class="col-4">{{ frame.state }}</div>
            <div class="col-6">{{ frame.subject.value }} {{ frame.subject.name }}</div>
          </div>
        </div>
      </div>


      <div v-if="!this.session.completed || !session.loggedInPlayer.score" class="p-2">
        <h5>Actions</h5>
        <div class="d-flex flex-row">
          <div v-if="isCurrentPlayer(session.loggedInPlayer)">
            <div v-if="session.loggedInPlayer.canPass" class="d-flex flex-row flex-wrap">
              <button
                class="btn btn-dark my-1"
                @click.prevent="playerPass(session.loggedInPlayer)"
              >
                <span v-if="awaitingPlayerPass">
                  <i class="fas fa-spinner fa-pulse"></i>
                </span>
                <span v-else>Pass</span>
              </button>
            </div>
            <div v-else>
              Your turn. Click a card below to play it.
            </div>
          </div>
          <div v-else-if="this.session.completed">
            <div class="form-group row">
              <div class="col-6">
                <label for="player-score" class="sr-only">Your Score</label>
                <input
                  type="text"
                  class="form-control"
                  id="player-score"
                  placeholder="Your Score"
                  v-model="playerParams.score"
                >
              </div>
              <button
                type="submit"
                class="btn btn-dark"
                @click.prevent="playerUpdate(session.loggedInPlayer)"
              >
                <span v-if="awaitingPlayerUpdate">
                  <i class="fas fa-spinner fa-pulse"></i>
                </span>
                <span v-else>Submit</span>
              </button>
            </div>
          </div>
          <div v-else>{{ this.session.currentPlayer.user.name }}'s turn...</div>
        </div>
      </div>

      <div v-if="displayCards.length > 0" class="d-flex flex-row justify-content-between p-2">
        <div>
          <h5>Your Cards</h5>
        </div>
        <div class="align-self-center">
          grouped by:
          <a href="#" @click.prevent="changeCardGrouping">
            {{ session.terms[groupCardsBy] }}
          </a>
        </div>
        <div class="align-self-center">
          sorted by:
          <a href="#" @click.prevent="changeCardSort">
            {{ session.terms[sortCardsBy] }}
          </a>
        </div>
      </div>

      <div class="d-flex flex-row" v-for="group in cardGroups" :key="group.title">
        <div class="align-self-top">
          <div class="badge badge-light mt-2 mr-2 p-2">{{ group.title }}</div>
        </div>
        <div class="d-flex flex-row flex-wrap">
          <div v-for="card in group.cards" class="p-1">
            <button
              :class="`btn btn-primary my-1 ${card.color}`"
              :disabled="!card.playable || !isCurrentPlayer(session.loggedInPlayer)"
              @click.prevent="playCard(card)"
            >
              <span v-if="awaitingPlayCard.includes(card.id)">
                <i class="fas fa-spinner fa-pulse"></i>
              </span>
              <span v-else>
                <i :class="`fas fa-${card.iconClass}`"></i>
                {{ card.name }}
              </span>
            </button>
          </div>
        </div>
      </div>
    </div>

    <div class="px-2 mb-2" v-else-if="session.joinable && !session.loggedInPlayer">
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
        awaitingPlayerPass: false,
        awaitingPlayerUpdate: false,
        awaitingPlayCard: [],
        groupCardsBy: 'dealtDuringState',
        session: this.initGameSession,
        sortCardsBy: 'status',
        playerParams: {
          score: null
        }
      }
    },

    computed: {
      ...mapGetters(['currentUser', 'token', 'paths']),

      updateParams: function () {
        return {
          uid: this.session.uid,
          authenticity_token: this.token,
          player: this.playerParams
        }
      },

      displayCards: function () {
        if (!this.session.loggedInPlayer) { return [] }
        return this.session.loggedInPlayer.cards.sort((a,b) => (a[this.sortGroupsBy] > b[this.sortGroupsBy]) ? 1 : -1)
      },

      cardGroups: function () {
        return [...new Set(this.displayCards.map(i => i[this.groupCardsBy]))].map(
          title => {
            return {
              title: title,
              cards: this.displayCards.filter(i => i[this.groupCardsBy] === title).sort((a,b) => (a[this.sortCardsBy] > b[this.sortCardsBy]) ? 1 : -1)
            }
          }
        )
      },

      sortGroupsBy: function () {
        const map = {
          dealtDuringState: 'dealtAt',
          status: 'status',
          name: 'nameSort',
          value: 'valueSort'
        }
        return map[this.groupCardsBy]
      },

      showActionButton: function () {
        if (!this.session.loggedInPlayer) { return false }
        return this.session.playable && !this.session.started
      }

    },

    methods: {
      isCurrentPlayer: function (player) {
        if (!this.session.started) { return false }
        if (this.session.completed) { return false }
        return player.id === this.session.currentPlayer.id
      },

      playerBadgeClass: function (player) {
        return {
          'p-2 mr-2 mb-2 rounded': true,
          'bg-light': !this.isCurrentPlayer(player) && !player.winner,
          'btn-primary info': this.isCurrentPlayer(player),
          'bg-warning': player.winner,
        }
      },

      changeCardSort: function () {
        const map = {
          status: 'nameSort',
          nameSort: 'valueSort',
          valueSort: 'status'
        }
        this.sortCardsBy = map[this.sortCardsBy]
      },

      changeCardGrouping: function () {
        const map = {
          status: 'name',
          name: 'value',
          value: 'dealtDuringState',
          dealtDuringState: 'status'
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
      },

      playCard: async function (card) {
        this.awaitingPlayCard.push(card.id)
        console.log(this.awaitingPlayCard)
        try {
          const response = await this.callEndpoint('PATCH', card.playCardPath, this.updateParams)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          const index = this.awaitingPlayCard.indexOf(card.id)
          this.awaitingPlayCard.splice(index,1)
        }
      },

      playerPass: async function (player) {
        this.awaitingPlayerPass = true
        try {
          const response = await this.callEndpoint('PATCH', player.passPath, this.updateParams)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          this.awaitingPlayerPass = false
        }
      },

      playerUpdate: async function (player) {
        this.awaitingPlayerUpdate = true
        try {
          const response = await this.callEndpoint('PATCH', player.playerPath, this.updateParams)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          this.awaitingPlayerUpdate = false
        }
      }
    }
  }
</script>
