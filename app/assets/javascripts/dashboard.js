let createData = (data) => {
    let groupedByState = data.map(d => d.state).reduce((previous, current) => {
        if (current in previous) {
            previous[current]++;
        } else {
            previous[current] = 1;
        }
        return previous;
    }, {})

    var ctx = document.getElementById('myChart').getContext('2d');
    var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: Object.keys(groupedByState),
            datasets: [{
                label: '# of Samples',
                data: Object.values(groupedByState),
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(54, 162, 235, 0.2)',
                    'rgba(255, 206, 86, 0.2)',
                    'rgba(75, 192, 192, 0.2)',
                    'rgba(153, 102, 255, 0.2)',
                    'rgba(255, 159, 64, 0.2)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)',
                    'rgba(153, 102, 255, 1)',
                    'rgba(255, 159, 64, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            scales: {
                yAxes: [{
                    ticks: {
                        beginAtZero: true
                    }
                }]
            },
            responsive: true,
            maintainAspectRatio: false
        }
    });
}

const loadChart = () => {
    if (window.location.pathname != '/samples/dashboard') {
        return;
    }
    fetch('/samples.json')
        .then((response) => {
            return response.json();
        })
        .then((data) => {
            createData(data);
        });

}

$(document).on('turbolinks:load', () => { loadChart() });