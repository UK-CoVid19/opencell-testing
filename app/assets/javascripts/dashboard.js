import 'chart.js';

const data = fetch('/samples.json')
    .then((response) => {
        return response.json();
    })
    .then((data) => {
        createData(data);
    });

let createData = (data) => {
    console.log(data);
    let groupedByState = data.reduce((previous, current) => {
        if (current.state in previous){
            previous[current.state] ++;
        }else{
            previous[current.state] = 1;
        }
        return previous;
    }, {})

    var ctx = document.getElementById('myChart').getContext('2d');
    var myChart = new Chart(ctx, {
        type: 'bar',
        data: {
            labels: groupedByState.keys(),
            datasets: [{
                label: '# of Votes',
                data: groupedByState.values(),
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
            }
        }
    });
}