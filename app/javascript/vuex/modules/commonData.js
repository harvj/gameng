const state = {
  currentUser: null,
  loggedIn: null,
  paths: {},
  railsEnv: null,
  token: null
}

const getters = {
  currentUser: state => state.currentUser,
  loggedIn: state => state.loggedIn,
  paths: state => state.paths,
  railsEnv: state => state.railsEnv,
  token: state => state.token
}

const mutations = {
  loadCommon (state, data) {
    state.currentUser = data.currentUser
    state.loggedIn = data.loggedIn
    state.paths = data.paths
    state.railsEnv = data.railsEnv
    state.token = data.token
  },

  updateCurrentUser (state, user) {
    state.currentUser = user
  }
}

export default { state, getters, mutations }
