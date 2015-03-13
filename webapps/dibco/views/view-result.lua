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
      BEGIN 'image'{ src="/dibco/images/clean/" .. model.hashed_name,
                     --width=model.w, height=model.h,
                     name="refresh",
                   } END 'image'
      END 'a' END 'td' END 'tr'
    
    end
    END 'table'
    
    BEGIN 'script' { language='JavaScript', type="text/javascript" }
    do
      TEXT(string.format([[
var t = 20 // Interval in Seconds
function Start() { 
  document.images["refresh"].src = "%s?" + new Date().getTime();
  setTimeout("Start()", t*1000) 
} 
Start();
]], "/dibco/images/clean/"..model.hashed_name))
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
