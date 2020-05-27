<template>
  <div id="games-index">
    <h2>What are we playing?</h2>
    <div
      v-for="game in games"
      :key="game.slug"
    >
      <a :href="game.showPath">
        {{ game.name }}
      </a>
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
