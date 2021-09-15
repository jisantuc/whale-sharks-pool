const plotly = require("plotly");

exports.linePlot = (elemId, data) => {
    return () => plotly.newPlot(elemId, data, "lines");
}

exports.markersPlot = (elemId, data) => {
    return () => plotly.newPlot(elemId, data, "markers");
}

exports.linesPlusMarkersPlot = (elemId, data) => {
    return () => plotly.newPlot(elemId, data, "lines+markers");
}