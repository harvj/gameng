<template>
  <div class="p-2">
    <div class="p-2 container" v-for="count in ['5','4']">
      <h3>{{ count }} players</h3>
      <div class="row px-1">
        <div class="col-sm"></div>
        <div class="col-sm font-weight-light">games played</div>
        <div class="col-sm font-weight-light">average</div>
        <div class="col-sm font-weight-light">high score</div>
        <div class="col-sm font-weight-light">low score</div>
        <div class="col-sm font-weight-light">wins</div>
      </div>
      <div class="row px-1" v-for="stats in userStats[count]">
        <div class="col-sm">{{ stats.username }}</div>
        <div class="col-sm">{{ stats.games_played }}</div>
        <div class="col-sm">{{ stats.average }}</div>
        <div class="col-sm">{{ stats.high_score }}</div>
        <div class="col-sm">{{ stats.low_score }}</div>
        <div class="col-sm">{{ stats.win_count }}</div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'user-stats',

    props: {
      userStats: { type: Object, required: true }
    }
  }
</script>
