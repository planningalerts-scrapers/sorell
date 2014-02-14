<?
date_default_timezone_set('Australia/Sydney');

require 'scraperwiki.php';
require 'scraperwiki/simple_html_dom.php';

$html = scraperwiki::scrape("http://www.sorell.tas.gov.au/planning-building/planning/item/282");
$dom = new simple_html_dom();
$dom->load($html);

$comment_url = "http://www.sorell.tas.gov.au/planning-building/planning/item/282";
$description = "Description not available. See 'Read more information' link.";

foreach($dom->find("table.docmanlist") as $data){
    $application_lists = $data->find("td.name");
    
    foreach ($application_lists as $app)
    {
        $application_text = $app->find("a.name");
        foreach ($application_text as $text)
        {
            $elements = explode(" - ", $text->innertext);
            $id_messy = trim($elements[0]);
            $id_explode = explode(" ", $id_messy);
            $representations = explode("Representations Close", $elements[2]);
            $date_scraped = date('Y-m-d', strtotime("now"));
            $council_reference = $id_explode[0];
            
            //Saving data:
            $unique_keys = array('council_reference');
            $row = array('council_reference'=>$id_explode[0], 'address'=>$elements[1].", TAS", 'description'=>$description, 
                'info_url'=>'http://www.sorell.tas.gov.au'.$text->href, 'comment_url'=>$comment_url, 'date_scraped'=>$date_scraped);
          
            //Check to see if the record has already been inserted into the database.
            if (scraperwiki::get_var($council_reference) == "")
            {
              //No record found. Insert.
              print "New application found. Inserting ".$council_reference."\n";
              scraperwiki::save_sqlite($unique_keys, $row, 'data');
              scraperwiki::save_var($council_reference, $council_reference);
            }
            else 
            {
              //Record is found, so skip.
              print "Record found. Skipping ".$council_reference."\n";
            }
        } 
    }
}

?>

