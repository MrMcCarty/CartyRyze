 <?php
     $json = json_decode(file_get_contents('php://input')); //allow you to get all content
     
     
     $value_1 = $json->data[0]->Object1; // get the object in question (table start to 0)
     $value_2 = $json->data[1]->Object2;
 
     
     echo json_encode(array('YourValue1'=>$value_1, 'YourValue2'=>$value_2)); //don't forget to re-encode the array
 ?>
 
 
