export default {
  callEndpoint: function (method, url, params, handleManually = false) {
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
            this.setFlash({ status: 'error', content: 'A server error has occured. Please try again.' })
            return reject(response)
          }
          if (handleManually) return resolve(response)
          this.setFlash({ status: response.data.status, content: response.data.content })
          return (response.data.status === 'error' ? reject(response) : resolve(response))
        }).catch((response) => {
          this.setFlash({ status: 'error', content: 'A server error has occured. Please try again.' })
          return reject(response)
        })
    })
  }
}
