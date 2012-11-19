function rickshaw_time_series_line(data_series, id_selector){
    var palette = new Rickshaw.Color.Palette();


   
   var graph = new Rickshaw.Graph( {
        element: document.querySelector(id_selector),
        width: 900,
        height: 500,
        series: data_series,
    renderer: 'line'

    } );

    var axes = new Rickshaw.Graph.Axis.Time( { graph: graph } );



    graph.render();

}