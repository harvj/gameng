export default {
  methods: {
    callEndpoint: function (method, url, params) {
      const requestConfig = { method, url }
      if (params) {
        if (method === 'GET') {
          const urlParams = new window.URLSearchParams()
          for (const key in params) urlParams.append(key, params[key])
          requestConfig.params = urlParams
        } else {
          requestConfig.data = params
        }
      }

      return new Promise((resolve, reject) => {
        this.axios(requestConfig)
          .then((response) => {
            if (response.status !== 200) {
              return reject(response)
            }
            return resolve(response)
          }).catch((response) => {
            return reject(response)
          })
      })
    }
  }
}
