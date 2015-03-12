BEGIN 'html'
do
  
  BEGIN 'head'
  do
    BEGIN 'title'
    do
      TEXT 'TEST'
    end
    END 'title'
  end
  END 'head' 

  BEGIN 'body'
  do
    BEGIN 'form'{ action='http://localhost:7001/dibco/clean/1', method='post',
                  enctype="multipart/form-data" }
    do
      BEGIN 'label' TEXT 'Select an image' END 'label'
      BEGIN 'input'{ type='file', name='img_dirty_file' } END 'input'
      BEGIN 'input'{ type='text', name='text1', value='3' } END 'input'
      BEGIN 'input'{ type='text', name='text2', value='4' } END 'input'
      BEGIN 'br' END 'br'
      BEGIN 'input'{ type='submit', value='Send' } END 'input'
    end
    END 'form'
  end
  END 'body'
  
end
END 'html' 
