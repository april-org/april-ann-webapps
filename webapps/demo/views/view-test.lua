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
    BEGIN 'p'
    do
      TEXT 'Test image, RNN activations for parity task'
    end
    END 'p'
    BEGIN 'image' { src='/demo/image' } END 'image'
  end
  END 'body'
  
end
END 'html' 
