BEGIN 'html'
do
  
  BEGIN 'head'
  do
    BEGIN 'title'
    do
      TEXT 'DIBCO demo result'
    end
    END 'title'
  end
  END 'head' 

  BEGIN 'body'
  do

    TEXT 'Please wait, the process may take a few minutes.'
    
    BEGIN 'table'
    do
      
      BEGIN 'tr' BEGIN 'td' TEXT 'Model' BEGIN 'b' TEXT(model.model) END 'b' END 'td' END 'tr'
      
      BEGIN 'tr' BEGIN 'td' BEGIN 'b' TEXT 'Dirty image' END 'b' END 'td' END 'tr'
      
      BEGIN 'tr' BEGIN 'td' BEGIN 'a'{ href="/dibco/images/dirty/" .. model.hashed_name }
      BEGIN 'image'{ width=model.w, height=model.h, src="/dibco/images/dirty/" .. model.hashed_name } END 'image'
      END 'a' END 'td' END 'tr'

      BEGIN 'tr' BEGIN 'td' BEGIN 'b' TEXT 'Clean image' END 'b' END 'td' END 'tr'
      
      BEGIN 'tr' BEGIN 'td' BEGIN 'a'{ href="/dibco/images/clean/"..model.hashed_name }
      BEGIN 'image'{ name="refresh", src="/dibco/resources/loading.gif" } END 'image'
      END 'a' END 'td' END 'tr'
    
    end
    END 'table'
    
    BEGIN 'script' { language='JavaScript', type="text/javascript" }
    do
      local image_src = "/dibco/images/clean/"..model.hashed_name
      TEXT(string.format([[
function Start() {
  var t     = 20; // Interval in Seconds
  var image = new Image();
  var time  = new Date().getTime();
  image.src = "%s?" + time;
  image.onload = function() {
      document.images["refresh"].src = image.src;
  };
  image.onerror = function() {
      setTimeout("Start()", t*1000);
  };
} 
Start();
]], image_src, image_src))
    end
    END 'script'

  end
  END 'body'
  
end
END 'html' 

--[[ AJAX SOLUTION FOR IMAGE REFRESH
var xhr = new XMLHttpRequest();
xhr.onreadystatechange = function(){
    if (this.readyState == 4 && this.status == 200){
        //this.response is what you're looking for
        handler(this.response);
        console.log(this.response, typeof this.response);
        var img = document.getElementById('img');
        var url = window.URL || window.webkitURL;
        img.src = url.createObjectURL(this.response);
    }
}
xhr.open('GET', 'http://jsfiddle.net/img/logo.png');
xhr.responseType = 'blob';
xhr.send();     
]]
