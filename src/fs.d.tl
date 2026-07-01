local record fs
   record Buffer
   end
   
   read_file: function(path: string): Buffer
   write_file: function(path: string, content: Buffer)
   read_file_to_string: function(path: string): string
   write_file_from_string: function(path: string, content: string)
end

return fs
