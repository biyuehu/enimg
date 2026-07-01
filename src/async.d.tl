local record async
  record Aff<T>
  end

  next: function<T, R>(aff: Aff<T>, callback: function(data: T): R): Aff<R>
  catch: function<R>(aff: Aff<any>, callback: function(error: any): R): Aff<any>
  finally: function<R>(aff: Aff<any>, callback: function(): R): Aff<any>
end

return async
