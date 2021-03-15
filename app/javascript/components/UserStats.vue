<template>
  <div class="p-2">
    <div class="p-2 container" v-for="count in Object.keys(userStats).reverse()">
      <h3>{{ count }} players</h3>
      <div class="row px-1">
        <div class="col-sm"></div>
        <div v-for="name in columnNames" class="col-sm">
          <a href="#"
            :class="columnClass(count, name)"
            @click.prevent="reSort(count, name)"
          >
            {{ name.replace('_', ' ') }}
          </a>
        </div>
      </div>
      <div class="row px-1" v-for="stats in sortedStats(count)">
        <div class="col-sm">{{ stats.username }}</div>
        <div class="col-sm" v-for="name in columnNames">
          {{ stats[name] }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    name: 'user-stats',

    props: {
      userStats: { type: Object, required: true }
    },

    data: function () {
      return {
        sortBy: {
          '5': 'average',
          '4': 'average',
          '3': 'average'
        }
      }
    },

    computed: {
      columnNames: function () {
        return ['games_played', 'average', 'high_score', 'low_score', 'wins', 'doubles_per']
      }
    },

    methods: {
      sortedStats: function (count) {
        const mod = this.sortBy[count] === 'low_score' ? -1 : 1
        return this.userStats[count].sort((a,b) => (b[this.sortBy[count]] > a[this.sortBy[count]]) ? 1 * mod : -1 * mod)
      },

      columnClass: function (count, name) {
        return {
          'font-weight-light': name !== this.sortBy[count],
          'font-weight-bold': name === this.sortBy[count]
        }
      },

      reSort: function (count, name) {
        this.sortBy[count] = name
      }
    }
  }
</script>
