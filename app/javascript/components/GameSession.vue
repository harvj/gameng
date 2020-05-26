<template>
  <div :id="`session-${session.uid}`">
    <h2>{{ session.game.name }}</h2>

    <div class="session-info">
      <p>session id: {{ session.uid }}</p>
      <p>started: {{ session.started_at }}</p>
    </div>

    <div class="session-cards">
      <div v-for="(player, index) in session.players">
        <h6>{{ player.name }}</h6>
        <a href="#" @click="sortCards(index)">sort</a>
        <div v-for="card in player.cards">
          <button class="btn">
            <i :class="`fas fa-${card.iconClass}`"></i>
            {{ card.name }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'game-session',

    props: {
      initGameSession: Object
    },

    data: function () {
      return {
        session: this.initGameSession
      }
    },

    methods: {
      sortCards: function (index) {
        var cards = this.session.players[index].cards
        this.session.players[index].cards = cards.sort((a,b) => a.sort - b.sort)
      }
    }
  }
</script>
