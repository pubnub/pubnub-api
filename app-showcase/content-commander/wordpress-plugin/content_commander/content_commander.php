<?php
/**
 * @package Content_Commander
 * @version 0.1
 */
/*
Plugin Name: Content Commander
Plugin URI: http://github.com/pubnub
Description: Push Content. Set up your api keys <a href="plugins.php?page=cc-config">here</a>.
Author: Philip Deschaine
Version: 0.1
Author URI: http://pubnub.com
*/


function init_pubnub_viewer() {
    echo "
      <!-- PUBNUB -->
      <div sub-key='sub-f3307e99-6a4a-11e1-870f-affeca838b29' ssl='off' origin='pubsub.pubnub.com' id='pubnub'></div>
      <script src='http://cdn.pubnub.com/pubnub-3.1.min.js'></script>
      <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'></script>
      <script>(function(){
        PUBNUB.subscribe({
          channel    : 'content_commander', 
          restore    : false,      
          callback   : function(message) {
            console.log('got message: ' + JSON.stringify(message));
            if (message.name) {
              PUBNUB.events.fire(message.name, message.data);
            }
          },
          disconnect : function() { 
            console.log('Connection Lost.');
          },
          reconnect  : function() { 
            console.log('And were Back!');
          }
        });
        PUBNUB.events.bind('arb_html', function(data) {
          $('#cc_content').html('<div id=\'cc_content\'>'+ data.html + '</div>');
        });
      })();</script>
	";
}

function init_pubnub_commander() {
    $pub_key =  get_option('pubnub_publish_key');
    if ($pub_key == NULL) $pub_key = "";

    $sub_key =  get_option('pubnub_subscribe_key');
    if ($sub_key == NULL) $sub_key = "";

    echo sprintf("
      <!-- PUBNUB -->
      <div pub-key='%s' sub-key='%s' ssl='off' origin='pubsub.pubnub.com' id='pubnub'></div>
      <script src='http://cdn.pubnub.com/pubnub-3.1.min.js'></script>
      <script>(function(){
        PUBNUB.subscribe({
          channel    : 'content_commander', 
          restore    : false,      
          callback   : function(message) {
            console.log('got message: ' + JSON.stringify(message));
            if (message.name) {
              PUBNUB.events.fire(message.name, message.data);
            }
          },
          disconnect : function() { 
            console.log('Connection Lost.');
          },
          reconnect  : function() { 
            console.log('And were Back!');
          }
        });
      })();</script>", $pub_key, $sub_key);
}

function cc_content_box() {
    echo "
        <div id='cc_content'></div>
    ";

}

// Now we set that function up to execute when the admin_notices action is called
add_action( 'wp_footer', 'init_pubnub_viewer' );
add_action( 'admin_footer', 'init_pubnub_commander' );
add_action( 'loop_start', 'cc_content_box' );

function logo() {
    //$logo_url =  get_option('siteurl') + "/wp-content/plugins/content_commander/pubnub-logo-200.png";
	//echo "<img src='" + $logo_url + "' id='content_commander_logo'/ >";
	echo "<a href='plugins.php?page=commander'><img src='/wordpress/wp-content/plugins/content_commander/pubnub-logo-200.png' id='content_commander_logo'/ ></a>";
}
add_action( 'admin_notices', 'logo' );


// We need some CSS to position the paragraph
function cc_css() {
	// This makes sure that the positioning is also good for right-to-left languages
	$x = is_rtl() ? 'left' : 'right';

	echo "
	<style type='text/css'>
	#content_commander_logo {
		float: $x;
		padding-$x: 2px;
		padding-top: 2px;		
		margin: 0;
		height: 22px;
	}
    #arb_html {
        width: 50%; 
        min-height: 300px;
    }
	</style>
	";
}

add_action( 'admin_head', 'cc_css' );


function cc_pages() {
	if ( function_exists('add_submenu_page') )
		add_submenu_page('plugins.php', __('Content Commander Configuration'), __('Content Commander Configuration'), 'manage_options', 'cc-config', 'cc_conf');
		add_submenu_page('plugins.php', __('Content Commander'), __('Content Commander'), 'manage_options', 'commander', 'commander');
}

function commander() {
    echo "
    <script src='http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js'></script>
    <div id='arbitrary_html_box' class='box left'>
      <h2> Content to push: </h2>
      <form>
        <textarea name='arb_html' id='arb_html' value=''></textarea><br/>
        <input type='submit' id='arb_html_submit' name='arb_html_submit' value='Push'/>
      </form>
    </div>
    <script>
    $('#arb_html_submit').click( function(e) {
      e.preventDefault();

      var html = $('#arb_html').val();
      if ((html == undefined) && (html.length == 0)) { return; }

      PUBNUB.publish({ 
        channel : 'content_commander', 
        message : {
          'name'   : 'arb_html',
          'data'   : {
            'html'   : html
          }
        }
      });
    });
    </script>
    "; 
}

function cc_conf() {
    if ( isset($_POST['pubnub_conf_submit']) ) {
        if ( function_exists('current_user_can') && !current_user_can('manage_options') )
            die(__('Nope.'));
		if ( isset( $_POST['pubnub_publish_key'] ) )
            update_option( 'pubnub_publish_key', $_POST['pubnub_publish_key']);
		if ( isset( $_POST['pubnub_subscribe_key'] ) )
            update_option( 'pubnub_subscribe_key', $_POST['pubnub_subscribe_key']);
    }

    echo sprintf("
        <table>
            <form method='POST' target=''>
            <tr> 
                <td> Publish Key</td>
                <td><input type='text' value='%s' name='pubnub_publish_key' id='pubnub_publish_key'/></td>
            </tr>
            <tr>
                <td>Subscribe Key </td>
                <td><input type='text' value='%s' name='pubnub_subscribe_key' id='pubnub_subscribe_key'/></td>
            </tr>
            <tr>
                <td><input type='submit' value='Go'/></td>
            </tr>
            <input type='hidden' value='true' name='pubnub_conf_submit' id='pubnub_conf_submit'/>
            </form>
        </table>
        ", 
        get_option('pubnub_publish_key'),
        get_option('pubnub_subscribe_key')
        );
}

add_action( 'admin_menu', 'cc_pages' );
?>
