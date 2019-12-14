<template>
  <div>

    <!--Stats cards-->
    <div class="row">
      <div class="col-md-6 col-xl-4" v-for="stats in statsCards" :key="stats.title">
        <stats-card>
          <div class="icon-big text-center" :class="`icon-${stats.type}`" slot="header">
            <i :class="stats.icon"></i>
          </div>
          <div class="numbers text-left" slot="content">
            <p>房客姓名：{{stats.name}}</p>
            <p>地址：{{stats.address}}</p>
            <p>租金：{{stats.value}}</p>
            <p>{{stats.title}}</p>
          </div>
          <div class="numbers text-left" slot="footer">
            <p>房客評論：{{stats.footerText}}</p>

          </div>
        </stats-card>
      </div>
    </div>

    <!--Charts-->
 
  </div>
</template>
<script>
import { StatsCard } from "@/components/index";
export default {
  components: {
    StatsCard,
    
  },
  /**
   * Chart data used to render stats, charts. Should be replaced with server data
   */
  data() {
    return {
      statsCards: [
        {
          type: "warning",
          icon: "ti-server",
          name: "Alan",
          address: "台北市大安區長興街58號",
          value: "7000",
          footerText: "這間房子XXXXXXX這間房子XXXXXXX這間房子XXXXXXX這間房子XXXXXXX",
          footerIcon: "ti-reload"
        },
        {
          type: "warning",
          icon: "ti-server",
          name: "Alan",
          address: "台北市大安區長興街58號",
          value: "7000",
          footerText: "這間房子XXXXXXX這間房子XXXXXXX這間房子XXXXXXX這間房子XXXXXXX",
          footerIcon: "ti-reload"
        },
        {
          type: "warning",
          icon: "ti-server",
          name: "Alan",
          address: "台北市大安區長興街58號",
          value: "7000",
          footerText: "這間房子XXXXXXX這間房子XXXXXXX這間房子XXXXXXX這間房子XXXXXXX",
          footerIcon: "ti-reload"
        },
      ],
    
      activityChart: {
        data: {
          labels: [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "Mai",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec"
          ],
          series: [
            [542, 543, 520, 680, 653, 753, 326, 434, 568, 610, 756, 895],
            [230, 293, 380, 480, 503, 553, 600, 664, 698, 710, 736, 795]
          ]
        },
       
      },
   
    };
  }
};
</script>
<style>
</style>
