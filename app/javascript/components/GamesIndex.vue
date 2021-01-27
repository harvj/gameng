<template>
  <div id="games-index" class="p-3">
    <h6 class="px-1">What are we playing?</h6>
    <h2 class="px-1 pt-2" v-for="game in games" :key="game.key">
      <a :href="game.uri">{{ game.name }}</a>
    </h2>
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
