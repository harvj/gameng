export default {
  methods: {
    titleize: function (value) {
      if (value) {
        return value.replace(/_/g, ' ').replace(/(\w+)/g, function (match) {
          return match.charAt(0).toUpperCase() + match.slice(1)
        })
      } else {
        return ''
      }
    }
  }
}
