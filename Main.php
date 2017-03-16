 <?php
foreach($_REQUEST as $fieldName=>$fieldVal)
{
   $container = explode("=", $fieldName);
   if($container[0] =="t")
   {
    echo trim($container[1]);
   }
}
 ?>
