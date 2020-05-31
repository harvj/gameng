<template>
  <div id="games-index" class="p-2">
    <h2>What are we playing?</h2>
    <div v-for="game in games"
      :key="game.key"
    >
      <a :href="game.uri">{{ game.name }}</a>
    </div>
  </div>
</template>

<script>

export default {
  name: 'games-index',

  props: {
    initGames: Array
  },

  data: function () {
    return {
      games: this.initGames
    }
  }
}

</script>
