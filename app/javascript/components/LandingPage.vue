<template>
  <div id="landing-page">
    <h1>GameNG</h1>
    <div v-if="loggedIn">
      <p>Let's play some Modern Art, {{ this.currentUser.email }}!</p>
      <a :href="paths.logoutPath" data-method="delete" rel="nofollow">Logout</a>
    </div>
    <div v-else>
      <p>Go on and log in!</p>
      <a :href="paths.loginPath">Login</a>
    </div>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'landing-page',

  computed: {
    ...mapGetters([
      'currentUser',
      'loggedIn',
      'paths'
    ])
  }
}
</script>
