const chartJs = require("chart.js");

exports.register = () => chartJs.Chart.register(...chartJs.registerables);

exports.linePlot = (elemId, label, labels, data) => {
    console.log({
        label,
        labels,
        data
    });
    return () => new chartJs.Chart(elemId, {
        type: "line",
        data: {
            labels,
            datasets: [{
                label,
                data,
                backgroundColor: ['rgba(255, 99, 132, 0.2)'],
                borderWidth: 1
            }]
        }
    })
}