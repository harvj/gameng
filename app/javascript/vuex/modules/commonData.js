const state = {
  currentUser: null,
  loggedIn: null,
  paths: {},
  railsEnv: null
}

const getters = {
  currentUser: state => state.currentUser,
  loggedIn: state => state.loggedIn,
  paths: state => state.paths,
  railsEnv: state => state.railsEnv
}

const mutations = {
  loadCommon (state, data) {
    state.currentUser = data.currentUser
    state.loggedIn = data.loggedIn
    state.paths = data.paths
    state.railsEnv = data.railsEnv
  }
}

export default { state, getters, mutations }
