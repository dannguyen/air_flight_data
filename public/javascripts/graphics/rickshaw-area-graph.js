function rickshaw_area_graph(data_series, id_selector){
    var palette = new Rickshaw.Color.Palette();


   
   var graph = new Rickshaw.Graph( {
        element: document.querySelector(id_selector),
        width: 900,
        height: 500,
        series: data_series,
    renderer: 'bar'

    } );

    var axes = new Rickshaw.Graph.Axis.Time( { graph: graph } );



/*
var graph = new Rickshaw.Graph( {
            element: document.querySelector(id_selector),
    width: 235,
    height: 85,
    renderer: 'area',
    stroke: true,
    series: [ {
        data: [ { x: 0, y: 40 }, { x: 1, y: 49 }, { x: 2, y: 38 }, { x: 3, y: 30 }, { x: 4, y: 32 } ],
        color: '#9cc1e0'
    }, {
        data: [ { x: 0, y: 40 }, { x: 1, y: 49 }, { x: 2, y: 38 }, { x: 3, y: 30 }, { x: 4, y: 32 } ],
        color: '#cae2f7'
    } ]
} );
*/



    graph.render();

}