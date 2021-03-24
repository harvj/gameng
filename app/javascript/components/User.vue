<template>
  <div class="p-2">
    <div class="rounded mb-2 p-2 bg-light">
      <div class="px-2" v-for="game in gameStats">
        <strong><a :href="`/${game.key}`">{{ game.name }}</a></strong>:
        {{ game.play_count }} games played
      </div>
    </div>

    <div v-if="activeSessions.length > 0"
      class="rounded bg-warning p-3"
    >
      <h6>Active Sessions</h6>
      <div class="py-2" v-for="session in activeSessions">
        {{ session.name }}: <a :href="`/sessions/${session.uid}`">{{ session.uid }}</a>
      </div>
    </div>

    <div class="mt-1 p-2 container" v-for="count in Object.keys(userStats).reverse()">
      <h3>
        {{ count }} players
      </h3>
      <div v-if="byPlayerCount(count)" class="pb-2 text-muted">
        <span>{{ byPlayerCount(count).game_count }} games </span>
        <span>(average: {{ byPlayerCount(count).avg }}, </span>
        <span>std dev: {{ byPlayerCount(count).stddev }})</span>
      </div>
      <div class="row px-1">
        <div v-for="name in columnNames" class="col-sm">
          <a href="#"
            :class="columnClass(count, name)"
            @click.prevent="reSort(count, name)"
          >
            {{ name.replace(/_/g, ' ') }}
          </a>
        </div>
      </div>
      <div class="row px-1" v-for="stats in sortedStats(count)">
        <div class="col-sm" v-for="name in columnNames">
          {{ stats[name] }}
        </div>
      </div>
    </div>
    <div class="mt-1 p-2 container">
      <h3>Single double stats</h3>
      <div class="row px-1">
        <div v-for="name in singleDoubleColumnNames" class="col-sm">
          <a href="#"
            :class="sdColumnClass(name)"
            @click.prevent="sdReSort(name)"
          >
            {{ name.replace(/_/g, ' ') }}
          </a>
        </div>
      </div>
      <div class="row px-1" v-for="stats in sdSortedStats">
        <div class="col-sm" v-for="name in singleDoubleColumnNames">
          {{ stats[name] }}
        </div>
      </div>
    </div>
    <h3 class="mt-1 p-2">By turn order</h3>
    <div class="mt-1 p-2 container" v-for="count in Object.keys(turnOrderStats).reverse()">
      <div class="row px-1">
        <div v-for="name in turnOrderColumnNames" class="col-sm">
          <a href="#"
            :class="turnOrderColumnClass(count, name)"
            @click.prevent="turnOrderReSort(count, name)"
          >
            {{ name.replace(/_/g, ' ') }}
          </a>
        </div>
      </div>
      <div class="row px-1" v-for="stats in turnOrderSortedStats(count)">
        <div class="col-sm" v-for="name in turnOrderColumnNames">
          {{ stats[name] }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'user',

    props: {
      activeSessions: { type: Array, required: true },
      gameStats: { type: Array, required: true },
      scoreStats: { type: Array, required: true },
      singleDoubleStats: { type: Array, required: true },
      turnOrderStats: { type: Object, required: true },
      userStats: { type: Object, required: true }
    },

    data: function () {
      return {
        sortBy: {
          '5': 'average',
          '4': 'average',
          '3': 'average'
        },
        sdSortBy: 'sd_played_avg',
        turnOrderSortBy: {
          '5': 'turn_order',
          '4': 'turn_order',
          '3': 'turn_order'
        }
      }
    },

    computed: {
      columnNames: function () {
        return ['username', 'games_played', 'average', 'high_score', 'low_score', 'wins', 'doubles_per']
      },

      turnOrderColumnNames: function () {
        return ['turn_order', 'average', 'high_score', 'low_score', 'wins']
      },

      singleDoubleColumnNames: function () {
        return ['username', 'games', 'sd_played_avg', 'sd_played_count', 'sd_played_on_avg', 'sd_played_on_count']
      },

      sdSortedStats: function () {
        const mod = this.sdSortBy === 'username' ? -1 : 1
        return this.singleDoubleStats.sort((a,b) => (b[this.sdSortBy] > a[this.sdSortBy]) ? 1 * mod : -1 * mod)
      },
    },

    methods: {
      sortedStats: function (count) {
        const mod = ['username', 'low_score'].includes(this.sortBy[count]) ? -1 : 1
        return this.userStats[count].sort((a,b) => (b[this.sortBy[count]] > a[this.sortBy[count]]) ? 1 * mod : -1 * mod)
      },

      turnOrderSortedStats: function (count) {
        const mod = ['turn_order', 'low_score'].includes(this.turnOrderSortBy[count]) ? -1 : 1
        return this.turnOrderStats[count].sort((a,b) => (b[this.turnOrderSortBy[count]] > a[this.turnOrderSortBy[count]]) ? 1 * mod : -1 * mod)
      },

      columnClass: function (count, name) {
        return {
          'font-weight-light': name !== this.sortBy[count],
          'font-weight-bold': name === this.sortBy[count]
        }
      },

      turnOrderColumnClass: function (count, name) {
        return {
          'font-weight-light': name !== this.turnOrderSortBy[count],
          'font-weight-bold': name === this.turnOrderSortBy[count]
        }
      },

      sdColumnClass: function (name) {
        return {
          'font-weight-light': name !== this.sdSortBy,
          'font-weight-bold': name === this.sdSortBy
        }
      },

      reSort: function (count, name) {
        this.sortBy[count] = name
      },

      turnOrderReSort: function (count, name) {
        this.turnOrderSortBy[count] = name
      },

      sdReSort: function (name) {
        this.sdSortBy = name
      },

      byPlayerCount: function (count) {
        return this.scoreStats.find(i => i.player_count == count)
      }
    }
  }
</script>
