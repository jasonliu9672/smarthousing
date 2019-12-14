<template>
  <div class="wrapper">
    <side-bar>
      <template slot="links">
        <sidebar-link to="/dashboard" name="My Contracts" icon="ti-file"/>
        <sidebar-link to="/stats" name="Add a new contract" icon="ti-pencil-alt2" />
        <sidebar-link to="/table-list" name="Timeline" icon="ti-view-list-alt"/>
        <!-- <sidebar-link to="/typography" name="Typography" icon="ti-text"/> -->
        <!-- <sidebar-link to="/icons" name="Icons" icon="ti-pencil-alt2"/> -->
        <!-- <sidebar-link to="/maps" name="Map" icon="ti-map"/> -->
        <!-- <sidebar-link to="/notifications" name="Notifications" icon="ti-bell"/> -->
      </template>
      <mobile-menu>
        <li class="nav-item">
          <a class="nav-link">
            <i class="ti-panel"></i>
            <p>Stats</p>
          </a>
        </li>

        <li class="nav-item">
          <a class="nav-link">
            <i class="ti-settings"></i>
            <p>Settings</p>
          </a>
        </li>
        <li class="divider"></li>
      </mobile-menu>
    </side-bar>
    <div class="main-panel">
      <top-navbar></top-navbar>

      <dashboard-content @click.native="toggleSidebar">

      </dashboard-content>

    </div>
  </div>
</template>
<style lang="scss">
</style>
<script>
import TopNavbar from "./TopNavbar.vue";
import DashboardContent from "./Content.vue";
import MobileMenu from "./MobileMenu";
export default {
  components: {
    TopNavbar,
    DashboardContent,
    MobileMenu
  },
  methods: {
    toggleSidebar() {
      if (this.$sidebar.showSidebar) {
        this.$sidebar.displaySidebar(false);
      }
    }
  }
};
</script>
