// Initialize Web-Socket library
WEB_SOCKET_SWF_LOCATION = "WebSocketMain.swf";

// Set variables
var connected = false;
var RELOAD_TIMEOUT = 600000; // 10 minutes in ms

$(function(){
  // Get the address of the server
  SERVER_IP     = $('meta[name=server-ip]').attr("content");
  SERVER_PORT   = $('meta[name=server-port]').attr("content");
  WS_SERVER_URL = $('meta[name=ws-server-url]').attr("content");

  // prevent busting out of the frame
  ignore_next_redirect();

  // console.log safety
  if(!window.console){
    console = {
      log: function(x){ }
    };
  }

  // Set the height of the iFrame
  $('#frame').height($(window).height());

  // Start main process loop
  start_ws();
  
  // WebSocket stuff
  // ----------------------------------
  function start_ws(){
    $('#flash').text('Connecting to server...').show();

    // Connect to the web socket server
    console.log("Connecting to WebSocket server: " + WS_SERVER_URL);
    ws = new WebSocket(WS_SERVER_URL);

    // Process the WebSocket events as they come in
    ws.onmessage = function(evt){
      var data = JSON.parse(evt.data);
      process_page_update(data['data']);
    }

    ws.onopen = function(evt){
      connected = true;
      console.log('WebSocket connected...');
      $('#flash').hide();

      // Reload the page after some time.  
      // Chrome really hates re-loading iFrames all day.  This call is here
      // so that we can "resolve" this problem.  :/
      timedRefresh(RELOAD_TIMEOUT);
    }

    ws.onclose = function(evt){
      connected = false;
      console.log('WebSocket disconnected...');
      $('#flash').text('Server disconnected').show();

        //try to reconnect in 5 seconds
        setTimeout(start_ws, 5000);    
    }

    ws.onerror = function(evt){
      console.log('WebSocket generated an error...');
    }
  }

  // Handle the incoming WS messages
  // ----------------------------------
  // Respond to control signals
  function process_control(data) {
    if (data == 'start') 
      { $('#refreshing').show(); }
    else 
      { $('#refreshing').slideUp('slow'); }
  }

  // Reload the page after a timeout
  function timedRefresh(timeoutPeriod) {
    console.log(Date() + " - refresh timed for " + timeoutPeriod + " milliseconds.");
    setTimeout("if(connected) { location.reload(true); }",timeoutPeriod);
  }

  // Respond to page update
  function process_page_update(data) {
    // Update the "target" div with the current URL
    $('#target_url').html('&gt;&gt; <a href="'+data+'">'+data+'</a>');

    // Update the iFrame
    $('#frame').attr('src', data);

  }	
});

