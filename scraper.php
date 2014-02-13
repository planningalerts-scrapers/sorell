<?
date_default_timezone_set('Australia/Sydney');

require 'scraperwiki.php';
require 'scraperwiki/simple_html_dom.php';

$html = scraperwiki::scrape("http://www.sorell.tas.gov.au/planning-building/planning/item/282");
$dom = new simple_html_dom();
$dom->load($html);

$planning_alert = array();

$comment_url = "http://www.sorell.tas.gov.au/planning-building/planning/item/282";
$description = "";

foreach($dom->find("table.docmanlist") as $data){
    $application_lists = $data->find("td.name");
    $closing_dates = $data->find("td.center");
    foreach ($application_lists as $app)
    {

        $application_text = $app->find("a.name");
        foreach ($application_text as $text)
        {
            $elements = explode(" - ", $text->innertext);
            $id_messy = trim($elements[0]);
            $id_explode = explode(" ", $id_messy);
            //print "council_reference: " . $id_explode[0];
            //print " | ";
            //print "address: " . $elements[1] . ", TAS";
            
            //print " | ";
            $representations = explode("Representations Close", $elements[2]);
            //print "on_notice_to: " . date('c', strtotime(trim($representations[1])));
            //print " | ";
            //print "info_url: http://www.sorell.tas.gov.au" . $text->href;
            $date_scraped = date('c', strtotime("now"));
            //print "date_scraped: " . $date_scraped;
            
            //Saving data:
            $unique_keys = array($id_explode[0]);
            $row = array('council_reference'=>$id_explode[0], 'address'=>$elements[1], 'description'=>$description, 
                'info_url'=>$text->href, 'comment_url'=>$comment_url, 'date_scraped'=>$date_scraped);
            
            $data_sql = scraperwiki::select("* from swdata");
            
            print_r($data_sql);
            
            //scraperwiki::save_sqlite($unique_keys, $row);
            
            print "\n\n";
            
        }
        
        
    }

}




?>

