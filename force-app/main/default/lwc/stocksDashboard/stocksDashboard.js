import { LightningElement, track, wire } from 'lwc';
import getNasdaqStocks from '@salesforce/apex/TwelveDataApi.getNasdaqStocks';
import getNasdaqStockDetails from '@salesforce/apex/TwelveDataApi.getTimeSeriesData';
import { loadScript } from 'lightning/platformResourceLoader';
import ChartJs from '@salesforce/resourceUrl/chart';
import { showSpinner, hideSpinner, sortData, initializeChart } from './utils';

// Define columns for the data table
const columns = [
    { label: 'Symbol', fieldName: 'symbol', type: 'text', sortable: true },
    { label: 'Name', fieldName: 'name', type: 'text', sortable: true },
    { label: 'Exchange', fieldName: 'exchange', type: 'text', sortable: true },
    { label: 'MIC Code', fieldName: 'mic_code', type: 'text', sortable: true },
    { label: 'Country', fieldName: 'country', type: 'text', sortable: true },
    { label: 'Type', fieldName: 'type', type: 'text', sortable: true },
    { label: 'FIGI Code', fieldName: 'figi_code', type: 'text', sortable: true },
    { label: 'Action', type: 'button', typeAttributes: { label: 'Details', name: 'action' } },
];

export default class StocksDashboard extends LightningElement {
    @track data;
    @track error;
    @track columns = columns;
    @track timeSeriesData;
    @track chart;
    @track sortBy;
    @track sortDirection;
    @track companyName;
    @track isLoading = true;
    @track graphLoaded = false;

    // Fetch stock data from Apex on component load
    @wire(getNasdaqStocks)
    wiredStocks({ error, data }) {
        if (data) {
            this.data = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
        hideSpinner(this);
    }

    // Handle sorting of data table columns
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.data = sortData(this.data, this.sortBy, this.sortDirection);
    }

    // Handle row actions (Details button click)
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const symbol = row.symbol;
        this.companyName = row.name;

        if (actionName === 'action') {
            // Fetch stock details and load chart
            getNasdaqStockDetails({ symbol })
                .then(result => {
                    this.timeSeriesData = result;
                    this.error = undefined;
                    loadScript(this, ChartJs)
                        .then(() => {
                            this.chart = initializeChart(this.template.querySelector('canvas').getContext('2d'), result, this.chart);
                        })
                        .catch(error => {
                            console.error('Error loading Chart.js:', error);
                        });
                })
                .catch(error => {
                    this.error = error;
                    this.timeSeriesData = undefined;
                });
        }
    }
}
