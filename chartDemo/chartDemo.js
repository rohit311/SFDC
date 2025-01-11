import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import ChartJs from '@salesforce/resourceUrl/ChartJs';

export default class ChartDemo extends LightningElement {
  @track isChartJsInitialized = false;

  renderedCallback() {
    if (this.isChartJsInitialized) {
    return;
    }
    this.isChartJsInitialized = true;
    Promise.all([
      loadScript(this, ChartJs)
    ])
      .then(() => {
        // Chart.js library loaded
        this.initializePieChart();
      })
      .catch(error => {
        console.log('Error loading Chart.js');
        console.error(error);
      });
  }
  initializePieChart() {
  const ctx = this.template.querySelector('canvas').getContext('2d');
    // eslint-disable-next-line no-new
    new window.Chart(ctx, {
      type: 'pie',
    data: {
    labels: ['Website Forms', 'Social Media ', 'Email Marketing Campaigns', 'Referrals', 'Partner Channels', 'Networking'],
    datasets: [{
    label: '# of Votes',
    data: [12, 19, 3, 5, 2, 3],
    backgroundColor: [
    'rgba(255, 99, 132, 0.5)',
    'rgba(54, 162, 235, 0.5)',
    'rgba(255, 206, 86, 0.5)',
    'rgba(75, 192, 192, 0.5)',
    'rgba(153, 102, 255, 0.5)',
    'rgba(255, 159, 64, 0.5)'
    ]
    }]
    },
    options: {
    responsive: true,
    maintainAspectRatio: false,
    title: {
    display: true,
    text: "Lead Sources"
    }
    },
    });
  }
}