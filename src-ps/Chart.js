const chartJs = require("chart.js");

exports.register = () => chartJs.Chart.register(...chartJs.registerables);

exports.linePlot = (elemId, labels, datasets) => {
    return () => new chartJs.Chart(elemId, {
        type: "line",
        data: {
            labels,
            datasets
        }
    })
}