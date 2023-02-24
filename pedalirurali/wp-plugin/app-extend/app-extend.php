<?php
/**
 * Plugin Name: Estensione servizi per mobile app
 * Plugin URI: https://bitbucket.org/Bonny/pedalirurali_app/src/master/wp-plugin/
 * Description: Estensione servizi per mobile app: https://bitbucket.org/Bonny/pedalirurali_app/src/master/
 * Version: 1.0
 * Author: Luca Bonaldo
 * Author URI: http://www.lbonaldo.it
 */

function pr_css_event() {
    ?>
<style>
    .mec-event-date, .mec-event-time {display:none !important;}
    .mec-single-event-date, .mec-single-event-time  {display:none !important;}
</style>
    <?php
}

add_shortcode( 'css-events', 'pr_css_event' );


function pr_normalize_time($s) {
    $s = trim($s);
    if (strlen($s) == 1) {
        $s = '0' . $s;
    }
    return $s;
}

class App_RestApi_Rest extends WP_REST_Posts_Controller {
	
	protected $namespace;
    protected $rest_base;
    
    const EVENTS = "events";
    const PERMANENT = "permanent";

	public function __construct() {
		$this->namespace = 'pr/v1';
	}

	public function register_routes() {

        register_rest_route( $this->namespace, '/events/organizer', array(
			array(
				'methods'             => WP_REST_Server::READABLE,
                'callback'            => array( $this, 'get_event_organizer' )
			),
            'schema' => null
        ) );

		register_rest_route( $this->namespace, '/events/categories', array(
			array(
				'methods'             => WP_REST_Server::READABLE,
                'callback'            => array( $this, 'get_event_categories' )
			),
            'schema' => null
        ) );

        register_rest_route( $this->namespace, '/events/locations', array(
			array(
				'methods'             => WP_REST_Server::READABLE,
                'callback'            => array( $this, 'get_event_locations' )
			),
            'schema' => null
        ) );

        register_rest_route( $this->namespace, '/events/list', array(
			array(
				'methods'             => WP_REST_Server::READABLE,
                'callback'            => array( $this, 'get_event_list' ),
                'args' => array(
                    'include' => array(
                        'validate_callback' => function($param, $request, $key) {

                            $isNUmeric = true;
                            $params = explode(",", $param);

                            foreach ( $params as $p ) {
                                $isNUmeric = $isNUmeric && is_numeric($p);
                            }

                            return $isNUmeric;
                      }
                    ),
                    'type' => array(
                        'validate_callback' => function($param, $request, $key) {
                            return $param == 'events' || $param == "permanent";
                          }
                    ),
                    'favorite' => array(
                        'validate_callback' => function($param, $request, $key) {
                            return is_numeric($param);
                          }
                    ),
                    'page' => array(
                        'validate_callback' => function($param, $request, $key) {
                            return is_numeric($param);
                          }
                    ),
                    'per_page' => array(
                        'validate_callback' => function($param, $request, $key) {
                            return is_numeric($param);
                          }
                    ),
                    'category' => array(
                        'validate_callback' => function($param, $request, $key) {
                            return is_numeric($param);
                          }
                    ),
                    'location' => array(
                        'validate_callback' => function($param, $request, $key) {
                            return is_numeric($param);
                          }
                    ),
                    'organizer' => array(
                        'validate_callback' => function($param, $request, $key) {
                             return is_numeric($param);
                        }
                    )
                )
			),
            'schema' => array( $this, 'get_public_item_schema' )
        ) );

        register_rest_route( $this->namespace, '/events/metadata', array(
			array(
				'methods'             => WP_REST_Server::READABLE,
                'callback'            => array( $this, 'get_event_md' )
			),
            'schema' => null
        ) );


        $like_par = array(
            'uid' => array(
                'validate_callback' => function($param, $request, $key) {
                    return $param != null && strlen($param) > 0;
               }
            ),
            'pid' => array(
                'validate_callback' => function($param, $request, $key) {
                    return is_numeric($param);
               }
            )
        );

        register_rest_route( $this->namespace, '/events/favorite', array(
			array(
				'methods'             => WP_REST_Server::CREATABLE,
                'callback'            => array( $this, 'favorite_event' ),
                'args'                => $like_par,
                'permission_callback' => function () {
                    return current_user_can( 'read' );
                }
            ),
            array(
				'methods'             => WP_REST_Server::DELETABLE,
                'callback'            => array( $this, 'unfavorite_event' ),
                'args'                => $like_par,
                'permission_callback' => function () {
                    return current_user_can( 'read' );
                }
			),
            'schema' => null
        ) );

    }
    
    function normalize($strNum){
        return intval(trim(sanitize_text_field($strNum)));
    }

    function is($request, $name){
        $parameters = $request->get_params();
        return !empty($parameters[$name]) && $this->normalize($parameters[$name]) > 0;
    }

    public function get_event_list( $request ) {
  
        $parameters = $request->get_params();

        $per_page = $this->normalize($parameters['per_page']);
        $per_page = $per_page == 0 ? 10 : $per_page;
        $page = $this->normalize($parameters['page']);
        $page = $page == 0 ? 1 : $page;
        $type = $parameters['type'];

        $query = "";
        $where_date = "";
        $where_ids = "";
        $order_by = "";
        $join_date = "";
        $join_favorite_count = ", '0' as favorites ";

        if ($this->is($request, 'month') && $this->is($request, 'year')) {
           $year = $this->normalize($parameters['year']);
           $month = $this->normalize($parameters['month']) +1;
           $from = date("Y-m-d", mktime(0, 0, 0, $month-1, 1, $year) );
           $to = date("Y-m-d", mktime(0, 0, 0, $month,   0, $year) );
           $where_date = " AND D.dstart BETWEEN '${from}' AND '${to}' ";
        } else if ($this->is($request, 'month') && !$this->is($request, 'year')) {            
            $year = intval(date('Y'));
            $month = $this->normalize($parameters['month']) +1;
            $from = date("Y-m-d", mktime(0, 0, 0, $month-1, 1, $year) );
            $to = date("Y-m-d", mktime(0, 0, 0, $month,   0, $year) );
            $where_date = " AND D.dstart BETWEEN '${from}' AND '${to}' ";
         } else if (!$this->is($request, 'month') && $this->is($request, 'year')) {
            $year = $this->normalize($parameters['year']);
            $from = date("Y-m-d", mktime(0, 0, 0, 1, 1, $year) );
            $to = date("Y-m-d", mktime(0, 0, 0, 13,  0, $year) );
            $where_date = " AND D.dstart BETWEEN '${from}' AND '${to}' ";
        }

        $c = 0;
        $left_join = [];
        $left_join_where = [];
        foreach(['category', 'location'] as $i) {
            if ($this->is($request, $i)) {
                $alias = "tt" . $c;
                $left_join[] =" LEFT JOIN pr_term_relationships AS ${alias} ON (PP.ID = ${alias}.object_id) ";
                $left_join_where[] = " ${alias}.term_taxonomy_id = " . $this->normalize($parameters[$i]);
            }
            $c++;
        }

        if ($type == self::EVENTS) {
            $alias = "tt_evt";
            $left_join[] =" LEFT JOIN pr_term_relationships AS ${alias} ON (PP.ID = ${alias}.object_id) ";
            $left_join_where[] = " ${alias}.term_taxonomy_id = 49";

            // caso eventi con data HOIN con tabella pr_mec_dates and orderb by data inizio evento
            $join_date = " INNER JOIN pr_mec_dates D on (P.id = D.post_id) ";
            $order_by = " ORDER BY D.tstart ";

            //TODO decommentare per attivare contatore lato app
            //$join_favorite_count = " ,( SELECT count(F.post_id) from pr_favorite_events F WHERE F.post_id = P.ID ) as favorites ";
        }

        if ($type == self::PERMANENT) {
            $alias = "tt_pmt";
            $left_join[] =" LEFT JOIN pr_term_relationships AS ${alias} ON (PP.ID = ${alias}.object_id) ";
            $left_join_where[] = " ${alias}.term_taxonomy_id = 50";

            //No join con data altrimenti escono doppioni, il plugin insericce N record per ogni giorno
        }

        if ($this->is($request, 'favorite')) {
            $left_join = [];
            $where_date = "";
            $where_ids = " AND P.id in ( " . $parameters['include'] . " )";
        }
        
        $query = "SELECT P.id, P.post_title as title, P.post_content as content " . $join_favorite_count;
        $query .= " FROM pr_posts P ";
        $query .= $join_date;
        if (!empty($left_join)) {
            $query .= " INNER JOIN (
                SELECT PP.ID as ID FROM pr_posts PP
                     " . implode(" ", $left_join) . "
                     WHERE   
                         (" . implode(" AND ", $left_join_where) . ")
                         AND PP.post_type = 'mec-events' 
                         AND PP.post_status = 'publish'
                 GROUP BY PP.ID 
         ) P2 on P2.ID = P.ID";
        }
        $query .= " WHERE P.post_type = 'mec-events' AND P.post_status = 'publish' ";
        $query .= $where_date;
        $query .= $where_ids;
        $query .= $order_by;
        $query .= " LIMIT " . (($page - 1) * $per_page) .  ", " . $per_page;
//return $query;
        global $wpdb;
        $rs = $wpdb->get_results($query, ARRAY_A);
        
        $posts = [];
        foreach ( $rs as $i ) {
            $posts[] = $this->prepare_event($i, $type);
        }

        return rest_ensure_response( $posts );
    }

    function prepare_event($p, $type = NULL) {

        $postID = intval($p['id']);

        $p['id'] = $postID;
        $p['favorites'] = !$p['favorites'] ? 0 : intval($p['favorites']);
        $p['excerpt'] =  get_the_excerpt($postID);
        $p['link'] = get_post_permalink($postID);
        $p['thumbnail'] = get_the_post_thumbnail_url($postID);
        if (!$p['thumbnail']) {
            $p['thumbnail'] = "";
        }

        $categories = [];
        $rs = get_the_terms($postID, 'mec_category' );
        if ($rs) {
            foreach ($rs as $i){
                $categories[] = strval($i->term_id);
            }
        }

        $p['categories'] = $categories;

        if ($type != NULL) {
            $p['type'] = $type;
        } else {
            // eseguo la query solo nel caso dei favoriti, perchè sono misti
            $labels = [];
            $rs = get_the_terms($postID, 'mec_label' );
            if ($rs) {
                foreach ($rs as $i){
                    $labels[] = strval($i->term_id);
                }
            }
            if (in_array(49, $labels)) {
                $type = self::EVENTS;
            } else if (in_array(50, $labels)) {
                $type = self::PERMANENT;
            } else {
                $type = "unknown";
            }
            $p['type'] = $type;
        }

        $meta = array();

        global $wpdb;
        $rs = $wpdb->get_results("SELECT meta_key, meta_value FROM pr_postmeta WHERE post_id = " . $postID, OBJECT);
        foreach($rs as $r) { 
            $meta[$r->meta_key] = $r->meta_value;
        }

        $p['start_date'] = $p['end_date'] = $p['allday'] = $p['event_link'] = "";

        if ($meta['mec_more_info']) {
            $p['event_link'] = $meta['mec_more_info'];
        }
        if ($meta['mec_allday']) {
            $p['allday'] = $meta['mec_allday'];
        }
        if ($meta['mec_start_date']) {
            $p['start_date'] = $meta['mec_start_date'];
        }
        if ($meta['mec_end_date']) {
            $p['end_date'] = $meta['mec_end_date'];
        }

        $p['organizer_id'] = $p['location_id'] = -1;

        if ($meta['mec_organizer_id']) {
            $p['organizer_id'] = $meta['mec_organizer_id'];
        }
        if ($meta['mec_location_id']) {
            $p['location_id'] = $meta['mec_location_id'];
        }

        $p['start_time'] = $p['end_time'] = "";

        if ($this->normalize($meta['mec_allday']) == 0) {
            $p['start_time'] = $meta['mec_start_time_hour'] . ':' . pr_normalize_time($meta['mec_start_time_minutes']) . ' ' . $meta['mec_start_time_ampm'];
            $p['end_time'] = $meta['mec_end_time_hour'] . ':' . pr_normalize_time($meta['mec_end_time_minutes']) . ' ' . $meta['mec_end_time_ampm'];
        }


        //$p['meta'] = $meta;

        return $p;
    }

    function get_cats( $taxonomy ) {
  
        global $wpdb;
        $result = [
            array('id'=>'-1', 'name'=>'Seleziona..')
        ];
        $query = "SELECT t.term_id as id,t.name "
               . "FROM pr_term_taxonomy as tt, pr_terms as t "
               . "WHERE tt.term_id=t.term_id and tt.taxonomy='" . $taxonomy . "' "
               . "order by t.name";
        $rs = $wpdb->get_results($query, OBJECT);
        foreach($rs as $r) {
            $result[] = $r;
        }
        return  $result;
    
    }

    public function get_event_organizer( $request ) {
        return $this->get_cats('mec_organizer');
    }

    public function get_event_locations( $request ) {
        return $this->get_cats('mec_location');
    }

	public function get_event_categories( $request ) {
        return $this->get_cats('mec_category');
    }
    
    public function get_event_md( $request ) {
        return array(
            'locations'  => $this->get_cats('mec_location'),
            'categories' => $this->get_cats('mec_category'),
            'organizer'  => $this->get_cats('mec_organizer')
        );
    }

    function setFavotite($request, $opt) {
        $parameters = $request->get_params();
        $args = array( 
            'uid' => trim(sanitize_text_field($parameters['uid'])), 
            'post_id' => $this->normalize($parameters['pid'])
        );
        $replace = array('%s', '%d');
        global $wpdb;
        switch($opt) {
            case "INS":
                $wpdb->insert('pr_favorite_events', $args, $replace);
            break;
            case "DEL":
                $wpdb->delete('pr_favorite_events', $args, $replace);
            break;
            default:
        }
    }

    public function favorite_event( $request ) {
        $this->setFavotite($request, "INS");
        return array();
    }

    public function unfavorite_event( $request ) {
        $this->setFavotite($request, "DEL");
        return array();
    }
}


function register_app_restapi_controller() {
	$controller = new App_RestApi_Rest();
    $controller->register_routes();
}

add_action( 'rest_api_init', 'register_app_restapi_controller' );