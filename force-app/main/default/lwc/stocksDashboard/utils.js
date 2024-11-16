// Helper function to show spinner
export function showSpinner(component) {
    component.isLoading = true;
}

// Helper function to hide spinner
export function hideSpinner(component) {
    component.isLoading = false;
}

// Helper function to sort data
export function sortData(data, fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(data));
    let keyValue = (a) => {
        return a[fieldname];
    };
    let isReverse = direction === 'asc' ? 1 : -1;

    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : '';
        y = keyValue(y) ? keyValue(y) : '';
        return isReverse * ((x > y) - (y > x));
    });

    return parseData;
}

// Helper function to initialize the chart
export function initializeChart(ctx, stockInformation, existingChart) {
    if (existingChart) {
        existingChart.destroy();
    }

    // Initialize arrays for chart data
    let closeArray = [];
    let datetimeValueArray = [];
    let highArray = [];
    let lowArray = [];
    let openArray = [];
    let volumeArray = [];

    // Process stock information
    stockInformation.forEach(entry => {
        closeArray.push(entry.close);
        datetimeValueArray.push(entry.datetimeValue);
        highArray.push(parseFloat(entry.high));
        lowArray.push(parseFloat(entry.low));
        openArray.push(parseFloat(entry.open));
        volumeArray.push(parseFloat(entry.volume));
    });

    // Create and return the chart
    return new Chart(ctx, {
        type: 'line',
        data: {
            labels: datetimeValueArray,
            datasets: [
                {
                    label: 'Highest',
                    data: highArray,
                    backgroundColor: 'rgba(11, 156, 49, 0.2)',
                    borderColor: 'rgba(11, 156, 49, 1)',
                    borderWidth: 1,
                },
                {
                    label: 'Lowest',
                    data: lowArray,
                    backgroundColor: 'rgba(75, 192, 192, 0.2)',
                    borderColor: 'rgba(75, 192, 192, 1)',
                    borderWidth: 1,
                },
            ],
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    beginAtZero: true,
                },
            },
        },
    });
}
