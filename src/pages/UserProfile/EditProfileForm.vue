<template>
  <card class="card" title="Edit Contract">
    <div>
      <form @submit.prevent>
        <div class="row">
          <!-- <div class="col-md-5">
            <fg-input type="text"
                      label="Company"
                      :disabled="true"
                      placeholder="Paper dashboard"
                      v-model="user.company">
            </fg-input>
          </div> -->
          <div class="col-md-3">
            <fg-input type="text"
                      label="Tenant ID"
                      placeholder="Username"
                      v-model="user.username">
            </fg-input>
          </div>
          <!-- <div class="col-md-4">
            <fg-input type="email"
                      label="Username"
                      placeholder="Email"
                      v-model="user.email">
            </fg-input>
          </div> -->
        </div>

        <div class="row">
          <div class="col-md-6">
            <fg-input type="text"
                      label="Rent ( Per Month )"
                      placeholder=""
                      v-model="user.rent">
            </fg-input>
          </div>
          <div class="col-md-6">
            <fg-input type="text"
                      label="Start Time"
                      placeholder=""
                      v-model="user.startTime">
            </fg-input>
          </div>
        </div>

        <div class="row">
          <div class="col-md-12">
            <fg-input type="text"
                      label="House Address"
                      placeholder="Home Address"
                      v-model="user.address">
            </fg-input>
          </div>
        </div>

        <div class="row">
          <div class="col-md-4">
            <fg-input type="text"
                      label="City"
                      placeholder="City"
                      v-model="user.city">
            </fg-input>
          </div>
          <div class="col-md-4">
            <fg-input type="text"
                      label="Country"
                      placeholder="Country"
                      v-model="user.country">
            </fg-input>
          </div>
          <div class="col-md-4">
            <fg-input type="number"
                      label="Postal Code"
                      placeholder="ZIP Code"
                      v-model="user.postalCode">
            </fg-input>
          </div>
        </div>

        <div class="row">
          <div class="col-md-12">
            <div class="form-group">
              <label>More About House</label>
              <textarea rows="5" class="form-control border-input"
                        placeholder="Here can be your description"
                        v-model="user.aboutMe">

              </textarea>
            </div>
          </div>
        </div>
        <div class="text-center">
          <p-button type="info"
                    round
                    @click.native.prevent="updateProfile">
            Create a Contract
          </p-button>
        </div>
        <div class="clearfix"></div>
      </form>
    </div>
  </card>
</template>
<script>
export default {
  data() {
    return {
      user: {
        username: "12351523",
        email: "",
        rent: "7000",
        startTime: "2020/01/01",
        lastName: "Faker",
        address: "Melbourne, Australia",
        city: "Melbourne",
        postalCode: "",
        aboutMe: `Forniture including desks, tables, ......`
      }
    };
  },
  methods: {
    updateProfile() {
      alert("Your data: " + JSON.stringify(this.user));
    }
  }
};
</script>
<style>
</style>
