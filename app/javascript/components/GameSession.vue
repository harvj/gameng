<template>
  <div :id="`session-${session.uid}`">

    <!-- Player Prompt -->
    <div v-if="session.started && !session.completed && playerPrompt" :class="promptClass">
      <span v-if="session.loggedInPlayer.actionPhase !== 'inactive'" class="font-italic px-2">
        {{ playerPrompt }}
      </span>
      <span v-else class="font-italic px-2">{{ this.session.currentPlayerName }}'s turn...</span>
    </div>

    <!-- Session Info -->
    <div class="d-flex flex-row justify-content-between mt-2">
      <div class="p-2">
        <strong><a :href="session.game.uri">{{ session.game.name }}</a></strong>:
        {{ session.uid }}
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
      <div v-else class="p-2">
        <span v-if="session.completed">completed: {{ session.completedAt }}</span>
        <span v-else>{{ session.state }}</span>
      </div>
    </div>

    <!-- Player Buttons -->
    <div class="d-flex flex-row flex-wrap p-2">
      <div v-for="player in session.players">
        <button
          :class="playerButtonClass(player)"
          @click.prevent="handlePlayerClick(player)"
          :disabled="playerButtonDisabled(player)"
        >
          <div :class="playerButtonSubclass">
            <span v-if="player.turnOrder" class="badge badge-secondary mr-1">{{ player.turnOrder }}</span>
            <i v-if="isCurrentPlayer(player)" class="fas fa-user-clock"></i>
            <i v-if="player.winner" class="fas fa-trophy"></i>
            {{ player.user.name }}
            <span v-if="player.role">
              <img v-if="player.role.imagePath" :src="player.role.imagePath" height="24"></img>
              <span v-else :class="`badge ${player.role.color} mr-1`">{{ titleize(player.role.name)[0] }}</span>
            </span>
            <span v-if="player.score" class="badge badge-dark mr-1">{{ player.score }}</span>
          </div>
          <div class="mt-1" :class="playerButtonSubclass">
            <span v-for="badge in player.badges"
              v-if="currentUser.config.showAllBadges || !badge.hideable"
              :class="`badge mr-1 ${badge.color}`"
            >
              <i :class="`fas fa-${badge.icon_class}`"></i>
              <span v-if="badge.symbol">{{ badge.symbol }}</span>
              <span v-if="currentUser.config.showBadgeValues">{{ badge.value }}</span>
            </span>
          </div>
        </button>
      </div>
    </div>

    <!-- Score Form -->
    <div v-if="this.session.promptForPlayerScore && session.loggedInPlayer && !session.loggedInPlayer.score" class="d-flex flex-row p-2 mt-2">
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

    <hr>

    <!-- Join Button -->
    <div class="px-2 mb-2" v-if="session.joinable && !session.loggedInPlayer">
      <button class="btn btn-dark" @click.prevent="addPlayer">
        <i v-if="awaitingAddPlayer" class="fas fa-spinner fa-pulse"></i>
        <span v-else>Join</span>
      </button>
    </div>

    <!-- Display Player Cards and Actions -->
    <div v-if="displayPlayer && this.session.started" class="container px-2">

      <!-- -- Card title and player action buttons -->
      <div :class="`row justify-content-${session.allowDisplayPlayerSwitching ? 'between' : 'end'}`">
        <h5 v-if="session.allowDisplayPlayerSwitching" class="pl-3">{{ displayPlayerPossessive }} cards</h5>
        <div v-if="displayingLoggedInPlayer" class="d-flex flex-row flex-wrap justify-content-end pr-2">
          <div v-for="action, index in session.loggedInPlayer.possibleActions"
            class="mr-1"
            v-if="showPlayerActionButton(action)"
          >
            <button :class="playerActionButtonClass(index)"
              @click.prevent="handlePlayerActionClick(action)"
            >
              <span v-if="awaitingPlayerAction.includes(action)">
                <i class="fas fa-spinner fa-pulse"></i>
              </span>
              <span v-else>{{ titleize(action) }}</span>
            </button>
          </div>
        </div>
      </div>

      <!-- -- Card count and card display options -->
      <div class="row justify-content-between">
        <div class="pl-3">
          <h1 class="d-inline-block">{{ displayPlayer.activeCards.length }}</h1>
          <span>cards in hand</span>
        </div>
        <div class="pt-3 pr-3" v-if="displayPlayer.activeCards.length > 0 || displayPlayer.inactiveCards.length > 0">
          <span class="align-bottom">grouped by:</span>
          <a href="#" @click.prevent="changeCardGrouping">
            {{ session.terms[groupCardsBy] }}
          </a>
          <span>, sorted by:</span>
          <a href="#" @click.prevent="changeCardSort">
            {{ session.terms[sortCardsBy] }}
          </a>
        </div>
      </div>

      <!-- -- Card buttons -->
      <div v-for="cardGroup, index in [activeCards, inactiveCards]">
        <h6 class="mt-4" v-if="index === 1">
          <a href="#" @click.prevent="toggleInactiveCards">
            <span v-if="!showInactiveCards">Show</span>
            <span>Inactive Cards</span>
          </a>
        </h6>
        <div class="d-flex flex-row"
          v-for="group in cardGroup"
          v-if="index === 0 || showInactiveCards"
          :key="group.title"
        >
          <div class="align-self-top">
            <div class="badge badge-light p-2 mt-2">{{ group.title }}</div>
          </div>
          <div class="d-flex flex-row flex-wrap">
            <div v-for="card in group.cards" class="ml-2">
              <button
                :class="cardClass(card)"
                :disabled="cardButtonDisabled(card)"
                @click.prevent="handleCardClick(card)"
              >
                <span v-if="awaitingCardAction.includes(card.id)">
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
    </div>


    <!-- Additional Card Groups -->
    <div v-if="this.session.started">
      <div v-for="group in session.displayCardGroups" class="pt-3">
        <h5>
          <span>{{ titleize(group.name) }}</span>
          <span v-if="group.hasOwnProperty('count')" class="text-muted">{{ group.count }}</span>
        </h5>
        <div class="d-flex flex-row flex-wrap">
          <div v-for="card in group.cards">
            <button
              class="btn btn-primary mr-2 mb-2 light-purple"
              :disabled="cardButtonDisabled(card)"
              @click.prevent="handleCardClick(card)"
            >
              <span v-if="awaitingCardAction.includes(card.id)">
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

    <!-- Play History -->
    <div v-if="this.session.completed">
      <hr>
      <div class="px-2">
        <h5>{{ displayPlayerPossessive }} play history</h5>
        <div>
          <div v-for="frame in displayPlayer.playHistory" :key="frame.id" class="row">
            <div class="col-4">{{ frame.state }}</div>
            <div class="col-6">{{ frame.subject.value }} {{ frame.subject.name }}</div>
          </div>
        </div>
      </div>
    </div>

  </div>
</template>

<script>
  import { mapGetters } from 'vuex'
  import httpClient     from '../mixins/httpClient'
  import util           from '../mixins/util'

  export default {
    name: 'game-session',
    mixins: [httpClient, util],

    props: {
      initGameSession: Object
    },

    data: function () {
      return {
        session: this.initGameSession,
        awaitingAddPlayer: false,
        awaitingCardAction: [],
        awaitingPlayerAction: [],
        awaitingPlayerPass: false,
        awaitingPlayerUpdate: false,
        awaitingSessionUpdate: false,
        showInactiveCards: this.initGameSession.showInactiveCards,
        displayPlayer: this.initGameSession.loggedInPlayer || this.initGameSession.players.find(p => p.id === this.initGameSession.currentPlayerId),
        groupCardsBy: this.initGameSession.game.groupCardsBy,
        sortCardsBy: this.initGameSession.game.sortCardsBy,
        playerParams: {},
        cardParams: {}
      }
    },

    watch: {
      session: function (updatedSession) {
        this.displayPlayer = updatedSession.loggedInPlayer
        this.showInactiveCards = updatedSession.showInactiveCards
      }
    },

    computed: {
      ...mapGetters(['token', 'paths', 'currentUser']),

      updateParams: function () {
        return {
          uid: this.session.uid,
          authenticity_token: this.token,
          player: this.playerParams,
          card: this.cardParams
        }
      },

      showActionButton: function () {
        if (!this.session.loggedInPlayer) { return false }
        return this.session.playable && !this.session.started
      },

      promptClass: function () {
        if (!this.session.loggedInPlayer) { return }
        const specialClass = this.session.specialGamePhase || ['trade', 'discard'].includes(this.session.loggedInPlayer.actionPhase)
        return {
          'alert py-1 mb-0': true,
          'alert-secondary': !specialClass && !this.isCurrentPlayer(this.session.loggedInPlayer),
          'alert-success': !specialClass && this.isCurrentPlayer(this.session.loggedInPlayer),
          'alert-danger': specialClass
        }
      },

      playerPrompt: function () {
        if (!this.session.loggedInPlayer) { return }
        if (this.session.loggedInPlayer.actionPhase === 'trade' && (this.cardParams.id || this.playerParams.id)) {
          return `Trade ${this.cardParams.name || 'a card'} to ${this.playerParams.user ? this.playerParams.user.name : 'another player'}...`
        } else {
          return this.session.loggedInPlayer.actionPrompt
        }
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

      activeCards: function () {
        return this.groupedCards(this.displayPlayer.activeCards)
      },

      inactiveCards: function () {
        return this.groupedCards(this.displayPlayer.inactiveCards)
      },

      displayingLoggedInPlayer: function () {
        if (!this.session.loggedInPlayer) { return false }
        return this.displayPlayer.id === this.session.loggedInPlayer.id
      },

      displayPlayerPossessive: function () {
        if (this.displayingLoggedInPlayer) { return "Your" }
        return `${this.displayPlayer.user.name}'s`
      },

      playerButtonSubclass: function () {
        return {
          'text-left': true,
          'd-inline-block': !this.currentUser.config.showAllBadges
        }
      },
    },

    methods: {
      isCurrentPlayer: function (player) {
        if (!this.session.started) { return false }
        if (this.session.completed) { return false }
        return player.id === this.session.currentPlayerId
      },

      // Player buttons

      playerButtonClass: function (player) {
        return {
          'btn mr-2 mb-2 text-dark': true,
          'btn-light': !player.winner,
          'btn-warning': player.winner
        }
      },

      playerButtonDisabled: function (player) {
        if (!this.session.started) { return true }
        if (!this.session.allowDisplayPlayerSwitching) { return true }
        return this.displayPlayer && player.id === this.displayPlayer.id
      },

      // Card buttons

      cardClass: function (card) {
        const result = {
          'btn btn-primary my-1': true,
          [card.color]: card.color,
          'deemphasized': card.played || card.discarded
        }
        return result
      },

      cardButtonDisabled: function (card) {
        if (!this.session.loggedInPlayer) {
          return true
        } else if (this.session.loggedInPlayer.actionPhase === 'trade') {
          return !card.tradeable
        } else if (this.session.loggedInPlayer.actionPhase === 'discard') {
          return !card.active
        } else if (!this.displayingLoggedInPlayer) {
          return true
        }
        return !(card.validAction && (this.isCurrentPlayer(this.session.loggedInPlayer) || card.playableOutOfTurn))
      },

      // Player action buttons

      playerActionButtonClass: function (index) {
        if (!this.displayingLoggedInPlayer) { return }
        let count = this.session.loggedInPlayer.possibleActions.length
        return {
          'btn': true,
          'btn-dark': index + 1 === count,
          'btn-secondary btn-sm align-bottom': index + 1 < count
        }
      },

      showPlayerActionButton: function (action) {
        if (action === 'submit_trade') {
          return this.playerParams.id && this.cardParams.id
        } else {
          return true
        }
      },

      // Card sorting and grouping

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

      toggleInactiveCards: function () {
        this.showInactiveCards = !this.showInactiveCards
      },

      // Card groups

      groupedCards: function (cards) {
        return [...new Set(this.sortedCards(cards).map(i => i[this.groupCardsBy]))].map(
          title => {
            return {
              title: title,
              cards: this.sortedCards(cards).filter(i => i[this.groupCardsBy] === title).sort((a,b) => (a[this.sortCardsBy] > b[this.sortCardsBy]) ? 1 : -1)
            }
          }
        )
      },

      sortedCards: function (cards) {
        return cards.sort((a,b) => (a[this.sortGroupsBy] > b[this.sortGroupsBy]) ? 1 : -1)
      },

      // Button click handlers

      handleCardClick: function (card) {
        if (this.session.loggedInPlayer && this.session.loggedInPlayer.actionPhase === 'trade') {
          this.cardParams = card
        } else {
          this.cardAction(card)
        }
      },

      handlePlayerClick: function (player) {
        if (this.session.loggedInPlayer && this.session.loggedInPlayer.actionPhase === 'trade') {
          this.playerParams = player
        } else {
          this.displayPlayer = player
        }
      },

      handlePlayerActionClick: function (action) {
        if (action === 'cancel') {
          this.cardParams = {}
          this.playerParams = {}
        }
        this.playerAction(action)
      },

      // Async backend interactions

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

      cardAction: async function (card) {
        this.awaitingCardAction.push(card.id)
        let params = this.updateParams
        params['card_action'] = card.validAction
        try {
          const response = await this.callEndpoint('PATCH', card.updatePath, params)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          const index = this.awaitingCardAction.indexOf(card.id)
          this.awaitingCardAction.splice(index,1)
        }
      },

      playerAction: async function (action) {
        this.awaitingPlayerAction.push(action)
        let params = this.updateParams
        params['player_action'] = action
        try {
          const response = await this.callEndpoint('PATCH', this.session.loggedInPlayer.playPath, params)
          setTimeout(() => {
            if (response.data.status === 'success') {
              this.session = response.data.content.session
            }
          }, 250)
        } catch (e) {
          console.log(e)
        } finally {
          const index = this.awaitingPlayerAction.indexOf(action)
          this.awaitingPlayerAction.splice(index,1)
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
