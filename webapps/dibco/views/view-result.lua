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
      BEGIN 'image'{ width=model.w, height=model.h, src="/dibco/images/clean/" .. model.hashed_name } END 'image'
      END 'a' END 'td' END 'tr'
    
    end
    END 'table'
    
  end
  END 'body'
  
end
END 'html' 
