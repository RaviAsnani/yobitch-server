jQuery(document).ready(function() {
	
    /*
	    Top menu
	*/
	$('.show-menu a, .hide-menu a').tooltip();
	// show/hide menu
	$('.show-menu a').on('click', function(e) {
		e.preventDefault();
		$(this).fadeOut(100, function(){ $('nav').slideDown(); });
	});
	$('.hide-menu a').on('click', function(e) {
		e.preventDefault();
		$('nav').slideUp(function(){ $('.show-menu a').fadeIn(); });
	});
	// navigation
	$('nav a').on('click', function(e) {
		e.preventDefault();
		var element_class = $(this).attr('class');
		var scroll_to = 0;
		var nav_height = $('nav').height();
		if(element_class == 'menu-top') { scroll_to = $(".top-content").offset().top; }
		else if(element_class == 'menu-features') { scroll_to = $(".features").offset().top - nav_height - 60; }
		else if(element_class == 'menu-download') { scroll_to = $(".call-to-action-text").offset().top - nav_height - 60; }
		else if(element_class == 'menu-subscribe') { scroll_to = $(".subscribe").offset().top - nav_height - 60; }
		else if(element_class == 'menu-testimonials') { scroll_to = $(".testimonials").offset().top - nav_height - 60; }
		else if(element_class == 'menu-about-us') { scroll_to = $(".whos-behind").offset().top - nav_height - 60; }
		else if(element_class == 'menu-contact') { scroll_to = $(".contact").offset().top - nav_height - 60; }
		
		if($(window).scrollTop() != scroll_to && element_class !== undefined) {
			$('html, body').animate({scrollTop: scroll_to}, 1000);
		}
	});
	// learn more
	$('.top-arrow i').on('click', function() {
		var nav_height = $('nav').height();
		var nav_display = $('nav').css('display');
		var features_top = $('.features').offset().top;
		
		if(nav_display == 'block') { scroll_to = features_top - nav_height - 60; }
		else if(nav_display == 'none') { scroll_to = features_top - 60; }
		
		if($(window).scrollTop() != scroll_to) {
			$('html, body').animate({scrollTop: scroll_to}, 1000);
		}
	});
	// features
	$('.features-box-1-icon').on('click', function() {
		var nav_height = $('nav').height();
		var nav_display = $('nav').css('display');
		var feature_index = $('.features-box-1-icon').index($(this));
		var feature_scroll_to = $('.single-feature-text').eq(feature_index).offset().top;
		
		if(nav_display == 'block') { scroll_to = feature_scroll_to - nav_height - 60; }
		else if(nav_display == 'none') { scroll_to = feature_scroll_to - 60; }
		
		if($(window).scrollTop() != scroll_to) {
			$('html, body').animate({scrollTop: scroll_to}, 1000);
		}
	});
	
    /*
        Background slideshow
    */
    $('.top-content').backstretch([
      "assets/img/backgrounds/1.jpg"
    , "assets/img/backgrounds/2.jpg"
    , "assets/img/backgrounds/3.jpg"
    ], {duration: 3000, fade: 750});
    
    /*
        Testimonials
    */
    $('.testimonial-active').html('<p>' + $('.testimonial-single:first p').html() + '</p>');
    $('.testimonial-single:first .testimonial-single-image img').css('opacity', '1');
    
    $('.testimonial-single-image img').on('click', function() {
    	$('.testimonial-single-image img').css('opacity', '0.5');
    	$(this).css('opacity', '1');
    	var new_testimonial_text = $(this).parent('.testimonial-single-image').siblings('p').html();
    	$('.testimonial-active p').fadeOut(300, function() {
    		$(this).html(new_testimonial_text);
    		$(this).fadeIn(400);
    	});
    });
    
    /*
	    Show latest tweets
	*/
	$('.latest-tweets .tweets').tweet({
		modpath: 'assets/twitter/',
		username: 'anli_zaimi',
		page: 1,
		count: 5,
		loading_text: 'loading ...'
	});
	
	$('.latest-tweets .tweets .tweet_list li').append('<span class="tweet_nav"></span>');
	$('.latest-tweets .tweets .tweet_list li:first .tweet_nav').css('background', '#fff');
	$('.latest-tweets .tweets .tweet_list li .tweet_time').hide();
	$('.latest-tweets .tweets .tweet_list li .tweet_text').hide();
	$('.latest-tweets .tweet-active').html($('.latest-tweets .tweets .tweet_list li:first .tweet_text').html());

	$('.latest-tweets .tweets .tweet_list li .tweet_nav').on('click', function() {
		$('.latest-tweets .tweets .tweet_list li .tweet_nav').css('background', 'rgba(255, 255, 255, 0.6)');
		var clicked_tweet_nav = $(this);
    	var new_tweet_text = clicked_tweet_nav.siblings('.tweet_text').html();
    	$('.latest-tweets .tweet-active').fadeOut(300, function() {
    		$(this).html(new_tweet_text);
    		$(this).fadeIn(400);
    	});
    	clicked_tweet_nav.css('background', '#fff');
    });

    /*
	    Google maps
	*/
    var position = new google.maps.LatLng(45.067883, 7.687231);
    $('.contact-address .map').gmap({'center': position, 'zoom': 15, 'disableDefaultUI':true, 'callback': function() {
            var self = this;
            self.addMarker({'position': this.get('map').getCenter() });	
        }
    });

    /*
        Subscription form
    */
    $('.success-message').hide();
    $('.error-message').hide();

    $('.subscribe form').submit(function(e) {
    	e.preventDefault();
        var postdata = $('.subscribe form').serialize();
        $.ajax({
            type: 'POST',
            url: 'assets/subscribe.php',
            data: postdata,
            dataType: 'json',
            success: function(json) {
                if(json.valid == 0) {
                    $('.success-message').hide();
                    $('.error-message').hide();
                    $('.error-message').html(json.message);
                    $('.error-message').fadeIn();
                }
                else {
                    $('.error-message').hide();
                    $('.success-message').hide();
                    $('.subscribe form').hide();
                    $('.success-message').html(json.message);
                    $('.success-message').fadeIn();
                }
            }
        });
    });
    
    /*
	    Contact form
	*/
    $('.contact-form form input[type="text"], .contact-form form textarea').on('focus', function() {
    	$('.contact-form form input[type="text"], .contact-form form textarea').removeClass('contact-error');
    });
	$('.contact-form form').submit(function(e) {
		e.preventDefault();
	    $('.contact-form form input[type="text"], .contact-form form textarea').removeClass('contact-error');
	    var postdata = $('.contact-form form').serialize();
	    $.ajax({
	        type: 'POST',
	        url: 'assets/contact.php',
	        data: postdata,
	        dataType: 'json',
	        success: function(json) {
	            if(json.emailMessage != '') {
	                $('.contact-form form .contact-email').addClass('contact-error');
	            }
	            if(json.subjectMessage != '') {
	                $('.contact-form form .contact-subject').addClass('contact-error');
	            }
	            if(json.messageMessage != '') {
	                $('.contact-form form textarea').addClass('contact-error');
	            }
	            if(json.emailMessage == '' && json.subjectMessage == '' && json.messageMessage == '') {
	                $('.contact-form form').fadeOut('fast', function() {
	                    $('.contact-form').append('<p>Thanks for contacting us! We will get back to you very soon.</p>');
	                });
	            }
	        }
	    });
	});

    
});

