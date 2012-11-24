// Put your application scripts here

$(document).ready(function(){
	console.log("document.ready");
   
   $(".isotope").isotope();
   
   $(".box.it").hover(function(){
		$(this).addClass('hover');
	}, function(){
		$(this).removeClass('hover');
	});
});