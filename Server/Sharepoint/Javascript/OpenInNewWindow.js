<script language="JavaScript">
_spBodyOnLoadFunctionNames.push("PrepareLinks");
 
function PrepareLinks()
{
  //Luetaan linkit taulukkoon
   var anchors = document.getElementsByTagName("a");
     
  for (var x=0; x<anchors.length; x++)
   {
      //Sisältääkö linkki #openinnewwindow?
       if (anchors[x].outerHTML.indexOf('#openinnewwindow')>0)
        {
           //otetaan openinnewwindow linkki talteen
           oldText = anchors[x].outerHTML;
           //Muotoillaan linkki uusiksi ja lisätään target määritys perään
           newText = oldText.replace(/#openinnewwindow/,'" target="_blank');
           //Kirjoitetaan linkki sivulle
           anchors[x].outerHTML = newText;
         }
     }
 }

 // lisää tämä jokaisen urlin päätteeksi: #openinnewwindow
 // esim: http://www.google.fi#openinnewwindow
</script>


