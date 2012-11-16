function test_stack(data_set){
	// data_set is object
	/*
		{
			data: {
				x: [1,2,3,4,5],
				y: [1,2,3], [1,2,3]
			},
			
			layers: [
				{name: 'something'},
				{name: 'something2'}			
			]
			
		}
	
	*/
	
	
	var data = data_set.data;
	var layers = data_set.layers;
	
	var stack = d3.layout.stack();


	var x_points = data.x;
	var y_points_arrays = data.y;
	
	var layer_count = layers.length;
	var x_points_count = x_points.length;
	
	var d3_data_layers = stack( d3.range(layer_count).map( function(layer_idx) { 
			// for each layer		
			//map unto each xpoint
			console.log("layer_idx: " + layer_idx);
			return d3.range(x_points_count).map(function(x_idx){
								
				var hsh = {x: x_points[x_idx], y: y_points_arrays[x_idx][layer_idx] };
				console.log("\tx_idx: " + x_idx + ", (" + hsh.x + ", " + hsh.y +")");
				return hsh;
			});
	}) );
	
		

	var yStackMax = d3.max(d3_data_layers, function(layer) { return d3.max(layer, function(d) { return d.y0 + d.y; }); });
	
	console.log('yStackMax: ' + yStackMax)


	// chart boundaries 
	var margin = {top: 40, right: 10, bottom: 20, left: 10},
	    width = 960 - margin.left - margin.right,
	    height = 500 - margin.top - margin.bottom;

	var x = d3.scale.ordinal()
	    .domain(d3.range(x_points_count))
	    .rangeRoundBands([0, width], .08);

	var y = d3.scale.linear()
	    .domain([0, yStackMax])
	    .range([height, 0]);

	var color = d3.scale.linear()
	    .domain([0, layer_count - 1])
	    .range(["#aad", "#556"]);

	var xAxis = d3.svg.axis()
	    .scale(x)
	    .tickSize(0)
	    .tickPadding(6)
	    .orient("bottom");

	var svg = d3.select("#graphic-delay-causes").append("svg")
	    .attr("width", width + margin.left + margin.right)
	    .attr("height", height + margin.top + margin.bottom)
	  .append("g")
	    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

	var layer = svg.selectAll(".layer")
	    .data(d3_data_layers)
	    .enter().append("g")
	    .attr("class", "layer")
	    .style("fill", function(d, i) { return color(i); });

	var rect = layer.selectAll("rect")
	    .data(function(d) { return d; })
	  .enter().append("rect")
	    .attr("x", function(d) { return x(d.x); })
	    .attr("y", height)
	    .attr("width", x.rangeBand())
	    .attr("height", 0);

	rect.transition()
	    .delay(function(d, i) { return i * 10; })
	    .attr("y", function(d) { return y(d.y0 + d.y); })
	    .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); });

	svg.append("g")
	    .attr("class", "x axis")
	    .attr("transform", "translate(0," + height + ")")
	    .call(xAxis);


	function transitionStacked() {
	  y.domain([0, yStackMax]);

	  rect.transition()
	      .duration(500)
	      .delay(function(d, i) { return i * 30; })
	      .attr("y", function(d) { return y(d.y0 + d.y); })
	      .attr("height", function(d) { return y(d.y0) - y(d.y0 + d.y); })
	    .transition()
	      .attr("x", function(d) { return x(d.x); })
	      .attr("width", x.rangeBand());
	}

	function whatev(n){
		var arr = [];
		for(i = 0; i < n; i++){
			arr[i] = {x: Math.random() * 100, y: Math.random() * 100}
		}
		return arr;
	}

}



var the_data = 	{
		data: {
			x: d3.range(40), // [1,2,3,4,5,6,7,8,9],
			y: d3.range(40).map(function(){return [Math.random()*10 + 20 ,Math.random()*30,Math.random()*20,Math.random()*20]}) 
			//[[4,6,20], [3,6,2], [14,6,9], [4,1,2], [1,6,2], [99,4,95],[4,6,20], [3,6,2], [14,6,9], [4,1,2], [1,6,2]]
		},
		
		layers: [
			{name: 'something'},
			{name: 'something2'},
			{name: 'something3'}			
						
		]
		
	};
	
	
	test_stack(the_data);
	
	
