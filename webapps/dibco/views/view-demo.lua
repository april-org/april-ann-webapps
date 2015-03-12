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
    BEGIN 'form'{ action='http://localhost:7001/dibco/clean', method='post',
                  enctype="multipart/form-data" }
    do
      BEGIN 'br' END 'br'
      BEGIN 'label' TEXT 'Select a model' END 'label'
      BEGIN 'select'{ name="model" }
      do
        for _,name in pairs(model.nets_list) do
          BEGIN 'option'{ value=name } TEXT(name) END 'option'
        end
      end
      END 'select'
      BEGIN 'br' END 'br'
      BEGIN 'label' TEXT 'Pick an example or upload a new file' END 'label'
      BEGIN 'select'{ name="example" }
      do
        BEGIN 'option'{ value="" } END 'option'
        for _,name in pairs(model.examples_list) do
          BEGIN 'option'{ value=name } TEXT(name) END 'option'
        end
      end
      END 'select'
      BEGIN 'br' END 'br'
      BEGIN 'label' TEXT 'Select an image' END 'label'
      BEGIN 'input'{ type='file', name='img_dirty_file' } END 'input'
      BEGIN 'br' END 'br'
      BEGIN 'input'{ type='submit', value='Send' } END 'input'
    end
    END 'form'
  end
  END 'body'
  
end
END 'html' 
