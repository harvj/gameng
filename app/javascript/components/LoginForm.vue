<template>
  <div id='login-form'>
    <form
      accept-charset="UTF-8"
      method="post"
      action="/users/sign_in"
    >
      <input name="utf8" type="hidden" value="✓">
      <input type="hidden" name="authenticity_token" :value="csrfToken">
      <div class="form-group col-md-3">
        <label for="username">Username</label>
        <input type="text" class="form-control" id="username"
          v-model="username"
        >
      </div>
      <div class="form-group col-md-3">
        <label for="password">Password</label>
        <input type="password" class="form-control" id="password"
          v-model="password"
        >
      </div>
      <div class="col-md-3">
        <button type="submit" name="commit" class="btn btn-dark">Login</button>
      </div>
    </form>
  </div>
</template>

<script>
  import { mapGetters } from 'vuex'

  export default {
    name: 'login-form',

    data: function () {
      return {
        username: '',
        password: ''
      }
    },

    computed: {
      ...mapGetters(['paths', 'token']),

      csrfToken: function () {
        return document.getElementsByName('csrf-token')[0].content
      }
    }
  }

</script>
